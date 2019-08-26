UPDATE ETransfer
SET timestamp = @minTime + (blocknumber - @minBlock) / (@maxBlock - @minBlock) * (@maxTime - @minTime)
WHERE blocknumber >= @minBlock and blocknumber < @maxBlock;