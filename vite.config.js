import { VitePWA } from 'vite-plugin-pwa';
import { defineConfig } from 'vite'
import { viteStaticCopy } from 'vite-plugin-static-copy';
import topLevelAwait from 'vite-plugin-top-level-await';
import basicSsl from "@vitejs/plugin-basic-ssl";
import mkcert from "vite-plugin-mkcert"
import { readdirSync, writeFileSync, statSync } from 'fs';
import { resolve, relative } from 'path';

// Runs on every `vite dev`, `vite build`, `vite preview`
function generateManifest() {
  const abs = resolve(__dirname, 'public/FBOS');
  const files = [];

  function walk(current) {
    for (const entry of readdirSync(current, { withFileTypes: true })) {
      const full = resolve(current, entry.name);
      if (entry.isDirectory()) {
        walk(full);
      } else {
        files.push('/' + relative(abs, full).split('\\').join('/'));
      }
    }
  }

  walk(abs);
  return files;
}

// Write it into public/ — Vite serves public/ in dev, copies it to dist/ in build
writeFileSync(
  resolve(__dirname, 'public/FBOS/_manifest.json'),
  JSON.stringify(generateManifest(), null, 2)
);


// https://vitejs.dev/config/
export default defineConfig({
  base: '/FoxBrew/',
  plugins: [
    topLevelAwait({
      promiseExportName: "__tla",
      promiseImportName: i =>  `__tla_${i}`
    }),
    VitePWA({
    strategies: "generateSW",
    registerType: "prompt",

    pwaAssets: {
      disabled: false,
      config: true,
    },

    manifest: {
      name: 'FoxBrew',
      short_name: 'FoxBrew',
      description: 'homebrew apps using a browser',
      theme_color: '#ff7700a3',
      display: 'standalone',      // Emulates a native app look
      orientation: 'portrait',
      start_url: '/FoxBrew/',
      scope: '/FoxBrew/',
      icons: [
        {
          src: 'favicon.jpg',
          sizes: '192x192',
          type: 'image/jpeg'
        }
      ]
    },

    workbox: {
      globPatterns: ['/**/*'],
      cleanupOutdatedCaches: true,
      clientsClaim: true,
      modifyURLPrefix: {
        '': '/FoxBrew',
      },
      navigateFallback: '/FoxBrew/index.html'
    },

    devOptions: {
      enabled: false,
      navigateFallback: '/FoxBrew/index.html',
      suppressWarnings: false,
      type: 'module',
    },
  }),
  basicSsl(),
  mkcert(),
  viteStaticCopy({
      targets: [
        {
          src: 'public/FBOS/*',
          dest: 'FBOS', // Preserves structure inside dist
        },
      ],
  })
  ],
  server: {
    https: true
  }
})