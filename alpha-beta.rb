# alpha-beta.rb

class MyBoard < Array
  MAX_VALUE = 9
  MIN_VALUE = -9
  NOUGHT = -1
  CROSS = 1
  DRAW = 0
  GAUGE = 6
  attr_reader :line
  attr_reader :weight
  attr_accessor :counter
  attr_accessor :hist
  def initialize(*args, &block)
    super(*args, &block)
    @line = []
    @line << [0, 1, 2]
    @line << [3, 4, 5]
    @line << [6, 7, 8]
    @line << [0, 3, 6]
    @line << [1, 4, 7]
    @line << [2, 5, 8]
    @line << [0, 4, 8]
    @line << [2, 4, 6]
    @weight = [1, 0, 1, 0, 2, 0, 1, 0, 1]
    @c_q = Array.new
    @c_bk = Array.new
    @n_q = Array.new
    @n_bk = Array.new
    @duplication = Hash.new
    @counter = 0
    @hist = Array.new
  end

  def init
    self.each_with_index {|n, i|
      self[i] = nil
    }
    @c_q.clear
    @c_bk.clear
    @n_q.clear
    @n_bk.clear
    @duplication.clear
    @counter = 0
    @hist.clear
  end

  def check_dup(sengo)
    temp = self.dup
    temp.unshift(sengo)
    return @duplication.has_key?(temp.hash)
  end

  def set_dup(sengo)
    temp = self.dup
    temp.unshift(sengo)
    @duplication[(temp).hash] = temp
  end

  def set(i, v)
    if self[i] || (i > 8) || (i < 0)
      raise "Error!"
    else
      self[i] = v
    end
    if v == CROSS
      @c_q << i
      if @c_q.size > 3
        idx = @c_q.shift
        @c_bk.push([idx, self[idx]])
        self[idx] = nil
      end
    elsif v == NOUGHT
      @n_q << i
      if @n_q.size > 3
        idx = @n_q.shift
        @n_bk.push([idx, self[idx]])
        self[idx] = nil
      end
    end
  end

  def unset(v)
    if v == CROSS
      if @c_bk.size > 0
        h = Hash[*(@c_bk.pop)]
        temp = h.each{|k, v| self[k] = v}
        @c_q.unshift(temp.keys[0])
      end
      idx = @c_q.pop
    elsif v == NOUGHT
      if @n_bk.size > 0
        h = Hash[*(@n_bk.pop)]
        temp = h.each{|k, v| self[k] = v}
        @n_q.unshift(temp.keys[0])
      end
      idx = @n_q.pop
    end
    self[idx] = nil
  end

  def droppable
    return false if (self.select{|b| !b}.size == 0)
    self.line.each {|l|
      piece = self[l[0]]
      if (piece && piece == self[l[1]] && piece == self[l[2]])
        return false
      end
    }
    return true
  end

  def display
    print " "
    "a".ord.step("a".ord + 3 - 1, 1){|row| print " " + " "}
    print "\n"
    self.each_with_index{|b, i|
      print " |" if (i % 3) == 0
      print n2c(i) + "|"
      print "\n" if (i % 3) == 2
    }
  end

  private
  def n2c(idx)
    case self[idx]
    when CROSS
      "X"
    when NOUGHT
      "O"
    else
      (idx + 1).to_s
    end
  end
end

class AlphaBeta
  MAX_VALUE = 9
  MIN_VALUE = -9
  NOUGHT = -1
  CROSS = 1
  DRAW = 0
  LIMIT = 12

  attr_reader :board

  def initialize
    @board = MyBoard.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
    @duplication = Hash.new
  end

  def choose_action(state)
    # stateデータからMyBoard用の局面データに変換
    turn = nil; moved = nil
    state.each_with_index do |cell, i|
      if i == 9
        turn = (cell == :X) ? CROSS : NOUGHT
        if turn == CROSS
          moved = state[10].last if state[10].length > 0
        elsif turn == NOUGHT
          moved = state[11].last if state[11].length > 0
        else
          p "ab.choose_action Error! cell = #{cell}"
          exit
        end
        break
      end
      @board[i] = cell.nil? ? nil : (cell[0] == :X ? CROSS : NOUGHT)
    end
    oppo = (turn == CROSS) ? NOUGHT : CROSS
    # state内容に従ってAlphaBetaクラス内でも着手を再現
    unless moved.nil?
      @board[moved] = nil
      @board.set(moved, oppo);@board.set_dup(oppo)
    end
    if turn == CROSS
      threshold = MAX_VALUE
    elsif turn == NOUGHT
      threshold = MIN_VALUE
    else
      p "Error!! turn = #{turn}"
      exit
    end
    temp_v, locate = lookahead(@board, turn, 0, threshold)
    # p "temp_v = #{temp_v}, locate = #{locate}"
    @board.set(locate, turn); @board.set_dup(turn)
    # p @board
    return locate
  end

  private
  def check(board)
    return true if (board.select{|b| !b}.size == 0)
    board.line.each {|l|
      piece = board[l[0]]
      if (piece && piece == board[l[1]] && piece == board[l[2]])
        return true
      end
    }
    return false
  end

  def evaluation(board)
    board.counter += 1
    cross_win = false
    nought_win = false
    board.line.each {|l|
      piece = board[l[0]]
      if (piece && piece == board[l[1]] && piece == board[l[2]])
        cross_win = true if (piece == CROSS)
        nought_win = true if (piece == NOUGHT)
      end
    }
    if (cross_win && !nought_win)
      return MAX_VALUE
    elsif (nought_win && !cross_win)
      return MIN_VALUE
    else
      return DRAW
    end
  end
  def lookahead(board, turn, cnt, threshold)
    if turn == CROSS
      value = MIN_VALUE
    else
      value = MAX_VALUE
    end
    locate = nil
    board.each_with_index {|b, i|
      next if b
      board.set(i, turn)
      if !check(board) && (cnt < LIMIT)
        if board.check_dup(turn)
          temp_v = 0
        else
          teban = (turn == CROSS) ? NOUGHT : CROSS
          temp_v, temp_locate = lookahead(board, teban, cnt + 1, value)
        end
      else
        temp_v = evaluation(board)
      end
      board.unset(turn)
      if (temp_v >= value && turn == CROSS)
        value = temp_v
        locate = i
        break if (threshold < temp_v)
      elsif (temp_v <= value && turn == NOUGHT)
        value = temp_v
        locate = i
        break if (threshold > temp_v)
      end
    }
    return value, locate
  end
end
