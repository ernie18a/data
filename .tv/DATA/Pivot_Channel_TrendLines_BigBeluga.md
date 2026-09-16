<!-- tradingview-pine-id: PUB;efe277395f074e2f83e05a2fd5b80218 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pivot Channel TrendLines [BigBeluga]

Source: https://www.tradingview.com/script/GPTrj0bB-Pivot-Channel-TrendLines-BigBeluga/

## Description

🔵 OVERVIEW
The Pivot Channel TrendLines [BigBeluga] is an advanced technical analysis indicator designed by BigBeluga to automatically map structural pivot points, project dynamic trendline channels, and track directional breakout signals directly on the chart. Traditional manual trendline drawing is often subjective and time-consuming, while standard indicators fail to account for slope progression and volatility filters. To solve this limitation, this script combines an automated pivot detection engine with ATR-filtered extension lines and real-time breakout triggers.

The indicator visualizes key market highs and lows, dotted projection channels, and directional signals. The core calculations identify confirmed pivot extremes using configurable lookback periods, compute slope values between successive pivots, and filter out insignificant structures using Average True Range thresholds. Customizable color palettes, line styles, and extension lengths allow traders to fine-tune the geometric mappings across various asset classes and timeframes.

🔵 HOW IT WORKS
The system operates through an integrated architecture where each component dynamically influences chart behavior:

1 — Automated Pivot Detection Engine

[*] Lookback Scanning: Evaluates bar ranges using user-defined lookback criteria to identify significant swing highs and lows.
[*] ATR Filtering: Compares successive pivot price differentials against Average True Range thresholds to ensure only meaningful structural shifts generate active channels.

2 — Dynamic Trendline Projection & Channels

[*] Confirmed Trendlines: Connects historical pivot points with solid boundary lines to map ongoing trend channels.
[*] Dotted Extensions: Projects sloping extension lines forward by a user-defined bar length to monitor future support and resistance interactions.

[image]https://www.tradingview.com/x/nvbxfBgk/[/image]

3 — Directional Breakout & Price Dash System

[*] Breakout Triggers: Monitors active extension lines in real time, plotting directional labels ("Up" or "Down") whenever price closes beyond expected threshold boundaries.
[*] Last Pivot Dashes: Renders customizable horizontal dashed or dotted lines alongside precise price level tags for the latest identified high and low pivots.
[image]https://www.tradingview.com/x/qcCDnuGz/[/image]

🔵 HOW TO USE
Apart from serving as an automated structural mapping tool, the indicator can be applied in several ways:

[*] Identify Trend Channels: Follow the solid and dotted trendlines connecting major pivot highs and lows to track prevailing market direction and channel boundaries.
[*] Catch Structural Breakouts: Monitor the chart for Up or Down directional labels indicating when price has successfully broken through active projected extension lines.
[*] Track Recent Reference Prices: Use the last pivot price dashes to quickly reference key support and resistance boundaries established by the most recent market swings.

🔵 NOTES
Why this implementation is unique:

[*] It automates complex pivot channel mapping and slope projections directly on the chart.
[*] Features integrated ATR volatility filters to eliminate insignificant structural noise.
[*] Fully optimized for high-performance rendering under Pine Script version 6 standards.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Pivot Channel TrendLines [BigBeluga]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

GRP_SETTINGS = "Pivot Settings"
length              = input.int(15, title="Pivot Lookback Length", minval=1, group=GRP_SETTINGS, tooltip="Number of bars before and after to confirm a high or low pivot.")
tendLineExtension   = input.int(70, title="Trendline Extension Length", minval=1, group=GRP_SETTINGS, tooltip="Distance in bars to project extension trendlines and check for breakouts.")
extStyleInput       = input.string("Dotted", title="Extension Line Style", options=["Dashed", "Dotted", "Solid"], group=GRP_SETTINGS, tooltip="Visual style for the extension trendlines.")

GRP_VISUALS  = "Colors & Style Settings"
phColor             = input.color(color.blue, title="Pivot High Color", group=GRP_VISUALS, tooltip="Color for upper trendlines, labels, and high price dashes.")
plColor             = input.color(color.lime, title="Pivot Low Color", group=GRP_VISUALS, tooltip="Color for lower trendlines, labels, and low price dashes.")

GRP_DASHES   = "Last Pivot Price Dash Settings"
showLastPivotDashes = input.bool(true, title="Show Last Pivot Price", group=GRP_DASHES, tooltip="Display horizontal dashed lines and price labels for the latest high and low pivots.")
dashStyleInput      = input.string("Dashed", title="Line Style", options=["Dashed", "Dotted", "Solid"], group=GRP_DASHES, tooltip="Visual style for the pivot price dashes.")

GRP_SIGNALS  = "Direction Label Settings"
showDirLabels       = input.bool(true, title="Show Direction Labels", group=GRP_SIGNALS, tooltip="Display 'Up' / 'Down' labels when price breaks active extension trendlines.")

// Line Style Parsing
dashStyle = dashStyleInput == "Dashed" ? line.style_dashed : dashStyleInput == "Dotted" ? line.style_dotted : line.style_solid
extStyle  = extStyleInput == "Dashed" ? line.style_dashed : extStyleInput == "Dotted" ? line.style_dotted : line.style_solid

// }
// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

ph = ta.pivothigh(length, length)
pl = ta.pivotlow(length, length)

var float phVal = 0.0 
var int phIndx  = 1

var float plVal = 0.0 
var int plIndx  = 1

atr = ta.atr(200)

// Active extension line parameters
var int upperStartBar  = na
var float upperStartY  = na
var float upperSlope   = na
var bool upperActive   = false

var int lowerStartBar  = na
var float lowerStartY  = na
var float lowerSlope   = na
var bool lowerActive   = false

// Direction handle
var label labelDirect = na

// Pivot Dash handles
var line phDashLine   = na
var label phDashLabel = na
var line plDashLine   = na
var label plDashLabel = na

// Pivot High Logic
if not na(ph)
    line.new(phIndx, phVal, bar_index[length], ph, width = 2, color = phColor)

    val = (ph - phVal) / (bar_index[length] - phIndx)

    label.new(bar_index[length], ph, style = label.style_circle, size = size.tiny, color = color.new(phColor, 50))

    if ph < phVal and (phVal - ph) >= atr
        line.new(bar_index[length], ph, bar_index[length] + tendLineExtension, ph + val * tendLineExtension, style = extStyle, color = phColor)
        
        upperStartBar := bar_index[length]
        upperStartY   := ph
        upperSlope    := val
        upperActive   := true

    phVal  := ph 
    phIndx := bar_index[length]

    if showLastPivotDashes
        line.delete(phDashLine)
        label.delete(phDashLabel)
        phDashLine  := line.new(bar_index[length], ph, bar_index, ph, style = dashStyle, color = phColor, width = 1)
        phDashLabel := label.new(bar_index, ph, text = str.tostring(ph, "#.##"), style = label.style_label_left, color = phColor, textcolor = color.white, size = size.small)

// Pivot Low Logic
if not na(pl)
    line.new(plIndx, plVal, bar_index[length], pl, color = plColor, width = 2)

    val = (pl - plVal) / (bar_index[length] - plIndx)

    label.new(bar_index[length], pl, style = label.style_circle, size = size.tiny, color = color.new(plColor, 50))

    if plVal < pl and (pl - plVal) >= atr
        line.new(bar_index[length], pl, bar_index[length] + tendLineExtension, pl + val * tendLineExtension, style = extStyle, color = plColor)
        
        lowerStartBar := bar_index[length]
        lowerStartY   := pl
        lowerSlope    := val
        lowerActive   := true

    plVal  := pl 
    plIndx := bar_index[length]

    if showLastPivotDashes
        line.delete(plDashLine)
        label.delete(plDashLabel)
        plDashLine  := line.new(bar_index[length], pl, bar_index, pl, style = dashStyle, color = plColor, width = 1)
        plDashLabel := label.new(bar_index, pl, text = str.tostring(pl, "#.##"), style = label.style_label_left, color = plColor, textcolor = color.white, size = size.small)

// Directional Breakout Engine
if showDirLabels
    if upperActive
        int barsPassedUpper = bar_index - upperStartBar
        
        if barsPassedUpper <= tendLineExtension and barsPassedUpper >= 0
            float expectedUpperPrice = upperStartY + upperSlope * barsPassedUpper
            
            if close > expectedUpperPrice and barstate.isconfirmed
                label.delete(labelDirect)
                labelDirect := label.new(bar_index, low, "Up", style = label.style_label_up, color = phColor, textcolor = color.white, size = size.small)
                upperActive := false

        else if barsPassedUpper > tendLineExtension
            upperActive := false

    if lowerActive
        int barsPassedLower = bar_index - lowerStartBar
        
        if barsPassedLower <= tendLineExtension and barsPassedLower >= 0
            float expectedLowerPrice = lowerStartY + lowerSlope * barsPassedLower
            
            if close < expectedLowerPrice and barstate.isconfirmed
                label.delete(labelDirect)
                labelDirect := label.new(bar_index, high, "Down", style = label.style_label_down, color = plColor, textcolor = color.white, size = size.small)
                lowerActive := false
        else if barsPassedLower > tendLineExtension
            lowerActive := false

// }
// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

if showLastPivotDashes and barstate.islast
    if not na(phDashLine)
        line.set_x2(phDashLine, bar_index)
        label.set_x(phDashLabel, bar_index)
    if not na(plDashLine)
        line.set_x2(plDashLine, bar_index)
        label.set_x(plDashLabel, bar_index)

// }
````
