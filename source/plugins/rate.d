module plugins.rate;

import std.format : format;
import std.random : uniform;

import d2sqlite3 : Database;
import message : Message;
import plugins.utils : command;

class Rate {
    @command
    string rate(ref Database db, const Message message) {
        return "%d / 10".format(uniform(0, 10));
    }
}