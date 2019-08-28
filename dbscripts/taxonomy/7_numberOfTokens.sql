/*CREATE TABLE inUsed AS
SELECT `from` as name,count(distinct token) as cnt FROM ETransfer
WHERE blocknumber <= @blocknumber
GROUP BY `from`;

CREATE TABLE outUsed AS
SELECT `to` as name,count(distinct token) as cnt FROM ETransfer
WHERE blocknumber <= @blocknumber
GROUP BY `to`;

CREATE INDEX inUsed_name ON inUsed("name");
CREATE INDEX outUsed_name ON outUsed("name");
 
UPDATE inUsed
SET cnt = MAX(cnt, (SELECT cnt from outUsed where outUsed.name = inUsed.name))
WHERE name in (SELECT name FROM outUsed);

INSERT INTO inUsed
SELECT * FROM outUsed where outUsed.name not in (SELECT name FROM inUsed);
*/
UPDATE EntityTaxonomy
SET numberOfTokens = (
    SELECT CASE
        WHEN cnt is null THEN "ERR"
        WHEN cnt = 1 THEN "1"
        WHEN cnt < 3 THEN "2"
        WHEN cnt < 7 THEN "3-6"
        WHEN cnt <= 30 THEN "6-30"
        ELSE ">30"
    END 
    FROM
        inUsed
    WHERE inUsed.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;

UPDATE EntityTaxonomy
SET numberOfTokens = "NONE"
WHERE blocknumber = @blocknumber and numberOfTokens is null;

