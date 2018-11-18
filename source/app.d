import std.json : JSONValue;
import std.stdio : writeln;
import std.typecons : tuple;

import config : Config, readConfig;
import db : makeDB;
import matrix : Matrix;
import message : Message;

import plugins.core : Core;
import plugins.rate : Rate;
import plugins.quote : Quote;
import plugins.utils : callCommands, callNoPrompt;


void run(ref Matrix connection) {
    immutable string symbol = connection.getSymbol();
    auto plugins = tuple(new Core(), new Quote(), new Rate());

    connection.login();
    connection.join();
    connection.setMessageFilter();
    // initial sync
    connection.sync();

    while (true) {
        JSONValue data = connection.sync();
        Message[] messages = connection.extractMessages(data);
        immutable size_t messageCount = messages.length;
        if (messageCount == 0) {
            continue;
        }

        connection.markRead(messages[$ - 1]);
        foreach (ref message; messages) {
            if (message.sender == connection.getUserID()) {
                // ignore our own messages
                continue;
            }

            // TODO: pass messageCount to sendMessage, if it's more than
            // one, quote the original message in the reply

            foreach(ref plugin; plugins) {
                string response = callCommands(symbol, plugin, connection.db, message);
                if (response.length > 0) {
                    connection.sendMessage(response);
                }

                // run generic command
                response = callNoPrompt(plugin, connection.db, message);
                if (response.length > 0) {
                    connection.sendMessage(response);
                }
            }
        }
    }
}

void main() {
    auto db = makeDB();
    Config config = new Config(readConfig("config.json"));
    Matrix connection = new Matrix(config, db);
    run(connection);
}
