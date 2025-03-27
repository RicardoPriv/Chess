require_relative "../piece.rb"
require_relative "symbols"

# Rook chess piece class
class Rook < Piece
  include Symbols

  def initialize(color)
    super(Symbols::ROOK, color)
  end
end
