
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