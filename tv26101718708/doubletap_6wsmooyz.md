# DoubleTap

- url: https://www.tradingview.com/script/6wSMoOYZ-DoubleTap/
- type: indicator
- pine_id: PUB;62800590bb6f4b4c9f64842433479961
- version: 1.0

## Description

v1.0
DoubleTap automatically detects when the current candle's high or low 
revisits a previous price level within a defined tolerance — a key concept 
in price action trading often signaling support, resistance, or potential 
reversal zones.

🟢 Green arrows mark HIGH-to-HIGH matches
🔴 Red arrows mark LOW-to-LOW matches
🔢 Each pair is numbered so you can track multiple touches at once

⚙️ Features:
- Adjustable price tolerance (default 0.25 points)
- Minimum candle gap between touches
- Lookback window in trading days
- Session time filter with full timezone support (45 cities)
- Works on any intraday timeframe

Designed for intraday traders who use price action, support/resistance, 
and liquidity levels as part of their strategy.

## Source Code

````pine
//@version=6
indicator("Double Touch Arrows", overlay=true, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
tolerance    = input.float(0.25, "Max Price Difference (points)", step=0.05)
minGap       = input.int(2,      "Min Candles Between Touches", minval=1)
lookbackDays = input.int(3,      "Lookback (Trading Days)", minval=1, maxval=10)
showLabels   = input.bool(true,  "Show Pair Labels")
maxPairs     = input.int(30,     "Max Pairs to Display", minval=5, maxval=100)

// ─── TIME FILTER ──────────────────────────────────────────────────────────────
useTimeFilter = input.bool(true,  "Enable Time Filter", group="⏰ Session Filter")
startHour     = input.int(9,      "Start Hour (24h)",   minval=0, maxval=23, group="⏰ Session Filter")
startMinute   = input.int(30,     "Start Minute",       minval=0, maxval=59, group="⏰ Session Filter")
endHour       = input.int(16,     "End Hour (24h)",     minval=0, maxval=23, group="⏰ Session Filter")
endMinute     = input.int(0,      "End Minute",         minval=0, maxval=59, group="⏰ Session Filter")

tzChoice = input.string("America/New_York", "Timezone", group="⏰ Session Filter",
     options=[
         "America/New_York",
         "America/Chicago",
         "America/Denver",
         "America/Los_Angeles",
         "America/Sao_Paulo",
         "America/Toronto",
         "America/Vancouver",
         "America/Mexico_City",
         "Europe/London",
         "Europe/Paris",
         "Europe/Berlin",
         "Europe/Madrid",
         "Europe/Rome",
         "Europe/Amsterdam",
         "Europe/Zurich",
         "Europe/Stockholm",
         "Europe/Oslo",
         "Europe/Helsinki",
         "Europe/Warsaw",
         "Europe/Istanbul",
         "Europe/Moscow",
         "Africa/Cairo",
         "Africa/Johannesburg",
         "Africa/Lagos",
         "Asia/Jerusalem",
         "Asia/Riyadh",
         "Asia/Dubai",
         "Asia/Karachi",
         "Asia/Kolkata",
         "Asia/Dhaka",
         "Asia/Bangkok",
         "Asia/Singapore",
         "Asia/Shanghai",
         "Asia/Hong_Kong",
         "Asia/Tokyo",
         "Asia/Seoul",
         "Asia/Taipei",
         "Asia/Kuala_Lumpur",
         "Asia/Jakarta",
         "Australia/Sydney",
         "Australia/Melbourne",
         "Australia/Brisbane",
         "Pacific/Auckland",
         "Pacific/Honolulu",
         "UTC"
     ])

// ─── COLORS ───────────────────────────────────────────────────────────────────
colHigh = color.new(#00C087, 0)
colLow  = color.new(#FF4D4D, 0)

// ─── INTRADAY GUARD ───────────────────────────────────────────────────────────
isIntraday = timeframe.isintraday

// ─── CONVERT DAYS → BARS ─────────────────────────────────────────────────────
tfMins     = timeframe.in_seconds() / 60
barsPerDay = math.max(1, math.round(390 / tfMins))
maxBars    = math.min(lookbackDays * barsPerDay, 500)

// ─── TIME HELPER ─────────────────────────────────────────────────────────────
barInSession(offset) =>
    if not useTimeFilter
        true
    else
        t         = time[offset]
        h         = hour(t, tzChoice)
        m         = minute(t, tzChoice)
        barMins   = h * 60 + m
        startMins = startHour * 60 + startMinute
        endMins   = endHour   * 60 + endMinute
        barMins >= startMins and barMins < endMins

// ─── PERSISTENT DRAWING ARRAYS ───────────────────────────────────────────────
var label[] drawnLabels = array.new<label>()

clearDrawings() =>
    for lb in drawnLabels
        label.delete(lb)
    array.clear(drawnLabels)

// ─── ARROW PLACEMENT ─────────────────────────────────────────────────────────
placeArrow(barIdx, isHigh, pairNum) =>
    col      = isHigh ? colHigh : colLow
    offset   = bar_index - barIdx
    yPos     = isHigh ? high[offset] : low[offset]
    arrowTxt = isHigh ? "▼" : "▲"
    sty      = isHigh ? label.style_label_down : label.style_label_up

    lb = label.new(
         x         = barIdx,
         y         = yPos,
         text      = arrowTxt,
         color     = col,
         style     = sty,
         textcolor = color.white,
         size      = size.small,
         xloc      = xloc.bar_index)
    array.push(drawnLabels, lb)

    if showLabels
        lbTxt = label.new(
             x         = barIdx,
             y         = isHigh ? high[offset] + syminfo.mintick * 20 : low[offset] - syminfo.mintick * 20,
             text      = "P" + str.tostring(pairNum),
             color     = color.new(col, 50),
             style     = isHigh ? label.style_label_down : label.style_label_up,
             textcolor = color.white,
             size      = size.tiny,
             xloc      = xloc.bar_index)
        array.push(drawnLabels, lbTxt)

// ─── MAIN LOGIC ───────────────────────────────────────────────────────────────
if isIntraday

    clearDrawings()

    if barInSession(0)

        scanLen   = math.min(maxBars, bar_index)
        highPairs = 0
        lowPairs  = 0

        for i = (minGap + 1) to scanLen
            if highPairs + lowPairs >= maxPairs
                break

            if not barInSession(i)
                continue

            // ── HIGH vs prev HIGH only — green ────────────────────────────────
            if math.abs(high - high[i]) <= tolerance
                highPairs += 1
                placeArrow(bar_index - i, true, highPairs)
                placeArrow(bar_index,     true, highPairs)

            // ── LOW vs prev LOW only — red ────────────────────────────────────
            if (highPairs + lowPairs) < maxPairs and math.abs(low - low[i]) <= tolerance
                lowPairs += 1
                placeArrow(bar_index - i, false, lowPairs)
                placeArrow(bar_index,     false, lowPairs)

else if barstate.islast and isIntraday
    label.new(
         x         = bar_index,
         y         = high,
         text      = "⏸ Outside Session Window",
         color     = color.new(color.gray, 20),
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.small,
         xloc      = xloc.bar_index)

else if barstate.islast
    label.new(
         x         = bar_index,
         y         = high,
         text      = "⚠️ Use an Intraday Timeframe",
         color     = color.new(color.red, 20),
         textcolor = color.white,
         style     = label.style_label_left,
         size      = size.normal,
         xloc      = xloc.bar_index)
````
