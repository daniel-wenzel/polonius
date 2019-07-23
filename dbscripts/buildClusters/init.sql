DROP TABLE IF EXISTS cluster;
CREATE TEMP TABLE cluster AS
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
	senderMeta.distinctOutDegree < 5;

/* The above query will also insert addresses which are the only ones that deposited to that depositAddress
 This results in clusters of size 1, therefore we can immediately delete them*/
DELETE FROM cluster
WHERE clusterName in (SELECT clusterName FROM cluster GROUP BY clusterName HAVING count(*) = 1);

INSERT INTO cluster
SELECT a.address || '-capp' as clusterName, a.address as member 
FROM Address a
WHERE
	a.isCappReceiver = 1;
	
INSERT INTO cluster
SELECT MAX(`from`, `to`) || '-change' as ClusterName, MIN(`from`, `to`) as member FROM Transfer WHERE isChangeTransfer = 1
UNION ALL
SELECT MAX(`from`, `to`) || '-change', MAX(`from`, `to`) FROM Transfer WHERE isChangeTransfer = 1;

CREATE INDEX cluster_name ON cluster("clusterName");
CREATE INDEX cluster_member ON cluster("member");


