require_relative "../piece.rb"
require_relative "symbols"

# Rook chess piece class
class Rook < Piece
  include Symbols

  attr_accessor :castle

  def initialize(color)
    super(Symbols::ROOK, color)
    self.castle = true
  end

  # Vertical and Horixontal movement of the rook piece
  def do_moves(coordinate, board)
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    straight_movement(directions, coordinate, board)
    indirect_collisions(directions, coordinate, board)
  end
end
