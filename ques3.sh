#! /bin/bash

get_nested_value() {
    local json_objects="$1"
    local key="$2"
    jq -r --argjson key_array "[$(echo "$key" | tr '/' ',')]" 'getpath($key_array)' <<< "$json_object"
}
object='{"a":{"b":{"c":"d"}}}'
key='a/b/c'
result=$(get_nested_value "$object" "$key")
echo "value: $result"