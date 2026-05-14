# Sourced once at nu startup, before config.nu.
# Cross-platform: branches via $nu.os-info.name.

# Identity / editor
$env.LANG = "en_US.UTF-8"
$env.EDITOR = "code"
$env.GIT_EDITOR = "nano"
$env.SSH_KEY_PATH = $"($env.HOME? | default $env.USERPROFILE?)/.ssh/id_rsa"
$env.CLI_MFA = "ykman"

# AWS (personal default profile, not coilysiren)
$env.AWS_PROFILE = "default"
$env.AWS_REGION = "us-east-1"
$env.AWS_PAGER = ""

# Coily lockdown root (constant across hosts)
$env.COILY_LOCKDOWN_ROOT = $"($env.HOME? | default $env.USERPROFILE?)/projects/coilysiren"

# Per-host PATH and shell-specific tweaks
source ($nu.default-config-dir | path join hosts ($"($nu.os-info.name).nu"))
