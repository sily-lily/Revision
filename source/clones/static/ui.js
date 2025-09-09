/**
 *  
 *  Rewritten version of ScramJet's original UI file, for my search bar :3
 *  
 *  This version includes my UI, since I didn't really like
 *   ScramJet's..
 * 
 *  Hopefully this looks nicer! :3
 *  
 *  ** NOT DESIGNED FOR MOBILE (Or really small screens :3) **
 *  ** Maybe I'll add proper scaling in the future!         **
 * 
 */

const { ScramjetController } = $scramjetLoadController();

const ScramJet = new ScramjetController({
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

ScramJet.init();
navigator.serviceWorker.register("./sw.js");

function showWebContent(body, frame) {
    body.innerHTML = "";
    body.appendChild(frame.frame);
	body.id = "app";

	const footer = document.createElement("footer");
    footer.innerHTML = `
        <input id="search-bar" class="no-cursor search-bar" autocomplete="off" autocapitalize="off" placeholder="Provide any link and access now ..." />
    `;

	body.appendChild(footer);
	const search = document.getElementById("search-bar"); // 100% efficient, I promise..
    search.addEventListener("keydown", function(event) {
		if (event.key == "Enter") {
			var URL = search.value.trim();
			if (!URL.startsWith("http")) URL = "https://" + URL;
			showWebContent(body, frame);
			frame.go(URL);
		}
	});
}

const connection = new BareMux.BareMuxConnection("/baremux/worker.js");
connection.setTransport(store.transport, [{ wisp: store.wispurl }]);
document.addEventListener("DOMContentLoaded", function() {
	var URL = store.url;
	const frame = ScramJet.createFrame();
	const search = document.getElementById("search");
	const body = document.getElementById("app");

	search.value = URL;
    search.addEventListener("keydown", function(event) {
		if (event.key == "Enter") {
			URL = search.value.trim();
			if (!URL.startsWith("http")) URL = "https://" + URL;
			showWebContent(body, frame);
			frame.go(URL);
		}
	});
});