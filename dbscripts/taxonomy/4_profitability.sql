
/*DROP TABLE IF EXISTS Profits;
DROP TABLE IF EXISTS Purchase;
DROP TABLE IF EXISTS Sale;
CREATE TABLE Purchase AS
SELECT
    e.name, 
    t.token, 
    sum(IFNULL(amountInUSD,0)) as price,
    sum(
    CASE 
        WHEN amountInUSD is null THEN 0
        ELSE amountInTokens
    END) as amount,
    SUM(amountInTokens) as amount_unadjusted
FROM
    Entity e
    INNER JOIN
    ETransfer t
    ON e.name = t.`to`
WHERE blocknumber <= @blocknumber
GROUP BY e.name, t.token;

CREATE TABLE Sale AS
SELECT
    e.name, 
    t.token, 
    sum(IFNULL(amountInUSD,0)) as price,
    sum(
    CASE 
        WHEN amountInUSD is null THEN 0
        ELSE amountInTokens
    END) as amount,
    SUM(amountInTokens) as amount_unadjusted
FROM
    Entity e
    INNER JOIN
    ETransfer t
    ON e.name = t.`from`
WHERE blocknumber <= @blocknumber
GROUP BY e.name, t.token; 

CREATE INDEX sale_name ON sale("name");
CREATE INDEX sale_token ON sale("token");
CREATE INDEX purchase_name ON purchase("name");
CREATE INDEX purchase_token ON purchase("token");

CREATE TABLE Profits AS
SELECT
    name,
    SUM(saleProfits) as profits,
    SUM(tokensLeft * price) as holdingValue,
    SUM(purchaseExpenses) as expenses,
    SUM(saleProfits + tokensLeft * price) / SUM(purchaseExpenses) as profitPercentage
FROM
    (SELECT
        p.name,
        p.token,
        CASE (IFNULL(s.amount,0) > p.amount)
            WHEN 1 THEN IFNULL(s.price,0) / IFNULL(s.amount,1) * p.amount
            ELSE IFNULL(s.price,0)
        END as saleProfits,
        p.price as purchaseExpenses,
        CASE (IFNULL(s.amount,0) > p.amount)
            WHEN 1 THEN 0
            ELSE p.amount - IFNULL(s.amount,0)
        END as tokensLeft
    FROM
        Purchase p
        LEFT OUTER JOIN
        Sale s
        ON p.name = s.name and p.token = +s.token
    WHERE 
        p.price is not null and 
        s.price is not null) trades
    INNER JOIN
    Price
    ON 
        date = @day
        and
        Price.token = trades.token
GROUP BY name;

CREATE INDEX Profits_name ON Profits("name");
*/
UPDATE EntityMetadata 
SET profitability = (SELECT Profits.profitPercentage FROM Profits WHERE Profits.name = EntityMetadata.name);

UPDATE EntityTaxonomy
SET yield = (
    SELECT CASE
        WHEN profitability < 0.1 THEN "loss<.1"
        WHEN profitability < 0.67 THEN "loss<.67"
        WHEN profitability < 0.9 THEN "loss<.9"
        WHEN profitability < 1.1 THEN "steady>=.9,<1.1"
        WHEN profitability < 1.5 THEN "profit<1.5"
        WHEN profitability < 10 THEN "profit<10"
        WHEN profitability >= 10 THEN "profit>=10"
        ELSE "unknown"
    END 
    FROM
        EntityMetadata
    WHERE EntityMetadata.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;