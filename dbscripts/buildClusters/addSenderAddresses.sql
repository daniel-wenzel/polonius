/*INSERT INTO cluster
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
		(receiverAddress.isCappReceiver = 1 or receiverAddress.isCappOther = 1 or receiverAddress.isCappStorage = 1);
*/

INSERT INTO cluster
SELECT 
	c.clusterName, other.address
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
	INNER JOIN
	cluster c
ON 
	receiver.address = t.`from` and
	other.address = t.`to` and
	c.member = receiver.address
WHERE
	receiver.isCappReceiver = 1 and
	(other.isCappSender = 1 OR other.isCappOther = 1)
GROUP BY receiver.address, other.address
HAVING SUM(amountInUSDCurrent) > 0.05 * receiverM.outvolumeUSD