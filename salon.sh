#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"
echo -e "\n~~~ Welcome to Rose Salon ~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
 
  echo -e "\nHere are the salon's services:\n"
  DISPLAY_SERVICES

  echo -e "\nPlease select a service by entering the corresponding number:"
  read SERVICE_ID_SELECTED
  HANDLE_SERVICE_SELECTION $SERVICE_ID_SELECTED
}

#Function to display services
DISPLAY_SERVICES() {
 # Get all services
  ALL_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  # Loop through the services and display them
  echo "$ALL_SERVICES" | while IFS='|' read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

#Function to handle the service selecrion
HANDLE_SERVICE_SELECTION() {
 SERVICE_ID_SELECTED=$1

 #Validate input
 SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
 if [[ -z $SERVICE_NAME ]]
   then
    MAIN_MENU "Invalid service selection. Please try again."
   else 
   echo -e "\nYou have selected the service: $SERVICE_NAME"
   GET_CLIENT_INFO $SERVICE_ID_SELECTED "$SERVICE_NAME"
  fi
}

#Function to get client information
GET_CLIENT_INFO() {
  SERVICE_ID=$1
  SERVICE_NAME=$2
  
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nIt looks like you are a new customer. Please enter your name:"
    read CUSTOMER_NAME
    INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  else
   CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed -e 's/^ *//' -e 's/ *$//')
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  SCHEDULE_APPOINTMENT $CUSTOMER_ID $SERVICE_ID "$SERVICE_NAME" "$CUSTOMER_NAME"
}

#Function to schedule an appointment
SCHEDULE_APPOINTMENT() {
  CUSTOMER_ID=$1
  SERVICE_ID=$2
  SERVICE_NAME=$3
  CUSTOMER_NAME=$4

  echo -e "\nPlease enter your preferred time for the $SERVICE_NAME service, $CUSTOMER_NAME:"
  read SERVICE_TIME

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
   
 if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nThere was an error scheduling your appointment. Please try again."
    MAIN_MENU
  fi
}

MAIN_MENU
