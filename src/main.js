// Import Bootstrap's CSS
import './scss/style.css'
import 'bootstrap/dist/css/bootstrap.min.css'
import { LuaFactory, luaFactory } from "wasmoon"
// Import all of Bootstrap's JS (Popper is included automatically)
import * as bootstrap from 'bootstrap'
import { initPWA } from './pwa.js'
import { fs } from '@zenfs/core'; // You can also use the default export

fs.writeFileSync('/test.txt', 'You can do this anywhere, including browsers!');

const contents = fs.readFileSync('/test.txt', 'utf-8');
console.log(contents);
const app = document.querySelector('#app')
app.innerHTML = `
  <div>
    <img src="https://theluafox86.github.io/logo.jpg" style="width: 20%; height: 20%">
    <h1>hello, im LuaFox</h1>
    <p class="read-the-docs">
      im working on it comming soon
    </p>
  </div>
  <div
    id="pwa-toast"
    role="alert"
    aria-labelledby="toast-message"
  >
    <div class="message">
      <span id="toast-message"></span>
    </div>
    <div class="buttons">
      <button id="pwa-refresh" type="button">
        Reload
      </button>
      <button id="pwa-close" type="button">
        Close
      </button>
    </div>
  </div>
`
initPWA(app)
const factory = new LuaFactory()
const lua = await factory.createEngine()
lua.global.set("print", function(txt) {
  console.log(txt)
})
lua.global.set("app", app)
lua.global.set("alert", window.alert)
lua.doString(
  'alert("hello from wasmoon (lua) ")'
)