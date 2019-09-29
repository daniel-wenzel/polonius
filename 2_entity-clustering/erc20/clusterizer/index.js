const requireSQL = require('../../../util/requireSQL')

const init = requireSQL('2_entity-clustering/erc20/clusterizer/buildClusters/init.sql')
const addSenderAddresses = requireSQL('2_entity-clustering/erc20/clusterizer/buildClusters/addSenderAddresses.sql')
const getNumberOfClusterMerges = requireSQL('2_entity-clustering/erc20/clusterizer/buildClusters/getNumberOfClusterMerges.sql')
const mergeManyClusters = requireSQL('2_entity-clustering/erc20/clusterizer/buildClusters/mergeManyClusters.sql')
const dropDuplicates = requireSQL('2_entity-clustering/erc20/clusterizer/buildClusters/dropDuplicates.sql')
const getNumberOfClusterEntries = requireSQL('2_entity-clustering/erc20/clusterizer/buildClusters/getNumberOfClusterEntries.sql')
const collapseToEntityGraph = requireSQL('2_entity-clustering/erc20/clusterizer/buildClusters/collapseToEntityGraph.sql')


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