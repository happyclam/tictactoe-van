# alpha-beta.rb

class MyBoard < Array
  MAX_VALUE = 9
  MIN_VALUE = -9
  NOUGHT = -1
  CROSS = 1
  DRAW = 0
  GAUGE = 6
  @@lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ]
  @@weights = [1, 0, 1, 0, 2, 0, 1, 0, 1]
  attr_accessor :teban
  attr_accessor :move
  attr_accessor :_q, :_i
  def initialize(*args, &block)
    super(*args, &block)
    @_q = Array.new
    @_i = 0
    @teban = CROSS
    # Treeの重複局面チェック用とは別に千日手回避用Hash
    @repetition = Hash.new
  end

  def self.weights
    @@weights
  end

  def self.lines
    @@lines
  end

  def initialize_copy(obj)
    obj.each_with_index{|n,i| self[i] = n}
    @_q = obj._q.dup
  end

  def init
    self.each_with_index {|n, i|
      self[i] = nil
    }
    @_q.clear
    @_i = 0
    @repetition.clear
  end

  def self.weight
    @@weight
  end

  def line
    @@line
  end

  def check_dup
    temp = self.dup
    seed = temp._q.hash
    return @repetition.has_key?(seed)
  end

  def set_dup
    temp = self.dup
    seed = temp._q.hash
    @repetition[seed] = temp
  end

  def set(i, v)
    if self[i] || (i > 8) || (i < 0)
      raise "Error!"
    else
      self[i] = v
    end
    @_q << [i, v]
    @_i += 1
    if @_i > GAUGE
      self[@_q[@_i - GAUGE - 1][0]] = nil
    end
  end

  def unset
    temp = @_q.pop
    if temp
      @_i -= 1
      if @_i >= GAUGE
        self[@_q[@_i - GAUGE][0]] = @_q[@_i - GAUGE][1]
      end
      self[temp[0]] = nil
    end
  end

  def droppable
    return false if (self.select{|b| !b}.size == 0)
    @@lines.each {|l|
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
    @persist = Array.new
  end

  def choose_action(state, turn)
    state.each_with_index do |cell, i|
      break if i >= 9
      @board[i] = cell.nil? ? nil : (cell[0] == :X ? CROSS : NOUGHT)
    end

    if turn == :X
      threshold = MIN_VALUE
      sengo = NOUGHT
    elsif turn == :O
      threshold = MAX_VALUE
      sengo = CROSS
    else
      p "Error!! turn = #{turn}"
      exit
    end
    # p "sengo = #{sengo}, threshold = #{threshold}"
    @persist.clear
    temp_v, locate = lookahead(@board, sengo, 0, threshold)
    if @persist[1] && sengo == NOUGHT && temp_v != MIN_VALUE
      locate = @persist[1] unless @board[@persist[1]]
    end
    # temp_v, locate = lookahead(@board, sengo, 0, threshold)
    @board.set_dup
    return locate
  end

  private
  def check(board)
    return true if (board.select{|b| !b}.size == 0)
    MyBoard.lines.each {|l|
      piece = board[l[0]]
      if (piece && piece == board[l[1]] && piece == board[l[2]])
        return true
      end
    }
    return false
  end

  def evaluation(board)
    cross_win = false
    nought_win = false
    MyBoard.lines.each {|l|
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
        if board.check_dup
          temp_v = 0
        else
          teban = (turn == CROSS) ? NOUGHT : CROSS
          temp_v, temp_locate = lookahead(board, teban, cnt + 1, value)
        end
      else
        temp_v = evaluation(board)
        if (temp_v == MIN_VALUE && @sengo == CROSS)
          @persist[cnt] = i
        elsif (temp_v == MAX_VALUE && @sengo == NOUGHT)
          @persist[cnt] = i
        end
      end
      board.unset
      if (temp_v > value && turn == CROSS)
        value = temp_v
        locate = i
        break if threshold < temp_v
      elsif (temp_v < value && turn == NOUGHT)
        value = temp_v
        locate = i
        break if threshold > temp_v
      elsif (temp_v == value)
        if rand(2) == 1 || locate == nil
          locate = i
        end
      end
    }
    return value, locate
  end
end
