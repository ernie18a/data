# Multi MA-MTF + ATR

- url: https://www.tradingview.com/script/iHPKs7eZ-Multi-MA-MTF-ATR/
- type: indicator
- pine_id: PUB;24aed873db564df59366d5b45d6bea8e
- version: 1.0

## Description

Multi MA-MTF + ATR is a lightweight, flexible moving-average toolkit built for clean charting and multi-timeframe context.

Key Features

Up to 10 Moving Averages (SMA / EMA / RMA / WMA / VWMA / HMA)

Per-MA controls:

Enable/disable

Type, Length, Source

Color + Width

MTF mode

Project to LTF: display a higher-timeframe MA on lower timeframes (example: show the 1H MA directly on the 5m/15m chart)

Only on that TF: show the MA only when the chart timeframe matches the selected TF

Confirmed option for higher-timeframe values (helps avoid repaint-like behavior by holding the last confirmed HTF value)

ATR Panel

ATR value table displayed on the chart

Optional ATR high/low lines (disabled by default)

Defaults

Only MA1–MA3 enabled by default (clean out of the box)

Default MA line width set to 1

ATR lines OFF by default

Important Note (If it “drifts” / appears off the price)

If the indicator looks “detached” or seems to drift, it’s usually because TradingView moved it into a separate pane.
Fix: click the three dots next to the indicator name → Move to → Main chart.
You can also remove and re-add the indicator to reset its placement.

## Source Code

````pine
//@version=6
//------------------------------------------------------------------------------
// Multi MA-MTF + ATR
// Purpose: Multi-timeframe moving averages (project HTF MAs on LTF) + ATR value table.
// Notes:
//  • If the indicator looks "detached" or "drifts", TradingView likely moved it to a separate pane.
//    Fix: indicator name → three dots (⋯) → Move to → Main chart.
//  • Intended to be published as "Protected" on TradingView.
//  • Unauthorized re-upload/republication is prohibited.
// Copyright © 2026
//------------------------------------------------------------------------------
indicator("Multi MA-MTF + ATR", overlay=true, max_lines_count=500)
// Unauthorized re-upload/republication is prohibited.

//──────────────────────────────────────────────────────────────────────────────
// General
//──────────────────────────────────────────────────────────────────────────────
gGeneral = "General"
showAll  = input.bool(true, "Show MAs", group=gGeneral)

//──────────────────────────────────────────────────────────────────────────────
// MA core
//──────────────────────────────────────────────────────────────────────────────
f_ma(_type, _src, _len) =>
    l = math.max(_len, 1)
    switch _type
        "SMA"  => ta.sma(_src, l)
        "EMA"  => ta.ema(_src, l)
        "RMA"  => ta.rma(_src, l)
        "WMA"  => ta.wma(_src, l)
        "VWMA" => ta.vwma(_src, l)
        "HMA"  => ta.hma(_src, l)
        => ta.sma(_src, l)

// Expressions HTF (évaluées dans request.security)
f_ma_live(_type, _src, _len) =>
    f_ma(_type, _src, _len)

f_ma_confirmed_only(_type, _src, _len) =>
    ma = f_ma(_type, _src, _len)
    barstate.isconfirmed ? ma : na

f_sec_live(_tf, _type, _src, _len) =>
    request.security(syminfo.tickerid, _tf, f_ma_live(_type, _src, _len), barmerge.gaps_off, barmerge.lookahead_off)

f_sec_conf(_tf, _type, _src, _len) =>
    request.security(syminfo.tickerid, _tf, f_ma_confirmed_only(_type, _src, _len), barmerge.gaps_off, barmerge.lookahead_off)

//──────────────────────────────────────────────────────────────────────────────
// Inputs MA 1..10
// Defaut: seulement 3 MAs activées (MA1-3)
// Defaut: Width = 1 pour toutes les MAs
//──────────────────────────────────────────────────────────────────────────────

// MA 1
en1   = input.bool(true, "Enable", group="MA 1", inline="a")
t1    = input.string("SMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 1", inline="a")
l1    = input.int(20, "Len", minval=1, group="MA 1", inline="b")
s1    = input.source(close, "Src", group="MA 1", inline="b")
c1    = input.color(color.new(color.white, 0), "Color", group="MA 1", inline="c")
w1    = input.int(1, "Width", minval=1, maxval=5, group="MA 1", inline="c")
m1    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 1", inline="d")
tf1   = input.timeframe("", "TF", group="MA 1", inline="d")
h1    = input.bool(true, "Confirmed", group="MA 1", inline="e")

// MA 2
en2   = input.bool(true, "Enable", group="MA 2", inline="a")
t2    = input.string("SMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 2", inline="a")
l2    = input.int(50, "Len", minval=1, group="MA 2", inline="b")
s2    = input.source(close, "Src", group="MA 2", inline="b")
c2    = input.color(color.new(color.aqua, 0), "Color", group="MA 2", inline="c")
w2    = input.int(1, "Width", minval=1, maxval=5, group="MA 2", inline="c")
m2    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 2", inline="d")
tf2   = input.timeframe("", "TF", group="MA 2", inline="d")
h2    = input.bool(true, "Confirmed", group="MA 2", inline="e")

// MA 3
en3   = input.bool(true, "Enable", group="MA 3", inline="a")
t3    = input.string("SMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 3", inline="a")
l3    = input.int(100, "Len", minval=1, group="MA 3", inline="b")
s3    = input.source(close, "Src", group="MA 3", inline="b")
c3    = input.color(color.new(color.yellow, 0), "Color", group="MA 3", inline="c")
w3    = input.int(1, "Width", minval=1, maxval=5, group="MA 3", inline="c")
m3    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 3", inline="d")
tf3   = input.timeframe("", "TF", group="MA 3", inline="d")
h3    = input.bool(true, "Confirmed", group="MA 3", inline="e")

// MA 4
en4   = input.bool(false, "Enable", group="MA 4", inline="a")
t4    = input.string("SMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 4", inline="a")
l4    = input.int(200, "Len", minval=1, group="MA 4", inline="b")
s4    = input.source(close, "Src", group="MA 4", inline="b")
c4    = input.color(color.new(color.orange, 0), "Color", group="MA 4", inline="c")
w4    = input.int(1, "Width", minval=1, maxval=5, group="MA 4", inline="c")
m4    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 4", inline="d")
tf4   = input.timeframe("", "TF", group="MA 4", inline="d")
h4    = input.bool(true, "Confirmed", group="MA 4", inline="e")

// MA 5
en5   = input.bool(false, "Enable", group="MA 5", inline="a")
t5    = input.string("EMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 5", inline="a")
l5    = input.int(9, "Len", minval=1, group="MA 5", inline="b")
s5    = input.source(close, "Src", group="MA 5", inline="b")
c5    = input.color(color.new(color.fuchsia, 0), "Color", group="MA 5", inline="c")
w5    = input.int(1, "Width", minval=1, maxval=5, group="MA 5", inline="c")
m5    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 5", inline="d")
tf5   = input.timeframe("", "TF", group="MA 5", inline="d")
h5    = input.bool(true, "Confirmed", group="MA 5", inline="e")

// MA 6
en6   = input.bool(false, "Enable", group="MA 6", inline="a")
t6    = input.string("EMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 6", inline="a")
l6    = input.int(21, "Len", minval=1, group="MA 6", inline="b")
s6    = input.source(close, "Src", group="MA 6", inline="b")
c6    = input.color(color.new(color.lime, 0), "Color", group="MA 6", inline="c")
w6    = input.int(1, "Width", minval=1, maxval=5, group="MA 6", inline="c")
m6    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 6", inline="d")
tf6   = input.timeframe("", "TF", group="MA 6", inline="d")
h6    = input.bool(true, "Confirmed", group="MA 6", inline="e")

// MA 7
en7   = input.bool(false, "Enable", group="MA 7", inline="a")
t7    = input.string("SMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 7", inline="a")
l7    = input.int(150, "Len", minval=1, group="MA 7", inline="b")
s7    = input.source(close, "Src", group="MA 7", inline="b")
c7    = input.color(color.new(color.blue, 0), "Color", group="MA 7", inline="c")
w7    = input.int(1, "Width", minval=1, maxval=5, group="MA 7", inline="c")
m7    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 7", inline="d")
tf7   = input.timeframe("", "TF", group="MA 7", inline="d")
h7    = input.bool(true, "Confirmed", group="MA 7", inline="e")

// MA 8
en8   = input.bool(false, "Enable", group="MA 8", inline="a")
t8    = input.string("SMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 8", inline="a")
l8    = input.int(250, "Len", minval=1, group="MA 8", inline="b")
s8    = input.source(close, "Src", group="MA 8", inline="b")
c8    = input.color(color.new(color.red, 0), "Color", group="MA 8", inline="c")
w8    = input.int(1, "Width", minval=1, maxval=5, group="MA 8", inline="c")
m8    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 8", inline="d")
tf8   = input.timeframe("", "TF", group="MA 8", inline="d")
h8    = input.bool(true, "Confirmed", group="MA 8", inline="e")

// MA 9
en9   = input.bool(false, "Enable", group="MA 9", inline="a")
t9    = input.string("SMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 9", inline="a")
l9    = input.int(400, "Len", minval=1, group="MA 9", inline="b")
s9    = input.source(close, "Src", group="MA 9", inline="b")
c9    = input.color(color.new(color.teal, 0), "Color", group="MA 9", inline="c")
w9    = input.int(1, "Width", minval=1, maxval=5, group="MA 9", inline="c")
m9    = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 9", inline="d")
tf9   = input.timeframe("", "TF", group="MA 9", inline="d")
h9    = input.bool(true, "Confirmed", group="MA 9", inline="e")

// MA 10
en10  = input.bool(false, "Enable", group="MA 10", inline="a")
t10   = input.string("SMA", "Type", options=["SMA","EMA","RMA","WMA","VWMA","HMA"], group="MA 10", inline="a")
l10   = input.int(600, "Len", minval=1, group="MA 10", inline="b")
s10   = input.source(close, "Src", group="MA 10", inline="b")
c10   = input.color(color.new(color.purple, 0), "Color", group="MA 10", inline="c")
w10   = input.int(1, "Width", minval=1, maxval=5, group="MA 10", inline="c")
m10   = input.string("Project to LTF", "MTF", options=["Project to LTF","Only on that TF"], group="MA 10", inline="d")
tf10  = input.timeframe("", "TF", group="MA 10", inline="d")
h10   = input.bool(true, "Confirmed", group="MA 10", inline="e")
// Unauthorized re-upload/republication is prohibited.

//──────────────────────────────────────────────────────────────────────────────
// Calculs MTF (hold confirmé par MA)
//──────────────────────────────────────────────────────────────────────────────
calc_ma(_en, _t, _l, _s, _c, _w, _m, _tf, _h) =>
    _live = _tf == "" ? f_ma(_t, _s, _l) : f_sec_live(_tf, _t, _s, _l)
    _conf = _tf == "" ? _live            : f_sec_conf(_tf, _t, _s, _l)
    [_live, _conf]

// MA1
[ma1_live, ma1_conf] = calc_ma(en1, t1, l1, s1, c1, w1, m1, tf1, h1)
var float ma1_held = na
ma1_held := tf1 == "" ? ma1_live : nz(ma1_conf, nz(ma1_held[1], ma1_live))
ma1_raw  = tf1 == "" ? ma1_live : (h1 ? ma1_held : ma1_live)
ma1      = (tf1 != "" and m1 == "Only on that TF") ? (timeframe.period == tf1 ? ma1_raw : na) : ma1_raw

// MA2
[ma2_live, ma2_conf] = calc_ma(en2, t2, l2, s2, c2, w2, m2, tf2, h2)
var float ma2_held = na
ma2_held := tf2 == "" ? ma2_live : nz(ma2_conf, nz(ma2_held[1], ma2_live))
ma2_raw  = tf2 == "" ? ma2_live : (h2 ? ma2_held : ma2_live)
ma2      = (tf2 != "" and m2 == "Only on that TF") ? (timeframe.period == tf2 ? ma2_raw : na) : ma2_raw

// MA3
[ma3_live, ma3_conf] = calc_ma(en3, t3, l3, s3, c3, w3, m3, tf3, h3)
var float ma3_held = na
ma3_held := tf3 == "" ? ma3_live : nz(ma3_conf, nz(ma3_held[1], ma3_live))
ma3_raw  = tf3 == "" ? ma3_live : (h3 ? ma3_held : ma3_live)
ma3      = (tf3 != "" and m3 == "Only on that TF") ? (timeframe.period == tf3 ? ma3_raw : na) : ma3_raw

// MA4
[ma4_live, ma4_conf] = calc_ma(en4, t4, l4, s4, c4, w4, m4, tf4, h4)
var float ma4_held = na
ma4_held := tf4 == "" ? ma4_live : nz(ma4_conf, nz(ma4_held[1], ma4_live))
ma4_raw  = tf4 == "" ? ma4_live : (h4 ? ma4_held : ma4_live)
ma4      = (tf4 != "" and m4 == "Only on that TF") ? (timeframe.period == tf4 ? ma4_raw : na) : ma4_raw

// MA5
[ma5_live, ma5_conf] = calc_ma(en5, t5, l5, s5, c5, w5, m5, tf5, h5)
var float ma5_held = na
ma5_held := tf5 == "" ? ma5_live : nz(ma5_conf, nz(ma5_held[1], ma5_live))
ma5_raw  = tf5 == "" ? ma5_live : (h5 ? ma5_held : ma5_live)
ma5      = (tf5 != "" and m5 == "Only on that TF") ? (timeframe.period == tf5 ? ma5_raw : na) : ma5_raw

// MA6
[ma6_live, ma6_conf] = calc_ma(en6, t6, l6, s6, c6, w6, m6, tf6, h6)
var float ma6_held = na
ma6_held := tf6 == "" ? ma6_live : nz(ma6_conf, nz(ma6_held[1], ma6_live))
ma6_raw  = tf6 == "" ? ma6_live : (h6 ? ma6_held : ma6_live)
ma6      = (tf6 != "" and m6 == "Only on that TF") ? (timeframe.period == tf6 ? ma6_raw : na) : ma6_raw

// MA7
[ma7_live, ma7_conf] = calc_ma(en7, t7, l7, s7, c7, w7, m7, tf7, h7)
var float ma7_held = na
ma7_held := tf7 == "" ? ma7_live : nz(ma7_conf, nz(ma7_held[1], ma7_live))
ma7_raw  = tf7 == "" ? ma7_live : (h7 ? ma7_held : ma7_live)
ma7      = (tf7 != "" and m7 == "Only on that TF") ? (timeframe.period == tf7 ? ma7_raw : na) : ma7_raw

// MA8
[ma8_live, ma8_conf] = calc_ma(en8, t8, l8, s8, c8, w8, m8, tf8, h8)
var float ma8_held = na
ma8_held := tf8 == "" ? ma8_live : nz(ma8_conf, nz(ma8_held[1], ma8_live))
ma8_raw  = tf8 == "" ? ma8_live : (h8 ? ma8_held : ma8_live)
ma8      = (tf8 != "" and m8 == "Only on that TF") ? (timeframe.period == tf8 ? ma8_raw : na) : ma8_raw

// MA9
[ma9_live, ma9_conf] = calc_ma(en9, t9, l9, s9, c9, w9, m9, tf9, h9)
var float ma9_held = na
ma9_held := tf9 == "" ? ma9_live : nz(ma9_conf, nz(ma9_held[1], ma9_live))
ma9_raw  = tf9 == "" ? ma9_live : (h9 ? ma9_held : ma9_live)
ma9      = (tf9 != "" and m9 == "Only on that TF") ? (timeframe.period == tf9 ? ma9_raw : na) : ma9_raw

// MA10
[ma10_live, ma10_conf] = calc_ma(en10, t10, l10, s10, c10, w10, m10, tf10, h10)
var float ma10_held = na
ma10_held := tf10 == "" ? ma10_live : nz(ma10_conf, nz(ma10_held[1], ma10_live))
ma10_raw  = tf10 == "" ? ma10_live : (h10 ? ma10_held : ma10_live)
ma10      = (tf10 != "" and m10 == "Only on that TF") ? (timeframe.period == tf10 ? ma10_raw : na) : ma10_raw

//──────────────────────────────────────────────────────────────────────────────
// ATR (table + lignes optionnelles; défaut: lignes OFF)
//──────────────────────────────────────────────────────────────────────────────
gATR = "ATR"
length        = input.int(14, "ATR Period", minval=1, group=gATR)
smoothing     = input.string("RMA", "Smoothing", options=["RMA","SMA","EMA","WMA"], group=gATR)
atrMultiplier = input.float(1.5, "ATR Multiplier", minval=0.01, maxval=100, step=0.05, group=gATR)

src1 = input.source(high, "Src1 (High Line Base)", group=gATR)
src2 = input.source(low,  "Src2 (Low Line Base)",  group=gATR)

showPriceLines = input.bool(false, "Show Price Lines", group=gATR)  // défaut OFF

atrTextColor  = input.color(color.rgb(0, 0, 0), "ATR Text Color", group=gATR)
lowLineColor  = input.color(color.rgb(0, 150, 136),  "Low Line Color", group=gATR)
highLineColor = input.color(color.rgb(244, 67, 54),  "High Line Color", group=gATR)

tblPos = input.string("Top Right", "Position on Chart",
     options=["Top Left","Top Right","Bottom Left","Bottom Right","Middle Left","Middle Right"], group=gATR)

tblBorderColor = input.color(color.rgb(99, 99, 99), "Border Color", group=gATR)
cellBgColor    = input.color(color.white,           "Background Color", group=gATR)

f_tblpos(_s) =>
    _s == "Top Left" ? position.top_left :
     _s == "Top Right" ? position.top_right :
     _s == "Bottom Left" ? position.bottom_left :
     _s == "Bottom Right" ? position.bottom_right :
     _s == "Middle Left" ? position.middle_left :
     position.middle_right

f_atrma(_src, _len) =>
    switch smoothing
        "RMA" => ta.rma(_src, _len)
        "SMA" => ta.sma(_src, _len)
        "EMA" => ta.ema(_src, _len)
        "WMA" => ta.wma(_src, _len)

atrBase = f_atrma(ta.tr(true), length)
atrVal  = atrBase * atrMultiplier

hiLine = src1 + atrVal
loLine = src2 - atrVal

plot(showPriceLines ? hiLine : na, "High Line", highLineColor, 1)
plot(showPriceLines ? loLine : na, "Low Line",  lowLineColor,  1)

tblposition = f_tblpos(tblPos)
var table resultsTable = na
var string lastTblPos = na

if barstate.isfirst or tblPos != lastTblPos
    resultsTable := table.new(position=tblposition, columns=1, rows=1, bgcolor=cellBgColor, border_width=1, frame_color=tblBorderColor, frame_width=2)
    lastTblPos := tblPos

if barstate.islast
    table.clear(resultsTable, 0, 0, 0, 0)
    // Watermark discret (utile pour publication Protected)
    table.cell(
     resultsTable, 0, 0,
     "ATR Value: " + str.tostring(atrVal, format.mintick),
     text_color=atrTextColor, bgcolor=cellBgColor, text_halign=text.align_right
)
// Unauthorized re-upload/republication is prohibited.

//──────────────────────────────────────────────────────────────────────────────
// Plots MAs
//──────────────────────────────────────────────────────────────────────────────
plot(showAll and en1  ? ma1  : na, "MA1",  c1,  w1)
plot(showAll and en2  ? ma2  : na, "MA2",  c2,  w2)
plot(showAll and en3  ? ma3  : na, "MA3",  c3,  w3)
plot(showAll and en4  ? ma4  : na, "MA4",  c4,  w4)
plot(showAll and en5  ? ma5  : na, "MA5",  c5,  w5)
plot(showAll and en6  ? ma6  : na, "MA6",  c6,  w6)
plot(showAll and en7  ? ma7  : na, "MA7",  c7,  w7)
plot(showAll and en8  ? ma8  : na, "MA8",  c8,  w8)
plot(showAll and en9  ? ma9  : na, "MA9",  c9,  w9)
plot(showAll and en10 ? ma10 : na, "MA10", c10, w10)
// Unauthorized re-upload/republication is prohibited.
````
