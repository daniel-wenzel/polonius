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

UPDATE AddressMetadata
SET behavedLikeDepositAddress = 1
WHERE 
	AddressMetadata.address in 
		(SELECT t.`to` 
		 FROM Transfer t 
		 GROUP BY t.`to` HAVING min(wasEmptiedWithinXBlocks) = 1)
	and AddressMetadata.distinctOutDegree < 10;