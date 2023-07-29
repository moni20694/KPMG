#! /bin/bash

metadata=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document)

if [ $? -eq 0 ] && [ -n "$metadata" ]; then
  # Print the metadata as formatted JSON
  echo "$metadata" | jq .
else
  echo "Failed to retrieve metadata."
fi