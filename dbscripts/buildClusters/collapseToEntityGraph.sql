/*UPDATE Address
SET cluster = (SELECT clusterName from cluster where member = address)
WHERE address in (SELECT member from cluster);

UPDATE Address
SET cluster = address
WHERE address not in (SELECT member from cluster);
*/

DROP TABLE IF EXISTS ETransfer;
DROP TABLE IF EXISTS EntityTaxonomy;
DROP TABLE IF EXISTS EntityMetadata;
DROP TABLE IF EXISTS Entity;

    CREATE TABLE "Entity" (
        "name"	TEXT NOT NULL,
        "isCapp"	INTEGER,
        "isExchange" INTEGER,
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
    );
    

REPLACE INTO Entity
SELECT 
    cluster, max(isCappReceiver), max(isExchange)
FROM Address
GROUP BY cluster;

REPLACE INTO ETransfer
SELECT
    sender.cluster,
    receiver.cluster,
    t.token,
    t.blocknumber,
    null, /*SUM(t.amount), caused an integer overflow */
    t.timestamp,
    SUM(t.amountInTokens),
    SUM(t.amountInUSDCurrent),
    SUM(t.amountInUSD),
    emptiedAccount,
    canBeChangeTransfer,
    isChangeTransfer,
    isIntoDepositAddress,
    isIntraCapp,
    isFromCapp,
    percentile,
    isEarlyTransfer,
    isVeryEarlyTransfer,
    isFromDiluter,
    isToDiluter,
    isFromMixer,
    isToMixer,
    isToConcentrator,
    isFromConcentrator,
    isICOPurchase,
    wasEmptiedWithinXBlocks,
    null /* profitability */
FROM
    Address sender
    INNER JOIN
    Address receiver
    INNER JOIN
    Transfer t
    ON
        sender.address = t.`from` and
        receiver.address = t.`to`
GROUP BY 
    sender.cluster, 
    receiver.cluster, 
    t.token,
    t.blocknumber;


/* We can have no incoming or outcomming transactions for an address, therefore we have three different insert statements */
REPLACE INTO EntityMetadata (name, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD)
    SELECT i.addr, indegree, 0, indegree as degree, distinct_indegree as distinctDegree, distinct_indegree, 0, involumeUSD, 0
    FROM 
        (SELECT t.`to` as addr,count(*) as indegree, count(distinct t.`from`) as distinct_indegree, sum(t.amountInUSDCurrent) as involumeUSD FROM ETransfer t GROUP BY t.`to`) i;

REPLACE INTO EntityMetadata (name, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD)
    SELECT o.addr, 0, outdegree, 0+outdegree as degree, 0+distinct_outdegree as distinctDegree, 0, distinct_outdegree, 0, outvolumeUSD
    FROM 
        (SELECT t.`from` as addr,count(*) as outdegree, count(distinct t.`to`) as distinct_outdegree,  sum(t.amountInUSDCurrent) as outvolumeUSD FROM ETransfer t GROUP BY t.`from`) o;


REPLACE INTO EntityMetadata (name, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD)
    SELECT i.addr, indegree, outdegree, indegree+outdegree as degree, distinct_indegree+distinct_outdegree as distinctDegree, distinct_indegree, distinct_outdegree, involumeUSD, outvolumeUSD
    FROM 
        (SELECT t.`to` as addr,count(*) as indegree, count(distinct t.`from`) as distinct_indegree, sum(t.amountInUSDCurrent) as involumeUSD FROM ETransfer t GROUP BY t.`to`) i
        INNER JOIN
        (SELECT t.`from` as addr,count(*) as outdegree, count(distinct t.`to`) as distinct_outdegree,  sum(t.amountInUSDCurrent) as outvolumeUSD FROM ETransfer t GROUP BY t.`from`) o
        ON i.addr = o.addr;	