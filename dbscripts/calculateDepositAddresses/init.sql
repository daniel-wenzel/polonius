DROP TABLE IF EXISTS AddressMetadata;
DROP TABLE IF EXISTS balances;
CREATE TABLE "AddressMetadata" (
	"address"	TEXT NOT NULL UNIQUE,
	"indegree"	INTEGER,
	"outdegree"	INTEGER,
	"degree"	INTEGER,
	"distinctDegree"	INTEGER,
	"distinctInDegree"	INTEGER,
	"distinctOutDegree"	INTEGER,
	"behavedLikeDepositAddress"	INTEGER DEFAULT 0,
	"involumeUSD"	NUMERIC,
	"outvolumeUSD"	NUMERIC,
	"outdegreeFraction"	NUMERIC,
	"outvolumeFraction"	INTEGER,
	"isConcentrator"	INTEGER DEFAULT 0,
	"isMixer"	INTEGER DEFAULT 0,
	"isDiluter"	INTEGER DEFAULT 0,
	"firstOutBlocknumber"	INTEGER,
	"canBePaperWallet"	TEXT DEFAULT 'MAYBE',
	PRIMARY KEY("address")
);
/* We can have no incoming or outcomming transactions for an address, therefore we have three different insert statements */
INSERT INTO AddressMetadata (address, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD, outdegreeFraction, outvolumeFraction)
    SELECT i.addr, indegree, 0, indegree as degree, distinct_indegree as distinctDegree, distinct_indegree, 0, involumeUSD, 0, 1.0*0 / distinct_indegree, 0
    FROM 
        (SELECT t.`to` as addr,count(*) as indegree, count(distinct t.`from`) as distinct_indegree, sum(t.amountInUSDCurrent) as involumeUSD FROM Transfer t GROUP BY t.`to`) i;

REPLACE INTO AddressMetadata (address, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD, outdegreeFraction, outvolumeFraction)
    SELECT o.addr, 0, outdegree, 0+outdegree as degree, 0+distinct_outdegree as distinctDegree, 0, distinct_outdegree, 0, outvolumeUSD, null, null
    FROM 
        (SELECT t.`from` as addr,count(*) as outdegree, count(distinct t.`to`) as distinct_outdegree,  sum(t.amountInUSDCurrent) as outvolumeUSD FROM Transfer t GROUP BY t.`from`) o;


REPLACE INTO AddressMetadata (address, indegree, outdegree, degree, distinctDegree, distinctInDegree, distinctOutDegree, involumeUSD, outvolumeUSD, outdegreeFraction, outvolumeFraction)
    SELECT i.addr, indegree, outdegree, indegree+outdegree as degree, distinct_indegree+distinct_outdegree as distinctDegree, distinct_indegree, distinct_outdegree, involumeUSD, outvolumeUSD, 1.0*distinct_outdegree / distinct_indegree, outvolumeUSD / involumeUSD
    FROM 
        (SELECT t.`to` as addr,count(*) as indegree, count(distinct t.`from`) as distinct_indegree, sum(t.amountInUSDCurrent) as involumeUSD FROM Transfer t GROUP BY t.`to`) i
        INNER JOIN
        (SELECT t.`from` as addr,count(*) as outdegree, count(distinct t.`to`) as distinct_outdegree,  sum(t.amountInUSDCurrent) as outvolumeUSD FROM Transfer t GROUP BY t.`from`) o
        ON i.addr = o.addr;	

CREATE INDEX degree_index ON AddressMetadata (degree);
CREATE INDEX behavedLikeDepositAddress_index ON AddressMetadata (behavedLikeDepositAddress);
CREATE INDEX firstOutBlocknumber_index ON AddressMetadata (firstOutBlocknumber);

CREATE INDEX distinctInDegree_index ON AddressMetadata (distinctInDegree);
CREATE INDEX distinctOutDegree_index ON AddressMetadata (distinctOutDegree);

CREATE TABLE balances (
        "address"	TEXT,
        "blocknumber",
        "balanceChange"	REAL NOT NULL,
        "balance" REAL, 
        PRIMARY KEY("address", "blocknumber")
    );
CREATE INDEX balance_index ON balances (balance);
CREATE INDEX balances_blocknumber_index ON balances (blocknumber);
CREATE INDEX address_index ON balances (address);

INSERT INTO balances (address,blocknumber, balanceChange)
	SELECT b.address, blocknumber, sum(balanceChange) as balanceChange FROM
        AddressMetadata meta
        INNER JOIN
		(SELECT 
			t.`to` as address, 
			t.blocknumber,
			t.amountInUSDCurrent as balanceChange 
		FROM Transfer t 
		UNION ALL 
		SELECT 
			t.`from` as address, 
			t.blocknumber,
			-t.amountInUSDCurrent as balanceChange  
		FROM Transfer t) b
        ON meta.address = b.address
    where
        meta.degree < @maxDegree
	GROUP BY b.address, blocknumber;

UPDATE balances
SET balance = balanceChange
WHERE balances.blocknumber = (SELECT MIN(blocknumber) from balances b where b.address = balances.address)
