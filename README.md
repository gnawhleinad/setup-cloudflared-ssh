setup `~/.ssh` using [cloudflared access service token] and installs
[`cloudflared`]

[cloudflared access service token]: https://developers.cloudflare.com/access/service-auth/service-token/
[`cloudflared`]: https://github.com/cloudflare/cloudflared

### `TODO` / limitations

- [ ] assumes `sshd` is on port 22
- [ ] only works for a single remote machine jumping through a bastion
- [ ] assumes bastion and remote machine use the same user
- [ ] assumes private key is encrypted
- [ ] only works for `linux`
- [ ] installs [hardcoded version(s)] or the latest from the [`stable` channel]

[hardcoded version(s)]: cloudflared-versions
[`stable` channel]: https://dl.equinox.io/cloudflare/cloudflared/stable

### usage

```yaml
- uses: gnawhleinad/setup-cloudflared-ssh@v0.0.3
  with:
    # cloudflared --version (default: stable)
    cloudflared-version: stable

    # cloudflared access service token id
    cloudflared-service-token-id:

    # cloudflared access service token secret
    cloudflared-service-token-secret:

    # ssh bastion hostname (cloudflared access hostname)
    ssh-bastion:

    # contents of ~/.ssh/known_hosts (appended)
    ssh-known-hosts:

    # contents of ~/.ssh/{encrypted-key}
    ssh-private-key:

    # passphrase for ~/.ssh/{encrypted-key}
    ssh-passphrase:

    # ssh hostname
    ssh-hostname:
```

### `~/.ssh/config`

```ssh-config
Host {{ssh-bastion}}
        HostName {{ssh-bastion}}
        Port 22
        IdentityFile ~/.ssh/{{ssh-private-key}}
        ProxyCommand cloudflared access ssh --id {{cloudflared-service-token-id}} --secret {{cloudflared-service-token-secret}} --hostname %h

Host {{ssh-hostname}}
        HostName {{ssh-hostname}}
        Port 22
        IdentityFile ~/.ssh/{{ssh-private-key}}
        ProxyJump %r@{{ssh-bastion}}
```

see [`dist/setup-ssh.sh`] for more details

[`dist/setup-ssh.sh`]: dist/setup-ssh.sh
