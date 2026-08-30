module NextMove
  def make_move(curr_player)
    moving_piece, from_coord = choose_move_from(curr_player)
    return :save_game if moving_piece == :save_game

    to_coord = choose_move_to(curr_player, moving_piece, from_coord)
    return :save_game if to_coord == :save_game

    puts "Moving #{moving_piece.class.to_s.downcase} from #{convert_coord_to_notation(from_coord)} to #{convert_coord_to_notation(to_coord)}"
    move_piece_position(moving_piece, from_coord, to_coord)
    promotion(curr_player.colour, from_coord, to_coord) if moving_piece.is_a?(Pawn)
    toggle_move_status(moving_piece)
    toggle_en_passant_capture(curr_player.colour)
  end

  def move_piece_position(moving_piece, from_coord, to_coord)
    move_adj_rook(to_coord) if legal_castling?(moving_piece, from_coord, to_coord)
    captured_piece = board[to_coord]
    captured_piece = capture_en_passant_pawn(from_coord, to_coord) if moving_piece.is_a?(Pawn) && legal_en_passant?(moving_piece.player, from_coord,
                                                                                                                    to_coord)
    board[to_coord] = board[from_coord]
    board[from_coord] = nil
    return if captured_piece.nil?

    puts "Congratulations! (and commiserations...) A #{captured_piece.player} #{captured_piece.class.to_s.downcase} has been captured."
    @captured_pieces << captured_piece
  end

  def move_adj_rook(to_coord)
    if to_coord[0] == 7
      rook_from_coord = [8, to_coord[1]]
      rook_to_coord = [6, to_coord[1]]
    elsif to_coord[0] == 2
      rook_from_coord = [1, to_coord[1]]
      rook_to_coord = [3, to_coord[1]]
    end
    board[rook_to_coord] = board[rook_from_coord]
    board[rook_from_coord] = nil
  end

  def capture_en_passant_pawn(from_coord, to_coord)
    adj_pawn_coord = [to_coord[0], from_coord[1]]
    captured_pawn = board[adj_pawn_coord]
    board[adj_pawn_coord] = nil
    captured_pawn
  end

  def choose_move_from(curr_player)
    loop do
      from_coord = curr_player.move_from
      return :save_game if from_coord == :save_game

      moving_piece = board[from_coord]
      if moving_piece.nil?
        puts "Kinda difficult to move a piece that doesn't exist..."
      elsif moving_piece.player != curr_player.colour
        puts 'You cannot move from a square that does not contain a piece of your colour; use your own army, imperialist.'
      elsif !legal_move_from?(moving_piece, from_coord)
        puts 'That piece cannot move. At all.'
      else
        return [moving_piece, from_coord]
      end
      puts "Let's try that again, shall we?"
    end
  end

  def choose_move_to(curr_player, moving_piece, from_coord)
    to_coord = curr_player.move_to
    return :save_game if to_coord == :save_game

    until legal_move_to?(moving_piece, from_coord, to_coord)
      converted_coords = [convert_coord_to_notation(from_coord), convert_coord_to_notation(to_coord)]
      puts "Your #{moving_piece.class.to_s.downcase} cannot move from #{converted_coords[0]} to #{converted_coords[1]} without imploding. Try again."
      to_coord = curr_player.move_to
    end
    to_coord
  end

  def toggle_move_status(piece)
    return unless (piece.is_a?(King) || piece.is_a?(Rook)) && !piece.moved

    piece.moved = true
  end

  def toggle_en_passant_capture(colour)
    enemy_pawns = board.values.select { |piece| piece.is_a?(Pawn) && piece.player != colour }
    enemy_pawns.each { |pawn| pawn.en_passant_capture = false }
  end
end
