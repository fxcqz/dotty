module plugins.core;

import std.algorithm.searching : canFind;
import std.random : choice, uniform;

import message : Message;
import plugins.utils : command;

class Core {
private:
    immutable string[] laughing = ["lol", "lmao", "haha", "heh", "😂"];

public:
    @command
    string hello(const Message message) {
        return "Hello from the plugin system!";
    }

    string noPrompt(const ref Message message) {
        foreach(laughStr; laughing) {
            if (message.text.canFind(laughStr) && uniform(0, 3) == 2) {
                // 25% probability
                return laughing[uniform(0, laughing.length)];
            }
        }
        return "";
    }
}