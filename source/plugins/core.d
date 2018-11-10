module plugins.core;

import message : Message;
import plugins.utils : command;

class Core {
    @command
    string hello(const Message message) {
        return "Hello from the plugin system!";
    }
}