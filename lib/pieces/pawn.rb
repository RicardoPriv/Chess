# frozen_string_literal: true

require_relative '../piece'
require_relative 'symbols'

# Pawn chess piece class
class Pawn < Piece
  include Symbols

  def initialize(color)
    super(Symbols::PAWN, color)
  end

  # Pawn movement which includes: 1 space, 2 space start movement, diagonal taking and en passant
  def do_moves(coordinate, board, en_passant)
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
    en_passant(coordinate, board, player, en_passant)

    indirect_collisions([], coordinate, board)
  end

  private

  # Forward movement of the pawn
  def coordinate_movement(directions, coordinate, board)
    return unless within_board([coordinate[0] + directions[0][0], coordinate[1]])

    unless board[coordinate[0] + directions[0][0]][coordinate[1]].is_a?(Blank)
      self.moves = []
      return
    end

    super(directions, coordinate, board)
  end

  # 2 space movement if Pawn is at starting position
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

  # Adds in diagonal movement if there is a possible piece to take for the Pawn
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

  # Adds in the movement for en passant if there is a possible piece for en passant to take place
  def en_passant(coordinate, board, player, en_passant)
    return if en_passant.nil?

    if board[coordinate[0]][en_passant[1]].color != player && board[coordinate[0]][en_passant[1]].is_a?(Pawn) &&
       board[en_passant[0]][en_passant[1]].is_a?(Blank)
      row = coordinate[0] + vertical_dir(player)
      moves.push([row, en_passant[1]]) unless moves.include?([row, en_passant[1]])
    end
  end

  def vertical_dir(player)
    player == :white ? 1 : -1
  end
end
