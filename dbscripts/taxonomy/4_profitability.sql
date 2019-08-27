/*DROP TABLE IF EXISTS Purchase;
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
    END) as amount
FROM
    Entity e
    INNER JOIN
    ETransfer t
    ON e.name = t.`to`
WHERE blocknumber < @blocknumber
GROUP BY e.name, t.token
HAVING price > 0;

CREATE TABLE Sale AS
SELECT
    e.name, 
    t.token, 
    sum(IFNULL(amountInUSD,0)) as price,
    sum(
    CASE 
        WHEN amountInUSD is null THEN 0
        ELSE amountInTokens
    END) as amount
FROM
    Entity e
    INNER JOIN
    ETransfer t
    ON e.name = t.`from`
WHERE blocknumber < @blocknumber
GROUP BY e.name, t.token
HAVING price > 0; 

CREATE INDEX sale_name ON sale("name");
CREATE INDEX sale_token ON sale("token");
CREATE INDEX purchase_name ON purchase("name");
CREATE INDEX purchase_token ON purchase("token");
*/
CREATE TEMP TABLE Profitability AS
SELECT
    name,
    SUM(saleProfits) as profits,
    SUM(tokensLeft * price) as holdingValue,
    SUM(purchaseExpenses) as expenses,
    SUM(saleProfits + tokensLeft * price) / SUM(purchaseExpenses) as profitability
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
        ON p.name = s.name and p.token = +s.token) trades
    INNER JOIN
    Price
    ON 
        date = @day
        and
        Price.token = trades.token
GROUP BY name;

CREATE INDEX Profitability_name ON Profitability("name");

UPDATE EntityMetadata 
SET profitability = (SELECT Profitability.profitability FROM Profitability WHERE Profitability.name = EntityMetadata.name)
WHERE name <> "0x0000000000000000000000000000000000000002";