SELECT min(blocknumber) as minBlock, max(blocknumber) as maxBlock from Transfer where timestamp is null
