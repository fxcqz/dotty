module plugins.futurama;

import std.format : format;
import std.json : JSONException, JSONValue, parseJSON;
import std.net.curl : CurlException, get;
import std.random : uniform;
import std.uri : encode;

import d2sqlite3 : Database;
import message : Message;
import plugins.utils : command;

class Futurama {
    @command
    string futurama(ref Database db, const Message message) {
        string term = message.text;
        string url;
        bool isRandom = false;

        if (term.length == 0) {
            url = "https://morbotron.com/api/random";
            isRandom = true;
        } else {
            url = "https://morbotron.com/api/search?q=%s".format(term);
        }

        try {
            auto result = parseJSON(get(url.encode));
            JSONValue clip;
            if (isRandom) {
                // extract a single result from the random api
                clip = result["Frame"];
            } else {
                JSONValue[] data = result.array;
                if (data.length == 0) {
                    // no results found
                    return "";
                }
                clip = data[uniform(0, data.length)];
            }
            return "!!image https://morbotron.com/img/%s/%d.jpg".format(
                clip["Episode"].str, clip["Timestamp"].integer
            );
        }
        catch (JSONException e) {}
        catch (CurlException e) {}

        return "";
    }
}
