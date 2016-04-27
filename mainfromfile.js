#!/usr/local/bin/node --harmony_destructuring
var util = require('util');
var fs = require('fs');
var PEG = require("./arithmetics.js");
var fileName = process.argv[2] || 'input1';
fs.readFile(fileName, 'utf8', function (err,input) {
  if (err) {
    return console.log(err);
  }
  console.log(`Processing <\n${input}\n>`);
  var r = PEG.parse(input);
  console.log(util.inspect(r));
});

