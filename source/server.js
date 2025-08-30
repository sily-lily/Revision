/**
 *
 *  Revision ~ A new way of evading censorship
 *   Contributors (1): Lily
 *   GitHub: sily-lily | https://github.com/sily-lily/Revision
 *
 *  Thank you to MercuryWorkshop for the original proxy server! (ScramJet)
 *
 */

const express = require("express");
const { readFileSync } = require("fs");
const path = require("node:path");
const { PORTManager } = require("./manager.js");

const app = express();
const manager = new PORTManager();
const PORT = manager.pickPORT();

app.use(express.static("public"));
app.get("/", (_, response) => {
  response.send(readFileSync(path.join("public/index.html"), "utf-8"));
});

app.listen(PORT, () => {
  console.log(`Serving information on PORT:${PORT}`);
});
