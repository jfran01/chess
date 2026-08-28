module Check
  def check?(king_colour, king_coords = find_piece_coords(King, king_colour)[0])
    return true if attack_by_pawn?(king_colour, king_coords)
    return true if attack_by_knight?(king_colour, king_coords)
    return true if attack_by_sliding_piece?(king_colour, king_coords)

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
    pawn_coords.any? { |coord| board[coord].is_a?(Pawn) && board[coord].player != colour }
  end

  def attack_by_knight?(colour, coords)
    knight_attacks[coords].any? { |coord| board[coord].is_a?(Knight) && board[coord].player != colour }
  end

  def attack_by_sliding_piece?(colour, king_coords)
    enemy_sliding_pieces = enemy_sliding_piece_coords(colour)
    enemy_sliding_pieces.any? do |enemy_coord|
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
  def avoid_checkmate(king_colour)
    king_coords = find_piece_coords(King, king_colour)&.first
  end

  def escape_check?(king_coords)
    adj_squares[king_coords].any? do |adj_coord|
      legal_move_to?(board[king_coords], king_coords, adj_coord)
    end
  end
end
