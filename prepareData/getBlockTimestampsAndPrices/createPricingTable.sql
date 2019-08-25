CREATE TABLE IF NOT EXISTS "Price" (
    "date" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "price" REAL NOT NULL,
    PRIMARY KEY("date","token")
);