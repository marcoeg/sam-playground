#!/bin/bash

# This script submits a job to Databricks using the Databricks Jobs API and polls for its completion status.
# It takes three command line arguments: SAM_Table, IA_Index, and IA_Value, which are used as parameters for the job.
# The script starts by checking if the correct number of arguments is provided. If not, it prints a usage message and exits.
# Next, it assigns the provided arguments to the corresponding variables (SAM_Table, IA_Index, IA_Value).
# It then loads environment variables from a .env file using the export command and grep to filter out comments.
#
# The script constructs a JSON payload with the job parameters and submits the job using a POST request with curl.
# The response from the job submission is parsed to extract the run_id, which is used to poll the job status.
# A while loop is used to continuously check the job status every 10 seconds until the job reaches a terminal state
# (TERMINATED, SKIPPED, or INTERNAL_ERROR). The final job status is printed to the console.

# Example:
# $ ./submit_job.sh ita2020_matrix 7 0.075

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 SAM_Table IA_Index IA_Value"
  exit 1
fi

# Assign command line arguments to variables
SAM_Table=$1
IA_Index=$2
IA_Value=$3

# Print the values to verify
echo "SAM_Table: $SAM_Table"
echo "IA_Index: $IA_Index"
echo "IA_Value: $IA_Value"

# grab the enviromental variables from .env
export $(grep -v '^#' ../.env | sed 's/^export //g' | xargs)

# Execute a notebook using curl. 
#
# curl -X POST https://$DATABRICKS_SERVER_HOSTNAME/api/2.0/jobs/run-now \
#  -H "Authorization: Bearer $DATABRICKS_TOKEN" \
#  -H "Content-Type: application/json" \
#  -d '{
#    "job_id": 289803488124851,
#    "notebook_params": {
#     "SAM_Table": "ita2020_matrix",
#      "IA_Index": "1",
#      "IA_Value": "0.5"
#    }
# }
 
response=$(curl -s -X POST https://$DATABRICKS_SERVER_HOSTNAME/api/2.0/jobs/run-now \
  -H "Authorization: Bearer $DATABRICKS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": 289803488124851,
    "notebook_params": {
      "SAM_Table": "'"${SAM_Table}"'",
      "IA_Index": "'"${IA_Index}"'",
      "IA_Value": "'"${IA_Value}"'"
    }
  }')

run_id=$(echo $response | jq -r '.run_id')

# Check if run_id is retrieved correctly
if [[ -z "$run_id" || "$run_id" == "null" ]]; then
  echo "Failed to retrieve run_id. Response: $response"
  exit 1
fi

echo "Job submitted with run_id: $run_id"

# Poll the job status until completion
while true; do
  status_response=$(curl -s -X GET "https://$DATABRICKS_SERVER_HOSTNAME/api/2.0/jobs/runs/get?run_id=$run_id" \
    -H "Authorization: Bearer $DATABRICKS_TOKEN" \
    -H "Content-Type: application/json")

  # Print the full response for debugging
  #echo "Status response: $status_response"

  state=$(echo $status_response | jq -r '.state.life_cycle_state')

  echo "Job status: $state"

  if [[ "$state" == "TERMINATED" || "$state" == "SKIPPED" || "$state" == "INTERNAL_ERROR" ]]; then
    break
  fi

  sleep 10  # Wait for 10 seconds before polling again
done

# Print final job status
echo $status_response | jq .
final_status=$(echo $status_response | jq -r '.state.result_state')
echo "\nFinal job status: $final_status"