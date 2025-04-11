require_relative "../piece.rb"
require_relative "symbols"

# King chess piece class
class King < Piece
  include Symbols

  attr_accessor :castle

  def initialize(color)
    super(Symbols::KING, color)
    self.castle = true
  end

  # Movement for King / positions surrounding current tile
  def do_moves(coordinate, board, in_check)
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [-1, 1], [-1, -1], [1, -1]]
    coordinate_movement(directions, coordinate, board)
    indirect_collisions(directions, coordinate, board)
    castle_moves(board, in_check) if castle
  end

  private

  def castle_moves(board, in_check)
    return unless castle || !in_check

    rooks = []
    coords_between = []
    moves_to_push = []

    case color
    when :white
      # Left Rook variables
      rooks.push(board[0][0])
      coords_between.push([[0, 1], [0, 2], [0, 3]])
      moves_to_push.push([0, 2])

      # Right Rook variables
      rooks.push(board[0][7])
      coords_between.push([[0, 5], [0, 6]])
      moves_to_push.push([0, 6])
    when :black
      # Left Rook variables
      rooks.push(board[7][0])
      coords_between.push([[7, 1], [7, 2], [7, 3]])
      moves_to_push.push([7, 2])

      # Right Rook variables
      rooks.push(board[7][7])
      coords_between.push([[7, 5], [7, 6]])
      moves_to_push.push([7, 6])
    end

    2.times do |i|
      next if !rooks[i].is_a?(Rook) || (rooks[i].is_a?(Rook) && !rooks[i].castle)

      coords_between[i].each { |coord| return unless board[coord[0]][coord[1]].is_a?(Blank) }
      moves.push(moves_to_push[i])
    end
  end
end
