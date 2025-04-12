require_relative "board.rb"
require_relative "mechanics.rb"
require_relative "pieces/symbols.rb"

module Gameloop
  include Symbols
  include Mechanics

  EXIT_CONDITION = "e"
  RETURN_CONDITION = "b"

  TEST = [
    # White pieces
    { type: :king, color: :white, position: [5, 6], symbol: "Q" },
    { type: :rook, color: :white, position: [6, 6], symbol: "R" },
    { type: :pawn, color: :white, position: [6, 4], symbol: "R" },

    # Black pieces
    { type: :king, color: :black, position: [7, 7], symbol: "K" },
    { type: :pawn, color: :black, position: [5, 5], symbol: "R" }
  ]

=begin
  TEST = [
    # White pieces (now on bottom)
    { type: :king, color: :white, position: [0, 4], symbol: "K" },
    { type: :rook, color: :white, position: [0, 0], symbol: "R" },
    { type: :rook, color: :white, position: [0, 7], symbol: "R" },
    { type: :pawn, color: :white, position: [4, 1], symbol: "P" }, # White pawn ready to en passant
    { type: :pawn, color: :white, position: [1, 5], symbol: "P" }, # White pawn just moved two steps

    # Black pieces (now on top)
    { type: :king, color: :black, position: [7, 4], symbol: "K" },
    { type: :rook, color: :black, position: [7, 7], symbol: "R" },
    { type: :rook, color: :black, position: [7, 0], symbol: "R" },
    { type: :bishop, color: :black, position: [5, 3], symbol: "B" },
    { type: :pawn, color: :black, position: [3, 4], symbol: "P" }, # Black pawn just moved two steps
    { type: :pawn, color: :black, position: [2, 5], symbol: "P" }, # Black pawn just moved two steps
    { type: :pawn, color: :black, position: [1, 1], symbol: "P" } # Black pawn ready to en passant
  ]
=end

=begin
    # White pieces (now on bottom)
    { type: :king, color: :white, position: [0, 4], symbol: "K" },
    { type: :rook, color: :white, position: [0, 0], symbol: "R" },
    { type: :rook, color: :white, position: [2, 5], symbol: "R" },
    { type: :bishop, color: :white, position: [2, 7], symbol: "B" },
    { type: :bishop, color: :white, position: [3, 2], symbol: "B" },
    { type: :knight, color: :white, position: [4, 6], symbol: "N" },
    { type: :pawn, color: :white, position: [3, 4], symbol: "P" },
    { type: :pawn, color: :white, position: [1, 3], symbol: "P" },
    { type: :queen, color: :white, position: [2, 1], symbol: "Q" },
  
    # Black pieces (now on top)
    { type: :king, color: :black, position: [7, 4], symbol: "K" },
    { type: :queen, color: :black, position: [5, 3], symbol: "Q" },
    { type: :rook, color: :black, position: [7, 7], symbol: "R" },
    { type: :bishop, color: :black, position: [6, 2], symbol: "B" },
    { type: :knight, color: :black, position: [5, 6], symbol: "N" },
    { type: :knight, color: :black, position: [6, 1], symbol: "N" },
    { type: :pawn, color: :black, position: [4, 4], symbol: "P" },
    { type: :pawn, color: :black, position: [1, 6], symbol: "P" }
  ]
=end

  # Gameloop that continues until a winner is found
  def play
    board = Board.new
    board.setup_board(TEST)
    player = :white
    board.print_board

    while true #gameboard.winner?.nil?
      # Get player move
      loop do
        move_from = get_input("Input the piece you wish to move [A1-H8]: ") { |i| valid_input(i) || i == EXIT_CONDITION }

        next if move_from.nil?
        return if move_from == EXIT_CONDITION.upcase

        # Ensure tile selected has a valid piece for the player
        unless board.valid_player_piece(move_from, player)
          p "invalid player piece"
          break
        end

        # Get possible moves and piece from the selected tile
        moves = board.in_check.nil? ? board.get_possible_moves(move_from) : board.get_in_check_moves(move_from)
        p moves

        # Resets and asks again if no possible moves
        if moves == []
          print("No possible moves at tile #{move_from}\n")
          print("King is in Check\n") if board.in_check
          next
        end

        # Show moves on board
        board.add_possible_moves_colors(moves)
        p "After possible moves"
        board.print_board

        # Ask user which tile to move piece to
        move_to = get_input("Enter a valid move from #{moves}: ") do |i|
          (valid_input(i.upcase) && moves.include?(i.upcase)) || i == EXIT_CONDITION
        end

        board.revert_possible_moves_colors(move_from, player)

        next if move_to.nil?
        return if move_to == EXIT_CONDITION.upcase

        # Move piece on board and return the piece if one was taken
        board.move_piece(move_from, move_to)

        # Logic that allows player to promote a Pawn if it reaches the end of the board
        promote_tile = promotion(player, board.board)
        unless promote_tile.empty?
          promote_key = get_promotion_input("Enter symbol of the piece you wish to promote the Pawn to here: ")
          return if promote_key.upcase == EXIT_CONDITION.upcase

          board.change_piece_to(promote_tile, promote_key, player)
        end

        # Print gameboard changes
        board.print_board

        # Change player turn
        player = player == :white ? :black : :white

        break
      end

      p board.stalemate
      break if board.checkmate || board.stalemate
    end

    p "yay"
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

  def get_promotion_input(instruction)
    loop do
      print("\n#{instruction}")
      input = gets.chomp.upcase

      matching_key = Symbols.constants.find { |symb| Symbols.const_get(symb) == input }

      return matching_key.downcase if matching_key && input != Symbols::BLANK && 
                                      input != Symbols::KING && input != Symbols::PAWN
      return EXIT_CONDITION.upcase if input.upcase == EXIT_CONDITION.upcase

      print("Error: Invalid symbol - Choose from #{Symbols.constants.map { |s| Symbols.const_get(s) }.compact.join(', ')}\n")
    end
  end

  def valid_input(input)
    return true if input.length == 2 && input[0].match?(/^[a-zA-Z]$/) && input[1].match?(/^\d+$/) && 
                   input[0].upcase.ord >= 65 && input[0].upcase.ord <= 72 && input[1].ord >= 49 && input[1].ord <= 56

    false
  end
end
