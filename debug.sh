#!/bin/bash
npx vite --port 4000 &
# Create a temporary file to act as our running flag
FLAG_FILE=$(mktemp)

# Define the background worker function
run_background_loop() {
    count=1
    # Loop keeps running as long as the flag file exists
    while [ -f "$FLAG_FILE" ]; do
        echo "Processing iteration $count... (Press Enter to stop safely)"
        
        # Simulating a 3-second task cycle
        sleep 3 
        npx vite build
        count=$((count + 1))
    done
    echo "Current cycle finished safely. Exiting loop."
}

# 1. Start the loop function in the background
run_background_loop &
BACKGROUND_PID=$!

# 2. Wait for the user to press Enter in the foreground
read -r

# 3. User pressed Enter: Signal the loop to stop by removing the flag file
echo "Stop requested. Waiting for the current cycle to finish..."
rm -f "$FLAG_FILE"

# 4. Wait for the background process to finish its final cycle completely
wait $BACKGROUND_PID

echo "Script completely finished."
