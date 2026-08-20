# frozen_string_literal: true

require 'yaml'

module SaveGame
  def self.to_saved_data(board, players)
    filename = "#{players[0].id}_vs_#{players[1].id}"
    save_data = {
      board: board,
      players: players,
      filename: filename
    }
    save_path = File.join('saved_games', filename)
    File.write(save_path, YAML.dump(save_data))
  end

  def self.from_saved_data
  end

  def self.fetch_saved_data
  end
end
