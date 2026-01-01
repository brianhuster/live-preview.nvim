#!/usr/bin/env node

/**
 * Test script to demonstrate the Unicode/Chinese character fix
 * This simulates how the live-preview server sends HTTP responses
 */

const fs = require('fs');
const path = require('path');

console.log('='.repeat(70));
console.log('Unicode Character Rendering Fix - Demonstration');
console.log('='.repeat(70));
console.log();

// Read the content_type.lua file
const contentTypePath = path.join(__dirname, '../lua/livepreview/server/utils/content_type.lua');
const contentTypeLua = fs.readFileSync(contentTypePath, 'utf8');

// Extract relevant MIME types
const mimeTypes = {
  'html': contentTypeLua.match(/\["html"\]\s*=\s*"([^"]+)"/)?.[1],
  'htm': contentTypeLua.match(/\["htm"\]\s*=\s*"([^"]+)"/)?.[1],
  'css': contentTypeLua.match(/\["css"\]\s*=\s*"([^"]+)"/)?.[1],
  'js': contentTypeLua.match(/\["js"\]\s*=\s*"([^"]+)"/)?.[1],
  'svg': contentTypeLua.match(/\["svg"\]\s*=\s*"([^"]+)"/)?.[1],
  'xml': contentTypeLua.match(/\["xml"\]\s*=\s*"([^"]+)"/)?.[1],
};

console.log('📋 MIME Type Configuration Check:');
console.log('-'.repeat(70));

let allPass = true;
for (const [ext, mimeType] of Object.entries(mimeTypes)) {
  const hasCharset = mimeType && mimeType.includes('charset=UTF-8');
  const status = hasCharset ? '✓' : '✗';
  console.log(`  ${status} .${ext.padEnd(6)} → ${mimeType || 'NOT FOUND'}`);
  if (!hasCharset) allPass = false;
}

console.log();

// Simulate HTTP response
console.log('📡 Sample HTTP Response (for HTML file):');
console.log('-'.repeat(70));

const htmlContentType = mimeTypes['html'];
const testHtmlPath = path.join(__dirname, 'test-unicode.html');
const testHtml = fs.readFileSync(testHtmlPath, 'utf8');
const contentLength = Buffer.byteLength(testHtml, 'utf8');

console.log('HTTP/1.1 200 OK');
console.log(`Content-Type: ${htmlContentType}`);
console.log(`Content-Length: ${contentLength}`);
console.log('Connection: close');
console.log();
console.log('<!DOCTYPE html>');
console.log('<html lang="zh-CN">');
console.log('  <head>');
console.log('    <title>Unicode Test - 你好世界</title>');
console.log('  </head>');
console.log('  <body>');
console.log('    <h1>你好世界 Hello World</h1>');
console.log('    ...');
console.log('  </body>');
console.log('</html>');
console.log();

// Check test file
console.log('🧪 Test File Analysis:');
console.log('-'.repeat(70));

const unicodePatterns = [
  { name: 'Chinese', pattern: /你好世界/, sample: '你好世界' },
  { name: 'Japanese', pattern: /これは日本語/, sample: 'これは日本語' },
  { name: 'Korean', pattern: /한국어/, sample: '한국어' },
  { name: 'Emoji', pattern: /🌟/, sample: '🌟 🎉 🚀' },
  { name: 'Math symbols', pattern: /∀/, sample: '∀ ∃ ∈' },
  { name: 'Currency', pattern: /€/, sample: '€ £ ¥' },
];

for (const { name, pattern, sample } of unicodePatterns) {
  const found = pattern.test(testHtml);
  const status = found ? '✓' : '✗';
  console.log(`  ${status} ${name.padEnd(15)} found in test file: ${sample}`);
}

console.log();
console.log('='.repeat(70));

if (allPass) {
  console.log('✅ SUCCESS: All MIME types correctly include charset=UTF-8');
  console.log('');
  console.log('The fix ensures that browsers will correctly interpret Unicode');
  console.log('characters in HTML, CSS, JavaScript, SVG, and XML files.');
  console.log('');
  console.log('Before: text/html (browser may default to ISO-8859-1)');
  console.log('After:  text/html; charset=UTF-8 (explicit UTF-8 encoding)');
  process.exit(0);
} else {
  console.log('❌ FAILURE: Some MIME types missing charset=UTF-8');
  process.exit(1);
}
