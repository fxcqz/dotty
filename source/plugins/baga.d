module plugins.baga;

import std.conv : to;
import std.string : toStringz, replace;

import d2sqlite3 : Database;
import message : Message;
import plugins.utils : command;

extern(C) {
  char* nimBaga(immutable(char)* message);
}

class Baga {
  @command
  string baga(ref Database db, const Message message) {
    return to!string(nimBaga(message.text.toStringz));
  }

  @command
  string bhaga(ref Database db, const Message message) {
    return to!string(nimBaga(message.text.toStringz));
  }
}
