UPDATE ETransfer
SET amountInUSD = (
    SELECT price 
    FROM Price
    WHERE 
        date = CAST(timestamp AS int) / 86400 * 86400
        AND
        ETransfer.token = Price.token
    ) * amount;