# Momentum Engine (5-Min Forex)

- url: https://www.tradingview.com/script/R0lnPQtK-Momentum-Engine-5-Min-Forex/
- type: indicator
- pine_id: PUB;431b965bbb3e4593bae579538872023d
- version: 1.0

## Description

Color coded momentum with visible gauges designed for the 5 minute chart but can be used with other time frames.

## Source Code

````pine
//@version=6
indicator("Momentum Engine (5-Min Forex)", overlay=true, max_labels_count=500)

//-----------------------------
// Inputs
//-----------------------------
emaLen      = input.int(20, "EMA Length")
rsiLen      = input.int(14, "RSI Length")
macdFast    = input.int(12, "MACD Fast")
macdSlow    = input.int(26, "MACD Slow")
macdSignal  = input.int(9,  "MACD Signal")

//-----------------------------
// Core Calculations
//-----------------------------
ema20 = ta.ema(close, emaLen)

// MACD
macd      = ta.ema(close, macdFast) - ta.ema(close, macdSlow)
macdSig   = ta.ema(macd, macdSignal)
macdHist  = macd - macdSig

// RSI
rsi = ta.rsi(close, rsiLen)

//-----------------------------
// Momentum Conditions
//-----------------------------
trendBull = close > ema20
trendBear = close < ema20

macdBull  = macdHist > 0 and macdHist > macdHist[1]
macdBear  = macdHist < 0 and macdHist < macdHist[1]

rsiBull   = rsi > 50
rsiBear   = rsi < 50

//-----------------------------
// Momentum Score (0–3)
//-----------------------------
bullScore = (trendBull ? 1 : 0) + (macdBull ? 1 : 0) + (rsiBull ? 1 : 0)
bearScore = (trendBear ? 1 : 0) + (macdBear ? 1 : 0) + (rsiBear ? 1 : 0)

//-----------------------------
// Plotting
//-----------------------------
plot(ema20, "20 EMA", color=color.new(color.yellow, 0), linewidth=2)

// Background color for momentum strength
bgcolor(
     bullScore == 3 ? color.new(color.green, 85) :
     bullScore == 2 ? color.new(color.green, 92) :
     bearScore == 3 ? color.new(color.red, 85) :
     bearScore == 2 ? color.new(color.red, 92) :
     na
)

// Labels for momentum score
if barstate.islast
    label.new(bar_index, high, "Bull Score: " + str.tostring(bullScore), 
        color=color.new(color.green, 0), style=label.style_label_left, textcolor=color.white)
    label.new(bar_index, low, "Bear Score: " + str.tostring(bearScore), 
        color=color.new(color.red, 0), style=label.style_label_left, textcolor=color.white)
//-----------------------------
// Momentum Gauge Panel
//-----------------------------
var table gauge = table.new(position.top_right, 2, 3, border_width=1)

netMomentum = bullScore - bearScore  // Range: -3 to +3

gaugeColor =
     netMomentum == 3 ? color.new(color.green, 0) :
     netMomentum == 2 ? color.new(color.green, 40) :
     netMomentum == 1 ? color.new(color.green, 70) :
     netMomentum == 0 ? color.new(color.gray, 70) :
     netMomentum == -1 ? color.new(color.red, 70) :
     netMomentum == -2 ? color.new(color.red, 40) :
     color.new(color.red, 0)

if barstate.islast
    table.cell(gauge, 0, 0, "Bull", text_color=color.green)
    table.cell(gauge, 1, 0, str.tostring(bullScore), text_color=color.green)

    table.cell(gauge, 0, 1, "Bear", text_color=color.red)
    table.cell(gauge, 1, 1, str.tostring(bearScore), text_color=color.red)

    table.cell(gauge, 0, 2, "Net", text_color=color.white)
    table.cell(gauge, 1, 2, str.tostring(netMomentum), text_color=color.white, bgcolor=gaugeColor)
//-----------------------------
// Horizontal Momentum Bar
//-----------------------------
var table bar = table.new(position.bottom_right, 7, 1)

barIndex = netMomentum + 3  // convert -3..+3 → 0..6

for i = 0 to 6
    cellColor = i <= barIndex ? gaugeColor : color.new(color.gray, 85)
    table.cell(bar, i, 0, "", bgcolor=cellColor)
````
