# Mac-specific PATH and tooling.

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/usr/local/bin"
    "/usr/local/sbin"
    $"($env.HOME)/bin"
    $"($env.HOME)/.local/bin"
    $"($env.HOME)/.pyenv/shims"
    $"($env.HOME)/.cargo/bin"
    "/opt/homebrew/opt/ruby/bin"
    $"($env.HOME)/.gem/ruby/3.4.0/bin"
    "/opt/homebrew/opt/openjdk@17/bin"
    "/opt/homebrew/opt/gradle@7/bin"
    "/usr/local/share/dotnet"
    $"($env.HOME)/.fabro/bin"
  ]
  | uniq
)

# Java
$env.JAVA_HOME = "/opt/homebrew/opt/openjdk@17"

# Node: trust the local Caddy root CA for HTTPS dev work.
$env.NODE_EXTRA_CA_CERTS = $"($env.HOME)/Library/Application Support/Caddy/pki/authorities/local/root.crt"
