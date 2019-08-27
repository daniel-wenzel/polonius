INSERT INTO EntityTaxonomy
SELECT 
	name, 
    @blocknumber,
	CASE
		WHEN distinctInDegree = 0 and distinctOutDegree > 0 THEN "source"
		WHEN distinctInDegree = 1 and distinctOutDegree = 0 THEN "sink_simple"
		WHEN distinctInDegree > 1 and distinctOutDegree = 0 THEN "sink_complex"
		WHEN distinctInDegree = 1 and distinctOutDegree = 1 THEN "connector_simple"
		WHEN distinctInDegree >= 1 and distinctOutDegree >= 1 THEN "connector_complex"
		ELSE "n/a"
	END as type
FROM EntityMetadata
WHERE distinctDegree < 100;

INSERT INTO EntityTaxonomy
SELECT 
	name, 
    @blocknumber,
	CASE
		WHEN distinctInDegree / (0.0 + distinctInDegree + distinctOutDegree) >  0.9 THEN "concentrator"
		WHEN distinctOutDegree / (0.0 + distinctInDegree + distinctOutDegree) >  0.9 THEN "dilluter"
		ELSE "mixer"
	END
FROM EntityMetadata
WHERE distinctDegree >= 100;

/* This means we know in advance if an address will be an ICO */
UPDATE EntityTaxonomy
SET type = 'ico'
WHERE EntityTaxonomy.name in
    (SELECT DISTINCT Address.cluster
    FROM
        (ICOAddress 
        NATURAL JOIN 
        Address));

/* This means we know in advance if an address will be an ICO */
UPDATE EntityTaxonomy
SET type = 'exchange'
WHERE EntityTaxonomy.name in
    (SELECT name
    FROM
        Entity WHERE isExchange = 1);
