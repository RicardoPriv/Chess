module Chessmovements
  # Checks if the tile is within the borders of a chessboard [A1 - H8]
  def valid_tile?(tile)
    row = tile[0].ord - 65
    col = tile[1].to_i
    return true if (row >= 0 and row < 9) and (col > 0 and col < 9)
    return false
  end

  # Converts coordinate position on board to chess notation
  def position_to_tile(position)
    return (position[0] + 65 - 1).chr + (position[1]).to_s
  end

  # Converts a chess tile (eg A2) into a coordinate (eg 1, 2)
  def tile_to_position(tile)
    return [tile[0].ord - 64, tile[1].to_i]
  end

  # checks at the given position on the board if there is a piece of the opposing player (opponent of given player)
  def opponent_piece?(position, player, board)
    return false unless valid_tile?(position)

    row = board[position[0]]
    cell = row[position[1]]
    return false if cell.nil?
    return true if cell[:color] != player && !cell[:color].nil?
  end

  # Returns possible pawn movements
  def pawn_moves(tile, board, player)
    for_direction = player == :white ? 1 : -1
    possible_moves = Array.new
    coordinate = tile_to_position(tile)

    # Movement for single forward and diagonals if there is a capture target
    (0..2).each do |i|
      move = coordinate.dup.tap { |j| j[0], j[1] = j[0] - 1 + i, j[1] + for_direction }
      next if i % 2 == 0 && !opponent_piece?(move, player, board)
      possible_moves.push(move) if valid_tile?(position_to_tile(move))
    end

    # Movement for double starting jump and sets the direction depending on player colour
    if (player == :white && coordinate[1] == 2) || (player == :black && coordinate[1] == 7)
      possible_moves.push(coordinate.dup.tap { |i| i[1] = i[1] + (2 * for_direction) })
    end

    possible_moves.each_with_index { |i, index| possible_moves[index] = position_to_tile(i) }

    return possible_moves
  end

  def rook_moves(tile)

  end

  def knight_moves(tile)

  end

  def bishop_moves(tile)

  end

  def queen_moves(tile)

  end

  def king_moves(tile)

  end
end
