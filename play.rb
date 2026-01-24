require "pathname"
require_relative "./disappearing_tictactoe"
require_relative "./disappearing_markov"
require_relative "./stone_agent"

agent = nil
game = nil
order = nil
history = []
if File.exist?("./stones.dump")
  agent = StoneAgent::read("./stones.dump")
  # game = DisappearingTicTacToe.new
  game = DisappearingMarkov.new
  game.reset
else
  p "学習ファイル（stones.dump）が見つかりません"
  exit
end

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
  action = agent.choose_action(state, move)
  game.play(action)
  game.display
  print "\n"
end
until game.over?
  # AIの手番
  state = game.state
  actions = game.legal_actions
  action = agent.choose_action(state, actions)
  game.play(action)
  game.display
  history << [state, action]
  break if game.over?
  # 人間の手番
  state = game.state
  actions = game.legal_actions
  begin
    print "数字を入力後Enterキーを押してください："
    input = gets
  end until (input.to_i - 1) in actions
  move = [input.to_i - 1]
  action = agent.choose_action(state, move)
  game.play(action)
  game.display
  print "\n"
end
agent.reward!(history, game.result)
print "Game End!\n"
