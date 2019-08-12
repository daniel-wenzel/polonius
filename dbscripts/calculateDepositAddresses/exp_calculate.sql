UPDATE Transfer
SET wasEmptiedWithinXBlocks=0
WHERE wasEmptiedWithinXBlocks=1;

UPDATE Transfer
SET wasEmptiedWithinXBlocks = 1
WHERE EXISTS 
    (SELECT balance FROM balances b where 
		b.blocknumber > Transfer.blocknumber and 
		b.blocknumber < Transfer.blocknumber+@numBlocks and
		b.address = Transfer.`to` and 
		balance > -0.05 and balance < 0.05);

UPDATE AddressMetadata
SET behavedLikeDepositAddress=0
WHERE behavedLikeDepositAddress=1;

UPDATE Address
SET isCappReceiver=0, isDepositAddress=0
WHERE isCappReceiver=1 OR isDepositAddress=1;

UPDATE AddressMetadata
SET behavedLikeDepositAddress = 1
WHERE 
	AddressMetadata.address in 
		(SELECT t.`to` 
		 FROM Transfer t 
		 GROUP BY t.`to` HAVING min(wasEmptiedWithinXBlocks) = 1)
	and AddressMetadata.distinctOutDegree < 10;

UPDATE Address
SET isCappReceiver=1
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
		HAVING 
			count(DISTINCT senderMetadata.address) >= 100 and 
			count(DISTINCT senderMetadata.address) > @minPercentageBehavedLikeDepositAddress * receiverMetadata.distinctInDegree);
		
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
		ON m.address = t.`from` AND m.behavedLikeDepositAddress=1 AND t.`to`=a.address and a.isCappReceiver=1
	GROUP BY t.`from`
	HAVING min(isCappReceiver) = 1);


/* An address might actually not be a capp receiver because the deposit addresses also transfered to non receivers */
UPDATE Address
SET isCappReceiver=0
WHERE
	Address.address in 
		(SELECT address from
		(SELECT 
			receiver.address, 
            (SELECT count(distinct s.address)
                FROM 
                    Transfer t INNER JOIN 
                    Address s
                ON 
                    t.`to` = receiver.address and
                    t.`from` = s.address and
                    s.isDepositAddress
            ) as numDepositAddresses, 
            receiverMetadata.distinctInDegree
		FROM
            Address receiver
            NATURAL JOIN
			AddressMetadata receiverMetadata
        WHERE
            isCappReceiver = 1 and 
            (numDepositAddresses is null OR
            numDepositAddresses < 100 OR
            numDepositAddresses < @minPercentageBehavedLikeDepositAddress * receiverMetadata.distinctInDegree)) a);
/* now we might have fewer capp receivers, so we need to recalculate the deposit addresses */
UPDATE Address
SET isDepositAddress=0
WHERE
	isDepositAddress = 1 and 
    Address.address not in 
	(SELECT 
		t.`from`
	FROM
		AddressMetadata m
		INNER JOIN 
		Address a
		INNER JOIN
		Transfer t
		ON m.address = t.`from` AND m.behavedLikeDepositAddress=1 AND t.`to`=a.address and a.isCappReceiver=1
	GROUP BY t.`from`
	HAVING min(isCappReceiver) = 1);
/* actually this should be performed in a loop until its stable ... */

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
		count(*) = sum(receiver.isCappReceiver) AND
		(count(*) < 10 OR SUM(t.emptiedAccount) > 0.25 * count(*)))