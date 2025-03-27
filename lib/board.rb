require "colorize"
require_relative "./pieces/rook.rb"

Dir["#{__dir__}/pieces/*.rb"].each { |file| require_relative file }

# Class that handles chessboard logic
class Board
  attr_accessor :board

  MOVEABLE_COLOR = :yellow
  DIMENSION = 8

  def initialize
    self.board = Array.new(DIMENSION) { Array.new(DIMENSION) { Blank.new } }
    setup_board
  end

  def setup_board
    board[0] = [Rook.new(:white), Knight.new(:white), Bishop.new(:white), Queen.new(:white),
                King.new(:white), Bishop.new(:white), Knight.new(:white), Rook.new(:white)]
    board[1] = Array.new(DIMENSION) { Pawn.new(:white) }

    board[6] = Array.new(DIMENSION) { Pawn.new(:black) }
    board[7] = [Rook.new(:black), Knight.new(:black), Bishop.new(:black), Queen.new(:black),
                King.new(:black), Bishop.new(:black), Knight.new(:black), Rook.new(:black)]
  end

  # Set up the board with piece objects (Rook, Knight, Pawn, etc.)
  def set_board(custom_pieces = [])
    p "Setting up the board..."
    @board = Array.new(DIMENSION) { |i| Array.new(DIMENSION) { Blank.new } }

    # Place custom pieces on the board
    custom_pieces.each do |piece|
      row, col = piece[:position]
      piece_obj = case piece[:type]
                  when :rook then Rook.new(piece[:color])
                  when :knight then Knight.new(piece[:color])
                  when :bishop then Bishop.new(piece[:color])
                  when :queen then Queen.new(piece[:color])
                  when :king then King.new(piece[:color])
                  when :pawn then Pawn.new(piece[:color])
                  else nil
                  end
      if piece_obj
        @board[row][col] = piece_obj
      end
    end
    p "Board setup complete."
    p @board
  end

=begin
  # takes the tile (eg: A1) and retrieves the piece hash at that position on the board
  def get_piece(tile)
    row = get_board[tile[1].to_i - 1]
    return row[tile[0].ord % 65]
  end

  def valid_piece?(player, tile)
    piece = get_piece(tile)
    return true if piece[:color] == player
  end

  def valid_moves(player, tile)
    return nil unless valid_piece?(player, tile)

    piece = get_piece(tile)
    case piece[:type]
    when :pawn
      Chessmovements.pawn_moves(tile, get_board, player)
    when :rook
      Chessmovements.rook_moves(tile, get_board, player)
    when :knight
      Chessmovements.knight_moves(tile, get_board, player)
    when :bishop
      Chessmovements.bishop_moves(tile, get_board, player)
    when :queen
      Chessmovements.queen_moves(tile, get_board, player)
    when :king
      Chessmovements.king_moves(tile, get_board, player)
    end
  end

  def move_piece(tile_move_from, tile_move_to, player)
    board = get_board
    coord_from = [tile_move_from[1].to_i - 1, tile_move_from[0].ord - 65]
    coord_to = [tile_move_to[1].to_i - 1, tile_move_to[0].ord - 65]

    original_tile = board[coord_to[0]][coord_to[1]].dup
    board[coord_to[0]][coord_to[1]] = board[coord_from[0]][coord_from[1]].dup
    board[coord_from[0]][coord_from[1]] = {
      type: :empty,
      symbol: Chesspieces::PIECES[:empty],
      color: nil,
      position: coord_from
    }

    return original_tile[:type] if original_tile[:type] != :movement

    nil
  end

  def winner?
    winner = nil

    return winner
  end

  def add_possible_moves_colors(possible_moves)
    board = get_board
    possible_moves.each do |move|
      coord = [move[1].to_i - 1, move[0].ord - 65]
      if board[coord[0]][coord[1]][:type].eql?(:empty)
        cell = {
          type: :movement,
          symbol: Chesspieces::POSSIBLE_MOVE,
          color: MOVEABLE_COLOR,
          position: coord
        }
      else
        cell = board[coord[0]][coord[1]]
        cell[:color] = MOVEABLE_COLOR
      end
      board[coord[0]][coord[1]] = cell
    end
  end

  def revert_possible_moves_colors(possible_moves, player)
    board = get_board
    color = player == :white ? :black : :white

    possible_moves.each do |move|
      coord = [move[1].to_i - 1, move[0].ord - 65]
      if board[coord[0]][coord[1]][:type] == :movement
        board[coord[0]][coord[1]] = {
          type: :empty,
          symbol: Chesspieces::PIECES[:empty],
          color: nil,
          position: coord
        }
      else
        board[coord[0]][coord[1]][:color] = color
      end
    end
  end
=end
  def print_board
    board = self.board.reverse.dup
    board.each_with_index do |row, i|
      print "    -----------------\n"
      print("#{DIMENSION - i}|  |")
      row.each_with_index do |cell, i|
        if cell.symbol.nil?
          print(" |")
        else
          print(colorize_symbol!(cell.symbol, cell.color) + "|")
        end
      end
      print "\n"
    end
    print("    -----------------\n")
    print("\n    |A|B|C|D|E|F|G|H|\n")
  end

  def colorize_symbol!(symbol, color)
    case color
    when :white then "\e[37m#{symbol}\e[0m" # White
    when :black then "\e[30m#{symbol}\e[0m" # Black
    #when :red then "\e[31m#{symbol}\e[0m" # Red 
    #when :green then "\e[32m#{symbol}\e[0m"  # Green
    when :yellow then "\e[33m#{symbol}\e[0m" # Yellow

    else symbol
    end
  end
end
