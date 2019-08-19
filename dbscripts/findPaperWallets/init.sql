UPDATE Transfer
SET emptiedAccount = 0,
    isChangeTransfer = 0,
    canBeChangeTransfer = 0;

UPDATE AddressMetadata
SET firstOutBlocknumber = (SELECT MIN(t.blocknumber) FROM Transfer t where t.`from` = AddressMetadata.address)
WHERE
	address in (SELECT DISTINCT t.`from` from Transfer t);

UPDATE Transfer
SET emptiedAccount = 1
WHERE
	EXISTS
		(SELECT * FROM balances 
		where 
			balanceChange < -5 and balance < 0.05 and balance > -0.05
			and address = Transfer.`from` and balances.blocknumber = Transfer.blocknumber); 

/* It is a paper wallet it it was emptied with /shortly after the first outgoing transfer */
UPDATE AddressMetadata
SET canBePaperWallet = 'YES'
WHERE 
    firstOutBlocknumber is not null and
    exists (SELECT * FROM balances WHERE balances.address = AddressMetadata.address 
                    and 
                    firstOutBlocknumber < balances.blocknumber and
                    firstOutBlocknumber + 30 > balances.blocknumber and
                    balance > -0.05 and balance < 0.05
                );
/* it is not a paper wallet if it wasnt emptied with/shortly after the first outgoing transfer */
UPDATE AddressMetadata
SET canBePaperWallet = 'NO'
WHERE 
    firstOutBlocknumber is not null and
    NOT exists (SELECT * FROM balances WHERE balances.address = AddressMetadata.address 
                    and 
                    firstOutBlocknumber < balances.blocknumber and
                    firstOutBlocknumber + 30 > balances.blocknumber and
                    balance > -0.05 and balance < 0.05
                );
/* it wasnt a paper wallet if it receiver a transfer after the first outgoing transfer */
UPDATE AddressMetadata
SET canBePaperWallet = 'NO'
WHERE 
    firstOutBlocknumber is not null and
    EXISTS (SELECT * FROM Transfer t where 
        t.blocknumber > firstOutBlocknumber and 
        t.`to` = address);
/* Deposit addresses are not paper wallets */
UPDATE AddressMetadata
SET canBePaperWallet = 'NO'
WHERE 
    address in (SELECT address FROM Address WHERE isDepositAddress = 1);


/*UPDATE Transfer
SET isChangeTransfer = 1
WHERE
	emptiedAccount = 1
	and 
        ((SELECT firstOutBlocknumber FROM AddressMetadata m WHERE m.address = Transfer.`to`) > blocknumber 
        OR 
        (SELECT firstOutBlocknumber FROM AddressMetadata m WHERE m.address = Transfer.`to`) is null);
*/

UPDATE Transfer
SET isChangeTransfer = 1
WHERE
    Transfer.emptiedAccount = 1 and
    EXISTS (
        SELECT * FROM AddressMetadata m
        WHERE m.canBePaperWallet = 'YES' and m.address = Transfer.`from`
    )
    AND
	Transfer.`to` not in (SELECT address FROM AddressMetadata m WHERE m.canBePaperWallet = 'NO');