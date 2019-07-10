DELETE FROM cluster
WHERE rowid NOT IN (
  SELECT MIN(rowid) 
  FROM cluster 
  GROUP BY clusterName, member
);