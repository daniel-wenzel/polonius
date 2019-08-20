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
/*

SELECT
	coldWallet.*
FROM 
	Address receiver
	INNER JOIN
	Transfer fromReceiver
	INNER JOIN
	Address coldWallet
	INNER JOIN 
	Transfer toSender
	INNER JOIN 
	Address sender
	INNER JOIN
	AddressMetadata coldWalletM
ON
	receiver.address = fromReceiver.`from` and
	fromReceiver.`to` = coldWallet.address and
	coldWallet.address = toSender.`from` and
	toSender.`to` = sender.address and
	coldWallet.address = coldWalletM.address
WHERE
	receiver.isCappReceiver = 1 and
	sender.isCappSender = 1 and
	coldWallet.isDepositAddress = 0 and
	coldWalletM.involumeUSD > 5000
GROUP BY coldWallet.address
HAVING 
	SUM(fromReceiver.amountInUSDCurrent) > 0.8*coldWalletM.involumeUSD and 
	SUM(toSender.amountInUSDCurrent) > 0.8*coldWalletM.outvolumeUSD 
*/

/*
UPDATE Address
SET isDepositAddress = 0, isCappOther = 1
WHERE address in
	(SELECT 
	a.address
FROM 
    Address a
WHERE
    a.isCappReceiver = 0 and a.isCappSender = 0 and 
    EXISTS
		(SELECT inT.`to`
		FROM
			Transfer inT
		INNER JOIN
			Transfer outT
        INNER JOIN
            Address receiver
		ON 
                inT.`to` = outT.`from` AND 
                inT.`from` = a.address AND 
                outT.`to` = a.address AND 
                receiver.isCappReceiver = 1 and receiver.isCappSender = 1 and
                inT.`to` = receiver.address and
                inT.amountInUSDCurrent > 100 and
                outT.amountInUSDCurrent > 100));

UPDATE Address
SET isCappSender = 1
WHERE address in
	(SELECT 
		cappReceiver.address
	FROM
		Address cappReceiver
		INNER JOIN
		AddressMetadata cappReceiverM
		INNER JOIN
		AddressMetadata cappSenderM
		INNER JOIN
		Transfer t
		ON
		t.`from` = cappReceiver.address and cappReceiver.isCappReceiver = 1
		and cappReceiverM.address = cappReceiver.address
		and t.`to` = cappSenderM.address
		and not cappReceiver.address = cappSenderM.address
	GROUP BY cappReceiver.address
	HAVING cappReceiverM.distinctOutDegree > MIN(cappSenderM.distinctOutDegree));

UPDATE Address
SET isCappSender = 1
WHERE address in
	(SELECT 
		potentialCappSender.address 
	FROM 
		Address cappReceiver 
		INNER JOIN
		Address potentialCappSender
		INNER JOIN 
		Transfer t
		ON
		cappReceiver.address = t.`from` AND
		potentialCappSender.address = t.`to` AND
		(cappReceiver.isCappReceiver = 1 or cappReceiver.isCappSender = 1)
	GROUP BY cappReceiver.address
	HAVING count(distinct potentialCappSender.address) = 1)*/