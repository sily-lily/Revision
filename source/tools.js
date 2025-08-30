// Source of function: https://chatgpt.com/
function RNG(minimum, maximum) {
  return Math.floor(Math.random() * (maximum - minimum + 1)) + minimum;
}

module.exports = {
  RNG: RNG,
};
