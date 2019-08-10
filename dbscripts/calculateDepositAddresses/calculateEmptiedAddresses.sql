UPDATE Transfer
SET emptiedAccount=0, wasEmptiedWithinXBlocks=0;

UPDATE Transfer
SET emptiedAccount = 1
WHERE EXISTS 
    (SELECT balance 
	FROM balances b 
	where 
		b.blocknumber = Transfer.blocknumber and 
		b.address = Transfer.`from` and 
		balance > -0.05 and balance < 0.05);

UPDATE Transfer
SET wasEmptiedWithinXBlocks = 1
WHERE EXISTS 
    (SELECT balance FROM balances b where 
		b.blocknumber > Transfer.blocknumber and 
		b.blocknumber < Transfer.blocknumber+@numBlocks and
		b.address = Transfer.`to` and 
		balance > -0.05 and balance < 0.05);