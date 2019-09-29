

UPDATE balances
SET balance = 
        balanceChange + 
        (SELECT balance from balances b 
            where b.address = balances.address and
                  b.blocknumber = (SELECT MAX(blocknumber) 
                                    FROM balances bMax 
                                    WHERE bMAX.address = balances.address and 
                                          bMax.balance is not null))
WHERE 
    balance is null and
    balances.blocknumber = (SELECT MIN(blocknumber) 
        from balances b 
        where 
            b.address = balances.address and 
            balance is null)