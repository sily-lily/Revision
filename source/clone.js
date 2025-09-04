const fs = require("node:fs");
const path = require("node:path");

const ScramJetServer = path.join(process.cwd(), "ScramJet", "server.js");

function hasServer() {
    return fs.existsSync(ScramJetServer);
}

if (hasServer()) {
    const watermark = fs.readFileSync(path.join(process.cwd(), "source", "watermark.txt"), "utf-8");
    let content = `${watermark}\n\n${fs.readFileSync(ScramJetServer, "utf-8")}`;

    fs.writeFileSync(path.join(process.cwd(), "source", "server.js"), content, "utf-8");
} else {
    console.log("Server not found, please run: bash scripts/init.sh");
}