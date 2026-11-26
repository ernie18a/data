# Multi-Timeframe SMA Wave

- url: https://www.tradingview.com/script/OEX8z3NK-Multi-Timeframe-SMA-Wave/
- type: indicator
- pine_id: PUB;cb202c7b8e124a549d3897ac3d62cc37
- version: 1.0

## Description

This is a powerful multi-timeframe Simple Moving Average (SMA) visualizer that plots up to 28 different timeframes of the same SMA length simultaneously on your current chart.Instead of looking at one SMA on one timeframe, you see a "wave" or "fan" of SMAs from very fast (1-second) all the way to very slow (1-month). This creates a visual hierarchy of trend strength across different scales.

Key Features: 28 Timeframes covered: 1S, 5S, 10S, 15S, 30S, 1m, 2m, 3m, 5m, 10m, 15m, 20m, 30m, 45m, 60m, 90m, 120m, 180m, 240m, 360m, 480m, 720m, 1D, 2D, 3D, 1W, 2W, 1M.
Color-coded lines with increasing thickness on important timeframes (e.g., 5m is thicker).
Dynamic labels on the right side showing which line belongs to which timeframe (updates on the last bar).
Fill zones between certain groups (1-3m and 60-120m) for visual emphasis.
Info table in top-right showing SMA length and number of timeframes.
Uses request.security() with proper gaps/lookahead settings for clean data.

Trading Interpretation TipsBullish Setup: Price above most SMAs + wave sloping upward + fast TFs above slow TFs.

Bearish Setup: Price below most SMAs + wave sloping downward + fast TFs below slow TFs.

Compression / Breakout Setup: When the "wave" squeezes tightly together → often precedes strong moves.

Divergence: If price makes new highs but the higher-timeframe SMAs are flattening/turning down → warning sign.

Customization IdeasChange SMA len (default 5) — smaller = more reactive, larger = smoother.
Enable/disable fill zones.
Add more plots if you need even more timeframes.
Modify colors and line thickness for better visibility.

Summary:
This indicator is excellent for traders who use multi-timeframe analysis but hate switching between charts. It condenses a huge amount of information into one clean visual "wave," making it much easier to see alignment (or lack thereof) across timeframes. Very useful for day traders, swing traders, and discretionary price action traders who want contextual awareness.

## Source Code

````pine
//@version=6
indicator(title="Multi-Timeframe SMA Wave", shorttitle="SMA Wave full", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Inputs ──
len        = input.int(5, minval=1, title="SMA Length")
src        = input.source(close, title="Source")
showLabels = input.bool(true, title="Show Timeframe Labels")
labelOffset = input.int(10, minval=0, title="Label Offset (bars ahead)", tooltip="How many bars to the right of the current bar the labels appear")
fill1 = input.bool(true, "Fill group 1", group="group 1")
fillColor1 = input.color(color.new(#0963ea, 80), "Fill Pair 1-3m", group="group 1")

fill2 = input.bool(true, "Fill group 2", group="group 1")
fillColor2 = input.color(color.new(#0963ea, 80), "Fill Pair 60-120m", group="group 1")

// ── Timeframes ──
timeframes = array.from(
     "1S", "5S", "10S", "15S", "30S",
     "1",  "2",  "3",  "5",  "10", "15", "20", "30", "45",
     "60", "90", "120", "180", "240", "360", "480", "720",
     "1D", "2D", "3D", "1W", "2W", "1M"
)

// ── Calculate all SMAs ──
var float[] smaArray = array.new_float(array.size(timeframes), na)

for i = 0 to array.size(timeframes) - 1
    tf = array.get(timeframes, i)
    smaValue = request.security(syminfo.tickerid, tf, ta.sma(src, len)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    array.set(smaArray, i, smaValue)

// ── Colors ──
colors = array.from(color.white, color.orange, color.yellow, color.lime, color.aqua, 
                    color.rgb(55, 156, 239), color.fuchsia, color.purple, color.red)


// ── Persistent Labels Array ──
var label[] labelArray = array.new_label()

// Create labels once
if barstate.isfirst
    for i = 0 to array.size(timeframes) - 1
        newLabel = label.new(bar_index, na, "", 
                             color=color.new(color.white, 100), 
                             style=label.style_label_left, 
                             size=size.tiny)
        array.push(labelArray, newLabel)



// ── PLOTS (Global scope + completely static titles) ──
p1  = plot(array.get(smaArray, 0),  title="1s 01", color=array.get(colors, 0 % 9), linewidth=1)
p2  = plot(array.get(smaArray, 1),  title="5s 02", color=array.get(colors, 1 % 9), linewidth=1)
p3  = plot(array.get(smaArray, 2),  title="10s 03", color=array.get(colors, 2 % 9), linewidth=1)
p4  = plot(array.get(smaArray, 3),  title="15s 04", color=array.get(colors, 3 % 9), linewidth=1)
p5  = plot(array.get(smaArray, 4),  title="30s 05", color=array.get(colors, 4 % 9), linewidth=3)
p6  = plot(array.get(smaArray, 5),  title="1m 06", color=array.get(colors, 5 % 9), linewidth=1)
p7  = plot(array.get(smaArray, 6),  title="2m 07", color=array.get(colors, 6 % 9), linewidth=1)
p8  = plot(array.get(smaArray, 7),  title="3m 08", color=array.get(colors, 7 % 9), linewidth=2)
p9  = plot(array.get(smaArray, 8),  title="5m 09", color=array.get(colors, 8 % 9), linewidth=4)
p10 = plot(array.get(smaArray, 9),  title="10m 10", color=array.get(colors, 9 % 9), linewidth=1)
p11 = plot(array.get(smaArray, 10), title="15m 11", color=array.get(colors, 10 % 9), linewidth=1)
p12 = plot(array.get(smaArray, 11), title="20m 12", color=array.get(colors, 11 % 9), linewidth=1)
p13 = plot(array.get(smaArray, 12), title="30m 13", color=array.get(colors, 12 % 9), linewidth=1)
p14 = plot(array.get(smaArray, 13), title="45m 14", color=array.get(colors, 13 % 9), linewidth=1)
p15 = plot(array.get(smaArray, 14), title="60m 15", color=array.get(colors, 14 % 9), linewidth=1)
p16 = plot(array.get(smaArray, 15), title="90m 16", color=array.get(colors, 15 % 9), linewidth=1)
p17 = plot(array.get(smaArray, 16), title="120m 17", color=array.get(colors, 16 % 9), linewidth=1)
p18 = plot(array.get(smaArray, 17), title="180m 18", color=array.get(colors, 17 % 9), linewidth=1)
p19 = plot(array.get(smaArray, 18), title="240m 19", color=array.get(colors, 18 % 9), linewidth=1)
p20 = plot(array.get(smaArray, 19), title="360m 20", color=array.get(colors, 19 % 9), linewidth=1)
p21 = plot(array.get(smaArray, 20), title="480m 21", color=array.get(colors, 20 % 9), linewidth=1)
p22 = plot(array.get(smaArray, 21), title="720m 22", color=array.get(colors, 21 % 9), linewidth=1)
p23 = plot(array.get(smaArray, 22), title="1D 23", color=array.get(colors, 22 % 9), linewidth=1)
p24 = plot(array.get(smaArray, 23), title="2D 24", color=array.get(colors, 23 % 9), linewidth=1)
p25 = plot(array.get(smaArray, 24), title="3D 25", color=array.get(colors, 24 % 9), linewidth=1)
p26 = plot(array.get(smaArray, 25), title="1W 26", color=array.get(colors, 25 % 9), linewidth=1)
p27 = plot(array.get(smaArray, 26), title="2W 27", color=array.get(colors, 26 % 9), linewidth=1)
p28 = plot(array.get(smaArray, 27), title="1Mth 28", color=array.get(colors, 27 % 9), linewidth=1)

// Add more plots here if you want (up to ~60 total)

fill(p6, p7,  color = fill1 ? fillColor1 : na, title="Fill Pair 1-3m")
fill(p7, p8,  color = fill1 ? fillColor1 : na, title="Fill Pair 1-3m")

fill(p15, p16, color = fill2 ? fillColor2 : na, title="Fill Pair 60-120m")
fill(p16, p17, color = fill2 ? fillColor2 : na, title="Fill Pair 60-120m")

// ── Update Labels (no more stacking) ──
if showLabels and barstate.islast
    for i = 0 to array.size(timeframes) - 1
        tf     = array.get(timeframes, i)
        col    = array.get(colors, i % array.size(colors))
        smaVal = array.get(smaArray, i)
        lbl    = array.get(labelArray, i)
        
        label.set_xy(lbl, bar_index+ labelOffset, smaVal)
        label.set_text(lbl, tf)
        label.set_color(lbl, color.new(col, 70))
        label.set_textcolor(lbl, color.white)
        label.set_style(lbl, label.style_label_left)
        label.set_size(lbl, size.tiny)




// ── Info Table ──
var table info = table.new(position.top_right, 1, 3, bgcolor=color.new(color.black, 80))
if barstate.islast
    table.cell(info, 0, 0, "SMA Wave", text_color=color.white)
    table.cell(info, 0, 1, "Length: " + str.tostring(len), text_color=color.yellow)
    table.cell(info, 0, 2, "TFs: " + str.tostring(array.size(timeframes)), text_color=color.gray)
````
