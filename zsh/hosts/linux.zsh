# Linux-specific PATH (kai-server primarily).
#
# Harness allowlist matches the leading token of each command, so do NOT
# prefix with cd or export here. PATH is set via this file, which zsh
# sources at startup.

typeset -U path PATH
path=(
  /home/linuxbrew/.linuxbrew/bin
  /home/linuxbrew/.linuxbrew/sbin
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  $path
)
export PATH

# linuxbrew shellenv, if installed.
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
