#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
用法:
  ./scripts/publish.sh <source_html_path> [--tag <version_tag>] [--no-push]

示例:
  ./scripts/publish.sh "/Users/yuanqi/Downloads/效能与品质保障事业部战役规划-new2.27.html"
  ./scripts/publish.sh "/Users/yuanqi/Downloads/new.html" --tag "v2026-03-01"
  ./scripts/publish.sh "/Users/yuanqi/Downloads/new.html" --tag "v2026-03-01" --no-push
EOF
}

slugify() {
  local raw="$1"
  local value
  value="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | tr '[:space:]' '-' | tr -cd 'a-z0-9._-')"
  value="${value#-}"
  value="${value%-}"
  if [[ -z "$value" ]]; then
    value="release"
  fi
  printf '%s' "$value"
}

html_escape() {
  local value="$1"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  printf '%s' "$value"
}

render_versions_index() {
  local versions_dir="$1"
  local output_file="$2"
  local file
  local display
  local name
  local -a files=()

  while IFS= read -r name; do
    files+=("$name")
  done < <(
    for file in "${versions_dir}"/*.html; do
      [[ -e "$file" ]] || continue
      name="$(basename "$file")"
      [[ "$name" == "index.html" ]] && continue
      printf '%s\n' "$name"
    done | sort -r
  )

  {
    cat <<'HTML_HEAD'
<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>历史版本｜效能与品质保障事业部战役规划</title>
  <style>
    :root {
      --bg: #f7f9fd;
      --card: #ffffff;
      --line: #dbe3f2;
      --text: #1f2b45;
      --muted: #5f6c86;
      --primary: #2f6df6;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "PingFang SC",
        "Microsoft YaHei", sans-serif;
      line-height: 1.6;
    }
    .wrap {
      max-width: 920px;
      margin: 0 auto;
      padding: 28px 16px 40px;
    }
    .head {
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: 14px;
      padding: 18px;
      margin-bottom: 14px;
    }
    h1 {
      margin: 0 0 6px;
      font-size: 24px;
    }
    .desc {
      margin: 0;
      color: var(--muted);
      font-size: 14px;
    }
    .actions {
      margin-top: 10px;
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
    }
    .btn {
      border: 1px solid var(--line);
      background: #fff;
      color: var(--text);
      border-radius: 999px;
      font-size: 13px;
      text-decoration: none;
      padding: 7px 12px;
    }
    .btn:hover {
      border-color: var(--primary);
      color: var(--primary);
    }
    .list {
      list-style: none;
      padding: 0;
      margin: 0;
      display: grid;
      gap: 10px;
    }
    .item {
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 14px;
    }
    .item a {
      color: var(--primary);
      text-decoration: none;
      font-weight: 600;
    }
    .meta {
      color: var(--muted);
      font-size: 13px;
      margin-top: 4px;
      word-break: break-all;
    }
  </style>
</head>
<body>
  <main class="wrap">
    <section class="head">
      <h1>历史版本归档</h1>
      <p class="desc">以下文件按版本时间倒序排列，可直接访问历史快照。</p>
      <div class="actions">
        <a class="btn" href="../home.html">返回导航页</a>
        <a class="btn" href="../index.html">打开最新版</a>
      </div>
    </section>
    <ul class="list">
HTML_HEAD

    if [[ "${#files[@]}" -eq 0 ]]; then
      cat <<'HTML_EMPTY'
      <li class="item">
        <div class="meta">暂无历史版本。</div>
      </li>
HTML_EMPTY
    else
      for name in "${files[@]}"; do
        display="${name%.html}"
        if [[ "$display" =~ ^([0-9]{8})-([0-9]{6})-(.+)$ ]]; then
          display="${BASH_REMATCH[1]:0:4}-${BASH_REMATCH[1]:4:2}-${BASH_REMATCH[1]:6:2} ${BASH_REMATCH[2]:0:2}:${BASH_REMATCH[2]:2:2}:${BASH_REMATCH[2]:4:2} · ${BASH_REMATCH[3]}"
        fi
        printf '      <li class="item">\n'
        printf '        <a href="./%s">%s</a>\n' "$(html_escape "$name")" "$(html_escape "$name")"
        printf '        <div class="meta">%s</div>\n' "$(html_escape "$display")"
        printf '      </li>\n'
      done
    fi

    cat <<'HTML_TAIL'
    </ul>
  </main>
</body>
</html>
HTML_TAIL
  } > "$output_file"
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAIN_INDEX="${ROOT_DIR}/index.html"
VERSIONS_DIR="${ROOT_DIR}/versions"
VERSIONS_INDEX="${VERSIONS_DIR}/index.html"

SOURCE_FILE=""
VERSION_TAG=""
NO_PUSH=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      if [[ $# -lt 2 ]]; then
        echo "错误: --tag 需要参数"
        exit 1
      fi
      VERSION_TAG="$2"
      shift 2
      ;;
    --no-push)
      NO_PUSH=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -z "$SOURCE_FILE" ]]; then
        SOURCE_FILE="$1"
        shift
      else
        echo "错误: 未知参数 $1"
        usage
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$SOURCE_FILE" ]]; then
  usage
  exit 1
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "错误: 文件不存在: $SOURCE_FILE"
  exit 1
fi

if [[ ! -d "${ROOT_DIR}/.git" ]]; then
  echo "错误: 当前目录不是 Git 仓库: $ROOT_DIR"
  exit 1
fi

mkdir -p "$VERSIONS_DIR"

timestamp="$(date '+%Y%m%d-%H%M%S')"
if [[ -n "$VERSION_TAG" ]]; then
  release_tag="$(slugify "$VERSION_TAG")"
else
  release_tag="$(slugify "$(basename "${SOURCE_FILE%.*}")")"
fi
archive_name="${timestamp}-${release_tag}.html"
archive_path="${VERSIONS_DIR}/${archive_name}"

cp "$SOURCE_FILE" "$MAIN_INDEX"
cp "$SOURCE_FILE" "$archive_path"

render_versions_index "$VERSIONS_DIR" "$VERSIONS_INDEX"

git -C "$ROOT_DIR" add index.html versions/index.html "versions/${archive_name}"

if git -C "$ROOT_DIR" diff --cached --quiet; then
  echo "没有检测到变更，未创建提交。"
  exit 0
fi

git -C "$ROOT_DIR" commit -m "chore: publish strategy page ${timestamp}"

if [[ "$NO_PUSH" -eq 1 ]]; then
  echo "已完成本地提交（未推送）。"
  echo "手动推送: git -C \"$ROOT_DIR\" push origin main"
  exit 0
fi

git -C "$ROOT_DIR" pull --rebase origin main
git -C "$ROOT_DIR" push origin main

echo "发布完成。"
echo "在线地址: https://bakakabeckham.github.io/hubert-strategy-2026/"
echo "历史版本: https://bakakabeckham.github.io/hubert-strategy-2026/versions/"
