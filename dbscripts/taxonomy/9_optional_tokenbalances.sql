/* Here we are calculating the balance of each entity in tokens for later analysis */
DROP TABLE IF EXISTS TokenBalance;
DROP TABLE IF EXISTS BalanceSums;

CREATE TEMP Table BalanceSums AS
SELECT 
    p.token, 
    SUM(CASE 
        WHEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0) > 0 THEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0)
        ELSE 0
    END) as totalBalance
FROM
    Purchase p
    LEFT OUTER JOIN
    Sale s
    ON p.name = s.name and p.token = +s.token
WHERE 
    p.amount_unadjusted >= IFNULL(s.amount_unadjusted, 0)
GROUP BY p.token;

CREATE TABLE TokenBalance AS
SELECT
    x.name,
    x.token,
    x.balance,
    x.balance * 1.0 / totalBalance as percentage
FROM
    (SELECT 
        p.name, p.token, 
        CASE 
            WHEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0) > 0 THEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0)
            ELSE 0
        END as balance
    FROM
        Purchase p
        LEFT OUTER JOIN
        Sale s
        ON p.name = s.name and p.token = +s.token
    WHERE 
        /*p.token in (SELECT id FROM Token WHERE highMarketCap = 1) and*/
        p.amount_unadjusted >= IFNULL(s.amount_unadjusted, 0)) x
    NATURAL JOIN
    BalanceSums;

CREATE INDEX TokBal_name ON TokenBalance("name");
CREATE INDEX TokBal_token ON TokenBalance("token");

INSERT INTO TokenBalance
SELECT 
    name,
    "ALL_ADJUSTED",
    null,
    sum(percentage) / (SELECT count(distinct token) from TokenBalance inner join token ON TokenBalance.token = token.id where token.excludeFromAdjustedVolumes = 0)
FROM
    TokenBalance
WHERE token not in (SELECT id FROM Token WHERE excludeFromAdjustedVolumes = 1)
GROUP BY name;

INSERT INTO TokenBalance
SELECT 
    name,
    "HIGH_CAP",
    null,
    sum(percentage) / (SELECT count(distinct token) from TokenBalance inner join token ON TokenBalance.token = token.id where token.highMarketCap = 1)
FROM
    TokenBalance
WHERE token in (SELECT id FROM Token WHERE highMarketCap = 1)
GROUP BY name;