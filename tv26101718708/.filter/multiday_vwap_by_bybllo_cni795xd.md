# Multiday VWAP by Bybllo

- url: https://www.tradingview.com/script/CnI795xd/
- type: indicator
- pine_id: PUB;6526bb34b2f5447794b8914881c35a63
- version: 8.0

## Description

Multiday VWAP by Bybllo

OVERVIEW
This indicator plots up to 5 independent rolling Volume Weighted Average Price (VWAP) lines, each anchored a different number of calendar days back from the present bar (default: 2, 3, 4, 5, and 6 days back). Unlike a standard session VWAP that resets every day, each line here accumulates price*volume continuously from its own anchor day up to the current bar, giving traders a set of rolling reference levels for recent multi-day price/volume balance.

I built this for my own trading because I couldn't find an existing community script that did exactly this — a set of independent, multi-day rolling VWAP lines in one indicator — so I'm sharing it in case it's useful to others too.

KEY FEATURES
- 5 independently configurable rolling VWAP lines — toggle visibility, set the lookback in calendar days, and pick a color for each line individually.
- Lookback days are entered as calendar days (weekends included), so "6 days back" always lands on the same relative session regardless of where in the week you are.
- Real-price calculation — prices are pulled via request.security() against the plain ticker, so the VWAP values are identical whether your chart is displaying candlesticks, Heikin Ashi, Renko, or any other non-standard chart type. Volume is unaffected by chart type and is used as-is.
- Robust new-day detection — instead of relying on the chart's own bar-by-bar progress to detect a new trading day (which can be unreliable right after the chart first loads), this script requests daily-resolution data directly. Daily data loads much faster than intraday data, so the VWAP anchors are detected reliably even immediately after opening the chart.

HOW TO USE
Open the indicator settings and, for each of the 5 lines, set how many calendar days back you want that VWAP to start accumulating from. Use the lines as dynamic support/resistance or fair-value reference levels, similar to how a session VWAP is used, but for multi-day accumulation periods.

NOTES
- This script requires volume data from your data provider. If no volume is available for the symbol, the VWAP values will not calculate correctly.
- "Rolling Days" counts calendar days, not trading/session days.

Feedback and suggestions are welcome.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bybllo

//@version=6
// ══════════════════════════════════════════════════════════════════
// Multiday VWAP by Bybllo
// ══════════════════════════════════════════════════════════════════
// OVERVIEW
// This indicator plots up to 5 independent rolling Volume Weighted
// Average Price (VWAP) lines, each anchored a different number of
// real trading days back from the present bar (default: 2, 3, 4, 5,
// and 6 trading days back). Unlike a standard session VWAP that
// resets every day, each line here accumulates price*volume
// continuously from its own anchor day up to the current bar,
// giving traders a set of "rolling" reference levels for recent
// multi-day price/volume balance.
//
// WHY A ROLLING MULTI-DAY VWAP INSTEAD OF A SINGLE SESSION VWAP
// A standard session VWAP resets to zero every new trading day, so
// it only ever tells you where the volume-weighted average price
// sits relative to today's session. That's useful, but it throws
// away everything about how price and volume have balanced out over
// the last several days - information that often still matters for
// where price reacts intraday. This script keeps 5 separate VWAP
// calculations running in parallel, each starting its accumulation
// from a different day in the recent past, so you get a stack of
// "memory" levels from the last several sessions all visible on the
// current chart at once, instead of just today's.
//
// KEY FEATURES
// - 5 independently configurable rolling VWAP lines: toggle
//   visibility, set the lookback in trading days, and pick a color
//   for each line individually.
// - Lookback is counted in REAL TRADING DAYS, not calendar days.
//   Weekends and holidays (including irregular market closures that
//   don't follow a fixed calendar) never count as a lookback day,
//   so "N days back" always lands on an actual session with data -
//   you never have to manually adjust the count around a long
//   weekend or an unexpected market holiday.
// - Anchors are computed once per bar from a fixed reference point
//   (the live "now"), then locked to the first real trading day at
//   or after that point. If the calculated target date happens to
//   fall on an unscheduled holiday, the anchor automatically shifts
//   to the next available trading day instead of disappearing or
//   miscalculating.
// - Manual Anchor Mode. Flip a single toggle to switch all 5 lines
//   from the automatic "N trading days back" logic to 5
//   manually-entered anchor date/time pickers (year, month, day,
//   hour, minute), exactly like a classic multi-anchored-VWAP
//   script. This is useful when you want to anchor to a specific
//   event, session open, earnings date, or any date that doesn't
//   line up with a simple trading-day count. When Manual Anchor
//   Mode is on, the automatic rolling-day logic is fully disabled -
//   the two modes never run at the same time, so there's no
//   ambiguity about which anchor is actually in effect.
// - Real-price calculation: prices are pulled via request.security()
//   against the chart's own ticker, so the VWAP values are identical
//   whether your chart is displaying candlesticks, Heikin Ashi,
//   Renko, or any other non-standard chart type. Volume is
//   unaffected by chart type and is used as-is.
// - Each anchor point is marked with a small numbered label (#1-#5)
//   directly on the chart at the bar where that line begins
//   accumulating, so you can immediately see which VWAP corresponds
//   to which lookback setting without having to hover or check the
//   settings panel.
//
// HOW TO USE
// - Automatic mode (default): open the indicator settings and, for
//   each of the 5 lines, set how many trading days back you want
//   that VWAP to start accumulating from. Enter 1 for "yesterday's
//   session," 2 for "two trading days ago," and so on (internally
//   offset by one extra day so the first line defaults to 2 real
//   trading days back - adjust to taste).
// - Manual mode: enable "Manual Anchor Mode" and pick a date/time
//   for each of the 5 lines directly from the calendar picker.
//   Defaults are pre-filled a few days apart so you can see all 5
//   lines immediately, then adjust each one to the exact anchor you
//   want.
// - Use the lines as dynamic support/resistance or fair-value
//   reference levels, similar to how a session VWAP is used, but
//   for multi-day accumulation periods - price reacting at one of
//   these levels intraday can indicate that the recent multi-day
//   "fair value" zone is still relevant to current order flow.
//
// TYPICAL USE CASE
// Built for scalping/day trading futures (Nasdaq futures, KOSPI
// futures, Bitcoin futures, index futures from various countries,
// etc.). Showing the past several trading days' VWAP centerlines on
// the current bar gives a set of dynamic support/resistance levels
// to react to intraday. For the current (today's) session VWAP with
// standard deviation bands, use TradingView's own built-in VWAP
// indicator alongside this one - this script is meant to complement
// it with multi-day rolling reference levels, not replace it.
//
// NOTES
// - This script requires volume data from your data provider. If no
//   volume is available for the symbol, the VWAP values will not
//   calculate correctly.
// - "Rolling Days" counts real trading days (sessions with actual
//   bars), not calendar days - weekends and holidays are excluded
//   automatically. This only applies in automatic mode.
// - In Manual Anchor Mode, anchors are exact fixed timestamps, so no
//   trading-day counting or holiday logic applies - the line simply
//   starts accumulating at the date/time you set.
// - Because Pine Script's input() defaults must be compile-time
//   constants, the Manual Anchor Mode date pickers start out
//   pre-filled with a fixed set of example dates - these are only
//   starting points and are meant to be changed to whatever dates
//   you actually want to anchor to.
//
// DISCLAIMER
// For educational and informational purposes only. This is not
// financial advice. Past performance does not guarantee future
// results. Always verify how these levels behave on your specific
// symbol and timeframe before relying on them for live trading.
// ══════════════════════════════════════════════════════════════════
indicator('Multiday VWAP by Bybllo', overlay = true, timeframe = '', timeframe_gaps = true)

// ============================================
// INPUTS
// ============================================
showLabel = input(true, 'Show labels', group = 'Display')
source = input.source(hlc3, 'Source', display = display.data_window, group = 'Inputs')

// ---- Manual Anchor Mode toggle ----
manualMode = input.bool(false, 'Manual Anchor Mode (set dates manually)', group = 'Manual Anchor Mode')

show1 = input.bool(true, '', inline = 'v1', group = 'VWAP Lines')
rollingDays1 = input.int(1, 'Rolling Days #1', minval = 0, maxval = 30, inline = 'v1', group = 'VWAP Lines')
color1 = input.color(color.new(#f23645, 0), '', inline = 'v1', group = 'VWAP Lines')

show2 = input.bool(true, '', inline = 'v2', group = 'VWAP Lines')
rollingDays2 = input.int(2, 'Rolling Days #2', minval = 0, maxval = 30, inline = 'v2', group = 'VWAP Lines')
color2 = input.color(color.new(#f57c00, 0), '', inline = 'v2', group = 'VWAP Lines')

show3 = input.bool(true, '', inline = 'v3', group = 'VWAP Lines')
rollingDays3 = input.int(3, 'Rolling Days #3', minval = 0, maxval = 30, inline = 'v3', group = 'VWAP Lines')
color3 = input.color(color.new(#2962ff, 0), '', inline = 'v3', group = 'VWAP Lines')

show4 = input.bool(true, '', inline = 'v4', group = 'VWAP Lines')
rollingDays4 = input.int(4, 'Rolling Days #4', minval = 0, maxval = 30, inline = 'v4', group = 'VWAP Lines')
color4 = input.color(color.new(#4caf50, 50), '', inline = 'v4', group = 'VWAP Lines')

show5 = input.bool(true, '', inline = 'v5', group = 'VWAP Lines')
rollingDays5 = input.int(5, 'Rolling Days #5', minval = 0, maxval = 30, inline = 'v5', group = 'VWAP Lines')
color5 = input.color(color.new(#9c27b0, 55), '', inline = 'v5', group = 'VWAP Lines')

// ---- Manual anchor date/time inputs ----
// Pine's input defval only accepts compile-time literal constants (no
// "today" auto-calculation is possible), so these default to a fixed
// set of dates spaced one day apart, at 18:00 KST (UTC+9). Click any
// picker to change the date/time freely.
manualDate1 = input.time(timestamp('2026-07-18T18:00+09:00'), 'Date #1', inline = 'm1', group = 'Manual Anchor Mode')
manualDate2 = input.time(timestamp('2026-07-17T18:00+09:00'), 'Date #2', inline = 'm2', group = 'Manual Anchor Mode')
manualDate3 = input.time(timestamp('2026-07-16T18:00+09:00'), 'Date #3', inline = 'm3', group = 'Manual Anchor Mode')
manualDate4 = input.time(timestamp('2026-07-15T18:00+09:00'), 'Date #4', inline = 'm4', group = 'Manual Anchor Mode')
manualDate5 = input.time(timestamp('2026-07-14T18:00+09:00'), 'Date #5', inline = 'm5', group = 'Manual Anchor Mode')

// ============================================
// Force real market prices regardless of chart type (Heikin Ashi, Renko, etc.)
// Using syminfo.tickerid (not a freshly-built ticker.new) preserves the
// chart's own adjustment/session/currency settings, avoiding price offsets.
// ============================================
realSource = request.security(syminfo.tickerid, timeframe.period, source, barmerge.gaps_off, barmerge.lookahead_off)

// ============================================
// Compute the target anchor date (real trading days back from "now")
// timenow stays constant for the whole script run, so this target is
// a fixed reference point, not something that drifts bar to bar.
// Only used in automatic mode.
// ============================================
msPerDay = 86400000

f_targetDate(n) =>
    d = timenow
    count = 0
    result = timenow
    for i = 1 to 60
        d -= msPerDay
        dow = dayofweek(d)
        if dow != dayofweek.saturday and dow != dayofweek.sunday
            count += 1
            if count == n
                result := d
                break
    result

target1 = f_targetDate(rollingDays1 + 1)
target2 = f_targetDate(rollingDays2 + 1)
target3 = f_targetDate(rollingDays3 + 1)
target4 = f_targetDate(rollingDays4 + 1)
target5 = f_targetDate(rollingDays5 + 1)

// ============================================
// Anchor lock: match the first REAL trading day at or after the target
// date, exactly once. Weekends are already excluded from the target
// date calculation; unscheduled holidays are absorbed here because we
// don't require an exact date match — the first available session
// after the target time is used instead, then the flag prevents any
// re-trigger.
// When Manual Anchor Mode is on, this automatic logic never triggers
// (match is forced false), so it is fully disabled.
// ============================================
isNewDay = ta.change(time('D')) != 0

var bool started1 = false
var bool started2 = false
var bool started3 = false
var bool started4 = false
var bool started5 = false

match1 = not manualMode and isNewDay and not started1 and time >= target1
match2 = not manualMode and isNewDay and not started2 and time >= target2
match3 = not manualMode and isNewDay and not started3 and time >= target3
match4 = not manualMode and isNewDay and not started4 and time >= target4
match5 = not manualMode and isNewDay and not started5 and time >= target5

if match1
    started1 := true
if match2
    started2 := true
if match3
    started3 := true
if match4
    started4 := true
if match5
    started5 := true

autoAnchor1 = ta.valuewhen(match1, time, 0)
autoAnchor2 = ta.valuewhen(match2, time, 0)
autoAnchor3 = ta.valuewhen(match3, time, 0)
autoAnchor4 = ta.valuewhen(match4, time, 0)
autoAnchor5 = ta.valuewhen(match5, time, 0)

// ---- Final anchor selection: manual overrides automatic ----
anchor1 = manualMode ? manualDate1 : autoAnchor1
anchor2 = manualMode ? manualDate2 : autoAnchor2
anchor3 = manualMode ? manualDate3 : autoAnchor3
anchor4 = manualMode ? manualDate4 : autoAnchor4
anchor5 = manualMode ? manualDate5 : autoAnchor5

// ============================================
// Anchored VWAP accumulation
// ============================================
f_avwap(anchor) =>
    isStart = not na(anchor) and time >= anchor and time[1] < anchor
    sumSrc = realSource * volume
    sumVol = volume
    sumSrc := isStart ? sumSrc : sumSrc + sumSrc[1]
    sumVol := isStart ? sumVol : sumVol + sumVol[1]
    sumSrc / sumVol

// ============================================
// PLOTS
// ============================================
plot(show1 and not na(anchor1) and time >= anchor1 ? f_avwap(anchor1) : na, color = color1, title = 'Rolling Days #1')
plot(show2 and not na(anchor2) and time >= anchor2 ? f_avwap(anchor2) : na, color = color2, title = 'Rolling Days #2')
plot(show3 and not na(anchor3) and time >= anchor3 ? f_avwap(anchor3) : na, color = color3, title = 'Rolling Days #3')
plot(show4 and not na(anchor4) and time >= anchor4 ? f_avwap(anchor4) : na, color = color4, title = 'Rolling Days #4')
plot(show5 and not na(anchor5) and time >= anchor5 ? f_avwap(anchor5) : na, color = color5, title = 'Rolling Days #5')

plotshape(showLabel and show1 and not na(anchor1) ? time >= anchor1 and time[1] < anchor1 : false, text = '#1', textcolor = color.white, color = color.new(color1, 35), location = location.belowbar, style = shape.labelup, size = size.small)
plotshape(showLabel and show2 and not na(anchor2) ? time >= anchor2 and time[1] < anchor2 : false, text = '#2', textcolor = color.white, color = color.new(color2, 35), location = location.belowbar, style = shape.labelup, size = size.small)
plotshape(showLabel and show3 and not na(anchor3) ? time >= anchor3 and time[1] < anchor3 : false, text = '#3', textcolor = color.white, color = color.new(color3, 35), location = location.belowbar, style = shape.labelup, size = size.small)
plotshape(showLabel and show4 and not na(anchor4) ? time >= anchor4 and time[1] < anchor4 : false, text = '#4', textcolor = color.white, color = color.new(color4, 35), location = location.belowbar, style = shape.labelup, size = size.small)
plotshape(showLabel and show5 and not na(anchor5) ? time >= anchor5 and time[1] < anchor5 : false, text = '#5', textcolor = color.white, color = color.new(color5, 35), location = location.belowbar, style = shape.labelup, size = size.small)
````
