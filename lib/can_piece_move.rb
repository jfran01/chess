# frozen_string_literal: true

module PieceMoveability
  def can_coord_be_moved_from?(from)
    piece = board[from]
    can_piece_move_hash[piece.class].call(piece.player)
  end

  def can_piece_move_hash
    {
      King => ->(colour) { king_or_queen_can_move?(colour, King) },
      Queen => ->(colour) { king_or_queen_can_move?(colour, Queen) },
      Knight => ->(colour) { knight_can_move?(colour) },
      Rook => ->(colour) { sliding_piece_can_move?(colour, Rook, [[1, 0], [-1, 0], [0, 1], [0, -1]]) },
      Bishop => ->(colour) { sliding_piece_can_move?(colour, Bishop, [[1, 1], [1, -1], [-1, -1], [-1, 1]]) },
      Pawn => ->(colour) { pawn_can_move?(colour) }
    }
  end

  private

  # can king move?
  def king_or_queen_can_move?(player_colour, piece_type)
    # king_attacks map checks all immediate squares, a queen must be able to legally move to an immediate square
    piece_coord = find_piece_coords(piece_type, player_colour)[0]
    return false unless piece_coord

    king_attacks[piece_coord].any? do |move_to|
      legal_move?(piece_coord, move_to, player_colour)
    end
  end

  # can any knights move?
  def knight_can_move?(player_colour)
    find_piece_coords(Knight, player_colour).any? do |knight_coord|
      knight_attacks[knight_coord].any? { |move_to| legal_move?(knight_coord, move_to, player_colour) }
    end
  end

  # can any sliding pieces move?
  def sliding_piece_can_move?(player_colour, piece_type, offsets)
    find_piece_coords(piece_type, player_colour).any? do |piece_coord|
      adj_coords = offsets.map { |dx, dy| [piece_coord[0] + dx, piece_coord[1] + dy] }
      adj_coords.select! { |x, y| x.between?(1, 8) && y.between?(1, 8) }
      adj_coords.any? { |move_to| legal_move?(piece_coord, move_to, player_colour) }
    end
  end

  # can any pawns move?
  def pawn_can_move?(player_colour, coords = find_piece_coords(Pawn, player_colour))
    coords.any? do |pawn_coord|
      move_to = pawn_coord
      move_to[1] += if player_colour == :white
                      1
                    else
                      -1
                    end
      board[move_to].nil?
    end
  end
end
