# SHK 3 MA  EMA WMA | VWAP | TRIANGLE CROSS

- url: https://www.tradingview.com/script/rSrj5GG3-SHK-3-MA-EMA-WMA-VWAP-TRIANGLE-CROSS/
- type: indicator
- pine_id: PUB;7ca8ceaab56b46dcb89462d84023bc92
- version: 1.0

## Description

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SHK 3 MA  EMA WMA | VWAP | ▲▼ CROSS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A clean and powerful multi-purpose trend indicator combining 
3 fully customisable Moving Averages with crossover signals 
and an anchored VWAP — all in one overlay.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 MOVING AVERAGES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• 3 independent Moving Averages — MA1, MA2, MA3
• Each MA is individually selectable as EMA / SMA / WMA
• Each MA has its own length input
• Default lengths: MA1 = 9 | MA2 = 21 | MA3 = 50
• Color, opacity, thickness and line style controlled 
  directly from the chart legend (click the line name)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 CROSSOVER SIGNALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Two sets of cross signals with triangle labels:

▲ MA1 × MA2 — Bullish cross (triangle below bar)
   Label shows actual lengths e.g. "9×21"

▼ MA1 × MA2 — Bearish cross (triangle above bar)
   Label shows reversed lengths e.g. "21×9"

▲ MA2 × MA3 — Bullish cross (triangle below bar)
   Label shows actual lengths e.g. "21×50"

▼ MA2 × MA3 — Bearish cross (triangle above bar)
   Label shows reversed lengths e.g. "50×21"

Triangle colors match their respective MA line colors.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 VWAP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Volume Weighted Average Price (VWAP)
• Selectable anchor period:
  Session | Week | Month | Quarter | Year
• Toggle on/off from settings
• Color, opacity, thickness and line style 
  controlled from chart legend

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ALERTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4 built-in alert conditions:
• MA1 Crossed Above MA2 ▲ (Bullish)
• MA1 Crossed Below MA2 ▼ (Bearish)
• MA2 Crossed Above MA3 ▲ (Bullish)
• MA2 Crossed Below MA3 ▼ (Bearish)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Add indicator to chart
2. Set MA types and lengths in Settings
3. Click any line name in chart legend to 
   adjust color, opacity, thickness and style
4. Use VWAP as dynamic support/resistance
5. Set alerts from the Alerts menu

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 ⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This indicator is for educational and 
informational purposes only. It does NOT 
constitute financial advice, investment 
advice, or a recommendation to buy or sell 
any financial instrument.

Past performance of any indicator or strategy 
does not guarantee future results. Trading 
involves significant risk of loss and is not 
suitable for all investors. Always do your own 
research and consult a qualified financial 
advisor before making any trading decisions.

The author accepts no responsibility for any 
losses incurred from the use of this indicator.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 © SHK — All rights reserved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
indicator("SHK 3 MA | VWAP | ▲▼ CROSS", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════
//  MA 1
// ═══════════════════════════════════════════════════════════
ma1Type   = input.string("EMA", "MA 1  Type", options=["EMA","SMA","WMA"], group="MA 1", inline="ma1")
ma1Length = input.int(9,        "Length",      minval=1, maxval=500,        group="MA 1", inline="ma1")

// ═══════════════════════════════════════════════════════════
//  MA 2
// ═══════════════════════════════════════════════════════════
ma2Type   = input.string("EMA", "MA 2  Type", options=["EMA","SMA","WMA"], group="MA 2", inline="ma2")
ma2Length = input.int(21,       "Length",      minval=1, maxval=500,        group="MA 2", inline="ma2")

// ═══════════════════════════════════════════════════════════
//  MA 3
// ═══════════════════════════════════════════════════════════
ma3Type   = input.string("EMA", "MA 3  Type", options=["EMA","SMA","WMA"], group="MA 3", inline="ma3")
ma3Length = input.int(50,       "Length",      minval=1, maxval=500,        group="MA 3", inline="ma3")

// ═══════════════════════════════════════════════════════════
//  VWAP
// ═══════════════════════════════════════════════════════════
showVWAP   = input.bool(true, "Show VWAP", group="VWAP")
vwapAnchor = input.string("Session", "Anchor",
     options=["Session","Week","Month","Quarter","Year"], group="VWAP")

// ═══════════════════════════════════════════════════════════
//  MA CALCULATION
// ═══════════════════════════════════════════════════════════
getMA(src, len, t) =>
    switch t
        "EMA" => ta.ema(src, len)
        "SMA" => ta.sma(src, len)
        "WMA" => ta.wma(src, len)
        =>       ta.ema(src, len)

ma1 = getMA(close, ma1Length, ma1Type)
ma2 = getMA(close, ma2Length, ma2Type)
ma3 = getMA(close, ma3Length, ma3Type)

// ═══════════════════════════════════════════════════════════
//  PLOT MAs  — color/thickness/style via legend click
// ═══════════════════════════════════════════════════════════
p1 = plot(ma1, "MA 1", color=color.new(#2196F3, 0), linewidth=2)
p2 = plot(ma2, "MA 2", color=color.new(#FF9800, 0), linewidth=2)
p3 = plot(ma3, "MA 3", color=color.new(#E91E63, 0), linewidth=2)

// ═══════════════════════════════════════════════════════════
//  CROSS CONDITIONS
// ═══════════════════════════════════════════════════════════
cross12Up   = ta.crossover(ma1, ma2)
cross12Down = ta.crossunder(ma1, ma2)
cross23Up   = ta.crossover(ma2, ma3)
cross23Down = ta.crossunder(ma2, ma3)

// ═══════════════════════════════════════════════════════════
//  CROSS LABELS — triangle + lengths as text
//  UP → "9×21"   DOWN → "21×9"
// ═══════════════════════════════════════════════════════════
if cross12Up
    label.new(bar_index, low,  str.tostring(ma1Length) + "×" + str.tostring(ma2Length),
         style=label.style_triangleup,   color=color.new(#2196F3, 0), textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if cross12Down
    label.new(bar_index, high, str.tostring(ma2Length) + "×" + str.tostring(ma1Length),
         style=label.style_triangledown, color=color.new(#2196F3, 0), textcolor=color.white, size=size.small, yloc=yloc.abovebar)
if cross23Up
    label.new(bar_index, low,  str.tostring(ma2Length) + "×" + str.tostring(ma3Length),
         style=label.style_triangleup,   color=color.new(#FF9800, 0), textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if cross23Down
    label.new(bar_index, high, str.tostring(ma3Length) + "×" + str.tostring(ma2Length),
         style=label.style_triangledown, color=color.new(#FF9800, 0), textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// ═══════════════════════════════════════════════════════════
//  VWAP CALCULATION
// ═══════════════════════════════════════════════════════════
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

// ═══════════════════════════════════════════════════════════
//  PLOT VWAP  — color/thickness/style via legend click
// ═══════════════════════════════════════════════════════════
plot(showVWAP ? vwapVal : na, "VWAP", color=color.new(#FFEB3B, 0), linewidth=2)

// ═══════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(cross12Up,   title="MA1 Crossed Above MA2 ▲", message="{{ticker}} — MA1 crossed ABOVE MA2 (Bullish)")
alertcondition(cross12Down, title="MA1 Crossed Below MA2 ▼", message="{{ticker}} — MA1 crossed BELOW MA2 (Bearish)")
alertcondition(cross23Up,   title="MA2 Crossed Above MA3 ▲", message="{{ticker}} — MA2 crossed ABOVE MA3 (Bullish)")
alertcondition(cross23Down, title="MA2 Crossed Below MA3 ▼", message="{{ticker}} — MA2 crossed BELOW MA3 (Bearish)")
````
