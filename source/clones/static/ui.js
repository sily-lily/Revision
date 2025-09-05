/**
 * 
 *  I can't believe how poorly coded ScramJet files are..
 * 
 *  I tried to remove all of their UI (if I remade it) and 
 *   replaced it with mine.
 * 
 *  Hopefully, this should look better..
 * 
 */

import fs from "node:fs";
import path from "node:path";
const { ScramjetController } = $scramjetLoadController();

const scramjet = new ScramjetController({
	files: {
		wasm: "/scram/scramjet.wasm.wasm",
		all: "/scram/scramjet.all.js",
		sync: "/scram/scramjet.sync.js",
	},
	flags: {
		rewriterLogs: false,
		scramitize: false,
		cleanErrors: true,
		sourcemaps: true,
	},
});

scramjet.init();
navigator.serviceWorker.register("./sw.js");

const connection = new BareMux.BareMuxConnection("/baremux/worker.js");
const flex = css`display: flex;`;

connection.setTransport(store.transport, [{ wisp: store.wispurl }]);
function BrowserApp() {
	this.url = store.url;

	const frame = scramjet.createFrame();
	this.mount = () => {
		let body = btoa(fs.readFileSync(path.join(process.cwd(), "..", "..", "public", "index.html"), "utf-8"));
		frame.go(`data:text/html;base64,${body}`);
	};

	frame.addEventListener("urlchange", (e) => {
		if (!e.url) return;
		this.url = e.url;
	});

	const handleSubmit = () => {
		this.url = this.url.trim();
		//  frame.go(this.url)
		if (!this.url.startsWith("http")) {
			this.url = "https://" + this.url;
		}

		return frame.go(this.url);
	};

	const cfg = h(Config);
	document.body.appendChild(cfg);
	this.githubURL = `https://github.com/MercuryWorkshop/scramjet/commit/${$scramjetVersion.build}`;

    const searchBar = document.getElementById("search")
    /**
     * ${use(this.url)} on:input=${(e) => {
					this.url = e.target.value;
				}} on:keyup=${(e) => e.keyCode == 13 && (store.url = this.url) && handleSubmit()}
     */
    searchBar.addEventListener("keydown", function(event) {
        if (event.key === "Enter") {
            event.preventDefault();
            alert(1);
        }
    });
	return html`
      ${frame.frame}
    `;
}
window.addEventListener("load", async () => {
	const root = document.getElementById("app");
	try {
		root.replaceWith(h(BrowserApp));
	} catch (e) {
		root.replaceWith(document.createTextNode("" + e));
		throw e;
	}
	function b64(buffer) {
		let binary = "";
		const bytes = new Uint8Array(buffer);
		const len = bytes.byteLength;
		for (let i = 0; i < len; i++) {
			binary += String.fromCharCode(bytes[i]);
		}

		return btoa(binary);
	}
	const arraybuffer = await (await fetch("/assets/scramjet.png")).arrayBuffer();
    console.log(
		"%cb",
		`
            background-image: url(data:image/png;base64,${b64(arraybuffer)});
            color: transparent;
            padding-left: 200px;
            padding-bottom: 100px;
            background-size: contain;
            background-position: center center;
            background-repeat: no-repeat;
        `
	);
});