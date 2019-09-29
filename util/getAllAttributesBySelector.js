module.exports = ($, selector, attribute) => {
    const hits = []
    $(selector).each((i,e) => hits.push($(e).attr(attribute)))
    return hits
}