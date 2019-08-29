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
        "isOriginAddress"	INTEGER DEFAULT 0,
        "cluster"	TEXT,
        PRIMARY KEY("address")
    );
    CREATE TABLE "Token" (
        "id"	TEXT  NOT NULL UNIQUE,
        "decimals"	INTEGER NOT NULL,
        "name"	TEXT NOT NULL,
        "address"	TEXT NOT NULL UNIQUE,
        "reportedSupply" NUMERIC,
        "actualSupply" NUMERIC,
        "excludeFromAdjustedVolumes" INT,
        "highMarketCap" INT DEFAULT 0,
        PRIMARY KEY("id")
    );CREATE TABLE "Transfer" (
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
        "canBeChangeTransfer"	INTEGER DEFAULT 0,
        "isChangeTransfer"	INTEGER DEFAULT 0,
        "isIntoDepositAddress"	INTEGER DEFAULT 0,
        "isIntraCapp"	INTEGER DEFAULT 0,
        "isFromCapp"	INTEGER DEFAULT 0,
        "percentile"	NUMERIC,
        "isEarlyTransfer"	INTEGER,
        "isVeryEarlyTransfer"	INTEGER,
        "isFromDiluter"	INTEGER DEFAULT 0,
        "isToDiluter"	INTEGER DEFAULT 0,
        "isFromMixer"	INTEGER DEFAULT 0,
        "isToMixer"	INTEGER DEFAULT 0,
        "isToConcentrator"	INTEGER DEFAULT 0,
        "isFromConcentrator"	INTEGER DEFAULT 0,
        "isICOPurchase"	INTEGER DEFAULT 0,
        "wasEmptiedWithinXBlocks"	INTEGER DEFAULT 0,
        FOREIGN KEY("token") REFERENCES "Token"("id"),
        FOREIGN KEY("to") REFERENCES "Address"("address"),
        PRIMARY KEY("from","to","token","blocknumber"),
        FOREIGN KEY("from") REFERENCES "Address"("address")
    );

    CREATE TABLE "ICOAddress" (
        "address"	TEXT NOT NULL,
        "token"	TEXT NOT NULL,
        FOREIGN KEY("token") REFERENCES "Token"("id"),
        PRIMARY KEY("address","token"),
        FOREIGN KEY("address") REFERENCES "Address"("address")
    );
    
    CREATE INDEX transfer_blocknumber_index ON Transfer (blocknumber);
    CREATE INDEX transfer_from_index ON Transfer ("from");
    CREATE INDEX transfer_to_index ON Transfer ("to");
    CREATE INDEX transfer_token_index ON Transfer ("token");
    CREATE INDEX transfer_canBeChangeTransfer_index ON Transfer (canBeChangeTransfer);
    CREATE INDEX transfer_emptiedAccount_index ON Transfer (emptiedAccount);
    CREATE INDEX address_address_index ON Address ("address");

    CREATE INDEX address_isCappReceiver_index ON Address ("isCappReceiver");
    CREATE INDEX address_isCappSender_index ON Address ("isCappSender");
    CREATE INDEX address_isCappStorage_index ON Address ("isCappStorage");
    CREATE INDEX address_isCappOther_index ON Address ("isCappOther");
    CREATE INDEX address_cluster_index ON Address ("cluster");

    CREATE INDEX address_isDeposit_index ON Address ("isDepositAddress");
    CREATE INDEX token_id_index ON Token ("id");
    CREATE INDEX Token_exclude ON Token('excludeFromAdjustedVolumes');
    CREATE INDEX emptied_index ON Transfer (emptiedAccount);

    CREATE TABLE "Entity" (
        "name"	TEXT NOT NULL,
        "isCapp"	INTEGER,
        PRIMARY KEY("name")
    );

    CREATE TABLE "ETransfer" (
        "from"	TEXT NOT NULL,
        "to"	TEXT NOT NULL,
        "token"	TEXT NOT NULL,
        "blocknumber"	INTEGER NOT NULL,
        "amount"	INTEGER,
        "timestamp"	TEXT,
        "amountInTokens"	REAL,
        "amountInUSDCurrent"	REAL,
        "amountInUSD"	REAL,
        "emptiedAccount"	INTEGER DEFAULT 0,
        "canBeChangeTransfer"	INTEGER DEFAULT 0,
        "isChangeTransfer"	INTEGER DEFAULT 0,
        "isIntoDepositAddress"	INTEGER DEFAULT 0,
        "isIntraCapp"	INTEGER DEFAULT 0,
        "isFromCapp"	INTEGER DEFAULT 0,
        "percentile"	NUMERIC,
        "isEarlyTransfer"	INTEGER,
        "isVeryEarlyTransfer"	INTEGER,
        "isFromDiluter"	INTEGER DEFAULT 0,
        "isToDiluter"	INTEGER DEFAULT 0,
        "isFromMixer"	INTEGER DEFAULT 0,
        "isToMixer"	INTEGER DEFAULT 0,
        "isToConcentrator"	INTEGER DEFAULT 0,
        "isFromConcentrator"	INTEGER DEFAULT 0,
        "isICOPurchase"	INTEGER DEFAULT 0,
        "wasEmptiedWithinXBlocks"	INTEGER DEFAULT 0,
        "profitability"	NUMERIC,
        FOREIGN KEY("token") REFERENCES "Token"("id"),
        FOREIGN KEY("to") REFERENCES "Entity"("name"),
        PRIMARY KEY("from","to","token","blocknumber"),
        FOREIGN KEY("from") REFERENCES "Entity"("name")
    );
    CREATE INDEX etransfer_blocknumber_index ON ETransfer (blocknumber);
    CREATE INDEX etransfer_from_index ON ETransfer ("from");
    CREATE INDEX etransfer_to_index ON ETransfer ("to");
    CREATE INDEX etransfer_token_index ON ETransfer ("token");	
    CREATE INDEX entity_name_index ON Entity ("name");

    CREATE TABLE "EntityMetadata" (
        "name"	TEXT NOT NULL UNIQUE,
        "indegree"	INTEGER,
        "outdegree"	INTEGER,
        "degree"	INTEGER,
        "distinctDegree"	INTEGER,
        "distinctInDegree"	INTEGER,
        "distinctOutDegree"	INTEGER,
        "involumeUSD"	NUMERIC,
        "outvolumeUSD"	NUMERIC,
        "firstInTransfer" INTEGER,
        "firstOutTransfer" INTEGER,
        "lastInTransfer" INTEGER,
        "lastOutTransfer" INTEGER,
        "involumeUSD_adjusted" NUMERIC,
        "outvolumeUSD_adjusted" NUMERIC,
        "outvolumeUSD_highcap" NUMERIC DEFAULT 0,
        "involumeUSD_highcap" NUMERIC DEFAULT 0,
        PRIMARY KEY("name")
    );

    CREATE TABLE "EntityTaxonomy" (
        "name" TEXT NOT NULL UNIQUE,
        "type" TEXT,
        PRIMARY KEY("name")
    )
    `
    

db.transaction(() => {
    statements.split(';').forEach(s => {
        console.log(s)
        db.prepare(s).run()
    })
})();