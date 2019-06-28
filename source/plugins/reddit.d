module plugins.reddit;

import std.format : format;
import std.json : JSONException, JSONValue, parseJSON;
import std.net.curl : CurlException, get;
import std.random : uniform;

import d2sqlite3 : Database;
import message : Message;
import plugins.utils : command;

class Reddit {
  @command
  string reddit(ref Database db, const Message message) {
    import std.algorithm : canFind;
    import std.array : split;
    import std.stdio : writeln;
    import std.uni : isWhite;

    string subreddit = message.text;
    if (subreddit.canFind(" ")) {
      subreddit = subreddit.split!isWhite[0];
    }

    string url = "https://reddit.com/r/%s.json".format(subreddit);

    try {
      auto result = parseJSON(get(url));
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
    catch (JSONException e) {}
    catch (CurlException e) {}

    return "probably rate limited";
  }
}
