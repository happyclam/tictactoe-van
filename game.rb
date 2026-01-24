#-*- coding: utf-8 -*-
#require "pry"
require "pp"
require "pathname"
# require "digest/md5"
require "json"
require "bigdecimal"

class Tree
  @@total = 0
  @@pebbles = 0
  @@counter = 0
  attr_reader :value, :child, :score

  def self.counter
    @@counter
  end

  def self.counter=(val)
    @@counter = val
  end

  def self.toHex(val)
    ret = ""
    val.each_with_index{|v, i|
      if i == 0
        ret += (v[0] == 0) ? "9" : v[0].to_s
      else
        ret += v[0].to_s
      end
    }
    ret.to_i(16)
  end

  def self.toAry(val)
    ret = []
    return ret if val <= 0
    temp = val.to_s(16)
    temp.each_char.with_index{|v, i|
      if i == 0
        ret << [(v == "9") ? 0 : v.to_i, (i % 2) == 0 ? CROSS : NOUGHT]
      else
        ret << [v.to_i, (i % 2) == 0 ? CROSS : NOUGHT]
      end
    }
    return ret
  end

  def initialize(v, pebbles=PEBBLES)
    # @value = v.clone
    # @value = Digest::MD5.new.update(v._q.to_s).to_s
    # @value = v._q.to_s
    @value = Tree.toHex(v._q)
    @child = []
    #盤面が指定されている時は、すでに駒が置かれているところは
    #選べないようにあらかじめ 0 をセットしておく
    @score = [nil, nil, nil, nil, nil, nil, nil, nil, nil]
    # @score.map!.with_index{|n,i| (v[i] == nil) ? pebbles : nil}
    v.each_with_index{|b, i|
      @score[i] = (b == nil) ? pebbles : nil
    }
    @@counter = 0
    @@total = 0
  end

  def total
    return @@total
  end

  def toJson
    @@counter += 1 if @score.select{|v| v!=1.0 && v!=nil} == []
    # @@counter += 1
    ret = nil
    h = Hash.new
    h["value"] = @value
    h["child"] = []
    @child.each_with_index { |c, i|
      h["child"][i] = c.toJson
    }
    h["score"] = @score.clone
    return h
  end

  #動作確認用
  #一つ目のパラメータで指定された局面データ（親）を探して、その子ノードとしてオブジェクトを追加する
  def add(target, obj)
    ret = nil
    hexValue = Tree.toHex(target._q)
    @child.each_with_index { |c, i|
      if c.value == hexValue
        ret = c.child.push(obj)
      else
        ret = c.add(target, obj)
      end
      break if ret
    }
    return ret
  end
  #（その手に対するscore／局面にあるscoreの総数）の確率で手を選択する
  def apply(v)
    node = search(v)
    if node
      return idx(node.score)
    else
      p "=== Not Found ==="
      return nil
    end
  end
  #指定された局面のノードを返す
  def search(v)
    return nil if !v
    if v._i > GAUGE
      if (v._i % 2) == 1
        comp = v._q.values_at(-(GAUGE - 1)..-1, -GAUGE)
      else
        comp = v._q.values_at(-GAUGE..-1)
      end
    else
      comp = v._q
    end
    hexValue = Tree.toHex(comp)
    if @value == hexValue
      return self
    end
    ret = nil
    @child.each { |c|
      if c.value == hexValue
        ret = c
      else
        ret = c.search(v)
      end
      break if ret
    }
    return ret
  end
  #リーチ状態の局面を探してscoreを集計する
  def statistics_prevent
    # total = @score.inject(0){|sum, n| (n) ? sum + n : sum}
    # good = @score.select.with_index{|v, i| (i % 2) == 1}.inject(0){|sum, n| (n) ? sum + n : sum }
    # return total, good

    if @value == 0
      ret, good = good_move(self)
      @@total = @@total + @score.inject(0){|sum, n| (n) ? sum + n : sum}
      @@pebbles = @@pebbles + good
      # p "@@total = #{@@total}, @@pebbles = #{@@pebbles}"
    end
    @child.each { |c|
      @@counter += 1
      # locate = nil
      # ret, locate = reach(c.value)
      # ret, locate = fade_reach(c.value)
      # ret, locate = van_reach(c.value)
      # p "ret = #{ret}, locate = #{locate}"
      # p "score = #{c.score}"
      # if ret == CROSS || ret == NOUGHT
      #   @@total = @@total + c.score.inject(0){|sum, n| (n) ? sum + n : sum}
      #   @@pebbles = @@pebbles + c.score[locate]
      # end
      ret, good = good_move(c)
      if ret
        @@total = @@total + c.score.inject(0){|sum, n| (n) ? sum + n : sum}
        @@pebbles = @@pebbles + good
        # p "@@total = #{@@total}, @@pebbles = #{@@pebbles}"
      end
      @@total, @@pebbles = c.statistics_prevent
    }
    return @@total, @@pebbles
  end
  #動作確認用
  def count(v)
    @child.each { |c|
      if c.value == v
        @@counter += 1
      else
        @@counter = c.count(v)
      end
    }
    @@counter
  end
  #動作確認用
  def parent(v)
    ret = nil
    @child.each { |c|
      if c.value == v
        ret = self
      else
        ret = c.parent(v)
      end
      break if ret
    }
    return ret
  end

  def self.read(path)
    begin
      Pathname.new(path).open("rb") do |f|
        trees = Marshal.load(f)
      end
    rescue
      p $!
    end
  end

  def self.save(path, obj)
    begin
      Pathname.new(path).open("wb") do |f|
        Marshal.dump(obj, f)
      end
    rescue
      p $!
    end
  end

  private
  def idx(score)
    ret = nil
    index = rand(score.inject(0){|sum, n| (n) ? sum + n : sum} * 10) / 10.0
    start = 0
    score.each_with_index{|v, i|
      next unless v
      start += v
      if start > index
        ret = i
        break
      end
    }
    return ret
  end

  def good_move(board)
    aryValue = Tree.toAry(board.value)
    if aryValue.size > 1
      return false, nil
    # else
    #   p "aryValue.size = #{aryValue.size}"
    #   p "aryValue = #{aryValue}"
    #   p "score = #{board.score}"
    end
    # 空いている場所
    src = [0, 1, 2, 3, 4, 5, 6, 7, 8]
    rest = src - aryValue.map{|v| v[0]}
    good = 0
    case rest.size
    when 9
      # 初期盤面で辺の部分に打つ確率
      good = board.score.select.with_index{|v, i| (i % 2) == 1}.inject(0){|sum, n| (n) ? sum + n : sum }
    when 8
      # 初手で角に打たれたら、２手目で真ん中に打つ確率
      if aryValue[0][0] == 0 || aryValue[0][0] == 2 || aryValue[0][0] == 6 || aryValue[0][0] == 8
        good = board.score.select.with_index{|v, i| (i == 4)}.inject(0){|sum, n| (n) ? sum + n : sum }
      # 初手で真ん中に打たれたら、２手目で角の位置に打つ確率
      elsif aryValue[0][0] == 4
        good = board.score.select.with_index{|v, i| (i == 0) || (i == 2) || (i == 6) || (i == 8)}.inject(0){|sum, n| (n) ? sum + n : sum }
      # 初手で辺に打たれたら、２手目でどこに打とうが後手の負け
      else
        good = 0
      end
    else
      good = 0
    end
    # p "good = #{good}"
    return true, good
  end

  # def van_reach(board)
  #   aryValue = Tree.toAry(board)
  #   # p aryValue
  #   if aryValue.size < 4
  #     return ONGOING, nil
  #   end
  #   # 手番
  #   if aryValue.size >= GAUGE
  #     turn = nil
  #   else
  #     turn = (aryValue.last[1] == CROSS) ? NOUGHT : CROSS
  #   end
  #   # 空いている場所
  #   src = [0, 1, 2, 3, 4, 5, 6, 7, 8]
  #   rest = src - aryValue.map{|v| v[0]}
  #   # 次の指し手後も残る先手の駒
  #   l_cross = [aryValue.reverse.select{|v| v[1]==CROSS}[0][0], aryValue.reverse.select{|v| v[1]==CROSS}[1][0]]
  #   # 次の指し手後も残る後手の駒
  #   l_nought = [aryValue.reverse.select{|v| v[1]==NOUGHT}[0][0], aryValue.reverse.select{|v| v[1]==NOUGHT}[1][0]]
  #   locate = nil
  #   Board.lines.each {|l|
  #     # diff_cross = l - l_cross
  #     # diff_nought = l - l_nought
  #     rest.each{|locate|
  #       case turn
  #       when CROSS
  #         l_cross.push(locate)
  #         if (l - l_cross)==[]
  #           return CROSS, locate
  #         end
  #         l_cross.pop
  #       when NOUGHT
  #         l_nought.push(locate)
  #         if (l - l_nought)==[]
  #           return NOUGHT, locate
  #         end
  #         l_nought.pop
  #       else
  #         l_cross.push(locate)
  #         if (l - l_cross)==[]
  #           return CROSS, locate
  #         end
  #         l_cross.pop
  #         l_nought.push(locate)
  #         if (l - l_nought)==[]
  #           return NOUGHT, locate
  #         end
  #         l_nought.pop
  #       end
  #     }
  #   }
  #   return ONGOING, nil
  # end

  #リーチ局面の判定（リーチかどうかを知りたいだけなので、ゲーム終了していてもONGOINGを返している）
  def reach(board)
    cross_reach = false
    nought_reach = false
    locate = nil
    Board.lines.each {|l|
      piece = board[l[0]]
      if (piece && piece == board[l[1]] && piece == board[l[2]])
        cross_reach = false
        nought_reach = false
        locate = nil
        break
      else
        case board.teban
        when NOUGHT
          if (board[l[0]] == CROSS && board[l[1]] == CROSS && board[l[2]] == nil)
            cross_reach = true
            locate = l[2]
          elsif (board[l[0]] == nil && board[l[1]] == CROSS && board[l[2]] == CROSS)
            cross_reach = true
            locate = l[0]
          elsif (board[l[0]] == CROSS && board[l[1]] == nil && board[l[2]] == CROSS)
            cross_reach = true
            locate = l[1]
          end
        when CROSS
          if (board[l[0]] == NOUGHT && board[l[1]] == NOUGHT && board[l[2]] == nil)
            nought_reach = true
            locate = l[2]
          elsif (board[l[0]] == nil && board[l[1]] == NOUGHT && board[l[2]] == NOUGHT)
            nought_reach = true
            locate = l[0]
          elsif (board[l[0]] == NOUGHT && board[l[1]] == nil && board[l[2]] == NOUGHT)
            nought_reach = true
            locate = l[1]
          end
        else
          p "error ======================"
        end
      end
    }
    if cross_reach
      return CROSS, locate
    elsif nought_reach
      return NOUGHT, locate
    else
      return ONGOING, locate
    end
  end

end

class Game
  attr_accessor :board, :history

  def initialize
    @board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
    @history = []
  end

  def command(player)
    # locate = player.trees.apply(@board)
    # player.persist.clear
    # threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
    # temp_v, locate = player.lookahead(@board, player.sengo, 0, threshold)
    # p "temp_v = #{temp_v}, locate = #{locate}"
    # #後手の時で次の一手で勝つ時（temp_v != MIN_VALUE）以外は相手が揃う手を優先して妨害する
    # if player.persist[1] && player.sengo == NOUGHT && temp_v != MIN_VALUE
    #   locate = player.persist[1] unless @board[player.persist[1]]
    # end

    #人間役は常に機械学習ルーチンじゃない方
    #(=ソフト同志対戦させる時は常に機械学習ルーチンじゃ無い方のhumanプロパティをtrueにする)
    unless player.human
      locate = player.trees.apply(@board)
      p "AI locate = #{locate}"
    else
      #強いDFSと対戦
      rest = @board.select{|b| !b}.size
      if rest == 9
        locate = rand(9)
      else
        player.persist.clear
        threshold = (player.sengo == CROSS) ? MAX_VALUE : MIN_VALUE
        #後手の時で次の一手で勝つ時（temp_v != MIN_VALUE）以外は相手が揃う手を優先して妨害する
        temp_v, locate = player.lookahead(@board, player.sengo, 0, threshold)
        if player.persist[1] && player.sengo == NOUGHT && temp_v != MIN_VALUE
          locate = player.persist[1] unless @board[player.persist[1]]
        end
      end
      # #乱数と対戦
      # temp_v = nil
      # locate = rand(9)
      # p "locate = #{locate}"
      # while @board[locate] != nil
      #   locate = rand(9)
      # end
      p "Error" unless locate
      p "temp_v = #{temp_v}, locate = #{locate}"
    end
    if locate
      # @board[locate] = player.sengo
      @board.set(locate, player.sengo)
      @board.move = locate
      @history.push(@board.clone)
      @board.set_dup
      return true
    else
      return false
    end

  end

  def decision
    cross_win = false
    nought_win = false
    Board.lines.each {|l|
      piece = @board[l[0]]
      if (piece && piece == @board[l[1]] && piece == @board[l[2]])
        cross_win = true if (piece == CROSS)
        nought_win = true if (piece == NOUGHT)
      end
    }
    if (cross_win && !nought_win)
      return CROSS
    elsif (nought_win && !cross_win)
      return NOUGHT
    else
      if (@board.select{|b| !b}.size == 0)
        return DRAW
      else
        return ONGOING
      end
    end
  end

end

class Board < Array
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

class Player
  attr_accessor :sengo, :human, :trees
  attr_accessor :persist
  def initialize(sengo, human)
    @human = human
    @sengo = sengo
    @duplication = Hash.new
    @trees = nil
    @persist = Array.new
  end

  def prepare
    if File.exist?("./trees.dump")
      @trees = Tree::read("./trees.dump")
    else
      board = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
      @trees = Tree.new(board, PEBBLES)
      bfs(board)
    end
  end

  def learning(result, history)
    board = history.pop
    buf = @trees.search(board)
    pre_index = board.move
    #最後の手を取得してすぐにpopして一つ前の局面のscoreを更新する
    base = history.size.to_f
    while board
      dose = history.size / base
#      dose = 0.029 * 1.882 ** history.size
#      dose = 0.188 * 1.588 ** history.size
#      dose = (history.size <= 0) ? 0.1 : ((1.0 / base) + Math.log(history.size, base))
      case result
      when CROSS
        inc = (@sengo == CROSS) ? (3.0 * dose) : (-1.0 * dose)
      when DRAW
        inc = 1.0
      when NOUGHT
        inc = (@sengo == NOUGHT) ? (3.0 * dose) : (-1.0 * dose)
      end
      board = history.pop
      buf = @trees.search(board)
      if buf
        # p "=== learning ==="
        # p "board = #{board}"
        # p "board.teban = #{board.teban}"
        # p "inc = #{inc}"
        # p "@sengo = #{@sengo}"
        # p "buf.value = #{buf.value}"
        aryValue = Tree.toAry(buf.value)
        turn = ((board._q.size % 2) == 0) ? CROSS : NOUGHT
        # p "aryValue = #{aryValue}"
        # p "turn = #{turn}"
        # p "buf.score = #{buf.score}"
        buf.score[pre_index] += inc if (@sengo == turn)
        # p "buf.score = #{buf.score}"
        #石が０個になっていたら置ける箇所全てに追加（小数に対応するために0.1に変更）
        if buf.score[pre_index] <= 0.1
          positive = buf.score.min_by{|v| v.to_i}
          positive = positive ? (positive.abs + PEBBLES) : PEBBLES
          buf.score.map!{|v|
            v += positive if v
          }
        #数値が大きくなり過ぎたら１０分の１にする
        elsif buf.score[pre_index] > 100
          #指数表示になるとjsonに影響が出るかもしれないし、かと言って０になっても困るので
          #小数点以下第３位で切り上げ
          buf.score.map!{|v|
            v = BigDecimal((v / 10).to_s).ceil(3).to_f if v
          }
        end
        pre_index = board.move
      end
    end
    Tree::save("./trees.dump", @trees)
  end

  def init_dup
    @duplication.clear
  end

  def check_dup(board)
    temp = board.dup
    seed = temp._q.hash
    return @duplication.has_key?(seed)
  end

  def set_dup(board)
    temp = board.dup
    seed = temp._q.hash
    @duplication[seed] = board
  end

  def byweight(board)
    cross = 0
    nought = 0
    board.each_with_index {|p, i|
      if p == CROSS
        cross += Board.weights[i]
      elsif p == NOUGHT
        nought += Board.weights[i]
      end
    }
    return (cross - nought)
  end

  #勝負がついたか、置き場所が無くなったらtrueを返す
  def check(board)
    return true if (board.select{|b| !b}.size == 0)
    Board.lines.each {|l|
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
    Board.lines.each {|l|
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

  def bfs(board)
    init_dup
    queue = Array.new

    seq = Array.new(10,0)
    board.teban = CROSS
    set_dup(board); queue.push(board)

    n_cross = 0
    n_nought = 0
    n_draw = 0
    while queue != [] do
      buf = queue.shift
      layer = 9 - buf.select{|b| !b}.size
      buf.each_with_index {|b, i|
        next if b
        temp = buf.clone
        temp.set(i, buf.teban)
        temp.teban = ((layer % 2) == 1) ? CROSS : NOUGHT
        # p "check"
        # p "temp = #{temp}"
        # p seq
        # p temp._q
        # p temp._i
        # temp.display
        #重複データを削除しているので、Treeデータ生成時のmoveは意味がない
        temp.move = i
        #６手目までのすべての順列パターンをゲーム木に含めるので重複チェックは不要
        # next if check_dup(temp)
        next if layer > 5
        seq[layer] += 1
        case layer
        when 0
          @trees.child.push(Tree.new(temp, PEBBLES))
        else
          @trees.add(buf, Tree.new(temp, PEBBLES))
        end
        set_dup(temp); queue.push(temp)
      }
    end
    p "seq = #{seq}"
    p seq.inject(0){|sum, n| sum + n}
    return seq
  end

  def outputJson
    ret = @trees.toJson
    # File.open("output.json", 'w') do |file|
    #   hash = { "Ocean" => { "Squid" => 10, "Octopus" =>8 }}
    #   str = JSON.dump(ret, file)
    # end
  end

end
