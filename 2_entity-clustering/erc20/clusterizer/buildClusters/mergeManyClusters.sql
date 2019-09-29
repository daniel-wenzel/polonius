DROP TABLE IF EXISTS PendingMerges;
CREATE TEMP TABLE PendingMerges AS	
	SELECT
		MAX(a.clusterName, b.clusterName) as toBeReplaced, MIN(a.clusterName, b.clusterName) as newClusterName
	FROM 
		cluster a
		INNER JOIN
		cluster b
		ON a.member = b.member and a.clusterName is not b.clusterName;


CREATE INDEX PendingMerges_toBeReplaced ON PendingMerges("toBeReplaced");
CREATE INDEX PendingMerges_newClusterName ON PendingMerges("newClusterName");

UPDATE cluster
SET
	clusterName = (SELECT newClusterName FROM PendingMerges WHERE clusterName = toBeReplaced)
WHERE 
	clusterName in
		(SELECT 
			toBeReplaced
		FROM 
			PendingMerges p
		WHERE p.newClusterName not in (SELECT toBeReplaced FROM PendingMerges));

