UPDATE AddressMetadata
SET behavedLikeDepositAddress=0;

UPDATE Address
SET isCAPPHotWallet=0, isDepositAddress=0;

UPDATE AddressMetadata
SET behavedLikeDepositAddress = 1
WHERE AddressMetadata.address in (SELECT t.`to` FROM Transfer t GROUP BY t.`to` HAVING min(wasEmptiedWithinXBlocks) = 1);

UPDATE Address
SET isCAPPHotWallet=1
WHERE
	Address.address in 
		(SELECT 
			t.`to`
		FROM
			AddressMetadata senderMetadata
			INNER JOIN 
			AddressMetadata receiverMetadata
			INNER JOIN
			Transfer t
			ON senderMetadata.address = t.`from` AND senderMetadata.behavedLikeDepositAddress=1
				and receiverMetadata.address = t.`to`
		GROUP BY t.`to`
		HAVING count(DISTINCT senderMetadata.address) >= 100 and count(DISTINCT senderMetadata.address) > 0.25 * receiverMetadata.distinctInDegree);
		
UPDATE Address
SET isDepositAddress=1
WHERE
	Address.address in 
	(SELECT 
		t.`from`
	FROM
		AddressMetadata m
		INNER JOIN 
		Address a
		INNER JOIN
		Transfer t
		ON m.address = t.`from` AND m.behavedLikeDepositAddress=1 AND t.`to`=a.address and a.isCAPPHotWallet=1
	GROUP BY t.`from`
	HAVING min(isCAPPHotWallet) = 1);


UPDATE Address
SET isDepositAddress = 1
WHERE Address.address in
	(SELECT 
		a.address
	FROM
		Address a
		INNER JOIN
		Transfer t
		INNER JOIN
		Address receiver
		ON a.address = t.`from` and t.`to`=receiver.address
	WHERE
		a.isDepositAddress = 0
	GROUP BY a.address
	HAVING 
		count(*) = sum(receiver.isCAPPHotWallet) AND
		(count(*) < 10 OR SUM(t.emptiedAccount) > 0.25 * count(*)))