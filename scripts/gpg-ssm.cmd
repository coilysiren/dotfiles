@echo off
REM gpg-ssm.cmd - Windows entry point for git's gpg.program.
REM
REM Wraps the bash gpg-ssm script via Git for Windows' bundled bash.exe.
REM Earlier versions launched a PowerShell port (gpg-ssm.ps1), but pwsh
REM corrupts gpg's binary stdin/stdout when invoked through git on Windows
REM (CRLF translation, buffering); git would hang waiting for the signature.
REM bash.exe handles binary I/O cleanly and the bash script's --passphrase-fd 3
REM path is also simpler than the PRESET_PASSPHRASE dance the .ps1 needed.
REM
REM Wire-up (Git Bash):
REM   git config --global gpg.program "$HOME/.local/bin/gpg-ssm.cmd"
REM
REM %~dp0 resolves to this script's directory; the extensionless gpg-ssm
REM (bash) sits alongside.
"C:\Program Files\Git\usr\bin\bash.exe" "%~dp0gpg-ssm" %*
