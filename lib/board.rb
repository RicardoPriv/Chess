require "colorize"
require_relative "./pieces/rook.rb"

Dir["#{__dir__}/pieces/*.rb"].each { |file| require_relative file }

# Class that handles chessboard logic
class Board
  attr_accessor :board

  MOVEABLE_COLOR = :yellow
  MOVEABLE_SYMBOL = "+"
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
  #NOTE REMOVE WHEN COMPLETE OR CHANGE IF WANT TO ADD PUZZLE SCENARIOS
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
  end

  # takes the tile (eg: A1) and retrieves the piece hash at that position on the board
  def tile_to_piece(tile)
    row = board[tile[1].to_i - 1]
    row[tile[0].ord % 65]
  end

  def possible_moves(player, tile)
    piece = tile_to_piece(tile)
    return nil unless piece.color == player

    case piece
    when Pawn
    when Rook
      piece.do_moves(tile_to_coordinate(tile), board)
    when Knight
    when Bishop
    when Queen
    when King
    end

    piece
  end

  # Checks if the tile is within the borders of a chessboard [A1 - H8]
  def valid_tile?(tile)
    row = tile[0].ord - 65
    col = tile[1].to_i
    return true if (row >= 0 && row < 8) && (col >= 1 && col < 9)

    false
  end

  # Converts coordinate position on board to chess notation
  def coordinate_to_tile(coordinate)
    (coordinate[1] + 65).chr + (coordinate[0] + 1).to_s
  end

  # Converts a chess tile (eg A2) into a coordinate (eg 1, 0) [row, col]
  def tile_to_coordinate(tile)
    [tile[1].to_i - 1, tile[0].ord - 65]
  end

  # checks at the given position on the board if there is a piece of the opposing player (opponent of given player)
  def opponent_piece?(coordinate, player, board)
    return false unless valid_tile?(coordinate_to_tile([coordinate[1], coordinate[0]]))

    row = board[coordinate[0]]
    cell = row[coordinate[1]]

    return false if cell[:color].nil?

    true if cell[:color] != player && !cell[:color].nil?
  end

  # Converts and array of coordinates to their Chess tiles
  def array_coordinates_to_tiles(coordinates)
    tiles = []
    coordinates.each { |i| tiles.push(coordinate_to_tile(i).dup) }
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

=end
  # Adds color to all possible movement tiles
  def add_possible_moves_colors(piece, player)
    piece.moves.each do |row, col|
      cell = board[row][col]
      cell.symbol = MOVEABLE_SYMBOL
      cell.color = MOVEABLE_COLOR
    end

    piece.collisions.each { |row, col| board[row][col].color = MOVEABLE_COLOR if board[row][col].color != player}
  end

  # Removes the possible movement coloring
  def revert_possible_moves_colors(piece, player)
    opp_color = player == :white ? :black : :white
    piece.moves.each { |row, col| board[row][col] = Blank.new }
    piece.collisions.each { |row, col| board[row][col].color = opp_color if board[row][col].color == MOVEABLE_COLOR}
  end

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
