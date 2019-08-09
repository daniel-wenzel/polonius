REPLACE INTO Transfer
SELECT p."from", 
        p."to",
        p.token,
        p.blocknumber, 
        p.amount, 
        p.timestamp, 
        "amountInTokens",
        "amountInUSDCurrent",
        "amountInUSD",
        "emptiedAccount",
        "canBeChangeTransfer",
        "isChangeTransfer",
        "isIntoDepositAddress",
        "isIntraCapp",
        "isFromCapp",
        percentileN,
        percentileN < 0.05 as isEarlyTransfer,
        percentileN < 0.005 as isVeryEarlyTransfer,
        "isFromDiluter",
        "isToDiluter",
        "isFromMixer",
        "isToMixer",
        "isToConcentrator",
        "isFromConcentrator",
        "isICOPurchase",
        "wasEmptiedWithinXBlocks"
FROM
    (SELECT 
        t.*,
        PERCENT_RANK() OVER( 
            PARTITION BY token
            ORDER BY blocknumber 
        ) percentileN 
    FROM 
    Transfer t) p