<!-- tradingview-pine-id: PUB;63356301a75649d1aab306457dfe7819 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-HTF Candle Dashboard [Quantum Edge]

Source: https://www.tradingview.com/script/qfvSNrla-HTF-Candle-Projection-Dashboard-Quantum-Edge/

## Description

HTF Candle Projection Dashboard [Quantum Edge] projects multiple higher-timeframe candle structures directly onto your active chart.

Instead of switching between timeframes, the indicator displays the latest six candles from five configurable higher timeframes in a clean, forward-projected dashboard:

• 1 Hour
• 4 Hour
• Daily
• Weekly
• Monthly

Each timeframe group contains five historical candles plus the current developing candle. The live candle updates as new price data becomes available, allowing traders to monitor higher-timeframe range, direction, and key OHLC levels while executing from a lower timeframe.

FEATURES
• Displays five independently configurable higher timeframes
• Shows six candles per timeframe: five completed candles and one live candle
• Projects all higher-timeframe candle groups to the right of current price action
• Uses true chart prices—no normalized or synthetic price scale
• Bullish and bearish candle coloring
• Adjustable live and historical candle transparency
• Optional timeframe headers
• Optional Open, High, Low, and Close labels for each live HTF candle
• Adjustable right offset, candle width, candle spacing, and group spacing
• Designed for clean multi-timeframe context on intraday execution charts

HOW TO USE
1. Apply the indicator to a lower-timeframe chart.
2. Choose the higher timeframes you want to track in the settings.
3. Use the projected candle groups to identify higher-timeframe direction, current range position, prior highs/lows, and developing candle behavior.
4. Combine the dashboard with your preferred market-structure, support/resistance, volume, or execution model.

EXAMPLE WORKFLOW
A trader using a 1-minute or 5-minute chart can keep the 1H, 4H, Daily, Weekly, and Monthly candles visible at once. This makes it easier to see whether a lower-timeframe move is occurring near a higher-timeframe high, low, open, or close—without leaving the execution chart.

NOTES
• The rightmost candle in each group is the currently developing higher-timeframe candle, so its high, low, close, color, and OHLC labels can change until that timeframe closes.
• For the clearest results, use the script on a chart timeframe lower than the smallest selected dashboard timeframe.
• This is a visual analysis tool, not a trading strategy and not financial advice.

Created by Quantum Edge.

---

## Source Code

````pine
// © Quantum Edge
//@version=6
indicator(
     "Multi-HTF Candle Dashboard [Quantum Edge]",
     shorttitle = "HTF Dashboard",
     overlay = true,
     max_boxes_count = 100,
     max_lines_count = 100,
     max_labels_count = 100
)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
string TF_GROUP = "Higher Timeframe Rows"

string tf1 = input.timeframe("60",  "Row 1 — 1 Hour",  group = TF_GROUP)
string tf2 = input.timeframe("240", "Row 2 — 4 Hour",  group = TF_GROUP)
string tf3 = input.timeframe("D",   "Row 3 — Daily",   group = TF_GROUP)
string tf4 = input.timeframe("W",   "Row 4 — Weekly",  group = TF_GROUP)
string tf5 = input.timeframe("M",   "Row 5 — Monthly", group = TF_GROUP)

string LAYOUT_GROUP = "Dashboard Layout"

int rightOffset = input.int(15, "Right Offset", minval = 5, maxval = 80, group = LAYOUT_GROUP)
int candleWidth = input.int(5, "Candle Width", minval = 2, maxval = 8, group = LAYOUT_GROUP)
int candleGap = input.int(3, "Candle Gap", minval = 1, maxval = 5, group = LAYOUT_GROUP)
int groupGap = input.int(10, "Timeframe Group Gap", minval = 3, maxval = 20, group = LAYOUT_GROUP)

string STYLE_GROUP = "Style"

color bullColor = input.color(#089981, "Bullish Color", group = STYLE_GROUP)
color bearColor = input.color(#F23645, "Bearish Color", group = STYLE_GROUP)
color neutralColor = input.color(#787B86, "Header Color", group = STYLE_GROUP)

int liveTransparency = input.int(0, "Live Candle Transparency", minval = 0, maxval = 100, group = STYLE_GROUP)
int historyTransparency = input.int(78, "Historical Candle Transparency", minval = 0, maxval = 100, group = STYLE_GROUP)

bool showHeaders = input.bool(true, "Show Timeframe Headers", group = STYLE_GROUP)
bool showOHLC = input.bool(true, "Show Live Candle OHLC", group = STYLE_GROUP)

//──────────────────────────────────────────────────────────────────────────────
// Stored drawing objects for redraw cleanup
//──────────────────────────────────────────────────────────────────────────────
var drawnBoxes = array.new_box()
var drawnWicks = array.new_line()
var drawnLabels = array.new_label()

//──────────────────────────────────────────────────────────────────────────────
// Cleanup function
//──────────────────────────────────────────────────────────────────────────────
f_clearDrawings() =>
    if array.size(drawnBoxes) > 0
        for i = 0 to array.size(drawnBoxes) - 1
            box.delete(array.get(drawnBoxes, i))
    array.clear(drawnBoxes)

    if array.size(drawnWicks) > 0
        for i = 0 to array.size(drawnWicks) - 1
            line.delete(array.get(drawnWicks, i))
    array.clear(drawnWicks)

    if array.size(drawnLabels) > 0
        for i = 0 to array.size(drawnLabels) - 1
            label.delete(array.get(drawnLabels, i))
    array.clear(drawnLabels)

//──────────────────────────────────────────────────────────────────────────────
// Draw one six-candle HTF group
//
// Array order:
// [0] = oldest candle
// [4] = latest completed HTF candle
// [5] = current live HTF candle
//──────────────────────────────────────────────────────────────────────────────
f_drawGroup(
     array<float> openValues,
     array<float> highValues,
     array<float> lowValues,
     array<float> closeValues,
     string timeframeName,
     int groupNumber
 ) =>
    int candleStep = candleWidth + candleGap
    int fullGroupWidth = 6 * candleStep + groupGap
    int groupStart = last_bar_index + rightOffset + groupNumber * fullGroupWidth

    for candleNumber = 0 to 5
        float candleOpen = array.get(openValues, candleNumber)
        float candleHigh = array.get(highValues, candleNumber)
        float candleLow = array.get(lowValues, candleNumber)
        float candleClose = array.get(closeValues, candleNumber)

        bool isLive = candleNumber == 5
        bool isBullish = candleClose >= candleOpen

        color candleColor = isBullish ? bullColor : bearColor
        color wickColor = isLive ? candleColor : color.new(candleColor, 65)
        int bodyTransparency = isLive ? liveTransparency : historyTransparency

        int leftX = groupStart + candleNumber * candleStep
        int rightX = leftX + candleWidth
        int middleX = int(math.round((leftX + rightX) / 2))

        line wick = line.new(
             middleX,
             candleHigh,
             middleX,
             candleLow,
             xloc = xloc.bar_index,
             color = wickColor,
             width = 2
         )
        array.push(drawnWicks, wick)

        box body = box.new(
             leftX,
             math.max(candleOpen, candleClose),
             rightX,
             math.min(candleOpen, candleClose),
             xloc = xloc.bar_index,
             border_color = wickColor,
             bgcolor = color.new(candleColor, bodyTransparency)
         )
        array.push(drawnBoxes, body)

        if showHeaders and candleNumber == 0
            label header = label.new(
                 middleX,
                 candleHigh,
                 timeframeName,
                 xloc = xloc.bar_index,
                 color = color.new(color.black, 100),
                 textcolor = neutralColor,
                 style = label.style_label_down,
                 size = size.normal
             )
            array.push(drawnLabels, header)

        if showOHLC and isLive
            int labelX = rightX + 1

            label openLabel = label.new(
                 labelX,
                 candleOpen,
                 "O: " + str.tostring(candleOpen, format.mintick),
                 xloc = xloc.bar_index,
                 color = color.new(color.black, 100),
                 textcolor = neutralColor,
                 style = label.style_label_left,
                 size = size.tiny
             )
            array.push(drawnLabels, openLabel)

            label highLabel = label.new(
                 labelX,
                 candleHigh,
                 "H: " + str.tostring(candleHigh, format.mintick),
                 xloc = xloc.bar_index,
                 color = color.new(color.black, 100),
                 textcolor = bullColor,
                 style = label.style_label_left,
                 size = size.tiny
             )
            array.push(drawnLabels, highLabel)

            label lowLabel = label.new(
                 labelX,
                 candleLow,
                 "L: " + str.tostring(candleLow, format.mintick),
                 xloc = xloc.bar_index,
                 color = color.new(color.black, 100),
                 textcolor = bearColor,
                 style = label.style_label_left,
                 size = size.tiny
             )
            array.push(drawnLabels, lowLabel)

            label closeLabel = label.new(
                 labelX,
                 candleClose,
                 "C: " + str.tostring(candleClose, format.mintick),
                 xloc = xloc.bar_index,
                 color = color.new(color.black, 100),
                 textcolor = candleColor,
                 style = label.style_label_left,
                 size = size.tiny
             )
            array.push(drawnLabels, closeLabel)

//──────────────────────────────────────────────────────────────────────────────
// Fixed HTF data requests
//
// Important: There are NO request.security() calls inside loops.
// This prevents the CE10052 error shown in your screenshot.
//──────────────────────────────────────────────────────────────────────────────

// 1 Hour
[h1o5, h1h5, h1l5, h1c5,
 h1o4, h1h4, h1l4, h1c4,
 h1o3, h1h3, h1l3, h1c3,
 h1o2, h1h2, h1l2, h1c2,
 h1o1, h1h1, h1l1, h1c1,
 h1o0, h1h0, h1l0, h1c0] =
 request.security(
     syminfo.tickerid,
     tf1,
     [open[5], high[5], low[5], close[5],
      open[4], high[4], low[4], close[4],
      open[3], high[3], low[3], close[3],
      open[2], high[2], low[2], close[2],
      open[1], high[1], low[1], close[1],
      open, high, low, close],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
 )

// 4 Hour
[h4o5, h4h5, h4l5, h4c5,
 h4o4, h4h4, h4l4, h4c4,
 h4o3, h4h3, h4l3, h4c3,
 h4o2, h4h2, h4l2, h4c2,
 h4o1, h4h1, h4l1, h4c1,
 h4o0, h4h0, h4l0, h4c0] =
 request.security(
     syminfo.tickerid,
     tf2,
     [open[5], high[5], low[5], close[5],
      open[4], high[4], low[4], close[4],
      open[3], high[3], low[3], close[3],
      open[2], high[2], low[2], close[2],
      open[1], high[1], low[1], close[1],
      open, high, low, close],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
 )

// Daily
[d1o5, d1h5, d1l5, d1c5,
 d1o4, d1h4, d1l4, d1c4,
 d1o3, d1h3, d1l3, d1c3,
 d1o2, d1h2, d1l2, d1c2,
 d1o1, d1h1, d1l1, d1c1,
 d1o0, d1h0, d1l0, d1c0] =
 request.security(
     syminfo.tickerid,
     tf3,
     [open[5], high[5], low[5], close[5],
      open[4], high[4], low[4], close[4],
      open[3], high[3], low[3], close[3],
      open[2], high[2], low[2], close[2],
      open[1], high[1], low[1], close[1],
      open, high, low, close],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
 )

// Weekly
[w1o5, w1h5, w1l5, w1c5,
 w1o4, w1h4, w1l4, w1c4,
 w1o3, w1h3, w1l3, w1c3,
 w1o2, w1h2, w1l2, w1c2,
 w1o1, w1h1, w1l1, w1c1,
 w1o0, w1h0, w1l0, w1c0] =
 request.security(
     syminfo.tickerid,
     tf4,
     [open[5], high[5], low[5], close[5],
      open[4], high[4], low[4], close[4],
      open[3], high[3], low[3], close[3],
      open[2], high[2], low[2], close[2],
      open[1], high[1], low[1], close[1],
      open, high, low, close],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
 )

// Monthly
[m1o5, m1h5, m1l5, m1c5,
 m1o4, m1h4, m1l4, m1c4,
 m1o3, m1h3, m1l3, m1c3,
 m1o2, m1h2, m1l2, m1c2,
 m1o1, m1h1, m1l1, m1c1,
 m1o0, m1h0, m1l0, m1c0] =
 request.security(
     syminfo.tickerid,
     tf5,
     [open[5], high[5], low[5], close[5],
      open[4], high[4], low[4], close[4],
      open[3], high[3], low[3], close[3],
      open[2], high[2], low[2], close[2],
      open[1], high[1], low[1], close[1],
      open, high, low, close],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
 )

//──────────────────────────────────────────────────────────────────────────────
// Render on final chart bar only
//──────────────────────────────────────────────────────────────────────────────
if barstate.islast
    f_clearDrawings()

    array<float> hourOpens = array.from(h1o5, h1o4, h1o3, h1o2, h1o1, h1o0)
    array<float> hourHighs = array.from(h1h5, h1h4, h1h3, h1h2, h1h1, h1h0)
    array<float> hourLows = array.from(h1l5, h1l4, h1l3, h1l2, h1l1, h1l0)
    array<float> hourCloses = array.from(h1c5, h1c4, h1c3, h1c2, h1c1, h1c0)

    array<float> fourHourOpens = array.from(h4o5, h4o4, h4o3, h4o2, h4o1, h4o0)
    array<float> fourHourHighs = array.from(h4h5, h4h4, h4h3, h4h2, h4h1, h4h0)
    array<float> fourHourLows = array.from(h4l5, h4l4, h4l3, h4l2, h4l1, h4l0)
    array<float> fourHourCloses = array.from(h4c5, h4c4, h4c3, h4c2, h4c1, h4c0)

    array<float> dailyOpens = array.from(d1o5, d1o4, d1o3, d1o2, d1o1, d1o0)
    array<float> dailyHighs = array.from(d1h5, d1h4, d1h3, d1h2, d1h1, d1h0)
    array<float> dailyLows = array.from(d1l5, d1l4, d1l3, d1l2, d1l1, d1l0)
    array<float> dailyCloses = array.from(d1c5, d1c4, d1c3, d1c2, d1c1, d1c0)

    array<float> weeklyOpens = array.from(w1o5, w1o4, w1o3, w1o2, w1o1, w1o0)
    array<float> weeklyHighs = array.from(w1h5, w1h4, w1h3, w1h2, w1h1, w1h0)
    array<float> weeklyLows = array.from(w1l5, w1l4, w1l3, w1l2, w1l1, w1l0)
    array<float> weeklyCloses = array.from(w1c5, w1c4, w1c3, w1c2, w1c1, w1c0)

    array<float> monthlyOpens = array.from(m1o5, m1o4, m1o3, m1o2, m1o1, m1o0)
    array<float> monthlyHighs = array.from(m1h5, m1h4, m1h3, m1h2, m1h1, m1h0)
    array<float> monthlyLows = array.from(m1l5, m1l4, m1l3, m1l2, m1l1, m1l0)
    array<float> monthlyCloses = array.from(m1c5, m1c4, m1c3, m1c2, m1c1, m1c0)

    f_drawGroup(hourOpens, hourHighs, hourLows, hourCloses, "1H", 0)
    f_drawGroup(fourHourOpens, fourHourHighs, fourHourLows, fourHourCloses, "4H", 1)
    f_drawGroup(dailyOpens, dailyHighs, dailyLows, dailyCloses, "1D", 2)
    f_drawGroup(weeklyOpens, weeklyHighs, weeklyLows, weeklyCloses, "1W", 3)
    f_drawGroup(monthlyOpens, monthlyHighs, monthlyLows, monthlyCloses, "1M", 4)
````
