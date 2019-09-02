/* Here we are calculating the balance of each entity in tokens for later analysis */
CREATE TABLE TokenBalance AS
SELECT 
    p.name, p.token, 
    CASE 
        WHEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0) > 0 THEN p.amount_unadjusted - IFNULL(s.amount_unadjusted, 0)
        ELSE 0
    END as balance,
    null as percentage
FROM
    Purchase p
    LEFT OUTER JOIN
    Sale s
    ON p.name = s.name and p.token = +s.token
WHERE 
    p.token in (SELECT id FROM Token WHERE highMarketCap = 1) and
    p.amount_unadjusted >= IFNULL(s.amount_unadjusted, 0);

CREATE INDEX TokBal_name ON TokenBalance("name");
CREATE INDEX TokBal_token ON TokenBalance("token");
    
UPDATE TokenBalance
SET percentage = 1.0*balance / (SELECT sum(balance) FROM tokenBalance b WHERE b.token = TokenBalance.token);

INSERT INTO TokenBalance
SELECT 
    name,
    "ALL_ADJUSTED",
    sum(percentage) / (SELECT count(distinct token) from TokenBalance inner join token ON TokenBalance.token = token.id where token.excludeFromAdjustedVolumes = 0)
FROM
    TokenBalance
WHERE token not in (SELECT id FROM Token WHERE excludeFromAdjustedVolumes = 0)
GROUP BY name