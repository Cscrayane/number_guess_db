#!/bin/bash
RAND=$(( $RANDOM % 1000 + 1 ))
PSQL="psql --username=freecodecamp --dbname=users -t --no-align -c"
echo -e "\nEnter your username:"
read USERNAME
USERNAME_CHECK=$($PSQL "SELECT user_id FROM users_info WHERE name = '$USERNAME'")
SCORES=$($PSQL "SELECT played, score FROM users_info WHERE name = '$USERNAME'")
if [[ -z $USERNAME_CHECK ]]
then
  echo Welcome, $USERNAME! It looks like this is your first time here.
  INSERT_RESULT=$($PSQL "INSERT INTO users_info(name) VALUES('$USERNAME')")
else
  echo $SCORES | while IFS='|' read PLAYED SCORE
  do
    echo Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $SCORE guesses.
  done
fi

TIMES=0
FLAG=1
echo Guess the secret number between 1 and 1000:
while (( $FLAG == 1 ))
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo That is not an integer, guess again:
  else
    TIMES=$(( TIMES + 1 ))
    if (( GUESS < RAND ))
    then
      echo It\'s higher than that, guess again:
    elif (( GUESS > RAND ))
    then
      echo It\'s lower than that, guess again:
    else
      echo You guessed it in $TIMES tries. The secret number was $RAND. Nice job!
      FLAG=0
      echo $SCORES | while IFS='|' read PLAYED SCORE
      do
        PLAYED=$(( PLAYED + 1 ))
        UPDATE_RES=$($PSQL "UPDATE users_info SET played = $PLAYED WHERE name = '$USERNAME'")
        if [[ -z $SCORE || $TIMES -lt $SCORE ]]
        then
          UPDATE_RES=$($PSQL "UPDATE users_info SET score = $TIMES WHERE name = '$USERNAME'")
        fi
      done 
    fi
  fi

done

