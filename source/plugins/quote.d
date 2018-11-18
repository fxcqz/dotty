module plugins.quote;

import std.array : join, split;
import std.format : format;

import d2sqlite3 : Database, Row, Statement;
import message : Message;
import plugins.utils : command;

// Useful doc at:
// http://biozic.github.io/d2sqlite3/d2sqlite3.html

class Quote {
    private immutable string ADD_FAILURE = "Failed to add quote";
    private immutable string ADD_SUCCESS = "Added quote to the category: %s";

    private string formatQuote(string category, string quote) {
        return "(%s): %s".format(category, quote);
    }

    @command
    string qadd(ref Database db, const Message message) {
        string[] tokens = message.text.split(" ");

        if (tokens.length < 2) {
            return ADD_FAILURE;
        }

        string category = tokens[0];
        string quote = tokens[1 .. $].join(" ");

        if (quote.length == 0) {
            // must have a quote
            return ADD_FAILURE;
        }

        Statement query = db.prepare(
            "INSERT INTO quotes (category, quote) VALUES (:category, :quote)"
        );
        query.bind(":category", category);
        query.bind(":quote", quote);
        query.execute();
        query.reset();
        return ADD_SUCCESS.format(category);
    }

    @command
    string qget(ref Database db, const Message message) {
        string category = message.text;
        string result = "Could not find a quote for: %s".format(category);
        string query = "SELECT category, quote FROM quotes";

        if (message.text.length != 0) {
            query ~= " WHERE category = '%s'".format(category);
        }
        query ~= " ORDER BY random() LIMIT 1";

        auto rows = db.execute(query);
        foreach (ref Row row; rows) {
            // again, not that efficient but not really sure what exception
            // oneValue raises
            result = formatQuote(row["category"].as!string, row["quote"].as!string);
        }

        return result;
    }

    @command
    string qfind(ref Database db, const Message message) {
        string term = message.text;
        string result = "No quote found for search term: %s".format(term);

        if (message.text.length != 0) {
            auto rows = db.execute(
                "SELECT category, quote FROM quotes WHERE quote LIKE '%%%s%%'
                ORDER BY random() LIMIT 1".format(term)
            );
            foreach (ref Row row; rows) {
                result = formatQuote(row["category"].as!string, row["quote"].as!string);
            }
        }

        return result;
    }
}