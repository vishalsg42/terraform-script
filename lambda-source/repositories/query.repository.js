const pssql = require('../db/pssql');

class QueryRepo {
	get_sql_data(qry,data) {
		return new Promise(async (resolve, reject) => {
			try {
				let query = qry;
				for (var key in data) {
					let rx = new RegExp(`{${key}}`, 'gi');
                    query = query.replace(rx, data[key] || '');
                }
				const result = await pssql.execute(query, []);
				if (result.length > 0) {
                    return resolve(result[0]);
                }
                resolve(null);
			} catch (error) {
				reject(error);
			}
		});
	}

	create(qry,data) {
		return new Promise(async (resolve, reject) => {
			try {
				let query = qry;
				for (var key in data) {
					let rx = new RegExp(`{${key}}`, 'gi');
                    query = query.replace(rx, data[key] || '');
                }
				const result = await pssql.execute(query, []);
				if (result) {
                    return resolve(result);
                }
                resolve(null);
			} catch (error) {
				reject(error);
			}
		});
	}

	get_all_data(qry,data) {
		return new Promise(async (resolve, reject) => {
			try {
				let query = qry;
				for (var key in data) {
					let rx = new RegExp(`{${key}}`, 'gi');
                    query = query.replace(rx, data[key] || '');
                }
				const result = await pssql.execute(query, []);
				if (result.length > 0) {
                    return resolve(result);
                }
                resolve(null);
			} catch (error) {
				reject(error);
			}
		});
	}

	// run(qry,data) {
	// 	return new Promise(async (resolve, reject) => {
	// 		try {
	// 			let query = qry;
	// 			for (var key in data) {
	// 				let rx = new RegExp(`{${key}}`, 'gi');
    //                 query = query.replace(rx, data[key] || '');
    //             }
	// 			const result = await pssql.execute(query, []);
	// 			if (result.length > 0) {
    //                 return resolve(result[0]);
    //             }
    //             resolve(null);
	// 		} catch (error) {
	// 			reject(error);
	// 		}
	// 	});
	// }
}

module.exports = QueryRepo;
