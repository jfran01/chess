module Slideable
  def slide_straight(from, to)
    move = to.zip(from).map { |a, b| a - b }
    through_coords = []
    return false unless move.include?(0)

    if !move[0].zero?
      1.upto(move[0] - 1) { |i| through_coords << [from[0] + i, from[1]] }
    elsif !move[1].zero?
      1.upto(move[1] - 1) { |i| through_coords << [from[0], from[1] + i] }
    else
      return false
    end

    through_coords
  end

  def slide_diagonal(from, to)
  end
end
