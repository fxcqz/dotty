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

string[] wordNums = [
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
];

string[] quantities = [
    "hundred", "thousand", "million", "billion"
];

string getQuantityString() {
    string result;
    int option = uniform!"[]"(0, 2);
    switch (option) {
        case 0:
            result = "%d".format(uniform(0, 99));
            break;
        case 1:
            result = "%s %s".format(wordNums.choice, quantities.choice);
            break;
        case 2:
            result = "%s hundred %s".format(wordNums.choice, quantities[1 .. $].choice);
            break;
        default:
            break;
    }
    return result;
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
