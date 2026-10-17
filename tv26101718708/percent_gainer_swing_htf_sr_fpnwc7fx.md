# Percent Gainer - Swing HTF S/R

- url: https://www.tradingview.com/script/fpNWC7Fx-Percent-Gainer-Swing-HTF-S-R/
- type: indicator
- pine_id: PUB;beec8793548846a0b95929a2e04d13ae
- version: 2.0

## Description

Most multi-timeframe swing S/R tools draw each level from the swing candle, which makes it look like the level existed before it could have been known. Percent Gainer - Swing HTF S/R shows the real timeline: a faint line marks where the swing formed, and a solid line starts only once the swing is confirmed on its own timeframe. Levels from up to five timeframes are non-repainting and always calculated from standard OHLC, even on Heikin Ashi charts.

HOW IT WORKS
For each enabled timeframe, the script finds pivot highs and pivot lows using a Strength setting (the number of bars on each side of the pivot on that timeframe). Each level is offset by a small ATR buffer (ATR Length x ATR Multiple, measured on the pivot's own timeframe) to place the level just beyond the swing extreme.

A swing is only confirmed once Strength bars have closed after it on that timeframe. The script draws this in two parts:
- Faint dotted line: from the swing bar to the confirmation bar. This marks where the swing formed, but the level was not yet known during this period.
- Confirmed line: starts on the first bar after confirmation and extends right until price closes through it, then stops.

Swing highs use solid lines. Swing lows use the line style you choose (dashed by default). The most recent active level for each timeframe is also shown on the price scale.

NON-REPAINTING
Higher-timeframe data is taken only from closed bars of that timeframe. A level never appears from a developing 4H, 1H or 15m bar, so what you see in history is what you would have seen live.

STANDARD CANDLES ONLY
All calculations, including level breaks, use standard OHLC data regardless of chart type. On Heikin Ashi or other non-standard charts, the levels match a regular candlestick chart.

TIMEFRAMES (defaults)
- TF1: 4H (orange)
- TF2: 1H (yellow)
- TF3: 15m (blue)
- TF4: 5m (aqua)
- TF5: chart timeframe (red, off by default)
Each timeframe can be enabled, re-timed and recolored independently.

LOWER TIMEFRAMES ARE NOT SHOWN ON HIGHER TIMEFRAME CHARTS
Levels are only drawn from timeframes equal to or higher than the chart timeframe. Any timeframe lower than the chart is skipped automatically, because lower-timeframe data cannot be requested reliably on a higher-timeframe chart. Examples:
- On a 5m chart: 4H, 1H, 15m and 5m levels are all shown.
- On a 15m chart: 4H, 1H and 15m levels are shown; 5m is hidden.
- On a 1H chart: 4H and 1H levels are shown; 15m and 5m are hidden.
- Above 4H: only the Chart TF levels (TF5) can be shown, if enabled.

SETTINGS
- Confirmed Line Width, Line Style for Swing Lows
- Show Pre-Confirmation Line and its transparency
- Swing High / Swing Low Source (High, Low, Close, HL2, etc.)
- Per timeframe: SH Strength, SL Strength, Color, ATR Length, ATR Multiple

HOW TO USE
Use the higher-timeframe levels as reference zones for reactions, breakouts and targets on a lower-timeframe chart. A level stays active until a close beyond it; broken levels remain on the chart where they ended for context. Higher Strength values produce fewer, more significant swings with a longer confirmation delay.

NOTES
- The pre-confirmation line starts at the open of the higher-timeframe bar containing the swing, not at the exact lower-timeframe candle of the extreme.
- This is a charting tool. It does not generate signals and makes no performance claims.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Straight Line Trades Inc.

//@version=6
indicator("Percent Gainer - Swing HTF S/R", shorttitle = 'PG - Swing HTF', overlay=true, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ======================================================================
//  SHARED STYLE
// ======================================================================
grpStyle     = "Style"
lineWidth    = input.int(1,        "Confirmed Line Width", minval=1, maxval=4, group=grpStyle)
showPending  = input.bool(true,    "Show Pre-Confirmation Line", group=grpStyle, tooltip="Faint dotted line from the swing bar to the bar the swing was confirmed. The bold line starts at confirmation, which is when the level was actually known.")
pendTransp   = input.int(75,       "Pre-Confirmation Transparency", minval=0, maxval=100, group=grpStyle)
lineStyleStr = input.string("Dashed", "Line Style for Swing Lows",     options=["Solid","Dotted","Dashed"], group=grpStyle)
swingHiSrc   = input.string("High",  "Swing High Source", options=["High","Low","Open","Close","HL2","HLC3","OHLC4","HLCC4"], group=grpStyle)
swingLoSrc   = input.string("Low",   "Swing Low Source",  options=["High","Low","Open","Close","HL2","HLC3","OHLC4","HLCC4"], group=grpStyle)

lineStyleResolved = switch lineStyleStr
    "Solid"  => line.style_solid
    "Dotted" => line.style_dotted
    "Dashed" => line.style_dashed
    => line.style_dashed

getSource(src) =>
    switch src
        "High"  => high
        "Low"   => low
        "Open"  => open
        "Close" => close
        "HL2"   => hl2
        "HLC3"  => hlc3
        "OHLC4" => ohlc4
        "HLCC4" => (high + low + close + close) / 4.0
        => close

// Standard (non-HA) OHLC for every calculation, regardless of chart type
stdTicker = ticker.new(syminfo.prefix, syminfo.ticker, syminfo.session)
float stdClose = request.security(stdTicker, timeframe.period, close, lookahead = barmerge.lookahead_off)

// ======================================================================
//  TF1 — 4H  |  Orange
// ======================================================================
grp1       = "TF1 — 4H"
tf1_on     = input.bool(true,   "Enabled",      group=grp1)
tf1_tf     = input.timeframe("240", "  Timeframe", group=grp1)
tf1_shStr  = input.int(7,  "  SH Strength",  minval=1, maxval=90, group=grp1)
tf1_slStr  = input.int(7,  "  SL Strength",  minval=1, maxval=90, group=grp1)
tf1_color  = input.color(color.orange, "  Color", group=grp1)
tf1_atrLen = input.int(14,  "  ATR Length",   minval=1, group=grp1)
tf1_atrMlt = input.float(0, "  ATR Multiple", minval=0.0, step=0.01, group=grp1)

// ======================================================================
//  TF2 — 1H  |  Yellow
// ======================================================================
grp2       = "TF2 — 1H"
tf2_on     = input.bool(true,   "Enabled",      group=grp2)
tf2_tf     = input.timeframe("60",  "  Timeframe", group=grp2)
tf2_shStr  = input.int(10,  "  SH Strength",  minval=1, maxval=90, group=grp2)
tf2_slStr  = input.int(10,  "  SL Strength",  minval=1, maxval=90, group=grp2)
tf2_color  = input.color(color.yellow, "  Color", group=grp2)
tf2_atrLen = input.int(14,  "  ATR Length",   minval=1, group=grp2)
tf2_atrMlt = input.float(0, "  ATR Multiple", minval=0.0, step=0.01, group=grp2)

// ======================================================================
//  TF3 — 15min  |  Blue
// ======================================================================
grp3       = "TF3 — 15min"
tf3_on     = input.bool(true,   "Enabled",      group=grp3)
tf3_tf     = input.timeframe("15",  "  Timeframe", group=grp3)
tf3_shStr  = input.int(10,  "  SH Strength",  minval=1, maxval=90, group=grp3)
tf3_slStr  = input.int(10,  "  SL Strength",  minval=1, maxval=90, group=grp3)
tf3_color  = input.color(color.blue,   "  Color", group=grp3)
tf3_atrLen = input.int(14,  "  ATR Length",   minval=1, group=grp3)
tf3_atrMlt = input.float(0, "  ATR Multiple", minval=0.0, step=0.01, group=grp3)

// ======================================================================
//  TF4 — 5min  |  Aqua
// ======================================================================
grp4       = "TF4 — 5min"
tf4_on     = input.bool(true,   "Enabled",      group=grp4)
tf4_tf     = input.timeframe("5",   "  Timeframe", group=grp4)
tf4_shStr  = input.int(10,  "  SH Strength",  minval=1, maxval=90, group=grp4)
tf4_slStr  = input.int(10,  "  SL Strength",  minval=1, maxval=90, group=grp4)
tf4_color  = input.color(color.aqua,   "  Color", group=grp4)
tf4_atrLen = input.int(14,  "  ATR Length",   minval=1, group=grp4)
tf4_atrMlt = input.float(0, "  ATR Multiple", minval=0.0, step=0.01, group=grp4)

// ======================================================================
//  TF5 — Chart TF  |  Red  (no Timeframe input — always follows chart)
// ======================================================================
grp5       = "TF5 — Chart"
tf5_on     = input.bool(false,   "Enabled",      group=grp5)
tf5_shStr  = input.int(10,  "  SH Strength",  minval=1, maxval=90, group=grp5)
tf5_slStr  = input.int(10,  "  SL Strength",  minval=1, maxval=90, group=grp5)
tf5_color  = input.color(color.red,    "  Color", group=grp5)
tf5_atrLen = input.int(14,  "  ATR Length",   minval=1, group=grp5)
tf5_atrMlt = input.float(0, "  ATR Multiple", minval=0.0, step=0.01, group=grp5)

// ======================================================================
//  NON-REPAINTING SWING LEVELS
//  Evaluated on each TF from standard OHLC. [1] + lookahead_on returns
//  only the last CLOSED bar of that TF, so realtime = history.
//  ATR buffer is taken at the pivot bar, on the pivot's own TF.
// ======================================================================
swingData(int shStr, int slStr, int atrLen, float atrMlt) =>
    float a   = ta.atr(atrLen) * atrMlt
    float shL = ta.pivothigh(getSource(swingHiSrc), shStr, shStr) + a[shStr]
    float slL = ta.pivotlow(getSource(swingLoSrc),  slStr, slStr) - a[slStr]
    [shL[1], slL[1], time[shStr + 1], time[slStr + 1]]

[tf1_sh, tf1_sl, tf1_shT, tf1_slT] = request.security(stdTicker, tf1_tf,           swingData(tf1_shStr, tf1_slStr, tf1_atrLen, tf1_atrMlt), lookahead = barmerge.lookahead_on)
[tf2_sh, tf2_sl, tf2_shT, tf2_slT] = request.security(stdTicker, tf2_tf,           swingData(tf2_shStr, tf2_slStr, tf2_atrLen, tf2_atrMlt), lookahead = barmerge.lookahead_on)
[tf3_sh, tf3_sl, tf3_shT, tf3_slT] = request.security(stdTicker, tf3_tf,           swingData(tf3_shStr, tf3_slStr, tf3_atrLen, tf3_atrMlt), lookahead = barmerge.lookahead_on)
[tf4_sh, tf4_sl, tf4_shT, tf4_slT] = request.security(stdTicker, tf4_tf,           swingData(tf4_shStr, tf4_slStr, tf4_atrLen, tf4_atrMlt), lookahead = barmerge.lookahead_on)
[tf5_sh, tf5_sl, tf5_shT, tf5_slT] = request.security(stdTicker, timeframe.period, swingData(tf5_shStr, tf5_slStr, tf5_atrLen, tf5_atrMlt), lookahead = barmerge.lookahead_on)

// A TF lower than the chart TF can't be requested reliably — skip it
chartSec = timeframe.in_seconds(timeframe.period)
tf1_ok = tf1_on and timeframe.in_seconds(tf1_tf) >= chartSec
tf2_ok = tf2_on and timeframe.in_seconds(tf2_tf) >= chartSec
tf3_ok = tf3_on and timeframe.in_seconds(tf3_tf) >= chartSec
tf4_ok = tf4_on and timeframe.in_seconds(tf4_tf) >= chartSec
tf5_ok = tf5_on

// ======================================================================
//  ACTIVE LINE ARRAYS  (4 arrays per TF × 5 TFs = 20 arrays)
// ======================================================================
var array<line>  tf1_shLines  = array.new_line()
var array<float> tf1_shLevels = array.new_float()
var array<line>  tf1_slLines  = array.new_line()
var array<float> tf1_slLevels = array.new_float()

var array<line>  tf2_shLines  = array.new_line()
var array<float> tf2_shLevels = array.new_float()
var array<line>  tf2_slLines  = array.new_line()
var array<float> tf2_slLevels = array.new_float()

var array<line>  tf3_shLines  = array.new_line()
var array<float> tf3_shLevels = array.new_float()
var array<line>  tf3_slLines  = array.new_line()
var array<float> tf3_slLevels = array.new_float()

var array<line>  tf4_shLines  = array.new_line()
var array<float> tf4_shLevels = array.new_float()
var array<line>  tf4_slLines  = array.new_line()
var array<float> tf4_slLevels = array.new_float()

var array<line>  tf5_shLines  = array.new_line()
var array<float> tf5_shLevels = array.new_float()
var array<line>  tf5_slLines  = array.new_line()
var array<float> tf5_slLevels = array.new_float()

// ======================================================================
//  SWING LINE ENGINE  (one function, called once per TF)
//  Faint dotted: swing bar → confirmation bar (level not yet known)
//  Bold:         confirmation bar → break (level is live)
// ======================================================================
extendOrBreak(array<line> lns, array<float> lvls, bool isHigh) =>
    if array.size(lns) > 0
        for i = array.size(lns) - 1 to 0 by 1
            line  ln  = array.get(lns, i)
            float lvl = array.get(lvls, i)
            line.set_x2(ln, bar_index)
            if isHigh ? stdClose > lvl : stdClose < lvl
                array.remove(lns, i)
                array.remove(lvls, i)

processTF(bool ok, float sh, float sl, int shT, int slT, color col, array<line> shLines, array<float> shLevels, array<line> slLines, array<float> slLevels) =>
    bool newSH = not na(sh) and shT != shT[1]
    bool newSL = not na(sl) and slT != slT[1]
    if ok
        if newSH
            if showPending
                line.new(shT, sh, time, sh, xloc.bar_time, extend.none, color.new(col, pendTransp), line.style_dotted, 1)
            array.push(shLines, line.new(bar_index, sh, bar_index, sh, xloc.bar_index, extend.none, col, line.style_solid, lineWidth))
            array.push(shLevels, sh)
        if newSL
            if showPending
                line.new(slT, sl, time, sl, xloc.bar_time, extend.none, color.new(col, pendTransp), line.style_dotted, 1)
            array.push(slLines, line.new(bar_index, sl, bar_index, sl, xloc.bar_index, extend.none, col, lineStyleResolved, lineWidth))
            array.push(slLevels, sl)
        extendOrBreak(shLines, shLevels, true)
        extendOrBreak(slLines, slLevels, false)

processTF(tf1_ok, tf1_sh, tf1_sl, tf1_shT, tf1_slT, tf1_color, tf1_shLines, tf1_shLevels, tf1_slLines, tf1_slLevels)
processTF(tf2_ok, tf2_sh, tf2_sl, tf2_shT, tf2_slT, tf2_color, tf2_shLines, tf2_shLevels, tf2_slLines, tf2_slLevels)
processTF(tf3_ok, tf3_sh, tf3_sl, tf3_shT, tf3_slT, tf3_color, tf3_shLines, tf3_shLevels, tf3_slLines, tf3_slLevels)
processTF(tf4_ok, tf4_sh, tf4_sl, tf4_shT, tf4_slT, tf4_color, tf4_shLines, tf4_shLevels, tf4_slLines, tf4_slLevels)
processTF(tf5_ok, tf5_sh, tf5_sl, tf5_shT, tf5_slT, tf5_color, tf5_shLines, tf5_shLevels, tf5_slLines, tf5_slLevels)

// ======================================================================
//  PRICE SCALE LABELS  (one pair per TF, hidden when disabled)
// ======================================================================
plot(tf1_on and array.size(tf1_shLevels) > 0 ? array.last(tf1_shLevels) : na, title="4H:SH",    color=tf1_color, display=display.price_scale, style=plot.style_linebr)
plot(tf1_on and array.size(tf1_slLevels) > 0 ? array.last(tf1_slLevels) : na, title="4H:SL",    color=tf1_color, display=display.price_scale, style=plot.style_linebr)
plot(tf2_on and array.size(tf2_shLevels) > 0 ? array.last(tf2_shLevels) : na, title="1H:SH",    color=tf2_color, display=display.price_scale, style=plot.style_linebr)
plot(tf2_on and array.size(tf2_slLevels) > 0 ? array.last(tf2_slLevels) : na, title="1H:SL",    color=tf2_color, display=display.price_scale, style=plot.style_linebr)
plot(tf3_on and array.size(tf3_shLevels) > 0 ? array.last(tf3_shLevels) : na, title="15m:SH",   color=tf3_color, display=display.price_scale, style=plot.style_linebr)
plot(tf3_on and array.size(tf3_slLevels) > 0 ? array.last(tf3_slLevels) : na, title="15m:SL",   color=tf3_color, display=display.price_scale, style=plot.style_linebr)
plot(tf4_on and array.size(tf4_shLevels) > 0 ? array.last(tf4_shLevels) : na, title="5m:SH",    color=tf4_color, display=display.price_scale, style=plot.style_linebr)
plot(tf4_on and array.size(tf4_slLevels) > 0 ? array.last(tf4_slLevels) : na, title="5m:SL",    color=tf4_color, display=display.price_scale, style=plot.style_linebr)
plot(tf5_on and array.size(tf5_shLevels) > 0 ? array.last(tf5_shLevels) : na, title="Chart:SH", color=tf5_color, display=display.price_scale, style=plot.style_linebr)
plot(tf5_on and array.size(tf5_slLevels) > 0 ? array.last(tf5_slLevels) : na, title="Chart:SL", color=tf5_color, display=display.price_scale, style=plot.style_linebr)
````
