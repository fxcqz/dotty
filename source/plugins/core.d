module plugins.core;

import std.algorithm.searching : canFind, findSplitAfter;
import std.conv : to;
import std.format : format;
import std.random : choice, uniform;
import std.string : split, strip;
import std.uni : isWhite;

import d2sqlite3 : Database;
import message : Message;

import matrix : Matrix;
import plugins.constants : getFrequencyString, getQuantityString, getUnsureString;
import plugins.utils : command;

class Core {
private:
    immutable string[] laughing = ["lol", "lmao", "haha", "heh", "😂"];
    immutable string[] headsTails = ["heads", "tails"];

public:
    @command
    string hello(ref Database db, const Message message) {
        return "Hello from the plugin system!";
    }

    @command
    string ht(ref Database db, const Message message) {
        return headsTails[uniform(0, headsTails.length)];
    }

    string howResponses(string[] sentence)
    in (sentence.length > 1)
    do {
        string response = "";
        switch (sentence[0]) {
        case "many": case "much":
            response = getQuantityString();
            break;
        case "are": case "do":
            response = getUnsureString();
            break;
        case "often":
            response = getFrequencyString();
            break;
        default:
            break;
        }
        return response;
    }

    string how(string text) {
        // processing for sentences containing "how"
        if (!text.canFind("how")) {
            return "";
        }

        if (auto words = findSplitAfter(text, "how")) {
            if (words[1]) {
                string[] sentence = words[1].strip.split!isWhite;
                if (sentence.length > 1) {
                    return howResponses(sentence);
                }
            }
        }
        return "";
    }

    string noPrompt(ref Matrix connection, const ref Message message) {
        string howResponse = how(message.text);
        if (howResponse.length) {
            return howResponse;
        }

        // calculate the whether we're going to laugh before doing any looping
        if (uniform(0, 3) == 2) {
            foreach (laughStr; laughing) {
                if (message.text.canFind(laughStr)) {
                    // 25% probability
                    return laughing[uniform(0, laughing.length)];
                }
            }
        }
        return "";
    }
}
