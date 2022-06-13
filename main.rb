require 'io/console'
require 'yaml'
require 'colorize'

SAVE_FILE = 'saved.yaml'
DICTIONARY = 'dictionary.txt'
CHANCES = 8
MINIMUM_LENGTH = 5
MAXIMUM_LENGTH = 12

class Game
  def initialize
    @secret_word = random_word
    @chances_remaining = CHANCES
    @guesses = []
  end

  def help
    puts "H A N G M A N
    Guess the word
    Input: /s: save /q: quit"
  end

  def start
    display_status

    loop do
      print '>> '
      input = $stdin.getch

      case input
      when '/'
        case $stdin.getch
        when 's'
          puts
          save
        when 'q'
          puts
          quit
        end
      else
        handle_guess(input.downcase)
        break if game_over?
      end
    end
    quit
  end

  def correct_guess?(guess)
    @secret_word.include?(guess)
  end

  def handle_guess(guess)
    if @guesses.include?(guess)
      puts "Already guessed '#{guess}'" 
    elsif ! ('a'..'z').include?(guess)
      puts 'Enter an alphabet'
    else
      @guesses.push(guess)
      @chances_remaining -= 1 unless correct_guess?(guess)
      display_status
    end
  
  end

  def random_word
    words = File.readlines(DICTIONARY)
    word = nil
    loop do
      word = words.sample.chomp
      length = word.length
      break if length > MINIMUM_LENGTH && length < MAXIMUM_LENGTH
    end
    word.split('')
  end

  def display_status
    system('clear')
    help
    display_array = @secret_word.map do |letter|
      @guesses.include?(letter) ? letter.green : '_'
    end

    puts
    puts display_array.join(' ')
    puts "Chances remaining: #{@chances_remaining}"
    puts "Incorrect guesses: #{incorrect_guesses}"
  end

  def incorrect_guesses
    incorrect = []
    @guesses.each do |guess|
      incorrect << guess.red unless correct_guess?(guess)
    end
    incorrect.join(', ')
  end

  def game_over?
    if @secret_word.all? { |letter| @guesses.include?(letter) }
      puts 'YOU WON!'
      true
    elsif @chances_remaining <= 0
      puts 'YOU LOST!'
      true
    else
      false
    end
  end

  def quit
    puts "Thank you for playing"
    exit
  end

  def save
    save_game(self)
    quit
  end
end

def save_game(game)
  saved = load_saved_games
  print 'Enter save file name: '
  file_name = gets.chomp
  saved[file_name] = game
  File.open(SAVE_FILE, 'w') { |file| file.puts YAML.dump(saved) }
  puts "Saved current game state under \"#{file_name}\""
end

def load_saved_games
  saved = {}
  if File.exist?(SAVE_FILE)
    begin
      saved = YAML.load(File.read(SAVE_FILE), permitted_classes: [Game])
    rescue
      saved = {}
    end
  end
  saved
end

class Hangman
  def start
    game = nil
    
    loop do
      puts '1. Start new game'
      puts '2. Load saved game'

      choice = $stdin.getch
      case choice
      when '1'
        game = Game.new
      when '2'
        saved_games = load_saved_games
        unless saved_games.length.positive?
          puts 'No saved game found'
          next
        end
        puts 'Games Found:'
        saved_games.each_key { |game| puts game }
        loop do
          print 'Enter game name to load: '
          name = gets.chomp
          if saved_games.keys.include?(name)
            game = saved_games[name]
            break
          end
        end
      else
        puts 'Invalid input'
        next
      end
      break
    end

    game.start
  end
end

hangman = Hangman.new
hangman.start
