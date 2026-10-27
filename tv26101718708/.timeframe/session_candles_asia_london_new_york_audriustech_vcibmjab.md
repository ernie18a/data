# Session Candles - Asia / London / New York - AudriusTech

- url: https://www.tradingview.com/script/vcIbmjAb-Session-Candles-Asia-London-New-York-AudriusTech/
- type: indicator
- pine_id: PUB;76ae5b2b20854755be8200c1e03960e2
- version: 2.0

## Description

**Session Candles – Asia, London & New York** displays one enlarged candle for each trading session on the right side of your chart. This gives you a clear view of each session’s price movement, range and candle structure.

Each candle combines the session’s **open, high, low and close**. The body shows the movement between the opening and closing prices, while the wicks show the highest and lowest prices reached. Candles remain aligned with the chart’s actual price scale.

The default sessions are:

| Session  | New York time                 |
| -------- | ----------------------------- |
| Asia     | 21:00–02:00 the following day |
| London   | 03:00–06:00                   |
| New York | 09:30–16:30                   |

All session times are adjustable and follow New York daylight-saving changes automatically.

During an active session, its candle updates as new prices arrive. After the session ends, the completed candle remains visible until the next occurrence of that session begins. Each label shows the session name, its ending date and whether it is **LIVE** or **CLOSED**.

You can choose **any of the six possible candle orders**, with the first selected session appearing closest to the main chart. Other settings let you adjust candle width, spacing, distance from the chart, bullish and bearish colours, and whether OHLC prices appear beneath the candles.

The indicator uses available one-minute price data and supports standard intraday charts of one minute or higher. Enable extended trading hours where available to receive updates during overnight sessions.

## Source Code

````pine
//@version=6
indicator("Session Candles - Asia / London / New York", overlay = true, max_boxes_count = 10, max_lines_count = 20, max_labels_count = 10)

// One OHLC candle per session, drawn to the right of the latest chart bar.
// Use a standard intraday chart of 1 minute or higher. Enable extended hours
// on the chart for updates during the overnight sessions, where available.
// The three most recent sessions stay visible in chronological order.
// The date beneath each candle is its session END date in New York time.
// A new session appears on the right and pushes the oldest one off the left.
// With the default hours, the row rolls through Asia -> London -> New York.

const string TZ = "America/New_York"

asiaSession = input.session("2100-0200", "Asia", group = "Sessions - New York time")
londonSession = input.session("0300-0600", "London", group = "Sessions - New York time")
nySession = input.session("0930-1630", "New York", group = "Sessions - New York time")

rightOffset = input.int(12, "Distance from chart (bars)", minval = 2, maxval = 100, group = "Appearance")
bodyWidth = input.int(8, "Candle width (bars)", minval = 2, maxval = 20, step = 2, group = "Appearance")
candleGap = input.int(10, "Gap between candles (bars)", minval = 2, maxval = 30, group = "Appearance")
bullColor = input.color(color.rgb(38, 166, 154), "Bullish candle", group = "Appearance")
bearColor = input.color(color.rgb(239, 83, 80), "Bearish candle", group = "Appearance")
showPrices = input.bool(false, "Show OHLC beneath candles", group = "Appearance")

if not chart.is_standard or not timeframe.isintraday or timeframe.isseconds
    runtime.error("Use a standard time-based intraday chart of 1 minute or higher.")

// Runs INSIDE the requested 1-minute context, so larger chart bars cannot
// contribute prices from outside a session. Start is inclusive; end exclusive.
sessionOHLC(simple string sessionHours) =>
    var float sessionOpen = na
    var float sessionHigh = na
    var float sessionLow = na
    var float sessionClose = na
    var int sessionStart = na
    var int sessionEnd = na

    int startHour = int(str.tonumber(str.substring(sessionHours, 0, 2)))
    int startMinute = int(str.tonumber(str.substring(sessionHours, 2, 4)))
    int endHour = int(str.tonumber(str.substring(sessionHours, 5, 7)))
    int endMinute = int(str.tonumber(str.substring(sessionHours, 7, 9)))
    int startMinutes = startHour * 60 + startMinute
    int endMinutes = endHour * 60 + endMinute
    int localMinutes = hour(time, TZ) * 60 + minute(time, TZ)
    bool inside = not na(time("1", sessionHours, TZ))

    if inside
        // After midnight, an overnight session still belongs to its start date.
        // Calendar arithmetic also handles month/year changes and NY DST.
        int previousDay = localMinutes < startMinutes ? 1 : 0
        int startStamp = timestamp(TZ, year(time, TZ), month(time, TZ), dayofmonth(time, TZ) - previousDay, startHour, startMinute)
        bool newSession = na(sessionStart) or startStamp != sessionStart

        if newSession
            sessionOpen := open
            sessionHigh := high
            sessionLow := low
            sessionStart := startStamp
            int overnight = endMinutes <= startMinutes ? 1 : 0
            sessionEnd := timestamp(TZ, year(startStamp, TZ), month(startStamp, TZ), dayofmonth(startStamp, TZ) + overnight, endHour, endMinute)
        else
            sessionHigh := math.max(sessionHigh, high)
            sessionLow := math.min(sessionLow, low)

        sessionClose := close

    [sessionOpen, sessionHigh, sessionLow, sessionClose, sessionStart, sessionEnd]

// Extended-hours data is requested where the instrument/provider supports it.
string sourceTicker = ticker.modify(syminfo.tickerid, session = session.extended)
[aO, aH, aL, aC, aStart, aEnd] = request.security(sourceTicker, "1", sessionOHLC(asiaSession), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 20000)
[lO, lH, lL, lC, lStart, lEnd] = request.security(sourceTicker, "1", sessionOHLC(londonSession), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 20000)
[nO, nH, nL, nC, nStart, nEnd] = request.security(sourceTicker, "1", sessionOHLC(nySession), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 20000)

priceText(float value) =>
    str.tostring(value, format.mintick)

// Each written call has its own persistent drawing objects.
drawCandle(int slot, string sessionName, color nameColor, float o, float h, float l, float c, int starts, int ends, int referenceTime, float labelY) =>
    var line wick = line.new(x1 = na, y1 = na, x2 = na, y2 = na, xloc = xloc.bar_index, width = 2)
    var box body = box.new(left = na, top = na, right = na, bottom = na, xloc = xloc.bar_index, border_width = 2)
    var line doji = line.new(x1 = na, y1 = na, x2 = na, y2 = na, xloc = xloc.bar_index, width = 2)
    var label caption = label.new(x = na, y = na, text = "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = color.new(color.black, 100), size = size.small)

    int leftX = bar_index + rightOffset + slot * (bodyWidth + candleGap)
    int rightX = leftX + bodyWidth
    int centerX = leftX + int(bodyWidth / 2)
    label.set_xy(caption, centerX, labelY)
    label.set_textcolor(caption, nameColor)

    if not na(o)
        color candleColor = c >= o ? bullColor : bearColor
        line.set_xy1(wick, centerX, h)
        line.set_xy2(wick, centerX, l)
        line.set_color(wick, candleColor)

        box.set_lefttop(body, leftX, math.max(o, c))
        box.set_rightbottom(body, rightX, math.min(o, c))
        box.set_border_color(body, candleColor)
        box.set_bgcolor(body, candleColor)

        // Explicit horizontal body for a true doji; no artificial price height.
        line.set_xy1(doji, leftX, o)
        line.set_xy2(doji, rightX, o)
        line.set_color(doji, o == c ? candleColor : color.new(candleColor, 100))

        bool active = referenceTime >= starts and referenceTime < ends
        string stateText = active ? "LIVE" : "CLOSED"
        string values = "O: " + priceText(o) + "\nH: " + priceText(h) + "\nL: " + priceText(l) + "\nC: " + priceText(c)
        string captionText = sessionName + "\n" + str.format_time(ends, "dd MMM", TZ) + "\n" + stateText
        label.set_text(caption, captionText + (showPrices ? "\n" + values : ""))
        label.set_tooltip(caption, sessionName + " | New York time\n" + str.format_time(starts, "dd MMM yyyy HH:mm", TZ) + " to\n" + str.format_time(ends, "dd MMM yyyy HH:mm", TZ) + "\n\n" + values)
    else
        label.set_text(caption, sessionName + "\nNO SESSION DATA")
        label.set_tooltip(caption, "No 1-minute bars found for this session. Check the instrument's trading hours and data availability.")

// Keep the last three distinct session starts. Incoming values can arrive in a
// different order on larger chart timeframes, so insert by actual start time.
var array<int> starts = array.new<int>()
var array<int> ends = array.new<int>()
var array<string> names = array.new<string>()
var array<color> nameColors = array.new<color>()
var array<float> opens = array.new<float>()
var array<float> highs = array.new<float>()
var array<float> lows = array.new<float>()
var array<float> closes = array.new<float>()

rememberSession(string name, color nameColor, float o, float h, float l, float c, int startTime, int endTime) =>
    if not na(startTime) and not na(o)
        int existing = array.indexof(starts, startTime)
        if existing >= 0
            array.set(highs, existing, h)
            array.set(lows, existing, l)
            array.set(closes, existing, c)
        else if array.size(starts) < 3 or startTime > array.get(starts, 0)
            int position = array.size(starts)
            if array.size(starts) > 0
                for i = 0 to array.size(starts) - 1
                    if startTime < array.get(starts, i)
                        position := i
                        break
            array.insert(starts, position, startTime)
            array.insert(ends, position, endTime)
            array.insert(names, position, name)
            array.insert(nameColors, position, nameColor)
            array.insert(opens, position, o)
            array.insert(highs, position, h)
            array.insert(lows, position, l)
            array.insert(closes, position, c)
            if array.size(starts) > 3
                array.shift(starts)
                array.shift(ends)
                array.shift(names)
                array.shift(nameColors)
                array.shift(opens)
                array.shift(highs)
                array.shift(lows)
                array.shift(closes)

    // Consistent return type for both insertion and live-update paths.
    array.size(starts)

rememberSession("ASIA", color.orange, aO, aH, aL, aC, aStart, aEnd)
rememberSession("LONDON", color.rgb(66, 165, 245), lO, lH, lL, lC, lStart, lEnd)
rememberSession("NEW YORK", color.rgb(171, 71, 188), nO, nH, nL, nC, nStart, nEnd)

if barstate.islast
    float lowest = low
    float highest = high
    if array.size(starts) > 0
        for i = 0 to array.size(starts) - 1
            lowest := math.min(lowest, array.get(lows, i))
            highest := math.max(highest, array.get(highs, i))
    float padding = math.max((highest - lowest) * 0.08, syminfo.mintick * 10)
    int referenceTime = barstate.isrealtime ? timenow : time_close

    // Separate call sites give each slot its own persistent drawing objects.
    if array.size(starts) > 0
        drawCandle(0, array.get(names, 0), array.get(nameColors, 0), array.get(opens, 0), array.get(highs, 0), array.get(lows, 0), array.get(closes, 0), array.get(starts, 0), array.get(ends, 0), referenceTime, lowest - padding)
    if array.size(starts) > 1
        drawCandle(1, array.get(names, 1), array.get(nameColors, 1), array.get(opens, 1), array.get(highs, 1), array.get(lows, 1), array.get(closes, 1), array.get(starts, 1), array.get(ends, 1), referenceTime, lowest - padding)
    if array.size(starts) > 2
        drawCandle(2, array.get(names, 2), array.get(nameColors, 2), array.get(opens, 2), array.get(highs, 2), array.get(lows, 2), array.get(closes, 2), array.get(starts, 2), array.get(ends, 2), referenceTime, lowest - padding)
````
