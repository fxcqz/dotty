import std.json : JSONValue;

import config : Config, readConfig;
import matrix : Matrix;
import message : Message;

void run(ref Matrix connection) {
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
        foreach (message; messages) {
            // TODO: pass messageCount to sendMessage, if it's more than
            // one, quote the original message in the reply
            if (message.text == "hello bot") {
                connection.sendMessage("YO FROM D");
            }
        }
    }
}

void main() {
    Config config = new Config(readConfig("config.json"));
    Matrix connection = new Matrix(config);
    run(connection);
}
