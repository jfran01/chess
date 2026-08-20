require 'io/console'
require_relative 'modules/save_game'

class Player
  attr_reader :colour, :id, :num

  def initialize(num, colour)
    @num = num
    @id = num
    @colour = colour
    choose_name
  end

  def move_from
    puts 'Enter the square you would like to move from:'
    input = get_input
    return :save_game if input == :save_game

    exit! if input == :quit_game

    from_coord = convert_coord(input.chomp)
    return from_coord if from_coord.all? { |num| num.is_a?(Numeric) && num.between?(1, 8) }

    puts 'Those coordinates are not in range, please enter a valid letter + number combination'
    move_from
  end

  def move_to
    puts 'Enter the square you would like to move to:'
    input = get_input
    return :save_game if input == :save_game

    exit! if input == :quit_game

    to_coord = convert_coord(input.chomp)
    return to_coord if to_coord.all? { |num| num.between?(1, 8) }

    puts 'Those coordinates are not in range, please enter a valid letter + number combination'
    move_to
  end

  private

  def choose_name
    puts "Player #{@id}, what shall I call you?"
    @id = gets.chomp
  end

  ALPHABET_CONVERTER = ('a'..'z').each.with_index(1).to_h

  def convert_coord(coord)
    coord = coord.split('')
    coord[0] = ALPHABET_CONVERTER[coord[0]]
    coord[1] = coord[1].to_i
    coord
  end

  def get_input
    input = ''
    loop do
      char = $stdin.getch

      case char
      when "\cs"
        puts 'Things are getting to intense huh? Take a break?'
        puts '[Y]es or [N]o:'
        return :save_game if confirm?
      when "\cq"
        puts "You're about to quit the game and delete your progress. Are you sure that's what you want??"
        puts '[Y]es or [N]o:'
        exit! if confirm?
      when "\r"
        puts
        return input
      when "\u007F"
        input.chop!
        print "\b \b"
      else
        print char
        input << char
      end
    end
  end

  def confirm?
    loop do
      answer = get_input.chomp.downcase

      return true if answer.start_with?('y')
      return false if answer.start_with?('n')

      puts 'Please enter [Y]es or [N]o'
    end
  end
end
