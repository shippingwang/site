#!/usr/bin/env bash
# 拼个人站 dist/；编入 llm 书仓与 research 笔记仓
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"

rm -rf "$DIST"
mkdir -p "$DIST"
cp -a "$ROOT/public/." "$DIST/"

resolve_llm_dir() {
  if [[ -n "${LLM_DIR:-}" && -f "${LLM_DIR}/网站/mkdocs.yml" ]]; then
    echo "$LLM_DIR"
    return
  fi
  # 本机：与 site 并列的 现代大模型
  if [[ -f "$ROOT/../现代大模型/网站/mkdocs.yml" ]]; then
    echo "$ROOT/../现代大模型"
    return
  fi
  # CI / Cloudflare：拉公开仓 shippingwang/llm
  local cache="$ROOT/.cache/llm"
  if [[ ! -f "$cache/网站/mkdocs.yml" ]]; then
    mkdir -p "$ROOT/.cache"
    rm -rf "$cache"
    git clone --depth 1 https://github.com/shippingwang/llm.git "$cache"
  fi
  echo "$cache"
}

resolve_research_dir() {
  if [[ -n "${RESEARCH_DIR:-}" && -f "${RESEARCH_DIR}/build.py" ]]; then
    echo "$RESEARCH_DIR"
    return
  fi
  if [[ -f "$ROOT/../research/build.py" ]]; then
    echo "$ROOT/../research"
    return
  fi
  local cache="$ROOT/.cache/research"
  if [[ ! -f "$cache/build.py" ]]; then
    mkdir -p "$ROOT/.cache"
    rm -rf "$cache"
    git clone --depth 1 https://github.com/shippingwang/research.git "$cache"
  fi
  echo "$cache"
}

write_placeholder() {
  mkdir -p "$DIST/book/llm"
  cat >"$DIST/book/llm/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>现代大模型</title>
  <meta http-equiv="refresh" content="0;url=/book/" />
  <link rel="canonical" href="https://shippingwang.com/book/" />
  <script>location.replace("/book/");</script>
</head>
<body>
  <p><a href="/book/">书架</a></p>
</body>
</html>
HTML
}

build_book() {
  local llm web
  llm="$(resolve_llm_dir)"
  web="$llm/网站"
  echo "book source → $web"

  if ! command -v python3 >/dev/null; then
    echo "no python3, skip book" >&2
    write_placeholder
    return
  fi

  python3 -m pip install -q -r "$web/requirements.txt"
  # sync 失败也不挡：用仓里已有 docs 继续 build
  if [[ -f "$web/sync_content.py" ]]; then
    python3 "$web/sync_content.py" || echo "sync_content failed, using existing docs" >&2
  fi
  python3 -m mkdocs build --config-file "$web/mkdocs.yml"

  rm -rf "$DIST/book/llm"
  mkdir -p "$DIST/book/llm"
  cp -a "$web/site/." "$DIST/book/llm/"
  # 丛书入口在 /book/ 书架；/book/llm/ 不再单独列三册
  cat >"$DIST/book/llm/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>现代大模型</title>
  <meta http-equiv="refresh" content="0;url=/book/" />
  <link rel="canonical" href="https://shippingwang.com/book/" />
  <script>location.replace("/book/");</script>
</head>
<body>
  <p><a href="/book/">书架</a></p>
</body>
</html>
HTML
  echo "book → $DIST/book/llm"
}

if build_book; then
  :
else
  echo "book build failed, placeholder" >&2
  write_placeholder
fi

build_research() {
  local src
  src="$(resolve_research_dir)"
  echo "research source → $src"
  if ! command -v python3 >/dev/null; then
    echo "no python3, skip research" >&2
    return 1
  fi
  python3 "$src/build.py"
  rm -rf "$DIST/research"
  mkdir -p "$DIST/research"
  cp -a "$src/dist/." "$DIST/research/"
  echo "research → $DIST/research"
}

if build_research; then
  :
else
  echo "research build failed; keeping public/research placeholder" >&2
fi

echo "built → $DIST"
