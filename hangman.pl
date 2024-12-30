use strict;
use warnings;
use Term::ReadKey;
use Storable;
use Term::ANSIColor;

my @words = ('perl', 'programming', 'language', 'hangman', 'game');
my $word = $words[int(rand(@words))];
my $secretWord = '_' x length($word);
my $attempts = 6;
my @guessedLetters;

#   o
#  /|\
#  / \
sub printHangman {
    my ($wrongGuesses) = @_;

    my $hangman;

    # Initially, only print the hang post
    $hangman =  "   +---+\n";
    $hangman .= "       |\n";
    $hangman .= "       |\n";
    $hangman .= "       |\n";
    $hangman .= "      ===\n";

    if ($wrongGuesses == 1) {
        $hangman =  "   +---+\n";
        $hangman .= "   O   |\n";
        $hangman .= "       |\n";
        $hangman .= "       |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses == 2) {
        $hangman =  "   +---+\n";
        $hangman .= "   O   |\n";
        $hangman .= "   |   |\n";
        $hangman .= "       |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses == 3) {
        $hangman =  "   +---+\n";
        $hangman .= "   O   |\n";
        $hangman .= "   |\\  |\n"; # zbog escaping \, imamo ovu izbocinu
        $hangman .= "       |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses == 4) {
        $hangman =  "   +---+\n";
        $hangman .= "   O   |\n";
        $hangman .= "  /|\\  |\n";
        $hangman .= "       |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses == 5) {
        $hangman =  "   +---+\n";
        $hangman .= "   O   |\n";
        $hangman .= "  /|\\  |\n";
        $hangman .= "    \\  |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses >= 6) {
        $hangman =  "   +---+\n";
        $hangman .= "   O   |\n";
        $hangman .= "  /|\\  |\n";
        $hangman .= "  / \\  |\n";
        $hangman .= "      ===\n";
    }
    print "\n";
    print $hangman;
    print "\n";
}

# Save the state of the currently played game
sub saveGame {
    my ($filename) = @_;
    store({
        word => $word,
        secretWord => $secretWord,
        attempts => $attempts,
        guessedLetters => \@guessedLetters,
        currentPlayer => $currentPlayer
    }, $filename);
    print "Game saved!\n";
}

# Load the saved game
sub loadGame {
    my ($filename) = @_;
    my $state = retrieve($filename);
    $word = $state->{word};
    $secretWord = $state->{secretWord};
    $attempts = $state->{attempts};
    @guessedLetters = @{$state->{guessedLetters}};
    $currentPlayer = $state->{currentPlayer};
    print "Game loaded!\n";
}

# Save the scoreboard to a .sav file
sub saveScoreboard {
   # TODO
}

# Load the saved scoreboard from the scoreboard.sav file
sub loadScoreboard {
   # TODO
}

# Locally update scoreboard after the end of each game
sub updateScoreboard {
   # TODO
}

# Display the scoreboard 
sub viewScoreboard {
    # TODO
}

# Display the score of the current player after winning a game
sub displayScore {
    # TODO
}

# Display the start menu
sub displayMenu {
    print colored("\n~~~ Hangman Menu ~~~\n", "magenta");
    print colored("1. Start New Game\n", "cyan");
    print colored("2. Continue Saved Game\n", "cyan");
    print colored("3. View Scoreboard\n", "cyan");
    print colored("4. Exit\n", "cyan");
}

sub play {
    print "\n";
    print "~~~ Welcome to Hangman! ~~~\n";
    printHangman(0);
    print "Guess the word: $secretWord\n";

    while ($attempts > 0) {
        print "\n";
        # print "Attempts left: $attempts\n";
        # print "Guessed letters: @guessedLetters\n";
        print "Enter a letter: ";
        my $guess = <STDIN>;
        # Remove the trailing \n character from the input
        chomp($guess);

        # Check if we already guessed the letter
        my $alreadyGuessedFlag = 0;
        foreach my $letter (@guessedLetters) {
            if ($letter eq $guess) {
                # Set the flag
                $alreadyGuessedFlag = 1;
                last;
            }
        }

        if ($alreadyGuessedFlag) {
            print "You already guessed '$guess'. Try again.\n";
            next;
        } 
        # =~ operator since we are expecting a regex and matching the pattern
        if (!($guess =~ /^[a-zA-Z]$/ && length($guess) == 1)) {
            print "Invalid input. Please enter only a single letter. It's not that hard...\n";
            next;
        }
        # Add our guess to the guessed letters array
        push(@guessedLetters, $guess);

        # If index of the guessed letter is -1, it isn't the word => wrong guess
        if (index($word, $guess) == -1) {
            $attempts--;
            print "Wrong guess! $secretWord\n";
            printHangman(6 - $attempts);
            print "Attempts left: $attempts\n";
            print "Guessed letters: @guessedLetters\n";
            print "___________________\n";
            next;
        }
        
        # Loop trough the secret word
        for my $i (0 .. length($word) - 1) {
            # For every correctly guessed letter in the word, replace "_" with the correct letter in the secretWord
            if (substr($word, $i, 1) eq $guess) {
                # Replace the "_" with the letter that we guessed correctly
                substr($secretWord, $i, 1) = $guess;
            }
        }
        print "Good guess! $secretWord\n";

        last if $secretWord eq $word;
    }

    if ($secretWord eq $word) {
        print "Woohoo! You guessed the word: $word\n";
    } else {
        print "Sorry, you ran out of attempts :( The word was: $word\n";
    }
}

sub restartState {
    ($word) = @_;
    $secretWord = '_' x length($word);
    $attempts = 6;
    @guessedLetters = ();
    $currentPlayer = "";
}

sub init {
    displayMenu();
    print colored("Input:", "bright_yellow") . " ";
    my $input = <STDIN>;
    chomp($input);

    if($input == 1) {
        print colored("1. Singleplayer\n", "cyan");
        print colored("2. Multiplayer\n", "cyan");
        print colored("Input:", "bright_yellow") . " ";
        my $modeInput = <STDIN>;
        chomp($modeInput);

        if($modeInput == 2) {
            print colored("Enter custom word for Player2 (hidden):", "bright_yellow") . " ";
            ReadMode("noecho");
            my $customWord = <STDIN>;
            chomp($customWord);
            ReadMode(0);

            print "\n";

            $word = $customWord;
            restartState($word);
            play();
        } else {
            $word = $words[int(rand(@words))];
            restartState($word);
            play();
        }
    } elsif ($input == 2) {
        loadGame("hangman.sav");
        play();
    } elsif ($input == 3) {
        viewScoreboard();
        init();
    } elsif ($input == 4) {
        print colored("Exiting the game. Goodbye!\n", "cyan");
        # TODO SAVE SCOREBOARD
        exit;
    } else {
        print colored("Invalid choice! Please select 1-4.\n", "red");
        init();
    }
}

init();