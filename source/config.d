module config;

import core.stdc.stdlib : exit;
import std.experimental.logger : fatal;
import std.file : readText;
import std.json : JSONException, JSONValue, parseJSON;
import std.string : stripLeft;

class Config {
public:
    string username;
    string password;
    string address;
    string room;
    string commandSymbol;

    this(JSONValue config) {
        try {
            this.username = config["username"].str;
            this.password = config["password"].str;
            this.address = config["address"].str;
            this.room = config["room"].str;
            this.commandSymbol = config["commandSymbol"].str;
        } catch (JSONException e) {
            fatal("Could not read the config file!");
            fatal("Message:\n%s", e.msg);
            exit(-1);
        }
    }

    string serverName() {
        return this.address.stripLeft("https://");
    }
}

JSONValue readConfig(const string filename) {
    return parseJSON(readText(filename));
}