INSERT INTO cluster
SELECT 
    address, substr(MAX(rnk), INSTR(MAX(rnk), "$")+1)
FROM
    (SELECT 
        depo.address, count(*) || "$" || c.clusterName  as rnk
    FROM
        cluster c
        INNER JOIN
        Transfer t
        INNER JOIN
        Address depo
        INNER JOIN
        Address receiverAddress
        WHERE 
            c.member = t.`to` and 
            t.`from` = depo.address and
            depo.isDepositAddress = 1 and
            c.member = receiverAddress.address and
            (receiverAddress.isCappReceiver = 1 or receiverAddress.isCappOther = 1 or receiverAddress.isCappStorage = 1)
    GROUP BY depo.address, c.clusterName)
GROUP BY rnk;


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