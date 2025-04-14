# frozen_string_literal: true

# spec/helpers_spec.rb
require_relative '../lib/board'
require_relative '../lib/helpers'

describe Helpers do
  include Helpers

  let(:board_instance) { Board.new }

  # Dummy class to expose Helpers with board
  let(:helpers_class) do
    Class.new do
      include Helpers
      attr_accessor :board

      def initialize(board)
        @board = board
      end
    end
  end

  subject(:helpers) { helpers_class.new(board_instance.board) }

  describe '#tile_to_piece' do
    it 'returns the correct piece object from a tile' do
      expect(helpers.tile_to_piece('A1')).to be_a(Rook)
    end
  end

  describe '#coordinate_to_tile' do
    it 'converts a coordinate to a chess tile' do
      expect(helpers.coordinate_to_tile([0, 0])).to eq('A1')
      expect(helpers.coordinate_to_tile([7, 7])).to eq('H8')
    end
  end

  describe '#tile_to_coordinate' do
    it 'converts a chess tile to a coordinate' do
      expect(helpers.tile_to_coordinate('A1')).to eq([0, 0])
      expect(helpers.tile_to_coordinate('H8')).to eq([7, 7])
    end
  end

  describe '#array_coordinates_to_tiles' do
    it 'converts an array of coordinates into chess tiles' do
      coords = [[0, 0], [1, 1], [7, 7]]
      expect(helpers.array_coordinates_to_tiles(coords)).to eq(%w[A1 B2 H8])
    end
  end

  describe '#within_borders?' do
    it 'returns true for tiles within the chessboard' do
      expect(helpers.within_borders?('A1')).to be true
      expect(helpers.within_borders?('H8')).to be true
    end

    it 'returns false for out-of-bounds tiles' do
      expect(helpers.within_borders?('I1')).to be false
      expect(helpers.within_borders?('A9')).to be false
    end
  end

  describe '#opponent_piece?' do
    it 'returns true for an opponent piece at a coordinate' do
      board_instance.board[3][3] = Pawn.new(:black)
      expect(helpers.opponent_piece?([3, 3], :white)).to be true
    end

    it 'returns false for a friendly piece at a coordinate' do
      board_instance.board[3][3] = Pawn.new(:white)
      expect(helpers.opponent_piece?([3, 3], :white)).to be false
    end

    it 'returns false for a blank tile' do
      board_instance.board[3][3] = Blank.new
      expect(helpers.opponent_piece?([3, 3], :white)).to be false
    end
  end

  describe '#piece_from_tile' do
    it 'gets the piece from a given tile string' do
      board_instance.board[4][4] = Queen.new(:black)
      expect(helpers.piece_from_tile('E5')).to be_a(Queen)
    end
  end

  describe '#coords_between' do
    it 'returns the correct intermediate coordinates horizontally' do
      expect(helpers.coords_between([0, 0], [0, 3])).to eq([[0, 1], [0, 2]])
    end

    it 'returns the correct intermediate coordinates vertically' do
      expect(helpers.coords_between([0, 0], [3, 0])).to eq([[1, 0], [2, 0]])
    end

    it 'returns the correct intermediate coordinates diagonally' do
      expect(helpers.coords_between([0, 0], [3, 3])).to eq([[1, 1], [2, 2]])
    end

    it 'returns an empty array for adjacent tiles' do
      expect(helpers.coords_between([0, 0], [1, 1])).to eq([])
    end
  end
end
