UPDATE ETransfer
SET timestamp = null;

SELECT min(blocknumber) as minBlock, max(blocknumber) as maxBlock from ETransfer where timestamp is null