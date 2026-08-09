---
name: gh-pr-before-after
description: Use when a pull request changes something visual and the description should show it — capture a matched before/after screenshot pair, host the images so GitHub renders them, and embed them in the PR body.
---

# Before/after screenshots on a GitHub PR

A reviewer can read intent from a diff, but not pixels. When a PR moves, restyles, or
replaces something a person looks at, the description carries a matched pair of
screenshots: the same view before your change and after it.

Skip this for backend-only, refactor, or config PRs. When the view is brand new there is
no "before" — ship the single after shot.

## 1. Capture the pair

**The only difference between the two images is your change.** Everything else is noise
that a reviewer has to mentally subtract: viewport size, theme, locale, seed data,
logged-in user, scroll position, hover state, a visible clock. Pin them all, and pin the
viewport explicitly rather than inheriting whatever the browser opened at.

Capture with whichever browser tool you have (Playwright MCP, agent-browser, Chrome
DevTools MCP, or a manual screenshot). The tool does not matter; the pinning does.

Shoot **after** first — you are already on the branch and already know which view proves
the change. Then rewind to the base and shoot **before** through the identical steps.

Getting the base state:

| Situation | How to rewind |
| --- | --- |
| Change is source-only, dev server running | `git stash -u`, let hot reload settle, shoot, `git stash pop` |
| Base differs in dependencies, migrations, or env | `git worktree add ../base-state "$(git merge-base origin/HEAD HEAD)"`, install, run it on a second port |

Save the files as `before.png` and `after.png`.

## 2. Host the images

GitHub's API has no endpoint for attaching an image to a PR body — the uploader in the
web UI is browser-only ([cli/cli#1895](https://github.com/cli/cli/issues/1895)). So the
repo hosts the images itself, and the PR references them by **commit SHA**, which keeps
the URL alive after you delete the files again.

```bash
# 1. commit the images and push
mkdir -p docs/screenshots/<feature>
cp before.png after.png docs/screenshots/<feature>/
git add docs/screenshots/<feature>
git commit -m "chore: add PR screenshots"
git push -u origin HEAD

# 2. note the SHA that now holds the blobs
git rev-parse HEAD

# 3. delete them again, in a follow-up commit
git rm -r docs/screenshots/<feature>
git commit -m "chore: remove PR screenshots"
git push
```

The URL to reference:

```
https://github.com/<owner>/<repo>/blob/<sha>/docs/screenshots/<feature>/after.png?raw=true
```

**Pin the SHA, not a branch name.** A `blob/<branch>/…` URL 404s the moment the file
leaves that branch's tip — which step 3 does deliberately. The blob stays reachable at
its commit, so the merged diff carries no binaries.

Fast path: when `pin-screenshots.sh` sits next to this file, it runs all three steps and
prints the finished markdown.

```bash
./pin-screenshots.sh <feature-slug> before.png after.png
```

Rewriting the branch's history afterwards (a rebase or a squashing force-push) can orphan
the pinned commit. If you rewrite, reload the PR page and confirm the images still render;
re-pin against a fresh commit if they don't.

## 3. Embed in the PR body

Put the block directly after the one-line summary, collapsed so it never buries the text.
Two or three images, each with real alt text.

Side by side, for shots that are wider than they are tall:

```html
<details>
<summary>📸 Before / after</summary>

| Before | After |
| --- | --- |
| <img alt="Checkout summary with the total misaligned" src="https://github.com/<owner>/<repo>/blob/<sha>/docs/screenshots/<feature>/before.png?raw=true" /> | <img alt="Checkout summary with the total aligned to the column" src="https://github.com/<owner>/<repo>/blob/<sha>/docs/screenshots/<feature>/after.png?raw=true" /> |

</details>
```

Stacked, for tall or mobile-width shots — a table would shrink them past legibility:

```html
<details>
<summary>📸 Before / after</summary>

**Before**
<img width="420" alt="…" src="…/before.png?raw=true" />

**After**
<img width="420" alt="…" src="…/after.png?raw=true" />

</details>
```

Write the body to a file and apply it, so the markdown survives shell quoting:

```bash
gh pr edit --body-file pr-body.md      # or: gh pr create --body-file pr-body.md
```

## Before you call it done

- Both images differ only by your change — same viewport, theme, data, scroll.
- Every `src` is pinned to a SHA, and the PR page renders all of them.
- The screenshot files are gone from the branch tip in a follow-up commit.
- Two or three images at most, each carrying alt text that describes what to look at.
