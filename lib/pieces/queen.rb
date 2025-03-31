require_relative "../piece.rb"
require_relative "symbols"

# Queen chess piece class
class Queen < Piece
  include Symbols

  def initialize(color)
    super(Symbols::QUEEN, color)
  end

  def do_moves(coordinate, board)
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [-1, 1], [-1, -1], [1, -1]]
    straight_movement(directions, coordinate, board)
    indirect_collisions(directions, coordinate, board)
  end
end
