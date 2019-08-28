UPDATE EntityTaxonomy
SET holdingSize = (
    SELECT CASE
        WHEN involumeUSD_adjusted - outvolumeUSD_adjusted < -0.1 THEN "origin"
        WHEN involumeUSD_adjusted - outvolumeUSD_adjusted < 0.01 THEN "empty"
        WHEN involumeUSD_adjusted - outvolumeUSD_adjusted < 1 THEN "under_1USD"
        WHEN involumeUSD_adjusted - outvolumeUSD_adjusted < 10 THEN "under_10USD"
        WHEN involumeUSD_adjusted - outvolumeUSD_adjusted < 100 THEN "under_100USD"
        WHEN involumeUSD_adjusted - outvolumeUSD_adjusted < 1000 THEN "under_1kUSD"
        WHEN involumeUSD_adjusted - outvolumeUSD_adjusted < 10000 THEN "under_10kUSD"
        WHEN involumeUSD_adjusted - outvolumeUSD_adjusted < 1000000 THEN "under_1kkUSD"
        ELSE "over_1kkUSD"
    END 
    FROM
        EntityMetadata
    WHERE EntityMetadata.name = EntityTaxonomy.name)
WHERE blocknumber = @blocknumber;