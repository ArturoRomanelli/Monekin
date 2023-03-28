CREATE TABLE accounts (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    iniValue REAL NOT NULL,
    date TEXT NOT NULL,
    text TEXT,
    type TEXT NOT NULL,
    icon TEXT NOT NULL,
    currency TEXT NOT NULL,
    iban TEXT,
    swift TEXT
);