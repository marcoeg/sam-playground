# sam-playground
Playground for experimenting with SAM and Databricks.

![](hero.png)</br>
(source: OpenAI/DALL-E)

## Dataset
The Social Accounting Matrix for Ghana for 2015, estimated by European Commission, Joint Research Centre  (JRC) in 2021 is in the `./data` directory.

Source:
[https://data.jrc.ec.europa.eu/dataset/d7423648-90b8-403d-8518-ff2152f59820](https://data.jrc.ec.europa.eu/dataset/d7423648-90b8-403d-8518-ff2152f59820)

## Notebooks

### SAM Playground
The `SAM Playground` notebook provides a detailed workflow for performing shock analysis based on a Social Accounting Matrix (SAM). The process begins by defining the SAM matrix with adjusted values and zeros on the main diagonal, representing interactions between different sectors like Agriculture, Manufacturing, Services, Households, and Government. This matrix is then loaded into a Pandas DataFrame for initial visualization. To leverage the computational capabilities of Databricks, the SAM matrix is converted into a Spark DataFrame and transformed into a long format, similar to the melt function in Pandas. This transformation facilitates efficient data handling and manipulation within the Spark environment.

Next, the notebook proceeds with the normalization and regularization of the SAM to obtain the technical coefficients matrix and ensure numerical stability. The Leontief inverse of the normalized SAM is computed, accounting for potential singularities by using the Moore-Penrose pseudoinverse when necessary. The core of the analysis involves introducing a 10% increase in final demand for the Agriculture sector and calculating the impact on all sectors using the Leontief inverse. The resulting impact vector is then converted into a Spark DataFrame for visualization, highlighting how changes in one sector affect the entire economic system. This comprehensive workflow demonstrates the transformation of SAM data, matrix normalization, shock analysis, and the use of both Pandas and Spark DataFrames to analyze and visualize the economic impact.
### Impact analysis on Ghana economy based on the 2015 SAM.

The `Ghana SAM Analysis` notebook includes several key steps: importing necessary libraries such as pandas and numpy, loading the SAM data from a CSV file, and displaying the initial data. The notebook proceeds with extracting unique codes and names for spending agents, and then pivots the DataFrame to create a square matrix representing the transactions between agents. Missing values are filled with zeros to ensure matrix completeness. This matrix is then converted to a NumPy array and subsequently back to a Pandas DataFrame for further manipulation. The notebook also includes steps to convert the DataFrame into a Spark DataFrame, and normalize the SAM matrix by dividing each element by the sum of its column to facilitate further analysis. 

Finally, the notebook performs an impact analysis by normalizing and regularizing the SAM matrix, computing its inverse, and then applying an economic shock to assess the resulting impacts across sectors. The results are saved in the Databricks catalog for further analysis.

# Sample Code

`read_table.js`:
Javascript stand-alone script for fetching a table from the Databricks Unity Catalog.
```
 $ node read_table.js [catalog.schema.table] {ROWS}

 The number of rows is in the ROWS parameter. Default is 20.
```
Example:
```
% node read_table.js industry_solutions.esg_scoring.impact_ghana_df 10

{"level":"info","message":"Created DBSQLClient"}
{"level":"info","message":"DBSQLClient: initializing thrift client"}
Fetching table: industry_solutions.esg_scoring.impact_ghana_df
┌─────────┬──────────────────────────────────────────────────────────┬─────────────────────────┐
│ (index) │                          Sector                          │         Impact          │
├─────────┼──────────────────────────────────────────────────────────┼─────────────────────────┤
│    0    │      'Accommodation and food services (activities)'      │ -1.3032634174351846e-24 │
│    1    │ 'Accommodation and food services (marketed commodities)' │  1.80093859331498e-15   │
│    2    │      'Ashanti (Activities-Households as producers)'      │  -8.36079305289033e-25  │
│    3    │                 'Beverages (activities)'                 │  4.120889463427367e-24  │
│    4    │            'Beverages (marketed commodities)'            │  5.70146477795051e-16   │
│    5    │    'Brong Ahafo (Activities-Households as producers)'    │  2.219954974064285e-24  │
│    6    │             'Business services (activities)'             │ -8.690886282617265e-12  │
│    7    │        'Business services (marketed commodities)'        │   0.08690886282596183   │
│    8    │          'Capital - crops (Factors - Capital)'           │   -1.771939151097004    │
│    9    │        'Capital - livestock (Factors - Capital)'         │   10.685682757945461    │
└─────────┴──────────────────────────────────────────────────────────┴─────────────────────────┘
```
### Setup
```
$ npm i @databricks/sql
```

This script assumes that you have set the following environment variables:

`DATABRICKS_SERVER_HOSTNAME` set to the Server Hostname value for your cluster or SQL warehouse.

`DATABRICKS_HTTP_PATH` set to HTTP Path value for your cluster or SQL warehouse.

`DATABRICKS_TOKEN` set to the Databricks personal access token.

Connection details and token generation are in Databricks: `SQL Warehouses/[Warehouse]`

