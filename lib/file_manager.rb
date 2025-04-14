# frozen_string_literal: true

require 'json'

module FileManager
  SAVES_DIRECTORY = './saves/'

  # Loads a save game given the filename
  # Note: filename should not have the extension
  def self.load_chess_game(filename)
    filename = "#{SAVES_DIRECTORY}#{filename}.json"
    return nil unless File.exist?(filename)

    file_content = File.read(filename)
    JSON.parse(file_content, symbolize_names: true)
  end

  # Saves a save game given the filename
  # Note: filename should not have the extension
  def self.save_chess_game(filename, board, player)
    filepath = "#{SAVES_DIRECTORY}#{filename}.json"

    File.open(filepath, 'w') do |file|
      game_state = { board: board,
                     player: player }
      file.write(JSON.pretty_generate(game_state))
      puts 'File saved successfully'
    end
  end

  # Returns all save games in "saves" folder
  # Note: return list includes extensions in the filenames
  def self.list_save_games
    Dir.exist?(SAVES_DIRECTORY) ? Dir.children(SAVES_DIRECTORY) : []
  end
end
