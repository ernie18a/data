#  Glowing MA with Auto-coloured and Labels [icreature]

- url: https://www.tradingview.com/script/D3KSJ202-Glowing-MA-with-Auto-coloured-and-Labels-icreature/
- type: indicator
- pine_id: PUB;db2f8ce0ebfa44988645adf43da8e055
- version: 2.0

## Description

Hi all,

This MA includes multiple types for you to choose from, featuring automatic color changes to indicate bullish or bearish trends. It also comes with labels and a glow effect optimized for dark mode, so you won’t need to remember which MA periods or timeframes you’ve set. Enjoy!

## Source Code

````pine
//@version=6
indicator(title="Glowing MA with auto-coloured and labels [icreautre]", overlay=true)

get_timeframe_title(simple string tf = "") =>
    string result = na
    if timeframe.isminutes and timeframe.multiplier > 59
        if (timeframe.multiplier / 60) % 2 == 0
            result := str.tostring(timeframe.multiplier / 60) + "h"
        else
            result := str.tostring(timeframe.multiplier) + "m"
    else if timeframe.isminutes == true
        result := str.tostring(timeframe.multiplier) + "m"
    else
        result := timeframe.period
    tf == "" ? "" : request.security(syminfo.tickerid, tf, result)

smma(float src, int length) =>
    var float smma = na
    smma := na(smma[1]) ? ta.sma(src, length) : (smma[1] * (length - 1) + src) / length

get_mov_avg_type(string type, series float source, int length) =>
    switch str.upper(type)
        "SMA"  => ta.sma(source, length)
        "EMA"  => ta.ema(source, length)
        "SMMA" => smma(source, length)
        "RMA"  => ta.rma(source, length)
        "WMA"  => ta.wma(source, length)
        "HMA"  => ta.hma(source, length)
        "VWMA" => ta.vwma(source, length)

// Existing Inputs
label_size_input  = input.string("normal", title="Label Size", options=["small", "normal", "large"], display = display.none)
label_size_option = switch label_size_input
    "small"  => size.small
    "normal" => size.normal
    "large"  => size.large
distance_input = input(2, "Label Distance", display = display.none)

global_color_enable = input.bool(false, "Use one color", inline = "global_color", display = display.none)
global_color_input  = input.color(color.new(#7a7a7a, 0), title = "", inline = "global_color")

// Auto Color Options — now with adjustable bull/bear colours
auto_color_enable     = input.bool(false,                    "Auto Color Mode",   group = "Auto Color Options")
auto_color_bull_input = input.color(color.new(#FFFF00, 0),   "Bullish Color",     group = "Auto Color Options")
auto_color_bear_input = input.color(color.new(#808080, 0),   "Bearish Color",     group = "Auto Color Options")

// Glow Settings
glow_on      = input.bool(true, "Enable Glow",     group = "Glow Settings", inline = "glow")
glow_intense = input.int(80,    "Intensity (0-98)", group = "Glow Settings", inline = "glow", minval = 0, maxval = 98)

// MA1
ma1_enable      = input.bool(true,    "Enable MA1", group = "MA1 Options", display = display.none)
ma1_type        = input.string("EMA", "Type",       group = "MA1 Options", display = display.none, options = ["SMA", "EMA", "SMMA", "RMA", "WMA", "HMA", "VWMA"])
ma1_source      = input.source(close, "Source",     group = "MA1 Options", display = display.none)
ma1_timeframe   = input.timeframe("240", "Timeframe", group = "MA1 Options", display = display.none)
ma1_len         = input.int(200, minval=1, title="Length", group = "MA1 Options", display = display.none)
ma1_out         = get_mov_avg_type(ma1_type, ma1_source, ma1_len)
ma1_color_input = input.color(color.new(#008004, 0), title="Color", group = "MA1 Options")
ma1_display     = ma1_enable ? display.all - display.status_line : display.none

// MA2
ma2_enable      = input.bool(true,    "Enable MA2", group = "MA2 Options", display = display.none)
ma2_type        = input.string("EMA", "Type",       group = "MA2 Options", display = display.none, options = ["SMA", "EMA", "SMMA", "RMA", "WMA", "HMA", "VWMA"])
ma2_source      = input.source(close, "Source",     group = "MA2 Options", display = display.none)
ma2_timeframe   = input.timeframe("D", "Timeframe", group = "MA2 Options", display = display.none)
ma2_len         = input.int(100, minval=1, title="Length", group = "MA2 Options", display = display.none)
ma2_out         = get_mov_avg_type(ma2_type, ma2_source, ma2_len)
ma2_color_input = input.color(color.new(#F2AF29, 0), title="Color", group = "MA2 Options")
ma2_display     = ma2_enable ? display.all - display.status_line : display.none

// MA3
ma3_enable      = input.bool(true,    "Enable MA3", group = "MA3 Options", display = display.none)
ma3_type        = input.string("EMA", "Type",       group = "MA3 Options", display = display.none, options = ["SMA", "EMA", "SMMA", "RMA", "WMA", "HMA", "VWMA"])
ma3_source      = input.source(close, "Source",     group = "MA3 Options", display = display.none)
ma3_timeframe   = input.timeframe("D", "Timeframe", group = "MA3 Options", display = display.none)
ma3_len         = input.int(200, minval=1, title="Length", group = "MA3 Options", display = display.none)
ma3_out         = get_mov_avg_type(ma3_type, ma3_source, ma3_len)
ma3_color_input = input.color(color.new(#725AC1, 0), title="Color", group = "MA3 Options")
ma3_display     = ma3_enable ? display.all - display.status_line : display.none

// MA4
ma4_enable      = input.bool(true,     "Enable MA4", group = "MA4 Options", display = display.none)
ma4_type        = input.string("SMMA", "Type",       group = "MA4 Options", display = display.none, options = ["SMA", "EMA", "SMMA", "RMA", "WMA", "HMA", "VWMA"])
ma4_source      = input.source(close,  "Source",     group = "MA4 Options", display = display.none)
ma4_timeframe   = input.timeframe("",  "Timeframe",  group = "MA4 Options", display = display.none)
ma4_len         = input.int(7, minval=1, title="Length", group = "MA4 Options", display = display.none)
ma4_out         = get_mov_avg_type(ma4_type, ma4_source, ma4_len)
ma4_color_input = input.color(color.new(#FE5E41, 0), title="Color", group = "MA4 Options", display = display.none)
ma4_display     = ma4_enable ? display.all - display.status_line : display.none

// MA5
ma5_enable      = input.bool(false,   "Enable MA5", group = "MA5 Options", display = display.none)
ma5_type        = input.string("EMA", "Type",       group = "MA5 Options", display = display.none, options = ["SMA", "EMA", "SMMA", "RMA", "WMA", "HMA", "VWMA"])
ma5_source      = input.source(close, "Source",     group = "MA5 Options", display = display.none)
ma5_timeframe   = input.timeframe("W", "Timeframe", group = "MA5 Options", display = display.none)
ma5_len         = input.int(12, minval=1, title="Length", group = "MA5 Options", display = display.none)
ma5_out         = get_mov_avg_type(ma5_type, ma5_source, ma5_len)
ma5_color_input = input.color(color.new(#243E36, 0), title="Color", group = "MA5 Options")
ma5_display     = ma5_enable ? display.all - display.status_line : display.none

// MA6
ma6_enable      = input.bool(false,   "Enable MA6", group = "MA6 Options", display = display.none)
ma6_type        = input.string("EMA", "Type",       group = "MA6 Options", display = display.none, options = ["SMA", "EMA", "SMMA", "RMA", "WMA", "HMA", "VWMA"])
ma6_source      = input.source(close, "Source",     group = "MA6 Options", display = display.none)
ma6_timeframe   = input.timeframe("W", "Timeframe", group = "MA6 Options", display = display.none)
ma6_len         = input.int(21, minval=1, title="Length", group = "MA6 Options", display = display.none)
ma6_out         = get_mov_avg_type(ma6_type, ma6_source, ma6_len)
ma6_color_input = input.color(color.new(#3B3923, 0), title="Color", group = "MA6 Options")
ma6_display     = ma6_enable ? display.all - display.status_line : display.none

// MA7
ma7_enable      = input.bool(false,   "Enable MA7", group = "MA7 Options", display = display.none)
ma7_type        = input.string("EMA", "Type",       group = "MA7 Options", display = display.none, options = ["SMA", "EMA", "SMMA", "RMA", "WMA", "HMA", "VWMA"])
ma7_source      = input.source(close, "Source",     group = "MA7 Options", display = display.none)
ma7_timeframe   = input.timeframe("",  "Timeframe", group = "MA7 Options", display = display.none)
ma7_len         = input.int(12, minval=1, title="Length", group = "MA7 Options", display = display.none)
ma7_out         = get_mov_avg_type(ma7_type, ma7_source, ma7_len)
ma7_color_input = input.color(color.new(#3A7CA5, 0), title="Color", group = "MA7 Options")
ma7_display     = ma7_enable ? display.all - display.status_line : display.none

// MA8
ma8_enable      = input.bool(false,   "Enable MA8", group = "MA8 Options", display = display.none)
ma8_type        = input.string("EMA", "Type",       group = "MA8 Options", display = display.none, options = ["SMA", "EMA", "SMMA", "RMA", "WMA", "HMA", "VWMA"])
ma8_source      = input.source(close, "Source",     group = "MA8 Options", display = display.none)
ma8_timeframe   = input.timeframe("",  "Timeframe", group = "MA8 Options", display = display.none)
ma8_len         = input.int(26, minval=1, title="Length", group = "MA8 Options", display = display.none)
ma8_out         = get_mov_avg_type(ma8_type, ma8_source, ma8_len)
ma8_color_input = input.color(color.new(#7a7a7a, 0), title="Color", group = "MA8 Options")
ma8_display     = ma8_enable ? display.all - display.status_line : display.none

// Auto Color Logic — now uses the two adjustable colour pickers
ma1_color = auto_color_enable ? (close >= ma1_out ? auto_color_bull_input : auto_color_bear_input) : ma1_color_input
ma2_color = auto_color_enable ? (close >= ma2_out ? auto_color_bull_input : auto_color_bear_input) : ma2_color_input
ma3_color = auto_color_enable ? (close >= ma3_out ? auto_color_bull_input : auto_color_bear_input) : ma3_color_input
ma4_color = auto_color_enable ? (close >= ma4_out ? auto_color_bull_input : auto_color_bear_input) : ma4_color_input
ma5_color = auto_color_enable ? (close >= ma5_out ? auto_color_bull_input : auto_color_bear_input) : ma5_color_input
ma6_color = auto_color_enable ? (close >= ma6_out ? auto_color_bull_input : auto_color_bear_input) : ma6_color_input
ma7_color = auto_color_enable ? (close >= ma7_out ? auto_color_bull_input : auto_color_bear_input) : ma7_color_input
ma8_color = auto_color_enable ? (close >= ma8_out ? auto_color_bull_input : auto_color_bear_input) : ma8_color_input

// Apply global color if enabled
ma1_color_final = global_color_enable ? global_color_input : ma1_color
ma2_color_final = global_color_enable ? global_color_input : ma2_color
ma3_color_final = global_color_enable ? global_color_input : ma3_color
ma4_color_final = global_color_enable ? global_color_input : ma4_color
ma5_color_final = global_color_enable ? global_color_input : ma5_color
ma6_color_final = global_color_enable ? global_color_input : ma6_color
ma7_color_final = global_color_enable ? global_color_input : ma7_color
ma8_color_final = global_color_enable ? global_color_input : ma8_color

// Glow transparency layers (3 layers: 8x3 + 8 core = 32 plots, well under the 64 limit)
i  = glow_intense
i2 = math.min(i + 10, 98)
i3 = math.min(i + 20, 98)

// Glow series — na when line disabled or glow off
g1 = glow_on and ma1_enable ? ma1_out : na
g2 = glow_on and ma2_enable ? ma2_out : na
g3 = glow_on and ma3_enable ? ma3_out : na
g4 = glow_on and ma4_enable ? ma4_out : na
g5 = glow_on and ma5_enable ? ma5_out : na
g6 = glow_on and ma6_enable ? ma6_out : na
g7 = glow_on and ma7_enable ? ma7_out : na
g8 = glow_on and ma8_enable ? ma8_out : na

// Glow Layer 1 — linewidth 10
plot(g1, "MA1 Glow1", color.new(ma1_color_final, i),  linewidth = 10, editable = false)
plot(g2, "MA2 Glow1", color.new(ma2_color_final, i),  linewidth = 10, editable = false)
plot(g3, "MA3 Glow1", color.new(ma3_color_final, i),  linewidth = 10, editable = false)
plot(g4, "MA4 Glow1", color.new(ma4_color_final, i),  linewidth = 10, editable = false)
plot(g5, "MA5 Glow1", color.new(ma5_color_final, i),  linewidth = 10, editable = false)
plot(g6, "MA6 Glow1", color.new(ma6_color_final, i),  linewidth = 10, editable = false)
plot(g7, "MA7 Glow1", color.new(ma7_color_final, i),  linewidth = 10, editable = false)
plot(g8, "MA8 Glow1", color.new(ma8_color_final, i),  linewidth = 10, editable = false)

// Glow Layer 2 — linewidth 25
plot(g1, "MA1 Glow2", color.new(ma1_color_final, i2), linewidth = 25, editable = false)
plot(g2, "MA2 Glow2", color.new(ma2_color_final, i2), linewidth = 25, editable = false)
plot(g3, "MA3 Glow2", color.new(ma3_color_final, i2), linewidth = 25, editable = false)
plot(g4, "MA4 Glow2", color.new(ma4_color_final, i2), linewidth = 25, editable = false)
plot(g5, "MA5 Glow2", color.new(ma5_color_final, i2), linewidth = 25, editable = false)
plot(g6, "MA6 Glow2", color.new(ma6_color_final, i2), linewidth = 25, editable = false)
plot(g7, "MA7 Glow2", color.new(ma7_color_final, i2), linewidth = 25, editable = false)
plot(g8, "MA8 Glow2", color.new(ma8_color_final, i2), linewidth = 25, editable = false)

// Glow Layer 3 — linewidth 45
plot(g1, "MA1 Glow3", color.new(ma1_color_final, i3), linewidth = 45, editable = false)
plot(g2, "MA2 Glow3", color.new(ma2_color_final, i3), linewidth = 45, editable = false)
plot(g3, "MA3 Glow3", color.new(ma3_color_final, i3), linewidth = 45, editable = false)
plot(g4, "MA4 Glow3", color.new(ma4_color_final, i3), linewidth = 45, editable = false)
plot(g5, "MA5 Glow3", color.new(ma5_color_final, i3), linewidth = 45, editable = false)
plot(g6, "MA6 Glow3", color.new(ma6_color_final, i3), linewidth = 45, editable = false)
plot(g7, "MA7 Glow3", color.new(ma7_color_final, i3), linewidth = 45, editable = false)
plot(g8, "MA8 Glow3", color.new(ma8_color_final, i3), linewidth = 45, editable = false)

// Core MA Lines — drawn on top of glow
plot(ma1_enable ? ma1_out : na, color=ma1_color_final, display=ma1_display, linewidth=1, title="MA1")
plot(ma2_enable ? ma2_out : na, color=ma2_color_final, display=ma2_display, linewidth=1, title="MA2")
plot(ma3_enable ? ma3_out : na, color=ma3_color_final, display=ma3_display, linewidth=1, title="MA3")
plot(ma4_enable ? ma4_out : na, color=ma4_color_final, display=ma4_display, linewidth=1, title="MA4")
plot(ma5_enable ? ma5_out : na, color=ma5_color_final, display=ma5_display, linewidth=1, title="MA5")
plot(ma6_enable ? ma6_out : na, color=ma6_color_final, display=ma6_display, linewidth=1, title="MA6")
plot(ma7_enable ? ma7_out : na, color=ma7_color_final, display=ma7_display, linewidth=1, title="MA7")
plot(ma8_enable ? ma8_out : na, color=ma8_color_final, display=ma8_display, linewidth=1, title="MA8")

// Labels
var ma1_label = label.new(na, na, "", color=na, textcolor=ma1_color_final, style=label.style_label_center, size=label_size_option, yloc=yloc.price)
var ma2_label = label.new(na, na, "", color=na, textcolor=ma2_color_final, style=label.style_label_center, size=label_size_option, yloc=yloc.price)
var ma3_label = label.new(na, na, "", color=na, textcolor=ma3_color_final, style=label.style_label_center, size=label_size_option, yloc=yloc.price)
var ma4_label = label.new(na, na, "", color=na, textcolor=ma4_color_final, style=label.style_label_center, size=label_size_option, yloc=yloc.price)
var ma5_label = label.new(na, na, "", color=na, textcolor=ma5_color_final, style=label.style_label_center, size=label_size_option, yloc=yloc.price)
var ma6_label = label.new(na, na, "", color=na, textcolor=ma6_color_final, style=label.style_label_center, size=label_size_option, yloc=yloc.price)
var ma7_label = label.new(na, na, "", color=na, textcolor=ma7_color_final, style=label.style_label_center, size=label_size_option, yloc=yloc.price)
var ma8_label = label.new(na, na, "", color=na, textcolor=ma8_color_final, style=label.style_label_center, size=label_size_option, yloc=yloc.price)

if barstate.islast
    if ma1_enable
        label.set_xy(ma1_label, bar_index + distance_input, ma1_out)
        label.set_text(ma1_label, ma1_type + " " + str.tostring(ma1_len))
        label.set_textcolor(ma1_label, ma1_color_final)
    else
        label.set_text(ma1_label, "")

    if ma2_enable
        label.set_xy(ma2_label, bar_index + distance_input, ma2_out)
        label.set_text(ma2_label, ma2_type + " " + str.tostring(ma2_len))
        label.set_textcolor(ma2_label, ma2_color_final)
    else
        label.set_text(ma2_label, "")

    if ma3_enable
        label.set_xy(ma3_label, bar_index + distance_input, ma3_out)
        label.set_text(ma3_label, ma3_type + " " + str.tostring(ma3_len))
        label.set_textcolor(ma3_label, ma3_color_final)
    else
        label.set_text(ma3_label, "")

    if ma4_enable
        label.set_xy(ma4_label, bar_index + distance_input, ma4_out)
        label.set_text(ma4_label, ma4_type + " " + str.tostring(ma4_len))
        label.set_textcolor(ma4_label, ma4_color_final)
    else
        label.set_text(ma4_label, "")

    if ma5_enable
        label.set_xy(ma5_label, bar_index + distance_input, ma5_out)
        label.set_text(ma5_label, ma5_type + " " + str.tostring(ma5_len))
        label.set_textcolor(ma5_label, ma5_color_final)
    else
        label.set_text(ma5_label, "")

    if ma6_enable
        label.set_xy(ma6_label, bar_index + distance_input, ma6_out)
        label.set_text(ma6_label, ma6_type + " " + str.tostring(ma6_len))
        label.set_textcolor(ma6_label, ma6_color_final)
    else
        label.set_text(ma6_label, "")

    if ma7_enable
        label.set_xy(ma7_label, bar_index + distance_input, ma7_out)
        label.set_text(ma7_label, ma7_type + " " + str.tostring(ma7_len))
        label.set_textcolor(ma7_label, ma7_color_final)
    else
        label.set_text(ma7_label, "")

    if ma8_enable
        label.set_xy(ma8_label, bar_index + distance_input, ma8_out)
        label.set_text(ma8_label, ma8_type + " " + str.tostring(ma8_len))
        label.set_textcolor(ma8_label, ma8_color_final)
    else
        label.set_text(ma8_label, "")
````
