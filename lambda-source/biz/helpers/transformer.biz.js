const JsonTransformer = require('../../helpers/jsonTransformer');
class TransformerBiz {

	transform(data,template) {
		return new Promise(async (resolve, reject) => {	
			try {
				//replace string values
				for (var key in data) {
                    template = template.replace(`{@${key}}`, data[key]);
                }
				//call raw parser call
				const transformed_message = await new JsonTransformer(template).transform(data);
				resolve(transformed_message);
			} catch (error) {
				reject(error);
			}
		});
	}
}

module.exports = TransformerBiz;