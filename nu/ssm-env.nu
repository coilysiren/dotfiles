# In-process AWS SSM secret loader.
#
# Pulls every SSM parameter under / from the named profile and loads
# them into the current nu process environment. Never writes to disk.
#
# Var name derivation matches the legacy script: /foo/bar-baz -> FOO_BAR_BAZ
#
# Usage (interactive):   ssm-load
# Usage (other profile): ssm-load --profile other --region us-west-2
# Usage (one var only):  ssm-get /foo/bar-baz

export def --env ssm-load [
  --profile: string = "default"
  --region: string = "us-east-1"
] {
  let raw = (
    with-env { AWS_PROFILE: $profile, AWS_REGION: $region } {
      ^aws ssm get-parameters-by-path --path "/" --recursive --with-decryption --query "Parameters[].{Name:Name,Value:Value}" --output json
    } | from json
  )

  mut acc = {}
  for p in $raw {
    let key = (
      $p.Name
      | str substring 1..
      | str replace --all '/' '_'
      | str replace --all '-' '_'
      | str upcase
    )
    $acc = ($acc | upsert $key $p.Value)
  }
  load-env $acc
  print $"loaded ($acc | columns | length) SSM exports into env"
}

export def ssm-get [
  name: string
  --profile: string = "default"
  --region: string = "us-east-1"
] {
  with-env { AWS_PROFILE: $profile, AWS_REGION: $region } {
    ^aws ssm get-parameter --name $name --with-decryption --query "Parameter.Value" --output text
  }
}
