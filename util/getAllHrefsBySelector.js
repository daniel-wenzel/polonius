module.exports = ($, selector) => {
    const hits = []
    $(selector).each((i,e) => hits.push($(e).attr('href')))
    return hits
}