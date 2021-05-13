#!/bin/bash

email_status=$1

echo "email_status is $email_status"

source secrets.sh

if [[ "$email_status" = 'success' ]]; then
  curl -s -X POST --user "$MAILJET_USER_DATA" https://api.mailjet.com/v3.1/send -H 'Content-Type: application/json' -d @backup_success_mail.json  
  exit 0
elif [[ "$email_status" = 'failed' ]]; then 
  curl -s -X POST --user "$MAILJET_USER_DATA" https://api.mailjet.com/v3.1/send -H 'Content-Type: application/json' -d @backup_failed_mail.json  
  exit 0;
else
  echo "Unknown email status given... $email_status";
  exit 1
fi

echo "finished"
