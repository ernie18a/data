# SHK 3 MA | SIGNAL STRENGTH MA [HA/ST/UT] | VWAP | TRIANGLE CROSS

- url: https://www.tradingview.com/script/iuJtjDBA-SHK-3-MA-SIGNAL-STRENGTH-MA-HA-ST-UT-VWAP-TRIANGLE-CROSS/
- type: indicator
- pine_id: PUB;78aa8a98c40644aa97b37686499e2162
- version: 1.0

## Description

🔷 SHK 3 MA | Signal MA [HA · ST · UT] | VWAP | ▲▼ Cross Labels

An all-in-one trend-following overlay that combines three fully 
customizable Moving Averages, an intelligent colour-coded Signal MA, 
a manually anchored VWAP, and automatic triangle labels on every 
MA crossover — all in a single clean indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 THREE MOVING AVERAGES  (MA 1 · MA 2 · MA 3)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Each MA is independently configurable with:
  • Type   — EMA | SMA | WMA | HMA | TEMA | DEMA | ZLEMA
  • Length — 1 to 500
  • Colour — fully customizable

Use them as trend bias lines, dynamic support/resistance, 
or a classic 9/21/50 ribbon setup.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 SIGNAL MA — 3-FILTER VOTING SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A dedicated Signal MA whose colour dynamically reflects 
market bias, scored from three independent filters:

  ✅ Heiken Ashi  — Synthetic HA (non-repainting, real OHLC based)
  ✅ Supertrend   — ATR-based trend direction
  ✅ UT Bot       — ATR trailing stop momentum filter

  🟢 Green  = majority bullish  (score > 0)
  🔴 Red    = majority bearish  (score < 0)
  ⚪ Grey   = conflicting / neutral (score = 0)

Each filter can be toggled ON/OFF independently. 
Line width is also adjustable (1–5).

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 VWAP  (Manual Anchor)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Custom-built VWAP (not ta.vwap) with selectable anchor:
  Session | Week | Month | Quarter | Year

The cumulative TPV/Volume resets cleanly at each anchor period, 
giving accurate institutional price reference across all timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▲▼ MA CROSS LABELS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Triangle labels auto-plot at every crossover between:
  • MA 1 × MA 2
  • MA 2 × MA 3

  ▲ Up-triangle (below bar)  = bullish cross
  ▼ Down-triangle (above bar) = bearish cross

Label text shows the exact period pair (e.g. 9×21). 
Colour matches the respective MA colour. Up to 500 labels displayed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 ALERTS  (6 pre-built conditions)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • MA1 crossed above/below MA2
  • MA2 crossed above/below MA3
  • Signal MA flipped Bullish 🟢
  • Signal MA flipped Bearish 🔴

Signal MA flip alerts fire only once per state change 
(not on every bar), keeping notifications clean and actionable.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ RECOMMENDED SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Scalping / Intraday  →  9 / 21 / 50  EMA  |  VWAP: Session
  Swing Trading        →  20 / 50 / 200 EMA  |  VWAP: Week/Month
  All filters ON for strongest Signal MA confirmation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 NOTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  • Built in Pine Script® v6
  • Overlay indicator — works on any symbol and timeframe
  • Heiken Ashi is synthetic (does not repaint real price values)
  • UT Bot uses HA close as source for noise-filtered signals
  • No repainting on MA or cross label logic

Best used on NSE / BSE instruments (Nifty, BankNifty, stocks) 
on 5m, 15m, or 1H charts with all three filters enabled 
for high-confidence trend confirmation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This indicator is published for educational and informational 
purposes only. It does not constitute financial advice, investment 
recommendations, or a solicitation to buy or sell any financial 
instrument.

All trading involves substantial risk of loss. Past performance 
of any indicator or strategy does not guarantee future results. 
You are solely responsible for your own trading decisions.

This script does not repaint on MA or cross label logic; however, 
the Signal MA colour (HA · ST · UT filters) is calculated on the 
current bar and may update until the bar closes. Always wait for 
bar close confirmation before acting on any signal.

The author is not a SEBI-registered investment advisor. 
Use this tool at your own risk. Always apply proper 
risk management and consult a qualified financial professional 
before making any trading decisions.

© SHK — All rights reserved. Please do not copy, reproduce, 
or publish this script without the author's permission.

## Source Code

````pine
//@version=6
indicator("SHK 3 MA | VWAP | ▲▼ CROSS", overlay=true, max_labels_count=500)


// ═══════════════════════════════════════════════════════════
//  MA 1
// ═══════════════════════════════════════════════════════════
ma1Type   = input.string("EMA", "MA 1  Type", options=["EMA","SMA","WMA","HMA","TEMA","DEMA","ZLEMA"], group="MA 1", inline="ma1")
ma1Length = input.int(9,        "Length",     minval=1, maxval=500, group="MA 1", inline="ma1")
ma1Col    = input.color(color.new(#2196F3, 0), "Colour", group="MA 1", inline="ma1")

// ═══════════════════════════════════════════════════════════
//  MA 2
// ═══════════════════════════════════════════════════════════
ma2Type   = input.string("EMA", "MA 2  Type", options=["EMA","SMA","WMA","HMA","TEMA","DEMA","ZLEMA"], group="MA 2", inline="ma2")
ma2Length = input.int(21,       "Length",     minval=1, maxval=500, group="MA 2", inline="ma2")
ma2Col    = input.color(color.new(#FF9800, 0), "Colour", group="MA 2", inline="ma2")

// ═══════════════════════════════════════════════════════════
//  MA 3
// ═══════════════════════════════════════════════════════════
ma3Type   = input.string("EMA", "MA 3  Type", options=["EMA","SMA","WMA","HMA","TEMA","DEMA","ZLEMA"], group="MA 3", inline="ma3")
ma3Length = input.int(50,       "Length",     minval=1, maxval=500, group="MA 3", inline="ma3")
ma3Col    = input.color(color.new(#E91E63, 0), "Colour", group="MA 3", inline="ma3")

// ═══════════════════════════════════════════════════════════
//  SIGNAL MA  (colour driven by UT Bot + ST + HA)
// ═══════════════════════════════════════════════════════════
smType    = input.string("EMA", "Signal MA Type",  options=["EMA","SMA","WMA","HMA","TEMA","DEMA","ZLEMA"], group="Signal MA", inline="sm")
smLength  = input.int(20,       "Length",           minval=1, maxval=500, group="Signal MA", inline="sm")
smWidth   = input.int(3,        "Line Width",       minval=1, maxval=5,   group="Signal MA", inline="sm")
smBullCol = input.color(color.new(#00E676, 0), "Bull",    group="Signal MA", inline="smcol")
smBearCol = input.color(color.new(#FF1744, 0), "Bear",    group="Signal MA", inline="smcol")
smNeutCol = input.color(color.new(#B0BEC5, 0), "Neutral", group="Signal MA", inline="smcol")

useHA = input.bool(true, "Heiken Ashi filter", group="Signal MA — Filters", inline="f1")
useST = input.bool(true, "Supertrend filter",  group="Signal MA — Filters", inline="f1")
useUT = input.bool(true, "UT Bot filter",       group="Signal MA — Filters", inline="f1")

// ═══════════════════════════════════════════════════════════
//  VWAP
// ═══════════════════════════════════════════════════════════
showVWAP   = input.bool(true, "Show VWAP", group="VWAP")
vwapAnchor = input.string("Session", "Anchor",
     options=["Session","Week","Month","Quarter","Year"], group="VWAP")

// ═══════════════════════════════════════════════════════════
//  SUPERTREND  (background filter only)
// ═══════════════════════════════════════════════════════════
stLength = input.int(10,    "ATR Length", minval=1,   group="Supertrend (Signal MA filter)", inline="st")
stFactor = input.float(3.0, "Factor",     minval=0.1, group="Supertrend (Signal MA filter)", inline="st", step=0.1)

// ═══════════════════════════════════════════════════════════
//  UT BOT  (background filter only)
// ═══════════════════════════════════════════════════════════
utKeyValue = input.float(1.0, "Key Value",  minval=0.1, step=0.1, group="UT Bot (Signal MA filter)")
utATRLen   = input.int(1,     "ATR Period", minval=1,   group="UT Bot (Signal MA filter)")


// ═══════════════════════════════════════════════════════════
//  MA ENGINE
// ═══════════════════════════════════════════════════════════
getMA(src, len, t) =>
    float result = na
    switch t
        "EMA"   => result := ta.ema(src, len)
        "SMA"   => result := ta.sma(src, len)
        "WMA"   => result := ta.wma(src, len)
        "HMA"   => result := ta.wma(2 * ta.wma(src, len / 2) - ta.wma(src, len), math.round(math.sqrt(len)))
        "TEMA"  =>
            e1 = ta.ema(src, len)
            e2 = ta.ema(e1,  len)
            e3 = ta.ema(e2,  len)
            result := 3 * e1 - 3 * e2 + e3
        "DEMA"  =>
            e1 = ta.ema(src, len)
            result := 2 * e1 - ta.ema(e1, len)
        "ZLEMA" =>
            lag = math.round((len - 1) / 2)
            result := ta.ema(src + (src - src[lag]), len)
        => result := ta.ema(src, len)
    result

ma1   = getMA(close, ma1Length, ma1Type)
ma2   = getMA(close, ma2Length, ma2Type)
ma3   = getMA(close, ma3Length, ma3Type)
smVal = getMA(close, smLength,  smType)


// ═══════════════════════════════════════════════════════════
//  HEIKEN ASHI  (synthetic)
// ═══════════════════════════════════════════════════════════
haClose  = (open + high + low + close) / 4
var float haOpen = na
haOpen  := na(haOpen[1]) ? (open + close) / 2 : (haOpen[1] + haClose[1]) / 2
haIsBull = haClose > haOpen
haIsBear = haClose < haOpen


// ═══════════════════════════════════════════════════════════
//  SUPERTREND  (calculation only)
// ═══════════════════════════════════════════════════════════
[stLine, stDir] = ta.supertrend(stFactor, stLength)
stBull = stDir < 0
stBear = stDir > 0


// ═══════════════════════════════════════════════════════════
//  UT BOT  (calculation only)
// ═══════════════════════════════════════════════════════════
xATR  = ta.atr(utATRLen)
nLoss = utKeyValue * xATR
utSrc = haClose

var float xATRTS = 0.0
xATRTS :=
     utSrc > nz(xATRTS[1]) and utSrc[1] > nz(xATRTS[1]) ?
         math.max(nz(xATRTS[1]), utSrc - nLoss) :
     utSrc < nz(xATRTS[1]) and utSrc[1] < nz(xATRTS[1]) ?
         math.min(nz(xATRTS[1]), utSrc + nLoss) :
     utSrc > nz(xATRTS[1]) ? utSrc - nLoss : utSrc + nLoss

utBull = utSrc > xATRTS
utBear = utSrc < xATRTS


// ═══════════════════════════════════════════════════════════
//  SIGNAL MA COLOUR  (voting system)
// ═══════════════════════════════════════════════════════════
score = 0
score := score + (useHA ? (haIsBull ? 1 : haIsBear ? -1 : 0) : 0)
score := score + (useST ? (stBull   ? 1 : stBear   ? -1 : 0) : 0)
score := score + (useUT ? (utBull   ? 1 : utBear   ? -1 : 0) : 0)

smColor = score > 0 ? smBullCol : score < 0 ? smBearCol : smNeutCol


// ═══════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════
plot(ma1,   "MA 1",      color=ma1Col,   linewidth=2)
plot(ma2,   "MA 2",      color=ma2Col,   linewidth=2)
plot(ma3,   "MA 3",      color=ma3Col,   linewidth=2)
plot(smVal, "Signal MA", color=smColor,  linewidth=smWidth)

// VWAP
anchorReset =
     vwapAnchor == "Session"  ? timeframe.change("D")   :
     vwapAnchor == "Week"     ? timeframe.change("W")   :
     vwapAnchor == "Month"    ? timeframe.change("M")   :
     vwapAnchor == "Quarter"  ? (month != month[3] and (month == 1 or month == 4 or month == 7 or month == 10)) :
     vwapAnchor == "Year"     ? timeframe.change("12M") : timeframe.change("D")

var float cumTPV = 0.0
var float cumVol = 0.0
if anchorReset or barstate.isfirst
    cumTPV := hlc3 * volume
    cumVol := volume
else
    cumTPV += hlc3 * volume
    cumVol += volume

vwapVal = cumVol != 0 ? cumTPV / cumVol : na
plot(showVWAP ? vwapVal : na, "VWAP", color=color.new(#FFEB3B, 0), linewidth=2)


// ═══════════════════════════════════════════════════════════
//  MA CROSS LABELS  — triangle colour follows MA input colour
// ═══════════════════════════════════════════════════════════
cross12Up   = ta.crossover (ma1, ma2)
cross12Down = ta.crossunder(ma1, ma2)
cross23Up   = ta.crossover (ma2, ma3)
cross23Down = ta.crossunder(ma2, ma3)

if cross12Up
    label.new(bar_index, low,  str.tostring(ma1Length) + "×" + str.tostring(ma2Length),
         style=label.style_triangleup,   color=ma1Col,
         textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if cross12Down
    label.new(bar_index, high, str.tostring(ma2Length) + "×" + str.tostring(ma1Length),
         style=label.style_triangledown, color=ma1Col,
         textcolor=color.white, size=size.small, yloc=yloc.abovebar)
if cross23Up
    label.new(bar_index, low,  str.tostring(ma2Length) + "×" + str.tostring(ma3Length),
         style=label.style_triangleup,   color=ma2Col,
         textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if cross23Down
    label.new(bar_index, high, str.tostring(ma3Length) + "×" + str.tostring(ma2Length),
         style=label.style_triangledown, color=ma2Col,
         textcolor=color.white, size=size.small, yloc=yloc.abovebar)


// ═══════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(cross12Up,                   title="MA1 Crossed Above MA2 ▲",    message="{{ticker}} — MA1 crossed ABOVE MA2 (Bullish)")
alertcondition(cross12Down,                 title="MA1 Crossed Below MA2 ▼",    message="{{ticker}} — MA1 crossed BELOW MA2 (Bearish)")
alertcondition(cross23Up,                   title="MA2 Crossed Above MA3 ▲",    message="{{ticker}} — MA2 crossed ABOVE MA3 (Bullish)")
alertcondition(cross23Down,                 title="MA2 Crossed Below MA3 ▼",    message="{{ticker}} — MA2 crossed BELOW MA3 (Bearish)")
alertcondition(score > 0 and score[1] <= 0, title="Signal MA turned Bullish 🟢", message="{{ticker}} — Signal MA flipped BULL")
alertcondition(score < 0 and score[1] >= 0, title="Signal MA turned Bearish 🔴", message="{{ticker}} — Signal MA flipped BEAR")
````
