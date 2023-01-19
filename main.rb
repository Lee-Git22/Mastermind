# As codebreaker
# Generate code for cpu
  # Prompt guess
  # Generate feedback
# Display game result

# As codemaker
# Prompt code
  # Generage cpu guess
  # Give feedback
    # Modify cpu guess based on feedback
# Display game result

module DecodingBoard
  def showboard
    puts 'this is the board'
  end

  private
  def self.update_board
    puts 'board updated'
  end
end

class Codebreaker
  include DecodingBoard

  def guess
  end
end

class Codemaker
  def make_code
  end

  def feedback
  end
end

mastermind = {
  :player => '',
  :cpu => '',
  :guesses => 12,
  :decoding_board => []
}

mastermind[:player] = Codebreaker.new
mastermind[:player].showboard
DecodingBoard.update_board