try (
  fromjson |
  if .type == "assistant" then
    .message.content[] |
    if .type == "text" then .text
    elif .type == "tool_use" then
      (.input | to_entries | first) as $e |
      "> \(.name)\(if $e then ": \($e.value | tostring | .[0:60])" else "" end)"
    else empty
    end
  elif .type == "system" then
    if .subtype == "task_started" then "> Task: \(.description)"
    elif .subtype == "task_progress" then "  \(.description)"
    else empty
    end
  elif .type == "result" and .subtype == "success" then
    .result
  else empty
  end
) catch empty
