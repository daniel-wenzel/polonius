CREATE TEMPORARY TABLE AddressMetadata (
    "address" TEXT,
    "indegree" INTEGER,
    "outdegree" INTEGER,
    "degree" INTEGER,
    PRIMARY KEY ("address")
)

INSERT INTO AddressMetadata 
    SELECT i.addr, indegree, outdegree, indegree+outdegree as degree
    FROM 
        (SELECT t.`to` as addr,count(*) as indegree FROM Transfer t GROUP BY t.`to`) i
        INNER JOIN
        (SELECT t.`from` as addr,count(*) as outdegree FROM Transfer t GROUP BY t.`from`) o
        ON i.addr = o.addr

CREATE INDEX degree_index ON AddressMetadata (degree);

CREATE TEMPORARY TABLE balances (
        "address"	TEXT,
        "blocknumber",
        "balanceChange"	REAL NOT NULL,
        "balance" REAL, 
        PRIMARY KEY("address", "blocknumber")
    )
CREATE INDEX balance_index ON balances (balance);
CREATE INDEX blocknumber_index ON balances (blocknumber);
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
    WHERE
        meta.degree < 200
	GROUP BY b.address, blocknumber

UPDATE balances
SET balance = balanceChange
WHERE balances.blocknumber = (SELECT MIN(blocknumber) from balances b where b.address = balances.address)

UPDATE balances
SET balance = 
        balanceChange + 
        (SELECT balance from balances b 
            where b.address = balances.address and
                  b.blocknumber = (SELECT MAX(blocknumber) 
                                    FROM balances bMax 
                                    WHERE bMAX.address = balances.address and 
                                          bMax.balance is not null))
WHERE 
    balance is null and
    balances.blocknumber = (SELECT MIN(blocknumber) 
        from balances b 
        where 
            b.address = balances.address and 
            balance is null)




SELECT current.address, current.blocknumber, SUM(past.balanceChange) + current.balanceChange as balance FROM balanceChanges current, balanceChanges past
WHERE 
    current.address = past.address AND
    past.blocknumber < current.blocknumber
GROUP BY current.address, current.blocknumber
HAVING 
    balance < 0.05 and balance > -0.05



SELECT address, SUM(balanceChange) as balanceChange FROM
    (SELECT 
        t.`to` as address, 
        t.amountInUSDCurrent as balanceChange 
    FROM Transfer t 
    WHERE blocknumber = 1425001
    UNION ALL 
    SELECT 
        t.`from` as address, 
        -t.amountInUSDCurrent as balanceChange  
    FROM Transfer t 
    WHERE blocknumber = 1425001)
GROUP BY address


UPDATE balanceChanges
SET balance = balanceChange
WHERE balanceChanges.blocknumber = (SELECT MIN(blocknumber) from balanceChanges b where b.address = balanceChanges.address)

UPDATE balanceChanges
SET balance = 
        balanceChange + 
        (SELECT balance from balanceChanges b 
            where b.address = balanceChanges.address and
                  b.blocknumber = (SELECT MAX(blocknumber) 
                                    FROM balanceChanges bMax 
                                    WHERE bMAX.address = balanceChanges.address and 
                                          bMax.balance is not null))
WHERE 
    balance is null and
    balanceChanges.blocknumber = (SELECT MIN(blocknumber) 
        from balanceChanges b 
        where 
            b.address = balanceChanges.address and 
            balance is null)



UPDATE balanceChanges
SET balance = balanceChange
WHERE balanceChanges.blocknumber = (SELECT MIN(blocknumber) from balanceChanges b where b.address = balanceChanges.address)


REPLACE INTO balanceChanges
SELECT 
    current.address, 
    current.blocknumber, 
    current.balanceChange, 
    SUM(past.balanceChange) + current.balanceChange + lastWithBalance.balance as balance 
FROM balanceChanges current, balanceChanges past, balanceChanges lastWithBalance
WHERE 
	current.balance is null AND 
    past.balance is null AND
    lastWithBalance.blocknumber = (SELECT MAX(blocknumber) FROM 
                                        balanceChanges m 
                                    WHERE m.address = current.address 
                                        and m.balance is not null) 
                                    AND
    current.address = past.address AND
    current.address = lastWithBalance.address AND
    past.blocknumber < current.blocknumber AND
    past.blocknumber > lastWithBalance.blocknumber
GROUP BY current.address, current.blocknumber
HAVING count(*) <= 1