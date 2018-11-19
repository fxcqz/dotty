module plugins.simpsons;

import std.format : format;
import std.json : JSONException, JSONValue, parseJSON;
import std.net.curl : CurlException, get;
import std.random : uniform;

import d2sqlite3 : Database;
import message : Message;
import plugins.utils : command;

class Simpsons {
    @command
    string simpsons(ref Database db, const Message message) {
        string term = message.text;
        try {
            JSONValue[] data = parseJSON(
                get("https://frinkiac.com/api/search?q=%s".format(term))).array;
            JSONValue clip = data[uniform(0, data.length)];
            return "https://frinkiac.com/img/%s/%d.jpg".format(
                clip["Episode"].str, clip["Timestamp"].integer
            );
        } catch (JSONException e) {
            return "";
        } catch (CurlException e) {
            return "";
        }
    }
}