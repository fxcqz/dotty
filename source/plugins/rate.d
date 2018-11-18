module plugins.rate;

import std.format : format;
import std.random : uniform;

import d2sqlite3 : Database;
import message : Message;
import plugins.utils : command;

class Rate {
    @command
    string rate(ref Database db, const Message message, int limit = 10) {
        return "%d / %d".format(uniform(0, limit), limit);
    }

    @command
    string r8(ref Database db, const Message message) {
        return rate(db, message, 8);
    }
}