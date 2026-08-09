#!/usr/bin/env bash
# Host PR screenshots as commit-pinned blobs, then remove them from the branch tip.
#
#   ./pin-screenshots.sh <feature-slug> before.png after.png
#
# Commits the images, pushes, captures the SHA, deletes them in a follow-up commit,
# pushes again, and prints the markdown to paste into the PR body. The blobs stay
# reachable at the pinned SHA, so the merged diff carries no binaries.
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: $0 <feature-slug> <image>..." >&2
  exit 1
fi

slug=$1
shift

images=()
for img in "$@"; do
  [ -f "$img" ] || { echo "no such file: $img" >&2; exit 1; }
  images+=("$(cd "$(dirname "$img")" && pwd)/$(basename "$img")")
done

cd "$(git rev-parse --show-toplevel)"

# Both SSH (git@github.com:owner/repo.git) and HTTPS remotes reduce to owner/repo.
remote=$(git remote get-url origin)
slug_path=${remote#*github.com}
slug_path=${slug_path#[:/]}
repo_path=${slug_path%.git}
owner=${repo_path%%/*}
repo=${repo_path#*/}

dir="docs/screenshots/$slug"
mkdir -p "$dir"
cp "${images[@]}" "$dir/"

git add "$dir"
git commit -q -m "chore: add PR screenshots" -- "$dir"
git push -q -u origin HEAD
sha=$(git rev-parse HEAD)

git rm -rq "$dir"
git commit -q -m "chore: remove PR screenshots" -- "$dir"
git push -q origin HEAD

echo
echo "<details>"
echo "<summary>📸 Before / after</summary>"
echo
for img in "${images[@]}"; do
  name=$(basename "$img")
  echo "**${name%.*}**"
  echo "<img alt=\"TODO describe what to look at\" src=\"https://github.com/$owner/$repo/blob/$sha/$dir/$name?raw=true\" />"
  echo
done
echo "</details>"
