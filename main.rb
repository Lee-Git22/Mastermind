# Methods for manipulating decoding board
module DecodingBoard
  def rules
    puts <<~TEXT
      +++ Rules of Mastermind +++
      ---------------------------
      + Available colors are:
      Red, Green, Blue, Yellow, Orange, Violet, Indigo
      + Duplicates in colors are allowed
      + Codes are the initials of each color like RGBY
      + Correct position AND color is represented with !
      + Correct color only is represented with ?
      + Incorrect guesses is represented with O
      ---------------------------
    TEXT
  end

  def showboard(mastermind)
    puts '-----Current Board------'
    mastermind[:decoding_board].each { |row| puts "++ #{row.to_s.gsub!('"', '')} ++" }
    puts '------------------------'
  end

  def self.new_code_peg(guess)
    code_peg = ''
    guess.each_char { |color| code_peg = code_peg << color << '-' }
    code_peg.chop!
  end

  def self.new_key_peg(mastermind)
    # Takes feedback and formats it like code_peg
    key_peg = ''
    mastermind[:feedback].each_char { |peg| key_peg = key_peg << peg if peg == '!' || peg == '?' }
    until key_peg.length == 4
      key_peg = key_peg + 'O'
    end
    key_peg.gsub!('', '-')
    key_peg[1..].chop!
  end

  def self.add_peg(mastermind, code_peg, key_peg)
    mastermind[:decoding_board].push([code_peg, key_peg])
  end
end

# Methods for codebreaker
class Codebreaker
  include DecodingBoard

  def guess
    puts 'Enter your guess as 4 characters: (enter help for rules)'
    gets.chomp.upcase
  end

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

  def make_code
    code = ''
    rng = Random.new
    until code.length == 4
      tmp = VALID_COLORS[rng.rand(0...6)]
      code = code << tmp unless code.include?(tmp)
    end
    code
  end

  def check_color(mastermind)

    4.times do |peg|
      if mastermind[:feedback].include?(mastermind[:guess][peg])
        mastermind[:feedback] = mastermind[:feedback] << '?'
      end
    end

    mastermind[:feedback]
  end

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

  def feedback
    # Checks for correct positions and colors, then remove those indexes
    # Checks for correct colors for remaining indexes
    # Generate feedback based on count for 1 and 2
  end
end

mastermind = {
  player: '',
  cpu: '',
  turns_left: 12,
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

puts "code is: #{mastermind[:code] = mastermind[:cpu].make_code}"

until mastermind[:player].guess_check(mastermind[:guess]) != 'fail'
  mastermind[:guess] = mastermind[:player].guess
  code_peg = DecodingBoard.new_code_peg(mastermind[:guess])
end



puts mastermind[:feedback] = mastermind[:cpu].check_both(mastermind)
puts mastermind[:feedback] = mastermind[:cpu].check_color(mastermind)

key_peg = DecodingBoard.new_key_peg(mastermind)
DecodingBoard.add_peg(mastermind, code_peg, key_peg)
mastermind[:player].showboard(mastermind)