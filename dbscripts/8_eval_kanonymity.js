require('log-timestamp');
const requireSQL = require('./util/requireSQL')
const db = require('../insertIntoDB/util/db')
const run = requireSQL('dbscripts/k-anonymity/run.sql')
const perDimensionInit = requireSQL('dbscripts/k-anonymity/perDimension.sql')
let sinceLastSave = 0
//run() // this takes quite a while

const dimensions = 
    ["token", 
    "type", 
    "activeness", 
    "age", 
    "yield", 
    "children", 
    "parents", 
    "holdingSize", 
    "numberOfTokens", 
    "operator"
]

const fs = require('fs')
if (!fs.existsSync('./data/k-anonymity-combinations.json')) {
    console.log("init!")
    init()
}
const combinations = require('../data/k-anonymity-combinations.json')
if (Object.values(combinations).some(c => Object.entries(c).length == 0)) {
    perDimensionInit()
    Object.keys(combinations).filter(d => Object.entries(combinations[d]).length == 0).forEach(dimensions => {
        const ans = db.prepare(`
            SELECT 
                k, sum(k) as numMatches
            FROM
                (SELECT 
                    count(*) as k
                FROM
                kAnonPerDimension
                GROUP BY ${dimensions}) as exchangeUnique
            WHERE k <= 100
            GROUP BY k
            ORDER BY k
        `).all()
        const save = {
            k1:0,
            k20:0,
            k100:0
        }
        for ({k, numMatches} of ans) {
            if (k == 1) save.k1 += numMatches
            if (k <= 20) save.k20 += numMatches
            if (k <= 100) save.k100 += numMatches
        }
        combinations[dimensions] = save
        saveIfNeeded()
    })
}
saveIfNeeded(true)

function init() {
    const combinations = [[]]

    dimensions.forEach(d => {
        combinations.forEach(c => {
            combinations.push(c.concat(d))
        })
    })
    combinations.splice(0,1) // remove empty group by at the start
    const nCombinations = combinations.map(normalizeCombination)
    const map = {}
    nCombinations.forEach(c => map[c] = {})
    fs.writeFileSync('./data/k-anonymity-combinations.json', JSON.stringify(map, 0, 2))

    console.log("save")
}

function normalizeCombination(combination) {
    return combination.sort().join(', ')
}
function saveIfNeeded(force=false) {
    sinceLastSave ++
    if (force || sinceLastSave > 50) {
        fs.writeFileSync('./data/k-anonymity-combinations.json', JSON.stringify(combinations, 0, 2))
        sinceLastSave = 0
        console.log("saved")
    }
}

function calcPermutations(array) {
    const combinations = [[]]

    array.forEach(d => {
        combinations.forEach(c => {
            combinations.push(c.concat(d))
        })
    })
    combinations.splice(0,1) // remove empty group by at the start
    return combinations
}

const allResults = {}
for (dimension of dimensions) {
    const otherDimensions = dimensions.filter(d => d != dimension)
    const permutations = calcPermutations(otherDimensions)
    const nPermutations = permutations.map(p => numOptions(p.length, otherDimensions.length))
    const normalizedPermuatations = permutations.map(normalizeCombination)
    const valuesWithoutDimensions = normalizedPermuatations.map(p => combinations[p]).reduce((acc, c, i) => {
        return {
            k1: acc.k1 + c.k1 * nPermutations[i],
            k20: acc.k20 + c.k20 * nPermutations[i],
            k100: acc.k100 + c.k100 * nPermutations[i]
        }
    }, {k1:0, k20:0, k100:0})

    const normalizedPersWithD = permutations.map(p => p.concat([dimension])).map(normalizeCombination)
    const valuesWithDimensions = normalizedPersWithD.map(p => combinations[p]).reduce((acc, c, i) => {
        return {
            k1: acc.k1 + c.k1 * nPermutations[i],
            k20: acc.k20 + c.k20 * nPermutations[i],
            k100: acc.k100 + c.k100 * nPermutations[i]
        }
    }, {k1:0, k20:0, k100:0})
    const numPermutations = nPermutations.reduce((a,b) => a+b)
    console.log(numPermutations)
    const results = {
        k1: (valuesWithDimensions.k1 - valuesWithoutDimensions.k1) / numPermutations,
        k20: (valuesWithDimensions.k20 - valuesWithoutDimensions.k20) / numPermutations,
        k100: (valuesWithDimensions.k100 - valuesWithoutDimensions.k100) / numPermutations
    }
    allResults[dimension] = results
}

const sums = Object.values(allResults).reduce((a,b) => ({
    k1: a.k1 + b.k1,
    k20: a.k20 + b.k20,
    k100: a.k100 + b.k100
}))

const numEntries = 5518590
Object.values(allResults).forEach(r => {
    r.k1_p = Math.floor(r.k1 / sums.k1 * 100000) / 1000 + "%",
    r.k20_p = Math.floor(r.k20 / sums.k20 * 100000) / 1000+ "%",
    r.k100_p = Math.floor(r.k100 / sums.k100 * 100000) / 1000+ "%"
})
Object.keys(allResults).forEach(k => allResults[k].name = k)
const vals = Object.values(allResults)
vals.sort((x, y) => x.k1 - y.k1)
console.log(vals.map(v => [v.name, v.k1_p, v.k20_p, v.k100_p].join(', ')).join('\n'))

function numOptions(placedDimensions, allDimensions) {
    const unplacedDimensions = allDimensions - placedDimensions
    return fact(placedDimensions) * fact(unplacedDimensions)
}


function fact(n) {
    return n < 1? 1: n * fact(n-1)
}