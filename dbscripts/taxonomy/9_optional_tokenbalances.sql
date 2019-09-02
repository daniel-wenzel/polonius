/* Here we are calculating the balance of each entity in tokens for later analysis */
DROP TABLE IF EXISTS TokenBalance;

CREATE TEMP Table BalanceSums AS
SELECT 
    p.token, 
    SUM(CASE 
        WHEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0) > 0 THEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0)
        ELSE 0
    END) as totalBalance,
FROM
    Purchase p
    LEFT OUTER JOIN
    Sale s
    ON p.name = s.name and p.token = +s.token
WHERE 
    p.amount_unadjusted >= IFNULL(s.amount_unadjusted, 0);
GROUP BY token;

CREATE TABLE TokenBalance AS
SELECT 
    p.name, p.token, 
    CASE 
        WHEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0) > 0 THEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0)
        ELSE 0
    END as balance,
    1.0*CASE 
        WHEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0) > 0 THEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0)
        ELSE 0
    END / (SELECT totalBalance FROM BalanceSums WHERE BalanceSums.token = p.token) as percentage
FROM
    Purchase p
    LEFT OUTER JOIN
    Sale s
    ON p.name = s.name and p.token = +s.token
WHERE 
    /*p.token in (SELECT id FROM Token WHERE highMarketCap = 1) and*/
    p.amount_unadjusted >= IFNULL(s.amount_unadjusted, 0);

CREATE INDEX TokBal_name ON TokenBalance("name");
CREATE INDEX TokBal_token ON TokenBalance("token");
    


/*UPDATE TokenBalance
SET percentage = 1.0*balance / (SELECT totalBalance FROM BalanceSums b WHERE b.token = TokenBalance.token);
*/
INSERT INTO TokenBalance
SELECT 
    name,
    "ALL_ADJUSTED",
    null,
    sum(percentage) / (SELECT count(distinct token) from TokenBalance inner join token ON TokenBalance.token = token.id where token.excludeFromAdjustedVolumes = 0)
FROM
    TokenBalance
WHERE token not in (SELECT id FROM Token WHERE excludeFromAdjustedVolumes = 1)
GROUP BY name