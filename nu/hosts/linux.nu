# Linux-specific PATH (kai-server primarily).
#
# Harness allowlist matches the leading token of each command, so do NOT
# prefix with cd or export here. PATH is set via this file, which nu sources
# at startup.

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend [
    "/home/linuxbrew/.linuxbrew/bin"
    "/home/linuxbrew/.linuxbrew/sbin"
    $"($env.HOME)/bin"
    $"($env.HOME)/.local/bin"
    $"($env.HOME)/.cargo/bin"
  ]
  | uniq
)
