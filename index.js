const { getCursorShape, cleanup } = require('bindings')('cursor.node');

module.exports = {
    getCursorShape,
    cleanup
};