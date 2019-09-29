CREATE TABLE IF NOT EXISTS "Price" (
    "date" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "price" REAL NOT NULL,
    PRIMARY KEY("date","token")
);

CREATE INDEX IF NOT EXISTS price_token ON Price("token");
CREATE INDEX IF NOT EXISTS price_date ON price("date");