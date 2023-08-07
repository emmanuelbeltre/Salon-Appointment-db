#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Beauty Salon ~~~~~\n"


SERVICE_MENU() {
   if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo "How may I help you?" 
  #get all services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services ORDER BY service_id")

  #if not available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    MAIN_MENU "No services availables at the moment"
  else
    #display all services
    echo -e "\n Here are all the services available"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME 
    do
      echo "$SERVICE_ID) $NAME"
    done

   
    #ask for a service to recive
    echo -e "\nWhich service would you like to recive?"
    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      #send to main menu
       SERVICE_MENU "\nThat is not a valid number.\n"
      echo $SERVICE_ID
    else
    #get service selected 
    SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_SELECTED ]]
      then
        SERVICE_MENU "\nThat is not a valid number.\n"
      else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        #if customer doesn't  exixt 
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nWhat's your name?"
          read CUSTOMER_NAME     

          #Insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")  
        fi  
        
          # get customer_id
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          
          #get service selected
          SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

          echo -e "\nWhat time would you like to receive your service?"   
          read SERVICE_TIME

          INSERT_APPOIMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED, '$SERVICE_TIME')" )

         echo -e "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME." 
        
      fi
    
    fi


  fi 

}

EXIT() {
  echo -e "\nThank you for stopping in.\n"
}
# MAIN_MENU
SERVICE_MENU
