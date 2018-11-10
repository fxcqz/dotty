module plugins.quote;

import std.array : join, split;
import std.format : format;

import d2sqlite3 : Database, Row, Statement;
import message : Message;
import plugins.utils : command;

// Useful doc at:
// http://biozic.github.io/d2sqlite3/d2sqlite3.html

class Quote {
    @command
    string qadd(ref Database db, const Message message) {
        string[] tokens = message.text.split(" ");
        string category = tokens[0];
        string quote = tokens[1 .. $].join(" ");

        Statement query = db.prepare(
            "INSERT INTO quotes (category, quote) VALUES (:category, :quote)"
        );
        query.bind(":category", category);
        query.bind(":quote", quote);
        query.execute();
        query.reset();
        return "";
    }

    @command
    string qget(ref Database db, const Message message) {
        string category = message.text.split(" ")[0];
        auto results = db.execute("SELECT quote FROM quotes WHERE category = '%s'".format(
            category
        ));

        // TODO make it random
        foreach(Row row; results) {
            return row["quote"].as!string;
        }
        return "";
    }
}