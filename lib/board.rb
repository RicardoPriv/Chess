require "colorize"
require_relative "./pieces/rook.rb"

Dir["#{__dir__}/pieces/*.rb"].each { |file| require_relative file }

# Class that handles chessboard logic
class Board
  attr_accessor :board, :kings

  MOVEABLE_COLOR = :yellow
  MOVEABLE_SYMBOL = "+"
  DIMENSION = 8

  def initialize
    self.board = Array.new(DIMENSION) { Array.new(DIMENSION) { Blank.new } }
    setup_board
  end

  # Sets up a standard chess starting board
  def setup_board
    board[0] = [Rook.new(:white), Knight.new(:white), Bishop.new(:white), Queen.new(:white),
                King.new(:white), Bishop.new(:white), Knight.new(:white), Rook.new(:white)]
    board[1] = Array.new(DIMENSION) { Pawn.new(:white) }

    board[6] = Array.new(DIMENSION) { Pawn.new(:black) }
    board[7] = [Rook.new(:black), Knight.new(:black), Bishop.new(:black), Queen.new(:black),
                King.new(:black), Bishop.new(:black), Knight.new(:black), Rook.new(:black)]

    board[1].each_with_index { |piece, index| piece.do_moves([1, index], board) }
    board[6].each_with_index { |piece, index| piece.do_moves([6, index], board) }
    knights_positions = [[0, 1], [0, 6], [7, 1], [7, 6]]
    knights_positions.each { |p| board[p[0]][p[1]].do_moves(p, board) }

    self.kings = []
    kings.push({ color: board[0][4].color, position: [0, 4], in_check: false })
    kings.push({ color: board[7][4].color, position: [7, 4], in_check: false})

    print_board
  end

  # Add the movement coord array with collisions tiles where the piece is the opponents and returns as tiles
  def get_possible_moves(tile)
    piece = piece_from_tile(tile)
    moves = array_coordinates_to_tiles(piece.moves)
    piece.collisions.each { |c| moves.push(coordinate_to_tile(c)) if opponent_piece?(c, piece.color) }

    moves
  end

  # Set up the board with piece objects (Rook, Knight, Pawn, etc.)
  #NOTE REMOVE WHEN COMPLETE OR CHANGE IF WANT TO ADD PUZZLE SCENARIOS
  def set_board(custom_pieces = [])
    self.kings = []
    p "Setting up the board..."
    self.board = Array.new(DIMENSION) { |i| Array.new(DIMENSION) { Blank.new } }

    # Place custom pieces on the board
    custom_pieces.each do |piece|
      row, col = piece[:position]
      piece_obj = case piece[:type]
                  when :rook then Rook.new(piece[:color])
                  when :knight then Knight.new(piece[:color])
                  when :bishop then Bishop.new(piece[:color])
                  when :queen then Queen.new(piece[:color])
                  when :king
                    piece_obj = King.new(piece[:color])
                    kings.push({ color: piece_obj.color, position: piece[:position], in_check: false })
                    piece_obj
                  when :pawn then Pawn.new(piece[:color])
                  end

      board[row][col] = piece_obj if piece_obj
    end

    board.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        update_possible_moves(coordinate_to_tile([r, c]), cell.color)
      end
    end
  end

  # Adds color to all possible movement tiles
  def add_possible_moves_colors(tile, player)
    coord = tile_to_coordinate(tile)
    piece = board[coord[0]][coord[1]]

    piece.moves.each do |row, col|
      cell = board[row][col]
      cell.symbol = MOVEABLE_SYMBOL
      cell.color = MOVEABLE_COLOR
    end

    piece.collisions.each { |row, col| board[row][col].color = MOVEABLE_COLOR if board[row][col].color != player }
    p piece.indirect_col
  end

  # Removes the possible movement coloring
  def revert_possible_moves_colors(tile, player)
    opp_color = player == :white ? :black : :white

    coord = tile_to_coordinate(tile)
    piece = board[coord[0]][coord[1]]

    piece.moves.each { |row, col| board[row][col] = Blank.new }
    piece.collisions.each { |row, col| board[row][col].color = opp_color if board[row][col].color == MOVEABLE_COLOR}
  end

  # Moves the piece from tile_move_from to tile_move_to and returns what was originally at tile_move_to
  def move_piece(tile_move_from, tile_move_to)
    coord_from = tile_to_coordinate(tile_move_from)
    coord_to = tile_to_coordinate(tile_move_to)

    piece = piece_from_tile(tile_move_from)
    to_update = piece.collisions + piece.indirect_col

    board[coord_to[0]][coord_to[1]] = board[coord_from[0]][coord_from[1]].dup
    board[coord_from[0]][coord_from[1]] = Blank.new

    update_possible_moves(tile_move_to, piece.color)
    piece = piece_from_tile(tile_move_to)
    to_update += piece.collisions + piece.indirect_col

    to_update.each { |t| update_possible_moves(coordinate_to_tile(t), piece_from_tile(coordinate_to_tile(t)).color) }
    #update_in_check(tile_move_to)
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

  def check?(player)
    kings.each { |k| return k[:in_check] if k[:color] == player }
  end

  # Declaration of Private functions
  private

  # takes the tile (eg: A1) and retrieves the piece hash at that position on the board
  def tile_to_piece(tile)
    row = board[tile[1].to_i - 1]
    row[tile[0].ord % 65]
  end

  # Converts coordinate position on board to chess notation
  def coordinate_to_tile(coordinate)
    (coordinate[1] + 65).chr + (coordinate[0] + 1).to_s
  end

  # Converts a chess tile (eg A2) into a coordinate (eg 1, 0) [row, col]
  def tile_to_coordinate(tile)
    [tile[1].to_i - 1, tile[0].ord - 65]
  end

  # Converts and array of coordinates to their Chess tiles
  def array_coordinates_to_tiles(coordinates)
    coordinates.map { |i| coordinate_to_tile(i).dup }
  end

  def checkmate(player)

    false
  end

  # Checks if the opposing player is in check
  def update_in_check(tile)
    piece = piece_from_tile(tile)
    # Based on the moved piece's color, gets the opposing king
    index = kings.find_index { |k| k[:color] != piece.color }
    # Communicates that King is in check
    kings[index][:in_check] = piece.collisions.include?(kings[index][:position])
  end

  def promotions(player)

    nil
  end

  # Updates the possible movement for the piece at a given tile: Changes moves and collisions for the piece
  def update_possible_moves(tile, player)
    piece = tile_to_piece(tile)
    piece.clear_movement
    return nil unless piece.color == player

    coordinate = tile_to_coordinate(tile)
    case piece
    when Pawn
      piece.do_moves(coordinate, board)
    when Rook
      piece.do_moves(coordinate, board)
    when Knight
      piece.do_moves(coordinate, board)
    when Bishop
      piece.do_moves(coordinate, board)
    when Queen
      piece.do_moves(coordinate, board)
    when King
      piece.do_moves(coordinate, board)
    end

    piece
  end

  # Checks if the tile is within the borders of a chessboard [A1 - H8]
  def within_borders?(tile)
    row = tile[0].ord - 65
    col = tile[1].to_i
    return true if (row >= 0 && row < 8) && (col >= 1 && col < 9)

    false
  end

  # checks at the given position on the board if there is a piece of the opposing player (opponent of given player)
  def opponent_piece?(coordinate, player)
    return false unless within_borders?(coordinate_to_tile([coordinate[0], coordinate[1]]))

    row = board[coordinate[0]]
    cell = row[coordinate[1]]

    return true if cell.color != player && !cell.is_a?(Blank)

    false
  end

  def piece_from_tile(tile)
    coordinate = tile_to_coordinate(tile)
    board[coordinate[0]][coordinate[1]]
  end

  def clear_moves(tile)
    coord = tile_to_coordinate(tile)
    piece = board[coord[0]][coord[1]]
    piece.moves = []
    piece.collisions = []
    piece.indirect_col = []
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
