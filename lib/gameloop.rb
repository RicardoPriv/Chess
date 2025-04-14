# frozen_string_literal: true

require_relative 'board'
require_relative 'mechanics'
require_relative 'file_manager'
require_relative 'pieces/symbols'

module Gameloop
  include Symbols
  include Mechanics
  include FileManager

  START_PLAYER = :white
  EXIT_CONDITION = 'e'
  RETURN_CONDITION = 'b'
  SAVE_CONDITION = 'save'

  # Chess gameplay gameloop
  def play
    # Loading game/starting new game logic
    filename = get_load_game
    return if !filename.nil? && filename.upcase == EXIT_CONDITION.upcase

    if filename.nil?
      board = Board.new
      player = START_PLAYER
    else
      save_game = FileManager.load_chess_game(filename)
      board = Board.new(save_game[:board])
      player = save_game[:player] == 'white' ? :white : :black
    end

    # Show start state of board before beginning to play
    board.print_board

    # Core gameloop
    loop do
      print("\nIt is player #{player}'s turn:\n")
      # Getting the user piece they wish to move
      move_from = get_input('Input the piece you wish to move [A1-H8]: ', board, player) do |i|
        valid_input(i) || i == EXIT_CONDITION
      end

      next if move_from.nil?
      return if move_from == EXIT_CONDITION.upcase

      # Validates the input tile
      unless board.valid_player_piece(move_from, player)
        p 'invalid player piece'
        next
      end

      moves = board.in_check.nil? ? board.get_possible_moves(move_from) : board.get_in_check_moves(move_from)

      print("\nPlayer #{player}'s King is in Check\n") if board.in_check

      if moves.empty?
        print("No possible moves at tile #{move_from}\n")
        next
      end

      # Displayes the selected pieces possible movement
      board.add_possible_moves_colors(moves)
      board.print_board

      # Prompts for the tile to move the piece to from the player
      move_to = get_input("Enter a valid move from #{moves}: ", board, player) do |i|
        (valid_input(i.upcase) && moves.include?(i.upcase)) || i == EXIT_CONDITION
      end

      # Removes the possible moves highlighted spaces
      board.revert_possible_moves_colors(move_from, player)

      next if move_to.nil?
      return if move_to == EXIT_CONDITION.upcase

      # Moves the piece
      board.move_piece(move_from, move_to)

      # Prompts for Pawn promotion if Pawn reaches end of board
      promote_tile = promotion(player, board.board)
      unless promote_tile.empty?
        promote_key = get_promotion_input('Enter symbol of the piece you wish to promote the Pawn to here: ', board,
                                          player)
        return if promote_key.upcase == EXIT_CONDITION.upcase

        board.change_piece_to(promote_tile, promote_key, player)
      end

      # Prints end of turn board state
      board.print_board
      # Change player turn
      player = player == :white ? :black : :white

      # Gameover if checkmate
      if board.checkmate
        player = player == :white ? :black : :white
        print("\nCongratulations #{player} on winning!\n") if board.checkmate
        break
      end

      # Gameover if stalemate
      if board.stalemate
        print("\nGame tied\n")
        break
      end
    end
  end

  # Displayes saved games and prompts the user if they want to load a state or start a new game
  def get_load_game
    save_games = FileManager.list_save_games
    selected_game = ''

    loop do
      print("\nPlease type one of the following options:")
      print("\nNew Game")
      save_games.each { |save_game| print("\n#{File.basename(save_game, '.json')}") }
      print("\n")

      selected_game = gets.chomp
      break if selected_game.upcase == 'NEW GAME' || save_games.include?("#{selected_game}.json")
    end

    selected_game.upcase == 'NEW GAME' ? nil : selected_game
  end

  # Gets the input of the user
  def get_input(instruction, board = nil, player = nil)
    loop do
      print("\n#{instruction}")
      input = gets.chomp

      save_and_exit(board, player) if input.downcase == SAVE_CONDITION && board && player

      return input.tap { input[0] = input[0].upcase } if yield(input)
      return nil if input == RETURN_CONDITION

      print("Error: Invalid move\n")
    end
  end

  # Prompts for input if Pawn needs a promotion
  def get_promotion_input(instruction, board = nil, player = nil)
    loop do
      print("\n#{instruction}")
      input = gets.chomp.upcase

      return save_and_exit(board, player) if input.downcase == SAVE_CONDITION && board && player

      matching_key = Symbols.constants.find { |symb| Symbols.const_get(symb) == input }

      return matching_key.downcase if matching_key && input != Symbols::BLANK &&
                                      input != Symbols::KING && input != Symbols::PAWN
      return EXIT_CONDITION.upcase if input.upcase == EXIT_CONDITION.upcase

      print("Error: Invalid symbol - Choose from #{Symbols.constants.map do |s|
        Symbols.const_get(s)
      end.compact.join(', ')}\n")
    end
  end

  # Prompt for saving a game
  def save_and_exit(board, player)
    print("\nEnter filename to save your game as: ")
    filename = gets.chomp

    if File.exist?("saves/#{filename}.json")
      print('File already exists. Overwrite? (y/n): ')
      confirm = gets.chomp.downcase
      return if confirm != 'y'
    end

    FileManager.save_chess_game(filename, board.serialize, player)
    puts "Game saved as '#{filename}.json'. Exiting now!"
    exit
  end

  # Determines if the input is valid
  def valid_input(input)
    return true if input.length == 2 &&
                   input[0].match?(/^[a-hA-H]$/) &&
                   input[1].match?(/^[1-8]$/)

    false
  end
end
