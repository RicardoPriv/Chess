require_relative "chessboard"

require_relative "chesspieces.rb"
include Chesspieces

module Gameloop
  EXIT_CONDITION = "e"
  RETURN_CONDITION = "b"

  def play
    gameboard = Chessboard.new
    custom_pieces = [
      # White pieces
      { type: :king, color: :white, position: [7, 4], symbol: Chesspieces::PIECES[:king] },
      { type: :rook, color: :white, position: [7, 0], symbol: Chesspieces::PIECES[:rook] },
      { type: :rook, color: :white, position: [5, 5], symbol: Chesspieces::PIECES[:rook] },
      { type: :bishop, color: :white, position: [4, 2], symbol: Chesspieces::PIECES[:bishop] },
      { type: :knight, color: :white, position: [3, 6], symbol: Chesspieces::PIECES[:knight] },
      { type: :pawn, color: :white, position: [4, 4], symbol: Chesspieces::PIECES[:pawn] },
      { type: :pawn, color: :white, position: [6, 3], symbol: Chesspieces::PIECES[:pawn] },

      # Black pieces
      { type: :king, color: :black, position: [0, 4], symbol: Chesspieces::PIECES[:king] },
      { type: :queen, color: :black, position: [2, 3], symbol: Chesspieces::PIECES[:queen] },
      { type: :rook, color: :black, position: [0, 7], symbol: Chesspieces::PIECES[:rook] },
      { type: :bishop, color: :white, position: [5, 7], symbol: Chesspieces::PIECES[:bishop] },
      { type: :bishop, color: :black, position: [1, 2], symbol: Chesspieces::PIECES[:bishop] },
      { type: :knight, color: :black, position: [2, 6], symbol: Chesspieces::PIECES[:knight] },
      { type: :pawn, color: :black, position: [3, 4], symbol: Chesspieces::PIECES[:pawn] },
      { type: :pawn, color: :black, position: [1, 5], symbol: Chesspieces::PIECES[:pawn] }
    ]

    gameboard.set_board(custom_pieces)
    gameboard.print_board

    p gameboard.valid_moves(:white, "F6")
    p "---"
    p gameboard.valid_moves(:black, "H1")
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
