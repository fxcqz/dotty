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
  string reddit(ref Database db, const Message message, string t = "") {
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

    if (t != "") {
      url = "%s?sort=top&t=%s".format(url, t);
    }

    auto http = HTTP(url);
    string extra = generate(
        () => "abcdefghijklmnopqrstuvwxyz".split("").choice).take(8).join;
    http.setUserAgent("a %s man".format(extra));

    try {
      auto result = parseJSON(get(url, http));
      JSONValue[] data = result["data"]["children"].array;

      if (data.length == 0) {
        return reddit(db, message, "all");
      }

      while (true) {
        auto post = data[uniform(0, data.length)]["data"];
        if (post["stickied"].boolean) {
          continue;
        }

        string content;
        string content_url = post["url"].str;
        if (post["selftext"].str == "") {
          content = content_url;
        } else {
          content = post["selftext"].str;
        }

        if (post["over_18"].boolean) {
          content ~= " (nsfw)";
        } else if (content_url.canFind("jpg") || content_url.canFind("png")) {
          return "!!image %s".format(content_url);
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
