module plugins.reddit;

import std.format : format;
import std.json : JSONException, JSONValue, parseJSON;
import std.net.curl : CurlException, get, HTTP;
import std.random : choice, uniform;
import std.experimental.logger : warning;

import d2sqlite3 : Database;
import message : Message;
import plugins.utils : command;

class Reddit {
  @command
  string reddit(ref Database db, const Message message) {
    import std.algorithm : canFind;
    import std.array : join, split;
    import std.range : generate, take;
    import std.stdio : writeln;
    import std.uni : isWhite;

    string subreddit = message.text;
    if (subreddit.canFind(" ")) {
      subreddit = subreddit.split!isWhite[0];
    }

    string url = "https://reddit.com/r/%s.json".format(subreddit);

    auto http = HTTP(url);
    string extra = generate(
        () => "abcdefghijklmnopqrstuvwxyz".split("").choice).take(8).join;
    http.setUserAgent("a %s man".format(extra));

    try {
      auto result = parseJSON(get(url, http));
      JSONValue[] data = result["data"]["children"].array;
      while (true) {
        auto post = data[uniform(0, data.length)]["data"];
        if (post["stickied"].boolean) {
          continue;
        }

        string content;
        if (post["selftext"].str == "") {
          content = post["url"].str;
        } else {
          content = post["selftext"].str;
        }

        if (post["whitelist_status"].str.canFind("nsfw")) {
          content ~= " (nsfw)";
        }

        return content;
      }
    }
    catch (JSONException e) {
      warning("Reddit json decode failed: ", e);
    }
    catch (CurlException e) {
      warning("Reddit http request failed: ", e);
    }

    return "probably rate limited";
  }
}
