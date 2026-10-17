# Daily Bollinger Band Strategy

- url: https://www.tradingview.com/script/h0ePZA90/
- type: strategy
- pine_id: PUB;0fbfaa6b6cb245a4a8ce2d8d305b51bc
- version: 2.0

## Description

[b]Overview of the Daily Bollinger Band Strategy[/b]

[b]1. Strategy Overview and Features[/b]

This strategy is a tool for backtesting a trading method that uses Bollinger Bands. It is *not* a tool for automated trading.

[b]1-1. Main Display Items[/b]

The main chart displays the Bollinger Bands and the 200-day moving average.

It also shows the entry and exit points along with the position size (in units of 100 shares).

[b]1-2. Summary of Trading Rules[/b]

For long (buy) strategies, the trade enters when the price crosses above the +1σ line of the Bollinger Bands, aiming to ride an upward trend. The position is exited when the price crosses below the middle band.

For short (sell) strategies, the trade enters when the price crosses below the -1σ line of the Bollinger Bands, aiming to ride a downward trend. The position is exited when the price crosses above the middle band.

[b]1-3. Strategic Enhancements[/b]

The strategy uses the slope of the 200-day moving average to determine the trend direction and enter trades accordingly. This improves the win rate and payoff ratio.

Additionally, to reduce the probability of ruin, the risk per trade is limited to 1.0% of capital, and position sizing is adjusted using ATR (a volatility indicator).


[b]2. Trading Rules[/b]

[b]2-1. Chart Type[/b]

Only daily charts are used.

[b]2-2. Indicators Used[/b]

(1) Bollinger Bands** (used for entry and exit signals)  
- Period: Fixed at 80 days  
- Upper and lower bands: Fixed at ±1σ  

(2) Moving Average** (used to determine trend direction)  
- Period: Fixed at 200 days  
- Trend direction is judged based on whether the difference from the previous day is positive (upward) or negative (downward)

[b]2-3. Buy Rules[/b]

Setup:
- Price crosses above the +1σ line from below  
- Both the middle band and 200-day moving average are upward sloping  

Entry:
- Buy at the next day’s market open using a market order  

Exit:
- If the price crosses below the middle band, sell at the next day’s open using a market order  

[b]2-4. Sell Rules[/b]

Setup:
- Price crosses below the -1σ line from above  
- Both the middle band and 200-day moving average are downward sloping  

Entry:
- Sell at the next day’s market open using a market order  

Exit:
- If the price crosses above the middle band, buy back at the next day’s open using a market order  

[b]2-5. Risk Management Rules[/b]

- Risk per trade: 1.0% of total capital (acceptable loss = capital × 1.0%)  
- Position size: Acceptable loss ÷ 2ATR (rounded down to the nearest unit of 100 shares)  

[b]2-6. Other Notes[/b]

- No brokerage fees  
- No pyramiding  
- No partial exits  
- No reverse positions (no “stop-and-reverse” trades)  


[b]3. Strategy Parameters[/b]

The following settings can be specified:

[b]3-1. Period Settings[/b]

- Start date: Set the start date for the backtest period  
- Stop date: Set the end date for the backtest period  

[b]3-2. Display of Trend and Signals[/b]

- Show trend: When checked, the background color of the bars is light red for an uptrend and light blue for a downtrend  
- Show signal: When checked, entry and exit signals are displayed (note: signals are executed at the next day’s open, so there is a one-day lag in the display)  

[b]3-3. Capital Management Settings[/b]

- Funds: Capital available for trading (in JPY)  
- Risk rate: Specify what percentage of the capital to risk per trade  

Settings in the “Properties” tab are not used in this strategy.


[b]4. Backtest Results (Example)[/b]

Here are the backtest results conducted by the author:

- Target Stocks: All components of the Nikkei 225  
- Test Period: January 4, 2000 – December 30, 2024  
- Data Points: 12,886  
- Win Rate: 33.45%  
- Net Profit: ¥82,132,380  
- Payoff Ratio: 2.450  
- Expected Value: ¥6,373.8  
- Risk Rate: 1.0%  
- Probability of Ruin: 0.00%  


---
[b]デイリー・ボリンジャーバンド・ストラテジーの概要[/b]

[b]1. ストラテジーの概要と特徴[/b]

このストラテジーは、ボリンジャーバンドを使ったトレード手法のバックテストを行うツールです。自動売買を行うツールではありません。

[b]1-1. 主な表示項目[/b]

メインチャートにボリンジャーバンドと 200日移動平均線を表示します。

また、エントリーと手仕舞いのタイミングと数量（100株単位）も表示されます。


[b]1-2. トレードルールの概要[/b]

買い戦略の場合、ボリンジャーバンドの +1σ 超えでエントリーして上昇トレンドに乗り、ミドルバンドを割ったら決済します。

売り戦略の場合、ボリンジャーバンドの -1σ 割りでエントリーして下降トレンドに乗り、ミドルバンドを上抜けたら決済します。

[b]1-3. ストラテジーの工夫点[/b]

200日移動平均線の傾きを見てトレンド方向にエントリーをしています。こうして勝率とペイオフレシオの成績を向上しています。

また、破産確率を抑えるために、リスク資金比率を 1.0% にして、ATR（ボラティリティ指標） を使って注文数を調整しています。


[b]2. 売買ルール[/b]

[b]2-1. 使用するチャート[/b]

日足チャートに限定します

[b]2-2. 使用する指標[/b]

(1) ボリンジャーバンド（仕掛けと手仕舞いのシグナルに使用）

期間は80日に固定

上下バンドは ±1σ に固定

(2) 移動平均線（トレンドの方向を見るために使用）

期間は200日に固定

移動平均の値の前日との差がプラスのとき上向き、マイナスのとき下向きと判断

[b]2-3. 買いのルール[/b]

セットアップ：ボリンジャーバンドの +1σ を価格が下から上に交差 かつ ミドルバンドと 200日移動平均線が上向き

仕掛け：翌日の寄り付きに成行で買う

手仕舞い：ボリンジャーバンドのミドルバンドを価格が上から下に交差したら、翌日の寄り付きに成行で売る

[b]2-4. 売りのルール[/b]

セットアップ：ボリンジャーバンドの -1σ を価格が上から下に交差 かつ ミドルバンドと 200日移動平均線が下向き

仕掛け：翌日の寄り付きに成行で売る

手仕舞い：ボリンジャーバンドのミドルバンドを価格が下から上に交差したら、翌日の寄り付きに成行で買い戻す

[b]2-5. 資金管理のルール[/b]

リスク資金比率：資産の 1.0%（許容損失 = 資産 × 1.0%）

注文数：許容損失 ÷ 2ATR（単元株数未満は切り捨て）

[b]2-6. その他[/b]

仲介手数料：なし

ピラミッディング：なし

分割決済：なし

ドテン：しない


[b]3. ストラテジーのパラメーター[/b]

次の項目が指定できます。

[b]3-1. 期間の設定[/b]

Staer date : バックテストの検証期間の開始日を指定します

Stop date : バックテストの検証期間の終了日を指定します

[b]3-2. トレンドとシグナルの表示[/b]

Show trend : チェックを入れると、バーの背景色が、トレンドが上昇のときは薄い赤で、下落のときは薄い青で表示されます

Show signal : チェックを入れると、エントリーと手仕舞いのシグナルを表示します（シグナルの出た翌日の寄り付きに売買をするので表示に1日のずれがあります）

[b]3-3. 資金管理用の設定[/b]

Funds : トレード用の資金(円)

Risk rate : 許容損失を資金の何%にするかで指定します

「プロパティタブ」で設定する値は、このストラテジーでは有効ではありません。


[b]4. バックテストの結果（例）[/b]

作者がバックテストを実施した結果をお知らせします。

対象銘柄：日経225構成銘柄すべて

対象期間：2000年1月4日～2024年12月30日

データ件数：12,886

勝率：33.45%

純利益：82,132,380

ペイオフレシオ：2.450

期待値：6,373.8

リスク資金比率：1.0%

破産確率：0.00%

## Source Code

````pine
//@version=6
strategy("Daily Bollinger Band Strategy", overlay = true)

// period
startDate = input.time(timestamp("2000-01-04 00:00"), "start date", group = "period")
stopDate = input.time(timestamp("9999-12-30 00:00"), "stop date", group = "period")
withinPeriod = (time >= startDate) and (time <= stopDate)
// Bollinger Bands
// parameter
bbLength = input.int(20, "bollinger bands period", minval = 1, group = "bollinger bands")
multiply = input.float(1.0, "bollinger bands multiply", minval = 0.1, group = "bollinger bands")
bbColor = input.color(color.blue, "bollinger bands color", group = "bollinger bands")
// calcuration
[middle, upper, lower] = ta.bb(close, bbLength, multiply)
bbSlope = ta.change(middle, 1)
// plot
p1 = plot(upper, "upper band", bbColor)
plot(middle, "middle band", bbColor)
p2 = plot(lower, "lower band", bbColor)
fill(p1, p2, color.new(bbColor, 90))
plot(bbSlope, "middle band slope", display = display.data_window)

// trend filter
// parameter
tfLength = input.int(200, "Trend Filter(long ma) Period", minval = 1, group = "trend filter")
showTrend = input.bool(false, "show trend", group = "trend filter")
// calcuration
ma = ta.sma(close, tfLength)
tfSlope = ta.change(ma, 1)
// plot
plot(ma, "long ma", color.orange)
bgcolor(color = showTrend and tfSlope > 0 ? color.new(color.red, 80) : na)
bgcolor(color = showTrend and tfSlope < 0 ? color.new(color.blue, 80) : na)
plot(tfSlope, "long ma slope", display = display.data_window)

// signal
// parameter
showSignal = input.bool(false, "show signal", group = "entry and exit signal")
// entry
longCondition = withinPeriod and (strategy.position_size == 0) and ta.crossover(close, upper) and bbSlope > 0 and tfSlope > 0
shortCondition = withinPeriod and (strategy.position_size == 0) and ta.crossunder(close, lower) and bbSlope < 0 and tfSlope < 0

// close
longClose = withinPeriod and (strategy.position_size > 0) and ta.crossunder(close, middle)
shortClose = withinPeriod and (strategy.position_size < 0) and ta.crossover(close, middle)
// plot
plotshape(showSignal and longCondition, "longCondition", style = shape.circle, location = location.abovebar,
  color = color.red, size = size.tiny)
plotshape(showSignal and shortCondition, "shortCondition", style = shape.circle, location = location.belowbar,
  color = color.blue, size = size.tiny)
plotshape(showSignal and longClose ? middle : na, "longClose", style = shape.xcross,
  color = color.red, size = size.tiny)
plotshape(showSignal and shortClose ? middle : na, "shortClose", style = shape.xcross,
  color = color.blue, size = size.tiny)

// position size
// parameters
atrLength = input.int(20, "atr length", minval = 1, group = "position size")
rate = input.float(1.0, "risk rate(%)", minval = 0.5, group = "position size")
unit = input.int(100, "unit", minval = 1, group = "position size")
// calcuration
atr = ta.sma(ta.tr, atrLength)
s = (strategy.initial_capital * rate / 100) / (2 * atr)
size = math.floor(s / unit) * unit
// plot
plot (atr, "atr", display = display.data_window)
plot (size, "position size", display = display.data_window)

// order
if longCondition
    strategy.entry("long", strategy.long, qty = size)
if shortCondition
    strategy.entry("short", strategy.short, qty = size)
if longClose
    strategy.close("long")
if shortClose
    strategy.close("short")
````
