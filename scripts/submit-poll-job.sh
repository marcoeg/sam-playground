#!/bin/sh
export $(grep -v '^#' ../.env | sed 's/^export //g' | xargs)

response=$(curl -s -X POST https://$DATABRICKS_SERVER_HOSTNAME/api/2.0/jobs/run-now \
  -H "Authorization: Bearer $DATABRICKS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": 289803488124851,
    "notebook_params": {
      "SAM_Table": "ita2020_matrix",
      "IA_Index": "7",
      "IA_Value": "0.075"
    }
  }')

run_id=$(echo $response | jq -r '.run_id')


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