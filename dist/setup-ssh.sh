#!/usr/bin/env bash

set -euo pipefail

[[ -z "$CLOUDFLARED_SERVICE_TOKEN_ID" ]] || \
  [[ -z "$CLOUDFLARED_SERVICE_TOKEN_SECRET" ]] || \
  [[ -z "$SSH_BASTION" ]] || \
  [[ -z "$SSH_KNOWN_HOSTS" ]] || \
  [[ -z "$SSH_PRIVATE_KEY" ]] || \
  [[ -z "$SSH_PRIVATE_KEY_PASSPHRASE" ]] || \
  [[ -z "$SSH_HOSTNAME" ]] || {
  echo "ERROR: missing environment variable"
  exit 1
}

cd
mkdir -p ~/.ssh
chmod 700 ~/.ssh

cat "${SSH_KNOWN_HOSTS}" >> ~/.ssh/known_hosts

uuid="$(< /dev/urandom tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
cat "${SSH_PRIVATE_KEY}" > "${HOME}/.ssh/${uuid}"
ssh-keygen -p -P "${SSH_PRIVATE_KEY_PASSPHRASE}" -N "" -f "${HOME}/.ssh/${uuid}"
chmod 600 "${HOME}/.ssh/${uuid}"

cat << OHANA_MEANS_FAMILY >> ~/.ssh/config
Host ${BASTION}
        HostName ${BASTION}
        Port 22
        IdentityFile ~/.ssh/${uuid}
        ProxyCommand 'cloudflared access ssh --id ${CLOUDFLARED_SERVICE_TOKEN_ID} --secret ${CLOUDFLARED_SERVICE_TOKEN_SECRET} --hostname %h'

Host ${SSH_HOSTNAME}
        HostName ${SSH_HOSTNAME}
        Port 22
        IdentityFile ~/.ssh/${uuid}
        ProxyJump ${BASTION}
OHANA_MEANS_FAMILY
