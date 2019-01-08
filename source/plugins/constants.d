module plugins.constants;

import std.format : format;
import std.random : choice, uniform;

string[] thinking = [
    "", "um", "uh", "hm", "hmm", "er", "eh", "perhaps", "probably"
];

string[] concatenators = [",", "...", "..", ""];

string getThinkingString() {
    string first = thinking.choice;
    if (first.length) {
        return "%s%s ".format(first, concatenators.choice);
    }
    return "";
}

string[] unsure = [
    "I'm not sure", "I don't know", "dunno", "who knows"
];

string getUnsureString() {
    return unsure.choice;
}

string[] times = [
    "minute", "hour", "day", "week", "fortnight", "month", "year"
];

string[] quantitativeFrequencies = [
    "once", "twice", "three times", "four times", "five times",
    "a couple of times", "a few times"
];

string[] indeterminateFrequencies = [
    "lots", "not a lot", "rarely", "occasionally", "all the time",
    "constantly"
];

string getFrequencyString() {
    string response;
    if (uniform!"[]"(0, 1) == 1) {
        response = "%s per %s".format(quantitativeFrequencies.choice, times.choice);
    } else {
        response = indeterminateFrequencies.choice;
    }
    return response;
}
