require_relative "../piece.rb"
require_relative "symbols"

# Pawn chess piece class
class Pawn < Piece
  include Symbols

  def initialize(color)
    super(Symbols::PAWN, color)
  end
end
