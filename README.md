# 效能与品质保障事业部战役规划

本仓库用于发布单页战略规划页面（GitHub Pages），并提供版本归档与一键发布脚本。

## 在线访问

- 导航首页：[https://bakakabeckham.github.io/hubert-strategy-2026/home.html](https://bakakabeckham.github.io/hubert-strategy-2026/home.html)
- 最新版页面：[https://bakakabeckham.github.io/hubert-strategy-2026/](https://bakakabeckham.github.io/hubert-strategy-2026/)
- 历史版本列表：[https://bakakabeckham.github.io/hubert-strategy-2026/versions/](https://bakakabeckham.github.io/hubert-strategy-2026/versions/)
- 仓库地址：[https://github.com/bakakabeckham/hubert-strategy-2026](https://github.com/bakakabeckham/hubert-strategy-2026)

## 仓库结构

- `index.html`：最新版页面入口（GitHub Pages 根目录发布）
- `home.html`：导航页（入口聚合）
- `versions/`：历史版本归档目录
- `scripts/publish.sh`：一键发布脚本（自动归档、更新列表、提交、推送）
- `README.md`：项目说明

## 一键发布（推荐）

```bash
cd /Users/yuanqi/Documents/Codex/strategy-2026
./scripts/publish.sh "/Users/yuanqi/Downloads/新的规划文件.html" --tag "v2026-02-28"
```

脚本会自动完成：

1. 覆盖 `index.html` 为最新版本
2. 在 `versions/` 下归档一份带时间戳的快照
3. 重建 `versions/index.html` 历史列表
4. 自动 `commit` 并 `push` 到 `main`

可选参数：

- `--tag "xxx"`：指定版本后缀
- `--no-push`：只做本地提交，不推送远端

## 手动更新（兜底）

```bash
cd /Users/yuanqi/Documents/Codex/strategy-2026
cp "/Users/yuanqi/Downloads/新的规划文件.html" index.html
git add index.html versions/
git commit -m "chore: update strategy page manually"
git push origin main
```

推送后通常 1-5 分钟完成 Pages 更新。
