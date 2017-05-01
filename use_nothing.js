var PEG = require("./donothing.js");
var input = process.argv[2] || "5+3*2";
console.log(`Processing <${input}>`);
var r = PEG.parse(input);
console.log(JSON.stringify(r, null, 2));

