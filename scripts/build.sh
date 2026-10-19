#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"

rm -rf "$DIST"
mkdir -p "$DIST"
cp -a "$ROOT/public/." "$DIST/"

# 书站尚未迁入时的占位，避免 /book/llm 404
mkdir -p "$DIST/book/llm"
if [[ ! -f "$DIST/book/llm/index.html" ]]; then
  cat >"$DIST/book/llm/index.html" <<'HTML'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>现代大模型 · 迁入中</title>
  <meta http-equiv="refresh" content="0;url=/book/" />
  <link rel="stylesheet" href="/css/site.css" />
</head>
<body>
  <main class="page wrap">
    <p class="page__kicker">book / llm</p>
    <h1 class="page__title">正文迁入中</h1>
    <p class="page__lead">《现代大模型》构建产物稍后落到此路径。先回 <a href="/book/">书架</a>。</p>
  </main>
</body>
</html>
HTML
fi

echo "built → $DIST"
