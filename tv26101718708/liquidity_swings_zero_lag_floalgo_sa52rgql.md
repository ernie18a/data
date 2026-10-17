# Liquidity Swings [ Zero Lag ] - FloAlgo

- url: https://www.tradingview.com/script/SA52Rgql-Liquidity-Swings-Zero-Lag-FloAlgo/
- type: indicator
- pine_id: PUB;ae3bcd7bfa154873bb1727b4a22c9b70
- version: 1.0

## Description

This indicator identifies and tracks liquidity pools at swing highs and lows — a key Smart Money Concepts tool for visualizing institutional order flow and potential reversal zones.

[b]How It Works[/b]
The script operates in three stages:

[list]
[*]Pivot Detection — Confirmed swing highs and lows are identified using a lookback period, establishing the outer boundaries of resting liquidity pools.
[*]Zone Tracking — For each pivot, the script counts how many subsequent bars trade through the liquidity zone (wick tip to body edge) and accumulates the total volume of those touches, revealing market interest at each level.
[*]Cross Event — When price closes beyond a pivot's extreme, the level is marked as "consumed" — liquidity has been taken and the level becomes a dashed historical reference rather than an active trading zone.
[/list]

[b]Visual Elements[/b]

[list]
[*]Solid horizontal lines extending from pivot levels to current price
[*]Semi-transparent zone boxes spanning from wick tip to body edge
[*]Dashed lines marking levels where liquidity has been consumed
[*]Volume/count labels pinned at pivot bars showing accumulated activity
[*]Color-coded zones: red for supply (highs), green for demand (lows)
[/list]

[b]Key Settings[/b]

[list]
[*]Pivot Lookback — Sensitivity of pivot high/low detection
[*]Swing Area — Zone definition: Wick Tip to body edge, or Full Range (wick to opposite wick)
[*]Filter Areas By — Display threshold metric: Count (number of touches) or Volume (total volume)
[*]Filter Value — Minimum threshold — zones only appear when activity exceeds this value
[*]Swing High/Low — Toggle visibility of supply or demand zones
[*]Label Size — Size of volume/count labels displayed on chart
[/list]

## Source Code

````pine
// © FloAlgo
//@version=6
indicator("Liquidity Swings [FloAlgo]", "FloAlgo - Liq Swings", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

length = input.int(14, "Pivot Lookback", minval=2, group="Structure")
area   = input.string("Wick Tip", "Swing Area", options=["Wick Tip","Full Range"], group="Structure")

filterBy  = input.string("Count", "Filter Areas By", options=["Count","Volume"], inline="filter", group="Structure")
filterVal = input.float(0, "", inline="filter", group="Structure")

showTop    = input.bool(true,                    "Swing High",  inline="top", group="Style")
topCss     = input.color(#e74c3c,                 "",            inline="top", group="Style")
topAreaCss = input.color(color.new(#e74c3c, 50), "Area",        inline="top", group="Style")

showBtm    = input.bool(true,                    "Swing Low",   inline="btm", group="Style")
btmCss     = input.color(#00b894,                 "",            inline="btm", group="Style")
btmAreaCss = input.color(color.new(#00b894, 50), "Area",        inline="btm", group="Style")

lblSize = input.string("Tiny", "Label Size", options=["Tiny","Small","Normal"], group="Style")

n = bar_index

getSz() =>
    switch lblSize
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        =>          size.tiny

getCounts(bool condition, float top, float btm) =>
    var int   count = 0
    var float vol   = 0.0
    if condition
        count := 0
        vol   := 0.0
    else
        inRange = low[length] < top and high[length] > btm
        count  += inRange ? 1 : 0
        vol    += inRange ? volume[length] : 0.0
    [count, vol]

getTarget(int count, float vol) =>
    filterBy == "Count" ? count : vol

setZone(bool condition, int x, float top, float btm, int count, float vol, color css) =>
    var box bx = na
    tgt = getTarget(count, vol)
    if ta.crossover(tgt, filterVal)
        bx := box.new(x, top, x + count, btm, border_color=color(na), bgcolor=css)
    if tgt > filterVal
        bx.set_right(x + count)

setLevel(bool condition, bool crossed, float value, int count, float vol, color css) =>
    var line lvl = na
    var line prev_lvl = na
    tgt = getTarget(count, vol)
    if condition
        if tgt[1] < filterVal[1] and not na(prev_lvl)
            prev_lvl.delete()
        else if not crossed[1] and not na(prev_lvl)
            prev_lvl.set_x2(n - length)
        prev_lvl := lvl
        lvl := line.new(n - length, value, n, value, color=color(na))
    if not crossed[1]
        lvl.set_x2(n + 3)
    if crossed and not crossed[1]
        lvl.set_x2(n)
        lvl.set_style(line.style_dashed)
    if tgt > filterVal
        lvl.set_color(css)

setLabel(int count, float vol, int x, float y, color css, string lbl_style) =>
    var label lbl = na
    tgt = getTarget(count, vol)
    if ta.crossover(tgt, filterVal)
        lbl := label.new(x, y, str.tostring(vol, format.volume),
                  style=lbl_style, size=getSz(), color=#00000000, textcolor=css)
    if tgt > filterVal
        lbl.set_text(str.tostring(vol, format.volume))

var float ph_top     = na
var float ph_btm     = na
var bool  ph_crossed = false
var int   ph_x1      = 0
var box   ph_bx      = box.new(na, na, na, na,
              bgcolor=color.new(topAreaCss, 80), border_color=color(na))

var float pl_top     = na
var float pl_btm     = na
var bool  pl_crossed = false
var int   pl_x1      = 0
var box   pl_bx      = box.new(na, na, na, na,
              bgcolor=color.new(btmAreaCss, 80), border_color=color(na))

ph = ta.pivothigh(high, length, length)

[ph_count, ph_vol] = getCounts(not na(ph), ph_top, ph_btm)

if not na(ph) and showTop
    ph_top     := high[length]
    ph_btm     := area == "Wick Tip" ? math.max(close[length], open[length]) : low[length]
    ph_x1      := n - length
    ph_crossed := false
    ph_bx.set_lefttop(ph_x1, ph_top)
    ph_bx.set_rightbottom(ph_x1, ph_btm)
else
    ph_crossed := close > ph_top ? true : ph_crossed
    ph_bx.set_right(ph_crossed ? ph_x1 : n + 3)

if showTop
    setZone (not na(ph), ph_x1, ph_top, ph_btm, ph_count, ph_vol, topAreaCss)
    setLevel(not na(ph), ph_crossed, ph_top, ph_count, ph_vol, topCss)
    setLabel(ph_count, ph_vol, ph_x1, ph_top, topCss, label.style_label_down)

pl = ta.pivotlow(low, length, length)

[pl_count, pl_vol] = getCounts(not na(pl), pl_top, pl_btm)

if not na(pl) and showBtm
    pl_top     := area == "Wick Tip" ? math.min(close[length], open[length]) : high[length]
    pl_btm     := low[length]
    pl_x1      := n - length
    pl_crossed := false
    pl_bx.set_lefttop(pl_x1, pl_top)
    pl_bx.set_rightbottom(pl_x1, pl_btm)
else
    pl_crossed := close < pl_btm ? true : pl_crossed
    pl_bx.set_right(pl_crossed ? pl_x1 : n + 3)

if showBtm
    setZone (not na(pl), pl_x1, pl_top, pl_btm, pl_count, pl_vol, btmAreaCss)
    setLevel(not na(pl), pl_crossed, pl_btm, pl_count, pl_vol, btmCss)
    setLabel(pl_count, pl_vol, pl_x1, pl_btm, btmCss, label.style_label_up)

alertcondition(not ph_crossed[1] and ph_crossed, "FloAlgo — High Crossed", "FloAlgo: Price crossed above swing high liquidity")
alertcondition(not pl_crossed[1] and pl_crossed, "FloAlgo — Low Crossed",  "FloAlgo: Price crossed below swing low liquidity")
````
