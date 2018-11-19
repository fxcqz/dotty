import std.json : JSONValue;
import std.stdio : writeln;
import std.typecons : tuple;

import config : Config, readConfig;
import db : makeDB;
import matrix : Matrix;
import message : Message;

import plugins.core : Core;
import plugins.rate : Rate;
import plugins.simpsons : Simpsons;
import plugins.quote : Quote;
import plugins.utils : callCommands, callNoPrompt;


void run(ref Matrix connection) {
    immutable string symbol = connection.getSymbol();
    auto plugins = tuple(new Core(), new Quote(), new Rate(),
                         new Simpsons());

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

            string quote;
            if (messageCount > 1) {
                quote = message.text;
            }

            foreach(ref plugin; plugins) {
                string response = callCommands(symbol, plugin, connection.db, message);
                if (response.length > 0) {
                    connection.sendMessage(response, "m.text", quote);
                }

                // run generic command
                response = callNoPrompt(plugin, connection.db, message);
                if (response.length > 0) {
                    connection.sendMessage(response, "m.text", quote);
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
