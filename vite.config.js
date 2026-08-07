import { VitePWA } from 'vite-plugin-pwa';
import { defineConfig } from 'vite'
import topLevelAwait from 'vite-plugin-top-level-await';
import basicSsl from "@vitejs/plugin-basic-ssl";
import mkcert from "vite-plugin-mkcert"

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
      globPatterns: ['**/*.{js,css,html,svg,png,ico}'],
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
  mkcert()
  ],
  server: {
    https: true
  }
})