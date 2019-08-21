DROP TABLE IF EXISTS cluster;
CREATE /*TEMP*/ TABLE cluster AS
SELECT DISTINCT
	depositAddress.address || '-couse' as clusterName, senderAddress.address as member
FROM 
	address depositAddress
	INNER JOIN
	Transfer t
	INNER JOIN
	address senderAddress
	INNER JOIN
	AddressMetadata senderMeta
	ON senderAddress.address = t.`from` and t.`to` = depositAddress.address and senderAddress.address = senderMeta.address
WHERE 
	depositAddress.isDepositAddress = 1 and
	senderAddress.isCappSender = 0 and
	senderAddress.isCappReceiver = 0 and
	senderAddress.isCappOther = 0 and
	senderAddress.isCappStorage = 0 and
	senderAddress.isDepositAddress = 0 AND
	senderMeta.distinctOutDegree < 5
LIMIT 1;

/* The above query will also insert addresses which are the only ones that deposited to that depositAddress
 This results in clusters of size 1, therefore we can immediately delete them*/
DELETE FROM cluster
WHERE clusterName in (SELECT clusterName FROM cluster GROUP BY clusterName HAVING count(*) = 1);

INSERT INTO cluster
SELECT a.address || '-capp' as clusterName, a.address as member 
FROM Address a
WHERE
	a.isCappReceiver = 1;

/* All receivers which received from at least 50 different deposit addresses are part of the same cluster */
INSERT INTO cluster
SELECT 
    MAX(r1.address, r2.address) || "-samedepos" as cluster, r2.address
FROM 
    Address depo
    INNER JOIN
    Transfer t1
    INNER JOIN 
    Address r1
    INNER JOIN
    Transfer t2
    INNER JOIN 
    Address r2
ON
    depo.address = t1.`from` and
    t1.`to` = r1.address and
    depo.address = t2.`from` and
    t2.`to` = r2.address
WHERE 
    depo.isDepositAddress = 1 and
    r1.isCappReceiver = 1 and
    r2.isCappReceiver = 1 and
    r1.address <> r2.address
GROUP BY r1.address, r2.address
HAVING count(*) > 50
ORDER BY cluster

CREATE INDEX cluster_name ON cluster("clusterName");
CREATE INDEX cluster_member ON cluster("member");


