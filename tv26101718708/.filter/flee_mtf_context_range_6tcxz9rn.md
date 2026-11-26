# FLEE MTF Context & Range

- url: https://www.tradingview.com/script/6tcxz9RN-FLEE-MTF-Context-Range/
- type: indicator
- pine_id: PUB;294521e96aab4b06a9e5ba896a1abaf2
- version: 1.0

## Description

This indicator is a multi-timeframe market context tool. Its job is to help you quickly understand what the market is doing across multiple timeframes and what range price is currently trading inside.

It shows a context table in the top-right corner of the chart. That table tells you the trend direction for the 4H, 1H, 15M, and 5M timeframes. Each timeframe will show whether price is bullish, bearish, or neutral.

At the top of the table, it also shows the Daily overall bias. The daily bias is the main direction of the market, so you can quickly see whether the bigger picture is leaning bullish or bearish before taking trades on the lower timeframes.

The indicator also identifies the current range price is moving inside. When price is consolidating or trading between a high and a low, the indicator draws a transparent box around that range. The top of the box marks the range high, and the bottom marks the range low.

Inside the range box, the indicator draws a dotted 50% median line. This helps you see whether price is trading in the upper half or lower half of the range. The median can help with bias, entries, and understanding whether price is closer to premium or discount.

The indicator updates as the market moves. When a new range forms, the old range can disappear or stay depending on the settings. You can customize the colors, transparency, labels, timeframe options, and how sensitive the range detection is.

In simple words: this indicator tells you the trend on the higher and lower timeframes, gives you the daily bias, and visually marks the current price range with a 50% line so you can make cleaner trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("MTF Context & Range", overlay = true, max_boxes_count = 100, max_lines_count = 100, max_labels_count = 100)

// --- Groups ---
string G_TREND = "Trend Context Settings"
string G_RANGE = "Range Detection Settings"
string G_STYLE = "Style & Visuals"

// --- Inputs: Trend Context ---
bool show4H      = input.bool(true, "Show 4H Trend", group = G_TREND)
bool show1H      = input.bool(true, "Show 1H Trend", group = G_TREND)
bool show15M     = input.bool(true, "Show 15M Trend", group = G_TREND)
bool show5M      = input.bool(true, "Show 5M Trend", group = G_TREND)
bool showDaily   = input.bool(true, "Show Daily Bias", group = G_TREND)
string tablePos  = input.string("top_right", "Table Position", options = ["top_right", "bottom_right", "top_left", "bottom_left"], group = G_TREND)
string textSize  = input.string("small", "Text Size", options = ["tiny", "small", "normal", "large"], group = G_TREND)
color bullColor  = input.color(#089981, "Bullish Color", group = G_TREND)
color bearColor  = input.color(#f23645, "Bearish Color", group = G_TREND)
color neutColor  = input.color(#787b86, "Neutral Color", group = G_TREND)
int tableTransp  = input.int(20, "Background Transparency", minval = 0, maxval = 100, group = G_TREND)

// --- Inputs: Range Detection ---
int pivotLen     = input.int(10, "Range Sensitivity (Pivot Lookback)", minval = 2, tooltip = "Number of bars required to confirm a swing high/low.", group = G_RANGE)
bool showMedian  = input.bool(true, "Show 50% Median Line", group = G_RANGE)
bool showLabels  = input.bool(true, "Show Range Labels", group = G_RANGE)
bool extendRight = input.bool(true, "Extend Range Box to Right", group = G_RANGE)

// --- Inputs: Style ---
color rangeColor = input.color(color.new(#5b9cf6, 85), "Range Box Color", group = G_STYLE)
color medianCol  = input.color(color.gray, "Median Line Color", group = G_STYLE)
string medStyle  = input.string("Dotted", "Median Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_STYLE)

// --- Trend Calculation Logic ---
// We use price relative to EMA and EMA slope to determine trend
get_trend_data() =>
    ema50 = ta.ema(close, 50)
    ema20 = ta.ema(close, 20)
    trend = 0 // 1: Bull, -1: Bear, 0: Neutral
    if ema20 > ema50 and close > ema50
        trend := 1
    else if ema20 < ema50 and close < ema50
        trend := -1
    else
        trend := 0
    trend

// Requesting MTF Data
t_5m  = request.security(syminfo.tickerid, "5", get_trend_data())
t_15m = request.security(syminfo.tickerid, "15", get_trend_data())
t_1h  = request.security(syminfo.tickerid, "60", get_trend_data())
t_4h  = request.security(syminfo.tickerid, "240", get_trend_data())
t_1d  = request.security(syminfo.tickerid, "D", get_trend_data())

// --- Table Visualization ---
var table contextTable = table.new(
     tablePos == "top_right" ? position.top_right : 
     tablePos == "bottom_right" ? position.bottom_right : 
     tablePos == "top_left" ? position.top_left : position.bottom_left, 
     2, 6, color.new(chart.bg_color, tableTransp), color.gray, 1, color.gray, 1
 )

get_status_text(t) => t == 1 ? "Bullish" : t == -1 ? "Bearish" : "Neutral"
get_status_color(t) => t == 1 ? bullColor : t == -1 ? bearColor : neutColor
get_size(s) => s == "tiny" ? size.tiny : s == "small" ? size.small : s == "normal" ? size.normal : size.large

if barstate.islast
    int row = 0
    
    // Header/Daily Bias
    if showDaily
        table.cell(contextTable, 0, row, "Daily Bias", text_color = chart.fg_color, text_size = get_size(textSize), bgcolor = color.new(chart.fg_color, 90))
        table.cell(contextTable, 1, row, get_status_text(t_1d), text_color = get_status_color(t_1d), text_size = get_size(textSize), bgcolor = color.new(get_status_color(t_1d), 85))
        row += 1

    if show4H
        table.cell(contextTable, 0, row, "4H Context", text_color = chart.fg_color, text_size = get_size(textSize))
        table.cell(contextTable, 1, row, get_status_text(t_4h), text_color = get_status_color(t_4h), text_size = get_size(textSize))
        row += 1
        
    if show1H
        table.cell(contextTable, 0, row, "1H Context", text_color = chart.fg_color, text_size = get_size(textSize))
        table.cell(contextTable, 1, row, get_status_text(t_1h), text_color = get_status_color(t_1h), text_size = get_size(textSize))
        row += 1

    if show15M
        table.cell(contextTable, 0, row, "15M Context", text_color = chart.fg_color, text_size = get_size(textSize))
        table.cell(contextTable, 1, row, get_status_text(t_15m), text_color = get_status_color(t_15m), text_size = get_size(textSize))
        row += 1

    if show5M
        table.cell(contextTable, 0, row, "5M Context", text_color = chart.fg_color, text_size = get_size(textSize))
        table.cell(contextTable, 1, row, get_status_text(t_5m), text_color = get_status_color(t_5m), text_size = get_size(textSize))
        row += 1

// --- Range Detection ---
var float rangeHigh = na
var float rangeLow  = na
var int rangeStart  = na

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

if not na(ph)
    rangeHigh := ph
    rangeStart := bar_index - pivotLen
if not na(pl)
    rangeLow := pl
    rangeStart := bar_index - pivotLen

// --- Range Visuals ---
var box rangeBox = na
var line medianLine = na
var label hiLabel = na
var label loLabel = na
var label midLabel = na

// Clean up previous objects (showing only active range)
if barstate.islast and not na(rangeHigh) and not na(rangeLow)
    box.delete(rangeBox)
    line.delete(medianLine)
    label.delete(hiLabel)
    label.delete(loLabel)
    label.delete(midLabel)
    
    lineStyle = medStyle == "Solid" ? line.style_solid : medStyle == "Dashed" ? line.style_dashed : line.style_dotted
    medianVal = math.avg(rangeHigh, rangeLow)
    rightIndex = extendRight ? bar_index + 10 : bar_index
    
    // Create Box
    rangeBox := box.new(rangeStart, rangeHigh, rightIndex, rangeLow, 
         bgcolor = rangeColor, 
         border_color = color.new(rangeColor, 30), 
         extend = extendRight ? extend.right : extend.none)
    
    // Create Median Line
    if showMedian
        medianLine := line.new(rangeStart, medianVal, rightIndex, medianVal, 
             color = medianCol, 
             style = lineStyle, 
             extend = extendRight ? extend.right : extend.none)
    
    // Create Labels
    if showLabels
        hiLabel := label.new(rightIndex, rangeHigh, "Range High", color = #00000000, textcolor = chart.fg_color, style = label.style_label_left, size = size.small)
        loLabel := label.new(rightIndex, rangeLow, "Range Low", color = #00000000, textcolor = chart.fg_color, style = label.style_label_left, size = size.small)
        if showMedian
            midLabel := label.new(rightIndex, medianVal, "50% Median", color = #00000000, textcolor = chart.fg_color, style = label.style_label_left, size = size.small)
````
