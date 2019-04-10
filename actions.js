const pool = require('./connection');
const CronJob = require('cron').CronJob;
const job = require('./job');

const schedule = new CronJob('60 * * * * *', job, null, true);

const getStatistics = async (request, response) => {
    const query = `Select (Select Count(*) from temporary.temp_payment Where migration_status = 'inserted') as "InsertedCount",
                (Select Count(*) from temporary.temp_payment Where migration_status = 'updated') as "UpdatedCount",
                (Select Count(*) from temporary.temp_payment Where migration_status = 'error') as "ErrorsCount"`;
    try{
        const results = await pool.query(query);
        response.status(200).json(results.rows[0]);
    }
    catch(error){
        console.log(error);
        response.status(500).json(error.message);   
    }
}

const runJob = async (request, response) => {
    schedule.stop();

    const isSuccess = await job();

    schedule.start();

    response.status(200).json({isSuccess});
}

module.exports = {
    getStatistics,
    runJob
}