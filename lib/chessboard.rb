# class Chessboard

require_relative "chesspieces"
require "colorize"

include Chesspieces

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

  def print_board
    board = get_board.reverse
    board.each do |row|
      print "-----------------\n|"
      row.each_with_index do |cell, i|
        print colorize_symbol(cell[:symbol], cell[:color]) + "|"
      end
      print "\n"
    end 
    print("-----------------\n")
  end

  def colorize_symbol(symbol, color)
    case color
    when :white then "\e[37m#{symbol}\e[0m" # White
    when :black then "\e[30m#{symbol}\e[0m" # Black
    else symbol
    end
  end  
end
