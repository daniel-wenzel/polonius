const fs = require('fs');
const zlib     = require('zlib');
module.exports = (filePath) => {
    const output = fs.createWriteStream(filePath);
    const compress = zlib.createGzip()
    /* The following line will pipe everything written into compress to the file stream */
    compress.pipe(output);
    return compress
}
