# Multi EMA + Pinned TF EMAs

- url: https://www.tradingview.com/script/vmq3BHLh-Multi-EMA-Pinned-TF-EMAs/
- type: indicator
- pine_id: PUB;592dcb8f9a644056bb494ea2fbbff716
- version: 3.0

## Description

Multi & Pinned TF EMAs so you don't have to switch timeframes

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Kevin's Multi EMA with Pinned Timeframe EMAs

//@version=5
indicator("Multi EMA + Pinned TF EMAs", overlay=true, max_lines_count=500)

// ─────────────────────────────────────────
// GROUP 1: Standard EMAs (current timeframe)
// ─────────────────────────────────────────
grp1 = "Standard EMAs (Current Timeframe)"

show_ema1 = input.bool(true,  "Show EMA 1", group=grp1, inline="e1")
ema1_len  = input.int(9,      "",           group=grp1, inline="e1", minval=1)
ema1_col  = input.color(color.new(#00E5FF, 0), "", group=grp1, inline="e1")

show_ema2 = input.bool(true,  "Show EMA 2", group=grp1, inline="e2")
ema2_len  = input.int(20,     "",           group=grp1, inline="e2", minval=1)
ema2_col  = input.color(color.new(#2196F3, 0), "", group=grp1, inline="e2")

show_ema3 = input.bool(true,  "Show EMA 3", group=grp1, inline="e3")
ema3_len  = input.int(50,     "",           group=grp1, inline="e3", minval=1)
ema3_col  = input.color(color.new(#FF9800, 0), "", group=grp1, inline="e3")

show_ema4 = input.bool(true,  "Show EMA 4", group=grp1, inline="e4")
ema4_len  = input.int(100,    "",           group=grp1, inline="e4", minval=1)
ema4_col  = input.color(color.new(#E040FB, 0), "", group=grp1, inline="e4")

show_ema5 = input.bool(true,  "Show EMA 5", group=grp1, inline="e5")
ema5_len  = input.int(150,    "",           group=grp1, inline="e5", minval=1)
ema5_col  = input.color(color.new(#FFEB3B, 0), "", group=grp1, inline="e5")

show_ema6 = input.bool(true,  "Show EMA 6", group=grp1, inline="e6")
ema6_len  = input.int(200,    "",           group=grp1, inline="e6", minval=1)
ema6_col  = input.color(color.new(#F44336, 0), "", group=grp1, inline="e6")

show_ema7 = input.bool(false, "Show EMA 7", group=grp1, inline="e7")
ema7_len  = input.int(250,    "",           group=grp1, inline="e7", minval=1)
ema7_col  = input.color(color.new(#69F0AE, 0), "", group=grp1, inline="e7")

show_ema8 = input.bool(false, "Show EMA 8", group=grp1, inline="e8")
ema8_len  = input.int(300,    "",           group=grp1, inline="e8", minval=1)
ema8_col  = input.color(color.new(#FF4081, 0), "", group=grp1, inline="e8")

// ─────────────────────────────────────────
// GROUP 2: Pinned TF EMAs
// ─────────────────────────────────────────
grp2 = "📌 Pinned Timeframe EMAs (Fixed TF)"

show_pin1        = input.bool(true,   "Pinned EMA 1",  group=grp2, inline="p1")
pin1_len         = input.int(200,     "",              group=grp2, inline="p1", minval=1)
pin1_tf          = input.timeframe("5", "",            group=grp2, inline="p1")
pin1_width       = input.int(2,       "",              group=grp2, inline="p1", minval=1, maxval=4)
pin1_style_input = input.string("Solid", "",           group=grp2, inline="p1", options=["Solid", "Dashed", "Dotted"])

show_pin2        = input.bool(false,  "Pinned EMA 2",  group=grp2, inline="p2")
pin2_len         = input.int(50,      "",              group=grp2, inline="p2", minval=1)
pin2_tf          = input.timeframe("15", "",           group=grp2, inline="p2")
pin2_width       = input.int(2,       "",              group=grp2, inline="p2", minval=1, maxval=4)
pin2_style_input = input.string("Dashed", "",          group=grp2, inline="p2", options=["Solid", "Dashed", "Dotted"])

show_pin3        = input.bool(false,  "Pinned EMA 3",  group=grp2, inline="p3")
pin3_len         = input.int(200,     "",              group=grp2, inline="p3", minval=1)
pin3_tf          = input.timeframe("60", "",           group=grp2, inline="p3")
pin3_width       = input.int(2,       "",              group=grp2, inline="p3", minval=1, maxval=4)
pin3_style_input = input.string("Dashed", "",          group=grp2, inline="p3", options=["Solid", "Dashed", "Dotted"])

// ─────────────────────────────────────────
// GROUP 2b: Pinned EMA Color Mode
// ─────────────────────────────────────────
grp2b = "📌 Pinned EMAs — Color Settings"

// Pin 1 colors
pin1_color_mode  = input.string("Dynamic", "Pinned EMA 1 Color Mode", group=grp2b, options=["Static", "Dynamic"], inline="pc1")
pin1_static_col  = input.color(color.new(#00BCD4, 0), "Static",       group=grp2b, inline="pc1")
pin1_above_col   = input.color(color.new(#26A69A, 0), "Above",        group=grp2b, inline="pc1")
pin1_below_col   = input.color(color.new(#EF5350, 0), "Below",        group=grp2b, inline="pc1")

// Pin 2 colors
pin2_color_mode  = input.string("Dynamic", "Pinned EMA 2 Color Mode", group=grp2b, options=["Static", "Dynamic"], inline="pc2")
pin2_static_col  = input.color(color.new(#FFEB3B, 0), "Static",       group=grp2b, inline="pc2")
pin2_above_col   = input.color(color.new(#26A69A, 0), "Above",        group=grp2b, inline="pc2")
pin2_below_col   = input.color(color.new(#EF5350, 0), "Below",        group=grp2b, inline="pc2")

// Pin 3 colors
pin3_color_mode  = input.string("Dynamic", "Pinned EMA 3 Color Mode", group=grp2b, options=["Static", "Dynamic"], inline="pc3")
pin3_static_col  = input.color(color.new(#69F0AE, 0), "Static",       group=grp2b, inline="pc3")
pin3_above_col   = input.color(color.new(#26A69A, 0), "Above",        group=grp2b, inline="pc3")
pin3_below_col   = input.color(color.new(#EF5350, 0), "Below",        group=grp2b, inline="pc3")

// ─────────────────────────────────────────
// GROUP 3: Label Settings
// ─────────────────────────────────────────
grp3 = "Labels"
label_size    = input.string("small", "Label Size", group=grp3, options=["tiny", "small", "normal", "large"])
label_txt_col = input.color(color.new(#000000, 0), "Text Color (Standard EMAs)", group=grp3)
pin_txt_col   = input.color(color.new(#000000, 0), "Text Color (Pinned EMAs)",   group=grp3)

grp3a = "Labels › Standard EMAs"
lbl_ema1 = input.bool(true, "Label EMA 1", group=grp3a, inline="l1")
lbl_ema2 = input.bool(true, "Label EMA 2", group=grp3a, inline="l1")
lbl_ema3 = input.bool(true, "Label EMA 3", group=grp3a, inline="l1")
lbl_ema4 = input.bool(true, "Label EMA 4", group=grp3a, inline="l1")
lbl_ema5 = input.bool(true, "Label EMA 5", group=grp3a, inline="l2")
lbl_ema6 = input.bool(true, "Label EMA 6", group=grp3a, inline="l2")
lbl_ema7 = input.bool(true, "Label EMA 7", group=grp3a, inline="l2")
lbl_ema8 = input.bool(true, "Label EMA 8", group=grp3a, inline="l2")

grp3b = "Labels › Pinned EMAs"
lbl_pin1 = input.bool(true, "Label Pinned 1", group=grp3b, inline="lp")
lbl_pin2 = input.bool(true, "Label Pinned 2", group=grp3b, inline="lp")
lbl_pin3 = input.bool(true, "Label Pinned 3", group=grp3b, inline="lp")

// ─────────────────────────────────────────
// CALCULATIONS: Standard EMAs
// ─────────────────────────────────────────
e1 = ta.ema(close, ema1_len)
e2 = ta.ema(close, ema2_len)
e3 = ta.ema(close, ema3_len)
e4 = ta.ema(close, ema4_len)
e5 = ta.ema(close, ema5_len)
e6 = ta.ema(close, ema6_len)
e7 = ta.ema(close, ema7_len)
e8 = ta.ema(close, ema8_len)

plot(show_ema1 ? e1 : na, title="EMA 1", color=ema1_col, linewidth=1)
plot(show_ema2 ? e2 : na, title="EMA 2", color=ema2_col, linewidth=1)
plot(show_ema3 ? e3 : na, title="EMA 3", color=ema3_col, linewidth=1)
plot(show_ema4 ? e4 : na, title="EMA 4", color=ema4_col, linewidth=1)
plot(show_ema5 ? e5 : na, title="EMA 5", color=ema5_col, linewidth=1)
plot(show_ema6 ? e6 : na, title="EMA 6", color=ema6_col, linewidth=1)
plot(show_ema7 ? e7 : na, title="EMA 7", color=ema7_col, linewidth=1)
plot(show_ema8 ? e8 : na, title="EMA 8", color=ema8_col, linewidth=1)

// ─────────────────────────────────────────
// CALCULATIONS: Pinned TF EMAs + Dynamic Color
// ─────────────────────────────────────────
pin1_val = request.security(syminfo.tickerid, pin1_tf, ta.ema(close, pin1_len), lookahead=barmerge.lookahead_off)
pin2_val = request.security(syminfo.tickerid, pin2_tf, ta.ema(close, pin2_len), lookahead=barmerge.lookahead_off)
pin3_val = request.security(syminfo.tickerid, pin3_tf, ta.ema(close, pin3_len), lookahead=barmerge.lookahead_off)

// Resolve active color per pinned EMA
pin1_active_col = pin1_color_mode == "Dynamic" ? (close >= pin1_val ? pin1_above_col : pin1_below_col) : pin1_static_col
pin2_active_col = pin2_color_mode == "Dynamic" ? (close >= pin2_val ? pin2_above_col : pin2_below_col) : pin2_static_col
pin3_active_col = pin3_color_mode == "Dynamic" ? (close >= pin3_val ? pin3_above_col : pin3_below_col) : pin3_static_col

// Pinned EMA 1 — 3 style variants, only matching one active
plot(show_pin1 and pin1_style_input == "Solid"  ? pin1_val : na, title="📌 Pinned EMA 1",        color=pin1_active_col, linewidth=pin1_width, style=plot.style_line)
plot(show_pin1 and pin1_style_input == "Dashed" ? pin1_val : na, title="📌 Pinned EMA 1 Dashed", color=pin1_active_col, linewidth=pin1_width, style=plot.style_linebr)
plot(show_pin1 and pin1_style_input == "Dotted" ? pin1_val : na, title="📌 Pinned EMA 1 Dotted", color=pin1_active_col, linewidth=pin1_width, style=plot.style_circles)

// Pinned EMA 2
plot(show_pin2 and pin2_style_input == "Solid"  ? pin2_val : na, title="📌 Pinned EMA 2",        color=pin2_active_col, linewidth=pin2_width, style=plot.style_line)
plot(show_pin2 and pin2_style_input == "Dashed" ? pin2_val : na, title="📌 Pinned EMA 2 Dashed", color=pin2_active_col, linewidth=pin2_width, style=plot.style_linebr)
plot(show_pin2 and pin2_style_input == "Dotted" ? pin2_val : na, title="📌 Pinned EMA 2 Dotted", color=pin2_active_col, linewidth=pin2_width, style=plot.style_circles)

// Pinned EMA 3
plot(show_pin3 and pin3_style_input == "Solid"  ? pin3_val : na, title="📌 Pinned EMA 3",        color=pin3_active_col, linewidth=pin3_width, style=plot.style_line)
plot(show_pin3 and pin3_style_input == "Dashed" ? pin3_val : na, title="📌 Pinned EMA 3 Dashed", color=pin3_active_col, linewidth=pin3_width, style=plot.style_linebr)
plot(show_pin3 and pin3_style_input == "Dotted" ? pin3_val : na, title="📌 Pinned EMA 3 Dotted", color=pin3_active_col, linewidth=pin3_width, style=plot.style_circles)

// ─────────────────────────────────────────
// LABELS
// ─────────────────────────────────────────
f_lbl_size(s) =>
    s == "tiny"  ? size.tiny  :
     s == "small" ? size.small :
     s == "large" ? size.large : size.normal

if barstate.islast
    sz = f_lbl_size(label_size)

    if show_ema1 and lbl_ema1
        label.new(bar_index, e1, "EMA " + str.tostring(ema1_len), color=ema1_col, textcolor=label_txt_col, style=label.style_label_left, size=sz)
    if show_ema2 and lbl_ema2
        label.new(bar_index, e2, "EMA " + str.tostring(ema2_len), color=ema2_col, textcolor=label_txt_col, style=label.style_label_left, size=sz)
    if show_ema3 and lbl_ema3
        label.new(bar_index, e3, "EMA " + str.tostring(ema3_len), color=ema3_col, textcolor=label_txt_col, style=label.style_label_left, size=sz)
    if show_ema4 and lbl_ema4
        label.new(bar_index, e4, "EMA " + str.tostring(ema4_len), color=ema4_col, textcolor=label_txt_col, style=label.style_label_left, size=sz)
    if show_ema5 and lbl_ema5
        label.new(bar_index, e5, "EMA " + str.tostring(ema5_len), color=ema5_col, textcolor=label_txt_col, style=label.style_label_left, size=sz)
    if show_ema6 and lbl_ema6
        label.new(bar_index, e6, "EMA " + str.tostring(ema6_len), color=ema6_col, textcolor=label_txt_col, style=label.style_label_left, size=sz)
    if show_ema7 and lbl_ema7
        label.new(bar_index, e7, "EMA " + str.tostring(ema7_len), color=ema7_col, textcolor=label_txt_col, style=label.style_label_left, size=sz)
    if show_ema8 and lbl_ema8
        label.new(bar_index, e8, "EMA " + str.tostring(ema8_len), color=ema8_col, textcolor=label_txt_col, style=label.style_label_left, size=sz)

    if show_pin1 and lbl_pin1
        label.new(bar_index, pin1_val, "📌 EMA " + str.tostring(pin1_len) + " (" + pin1_tf + "m)", color=pin1_active_col, textcolor=pin_txt_col, style=label.style_label_left, size=sz)
    if show_pin2 and lbl_pin2
        label.new(bar_index, pin2_val, "📌 EMA " + str.tostring(pin2_len) + " (" + pin2_tf + "m)", color=pin2_active_col, textcolor=pin_txt_col, style=label.style_label_left, size=sz)
    if show_pin3 and lbl_pin3
        label.new(bar_index, pin3_val, "📌 EMA " + str.tostring(pin3_len) + " (" + pin3_tf + "m)", color=pin3_active_col, textcolor=pin_txt_col, style=label.style_label_left, size=sz)
````
