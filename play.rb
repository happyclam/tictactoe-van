require "pathname"
require_relative "./disappearing_tictactoe"
require_relative "./disappearing_markov"
require_relative "./stone_agent"
require_relative "./qlearning_agent"
require_relative "./alpha-beta"

agent = nil
game = nil
order = nil
if File.exist?("./mc_agent.dump")
# if File.exist?("./q_agent.dump")
  agent = StoneAgent::read("./mc_agent.dump")
  # agent = QLearningAgent::read("./q_agent.dump")
  game = DisappearingMarkov.new
  game.reset
else
  p "学習ファイル（mc_agent.dump || q_agent.dump）が見つかりません"
  exit
end
# ---αβ法対人間用-----------------
# ab = AlphaBeta.new  #αβ法を使ったプログラムとの対戦
# ab.board.init
# ---αβ法対人間用-----------------

game.display
begin
  print "First?(y/n)："
  order = gets
end until order[0].upcase == "Y" || order[0].upcase == "N"

if order[0].upcase == "Y"
  state = game.state
  actions = game.legal_actions
  begin
    print "数字を入力後Enterキーを押してください："
    input = gets
  end until (input.to_i - 1) in actions
  move = [input.to_i - 1]
  action = agent.choose_action_greedy(state, move)
  game.play(action)
  game.display
  print "\n"
end
until game.over?
  # AIの手番
  state = game.state
  actions = game.legal_actions
  action = agent.choose_action_greedy(state, actions)
  # ---αβ法対人間用-----------------
  # action = ab.choose_action(state)
  # ---αβ法対人間用-----------------
  game.play(action)
  game.display
  break if game.over?
  # 人間の手番
  state = game.state
  actions = game.legal_actions
  begin
    print "数字を入力後Enterキーを押してください："
    input = gets
  end until (input.to_i - 1) in actions
  move = [input.to_i - 1]
  action = agent.choose_action_greedy(state, move)
  game.play(action)
  game.display
  print "\n"
end
print "Game End!\n"
