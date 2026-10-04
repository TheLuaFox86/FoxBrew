// Import Bootstrap's CSS
import './scss/style.css'
import 'bootstrap/dist/css/bootstrap.min.css'
import fs from 'indexeddb-fs';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit'
import '@xterm/xterm/css/xterm.css';
import { Readline } from 'xterm-readline'; 
import { LuaFactory, luaFactory } from "wasmoon"
// Import all of Bootstrap's JS (Popper is included automatically)
import * as bootstrap from 'bootstrap'
import { initPWA } from './pwa.js'

const app = document.querySelector('#app')
app.innerHTML = `
  <div id="splash">
    <div style="text-align: center;">
      <img src="https://theluafox86.github.io/logo.jpg" style="width: 128px; height: auto;">
      <h1>hello, im LuaFox</h1>
      <p class="read-the-docs">im working on it comming soon</p>
    </div>
    <div id="pwa-toast" role="alert" aria-labelledby="toast-message">
      <div class="message"><span id="toast-message"></span></div>
      <div class="buttons">
        <button id="pwa-refresh" type="button">Reload</button>
        <button id="pwa-close" type="button">Close</button>
      </div>
    </div>
  </div>
  <div id="terminal" style="display:none;width:100%;height:100%;"></div>
`   
initPWA(app)
// Check if a directory exists
  
  const TEXT_EXT = /\.(txt|json|js|ts|css|html|md|xml|csv|svg|lua|wasm|py)$/i;
  
  async function isAccessible(url) {
  try {
    const r = await fetch(url, { method: 'HEAD', cache: 'no-store' });
    return r.ok;
  } catch {
    return false;
  }
}   
async function hydrateRO() {
  if (isAccessible("/FoxBrew/FBOS/_manifest.json")) {
      console.log("Updating System")
      var directoryExists = false;
      if (await fs.exists("/OS")) {
        directoryExists = await fs.isDirectory('/OS');
      }
    // Create a new directory if it doesn't exist
      if (directoryExists) {
        await fs.removeDirectory("/OS")
      }
      await fs.createDirectory('/OS');

      const res = await fetch('/FoxBrew/FBOS/_manifest.json');
      const files = await res.json();

      // Create directories
      const dirs = new Set();
      for (const file of files) {
        const dir = file.substring(0, file.lastIndexOf('/'));
        if (dir) dirs.add(dir);
      }
      for (const dir of dirs) {
        if (!(await fs.isDirectory(dir))) {
          await fs.createDirectory(dir);
        }
      }

      // Write files
      await Promise.all(
        files.map(async (file) => {
          const vfsPath = `OS${file}`; // e.g. "ro/config.json"
          const res = await fetch(`/FoxBrew/FBOS${file}`);
          const buf = await res.arrayBuffer();

          if (TEXT_EXT.test(vfsPath)) {
            await fs.writeFile(vfsPath, new TextDecoder().decode(buf));
          } else {
            await fs.writeFile(vfsPath, buf);
          }
        })
      );
    }
  }
hydrateRO().then(function() {
  async function main() {
  
    const factory = new LuaFactory()
    const lua = await factory.createEngine()
    lua.global.set("print", console.log)
    lua.global.set("printErr", console.error)
    lua.global.set("fs", fs)
    lua.global.set("jswasi", {})
    var term = new Terminal()
    const fitAddon = new FitAddon();
    term.loadAddon(fitAddon)
    term.open(document.getElementById("terminal"))
    const observer = new ResizeObserver(() => fitAddon.fit());
    observer.observe(document.getElementById('terminal'));

    lua.global.set("FA", fitAddon)  
    
    lua.global.set("term", term)
    lua.global.set("RL", new Readline())
    lua.global.set("DOCUMENT", document)
    lua.global.set("app", app)
    lua.global.set("splash", document.getElementById("splash"))
    lua.global.set("terminalContainer", document.getElementById("terminal"))
    lua.doString(await fs.readFile("/OS/BIOS.lua"))

  }
   main();
})