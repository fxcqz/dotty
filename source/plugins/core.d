module plugins.core;

import std.algorithm.searching : canFind;
import std.random : choice, uniform;

import d2sqlite3 : Database;
import message : Message;

import matrix : Matrix;
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

    string noPrompt(ref Matrix connection, const ref Message message) {
        foreach(laughStr; laughing) {
            if (message.text.canFind(laughStr) && uniform(0, 3) == 2) {
                // 25% probability
                return laughing[uniform(0, laughing.length)];
            }
        }
        return "";
    }
}
