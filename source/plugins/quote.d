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

        if (quote.length == 0) {
            // must have a quote
            return "";
        }

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
        string result = "Could not find a quote for %s".format(category);
        auto rows = db.execute(
            "SELECT quote FROM quotes WHERE category = '%s'
            ORDER BY random() LIMIT 1".format(category)
        );
        foreach (ref Row row; rows) {
            // again, not that efficient but not really sure what exception
            // oneValue raises
            result = row["quote"].as!string;
        }
        return result;
    }
}