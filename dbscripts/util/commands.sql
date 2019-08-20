UPDATE Address
SET isCappSender = 0
WHERE isCappSender <> 0;

UPDATE Address
SET isCappSender = 1
WHERE address in
(SELECT 
    sender.address
FROM
    address rec 
    INNER JOIN 
    AddressMetadata recM
    INNER JOIN
    transfer t
    INNER JOIN
    address sender
    INNER JOIN
    AddressMetadata senderM
    ON rec.address = t.`from` and sender.address = t.`to` and rec.address = recM.address and sender.address = senderM.address
WHERE 
    rec.isCappReceiver=1 and 
    senderM.distinctOutDegree > 100 and
	(senderM.distinctInDegree < 25 or sender.isCappReceiver = 1)
GROUP BY rec.address, sender.address
HAVING 
	SUM(t.amountInUSDCurrent) / (1.0 * recM.involumeUSD) > 0.001 and 
	count(*) / (1.0 * recM.outDegree) > 0.05
);

UPDATE Address
SET isCappSender = 1
WHERE address in
	(SELECT 
		cappReceiver.address
	FROM
		Address cappReceiver
		NATURAL JOIN
		AddressMetadata cappReceiver
	WHERE distinctOutDegree > 100 and isCappReceiver = 1);