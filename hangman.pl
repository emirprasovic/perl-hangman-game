use strict;
use warnings;
use Term::ReadKey;
use Storable;
use Term::ANSIColor;

my @words = ('otorinolaringologija', 'programming', 'languages', 'hangman', 'cedevita');
my $word;
my $secretWord;
my $attempts;
my @guessedLetters;
my $scoreboard = {};
my $currentPlayer = "";

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
        $hangman .= "   ".colored("O", "yellow")."   |\n";
        $hangman .= "       |\n";
        $hangman .= "       |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses == 2) {
        $hangman =  "   +---+\n";
        $hangman .= "   ".colored("O", "yellow")."   |\n";
        $hangman .= "   ".colored("|", "bright_cyan")."   |\n";
        $hangman .= "       |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses == 3) {
        $hangman =  "   +---+\n";
        $hangman .= "   ".colored("O", "yellow")."   |\n";
        $hangman .= "   ".colored("|\\", "bright_cyan")."  |\n"; # zbog escaping \, imamo ovu izbocinu
        $hangman .= "       |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses == 4) {
        $hangman =  "   +---+\n";
        $hangman .= "   ".colored("O", "yellow")."   |\n";
        $hangman .= "  ".colored("/|\\", "bright_cyan")."  |\n";
        $hangman .= "       |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses == 5) {
        $hangman =  "   +---+\n";
        $hangman .= "   ".colored("O", "yellow")."   |\n";
        $hangman .= "  ".colored("/|\\", "bright_cyan")."  |\n";
        $hangman .= "    ".colored("\\", "cyan")."  |\n";
        $hangman .= "      ===\n";
    } elsif ($wrongGuesses >= 6) {
        $hangman =  "   +---+\n";
        $hangman .= "   ".colored("O", "yellow")."   |\n";
        $hangman .= "  ".colored("/|\\", "bright_cyan")."  |\n";
        $hangman .= "  ".colored("/ \\", "cyan")."  |\n";
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
    my ($filename) = @_;
    store({
        scoreboard => $scoreboard
    }, $filename);
    print "Scoreboard saved\n";
}

# Load the saved scoreboard from the scoreboard.sav file
sub loadScoreboard {
    my ($filename) = @_;
    my $state = retrieve($filename);
    $scoreboard = $state->{scoreboard};
    print "Scoreboard loaded\n";
}

# Locally update scoreboard after the end of each game
sub updateScoreboard {
    my ($player, $won) = @_;
    if (!exists $scoreboard->{$player}) {
        $scoreboard->{$player} = { gamesPlayed => 0, gamesWon => 0 };
    }
    $scoreboard->{$player}->{gamesPlayed}++;
    $scoreboard->{$player}->{gamesWon}++ if $won;
}

# Display the scoreboard 
sub viewScoreboard {
    print colored("\n~~~ Scoreboard ~~~\n", "yellow");
    foreach my $player (keys %$scoreboard) {
        print "$player: Games Played: $scoreboard->{$player}->{gamesPlayed}, Games Won: $scoreboard->{$player}->{gamesWon}\n";
    }
}

# Display the score of the current player after winning a game
sub displayScore {
    my $gamesPlayed = $scoreboard->{$currentPlayer}->{gamesPlayed};
    my $gamesWon = $scoreboard->{$currentPlayer}->{gamesWon};
    print colored("\n~~~ Your Score ~~~\n", "yellow");
    print "$currentPlayer: Games played: $gamesPlayed | Games won: $gamesWon\n";
}

# Display the start menu
sub displayMenu {
    print colored("\n~~~ Hangman Menu ~~~\n", "magenta");
    print colored("1. Start New Game\n", "cyan");
    print colored("2. Continue Saved Game\n", "cyan");
    print colored("3. View Scoreboard\n", "cyan");
    print colored("4. Exit\n", "cyan");
}

# The actual game logic
sub play {
    print "\n";
    print colored("~~~ Welcome to Hangman ~~~\n", "magenta");

    # If the current player name is not set (new game), require input
    # This part will be skipped only when we load a saved game
    if ($currentPlayer eq "") {
        print colored("Enter your name:", "bright_yellow") . " ";
        my $name = <STDIN>;
        $currentPlayer = $name;
    }

    printHangman(6 - $attempts);
    print "Guess the word: $secretWord\n";

    while ($attempts > 0) {
        print "\n";
        # print "Attempts left: $attempts\n";
        # print "Guessed letters: @guessedLetters\n";
        print colored("Enter a letter: ", "bright_yellow");
        my $guess = <STDIN>;
        # Remove the trailing \n character from the input
        chomp($guess);

        # By entering the "save" keyword in the middle of a game, we save the state and finish the current game
        if ($guess eq "save") {
            saveGame("hangman.sav");
            # last;
            exit;
        }

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
            print colored("You already guessed '$guess'. Try again.\n", "bright_red");
            next;
        } 
        # =~ operator since we are expecting a regex and matching the pattern
        if (!($guess =~ /^[a-zA-Z]$/ && length($guess) == 1)) {
            print colored("Invalid input. Please enter only a single letter. It's not that hard...\n", "bright_red");
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
            print "___________________________\n";
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

        last if $secretWord eq $word;

        # This print is beneath the line above so we don't print out the completed word twice
        print "Good guess! $secretWord\n";
    }

    if ($secretWord eq $word) {
        # Player wins -> congratulate, update scoreboard with win, display score
        print colored("Bravo! You guessed the word: $word\n", "bright_green");
        updateScoreboard($currentPlayer, 1);
        displayScore();
    } else {
        # Player loses, naruzi ga, update scoreboard with loss
        print colored("Sorry, you ran out of attempts :( The word was: $word\n", "bright_red");
        updateScoreboard($currentPlayer, 0);
    }
    # After game end, show the menu again
    init();
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
            # $secretWord = '_' x length($word);
            # $attempts = 6;
            # @guessedLetters = ();
            # $currentPlayer = "";

            play();
        } else {
            $word = $words[int(rand(@words))];
            restartState($word);
            # $secretWord = '_' x length($word);
            # $attempts = 6;
            # @guessedLetters = ();
            # $currentPlayer = "";

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
        saveScoreboard("scoreboard.sav");
        exit;
    } else {
        print colored("Invalid choice! Please select 1-4.\n", "red");
        init();
    }
}

# print colored("This is bright blue text\n", 'bright_blue');
# print colored("This is blue text\n", 'blue');
# print colored("This is bright cyan text\n", 'bright_cyan');
# print colored("This is cyan text\n", 'cyan');
# print colored("This is bright red text\n", 'bright_red');
# print colored("This is red text\n", 'red');
# print colored("This is bright yellow text\n", 'bright_yellow');
# print colored("This is yellow text\n", 'yellow');
# print colored("This is magenta text\n", 'magenta'); 
# print colored("This is bright magenta text\n", 'bright_magenta');
# print colored("This is bright green text\n", 'bright_green');
# print colored("This is green text\n", 'green'); 

loadScoreboard("scoreboard.sav");
init();
