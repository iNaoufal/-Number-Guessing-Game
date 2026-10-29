#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]; then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null 
else
    IFS="|" read DB_USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
    echo "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

while [[ "$GUESS" != "$SECRET_NUMBER" ]]; do
    if ! [[ "$GUESS" =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
    elif (( GUESS > SECRET_NUMBER )); then
        echo "It's lower than that, guess again:"
    else
        echo "It's higher than that, guess again:"
    fi

    read GUESS
    ((NUMBER_OF_GUESSES++))
done

echo "You guessed it in $((NUMBER_OF_GUESSES + 1)) tries. The secret number was $SECRET_NUMBER. Nice job!"

FINAL_GUESSES=$((NUMBER_OF_GUESSES + 1))

$PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'" > /dev/null 

$PSQL "UPDATE users SET best_game = $FINAL_GUESSES WHERE username = '$USERNAME' AND (best_game IS NULL OR best_game > $FINAL_GUESSES)" > /dev/null
