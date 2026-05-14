# Sourced after env.nu. Aliases, functions, integrations.

use ssm-env.nu *

# ─── Aliases ──────────────────────────────────────────────────────────────────
alias del = rm -r
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..
alias gt = git status
alias gush = git push -u origin HEAD

# rg with the same hidden/glob ignores used in zsh.
def rg [...args] {
  ^rg --hidden --glob '!.git' --glob '!*.svg' --glob '!.vscode' ...$args
}

# ─── Git helpers (ported from zsh) ────────────────────────────────────────────
def git-default-branch [] {
  ^git symbolic-ref --short refs/remotes/origin/HEAD | str replace 'origin/' ''
}

def git-pr-title [] {
  with-env { PAGER: "" } { ^gh pr view --json title --jq ".title" }
}

def git-merge-default-branch [] {
  let default = (git-default-branch)
  ^git switch $default
  ^git pull
  ^git switch -
  ^git fetch origin $default
  ^git merge $"origin/($default)"
}

def git-checkpoint [msg?: string] {
  let stamp = $"checkpoint-(whoami | str trim)-(date now | format date '%s')"
  let final = ($msg | default $stamp)
  ^git commit . -m $final --allow-empty
  ^git push -u origin HEAD
}

def git-squash [] {
  git-merge-default-branch
  let default = (git-default-branch)
  let branch = (^git branch --show-current | str trim)
  let base = (^git merge-base $default $branch | str trim)
  ^git reset $base
  ^git add -A
  ^git commit . -m (git-pr-title)
  ^git push -u origin HEAD -f
}

def gt-conflicts [] {
  ^git ls-files --unmerged --deduplicate | lines | each { |l| $l | split column -r '\s+' | get column4.0 } | uniq
}

# ─── Other ports ──────────────────────────────────────────────────────────────
def docker-bash [name: string] {
  let id = (^docker container ls --filter $"name=($name)" --quiet | str trim)
  ^docker exec -it $id bash
}

def rg-code [pattern: string] {
  ^rg $pattern --files-with-matches | lines | each { |f| ^code $f }
}

def pull-all-repos [] {
  ls | where type == dir | each { |d|
    if ($"($d.name)/.git" | path exists) {
      print $"==> ($d.name)"
      ^git -C $d.name pull
    }
  }
}

def count-lines [] {
  ^rg --files | lines | each { |f|
    { file: $f, lines: (open $f | lines | length) }
  } | sort-by lines --reverse
}

# ─── Integrations ─────────────────────────────────────────────────────────────
# direnv hook: nu has a community port. If not installed, this is a no-op.
# zoxide / starship / atuin can be added later.

# GitHub PAT - lazy: only fetched when a command actually reads $env.GITHUB_PERSONAL_ACCESS_TOKEN.
# (zsh used to eagerly call `gh auth token` on every shell start; nu defers.)
def --env github-token-load [] {
  $env.GITHUB_PERSONAL_ACCESS_TOKEN = (^gh auth token | str trim)
  $env.HOMEBREW_GITHUB_PACKAGES_USER = "coilysiren"
  $env.HOMEBREW_GITHUB_PACKAGES_TOKEN = $env.GITHUB_PERSONAL_ACCESS_TOKEN
}
