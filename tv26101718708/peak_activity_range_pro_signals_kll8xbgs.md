# Peak Activity Range Pro + Signals

- url: https://www.tradingview.com/script/KLL8XBGS-Peak-Activity-Range-Pro-Signals/
- type: indicator
- pine_id: PUB;341831f2b34d42d3aeb7d2d960a5dc25
- version: 2.0

## Description

[b]Peak Activity Range Pro + Signals[/b] is an advanced price action indicator that automatically identifies high-activity trading zones where buyers and sellers have shown strong participation. These zones can help traders monitor potential support, resistance, breakout, and retest opportunities across multiple markets.

The indicator continuously analyzes recent price action to locate areas where momentum slows, reversals develop, or consolidation occurs before significant market moves.

[b]Features[/b]
• Automatic Bullish Activity Zones
• Automatic Bearish Activity Zones
• Dynamic Supply & Demand Areas

• [b]Retest Detection[/b]
• Zone Strength Classification
• Bullish & Bearish Reaction Markers
• Automatic Zone Extension
• Expired Zone Removal
• Optional EMA Trend Filter
• Multi-Timeframe Compatible
• Non-Repainting Zone Detection

[b] How It Works[/b]
The indicator scans recent candles to detect areas where price experienced significant buying or selling activity. When a bullish accumulation zone is confirmed, a Buy Activity Range is created and projected forward until it is invalidated When bearish distribution is detected, a Sell Activity Range is generated to highlight potential resistance. As price revisits these areas, traders can monitor reactions for continuation or reversal confirmation.

[b]Zone Colors[/b]

🟢[b] Bullish Activity Range[/b]
* Potential demand
* Buyer participation
* Retest support

🔴 [b]Bearish Activity Range[/b]
* Potential supply
* Seller participation
* Retest resistance

[b]Recommended Timeframes[/b]
[b]
Scalping[/b]
• M5
• M15

[b]Intraday[/b]
• M30
• H1

[b]Swing Trading[/b]
• H4
• Daily

[b]Indicator Highlights[/b]
• Automatic Activity Range Detection • Smart Zone Projection • Clean Chart Layout
• Lightweight Performance • Configurable Sensitivity • Adjustable Zone Width • Retest Confirmation • Visual Buy/Sell Bias • Suitable for Trending and Ranging Markets

[b]Suggested Trading Workflow[/b]
1. Identify the prevailing market trend.
2. Wait for price to return to an activity range.
3. Watch for confirmation such as a rejection candle, market structure shift, or momentum signal.
4. Manage risk using appropriate stop-loss and position sizing.


[b]Notes[/b]
This indicator is designed as an analytical tool to highlight historical price activity zones. It should be used alongside your own trading plan, market structure analysis, and risk management. Like all technical indicators, it does not predict future price movements or guarantee profitable trades.

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
