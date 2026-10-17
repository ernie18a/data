# SMC Order Blocks

- url: https://www.tradingview.com/script/LyNOPRgJ-SMC-Order-Blocks/
- type: indicator
- pine_id: PUB;e0040926d7d4412ab3531b67d6df54b9
- version: 1.0

## Description

This is clos script using OB's, time macros, and various market opens throughout the day.

## Source Code

````pine
//@version=6
indicator("SMC Order Blocks", overlay=true, max_lines_count=10, max_labels_count=10)

// ============================================================
// === SETTINGS
// ============================================================
ob_group          = "Order Blocks"
bull_ob_color     = input.color(color.new(color.green, 0), "OB+ Line Color",  group=ob_group)
bear_ob_color     = input.color(color.new(color.red,   0), "OB- Line Color",  group=ob_group)
ob_line_width     = input.int(2, "Line Width", minval=1, maxval=4,             group=ob_group)
ob_line_style_inp = input.string("Solid", "Line Style", options=["Solid","Dashed","Dotted"], group=ob_group)
lookback          = input.int(100, "Lookback Bars", minval=10, maxval=500,     group=ob_group)

lbl_group        = "Labels"
bull_ob_lbl_txt  = input.string("OB+", "Bullish OB Label", group=lbl_group)
bear_ob_lbl_txt  = input.string("OB-", "Bearish OB Label", group=lbl_group)

// ============================================================
// === HELPERS
// ============================================================
f_line_style(s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

f_tf_label() =>
    tf = timeframe.period
    tf == "1"   ? "1m"  : tf == "2"   ? "2m"  : tf == "3"   ? "3m"  :
     tf == "5"   ? "5m"  : tf == "10"  ? "10m" : tf == "15"  ? "15m" :
     tf == "30"  ? "30m" : tf == "45"  ? "45m" : tf == "60"  ? "1h"  :
     tf == "120" ? "2h"  : tf == "180" ? "3h"  : tf == "240" ? "4h"  :
     tf == "D"   ? "1D"  : tf == "W"   ? "1W"  : tf == "M"   ? "1M"  : tf

tf_label = f_tf_label()

// ============================================================
// === SCAN: highest up-close open (OB-) and lowest down-close open (OB+)
// ============================================================
var float bull1_open = na
var int   bull1_bar  = na
var float bear1_open = na
var int   bear1_bar  = na

if barstate.islast
    bull1_open := na
    bull1_bar  := na
    bear1_open := na
    bear1_bar  := na

    for i = 1 to lookback
        o = open[i]
        c = close[i]
        b = bar_index - i

        if c > o
            if na(bull1_open) or o > bull1_open
                bull1_open := o
                bull1_bar  := b

        if c < o
            if na(bear1_open) or o < bear1_open
                bear1_open := o
                bear1_bar  := b

// ============================================================
// === DRAW
// ============================================================
var line  ln_bear1 = na
var label lb_bear1 = na
var line  ln_bull1 = na
var label lb_bull1 = na

if barstate.islast
    if not na(ln_bear1)
        line.delete(ln_bear1)
    if not na(lb_bear1)
        label.delete(lb_bear1)
    if not na(ln_bull1)
        line.delete(ln_bull1)
    if not na(lb_bull1)
        label.delete(lb_bull1)

    right_bar = bar_index + 500

    // OB-
    if not na(bull1_open)
        ln_bear1 := line.new(
             x1=bull1_bar, y1=bull1_open,
             x2=bull1_bar + 1, y2=bull1_open,
             color=bear_ob_color, width=ob_line_width,
             style=f_line_style(ob_line_style_inp), extend=extend.right)
        lb_bear1 := label.new(
             x=right_bar, y=bull1_open,
             text=tf_label + " " + bear_ob_lbl_txt,
             color=color.new(bear_ob_color, 80), textcolor=bear_ob_color,
             style=label.style_label_left, size=size.small,
             xloc=xloc.bar_index)

    // OB+
    if not na(bear1_open)
        ln_bull1 := line.new(
             x1=bear1_bar, y1=bear1_open,
             x2=bear1_bar + 1, y2=bear1_open,
             color=bull_ob_color, width=ob_line_width,
             style=f_line_style(ob_line_style_inp), extend=extend.right)
        lb_bull1 := label.new(
             x=right_bar, y=bear1_open,
             text=tf_label + " " + bull_ob_lbl_txt,
             color=color.new(bull_ob_color, 80), textcolor=bull_ob_color,
             style=label.style_label_left, size=size.small,
             xloc=xloc.bar_index)
````
