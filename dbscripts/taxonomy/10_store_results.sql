/*DROP TABLE IF EXISTS TokenBalance;
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
*/
CREATE IF NOT EXISTS TABLE TaxonomyResults (
		"blocknumber" INTEGER NOT NULL, 
        "token" TEXT NOT NULL,
        "type" TEXT, NOT NULL,
		"operator" TEXT NOT NULL,
		"activeness" TEXT NOT NULL,
		"age" TEXT NOT NULL,
		"yield" TEXT NOT NULL,
		"parents" TEXT NOT NULL,
		"children" TEXT NOT NULL,
		"holdingSize" TEXT NOT NULL,
		"numberOfTokens" TEXT NOT NULL,
        "numAddresses" NUMERIC NOT NULL,
        "percEntities" NUMERIC NOT NULL,
        PRIMARY KEY("blocknumber", "token", "type", "operator", "activness", "age", "yield", "parents", "children", "holdingSize", "numberOfTokens")
);

CREATE INDEX IF NOT EXISTS TaxonomyResults_blocknumber ON TaxonomyResults("blocknumber");
CREATE INDEX IF NOT EXISTS TaxonomyResults_token ON TaxonomyResults("token");

REPLACE INTO TaxonomyResults
SELECT 
    blocknumber, token, type, operator, age, activeness, yield, parents, children, holdingSize, numberOfTokens, count(*) as numAddresses, sum(percentage) as percTokens
FROM
    EntityTaxonomy
    NATURAL JOIN
    TokenBalance
WHERE 
    percentage > 0 and
    blocknumber = @blocknumber
group by type, operator, age, activeness, yield, parents, children, holdingSize, numberOfTokens, token;
