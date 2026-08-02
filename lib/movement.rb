module CheckMoves
  def legal_move?(piece, from, to)
    return false unless legal_move_to?(piece, to)
    return false unless legal_slide?(piece, from, to)
    return false unless check_attack_maps(piece, from, to)
    return false if piece.instance_of?(Pawn) && !legal_pawn_move?(piece.player, from, to)

    true
  end

  def legal_move_to?(piece, to)
    return true unless board[to]

    piece.player != board[to].player
  end

  def legal_slide?(piece, from, to)
    if piece.instance_of?(Rook)
      through_coords = piece.slide_straight(from, to)
    elsif piece.instance_of?(Bishop)
      through_coords = piece.slide_diagonal(from, to)
    elsif piece.instance_of?(Queen)
      through_coords = piece.slide_straight(from, to)
      through_coords << piece.slide_diagonal(from, to)
    else
      return true
    end
    return false if through_coords.any? { |coord| board[coord] }

    true
  end

  def check_attack_maps(piece, from, to)
    if piece.instance_of?(Knight)
      return true if knight_attacks[from].include?(to)
    elsif piece.instance_of?(King)
      return true if king_attacks[from].include?(to)
    elsif piece.instance_of?(Pawn)
      return true unless board[to]

      if piece.player == :white
        return true if white_pawn_attacks[from].include?(to)
      elsif piece.player == :black
        return true if white_pawn_attacks[from].include?(to)
      end
    elsif piece.instance_of?(Queen) || piece.instance_of?(Bishop) || piece.instance_of?(Rook)
      true
    end
    false
  end

  def legal_pawn_move?(colour, from, to)
    return true if board[to]

    offset = to.zip(from).map { |a, b| a - b }
    if colour == :white
      return true if offset == [0, 1]
    elsif colour == :black
      return true if offset == [0, -1]
    end
    false
  end
end

module AttackMaps
  def init_attack_maps(offsets)
    map = {}
    board.each_key do |coord|
      adj = offsets.map { |dx, dy| [coord[0] + dx, coord[1] + dy] }
      adj.select! { |x, y| x.between?(1, 8) && y.between?(1, 8) }
      map[coord] = adj
    end
    map
  end
end

module Slideable
  def slide_straight(from, to)
    move = to.zip(from).map { |a, b| a - b }
    return false unless move.include?(0)

    through_coords = []
    if !move[0].zero?
      direction = move[0] <=> 0
      (move[0].abs - 1).times do |i|
        through_coords << [from[0] + (direction * (i + 1)), from[1]]
      end
    elsif !move[1].zero?
      direction = move[1] <=> 0
      (move[1].abs - 1).times do |i|
        through_coords << [from[0], from[1] + (direction * (i + 1))]
      end
    else
      return false
    end

    through_coords
  end

  def slide_diagonal(from, to)
    move = to.zip(from).map { |a, b| a - b }
    return false if move.include?(0) || move[0].abs != move[1].abs

    through_coords = []
    dx = move[0] <=> 0
    dy = move[1] <=> 0
    (move[0].abs - 1).times do |i|
      through_coords << [from[0] + (dx * (i + 1)), from[1] + (dy * (i + 1))]
    end
    through_coords
  end
end
