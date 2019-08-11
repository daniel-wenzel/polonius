#wget --no-check-certificate --content-disposition "https://tubcloud.tu-berlin.de/s/LMfkic6MKZqWF72/download"

tar xvfO transfers.tar.gz tokenTransfers.csv | gzip > tokenTransfers.csv.gz
tar xvfO transfers.tar.gz tokenCreations.csv | gzip > tokenCreations.csv.gz
tar xvfO transfers.tar.gz erc20contractStats.csv | gzip > erc20contractStats.csv.gz


