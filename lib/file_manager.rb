require 'json'

module FileManager
  SAVES_DIRECTORY = './saves/'.freeze

  def self.load_chess_game(filename)
    filename = SAVES_DIRECTORY + filename + ".json"
    return nil unless File.exist?(filename)

    file_content = File.read(filename)
    JSON.parse(file_content, symbolize_names: true)
  end

  def self.save_chess_game(filename, board, player)
    filepath = SAVES_DIRECTORY + filename + '.json'

    File.open(filepath, 'w') do |file|
      game_state = { board: board,
                     player: player}
      file.write(JSON.pretty_generate(game_state))
      puts 'File saved successfully'
    end
  end

  def self.list_save_games
    Dir.exist?(SAVES_DIRECTORY) ? Dir.children(SAVES_DIRECTORY) : []
  end
end
