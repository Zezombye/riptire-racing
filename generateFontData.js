
const FONT_HEIGHT = 12;
const FULLWIDTH_SPACE = " "

var charLengths = [];
var charLines = [];

for (var char in font) {
    var currentCharLines = [];
    var currentCharLength = 0;
    for (var line of font[char]) {
        if (line.length > currentCharLength) {
            currentCharLength = line.length;
        }
        currentCharLines.push(line);
    }
    for (var i = currentCharLines.length; i < FONT_HEIGHT; i++) {
        currentCharLines.push("");
    }
    for (var i = 0; i < currentCharLines.length; i++) {
        currentCharLines[i] = currentCharLines[i].padEnd(currentCharLength, " ");
    }

    currentCharLines = currentCharLines.map(x => x.replace(/ /g, FULLWIDTH_SPACE).replace(/#/g, "▒"));
    charLines.push(currentCharLines);
    charLengths.push(currentCharLength);
}

`
globalvar charLengths = ${JSON.stringify(charLengths)}
globalvar charLines = ${JSON.stringify(charLines)}
`
