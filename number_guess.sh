#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

ANSWER=$((RANDOM % 1000 + 1 ))

echo 'Enter your username:'
read USERNAME_INPUT

USERNAME=$($PSQL "SELECT username FROM users WHERE username = '$USERNAME_INPUT'")

if [[ -z $USERNAME ]]
then
  # User not found
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT')")
else
  # User found
  USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")
  IFS="|" read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GUESS_COUNT=1

echo 'Guess the secret number between 1 and 1000:'
read GUESS

while [[ $GUESS -ne $ANSWER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    # Not a number
    echo 'That is not an integer, guess again:'
  elif [[ $GUESS -gt $ANSWER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi

    read GUESS
    GUESS_COUNT=$(( GUESS_COUNT + 1 ))
done

UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = COALESCE(games_played, 0) + 1, best_game = CASE
  WHEN best_game IS NULL OR $GUESS_COUNT < best_game THEN $GUESS_COUNT
  ELSE best_game END
  WHERE username = '$USERNAME_INPUT'")

echo "You guessed it in $GUESS_COUNT tries. The secret number was $ANSWER. Nice job!"