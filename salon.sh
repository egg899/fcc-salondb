
#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~~My Salon~~~~~~\n"
echo -e "\n ~~~~~Welcome to my salon, how can I help you?~~~~~~\n"

EXIT() {
  echo -e ""
  exit 0
}

LIST_SERVICES() {
  if [[ $1 ]]; then
    echo -e "\n$1\n"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo -e "\nAvailable services:\n"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME; do 
    echo "$SERVICE_ID) $NAME Service"
  done
}

MAIN_MENU() {
  while true; do
    LIST_SERVICES

    echo -e "\nPlease enter the service ID:"
    read SERVICE_ID_SELECTED

    # if [[ $SERVICE_ID_SELECTED == 'exit' ]]; then
    #   EXIT
    # fi

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
      LIST_SERVICES "Invalid service ID. Please enter a valid service ID."
      continue
    fi

    HAVE_ID=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $HAVE_ID ]]; then
      LIST_SERVICES "Invalid service ID. Please enter a valid service ID."
      continue
    fi

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    HAVE_PHONE=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $HAVE_PHONE ]]; then 
      echo -e "\nI don't have a record for that phone number. What's your name?"
      read CUSTOMER_NAME
      echo -e "\nWhat time would you like your $HAVE_ID, $CUSTOMER_NAME?"
      read SERVICE_TIME

      INSERT_CUST=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUST_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
      INSERT_APP=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES ('$SERVICE_ID_SELECTED', '$CUST_ID', '$SERVICE_TIME')") 
      echo -e "\nI have put you down for a $HAVE_ID at $SERVICE_TIME, $CUSTOMER_NAME." 
      EXIT
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      #echo "$CUSTOMER_NAME is already in the list."  
      echo -e "\nWhat time would you like your $HAVE_ID, $CUSTOMER_NAME?"
      read SERVICE_TIME
      echo -e "\nI have put you down for a $HAVE_ID at $SERVICE_TIME, $CUSTOMER_NAME." 
      EXIT
      
    fi
  done
}

MAIN_MENU
