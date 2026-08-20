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
    YAML.load_file(filename, permitted_classes: [Board,
                                                 King, Queen, Bishop, Rook, Knight, Pawn, Symbol, Player],
                             aliases: true)
  end

  def self.fetch_saved_data
    games = Dir.children('saved_games')
    puts "You have #{games.size} games saved. Choose one:"
    games.each_with_index { |filename, idx| puts "\e[1m(#{idx + 1})\e[0m #{filename}" }
    games[gets.chomp.to_i - 1]
  end

  def load_game
    saved_data = SaveGame.from_saved_data
    @board = saved_data[:board]
    @players = saved_data[:players]
    @curr_player = @players[0]
    @players.each do |player|
      if player.num == 1
        @player1 = player
      elsif player.num == 2
        @player2 = player
      end
    end
  end
end
