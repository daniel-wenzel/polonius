INSERT INTO cluster
SELECT DISTINCT
	c.clusterName, t.`from`
FROM
	cluster c
	INNER JOIN
	Transfer t
	INNER JOIN
	Address senderAddress
	INNER JOIN
	Address receiverAddress
	WHERE 
		c.member = t.`to` and 
		t.`from` = senderAddress.address and
		senderAddress.isDepositAddress = 1 and
		c.member = receiverAddress.address and
		(receiverAddress.isCappReceiver = 1 or receiverAddress.isCappOther = 1 or receiverAddress.isCappStorage = 1)