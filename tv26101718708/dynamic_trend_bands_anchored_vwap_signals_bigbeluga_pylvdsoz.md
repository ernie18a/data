# Dynamic Trend Bands & Anchored VWAP Signals [BigBeluga]

- url: https://www.tradingview.com/script/pYlVdSoZ-Dynamic-Trend-Bands-Anchored-VWAP-Signals-BigBeluga/
- type: indicator
- pine_id: PUB;17d0907778714e1fbafabc0273800259
- version: 2.0

## Description

[b]Dynamic Trend Bands & Anchored VWAP Signals [BigBeluga][/b] is an institutional-grade market structure toolkit built for TradingView. It blends smooth mathematical trend mapping with real-time volume calculations to identify key market turning points and trade breakout momentum.

Instead of displaying standard lag-heavy moving averages, this system locks onto real-time volatility boundaries and anchors Volume Weighted Average Price (VWAP) paths to major swing pivots. It tells you exactly who controls the market—buyers or sellers—and tracks the net volume driving every single expansion phase.

[b]🔵 MAIN ENGINE & MARKET CALCULATION MECHANICS[/b]

[b]1. Dynamic Volatility Envelope Framework[/b]
[list]
[*] [b]Smoothed Base Filter:[/b] The indicator runs a double-smoothed exponential moving average engine ([b]Baseline Length[/b]) to find the true structural baseline of the asset.
[*] [b]ATR Volatility Channels:[/b] It projects dynamic outer bands based on market volatility over a set period ([b]ATR Volatility Length[/b]). The width adjusts automatically using your preference ([b]ATR Band Multiplier[/b]) to trap standard price fluctuations and highlight true volatility expansion zones.
[*] [b]Trend Flip Architecture:[/b] A definitive close above the upper band switches the system to a Bullish Regime, while a close below the lower band forces a Bearish Regime.
[image]https://www.tradingview.com/x/NufFLiNh/[/image]
[/list]

[b]2. Pivot-Anchored VWAP Matrix[/b]
[list]
[*] [b]Structural Anchor Selection:[/b] The engine scans your chart using your lookback criteria ([b]Pivot Point Detection Length[/b]) to pinpoint major structural market highs and lows.
[*] [b]Live VWAP Projections:[/b] The moment a trend flip occurs and a pivot is confirmed, the script constructs a dynamic, non-repainting polyline tracking the Volume Weighted Average Price (VWAP) directly from that structural anchor point.
[*] [b]Delta Volume Accumulation Engine:[/b] As price moves along the anchored line, a real-time looping counter sums up the true buy and sell volume to calculate Delta Volume (buying volume minus selling volume).
[image]https://www.tradingview.com/x/DTeT9g1F/[/image]
[/list]

[pine]
// Pivot-Anchored VWAP Delta Volume Accumulation Loop Snippet
for i = 0 to bar_index - highIndex - 1
    cp1.push(chart.point.from_index(bar_index - i, vwap1[i]))
    loopDeltaVolHigh := loopDeltaVolHigh + (close[i] > open[i] ? volume[i] : -volume[i])
    
poly1 := polyline.new(cp1, line_color = bullColor, line_style = line.style_dotted, line_width = 2)
[/pine]

[b]🔵 WHY IT IS USEFUL[/b]

[list]
[*] [b]Exposes Institutional Commitments:[/b] Standard indicators show where price has been. This engine anchors to major structural pivots and factors in volume data to show you exactly where big institutional players are positioning their capital.
[*] [b]Provides Instant Market Context:[/b] The floating real-time dashboard reveals the macro trend status and the exact volume backing the latest market cycle at a glance, allowing you to instantly align your bias with the dominant force.
[*] [b]Quantifies Breakout Authenticity:[/b] When price breaches the anchored VWAP baseline, the indicator immediately calculates the net Delta Volume. This tells you if a breakout is backed by aggressive institutional participation or if it is just a low-volume trap.
[image]https://www.tradingview.com/x/WAB1AlvZ/[/image]
[/list]

[b]🔵 HOW TO USE THE SYSTEM[/b]

[list]
[*] [b]Trading Bullish Breakouts:[/b] During an active uptrend, watch for price to pull back toward the lower volatility support bands or consolidation zones. Look for price to break sharply back up through the anchored VWAP baseline line. When a green breakout triangle ([b]▲[/b]) appears, check the Delta Volume text label to verify aggressive buying pressure before entering.

[*] [b]Trading Bearish Breakdowns:[/b] When the macro regime shifts to bearish, monitor rallies into the upper resistance bands. Wait for price to cross down through the bearish anchored VWAP baseline. A purple breakdown triangle ([b]▼[/b]) signals a high-probability short opportunity backed by aggressive selling volume.
[*] [b]Managing Risk and Invalidations:[/b] Use the outer volatility bands as dynamic structural backstops. For long positions, place your defensive stop loss just below the lower dotted line boundary; for short positions, manage risk right above the upper dotted line boundary.
[/list]

Master institutional volume cycles and track true structural momentum using the [b]Dynamic Trend Bands & Anchored VWAP Signals[/b] workspace.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Dynamic Trend Bands & Anchored VWAP Signals [BigBeluga]", "Dynamic Trend Bands & Signals [BigBeluga]", overlay = true, max_bars_back = 5000, max_labels_count = 500, max_polylines_count = 100, calc_bars_count = 5000)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

int lrLength    = input.int(50, minval=1, title="Baseline Length", tooltip="Sets the period for the central moving average baseline calculation.")
int atrLength   = input.int(100, minval=1, title="ATR Volatility Length", tooltip="Determines the number of bars used to measure market volatility for band spacing.")
float atrMult   = input.float(3.0, minval=0.1, step=0.1, title="ATR Band Multiplier", tooltip="Multiplies the volatility value to widen or narrow the outer support/resistance bands.")
int pivotLength = input.int(10, minval=1, title="Pivot Point Detection Length", tooltip="The number of bars required on each side to confirm a valid market structural high or low pivot.")

// Style & Color Inputs
color bullColor = input.color(color.lime, title="Bullish / Up Color", group="Color Settings")
color bearColor = input.color(color.rgb(158, 55, 255), title="Bearish / Down Color", group="Color Settings")

// Dashboard Settings
bool showDash    = input.bool(true, title="Show Information Dashboard", group="Dashboard Settings")
string dashPos   = input.string(position.top_right, title="Dashboard Position", options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left], group="Dashboard Settings")

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// ── Volatility Band Calculations ──
float atrValue   = ta.atr(atrLength)
float lrCenter   = ta.ema(ta.ema(close, lrLength), lrLength)

float upperBand  = lrCenter + (atrValue * atrMult)
float lowerBand  = lrCenter - (atrValue * atrMult)

// ── State Tracking Logic ──
var int trendState = 0

if ta.crossover(close, upperBand)
    trendState := 1
if ta.crossunder(close, lowerBand)
    trendState := -1

float plotUpper = trendState == -1 ? upperBand : na
float plotLower = trendState == 1 ? lowerBand : na

// ── Signal & Tracking Variables ──
bool breakUp = false
bool breakDn = false

var float finalDeltaVolLow  = 0.0
var float finalDeltaVolHigh = 0.0
var label lbl               = na

// Clear the real-time tracking label on every new bar tick before rewriting
lbl.delete()

// ── Pivot & VWAP Logic (Low / Bearish Regime) ──
float pl      = ta.pivotlow(pivotLength, pivotLength)
float l       = ta.lowest(pivotLength)
bool lowPivot = low[1] == l and low > l 

var int lowIndx  = 0 
var int lowIndex = 0

if trendState == -1
    if lowPivot
        lowIndx := bar_index - 1
    if not na(pl)
        lowIndex := lowIndx

float vwap = ta.vwap(low[1], lowPivot)

var polyline poly = na
chart.point[] cp  = array.new<chart.point>()


if trendState == -1
    if not na(pl) and trendState[pivotLength] == -1
        cp.clear()
        poly.delete()
        poly := polyline.new(cp)
    else if not na(poly) 
        poly.delete()
        float loopDeltaVolLow = 0.0
        
        for i = 0 to bar_index - lowIndex - 1
            cp.push(chart.point.from_index(bar_index - i, vwap[i]))
            loopDeltaVolLow := loopDeltaVolLow + (close[i] > open[i] ? volume[i] : -volume[i])
        
        lbl  := label.new(bar_index, vwap, str.tostring(loopDeltaVolLow, format.volume), textcolor = bearColor, color = color.new(bearColor, 100), style = label.style_label_left)
        poly := polyline.new(cp, line_color = bearColor, line_style = line.style_dotted, line_width = 2)

        if close <= vwap and na(pl)
            poly             := na
            breakDn          := true
            finalDeltaVolLow := loopDeltaVolLow

// ── Pivot & VWAP Logic (High / Bullish Regime) ──
float ph       = ta.pivothigh(pivotLength, pivotLength)
float h        = ta.highest(pivotLength)
bool highPivot = high[1] == h and high < h 

var polyline poly1 = na
chart.point[] cp1  = array.new<chart.point>()

var int highIndx  = 0 
var int highIndex = 0

if trendState == 1
    if highPivot
        highIndx := bar_index - 1
    if not na(ph)
        highIndex := highIndx

float vwap1 = ta.vwap(high[1], highPivot)

if trendState == 1
    if not na(ph) and trendState[pivotLength] == 1
        cp1.clear()
        poly1.delete()
        poly1 := polyline.new(cp1)
    else if not na(poly1) 
        poly1.delete()
        float loopDeltaVolHigh = 0.0
        
        for i = 0 to bar_index - highIndex - 1
            cp1.push(chart.point.from_index(bar_index - i, vwap1[i]))
            loopDeltaVolHigh := loopDeltaVolHigh + (close[i] > open[i] ? volume[i] : -volume[i])
            
        poly1 := polyline.new(cp1, line_color = bullColor, line_style = line.style_dotted, line_width = 2)
        lbl   := label.new(bar_index, vwap1, str.tostring(loopDeltaVolHigh, format.volume), textcolor = bullColor, color = color.new(bearColor, 100), style = label.style_label_left)

        if close >= vwap1 and na(ph)
            poly1             := na
            breakUp           := true
            finalDeltaVolHigh := loopDeltaVolHigh

// ── State Reset Cleanup ──
if trendState != trendState[1]
    poly.delete()
    poly1.delete()
    poly1 := na 
    poly  := na

// ── Dashboard Persistent History Tracking ──
var string lastBreakType = "None"
var float lastBreakVol   = 0.0

if breakUp
    lastBreakType := "Bullish"
    lastBreakVol   := finalDeltaVolHigh
if breakDn
    lastBreakType := "Bearish"
    lastBreakVol   := finalDeltaVolLow

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

// ── Volatility Bands Plots ──
pup = plot(plotUpper, color=bearColor, linewidth=1, style=plot.style_linebr, title="Upper Resistance Band")
plo = plot(plotLower, color=bullColor, linewidth=1, style=plot.style_linebr, title="Lower Support Band")

pp   = plot(close, "Price", editable = false, display = display.none)
pup1 = plot(plotUpper-atrValue, color=bearColor, linewidth=1, style=plot.style_linebr, title="Upper Resistance Band", linestyle = plot.linestyle_dotted)
plo1 = plot(plotLower+atrValue, color=bullColor, linewidth=1, style=plot.style_linebr, title="Lower Support Band", linestyle = plot.linestyle_dotted)

fill(pup, pup1, plotUpper, plotUpper-atrValue, color.new(bearColor, 70), color.new(bearColor, 100), title = "Upper Fill")
fill(plo, plo1, plotLower+atrValue, plotLower, color.new(bullColor, 100), color.new(bullColor, 70), title = "Lower Fill")

// ── Breakout/Breakdown Shapes ──
plotshape(breakUp, "Break Up Triangle", shape.triangleup, location.belowbar, color=bullColor, size = size.tiny)
plotshape(breakDn, "Break Dn Triangle", shape.triangledown, location.abovebar, bearColor, size = size.tiny)

// ── Dynamic Breakout Label Instantiation ──
if breakUp
    label.new(
         x=bar_index, 
         y=low, 
         text="Δ: " + str.tostring(finalDeltaVolHigh, "#,###"), 
         yloc=yloc.belowbar, 
         color=color.new(bullColor, 100), 
         textcolor=chart.fg_color, 
         style=label.style_label_up, 
         size=size.small
     )

if breakDn
    label.new(
         x=bar_index, 
         y=high, 
         text= "Δ: " + str.tostring(finalDeltaVolLow, "#,###"), 
         yloc=yloc.abovebar, 
         color=color.new(bearColor, 100), 
         textcolor=chart.fg_color, 
         style=label.style_label_down, 
         size=size.small
     )

// ── Dashboard Display Implementation ──
var table dashTable = table.new(dashPos, 2, 3, bgcolor=color.new(color.black, 20), border_color=chart.bg_color, border_width=1)

if showDash and barstate.islast
    // Header Style Setup
    color headerBg = color.new(color.black, 30)
    
    // Row 0: Headers
    table.cell(dashTable, 0, 0, "Metric", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    table.cell(dashTable, 1, 0, "Current Value", text_color=color.white, bgcolor=headerBg, text_size=size.small)
    
    // Row 1: Trend State
    string trendText = trendState == 1 ? "BULLISH" : trendState == -1 ? "BEARISH" : "NEUTRAL"
    color trendBg    = trendState == 1 ? color.new(bullColor, 30) : trendState == -1 ? color.new(bearColor, 30) : color.new(color.gray, 50)
    table.cell(dashTable, 0, 1, "Current Trend", text_color=color.white, bgcolor=color.new(color.gray, 15), text_size=size.small)
    table.cell(dashTable, 1, 1, trendText, text_color=color.white, bgcolor=trendBg, text_size=size.small)
    
    // Row 2: Last Breakout Status
    color breakBg   = lastBreakType == "Bullish" ? color.new(bullColor, 40) : lastBreakType == "Bearish" ? color.new(bearColor, 40) : color.new(color.gray, 50)
    string breakVal = lastBreakType == "None" ? "No Breakouts" : lastBreakType + " (Delta Vol: " + str.tostring(lastBreakVol, format.volume) + ")"
    table.cell(dashTable, 0, 2, "Last Breakout", text_color=color.white, bgcolor=color.new(color.gray, 15), text_size=size.small)
    table.cell(dashTable, 1, 2, breakVal, text_color=color.white, bgcolor=breakBg, text_size=size.small)
// }
````
