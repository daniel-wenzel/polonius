DROP TABLE IF EXISTS ActiveTokens;
CREATE TABLE ActiveTokens AS
SELECT token, e.blocknumber
FROM
    (SELECT distinct blocknumber FROM EntityTaxonomy) e
    INNER JOIN
    ETransfer t
    ON t.blocknumber <= e.blocknumber
GROUP BY token, e.blocknumber
HAVING count(distinct `to`) > 100;

CREATE INDEX ActiveTokens_token ON ActiveTokens("token");
CREATE INDEX ActiveTokens_blocknumber ON ActiveTokens("blocknumber");