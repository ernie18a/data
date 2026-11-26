# Order Blocking The Island + High Volume

- url: https://www.tradingview.com/script/9j9551C7-Order-Blocking-The-Island-High-Volume/
- type: indicator
- pine_id: PUB;feba6470220c4c76b9cedac842a5a591
- version: 1.0

## Description

VERY IMPORTANT!!!!!!!

This indicator is not your ordinary Order Block indicator.

I built this with the complete opposite to the original plan because nothing is what it seems to be when it comes to the market.

This was constructed around an Order Block price range ( ZONE ). That when this range has been completely overtaken by the opposing side ( BUYERS vs SELLS ), extream volatility comes in to the market for a small time window of opportunity that we as SCALPERS will surely enjoy.

I ask that you trade well and enjoy.

And like always, do back test or paper trade to get a full understanding on how it works.

Happy Trading!!!

## Source Code

````pine
//@version=6
indicator("Order Blocking The Island + High Volume", overlay=true, max_boxes_count=500, max_labels_count=500)

// DISCLAIMER: This code is for educational and testing purposes only.
// Not a financial advice.
// Past performance in backtests does not guarantee future results.
// Always verify code logic and test on a demo account before use.

// === INPUTS ===
string GRP_SWING = "Swing Detection"
string GRP_VOL   = "Volume Filter"
string GRP_DISP  = "Display"
string GRP_COL   = "Colors"
string GRP_DIR   = "Direction"
string GRP_MRK   = "Markers"
string GRP_ATR     = "ATR Window"
string GRP_SIGNALS = "Signals"
string GRP_MA      = "Moving Averages"

int   leftBars  = input.int(5,   "Pivot Left Bars",             minval=1,             group=GRP_SWING)
int   rightBars = input.int(5,   "Pivot Right Bars",            minval=1,             group=GRP_SWING)
int   volPct    = input.int(90,  "Volume Percentile Threshold", minval=1, maxval=100, group=GRP_VOL)
int   volLen    = input.int(100, "Volume Lookback",             minval=1,             group=GRP_VOL)
int   extLen    = input.int(50,  "Extend Length (bars)",        minval=1,             group=GRP_DISP)
bool  fullExt   = input.bool(true, "Full Extension (to right)",                       group=GRP_DISP)
bool  mit       = input.bool(true, "Enable Mitigation",                              group=GRP_DISP)
int   cleanupBars = input.int(7, "Remove Mitigated After (bars)", minval=1,           group=GRP_DISP)
color bullCol   = input.color(color.green, "Bullish OB Color",                       group=GRP_COL)
color bearCol   = input.color(color.red,   "Bearish OB Color",                       group=GRP_COL)
color mitCol    = input.color(color.gray,  "Mitigated Color",                        group=GRP_COL)
bool  showBull  = input.bool(true, "Show Bullish OBs",                               group=GRP_DIR)
bool  showBear  = input.bool(true, "Show Bearish OBs",                               group=GRP_DIR)
bool  showMrk   = input.bool(true, "Show Triangle Markers",                          group=GRP_MRK)
bool  showATR   = input.bool(true, "Show ATR Window",                                 group=GRP_ATR)
int   atrLen    = input.int(14,    "ATR Length",                  minval=1,           group=GRP_ATR)
color atrCol    = input.color(color.orange, "ATR Color",                              group=GRP_ATR)
string atrSize  = input.string("Normal", "ATR Text Size", options=["Tiny","Small","Normal","Large","Huge"], group=GRP_ATR)
color buySignalCol = input.color(color.lime, "Buy Signal Color",  group=GRP_SIGNALS)
color sellSignalCol = input.color(color.red,  "Sell Signal Color", group=GRP_SIGNALS)
bool  showWmaFast = input.bool(true, "Show WMA Fast",                          group=GRP_MA)
int   wmaFastLen  = input.int(15,    "WMA Fast Length",  minval=1,            group=GRP_MA)
color wmaFastCol  = input.color(color.blue,  "WMA Fast Color",                group=GRP_MA)
bool  showWmaSlow = input.bool(true, "Show WMA Slow",                          group=GRP_MA)
int   wmaSlowLen  = input.int(50,    "WMA Slow Length",  minval=1,            group=GRP_MA)
color wmaSlowCol  = input.color(color.purple, "WMA Slow Color",                group=GRP_MA)

// === PIVOT DETECTION ===
float pl = ta.pivotlow(low,  leftBars, rightBars)
float ph = ta.pivothigh(high, leftBars, rightBars)

// Volume percentile threshold computed on every bar so we can look back at the
// historical value when an OB candle is confirmed by a pivot.
float volThresh = ta.percentile_nearest_rank(volume, volLen, volPct)

// ATR for the price-chart window
float atrVal = ta.atr(atrLen)

// Weighted moving averages for the price chart
float wmaFast = ta.wma(close, wmaFastLen)
float wmaSlow = ta.wma(close, wmaSlowLen)

// === STORAGE FOR MITIGATION TRACKING ===
var box[]   bullBoxes    = array.new_box()
var float[] bullOBLows   = array.new_float()
var bool[]  bullMitFlag  = array.new_bool()
var int[]   bullMitBar   = array.new_int()
var box[]   bearBoxes    = array.new_box()
var float[] bearOBHighs  = array.new_float()
var bool[]  bearMitFlag  = array.new_bool()
var int[]   bearMitBar   = array.new_int()

// Maximum bars to look back from a pivot when searching for the OB candle
const int SEARCH_MAX = 50

// === BULLISH OB DETECTION ===
// Last bearish candle before a confirmed swing low forms a bullish Order Block
if not na(pl)
    int   obBar = na
    float obH   = na
    float obL   = na
    for i = 1 to SEARCH_MAX
        if close[i + rightBars] < open[i + rightBars]
            obBar := bar_index - i - rightBars
            obH   := high[i + rightBars]
            obL   := low[i + rightBars]
            break
    if not na(obBar)
        int ago = bar_index - obBar
        if volume[ago] >= volThresh[ago]
            if showBull
                box bx = box.new(obBar, obH, obBar + extLen, obL,
                     border_color=bullCol, bgcolor=color.new(bullCol, 85),
                     border_width=1, border_style=line.style_solid)
                if fullExt
                    box.set_extend(bx, extend.right)
                array.push(bullBoxes, bx)
                array.push(bullOBLows, obL)
                array.push(bullMitFlag, false)
                array.push(bullMitBar, 0)
                if showMrk
                    label.new(obBar, na, "▲", xloc.bar_index, yloc.abovebar,
                         textcolor=bullCol, style=label.style_none, size=size.small)

// === BEARISH OB DETECTION ===
// Last bullish candle before a confirmed swing high forms a bearish Order Block
if not na(ph)
    int   obBar = na
    float obH   = na
    float obL   = na
    for i = 1 to SEARCH_MAX
        if close[i + rightBars] > open[i + rightBars]
            obBar := bar_index - i - rightBars
            obH   := high[i + rightBars]
            obL   := low[i + rightBars]
            break
    if not na(obBar)
        int ago = bar_index - obBar
        if volume[ago] >= volThresh[ago]
            if showBear
                box bx = box.new(obBar, obH, obBar + extLen, obL,
                     border_color=bearCol, bgcolor=color.new(bearCol, 85),
                     border_width=1, border_style=line.style_solid)
                if fullExt
                    box.set_extend(bx, extend.right)
                array.push(bearBoxes, bx)
                array.push(bearOBHighs, obH)
                array.push(bearMitFlag, false)
                array.push(bearMitBar, 0)
                if showMrk
                    label.new(obBar, na, "▼", xloc.bar_index, yloc.belowbar,
                         textcolor=bearCol, style=label.style_none, size=size.small)

// === MITIGATION ===
// A bullish OB is mitigated when price closes below its low; a bearish OB when close exceeds its high
// sellSignal fires when a bullish OB is mitigated (close < its low) - contrarian sell
// buySignal fires when a bearish OB is mitigated (close > its high) - contrarian buy
bool sellSignal = false
bool buySignal  = false
if mit
    if array.size(bullBoxes) > 0
        for i = 0 to array.size(bullBoxes) - 1
            if not array.get(bullMitFlag, i)
                if close < array.get(bullOBLows, i)
                    box bx = array.get(bullBoxes, i)
                    box.set_border_color(bx, mitCol)
                    box.set_bgcolor(bx, color.new(mitCol, 85))
                    array.set(bullMitFlag, i, true)
                    array.set(bullMitBar, i, bar_index)
                    sellSignal := true
    if array.size(bearBoxes) > 0
        for i = 0 to array.size(bearBoxes) - 1
            if not array.get(bearMitFlag, i)
                if close > array.get(bearOBHighs, i)
                    box bx = array.get(bearBoxes, i)
                    box.set_border_color(bx, mitCol)
                    box.set_bgcolor(bx, color.new(mitCol, 85))
                    array.set(bearMitFlag, i, true)
                    array.set(bearMitBar, i, bar_index)
                    buySignal := true

    // Remove mitigated OBs after cleanupBars bars have passed since mitigation
    if array.size(bullBoxes) > 0
        for i = array.size(bullBoxes) - 1 to 0
            if array.get(bullMitFlag, i) and bar_index - array.get(bullMitBar, i) >= cleanupBars
                box.delete(array.get(bullBoxes, i))
                array.remove(bullBoxes, i)
                array.remove(bullOBLows, i)
                array.remove(bullMitFlag, i)
                array.remove(bullMitBar, i)
    if array.size(bearBoxes) > 0
        for i = array.size(bearBoxes) - 1 to 0
            if array.get(bearMitFlag, i) and bar_index - array.get(bearMitBar, i) >= cleanupBars
                box.delete(array.get(bearBoxes, i))
                array.remove(bearBoxes, i)
                array.remove(bearOBHighs, i)
                array.remove(bearMitFlag, i)
                array.remove(bearMitBar, i)

// === ATR WINDOW ===
// Single-cell table in the bottom-right corner of the chart viewport.
// The table is created once with `var` so the cell is reused on every bar
// instead of being re-allocated each tick. Only the cell text is updated.
var table atrTbl = table.new(position.bottom_right, 1, 1, border_width=0)
// Map the user's "Tiny/Small/Normal/Large/Huge" choice to the matching size.* constant
atrTextSize = atrSize == "Tiny"   ? size.tiny   :
              atrSize == "Small"  ? size.small  :
              atrSize == "Large"  ? size.large  :
              atrSize == "Huge"   ? size.huge   : size.normal
if showATR
    table.cell(atrTbl, 0, 0, "ATR: " + str.tostring(atrVal, "#.####"),
         text_color=atrCol, text_size=atrTextSize,
         text_font_family=font.family_monospace)

// === SIGNALS ===
// Buy signal: bearish OB mitigated (close > its high) - contrarian bullish breakout
// Sell signal: bullish OB mitigated (close < its low) - contrarian bearish breakdown
// Gated by mit and barstate.isconfirmed so the shape only paints at candle close
plotshape(mit and buySignal  and barstate.isconfirmed, "Bearish OB Mitigated (Buy)",  shape.triangleup,   location.belowbar, color=buySignalCol,  size=size.small)
plotshape(mit and sellSignal and barstate.isconfirmed, "Bullish OB Mitigated (Sell)", shape.triangledown, location.abovebar, color=sellSignalCol, size=size.small)

// === MOVING AVERAGES ===
// Two weighted moving averages drawn directly on the price chart.
// Each plot is gated by its Show toggle; no fill, crossover, or alert
// is added so the price line is not crowded.
plot(showWmaFast ? wmaFast : na, "WMA Fast", color=wmaFastCol, linewidth=1)
plot(showWmaSlow ? wmaSlow : na, "WMA Slow", color=wmaSlowCol, linewidth=1)
````
