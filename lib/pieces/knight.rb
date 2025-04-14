# frozen_string_literal: true

require_relative '../piece'
require_relative 'symbols'

# Knight chess piece class
class Knight < Piece
  include Symbols

  def initialize(color)
    super(Symbols::KNIGHT, color)
  end

  # L movement of the Knight piece
  def do_moves(coordinate, board)
    directions = [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]
    coordinate_movement(directions, coordinate, board)
    indirect_collisions(directions, coordinate, board)
  end
end
