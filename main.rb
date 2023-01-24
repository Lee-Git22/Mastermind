# Methods for manipulating decoding board
module Mastermind
  # Outputs game rules
  def self.rules
    puts <<~TEXT
      +++ Rules of MASTERMIND +++
      ---------------------------
      + Available colors are:
      Red, Green, Blue, Yellow, Orange, Violet, Indigo
      + Duplicates in code is NOT allowed
      + Codes are the initials of each color like RGBY
      + Correct position AND color is represented with !
      + Correct color only is represented with ?
      + Incorrect guesses is represented with O
      + The Codebreaker has 8 turns to guess the code
      ---------------------------
    TEXT
  end

  def self.assign_roles(gamestate)
    puts 'Enter 1 to play as Codebreaker, and 2 to play as Codemaker'
    case gets.chomp
    when '1'
      gamestate[:player] = Codebreaker.new
      gamestate[:cpu] = Codemaker.new
    when '2'
      gamestate[:player] = Codemaker.new
      gamestate[:cpu] = Codebreaker.new
    else
      'fail'
    end
    puts "You are playering as #{gamestate[:player].class}..."
  end

  # Shows current board configuration
  def self.showboard(gamestate)
    puts '-------MASTERMIND-------'
    gamestate[:decoding_board].each_with_index { |row, i| puts "#{i + 1}. #{row.to_s.gsub!('"', '')} ||" }
    puts '------------------------'
  end

  # Ensures guess is in correct format
  def self.validate_input(input)
    if input == 'HELP'
      self.rules
      'fail'
    elsif input.length != 4
      'fail'
    else
      input.each_char do |color|
        return 'fail' unless VALID_COLORS.include?(color)
      end
    end
  end

  # Creates new code peg from guess in X-X-X-X format
  def self.new_code_peg(guess)
    code_peg = ''
    guess.each_char { |color| code_peg = code_peg << color << '-' }
    code_peg.chop!
  end

  # Creates new key peg from feedback in Y-Y-Y-Y format
  def self.new_key_peg(gamestate)
    key_peg = ''
    gamestate[:feedback].each_char { |peg| key_peg = key_peg << peg if peg == '!' || peg == '?' }
    key_peg += 'O' until key_peg.length == 4
    key_peg.gsub!('', '-')
    key_peg[1..].chop!
  end

  # Adds formatted pegs to decoding board
  def self.add_peg(gamestate, code_peg, key_peg)
    gamestate[:decoding_board].push([code_peg, key_peg])
  end

  def self.check_winner(gamestate)
    if gamestate[:feedback] == '!!!!'
      gamestate[:winner] = gamestate[:player].instance_of?(Codebreaker) ? 'Player' : 'Computer'
    elsif gamestate[:turn] == 8
      gamestate[:winner] = gamestate[:player].instance_of?(Codemaker) ? 'Player' : 'Computer'
    end
  end

  def self.next_turn(gamestate)
    gamestate[:feedback] = ''
    gamestate[:guess] = 'fail'
    gamestate[:turn] += 1
  end

  def self.game_over(gamestate)
    puts "#{gamestate[:winner]} Wins!"
  end
end

# Methods for codebreaker
class Codebreaker
  include Mastermind

  # Inputs user guess
  def input_guess
    puts 'Enter your guess as 4 characters: (enter help for rules)'
    gets.chomp.upcase
  end

end

# Methods for codemaker
class Codemaker
  include Mastermind

  # Inputs user guess
  def input_code
    puts 'Enter your code as 4 characters: (enter help for rules)'
    gets.chomp.upcase
  end

  # Creates a randomly selected code from valid color pool
  def make_code
    code = ''
    rng = Random.new
    until code.length == 4
      color = VALID_COLORS[rng.rand(0...6)]
      code += color unless code.include?(color)
    end
    code
  end

  # Modify feedback by checking guess for correct position AND color
  def check_both(gamestate)
    4.times do |peg|
      gamestate[:feedback] += if gamestate[:code][peg] == gamestate[:guess][peg]
                                '!'
                              else
                                gamestate[:code][peg]
                              end
    end
    gamestate[:feedback]
  end

  # Modify feedback by checking guess with modified code that excludes correct position and color pegs
  def check_color(gamestate)
    4.times do |peg|
      gamestate[:feedback] += '?' if gamestate[:feedback].include?(gamestate[:guess][peg])
    end
    gamestate[:feedback]
  end

  # Creates complete feedback
  def new_feedback(gamestate)
    check_both(gamestate)
    check_color(gamestate)
  end
end

gamestate = {
  player: '',
  cpu: '',
  turn: 1,
  decoding_board: [],
  guess: '',
  code: '',
  feedback: '',
  winner: ''
}

VALID_COLORS = ['R', 'G', 'B', 'Y', 'O', 'V', 'I']

# As codemaker
  # Enter code
  # Generage cpu guess
  # Enter feedback
  # Modify cpu guess based on feedback
  # Display game result


### For debugging

# Assign Roles
Mastermind.assign_roles(gamestate)

# Play game for 8 turns or until code is guessed
until gamestate[:turn] > 9 || gamestate[:winner] != ''

  # Gameplay if player is codebreaker
  if gamestate[:player].instance_of?(Codebreaker)

    # Generate code for cpu
    gamestate[:code] = gamestate[:cpu].make_code

    # Enter guess and code peg
    until Mastermind.validate_input(gamestate[:guess]) != 'fail'
      gamestate[:guess] = gamestate[:player].input_guess
      code_peg = Mastermind.new_code_peg(gamestate[:guess])
    end

    # Generate feedback for cpu and key peg
    gamestate[:feedback] = gamestate[:cpu].new_feedback(gamestate)
    key_peg = Mastermind.new_key_peg(gamestate)
  else
    until Mastermind.validate_input(gamestate[:code]) != 'fail'
      gamestate[:code] = gamestate[:player].input_code
      # code_peg = Mastermind.new_code_peg(gamestate[:guess])
    end

  end

  # Display game result
  Mastermind.add_peg(gamestate, code_peg, key_peg)
  Mastermind.showboard(gamestate)

  Mastermind.check_winner(gamestate)
  Mastermind.next_turn(gamestate)
end

Mastermind.game_over(gamestate)
