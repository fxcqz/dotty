module plugins.bash;

import std.conv : to;
import std.string : toStringz, replace;

import d2sqlite3 : Database;
import message : Message;
import plugins.utils : command;

extern(C) {
  char* nimBash(immutable(char)* message);
}

class Bash {
    @command
    string bash(ref Database db, const Message message) {
        return to!string(nimBash(message.text.toStringz))
          .replace("\n", "\\n")
          .replace("\"", "\\\"");
    }
}
