# 效能与品质保障事业部战役规划

本仓库用于发布单页战略规划页面（GitHub Pages）。

## 在线访问

- 页面地址：[https://bakakabeckham.github.io/hubert-strategy-2026/](https://bakakabeckham.github.io/hubert-strategy-2026/)
- 仓库地址：[https://github.com/bakakabeckham/hubert-strategy-2026](https://github.com/bakakabeckham/hubert-strategy-2026)

## 仓库结构

- `index.html`：页面入口文件（GitHub Pages 从根目录发布）
- `README.md`：项目说明

## 如何更新页面内容

1. 用新的 `html` 文件覆盖 `index.html`
2. 提交并推送到 `main` 分支

```bash
cd /Users/yuanqi/Documents/Codex/strategy-2026
cp "/Users/yuanqi/Downloads/效能与品质保障事业部战役规划-new2.27.html" index.html
git add index.html
git commit -m "chore: update strategy page"
git push origin main
```

推送后通常 1-5 分钟完成 Pages 更新。
