require "pathname"
require_relative "./disappearing_tictactoe"
require_relative "./disappearing_markov"
require_relative "./stone_agent"

# game = DisappearingTicTacToe.new
game = DisappearingMarkov.new
agent = StoneAgent.new

EPISODES = 1000000

EPISODES.times do
  game.reset
  history = []
  until game.over?
    state = game.state
    actions = game.legal_actions
    action = agent.choose_action(state, actions)
    game.play(action)
    history << [state, action]
  end
  agent.reward!(history, game.result)
end

puts "学習完了"

p agent.stones.length
# p agent.stones
StoneAgent::save("./stones.dump", agent)
