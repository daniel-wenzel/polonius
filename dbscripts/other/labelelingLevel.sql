SELECT isFromCapp, isIntoDepositAddress, isIntraCapp, isEarlyTransfer, isVeryEarlyTransfer, count(*) as numTransfers, round(sum(amountInUSDCurrent) / 1000000) as volume
FROM Transfer
GROUP BY isFromCapp, isIntoDepositAddress, isIntraCapp, isEarlyTransfer, isVeryEarlyTransfer
ORDER BY sum(amountInUSDCurrent) DESC