class Player
  def initialize(id, colour)
    @id = id
    @colour = colour
    @name = choose_name
  end

  private

  def choose_name
    puts "Player #{@id}, what shall I call you?"
    gets.chomp
  end
end
