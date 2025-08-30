// Source of function: https://chatgpt.com/
function RNG() {
  return Math.floor(Math.random() * (65535 - 100) + 100);
}

module.exports = {
  RNG: RNG,
};
