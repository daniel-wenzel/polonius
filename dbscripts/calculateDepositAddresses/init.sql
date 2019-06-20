CREATE TABLE AddressMetadata (
    "address" TEXT,
    "indegree" INTEGER,
    "outdegree" INTEGER,
    "degree" INTEGER,
    "distinctDegree" INTEGER,
    "behavedLikeDepositAddress" INTEGER DEFAULT 0,
    PRIMARY KEY ("address")
);
INSERT INTO AddressMetadata (address, indegree, outdegree, degree, distinctDegree, distinctInDegree)
    SELECT i.addr, indegree, outdegree, indegree+outdegree as degree, distinct_indegree+distinct_outdegree as distinctDegree, distinct_indegree
    FROM 
        (SELECT t.`to` as addr,count(*) as indegree, count(distinct t.`from`) as distinct_indegree FROM Transfer t GROUP BY t.`to`) i
        INNER JOIN
        (SELECT t.`from` as addr,count(*) as outdegree, count(distinct t.`to`) as distinct_outdegree FROM Transfer t GROUP BY t.`from`) o
        ON i.addr = o.addr;

CREATE INDEX degree_index ON AddressMetadata (degree);
CREATE INDEX behavedLikeDepositAddress_index ON AddressMetadata (behavedLikeDepositAddress);
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
