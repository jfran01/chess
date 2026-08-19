class Player
  attr_reader :colour, :id

  def initialize(id, colour)
    @id = id
    @colour = colour
    choose_name
  end

  def move_from
    puts 'Enter the square you would like to move from:'
    from_coord = convert_coord(get_input.chomp)
    return from_coord if from_coord.all? { |num| num.is_a?(Numeric) && num.between?(1, 8) }

    puts 'Those coordinates are not in range, please enter a valid letter + number combination'
    move_from
  end

  def move_to
    puts 'Enter the square you would like to move to:'
    to_coord = convert_coord(get_input.chomp)
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
      char = STDIN.getch

      case char
      when "\cs"
        print 'ctrl + s'
        return
      when "\cq"
        print 'ctrl + q'
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
end
