#-*- coding: utf-8 -*-
require "./constant.rb"
require "./game.rb"

sente_player = Player.new(CROSS, false)
sente_player.prepare

10.times {|n|
  target = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
  if n < 9
    # target[n] = 1
    target.set(n, 1)
  end

  # target.display
  buf = sente_player.trees.search(target)
  p "buf.score = #{buf.score}"
  # p "buf.value.teban = #{buf.value.teban}"
}

p "============================================================"
# target = Board.new([nil, nil, nil, nil, nil, nil, nil, nil, nil])
# count = 0
# (0..8).each{|first|
#   # target[first] = CROSS
#   target.set(first, CROSS)
#   (0..8).each{|second|
#     p "#{first} - #{second}"
#     if target[second] == nil
#       count += 1
#       # target[second] = NOUGHT
#       target.set(second, NOUGHT)
#       target.display
#       buf = sente_player.trees.search(target)
#       p buf.score if buf
#       p buf.value._q
#       p "buf.value.teban = #{buf.value.teban}"
#       target.unset
#     end
#   }
#   # target[first] = nil
#   target.unset
# }
# p "count = #{count}"

# p sente_player.trees.count(target)

# buf = target
# begin
#   buf = sente_player.trees.parent(buf)
#   buf.display
#   p buf.move if buf
# end until buf == nil

#trees.show
#p "test"
#p trees.total
#Tree::save("./temp.dump", trees)

# p "statistics_prevent"
# total, pebbles = sente_player.trees.statistics_prevent
# p total
# p pebbles
# p "progress = #{(pebbles / total) * 100}%"
# p "count = #{Tree.counter}"
Tree.counter = 0
sente_player.outputJson
p "count = #{Tree.counter}"
