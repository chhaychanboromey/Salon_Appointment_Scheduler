#! /bin/bash

# Database connection command
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo "Welcome to My Salon, how can I help you?"

MAIN_MENU() {
  # If an argument is passed, display it as a message
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Display list of services in format: #) <service>
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  # Read selected service into variable SERVICE_ID_SELECTED
  read SERVICE_ID_SELECTED

  # Check if service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_NAME ]]
  then
    # Show main menu again if service does not exist
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Prompt for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Check if phone number exists in customers table
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    # If customer does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Prompt for customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Insert new customer record
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi

    # Get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    # Prompt for appointment time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment into appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

    # Confirmation message
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU