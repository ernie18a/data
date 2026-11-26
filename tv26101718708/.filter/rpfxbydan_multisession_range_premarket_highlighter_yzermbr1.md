# RPFXBYDAN  - Multi-Session Range & Pre-Market Highlighter

- url: https://www.tradingview.com/script/YZERmbr1-RPFXBYDAN-Multi-Session-Range-Pre-Market-Highlighter/
- type: indicator
- pine_id: PUB;8caf8d797292448dab69f1fe0dba8bcf
- version: 2.0

## Description

# Multi-Session Range & Pre-Market Highlighter

An educational visualization tool that automatically highlights three key intraday time windows for the New York, London, or Tokyo sessions: a pre-market window ahead of the exchange open, a short opening range around the open, and the regular trading session that follows. Designed to help chart readers see how price behaves across these fixed time blocks each day.

This script does not generate trade advice, does not predict future price movement, and does not backtest a strategy. It is a visualization overlay that draws boxes and reference levels based purely on session time and the price action of the current chart.

## What It Displays

The indicator identifies and marks three distinct intraday windows in the timezone of the selected market:

1. **Pre-Market Window** — A short block of time ahead of the exchange open. By default this is a 15-minute window starting 1.5 hours before the trading session begins. The high and low across this window are recorded and drawn as a translucent box with optional dashed reference lines.

2. **Opening Range Window** — The 15 minutes immediately before the regular trading session begins. During this window, the indicator records the highest high and lowest low. When the window ends, those two prices are locked and drawn as horizontal reference levels for the rest of the day.

3. **Trading Session** — The regular exchange hours. During this window, the indicator continues to display the locked reference levels from the opening range and observes when price crosses above the upper level or below the lower level. Cross events are marked on the chart with small directional markers.

All three windows reset automatically at the start of each new trading day.

## How Reference Levels Are Formed

For each new trading day, the indicator tracks the highest high and lowest low of every bar within the opening range window. When the window closes, these two prices become that day's fixed reference levels. They remain drawn on the chart through the rest of the session so the viewer can see the day's early range relative to subsequent price action.

The pre-market window works the same way independently — its own high and low are recorded and shown, giving context for how the market moved into the open.

## Cross Events

Once the opening range levels are locked and the trading session is open, the indicator observes when the current bar crosses above the upper reference level or below the lower reference level. The trigger can be configured to any of the following:

- **Close** — Requires a bar to close beyond the level.
- **High / Low** — Any intrabar high or low print beyond the level triggers.

An optional **retest confirmation** filter can also be enabled: after an initial cross, a return to the level and a re-cross in the same direction is required before the event is marked. A limit of one event per direction per day can also be enabled to keep the chart clean.

Cross events are informational only — they mark where price interacted with the reference level. They are not trade signals and do not constitute a recommendation to buy, sell, hold, or take any action.

## Built-in Session Presets

Selecting a Market applies the standard hours for that exchange, evaluated in the exchange's own timezone (so it works correctly regardless of your chart's timezone):

- **New York (NYSE/NASDAQ)** — Opening Range 09:15-09:30, Trading 09:30-16:00 America/New_York
- **London (LSE)** — Opening Range 07:45-08:00, Trading 08:00-16:30 Europe/London
- **Tokyo (TSE)** — Opening Range 08:45-09:00, Trading 09:00-15:00 Asia/Tokyo

Every default can be overridden with custom session strings for non-standard schedules (half-days, futures pit hours, FX-overlap windows, etc.).

## Settings

- **Market & Sessions** — Market selector, "Use Market Defaults" toggle, custom Opening Range and Trading Session strings, and a fine-grained Opening-Range Start Offset control that nudges only the OR start time in 1-minute steps.
- **Your Local Timezone** — Display-only. Controls the timezone shown in the local column of the info table. Does not affect any calculations.
- **Signal Logic** — (This group controls the cross-event trigger.) Choose trigger source (Close vs High/Low), enable the retest filter, set the retest window, and toggle the one-event-per-side-per-day cap.
- **Pre-Market Marker** — Enable/disable, minutes before exchange open, window length, and style controls.
- **Visuals** — Toggles and color/width controls for the opening range box, reference lines, midline, on-chart markers, and info table.

## Info Panel

An optional info panel in the top-right corner of the chart shows the selected market, both timezones, and the resolved time window for each of the three windows in both the exchange timezone and your local timezone.

## Alerts

The indicator provides three alert conditions:

- **Range High Break** — Fires when price crosses above the locked upper reference level (after the OR window has closed).
- **Range Low Break** — Fires when price crosses below the locked lower reference level (after the OR window has closed).
- **Opening Range Locked** — Fires at the moment the opening range window ends and the reference levels are finalized for the day.

## Timeframes and Instruments

The indicator is designed for intraday timeframes (1-minute through 15-minute typically works best). It is compatible with any instrument that has intraday data, including stocks, futures, indices, forex, and crypto. Non-standard trading hours can be handled by disabling defaults and typing custom session strings.

## Educational Notes on the Opening Range Concept

The opening range is a well-known chart-reading concept: the high and low of a fixed early portion of the trading day. Many chart readers use these levels as visual reference points for evaluating subsequent price action. This indicator does not endorse or recommend any particular way of using them — it simply draws the levels consistently and lets the viewer study them.

## Disclaimer

This script is provided for educational and informational purposes only. It is a visualization tool that highlights configurable price windows on the chart; it is not a trading system, is not trading advice, and does not constitute a recommendation to buy, sell, hold, or take any other action with respect to any instrument. Trading and investing carry substantial risk of loss. Past price behavior is not indicative of future results. You are solely responsible for any decisions you make based on what you see on your chart. Always do your own research and consider consulting a licensed financial professional before making any trading or investment decisions.

## Source Code

````pine
//@version=6
// =============================================================================
// Multi-Session Range & Pre-Market Highlighter
// -----------------------------------------------------------------------------
// A visualization overlay that marks three intraday time windows: a pre-market
// window, a short opening range window around the exchange open, and the
// regular trading session that follows. Reference levels are drawn based on
// price behavior within these windows. This script does not generate trade
// advice or predict future price movement — it is a chart-reading aid only.
//
// Disclaimer: This script is provided for educational and informational
// purposes only. It is not a trading system, is not trading advice, and does
// not constitute a recommendation to buy, sell, or hold any instrument. Past
// price behavior is not indicative of future results.
// =============================================================================
indicator("RPFXBYDAN - Multi-Session Range & Pre-Market Highlighter", shorttitle="RPFXBYDAN - Session Range", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================== INPUTS =======================================
// -- Market / Sessions -------------------------------------------------------
// The Market selector chooses BOTH the timezone the sessions are evaluated in
// AND the default session times for that market. Leave "Use Market Defaults"
// on for one-click setup, or turn it off to type custom windows.
//
// Built-in market presets — Opening Range is the 15 minutes immediately
// BEFORE the regular trading start (market open):
//   New York (NYSE/NASDAQ) — TZ America/New_York
//       Opening Range: 09:15-09:30  |  Trading: 09:30-16:00
//   London (LSE)           — TZ Europe/London
//       Opening Range: 07:45-08:00  |  Trading: 08:00-16:30
//   Tokyo (TSE)            — TZ Asia/Tokyo
//       Opening Range: 08:45-09:00  |  Trading: 09:00-15:00
//
// Your CHART timezone does not matter — sessions are anchored to the chosen
// market's local time wherever you live.
grpSession       = "Market & Sessions"
market           = input.string("New York", "Market", options=["New York", "London", "Tokyo"], group=grpSession, tooltip="Selects the timezone the sessions are evaluated in (and the default session times if 'Use Market Defaults' is on).")
useDefaults      = input.bool(true, "Use Market Defaults", group=grpSession, tooltip="If on, ignores the custom session inputs below and uses standard open/trade hours for the selected market.")
orSessionUser    = input.session("0915-0930", "Custom Opening Range Session", group=grpSession, tooltip="Used only when 'Use Market Defaults' is OFF. Times are interpreted in the selected market's timezone.")
tradeSessionUser = input.session("0930-1600", "Custom Trading Session",       group=grpSession, tooltip="Used only when 'Use Market Defaults' is OFF. Times are interpreted in the selected market's timezone.")
exchangeOffset   = input.int(0, "OR Start Offset (minutes)", minval=-120, maxval=120, step=1, group=grpSession, tooltip="Nudges ONLY the Opening Range START time by +/- N minutes (1-minute steps). The OR end time, the Trading Session, and the Pre-Session Marker are NOT affected. Example: with OR 09:30-09:45 and offset = +5, the OR becomes 09:35-09:45 (a 10-minute window). Offset = -5 makes it 09:25-09:45 (a 20-minute window).")

// -- Your Local Timezone -----------------------------------------------------
// The indicator always anchors the Opening Range to the market's timezone so
// the levels are calculated correctly. This input controls how those session
// times are DISPLAYED back to you — pick where you live and the info table
// will show what 09:30 New York (etc.) looks like on your clock.
grpLocal = "Your Local Timezone"
userTZ   = input.string("America/New_York", "Your Timezone", options=["America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles", "America/Anchorage", "America/Honolulu", "America/Toronto", "America/Vancouver", "America/Mexico_City", "America/Sao_Paulo", "America/Buenos_Aires", "Europe/London", "Europe/Dublin", "Europe/Paris", "Europe/Berlin", "Europe/Madrid", "Europe/Rome", "Europe/Amsterdam", "Europe/Zurich", "Europe/Stockholm", "Europe/Moscow", "Europe/Istanbul", "Africa/Johannesburg", "Africa/Cairo", "Asia/Dubai", "Asia/Tel_Aviv", "Asia/Kolkata", "Asia/Bangkok", "Asia/Jakarta", "Asia/Singapore", "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Taipei", "Asia/Seoul", "Asia/Tokyo", "Australia/Perth", "Australia/Sydney", "Australia/Melbourne", "Pacific/Auckland", "UTC"], group=grpLocal, tooltip="Where YOU are. Used to display session times on your clock. Does not change ORB calculations.")

// Resolve timezone and default sessions from the chosen market (single-line ternaries)
sessionTZ    = market == "Tokyo" ? "Asia/Tokyo" : market == "London" ? "Europe/London" : "America/New_York"
defaultOR    = market == "Tokyo" ? "0845-0900" : market == "London" ? "0745-0800"     : "0915-0930"
defaultTrade = market == "Tokyo" ? "0900-1500" : market == "London" ? "0800-1630"     : "0930-1600"

orSession    = useDefaults ? defaultOR    : orSessionUser
tradeSession = useDefaults ? defaultTrade : tradeSessionUser

// -- Signal Logic ------------------------------------------------------------
grpSignals     = "Signal Logic"
breakoutSource = input.string("Close", "Breakout Source", options=["Close", "High/Low", "Wick"], group=grpSignals, tooltip="Close = closing price must break ORB. High/Low or Wick = any intrabar pierce.")
useRetest      = input.bool(false, "Require Retest Confirmation", group=grpSignals, tooltip="If enabled, a signal is generated only after price retests the broken ORB level.")
retestBars     = input.int(20, "Retest Window (bars)", minval=1, maxval=200, group=grpSignals, tooltip="Maximum number of bars after the initial break in which a retest is still considered valid.")
oneSignalSide  = input.bool(true, "One Signal Per Side / Day", group=grpSignals, tooltip="Limit to a single Buy and a single Sell signal per trading day.")

// -- Pre-Session Marker ------------------------------------------------------
// Marks out a short window ahead of the Trading Session (exchange open).
// Defaults to a 15-minute window starting 1.5 hours (90 minutes) before the
// exchange opens — e.g. with the New York preset (Trading 09:30-16:00) this
// highlights 08:00-08:15. The offset is anchored to the Trading Session START,
// not the OR start, so it stays at "1.5h before the exchange" regardless of
// how the OR is configured. The custom inputs below let you override.
grpPre        = "Pre-Session Marker"
showPreRange  = input.bool(true, "Show Pre-Session Range", group=grpPre, tooltip="Mark out a short window ahead of the Trading Session start (exchange open). Useful for tracking pre-market positioning.")
preOffsetMin  = input.int(90, "Minutes Before Exchange Open", minval=1, maxval=480, group=grpPre, tooltip="How long before the Trading Session start (exchange open) this pre-window begins. Default 90 = 1.5 hours before the exchange. Anchored to the Trading Session start, not the OR.")
preLengthMin  = input.int(15, "Pre-Session Length (minutes)", minval=1, maxval=120, group=grpPre, tooltip="How many minutes the pre-window covers from its start.")
showPreLines  = input.bool(true, "Show Pre-Session High/Low Lines", group=grpPre)
preBoxColor   = input.color(color.new(color.orange, 85), "Pre-Session Box Fill", group=grpPre)
preLineColor  = input.color(color.new(color.orange, 0),  "Pre-Session Line Color", group=grpPre)

// -- Nearest Pre-OR Breach Levels --------------------------------------------
// After the OR ends, this walks BACKWARDS in time from just before the OR
// start. It finds the FIRST candle (going back) whose HIGH exceeds the OR
// High, and the FIRST candle whose LOW drops below the OR Low. Whatever it
// finds first, no matter how many candles back, is what gets drawn — dashed
// horizontal lines that extend across the chart. Useful for identifying the
// closest prior candle that broke each side of the OR range.
grpRef         = "Nearest Pre-OR Breach"
showRefCandle  = input.bool(true, "Show Nearest Pre-OR Breach Levels", group=grpRef, tooltip="Walks backwards from just before the OR and finds the first candle whose HIGH exceeded the OR High, and the first candle whose LOW went below the OR Low. Those two levels are drawn as horizontal dashed lines.")
refLookbackMin = input.int(240, "Max Lookback (minutes)", minval=15, maxval=1440, step=15, group=grpRef, tooltip="How far back before the OR to search. 240 = 4 hours, 480 = 8 hours. If no breach is found within this range, that side is skipped.")
refHiColor     = input.color(color.new(color.lime, 0), "Upper Breach Color (above OR High)", group=grpRef)
refLoColor     = input.color(color.new(color.red,  0), "Lower Breach Color (below OR Low)",  group=grpRef)
refLineWidth   = input.int(2, "Line Width", minval=1, maxval=5, group=grpRef)

// -- Visuals -----------------------------------------------------------------
grpStyle      = "Visuals"
showRangeBox  = input.bool(true,  "Show Opening Range Box",      group=grpStyle)
showOrLines   = input.bool(true,  "Show ORB High/Low Lines",     group=grpStyle)
extendLines   = input.bool(true,  "Extend Lines Through Trade Session", group=grpStyle)
showLabels    = input.bool(true,  "Show Buy/Sell Labels",        group=grpStyle)
showMidline   = input.bool(false, "Show ORB Midline",            group=grpStyle)
showInfoTable = input.bool(true,  "Show Market Info Table",      group=grpStyle, tooltip="Displays the selected market, timezone, and resolved session times in the top-right corner.")
hiColor       = input.color(color.new(color.teal, 0),  "ORB High Color", group=grpStyle)
loColor       = input.color(color.new(color.red,  0),  "ORB Low Color",  group=grpStyle)
boxColor      = input.color(color.new(color.blue, 85), "Range Box Fill", group=grpStyle)
midColor      = input.color(color.new(color.gray, 40), "Midline Color",  group=grpStyle)
lineWidth     = input.int(2, "Line Width", minval=1, maxval=5, group=grpStyle)

// ============================== HELPERS ======================================
// Zero-pad an integer to two characters ("5" -> "05").
f_pad2(int n) =>
    n < 10 ? "0" + str.tostring(n) : str.tostring(n)

// Build a session string "HHMM-HHMM" representing a window that starts
// _offsetMin minutes before the OR session and lasts _lengthMin minutes.
// Clamped to a single day so it never wraps past midnight.
f_buildPreSession(string _orSess, int _offsetMin, int _lengthMin) =>
    sh         = math.round(nz(str.tonumber(str.substring(_orSess, 0, 2))))
    sm         = math.round(nz(str.tonumber(str.substring(_orSess, 2, 4))))
    rawStart   = sh * 60 + sm - _offsetMin
    rawEnd     = rawStart + _lengthMin
    totalStart = math.max(rawStart, 0)
    totalEnd   = math.min(math.max(rawEnd, totalStart + 1), 24 * 60 - 1)
    aH = totalStart / 60
    aM = totalStart % 60
    bH = totalEnd / 60
    bM = totalEnd % 60
    f_pad2(aH) + f_pad2(aM) + "-" + f_pad2(bH) + f_pad2(bM)

// Returns true when the given session is active for the current bar.
f_inSession(string _sess) =>
    not na(time(timeframe.period, _sess, sessionTZ))

// Converts a session string like "0930-1000" (in fromTZ) into the equivalent
// "HH:mm-HH:mm" formatted in toTZ, using the current bar's calendar date in
// the source timezone as the reference day. Handles DST automatically and is
// na-safe (timestamp() returns na for non-existent wall-clock times during
// spring-forward DST transitions; passing na to str.format_time would trigger
// a runtime warning).
f_sessionToLocal(string _sess, string _fromTZ, string _toTZ) =>
    string result = _sess
    if str.length(_sess) >= 9
        startH  = math.round(nz(str.tonumber(str.substring(_sess, 0, 2))))
        startM  = math.round(nz(str.tonumber(str.substring(_sess, 2, 4))))
        endH    = math.round(nz(str.tonumber(str.substring(_sess, 5, 7))))
        endM    = math.round(nz(str.tonumber(str.substring(_sess, 7, 9))))
        y       = year(time, _fromTZ)
        mo      = month(time, _fromTZ)
        d       = dayofmonth(time, _fromTZ)
        startTs = timestamp(_fromTZ, y, mo, d, startH, startM)
        endTs   = timestamp(_fromTZ, y, mo, d, endH,   endM)
        startStr = na(startTs) ? "--:--" : str.format_time(startTs, "HH:mm", _toTZ)
        endStr   = na(endTs)   ? "--:--" : str.format_time(endTs,   "HH:mm", _toTZ)
        result := startStr + "-" + endStr
    result

// Pre-session window built from the TRADING SESSION start + offset/length.
// Kept as a string ONLY for the info-table display. The actual in-window
// detection uses minute-of-day comparison below (passing a dynamically
// constructed string to time(...) triggers a runtime warning in Pine v6).
preSession = f_buildPreSession(tradeSession, preOffsetMin, preLengthMin)

// Compute pre-session start/end as minutes-from-midnight in sessionTZ.
// Parse OR and Trading session bounds into minutes-from-midnight (in sessionTZ)
orStartH         = math.round(nz(str.tonumber(str.substring(orSession, 0, 2))))
orStartM         = math.round(nz(str.tonumber(str.substring(orSession, 2, 4))))
orEndH           = math.round(nz(str.tonumber(str.substring(orSession, 5, 7))))
orEndM           = math.round(nz(str.tonumber(str.substring(orSession, 7, 9))))
tradeStartH      = math.round(nz(str.tonumber(str.substring(tradeSession, 0, 2))))
tradeStartM      = math.round(nz(str.tonumber(str.substring(tradeSession, 2, 4))))
tradeEndH        = math.round(nz(str.tonumber(str.substring(tradeSession, 5, 7))))
tradeEndM        = math.round(nz(str.tonumber(str.substring(tradeSession, 7, 9))))

// Base session bounds (in minutes-from-midnight, sessionTZ)
orStartMin       = orStartH * 60 + orStartM
orEndMin         = orEndH   * 60 + orEndM
tradeStartMin    = tradeStartH * 60 + tradeStartM
tradeEndMin      = tradeEndH   * 60 + tradeEndM

// Pre-session is anchored to the Trading Session start (the exchange open).
// This keeps it at "N minutes before the exchange opens" regardless of how
// the OR window is configured or offset. Default: 90 min before = 1.5 hours.
preStartMin      = math.max(tradeStartMin - preOffsetMin, 0)
preEndMin        = math.min(preStartMin + preLengthMin, 24 * 60 - 1)

// Effective OR start with the user's offset applied. The OR END and every
// other window stay untouched.
effectiveOrStart = math.max(math.min(orStartMin + exchangeOffset, orEndMin - 1), 0)

// Current bar's clock time in the session timezone
curMinOfDay      = hour(time, sessionTZ) * 60 + minute(time, sessionTZ)

inOR    = curMinOfDay >= effectiveOrStart and curMinOfDay < orEndMin
inTrade = curMinOfDay >= tradeStartMin    and curMinOfDay < tradeEndMin
inPre   = curMinOfDay >= preStartMin      and curMinOfDay < preEndMin

// Detect session transitions and day changes
orStart    = inOR    and not inOR[1]
orEnd      = not inOR and inOR[1]
preStart   = inPre   and not inPre[1]
preEnd     = not inPre and inPre[1]
tradeStart = inTrade and not inTrade[1]
newDay     = ta.change(time("D")) != 0

// ============================== STATE ========================================
var float orHigh        = na
var float orLow         = na
var int   orStartTime   = na
var int   orEndTime     = na
var bool  orLocked      = false

// Drawing handles so they persist & can be updated as the OR builds
var line  hiLine   = na
var line  loLine   = na
var line  midLine  = na
var box   rangeBox = na

// Pre-session state & visuals
var float preHigh    = na
var float preLow     = na
var bool  preLocked  = false
var line  preHiLine  = na
var line  preLoLine  = na
var box   preBox     = na

// Nearest pre-OR breach state & visuals
var float refHigh       = na
var float refLow        = na
var line  refHiLine     = na
var line  refLoLine     = na

// Bar_index of the first OR bar for the current day. Used by the backwards
// scan to compute the offset to the first pre-OR bar without keeping a
// running counter — supports dynamic re-scanning while the OR is still
// forming (orHigh / orLow keep updating each bar).
var int   orFirstBarIdx = na
var int   orBarCount    = 0

// Signal state, reset each day
var bool  longBreak     = false
var bool  shortBreak    = false
var int   longBreakBar  = na
var int   shortBreakBar = na
var bool  longSignaled  = false
var bool  shortSignaled = false

// ============================== DAILY RESET ==================================
if newDay
    orHigh        := na
    orLow         := na
    orStartTime   := na
    orEndTime     := na
    orLocked      := false
    longBreak     := false
    shortBreak    := false
    longBreakBar  := na
    shortBreakBar := na
    longSignaled  := false
    shortSignaled := false
    hiLine        := na
    loLine        := na
    midLine       := na
    rangeBox      := na
    preHigh       := na
    preLow        := na
    preLocked     := false
    preHiLine     := na
    preLoLine     := na
    preBox        := na
    refHigh        := na
    refLow         := na
    refHiLine      := na
    refLoLine      := na
    orBarCount     := 0
    orFirstBarIdx  := na

// Track number of bars in the current day's OR window (needed for backwards
// scan to skip these bars before searching pre-OR territory).
if inOR
    orBarCount := orBarCount + 1

// ============================== BUILD PRE-SESSION RANGE =====================
if showPreRange and inPre
    if preStart or na(preHigh)
        preHigh   := high
        preLow    := low
        preLocked := false
        if showPreLines
            preHiLine := line.new(x1=time, y1=preHigh, x2=time, y2=preHigh, xloc=xloc.bar_time, color=preLineColor, width=lineWidth, style=line.style_dashed)
            preLoLine := line.new(x1=time, y1=preLow,  x2=time, y2=preLow,  xloc=xloc.bar_time, color=preLineColor, width=lineWidth, style=line.style_dashed)
        preBox := box.new(left=time, top=preHigh, right=time, bottom=preLow, xloc=xloc.bar_time, bgcolor=preBoxColor, border_color=color.new(color.orange, 50))
    else
        preHigh := math.max(preHigh, high)
        preLow  := math.min(preLow,  low)

    // Live update of pre-session visuals as the window forms.
    // Use time_close (end of the bar) so the visual covers the full last bar.
    if showPreLines and not na(preHiLine)
        line.set_xy2(preHiLine, time_close, preHigh)
        line.set_y1(preHiLine, preHigh)
        line.set_xy2(preLoLine, time_close, preLow)
        line.set_y1(preLoLine, preLow)
    if not na(preBox)
        box.set_right(preBox, time_close)
        box.set_top(preBox, preHigh)
        box.set_bottom(preBox, preLow)

// Lock the pre-session high/low when its window ends
if preEnd and not preLocked
    preLocked := true

// ============================== BUILD OPENING RANGE ==========================
if inOR
    if orStart or na(orHigh)
        orHigh        := high
        orLow         := low
        orStartTime   := time
        orLocked      := false
        orFirstBarIdx := bar_index
        if showOrLines
            hiLine := line.new(x1=time, y1=orHigh, x2=time, y2=orHigh, xloc=xloc.bar_time, color=hiColor, width=lineWidth, style=line.style_solid)
            loLine := line.new(x1=time, y1=orLow,  x2=time, y2=orLow,  xloc=xloc.bar_time, color=loColor, width=lineWidth, style=line.style_solid)
        if showMidline
            midLine := line.new(x1=time, y1=(orHigh + orLow) / 2, x2=time, y2=(orHigh + orLow) / 2, xloc=xloc.bar_time, color=midColor, width=1, style=line.style_dotted)
        if showRangeBox
            rangeBox := box.new(left=time, top=orHigh, right=time, bottom=orLow, xloc=xloc.bar_time, bgcolor=boxColor, border_color=color.new(color.gray, 60))
    else
        orHigh := math.max(orHigh, high)
        orLow  := math.min(orLow,  low)

    // Live update of visuals while the OR is forming.
    // Use time_close so the box and lines cover the full final bar.
    if showOrLines and not na(hiLine)
        line.set_xy2(hiLine, time_close, orHigh)
        line.set_y1(hiLine, orHigh)
        line.set_xy2(loLine, time_close, orLow)
        line.set_y1(loLine, orLow)
    if showMidline and not na(midLine)
        mid = (orHigh + orLow) / 2
        line.set_xy2(midLine, time_close, mid)
        line.set_y1(midLine, mid)
    if showRangeBox and not na(rangeBox)
        box.set_right(rangeBox, time_close)
        box.set_top(rangeBox, orHigh)
        box.set_bottom(rangeBox, orLow)

// Lock the OR levels at session end
if orEnd and not orLocked
    orEndTime := time
    orLocked  := true

// ============================== DYNAMIC PRE-OR BREACH SCAN ==================
// Runs on every bar during the OR (while orHigh/orLow are still updating) AND
// once more at orEnd, so the reference lines track the current OR bounds live.
// The lines anchor at the reference candle's timestamp and end 5 minutes after
// the Trading Session opens.
if showRefCandle and (inOR or orEnd) and not na(orHigh) and not na(orLow) and not na(orFirstBarIdx)
    // Line endpoint: 5 minutes after the Trading Session start, on the
    // current day, in the session timezone.
    endBaseMin = tradeStartMin + 5
    endBaseH   = endBaseMin / 60
    endBaseM   = endBaseMin % 60
    lineEndTs  = timestamp(sessionTZ, year(time, sessionTZ), month(time, sessionTZ), dayofmonth(time, sessionTZ), endBaseH, endBaseM)

    // Convert user's minutes-back into bars for this timeframe.
    tfSec        = math.max(timeframe.in_seconds(), 60)
    lookbackBars = math.min(math.floor(refLookbackMin * 60 / tfSec), 4000)
    // Skip every bar from the OR's first bar through the current bar,
    // then start scanning at the first pre-OR bar.
    startBack    = bar_index - orFirstBarIdx + 1

    foundHi = false
    foundLo = false
    hiVal   = 0.0
    loVal   = 0.0
    hiIdx   = 0
    loIdx   = 0
    for i = startBack to (startBack + lookbackBars - 1)
        if not foundHi and not na(high[i]) and high[i] > orHigh
            hiVal   := high[i]
            hiIdx   := i
            foundHi := true
        if not foundLo and not na(low[i]) and low[i] < orLow
            loVal   := low[i]
            loIdx   := i
            foundLo := true
        if foundHi and foundLo
            break

    // Upper reference line
    if foundHi
        refHigh := hiVal
        hiStart = time[hiIdx]
        if na(refHiLine)
            refHiLine := line.new(x1=hiStart, y1=hiVal, x2=lineEndTs, y2=hiVal, xloc=xloc.bar_time, color=refHiColor, width=refLineWidth, style=line.style_dashed)
        else
            line.set_xy1(refHiLine, hiStart, hiVal)
            line.set_xy2(refHiLine, lineEndTs, hiVal)
    else
        refHigh := na
        if not na(refHiLine)
            line.delete(refHiLine)
            refHiLine := na

    // Lower reference line
    if foundLo
        refLow := loVal
        loStart = time[loIdx]
        if na(refLoLine)
            refLoLine := line.new(x1=loStart, y1=loVal, x2=lineEndTs, y2=loVal, xloc=xloc.bar_time, color=refLoColor, width=refLineWidth, style=line.style_dashed)
        else
            line.set_xy1(refLoLine, loStart, loVal)
            line.set_xy2(refLoLine, lineEndTs, loVal)
    else
        refLow := na
        if not na(refLoLine)
            line.delete(refLoLine)
            refLoLine := na

// ============================== EXTEND THROUGH TRADING SESSION ==============
if orLocked and inTrade and extendLines
    if showOrLines and not na(hiLine)
        line.set_xy2(hiLine, time_close, orHigh)
        line.set_xy2(loLine, time_close, orLow)
    if showMidline and not na(midLine)
        line.set_xy2(midLine, time_close, (orHigh + orLow) / 2)

// ============================== SIGNAL LOGIC =================================
brkUp = breakoutSource == "Close" ? close > orHigh : high > orHigh
brkDn = breakoutSource == "Close" ? close < orLow  : low  < orLow

canSignal = orLocked and inTrade and not na(orHigh) and not na(orLow)

// Initial break detection
if canSignal and not longBreak and brkUp
    longBreak    := true
    longBreakBar := bar_index
if canSignal and not shortBreak and brkDn
    shortBreak    := true
    shortBreakBar := bar_index

// Generate signals
var bool buySignal  = false
var bool sellSignal = false
buySignal  := false
sellSignal := false

if canSignal
    if not useRetest
        buySignal  := longBreak  and not longSignaled  and bar_index == longBreakBar
        sellSignal := shortBreak and not shortSignaled and bar_index == shortBreakBar
    else
        if longBreak and not longSignaled and (bar_index - longBreakBar) <= retestBars
            retestedLong = low <= orHigh and close > orHigh
            buySignal := retestedLong
        if shortBreak and not shortSignaled and (bar_index - shortBreakBar) <= retestBars
            retestedShort = high >= orLow and close < orLow
            sellSignal := retestedShort

// One signal per side per day
if oneSignalSide
    if buySignal and longSignaled
        buySignal := false
    if sellSignal and shortSignaled
        sellSignal := false

if buySignal
    longSignaled  := true
if sellSignal
    shortSignaled := true

// ============================== PLOTTING =====================================
if showLabels and buySignal
    label.new(bar_index, low,  text="▲",  style=label.style_label_up,   color=color.new(color.green, 0), textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if showLabels and sellSignal
    label.new(bar_index, high, text="▼", style=label.style_label_down, color=color.new(color.red,   0), textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// Subtle background shading during the opening range and pre-session
bgcolor(inOR ? color.new(color.yellow, 92) : na, title="Opening Range BG")
bgcolor(showPreRange and inPre ? color.new(color.orange, 92) : na, title="Pre-Session BG")

// Series plots so the levels appear in the Data Window / price scale
plot(orLocked ? orHigh : na, title="ORB High", color=hiColor, linewidth=1, style=plot.style_linebr, display=display.data_window + display.price_scale)
plot(orLocked ? orLow  : na, title="ORB Low",  color=loColor, linewidth=1, style=plot.style_linebr, display=display.data_window + display.price_scale)

// ============================== ALERTS =======================================
alertcondition(buySignal,  title="Range High Break",    message="Session Range: price crossed above the upper reference level")
alertcondition(sellSignal, title="Range Low Break",     message="Session Range: price crossed below the lower reference level")
alertcondition(orEnd,      title="Opening Range Locked", message="Session Range: opening range window complete — reference levels locked")

// ============================== INFO TABLE ===================================
// Only build the table on the last bar — the timezone conversions are
// relatively expensive and only need to be displayed once.
var table info = na
if showInfoTable and barstate.islast
    orSessionLocal    = f_sessionToLocal(orSession,    sessionTZ, userTZ)
    tradeSessionLocal = f_sessionToLocal(tradeSession, sessionTZ, userTZ)
    preSessionLocal   = f_sessionToLocal(preSession,   sessionTZ, userTZ)
    if na(info)
        info := table.new(position.top_right, 3, 7, bgcolor=color.new(color.black, 80), border_color=color.new(color.gray, 60), border_width=1)
    // Header row
    table.cell(info, 0, 0, "",                text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 0, "Market",          text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 2, 0, "Your Local",      text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    // Market name / your TZ label
    table.cell(info, 0, 1, "Name",            text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 1, market,            text_color=color.white, text_size=size.small)
    table.cell(info, 2, 1, userTZ,            text_color=color.white, text_size=size.small)
    // Timezone row (with OR-start offset annotation if non-zero)
    offsetStr = exchangeOffset == 0 ? sessionTZ : sessionTZ + " (OR start " + (exchangeOffset > 0 ? "+" : "") + str.tostring(exchangeOffset) + "m)"
    table.cell(info, 0, 2, "Timezone",        text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 2, offsetStr,         text_color=exchangeOffset == 0 ? color.white : color.new(color.aqua, 0), text_size=size.small)
    table.cell(info, 2, 2, userTZ,            text_color=color.white, text_size=size.small)
    // Pre-Session row
    preLabel = showPreRange ? "Pre-Sess" : "Pre-Sess (off)"
    preTextColor = showPreRange ? color.new(color.orange, 0) : color.new(color.gray, 30)
    table.cell(info, 0, 3, preLabel,          text_color=color.white,  text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 3, preSession,        text_color=preTextColor, text_size=size.small)
    table.cell(info, 2, 3, preSessionLocal,   text_color=preTextColor, text_size=size.small)
    // Opening Range row
    table.cell(info, 0, 4, "Op. Range",       text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 4, orSession,         text_color=color.white, text_size=size.small)
    table.cell(info, 2, 4, orSessionLocal,    text_color=color.new(color.yellow, 0), text_size=size.small)
    // Trading session row
    table.cell(info, 0, 5, "Trading",         text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 5, tradeSession,      text_color=color.white, text_size=size.small)
    table.cell(info, 2, 5, tradeSessionLocal, text_color=color.new(color.yellow, 0), text_size=size.small)
    // Reference candle row
    refLabel = showRefCandle ? "Breach ±" + str.tostring(refLookbackMin) + "m" : "Breach (off)"
    hiText   = na(refHigh) ? "—" : str.tostring(refHigh, format.mintick)
    loText   = na(refLow)  ? "—" : str.tostring(refLow,  format.mintick)
    refText  = showRefCandle ? hiText + " / " + loText : "-"
    refTextColor = showRefCandle ? color.new(color.lime, 0) : color.new(color.gray, 30)
    table.cell(info, 0, 6, refLabel, text_color=color.white,  text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 6, refText,  text_color=refTextColor, text_size=size.small)
    table.cell(info, 2, 6, refText,  text_color=refTextColor, text_size=size.small)
````
