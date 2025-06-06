#!/bin/bash

MQ_USER="admin"
MQ_PASS="${1}"
COMMAND_FILE="${2:-./commands.mqsc}"
LB="${3}"
ERROR_LOG="${4}"
QM="${5}"
MQ_URL="https://${LB}:9443/ibmmq/rest/v2/admin/action/qmgr/${QM}/mqsc"

any_failure=0

if [[ -z "$ERROR_LOG" ]]; then
  echo "❌ ERROR_LOG variable not set"
  exit 1
fi


for i in {1..30}; do
  response=$(curl -s -k -u "$MQ_USER:$MQ_PASS" \
    -H "ibm-mq-rest-csrf-token: csrf-token" \
    "https://${LB}:9443/ibmmq/rest/v2/admin/qmgr")

  if echo "$response" | grep -q '"qmgr"'; then
    echo "✅ Queue manager is up and listening."
    sleep 10
    break
  else
    echo "Queue manager not ready yet..."
    sleep 5
  fi
done

if ! echo "$response" | grep -q '"qmgr"'; then
  echo "❌ Queue manager did not become ready after waiting."
  exit 1
fi

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
    --data-raw "$payload")

    #--data "$payload")

  # Show response
  echo "$response" | jq .

  # Check if command failed
  completionCode=$(echo "$response" | jq -r '.commandResponse[0].completionCode // empty')

  if [[ "$completionCode" != "0" && -n "$completionCode" ]]; then
    echo "❌ ERROR: Command failed: $escaped_command" >> "$ERROR_LOG"
    echo "$response" | jq . >> "$ERROR_LOG"
    echo "❗ Logged to $ERROR_LOG"
    any_failure=1
  else
    echo "✅ Success"
  fi

  echo "-----------------------------"

done < "$COMMAND_FILE"

if [[ "$any_failure" -eq 1 ]]; then
  echo "❌ One or more MQSC commands failed. See $ERROR_LOG for details."
  exit 1
fi

