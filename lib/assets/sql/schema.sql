CREATE TABLE IF NOT EXISTS accounts (
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

CREATE TABLE IF NOT EXISTS mainCategories (
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    icon TEXT NOT NULL,
    color TEXT NOT NULL,
    type TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS childCategories(
    id TEXT PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    icon TEXT NOT NULL,
    parentCategory TEXT NOT NULL REFERENCES mainCategories(id)
);
