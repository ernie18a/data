# FADI EMA 

- url: https://www.tradingview.com/script/ytoYXDV9-FADI-EMA/
- type: indicator
- pine_id: PUB;45227be000bf4797b3b1c95ea7a14e8b
- version: 1.0

## Description

good EMA for small TFs ,  can be modified as you wish , very helpful

hope you enjoy it

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © your_username

//@version=6
indicator("FADI EMA ", overlay=true, max_lines_count=10, max_labels_count=10)

// ──────────────────────────────────────────
// BASELINE INPUTS
// ──────────────────────────────────────────
grp_base = "Baseline Settings"
maType    = input.string("HMA", title="Baseline Type", options=["HMA", "SMA", "EMA"], group=grp_base)
baseLen   = input.int(60, title="Baseline Length", group=grp_base)
baseSrc   = input.source(close, title="Baseline Source", group=grp_base)
baseColor = input.color(color.blue, title="Baseline Color", group=grp_base)

// ──────────────────────────────────────────
// BASELINE FUNCTION
// ──────────────────────────────────────────
ma(type, source, length) =>
    if type == "SMA"
        ta.sma(source, length)
    else if type == "EMA"
        ta.ema(source, length)
    else
        ta.wma(2 * ta.wma(source, math.round(length / 2)) - ta.wma(source, length), math.round(math.sqrt(length)))

// BASELINE CALCULATION
baseline = ma(maType, baseSrc, baseLen)

// PLOT BASELINE
plot(baseline, title="Baseline", color=baseColor, linewidth=3)


// ──────────────────────────────────────────
// EMA INPUTS
// ──────────────────────────────────────────
grp_ema = "EMA Settings"
len4  = input.int(165, "EMA 4 Length", minval=1, group=grp_ema)
len9  = input.int(330, "EMA 9 Length", minval=1, group=grp_ema)
len20 = input.int(660, "EMA 20 Length", minval=1, group=grp_ema)
len82 = input.int(2706, "EMA 82 Length", minval=1, group=grp_ema)
htf   = input.timeframe("5", "Higher Timeframe", group=grp_ema)


// ──────────────────────────────────────────
// EMA STYLE
// ──────────────────────────────────────────
grp_style = "EMA Style"
col4  = input.color(color.new(#F0B429, 0), "EMA 4 Color", group=grp_style)
col9  = input.color(color.new(#8B5CF6, 0), "EMA 9 Color", group=grp_style)
col20 = input.color(color.new(#26C6DA, 0), "EMA 20 Color", group=grp_style)
col82 = input.color(color.new(#EF4444, 0), "EMA 82 Color", group=grp_style)
lw    = input.int(2, "Line Width", minval=1, maxval=4, group=grp_style)


// ──────────────────────────────────────────
// LEVEL SETTINGS
// ──────────────────────────────────────────
grp_lvl = "Levels"
show_lvl   = input.bool(true, "Show Current Level Lines", group=grp_lvl)
show_lbl   = input.bool(true, "Show Value Labels", group=grp_lvl)
extend_lvl = input.bool(true, "Extend Levels Right", group=grp_lvl)


// ──────────────────────────────────────────
// EMA CALCULATIONS (NO REPAINT)
// ──────────────────────────────────────────
ema4_raw  = ta.ema(close, len4)
ema9_raw  = ta.ema(close, len9)
ema20_raw = ta.ema(close, len20)
ema82_raw = ta.ema(close, len82)

ema4  = request.security(syminfo.tickerid, htf, ema4_raw, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
ema9  = request.security(syminfo.tickerid, htf, ema9_raw, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
ema20 = request.security(syminfo.tickerid, htf, ema20_raw, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
ema82 = request.security(syminfo.tickerid, htf, ema82_raw, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)


// ──────────────────────────────────────────
// EMA PLOTS
// ──────────────────────────────────────────
plot(ema82, title="EMA 82 (5m)", color=col82, style=plot.style_stepline, linewidth=lw)
plot(ema20, title="EMA 20 (5m)", color=col20, style=plot.style_stepline, linewidth=lw)
plot(ema9, title="EMA 9 (5m)", color=col9, style=plot.style_stepline, linewidth=lw)
plot(ema4, title="EMA 4 (5m)", color=col4, style=plot.style_stepline, linewidth=lw)


// ──────────────────────────────────────────
// CROSSOVER SIGNALS
// ──────────────────────────────────────────
bullCross = ta.crossover(ema4, ema9)
bearCross = ta.crossunder(ema4, ema9)

bgcolor(bullCross ? color.new(#F0B429, 88) : na)
bgcolor(bearCross ? color.new(#8B5CF6, 88) : na)

plotshape(bullCross, title="Bull Cross", location=location.belowbar,
     style=shape.triangleup, color=color.new(#F0B429, 20), size=size.tiny)

plotshape(bearCross, title="Bear Cross", location=location.abovebar,
     style=shape.triangledown, color=color.new(#8B5CF6, 20), size=size.tiny)


// ──────────────────────────────────────────
// DYNAMIC LEVEL LINES & LABELS
// ──────────────────────────────────────────
var line line_ema4 = na
var line line_ema9 = na
var line line_ema20 = na
var line line_ema82 = na

var label lbl_ema4 = na
var label lbl_ema9 = na
var label lbl_ema20 = na
var label lbl_ema82 = na

if barstate.islast
    if show_lvl
        line.delete(line_ema4)
        line.delete(line_ema9)
        line.delete(line_ema20)
        line.delete(line_ema82)

        ext = extend_lvl ? extend.right : extend.none

        line_ema4 := line.new(bar_index - 30, ema4, bar_index, ema4, color=color.new(col4, 55), width=1, style=line.style_dashed, extend=ext)
        line_ema9 := line.new(bar_index - 30, ema9, bar_index, ema9, color=color.new(col9, 55), width=1, style=line.style_dashed, extend=ext)
        line_ema20 := line.new(bar_index - 30, ema20, bar_index, ema20, color=color.new(col20, 55), width=1, style=line.style_dashed, extend=ext)
        line_ema82 := line.new(bar_index - 30, ema82, bar_index, ema82, color=color.new(col82, 55), width=1, style=line.style_dashed, extend=ext)

    if show_lbl
        label.delete(lbl_ema4)
        label.delete(lbl_ema9)
        label.delete(lbl_ema20)
        label.delete(lbl_ema82)

        lbl_ema4 := label.new(bar_index + 2, ema4, "EMA4 " + str.tostring(ema4, format.mintick), color=color.new(color.black, 100), textcolor=col4, style=label.style_label_left, size=size.small)
        lbl_ema9 := label.new(bar_index + 2, ema9, "EMA9 " + str.tostring(ema9, format.mintick), color=color.new(color.black, 100), textcolor=col9, style=label.style_label_left, size=size.small)
        lbl_ema20 := label.new(bar_index + 2, ema20, "EMA20 " + str.tostring(ema20, format.mintick), color=color.new(color.black, 100), textcolor=col20, style=label.style_label_left, size=size.small)
        lbl_ema82 := label.new(bar_index + 2, ema82, "EMA82 " + str.tostring(ema82, format.mintick), color=color.new(color.black, 100), textcolor=col82, style=label.style_label_left, size=size.small)
````
