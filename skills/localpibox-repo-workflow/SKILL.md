---
name: localpibox-repo-workflow
description: Manage the 6 LocalPibox repos — CI-only versioning, hooks, image builds, lpb.py.
---
# LocalPibox Repository Workflow

Versioning model: **single-source** (devstack/VERSION). CI bumps version after tests pass, creates tags on all 6 repos, builds images. Git hooks validate only — no cross-repo version sync.

## When to Use

- Onboarding new developers to the LocalPibox stack
- Setting up CI/CD pipelines (build-and-publish.yml)
- Debugging version/tag alignment issues
- Adding/removing repos from the stack
- Validating Docker image builds for `dev` or `main` targets
- Using `lpb --version`, `lpb --tag`, `lpb.py` scripts

## Versioning Model (Option C)

```
Single source: devstack/VERSION
CI bump: tests → bump VERSION → commit+push → create tags on all repos → build images
```

- **devstack/VERSION** — only file that matters (e.g., `0.0.6-lpb`)
- **lpb.stack.env** — LPB_PI_REF = VERSION, used by CI + lpb.py
- **settings.json** — extension pins match VERSION string
- **Docker images** — tagged with stack version (`:0.0.6-lpb-cli`)  
- **GitHub tags** — same version tag on all 6 repos
- **No VERSION files in other repos** — they are identified by tags only
- **Git hooks** — validate only (no cross-repo writes)
- **CI** — bumps version, creates tags, builds/pushes images

Standardized workflow for managing the 6 LocalPibox repositories, with conventions for branches, commits, tags, versions, CI, and git hooks.

## When to Use

- Onboarding new developers to the LocalPibox stack
- Creating or restructuring repositories in the 6-repo layout
- Setting up CI/CD pipelines (build-and-publish.yml)
- Managing version bumps, tagging, and branch strategy
- Debugging extension symlink or workspace issues
- Validating Docker image builds for `dev` or `main` targets
- Using `lpb.py` to select image tags (`:dev`, `:main`, `:{version}`)

## Repository Map

| Repo | Type | Default | lpb == lpb-dev? |
|---|---|---|---|
| **config** | workspace | `dev` | — |
| **devstack** | workspace | `dev` | — |
| **lpb-memory** | workspace + extension | `dev` | — |
| **pi** | workspace (CI cloned) | `lpb-dev` | ✅ |
| **pi-subagents** | extension | `lpb-dev` | ✅ |
| **lemonade-pi-plugin** | extension | `lpb-dev` | ✅ |

## Repository Layout

```
Workspace clones:
  /home/lpb/workspace/localpibox/config          (config)
  /home/lpb/workspace/localpibox/devstack         (devstack)
  /home/lpb/workspace/localpibox/lpb-memory       (lpb-memory)
  /home/lpb/workspace/localpibox/devstack/workspace/
      pi                                          (pi REAL clone — CI build dependency)
      lemonade-pi-plugin → symlink to extension
      lpb-memory → symlink to extension
      pi-subagents → symlink to extension

Extension clones:
  /home/lpb/.pi/agent/git/github.com/localpibox/
      pi-subagents
      lemonade-pi-plugin
      lpb-memory

⚠️ workspace/ is .gitignore — NOT tracked.
   Recreate with: git clone (for pi) or symlinks for extensions
```

## Branch Strategy

- **`dev`** (config, devstack, lpb-memory): Primary development. Default on GitHub.
- **`main`** (config, devstack, lpb-memory): Backup/initial state.
- **`lpb-dev`** (pi, pi-subagents, lemonade-pi-plugin): Development from upstream + LPB patches. Default.
- **`lpb`**: Copy of `lpb-dev`, kept for compatibility. Must always equal `lpb-dev`.

**Rule:** Always work on the default branch (`dev` or `lpb-dev`).

## Commit Author Convention

ALL LocalPibox-specific commits MUST use:
```
Author: localpibox <localpibox@gmail.com>
```

Never use `lpb`, `LocalPibox`, or other aliases.

### Fixing wrong authors
```bash
# Single commit
git commit --amend --author="localpibox <localpibox@gmail.com>" --no-edit

# Entire repo history
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --env-filter '
export GIT_AUTHOR_NAME="localpibox"
export GIT_AUTHOR_EMAIL="localpibox@gmail.com"
export GIT_COMMITTER_NAME="localpibox"
export GIT_COMMITTER_EMAIL="localpibox@gmail.com"
' -- --all
```

## Pre-commit Hook

**Installed in all 6 repos.** Validates BEFORE commit:

1. All VERSION files in sync
2. `lpb.stack.env` LPB_PI_REF matches VERSION
3. `settings.json` extension pins match VERSION
4. All repos clean (except VERSION/env changes)
5. Auto-stages VERSION files + `lpb.stack.env`

**Exit non-zero to abort commit.** Use `--no-verify` to skip.

## commit-msg Hook

**Installed in all 6 repos.** Runs AFTER pre-commit:

1. Checks for `[skip-version]` in commit message
2. Reads `0.0.x-lpb` pattern from devstack/VERSION
3. Increments patch: `0.0.5-lpb` → `0.0.6-lpb`
4. Updates VERSION in all 6 repos
5. Updates `lpb.stack.env` LPB_PI_REF
6. **Does NOT touch package.json** (kept at original fork versions)

## Version Management

### Version Policy
```
VERSION file  → LocalPibox stack version (0.0.x-lpb) — auto-incremented on every commit
package.json  → Original fork version — NEVER changed
Tags          → Point to commits with matching VERSION (e.g., 0.0.1-lpb)
```

### Package.json Versions (Fork Originals)
| Repo | Version |
|---|---|
| lemonade-pi-plugin | `1.0.0` |
| lpb-memory | `0.9.1` |
| pi-subagents | `0.14.3` |
| pi | `0.0.1-lpb` |

### Manual version bump
```bash
cd /home/lpb/workspace/localpibox/devstack
./support/version.sh patch    # 0.0.x → 0.0.(x+1)
./support/version.sh minor    # 0.0.x → 0.(x+1).0
./support/version.sh major    # 0.0.x → 1.0.0
```

### Tagging
```bash
./support/version.sh tag 0.2.0-lpb     # Create tags on all repos
./support/version.sh push-tags         # Push tags to remotes
```

## Update Workflow

### Checking status
```bash
for repo in config devstack lpb-memory; do
  cd /home/lpb/workspace/localpibox/$repo
  echo "$repo: $(git branch --show-current) → $(git log -1 --oneline)"
done
for repo in pi-subagents lemonade-pi-plugin; do
  cd /home/lpb/.pi/agent/git/github.com/localpibox/$repo
  echo "$repo: $(git branch --show-current) → $(git log -1 --oneline)"
done
echo "pi: $(cd /home/lpb/workspace/localpibox/devstack/workspace/pi && git branch --show-current) → $(git log -1 --oneline)"
```

### Switching to default branches
```bash
cd /home/lpb/workspace/localpibox/config && git checkout dev
cd /home/lpb/workspace/localpibox/devstack && git checkout dev
cd /home/lpb/workspace/localpibox/lpb-memory && git checkout dev
cd /home/lpb/.pi/agent/git/github.com/localpibox/pi-subagents && git checkout lpb-dev
cd /home/lpb/.pi/agent/git/github.com/localpibox/lemonade-pi-plugin && git checkout lpb-dev
cd /home/lpb/workspace/localpibox/devstack/workspace/pi && git checkout lpb-dev
```

### Creating lpb-dev with upstream base
```bash
cd /path/to/repo

# 1. Add upstream remote (if not exists)
git remote add upstream <upstream-url> 2>/dev/null
git fetch upstream

# 2. Create lpb-dev from latest upstream tag + LPB changes
git checkout -b lpb-dev <upstream-tag>  # e.g., v0.84.1
git cherry-pick <lpb-commit-1> <lpb-commit-2> ...

# 3. Create lpb from lpb-dev
git branch -f lpb lpb-dev

# 4. Push
git push origin lpb-dev
git push origin lpb --force-with-lease

# 5. Set default branch
gh api repos/<owner>/<repo> --method PATCH -f default_branch=lpb-dev

# 6. Delete old tags
git tag -d <old-tag>
git push origin --delete <old-tag>
```

## Cleanup Checklist

Before declaring a repo clean:
- [ ] Default branch set correctly (`dev` or `lpb-dev`)
- [ ] Working on default branch
- [ ] All commits from `localpibox <localpibox@gmail.com>`
- [ ] Stale branches deleted
- [ ] Old LPB tags cleaned up
- [ ] `lpb` branch = `lpb-dev` (for repos with this pattern)
- [ ] commit-msg hook installed (all repos)
- [ ] pre-commit hook installed (all repos)
- [ ] Version progressing via auto-increment
- [ ] VERSION files synced across all repos

## CI/CD Workflow

### GitHub Actions: `.github/workflows/build-and-publish.yml`
- **Push to dev**: Builds → `:dev`, `:dev-cli`, `:dev-web`, `:{sha}-cli/web`
- **Push to main from tag** (`0.*-lpb`, `1.*-lpb`): Builds → `:{version}-cli/web`
- **Manual dispatch**: Publishes `:latest-cli`, `:latest-web`
- **Weekly cron**: Publishes `:weekly-cli`, `:weekly-web`

```yaml
on:
  push:
    branches: [dev]
    paths: ['Dockerfile', 'support/**', 'lpb.stack.env', ...]
  push:
    tags:
      - '0.*-lpb'
      - '1.*-lpb'
    paths: ['VERSION', 'lpb.stack.env']
  schedule:
    - cron: '0 3 * * 1'
  workflow_dispatch:
    inputs:
      publish_latest:
        type: boolean
        default: true
```

### Build images
- `ghcr.io/localpibox/devstack:cli` — Base dev environment + Pi CLI
- `ghcr.io/localpibox/devstack:web` — Extends cli + VSCodium server

### CI does NOT use workspace/pi
- CI clones pi to `/opt/pi-src` during Docker build
- workspace/pi is only for local development convenience
- workspace/ is `.gitignore`d

## Extension Installation

Extensions update at runtime via `pi update --extensions`. They are NOT baked into images.

The devstack image contains:
- Pi CLI (built from pi fork)
- npm global packages
- Support scripts

Extensions loaded from:
- `/home/lpb/.pi/agent/git/github.com/localpibox/`
- Or symlinked via `workspace/` → extension repos

Settings pinned in `~/.pi/agent/settings.json` under `"packages"` array.
