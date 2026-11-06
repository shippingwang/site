# shippingwang / site

个人站壳子 → [shippingwang.com](https://shippingwang.com)

| 路径 | 栏目 |
|------|------|
| `/` | 首页 |
| `/research/` | 研究笔记（内容仓 [`shippingwang/research`](https://github.com/shippingwang/research)） |
| `/book/` | 书架（丛书分层）；正文在 `/book/llm/<册>/` |
| `/life/` | 生活 |
| `/idea/` | 短卡片 |

书稿仓库是 [`shippingwang/llm`](https://github.com/shippingwang/llm)；研究笔记是 [`shippingwang/research`](https://github.com/shippingwang/research)。都不要合进本仓。

## 本地

```bash
./scripts/build.sh
npx --yes serve dist   # 或 python3 -m http.server -d dist 8080
```

## 一键发布（research + llm + site）

脚本：`scripts/publish.sh`。旁路默认：`../research`、`../现代大模型`。有改动会 commit / push，再空提交触发 site CI 重建线上站。

### 常用命令

在本仓根目录：

```bash
cd /picassox/intelligent-cpfs/human-body/wsp/research/site

./scripts/publish.sh              # 默认 all：research + llm + site
./scripts/publish.sh all

./scripts/publish.sh site         # 只推站点壳子（/、/book/、css、assets 等）
./scripts/publish.sh llm          # 只推书稿仓 shippingwang/llm（《现代大模型》三册）
./scripts/publish.sh research     # 只推研究笔记仓 shippingwang/research

./scripts/publish.sh research llm # 可多选
./scripts/publish.sh site llm
```

带提交说明（推荐）：

```bash
MSG="update book page" ./scripts/publish.sh site
MSG="update book3" ./scripts/publish.sh llm
MSG="update research notes" ./scripts/publish.sh research
MSG="site + book3" ./scripts/publish.sh site llm
```

不先 `cd` 时用绝对路径：

```bash
# 1. 推站点
MSG="update site" bash /picassox/intelligent-cpfs/human-body/wsp/research/site/scripts/publish.sh site

# 2. 推书稿（含第三册正文；整本 llm 仓一起推）
MSG="update book3" bash /picassox/intelligent-cpfs/human-body/wsp/research/site/scripts/publish.sh llm

# 3. 推研究笔记
MSG="update research" bash /picassox/intelligent-cpfs/human-body/wsp/research/site/scripts/publish.sh research
```

### 说明

| 参数 | 推哪个仓 | 线上大致对应 |
|------|----------|--------------|
| `site` | `shippingwang/site` | `/`、`/book/` 书架、壳子 css/js/assets |
| `llm` | `shippingwang/llm` | `/book/llm/<册>/` 书稿正文 |
| `research` | `shippingwang/research` | `/research/` 笔记 |

可选环境变量：

- `MSG`：commit message（默认 `publish YYYY-MM-DD`）
- `LLM_DIR`：书稿目录（默认 `../现代大模型`）
- `RESEARCH_DIR`：笔记目录（默认 `../research`）

`research` 仓里的 `./publish.sh` 仍可用，内部转调本脚本的 `research` 模式。

推 `llm` 时会先跑 `现代大模型/网站/check_math.py --fix`（行内误塞 `align`、跨行行内公式、`\frac1d` 等）；修不干净会直接失败，避免把坏公式推上线。llm 仓 CI 里也会再跑一遍只读检查。

推完等 CI → https://shippingwang.com/

## 部署

Cloudflare Workers：`wrangler.toml` → `assets.directory = "dist"`。

push `main` → `.github/workflows/deploy.yml`（需 `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID`）。  
CI 会拉 [`llm`](https://github.com/shippingwang/llm) 与 [`research`](https://github.com/shippingwang/research) 编进 `dist/book/llm/`、`dist/research/`。
