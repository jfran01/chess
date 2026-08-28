module Check
  def check?(king_colour, king_coords = find_piece_coords(King, king_colour)[0])
    checking_pieces = 0
    checking_pieces += attack_by_pawn?(king_colour, king_coords).size
    checking_pieces += attack_by_knight?(king_colour, king_coords).size
    checking_pieces += attack_by_sliding_piece?(king_colour, king_coords).size

    return checking_pieces unless checking_pieces.zero?

    false
  end

  def find_piece_coords(target_piece, colour)
    board.select { |_coord, piece| !piece.nil? && piece.instance_of?(target_piece) && piece.player == colour }.keys
  end

  def attack_by_pawn?(colour, coords)
    pawn_coords = if colour == :white
                    white_pawn_attacks[coords]
                  else
                    black_pawn_attacks[coords]
                  end
    pawn_coords.select { |coord| board[coord].is_a?(Pawn) && board[coord].player != colour }
  end

  def attack_by_knight?(colour, coords)
    knight_attacks[coords].select { |coord| board[coord].is_a?(Knight) && board[coord].player != colour }
  end

  def attack_by_sliding_piece?(colour, king_coords)
    enemy_sliding_pieces = enemy_sliding_piece_coords(colour)
    enemy_sliding_pieces.select do |enemy_coord|
      legal_slide?(board[enemy_coord], king_coords, enemy_coord)
    end
  end

  def enemy_sliding_piece_coords(colour)
    pieces = []
    board.each do |coord, piece|
      pieces << coord if !piece.nil? && piece.player != colour && (piece.is_a?(Rook) || piece.is_a?(Queen) || piece.is_a?(Bishop))
    end
    pieces
  end

  def enemy_colour(colour)
    return :black if colour == :white

    :white
  end
end

module Checkmate
  include Check
  def avoid_checkmate?(king_colour)
    king_coords = find_piece_coords(King, king_colour)&.first
    num_checking_pieces = check?(king_colour, king_coords)
    return true if legal_move_from?(board[king_coords], king_coords)
    return false if num_checking_pieces > 1

    false
  end

  def block_check?(king_colour, king_coords)
    sliding_attack_coords = attack_by_sliding_piece?(king_colour, king_coords)
    return false if sliding_attack_coords.empty?

    sliding_attack_coords.each do |sliding_coord|
      return false if adj_squares[king_coords].include?(sliding_coord)

      move = king_coords.zip(sliding_coord).map { |x, y| x - y }
      through_coords = through_coords(sliding_coord, king_coords, move)
      return true if through_coords.any? { |through| check?(enemy_colour(king_colour), through) }
    end

    false
  end
end
