# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

node prepareData/getBlockTimestampsAndPrices
node prepareData/getBlockTimestampsAndPrices/insertPrices
#node prepareData/transfers/parseIndividualTokens

#node insertIntoDB
#node dbscripts/index.js
