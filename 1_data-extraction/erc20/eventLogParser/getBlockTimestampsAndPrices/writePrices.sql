UPDATE Transfer
SET amountInUSD = amountInTokens * (
    SELECT price 
    FROM Price
    WHERE 
        date = "" || CAST(timestamp AS int) / 86400 * 86400
        AND
        Transfer.token = Price.token
    )
WHERE token = @token