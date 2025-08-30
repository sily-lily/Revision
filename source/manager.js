const { readFileSync, writeFileSync } = require("node:fs");
const { RNG } = require("./tools");
const path = require("node:path");

class PORTManager {
  maxPORTLimit = JSON.parse(readFileSync(path.join("settings.json"), "utf-8")).maxPORTLimit;
  isBanned(PORT) {
    if (!PORT || PORT.length <= 0) {
      throw new Error(`Couldn't identify if "${PORT}" is banned.`);
    }

    const parsed = JSON.parse(readFileSync(path.join("cache.json"), "utf-8"));
    const PORTInfo = parsed.PORTInfo;
    var banned = false;
    for (const PORTkey in PORTInfo) {
      const cachedPORT = PORTInfo[PORTkey];
      if (cachedPORT === PORT.toString() && cachedPORT.banned) {
        banned = true;
        break;
      }
    }

    return banned;
  }

  newPORT() {
    var PORT = -1;
    while (PORT === -1) {
      const generated = RNG(1, 65535);
      if (!this.isBanned(generated)) {
        PORT = generated;
        console.log(`Generated a new available PORT! (${generated})`);
      }
    }

    return PORT;
  }

  // Ignore my shitty code, please
  pickPORT() {
    const parsed = JSON.parse(readFileSync(path.join("cache.json"), "utf-8"));
    const precheck = parsed.precheck;
    const PORTInfo = parsed.PORTInfo;
    const check = () => {
      const makeNew = () => {
        const cachedPORT = this.newPORT();
        PORTInfo[cachedPORT.toString()] = {
          "uses": 0,
          "banned": false,
          "PORT": cachedPORT
        }

        precheck.usingAny = true;
        precheck.PORT = cachedPORT;
        PORTInfo[cachedPORT.toString()].uses += 1;
        console.log(`Generated new PORT. (${cachedPORT})`);
      }

      if ((!precheck.usingAny || precheck.PORT === -1) && !PORTInfo[precheck.PORT]) {
        console.log("Choosing a new PORT for you..");
        if (PORTInfo.length > 2) {
          for (const PORTkey in PORTInfo) {
            const PORT = PORTInfo[PORTkey];
            if (!PORT.banned) {
              precheck.usingAny = true;
              precheck.PORT = PORT.PORT;
              PORT.uses += 1;
              console.log(`Found and now using new PORT. (${PORT.PORT})`);
              break;
            } else {
              makeNew();
              break;
            }
          }
        } else {
          makeNew();
        }
      } else if ((precheck.usingAny && precheck.PORT !== -1)) {
        if (!PORTInfo[precheck.PORT]) return;
        if (!PORTInfo[precheck.PORT].banned || !PORTInfo[precheck.PORT].uses > this.maxPORTLimit - 1) {
          console.log("Using predetermined PORT for efficiency.");
          PORTInfo[precheck.PORT].uses += 1;
          return precheck.PORT;
        }
      }
    }

    if (PORTInfo[precheck.PORT]) {
      if (precheck.usingAny && PORTInfo[precheck.PORT].uses > this.maxPORTLimit - 1) {
        const PORT = PORTInfo[precheck.PORT];
        PORT.banned = true;
        PORT.uses = -1;
        precheck.usingAny = false;
        precheck.PORT = -1;
        console.log(`Banned PORT from being reusable. Exceeded ${this.maxPORTLimit} use${this.maxPORTLimit > 1 ? 's' : ''}! (${PORT.PORT})`);
      }
    }

    check();
    writeFileSync(path.join("cache.json"), JSON.stringify(parsed, null, "\t"));
    return precheck.PORT || precheck.PORT === -1 && 8000;
  }
}

module.exports = {
  PORTManager: PORTManager,
};
