#!/usr/bin/env bats

@test "exists cloudflared" {
  command -v cloudflared
}

@test "verify cloudflared version" {
  [[ $(cloudflared --version) = "cloudflared version 2020.6.1 (built 2020-06-09-2126 UTC)" ]]
}
