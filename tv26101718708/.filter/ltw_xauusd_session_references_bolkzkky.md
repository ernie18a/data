# LTW XAUUSD Session References

- url: https://www.tradingview.com/script/BOlkZkky-LTW-XAUUSD-Session-References/
- type: indicator
- pine_id: PUB;9b0dc33e702d461388708bd86e957187
- version: 1.0

## Description

LTW XAUUSD Session References is a chart overlay for reviewing spot gold during the Tokyo and New York sessions. LTW means Lubana Trading World; XAUUSD denotes gold quoted in US dollars. It brings together a short-term average, the feed's session volume-weighted average, completed 15-minute opening ranges, and up to four completed daily high/low pairs.

Purpose and how to use the combination

The workflow is to compare the current session's activity with both its opening range and the preceding daily ranges. EMA 8 provides a responsive reference for recent closing prices. Session VWAP supplies a separate, volume-weighted reference for the current broker session. Tokyo/NY opening-range highs and lows mark the extremes of a precisely defined initial interval. The daily pairs show where those intraday references sit relative to recent completed broker days. These references answer different questions; agreement between them does not establish a trade signal or profitable setup.

For example, on a standard 5-minute XAUUSD chart during New York, first wait for the 09:30-09:45 New York range to finish. Compare subsequent candles with NY ORH/ORL and VWAP, then use EMA 8 and the daily pairs to inspect the surrounding price context. A move through a range boundary followed by a return can be inspected visually, but this script does not detect, score or alert on breakouts or retests. It does not select entries, stops or profit targets. Setups and execution decisions require a separate method.

What the implementation adds

EMA and VWAP use standard calculations; no new formula or predictive edge is claimed. The custom behavior coordinates exact completed-range coverage, session-specific display, daily-reference drawings, and matching labels. It prevents a range from being presented as complete when its source window is partial or has missing bars. Source-timeframe selection preserves more usable history for standard windows while excluding a candle's prices outside the specified 15 minutes. Tokyo and NY ranges disappear outside their own display windows, while historical segments remain within those windows. Reusable daily lines show the current reference set without joining successive days with diagonal or stepped lines. These behaviors address timing, stale-level and chart-reading problems in the stated gold-session workflow.

Calculations and defaults

EMA 8 is the exponential moving average of closing prices over eight chart bars, shown in green. Its length is fixed at eight; changing the chart interval changes the time represented by those bars.

The white Session VWAP weights each chart bar's typical price, (high + low + close) / 3, by the volume supplied by the selected feed. Accumulation resets when the symbol's daily period changes. It uses the chart timeframe, no deviation bands and no plot offset. VWAP is hidden on daily and higher charts. Its broker-defined daily boundary is separate from the opening-range reset described below.

The default opening-range calculation windows are 20:00-20:15 for Tokyo and 09:30-09:45 for New York, both expressed in America/New_York. Each range is the highest high and lowest low of that complete 15-minute interval. It is withheld until the interval has closed and the chart has received its result. A chart bar that straddles the ending time does not contribute prices beyond that time. Standard windows use exact 15-minute source candles; custom windows aligned to five minutes use 5-minute candles; other custom starts use 1-minute candles. Coverage must be contiguous and match the specified start and end. Keep edited calculation windows exactly 15 minutes long. Missing history or invalid/incomplete coverage leaves the affected range blank.

Opening-range state resets at 18:00 America/New_York. Each range also has an independent display window: Tokyo 09:00-15:30 Asia/Tokyo and NY 09:30-16:00 America/New_York by default. A completed range is visible only on intraday intervals below one hour and only during its own display window. Its label disappears with it. These are display choices, not statements that spot gold closes at those times. Both calculation and display windows can be edited.

The Tokyo calculation is fixed to New York time by default, so its Tokyo equivalent changes with US daylight saving: 20:00 New York is 09:00 Tokyo the following day during US daylight time and 10:00 during US standard time. The Tokyo display window remains in Tokyo local time. Review these inputs when matching another session convention. There is no London range in this version.

PDH and PDL are the high and low of the immediately previous completed broker daily candle, including its overnight trading, and are enabled by default. Independent options add the second, third and fourth previous completed daily candles, labeled PD2H/PD2L through PD4H/PD4L. Non-trading days are skipped. Daily highs default to orange and lows to yellow. The first pair is solid; older pairs are thin and dashed. These levels appear on intraday and daily charts and are hidden above daily.

Timing, drawings and limitations

EMA and VWAP can move while a chart candle develops. A completed opening range stays fixed for its gold day, subject to vendor data corrections. Daily values use only completed candles: the daily high/low expressions are offset by one to four daily bars before being carried forward. The developing daily candle is excluded. The source uses lookahead_on for those already-offset daily values; opening-range requests use lookahead_off.

Daily horizontal lines extend left and right across the visible chart. They represent the latest live or Bar Replay day's reference set, not the levels that were known at every earlier candle crossed by the lines. Their backward extension must not be read as historical signal evidence. Pane labels sit beside the latest values; their horizontal offset moves labels only and does not predict future prices. Label visibility, offset and size are configurable. Line colors are configurable, including independent NY high/low colors.

Use standard time-based candles, preferably 2-minute or 5-minute XAUUSD, with full-session history. Synthetic chart types have not been validated. Gold feeds differ in daily boundaries, prices and volume; spot-gold volume may represent tick activity rather than centralized exchange volume. VWAP and daily levels can consequently differ between brokers. A first loaded session with incomplete history can also have an incomplete VWAP accumulation. Platform history limits particularly affect custom lower-timeframe ranges. Blank ranges are not trading signals.

This is an open-source reference overlay, not a strategy backtest or order system. It contains no trade alerts and makes no claim about profitability, accuracy or future results.

## Source Code

````pine
// SPDX-License-Identifier: MPL-2.0
// Copyright 2026 faujasingh13
//@version=6
indicator("LTW XAUUSD", shorttitle="LTW XAUUSD", overlay=true, max_lines_count=8, max_labels_count=14)

// Lubana Trading World — gold session reference overlay.
// Up to four completed daily high/low pairs shown as current horizontal references.
// EMA 8, Session VWAP, Tokyo/NY opening ranges, and optional daily levels.
string tz = input.string("America/New_York", "Opening-range timezone")
string tokyo = input.session("2000-2015", "Tokyo opening range")
string newYork = input.session("0930-0945", "New York opening range")
string tokyoDisplay = input.session("0900-1530", "Tokyo display session (Tokyo time)", group="Session display")
string newYorkDisplay = input.session("0930-1600", "NY display session (New York time)", group="Session display")
color emaColor = input.color(#00AA00, "EMA 8 color")
color tokyoHighColor = input.color(#00BCD4, "Tokyo high color")
color tokyoLowColor = input.color(#4DD0E1, "Tokyo low color")
color newYorkHighColor = input.color(#BA68C8, "New York high color", group="New York colors")
bool showPaneLabels = input.bool(true, "Show pane labels", group="Pane labels")
int labelOffset = input.int(3, "Label offset (bars)", minval=0, maxval=50, group="Pane labels")
string labelSize = input.string(size.small, "Label size", options=[size.tiny, size.small, size.normal, size.large], group="Pane labels")
// Append the new input to preserve existing input positions on saved charts.
color newYorkLowColor = input.color(#BA68C8, "New York low color", group="New York colors")
bool showDailyLevels = input.bool(true, "Show previous daily high/low", group="Daily levels", tooltip="Uses the previous completed broker daily candle, including overnight trading. Lines extend across the view as current reference levels. In Bar Replay, they use the previous day at the replay point.")
color dailyHighColor = input.color(color.orange, "Previous daily high color", group="Daily levels")
color dailyLowColor = input.color(color.yellow, "Previous daily low color", group="Daily levels")
// Keep the first previous candle on by default; older pairs are opt-in.
bool showDaily2 = input.bool(false, "Show 2nd previous daily high/low", group="Daily levels", tooltip="Adds the high and low from two completed broker daily candles ago. Non-trading days are skipped.")
bool showDaily3 = input.bool(false, "Show 3rd previous daily high/low", group="Daily levels", tooltip="Adds the high and low from three completed broker daily candles ago. Non-trading days are skipped.")
bool showDaily4 = input.bool(false, "Show 4th previous daily high/low", group="Daily levels", tooltip="Adds the high and low from four completed broker daily candles ago. Non-trading days are skipped.")

float ema8 = ta.ema(close, 8)
// Native Session anchor, HLC3, chart timeframe, offset 0, no bands.
float sessionVwap = ta.vwap(hlc3, timeframe.change("1D") or barstate.isfirst)
plot(ema8, "EMA 8", emaColor, 2)
plot(timeframe.isintraday ? sessionVwap : na, "VWAP", color.white, 2)

// Use the largest source candles that fit the exact 15-minute window.
// Standard windows use 15m history instead of exhausting 1m intrabar history.
rangeTimeframe(simple string sessionHours) =>
    int startMinute = int(str.tonumber(str.substring(sessionHours, 0, 2))) * 60 + int(str.tonumber(str.substring(sessionHours, 2, 4)))
    int endMinute = int(str.tonumber(str.substring(sessionHours, 5, 7))) * 60 + int(str.tonumber(str.substring(sessionHours, 7, 9)))
    startMinute % 15 == 0 and endMinute % 15 == 0 ? "15" : startMinute % 5 == 0 and endMinute % 5 == 0 ? "5" : "1"

openingRange(simple string sessionHours) =>
    bool inside = not na(time(timeframe.period, sessionHours, tz))
    int dayKey = time("1D", "1800-1800", "America/New_York")
    bool newGoldDay = ta.change(dayKey) != 0
    int startMinute = int(str.tonumber(str.substring(sessionHours, 0, 2))) * 60 + int(str.tonumber(str.substring(sessionHours, 2, 4)))
    int endMinute = int(str.tonumber(str.substring(sessionHours, 5, 7))) * 60 + int(str.tonumber(str.substring(sessionHours, 7, 9)))
    var float hi = na
    var float lo = na
    var int firstTime = na
    var int lastClose = na
    var int coveredMs = 0
    var bool contiguous = true
    if newGoldDay
        hi := na
        lo := na
        firstTime := na
        lastClose := na
        coveredMs := 0
        contiguous := true
    if inside
        if not na(lastClose) and time != lastClose
            contiguous := false
        hi := na(hi) ? high : math.max(hi, high)
        lo := na(lo) ? low : math.min(lo, low)
        firstTime := na(firstTime) ? time : firstTime
        lastClose := time_close
        coveredMs += time_close - time
    bool exactWindow = contiguous and coveredMs == 15 * 60000 and lastClose - firstTime == 15 * 60000 and hour(firstTime, tz) * 60 + minute(firstTime, tz) == startMinute and hour(lastClose, tz) * 60 + minute(lastClose, tz) == endMinute
    [exactWindow ? hi : na, exactWindow ? lo : na, lastClose, dayKey]

completedRange(simple string sessionHours) =>
    [rangeH, rangeL, closedAt, sourceDay] = request.security(syminfo.tickerid, rangeTimeframe(sessionHours), openingRange(sessionHours), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, calc_bars_count=100000)
    // Historical/replay bars use their own close; live bars also wait for real time.
    // A 2m candle that straddles the end cannot add the sixteenth minute to the range.
    int completedThrough = math.min(time_close, timenow)
    int chartDay = time("1D", "1800-1800", "America/New_York")
    bool ready = sourceDay == chartDay and not na(closedAt) and closedAt <= completedThrough
    [ready ? rangeH : na, ready ? rangeL : na]

[tokyoH, tokyoL] = completedRange(tokyo)
[newYorkH, newYorkL] = completedRange(newYork)
bool showRanges = timeframe.isintraday and timeframe.in_seconds() < 3600
bool showTokyo = showRanges and not na(time(timeframe.period, tokyoDisplay, "Asia/Tokyo"))
bool showNewYork = showRanges and not na(time(timeframe.period, newYorkDisplay, "America/New_York"))
plot(showTokyo ? tokyoH : na, "Tokyo OR High", tokyoHighColor, 1, plot.style_linebr)
plot(showTokyo ? tokyoL : na, "Tokyo OR Low", tokyoLowColor, 1, plot.style_linebr)
plot(showNewYork ? newYorkH : na, "NY ORH", newYorkHighColor, 1, plot.style_linebr)
plot(showNewYork ? newYorkL : na, "NY ORL", newYorkLowColor, 1, plot.style_linebr)

// Daily levels follow the broker's daily boundary, independently of the OR reset.
// Offset the DAILY expression before using lookahead_on: only the previous
// completed daily candles are carried forward. Never use developing-day extrema.
[previousHigh, previousLow, previous2High, previous2Low, previous3High, previous3Low, previous4High, previous4Low] = request.security(syminfo.tickerid, "1D", [high[1], low[1], high[2], low[2], high[3], low[3], high[4], low[4]], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
bool dailyTimeframe = timeframe.in_seconds() <= timeframe.in_seconds("1D")
bool showDaily = showDailyLevels and dailyTimeframe
float dailyHigh = showDaily ? previousHigh : na
float dailyLow = showDaily ? previousLow : na
float daily2High = showDaily2 and dailyTimeframe ? previous2High : na
float daily2Low = showDaily2 and dailyTimeframe ? previous2Low : na
float daily3High = showDaily3 and dailyTimeframe ? previous3High : na
float daily3Low = showDaily3 and dailyTimeframe ? previous3Low : na
float daily4High = showDaily4 and dailyTimeframe ? previous4High : na
float daily4Low = showDaily4 and dailyTimeframe ? previous4Low : na
// Values remain inspectable without drawing connected historical steps.
plot(dailyHigh, "PDH", dailyHighColor, display=display.data_window + display.price_scale)
plot(dailyLow, "PDL", dailyLowColor, display=display.data_window + display.price_scale)
plot(daily2High, "PD2H", dailyHighColor, display=display.data_window + display.price_scale)
plot(daily2Low, "PD2L", dailyLowColor, display=display.data_window + display.price_scale)
plot(daily3High, "PD3H", dailyHighColor, display=display.data_window + display.price_scale)
plot(daily3Low, "PD3L", dailyLowColor, display=display.data_window + display.price_scale)
plot(daily4High, "PD4H", dailyHighColor, display=display.data_window + display.price_scale)
plot(daily4Low, "PD4L", dailyLowColor, display=display.data_window + display.price_scale)

// Reuse up to eight full-width reference lines, also at the Bar Replay endpoint.
// Extending left is visual only; it does not make the levels historical signals.
dailyLevel(float value, color lineColor, int lineWidth, string lineStyle) =>
    var line level = na
    if barstate.islast
        if na(value)
            line.delete(level)
            level := na
        else
            if na(level)
                level := line.new(bar_index, value, bar_index + 1, value, extend=extend.both, color=lineColor, width=lineWidth, style=lineStyle)
            line.set_xy1(level, bar_index, value)
            line.set_xy2(level, bar_index + 1, value)
    level

dailyLevel(dailyHigh, dailyHighColor, 2, line.style_solid)
dailyLevel(dailyLow, dailyLowColor, 2, line.style_solid)
dailyLevel(daily2High, dailyHighColor, 1, line.style_dashed)
dailyLevel(daily2Low, dailyLowColor, 1, line.style_dashed)
dailyLevel(daily3High, dailyHighColor, 1, line.style_dashed)
dailyLevel(daily3Low, dailyLowColor, 1, line.style_dashed)
dailyLevel(daily4High, dailyHighColor, 1, line.style_dashed)
dailyLevel(daily4Low, dailyLowColor, 1, line.style_dashed)

// Reuse one label per line at the latest bar; never leave labels on old sessions.
paneLabel(float value, string title, color lineColor, color textColor) =>
    var label tag = na
    bool daily = str.startswith(title, "PD")
    // Put EMA below and VWAP above their anchors so nearby values stay readable.
    string tagStyle = title == "EMA 8" ? label.style_label_upper_left : title == "VWAP" ? label.style_label_lower_left : label.style_label_left
    if barstate.islast
        if showPaneLabels and not na(value)
            if na(tag)
                tag := label.new(bar_index + labelOffset, value, title, xloc=xloc.bar_index, yloc=yloc.price, style=tagStyle, color=daily ? lineColor : color.new(lineColor, 15), textcolor=textColor, size=labelSize)
            else
                label.set_xy(tag, bar_index + labelOffset, value)
            label.set_text(tag, daily ? title + "  " + str.tostring(value, format.mintick) : title)
            label.set_tooltip(tag, title + ": " + str.tostring(value, format.mintick))
        else
            label.delete(tag)
            tag := na
    tag

paneLabel(ema8, "EMA 8", emaColor, color.white)
paneLabel(timeframe.isintraday ? sessionVwap : na, "VWAP", color.white, color.black)
paneLabel(showTokyo ? tokyoH : na, "Tokyo ORH", tokyoHighColor, color.black)
paneLabel(showTokyo ? tokyoL : na, "Tokyo ORL", tokyoLowColor, color.black)
paneLabel(showNewYork ? newYorkH : na, "NY ORH", newYorkHighColor, color.white)
paneLabel(showNewYork ? newYorkL : na, "NY ORL", newYorkLowColor, color.white)
readableText(color bg) =>
    0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg) > 128 ? color.black : color.white

paneLabel(dailyHigh, "PDH", dailyHighColor, readableText(dailyHighColor))
paneLabel(dailyLow, "PDL", dailyLowColor, readableText(dailyLowColor))

paneLabel(daily2High, "PD2H", dailyHighColor, readableText(dailyHighColor))
paneLabel(daily2Low, "PD2L", dailyLowColor, readableText(dailyLowColor))
paneLabel(daily3High, "PD3H", dailyHighColor, readableText(dailyHighColor))
paneLabel(daily3Low, "PD3L", dailyLowColor, readableText(dailyLowColor))
paneLabel(daily4High, "PD4H", dailyHighColor, readableText(dailyHighColor))
paneLabel(daily4Low, "PD4L", dailyLowColor, readableText(dailyLowColor))
````
