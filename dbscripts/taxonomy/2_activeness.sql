UPDATE EntityTaxonomy
SET activeness = (
    SELECT CASE
        WHEN involumeUSD - outvolumeUSD BETWEEN -0.05 and 0.05 THEN "empty"
        WHEN @maxDate - MAX(IFNULL(lastInTransfer,0), IFNULL(lastOutTransfer,0)) < 1000 * 60 * 60 * 24 THEN "daily"
        WHEN @maxDate - MAX(IFNULL(lastInTransfer,0), IFNULL(lastOutTransfer,0)) < 1000 * 60 * 60 * 24 * 7 THEN "weekly"
        WHEN @maxDate - MAX(IFNULL(lastInTransfer,0), IFNULL(lastOutTransfer,0)) < 1000 * 60 * 60 * 24 * 30 THEN "monthly"
        ELSE "inactive"
    END 
    FROM
        EntityMetadata
    WHERE EntityMetadata.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;