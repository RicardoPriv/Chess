require_relative "board.rb"
require_relative "mechanics.rb"
require_relative "file_manager.rb"
require_relative "pieces/symbols.rb"

module Gameloop
  include Symbols
  include Mechanics
  include FileManager

  START_PLAYER = :white
  EXIT_CONDITION = "e"
  RETURN_CONDITION = "b"
  SAVE_CONDITION = "save"

  def play
    filename = get_load_game
    return if !filename.nil? && filename.upcase == EXIT_CONDITION.upcase

    if filename.nil?
      board = Board.new
      player = START_PLAYER
    else
      save_game = FileManager.load_chess_game(filename)
      board = Board.new(save_game[:board])
      player = save_game[:player] == "white" ? :white : :black
    end

    board.print_board

    while true
      loop do
        print("\nIt is player #{player}'s turn:\n")
        move_from = get_input("Input the piece you wish to move [A1-H8]: ", board, player) do |i|
          valid_input(i) || i == EXIT_CONDITION
        end

        next if move_from.nil?
        return if move_from == EXIT_CONDITION.upcase

        unless board.valid_player_piece(move_from, player)
          p "invalid player piece"
          break
        end

        moves = board.in_check.nil? ? board.get_possible_moves(move_from) : board.get_in_check_moves(move_from)

        print("\nPlayer #{player}'s King is in Check\n") if board.in_check

        if moves.empty?
          print("No possible moves at tile #{move_from}\n")
          next
        end

        board.add_possible_moves_colors(moves)
        # After possible moves
        board.print_board

        move_to = get_input("Enter a valid move from #{moves}: ", board, player) do |i|
          (valid_input(i.upcase) && moves.include?(i.upcase)) || i == EXIT_CONDITION
        end

        board.revert_possible_moves_colors(move_from, player)

        next if move_to.nil?
        return if move_to == EXIT_CONDITION.upcase

        board.move_piece(move_from, move_to)

        promote_tile = promotion(player, board.board)
        unless promote_tile.empty?
          promote_key = get_promotion_input("Enter symbol of the piece you wish to promote the Pawn to here: ", board, player)
          return if promote_key.upcase == EXIT_CONDITION.upcase

          board.change_piece_to(promote_tile, promote_key, player)
        end

        board.print_board
        player = player == :white ? :black : :white

        break
      end

      if board.checkmate
        player = player == :white ? :black : :white
        print("\nCongratulations #{player} on winning!\n") if board.checkmate
        break
      end

      if board.stalemate
        print("\nGame tied\n")
        break
      end
    end
  end

  def get_load_game
    save_games = FileManager.list_save_games
    selected_game = ""

    loop do
      print("\nPlease type one of the following options:")
      print("\nNew Game")
      save_games.each { |save_game| print("\n#{File.basename(save_game, ".json")}") }
      print("\n")

      selected_game = gets.chomp
      break if selected_game.upcase == "NEW GAME" || save_games.include?(selected_game + ".json")
    end

    selected_game.upcase == "NEW GAME" ? nil : selected_game
  end

  def get_input(instruction, board = nil, player = nil)
    loop do
      print("\n#{instruction}")
      input = gets.chomp

      if input.downcase == SAVE_CONDITION && board && player
        save_and_exit(board, player)
      end

      return input.tap { input[0] = input[0].upcase } if yield(input)
      return nil if input == RETURN_CONDITION

      print("Error: Invalid move\n")
    end
  end

  def get_promotion_input(instruction, board = nil, player = nil)
    loop do
      print("\n#{instruction}")
      input = gets.chomp.upcase

      return save_and_exit(board, player) if input.downcase == SAVE_CONDITION && board && player

      matching_key = Symbols.constants.find { |symb| Symbols.const_get(symb) == input }

      return matching_key.downcase if matching_key && input != Symbols::BLANK &&
                                      input != Symbols::KING && input != Symbols::PAWN
      return EXIT_CONDITION.upcase if input.upcase == EXIT_CONDITION.upcase

      print("Error: Invalid symbol - Choose from #{Symbols.constants.map { |s| Symbols.const_get(s) }.compact.join(', ')}\n")
    end
  end

  def save_and_exit(board, player)
    print("\nEnter filename to save your game as: ")
    filename = gets.chomp

    if File.exist?("saves/#{filename}.json")
      print("File already exists. Overwrite? (y/n): ")
      confirm = gets.chomp.downcase
      return if confirm != 'y'
    end

    FileManager.save_chess_game(filename, board.serialize, player)
    puts "Game saved as '#{filename}.json'. Exiting now!"
    exit
  end

  def valid_input(input)
    return true if input.length == 2 &&
                   input[0].match?(/^[a-hA-H]$/) &&
                   input[1].match?(/^[1-8]$/)

    false
  end
end
