require "colorize"
require_relative "./pieces/rook.rb"

Dir["#{__dir__}/pieces/*.rb"].each { |file| require_relative file }

# Class that handles chessboard logic
class Board
  attr_accessor :board, :kings, :in_check


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
    kings.push({ color: board[0][4].color, position: [0, 4] })
    kings.push({ color: board[7][4].color, position: [7, 4] })
  end

  # Add the movement coord array with collisions tiles where the piece is the opponents and returns as tiles
  def get_possible_moves(tile)
    piece = piece_from_tile(tile)
    moves = array_coordinates_to_tiles(piece.moves)
    piece.collisions.each { |c| moves.push(coordinate_to_tile(c)) if opponent_piece?(c, piece.color) }

    moves
  end

  # Returns the possible moves for the tile if the King is in check
  def get_in_check_moves(tile)
    moves = []
    return moves if in_check.nil?

    piece = piece_from_tile(tile)
    king = king_from_color(piece.color)

    # Returns King's moves to get out of check
    if piece.is_a?(King)
      # Sets possible King moves without accounting for threats
      moves = king[:king].moves + king[:king].collisions

      # Simulates moves as though king didn't exist
      # This is to account for moves that would not be in possible moves
      # Eg: without simulations - |R| | |K|+| | | | with simulation - |R| | |K| | | | |
      board[king[:position][0]][king[:position][1]] = Blank.new

      king[:threats].each do |threat|
        next if threat[:moves].empty?

        simulate = piece_from_tile(threat[:tile]).dup
        simulate.do_moves(tile_to_coordinate(threat[:tile]), board)

        moves -= simulate.moves
      end

      board[king[:position][0]][king[:position][1]] = king[:king]

      # Removes if collisions:
      # are of same color
      # are backed by another piece
      king[:king].collisions.each do |th_collision|
        piece_at_col = tile_to_piece(coordinate_to_tile(th_collision))
        moves.delete(th_collision) if piece_at_col.color == king[:king].color

        temp = piece_at_col.collisions + piece_at_col.indirect_col
        temp.each do |backing_coord|
          backing_piece = tile_to_piece(coordinate_to_tile(backing_coord))
          next if backing_piece.color != piece_at_col.color
          next unless backing_piece.collisions.include?(th_collision)

          moves.delete(th_collision)
        end
      end

    # Returns other pieces moves to block check if possible
    else
      king_pos = king[:position]

      king[:threats].each do |threat|
        next unless threat[:moves].include?(king_pos)

        th_piece = tile_to_piece(threat[:tile])
        th_moves = th_piece.moves
        th_coord = tile_to_coordinate(threat[:tile])

        # Capture: If the piece can capture the threat
        moves.push(th_coord) if piece.collisions.include?(th_coord)

        # Blocking: If the threat is a sliding piece (rook/bishop/queen), try to block
        # Only applies if threat is not a knight or pawn
        next if th_piece.is_a?(Knight) || th_piece.is_a?(Pawn)

        # Get path from threat to king (excluding threat tile itself)
        blocked_coords = coords_between(king_pos, th_coord) & piece.moves
        moves.concat(blocked_coords)
        p moves
      end
    end

    array_coordinates_to_tiles(moves)
  end

  def coords_between(start_coord, end_coord)
    line = []
    r1, c1 = start_coord
    r2, c2 = end_coord
    dr = r2 <=> r1
    dc = c2 <=> c1

    cur_r, cur_c = r1 + dr, c1 + dc
    while [cur_r, cur_c] != [r2, c2]
      line << [cur_r, cur_c]
      cur_r += dr
      cur_c += dc
    end

    line
  end

  # Set up the board with piece objects (Rook, Knight, Pawn, etc.)
  #NOTE REMOVE WHEN COMPLETE OR CHANGE IF WANT TO ADD PUZZLE SCENARIOS
  def set_board(custom_pieces = [])
    self.kings = [{ king: King.new(:white), position: [], threats: [] },
                  { king: King.new(:black), position: [], threats: [] }]
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
                    king = kings.find { |k| k[:king].color == piece[:color] }
                    king[:king] = piece_obj
                    king[:position] = piece[:position]
                    piece_obj
                  when :pawn then Pawn.new(piece[:color])
                  end

      board[row][col] = piece_obj if piece_obj
    end

    board.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        color = cell.color == :white ? :black : :white
        kings.each { |king| king[:threats] << { tile: coordinate_to_tile([r, c]), moves: [] } if king[:king].color == color } unless cell.is_a?(Blank)
      end
    end

    kings.each { |king| update_possible_moves(coordinate_to_tile(king[:position]), king[:king].color) }
    # king => { color: position: threats: [{tile: moves: []}] }
    board.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        update_possible_moves(coordinate_to_tile([r, c]), cell.color)
      end
    end
  end

  def get_king_tile(player)
    kings.find { |king| return coordinate_to_tile(king[:position]) if king[:king].color == player }
  end

  # Adds color to all possible movement tiles
  def add_possible_moves_colors(moves)
    moves.each do |move|
      row, col = tile_to_coordinate(move)
      cell = board[row][col]
      cell.symbol = MOVEABLE_SYMBOL if cell.is_a?(Blank)
      cell.color = MOVEABLE_COLOR
    end
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
    # Get required variables
    coord_from = tile_to_coordinate(tile_move_from)
    coord_to = tile_to_coordinate(tile_move_to)

    piece = piece_from_tile(tile_move_from)
    to_update = piece.collisions + piece.indirect_col
    remove_threats(tile_move_from)

    # Move piece from tile_move_from to tile_move_to
    board[coord_to[0]][coord_to[1]] = board[coord_from[0]][coord_from[1]].dup
    board[coord_from[0]][coord_from[1]] = Blank.new
    update_threat_tile(tile_move_from, tile_move_to)

    # Update the possible moves for all affected pieces
    update_possible_moves(tile_move_to, piece.color)
    piece = piece_from_tile(tile_move_to)
    to_update += piece.collisions + piece.indirect_col
    to_update.each { |t| update_possible_moves(coordinate_to_tile(t), piece_from_tile(coordinate_to_tile(t)).color) }
    add_threats(tile_move_to)

    # Updates check
    check
  end

  # Checks if a player is in checkmate and return the checkmated player
  def checkmate
    player = kings.find do |king|
      moves = king[:king].moves + [king[:position]]
      moves.all? { |move| king[:threats].any? { |th| th[:moves].include?(move) } }
    end

    player ? player[:king].color : nil
  end

  def print_board
    board = self.board.reverse.dup
    board.each_with_index do |row, i|
      print "    -----------------\n"
      print("#{DIMENSION - i}|  |")
      row.each_with_index do |cell, i|
        if cell.symbol.nil?
          print(" |")
        elsif cell.is_a?(King) && in_check == cell.color
          print(colorize_symbol!(cell.symbol, :red) + "|")
        else
          print(colorize_symbol!(cell.symbol, cell.color) + "|")
        end
      end
      print "\n"
    end
    print("    -----------------\n")
    print("\n    |A|B|C|D|E|F|G|H|\n")
  end

  def valid_player_piece(tile, player)
    tile_to_piece(tile).color == player
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

  # Checks if a player is in check and updates in_check
  def check
    king_in_check = kings.find do |king|
      king[:threats].any? { |threat| threat[:moves].include?(king[:position]) }
    end

    self.in_check = king_in_check ? king_in_check[:king].color : nil
  end

  def promotions(player)

    nil
  end

  # Updates the possible movement for the piece at a given tile: Changes moves and collisions for the piece
  def update_possible_moves(tile, player)
    piece = tile_to_piece(tile)
    return nil unless piece.color == player

    remove_threats(tile)
    piece.clear_movement
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
      king = kings.find { |k| k[:king].color == player }
      king[:king] = piece
      king[:position] = coordinate
    end

    add_threats(tile)
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

  # Adds the tile to the kings threats if it has a valid threat
  def add_threats(tile)
    piece = tile_to_piece(tile)
    return if piece.is_a?(Blank) || piece.is_a?(King)

    player = piece.color == :white ? :black : :white
    king = kings.find { |k| k[:king].color == player }

    piece_moves = piece.moves + piece.collisions
    possible_threats = king[:king].moves + king[:king].collisions + [king[:position]]
    threats = possible_threats & piece_moves

    return if threats.empty?

    # Remove existing threat from this piece if already exists to avoid duplicates
    king[:threats].delete_if { |th| th[:tile] == tile }

    # Add updated threat
    king[:threats] << { tile: tile, moves: threats }

    # Check if threat puts king in check
    self.in_check = player if threats.include?(king[:position])
  end

  def remove_threats(tile)
    player = tile_to_piece(tile).color == :white ? :black : :white
    king = kings.find { |k| k[:king].color == player }

    king[:threats].delete_if { |th| th[:tile] == tile }
  end

  def update_threat_tile(tile_old, tile_new)
    kings.each do |king|
      king[:threats].each do |threat|
        next unless threat[:tile] != tile_old

        threat[:tile] = tile_new
        break
      end
    end
  end

  def king_from_color(color)
    kings.find { |k| k[:king].color == color }
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
    when :red then "\e[31m#{symbol}\e[0m" # Red
    when :yellow then "\e[33m#{symbol}\e[0m" # Yellow

    else symbol
    end
  end
end
