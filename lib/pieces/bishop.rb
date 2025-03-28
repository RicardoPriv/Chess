require_relative "../piece.rb"
require_relative "symbols"

# Bishop chess piece class
class Bishop < Piece
  include Symbols

  def initialize(color)
    super(Symbols::BISHOP, color)
  end

  # Diagonal movement of the bishop piece
  def do_moves(coordinate, board)
    directions = [[1, 1], [-1, 1], [-1, -1], [1, -1]]
    straight_movement(directions, coordinate, board)
  end
end
