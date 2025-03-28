require_relative "../piece.rb"
require_relative "symbols"

# King chess piece class
class King < Piece
  include Symbols

  def initialize(color)
    super(Symbols::KING, color)
  end

  # Movement for King / positions surrounding current tile
  def do_moves(coordinate, board)
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [-1, 1], [-1, -1], [1, -1]]
    coordinate_movement(directions, coordinate, board)
  end
end
