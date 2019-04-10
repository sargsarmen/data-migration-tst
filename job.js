const pool = require('./connection');

const isExist = async (query)=>{
    const result = await pool.query(query);

    return result.rows[0].count > 0;
}

const salesJob = async ()=>{
    while(await isExist(`SELECT COUNT(*) from temporary.temp_sale WHERE migration_status IS NULL;`) > 0){
        const query = `SELECT temporary.merge_sales(id) FROM temporary.temp_sale WHERE migration_status IS NULL ORDER BY id LIMIT 50000;`;
        await pool.query(query);
    }
}

const paymentsJob = async ()=>{
    while(await isExist(`SELECT COUNT(*) FROM temporary.temp_payment WHERE migration_status IS NULL;`) > 0){
        const query = `SELECT temporary.merge_payments(id) FROM temporary.temp_payment WHERE migration_status IS NULL ORDER BY id LIMIT 50000;`;
        await pool.query(query);
    }
}

const job = async ()=>{
    try{
        await Promise.all([salesJob(), paymentsJob()]);
        console.log("Job done"); 
        return true;
    }catch(error){
        console.log("Something went wrong"); 
        return false;
    }
};

module.exports = job;