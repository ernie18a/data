# Goldbach Pivots

- url: https://www.tradingview.com/script/ilEsqrpw-Goldbach-Pivots/
- type: indicator
- pine_id: PUB;0883d781837c4cd1a92ebad7ee2c9998
- version: 3.0

## Description

**Goldbach Pivots**

Based on Goldbach Price Levels as developed by Hopiplaka.  Plots horizontal price levels derived from powers of 3 (3, 9, 27, 81, 243, 729, 2187, 6561, 19683, 59049, 177147), calculated as `floor(close/X)*X` for each enabled divisor — creating a nested grid of "Dealing Ranges" (DRs) that traders using Goldbach/ICT-style methodology use to frame price action.

**Key features:**
- **Multiple independent DRs** — enable any combination of the eleven power-of-3 divisors simultaneously, each with its own color, line style (solid/dashed/dotted), and width
- **Configurable range** — set how many DR levels plot above and below current price via the iterations input
- **Percent sub-levels** — optional 11%, 17%, 50%, 83%, and 89% intermediate lines within each DR, each independently toggleable and styleable
- **Custom percent level** — define any percentage (with optional mirroring to the complementary level on the opposite side of the range) for levels outside the standard set
- **Stop Run lines** — per-DR toggle that plots short dotted lines a configurable distance inside the DR boundary, marking potential liquidity-run zones
- **Overlap priority rendering** — smaller DRs draw on top of larger ones so nested structure stays visually clear

All levels recalculate live off the current close and redraw on the last bar, keeping the grid aligned with price in real time.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────
//  v1.4 — 2026-08-25 — per-DR Infinite toggle, length/thickness
//  controls, labeled inputs, consistent 2-row DR layout
// ─────────────────────────────────────────────────────────────
indicator("Goldbach Pivots", overlay=true, max_lines_count=500)

// ═══════════════════════════════════════════════════════════
//  DEALING RANGES — col order: on | DR label | style | width | length | infinite | stop run
// ═══════════════════════════════════════════════════════════
use_3      = input.bool(true, "On",        group="Goldbach Dealing Range (DR)", inline="3a")
col_3      = input.color(color.black,  "3",      group="Goldbach Dealing Range (DR)", inline="3a")
sty_3      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="3a")
wid_3      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="3a")
len_3      = input.int(50, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="3b")
inf_3      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="3b")
sr_3       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="3b")

use_9      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="9a")
col_9      = input.color(color.blue,  "9",      group="Goldbach Dealing Range (DR)", inline="9a")
sty_9      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="9a")
wid_9      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="9a")
len_9      = input.int(75, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="9b")
inf_9      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="9b")
sr_9       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="9b")

use_27      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="27a")
col_27      = input.color(color.purple,  "27",      group="Goldbach Dealing Range (DR)", inline="27a")
sty_27      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="27a")
wid_27      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="27a")
len_27      = input.int(100, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="27b")
inf_27      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="27b")
sr_27       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="27b")

use_81      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="81a")
col_81      = input.color(color.teal,  "81",      group="Goldbach Dealing Range (DR)", inline="81a")
sty_81      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="81a")
wid_81      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="81a")
len_81      = input.int(150, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="81b")
inf_81      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="81b")
sr_81       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="81b")

use_243      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="243a")
col_243      = input.color(color.green,  "243",      group="Goldbach Dealing Range (DR)", inline="243a")
sty_243      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="243a")
wid_243      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="243a")
len_243      = input.int(200, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="243b")
inf_243      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="243b")
sr_243       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="243b")

use_729      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="729a")
col_729      = input.color(color.lime,  "729",      group="Goldbach Dealing Range (DR)", inline="729a")
sty_729      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="729a")
wid_729      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="729a")
len_729      = input.int(300, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="729b")
inf_729      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="729b")
sr_729       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="729b")

use_2187      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="2187a")
col_2187      = input.color(color.yellow,  "2187",      group="Goldbach Dealing Range (DR)", inline="2187a")
sty_2187      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="2187a")
wid_2187      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="2187a")
len_2187      = input.int(400, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="2187b")
inf_2187      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="2187b")
sr_2187       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="2187b")

use_6561      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="6561a")
col_6561      = input.color(color.orange,  "6561",      group="Goldbach Dealing Range (DR)", inline="6561a")
sty_6561      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="6561a")
wid_6561      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="6561a")
len_6561      = input.int(500, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="6561b")
inf_6561      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="6561b")
sr_6561       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="6561b")

use_19683      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="19683a")
col_19683      = input.color(color.red,  "19683",      group="Goldbach Dealing Range (DR)", inline="19683a")
sty_19683      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="19683a")
wid_19683      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="19683a")
len_19683      = input.int(600, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="19683b")
inf_19683      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="19683b")
sr_19683       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="19683b")

use_59049      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="59049a")
col_59049      = input.color(color.maroon,  "59049",      group="Goldbach Dealing Range (DR)", inline="59049a")
sty_59049      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="59049a")
wid_59049      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="59049a")
len_59049      = input.int(750, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="59049b")
inf_59049      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="59049b")
sr_59049       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="59049b")

use_177147      = input.bool(false, "On",        group="Goldbach Dealing Range (DR)", inline="177147a")
col_177147      = input.color(color.white,  "177147",      group="Goldbach Dealing Range (DR)", inline="177147a")
sty_177147      = input.string("Solid", "Style", options=["Solid","Dashed","Dotted"], group="Goldbach Dealing Range (DR)", inline="177147a")
wid_177147      = input.int(1, "Width", minval=1, maxval=10, group="Goldbach Dealing Range (DR)", inline="177147a")
len_177147      = input.int(900, "Length", minval=5, maxval=3000, group="Goldbach Dealing Range (DR)", inline="177147b")
inf_177147      = input.bool(false, "Infinite", group="Goldbach Dealing Range (DR)", inline="177147b")
sr_177147       = input.bool(false, "Stop Run", group="Goldbach Dealing Range (DR)", inline="177147b")

// ═══════════════════════════════════════════════════════════
//  DR LINES — iterations
// ═══════════════════════════════════════════════════════════
iterations = input.int(5, "DRs Above & Below", minval=1, group="DR Lines")

// ═══════════════════════════════════════════════════════════
//  STOP RUN — distance
// ═══════════════════════════════════════════════════════════
ext_dist  = input.int(27, "Stop Run Distance (points)", minval=1, group="Stop Run")
sr_width  = input.int(1,  "Stop Run Line Width", minval=1, maxval=10, group="Stop Run")

// ═══════════════════════════════════════════════════════════
//  PERCENT LINES — col order: on | label | style | width
// ═══════════════════════════════════════════════════════════
show_50    = input.bool(false, "On",           group="Percent Lines", inline="p50")
col_50     = input.color(color.red,    "50%",      group="Percent Lines", inline="p50")
style_50   = input.string("Dashed",    "Style",    options=["Solid","Dashed","Dotted"], group="Percent Lines", inline="p50")
width_50   = input.int(1, "Width",       minval=1, maxval=10, group="Percent Lines", inline="p50")

show_11    = input.bool(false, "On",           group="Percent Lines", inline="p11")
col_11     = input.color(color.orange, "11%",      group="Percent Lines", inline="p11")
style_11   = input.string("Dashed",    "Style",    options=["Solid","Dashed","Dotted"], group="Percent Lines", inline="p11")
width_11   = input.int(1, "Width",       minval=1, maxval=10, group="Percent Lines", inline="p11")

show_89    = input.bool(false, "On",           group="Percent Lines", inline="p89")
col_89     = input.color(color.orange, "89%",      group="Percent Lines", inline="p89")
style_89   = input.string("Dashed",    "Style",    options=["Solid","Dashed","Dotted"], group="Percent Lines", inline="p89")
width_89   = input.int(1, "Width",       minval=1, maxval=10, group="Percent Lines", inline="p89")

show_17    = input.bool(false, "On",           group="Percent Lines", inline="p17")
col_17     = input.color(color.yellow, "17%",      group="Percent Lines", inline="p17")
style_17   = input.string("Dashed",    "Style",    options=["Solid","Dashed","Dotted"], group="Percent Lines", inline="p17")
width_17   = input.int(1, "Width",       minval=1, maxval=10, group="Percent Lines", inline="p17")

show_83    = input.bool(false, "On",           group="Percent Lines", inline="p83")
col_83     = input.color(color.yellow, "83%",      group="Percent Lines", inline="p83")
style_83   = input.string("Dashed",    "Style",    options=["Solid","Dashed","Dotted"], group="Percent Lines", inline="p83")
width_83   = input.int(1, "Width",       minval=1, maxval=10, group="Percent Lines", inline="p83")

// ═══════════════════════════════════════════════════════════
//  CUSTOM PERCENT LEVEL
// ═══════════════════════════════════════════════════════════
show_custom   = input.bool(false,       "On",        group="Custom Percent Level", inline="pc")
col_custom    = input.color(color.teal, "Custom %",  group="Custom Percent Level", inline="pc")
style_custom  = input.string("Dotted",  "Style",     options=["Solid","Dashed","Dotted"], group="Custom Percent Level", inline="pc")
width_custom  = input.int(1, "Width",   minval=1, maxval=10, group="Custom Percent Level", inline="pc")
mirror_custom = input.bool(true, "Mirror — also draws (100 - X)% on the opposite side of the range", group="Custom Percent Level")
custom_pct    = input.float(33.0, "Percent (%)", minval=0.01, maxval=99.99, group="Custom Percent Level")

// ═══════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════
getStyle(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

getExtend(useInf) =>
    useInf ? extend.both : extend.none

drawLine(lvl, col, sty, wid, length, useInf) =>
    line.new(
         x1     = bar_index - length,
         y1     = lvl,
         x2     = bar_index + length,
         y2     = lvl,
         xloc   = xloc.bar_index,
         extend = getExtend(useInf),
         color  = col,
         style  = getStyle(sty),
         width  = wid)

// ═══════════════════════════════════════════════════════════
//  STOP RUN EXTENSION LOGIC
// ═══════════════════════════════════════════════════════════
drawExtensions(x, drCol, length, useInf) =>
    baseLevel    = math.floor(close / x) * x
    nearestBelow = baseLevel
    nearestAbove = baseLevel + x
    if close > nearestBelow and close < nearestAbove
        line.new(
             x1     = bar_index - length,
             y1     = nearestBelow + ext_dist,
             x2     = bar_index + length,
             y2     = nearestBelow + ext_dist,
             xloc   = xloc.bar_index,
             extend = getExtend(useInf),
             color  = drCol,
             style  = line.style_dotted,
             width  = sr_width)
        line.new(
             x1     = bar_index - length,
             y1     = nearestAbove - ext_dist,
             x2     = bar_index + length,
             y2     = nearestAbove - ext_dist,
             xloc   = xloc.bar_index,
             extend = getExtend(useInf),
             color  = drCol,
             style  = line.style_dotted,
             width  = sr_width)

// ═══════════════════════════════════════════════════════════
//  DRAW ALL LEVELS FOR ONE DIVISOR
// ═══════════════════════════════════════════════════════════
drawLevels(x, drCol, drSty, drWid, length, useInf) =>
    baseLevel = math.floor(close / x) * x
    for i = -iterations to iterations
        mainLevel = baseLevel + i * x
        line.new(
             x1     = bar_index - length,
             y1     = mainLevel,
             x2     = bar_index + length,
             y2     = mainLevel,
             xloc   = xloc.bar_index,
             extend = getExtend(useInf),
             color  = drCol,
             style  = getStyle(drSty),
             width  = drWid)
        if show_50
            drawLine(mainLevel + x * 0.50, col_50, style_50, width_50, length, useInf)
        if show_11
            drawLine(mainLevel + x * 0.11, col_11, style_11, width_11, length, useInf)
        if show_89
            drawLine(mainLevel + x * 0.89, col_89, style_89, width_89, length, useInf)
        if show_17
            drawLine(mainLevel + x * 0.17, col_17, style_17, width_17, length, useInf)
        if show_83
            drawLine(mainLevel + x * 0.83, col_83, style_83, width_83, length, useInf)
        if show_custom
            drawLine(mainLevel + x * (custom_pct / 100), col_custom, style_custom, width_custom, length, useInf)
            if mirror_custom
                drawLine(mainLevel + x * (1.0 - custom_pct / 100), col_custom, style_custom, width_custom, length, useInf)

// ═══════════════════════════════════════════════════════════
//  MAIN — lowest DR first, highest last (overlap priority)
// ═══════════════════════════════════════════════════════════
if barstate.islast
    if use_3
        drawLevels(3,      col_3,      sty_3,      wid_3,      len_3,      inf_3)
    if use_9
        drawLevels(9,      col_9,      sty_9,      wid_9,      len_9,      inf_9)
    if use_27
        drawLevels(27,     col_27,     sty_27,     wid_27,     len_27,     inf_27)
    if use_81
        drawLevels(81,     col_81,     sty_81,     wid_81,     len_81,     inf_81)
    if use_243
        drawLevels(243,    col_243,    sty_243,    wid_243,    len_243,    inf_243)
    if use_729
        drawLevels(729,    col_729,    sty_729,    wid_729,    len_729,    inf_729)
    if use_2187
        drawLevels(2187,   col_2187,   sty_2187,   wid_2187,   len_2187,   inf_2187)
    if use_6561
        drawLevels(6561,   col_6561,   sty_6561,   wid_6561,   len_6561,   inf_6561)
    if use_19683
        drawLevels(19683,  col_19683,  sty_19683,  wid_19683,  len_19683,  inf_19683)
    if use_59049
        drawLevels(59049,  col_59049,  sty_59049,  wid_59049,  len_59049,  inf_59049)
    if use_177147
        drawLevels(177147, col_177147, sty_177147, wid_177147, len_177147, inf_177147)

    if use_3      and sr_3
        drawExtensions(3,      col_3,      len_3,      inf_3)
    if use_9      and sr_9
        drawExtensions(9,      col_9,      len_9,      inf_9)
    if use_27     and sr_27
        drawExtensions(27,     col_27,     len_27,     inf_27)
    if use_81     and sr_81
        drawExtensions(81,     col_81,     len_81,     inf_81)
    if use_243    and sr_243
        drawExtensions(243,    col_243,    len_243,    inf_243)
    if use_729    and sr_729
        drawExtensions(729,    col_729,    len_729,    inf_729)
    if use_2187   and sr_2187
        drawExtensions(2187,   col_2187,   len_2187,   inf_2187)
    if use_6561   and sr_6561
        drawExtensions(6561,   col_6561,   len_6561,   inf_6561)
    if use_19683  and sr_19683
        drawExtensions(19683,  col_19683,  len_19683,  inf_19683)
    if use_59049  and sr_59049
        drawExtensions(59049,  col_59049,  len_59049,  inf_59049)
    if use_177147 and sr_177147
        drawExtensions(177147, col_177147, len_177147, inf_177147)
````
