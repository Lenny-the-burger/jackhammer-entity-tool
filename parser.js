// this script parses the fgd files and builds a useable json file
// why use js? i wouldve used python but I found a package for parsing fgd files
// and it was written in js so might as well use it

// All fgds used for the addon are in the fgd/ folder, if you want to add more just drop them in there
//   and run the parser again they will be automatically detected and a new json file will be created.
//    Also dumps all the file names into a text file because i cant figure out how to get the file names otherwise

// to run the parser run "node parser.js" make sure all dependencies are installed

// Import FGD package
const fgd = require('fgd');
var fs = require('fs');

// wipe mouned fgds file just in case
fs.closeSync(fs.openSync("lua/autorun/client/mounted_fgds.txt", 'w'));

// get all the fgd files in the fgd folder
var files = fs.readdirSync('fgds');

// loop through all the fgd files and parse them into jsons
for (var i = 0; i < files.length; i++) {
    var file = files[i];
    const FGD_TEXT = require('fs').readFileSync('fgds/' + file, 'utf-8');
    let fgdAsJSON = fgd.toJSON(FGD_TEXT)
    var json = JSON.stringify(fgdAsJSON, null, 2);
    var file_name = file.replace('.fgd', '.json');
    fs.writeFileSync('json/' + file_name, json);
    fs.appendFile('lua/autorun/client/mounted_fgds.txt', file_name + '\n', function(err, result) {
        if(err) console.log('error', err);
    });
}