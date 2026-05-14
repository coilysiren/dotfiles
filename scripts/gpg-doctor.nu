#!/usr/bin/env nu
#
# Diagnose commit signing failures. Run with `nu scripts/gpg-doctor.nu`
# any time `git commit` reports `gpg failed to sign the data`.
#
# Walks every check in order, prints a sign-test result at the end, and
# names the most-likely fix for each failure mode.

def status [ok: bool, msg: string] {
  let mark = if $ok { "OK  " } else { "FAIL" }
  print $"  ($mark)  ($msg)"
}

def heading [s: string] {
  print ""
  print $"== ($s) =="
}

def have [cmd: string] {
  (which $cmd | length) > 0
}

# 1. Binaries -----------------------------------------------------------------
heading "binaries"
status (have "gpg")       $"gpg              (^which gpg | str trim)"
status (have "gpg-agent") $"gpg-agent        (^which gpg-agent | str trim)"
status (have "gpgconf")   $"gpgconf          (^which gpgconf | str trim)"
status (have "git")       $"git              (^which git | str trim)"
status (have "ykman")     "ykman            (optional, for YubiKey-backed keys)"

if not (have "gpg") {
  print ""
  print "FIX: brew install gnupg"
  exit 1
}

# 2. gpg-agent socket ---------------------------------------------------------
heading "gpg-agent"
let socket = (^gpgconf --list-dirs agent-socket | str trim)
status (($socket | path exists)) $"agent socket     ($socket)"

let agent_alive = (do { ^gpg-connect-agent /bye } | complete | get exit_code) == 0
status $agent_alive "agent responds to /bye"

if not $agent_alive {
  print ""
  print "FIX: gpgconf --kill gpg-agent ; gpg-agent --daemon"
}

# 3. git config ---------------------------------------------------------------
heading "git config"
let signing_key = (^git config --global user.signingkey | complete | get stdout | str trim)
let gpg_sign    = (^git config --global commit.gpgsign | complete | get stdout | str trim)
status (($signing_key | str length) > 0) $"user.signingkey  ($signing_key)"
status ($gpg_sign == "true")             $"commit.gpgsign   ($gpg_sign)"

# 4. Keys ---------------------------------------------------------------------
heading "secret keys"
let secrets = (^gpg --list-secret-keys --with-colons | complete | get stdout | lines | where ($it | str starts-with "sec"))
let n_keys = ($secrets | length)
status ($n_keys > 0) $"secret keys      ($n_keys)"
if ($n_keys == 0) {
  print "FIX: import your secret key, or generate one with `gpg --full-generate-key`."
}

if ($signing_key | str length) > 0 {
  let found = (^gpg --list-secret-keys $signing_key | complete | get exit_code) == 0
  status $found $"signing key ($signing_key) is present in keyring"
  if not $found {
    print $"FIX: gpg does not see ($signing_key). Either import it or fix `git config --global user.signingkey`."
  }
}

# 5. YubiKey (optional) -------------------------------------------------------
if (have "ykman") {
  heading "yubikey"
  let yk = (^ykman list | complete)
  status ($yk.exit_code == 0) "ykman list responds"
  if $yk.exit_code == 0 {
    print $"  ($yk.stdout | str trim)"
  } else {
    print "FIX: yubikey not detected. Plug it in, then touch the key when prompted."
  }
}

# 6. The real test: sign a tiny payload --------------------------------------
heading "sign test"
let test = (do { echo "gpg-doctor test" | ^gpg --clearsign --batch --pinentry-mode error } | complete)
status ($test.exit_code == 0) "bare gpg --clearsign"
if $test.exit_code != 0 {
  print $"  ($test.stderr | str trim)"
}

# 6b. Also sign-test through git's configured gpg.program if it's a wrapper.
# git invokes that program, not bare gpg, so a wrapper failure breaks
# `git commit` even when bare gpg works.
let gpg_program = (^git config --global gpg.program | complete | get stdout | str trim)
let bare_gpg = (which gpg | get path.0? | default "")
let wrapper_test = if (($gpg_program | str length) > 0) and ($gpg_program != $bare_gpg) {
  if not ($gpg_program | path exists) {
    status false $"gpg.program ($gpg_program) does not exist on disk"
    null
  } else {
    let r = (do { echo "gpg-doctor test" | ^$gpg_program --clearsign --batch } | complete)
    status ($r.exit_code == 0) $"gpg.program wrapper: ($gpg_program)"
    if $r.exit_code != 0 {
      print $"  ($r.stderr | str trim)"
    }
    $r
  }
} else {
  null
}

let wrapper_ok = ($wrapper_test == null) or ($wrapper_test.exit_code == 0)
let bare_ok = ($test.exit_code == 0)

if $bare_ok and $wrapper_ok {
  print ""
  print "All checks passed. Retry your `git commit`."
  exit 0
} else if $bare_ok and (not $wrapper_ok) {
  print ""
  print $"Bare gpg signs fine but gpg.program (($gpg_program)) fails."
  print "git uses gpg.program for commit signing, so commits will still break."
  print ""
  print "Most-likely fixes:"
  print "  1. Run the wrapper directly to see its raw error:"
  print $"       echo test | ($gpg_program) --clearsign --batch"
  print "  2. If the wrapper shells out to other tools (aws, ssm, vault, etc.),"
  print "     check whether the current shell can reach them (lockdown, PATH, creds)."
  print "  3. Unset gpg.program temporarily as a workaround:"
  print "       git -c gpg.program=gpg commit ..."
  exit 1
} else {
  print ""
  print "Most-likely fixes, in order:"
  print "  1. Touch your YubiKey if it's plugged in (gpg waits silently for the touch)."
  print "  2. Cache the passphrase by running interactively:"
  print "       echo test | gpg --clearsign"
  print "     and entering your passphrase when prompted."
  print "  3. Restart the agent:"
  print "       gpgconf --kill gpg-agent"
  print "       gpg-agent --daemon"
  print "  4. Check that GPG_TTY is exported in your current shell:"
  print "       $env.GPG_TTY = (tty | str trim)"
  exit 1
}
