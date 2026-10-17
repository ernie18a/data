# HTF Gap Zones + MA Suite

- url: https://www.tradingview.com/script/2gmtMOr6-HTF-Gap-Zones-MA-Suite/
- type: indicator
- pine_id: PUB;8a7ed2574ae24660bf016f5bf98e5d3e
- version: 2.0

## Description

This indicator plots higher-timeframe moving averages and highlights unfilled gap zones directly on your current chart.

It uses a configurable anchor timeframe, such as Daily or Weekly, to calculate EMA and SMA levels while allowing you to view them on lower timeframes. This helps traders keep key higher-timeframe structure visible without constantly switching charts.

The script also scans recent higher-timeframe candles for bullish and bearish gaps. Only unclosed gaps are displayed, making it easier to identify potential areas of interest, imbalance, support, resistance, or price reaction zones.

Features:

Configurable higher-timeframe anchor
Detects bullish and bearish unfilled HTF gaps
Adjustable gap lookback
Custom bullish and bearish gap colors
Five customizable EMAs
Five customizable SMAs
Optional labels for moving averages
Solid, dotted, or dashed visual style
Designed to keep higher-timeframe context visible on intraday charts

This tool is useful for traders who want to combine higher-timeframe structure, gap/imbalance zones, and trend-following moving averages in one clean overlay.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("HTF Levels & Gaps", overlay = true, max_boxes_count = 500)

// --- Constants ---
string G_HTF   = "Timeframe Settings"
string G_GAPS  = "Gap Settings"
string G_EMA   = "EMA Settings"
string G_SMA   = "SMA Settings"
string G_STYLE = "Global Settings"

// --- Inputs ---
string htfInput      = input.timeframe("D", "Anchor Timeframe", group = G_HTF, tooltip = "The timeframe used to calculate levels and gaps (e.g., Daily or Weekly).")
int gapLookbackInput = input.int(30, "Gap Lookback (HTF Bars)", minval = 1, maxval = 200, group = G_GAPS, tooltip = "Number of HTF bars to check for unclosed gaps.")
color bullGapColor   = input.color(color.new(#089981, 80), "Bullish Gap Color", group = G_GAPS, inline = "gap_colors")
color bearGapColor   = input.color(color.new(#f23645, 80), "Bearish Gap Color", group = G_GAPS, inline = "gap_colors")

// EMA Inputs
int emaLen1 = input.int(8, "EMA 1", group = G_EMA, inline = "e1")
color emaCol1 = input.color(#5b9cf6, "", group = G_EMA, inline = "e1")
int emaLen2 = input.int(13, "EMA 2", group = G_EMA, inline = "e2")
color emaCol2 = input.color(#5d606b, "", group = G_EMA, inline = "e2")
int emaLen3 = input.int(21, "EMA 3", group = G_EMA, inline = "e3")
color emaCol3 = input.color(#f23645, "", group = G_EMA, inline = "e3")
int emaLen4 = input.int(50, "EMA 4", group = G_EMA, inline = "e4")
color emaCol4 = input.color(#ff9800, "", group = G_EMA, inline = "e4")
int emaLen5 = input.int(200, "EMA 5", group = G_EMA, inline = "e5")
color emaCol5 = input.color(#9c27b0, "", group = G_EMA, inline = "e5")

// SMA Inputs
int smaLen1 = input.int(5, "SMA 1", group = G_SMA, inline = "s1")
color smaCol1 = input.color(color.new(#5b9cf6, 50), "", group = G_SMA, inline = "s1")
int smaLen2 = input.int(20, "SMA 2", group = G_SMA, inline = "s2")
color smaCol2 = input.color(color.new(#5d606b, 50), "", group = G_SMA, inline = "s2")
int smaLen3 = input.int(50, "SMA 3", group = G_SMA, inline = "s3")
color smaCol3 = input.color(color.new(#f23645, 50), "", group = G_SMA, inline = "s3")
int smaLen4 = input.int(100, "SMA 4", group = G_SMA, inline = "s4")
color smaCol4 = input.color(color.new(#ff9800, 50), "", group = G_SMA, inline = "s4")
int smaLen5 = input.int(200, "SMA 5", group = G_SMA, inline = "s5")
color smaCol5 = input.color(color.new(#9c27b0, 50), "", group = G_SMA, inline = "s5")

string lineStyleInput = input.string("Solid", "MA Line Style", options = ["Solid", "Dotted", "Dashed"], group = G_STYLE)
bool showLabelsInput  = input.bool(true, "Show Labels on MAs", group = G_STYLE, tooltip = "Toggle labels next to the MA lines on the last bar.")

// --- Logic ---

// Fetch HTF Data
[h, l, c, t, e1, e2, e3, e4, e5, s1, s2, s3, s4, s5] = request.security(syminfo.tickerid, htfInput, [
     high, low, close, time,
     ta.ema(close, emaLen1), ta.ema(close, emaLen2), ta.ema(close, emaLen3), ta.ema(close, emaLen4), ta.ema(close, emaLen5),
     ta.sma(close, smaLen1), ta.sma(close, smaLen2), ta.sma(close, smaLen3), ta.sma(close, smaLen4), ta.sma(close, smaLen5)
 ], lookahead = barmerge.lookahead_on)

// Style conversion
get_style(s) =>
    s == "Dotted" ? line.style_dotted : s == "Dashed" ? line.style_dashed : line.style_solid

// Plot MAs
maStyle = get_style(lineStyleInput)
plot(e1, "EMA 1", emaCol1, style = plot.style_linebr)
plot(e2, "EMA 2", emaCol2, style = plot.style_linebr)
plot(e3, "EMA 3", emaCol3, style = plot.style_linebr)
plot(e4, "EMA 4", emaCol4, style = plot.style_linebr, linewidth = 2)
plot(e5, "EMA 5", emaCol5, style = plot.style_linebr, linewidth = 2)

plot(s1, "SMA 1", smaCol1, style = plot.style_linebr)
plot(s2, "SMA 2", smaCol2, style = plot.style_linebr)
plot(s3, "SMA 3", smaCol3, style = plot.style_linebr)
plot(s4, "SMA 4", smaCol4, style = plot.style_linebr, linewidth = 2)
plot(s5, "SMA 5", smaCol5, style = plot.style_linebr, linewidth = 2)

// --- Gap Detection & Management ---
var boxes = array.new_box()

if barstate.islast
    for b in boxes
        box.delete(b)
    array.clear(boxes)

    [hArr, lArr, tArr] = request.security(syminfo.tickerid, htfInput, [
         array.new_float(gapLookbackInput + 1, high), 
         array.new_float(gapLookbackInput + 1, low), 
         array.new_int(gapLookbackInput + 1, time)
     ], lookahead = barmerge.lookahead_on)

    int size = array.size(hArr)
    if size > 1
        for i = 1 to size - 1
            float olderHigh = array.get(hArr, i)
            float olderLow  = array.get(lArr, i)
            float newerHigh = array.get(hArr, i-1)
            float newerLow  = array.get(lArr, i-1)
            int   gapTime   = array.get(tArr, i-1)
            
            bool isBullGap = newerLow > olderHigh
            bool isBearGap = newerHigh < olderLow
            
            if isBullGap or isBearGap
                float top    = isBullGap ? newerLow : olderLow
                float bottom = isBullGap ? olderHigh : newerHigh
                bool  isClosed = false
                
                if i > 1
                    for j = 0 to i - 2
                        float checkHigh = array.get(hArr, j)
                        float checkLow  = array.get(lArr, j)
                        if isBullGap and checkLow <= bottom
                            isClosed := true
                            break
                        if isBearGap and checkHigh >= top
                            isClosed := true
                            break
                
                if not isClosed
                    if isBullGap and low <= bottom
                        isClosed := true
                    else if isBearGap and high >= top
                        isClosed := true

                if not isClosed
                    box b = box.new(gapTime, top, time, bottom, 
                         xloc = xloc.bar_time, 
                         bgcolor = isBullGap ? bullGapColor : bearGapColor, 
                         border_color = color.new(isBullGap ? bullGapColor : bearGapColor, 0),
                         border_style = maStyle)
                    array.push(boxes, b)

// --- MA Labels ---
update_ma_label(lbl, val, txt, col, show) =>
    if show and not na(val)
        if na(lbl)
            label.new(bar_index, val, txt, xloc.bar_index, yloc.price, col, label.style_label_left, color.white, size.small)
        else
            label.set_xy(lbl, bar_index, val)
            label.set_text(lbl, txt)
            lbl
    else
        label.delete(lbl)
        label(na)

var label e1L = na, var label e2L = na, var label e3L = na, var label e4L = na, var label e5L = na
var label s1L = na, var label s2L = na, var label s3L = na, var label s4L = na, var label s5L = na

if barstate.islast
    e1L := update_ma_label(e1L, e1, "EMA " + str.tostring(emaLen1), emaCol1, showLabelsInput)
    e2L := update_ma_label(e2L, e2, "EMA " + str.tostring(emaLen2), emaCol2, showLabelsInput)
    e3L := update_ma_label(e3L, e3, "EMA " + str.tostring(emaLen3), emaCol3, showLabelsInput)
    e4L := update_ma_label(e4L, e4, "EMA " + str.tostring(emaLen4), emaCol4, showLabelsInput)
    e5L := update_ma_label(e5L, e5, "EMA " + str.tostring(emaLen5), emaCol5, showLabelsInput)
    
    s1L := update_ma_label(s1L, s1, "SMA " + str.tostring(smaLen1), smaCol1, showLabelsInput)
    s2L := update_ma_label(s2L, s2, "SMA " + str.tostring(smaLen2), smaCol2, showLabelsInput)
    s3L := update_ma_label(s3L, s3, "SMA " + str.tostring(smaLen3), smaCol3, showLabelsInput)
    s4L := update_ma_label(s4L, s4, "SMA " + str.tostring(smaLen4), smaCol4, showLabelsInput)
    s5L := update_ma_label(s5L, s5, "SMA " + str.tostring(smaLen5), smaCol5, showLabelsInput)
````
