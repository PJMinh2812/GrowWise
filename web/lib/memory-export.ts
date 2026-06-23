import type { Memory } from '@/lib/types'

export type ChildInfo = { name: string; emoji: string }
export type ChildMap = Record<string, ChildInfo>

const CREAM_TOP = '#FFF8E7'
const CREAM_BOTTOM = '#FFFDE7'
const ORANGE = '#f97316'
const NAVY = '#1A1A2E'
const SLATE = '#475569'
const GRAY = '#94A3B8'
const JAKARTA = '"Plus Jakarta Sans", sans-serif'

function loadImage(url: string): Promise<HTMLImageElement | null> {
  return new Promise((resolve) => {
    const img = new Image()
    img.crossOrigin = 'anonymous'
    img.onload = () => resolve(img)
    img.onerror = () => resolve(null)
    img.src = url
  })
}

function roundRect(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number) {
  ctx.beginPath()
  ctx.roundRect(x, y, w, h, r)
}

/** Draw an image cover-fit (like object-fit: cover) into a box. */
function drawCover(
  ctx: CanvasRenderingContext2D,
  img: HTMLImageElement,
  x: number,
  y: number,
  w: number,
  h: number,
) {
  const ir = img.width / img.height
  const br = w / h
  let sw = img.width
  let sh = img.height
  let sx = 0
  let sy = 0
  if (ir > br) {
    sw = img.height * br
    sx = (img.width - sw) / 2
  } else {
    sh = img.width / br
    sy = (img.height - sh) / 2
  }
  ctx.drawImage(img, sx, sy, sw, sh, x, y, w, h)
}

/** Draw wrapped text; returns the y after the last line. */
function wrapText(
  ctx: CanvasRenderingContext2D,
  text: string,
  x: number,
  y: number,
  maxWidth: number,
  lineHeight: number,
): number {
  const words = text.split(' ')
  let line = ''
  let cy = y
  for (const word of words) {
    const test = line ? `${line} ${word}` : word
    if (ctx.measureText(test).width > maxWidth && line) {
      ctx.fillText(line, x, cy)
      line = word
      cy += lineHeight
    } else {
      line = test
    }
  }
  if (line) {
    ctx.fillText(line, x, cy)
    cy += lineHeight
  }
  return cy
}

function placeholder(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number) {
  ctx.fillStyle = '#F1F5F9'
  ctx.fillRect(x, y, w, h)
  ctx.fillStyle = GRAY
  ctx.textAlign = 'center'
  ctx.font = `${Math.round(h * 0.25)}px sans-serif`
  ctx.fillText('📷', x + w / 2, y + h / 2 + h * 0.08)
  ctx.textAlign = 'left'
}

/** A single decorated GrowWise postcard for one memory (1080×1400). */
export async function drawPostcard(m: Memory, childName?: string): Promise<HTMLCanvasElement> {
  await document.fonts.ready
  const W = 1080
  const H = 1400
  const canvas = document.createElement('canvas')
  canvas.width = W
  canvas.height = H
  const ctx = canvas.getContext('2d')!

  // background
  const g = ctx.createLinearGradient(0, 0, 0, H)
  g.addColorStop(0, CREAM_TOP)
  g.addColorStop(1, CREAM_BOTTOM)
  ctx.fillStyle = g
  ctx.fillRect(0, 0, W, H)

  // inner white card
  ctx.save()
  ctx.shadowColor = 'rgba(0,0,0,0.08)'
  ctx.shadowBlur = 30
  ctx.shadowOffsetY = 10
  ctx.fillStyle = '#ffffff'
  roundRect(ctx, 40, 40, W - 80, H - 80, 40)
  ctx.fill()
  ctx.restore()

  // header
  ctx.textAlign = 'left'
  ctx.fillStyle = ORANGE
  ctx.font = `800 56px ${JAKARTA}`
  ctx.fillText('GrowWise', 90, 150)
  const brandW = ctx.measureText('GrowWise').width
  ctx.font = '44px sans-serif'
  ctx.fillText('🌱', 90 + brandW + 16, 150)
  ctx.fillStyle = GRAY
  ctx.font = `600 30px ${JAKARTA}`
  ctx.fillText('Kỷ niệm của con', 92, 200)

  // photo frame
  const px = 90
  const py = 250
  const pw = W - 180
  const ph = 620
  ctx.save()
  ctx.shadowColor = 'rgba(0,0,0,0.1)'
  ctx.shadowBlur = 20
  ctx.shadowOffsetY = 8
  ctx.fillStyle = '#fff'
  roundRect(ctx, px - 12, py - 12, pw + 24, ph + 24, 28)
  ctx.fill()
  ctx.restore()

  const img = m.proof_image_url ? await loadImage(m.proof_image_url) : null
  ctx.save()
  roundRect(ctx, px, py, pw, ph, 20)
  ctx.clip()
  if (img) drawCover(ctx, img, px, py, pw, ph)
  else placeholder(ctx, px, py, pw, ph)
  ctx.restore()

  // caption
  let y = py + ph + 90
  ctx.textAlign = 'left'
  ctx.fillStyle = NAVY
  ctx.font = `800 50px ${JAKARTA}`
  y = wrapText(ctx, `${m.emoji} ${m.task_title}`, 90, y, pw, 62)

  if (m.note) {
    ctx.fillStyle = SLATE
    ctx.font = `italic 34px ${JAKARTA}`
    y += 16
    y = wrapText(ctx, `"${m.note}"`, 90, y, pw, 46)
  }

  ctx.fillStyle = GRAY
  ctx.font = `600 30px ${JAKARTA}`
  const dateStr = new Date(m.created_at).toLocaleDateString('vi-VN')
  ctx.fillText(`${childName ? childName + ' · ' : ''}${dateStr}`, 90, y + 50)

  // footer
  ctx.fillStyle = ORANGE
  ctx.textAlign = 'center'
  ctx.font = `700 28px ${JAKARTA}`
  ctx.fillText('🌱 GrowWise — Dạy con yêu tiền', W / 2, H - 70)

  return canvas
}

/** A collage album of all memories on one tall canvas. */
export async function drawAlbum(memories: Memory[], childMap: ChildMap): Promise<HTMLCanvasElement> {
  await document.fonts.ready
  const W = 1080
  const pad = 40
  const gap = 30
  const cols = 2
  const cardW = (W - pad * 2 - gap) / cols
  const imgH = 300
  const cardH = imgH + 140
  const headerH = 210
  const footerH = 110
  const rows = Math.ceil(memories.length / cols)
  const H = headerH + rows * (cardH + gap) + footerH

  const canvas = document.createElement('canvas')
  canvas.width = W
  canvas.height = H
  const ctx = canvas.getContext('2d')!

  const g = ctx.createLinearGradient(0, 0, 0, H)
  g.addColorStop(0, CREAM_TOP)
  g.addColorStop(1, CREAM_BOTTOM)
  ctx.fillStyle = g
  ctx.fillRect(0, 0, W, H)

  // header
  ctx.textAlign = 'center'
  ctx.fillStyle = ORANGE
  ctx.font = `800 56px ${JAKARTA}`
  ctx.fillText('GrowWise 🌱', W / 2, 110)
  ctx.fillStyle = NAVY
  ctx.font = `800 40px ${JAKARTA}`
  ctx.fillText('Album kỷ niệm của con', W / 2, 170)

  const images = await Promise.all(
    memories.map((m) => (m.proof_image_url ? loadImage(m.proof_image_url) : Promise.resolve(null))),
  )

  memories.forEach((m, i) => {
    const col = i % cols
    const row = Math.floor(i / cols)
    const x = pad + col * (cardW + gap)
    const yy = headerH + row * (cardH + gap)

    // card
    ctx.save()
    ctx.shadowColor = 'rgba(0,0,0,0.08)'
    ctx.shadowBlur = 16
    ctx.shadowOffsetY = 6
    ctx.fillStyle = '#fff'
    roundRect(ctx, x, yy, cardW, cardH, 24)
    ctx.fill()
    ctx.restore()

    // photo
    ctx.save()
    roundRect(ctx, x + 16, yy + 16, cardW - 32, imgH, 16)
    ctx.clip()
    const img = images[i]
    if (img) drawCover(ctx, img, x + 16, yy + 16, cardW - 32, imgH)
    else placeholder(ctx, x + 16, yy + 16, cardW - 32, imgH)
    ctx.restore()

    // title
    ctx.textAlign = 'left'
    ctx.fillStyle = NAVY
    ctx.font = `700 30px ${JAKARTA}`
    const title = `${m.emoji} ${m.task_title}`
    const clipped =
      ctx.measureText(title).width > cardW - 40
        ? title.slice(0, 18) + '…'
        : title
    ctx.fillText(clipped, x + 20, yy + imgH + 60)

    // date + child
    ctx.fillStyle = GRAY
    ctx.font = `600 24px ${JAKARTA}`
    const child = childMap[m.child_id]
    const dateStr = new Date(m.created_at).toLocaleDateString('vi-VN')
    ctx.fillText(`${child ? child.name + ' · ' : ''}${dateStr}`, x + 20, yy + imgH + 100)
  })

  // footer
  ctx.textAlign = 'center'
  ctx.fillStyle = ORANGE
  ctx.font = `700 28px ${JAKARTA}`
  ctx.fillText('🌱 GrowWise — Dạy con yêu tiền', W / 2, H - 50)

  return canvas
}

/** Trigger a PNG download of a canvas. Throws if the canvas is tainted (CORS). */
export function downloadCanvas(canvas: HTMLCanvasElement, filename: string): Promise<void> {
  return new Promise((resolve, reject) => {
    canvas.toBlob((blob) => {
      if (!blob) {
        reject(new Error('toBlob failed (canvas tainted?)'))
        return
      }
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = filename
      document.body.appendChild(a)
      a.click()
      a.remove()
      URL.revokeObjectURL(url)
      resolve()
    }, 'image/png')
  })
}

export function safeFilename(s: string): string {
  return s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '') // strip Vietnamese diacritics
    .replace(/[^a-zA-Z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase()
    .slice(0, 40)
}
