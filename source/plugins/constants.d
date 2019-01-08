module plugins.constants;

import std.format : format;
import std.random : choice;

string[] thinking = [
    "", "um", "uh", "hm", "hmm", "er", "eh", "perhaps", "probably"
];

string[] unsure = [
    "I'm not sure", "I don't know", "dunno", "who knows"
];

string[] concatenators = [",", "...", "..", ""];

string getThinkingString() {
    string first = thinking.choice;
    if (first.length) {
        return "%s%s ".format(first, concatenators.choice);
    }
    return "";
}

string getUnsureString() {
    return unsure.choice;
}
