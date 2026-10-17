# THE 4TH DESK

- url: https://www.tradingview.com/script/IFiROk34-THE-4TH-DESK/
- type: indicator
- pine_id: PUB;62fa1be157a9471fb456170ba1b4b5bf
- version: 8.0

## Description

Watermark + ATR + 4 EMA
A three-in-one overlay indicator combining a chart watermark, an ATR-based stop-loss reference, and a four-line EMA ribbon — each independently configurable and toggleable.
Watermark
Displays the current symbol, exchange prefix, timeframe, and (optionally) percentage change in a customizable table anchored to any corner or edge of the chart. Includes an editable signature/branding field, adjustable text sizes, and a custom color with transparency support.
ATR Value Table
Calculates Average True Range (length and smoothing method both configurable — RMA, SMA, EMA, or WMA) multiplied by a user-defined multiplier, useful for setting stop-loss distances. Shown in its own bordered table, positioned and styled independently from the watermark.
4 EMA Ribbon
Plots four exponential moving averages (default periods: 13, 34, 55, 200) on the price chart, each with its own configurable length and color — useful for trend identification and dynamic support/resistance.
All three components have their own input group in the settings panel (Watermark / ATR / 4 EMA), so you can enable, disable, or restyle each piece independently without affecting the others.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Watermark portion © ashezpow, ATR portion © PriceCatch, EMA portion adapted from original v2 script — combined indicator

//@version=6
indicator("Watermark + ATR + 4 EMA", shorttitle="THE FOURTH DESK", overlay=true)

// ============================= DISPLAY TOGGLES =============================
g_display = "Display"
showWatermark = input.bool(true, "Show Watermark", group = g_display)
showATR = input.bool(true, "Show ATR table", group = g_display)
showEMAs = input.bool(true, "Show EMAs", group = g_display)

// ============================= WATERMARK =============================
showTF = input.bool(true, "show time frame", inline = "24", group = "Watermark")
showpf = input.bool(true, "show prefix", inline = "24", group = "Watermark")
showchange = input.bool(false, "show change %", inline = "24", group = "Watermark")
i_tableYpos = input.string("bottom", "Position", inline = "12", options = ["top", "middle", "bottom"], group = "Watermark")
i_tableXpos = input.string("right", "", inline = "12", options = ["left", "center", "right"], group = "Watermark")
size1 = input.string("huge", "title", inline = "14", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "Watermark")
size3 = input.string("large", "change", inline = "14", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "Watermark")
size2 = input.string("small", "signature", inline = "14", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = "Watermark")
mainColor = input.color(#ffffff77, "color", group = "Watermark")
signature = input.string("by you", "your signature", group = "Watermark")
separator = input.string("/", "seperator", group = "Watermark")

changeClose = request.security(syminfo.tickerid, timeframe.period, close)

cur = syminfo.currency
base = syminfo.basecurrency
exchange = syminfo.prefix

getTimeFrame() =>
    int tf = timeframe.multiplier
    string tfstr = ""
    if timeframe.isseconds
        tfstr := "s"
    if timeframe.isminutes
        if tf >= 60
            tf := int(tf / 60)
            tfstr := "h"
        else
            tfstr := "m"
    if timeframe.isdaily
        tfstr := "D"
    if timeframe.isweekly
        tfstr := "W"
    if timeframe.ismonthly
        tfstr := "M"
    [tfstr, str.tostring(tf)]

var table watermarkTable = table.new(i_tableYpos + "_" + i_tableXpos, 4, 1)

if barstate.islast and showWatermark
    str1 = base != "" ? base + separator + cur : syminfo.ticker
    [tf, period] = getTimeFrame()
    change = math.round(((changeClose / changeClose[1]) - 1) * 100, 2)
    changeStr = change > 0 ? "▲" + str.tostring(math.abs(change)) + "%" : "▼" + str.tostring(math.abs(change)) + "%"

    table.cell(watermarkTable, 0, 0, showpf ? exchange : "", text_color = mainColor, width=0, text_size=size2)
    table.cell(watermarkTable, 1, 0, str1 + (showTF ? (" " + period + tf) : ""), width=0, text_color = mainColor, text_size=size1)
    table.cell(watermarkTable, 2, 0, showchange ? changeStr : "", width=0, text_color = change > 0 ? color.green : color.red, text_size=size3)
    table.cell(watermarkTable, 3, 0, signature, text_color = mainColor, width=0, text_size=size2)
else if barstate.islast and not showWatermark
    table.clear(watermarkTable, 0, 0, 3, 0)

// ================================ ATR =================================
atrLength = input.int(14, title="ATR Period", minval=1, group = "ATR")
smoothing = input.string(title="Smoothing", defval="RMA", options=["RMA", "SMA", "EMA", "WMA"], group = "ATR")
atrmultiplier = input.float(title="ATR Multiplier", defval=0.5, minval=.01, maxval=100, step=0.05, group = "ATR")

ma_function(source, len) =>
    result = switch smoothing
        "RMA" => ta.rma(source, len)
        "SMA" => ta.sma(source, len)
        "EMA" => ta.ema(source, len)
        "WMA" => ta.wma(source, len)
        => ta.rma(source, len)
    result

catr = ma_function(ta.tr(true), atrLength)
atrVal = catr * atrmultiplier

tblPos = input.string(title="Position on Chart", defval="Top Right", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Left", "Middle Right"], group = "ATR")
tblposition = tblPos == "Top Left" ? position.top_left : tblPos == "Top Right" ? position.top_right : tblPos == "Bottom Left" ? position.bottom_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Middle Left" ? position.middle_left : position.middle_right

tblBorderColor = input(title="Border Color", defval=#636363, group = "ATR")
cellBgColor = input(title="Background Color", defval=#ffffff, group = "ATR")
cellTextColor = input(title="Text Color", defval=#000000, group = "ATR")

var table atrTable = table.new(position=tblposition, columns=1, rows=1, bgcolor=#ffffff, border_width=1, frame_color=tblBorderColor, frame_width=4)

if barstate.islast
    table.clear(atrTable, 0, 0)
    if showATR
        table.cell(atrTable, column=0, row=0, text="ATR Value: " + str.tostring(atrVal, format.mintick), text_color=cellTextColor, text_halign=text.align_right, text_valign=text.align_center, bgcolor=cellBgColor)

// ============================== 4 EMA ==================================
emaSrc = input.source(close, title="Source", group = "4 EMA")

showEma1 = input.bool(true, title="", inline="ema1", group = "4 EMA")
emaLen1 = input.int(13, title="EMA-1", inline="ema1", group = "4 EMA")

showEma2 = input.bool(true, title="", inline="ema2", group = "4 EMA")
emaLen2 = input.int(34, title="EMA-2", inline="ema2", group = "4 EMA")

showEma3 = input.bool(true, title="", inline="ema3", group = "4 EMA")
emaLen3 = input.int(55, title="EMA-3", inline="ema3", group = "4 EMA")

showEma4 = input.bool(true, title="", inline="ema4", group = "4 EMA")
emaLen4 = input.int(200, title="EMA-4", inline="ema4", group = "4 EMA")

pema1 = ta.ema(emaSrc, emaLen1)
pema2 = ta.ema(emaSrc, emaLen2)
pema3 = ta.ema(emaSrc, emaLen3)
pema4 = ta.ema(emaSrc, emaLen4)

plot(showEMAs and showEma1 ? pema1 : na, title="EMA-1", color=color.aqua)
plot(showEMAs and showEma2 ? pema2 : na, title="EMA-2", color=color.blue)
plot(showEMAs and showEma3 ? pema3 : na, title="EMA-3", color=color.black)
plot(showEMAs and showEma4 ? pema4 : na, title="EMA-4", color=color.orange)

// ============================ EMA BREAKS ================================
g_break = "EMA Breaks"

showEmaBreak = input.bool(true, "Color candles on EMA break", group = g_break)

// ========================================================================
// TIMEFRAME FOR CANDLE COLORING
// ========================================================================

// Enable/disable timeframe filtering
useBreakTimeframe = input.bool(
     false,
     "Use custom timeframe",
     group = g_break,
     tooltip = "When enabled, EMA-break candles are colored only when the chart is on the selected timeframe."
)

// Custom timeframe interval
breakColorTimeframe = input.timeframe(
     "15",
     "Color candles timeframe",
     group = g_break,
     tooltip = "The chart timeframe on which EMA-break candle colors will be displayed. Examples: 3, 5, 15, 45, 60, 120, 240, D, W."
)

breakEmaSelect = input.string(
     defval="EMA-1",
     options=["EMA-1", "EMA-2", "EMA-3", "EMA-4"],
     title="Break using",
     group = g_break)

breakUpColor = input.color(color.green, "Close above color", group = g_break)
breakDownColor = input.color(color.red, "Close below color", group = g_break)


// ======================== TIMEFRAME FILTER =============================

// Convert both timeframes to seconds.
// This makes equivalent timeframe formats match correctly.
chartTfSeconds = timeframe.in_seconds()
breakTfSeconds = timeframe.in_seconds(breakColorTimeframe)

// If custom timeframe is disabled, allow coloring on current chart timeframe.
// If enabled, only allow coloring on the selected timeframe.
showBreakOnTimeframe = not useBreakTimeframe or chartTfSeconds == breakTfSeconds


// ========================== EMA BREAK LOGIC =============================

breakEmaValue = switch breakEmaSelect
    "EMA-1" => pema1
    "EMA-2" => pema2
    "EMA-3" => pema3
    "EMA-4" => pema4
    => pema1

// Only flag the FIRST candle that closes above/below the EMA
closedAbove = close > breakEmaValue
closedBelow = close < breakEmaValue

firstCloseAbove = closedAbove and not closedAbove[1]
firstCloseBelow = closedBelow and not closedBelow[1]

// Trend filter using EMA-4
trendUpFilter = close > pema4
trendDownFilter = close < pema4

showCloseAbove = firstCloseAbove and trendUpFilter
showCloseBelow = firstCloseBelow and trendDownFilter


// ========================= CANDLE COLOR ================================

// Apply the timeframe filter to the existing EMA-break logic.
emaBreakColor = showBreakOnTimeframe ?
     (showCloseAbove ? breakUpColor :
     showCloseBelow ? breakDownColor :
     na) :
     na

barcolor(showEmaBreak ? emaBreakColor : na)
````
