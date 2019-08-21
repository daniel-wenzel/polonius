const db = require('../../insertIntoDB/util/db')
const fs = require('fs')

module.exports = (path) => {
    const statementFileRaw = fs.readFileSync('./'+path, {encoding: 'utf-8'})
    const statementFile = statementFileRaw.replace(/\/\*([\s\S]*?)\*\//, "")
    return db.transaction((args, method = 'run') => {
        const pathElements = path.split('/')
        const results = []
        console.log("Running "+pathElements[pathElements.length-1])
        // remove comments
        statementFile.split(';').forEach(statement => {
            if (statement.trim() == "") return
            const startTime = Date.now()
            console.log(statement.trim())
            if (args != undefined) {
                results.push(db.prepare(statement)[method](args))
            }
            else {
                results.push(db.prepare(statement)[method]())
            }
            const timeInSeconds = Math.round((Date.now() -startTime)/100)/10
            console.log(`Finished in ${timeInSeconds} seconds`)
        })
        if (results.length == 0) return undefined
        if (results.length == 1) return results[0]
        return results
    })
}