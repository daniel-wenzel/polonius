
UPDATE Transfer
SET intoDepositAddress=1
WHERE Transfer.`to` in (SELECT address FROM Address WHERE isDepositAddress=1)

UPDATE Transfer
SET intraCAPP=1
WHERE Transfer.`from` in (SELECT address FROM Address WHERE isDepositAddress=1)

UPDATE Transfer
SET fromCAPP=1
WHERE Transfer.`from` in (SELECT address FROM Address WHERE isCAPPHotWallet=1)
	
UPDATE Transfer
SET revealedPublicKey=1
WHERE Transfer.blocknumber = (SELECT 
		min(blocknumber)
	FROM Transfer t
	WHERE t.`from`=transfer.`from`)

SELECT r.*, a.* FROM
	(SELECT cappReceiver.address, cappReceiver.name, cappReceiverM.distinctOutDegree, MAX(cappSenderM.distinctOutDegree) as maxOutDegree FROM
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
	GROUP BY cappReceiver.address) r
	INNER JOIN
	AddressMetadata a
	on exists (SELECT * FROM Transfer t WHERE t.'from' = r.address and t.'to' = a.address)
	and a.distinctOutDegree = r.maxOutDegree

SELECT * FROM
	Address a
	INNER JOIN
	AddressMetadata m
	ON m.address = a.address and a.isCappReceiver = 1



#############
SELECT 
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
HAVING cappReceiverM.distinctOutDegree > MIN(cappSenderM.distinctOutDegree)

SELECT 
	cappReceiver.address, cappSenderM.address, cappSenderM.distinctOutDegree
FROM
	Address cappReceiver
	INNER JOIN
	AddressMetadata cappReceiverM
	INNER JOIN
	AddressMetadata cappSenderM
	INNER JOIN
	Address cappSender
	INNER JOIN
	Transfer t
	ON
	t.`from` = cappReceiver.address and cappReceiver.isCappReceiver = 1
	and cappReceiverM.address = cappReceiver.address
	and t.`to` = cappSenderM.address
	and not cappReceiver.address = cappSenderM.address
	and cappSender.address = cappSenderM.address
	and not cappSender.isCappReceiver = 1
GROUP BY cappReceiver.address, cappSenderM.address
HAVING cappSenderM.distinctOutDegree > 100

###########


SELECT 
	cappReceiver.address, t.`to`, SUM(t.amountInUSDCurrent)
FROM 
	Address cappReceiver
	INNER JOIN
	Transfer t
	ON t.`from` = cappReceiver.address and cappReceiver.isCappReceiver = 1
GROUP BY cappReceiver.address, t.`to`



SELECT 
	allOutflows.address, topOutflow, allOutflow, 100 * topOutflow / allOutflow as percentage
FROM
	(SELECT 
		cappReceiver.address, SUM(t.amountInUSDCurrent) as topOutflow
	FROM 
		Address cappReceiver
		INNER JOIN
		Transfer t
		ON t.`from` = cappReceiver.address and cappReceiver.isCappReceiver = 1
	WHERE
		t.`to` in (SELECT 
					t_.`to` 
				   FROM 
					transfer t_
				   WHERE
					 t_.`from` = cappReceiver.address
				   GROUP BY
					 t_.`to`
				   ORDER BY SUM(t_.amountInUSDCurrent) DESC
				   LIMIT 5)
	GROUP BY cappReceiver.address) topOutflows
	INNER JOIN
		(SELECT 
			cappReceiver.address, SUM(t.amountInUSDCurrent) as allOutflow
		FROM 
			Address cappReceiver
			INNER JOIN
			Transfer t
			ON t.`from` = cappReceiver.address and cappReceiver.isCappReceiver = 1
		GROUP BY cappReceiver.address) allOutflows
	ON allOutflows.address = topOutflows.address



SELECT * 
FROM
	(SELECT 
		Token.id,
		(SELECT max(blocknumber) FROM 
			(SELECT *
			from
				Transfer t
			WHERE t.token = Token.id 
			ORDER BY t.blocknumber
			LIMIT 10
		)) as maxBlock
	FROM Token LIMIT 5) tokenData
	INNER JOIN
	Transfer t
	ON tokenData.id = t.token and t.blocknumber < tokenData.maxBlock
GROUP BY t.token


