module config;

import core.stdc.stdlib : exit;
import std.experimental.logger : fatal;
import std.file : readText;
import std.json : JSONException, JSONValue, parseJSON;

class Config {
public:
    string username;
    string password;
    string address;
    string room;

    this(JSONValue config) {
        try {
            this.username = config["username"].str;
            this.password = config["password"].str;
            this.address = config["address"].str;
            this.room = config["room"].str;
        } catch (JSONException e) {
            fatal("Could not read the config file!");
            fatal("Message:\n%s", e.msg);
            exit(-1);
        }
    }
}

JSONValue readConfig(const string filename) {
    return parseJSON(readText(filename));
}