CREATE TABLE IF NOT EXISTS "Price" (
    "date" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "price" REAL NOT NULL,
    PRIMARY KEY("date","token")
);

CREATE INDEX price_token ON Price("token");
CREATE INDEX price_date ON price("date");