require_relative "../piece.rb"
require_relative "symbols"

# Blank chess piece class
class Blank < Piece
  include Symbols

  def initialize
    super(Symbols::BLANK, nil)
  end
end
