#!/usr/bin/env bash
#script prompts the user for their name 
read -p"what is your name ?" name
mkdir submission_reminder_$name

#create sub-directories

BASE_DIR="$HOME/submission_reminder_app_TKcodes-bit"
mkdir -p "$BASE_DIR/submission_reminder_$name/app"
mkdir -p "$BASE_DIR/submission_reminder_$name/modules"
mkdir -p "$BASE_DIR/submission_reminder_$name/assets"
mkdir -p "$BASE_DIR/submission_reminder_$name/config"

touch "$BASE_DIR/submission_reminder_$name/app/reminder.sh"
touch "$BASE_DIR/submission_reminder_$name/modules/function.sh"
touch "$BASE_DIR/submission_reminder_$name/assets/submissions.txt"
touch "$BASE_DIR/submission_reminder_$name/config/config.env"
touch "$BASE_DIR/submission_reminder_$name/startup.sh"

#Give the file executable permission

chmod +x "$BASE_DIR/submission_reminder_$name/app/reminder.sh"
chmod +x "$BASE_DIR/submission_reminder_$name/modules/function.sh"
chmod +x "$BASE_DIR/submission_reminder_$name/startup.sh"

#updating the data given into our file

cat <<EOF>"$BASE_DIR/submission_reminder_$name/app/reminder.sh"
#!/bin/bash

# Source environment variables and helper functions
source /config/config.env
source /modules/functions.sh

# Path to the submissions file
submissions_file="/assets/submissions.txt"

# Print remaining time and run the reminder function
echo "Assignment: \$ASSIGNMENT"
echo "Days remaining to submit: \$DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions \$submissions_file
EOF
cat<<EOF>"$BASE_DIR/submission_reminder_$name/modules/function.sh"
#!/bin/bash

# Function to read submissions file and output students who have not submitted
function check_submissions {
    local submissions_file=\$1
    echo "Checking submissions in $submissions_file"

    # Skip the header and iterate through the lines
    while IFS=, read -r student assignment status; do
        # Remove leading and trailing whitespace
        student=\$(echo "\$student" | xargs)
        assignment=\$(echo "\$assignment" | xargs)
        status=\$(echo "\$status" | xargs)

        # Check if assignment matches and status is 'not submitted'
        if [[ "\$assignment" == "\$ASSIGNMENT" && "\$status" == "not submitted" ]]; then
            echo "Reminder: \$student has not submitted the \$ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "\$submissions_file") # Skip the header
}
EOF
cat<<EOF>"$BASE_DIR/submission_reminder_$name/assets/submissions.txt"
# This is the config file
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOF
cat<<EOF>"$BASE_DIR/submission_reminder_$name/config/config.env"
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
Harun, Shell Navigation, not submitted
Drake, Shell Basics, submitted
Grace, Git, submitted
Sophia, Shell Navigation, submitted
Musoma, Git, Submitted
EOF
cat<<EOF>"$BASE_DIR/submission_reminder_$name/startup.sh"
#!/bin/bash

# startup.sh - Start the submission reminder application

# Define base directory
BASE_DIR="\$HOME/submission_reminder_app_TKcodes-bit/submission_reminder_$name"

# Check if necessary files exist
if [ ! -f "\$BASE_DIR/config/config.env" ]; then
    echo "Error: config.env not found!"
    exit 1
fi

if [ ! -f "\$BASE_DIR/modules/functions.sh" ]; then
    echo "Error: functions.sh not found!"
    exit 1
fi

if [ ! -f "\$BASE_DIR/assets/submissions.txt" ]; then
    echo "Error: submissions.txt not found!"
    exit 1
fi

# Source configuration file and functions file
source "\$BASE_DIR/config/config.env"
source "\$BASE_DIR/modules/functions.sh"

# Check if all necessary variables are set
if [ -z "\$ASSIGNMENT" ] || [ -z "\$DAYS_REMAINING" ]; then
    echo "Error: Required environment variables (ASSIGNMENT, DAYS_REMAINING) are not set in 
config.env"
    exit 1
fi

# Print initial information
echo "===================================="
echo "Starting the Submission Reminder App"
echo "Assignment: \$ASSIGNMENT"
echo "Days remaining to submit: \$DAYS_REMAINING"
echo "===================================="

# Run the reminder script
bash "\$BASE_DIR/app/reminder.sh"
EOF
