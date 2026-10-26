# shippingwang / site

个人站壳子 → [shippingwang.com](https://shippingwang.com)

| 路径 | 栏目 |
|------|------|
| `/` | 首页 |
| `/research/` | 研究笔记（内容仓 [`shippingwang/research`](https://github.com/shippingwang/research)） |
| `/book/` | 书架；书正文在 `/book/<slug>/` |
| `/life/` | 生活 |
| `/idea/` | 短卡片 |

书稿仓库是 [`shippingwang/llm`](https://github.com/shippingwang/llm)；研究笔记是 [`shippingwang/research`](https://github.com/shippingwang/research)。都不要合进本仓。

## 本地

```bash
./scripts/build.sh
npx --yes serve dist   # 或 python3 -m http.server -d dist 8080
```

## 部署

Cloudflare Workers 静态资源：`wrangler.toml` → `assets.directory = "dist"`。

```bash
./scripts/build.sh
npx wrangler deploy
```

或 push `main`，走 `.github/workflows/deploy.yml`（需配置 `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID`）。

## 下一步

CI 里 checkout `llm` → `mkdocs build` → 输出到 `dist/book/llm/`，并把书内 `site_url` 改为 `https://shippingwang.com/book/llm/`。
