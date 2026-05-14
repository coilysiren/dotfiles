# Windows-specific PATH.
#
# Git Bash is the canonical shell-out target on Windows. nu hosts the
# terminal, but bash scripts run under git-bash.exe (set via wezterm's
# launch_menu, not here). Path entries here are for nu's own commands.

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend [
    $"($env.USERPROFILE)\\bin"
    $"($env.USERPROFILE)\\.local\\bin"
    $"($env.USERPROFILE)\\.cargo\\bin"
    "C:\\Program Files\\Git\\bin"
    "C:\\Program Files\\Git\\usr\\bin"
  ]
  | uniq
)
