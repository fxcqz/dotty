module db;

import std.file : readText;

import d2sqlite3;

auto makeDB() {
    auto db = Database("dotty.db");
    db.run(readText("schema.sql"));
    return db;
}