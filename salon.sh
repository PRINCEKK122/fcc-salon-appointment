#!/bin/bash
PSQL="psql --username=postgres --dbname=salon -t --no-align -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  echo -e "$1"
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
  SERVICES_RESULTS=$(echo "$SERVICES" | sed 's/|/) /')
  echo "$SERVICES_RESULTS"

  read SERVICE_ID_SELECTED

  # check to see if user input is a number
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    USER_CHOICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  fi

  if [[ -z $USER_CHOICE ]]
  then
    # send to main menu
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    SELECT_MENU
  fi
}

SELECT_MENU() {
  # get user input
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  GET_NUMBER_FROM_DB=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
 
  # if phone number is empty
  if [[ -z $GET_NUMBER_FROM_DB ]]
  then
    # get the name and insert a new record to the db
    echo -e "\nI don't have a record for that number, what's your name?"
    read CUSTOMER_NAME

    # inserting to the db
    $($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  USER_SERVICE_CHOICE=$($PSQL "SELECT name FROM services WHERE service_id = $USER_CHOICE")
  NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  APPOINT_TIME $USER_SERVICE_CHOICE $NAME
}

APPOINT_TIME() {
  echo -e "\nWhat time would you like your $1, $2?"
  read SERVICE_TIME

  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name='$1'")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$2'")
  $($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES ('$SERVICE_TIME', $SERVICE_ID, $CUSTOMER_ID)")
  echo -e "\nI have put you down for a $USER_SERVICE_CHOICE at $SERVICE_TIME, $NAME.\n"
}

MAIN_MENU "Welcome to my salon, how can I help you?\n"

