/*CREATE TEMP TABLE numTokensUsed AS
SELECT 
name, count(distinct token) as numTokens
FROM
(SELECT `from` as name, token FROM ETransfer WHERE blocknumber <= @blocknumber
UNION ALL
SELECT `to` as name, token FROM ETransfer WHERE blocknumber <= @blocknumber)
GROUP BY name;*/

CREATE TEMP TABLE numTokensUsed AS
SELECT e.name, MAX(IFNULL(f.cnt, 0), IFNULL(t.cnt, 0))
FROM
Entity e
LEFT OUTER JOIN
(SELECT `from` as name,count(distinct token) as cnt FROM ETransfer
WHERE blocknumber <= @blocknumber
GROUP BY `from`) f
LEFT OUTER JOIN
(SELECT `to` as name,count(distinct token) as cnt FROM ETransfer
WHERE blocknumber <= @blocknumber
GROUP BY `to`) t
ON e.name = f.name and e.name = t.name


UPDATE EntityTaxonomy
SET numberOfTokens = (
    SELECT CASE
        WHEN numTokens is null THEN "NONE"
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

