#!/bin/sh

response=$(curl -X POST https://$DATABRICKS_SERVER_HOSTNAME/api/2.0/jobs/run-now \
  -H "Authorization: Bearer $DATABRICKS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "job_id": 289803488124851,
    "notebook_params": {
      "SAM_Table": "ita2020_matrix",
      "IA_Index": "1",
      "IA_Value": "0.3"
    }
  }')

run_id=$(echo $response | jq -r '.run_id')
echo "run id: "$run_id