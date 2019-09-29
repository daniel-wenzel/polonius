module.exports = ($, selector) => {
    const hits = []
    $(selector).each((i,e) => hits.push($(e).text()))
    return hits
}