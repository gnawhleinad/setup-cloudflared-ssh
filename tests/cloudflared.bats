#!/usr/bin/env bats

@test "exists cloudflared" {
  command -v cloudflared
}

@test "verify cloudflared --version" {
  [[ $(cloudflared --version) =~ ^cloudflared version .* ]]
}
