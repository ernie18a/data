# Multi Time Frame EMA 21 / 50 / 200

- url: https://www.tradingview.com/script/YFO8DgPq-Multi-Time-Frame-EMA-21-50-200/
- type: indicator
- pine_id: PUB;08105eccd80f42629fd8eb99924738c3
- version: 1.0

## Description

Title:
Multi Time Frame EMA 21 / 50 / 200

Description:
Multi Time Frame EMA 21 / 50 / 200 draws the 21, 50 and 200 EMAs from up to 12 timeframes on one chart, with one indicator. Each line ends in a small note, such as "EMA 200 · 4h", so you can always tell which timeframe and EMA a line belongs to.

HOW IT WORKS
• Timeframes: Chart, 1m, 3m, 5m, 15m, 30m, 1h, 4h, 8h, 1D, 3D and 1W.
• For each timeframe the script calculates the three EMAs on that timeframe's own candles and draws them on your chart.
• All three EMAs of a timeframe come from a single data request. Only enabled timeframes are requested, which keeps the script light.
• Timeframes lower than the chart's are hidden automatically, because they cannot be shown meaningfully on a higher-timeframe chart. A timeframe equal to the chart's uses the chart's own EMAs.

SETTINGS
EMA lengths / line width
• The three EMA lengths (default 21, 50, 200) and a line width for each. The widths are 1, 2 and 3 by default, so the colour tells you the timeframe and the thickness tells you the EMA.
• Source (default: close).
• History (bars): how far back the lines are drawn (default 2000).
• Wait for higher-timeframe bar to close (default on):
  – On: a higher-timeframe EMA only updates when that timeframe's candle closes. Historical values are exactly what you would have seen live, so the lines do not repaint.
  – Off: the EMA moves live with the still-open higher-timeframe candle. This is more responsive, but past values can look better than they really were.

Timeframe — enabled / EMAs / color
One row per timeframe: an on/off switch, a checkbox for each EMA (21 / 50 / 200), and a colour. For example, you can show only the 200 EMA on the weekly and all three EMAs on the 4h.
By default, Chart, 1h, 4h and 1D are enabled.

Line notes
• A small note to the right of the last visible candle, in the line's colour, with a dotted connector pointing to the exact price.
• Notes close to each other are spaced apart automatically so they stay readable. Note spacing (%) controls the minimum distance.
• Lines at the same price share one note (for example "EMA 50 · Chart · 1h" on a 1h chart).
• Hover a note to see the exact EMA value and whether it uses closed or live higher-timeframe candles.
• Note size and distance from the candles are adjustable, and notes can be turned off.

HOW TO USE IT
Higher-timeframe EMAs often act as support and resistance, and their order shows the trend on each timeframe. With several timeframes on one chart you can see at a glance:
• where price sits relative to the 1h, 4h and daily trend;
• where EMAs from different timeframes cluster, forming stronger zones;
• when a lower-timeframe pullback reaches a higher-timeframe EMA.

Example from the chart above: BTCUSDT on the 30-minute chart, with the 1h EMAs (green), 4h EMAs (blue) and 1D EMA 21 (purple). Price is consolidating between the 1h EMA 21/50 below and the 4h/1D EMA 21 just above, while the 1h EMA 200 and 4h EMA 50 overhead mark the next resistance zone.

NOTES AND LIMITATIONS
• To fit all 36 possible lines (12 timeframes × 3 EMAs) with a colour per timeframe, the lines are drawn as polylines instead of plots. Because of this, the values do not appear in the Data Window or on the price scale. Hover the notes for exact values.
• Lines are drawn for the number of bars set in History (bars).
• Higher-timeframe EMAs need enough history on that timeframe. A 200 EMA on the weekly needs about 200 weeks of data, so it may not appear on recently listed symbols.
• Works on standard time-based charts.

This indicator is a visual tool and not a trading signal or financial advice.

## Source Code

````pine
//@version=6
// Multi Time Frame EMA 21 / 50 / 200
indicator("Multi Time Frame EMA 21 / 50 / 200", shorttitle="MTF EMA", overlay=true, max_lines_count=100, max_labels_count=100, max_polylines_count=100, dynamic_requests=true)

const string EMA = "EMA lengths / line width"
int len1 = input.int(21, "21", minval=1, group=EMA, inline="len", display=display.none)
int len2 = input.int(50, "50", minval=1, group=EMA, inline="len", display=display.none)
int len3 = input.int(200, "200", minval=1, group=EMA, inline="len", display=display.none, tooltip="The 21 / 50 / 200 checkboxes below refer to these three positions. If you change a length, the checkbox keeps its column; labels show the actual length.")
int w1 = input.int(1, "Width", minval=1, maxval=4, group=EMA, inline="width", display=display.none)
int w2 = input.int(2, "", minval=1, maxval=4, group=EMA, inline="width", display=display.none)
int w3 = input.int(3, "", minval=1, maxval=4, group=EMA, inline="width", display=display.none)
float src = input.source(close, "Source", group=EMA, display=display.none)
int history = input.int(2000, "History (bars)", minval=100, maxval=10000, step=100, group=EMA, display=display.none, tooltip="How many chart bars back each line is drawn. Higher values draw further back but take longer to calculate.")
bool noRepaint = input.bool(true, "Wait for higher-timeframe bar to close", group=EMA, display=display.none, tooltip="On: higher-timeframe EMAs only update when that timeframe's bar closes (no repainting).\nOff: they move live with the current higher-timeframe bar.")

const string TF = "Timeframe — enabled / EMAs / color"
bool onCh = input.bool(true, "Chart", inline="ch", group=TF, display=display.none)
bool aCh = input.bool(true, "21", inline="ch", group=TF, display=display.none)
bool bCh = input.bool(true, "50", inline="ch", group=TF, display=display.none)
bool cCh = input.bool(true, "200", inline="ch", group=TF, display=display.none)
color colCh = input.color(#B2B5BE, "", inline="ch", group=TF, display=display.none)
bool on0 = input.bool(false, "1m", inline="c0", group=TF, display=display.none)
bool a0 = input.bool(true, "21", inline="c0", group=TF, display=display.none)
bool b0 = input.bool(true, "50", inline="c0", group=TF, display=display.none)
bool c0 = input.bool(true, "200", inline="c0", group=TF, display=display.none)
color col0 = input.color(#9E9E9E, "", inline="c0", group=TF, display=display.none)
bool on1 = input.bool(false, "3m", inline="c1", group=TF, display=display.none)
bool a1 = input.bool(true, "21", inline="c1", group=TF, display=display.none)
bool b1 = input.bool(true, "50", inline="c1", group=TF, display=display.none)
bool c1 = input.bool(true, "200", inline="c1", group=TF, display=display.none)
color col1 = input.color(#80DEEA, "", inline="c1", group=TF, display=display.none)
bool on2 = input.bool(false, "5m", inline="c2", group=TF, display=display.none)
bool a2 = input.bool(true, "21", inline="c2", group=TF, display=display.none)
bool b2 = input.bool(true, "50", inline="c2", group=TF, display=display.none)
bool c2 = input.bool(true, "200", inline="c2", group=TF, display=display.none)
color col2 = input.color(#26C6DA, "", inline="c2", group=TF, display=display.none)
bool on3 = input.bool(false, "15m", inline="c3", group=TF, display=display.none)
bool a3 = input.bool(true, "21", inline="c3", group=TF, display=display.none)
bool b3 = input.bool(true, "50", inline="c3", group=TF, display=display.none)
bool c3 = input.bool(true, "200", inline="c3", group=TF, display=display.none)
color col3 = input.color(#FF9800, "", inline="c3", group=TF, display=display.none)
bool on4 = input.bool(false, "30m", inline="c4", group=TF, display=display.none)
bool a4 = input.bool(true, "21", inline="c4", group=TF, display=display.none)
bool b4 = input.bool(true, "50", inline="c4", group=TF, display=display.none)
bool c4 = input.bool(true, "200", inline="c4", group=TF, display=display.none)
color col4 = input.color(#FFEB3B, "", inline="c4", group=TF, display=display.none)
bool on5 = input.bool(true, "1h", inline="c5", group=TF, display=display.none)
bool a5 = input.bool(true, "21", inline="c5", group=TF, display=display.none)
bool b5 = input.bool(true, "50", inline="c5", group=TF, display=display.none)
bool c5 = input.bool(true, "200", inline="c5", group=TF, display=display.none)
color col5 = input.color(#AB47BC, "", inline="c5", group=TF, display=display.none)
bool on6 = input.bool(true, "4h", inline="c6", group=TF, display=display.none)
bool a6 = input.bool(true, "21", inline="c6", group=TF, display=display.none)
bool b6 = input.bool(true, "50", inline="c6", group=TF, display=display.none)
bool c6 = input.bool(true, "200", inline="c6", group=TF, display=display.none)
color col6 = input.color(#2962FF, "", inline="c6", group=TF, display=display.none)
bool on7 = input.bool(false, "8h", inline="c7", group=TF, display=display.none)
bool a7 = input.bool(true, "21", inline="c7", group=TF, display=display.none)
bool b7 = input.bool(true, "50", inline="c7", group=TF, display=display.none)
bool c7 = input.bool(true, "200", inline="c7", group=TF, display=display.none)
color col7 = input.color(#EC407A, "", inline="c7", group=TF, display=display.none)
bool on8 = input.bool(true, "1D", inline="c8", group=TF, display=display.none)
bool a8 = input.bool(true, "21", inline="c8", group=TF, display=display.none)
bool b8 = input.bool(true, "50", inline="c8", group=TF, display=display.none)
bool c8 = input.bool(true, "200", inline="c8", group=TF, display=display.none)
color col8 = input.color(#26A69A, "", inline="c8", group=TF, display=display.none)
bool on9 = input.bool(false, "3D", inline="c9", group=TF, display=display.none)
bool a9 = input.bool(true, "21", inline="c9", group=TF, display=display.none)
bool b9 = input.bool(true, "50", inline="c9", group=TF, display=display.none)
bool c9 = input.bool(true, "200", inline="c9", group=TF, display=display.none)
color col9 = input.color(#8D6E63, "", inline="c9", group=TF, display=display.none)
bool on10 = input.bool(false, "1W", inline="c10", group=TF, display=display.none)
bool a10 = input.bool(true, "21", inline="c10", group=TF, display=display.none)
bool b10 = input.bool(true, "50", inline="c10", group=TF, display=display.none)
bool c10 = input.bool(true, "200", inline="c10", group=TF, display=display.none)
color col10 = input.color(#FFFFFF, "", inline="c10", group=TF, display=display.none)

const string LBL = "Line notes"
bool showNotes = input.bool(true, "Show notes", group=LBL, display=display.none, tooltip="A small note to the right of each line, e.g. \"EMA 50 · 4h\". Lines at the same price share one note. Hover a note for its exact value.")
string noteSize = input.string(size.small, "Note size", options=[size.tiny, size.small, size.normal], group=LBL, display=display.none)
int noteOffset = input.int(5, "Note distance (bars)", minval=0, maxval=100, group=LBL, display=display.none, tooltip="Distance to the right of the last visible candle. Adjust to fit your chart's right margin.")
float noteSpacing = input.float(2.5, "Note spacing (%)", minval=0, maxval=20, step=0.5, group=LBL, display=display.none, tooltip="Minimum spacing as a percentage of the visible price range. Dotted connectors point to the exact prices. Zero places notes at their actual prices.")

// ───── Calculations ─────
float chartSeconds = timeframe.in_seconds()
float e1 = ta.ema(src, len1)
float e2 = ta.ema(src, len2)
float e3 = ta.ema(src, len3)

int off = noRepaint ? 1 : 0
f_set() =>
    [ta.ema(src, len1)[off], ta.ema(src, len2)[off], ta.ema(src, len3)[off]]

// One request per timeframe for all three EMAs, made only for enabled timeframes
// above the chart. Lower timeframes are never requested; a timeframe equal to the
// chart uses the chart's own values.
f_tf(string code, bool on, bool a, bool b, bool c) =>
    float s = timeframe.in_seconds(code)
    float r1 = na
    float r2 = na
    float r3 = na
    if on and (a or b or c) and s >= chartSeconds
        if s == chartSeconds
            r1 := e1
            r2 := e2
            r3 := e3
        else
            [h1, h2, h3] = request.security(syminfo.tickerid, code, f_set(), lookahead=noRepaint ? barmerge.lookahead_on : barmerge.lookahead_off)
            r1 := h1
            r2 := h2
            r3 := h3
    [a ? r1 : na, b ? r2 : na, c ? r3 : na]

float ch1 = onCh and aCh ? e1 : na
float ch2 = onCh and bCh ? e2 : na
float ch3 = onCh and cCh ? e3 : na
[v0a, v0b, v0c] = f_tf("1", on0, a0, b0, c0)
[v1a, v1b, v1c] = f_tf("3", on1, a1, b1, c1)
[v2a, v2b, v2c] = f_tf("5", on2, a2, b2, c2)
[v3a, v3b, v3c] = f_tf("15", on3, a3, b3, c3)
[v4a, v4b, v4c] = f_tf("30", on4, a4, b4, c4)
[v5a, v5b, v5c] = f_tf("60", on5, a5, b5, c5)
[v6a, v6b, v6c] = f_tf("240", on6, a6, b6, c6)
[v7a, v7b, v7c] = f_tf("480", on7, a7, b7, c7)
[v8a, v8b, v8c] = f_tf("1D", on8, a8, b8, c8)
[v9a, v9b, v9c] = f_tf("3D", on9, a9, b9, c9)
[v10a, v10b, v10c] = f_tf("1W", on10, a10, b10, c10)

// ───── Lines ─────
// Drawn as polylines instead of plot(): Pine allows 64 plots and a plot with an
// input color counts twice, so 36 colored plots (72) do not fit. Polylines have
// no such limit and keep each row's color and each EMA's width.
type Track
    array<chart.point> pts
    polyline pl

var array<Track> tracks = array.new<Track>()
var array<color> trackColors = array.from(colCh, colCh, colCh, col0, col0, col0, col1, col1, col1, col2, col2, col2, col3, col3, col3, col4, col4, col4, col5, col5, col5, col6, col6, col6, col7, col7, col7, col8, col8, col8, col9, col9, col9, col10, col10, col10)
var array<int> trackWidths = array.from(w1, w2, w3)
if barstate.isfirst
    for i = 0 to 35
        array.push(tracks, Track.new(array.new<chart.point>(), na))

// Ordinary var state rolls back on realtime updates, so each tick replaces
// the current bar's point instead of adding another one.
array<float> vals = array.from(ch1, ch2, ch3, v0a, v0b, v0c, v1a, v1b, v1c, v2a, v2b, v2c, v3a, v3b, v3c, v4a, v4b, v4c, v5a, v5b, v5c, v6a, v6b, v6c, v7a, v7b, v7c, v8a, v8b, v8c, v9a, v9b, v9c, v10a, v10b, v10c)
for i = 0 to 35
    float v = array.get(vals, i)
    if not na(v)
        Track t = array.get(tracks, i)
        array.push(t.pts, chart.point.from_time(time, v))
        if array.size(t.pts) > history
            array.shift(t.pts)

if barstate.islast
    for i = 0 to 35
        Track t = array.get(tracks, i)
        polyline.delete(t.pl)
        t.pl := na
        if array.size(t.pts) > 1
            t.pl := polyline.new(t.pts, xloc=xloc.bar_time, line_color=array.get(trackColors, i), line_width=array.get(trackWidths, i % 3))

// ───── Line notes ─────
type Note
    float price
    float value
    int len
    string names
    color col

// Lines with the same length at the same tick price share one note
// (e.g. "Chart" and "1h" on a 1h chart). The higher timeframe's color wins.
f_note(array<Note> notes, float v, string name, int len, color col) =>
    if not na(v)
        float p = math.round_to_mintick(v)
        int found = -1
        if array.size(notes) > 0
            for i = 0 to array.size(notes) - 1
                Note n = array.get(notes, i)
                if n.price == p and n.len == len
                    found := i
                    break
        if found < 0
            array.push(notes, Note.new(p, v, len, name, col))
        else
            Note n = array.get(notes, found)
            n.names += " · " + name
            n.col := col
    true

// Least-displacement ordered layout: nearby rows share displacement in both
// directions. Isolated prices remain exact.
f_labelRows(array<float> sortedPrices, float gap) =>
    array<float> means = array.new<float>()
    array<int> weights = array.new<int>()
    int index = 0
    for price in sortedPrices
        array.push(means, price - gap * index)
        array.push(weights, 1)
        while array.size(means) > 1
            int last = array.size(means) - 1
            if array.get(means, last - 1) <= array.get(means, last)
                break
            float rightMean = array.pop(means)
            int rightWeight = array.pop(weights)
            float leftMean = array.pop(means)
            int leftWeight = array.pop(weights)
            array.push(means, (leftMean * leftWeight + rightMean * rightWeight) / (leftWeight + rightWeight))
            array.push(weights, leftWeight + rightWeight)
        index += 1
    array<float> rows = array.new<float>()
    if array.size(means) > 0
        for block = 0 to array.size(means) - 1
            for member = 1 to array.get(weights, block)
                array.push(rows, array.get(means, block) + gap * array.size(rows))
    rows

// Visible candle bounds approximate vertical spacing; Pine exposes no pixel scale.
var float visibleHigh = na
var float visibleLow = na
if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    visibleHigh := na(visibleHigh) ? high : math.max(visibleHigh, high)
    visibleLow := na(visibleLow) ? low : math.min(visibleLow, low)

var array<label> noteLabels = array.new<label>()
var array<line> noteLines = array.new<line>()

if barstate.islast
    for lb in noteLabels
        label.delete(lb)
    for ln in noteLines
        line.delete(ln)
    array.clear(noteLabels)
    array.clear(noteLines)
    if showNotes
        array<Note> notes = array.new<Note>()
        f_note(notes, ch1, "Chart", len1, colCh), f_note(notes, ch2, "Chart", len2, colCh), f_note(notes, ch3, "Chart", len3, colCh)
        f_note(notes, v0a, "1m", len1, col0), f_note(notes, v0b, "1m", len2, col0), f_note(notes, v0c, "1m", len3, col0)
        f_note(notes, v1a, "3m", len1, col1), f_note(notes, v1b, "3m", len2, col1), f_note(notes, v1c, "3m", len3, col1)
        f_note(notes, v2a, "5m", len1, col2), f_note(notes, v2b, "5m", len2, col2), f_note(notes, v2c, "5m", len3, col2)
        f_note(notes, v3a, "15m", len1, col3), f_note(notes, v3b, "15m", len2, col3), f_note(notes, v3c, "15m", len3, col3)
        f_note(notes, v4a, "30m", len1, col4), f_note(notes, v4b, "30m", len2, col4), f_note(notes, v4c, "30m", len3, col4)
        f_note(notes, v5a, "1h", len1, col5), f_note(notes, v5b, "1h", len2, col5), f_note(notes, v5c, "1h", len3, col5)
        f_note(notes, v6a, "4h", len1, col6), f_note(notes, v6b, "4h", len2, col6), f_note(notes, v6c, "4h", len3, col6)
        f_note(notes, v7a, "8h", len1, col7), f_note(notes, v7b, "8h", len2, col7), f_note(notes, v7c, "8h", len3, col7)
        f_note(notes, v8a, "1D", len1, col8), f_note(notes, v8b, "1D", len2, col8), f_note(notes, v8c, "1D", len3, col8)
        f_note(notes, v9a, "3D", len1, col9), f_note(notes, v9b, "3D", len2, col9), f_note(notes, v9c, "3D", len3, col9)
        f_note(notes, v10a, "1W", len1, col10), f_note(notes, v10b, "1W", len2, col10), f_note(notes, v10c, "1W", len3, col10)

        // Draw in price order so close lines get separate, ordered note rows.
        array<float> prices = array.new<float>()
        for n in notes
            array.push(prices, n.price)
        array<int> idx = array.sort_indices(prices, order.ascending)
        array<float> sorted = array.new<float>()
        for ix in idx
            array.push(sorted, array.get(prices, ix))
        float span = math.max(nz(visibleHigh, high) - nz(visibleLow, low), syminfo.mintick)
        array<float> rows = f_labelRows(sorted, span * noteSpacing / 100)

        int barMs = int(chartSeconds * 1000)
        int lineEnd = time
        int noteX = math.max(chart.right_visible_bar_time, time) + barMs * noteOffset
        string mode = noRepaint ? "closed higher-timeframe bars" : "live higher-timeframe bars"
        int row = 0
        for ix in idx
            Note n = array.get(notes, ix)
            float y = array.get(rows, row)
            row += 1
            string tip = "EMA " + str.tostring(n.len) + " — " + n.names + "\nValue: " + str.tostring(n.value, format.mintick) + "\nSource: " + mode
            array.push(noteLines, line.new(x1=lineEnd, y1=n.price, x2=noteX, y2=y, xloc=xloc.bar_time, color=color.new(n.col, 60), style=line.style_dotted, width=1))
            array.push(noteLabels, label.new(x=noteX, y=y, text="EMA " + str.tostring(n.len) + " · " + n.names, xloc=xloc.bar_time, style=label.style_label_left, textalign=text.align_left, color=color.new(n.col, 100), textcolor=color.new(n.col, 10), size=noteSize, tooltip=tip))
````
