# Methods for manipulating decoding board
module DecodingBoard
  # Outputs game rules
  def rules
    puts <<~TEXT
      +++ Rules of Mastermind +++
      ---------------------------
      + Available colors are:
      Red, Green, Blue, Yellow, Orange, Violet, Indigo
      + Duplicates in code is NOT allowed
      + Codes are the initials of each color like RGBY
      + Correct position AND color is represented with !
      + Correct color only is represented with ?
      + Incorrect guesses is represented with O
      ---------------------------
    TEXT
  end

  # Shows current board configuration
  def showboard(mastermind)
    puts '-------MASTERMIND-------'
    mastermind[:decoding_board].each { |row| puts "#{mastermind[:turn]}. #{row.to_s.gsub!('"', '')} ||" }
    puts '------------------------'
  end

  # Creates new code peg from guess in X-X-X-X format
  def self.new_code_peg(guess)
    code_peg = ''
    guess.each_char { |color| code_peg = code_peg << color << '-' }
    code_peg.chop!
  end

  # Creates new key peg from feedback in Y-Y-Y-Y format
  def self.new_key_peg(mastermind)
    key_peg = ''
    mastermind[:feedback].each_char { |peg| key_peg = key_peg << peg if peg == '!' || peg == '?' }
    key_peg += 'O' until key_peg.length == 4
    key_peg.gsub!('', '-')
    key_peg[1..].chop!
  end

  # Adds formatted pegs to decoding board
  def self.add_peg(mastermind, code_peg, key_peg)
    mastermind[:decoding_board].push([code_peg, key_peg])
  end
end

# Methods for codebreaker
class Codebreaker
  include DecodingBoard

  # Inputs user guess 
  def guess
    puts 'Enter your guess as 4 characters: (enter help for rules)'
    gets.chomp.upcase
  end

  # Ensures guess is in correct format
  def guess_check(guess)
    if guess == 'HELP'
      rules
      'fail'
    elsif guess.length != 4
      'fail'
    else
      guess.each_char do |color|
        return 'fail' unless VALID_COLORS.include?(color)
      end
    end
  end
end

# Methods for codemaker
class Codemaker
  include DecodingBoard

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
  def check_both(mastermind)
    mastermind[:feedback] = ''
    4.times do |peg|
      if mastermind[:code][peg] == mastermind[:guess][peg]
        mastermind[:feedback] = mastermind[:feedback] << '!'
      else
        mastermind[:feedback] = mastermind[:feedback] << mastermind[:code][peg]
      end
    end
    mastermind[:feedback]
  end

  # Modify feedback by checking guess with modified code that excludes correct position and color pegs
  def check_color(mastermind)
    4.times do |peg|
      mastermind[:feedback] += '?' if mastermind[:feedback].include?(mastermind[:guess][peg])
    end
    mastermind[:feedback]
  end

  # Creates complete feedback
  def new_feedback(mastermind)
    check_both(mastermind)
    check_color(mastermind)
  end
end

mastermind = {
  player: '',
  cpu: '',
  turn: 1,
  decoding_board: [
  ],
  guess: '',
  code: '',
  feedback: ''
}

VALID_COLORS = ['R', 'G', 'B', 'Y', 'O', 'V', 'I']

### Gameflow for player
# As codebreaker
  # Generate code for cpu
  # Enter guess
  # Generate feedback for cpu
  # Display game result

# As codemaker
  # Enter code
  # Generage cpu guess
  # Enter feedback
    # Modify cpu guess based on feedback
  # Display game result


### For debugging
mastermind[:player] = Codebreaker.new
mastermind[:cpu] = Codemaker.new

mastermind[:code] = mastermind[:cpu].make_code
# puts "code is: #{mastermind[:code] = mastermind[:cpu].make_code}"

until mastermind[:player].guess_check(mastermind[:guess]) != 'fail'
  mastermind[:guess] = mastermind[:player].guess
  code_peg = DecodingBoard.new_code_peg(mastermind[:guess])
end

mastermind[:feedback] = mastermind[:cpu].new_feedback(mastermind)
key_peg = DecodingBoard.new_key_peg(mastermind)

DecodingBoard.add_peg(mastermind, code_peg, key_peg)
mastermind[:player].showboard(mastermind)