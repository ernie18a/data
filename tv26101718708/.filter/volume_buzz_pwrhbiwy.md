#  Volume Buzz

- url: https://www.tradingview.com/script/PWrhbIWy-Volume-Buzz/
- type: indicator
- pine_id: PUB;f246029ea32f4765aa56645c3b103dcd
- version: 1.0

## Description

Volume Buzz/Run Rate

Most RVol indicators measure volume against the full-day average — which tells you very little intraday. This indicator solves that by comparing each bar's volume only against the same time slot from previous days, giving you a true apples-to-apples volume reading throughout the session.

How It Works

The indicator runs two modes depending on where you are in the session:

9:30–9:44 (Early Session): Uses a cumulative 1-min comparison, measuring total volume printed so far against the average cumulative volume at that same point in time over the lookback period. This gives you an accurate read on opening drive strength before a full 5-min bar has formed.

9:45+ (Rest of Session): Switches to 5-min slot-based comparison, measuring each 5-min bar against the historical average for that specific time slot. The value holds between bars so it doesn't flicker.

How to Read It

The "Volume Buzz" label displays the current multiplier in real time.

Green (≥ 2.5x): Significantly above average volume for this time of day. Institutional participation likely. High-quality signal on breakouts and momentum moves.
Red (< 1.0x): Below average. Avoid chasing moves — low conviction, prone to fading.
White (1.0x–2.5x): Normal range. Neutral.

Inputs

Lookback Days: How many prior sessions to average (default 14)
High/Low Thresholds: Customize the green/red cutoffs to fit your style
Table Size and Colors: Fully adjustable

Best Use Cases

Works on any intraday timeframe. Designed for momentum and breakout traders who need to know whether the volume behind a move is real or noise — particularly useful in the first 30 minutes of the session.

## Source Code

````pine
//@version=6
indicator("Time-of-Day Volume Buzz", shorttitle="Vol Buzz", overlay=false)

length      = input.int(14, "Lookback Days", minval=5, maxval=50)
highLine    = input.float(2.5, "High Threshold", minval=0.1, step=0.1)
lowLine     = input.float(1.0, "Low Threshold",  minval=0.1, step=0.1)
colHigh     = input.color(color.new(#00ff00, 0),      "Above 2.5x Color")
colLow      = input.color(color.new(#ff0015, 0),      "Below 1.0x Color")
colNeutral  = input.color(color.new(#787b86, 0),      "Neutral Color")
colLine     = input.color(color.new(color.white, 60), "Threshold Line Color")
bg_col      = input.color(color.new(color.black, 100), 'Background', group='Table')
tbl_size    = input.string('Normal', 'Table Size', options=['Tiny','Small','Normal','Large'], group='Table')

size_tbl = switch tbl_size
    'Normal' => size.normal
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Large'  => size.large

// ── Core Volume Buzz function — parameterized for 1-min or 5-min ─────
f_tod_buzz(slotMinutes) =>
    isMarket  = hour >= 9 and hour < 16 and not (hour == 9 and minute < 30)
    maxSlots  = slotMinutes == 1 ? 390 : 78
    minIdx    = int(((hour - 9) * 60 + (minute - 30)) / slotMinutes)

    var float[] slotHistory = array.new_float(maxSlots * 51, na)
    var float[] slotAvg     = array.new_float(maxSlots, na)

    float buzz = na

    if isMarket and minIdx >= 0 and minIdx < maxSlots
        for i = length - 1 to 1
            array.set(slotHistory, minIdx * 50 + i, array.get(slotHistory, minIdx * 50 + i - 1))
        array.set(slotHistory, minIdx * 50 + 0, volume)

        float s = 0.0
        int   c = 0
        for i = 1 to length
            v = array.get(slotHistory, minIdx * 50 + i)
            if not na(v)
                s += v
                c += 1

        float avg = c > 0 ? s / c : na
        array.set(slotAvg, minIdx, avg)
        buzz := not na(avg) and avg > 0 ? volume / avg : na

    buzz

// ── 5-min held Volume Buzz (post-9:44) ──────────────────────────────
f_buzz_both(slotMinutes) =>
    b = f_tod_buzz(slotMinutes)
    isEarly = hour == 9 and minute >= 30 and minute <= 44
    held = isEarly ? b : b[barstate.isrealtime ? 1 : 0]
    [b, held]

// ── Cumulative early-session Volume Buzz (9:30–9:44) ─────────────────
f_cumulative_early_buzz() =>
    isMarket = hour >= 9 and hour < 16 and not (hour == 9 and minute < 30)
    isEarly  = hour == 9 and minute >= 30 and minute <= 44
    earlyIdx = minute - 30

    var float[] earlyHistory = array.new_float(15 * 51, na)
    var float[] earlyAvgCum  = array.new_float(15, na)

    float cumBuzz = na

    if isMarket and isEarly and earlyIdx >= 0 and earlyIdx < 15
        for i = length - 1 to 1
            array.set(earlyHistory, earlyIdx * 50 + i, array.get(earlyHistory, earlyIdx * 50 + i - 1))
        array.set(earlyHistory, earlyIdx * 50 + 0, volume)

        float totalCum = 0.0
        int   dayCnt   = 0
        for d = 1 to length
            float daySum = 0.0
            bool  dayOk  = true
            for slot = 0 to earlyIdx
                v = array.get(earlyHistory, slot * 50 + d)
                if na(v)
                    dayOk := false
                    break
                daySum += v
            if dayOk
                totalCum += daySum
                dayCnt   += 1

        float avgCum = dayCnt > 0 ? totalCum / dayCnt : na
        array.set(earlyAvgCum, earlyIdx, avgCum)
        cumBuzz := avgCum

    cumBuzz

// ── Security calls ────────────────────────────────────────────
avgCumFor1m = request.security(syminfo.tickerid, "1", f_cumulative_early_buzz(),
              gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[buzzLive_5m, buzzHeld_5m] = request.security(syminfo.tickerid, "5", f_buzz_both(5),
              gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ── State ─────────────────────────────────────────────────────
isMarketOpen     = hour >= 9 and not (hour == 9 and minute < 30) and hour < 16
isEarlyOnChart   = hour == 9 and minute >= 30 and minute <= 44
isOpenBar        = hour == 9 and minute == 30

var float chartEarlyCumVol = 0.0
var int   chartEarlyDay    = na

if isOpenBar and (na(chartEarlyDay) or dayofmonth != chartEarlyDay)
    chartEarlyCumVol := 0.0
    chartEarlyDay    := dayofmonth

if isEarlyOnChart
    chartEarlyCumVol := chartEarlyCumVol + volume

cumulativeBuzz = not na(avgCumFor1m) and avgCumFor1m > 0
     ? chartEarlyCumVol / avgCumFor1m : na

buzzDisplay = isEarlyOnChart ? cumulativeBuzz : buzzHeld_5m

// ── Peak tracking ─────────────────────────────────────────────
var float curBuzz  = na
var float peakBuzz = na
var int   lastDay  = na

if isOpenBar and (na(lastDay) or dayofmonth != lastDay)
    curBuzz  := na
    peakBuzz := na
    lastDay  := dayofmonth

if isMarketOpen
    newVal = buzzDisplay
    if not na(newVal)
        curBuzz := newVal
        if na(peakBuzz) or curBuzz > peakBuzz
            peakBuzz := curBuzz

// ── Volume Buzz color helper ─────────────────────────────────────────
f_buzz_color(val) =>
    if na(val)
        colNeutral
    else if val >= highLine
        close >= open ? colHigh : colLow
    else if val < lowLine
        colLow
    else
        colNeutral

// ── Table ────────────────────────────────────────────────────
var table buzz_tbl = table.new(position.top_left, 2, 1, bgcolor=bg_col, border_width=0, frame_width=0)

if barstate.islast
    buzzStr = not na(curBuzz) ? str.tostring(curBuzz, "0.0") + "x" : "—"
    col_cur = f_buzz_color(curBuzz)

    table.cell(buzz_tbl, 0, 0, "Volume Buzz", text_color=color.white, text_size=size_tbl, text_halign=text.align_left)
    table.cell(buzz_tbl, 1, 0, buzzStr,       text_color=col_cur,     text_size=size_tbl, text_halign=text.align_center)
````
