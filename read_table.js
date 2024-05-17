/*
    Databricks table query example.

    $ node read_table.js [catalog.schema.table] {ROWS}

    Ex. $ node read_table.js industry_solutions.esg_scoring.impact_ghana_df

    The number of rows is in the ROWS parameter. Default is 20.

    Ref: https://docs.databricks.com/en/dev-tools/nodejs-sql-driver.html
*/

const { DBSQLClient } = require('@databricks/sql');

const serverHostname = process.env.DATABRICKS_SERVER_HOSTNAME;
const httpPath       = process.env.DATABRICKS_HTTP_PATH;
const token          = process.env.DATABRICKS_TOKEN;

const arguments = process.argv;
if ((arguments.length) < 3) {
    console.log("ERROR: A table name argument in the form [catalog.schema.table] is required.");
    console.log("Exiting ...");
    process.exit();
}
const table_name = arguments[2];

var limit = 20;
if (arguments.length > 3) {
    limit = arguments[3];
}
if (!token || !serverHostname || !httpPath) {
  throw new Error("Cannot find Server Hostname, HTTP Path, or personal access token. ");
}

const client = new DBSQLClient();
const connectOptions = {
  token: token,
  host: serverHostname,
  path: httpPath
};

client.connect(connectOptions)
  .then(async client => {
    const session = await client.openSession();
    console.log("Fetching table:",table_name)
    const query = `SELECT * FROM ${table_name} LIMIT ${limit}`;
    const queryOperation = await session.executeStatement(query, {
        runAsync: true,
        maxRows: 10000 // This option enables the direct results feature.
    });

    const result = await queryOperation.fetchAll();
    await queryOperation.close();

    console.table(result);

    await session.close();
    await client.close();
})
.catch((error) => {
    console.error(error.response.displayMessage);
});
