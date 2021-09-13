const utility_functions = require('../helpers/utitlity');
const ST = require('stjs');
class JsonTransformer{
    constructor(template){
        this.template = template;
    }

    async transform(raw){
        return new Promise(async (resolve, reject) => {	
			try {
                    let parsed_message = {};
                    parsed_message = ST.select(raw)
                    .inject(utility_functions)
                    .transformWith(JSON.parse(this.template))
                    .root();
                    resolve(parsed_message);
            } catch (error) {
                    reject(error);
            }
        });
    }
}


module.exports = JsonTransformer;