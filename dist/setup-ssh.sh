#!/usr/bin/env bash

set -euo pipefail

{ [ -z ${CLOUDFLARED_SERVICE_TOKEN_ID+x} ] || \
  [ -z ${CLOUDFLARED_SERVICE_TOKEN_SECRET+x} ] || \
  [ -z ${SSH_BASTION+x} ] || \
  [ -z ${SSH_KNOWN_HOSTS+x} ] || \
  [ -z ${SSH_PRIVATE_KEY+x} ] || \
  [ -z ${SSH_PRIVATE_KEY_PASSPHRASE+x} ] || \
  [ -z ${SSH_HOSTNAME+x} ]; } && {
  echo "ERROR: missing environment variable"
  exit 1
}

cd
mkdir -p ~/.ssh
chmod 700 ~/.ssh

echo "${SSH_KNOWN_HOSTS}" >> ~/.ssh/known_hosts

uuid="$(< /dev/urandom tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
echo -e "${SSH_PRIVATE_KEY}" > "${HOME}/.ssh/${uuid}"
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
