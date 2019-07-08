const db = require('./util/db')

const statements = 
    `CREATE TABLE "Address" (
        "address"	TEXT NOT NULL UNIQUE,
        "name"	TEXT,
        "url"	TEXT,
        "isExchange"	INTEGER DEFAULT 0,
        "isDepositAddress"	INTEGER DEFAULT 0,
        "isCappReceiver"	INTEGER DEFAULT 0,
        "isCappSender"	INTEGER DEFAULT 0,
        "isCappStorage"	INTEGER DEFAULT 0,
        "isCappOther"	INTEGER DEFAULT 0,
        PRIMARY KEY("address")
    );
    CREATE TABLE "Token" (
        "id"	TEXT  NOT NULL UNIQUE,
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
        "isIntoDepositAddress"	INTEGER DEFAULT 0,
        "isIntraCAPP"	INTEGER DEFAULT 0,
        "isFromCAPP"	INTEGER DEFAULT 0,
        "revealedPublicKey"	INTEGER DEFAULT 0,
        "percentile"	NUMERIC,
        "isEarlyTransfer"	INTEGER,
        "isVeryEarlyTransfer"	INTEGER,
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

    CREATE INDEX address_isCappReceiver_index ON Address ("isCappReceiver");
    CREATE INDEX address_isCappSender_index ON Address ("isCappSender");
    CREATE INDEX address_isCappStorage_index ON Address ("isCappStorage");
    CREATE INDEX address_isCappOther_index ON Address ("isCappOther");

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