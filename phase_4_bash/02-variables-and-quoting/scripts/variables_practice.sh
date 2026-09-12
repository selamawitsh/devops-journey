#!/bin/bash

readonly APP_NAME="devops-journey"
export APP_ENV="development"

echo "App: $APP_NAME running in: $APP_ENV"

CURRENT_DATE=$(date +%Y-%m-%d)
echo "Today's date: $CURRENT_DATE"

bash -c 'echo "Child process sees APP_ENV as: $APP_ENV"'
