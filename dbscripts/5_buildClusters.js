const db = require('../insertIntoDB/util/db')
const requireSQL = require('./util/requireSQL')

const init = requireSQL('dbscripts/buildClusters/init.sql')
const addSenderAddresses = requireSQL('dbscripts/buildClusters/addSenderAddresses.sql')
const getNumberOfClusterMerges = requireSQL('dbscripts/buildClusters/getNumberOfClusterMerges.sql')
const mergeManyClusters = requireSQL('dbscripts/buildClusters/mergeManyClusters.sql')
const dropDuplicates = requireSQL('dbscripts/buildClusters/dropDuplicates.sql')
const getNumberOfClusterEntries = requireSQL('dbscripts/buildClusters/getNumberOfClusterEntries.sql')
const collapseToEntityGraph = requireSQL('dbscripts/buildClusters/collapseToEntityGraph.sql')


init()
performAllPossibleMerges()
let numberOfEntries = 0
addedEntries = undefined
do {
    addSenderAddresses()
    let newNumberOfEntries = Object.values(getNumberOfClusterEntries(undefined, 'get'))[0]
    addedEntries = newNumberOfEntries > numberOfEntries
    numberOfEntries = newNumberOfEntries

    console.log("add addresses (now "+numberOfEntries+")")
    performAllPossibleMerges()
}
while (addedEntries)

collapseToEntityGraph()


function performAllPossibleMerges() {
    let numberOfMerges = Object.values(getNumberOfClusterMerges(undefined, 'get'))[0]
    while (numberOfMerges > 0) {
        console.log(numberOfMerges+" merges left")
        mergeManyClusters()
        numberOfMerges = Object.values(getNumberOfClusterMerges(undefined, 'get'))[0]
    }
    dropDuplicates()
}