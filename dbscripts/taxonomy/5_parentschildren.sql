CREATE TEMP TABLE parents AS
SELECT 
    m.name, 
    parentT.type
FROM 
    EntityMetadata m
    INNER JOIN
    ETransfer t
    INNER JOIN
    (Entity parent
    NATURAL JOIN
    EntityTaxonomy parentT)
ON 
    m.name = t.`to` and 
    t.`from` = parent.name and
    parentT.blocknumber = @blocknumber and
    t.blocknumber <= @blocknumber
GROUP BY m.name, parentT.type
HAVING sum(amountInUSDCurrent) > 0.75 * involumeUSD;

CREATE TEMP TABLE children AS
SELECT 
    m.name, 
    childT.type
FROM 
    EntityMetadata m
    INNER JOIN
    ETransfer t
    INNER JOIN
    (Entity child
    NATURAL JOIN
    EntityTaxonomy childT)
ON 
    m.name = t.`from` and 
    t.`to` = child.name and
    childT.blocknumber = @blocknumber and
    t.blocknumber <= @ blocknumber
GROUP BY m.name, childT.type
HAVING sum(amountInUSDCurrent) > 0.75 * outvolumeUSD;

CREATE INDEX Children_name ON children("name");
CREATE INDEX Parents_name ON parents("name");

UPDATE EntityTaxonomy
SET children = (SELECT type FROM children WHERE children.name = EntityTaxonomy.name)
SET parents = (SELECT type FROM parents WHERE parents.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;

UPDATE EntityTaxonomy
SET children = 'none'
WHERE blocknumber = @blocknumber and name in (SELECT name from EntityMetadata where distinctOutDegree = 0);

UPDATE EntityTaxonomy
SET parents = 'mixed'
WHERE blocknumber = @blocknumber and parents is null;

UPDATE EntityTaxonomy
SET children = 'mixed'
WHERE blocknumber = @blocknumber and children is null;