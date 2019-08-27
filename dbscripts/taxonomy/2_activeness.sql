UPDATE EntityTaxonomy
SET activeness = (
    SELECT CASE
        WHEN involumeUSD - outvolumeUSD BETWEEN -0.05 and 0.05 THEN "empty"
        WHEN @maxDate - MAX(lastInTransfer, lastOutTransfer) < 1000 * 60 * 60 * 24 THEN "daily"
        WHEN @maxDate - MAX(lastInTransfer, lastOutTransfer) < 1000 * 60 * 60 * 24 * 7 THEN "weekly"
        WHEN @maxDate - MAX(lastInTransfer, lastOutTransfer) < 1000 * 60 * 60 * 24 * 30 THEN "monthly"
        ELSE "inactive"
    FROM
        EntityMetadata
    WHERE EntityMetadata.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;