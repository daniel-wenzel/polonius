UPDATE ETransfer
SET timestamp = (CAST (ROUND(@minTime + 1.0*(blocknumber - @minBlock) / (@maxBlock - @minBlock) * (@maxTime - @minTime))) as int)
WHERE blocknumber >= @minBlock and blocknumber < @maxBlock;