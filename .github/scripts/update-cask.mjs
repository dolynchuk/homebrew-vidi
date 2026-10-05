/**
 * Point the cask at the newest Vidi release.
 *
 * Reads the update feed the app itself reads, checks that the versioned DMG it names is
 * really there, pins its SHA-256, and rewrites Casks/vidi.rb. Writes nothing when the
 * cask already names that build, so a scheduled run with no release is a no-op.
 */
import crypto from 'node:crypto'
import fs from 'node:fs/promises'

const R2 = 'https://pub-27d78e2130484b6d8cd7b966751bb826.r2.dev'
const feed = await (await fetch(`${R2}/releases/latest/latest.json`, { cache: 'no-store' })).json()
const base = String(feed.version).split('+')[0]
const build = Number(feed.build)
if (!/^\d+\.\d+\.\d+$/.test(base) || !Number.isInteger(build)) throw new Error(`Unreadable feed: ${JSON.stringify(feed)}`)

const caskFile = new URL('../../Casks/vidi.rb', import.meta.url)
const current = await fs.readFile(caskFile, 'utf8').catch(() => '')
const version = `${base},${build}`
if (current.includes(`version "${version}"`)) {
  console.log(`Cask already at ${version}`)
  process.exit(0)
}

// The versioned upload, never Vidi-latest.dmg: a pinned checksum on a file that is
// overwritten by every release would break the install the moment the next one lands.
const url = `${R2}/releases/v${base}-build.${build}/Vidi-${base}-arm64.dmg`
let sha256 = typeof feed.sha256 === 'string' && /^[0-9a-f]{64}$/.test(feed.sha256) ? feed.sha256 : null
if (sha256) {
  const head = await fetch(url, { method: 'HEAD' })
  if (!head.ok) throw new Error(`${url} → ${head.status}`)
} else {
  const response = await fetch(url)
  if (!response.ok) throw new Error(`${url} → ${response.status}`)
  sha256 = crypto.createHash('sha256').update(Buffer.from(await response.arrayBuffer())).digest('hex')
}

const template = await fs.readFile(new URL('../cask.rb.template', import.meta.url), 'utf8')
await fs.writeFile(caskFile, template.replace('{{version}}', version).replace('{{sha256}}', sha256).replace('{{r2}}', R2))
console.log(`Cask updated to ${version} (${sha256})`)
