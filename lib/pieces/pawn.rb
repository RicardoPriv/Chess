require_relative "../piece.rb"
require_relative "symbols"

# Pawn chess piece class
class Pawn < Piece
  include Symbols

  def initialize(color)
    super(Symbols::PAWN, color)
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
