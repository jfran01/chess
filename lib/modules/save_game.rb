# frozen_string_literal: true

require 'yaml'

module SaveGame
  def self.to_saved_data(board, players)
    filename = "#{players[0].id}_vs_#{players[1].id}"
    save_data = {
      board: board,
      players: players
    }
    save_path = File.join('saved_games', filename)
    File.write(save_path, YAML.dump(save_data))
  end

  def self.from_saved_data
    filename = fetch_saved_data
    filename = File.join('saved_games', filename)
    game_data = YAML.load_file(filename)
    File.delete(filename)
    game_data
  end

  def self.fetch_saved_data
    games = Dir.children('saved_games')
    puts "You have #{games.size} games saved. Choose one:"
    games.each_with_index { |filename, idx| puts "\e[1m(#{idx + 1})\e[0m #{filename}" }
    games[gets.chomp.to_i - 1]
  end
end
