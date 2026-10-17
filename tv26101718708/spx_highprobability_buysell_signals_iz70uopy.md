# SPX High-Probability Buy/Sell Signals

- url: https://www.tradingview.com/script/iZ70uOPY-SPX-High-Probability-Buy-Sell-Signals/
- type: indicator
- pine_id: PUB;a91130d68e924da49b7b16ffc875fc73
- version: 1.0

## Description

The indicator analyzes price action and technical factors to identify high-probability entry points for both buying and selling. Include visual alerts on the chart such as arrows and labels marking buy and sell opportunities. The signals are based on well-known technical methods (e.g., moving average crossovers, RSI levels, MACD, oand other reliable indicators) combination thereof to improve accuracy.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TSLA2Tesla
//@version=5
indicator(title="SPX High-Probability Buy/Sell Signals", shorttitle="SPX Signals", overlay=true, max_bars_back=1000)

// ──────────────────────────────────────────────────────────────
// INPUTS - Grouped for easy customization
// ──────────────────────────────────────────────────────────────
groupMA = "Moving Averages"
fastMALength = input.int(9,  minval=1, title="Fast EMA Length",  group=groupMA, tooltip="Shorter EMA for quick trend detection")
slowMALength = input.int(21, minval=1, title="Slow EMA Length",  group=groupMA, tooltip="Longer EMA for trend confirmation")

groupTrend = "Trend Filter"
trendMALength = input.int(200, minval=50, title="Long-Term Trend EMA Length", group=groupTrend, tooltip="Acts as a filter — only take buys above this EMA, sells below it (classic for SPX trending market)")

groupRSI = "RSI Settings"
rsiLength   = input.int(14, minval=1, title="RSI Length", group=groupRSI)
rsiBuyLevel = input.int(50, minval=0, maxval=100, title="RSI Minimum for Buy", group=groupRSI, tooltip="RSI must be above this level for a buy signal")
rsiSellLevel= input.int(50, minval=0, maxval=100, title="RSI Maximum for Sell", group=groupRSI, tooltip="RSI must be below this level for a sell signal")

groupMACD = "MACD Settings"
macdFast   = input.int(12, title="MACD Fast Length",   group=groupMACD)
macdSlow   = input.int(26, title="MACD Slow Length",   group=groupMACD)
macdSignal = input.int(9,  title="MACD Signal Length", group=groupMACD)

// ──────────────────────────────────────────────────────────────
// CALCULATIONS
// ──────────────────────────────────────────────────────────────
fastMA   = ta.ema(close, fastMALength)
slowMA   = ta.ema(close, slowMALength)
trendMA  = ta.ema(close, trendMALength)

rsiValue = ta.rsi(close, rsiLength)

[macdLine, signalLine, _] = ta.macd(close, macdFast, macdSlow, macdSignal)

// ──────────────────────────────────────────────────────────────
// SIGNAL LOGIC (High-Probability Rules)
// Buy  = Fast EMA crosses above Slow EMA + RSI bullish + MACD bullish + price above long-term trend
// Sell = Fast EMA crosses below Slow EMA + RSI bearish + MACD bearish + price below long-term trend
// This multi-factor confirmation dramatically reduces whipsaws on SPX
// ──────────────────────────────────────────────────────────────
maBullCross  = ta.crossover(fastMA, slowMA)
maBearCross  = ta.crossunder(fastMA, slowMA)

rsiBullish   = rsiValue > rsiBuyLevel
rsiBearish   = rsiValue < rsiSellLevel

macdBullCross = ta.crossover(macdLine, signalLine)
macdBearCross = ta.crossunder(macdLine, signalLine)

trendBull = close > trendMA
trendBear = close < trendMA

buySignal  = maBullCross and rsiBullish and macdBullCross and trendBull
sellSignal = maBearCross and rsiBearish and macdBearCross and trendBear

// ──────────────────────────────────────────────────────────────
// PLOTTING - Clean chart visuals
// ──────────────────────────────────────────────────────────────
// Moving Averages
plot(fastMA,  color=color.new(#00BFFF, 0), linewidth=2, title="Fast EMA (9)")
plot(slowMA,  color=color.new(#FF4500, 0), linewidth=2, title="Slow EMA (21)")
plot(trendMA, color=color.new(#FFD700, 0), linewidth=3, title="200 EMA Trend Filter")

// Buy / Sell arrows with clear labels
plotshape(buySignal,  title="BUY Signal",  location=location.belowbar, color=color.new(#00FF00, 0), style=shape.triangleup,   size=size.large, text="BUY",  textcolor=color.white, editable=false)
plotshape(sellSignal, title="SELL Signal", location=location.abovebar, color=color.new(#FF0000, 0), style=shape.triangledown, size=size.large, text="SELL", textcolor=color.white, editable=false)

// Background tint for quick visual reference (very light so it doesn't clutter the chart)
bgcolor(buySignal  ? color.new(#00FF00, 92) : na, title="Buy Background")
bgcolor(sellSignal ? color.new(#FF0000, 92) : na, title="Sell Background")

// ──────────────────────────────────────────────────────────────
// ALERTS - Ready to use in TradingView
// ──────────────────────────────────────────────────────────────
alertcondition(buySignal,  title="SPX BUY Alert",  message="🚀 SPX BUY Signal - High-probability long entry detected!")
alertcondition(sellSignal, title="SPX SELL Alert", message="🔻 SPX SELL Signal - High-probability short / exit signal detected!")

// ──────────────────────────────────────────────────────────────
// TABLE - Shows current status (optional but very useful)
// ──────────────────────────────────────────────────────────────
var table statusTable = table.new(position.top_right, 1, 5, bgcolor=color.new(color.black, 80), border_width=1)

if barstate.islast
    table.cell(statusTable, 0, 0, "SPX Signals", text_color=color.white, text_size=size.small)
    table.cell(statusTable, 0, 1, "Fast EMA: " + str.tostring(fastMA, "#.##"), text_color=color.new(#00BFFF, 0))
    table.cell(statusTable, 0, 2, "Slow EMA: " + str.tostring(slowMA, "#.##"), text_color=color.new(#FF4500, 0))
    table.cell(statusTable, 0, 3, "RSI: " + str.tostring(rsiValue, "#.##"), text_color=rsiValue > 50 ? color.new(#00FF00, 0) : color.new(#FF0000, 0))
    table.cell(statusTable, 0, 4, "Trend: " + (close > trendMA ? "BULLISH" : "BEARISH"), text_color=close > trendMA ? color.new(#00FF00, 0) : color.new(#FF0000, 0))

// ──────────────────────────────────────────────────────────────
````
