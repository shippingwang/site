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

## 一键发布（research + llm + site）

旁路默认：`../research`、`../现代大模型`。改完任意仓后：

```bash
./scripts/publish.sh              # 全部：有改动就 commit/push，再空提交触发 CI
./scripts/publish.sh research     # 只笔记
./scripts/publish.sh llm          # 只书
./scripts/publish.sh site         # 只壳子
./scripts/publish.sh research llm
MSG="fix home type" ./scripts/publish.sh site
```

`research` 仓里的 `./publish.sh` 仍可用，内部转调本脚本的 `research` 模式。

推 `llm` 时会先跑 `现代大模型/网站/check_math.py --fix`（行内误塞 `align`、跨行行内公式、`\frac1d` 等）；修不干净会直接失败，避免把坏公式推上线。llm 仓 CI 里也会再跑一遍只读检查。

## 部署

Cloudflare Workers：`wrangler.toml` → `assets.directory = "dist"`。

push `main` → `.github/workflows/deploy.yml`（需 `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID`）。  
CI 会拉 [`llm`](https://github.com/shippingwang/llm) 与 [`research`](https://github.com/shippingwang/research) 编进 `dist/book/llm/`、`dist/research/`。
