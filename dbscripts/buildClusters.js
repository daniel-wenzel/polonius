const db = require('../insertIntoDB/util/db')
const requireSQL = require('./util/requireSQL')

const init = requireSQL('dbscripts/buildClusters/init.sql')
const addSenderAddresses = requireSQL('dbscripts/buildClusters/addSenderAddresses.sql')
const getNumberOfClusterMerges = requireSQL('dbscripts/buildClusters/getNumberOfClusterMerges.sql')
const mergeTwoClusters = requireSQL('dbscripts/buildClusters/mergeTwoClusters.sql')
const dropDuplicates = requireSQL('dbscripts/buildClusters/dropDuplicates.sql')
const getNumberOfClusterEntries = requireSQL('dbscripts/buildClusters/getNumberOfClusterEntries.sql')


init()
let numberOfEntries = 0
addedEntries = undefined
do {
    addSenderAddresses()
    let newNumberOfEntries = Object.values(getNumberOfClusterEntries(undefined, 'get'))[0]
    addedEntries = newNumberOfEntries > numberOfEntries
    numberOfEntries = newNumberOfEntries

    console.log("add addresses (now "+numberOfEntries+")")
    const numberOfMerges = Object.values(getNumberOfClusterMerges(undefined, 'get'))[0]
    console.log("merge addresses ("+numberOfMerges+" times)")
    for (let j=0; j<numberOfMerges; j++) {
        console.log(j)
        mergeTwoClusters()
    }
    dropDuplicates()
}
while (addedEntries)