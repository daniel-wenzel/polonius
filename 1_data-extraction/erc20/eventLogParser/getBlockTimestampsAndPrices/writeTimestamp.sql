UPDATE Transfer
SET timestamp = ROUND(@minTime + 1.0*(blocknumber - @minBlock) / (@maxBlock - @minBlock) * (@maxTime - @minTime))
WHERE blocknumber >= @minBlock and blocknumber < @maxBlock;