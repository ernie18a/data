# FVG_SWG

- url: https://www.tradingview.com/script/BXhOTN0s/
- type: indicator
- pine_id: PUB;0ef52dddd1a540ce9e3eb4dda6f33294
- version: 2.0

## Description

FVG Liquidity & Gaps is a high-performance technical analysis tool built on the principles of Smart Money Concepts (SMC). This script integrates a dual-layer visualization system to track institutional order flow by identifying extreme liquidity zones (Swings) and price imbalances (Fair Value Gaps) in a single, unified panel.

The standout feature of this tool is its Dynamic Mitigation Engine, which physically resizes imbalance boxes as price interacts with them, providing a real-time view of remaining unfilled liquidity.

Key Features:
1. Liquidity Swings with Volume Analysis
Automatic Detection: Instantly identifies significant fractal highs and lows (Pivot High/Low).

Quantitative Insights: Each liquidity level includes a label displaying the Accumulated Volume or Touch Count within that zone. This helps traders distinguish between "weak" retail levels and "high-conviction" institutional walls.

Dynamic Projections: Liquidity lines remain solid while active and transition to a dashed style once the level is "purged" (swept), maintaining a clean structural history of the market.

2. Intelligent Fair Value Gaps (FVG)
Imbalance Visualization: Automatically detects and plots Bullish and Bearish Fair Value Gaps.

Mitigation Reduction (isFvgReduce): This "pro-level" feature automatically shrinks the FVG boxes as price fills the gap. If a wick enters 50% of an FVG, the box resizes to show only the remaining 50% that is yet to be mitigated.

Optimized Memory: Includes a history manager to limit the number of active gaps, ensuring the chart remains focused on the most relevant current action.

How to Trade with this Script:
Liquidity Sweeps (Stop Hunts): Monitor the Swing levels for potential sweeps. When price breaks a high-volume liquidity line and quickly rejects, it provides a high-probability reversal signal.

Order Block & Inefficiency Entry: Use the unfilled (or partially reduced) FVG boxes as targets or entry zones where the market is likely to seek balance.

Noise Filtering: Adjust the Filter Min Value to only display labels on liquidity levels that have seen significant trading activity—ideal for high-volatility assets like Nasdaq (NAS100), Gold (XAUUSD), or Crypto.

Technical Configuration:
Pivot Lookback: Define the sensitivity of market structure.

Swing Area: Choose between measuring only the mecha (Wick Extremity) or the Full Range for liquidity volume calculations.

Custom Aesthetics: Fully customizable colors to match any UI theme (Dark/Light modes).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ScalpWolfTrader


//@version=5
indicator("FVG_SWG", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ==========================================
// 1. CONFIGURACIÓN (INPUTS)
// ==========================================

// --- Liquidez (Swing Lines) ---
gp_liq      = "Liquidity Settings"
length      = input.int(5, 'Pivot Lookback', minval=1, group=gp_liq)
area        = input.string('Full Range', 'Swing Area', options = ['Wick Extremity', 'Full Range'], group=gp_liq)
filterOpt   = input.string('Count', 'Filter Areas By', options = ['Count', 'Volume'], group=gp_liq)
filterVal   = input.float(0, 'Filter Min Value', group=gp_liq)
showTop     = input(true, 'Show Swing High', inline='top', group=gp_liq)
topCss      = input.color(#ff5252, '', inline='top', group=gp_liq)
showBtm     = input(true, 'Show Swing Low', inline='btm', group=gp_liq)
btmCss      = input.color(#006064, '', inline='btm', group=gp_liq)
labelSize   = input.string('Tiny', 'Labels Size', options = ['Tiny', 'Small', 'Normal'], group=gp_liq)

// --- FVG (Fair Value Gaps) ---
gp_fvg      = "FVG Configuration"
isFvgShow   = input(true, "Display FVG", group=gp_fvg)
bullFvgColor = input.color(#0061641a, "Bullish FVG Color", group=gp_fvg)
bearFvgColor = input.color(#ff525219, "Bearish FVG Color", group=gp_fvg)
mitigFvgColor = input.color(#f57b001a, "Mitigated FVG Color", group=gp_fvg)
fvgHistory  = input.int(10, "Max Gaps on Chart", 1, 50, group=gp_fvg)
isFvgReduce = input(true, "Reduce Box on Mitig.", group=gp_fvg)

// ==========================================
// 2. FUNCIONES Y VARIABLES GLOBALES
// ==========================================

n = bar_index

get_counts(condition, top, btm) =>
    var count = 0
    var vol = 0.
    if condition
        count := 0
        vol := 0.
    else
        vol   += low[length] < top and high[length] > btm ? volume[length] : 0
        count += low[length] < top and high[length] > btm ? 1 : 0
    [count, vol]

set_label(count, vol, x, y, css, lbl_style) =>
    var label lbl = na
    l_size = labelSize == 'Tiny' ? size.tiny : labelSize == 'Small' ? size.small : size.normal
    target = filterOpt == 'Count' ? count : vol
    if ta.crossover(target, filterVal)
        lbl := label.new(x, y, str.tostring(vol, format.volume), style=lbl_style, size=l_size, color=#00000000, textcolor=css)
    if target > filterVal
        label.set_text(lbl, str.tostring(vol, format.volume))

set_level(condition, crossed, value, count, vol, css) =>
    var line lvl = na
    target = filterOpt == 'Count' ? count : vol
    if condition
        if target[1] < filterVal
            line.delete(lvl[1])
        else if not crossed[1]
            line.set_x2(lvl, n - length)
        lvl := line.new(n - length, value, n, value, color = na)
    if not crossed[1]
        line.set_x2(lvl, n+3)
    if crossed and not crossed[1]
        line.set_x2(lvl, n)
        line.set_style(lvl, line.style_dashed)
    if target > filterVal
        line.set_color(lvl, css)

// ==========================================
// 3. LÓGICA DE LIQUIDEZ (SWINGS)
// ==========================================

// --- Swing High ---
var float ph_top = na
var float ph_btm = na
var bool  ph_crossed = na
var int   ph_x1 = 0
ph = ta.pivothigh(length, length)
[ph_count, ph_vol] = get_counts(ph, ph_top, ph_btm)

if ph and showTop
    ph_top := high[length]
    ph_btm := area == 'Wick Extremity' ? math.max(close[length], open[length]) : low[length]
    ph_x1 := n - length
    ph_crossed := false
else
    ph_crossed := close > ph_top ? true : ph_crossed

if showTop
    set_level(ph, ph_crossed, ph_top, ph_count, ph_vol, topCss)
    set_label(ph_count, ph_vol, ph_x1, ph_top, topCss, label.style_label_down)

// --- Swing Low ---
var float pl_top = na
var float pl_btm = na
var bool  pl_crossed = na
var int   pl_x1 = 0
pl = ta.pivotlow(length, length)
[pl_count, pl_vol] = get_counts(pl, pl_top, pl_btm)

if pl and showBtm
    pl_top := area == 'Wick Extremity' ? math.min(close[length], open[length]) : high[length] 
    pl_btm := low[length]
    pl_x1 := n - length
    pl_crossed := false
else
    pl_crossed := close < pl_btm ? true : pl_crossed

if showBtm
    set_level(pl, pl_crossed, pl_btm, pl_count, pl_vol, btmCss)
    set_label(pl_count, pl_vol, pl_x1, pl_btm, btmCss, label.style_label_up)

// ==========================================
// 4. LÓGICA DE FVG (MODO MEMORIA)
// ==========================================

var array<box>   fvgBoxes  = array.new_box(0)
var array<bool>  fvgTypes  = array.new_bool(0) 
var array<label> fvgLabels = array.new_label(0)
var array<bool>  isMitig   = array.new_bool(0)

if isFvgShow
    // FVG ALCISTA (Bullish)
    if high[2] < low[0]
        // Izquierda: bar_index-2 | Techo: low[0] | Piso: high[2]
        _b = box.new(bar_index-2, low[0], bar_index, high[2], bgcolor=bullFvgColor, border_color=na)
        _l = label.new(bar_index-1, (low[0]+high[2])/2, "FVG", style=label.style_none, textcolor=#2e2e2e80, size=size.tiny)
        array.push(fvgBoxes, _b), array.push(fvgTypes, true), array.push(fvgLabels, _l), array.push(isMitig, false)
    
    // FVG BAJISTA (Bearish): El mínimo de hace 2 velas es mayor al máximo actual
    if low[2] > high[0]
        // Izquierda: bar_index-2 | Techo: low[2] | Piso: high[0]
        _b = box.new(bar_index-2, low[2], bar_index, high[0], bgcolor=bearFvgColor, border_color=na)
        _l = label.new(bar_index-1, (low[2]+high[0])/2, "FVG", style=label.style_none, textcolor=#2e2e2e80, size=size.tiny)
        array.push(fvgBoxes, _b), array.push(fvgTypes, false), array.push(fvgLabels, _l), array.push(isMitig, false)

    if array.size(fvgBoxes) > fvgHistory
        box.delete(array.remove(fvgBoxes, 0)), label.delete(array.remove(fvgLabels, 0)), array.remove(fvgTypes, 0), array.remove(isMitig, 0)

if array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        box   _thisBox   = array.get(fvgBoxes, i)
        label _thisLabel = array.get(fvgLabels, i)
        bool  _isBull    = array.get(fvgTypes, i)
        
        if _isBull
            if low <= box.get_bottom(_thisBox)
                box.delete(array.remove(fvgBoxes, i)), label.delete(array.remove(fvgLabels, i)), array.remove(fvgTypes, i), array.remove(isMitig, i)
            else
                if low < box.get_top(_thisBox)
                    box.set_bgcolor(_thisBox, mitigFvgColor)
                    if isFvgReduce
                        box.set_top(_thisBox, low)
                box.set_right(_thisBox, bar_index)
                label.set_xy(_thisLabel, (box.get_left(_thisBox) + bar_index)/2, (box.get_top(_thisBox) + box.get_bottom(_thisBox))/2)
        else
            if high >= box.get_top(_thisBox)
                box.delete(array.remove(fvgBoxes, i)), label.delete(array.remove(fvgLabels, i)), array.remove(fvgTypes, i), array.remove(isMitig, i)
            else
                if high > box.get_bottom(_thisBox)
                    box.set_bgcolor(_thisBox, mitigFvgColor)
                    if isFvgReduce
                        box.set_bottom(_thisBox, high)
                box.set_right(_thisBox, bar_index)
                label.set_xy(_thisLabel, (box.get_left(_thisBox) + bar_index)/2, (box.get_top(_thisBox) + box.get_bottom(_thisBox))/2)
````
