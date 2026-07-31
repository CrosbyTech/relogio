// Gera os PNGs exigidos pelo manifest do canal Roku (icone e splash).
// Sao imagens de cor solida no fundo da marca — nao ha dependencia externa,
// o PNG e montado na mao com o zlib do proprio Node.
//
//   node tools/gerar-icones.js

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const BG = [0x02, 0x03, 0x08]; // #020308

const CRC_TABLE = (() => {
  const table = new Int32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    table[n] = c;
  }
  return table;
})();

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const body = Buffer.concat([Buffer.from(type, 'ascii'), data]);
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(body), 0);
  return Buffer.concat([len, body, crc]);
}

function solidPng(width, height, [r, g, b]) {
  const stride = width * 3 + 1; // +1 do byte de filtro por linha
  const raw = Buffer.alloc(stride * height);
  for (let y = 0; y < height; y++) {
    const off = y * stride;
    raw[off] = 0; // filtro None
    for (let x = 0; x < width; x++) {
      raw[off + 1 + x * 3] = r;
      raw[off + 2 + x * 3] = g;
      raw[off + 3 + x * 3] = b;
    }
  }

  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 2; // color type: truecolor RGB

  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0)),
  ]);
}

const OUT = path.join(__dirname, '..', 'roku', 'images');
fs.mkdirSync(OUT, { recursive: true });

const files = [
  ['icon_focus_hd.png', 336, 210],
  ['icon_side_hd.png', 108, 69],
  ['splash_hd.png', 1280, 720],
  ['splash_fhd.png', 1920, 1080],
];

for (const [name, w, h] of files) {
  const file = path.join(OUT, name);
  fs.writeFileSync(file, solidPng(w, h, BG));
  console.log(`${name}  ${w}x${h}`);
}
