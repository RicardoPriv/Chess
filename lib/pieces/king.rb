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
    pawn_checks(board)
  end

  private

  def pawn_checks(board)
    offset = color == :white ? 1 : -1
    all_moves = moves + collisions

    all_moves.each do |row, col|
      threaten = [[row + offset, col - 1], [row + offset, col + 1]]
      moves.delete([row, col]) if threaten.any? { |row_th, col_th| board[row_th][col_th].is_a?(Pawn) && board[row_th][col_th].color != color }
    end
  end

  def castle_moves(board, in_check)
    return unless castle || !in_check

    rooks = []
    coords_between = []
    moves_to_push = []

    case color
    when :white
      # Left Rook variables
      rooks.push(board[0][0])
      coords_between.push([[0, 2], [0, 3]])
      moves_to_push.push([0, 2])

      # Right Rook variables
      rooks.push(board[0][7])
      coords_between.push([[0, 5], [0, 6]])
      moves_to_push.push([0, 6])
    when :black
      # Left Rook variables
      rooks.push(board[7][0])
      coords_between.push([[7, 2], [7, 3]])
      moves_to_push.push([7, 2])

      # Right Rook variables
      rooks.push(board[7][7])
      coords_between.push([[7, 5], [7, 6]])
      moves_to_push.push([7, 6])
    end

    directions = [[0, 1], [0, -1], [1, 0], [-1, 0], [1, 1], [-1, 1], [-1, -1], [1, -1]]
    castle = []

    2.times do |i|
      rook = rooks[i]
      next unless rook.is_a?(Rook) && rook.castle

      # Check that all squares between king and rook are blank
      path_clear = coords_between[i].all? { |r, c| board[r][c].is_a?(Blank) }
      next unless path_clear

      # Simulate king moving through the squares
      path_safe = coords_between[i].all? do |coord|
        clear_movement
        straight_movement(directions, coord, board)
        castle_th = collisions + indirect_col

        castle_th.none? do |row, col|
          piece = board[row][col]
          if board[row][col].is_a?(Pawn)
            dir = piece.color == :white ? 1 : -1
            threatened = [[row + dir, col - 1], [row + dir, col + 1]]


            threatened.include?(coord) && piece.color != color
          else
            board[row][col].collisions.include?(coord) && board[row][col].color != color
          end
        end

      end

      clear_movement
      case color
      when :white
        coordinate_movement(directions, [0, 4], board)
        indirect_collisions(directions, [0, 4], board)
      when :black
        coordinate_movement(directions, [7, 4], board)
        indirect_collisions(directions, [7, 4], board)
      end

      next unless path_safe

      castle.push(moves_to_push[i])
    end

    moves.concat(castle) unless castle.empty?
  end
end
