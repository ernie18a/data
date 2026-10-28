# EMA 9/21 + SMA 20/50 [0DTE]

- url: https://www.tradingview.com/script/VLcAgJzC-EMA-9-21-SMA-20-50-0DTE/
- type: indicator
- pine_id: PUB;0b4ee73a6cc84807a2e2fa8328aaa7f2
- version: 1.0

## Description

Combined EMA / SMA.


Put this together for people who dont have paid subscriptions to TV

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © willway04

//@version=6
indicator("EMA 9/21 + SMA 20/50 [0DTE]", shorttitle="EMA/SMA Stack - CaptKidd", overlay=true)

// ==================== INPUTS ====================
show_ema9 = input.bool(true, "Show EMA 9", group="EMAs")
show_ema21 = input.bool(true, "Show EMA 21", group="EMAs")
show_sma20 = input.bool(true, "Show SMA 20", group="SMAs")
show_sma50 = input.bool(true, "Show SMA 50", group="SMAs")
show_signals= input.bool(true, "Show Crossover Arrows", group="Signals")

// ==================== CALCULATIONS ====================
ema9 = ta.ema(close, 5)
ema21 = ta.ema(close, 13)
sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)

// Trend conditions
bull_trend = ema9 > ema21 and ema21 > sma20 and sma20 > sma50
bear_trend = ema9 < ema21 and ema21 < sma20 and sma20 < sma50

// Signals
long_cross = ta.crossover(ema9, ema21) and ema21 > sma20
short_cross = ta.crossunder(ema9, ema21) and ema21 < sma20

// ==================== PLOTS ====================
plot(show_ema9 ? ema9 : na, "EMA 9", color=color.blue, linewidth=2)
plot(show_ema21 ? ema21 : na, "EMA 21", color=color.aqua, linewidth=2)
plot(show_sma20 ? sma20 : na, "SMA 20", color=color.orange, linewidth=2)
plot(show_sma50 ? sma50 : na, "SMA 50", color=color.red, linewidth=2)

// Signals
plotshape(show_signals and long_cross, title="Bullish Cross", location=location.belowbar, color=color.lime, style=shape.triangleup, size=size.large, text="BUY")
plotshape(show_signals and short_cross, title="Bearish Cross", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.large, text="SELL")

// ==================== TABLE DASHBOARD ====================
var table dash = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 85), border_width=1)

if bar_index % 5 == 0 or long_cross or short_cross
    
    table.cell(dash, 0, 4, "Trend", text_color=color.white)
    table.cell(dash, 1, 4, bull_trend ? "BULLISH" : bear_trend ? "BEARISH" : "NEUTRAL", 
               text_color = bull_trend ? color.lime : bear_trend ? color.red : color.gray)

// ==================== ALERTS ====================
alertcondition(long_cross, title="EMA Bullish Cross", message="EMA 9/21 Bullish Crossover on {{ticker}} @ {{close}} - 0DTE LONG Bias")
alertcondition(short_cross, title="EMA Bearish Cross", message="EMA 9/21 Bearish Crossover on {{ticker}} @ {{close}} - 0DTE SHORT Bias")
````
