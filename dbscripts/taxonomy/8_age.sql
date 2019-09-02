UPDATE EntityTaxonomy
SET age = (
    SELECT CASE
        WHEN (@timestamp - MIN(IFNULL(firstInTransfer,firstOutTransfer), IFNULL(firstOutTransfer, firstInTransfer)))/60.0/60/24 < 7 THEN "week"
        WHEN (@timestamp - MIN(IFNULL(firstInTransfer,firstOutTransfer), IFNULL(firstOutTransfer, firstInTransfer)))/60.0/60/24 < 30 THEN "month"
        WHEN (@timestamp - MIN(IFNULL(firstInTransfer,firstOutTransfer), IFNULL(firstOutTransfer, firstInTransfer)))/60.0/60/24 < 90 THEN "quarter"
        WHEN (@timestamp - MIN(IFNULL(firstInTransfer,firstOutTransfer), IFNULL(firstOutTransfer, firstInTransfer)))/60.0/60/24 < 365 THEN "year"
        WHEN (@timestamp - MIN(IFNULL(firstInTransfer,firstOutTransfer), IFNULL(firstOutTransfer, firstInTransfer)))/60.0/60/24 >= 365 THEN "over1Year"
        ELSE 'unknown'
    END 
    FROM
        EntityMetadata
    WHERE EntityMetadata.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;