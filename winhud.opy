#!mainFile "main.opy"

#https://www.dafont.com/edition-12.font
#https://www.dafont.com/alkhemikal.font

#Strings have a maximum of 511 bytes, so to get the nth letter of a name (starting at 0), we need a length of 510-n.
#Battletags have a max of 12 letters, so to get letter[11], we need a min length of 510-11 = 499.
#globalvar str510Bytes = "mjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdkqsdfmjklqsdfmklsdfmkljfdsqjkmlqsdfqdfsfdsqdfz"

globalvar str499Bytes = p"mjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkflnmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjnlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmnjkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjnkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdnsfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjslnmkfljmfqsdkqsdfmjklqsdfmklsdfmkljfdsqjk\nlqsdf"

globalvar strAdditionalBytes = [
    p"",
    p"*",
    p"**",
    p"***",
    p"****",
    p"*****",
    p"******",
    p"*******",
    p"********",
    p"*********",
    p"**********",
    p"***********",
]

#globalvar str254Bytes = "mjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjlkdqfslqfdmjskjsldmkfljmfqsdksfdkjmlkjlmkmjlksqmjsfdmljkfqdsmjqsdf"

globalvar displayWinHuds

playervar i
playervar j

playervar strByteLimit
playervar strWithName
playervar strWithGuessedName
playervar currentLetter
playervar playerName = ""
playervar playerLetters = []
playervar hudLines = []
playervar hudPadding = ""
playervar lineLength
playervar couldNameBeGuessed = false

#!include "font.opy"

#!define BATTLETAG_MAX_LENGTH 12

#!define generateAlphabetMappings(mappings) __script__("generateAlphabetMappings.js")

#TODO: shit with diacritics, they take more than 1 byte so we gotta compare byte by byte, then merge later
#https://docs.oracle.com/cd/E29584_01/webhelp/mdex_basicDev/src/rbdv_chars_mapping.html

generateAlphabetMappings({
    "0": ["0"],
    "1": ["1"],
    "2": ["2"],
    "3": ["3"],
    "4": ["4"],
    "5": ["5"],
    "6": ["6"],
    "7": ["7"],
    "8": ["8"],
    "9": ["9"],
    "A": ["A", "a"/*, "À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "à", "á", "â", "ã", "ä", "å", "æ", "Ā", "ā", "Ă", "ă", "Ą", "ą"*/],
    "B": ["B", "b"/*, "ß"*/],
    "C": ["C", "c"/*, "Ç", "ç", "Ć", "ć", "Ĉ", "ĉ", "Ċ", "ċ", "Č", "č"*/],
    "D": ["D", "d"/*, "Ď", "ď", "Đ", "Ð", "đ"*/],
    "E": ["E", "e"/*, "È", "É", "Ê", "Ë", "è", "é", "ê", "ë", "Ē", "ē", "Ĕ", "ĕ", "Ė", "ė", "Ę", "ę", "Ě", "ě"*/],
    "F": ["F", "f"],
    "G": ["G", "g"/*, "Ĝ", "ĝ", "Ğ", "ğ", "Ġ", "ġ", "Ģ", "ģ"*/],
    "H": ["H", "h"/*, "Ĥ", "ĥ", "Ħ", "ħ"*/],
    "I": ["I", "i"/*, "Ì", "Í", "Î", "Ï", "ì", "í", "î", "ï", "Ĩ", "ĩ", "Ī", "ī", "Ĭ", "ĭ", "Į", "į", "İ", "ı"*/],
    "J": ["J", "j"/*, "Ĵ", "ĵ"*/],
    "K": ["K", "k"/*, "Ķ", "ķ", "ĸ"*/],
    "L": ["L", "l"/*, "Ĺ", "ĺ", "Ļ", "ļ", "Ľ", "ľ", "Ŀ", "ŀ", "Ł", "ł"*/],
    "M": ["M", "m"],
    "N": ["N", "n"/*, "Ñ", "ñ", "Ń", "ń", "Ņ", "ņ", "Ň", "ň", "ŉ", "Ŋ", "ŋ"*/],
    "O": ["O", "o"/*, "Ò", "Ó", "Ô", "Õ", "Ö", "Ø", "ò", "ó", "ô", "õ", "ö", "ø", "Ō", "ō", "Ŏ", "ŏ", "Ő", "ő"*/],
    "P": ["P", "p"/*, "Þ", "þ"*/],
    "Q": ["Q", "q"],
    "R": ["R", "r"/*, "Ŕ", "ŕ", "Ŗ", "ŗ", "Ř", "ř"*/],
    "S": ["S", "s"/*, "Ś", "ś", "Ŝ", "ŝ", "Ş", "ş", "Š", "š"*/],
    "T": ["T", "t"/*, "Ţ", "ţ", "Ť", "ť", "Ŧ", "ŧ"*/],
    "U": ["U", "u"/*, "Ù", "Ú", "Û", "Ü", "ù", "ú", "û", "ü", "Ũ", "ũ", "Ū", "ū", "Ŭ", "ŭ", "Ů", "ů", "Ű", "ű", "Ų", "ų"*/],
    "V": ["V", "v"],
    "W": ["W", "w"/*, "Ŵ", "ŵ"*/],
    "X": ["X", "x"],
    "Y": ["Y", "y"/*, "Ý", "ý", "ÿ", "Ŷ", "ŷ", "Ÿ"*/],
    "Z": ["Z", "z"/*, "Ź", "ź", "Ż", "ż", "Ž", "ž"*/],
})

#!define HALFWIDTH_SPACE " "
#!define THIN_SPACE " "
#!define FULLWIDTH_SPACE " "
#!define MAX_CHARS_IN_LINE 132

rule "determine player name":
    @Event eachPlayer
    @Condition eventPlayer.hasSpawned()
    wait(2)

    #print("{}".format(eventPlayer.strNameDeterminator))
    #print(eventPlayer.strWithName)
    #print("{}{}".format(eventPlayer.strWithGuessedName, alphabetMappings[eventPlayer.i][eventPlayer.j]))
    #print("player name: {}".format(eventPlayer.playerName))
    #print("i: {}, j: {}".format(eventPlayer.i, eventPlayer.j))

    for eventPlayer.currentLetter in range(BATTLETAG_MAX_LENGTH):
        eventPlayer.strByteLimit = "{}{}".format(str499Bytes, strAdditionalBytes[BATTLETAG_MAX_LENGTH-1-eventPlayer.currentLetter])
        eventPlayer.strWithName = "{}{}".format(eventPlayer.strByteLimit, eventPlayer)
        eventPlayer.strWithGuessedName = "{}{}".format(eventPlayer.strByteLimit, eventPlayer.playerName)

        for eventPlayer.i in range(len(alphabet)):
            for eventPlayer.j in range(len(alphabetMappings[eventPlayer.i])):
                if eventPlayer.strWithName == "{}{}".format(eventPlayer.strWithGuessedName, alphabetMappings[eventPlayer.i][eventPlayer.j]):
                    eventPlayer.playerName = "{}{}".format(eventPlayer.playerName, alphabetMappings[eventPlayer.i][eventPlayer.j])
                    eventPlayer.playerLetters.append(eventPlayer.i)
                    goto letter_found
                wait()
        goto end_search
        letter_found:

    end_search:

    if eventPlayer.playerName != "{}".format(eventPlayer):
        eventPlayer.couldNameBeGuessed = false
        return

    #Calculate the player's line length (not including padding)
    eventPlayer.lineLength = 0
    for eventPlayer.i in range(len(eventPlayer.playerLetters)):
        eventPlayer.lineLength += charLengths[eventPlayer.playerLetters[eventPlayer.i]]
        if eventPlayer.i < len(eventPlayer.playerLetters)-1:
            eventPlayer.lineLength += 2 #account for the space between letters
    
    #Put padding
    for eventPlayer.i in range(floor((MAX_CHARS_IN_LINE-eventPlayer.lineLength)/2)):
        eventPlayer.hudPadding = "{}{}".format(eventPlayer.hudPadding, FULLWIDTH_SPACE)
    if (MAX_CHARS_IN_LINE-eventPlayer.lineLength)%2 == 1:
        eventPlayer.hudPadding = "{}{}".format(eventPlayer.hudPadding, HALFWIDTH_SPACE)

    for eventPlayer.i in range(FONT_HEIGHT):
        eventPlayer.hudLines[eventPlayer.i] = ""

        for eventPlayer.j in range(len(eventPlayer.playerLetters)):
            eventPlayer.hudLines[eventPlayer.i] = "{}{}{}".format(eventPlayer.hudLines[eventPlayer.i], charLines[eventPlayer.playerLetters[eventPlayer.j]][eventPlayer.i], FONT_LETTER_SPACING if eventPlayer.j < len(eventPlayer.playerLetters)-1 else "")
            wait()

    eventPlayer.couldNameBeGuessed = true
        


#!define winHud(str, pos, sortOrder, hudreeval) hudSubheader(getAllPlayers() if displayWinHuds else [], str, pos, sortOrder, Color.GREEN, hudreeval, SpecVisibility.ALWAYS)

#!define winHudLineLeft(index) winHud("{}{}{}".format(winner.hudPadding, THIN_SPACE, winner.hudLines[index]), HudPosition.LEFT, -550+(index), HudReeval.VISIBILITY_AND_STRING)
#!define winHudLineRight(index) winHud("{}{}".format(winner.hudLines[index], winner.hudPadding), HudPosition.RIGHT, -550+(index), HudReeval.VISIBILITY_AND_STRING)

rule "display win huds":

    winHud(b" \n\n\n\n\n\n\n\n\n", HudPosition.RIGHT, -600, HudReeval.VISIBILITY)
    winHud( " \n\n\n\n\n\n\n\n", HudPosition.LEFT, -600, HudReeval.VISIBILITY)
    winHud(" \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.TOP, -9999, HudReeval.VISIBILITY)

    #winHud(" \n\n\n\n\n\n\n\n\n\n", HudPosition.RIGHT, -590, HudReeval.VISIBILITY)
    #winHud(" \n\n\n\n\n\n\n\n\n\n", HudPosition.LEFT, -590, HudReeval.VISIBILITY)

    winHudLineLeft(0)
    winHudLineLeft(1)
    winHudLineLeft(2)
    winHudLineLeft(3)
    winHudLineLeft(4)
    winHudLineLeft(5)
    winHudLineLeft(6)
    winHudLineLeft(7)
    winHudLineLeft(8)
    winHudLineLeft(9)
    winHudLineLeft(10)
    winHudLineLeft(11)
    
    winHudLineRight(0)
    winHudLineRight(1)
    winHudLineRight(2)
    winHudLineRight(3)
    winHudLineRight(4)
    winHudLineRight(5)
    winHudLineRight(6)
    winHudLineRight(7)
    winHudLineRight(8)
    winHudLineRight(9)
    winHudLineRight(10)
    winHudLineRight(11)
    
    winHud(" \n\n", HudPosition.RIGHT, -500, HudReeval.VISIBILITY)
    winHud(" \n\n", HudPosition.LEFT, -500, HudReeval.VISIBILITY)

    winHud("                                                 ▒▒      ▒▒  ▒▒                    ▒▒", HudPosition.LEFT, -485, HudReeval.VISIBILITY)
    winHud("                                                 ▒▒      ▒▒  ▒▒                    ▒▒", HudPosition.LEFT, -484, HudReeval.VISIBILITY)
    winHud("                                                 ▒▒  ▒▒  ▒▒      ▒▒▒▒▒▒    ▒▒▒▒▒▒  ▒▒", HudPosition.LEFT, -483, HudReeval.VISIBILITY)
    winHud("                                                 ▒▒  ▒▒  ▒▒  ▒▒  ▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒  ▒▒", HudPosition.LEFT, -482, HudReeval.VISIBILITY)
    winHud("                                                 ▒▒  ▒▒  ▒▒  ▒▒  ▒▒   ▒▒  ▒▒       ▒▒", HudPosition.LEFT, -481, HudReeval.VISIBILITY)
    winHud("                                                 ▒▒▒ ▒▒ ▒▒▒  ▒▒  ▒▒   ▒▒  ▒▒▒▒▒▒   ▒▒", HudPosition.LEFT, -480, HudReeval.VISIBILITY)
    winHud("                                                  ▒▒ ▒▒ ▒▒   ▒▒  ▒▒   ▒▒   ▒▒▒▒▒▒  ▒▒", HudPosition.LEFT, -479, HudReeval.VISIBILITY)
    winHud("                                                  ▒▒▒▒▒▒▒▒   ▒▒  ▒▒   ▒▒       ▒▒    ", HudPosition.LEFT, -478, HudReeval.VISIBILITY)
    winHud("                                                  ▒▒▒▒▒▒▒▒   ▒▒  ▒▒   ▒▒  ▒▒▒▒▒▒▒  ▒▒", HudPosition.LEFT, -477, HudReeval.VISIBILITY)
    winHud("                                                   ▒▒  ▒▒    ▒▒  ▒▒   ▒▒  ▒▒▒▒▒▒   ▒▒
    \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.LEFT, -476, HudReeval.VISIBILITY)

    winHud("▒▒      ▒▒  ▒▒                    ▒▒                                                ", HudPosition.RIGHT, -485, HudReeval.VISIBILITY)
    winHud("▒▒      ▒▒  ▒▒                    ▒▒                                                ", HudPosition.RIGHT, -484, HudReeval.VISIBILITY)
    winHud("▒▒  ▒▒  ▒▒      ▒▒▒▒▒▒    ▒▒▒▒▒▒  ▒▒                                                ", HudPosition.RIGHT, -483, HudReeval.VISIBILITY)
    winHud("▒▒  ▒▒  ▒▒  ▒▒  ▒▒▒▒▒▒▒  ▒▒▒▒▒▒▒  ▒▒                                                ", HudPosition.RIGHT, -482, HudReeval.VISIBILITY)
    winHud("▒▒  ▒▒  ▒▒  ▒▒  ▒▒   ▒▒  ▒▒       ▒▒                                                ", HudPosition.RIGHT, -481, HudReeval.VISIBILITY)
    winHud("▒▒▒ ▒▒ ▒▒▒  ▒▒  ▒▒   ▒▒  ▒▒▒▒▒▒   ▒▒                                                ", HudPosition.RIGHT, -480, HudReeval.VISIBILITY)
    winHud(" ▒▒ ▒▒ ▒▒   ▒▒  ▒▒   ▒▒   ▒▒▒▒▒▒  ▒▒                                                ", HudPosition.RIGHT, -479, HudReeval.VISIBILITY)
    winHud(" ▒▒▒▒▒▒▒▒   ▒▒  ▒▒   ▒▒       ▒▒                                                    ", HudPosition.RIGHT, -478, HudReeval.VISIBILITY)
    winHud(" ▒▒▒▒▒▒▒▒   ▒▒  ▒▒   ▒▒  ▒▒▒▒▒▒▒  ▒▒                                                ", HudPosition.RIGHT, -477, HudReeval.VISIBILITY)
    winHud("  ▒▒  ▒▒    ▒▒  ▒▒   ▒▒  ▒▒▒▒▒▒   ▒▒                                                
    \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", HudPosition.RIGHT, -476, HudReeval.VISIBILITY)
    
