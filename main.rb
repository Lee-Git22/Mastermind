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

module DecodingBoard
  def rules
    puts <<~TEXT
      +++ Rules of Mastermind +++
      ---------------------------
      + There are no duplicates in colors for the code
      + Available colors are:
      Red, Green, Blue, Yellow, Orange, Violet, Indigo
      + Codes are the initials of each color like RGBY
      + Correct position AND color is represented with !
      + Correct color only is represented with ?
      + Incorrect guesses is represented with O
    TEXT
  end

  def showboard(mastermind)
    puts '-----Current Board------'
    mastermind[:decoding_board].each { |row| puts "++ #{row.to_s.gsub!('"', '')} ++" }
    puts '------------------------'
  end

  private

  def self.new_code_peg(guess)
    code_peg = ''
    guess.each_char {|color| code_peg = code_peg + color + '-'}
    code_peg.chop!
  end

  def self.new_key_peg(feedback)
    # Takes feedback and formats it like code_peg
    'O-O-O-O'
  end

  def self.add_peg(mastermind, code_peg, key_peg)
    mastermind[:decoding_board].push([code_peg, key_peg])
  end
end

class Codebreaker
  include DecodingBoard

  def guess
    puts 'Enter your guess as 4 characters: (enter help for rules)'
    guess = gets.chomp
    if guess == 'help'
      self.rules
    else
      guess
    end
  end
end

class Codemaker
  def make_code
    # RNG 1-7 4 times and reroll if duplicates
  end

  def feedback
    # Checks for correct positions and colors, then remove those indexes
    # Checks for correct colors for remaining indexes
    # Generate feedback based on count for 1 and 2
  end
end

mastermind = {
  player: '',
  cpu: '',
  guesses: 12,
  decoding_board: [
  ]
}


### For debugging
mastermind[:player] = Codebreaker.new
mastermind[:player].showboard(mastermind)

guess = mastermind[:player].guess
# a = DecodingBoard.new_code_peg(guess)
# b = DecodingBoard.new_key_peg
# DecodingBoard.add_peg(mastermind, a, b)
# mastermind[:player].showboard(mastermind)
