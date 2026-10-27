# HTF Candle Clusters - Multi-Timeframe PO3 Overlay

- url: https://www.tradingview.com/script/5gAiiYbk-HTF-Candle-Clusters-Multi-Timeframe-PO3-Overlay/
- type: indicator
- pine_id: PUB;36fb391c78f04a8ea62c0e4dc86d44ae
- version: 2.0

## Description

HTF Candle Clusters is a configurable multi-timeframe overlay that projects up to three higher-timeframe candle groups beside the live chart.

The indicator helps traders read higher-timeframe structure without leaving their execution timeframe. It provides a compact visual framework for HTF candle analysis, PO3 candle analysis, and discretionary Power of Three workflows.

KEY FEATURES

- Display up to three independent HTF candle clusters.
- Configure the timeframe and number of candles for each cluster.
- Use manual timeframes or enable Auto Mode to select suitable higher timeframes from the current chart timeframe.
- View the developing current HTF candle alongside completed HTF candles.
- Draw the current HTF open from its actual opening time to the projected current candle.
- Display the previous HTF candle midpoint when enabled.
- Show a live countdown for the current candle in each cluster.
- Combine the timeframe and countdown in a clean label positioned above the highest candle in the cluster.
- Customize bullish and bearish bodies, wicks, borders, open lines, midpoint lines, widths, colors, and line styles.
- Adjust candle width, candle spacing, cluster spacing, and right-side offset.

DEFAULT CONFIGURATION

- Auto Mode: enabled.
- Cluster 1: 15-minute timeframe, 6 candles.
- Cluster 2: 1-hour timeframe, 4 candles.
- Cluster 3: 1-day timeframe, 1 candle.
- Current HTF open lines: enabled with dotted style.
- Previous HTF midpoint lines: disabled by default and available per cluster.
- Countdown labels: enabled.

PO3 AND POWER OF THREE USE

PO3 traders can use the projected HTF candles to monitor the current higher-timeframe open, candle range, optional previous midpoint, and time remaining before the candle closes.

This indicator does not automatically classify accumulation, manipulation, or distribution, and it does not generate PO3 trading signals. It is a visual analysis tool designed to support discretionary PO3 candle and Power of Three analysis.

HOW TO USE

Apply the indicator to a timeframe lower than the configured cluster timeframes. Use the current HTF open and optional previous midpoint as visual reference levels while comparing the developing candle with recently completed higher-timeframe candles.

Each cluster can be enabled, disabled, or styled independently. Auto Mode is useful when moving between chart timeframes, while Manual Mode provides full control over the displayed HTFs.

NOTES

The current HTF candle updates as new market data arrives and remains developing until its timeframe closes. Completed HTF candles remain fixed.

The indicator is intended for time-based charts. A cluster must use a timeframe higher than the current chart timeframe.

ORIGINALITY

Unlike single-timeframe HTF candle overlays, this script focuses on side-by-side comparison of up to three independently configurable candle clusters. It combines custom candle counts, Auto Mode, actual HTF open anchoring, optional previous-candle midpoint levels, live countdowns, and per-cluster styling in one overlay.

This indicator is a visualization and educational tool. It does not provide financial advice, trade recommendations, or guaranteed outcomes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © phankietit
//@version=6
indicator("HTF Candle Clusters - Multi-Timeframe PO3 Overlay", shorttitle = "HTF PO3 Clusters", overlay = true, max_boxes_count = 100, max_lines_count = 200, max_labels_count = 30)

//------------------------------------------------------------------------------
// General settings
//------------------------------------------------------------------------------
const string GRP_GENERAL = "General"
const string GRP_LAYOUT  = "Layout"
const string GRP_1       = "HTF Cluster 1"
const string GRP_2       = "HTF Cluster 2"
const string GRP_3       = "HTF Cluster 3"

bool autoMode = input.bool(true, "Auto mode", group = GRP_GENERAL, tooltip = "Automatically selects three higher timeframes from the current chart timeframe.")
bool showTfLabels = input.bool(true, "Show timeframe labels", group = GRP_GENERAL)

int rightOffset = input.int(8, "Right offset (bars)", minval = 1, maxval = 100, group = GRP_LAYOUT)
int bodyWidth = input.int(2, "Candle body width", minval = 1, maxval = 6, group = GRP_LAYOUT)
int candleGap = input.int(1, "Gap between candles", minval = 0, maxval = 10, group = GRP_LAYOUT)
int clusterGap = input.int(5, "Gap between clusters", minval = 1, maxval = 30, group = GRP_LAYOUT)

//------------------------------------------------------------------------------
// Cluster 1 defaults: 15m / 6 candles
//------------------------------------------------------------------------------
bool show1 = input.bool(true, "Show cluster", group = GRP_1)
string manualTf1 = input.timeframe("15", "Timeframe", group = GRP_1)
int count1 = input.int(6, "Candles", minval = 1, maxval = 12, group = GRP_1)
color bull1 = input.color(color.rgb(199, 226, 247), "Bull body", group = GRP_1, inline = "1body")
color bear1 = input.color(color.rgb(90, 100, 114), "Bear body", group = GRP_1, inline = "1body")
color wick1 = input.color(color.rgb(90, 96, 105), "Wick", group = GRP_1, inline = "1edge")
color border1 = input.color(color.rgb(90, 100, 114), "Border", group = GRP_1, inline = "1edge")
int borderWidth1 = input.int(1, "Border width", minval = 0, maxval = 4, group = GRP_1)
int wickWidth1 = input.int(1, "Wick width", minval = 1, maxval = 4, group = GRP_1)
bool showOpen1 = input.bool(true, "Current HTF open", group = GRP_1, inline = "1open")
color openColor1 = input.color(color.rgb(11, 18, 32), "", group = GRP_1, inline = "1open")
string openStyle1 = input.string("Dotted", "Open style", options = ["Solid", "Dashed", "Dotted"], group = GRP_1, inline = "1openstyle")
int openWidth1 = input.int(1, "", minval = 1, maxval = 4, group = GRP_1, inline = "1openstyle")
bool showMid1 = input.bool(false, "Previous midpoint", group = GRP_1, inline = "1mid")
color midColor1 = input.color(color.rgb(156, 39, 176), "", group = GRP_1, inline = "1mid")
string midStyle1 = input.string("Dotted", "Mid style", options = ["Solid", "Dashed", "Dotted"], group = GRP_1, inline = "1midstyle")
int midWidth1 = input.int(1, "", minval = 1, maxval = 4, group = GRP_1, inline = "1midstyle")
bool showCountdown1 = input.bool(true, "Countdown", group = GRP_1, inline = "1count")
color countdownColor1 = input.color(color.white, "", group = GRP_1, inline = "1count")

//------------------------------------------------------------------------------
// Cluster 2 defaults: 1h / 4 candles
//------------------------------------------------------------------------------
bool show2 = input.bool(true, "Show cluster", group = GRP_2)
string manualTf2 = input.timeframe("60", "Timeframe", group = GRP_2)
int count2 = input.int(4, "Candles", minval = 1, maxval = 12, group = GRP_2)
color bull2 = input.color(color.rgb(8, 153, 129), "Bull body", group = GRP_2, inline = "2body")
color bear2 = input.color(color.rgb(90, 100, 114), "Bear body", group = GRP_2, inline = "2body")
color wick2 = input.color(color.rgb(90, 100, 114), "Wick", group = GRP_2, inline = "2edge")
color border2 = input.color(color.rgb(90, 100, 114), "Border", group = GRP_2, inline = "2edge")
int borderWidth2 = input.int(1, "Border width", minval = 0, maxval = 4, group = GRP_2)
int wickWidth2 = input.int(1, "Wick width", minval = 1, maxval = 4, group = GRP_2)
bool showOpen2 = input.bool(true, "Current HTF open", group = GRP_2, inline = "2open")
color openColor2 = input.color(color.rgb(8, 153, 129), "", group = GRP_2, inline = "2open")
string openStyle2 = input.string("Dotted", "Open style", options = ["Solid", "Dashed", "Dotted"], group = GRP_2, inline = "2openstyle")
int openWidth2 = input.int(1, "", minval = 1, maxval = 4, group = GRP_2, inline = "2openstyle")
bool showMid2 = input.bool(false, "Previous midpoint", group = GRP_2, inline = "2mid")
color midColor2 = input.color(color.rgb(156, 39, 176), "", group = GRP_2, inline = "2mid")
string midStyle2 = input.string("Dotted", "Mid style", options = ["Solid", "Dashed", "Dotted"], group = GRP_2, inline = "2midstyle")
int midWidth2 = input.int(1, "", minval = 1, maxval = 4, group = GRP_2, inline = "2midstyle")
bool showCountdown2 = input.bool(true, "Countdown", group = GRP_2, inline = "2count")
color countdownColor2 = input.color(color.white, "", group = GRP_2, inline = "2count")

//------------------------------------------------------------------------------
// Cluster 3 defaults: 1D / 2 candles
//------------------------------------------------------------------------------
bool show3 = input.bool(true, "Show cluster", group = GRP_3)
string manualTf3 = input.timeframe("D", "Timeframe", group = GRP_3)
int count3 = input.int(1, "Candles", minval = 1, maxval = 12, group = GRP_3)
color bull3 = input.color(color.rgb(41, 98, 255), "Bull body", group = GRP_3, inline = "3body")
color bear3 = input.color(color.rgb(90, 100, 114), "Bear body", group = GRP_3, inline = "3body")
color wick3 = input.color(color.rgb(90, 100, 114), "Wick", group = GRP_3, inline = "3edge")
color border3 = input.color(color.rgb(90, 100, 114), "Border", group = GRP_3, inline = "3edge")
int borderWidth3 = input.int(1, "Border width", minval = 0, maxval = 4, group = GRP_3)
int wickWidth3 = input.int(1, "Wick width", minval = 1, maxval = 4, group = GRP_3)
bool showOpen3 = input.bool(true, "Current HTF open", group = GRP_3, inline = "3open")
color openColor3 = input.color(color.rgb(41, 98, 255), "", group = GRP_3, inline = "3open")
string openStyle3 = input.string("Dotted", "Open style", options = ["Solid", "Dashed", "Dotted"], group = GRP_3, inline = "3openstyle")
int openWidth3 = input.int(1, "", minval = 1, maxval = 4, group = GRP_3, inline = "3openstyle")
bool showMid3 = input.bool(false, "Previous midpoint", group = GRP_3, inline = "3mid")
color midColor3 = input.color(color.rgb(156, 39, 176), "", group = GRP_3, inline = "3mid")
string midStyle3 = input.string("Dotted", "Mid style", options = ["Solid", "Dashed", "Dotted"], group = GRP_3, inline = "3midstyle")
int midWidth3 = input.int(1, "", minval = 1, maxval = 4, group = GRP_3, inline = "3midstyle")
bool showCountdown3 = input.bool(true, "Countdown", group = GRP_3, inline = "3count")
color countdownColor3 = input.color(color.white, "", group = GRP_3, inline = "3count")

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
var array<box> candleBoxes = array.new<box>()
var array<line> drawingLines = array.new<line>()
var array<label> drawingLabels = array.new<label>()

f_line_style(string styleName) =>
    styleName == "Dashed" ? line.style_dashed : styleName == "Dotted" ? line.style_dotted : line.style_solid

f_two_digits(int value) =>
    value < 10 ? "0" + str.tostring(value) : str.tostring(value)

f_countdown(int closeTime) =>
    // timenow is wall-clock time, so historical Replay bars would always clamp to zero.
    // Fall back to the active chart bar's close time whenever the HTF close is in the past.
    int clockTime = timenow <= closeTime ? timenow : nz(time_close, time)
    int totalSeconds = math.max(int(math.floor((closeTime - clockTime) / 1000)), 0)
    int days = int(math.floor(totalSeconds / 86400))
    int hours = int(math.floor((totalSeconds % 86400) / 3600))
    int minutes = int(math.floor((totalSeconds % 3600) / 60))
    int seconds = totalSeconds % 60
    string clock = f_two_digits(hours) + ":" + f_two_digits(minutes) + ":" + f_two_digits(seconds)
    days > 0 ? str.tostring(days) + "d " + clock : clock

f_tf_display(string tf) =>
    int tfMinutes = int(nz(str.tonumber(tf), -1))
    tfMinutes > 0 ? (tfMinutes >= 60 and tfMinutes % 60 == 0 ? str.tostring(int(tfMinutes / 60)) + "H" : str.tostring(tfMinutes) + "m") : tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf

f_clear_drawings() =>
    for item in candleBoxes
        box.delete(item)
    array.clear(candleBoxes)
    for item in drawingLines
        line.delete(item)
    array.clear(drawingLines)
    for item in drawingLabels
        label.delete(item)
    array.clear(drawingLabels)

f_auto_timeframes() =>
    float chartSeconds = timeframe.in_seconds()
    string first = chartSeconds <= 60 ? "15" : chartSeconds <= 900 ? "60" : chartSeconds <= 3600 ? "240" : chartSeconds <= 14400 ? "D" : chartSeconds <= 86400 ? "W" : chartSeconds <= 604800 ? "M" : "3M"
    string second = chartSeconds <= 60 ? "60" : chartSeconds <= 900 ? "240" : chartSeconds <= 3600 ? "D" : chartSeconds <= 14400 ? "W" : chartSeconds <= 86400 ? "M" : chartSeconds <= 604800 ? "3M" : "6M"
    string third = chartSeconds <= 60 ? "D" : chartSeconds <= 900 ? "D" : chartSeconds <= 3600 ? "W" : chartSeconds <= 14400 ? "M" : chartSeconds <= 86400 ? "3M" : chartSeconds <= 604800 ? "12M" : "12M"
    [first, second, third]

f_draw_cluster(bool enabled, string tf, int candleCount, int startX, color bullColor, color bearColor, color wickColor, color borderColor, int borderW, int wickW, bool drawOpen, color openColor, string openStyle, int openW, bool drawMid, color midColor, string midStyle, int midW, bool drawCountdown, color countdownTextColor) =>
    [o0, h0, l0, c0, o1, h1, l1, c1, o2, h2, l2, c2, o3, h3, l3, c3, o4, h4, l4, c4, o5, h5, l5, c5, o6, h6, l6, c6, o7, h7, l7, c7, o8, h8, l8, c8, o9, h9, l9, c9, o10, h10, l10, c10, o11, h11, l11, c11] = request.security(syminfo.tickerid, tf, [open, high, low, close, open[1], high[1], low[1], close[1], open[2], high[2], low[2], close[2], open[3], high[3], low[3], close[3], open[4], high[4], low[4], close[4], open[5], high[5], low[5], close[5], open[6], high[6], low[6], close[6], open[7], high[7], low[7], close[7], open[8], high[8], low[8], close[8], open[9], high[9], low[9], close[9], open[10], high[10], low[10], close[10], open[11], high[11], low[11], close[11]], lookahead = barmerge.lookahead_off)
    int currentHtfOpenTime = request.security(syminfo.tickerid, tf, time, lookahead = barmerge.lookahead_off)
    int currentHtfCloseTime = time_close(tf)
    int nextX = startX
    if barstate.islast and enabled
        bool validTf = timeframe.in_seconds(tf) > timeframe.in_seconds()
        if validTf
            array<float> opens = array.from(o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11)
            array<float> highs = array.from(h0, h1, h2, h3, h4, h5, h6, h7, h8, h9, h10, h11)
            array<float> lows = array.from(l0, l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11)
            array<float> closes = array.from(c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11)
            int step = bodyWidth + candleGap
            int endX = startX + (candleCount - 1) * step + bodyWidth
            float clusterHigh = array.get(highs, candleCount - 1)
            float clusterLow = array.get(lows, candleCount - 1)
            for displayIndex = 0 to candleCount - 1
                int historyIndex = candleCount - 1 - displayIndex
                float candleOpen = array.get(opens, historyIndex)
                float candleHigh = array.get(highs, historyIndex)
                float candleLow = array.get(lows, historyIndex)
                float candleClose = array.get(closes, historyIndex)
                int leftX = startX + displayIndex * step
                int rightX = leftX + bodyWidth
                int middleX = leftX + int(math.floor(bodyWidth * 0.5))
                color bodyColor = candleClose >= candleOpen ? bullColor : bearColor
                float bodyTop = math.max(candleOpen, candleClose)
                float bodyBottom = math.min(candleOpen, candleClose)
                if bodyTop == bodyBottom
                    bodyTop += syminfo.mintick
                    bodyBottom -= syminfo.mintick
                line wickLine = line.new(middleX, candleLow, middleX, candleHigh, xloc = xloc.bar_index, color = wickColor, width = wickW)
                box bodyBox = box.new(leftX, bodyTop, rightX, bodyBottom, xloc = xloc.bar_index, border_color = borderColor, border_width = borderW, bgcolor = bodyColor)
                array.push(drawingLines, wickLine)
                array.push(candleBoxes, bodyBox)
                clusterHigh := math.max(clusterHigh, candleHigh)
                clusterLow := math.min(clusterLow, candleLow)
            if drawOpen and not na(o0) and not na(currentHtfOpenTime)
                int currentBodyLeft = endX - bodyWidth
                int chartBarMs = int(timeframe.in_seconds() * 1000)
                int currentBodyLeftTime = time + (currentBodyLeft - bar_index) * chartBarMs
                line openLine = line.new(currentHtfOpenTime, o0, currentBodyLeftTime, o0, xloc = xloc.bar_time, color = openColor, style = f_line_style(openStyle), width = openW)
                array.push(drawingLines, openLine)
            bool countdownReady = drawCountdown and not na(currentHtfCloseTime)
            if (showTfLabels or countdownReady) and not na(h0) and not na(l0)
                int clusterCenterX = startX + int(math.floor((endX - startX) * 0.5))
                float labelPadding = math.max((clusterHigh - clusterLow) * 0.06, syminfo.mintick * 8.0)
                float infoLabelY = clusterHigh + labelPadding
                string infoText = showTfLabels and countdownReady ? f_tf_display(tf) + "   " + f_countdown(currentHtfCloseTime) : showTfLabels ? f_tf_display(tf) : f_countdown(currentHtfCloseTime)
                label infoLabel = label.new(clusterCenterX, infoLabelY, infoText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(borderColor, 15), textcolor = countdownTextColor, size = size.small)
                array.push(drawingLabels, infoLabel)
            float previousMid = (h1 + l1) * 0.5
            if drawMid and not na(previousMid)
                line midLine = line.new(startX, previousMid, endX, previousMid, xloc = xloc.bar_index, color = midColor, style = f_line_style(midStyle), width = midW)
                array.push(drawingLines, midLine)
            nextX := endX + clusterGap
        else
            label warningLabel = label.new(startX, high, tf + " must be higher than " + timeframe.period, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.rgb(185, 45, 45), textcolor = color.white, size = size.small)
            array.push(drawingLabels, warningLabel)
            nextX := startX + clusterGap + 4
    nextX

[autoTf1, autoTf2, autoTf3] = f_auto_timeframes()
string tf1 = autoMode ? autoTf1 : manualTf1
string tf2 = autoMode ? autoTf2 : manualTf2
string tf3 = autoMode ? autoTf3 : manualTf3

if barstate.islast
    f_clear_drawings()

int cluster1Start = bar_index + rightOffset
int cluster2Start = f_draw_cluster(show1, tf1, count1, cluster1Start, bull1, bear1, wick1, border1, borderWidth1, wickWidth1, showOpen1, openColor1, openStyle1, openWidth1, showMid1, midColor1, midStyle1, midWidth1, showCountdown1, countdownColor1)
int cluster3Start = f_draw_cluster(show2, tf2, count2, cluster2Start, bull2, bear2, wick2, border2, borderWidth2, wickWidth2, showOpen2, openColor2, openStyle2, openWidth2, showMid2, midColor2, midStyle2, midWidth2, showCountdown2, countdownColor2)
f_draw_cluster(show3, tf3, count3, cluster3Start, bull3, bear3, wick3, border3, borderWidth3, wickWidth3, showOpen3, openColor3, openStyle3, openWidth3, showMid3, midColor3, midStyle3, midWidth3, showCountdown3, countdownColor3)
````
