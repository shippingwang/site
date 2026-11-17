# shippingwang / site

个人站壳子 → [shippingwang.com](https://shippingwang.com)

| 路径 | 栏目 |
|------|------|
| `/` | 首页 |
| `/research/` | 研究笔记（内容仓 [`shippingwang/research`](https://github.com/shippingwang/research)） |
| `/book/` | 书架（现代大模型 / 现代视觉模型）；大模型正文在 `/book/llm/<册>/`，视觉正文在 `/book/vision/<册>/` |
| `/life/` | 生活 |
| `/idea/` | 短念头（内容仓 [`shippingwang/idea`](https://github.com/shippingwang/idea)） |

书稿仓库：[`shippingwang/llm`](https://github.com/shippingwang/llm)、[`shippingwang/vlm`](https://github.com/shippingwang/vlm)；研究笔记 [`shippingwang/research`](https://github.com/shippingwang/research)；念头 [`shippingwang/idea`](https://github.com/shippingwang/idea)。都不要合进本仓。

## 本地

```bash
./scripts/build.sh
npx --yes serve dist   # 或 python3 -m http.server -d dist 8080
```

## 一键发布

脚本：`scripts/publish.sh`。旁路默认：`../research`、`../现代大模型`、`../现代视觉模型`、`../idea`。有改动会 commit / push，再空提交触发 site CI 重建线上站。

### 常用命令

在本仓根目录：

```bash
cd /picassox/intelligent-cpfs/human-body/wsp/research/site

./scripts/publish.sh              # 默认 all：research + llm + vision + idea + site
./scripts/publish.sh all

./scripts/publish.sh site         # 只推站点壳子
./scripts/publish.sh llm          # 只推 shippingwang/llm（《现代大模型》）
./scripts/publish.sh vision       # 只推 shippingwang/vlm（《现代视觉模型》）
./scripts/publish.sh research     # 只推 shippingwang/research
./scripts/publish.sh idea         # 只推 shippingwang/idea

./scripts/publish.sh research llm
./scripts/publish.sh site vision
```

带提交说明：

```bash
MSG="update book page" ./scripts/publish.sh site
MSG="update book3" ./scripts/publish.sh llm
MSG="update vision book3" ./scripts/publish.sh vision
MSG="update research notes" ./scripts/publish.sh research
MSG="update idea" ./scripts/publish.sh idea
MSG="site + vision" ./scripts/publish.sh site vision
```

### 说明

| 参数 | 推哪个仓 | 线上大致对应 |
|------|----------|--------------|
| `site` | `shippingwang/site` | `/`、`/book/` 书架、壳子 css/js/assets |
| `llm` | `shippingwang/llm` | `/book/llm/<册>/` 书稿正文 |
| `vision` | `shippingwang/vlm` | `/book/vision/<册>/` 书稿正文 |
| `research` | `shippingwang/research` | `/research/` 笔记 |
| `idea` | `shippingwang/idea` | `/idea/` 短念头 |

可选环境变量：

- `MSG`：commit message（默认 `publish YYYY-MM-DD`）
- `LLM_DIR`：大模型书稿目录（默认 `../现代大模型`）
- `VISION_DIR`：视觉书稿目录（默认 `../现代视觉模型`）
- `RESEARCH_DIR`：笔记目录（默认 `../research`）
- `IDEA_DIR`：念头目录（默认 `../idea`）

推 `llm` 时会先跑 `现代大模型/网站/check_math.py --fix`；推 `vision` 时会先跑 `现代视觉模型/网站/sync_content.py`。

推完等 CI → https://shippingwang.com/

## 部署

Cloudflare Workers：`wrangler.toml` → `assets.directory = "dist"`。

push `main` → `.github/workflows/deploy.yml`（需 `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID`）。  
CI 跑 `scripts/build.sh`，会拉 [`llm`](https://github.com/shippingwang/llm)、[`vlm`](https://github.com/shippingwang/vlm)、[`research`](https://github.com/shippingwang/research)、[`idea`](https://github.com/shippingwang/idea) 编进 `dist/book/llm/`、`dist/book/vision/`、`dist/research/`、`dist/idea/`。
