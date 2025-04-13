require_relative "helpers.rb"

# Module containing more outlier functions/rules of chess like castling, promotions etc
module Mechanics
  include Helpers

  # Returns the tile of a pawn that is ready for promotion
  # Won't return multiple since shouldn't be possible in a standard chess game
  def promotion(player, board)
    row = player == :white ? 7 : 0
    p row
    8.times { |col| return coordinate_to_tile([row, col]) if board[row][col].is_a?(Pawn) }

    ""
  end

  def king_castle(piece, king_move, board)
    # Checks if piece can castle
    # Changes possibility to false to account for castling only allowed if piece hasn't moved
    return unless piece.respond_to?(:castle) && piece.castle

    piece.castle = false
    # Checks if piece moving is a King since only need to account for Rook if King is castling
    return unless piece.is_a?(King)

    # Set appropriate positions for castle depending on color and side
    rook_piece = nil
    board_corner = []
    castle_position = []

    case king_move
    when "C1"
      rook_piece = board[0][0].dup
      board_corner = [0, 0]
      castle_position = [0, 3]
    when "G1"
      rook_piece = board[0][7].dup
      board_corner = [0, 7]
      castle_position = [0, 5]
    when "C8"
      rook_piece = board[7][0].dup
      board_corner = [7, 0]
      castle_position = [7, 3]
    when "G8"
      rook_piece = board[7][7].dup
      board_corner = [7, 7]
      castle_position = [7, 5]
    end

    return unless rook_piece.is_a?(Rook) && rook_piece.color == piece.color && rook_piece.castle

    # Move Rook to compensate for castle
    board[board_corner[0]][board_corner[1]] = Blank.new
    board[castle_position[0]][castle_position[1]] = rook_piece
    rook_piece.do_moves(castle_position, board)
  end

  def en_passant(piece, move_from, move_to, board)
    if piece.is_a?(Pawn) && !@en_passant.nil?
      from_coord = tile_to_coordinate(move_from)
      to_coord = tile_to_coordinate(move_to)

      return unless piece.color != board[from_coord[0]][to_coord[1]].color

      row_diff = (from_coord[0] - to_coord[0]).abs
      col_diff = (from_coord[1] - to_coord[1]).abs

      return unless (row_diff == 1 && col_diff == 1)

      board[from_coord[0]][to_coord[1]] = Blank.new
    end

    @en_passant = piece.is_a?(Pawn) ? tile_to_coordinate(move_from) : nil
  end
end
