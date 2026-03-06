const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const sizes = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192
};

const basePath = '/home/test/.openclaw/workspace/badminton-diary-flutter/android/app/src/main/res';

async function createIcon(size, folder) {
  // 创建绿色背景 + 白色圆形
  const svg = `
    <svg width="${size}" height="${size}" xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="#07C160"/>
      <circle cx="${size/2}" cy="${size/2}" r="${size/3}" fill="white"/>
    </svg>
  `;
  
  const buffer = await sharp(Buffer.from(svg))
    .png()
    .toBuffer();
  
  fs.writeFileSync(path.join(basePath, folder, 'ic_launcher.png'), buffer);
  fs.writeFileSync(path.join(basePath, folder, 'ic_launcher_round.png'), buffer);
  
  console.log(`Created ${folder}/ic_launcher.png (${size}x${size})`);
}

async function main() {
  for (const [folder, size] of Object.entries(sizes)) {
    await createIcon(size, folder);
  }
  console.log('All icons created!');
}

main().catch(console.error);
