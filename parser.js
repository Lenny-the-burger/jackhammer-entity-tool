// this script parses the fgd files and builds a useable json file
// why use js? i wouldve used python but I found a package for parsing fgd files
// and it was written in js so might as well use it

// All fgds used for the addon are in the fgd/ folder, if you want to add more just drop them in there
// and run the parser again they will be automatically detected and a new json file will be created

// to run the parser run "node parser.js" make sure all dependencies are installed

// Import FGD package
const fgd = require('fgd');
var fs = require('fs');

// get all the fgd files in the fgd folder
var files = fs.readdirSync('fgds');

// loop through all the fgd files and parse them into jsons
for (var i = 0; i < files.length; i++) {
    var file = files[i];
    const FGD_TEXT = require('fs').readFileSync('fgds/' + file, 'utf-8');
    let fgdAsJSON = fgd.toJSON(FGD_TEXT)
    var json = JSON.stringify(fgdAsJSON, null, 2);
    fs.writeFileSync('json/' + file.replace('.fgd', '.json'), json);
}