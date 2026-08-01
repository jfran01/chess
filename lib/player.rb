class Player
  attr_reader :colour

  def initialize(id, colour)
    @id = id
    @colour = colour
    choose_name
  end

  def move_from
    puts "\n\e[4m#{@id}'s turn\e[0m"
    puts 'Enter the square you would like to move from:'
    from_coord = convert_coord(gets.chomp)
    return from_coord if from_coord.all? { |num| num.between?(1, 8) }

    puts 'Those coordinates are not in range, please enter a valid letter + number combination'
    move_from
  end

  def move_to
    puts 'Enter the square you would like to move to:'
    to_coord = convert_coord(gets.chomp)
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
end
