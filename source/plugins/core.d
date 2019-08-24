module plugins.core;

import std.array : join, replace;
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
    immutable string[] modals = [
        "can", "could", "may", "might", "shall", "should", "will", "would",
        "must", "ought", "are", "am", "is", "does", "did", "didn't", "do",
        "don't", "dont", "was", "didnt"
    ];
    immutable string[] pronouns = [
        "i", "you", "me", "they", "he", "she", "it"
    ];

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
        import std.algorithm.searching : endsWith;
        if (!text.canFind("how") || !text.endsWith("?")) {
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

    string or(string text) {
        import std.algorithm.searching : endsWith;
        if (!text.canFind(" or ") || !text.endsWith("?")) {
            return "";
        }
        auto words = text.split!isWhite;
        if (this.modals.canFind(words[0])) {
            words = words[1 .. $];
        }
        if (this.pronouns.canFind(words[0])) {
            words = words[1 .. $];
        }
        if (auto choices = split(words.join(" "), " or ")) {
            return choices.choice.strip.strip("?").replace(" myself", " yourself").replace(" me", " you").replace(" my", " your").replace(" our", " your");
        }
        return "";
    }

    string pageTitle(string apiKey, string text) {
      import std.algorithm.searching : startsWith;
      import std.format : format;
      import std.json : JSONException, parseJSON;
      import std.regex : matchFirst, regex;
      import std.net.curl : CurlException, get;

      // https://stackoverflow.com/a/37704433/11793168
      auto urlR = regex(r"((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|v\/)?)([\w\-]+)(\S+)?");
      auto match = text.matchFirst(urlR);

      if (!match.empty) {
        try {
          string url =
            "https://www.googleapis.com/youtube/v3/videos?key=%s&part=snippet&id=%s".format(
              apiKey, match[5]
            );
          auto response = parseJSON(get(url));
          return "!!html <blockquote>\n<p>%s</p>\n</blockquote>\n<p>%s</p>\n".format(
            text,
            response["items"].array[0]["snippet"]["title"].str
          );
        } catch (JSONException e) {
        } catch (CurlException e) {
        }
      }

      return "";
    }

    string noPrompt(ref Matrix connection, const ref Message message) {
        string howResponse = how(message.text);
        if (howResponse.length) {
            return howResponse;
        }

        string orResponse = or(message.text);
        if (orResponse.length) {
            return orResponse;
        }

        string titleResponse = pageTitle(connection.config.apiKeyGoogle, message.original);
        if (titleResponse.length) {
            return titleResponse;
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
