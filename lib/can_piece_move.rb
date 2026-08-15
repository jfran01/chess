# frozen_string_literal: true

module PieceMoveability
  def can_coord_be_moved_from?(from)
    piece = board[from]
    can_piece_move_hash[piece.class].call(piece.player)
    binding.pry
  end

  def can_piece_move_hash
    {
      King => ->(colour, piece_coord) { king_or_queen_can_move?(colour, piece_coord) },
      Queen => ->(colour, piece_coord) { king_or_queen_can_move?(colour, piece_coord) },
      Knight => ->(colour, piece_coord) { knight_can_move?(colour, piece_coord) },
      Rook => lambda { |colour, piece_coord|
        sliding_piece_can_move?(colour, piece_coord, [[1, 0], [-1, 0], [0, 1], [0, -1]])
      },
      Bishop => lambda { |colour, piece_coord|
        sliding_piece_can_move?(colour, piece_coord, [[1, 1], [1, -1], [-1, -1], [-1, 1]])
      },
      Pawn => ->(colour, piece_coord) { pawn_can_move?(colour, piece_coord) }
    }
  end

  private

  # can king move?
  def king_or_queen_can_move?(player_colour, piece_coord)
    # king_attacks map checks all immediate squares, a queen must be able to legally move to an immediate square

    king_attacks[piece_coord].any? do |move_to|
      legal_move?(piece_coord, move_to, player_colour)
    end
  end

  # can any knights move?
  def knight_can_move?(player_colour, piece_coord)
    knight_attacks[piece_coord].any? { |move_to| legal_move?(piece_coord, move_to, player_colour) }
  end

  # can any sliding pieces move?
  def sliding_piece_can_move?(player_colour, piece_coord, offsets)
    adj_coords = offsets.map { |dx, dy| [piece_coord[0] + dx, piece_coord[1] + dy] }
    adj_coords.select! { |x, y| x.between?(1, 8) && y.between?(1, 8) }
    adj_coords.any? { |move_to| legal_move?(piece_coord, move_to, player_colour) }
  end

  # can any pawns move?
  def pawn_can_move?(player_colour, coords)
    move_to = coords
    move_to[1] += if player_colour == :white
                    1
                  else
                    -1
                  end
    board[move_to].nil?
  end
end
