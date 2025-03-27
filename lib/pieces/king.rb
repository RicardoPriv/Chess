require_relative "../piece.rb"
require_relative "symbols"

# King chess piece class
class King < Piece
  include Symbols

  def initialize(color)
    super(Symbols::KING, color)
  end
end
