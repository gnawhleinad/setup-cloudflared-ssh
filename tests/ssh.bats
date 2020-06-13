#!/usr/bin/env bats

@test "exists ~/.ssh/known_hosts" {
  [ -f ~/.ssh/known_hosts ]
}

@test "exists ~/.ssh/config" {
  [ -f ~/.ssh/config ]
}

@test "exists ~/.ssh/{key}" {
  [ $(find ~/.ssh -type f ! -name config -o ! -name known_hosts | wc -l) -eq 1 ]
}

@test "~/.ssh is 700" {
  [ $(stat --format '%a' ~/.ssh) -eq 700 ]
}

@test "~/.ssh/{key} is 600" {
  [ $(find ~/.ssh -type f ! -name config -o ! -name known_hosts -exec stat --format '%a' {} \;) -eq 600 ]
}
