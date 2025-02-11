#!/bin/bash

# Connect to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# Ask for the username
echo -e "\nEnter your username:"
read USERNAME

# Ensure username does not exceed 22 characters
USERNAME=${USERNAME:0:22}

# Check if user exists in the database
USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USER_INFO ]]; then
  # New user
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 1000)"
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # Returning user
  echo "$USER_INFO" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME; do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# Start the guessing game
echo -e "\nGuess the secret number between 1 and 1000:"
NUMBER_OF_GUESSES=0

while true; do
  read GUESS
  ((NUMBER_OF_GUESSES++))

  # Validate input
  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Check if guess is correct
  if [[ $GUESS -eq $SECRET_NUMBER ]]; then
    echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Update user stats
    USER_INFO=$($PSQL "SELECT user_id, games_played, best_game FROM users WHERE username='$USERNAME'")
    echo "$USER_INFO" | while IFS="|" read USER_ID GAMES_PLAYED BEST_GAME; do
      NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
      if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
        $PSQL "UPDATE users SET best_game=$NUMBER_OF_GUESSES WHERE user_id=$USER_ID"
      fi
      $PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE user_id=$USER_ID"
    done

    break
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  else
    echo "It's higher than that, guess again:"
  fi
done
