const _ = require("lodash");

module.exports = {
    clean: (root, data) => {
        try {
            return _.get(root, data, null);
        } catch (err) {
            return null;
        }

    }
}