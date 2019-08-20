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
TODODODO
SELECT 

FROM
	(Address receiver
	NATURAL JOIN
	AddressMetadata receiverM)
	INNER JOIN
	Transfer t
	INNER JOIN
	(Address other
	NATURAL JOIN
	AddressMetadata other)
ON 
	receiver.address = t.`from` and
	other.address = t.`to`
WHERE
	receiver.isCappReceiver = 1 and
	(sender.isCappSender = 1 OR sender.isCappOther = 1)
GROUP BY receiver.address, sender.address
HAVING SUM(amountInUSDCurrent) > 0.05 * receiver.outvolumeUSD