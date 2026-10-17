# Line Break Strategy

- url: https://www.tradingview.com/script/7wgvQ883-Line-Break-Strategy/
- type: strategy
- pine_id: PUB;XKLYRtMCKFATZiIh52NwMY4aQQxxkThW
- version: 1.0

## Description

Line Break Strategy 

[b]Entry rule:[/b]
Long on a bullish line and short on a bearish line.

[b]Backtest:[/b]
Profit factors are shown below for three-line break.
Daily time frame, [.]FXCM broker.

[.]EURUSD: 1.267, [.]USDJPY: 1.039, [.]GBPUSD: -0.816, [.]AUDUSD: -0.959
[.]S&P500: -0.783, [.]Nikkei225: 1.099
[.]CrudeOil: 1.03, [.]Gold: 1.196
[.]BTCUSD: -0.883

[b]Reference:[/b]
 Steve Nison, Beyond Candlesticks  - New Japanese Charting Techniques Revealed

[b]Note:[/b]
This strategy doesn't work properly on the linebreak chart. 
A good example is shown below. The entry prices are not always correct.
If you have signal, but the next candle moves in the opposite direction, the entry price is drawn at the Open of the new candle instead of the Close of the previous candle.
The results of backtest are unreliable due to this reason.
https://www.tradingview.com/x/Ku9bwLYL/

## Source Code

````pine
strategy("Line Break Strategy", overlay=true)
src = input("close", title="Source")
nl = input(3, title="Number of Line")

lb_t = linebreak(tickerid, src, nl)
lb_o = security(lb_t, period, open)
lb_c = security(lb_t, period, close)

// Overlays line break bars on regular candle bars 
palette = lb_o < lb_c ? green : red
po = plot(lb_o, color=palette, title="Open")
pc = plot(lb_c, color=palette, title="Close")
fill(po, pc, color=palette)

long_entry = lb_o < lb_c
short_entry = lb_o > lb_c

strategy.entry("Long", strategy.long, when=long_entry)
strategy.entry("Short", strategy.short, when=short_entry)
````
