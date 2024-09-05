#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

#get username from database to USER_DB
USER_DB=$($PSQL "SELECT * FROM game WHERE username='$USERNAME'")
#GET count of this username show up on database
PLAYED=$($PSQL "SELECT COUNT(*) FROM game WHERE username='$USERNAME'")
#get min() guesses from this user
SCORE=$($PSQL "SELECT MIN(guesses) FROM game WHERE username='$USERNAME'")
#print filtered credentials and apply them to variables
echo $USER_DB | sed 's/|/ /g' | while read USER_ID NAME GUESSES; do

    #check if username exist on database
    if [[ -n $USER_DB ]]; then
        echo "Welcome back, $NAME! You have played $PLAYED games, and your best game took $SCORE guesses."

    #username doesnt exist in database
    else
        echo "Welcome, $USERNAME! It looks like this is your first time here."
        #insert username to database
    fi
done
#creates a random number between 1 and 1000
RANDOM_GUESS=$(((RANDOM % 1000) + 1))
#create counter of guesses for later
ATTEMPS=1

GUESSING() {
    if [[ $1 ]]; then
        echo -e "\n$1 \n"
    fi
    #-echo $ATTEMPS
    echo "Guess the secret number between 1 and 1000:"
    read GUESS

    #check for integer
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
        GUESSING "That is not an integer, guess again:"

    else
        while [ $GUESS -ne $RANDOM_GUESS ]; do
            if [[ $GUESS -gt $RANDOM_GUESS ]]; then
                ((ATTEMPS++))
                echo "It's lower than that, guess again:"
                read GUESS
            elif [[ $GUESS -lt $RANDOM_GUESS ]]; then
                ((ATTEMPS++))
                echo "It's higher than that, guess again:"
                read GUESS
            fi
        done
        #INSERT every data to database as new entry
        INSERT_USER=$($PSQL "INSERT INTO game(username,guesses) VALUES('$USERNAME','$ATTEMPS')")
        if [[ $GUESS -eq $RANDOM_GUESS ]]; then

            echo "You guessed it in $ATTEMPS tries. The secret number was $RANDOM_GUESS. Nice job!"
            exit
        fi
    fi
}
GUESSING
