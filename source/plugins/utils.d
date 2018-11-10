module plugins.utils;

import std.algorithm.searching : startsWith;
import std.traits;

import message;

// UDA for direct commands
struct command {}

string callCommands(T)(string symbol, ref T plugin, const ref Message message) {
    // assume commands will not collide with each other, so just
    // return a single string
    if (!message.text.startsWith(symbol)) {
        return "";
    }
    static foreach (trait; __traits(allMembers, T)) {
        // use typeof work around because we are only interested in public members
        static if (is(typeof(__traits(getMember, T.init, trait)))) {
            static if (hasUDA!(__traits(getMember, T, trait), command)) {
                if (message.text.startsWith(symbol ~ trait)) {
                    size_t commandLen = (symbol ~ trait).length;
                    // a bit slow maybe?
                    string result = mixin("plugin." ~ trait)(message.asCommand(commandLen));
                    if (result.length > 0) {
                        return result;
                    }
                }
            }
        }
    }
    return "";
}

string callNoPrompt(T)(ref T plugin, const ref Message message) {
    static if (__traits(hasMember, T, "noPrompt")) {
        return plugin.noPrompt(message);
    } else {
        return "";
    }
}