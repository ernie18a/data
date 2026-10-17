# Advanced Smart Trendline + Fib Golden Zone

- url: https://www.tradingview.com/script/QbFsrg55-Advanced-Smart-Trendline-Fib-Golden-Zone/
- type: indicator
- pine_id: PUB;73cd20fe9c534c42bdf9892c6e62621c
- version: 1.0

## Description

# Advanced Smart Trendline + Fibonacci Golden Zone

Advanced Smart Trendline + Fibonacci Golden Zone is a powerful institutional-style TradingView indicator designed for traders who want high-quality trendline breakout confirmations with smart confluence filters.

This script automatically detects dynamic market structure trendlines using pivot highs and lows, then combines them with Fibonacci Golden Zone retracement levels (0.618 - 0.705) to identify high-probability reversal and continuation setups.

The indicator uses multiple advanced filters including EMA trend confirmation, volume strength analysis, ATR-based volatility calculation, and breakout validation to reduce market noise and avoid weak signals.

Key Features:
• Automatic Smart Trendline Detection
• Fibonacci Golden Zone (0.618 - 0.705)
• Institutional Style Breakout Confirmation
• EMA 50 / EMA 200 Trend Filter
• High Volume Confirmation
• ATR-Based Stop Loss & Take Profit
• Buy / Sell Signal Labels
• Dynamic TP & SL Levels
• Clean and Minimal Chart View
• Smart Market Structure Logic
• Real-Time Alert Conditions

This indicator is suitable for:
• Intraday Trading
• Swing Trading
• Forex
• Crypto
• Stocks
• Indices

The system focuses on quality over quantity by filtering out low-probability setups and highlighting strong trend continuation or reversal opportunities near key liquidity zones.

Best used with proper risk management and higher timeframe trend confirmation.

## Source Code

````pine
//@version=5
indicator("Advanced Smart Trendline + Fib Golden Zone", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=200)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
leftBars      = input.int(5, "Pivot Left", minval=1)
rightBars     = input.int(5, "Pivot Right", minval=1)
showFib       = input.bool(true, "Show Fibonacci Golden Zone")
showBreakout  = input.bool(true, "Show Trendline Breakouts")
showTargets   = input.bool(true, "Show TP / SL")
trendStrength = input.int(3, "Trend Strength Filter", minval=1)

emaFastLen    = input.int(50, "Fast EMA")
emaSlowLen    = input.int(200, "Slow EMA")

atrLen        = input.int(14, "ATR Length")
atrMult       = input.float(1.5, "ATR SL Multiplier")

volFilter     = input.bool(true, "Use Volume Filter")
volLength     = input.int(20, "Volume SMA Length")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA TREND FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

bullTrend = emaFast > emaSlow
bearTrend = emaFast < emaSlow

plot(emaFast, color=color.aqua, linewidth=2)
plot(emaSlow, color=color.orange, linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow  = ta.pivotlow(low, leftBars, rightBars)

var float lastHigh = na
var float prevHigh = na
var int   lastHighBar = na
var int   prevHighBar = na

var float lastLow = na
var float prevLow = na
var int   lastLowBar = na
var int   prevLowBar = na

if not na(pivotHigh)
    prevHigh := lastHigh
    prevHighBar := lastHighBar
    lastHigh := pivotHigh
    lastHighBar := bar_index[rightBars]

if not na(pivotLow)
    prevLow := lastLow
    prevLowBar := lastLowBar
    lastLow := pivotLow
    lastLowBar := bar_index[rightBars]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRENDLINES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line bullishTL = na
var line bearishTL = na

if not na(prevLow) and not na(lastLow)
    line.delete(bullishTL)
    bullishTL := line.new(
         prevLowBar, prevLow,
         lastLowBar, lastLow,
         extend=extend.right,
         color=color.lime,
         width=2)

if not na(prevHigh) and not na(lastHigh)
    line.delete(bearishTL)
    bearishTL := line.new(
         prevHighBar, prevHigh,
         lastHighBar, lastHigh,
         extend=extend.right,
         color=color.red,
         width=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRENDLINE VALUES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullTL = line.get_price(bullishTL, bar_index)
bearTL = line.get_price(bearishTL, bar_index)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FIBONACCI GOLDEN ZONE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box fibBoxBull = na
var box fibBoxBear = na

if showFib and not na(lastHigh) and not na(lastLow)

    // Bullish Fib
    bullFib618 = lastHigh - ((lastHigh - lastLow) * 0.618)
    bullFib705 = lastHigh - ((lastHigh - lastLow) * 0.705)

    box.delete(fibBoxBull)

    fibBoxBull := box.new(
         left=bar_index-30,
         top=bullFib618,
         right=bar_index+10,
         bottom=bullFib705,
         bgcolor=color.new(color.green, 85),
         border_color=color.new(color.green, 30))

    // Bearish Fib
    bearFib618 = lastLow + ((lastHigh - lastLow) * 0.618)
    bearFib705 = lastLow + ((lastHigh - lastLow) * 0.705)

    box.delete(fibBoxBear)

    fibBoxBear := box.new(
         left=bar_index-30,
         top=bearFib705,
         right=bar_index+10,
         bottom=bearFib618,
         bgcolor=color.new(color.red, 85),
         border_color=color.new(color.red, 30))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLUME FILTER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volSma = ta.sma(volume, volLength)
highVol = volume > volSma

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BREAKOUT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullBreak = ta.crossover(close, bearTL)
bearBreak = ta.crossunder(close, bullTL)

validBull = bullBreak and bullTrend and (volFilter ? highVol : true)
validBear = bearBreak and bearTrend and (volFilter ? highVol : true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR TARGETS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)

buySL = close - atr * atrMult
buyTP = close + atr * atrMult * 2

sellSL = close + atr * atrMult
sellTP = close - atr * atrMult * 2

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     validBull and showBreakout,
     title="BUY",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     textcolor=color.black,
     size=size.small)

plotshape(
     validBear and showBreakout,
     title="SELL",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP / SL LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if validBull and showTargets
    label.new(
         bar_index,
         low,
         "BUY\nTP: " + str.tostring(buyTP, format.mintick) +
         "\nSL: " + str.tostring(buySL, format.mintick),
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black)

if validBear and showTargets
    label.new(
         bar_index,
         high,
         "SELL\nTP: " + str.tostring(sellTP, format.mintick) +
         "\nSL: " + str.tostring(sellSL, format.mintick),
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(validBull, title="BUY SIGNAL", message="Bullish Trendline Breakout")
alertcondition(validBear, title="SELL SIGNAL", message="Bearish Trendline Breakdown")
````
