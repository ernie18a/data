# SMC Lite Pro [BOS + CHoCH + OB + FVG

- url: https://www.tradingview.com/script/C2oUiIAA-SMC-Lite-Pro-BOS-CHoCH-OB-FVG/
- type: indicator
- pine_id: PUB;f6426bc41d35453b823a0c25ce9f72ea
- version: 2.0

## Description

[b]Overview[/b]
[b]SMC Lite Pro [BOS + CHoCH + OB + FVG[/b] is a Smart Money Concepts (SMC) based trading indicator designed to help traders identify market structure shifts, liquidity movements, institutional order flow, and high-probability reaction zones directly on the chart.

This all-in-one tool combines Break of Structure (BOS), Change of Character (CHoCH), Order Blocks, Fair Value Gaps (FVG), and Liquidity Sweeps into a single clean and powerful trading system. It is built for traders who follow price action and institutional-style market behavior across Forex, Crypto, Indices, and Commodities.

[b]Key Features
Market Structure Engine[/b]

* Swing Highs & Swing Lows detection
* Higher High / Lower Low structure mapping
* Real-time trend identification

🚀 [b]BOS & CHoCH Detection[/b]
* Break of Structure (Bullish & Bearish)
* Change of Character (Trend reversal signals)
* Clean visual labels for structure shifts

🏦 [b]Order Blocks (SMC Zones)[/b]
https://www.tradingview.com/x/QazqadZ9/
* Bullish Order Blocks (demand zones)
* Bearish Order Blocks (supply zones)
* Institutional entry zones based on displacement moves

[b]⚡ Fair Value Gaps (FVG)[/b]
https://www.tradingview.com/x/TD8lio9B/
* Imbalance detection between candles
* Bullish and Bearish FVG zones
* Potential price retracement areas

💧 [b]Liquidity Concepts[/b]
https://www.tradingview.com/x/ynrjuYfE/
* Equal Highs / Equal Lows detection
* Liquidity sweep identification
* Smart money stop hunt zones

📈 [b]Best Market Conditions[/b]
* Trending markets
* High volatility sessions (London & New York)
* Strong breakout environments

⏱ [b]Recommended Timeframes[/b]
* 1M – 5M → Scalping (fast entries)
* 15M – 1H → Intraday trading (BEST performance)
* 4H – Daily → Swing trading (high accuracy setups)

🎯 [b]How to Use[/b]
* Wait for BOS or CHoCH for directional bias
* Identify Order Blocks after structure shift
* Use FVG zones for pullback entries
* Confirm liquidity sweep before entry
* Trade in direction of market structure

⚠️ [b]Disclaimer[/b]
This indicator is based on Smart Money Concepts and historical price action analysis. It does not guarantee profits. Trading involves risk, and users should apply proper risk management and confirmation before entering trades.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("SMC Lite Pro [BOS + CHoCH + OB + FVG]", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

//==============================
// INPUTS
//==============================
swingLen   = input.int(5, "Swing Length")
showBOS    = input.bool(true, "Show BOS")
showCHOCH  = input.bool(true, "Show CHoCH")
showOB     = input.bool(true, "Show Order Blocks")
showFVG    = input.bool(true, "Show FVG")
showSweep  = input.bool(true, "Show Liquidity Sweeps")

bullColor = color.lime
bearColor = color.red

//==============================
// SWINGS (STRUCTURE ENGINE)
//==============================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow  = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

//==============================
// MARKET STRUCTURE (BOS / CHOCH)
//==============================
var int trend = 0

bullBOS  = not na(lastHigh) and close > lastHigh and close[1] <= lastHigh
bearBOS  = not na(lastLow)  and close < lastLow  and close[1] >= lastLow

bullCHOCH = bearBOS and trend == 1
bearCHOCH = bullBOS and trend == -1

if bullBOS
    trend := 1
if bearBOS
    trend := -1

//==============================
// BOS / CHOCH VISUALS
//==============================
if showBOS and bullBOS
    label.new(bar_index, low, "BOS ↑", style=label.style_label_up, color=bullColor, textcolor=color.black)

if showBOS and bearBOS
    label.new(bar_index, high, "BOS ↓", style=label.style_label_down, color=bearColor, textcolor=color.white)

if showCHOCH and bullCHOCH
    label.new(bar_index, low, "CHoCH ↑", style=label.style_label_up, color=color.blue, textcolor=color.white)

if showCHOCH and bearCHOCH
    label.new(bar_index, high, "CHoCH ↓", style=label.style_label_down, color=color.orange, textcolor=color.white)

//==============================
// ORDER BLOCKS (BASIC SMC LOGIC)
//==============================
var box bullOB = na
var box bearOB = na

bullOBCondition = bullBOS and close[1] < open[1]
bearOBCondition = bearBOS and close[1] > open[1]

if showOB and bullOBCondition
    bullOB := box.new(bar_index-2, high[2], bar_index+20, low[2],
         bgcolor=color.new(color.green, 85),
         border_color=color.green)

if showOB and bearOBCondition
    bearOB := box.new(bar_index-2, high[2], bar_index+20, low[2],
         bgcolor=color.new(color.red, 85),
         border_color=color.red)

//==============================
// FAIR VALUE GAP (FVG)
//==============================

// Bullish FVG
bullFVG = low > high[2]

// Bearish FVG
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(bar_index-2, low, bar_index, high[2],
         bgcolor=color.new(color.green, 90),
         border_color=color.green)

if showFVG and bearFVG
    box.new(bar_index-2, low[2], bar_index, high,
         bgcolor=color.new(color.red, 90),
         border_color=color.red)

//==============================
// LIQUIDITY SWEEPS (EQH / EQL BASIC)
//==============================
eqh = high == ta.highest(high, swingLen * 2)
eql = low  == ta.lowest(low, swingLen * 2)

if showSweep and eqh
    label.new(bar_index, high, "Liquidity High", style=label.style_label_down, color=color.purple)

if showSweep and eql
    label.new(bar_index, low, "Liquidity Low", style=label.style_label_up, color=color.purple)

//==============================
// TREND BACKGROUND
//==============================
bgcolor(trend == 1 ? color.new(color.green, 92) :
       trend == -1 ? color.new(color.red, 92) : na)

//==============================
// ALERTS
//==============================
alertcondition(bullBOS, "Bullish BOS", "Bullish BOS")
alertcondition(bearBOS, "Bearish BOS", "Bearish BOS")
alertcondition(bullCHOCH, "Bullish CHoCH", "Bullish CHoCH")
alertcondition(bearCHOCH, "Bearish CHoCH", "Bearish CHoCH")
````
