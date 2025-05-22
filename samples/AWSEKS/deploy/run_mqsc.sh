#!/bin/bash

MQ_USER="admin"
MQ_PASS="${1}"
MQ_URL="https://aab06742b96ed4cb1802e38033ee4e93-516874369.us-east-1.elb.amazonaws.com:9443/ibmmq/rest/v2/admin/action/qmgr/secureapphelm/mqsc"
ERROR_LOG="mqsc_errors.log"

echo "My dir"
pwd


# Clear previous log
> "$ERROR_LOG"

while IFS= read -r line || [[ -n "$line" ]]; do
  # Escape single quotes for MQSC syntax
  escaped_command="$line"


  payload=$(jq -n --arg cmd "$escaped_command" '{
    type: "runCommand",
    parameters: {
      command: $cmd
    }
  }')

  echo "▶ Running: $escaped_command"

  response=$(curl -s -k -u "$MQ_USER:$MQ_PASS" \
    -H "Content-Type: application/json" \
    -H "ibm-mq-rest-csrf-token: csrf-token" \
    -X POST "$MQ_URL" \
    --data "$payload")

  # Show response
  echo "$response" | jq .

  # Check if command failed
  completionCode=$(echo "$response" | jq -r '.commandResponse[0].completionCode // empty')

  if [[ "$completionCode" != "0" && -n "$completionCode" ]]; then
    echo "❌ ERROR: Command failed: $escaped_command" >> "$ERROR_LOG"
    echo "$response" | jq . >> "$ERROR_LOG"
    echo "❗ Logged to $ERROR_LOG"
  else
    echo "✅ Success"
  fi

  echo "-----------------------------"
done < ./commands.mqsc


