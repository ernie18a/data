# CSR - RSI + MACD + EMA Trend + Volume Filter

- url: https://www.tradingview.com/script/ybLRs9M9-CSR-RSI-MACD-EMA-Trend-Volume-Filter/
- type: indicator
- pine_id: PUB;cc57a8ac600747c18ba1148dcbb36e94
- version: 1.0

## Description

Indicator based on RSI, MACD, EMA Trend + Volume filler with Buy and Sell signals. which provides to buy and sell.

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

// RSI & MACD in Separate Pane
plot(rsi, "RSI", color=color.blue, linewidth=2, display=display.pane)

hline(rsiOverbought, "Overbought", color=color.red, linestyle=hline.style_dashed)
hline(rsiOversold,   "Oversold",   color=color.green, linestyle=hline.style_dashed)

histColor = hist >= 0 ? color.green : color.red
plot(hist, "MACD Hist", color=histColor, style=plot.style_columns, linewidth=3, display=display.pane)
plot(macdLine,   "MACD",   color=color.blue,  display=display.pane)
plot(signalLine, "Signal", color=color.orange, display=display.pane)

// ── Buy / Sell Signals on Main Chart ───────────
plotshape(buySignal,  title="Buy Signal",  location=location.belowbar, 
          color=color.lime, style=shape.arrowup, size=size.large, 
          text="BUY", textcolor=color.black)

plotshape(sellSignal, title="Sell Signal", location=location.abovebar, 
          color=color.red, style=shape.arrowdown, size=size.large, 
          text="SELL", textcolor=color.white)

// Background tint for better visibility
bgcolor(buySignal  ? color.new(color.green, 85) : na)
bgcolor(sellSignal ? color.new(color.red,   85) : na)

// Alerts
alertcondition(buySignal,  title="Buy Alert",  message="RSI + MACD + EMA + Volume BUY Signal")
alertcondition(sellSignal, title="Sell Alert", message="RSI + MACD + EMA + Volume SELL Signal")
````
