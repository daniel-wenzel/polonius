UPDATE EntityTaxonomy
SET activeness = (
    SELECT CASE
        WHEN involumeUSD - outvolumeUSD BETWEEN -0.05 and 0.05 THEN "empty"
        WHEN @timestamp - MAX(IFNULL(lastInTransfer,0), IFNULL(lastOutTransfer,0)) < 60 * 60 * 24 THEN "daily"
        WHEN @timestamp - MAX(IFNULL(lastInTransfer,0), IFNULL(lastOutTransfer,0)) < 60 * 60 * 24 * 7 THEN "weekly"
        WHEN @timestamp - MAX(IFNULL(lastInTransfer,0), IFNULL(lastOutTransfer,0)) < 60 * 60 * 24 * 30 THEN "monthly"
        ELSE "inactive"
    END 
    FROM
        EntityMetadata
    WHERE EntityMetadata.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;