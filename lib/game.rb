# frozen_string_literal: true

require_relative 'player'
require_relative 'board'
require_relative 'pieces'

class Game
  DIVIDER = '--------------------------------------------'
  RESET = "\e[0m"
  BOLD = "\e[1m"
  UNDERLINE = "\e[4m"

  def initialize
    introduce
    @board = Board.new
    @player1 = Player.new(1, :white)
    @player2 = Player.new(2, :black)
    @curr_player = @player1
    puts DIVIDER
    @board.render_board
    puts DIVIDER
  end

  def play_round
    move_piece
  end

  private

  def introduce
    puts "Welcome to chess: the classic game of strategy, prediction, and emotional overinvestment.\n"
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

  def move_piece
    from_coord = @curr_player.move_from
    unless from_coord.all? { |num| num.between?(1, 8) }
      puts 'Those coordinates are not in range, please enter a valid letter + number combination'
    end
    piece = @board.board[from_coord]
    to_coord = @curr_player.move_to
    @board.legal_move?(piece, from_coord, to_coord)
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
end

Game.new.play_round
