CREATE TABLE "EntityTaxonomy" (
        "name" TEXT NOT NULL UNIQUE,
        "type" TEXT,
        PRIMARY KEY("name")
    );

/* ITER 1 */
INSERT INTO EntityTaxonomy
SELECT 
	name, 
	CASE
		WHEN distinctInDegree / (0.0 + distinctInDegree + distinctOutDegree) >  0.9 THEN "concentrator"
		WHEN distinctOutDegree / (0.0 + distinctInDegree + distinctOutDegree) >  0.9 THEN "dilluter"
		ELSE "mixer"
	END
FROM EntityMetadata
WHERE distinctDegree >= 100;
/* ITER 2 */
INSERT INTO EntityTaxonomy
SELECT 
	name, 
	CASE
		WHEN distinctInDegree = 0 and distinctOutDegree > 0 THEN "source"
		WHEN distinctInDegree = 1 and distinctOutDegree = 0 THEN "sink_simple"
		WHEN distinctInDegree > 1 and distinctOutDegree = 0 THEN "sink_complex"
		WHEN distinctInDegree = 1 and distinctOutDegree = 1 THEN "connector_simple"
		WHEN distinctInDegree >= 1 and distinctOutDegree >= 1 THEN "connector_complex"
		ELSE "n/a"
	END
FROM EntityMetadata
WHERE distinctDegree < 100;
/* ITER 3 */
