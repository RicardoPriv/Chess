require_relative "chessboard"

module Gameloop
  EXIT_CONDITION = "e"
  RETURN_CONDITION = "b"

  def play
    gameboard = Chessboard.new
    gameboard.print_board


    p gameboard.valid_moves(:white, "A2")
    p "---"
    p gameboard.valid_moves(:black, "A7")
    return
    while gameboard.winner?.nil?
      input = get_input("Get input hehe")
      return if input.nil?
      input[0] = input[0].upcase
      #gameboard.print_board
    end

  end

  def get_input(instruction)
    while true
      print("\n#{instruction}:")
      input = gets.chomp
      return input if valid_input(input)
      return nil if input == EXIT_CONDITION or input == RETURN_CONDITION
      print("Invalid move\n")
    end
  end

  def valid_input(input)
    return true if input.length == 2 and input[0].match?(/^[a-zA-Z]$/) and input[1].match?(/^\d+$/) and 
                   input[0].upcase.ord >= 65 and input[0].upcase.ord <= 72 and input[1].ord >= 49 and input[1].ord <= 56
    return false
  end
end
