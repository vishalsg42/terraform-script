const QueryRepo = require("../../repositories/query.repository");

class PsSqlBiz {
    constructor() {
      this.queryRepo = new QueryRepo();
    }
    get(data, queries) {
      return new Promise(async (resolve, reject) => {
        try {
          var result = {};
          let promises = [];
          for (var query of queries) {
            let raw = this.queryRepo.get_sql_data(query, data);
            promises.push(raw);
          }
  
          promises = await Promise.all(promises);
          for (const promise of promises) {
            result = {
              ...result,
              ...promise
            }
          }
  
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
    }
  
    select(data, queries) {
      return new Promise(async (resolve, reject) => {
        try {
          var result = [];
          for (var query of queries) {
            let raw = await this.queryRepo.get_all_data(query, data);
            result = {
              ...result,
              ...raw
            }
          }
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
    }
  
    get_one(data, query) {
      return new Promise(async (resolve, reject) => {
        try {
          let raw = await this.queryRepo.get_all_data(query, data);
          let result = raw
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
    }
  
    insert(query, data) {
      return new Promise(async (resolve, reject) => {
        try {
          let result = await this.queryRepo.create(query, data);
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
    }
  
    update(query, data) {
      return new Promise(async (resolve, reject) => {
        try {
          let result = await this.queryRepo.create(query, data);
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
    }
  
    updateAll(queries, data) {
      return new Promise(async (resolve, reject) => {
        try {
          let promises = [];
          for (var query of queries) {
            let raw = this.queryRepo.create(query, data);
            promises.push(raw);
          }
          let result = await Promise.all(promises);
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
    }
  
  }
  
  module.exports = PsSqlBiz;