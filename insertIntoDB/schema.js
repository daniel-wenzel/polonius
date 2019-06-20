const db = require('./util/db')

const statements = 
    `CREATE TABLE "Address" (
        "address"	TEXT,
        "name" TEXT,
        "url" TEXT,
        "isExchange" INTEGER DEFAULT 0,
        "isDepositAddress"	INTEGER DEFAULT 0,
        "isCAPPHotWallet"	INTEGER DEFAULT 0,
        PRIMARY KEY("address")
    );
    CREATE TABLE "Token" (
        "id"	TEXT,
        "decimals"	INTEGER NOT NULL,
        "name"	TEXT NOT NULL,
        "address"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id")
    );
    CREATE TABLE "Transfer" (
        "from"	TEXT,
        "to"	TEXT,
        "token"	TEXT,
        "blocknumber"	INTEGER,
        "amount"	INTEGER,
        "timestamp"	TEXT,
        "amountInTokens"	REAL,
        "amountInUSDCurrent"	REAL,
        "amountInUSD"	REAL,
        "emptiedAccount"	INTEGER DEFAULT 0,
        "wasEmptiedWithinXBlocks"	INTEGER DEFAULT 0,
        "intoDepositAddress"	INTEGER DEFAULT 0,
        "intraCAPP"	INTEGER DEFAULT 0,
        "fromCAPP"	INTEGER DEFAULT 0,
        "revealedPublicKey"	INTEGER DEFAULT 0,
        FOREIGN KEY("from") REFERENCES "Address"("address"),
        PRIMARY KEY("from","to","token","blocknumber"),
        FOREIGN KEY("to") REFERENCES "Address"("address"),
        FOREIGN KEY("token") REFERENCES "Token"("id")
    );
    
    CREATE INDEX transfer_blocknumber_index ON Transfer (blocknumber);
    CREATE INDEX transfer_from_index ON Transfer ("from");
    CREATE INDEX transfer_to_index ON Transfer ("to");
    CREATE INDEX transfer_token_index ON Transfer ("token");
    CREATE INDEX address_address_index ON Address ("address");
    CREATE INDEX address_isCapp_index ON Address ("isCAPPHotWallet");
    CREATE INDEX address_isDeposit_index ON Address ("isDepositAddress");
    CREATE INDEX token_id_index ON Token ("id");
    CREATE INDEX emptied_index ON Transfer (emptiedAccount)
    `
    

db.transaction(() => {
    statements.split(';').forEach(s => {
        console.log(s)
        db.prepare(s).run()
    })
})();
console.log("created schema!")