# frozen_string_literal: true

require_relative 'player'
require_relative 'board'
require_relative 'pieces'
require_relative 'modules/save_game'
require 'pry-byebug'

class Game
  include SaveGame

  DIVIDER = '--------------------------------------------'
  RESET = "\e[0m"
  BOLD = "\e[1m"
  UNDERLINE = "\e[4m"

  attr_accessor :board
  attr_reader :players, :filename

  def initialize
    introduce
    @board ||= Board.new
    @player1 ||= Player.new(1, :white)
    @player2 ||= Player.new(2, :black)
    @players ||= [@player1, @player2]
    @curr_player ||= @players[0]
    puts DIVIDER
    @board.render_board
    puts DIVIDER
  end

  def play_game
    play_round until end_of_game?
  end

  def play_round
    puts "\n\e[4m#{@curr_player.id}'s turn\e[0m"
    move = @board.move_piece(@curr_player)
    save_game if move == :save_game
    print_result
    @curr_player = @players.reverse![0]
  end

  def save_game
    @filename = "#{players[0].id}_vs_#{players[1].id}" unless filename
    SaveGame.to_saved_data(@board, @players)
    puts "\e[1mTo be continued...\e[0m"
    puts "Game saved under #{@filename}"
    exit!
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

  private

  def introduce
    puts "Welcome to chess: the classic game of strategy, prediction, and emotional overinvestment.\n"
    puts 'Would you like to continue a game, or start afresh?'
    puts '[C]ontinue or Start [N]ew:'
    answer = gets.upcase
    load_game if answer.start_with?('C')
    describe_moves
  end

  def describe_moves
    puts 'Would you like to be reminded of the basic moves of each piece?'
    answer = gets.upcase
    if answer[0] == 'Y'
      puts RULES
    else
      puts "No worries then chess master. Let's get on with it..."
    end
  end

  RULES = <<~RULES

    #{DIVIDER}

    #{BOLD}#{UNDERLINE}King:#{RESET}
    The most important piece, must be protected or you lose the game \e[3m(reeks of toxic masculinity but ok...)#{RESET}
    #{BOLD}Moves one square in any direction
    #{'  '}
    #{UNDERLINE}Queen:#{RESET}
    The most powerful piece on the board \e[3m(why yes of course she is)#{RESET}
    #{BOLD}Moves any number of squares horizontally, vertically, or diagonally
    #{'  '}
    #{UNDERLINE}Rook:#{RESET}
    Also a pretty powerful piece- it's the one shaped like a castle tower
    #{BOLD}Moves any number of squares horizontally or vertically
    #{'  '}
    #{UNDERLINE}Bishop:#{RESET}
    Considered a minor piece, although still very useful
    #{BOLD}Moves any number of squares diagonally
    #{'  '}
    #{UNDERLINE}Knight:#{RESET}
    Also considered a minor piece \e[3m(but it might be my favourite, although take that with a pinch of salt because I'm not a chess player)#{RESET}
    #{BOLD}Moves in an 'L' shape- 2 squares in a straight direction, and then 1 square perpendicular to that. It can also jump over a piece that is in the first square it will move over

    #{UNDERLINE}Pawn:#{RESET}
    They seem lowly and expendable, but they actually have the most complex rules of movement
    #{BOLD}1: On it's first move, can move 2 squares directly forward
    2: On any subsequent move, moves 1 square directly forward
    3: Moves diagonally when taking
    At the end of the board, they 'promote' to any other piece (excluding the king) of the same colour#{RESET}

    #{DIVIDER}

  RULES

  def print_result
    puts self.class::DIVIDER
    captured_pieces = get_captured_pieces(@player1.colour)
    puts "#{@player2.id}'s captured pieces: #{captured_pieces}\n" unless captured_pieces.empty?
    @board.render_board
    captured_pieces = get_captured_pieces(@player2.colour)
    puts "\n#{@player1.id}'s captured pieces: #{captured_pieces}" unless captured_pieces.empty?
    puts self.class::DIVIDER
  end

  def get_captured_pieces(player_colour)
    captured_pieces = @board.captured_pieces.select { |piece| piece.player == player_colour }
    captured_icons = []
    captured_pieces.each { |piece| captured_icons << piece.icon }
    captured_icons.join
  end

  def end_of_game?
    @board.checking_pieces = @board.check?(@curr_player.colour)
    return false unless @board.checking_pieces

    if @board.checkmate?(@curr_player.colour)
      puts "CHECKMATE! #{@players[1]} is victorious and may now decide #{@curr_player}'s fate."
      return true
    elsif @board.stalemate?(@curr_player.colour)
      puts 'STALEMATE. Well played (or commiserations) to you both.'
      return true
    else
      puts "#{@curr_player}, you are in check- be careful fine warrior."
    end
    false
  end
end

# game = Game.new
# game.play_game
