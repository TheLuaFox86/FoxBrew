import { VitePWA } from 'vite-plugin-pwa';
import { defineConfig } from 'vite'
import basicSsl from "@vitejs/plugin-basic-ssl";
import mkcert from "vite-plugin-mkcert"

// https://vitejs.dev/config/
export default defineConfig({
  base: '/FoxBrew/',
  plugins: [VitePWA({
    registerType: 'prompt',
    strategies: "generateSW",

    pwaAssets: {
      disabled: false,
      config: true,
    },

    manifest: {
      name: 'FoxBrew',
      short_name: 'FoxBrew',
      description: 'homebrew apps using a browser',
      theme_color: '#3C0000',
      display: 'standalone',      // Emulates a native app look
      orientation: 'portrait',
      start_url: '/FoxBrew/',
      scope: '/FoxBrew/',
      icons: [
        {
          src: 'pwa-192x192.png',
          sizes: '192x192',
          type: 'image/png'
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