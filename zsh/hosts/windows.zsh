# Windows-specific PATH.
#
# Git Bash is the canonical shell on Windows. zsh runs under Git Bash via
# MSYS, and uname reports MINGW*/MSYS*. Path entries are POSIX-style
# (Git Bash translates).

typeset -U path PATH
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  /c/Program\ Files/Git/bin
  /c/Program\ Files/Git/usr/bin
  $path
)
export PATH
