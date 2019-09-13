require('log-timestamp');
const requireSQL = require('./util/requireSQL')
const db = require('../insertIntoDB/util/db')
const run = requireSQL('dbscripts/k-anonymity/run.sql')
const perDimensionInit = requireSQL('dbscripts/k-anonymity/perDimension.sql')
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
            WHERE k = 1 OR k = 20 OR k = 100
            GROUP BY k
            ORDER BY k
        `).all()
        combinations[dimensions] = ans
        saveIfNeeded(true)
    })
}

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
let sinceLastSave = 0
function saveIfNeeded(force=false) {
    sinceLastSave ++
    if (force || sinceLastSave > 50) {
        fs.writeFileSync('./data/k-anonymity-combinations.json', JSON.stringify(combinations, 0, 2))
        sinceLastSave = 0
        console.log("saved")
    }
}