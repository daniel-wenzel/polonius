CREATE TEMP TABLE numTokensUsed AS
SELECT 
name, count(distinct token) as numTokens
FROM
(SELECT `from` as name, token FROM ETransfer WHERE blocknumber <= @blocknumber
UNION ALL
SELECT `to` as name, token FROM ETransfer WHERE blocknumber <= @blocknumber)
GROUP BY name;

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

