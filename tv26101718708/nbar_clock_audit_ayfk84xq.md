# N-Bar Clock Audit

- url: https://www.tradingview.com/script/AyFK84xq-N-Bar-Clock-Audit/
- type: indicator
- pine_id: PUB;d9849770dc2b4409862e7a44819ea523
- version: 2.0

## Description

N-Bar Clock Audit

PURPOSE
A 20-bar lookback on an hourly chart does not always represent 20 elapsed hours. Session closures, weekends, omitted chart sessions and shortened final session bars change its clock-time span. This educational diagnostic makes that difference measurable before comparing bar-based research across instruments or chart settings.

The script plots the elapsed-to-nominal time ratio of a rolling, confirmed close-to-close horizon. Its table reconciles that horizon into scheduled bar durations, forward gaps and timestamp overlaps, with exact UTC endpoints and a numerical identity check. It does not analyze price direction or produce buy/sell signals.

WHAT N MEANS
The start is the close timestamp N bars ago. The end is the latest confirmed bar's close timestamp. The N intervening bars, including the bar ending the window, supply N bar durations and N transitions from the preceding close to the next open. N + 1 chart bars must therefore be available.

This is a close-to-close horizon, such as the timestamp span underlying a comparison of close with close[N]. It is not the open-to-close width of a set of N candles. For N = 1, an overnight break belongs to the window if the current bar opens after the previous bar's close.

METHOD
For each of the N bars:
- Scheduled duration = current close timestamp minus current open timestamp
- Forward gap = max(current open timestamp minus preceding close timestamp, 0)
- Timestamp overlap = max(preceding close timestamp minus current open timestamp, 0)

The exact reconciliation is:
Elapsed time = sum of scheduled durations + sum of forward gaps - sum of timestamp overlaps.

This is an accounting and indexing check, not evidence that the feed is complete.

Nominal time = N multiplied by the chart timeframe's fixed duration. The plotted ratio equals elapsed time divided by nominal time. A reading of 3.500x means that this close-to-close horizon spans 3.5 times its nominal duration. The dashed 1x line is a time reference, not a trading threshold.

The table also reports the number and largest size of forward gaps, the number of overlaps, and counts of bars shorter or longer than the nominal timeframe. A shortened last bar of a session can reduce the scheduled-duration sum without creating a gap. The identity residual should be zero milliseconds for a valid window. Windows containing unavailable timestamps, non-positive bar durations, or a non-positive total elapsed span show an invalid-window state with no metrics rather than silently substituting data.

USING IT
Use standard, time-based intraday seconds or minute/hour charts. Daily, weekly, monthly, tick and synthetic charts are intentionally blocked because this release uses a fixed intraday duration baseline. The default N = 20 is illustrative and is not optimized. N can range from 1 to 2000.

Compare the same N on a continuously traded instrument and on a session-limited instrument, or compare regular and extended chart sessions where your data plan permits. Inspect how much of a particular lookback is scheduled bar time versus time between included bars. Use the Data Window to inspect historical ratios and their components. Changing N defines a different horizon; changing the session setting changes the underlying chart dataset.

The table always shows the latest confirmed window, not the bar under the cursor. Start and end timestamps are explicitly UTC, independent of the chart's visual timezone. Values are displayed in minutes, including fractional minutes on seconds charts. The table can be hidden or moved to any corner.

CONFIRMATION AND HISTORY
Calculations use only the chart's own opening and closing timestamps. There are no external symbol requests, future offsets, or lookahead calls. A live bar's scheduled close does not mean it has finished: its plot is blank until confirmation, and the table retains the previous confirmed window. Historical plots are placed at the bar where each window ends, with no backward placement.

WHAT IS DISTINCT
This is a rolling horizon audit, rather than a candle countdown, session overlay or marker that calls every time gap a missing bar. Its contribution is the exact close-to-close decomposition, explicit N + 1 anchor rule, shortened-bar and overlap diagnostics, confirmed-window handling, and inspectable reconciliation in one small tool. Timestamp subtraction and rolling sums are standard building blocks; this implementation was written independently, without copying another author's script. It serves a different purpose from Range Breakout Outcome Audit, which studies subsequent price-barrier outcomes.

LIMITATIONS
Forward gaps may be ordinary overnight or weekend closures, holidays, omitted sessions, intervals with no trades, or data irregularities. The script cannot distinguish these causes and does not label them outages or missing trades. It has no exchange calendar and does not reconstruct absent bars.

Scheduled bar duration is the span between chart timestamps, not measured time spent trading or guaranteed data coverage. An overlap is a timestamp diagnostic; it is not overlapping positions. A ratio below 1 can result from shortened bars and is not automatically an error. Clock arithmetic uses absolute timestamps, so timezone-display changes cannot alter the arithmetic; changes in session schedules can.

The audit sees only loaded chart data. Session selection, feed revisions and data availability can change its results. A ratio of 1 can hide offsetting shortened bars and gaps; inspect the components rather than treating 1 as a completeness score. Adjacent rolling windows overlap heavily and are not independent samples. No statistical reliability, strategy performance, profitability, execution quality or future-price claim is made. Use the result as context for bar-based research, not as a trading recommendation.

## Source Code

````pine
//@version=6
indicator("N-Bar Clock Audit", overlay = false, max_bars_back = 5000, precision = 3)

// Original educational timing diagnostic for ZILLIONAIRE010.
// A close-to-close N-bar horizon contains N bar durations and N transitions.
// elapsed = scheduled bar durations + forward gaps - timestamp overlaps.
// A time gap is NOT evidence of missing trades, a feed fault, or an outage.
// No prices, orders, external series, future data, or trading signals are used.

int length = input.int(20, "Close-to-close horizon (N bars)", minval = 1, maxval = 2000, tooltip = "Measures from the close timestamp N bars ago to the latest confirmed close. Needs N + 1 chart bars. This differs from the open-to-close span of N candles.")
bool showTable = input.bool(true, "Show latest confirmed window")
string corner = input.string("Top right", "Table corner", options = ["Top right", "Top left", "Bottom right", "Bottom left"])
string tableTextSize = input.string("Compact", "Table text size", options = ["Compact", "Standard", "Large"])
string tableCellSize = switch tableTextSize
    "Standard" => size.small
    "Large" => size.normal
    => size.tiny

if barstate.isfirst and (not chart.is_standard or not (timeframe.isseconds or timeframe.isminutes))
    runtime.error("Use standard time-based seconds or minute/hour charts. Daily, weekly, monthly, tick, and synthetic charts are outside this audit's fixed-duration baseline.")

float nominalBarMs = timeframe.in_seconds() * 1000.0
float nominalWindowMs = length * nominalBarMs
bool validPair = not na(time_close) and not na(time_close[1]) and time_close > time
float durationMs = validPair ? float(time_close - time) : 0.0
float transitionMs = validPair ? float(time - time_close[1]) : 0.0
float gapMs = math.max(transitionMs, 0.0)
float overlapMs = math.max(-transitionMs, 0.0)

// Every rolling function runs on every execution. Invalid timestamps count as
// invalid, rather than being skipped by an na-ignoring rolling function.
float durations = math.sum(durationMs, length)
float gaps = math.sum(gapMs, length)
float overlaps = math.sum(overlapMs, length)
float gapCount = math.sum(gapMs > 0 ? 1.0 : 0.0, length)
float overlapCount = math.sum(overlapMs > 0 ? 1.0 : 0.0, length)
float shortCount = math.sum(validPair and durationMs < nominalBarMs ? 1.0 : 0.0, length)
float longCount = math.sum(validPair and durationMs > nominalBarMs ? 1.0 : 0.0, length)
float invalidCount = math.sum(validPair ? 0.0 : 1.0, length)
float largestGap = ta.highest(gapMs, length)
float elapsedMs = float(time_close - time_close[length])
bool fullWindow = bar_index >= length
bool ready = fullWindow and invalidCount == 0 and not na(elapsedMs) and elapsedMs > 0
float ratio = ready ? elapsedMs / nominalWindowMs : na
float residualMs = ready ? elapsedMs - (durations + gaps - overlaps) : na
bool closedWindow = barstate.isconfirmed and ready

// The live bar is intentionally blank. Its scheduled closing timestamp does
// not mean it has closed. The table retains the last committed window.
plot(closedWindow ? ratio : na, "Elapsed / nominal N-bar time", color = color.teal, linewidth = 2, style = plot.style_linebr)
hline(1.0, "Nominal N x timeframe", color = color.gray, linestyle = hline.style_dashed)
plot(closedWindow ? elapsedMs / 60000.0 : na, "Elapsed minutes", display = display.data_window)
plot(closedWindow ? durations / 60000.0 : na, "Scheduled bar minutes", display = display.data_window)
plot(closedWindow ? gaps / 60000.0 : na, "Forward gap minutes", display = display.data_window)
plot(closedWindow ? overlaps / 60000.0 : na, "Timestamp overlap minutes", display = display.data_window)
plot(closedWindow ? gapCount : na, "Forward gap count", display = display.data_window)
plot(closedWindow ? largestGap / 60000.0 : na, "Largest forward gap minutes", display = display.data_window)
plot(closedWindow ? shortCount : na, "Shorter-than-nominal bars", display = display.data_window)
plot(closedWindow ? longCount : na, "Longer-than-nominal bars", display = display.data_window)
plot(closedWindow ? overlapCount : na, "Timestamp overlap count", display = display.data_window)
plot(closedWindow ? residualMs : na, "Decomposition residual milliseconds", display = display.data_window)

var float lastRatio = na
var float lastElapsed = na
var float lastDuration = na
var float lastGaps = na
var float lastOverlaps = na
var float lastGapCount = na
var float lastLargest = na
var float lastShort = na
var float lastLong = na
var float lastOverlapCount = na
var float lastResidual = na
var int startClose = na
var int endClose = na
var bool lastReady = false
var bool lastFull = false
if barstate.isconfirmed
    lastReady := ready
    lastFull := fullWindow
    lastRatio := ratio
    lastElapsed := ready ? elapsedMs : na
    lastDuration := ready ? durations : na
    lastGaps := ready ? gaps : na
    lastOverlaps := ready ? overlaps : na
    lastGapCount := ready ? gapCount : na
    lastLargest := ready ? largestGap : na
    lastShort := ready ? shortCount : na
    lastLong := ready ? longCount : na
    lastOverlapCount := ready ? overlapCount : na
    lastResidual := residualMs
    startClose := ready ? time_close[length] : na
    endClose := ready ? time_close : na

f_minutes(float milliseconds) =>
    na(milliseconds) ? "n/a" : str.tostring(milliseconds / 60000.0, "#,##0.###") + " min"

f_count(float count) =>
    na(count) ? "n/a" : str.tostring(count, "0")

f_row(table t, int row, string label, string value, color bg) =>
    table.cell(t, 0, row, label, text_color = chart.fg_color, bgcolor = bg, text_size = tableCellSize, text_halign = text.align_left)
    table.cell(t, 1, row, value, text_color = chart.fg_color, bgcolor = bg, text_size = tableCellSize, text_halign = text.align_right)

string tablePosition = switch corner
    "Top left" => position.top_left
    "Bottom right" => position.bottom_right
    "Bottom left" => position.bottom_left
    => position.top_right
var table audit = table.new(tablePosition, 2, 15, border_width = 1, border_color = color.new(color.gray, 70))
if barstate.isfirst
    table.merge_cells(audit, 0, 0, 1, 0)
    table.merge_cells(audit, 0, 12, 1, 12)
    table.merge_cells(audit, 0, 13, 1, 13)
    table.merge_cells(audit, 0, 14, 1, 14)

if barstate.islast and showTable
    color bg = color.new(chart.bg_color, 5)
    color accent = color.new(color.teal, 82)
    string stateText = lastReady ? "Latest confirmed window" : lastFull ? "Invalid timestamp window" : "Waiting for N + 1 bars"
    table.cell(audit, 0, 0, "N-Bar Clock Audit | N = " + str.tostring(length), text_color = chart.fg_color, bgcolor = accent, text_size = tableCellSize)
    f_row(audit, 1, "Elapsed / nominal", lastReady ? str.tostring(lastRatio, "0.000") + "x" : "n/a", accent)
    f_row(audit, 2, "Elapsed close-to-close", f_minutes(lastElapsed), bg)
    f_row(audit, 3, "Nominal N x timeframe", f_minutes(nominalWindowMs), bg)
    f_row(audit, 4, "Scheduled bar durations", f_minutes(lastDuration), bg)
    f_row(audit, 5, "Forward gaps (+)", f_minutes(lastGaps) + " | " + f_count(lastGapCount), bg)
    f_row(audit, 6, "Timestamp overlaps (-)", f_minutes(lastOverlaps) + " | " + f_count(lastOverlapCount), bg)
    f_row(audit, 7, "Largest forward gap", f_minutes(lastLargest), bg)
    f_row(audit, 8, "Short / long bars", f_count(lastShort) + " / " + f_count(lastLong), bg)
    f_row(audit, 9, "Start close (UTC)", lastReady ? str.format_time(startClose, "yyyy-MM-dd HH:mm:ss", "UTC") : "n/a", bg)
    f_row(audit, 10, "End close (UTC)", lastReady ? str.format_time(endClose, "yyyy-MM-dd HH:mm:ss", "UTC") : "n/a", bg)
    f_row(audit, 11, "Identity residual", lastReady ? str.tostring(lastResidual, "0.###") + " ms" : "n/a", bg)
    table.cell(audit, 0, 12, stateText + " | Live bar excluded", text_color = chart.fg_color, bgcolor = bg, text_size = tableCellSize)
    table.cell(audit, 0, 13, "Durations are scheduled time, not traded activity", text_color = chart.fg_color, bgcolor = bg, text_size = tableCellSize)
    table.cell(audit, 0, 14, "Gaps may be normal closures; no outage inference", text_color = chart.fg_color, bgcolor = bg, text_size = tableCellSize)
````
