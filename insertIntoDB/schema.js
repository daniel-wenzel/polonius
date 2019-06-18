const db = require('./util/db')

const statements = [
    `CREATE TABLE "Address" (
        "address"	TEXT,
        "indegree"	INTEGER,
        "outdegree"	INTEGER,
        "isDepositAddress"	INTEGER,
        PRIMARY KEY("address")
    );`,
    `CREATE TABLE "Token" (
        "id"	TEXT,
        "decimals"	INTEGER NOT NULL,
        "name"	TEXT NOT NULL,
        "address"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id")
    )`,
    `CREATE TABLE "Transfer" (
        "from"	TEXT,
        "to"	TEXT,
        "token"	TEXT,
        "blocknumber"	INTEGER,
        "amount"	INTEGER,
        "timestamp"	TEXT,
        "amountInTokens"	REAL,
        "amountInUSDCurrent"	REAL,
        "amountInUSD"	REAL,
        "emptiedAccount"	INTEGER,
        FOREIGN KEY("from") REFERENCES "Address"("address"),
        PRIMARY KEY("from","to","token","blocknumber"),
        FOREIGN KEY("to") REFERENCES "Address"("address"),
        FOREIGN KEY("token") REFERENCES "Token"("id")
    );`
]

db.transaction(() => {
    statements.forEach(s => {
        db.prepare(s).run()
    })
})();
console.log("created schema!")