# RSI + MACD + EMA Trend + Volume Filter

- url: https://www.tradingview.com/script/wGiQBKy9-RSI-MACD-EMA-Trend-Volume-Filter/
- type: indicator
- pine_id: PUB;3f15722445c54882b1047bdb1331c097
- version: 1.0

## Description

Large, bold BUY/SELL labels directly on the chart (much more visible than plotshape)
Labels appear below the candle for BUY and above for SELL
Only the latest signal label remains (previous ones are deleted)
Strong colors and large size

Paste the full script into TradingView Pine Editor and add to chart.
Would you like any more changes? (e.g., keep all historical labels, add price level, change colors, or convert to Strategy for backtesting)

## Source Code

````pine
//@version=6
indicator("RSI + MACD + EMA Trend + Volume Filter", shorttitle="RSI_MACD_EMA_Vol", overlay=true)

// ── Inputs ─────────────────────────────────────
rsiLength     = input.int(14,  "RSI Length",      minval=1)
rsiOverbought = input.int(70,  "RSI Overbought",  minval=1)
rsiOversold   = input.int(30,  "RSI Oversold",    minval=1)

macdFast   = input.int(12, "MACD Fast Length",  minval=1)
macdSlow   = input.int(26, "MACD Slow Length",  minval=1)
macdSignal = input.int(9,  "MACD Signal Length", minval=1)

emaLength     = input.int(200, "EMA Trend Length", minval=1)
useTrendFilter= input.bool(true, "Use EMA Trend Filter")

volLength     = input.int(20, "Volume SMA Length", minval=1)
volMultiplier = input.float(1.0, "Volume Multiplier", minval=0.1, step=0.1)
useVolFilter  = input.bool(true, "Use Volume Confirmation")

// ── Calculations ───────────────────────────────
rsi = ta.rsi(close, rsiLength)
[macdLine, signalLine, hist] = ta.macd(close, macdFast, macdSlow, macdSignal)
emaTrend = ta.ema(close, emaLength)
volSMA = ta.sma(volume, volLength)

// ── Conditions ─────────────────────────────────
macdBullCross  = ta.crossover(macdLine, signalLine)
macdBearCross  = ta.crossunder(macdLine, signalLine)

rsiBull = ta.crossunder(rsi, rsiOversold)
rsiBear = ta.crossover(rsi, rsiOverbought)

trendBull = not useTrendFilter or (close > emaTrend)
trendBear = not useTrendFilter or (close < emaTrend)

volBull = not useVolFilter or (volume > volSMA * volMultiplier)
volBear = not useVolFilter or (volume > volSMA * volMultiplier)

buySignal  = macdBullCross and rsiBull and trendBull and volBull
sellSignal = macdBearCross and rsiBear and trendBear and volBear

// ── Plotting ───────────────────────────────────
plot(emaTrend, "EMA Trend", color=color.purple, linewidth=2)

// RSI + MACD Pane
plot(rsi, "RSI", color=color.blue, linewidth=2, display=display.pane)
hline(rsiOverbought, "Overbought", color=color.red, linestyle=hline.style_dashed)
hline(rsiOversold,   "Oversold",   color=color.green, linestyle=hline.style_dashed)

histColor = hist >= 0 ? color.green : color.red
plot(hist, "MACD Hist", color=histColor, style=plot.style_columns, linewidth=3, display=display.pane)
plot(macdLine,   "MACD",   color=color.blue,  display=display.pane)
plot(signalLine, "Signal", color=color.orange, display=display.pane)

// ── Strong Buy / Sell Labels on Main Chart ─────
var label buyLabel = na
var label sellLabel = na

if buySignal
    label.delete(buyLabel)
    buyLabel := label.new(bar_index, low * 0.995, "BUY", 
                         color=color.new(color.green, 0), 
                         textcolor=color.white, 
                         style=label.style_label_up, 
                         size=size.large, 
                         yloc=yloc.belowbar)

if sellSignal
    label.delete(sellLabel)
    sellLabel := label.new(bar_index, high * 1.005, "SELL", 
                          color=color.new(color.red, 0), 
                          textcolor=color.white, 
                          style=label.style_label_down, 
                          size=size.large, 
                          yloc=yloc.abovebar)

// Background tint
bgcolor(buySignal  ? color.new(color.green, 85) : na)
bgcolor(sellSignal ? color.new(color.red,   85) : na)

// Alerts
alertcondition(buySignal,  title="Buy Alert",  message="🚀 RSI + MACD + EMA + Volume BUY Signal")
alertcondition(sellSignal, title="Sell Alert", message="🔻 RSI + MACD + EMA + Volume SELL Signal")
````
