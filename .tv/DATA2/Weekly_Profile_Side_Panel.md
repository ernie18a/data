<!-- tradingview-pine-id: PUB;cdd3a2cc59884813b820129eef7e65d4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Weekly Profile (Side Panel)

Source: https://www.tradingview.com/script/B9jVuqUW-Weekly-Profile-Side-Panel/

## Description

Weekly Profile (Side Panel)

Builds a live, day-by-day "weekly profile" of daily candles and displays them as a compact panel off to the side of live price, on any chart timeframe of 4H or lower.

How it works:
- Each trading day is defined using the standard futures/forex session convention: 18:00 ET to 18:00 ET the next day. Sunday 18:00 ET marks the start of the "Monday" session.
- As the week progresses, the indicator accumulates a running Open/High/Low/Close for each weekday from the lower-timeframe bars on your chart, effectively reconstructing what the daily candle would look like.
- On Monday, only the Monday candle is shown, updating live. On Tuesday, Monday (finalized) and Tuesday (live) are both shown. This continues through Friday.
- When the Friday session closes and the next Monday session opens, the whole panel resets and rebuilds for the new week.

Display:
- The 5 daily candles are drawn as boxes (bodies) with wick lines, positioned in a fixed panel to the right of the live price action rather than overlaid on the real bars.
- Body fill color reflects up/down, with a separate customizable border color/width so the bodies are clearly outlined.
- Optional Mon/Tue/Wed/Thu/Fri labels under each candle.
- Gap from live price, candle width, and spacing between candles are all adjustable inputs.

Notes:
- Only runs on timeframes of 4H or lower; on higher timeframes it shows a warning label instead.
- Designed for instruments with real session gaps (futures, forex); on 24/7 feeds the reset still triggers off the NY 18:00 boundary but there's no actual market closure to align it with.

---

## Source Code

````pine
//@version=6
indicator("Weekly Profile (Side Panel)", overlay = true, max_bars_back = 500)

// ---------------- Inputs ----------------
gapBars       = input.int(10, "Gap from live price (bars)", minval = 1)
candleWidth   = input.int(4, "Candle width (bars, half-width used)", minval = 2)
candleSpacing = input.int(6, "Spacing between candles (bars)", minval = 3)
upColor       = input.color(color.new(#26a69a, 0), "Up color")
dnColor       = input.color(color.new(#000000, 0), "Down color")
wickColor     = input.color(color.new(#787b86, 0), "Wick color")
borderColor   = input.color(color.new(#000000, 0), "Body border color")
borderWidth   = input.int(1, "Body border width", minval = 1, maxval = 4)
showLabels    = input.bool(true, "Show Mon/Tue/... labels")

// Weekly session (futures/forex convention): each trading day runs
// 18:00 ET -> 18:00 ET the next calendar day. Sunday 18:00 ET starts "Monday".
tz = "America/New_York"

validTf = timeframe.in_seconds() <= 14400  // <= 4H

// ---------------- Session / day-of-week detection ----------------
nyHour = hour(time, tz)
nyDow  = dayofweek(time, tz)                       // Sunday = 1 ... Saturday = 7

// The session a bar belongs to: after 18:00 ET it belongs to the NEXT calendar day's session
sessionDow = nyHour >= 18 ? (nyDow == 7 ? 1 : nyDow + 1) : nyDow

newSession = ta.change(sessionDow) != 0
dowIdx     = sessionDow - 2                        // Monday -> 0 ... Friday -> 4
validDay   = dowIdx >= 0 and dowIdx <= 4

// ---------------- Persistent per-day OHLC storage ----------------
var float[] dO = array.new_float(5, na)
var float[] dH = array.new_float(5, na)
var float[] dL = array.new_float(5, na)
var float[] dC = array.new_float(5, na)

var box[]   boxes  = array.new_box(5, na)
var line[]  wicks  = array.new_line(5, na)
var label[] labels = array.new_label(5, na)

dayNames = array.from("Mon", "Tue", "Wed", "Thu", "Fri")

if validTf and validDay
    if newSession
        if sessionDow == 2  // fresh Monday session -> wipe the whole week
            array.fill(dO, na)
            array.fill(dH, na)
            array.fill(dL, na)
            array.fill(dC, na)
        array.set(dO, dowIdx, open)
        array.set(dH, dowIdx, high)
        array.set(dL, dowIdx, low)
        array.set(dC, dowIdx, close)
    else
        array.set(dH, dowIdx, math.max(array.get(dH, dowIdx), high))
        array.set(dL, dowIdx, math.min(array.get(dL, dowIdx), low))
        array.set(dC, dowIdx, close)

// ---------------- Draw / refresh the side panel ----------------
if validTf and barstate.islast
    halfW = math.max(1, candleWidth / 2)
    for i = 0 to 4
        o = array.get(dO, i)
        h = array.get(dH, i)
        l = array.get(dL, i)
        c = array.get(dC, i)

        oldBox = array.get(boxes, i)
        oldWk  = array.get(wicks, i)
        oldLbl = array.get(labels, i)
        if not na(oldBox)
            box.delete(oldBox)
        if not na(oldWk)
            line.delete(oldWk)
        if not na(oldLbl)
            label.delete(oldLbl)

        if na(o)
            array.set(boxes, i, na)
            array.set(wicks, i, na)
            array.set(labels, i, na)
        else
            xCenter = bar_index + gapBars + i * candleSpacing
            xLeft   = xCenter - halfW
            xRight  = xCenter + halfW
            bodyTop = math.max(o, c)
            bodyBot = math.min(o, c)
            col     = c >= o ? upColor : dnColor

            newWk  = line.new(xCenter, l, xCenter, h, xloc.bar_index, color = wickColor, width = 1)
            newBox = box.new(xLeft, bodyTop, xRight, bodyBot, border_color = borderColor, border_width = borderWidth, bgcolor = col)
            array.set(wicks, i, newWk)
            array.set(boxes, i, newBox)

            if showLabels
                newLbl = label.new(xCenter, l, array.get(dayNames, i), xloc.bar_index, yloc.price, color = color.new(color.gray, 100), textcolor = color.gray, style = label.style_label_up, size = size.small)
                array.set(labels, i, newLbl)
            else
                array.set(labels, i, na)

if not validTf and barstate.islast
    label.new(bar_index, high, "Weekly Profile: switch to a timeframe <= 4H", style = label.style_label_down, color = color.red, textcolor = color.white)
````
