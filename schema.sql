CREATE TABLE IF NOT EXISTS quotes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT,
    quote TEXT
);

CREATE TABLE IF NOT EXISTS messages (
  sender TEXT,
  room TEXT,
  message TEXT
);
