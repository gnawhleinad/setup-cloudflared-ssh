setup `~/.ssh` using [cloudflared access service token] and installs
[`cloudflared-2020.6.1`]

[cloudflared access service token]: https://developers.cloudflare.com/access/service-auth/service-token/
[`cloudflared-2020.6.1`]: https://github.com/cloudflare/cloudflared/releases/tag/2020.6.1

### `TODO` / limitations

- [ ] assumes `sshd` is on port 22
- [ ] only works for a single remote machine jumping through a bastion
- [ ] assumes bastion and remote machine use the same user
- [ ] assumes private key is encrypted

### usage

```yaml
- uses: gnawhleinad/setup-cloudflared-ssh@v0.0.1
  with:
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
OHANA_MEANS_FAMILY
```

see [`dist/setup-ssh.sh`] for more details

[`dist/setup-ssh.sh`]: dist/setup-ssh.sh
