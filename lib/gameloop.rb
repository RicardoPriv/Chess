require_relative "board.rb"

module Gameloop
  EXIT_CONDITION = "e"
  RETURN_CONDITION = "b"

  TEST = [
    # White pieces
    { type: :king, color: :white, position: [7, 4], symbol: "K" },
    { type: :rook, color: :white, position: [7, 0], symbol: "R" },
    { type: :rook, color: :white, position: [5, 5], symbol: "R" },
    { type: :bishop, color: :white, position: [5, 7], symbol: "B" },
    { type: :bishop, color: :white, position: [4, 2], symbol: "B" },
    { type: :knight, color: :white, position: [3, 6], symbol: "N" },
    { type: :pawn, color: :white, position: [4, 4], symbol: "P" },
    { type: :pawn, color: :white, position: [6, 3], symbol: "P" },
    { type: :queen, color: :white, position: [5, 1], symbol: "Q" },

    # Black pieces
    { type: :king, color: :black, position: [0, 4], symbol: "K" },
    { type: :queen, color: :black, position: [2, 3], symbol: "Q" },
    { type: :rook, color: :black, position: [0, 7], symbol: "R" },
    { type: :bishop, color: :black, position: [1, 2], symbol: "B" },
    { type: :knight, color: :black, position: [2, 6], symbol: "N" },
    { type: :knight, color: :black, position: [1, 1], symbol: "N" },
    { type: :pawn, color: :black, position: [3, 4], symbol: "P" },
    { type: :pawn, color: :black, position: [1, 5], symbol: "P" }
  ]

  # Gameloop that continues until a winner is found
  def play
    board = Board.new
    board.set_board(TEST)
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

        # Print gameboard changes
        board.print_board

        # Change player turn
        player = player == :white ? :black : :white

        break
      end

      p board.checkmate
      break if board.checkmate
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

  def valid_input(input)
    return true if input.length == 2 && input[0].match?(/^[a-zA-Z]$/) && input[1].match?(/^\d+$/) && 
                   input[0].upcase.ord >= 65 && input[0].upcase.ord <= 72 && input[1].ord >= 49 && input[1].ord <= 56

    false
  end
end
