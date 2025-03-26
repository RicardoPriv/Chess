# class Chessboard

require_relative "chesspieces"
require_relative "chessmovements"
require "colorize"

include Chesspieces
include Chessmovements

class Chessboard
  DIMENSION = 8

  def initialize
    @board = Array.new(DIMENSION) { Array.new(DIMENSION) }
    setup_board
  end

  def setup_board
    back_row_types = [:rook, :knight, :bishop, :queen, :king, :bishop, :knight, :rook]

    @board[0] = back_row_types.map.with_index { |type, i| piece_hash(type, :white, 0, i) }
    @board[1] = Array.new(DIMENSION) { |i| piece_hash(:pawn, :white, 1, i) }

    (2..5).each { |i| @board[i] = Array.new(DIMENSION) { |j| piece_hash(:empty, nil, i, j) } }

    @board[6] = Array.new(DIMENSION) { |i| piece_hash(:pawn, :black, 6, i) }
    @board[7] = back_row_types.map.with_index { |type, i| piece_hash(type, :black, 7, i) }
  end

  def piece_hash(type, color, row, col)
    return { type: type, symbol: Chesspieces::PIECES[type], color: color, position: [row, col] }
  end

  def get_board
    return @board
  end

  def set_board(custom_pieces = [])
    p "test"
    @board = Array.new(DIMENSION) { |i| Array.new(DIMENSION) { |j| piece_hash(:empty, nil, i, j) } }
  
    custom_pieces.each do |piece|
      row, col = piece[:position]
      @board[row][col] = piece
    end
    p "\n\n"
  end
  
  # takes the tile (eg: A1) and retrieves the piece hash at that position on the board
  def get_piece(tile)
    row = get_board[tile[1].to_i - 1]
    return row[tile[0].ord % 65]
  end

  def valid_piece?(player, tile)
    piece = get_piece(tile)
    return true if piece[:color] == player
  end

  def valid_moves(player, tile)
    return nil unless valid_piece?(player, tile)
    piece = get_piece(tile)
    
    case piece[:type]
    when :pawn
      Chessmovements.pawn_moves(tile, get_board, player)
    when :rook
      Chessmovements.rook_moves(tile, get_board, player)
    when :knight
    
    when :bishop
      Chessmovements.bishop_moves(tile, get_board, player)
    when :queen
      Chessmovements.queen_moves(tile, get_board, player)
    when :king

    else
      return nil
    end
  end

  def winner?
    winner = nil

    
    return winner
  end

  def print_board
    board = get_board.reverse
    board.each_with_index do |row, i|
      print "    -----------------\n"
      print("#{DIMENSION - i}|  |")
      row.each_with_index do |cell, i|
        if cell[:symbol].nil?
          print(" |")
        else
          print(colorize_symbol!(cell[:symbol], cell[:color]) + "|")
        end
      end
      print "\n"
    end 
    print("    -----------------\n")
    print("\n    |A|B|C|D|E|F|G|H|\n")
  end

  def colorize_symbol!(symbol, color)
    case color
    when :white then "\e[37m#{symbol}\e[0m" # White
    when :black then "\e[30m#{symbol}\e[0m" # Black
    else symbol
    end
  end  
end
