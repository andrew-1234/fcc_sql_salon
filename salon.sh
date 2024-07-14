#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Welcome to the salon message
echo -e "\n\n~~~ Welcome to the Spooky Salon! ~~~\n"
cat <<"EOF"
           O>         _
          ,/)          )_
      -----<---<<<   )   )
           ``      ` _)    
EOF

SERVICE_LIST=$(
  echo -e "\nTo book an appointment, please select from one of our available services:"
  $PSQL "SELECT service_id, name FROM services" | while IFS="|" read -r service_id name; do
    echo "${service_id}) $name"
  done
  echo "Enter the service number you would like to book, or q to quit:"
)

AVAILABLE_SERVICES() {

  if [[ ! $1 ]]; then
    echo "$SERVICE_LIST"
  else
    echo -e "Invalid service number - Try again:"
    echo "$SERVICE_LIST"
  fi

  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED == "q" ]]; then
    echo "Goodbye!"
    exit
  fi

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    AVAILABLE_SERVICES again
  fi

  VALUE=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
}

AVAILABLE_SERVICES

until [[ "$VALUE" ]]; do
  AVAILABLE_SERVICES again
done

echo "You selected service number: $SERVICE_ID_SELECTED"

# Get the phone number from the user
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check phone number exists in the database
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ ! "$CUSTOMER_ID" ]]; then
  echo "We don't have a customer with that phone number in our system."
  echo "Please enter your name to create a new customer profile:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_ID=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  if [[ $INSERT_CUSTOMER_ID == 'INSERT 0 1' ]]; then
    echo Created new customer - Welcome, "$CUSTOMER_NAME"
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo "Welcome back, $CUSTOMER_NAME!"
fi

# What time would you like to book the appointment for?
BOOK_APPOINTMENT() {
  echo "What time would you like to book the appointment for? (HH:MM)"
  read SERVICE_TIME
  if [[ ! $SERVICE_TIME =~ ^[0-9]{2}.*$ ]]; then
    echo "Invalid time format - Please enter the time in HH:MM format"
    # BOOK_APPOINTMENT
  fi
}
BOOK_APPOINTMENT

# Add the appointment to the database and check it was added
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (service_id, customer_id, time) VALUES ($SERVICE_ID_SELECTED, $CUSTOMER_ID, '$SERVICE_TIME')")
if [[ $INSERT_APPOINTMENT == 'INSERT 0 1' ]]; then
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
else
  echo "Oops! There was an error booking your appointment. Please try again."
fi
