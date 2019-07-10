WITH clusterUpdate AS
	(SELECT
		MAX(a.clusterName, b.clusterName) as toBeReplaced, MIN(a.clusterName, b.clusterName) as replacing
	FROM 
		cluster a
		INNER JOIN
		cluster b
		ON a.member = b.member and a.clusterName is not b.clusterName
		LIMIT 1)
UPDATE cluster SET clusterName = (SELECT replacing FROM clusterUpdate)
WHERE cluster.clusterName in (SELECT toBeReplaced FROM clusterUpdate) 