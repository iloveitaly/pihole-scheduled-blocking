#!/bin/sh
# Description: Inject a line into the start.sh script before the "wait $CAPSH_PID" line.
#              this seems like the best place to run any sort of configuration.

SCRIPT_PATH="/usr/bin/start.sh"
INJECTED_LINE="$1"

if [ -z "$INJECTED_LINE" ]; then
  echo "Error: No line to inject provided."
  exit 1
fi

if [ ! -f "$SCRIPT_PATH" ]; then
  echo "Error: Script file $SCRIPT_PATH does not exist."
  exit 1
fi

# Find the line number of "wait $CAPSH_PID"
LINE_NUM=$(grep -n 'if \[ "\${TAIL_FTL_LOG:-1}" -eq 1 \]; then' "$SCRIPT_PATH" | cut -d: -f1)
if [ -z "$LINE_NUM" ]; then
  echo "Error: 'wait \$CAPSH_PID' not found in the script."
  exit 1
fi

# Insert the line before that line number
sed -i "${LINE_NUM}i $INJECTED_LINE" "$SCRIPT_PATH"