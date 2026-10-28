#!/usr/bin/env bash
# 一键：把本地改动推进对应 GitHub 仓，并触发 site CI 重新组装线上站。
#
#   ./scripts/publish.sh              # 默认 all
#   ./scripts/publish.sh all
#   ./scripts/publish.sh research
#   ./scripts/publish.sh llm
#   ./scripts/publish.sh site
#   ./scripts/publish.sh research llm # 可多选
#
# 环境变量（可选）：
#   RESEARCH_DIR  LLM_DIR  MSG
set -euo pipefail

SITE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RESEARCH_DIR="${RESEARCH_DIR:-$SITE_ROOT/../research}"
LLM_DIR="${LLM_DIR:-$SITE_ROOT/../现代大模型}"
MSG="${MSG:-publish $(date +%Y-%m-%d)}"

TARGETS=()
if [[ $# -eq 0 ]]; then
  TARGETS=(all)
else
  TARGETS=("$@")
fi

want() {
  local t="$1"
  local x
  for x in "${TARGETS[@]}"; do
    if [[ "$x" == "all" || "$x" == "$t" ]]; then
      return 0
    fi
  done
  return 1
}

push_repo() {
  # $1=dir  $2=label  $3...=git add paths (relative to dir)
  local dir="$1" label="$2"
  shift 2
  if [[ ! -d "$dir/.git" ]]; then
    echo "skip $label: not a git repo ($dir)" >&2
    return 0
  fi
  echo "==> $label"
  (
    cd "$dir"
    local paths=()
    local p
    for p in "$@"; do
      if [[ -e "$p" ]]; then
        paths+=("$p")
      fi
    done
    if [[ ${#paths[@]} -eq 0 ]]; then
      echo "    no matching paths, skip"
      return 0
    fi
    git add -- "${paths[@]}"
    if git diff --cached --quiet; then
      if [[ -n "$(git log "origin/$(git rev-parse --abbrev-ref HEAD)"..HEAD --oneline 2>/dev/null || true)" ]]; then
        git push origin HEAD
        echo "    pushed existing commits"
      else
        echo "    clean, nothing to push"
      fi
      return 0
    fi
    git commit -m "$MSG ($label)"
    git push origin HEAD
    echo "    pushed"
  )
}

trigger_site() {
  echo "==> trigger site CI"
  (
    cd "$SITE_ROOT"
    # 若刚推过真实 site 改动，再空提交一次也无妨，保证 rebuild
    git commit --allow-empty -m "chore: rebuild site ($MSG)"
    git push origin HEAD
  )
  echo "done → wait CI → https://shippingwang.com/"
}

# —— research：先本地 build，再推源文件（dist 在 gitignore）——
if want research; then
  if [[ -f "$RESEARCH_DIR/build.py" ]]; then
    echo "==> research build"
    python3 "$RESEARCH_DIR/build.py"
  fi
  push_repo "$RESEARCH_DIR" research \
    posts static build.py README.md publish.sh
fi

# —— llm：公式检查/修复 → 再推书稿 + 站点生成脚本 ——
if want llm; then
  echo "==> llm math check"
  python3 "$LLM_DIR/网站/check_math.py" --fix
  push_repo "$LLM_DIR" llm \
    书稿 网站 sync_notion.py wrangler.toml LICENSE .github .gitignore
fi

# —— site 壳：public / scripts / wrangler ——
if want site; then
  push_repo "$SITE_ROOT" site \
    public scripts wrangler.toml README.md .github
fi

# 只要动过任一内容仓，或显式 all/site，就触发一次 site 重建
if want all || want research || want llm || want site; then
  trigger_site
fi
