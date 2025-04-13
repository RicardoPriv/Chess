require "colorize"
require_relative "mechanics"
require_relative "./pieces/rook.rb"

Dir["#{__dir__}/pieces/*.rb"].each { |file| require_relative file }

# Class that handles chessboard logic
class Board
  include Mechanics

  attr_accessor :board, :kings, :in_check

  MOVEABLE_COLOR = :yellow
  MOVEABLE_SYMBOL = "+"
  DIMENSION = 8

  def initialize(save_game = [])
    self.board = Array.new(DIMENSION) { Array.new(DIMENSION) { Blank.new } }

    if save_game.nil? || save_game.empty?
      @en_passant = nil
      setup_board([])
    else
      @en_passant = save_game[:en_passant]
      in_check = save_game[:in_check]
      setup_board(save_game[:board])
    end
  end

  def setup_board(custom_board)
    self.kings = [{ king: King.new(:white), position: [0, 4], threats: [] },
                  { king: King.new(:black), position: [7, 4], threats: [] }]

    self.board = Array.new(DIMENSION) { Array.new(DIMENSION) { Blank.new } }

    if custom_board.empty?
      # Default full setup
      board[0] = [Rook.new(:white), Knight.new(:white), Bishop.new(:white), Queen.new(:white),
                  King.new(:white), Bishop.new(:white), Knight.new(:white), Rook.new(:white)]
      board[1] = Array.new(DIMENSION) { Pawn.new(:white) }
      board[6] = Array.new(DIMENSION) { Pawn.new(:black) }
      board[7] = [Rook.new(:black), Knight.new(:black), Bishop.new(:black), Queen.new(:black),
                  King.new(:black), Bishop.new(:black), Knight.new(:black), Rook.new(:black)]
    else
      # Rebuild board from saved data
      custom_board.each_with_index do |row, r|
        row.each_with_index do |cell, c|
          next if cell.nil?

          piece_obj = case cell[:type].to_sym
                      when :rook   then Rook.new(cell[:color].to_sym)
                      when :knight then Knight.new(cell[:color].to_sym)
                      when :bishop then Bishop.new(cell[:color].to_sym)
                      when :queen  then Queen.new(cell[:color].to_sym)
                      when :king
                        king_obj = King.new(cell[:color].to_sym)
                        king = kings.find { |k| k[:king].color == cell[:color].to_sym }
                        king[:king] = king_obj
                        king[:position] = cell[:position]
                        king_obj
                      when :pawn   then Pawn.new(cell[:color].to_sym)
                      end

          board[r][c] = piece_obj
        end
      end
    end

    # Add initial threat placeholders
    board.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        next if cell.is_a?(Blank)

        enemy_color = cell.color == :white ? :black : :white
        kings.each do |king|
          if king[:king].color == enemy_color
            king[:threats] << { tile: coordinate_to_tile([r, c]), moves: [] }
          end
        end
      end
    end

    # Update threat moves
    kings.each { |king| update_possible_moves(coordinate_to_tile(king[:position]), king[:king].color) }
    board.each_with_index do |row, r|
      row.each_with_index do |cell, c|
        update_possible_moves(coordinate_to_tile([r, c]), cell.color) unless cell.is_a?(Blank)
      end
    end
  end

  # Add the movement coord array with collisions tiles where the piece is the opponents and returns as tiles
  def get_possible_moves(tile)
    piece = piece_from_tile(tile)
    moves = array_coordinates_to_tiles(piece.moves)
    piece.collisions.each { |c| moves.push(coordinate_to_tile(c)) if opponent_piece?(c, piece.color) }

    if piece.is_a?(King)
      king = king_from_color(piece.color)
      moves.reject! do |move|
        king[:threats].any? { |th| th[:moves].include?(tile_to_coordinate(move)) && !tile_to_piece(th[:tile]).is_a?(Pawn) }
      end
    end

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
        if simulate.is_a?(King)
          simulate.do_moves(tile_to_coordinate(threat[:tile]), board, in_check)
        elsif simulate.is_a?(Pawn)
          coord = tile_to_coordinate(threat[:tile])
          simulate.do_moves(coord, board, @en_passant)
          vert = simulate.color == :white ? 1 : -1
          simulate.moves.delete([coord[0] + vert, coord[1]])

          if coord[0] == 1 && simulate.color == :white
            simulate.moves.delete([coord[0] + vert * 2, coord[1]])
          elsif coord[0] == 6 && simulate.color == :black
            simulate.moves.delete([coord[0] + vert * 2, coord[1]])
          end
        else
          simulate.do_moves(tile_to_coordinate(threat[:tile]), board)
        end
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
        th_coord = tile_to_coordinate(threat[:tile])

        # Capture: If the piece can capture the threat
        moves.push(th_coord) if piece.collisions.include?(th_coord)

        # Blocking: If the threat is a sliding piece (rook/bishop/queen), try to block
        # Only applies if threat is not a knight or pawn
        next if th_piece.is_a?(Knight) || th_piece.is_a?(Pawn)

        # Get path from threat to king (excluding threat tile itself)
        blocked_coords = coords_between(king_pos, th_coord) & piece.moves
        moves.concat(blocked_coords)
      end
    end

    array_coordinates_to_tiles(moves)
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
    remove_threats(tile_move_to) unless tile_to_piece(tile_move_to).is_a?(Blank)

    # Move piece from tile_move_from to tile_move_to
    board[coord_to[0]][coord_to[1]] = board[coord_from[0]][coord_from[1]].dup
    board[coord_from[0]][coord_from[1]] = Blank.new
    update_threat_tile(tile_move_from, tile_move_to)

    # Update the possible moves for all affected pieces
    update_possible_moves(tile_move_to, piece.color)
    piece = piece_from_tile(tile_move_to)
    to_update += piece.collisions + piece.indirect_col

    # Check for special moves
    king_castle(piece, tile_move_to, board)
    en_passant(piece, tile_move_from, tile_move_to, board)

    to_update.each { |t| update_possible_moves(coordinate_to_tile(t), piece_from_tile(coordinate_to_tile(t)).color) }
    add_threats(tile_move_to)

    # Updates check
    check
  end

  # Changes the piece on the board at a given tile to the given key (only works to change to pieces, not to Blank)
  def change_piece_to(tile, piece_symbol, player)
    coord = tile_to_coordinate(tile)
    new_piece = nil

    case piece_symbol
    when :pawn
      new_piece = Pawn.new(player)
      new_piece.do_moves(coord, board, @en_passant)
    when :rook
      new_piece = Rook.new(player)
    when :knight
      new_piece = Knight.new(player)
    when :bishop
      new_piece = Bishop.new(player)
    when :queen
      new_piece = Queen.new(player)
    when :king
      new_piece = King.new(player)
      new_piece.do_moves(coord, board, in_check)
    end

    new_piece.do_moves(coord, board) unless new_piece.is_a?(King) || new_piece.is_a?(Pawn)
    board[coord[0]][coord[1]] = new_piece

    remove_threats(tile)
    add_threats(coordinate_to_tile(coord))
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

  # Checks if a player is in check and updates in_check
  def check
    king_in_check = kings.find do |king|
      king[:threats].any? { |threat| threat[:moves].include?(king[:position]) }
    end

    self.in_check = king_in_check ? king_in_check[:king].color : nil
  end

  def stalemate
    # Find the player whose king is potentially in stalemate
    player = kings.find do |king|
      moves = king[:king].moves + king[:king].collisions
      # Check if all of the king's possible moves are either blocked or in check
      king_moves_blocked_or_in_check = moves.all? do |move|
        king[:threats].any? { |threat| threat[:moves].include?(move) }
      end

      # If all of the king's moves are blocked or in check, we continue to check for other moveable pieces
      if king_moves_blocked_or_in_check
        # Check if any piece for the player can move (excluding the king)
        pieces = board.flatten.select { |tile| tile.is_a?(Piece) && tile.color == king[:king].color && !tile.is_a?(King) }
        pieces.each do |piece|
          # Get the piece's possible moves
          piece_moves = piece.moves + piece.collisions
          # If the piece has any valid moves that aren't blocked or in check, return false (not stalemate)
          return false if piece_moves.any? { |move| !king[:threats].any? { |threat| threat[:moves].include?(move) } }
        end

        # If no piece has a valid move and the king is blocked or in check, it's a stalemate
        true
      else
        # The king has at least one valid move, no stalemate
        false
      end
    end

    # If we found a player in stalemate, return true; otherwise, return false
    player ? true : false
  end

  # Serializes the board into a state that can be saved in a json file
  def serialize
    output = {
      board: [],
      in_check: in_check,
      en_passant: @en_passant
    }

    # Turns the objects within the board into hashes store-able in a json
    output[:board] = board.map.with_index do |row, r|
      row.map.with_index do |cell, c|
        if cell.is_a?(Blank)
          nil
        else
          {
            type: cell.class.name.split("::").last.downcase.to_sym,
            position: [r, c],
            color: cell.color
          }
        end
      end
    end

    output
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

  # Checks if the piece at given tile is the given player's piece
  def valid_player_piece(tile, player)
    tile_to_piece(tile).color == player
  end

  # Declaration of Private functions
  private

  # Updates the possible movement for the piece at a given tile: Changes moves and collisions for the piece
  def update_possible_moves(tile, player)
    piece = tile_to_piece(tile)
    return nil unless piece.color == player

    remove_threats(tile)
    piece.clear_movement
    coordinate = tile_to_coordinate(tile)

    case piece
    when Pawn
      piece.do_moves(coordinate, board, @en_passant)
    when Rook
      piece.do_moves(coordinate, board)
    when Knight
      piece.do_moves(coordinate, board)
    when Bishop
      piece.do_moves(coordinate, board)
    when Queen
      piece.do_moves(coordinate, board)
    when King
      piece.do_moves(coordinate, board, in_check)
      king = kings.find { |k| k[:king].color == player }
      king[:king] = piece
      king[:position] = coordinate
    end

    add_threats(tile)
    piece
  end

  # Adds the tile to the kings threats if it has a valid threat
  def add_threats(tile)
    piece = tile_to_piece(tile)
    return if piece.is_a?(Blank)

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
