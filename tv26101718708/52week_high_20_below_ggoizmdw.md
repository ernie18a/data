# 52-Week High & 20% Below

- url: https://www.tradingview.com/script/GgOIZMDW-52-Week-High-20-Below/
- type: indicator
- pine_id: PUB;09695972e226436e941160b2a4f33fd7
- version: 1.0

## Description

This indicator plots the rolling 52-week high along with a clear horizontal level 20% below that high.
The core idea behind this script:
For long-term investors who truly believe in a company’s fundamentals, a 20% drop from the 52-week high often represents a high-probability area to add to positions or start building a position.
This tool helps you visually identify those moments of temporary weakness in quality companies without getting caught up in short-term noise. It’s designed for patient, conviction-based investing — not for day trading or chasing momentum.
How to use it:

Watch for price approaching or touching the red 20% Below line on stocks you already like fundamentally.
Use it as a reference to scale into positions during pullbacks rather than trying to catch the absolute bottom.
Best used on daily charts for stocks, ETFs, or indices you intend to hold for years.

This is a simple visual aid to support a time-tested long-term investing approach: Buy quality companies when they go on sale.

## Source Code

````pine
//@version=6
indicator("52-Week High & 20% Below", shorttitle="52W High +20%Below", overlay=true, max_lines_count=500, max_labels_count=500)

// === INPUTS ===
len = input.int(252, "Lookback Length (bars ≈ 52 weeks)", minval=50, maxval=1000, step=1, group="Settings")
pctInput = input.float(20.0, "Percentage Below (%)", minval=1, maxval=90, step=0.5, group="Settings") / 100

showHigh   = input.bool(true, "Show 52-Week High Line", group="Visibility")
showBelow  = input.bool(true, "Show 20% Below Line", group="Visibility")
showFill   = input.bool(true, "Show Zone Fill Between Lines", group="Visibility")

colHigh    = input.color(color.new(#00C853, 0), "52W High Color", group="Colors")     // Green
colBelow   = input.color(color.new(#FF1744, 0), "20% Below Color", group="Colors")   // Red
colFill    = input.color(color.new(#FF9800, 85), "Zone Fill Color", group="Colors")  // Orange, semi-transparent

lwHigh     = input.int(2, "52W High Line Width", minval=1, maxval=5, group="Style")
lwBelow    = input.int(2, "20% Below Line Width", minval=1, maxval=5, group="Style")

// === CALCULATIONS ===
high52     = ta.highest(high, len)
belowLevel = high52 * (1 - pctInput)

// === PLOTS ===
pHigh = plot(showHigh ? high52 : na, 
     title="52-Week High", 
     color=colHigh, 
     linewidth=lwHigh, 
     style=plot.style_line)

pBelow = plot(showBelow ? belowLevel : na, 
     title="20% Below 52W High", 
     color=colBelow, 
     linewidth=lwBelow, 
     style=plot.style_line)

// Fill between the two lines (highlights the zone clearly)
fill(pHigh, pBelow, color=colFill, title="20% Below Zone")

// === CURRENT VALUE LABELS (last bar only) ===
var label lblHigh  = na
var label lblBelow = na

if barstate.islast
    label.delete(lblHigh)
    label.delete(lblBelow)
    
    if showHigh
        lblHigh := label.new(bar_index, high52, 
             "52W High\n" + str.tostring(high52, format.mintick), 
             color=colHigh, 
             textcolor=color.white, 
             style=label.style_label_left, 
             yloc=yloc.price, 
             size=size.normal)
    
    if showBelow
        lblBelow := label.new(bar_index, belowLevel, 
             str.tostring(pctInput * 100, "#.##") + "% Below\n" + str.tostring(belowLevel, format.mintick), 
             color=colBelow, 
             textcolor=color.white, 
             style=label.style_label_left, 
             yloc=yloc.price, 
             size=size.normal)
````
