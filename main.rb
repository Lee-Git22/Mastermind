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

  # Prompts user to select role for new game
  def self.assign_roles(gamestate)
    puts 'Enter 1 to play as Codebreaker, and 2 to play as Codemaker'
    case gets.chomp
    when '1'
      gamestate[:player] = Codebreaker.new
      gamestate[:cpu] = Codemaker.new
      gamestate[:roles] = true

    when '2'
      gamestate[:player] = Codemaker.new
      gamestate[:cpu] = Codebreaker.new
      gamestate[:roles] = true

    else
      gamestate[:roles] = false
    end
  end

  # Outputs player role
  def self.declare_role(gamestate)
    puts <<~TEXT
      You are playering as #{gamestate[:player].class}...
      ---------------------------
    TEXT
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
      rules
      'fail'
    elsif input.length == 4
      input.each_char do |color|
        return 'fail' unless VALID_COLORS.include?(color)
      end
    else
      'fail'
    end
  end

  # Ensures feedback is in correct format
  def self.validate_feedback(gamestate)
    if gamestate[:feedback].upcase == 'HELP'
      rules
      'fail'
    elsif gamestate[:feedback].length <= 4
      gamestate[:feedback].each_char {|char| return 'fail' unless char == '?' || char == '!' }
    else
      'fail'
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

  # Checks for winner
  def self.check_winner(gamestate)
    if gamestate[:feedback] == '!!!!'
      gamestate[:winner] = gamestate[:player].instance_of?(Codebreaker) ? 'Player' : 'Computer'
    elsif gamestate[:turn] == 8
      gamestate[:winner] = gamestate[:player].instance_of?(Codemaker) ? 'Player' : 'Computer'
    end
  end

  # Updates parameters for next turn
  def self.next_turn(gamestate)
    gamestate[:memory] = gamestate[:guess]
    gamestate[:guess] = 'fail'
    gamestate[:turn] += 1
  end

  # Outputs winner
  def self.game_over(gamestate)
    puts "The code was #{gamestate[:code]}, #{gamestate[:winner]} Wins!"
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
end

# Methods for codebreaker
class Codebreaker
  include Mastermind

  # Inputs user guess
  def input_guess
    puts 'Enter your guess as 4 characters: (enter help for rules)'
    gets.chomp.upcase
  end

  # Creates smart guess for CPU using feedback
  def make_smart_guess(gamestate)
    rng = Random.new
    code = ''
    unless gamestate[:turn] == 1
      puts 'hello'
      puts gamestate[:feedback]
      puts gamestate[:memory]
      until code.length == gamestate[:memory].length
        color = gamestate[:memory][rng.rand(0...4)]
        code += color unless code.include?(color)
      end
    end

    until code.length == 4
      color = VALID_COLORS[rng.rand(0...6)]
      code += color unless code.include?(color)
    end
    gamestate[:feedback] = 'fail'
    code
  end
end

# Methods for codemaker
class Codemaker
  include Mastermind

  # Inputs user code
  def input_code
    puts 'Enter your code as 4 characters: (enter help for rules)'
    gets.chomp.upcase
  end

  # Inputs user feedback
  def input_feedback(gamestate)
    puts "Your code is: #{gamestate[:code]}..."
    puts "Computer guessed #{gamestate[:guess]}: Enter your feedback with '!' and '?' (enter help for rules)"
    gets.chomp.upcase
  end

  # Modify feedback by checking guess for correct position AND color
  def check_both(gamestate)
    gamestate[:feedback] = ''
    4.times do |peg|
      gamestate[:feedback] += if gamestate[:code][peg] == gamestate[:guess][peg]
                                '!'
                              else
                                gamestate[:code][peg]
                              end
    end
    gamestate[:feedback]
  end

  # Modify feedback by checking guess with remaining code that excludes duplicate guesses
  def check_color(gamestate)
    filtered = gamestate[:guess].chars.uniq
    filtered = filtered.join.to_s
    filtered.length.times do |peg|
      gamestate[:feedback] += '?' if gamestate[:feedback].include?(filtered[peg])
    end
    gamestate[:feedback]
  end

  # Creates complete feedback
  def new_feedback(gamestate)
    check_both(gamestate)
    check_color(gamestate)
  end
end

# Starting Gamestate parameters
gamestate = {
  player: '',
  cpu: '',
  roles: false,
  turn: 1,
  decoding_board: [],
  guess: 'fail',
  memory: '',
  code: 'fail',
  feedback: 'fail',
  winner: ''
}

VALID_COLORS = ['R', 'G', 'B', 'Y', 'O', 'V', 'I']

# Assign Roles
gamestate[:roles] = Mastermind.assign_roles(gamestate) until gamestate[:roles] == true
Mastermind.declare_role(gamestate)

# Play game for 8 turns or until code is guessed
until gamestate[:turn] > 9 || gamestate[:winner] != ''

  # Gameplay if player is codebreaker
  if gamestate[:player].instance_of?(Codebreaker)

    # Generate code for cpu
    gamestate[:code] = gamestate[:cpu].make_code if gamestate[:code] == 'fail'

    # Prompts user to enter valid guess and create code peg
    until Mastermind.validate_input(gamestate[:guess]) != 'fail'
      gamestate[:guess] = gamestate[:player].input_guess
      code_peg = Mastermind.new_code_peg(gamestate[:guess])
    end

    # Generate feedback for cpu
    gamestate[:feedback] = gamestate[:cpu].new_feedback(gamestate)
  
  # Gameplay if player is codemaker
  else
    # Prompts user to enter valid code
    until Mastermind.validate_input(gamestate[:code]) != 'fail'
      gamestate[:code] = gamestate[:player].input_code
    end

    # Generate guess for cpu and reset feedback
    gamestate[:guess] = gamestate[:cpu].make_smart_guess(gamestate)
    code_peg = Mastermind.new_code_peg(gamestate[:guess])

    # Prompts user to input feedback
    until Mastermind.validate_feedback(gamestate) != 'fail'
      gamestate[:feedback] = gamestate[:player].input_feedback(gamestate)
    end
  end

  # Create key peg for decoding board
  key_peg = Mastermind.new_key_peg(gamestate)

  # Update and show decoding board
  Mastermind.add_peg(gamestate, code_peg, key_peg)
  Mastermind.showboard(gamestate)

  # Check winner and prepare for next turn
  Mastermind.check_winner(gamestate)
  Mastermind.next_turn(gamestate)
end

# Display game result
Mastermind.game_over(gamestate)
