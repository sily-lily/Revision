const fs = require("node:fs");
const path = require("node:path");

function ScramJetBuilt() {
    return fs.existsSync(path.join(process.cwd(), "ScramJet")) &&
           fs.existsSync(path.join(process.cwd(), "ScramJet", "RevisionCache.json")) &&
           JSON.parse(fs.readFileSync(path.join(process.cwd(), "ScramJet", "RevisionCache.json"))).installed !== -1
}

if (ScramJetBuilt()) {
    console.log("Overriding ScramJet files ...");
    try {
        const server = fs.readFileSync(path.join(process.cwd(), "source", "clones", "server.js"), "utf-8");
        const ui = fs.readFileSync(path.join(process.cwd(), "source", "clones", "static", "ui.js"), "utf-8");

        fs.writeFileSync(path.join(process.cwd(), "ScramJet", "server.js"), server);
        fs.writeFileSync(path.join(process.cwd(), "ScramJet", "static", "ui.js"), ui);
    
        console.log("Successfully replaced original ScramJet files!");
    } catch (error) {
        console.log(`Failed to replace ScramJet files :( (${error})`);
    }
} else {
    console.log("ScramJet hasn't been built yet. Initiate a build using: bash scripts/init.sh");
}