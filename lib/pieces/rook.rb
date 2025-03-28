require_relative "../piece.rb"
require_relative "symbols"

# Rook chess piece class
class Rook < Piece
  include Symbols

  def initialize(color)
    super(Symbols::ROOK, color)
  end

  # Vertical and Horixontal movement of the rook piece
  def do_moves(tile, board)
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    straight_movement(directions, tile, board)
  end
end
