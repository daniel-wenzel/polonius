UPDATE Address
SET ownedBy = (SELECT t.`to` 
				FROM Transfer t 
					INNER JOIN
					Address rec
					ON t.`to` = rec.address
				WHERE t.`from`=address and rec.isCappReceiver = 1)
WHERE isDepositAddress = 1;

## Any intracapp transfers happened between addresses of the same owner
CREATE TEMP TABLE ownedBy AS
SELECT 
	CASE 
		WHEN aMeta.distinctDegree >= bMeta.distinctDegree THEN b
		ELSE a
	END as owned,
	CASE 
		WHEN aMeta.distinctDegree >= bMeta.distinctDegree THEN a
		ELSE b
	END as owner,
    MAX(aMeta.distinctDegree, bMeta.distinctDegree) as ownerDistinctDegree
FROM
	(SELECT DISTINCT t.`to` as a, t.`from` as b
	FROM Transfer t WHERE t.isIntraCapp = 1) s
	INNER JOIN
	AddressMetadata aMeta
	INNER JOIN
	AddressMetadata bMeta
	ON aMeta.address = a and bMeta.address = b

# if an address is owned by two other addresses, we pick a owner among the two
INSERT INTO ownedBy
SELECT 
	smallerOwner.owner as owned, biggerOwner.owner as owner, biggerOwner.ownerDistinctDegree
FROM 
	ownedBy smallerOwner
	INNER JOIN
	ownedBy biggerOwner
	ON smallerOwner.owned = biggerOwner.owned and smallerOwner.owner is not biggerOwner.owner
WHERE biggerOwner.ownerDistinctDegree >= smallerOwner.ownerDistinctDegree;



UPDATE Address
SET ownedBy = (SELECT owner FROM ownedBy where owned = address)
WHERE address in (SELECT owned FROM ownedBy);

UPDATE Address
SET ownedBy = (SELECT owner FROM ownedBy where owned = Address.ownedBy)
WHERE Address.ownedBy in (SELECT owned FROM ownedBy);



## Must be empty:
SELECT owner.address 
FROM Address owner
	INNER JOIN
	Address owned
	ON owned.ownedBy = owner.address
WHERE owner.ownedBy is not null;


SELECT 
	ownedA.owned, ownedA.owner, ownedB.owner
FROM 
	ownedBy ownedA
	INNER JOIN
	ownedBy ownedB
	ON ownedA.owned = ownedB.owned and ownedA.owner is not ownedB.owner;
	
SELECT count(*) FROM ownedBy;