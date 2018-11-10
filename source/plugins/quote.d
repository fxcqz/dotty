module plugins.quote;

import std.array : join, split;

import d2sqlite3 : Database, Statement;
import message : Message;
import plugins.utils : command;

class Quote {
    @command
    string qadd(ref Database db, const Message message) {
        string[] tokens = message.text.split(" ");
        string category = tokens[0];
        string quote = tokens[1 .. $].join(" ");

        Statement query = db.prepare(
            "INSERT INTO quote (category, quote) VALUES (:category, :quote)"
        );
        query.bind(":category", category);
        query.bind(":quote", quote);
        query.execute();
        query.reset();
        return "";
    }
}