require_relative "../piece.rb"
require_relative "symbols"

# Pawn chess piece class
class Pawn < Piece
  include Symbols

  def initialize(color)
    super(Symbols::PAWN, color)
  end

  def do_moves(coordinate, board)
    vertical = vertical_dir(board[coordinate[0]][coordinate[1]].color)
    player = board[coordinate[0]][coordinate[1]].color
    directions = [[vertical, 0]]

    # normal one piece forward move
    coordinate_movement(directions, coordinate, board)
    # double jump if havent moved
    pawn_double_jump(coordinate, board, player)
    # take piece diagonally
    pawn_diagonals(coordinate, board, player)
    # en passant

    indirect_collisions([], coordinate, board)
  end

  private

  def coordinate_movement(directions, coordinate, board)
    unless board[coordinate[0] + directions[0][0]][coordinate[1]].is_a?(Blank)
      self.moves = []
      return
    end

    super(directions, coordinate, board)
  end

  def pawn_double_jump(coordinate, board, player)
    case player
    when :white
      return unless coordinate[0] == 1
      return unless board[coordinate[0] + 1][coordinate[1]].is_a?(Blank)

      moves.concat([[coordinate[0] + 2, coordinate[1]]])
    when :black
      return unless coordinate[0] == 6
      return unless board[coordinate[0] - 1][coordinate[1]].is_a?(Blank)

      moves.concat([[coordinate[0] - 2, coordinate[1]]])
    end
  end

  def pawn_diagonals(coordinate, board, player)
    vertical = vertical_dir(player)
    directions = [[vertical, -1], [vertical, 1]]

    directions.each do |r, c|
      diag_r = coordinate[0] + r
      diag_c = coordinate[1] + c

      next if (diag_r.negative? || diag_r > 7) || (diag_c.negative? || diag_c > 7) ||
              board[diag_r][diag_c].is_a?(Blank) || board[diag_r][diag_c].color == player

      collisions.concat([[diag_r, diag_c]])
    end
  end

  def en_passant()
    
  end

  def vertical_dir(player)
    player == :white ? 1 : -1
  end
=begin
  # Returns possible pawn movements
  def pawn_moves(tile, board, player)
    for_direction = player == :white ? 1 : -1
    possible_moves = Array.new
    coordinate = tile_to_coordinate(tile)

    # Movement for single forward and diagonals if there is a capture target
    (0..2).each do |i|
      move = coordinate.dup.tap { |j| j[0], j[1] = j[0] - 1 + i, j[1] + for_direction }
      next if i % 2 == 0 && !opponent_piece?(move, player, board)
      possible_moves.push(move) if valid_tile?(coordinate_to_tile(move))
    end

    # Movement for double starting jump and sets the direction depending on player colour
    if (player == :white && coordinate[1] == 2) || (player == :black && coordinate[1] == 7)
      possible_moves.push(coordinate.dup.tap { |i| i[1] = i[1] + (2 * for_direction) })
    end

    possible_moves.each_with_index { |i, index| possible_moves[index] = coordinate_to_tile(i) }

    return possible_moves
  end
=end
end
