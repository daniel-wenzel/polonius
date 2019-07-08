UPDATE Address
SET isDepositAddress = 0, isCappOther = 1
WHERE address in
	(SELECT 
		a.address
	FROM 
		Address a
	WHERE
		a.isDepositAddress = 1
		AND EXISTS
			(SELECT inT.`to`
			FROM
				Transfer inT
			INNER JOIN
				Transfer outT
			ON inT.`to` = outT.`from` AND inT.`from` = a.address AND outT.`to` = a.address));

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
	HAVING count(distinct potentialCappSender.address) = 1)