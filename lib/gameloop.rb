require_relative "chessboard"

require_relative "chesspieces"
include Chesspieces

module Gameloop
  EXIT_CONDITION = "e"
  RETURN_CONDITION = "b"

  CU = [
      # White pieces
      { type: :king, color: :white, position: [7, 4], symbol: Chesspieces::PIECES[:king] },
      { type: :rook, color: :white, position: [7, 0], symbol: Chesspieces::PIECES[:rook] },
      { type: :rook, color: :white, position: [5, 5], symbol: Chesspieces::PIECES[:rook] },
      { type: :bishop, color: :white, position: [5, 7], symbol: Chesspieces::PIECES[:bishop] },
      { type: :bishop, color: :white, position: [4, 2], symbol: Chesspieces::PIECES[:bishop] },
      { type: :knight, color: :white, position: [3, 6], symbol: Chesspieces::PIECES[:knight] },
      { type: :pawn, color: :white, position: [4, 4], symbol: Chesspieces::PIECES[:pawn] },
      { type: :pawn, color: :white, position: [6, 3], symbol: Chesspieces::PIECES[:pawn] },
      { type: :queen, color: :white, position: [5, 1], symbol: Chesspieces::PIECES[:queen] },

      # Black pieces
      { type: :king, color: :black, position: [0, 4], symbol: Chesspieces::PIECES[:king] },
      { type: :queen, color: :black, position: [2, 3], symbol: Chesspieces::PIECES[:queen] },
      { type: :rook, color: :black, position: [0, 7], symbol: Chesspieces::PIECES[:rook] },
      { type: :bishop, color: :black, position: [1, 2], symbol: Chesspieces::PIECES[:bishop] },
      { type: :knight, color: :black, position: [2, 6], symbol: Chesspieces::PIECES[:knight] },
      { type: :knight, color: :black, position: [1, 1], symbol: Chesspieces::PIECES[:knight] },
      { type: :pawn, color: :black, position: [3, 4], symbol: Chesspieces::PIECES[:pawn] },
      { type: :pawn, color: :black, position: [1, 5], symbol: Chesspieces::PIECES[:pawn] }
    ]

  def play
    gameboard = Chessboard.new

    gameboard.set_board(CU)

    player = :white

    #p gameboard.valid_moves(:white, "H6")
    #p "---"
    #p gameboard.valid_moves(:black, "H1")
    #p "---"
    #p gameboard.valid_moves(:black, "D3")

    # Gameloop that continues until a winner is found
    while gameboard.winner?.nil?
      # Get player move
      moved = nil
      loop do
        # Print gameboard changes
        gameboard.print_board

        # Get piece to move
        move_from = get_input("Input the piece you wish to move [A1-H8]: ") { |i| valid_input(i.upcase) || i == EXIT_CONDITION }

        next if move_from.nil?
        return if move_from.upcase == EXIT_CONDITION.upcase

        # Get possible moves from the chosen piece
        moves = gameboard.valid_moves(player, move_from)
        if moves.nil?
          print("No possible moves at tile #{move_from}\n")
          next
        end

        # Show moves on board
        gameboard.add_possible_moves_colors(moves)
        gameboard.print_board

        # Ask user which tile to move piece to
        move_to = get_input("Enter a valid move from #{moves}: ") { |i| (valid_input(i.upcase) && moves.include?(i.upcase)) || i == EXIT_CONDITION }
        gameboard.revert_possible_moves_colors(moves, player)

        next if move_to.nil?
        return if move_to.upcase == EXIT_CONDITION.upcase

        # Move piece on board and return the piece if one was taken
        original_piece = gameboard.move_piece(move_from, move_to, player)
        #add taken pieces to some array so I have pieces taken tracked

        # Change player turn
        player = player == :white ? :black : :white

        break
      end


    end
  end

  def get_input(instruction)
    loop do
      print("\n#{instruction}")
      input = gets.chomp

      return input.tap { input[0] = input[0].upcase } if yield(input)
      return nil if input == RETURN_CONDITION

      print("Error: Invalid move\n")
    end
  end

  def valid_input(input)
    return true if input.length == 2 and input[0].match?(/^[a-zA-Z]$/) and input[1].match?(/^\d+$/) and 
                   input[0].upcase.ord >= 65 and input[0].upcase.ord <= 72 and input[1].ord >= 49 and input[1].ord <= 56
    return false
  end
end
