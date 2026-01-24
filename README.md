# 消える三目並べ（Vanishing TicTacToe）

[消える三目並べアプリ](https://happyclam.booth.pm/items/6582961)の実行ファイルと学習データ作成環境一式です。  
学習データを作成する`Ruby環境`と、その下の`Docs/`ディレクトリ以下の実行環境（HTML+JavaScript）に分かれてます。

※CoffeeScriptのトランスパイル環境は入れてませんがソースファイル（tictactoe.coffee）は/Docs下に収納しています。  
※過去にあったAndroidアプリの制限強化のため、現バージョンは学習済みの初期データファイルをindex.htmlファイルに貼り付けていますのでファイルサイズが大きくなっています。

### 関連記事
* [「消える三目並べをマルコフ拡張」](https://happyclam.github.io/software/2026-01-25/markov_chain)
* [「消える三目並べ」リリースしました](https://happyclam.github.io/project/2017-07-11/tictactoe-van)
* [「消える三目並べ」、思ったより大変](https://happyclam.github.io/programming/2016-11-03/ml_miscellaneous2)

### ファイルの役割
##### masterブランチ
* test.sh --- 学習データ作成用スクリプト（学習データファイルtrees.dump出力）
* play.rb --- 対人テスト用対戦スクリプト（trees.dumpファイルが無い場合は一局対戦後に出力する）
* verify.rb --- 学習データ確認用スクリプト
* trees.dump --- 学習済みデータ（仮）
* learning.rb --- 学習実行ファイル（１エピソード）
* game.rb --- 消える三目並べクラス（諸々）

##### chatGPTブランチ
* learning.rb --- 学習データ作成用スクリプト（学習データファイルstones.dump出力）
* play.rb --- 対人テスト用対戦スクリプト
* disappearing_tictactoe.rb --- 確率的方策（ポリアの壺モデル）によるモンテカルロ制御クラス
* disappearing_markov.rb --- マルコフ拡張モンテカルロ制御クラス
* stone_agent.rb --- 学習エージェントクラス（ノーマル学習＆マルコフ学習兼用）
* stones.dump --- 学習済みデータ


[PC版実行](https://happyclam.github.io/tictactoe-van/)

