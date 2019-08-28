CREATE TEMP TABLE numTokensUsed
    (SELECT e.`to` as name, count(distinct token) as numTokens
    FROM ETransfer e) ins
    LEFT OUTER
GROUP BY e.`to`



UPDATE EntityTaxonomy
SET numberOfTokens = (
    SELECT CASE
        WHEN numTokens = 1 THEN "1"
        WHEN numTokens < 3 THEN "2"
        WHEN numTokens < 7 THEN "3-6"
        WHEN numTokens < 7 THEN "6-30"
        ELSE ">30"
    END 
    FROM
        numTokensUsed
    WHERE numTokensUsed.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;

UPDATE EntityTaxonomy
SET numberOfTokens = "NONE"
WHERE blocknumber = @blocknumber and numberOfTokens is null;

