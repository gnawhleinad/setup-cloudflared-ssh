import * as core from '@actions/core'
import * as exec from '@actions/exec'
import {ExecOptions} from '@actions/exec/lib/interfaces'
import * as tc from '@actions/tool-cache'
import * as path from 'path'

async function run(): Promise<void> {
  try {
    if (process.platform !== 'linux') {
      throw new Error(`invalid platform: ${process.platform}`)
    }

    const configuration: {[key: string]: string} = {}
    configuration[
      'CLOUDFLARED_SERVICE_TOKEN_ID'
    ] = core.getInput('cloudflared-service-token-id', {required: true})
    configuration[
      'CLOUDFLARED_SERVICE_TOKEN_SECRET'
    ] = core.getInput('cloudflared-service-token-secret', {required: true})
    configuration['SSH_BASTION'] = core.getInput('ssh-bastion', {
      required: true
    })

    configuration['SSH_KNOWN_HOSTS'] = core.getInput('ssh-known-hosts', {
      required: true
    })
    configuration['SSH_PRIVATE_KEY'] = core.getInput('ssh-private-key', {
      required: true
    })
    configuration[
      'SSH_PRIVATE_KEY_PASSPHRASE'
    ] = core.getInput('ssh-passphrase', {required: true})
    configuration['SSH_HOSTNAME'] = core.getInput('ssh-hostname', {
      required: true
    })

    const version = core.getInput('cloudflared-version') || 'stable'

    await installCloudflared(version)
    await setupSsh(configuration)
  } catch (error) {
    core.setFailed(error.message)
  }
}

async function installCloudflared(version: string): Promise<void> {
  core.debug(`installing cloudflared-${version}`)

  let tool = ''
  if (version !== 'stable') {
    tool = tc.find('cloudflared', version)
  }

  if (!tool) {
    tool = await downloadCloudflared(version)
  }

  core.addPath(tool)
}

async function downloadCloudflared(version: string): Promise<string> {
  const cloudflared = 'cloudflared'
  let url = 'https://bin.equinox.io'
  if (version === 'stable') {
    url += '/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.tgz'
  } else if (version === '2020.6.1') {
    url += '/a/W8zBUSyawx/cloudflared-2020.6.1-linux-amd64.tar.gz'
  }
  core.debug(`downloading ${url}`)

  try {
    const download = await tc.downloadTool(url)
    const extracted = await tc.extractTar(download)
    const tool = path.join(extracted, cloudflared)

    if (version !== 'stable') {
      return await tc.cacheFile(tool, cloudflared, cloudflared, version)
    } else {
      return tool
    }
  } catch (err) {
    throw err
  }
}

async function setupSsh(configuration: {[key: string]: string}): Promise<void> {
  core.debug(`setting up ssh`)

  const options: ExecOptions = {}
  options.env = Object.assign(configuration, process.env)
  await exec.exec('bash', [path.join(__dirname, 'setup-ssh.sh')], options)
}

run()
