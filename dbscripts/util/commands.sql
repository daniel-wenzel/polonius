CREATE TEMP TABLE inTokens AS
SELECT
    i.`to` as name, i.`token`, SUM(i.amountInTokens) as amount
FROM
    ETransfer i
GROUP BY i.`to`, i.token;

CREATE TEMP TABLE outTokens AS
SELECT
    i.`from` as name, i.`token`, SUM(i.amountInTokens) as amount
FROM
    ETransfer i
GROUP BY i.`from`, i.token;

CREATE INDEX inTokens_ft ON inTokens("name","token");
CREATE INDEX inTokens_t ON inTokens("token");
CREATE INDEX outTokens_ft ON outTokens("name","token");

CREATE TEMP TABLE supplies AS
SELECT
    token, SUM(i.amount - IFNULL(o.amount,0)) as supply
FROM
    inTokens i
    LEFT OUTER JOIN
    outTokens o
    ON
        i.token = o.token and i.name = o.name
WHERE i.amount - IFNULL(o.amount,0) > 0
GROUP BY i.token;

UPDATE Token
SET actualSupply = (SELECT supply FROM supplies WHERE supplies.token = Token.id);