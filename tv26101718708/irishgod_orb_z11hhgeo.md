# IrishGOD (ORB)

- url: https://www.tradingview.com/script/z11HHgEo-IrishGOD-ORB/
- type: indicator
- pine_id: PUB;3fe5e36c68a544fda01a87350fc589ec
- version: 2.0

## Description

Opening Range Breakout (ORB) Indicator — Professional Description
Pine Script v5 Overlay Indicator Intraday
Opening Range Breakout (ORB)
A precision intraday indicator that defines the high and low of a configurable opening range window, locks those levels once the window expires, and flags the first directional breakout of the day with a clear visual signal directly on the chart.

Overview

The Opening Range Breakout strategy is one of the most widely used frameworks in active intraday and momentum trading. The theory holds that the high and low established during the first N minutes of a session represent a market structure boundary — a zone of price discovery where institutional and retail participants alike are establishing positions. A decisive break above or below this range often signals the direction of the day's dominant trend.

This indicator automates the entire process: it watches price during the formation window, locks the range the instant the window closes, draws clean reference lines, and marks the first breakout in each direction with a non-cluttering arrow label — without requiring any manual input from the trader after initial setup.

Core logic

Phase 1 — Range formation

From the configured session open time, the indicator tracks the rolling high and low of every bar within the ORB window. No lines are drawn yet; the range is still live and expanding with each new bar.

Phase 2 — Range lock

On the first bar after the ORB window closes, the high and low are frozen. Two horizontal lines are drawn from that exact bar extending forward for the remainder of the session. The range will not change again for the rest of the day.

Phase 3 — Bullish breakout signal

If price closes above the ORB High after the window has locked, a green upward arrow is plotted below the breakout candle. This signal fires only once per day — the first confirmed close above the range.

Phase 4 — Bearish breakout signal

If price closes below the ORB Low after the window has locked, a red downward arrow is plotted above the breakout candle. Like the bullish signal, this fires once per day on first confirmed close below the range.

Configuration parameters

Parameter	Default	Description
Session Start Hour	9	Hour of day (24-hour format) when the session opens and ORB formation begins. Adjust for futures, forex, or international markets.
Session Start Minute	30	Minute offset within the start hour. Combined with the hour input, defines the exact session open (default: 9:30 for US equities).
ORB Duration	30 min	How many minutes the range formation window remains open. Common settings are 5, 15, 30, and 60 minutes. Accepts 1–240 minutes.
Range High Line Color	Teal	Color of the horizontal ORB High reference line. Fully customizable via the TradingView color picker.
Range Low Line Color	Orange	Color of the horizontal ORB Low reference line. Distinct from the high to allow instant visual separation at a glance.
Line Width	1	Thickness of the range lines in pixels. Range of 1–4. Useful for scaling visibility on higher-resolution monitors.
Arrow Size	small	Controls the rendered size of breakout arrow labels. Options: tiny, small, normal, large. Sized to avoid obscuring surrounding price action.
Extend Lines	true	When enabled, range lines extend 500 bars to the right — effectively to the right edge of the visible chart. Disable to limit lines to ~390 bars (standard session length).
Enable Alerts	false	When enabled, fires a TradingView alert on the first bullish or bearish breakout of each session. Compatible with webhooks, email, and push notifications.
Visual features

Formation Window

Yellow background tint

A subtle highlight shades the candles within the ORB formation window so you can immediately see which bars contributed to the range definition.

Reference Lines

Clean horizontal levels

Single solid lines mark the ORB High and Low from the moment the window closes, extending forward without visual clutter. Previous day's lines are removed automatically.

Breakout Arrows

Directional label markers

Arrow labels are offset from price using ATR(14) so they never overlap the candle body or wick. Transparent backgrounds keep the chart unobstructed.

Data Window

ORB level readout

Once the range is locked, the exact ORB High and Low values appear in TradingView's Data Window panel for precise reference at any bar.

Compatibility

The indicator is designed for intraday timeframes — it is most effective on charts from 1-minute through 30-minute bars. It will not produce signals on daily or higher timeframes, as the ORB window logic depends on intraday time-of-day calculations.

The session start time defaults to 9:30 AM ET for US equity and ETF markets. For futures markets (ES, NQ, CL), crypto, or forex, adjust the start hour and minute to match the relevant session open.

US Equities
ETFs
Equity Futures
Crypto
Forex
Commodities
Installation

Open the Pine Script Editor in TradingView, paste the full source code, click Save, then click Add to chart. The indicator will appear immediately on the active chart. All inputs are accessible via the gear icon in the indicator title bar.

## Source Code

````pine
//@version=6
indicator("Opening Range Breakout (ORB)", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp_time  = "Opening Range Settings"
orb_start_hour   = input.int(9,  "Session Start Hour (24h)",  minval=0, maxval=23, group=grp_time)
orb_start_minute = input.int(30, "Session Start Minute",       minval=0, maxval=59, group=grp_time)
orb_minutes      = input.int(30, "ORB Duration (minutes)",     minval=1, maxval=240, group=grp_time,
     tooltip="How many minutes after the session open to define the Opening Range.")

grp_filter = "Signal Filter"
cooldown_bars = input.int(5, "Cooldown (bars between signals)", minval=1, maxval=100, group=grp_filter,
     tooltip="Minimum number of bars that must pass after any breakout signal before the next signal in the same direction can fire. Increase to reduce signal frequency.")
require_close  = input.bool(true, "Require Bar Close Beyond Level", group=grp_filter,
     tooltip="When enabled (recommended), a signal only fires on a confirmed close beyond the ORB level. When disabled, signals can fire intra-bar on a touch.")
retest_filter  = input.bool(false, "Only Signal on Re-entries (Retests)", group=grp_filter,
     tooltip="When enabled, signals only fire when price crosses BACK through the ORB level after having been on the other side, i.e. pullback re-entry signals only.")

grp_style = "Visual Settings"
line_color_high  = input.color(color.new(color.teal,   20), "Range High Line Color", group=grp_style)
line_color_low   = input.color(color.new(color.orange, 20), "Range Low Line Color",  group=grp_style)
line_width       = input.int(1, "Line Width", minval=1, maxval=4, group=grp_style)
arrow_size       = input.string("small", "Arrow Size", options=["tiny","small","normal","large"], group=grp_style)
extend_lines     = input.bool(true, "Extend Lines to End of Session", group=grp_style)

grp_alert = "Alerts"
enable_alerts    = input.bool(false, "Enable Alerts on Breakout", group=grp_alert)

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────
arrowSizeVal() =>
    switch arrow_size
        "tiny"   => size.tiny
        "small"  => size.small
        "large"  => size.large
        =>          size.normal

// Convert session time inputs to minutes since midnight
orbEndMinutes = orb_start_hour * 60 + orb_start_minute + orb_minutes

// Current bar time-of-day in minutes
barMinutes = hour * 60 + minute

// True on the very first bar of the session open minute
isSessionOpen = barMinutes == orb_start_hour * 60 + orb_start_minute

// True while still inside the ORB formation window
inOrbWindow = barMinutes >= orb_start_hour * 60 + orb_start_minute and barMinutes < orbEndMinutes

// True on the first bar AFTER the ORB window closes
orbJustClosed = barMinutes == orbEndMinutes

// Price reference: close for confirmed signals, high/low for intra-bar
checkHigh = require_close ? close : high
checkLow  = require_close ? close : low

// ─────────────────────────────────────────────
//  STATE VARIABLES
// ─────────────────────────────────────────────
var float orbHigh       = na
var float orbLow        = na
var bool  orbLocked     = false

// Cooldown counters: bars elapsed since last signal in each direction
var int   barsSinceBull = 999
var int   barsSinceBear = 999

// Track which side price has visited for retest filter
var bool  wasAboveHigh  = false
var bool  wasBelowLow   = false

var line  lineHigh      = na
var line  lineLow       = na

// ─────────────────────────────────────────────
//  RESET EACH NEW DAY
// ─────────────────────────────────────────────
if isSessionOpen
    orbHigh       := high
    orbLow        := low
    orbLocked     := false
    barsSinceBull := 999
    barsSinceBear := 999
    wasAboveHigh  := false
    wasBelowLow   := false

// ─────────────────────────────────────────────
//  BUILD THE RANGE DURING THE ORB WINDOW
// ─────────────────────────────────────────────
if inOrbWindow and not orbLocked
    orbHigh := math.max(orbHigh, high)
    orbLow  := math.min(orbLow,  low)

// ─────────────────────────────────────────────
//  LOCK THE RANGE AND DRAW LINES AT CLOSE OF ORB
// ─────────────────────────────────────────────
if orbJustClosed and not orbLocked and not na(orbHigh) and not na(orbLow)
    orbLocked := true

    lineEnd = extend_lines ? bar_index + 500 : bar_index + 390

    if not na(lineHigh)
        line.delete(lineHigh)
    if not na(lineLow)
        line.delete(lineLow)

    lineHigh := line.new(
         x1    = bar_index,
         y1    = orbHigh,
         x2    = lineEnd,
         y2    = orbHigh,
         color = line_color_high,
         width = line_width,
         style = line.style_solid)

    lineLow := line.new(
         x1    = bar_index,
         y1    = orbLow,
         x2    = lineEnd,
         y2    = orbLow,
         color = line_color_low,
         width = line_width,
         style = line.style_solid)

// ─────────────────────────────────────────────
//  COOLDOWN COUNTER — increments every bar after lock
// ─────────────────────────────────────────────
if orbLocked
    barsSinceBull := math.min(barsSinceBull + 1, 999)
    barsSinceBear := math.min(barsSinceBear + 1, 999)

// ─────────────────────────────────────────────
//  SIDE-TRACKING FOR RETEST FILTER
//  Records whether price has previously crossed each level
// ─────────────────────────────────────────────
if orbLocked
    if close > orbHigh
        wasAboveHigh := true
    if close < orbLow
        wasBelowLow  := true

// ─────────────────────────────────────────────
//  BREAKOUT CONDITIONS
// ─────────────────────────────────────────────
cooldownOkBull = barsSinceBull >= cooldown_bars
cooldownOkBear = barsSinceBear >= cooldown_bars

afterOrb = barMinutes >= orbEndMinutes

// Standard breakout: price crosses beyond the level
rawBullBreak = orbLocked and afterOrb and checkHigh > orbHigh
rawBearBreak = orbLocked and afterOrb and checkLow  < orbLow

// Retest / re-entry: price pulls back THROUGH the level after having been beyond it
// Bull retest  = was above ORB High, pulled back below, now closes above again
// Bear retest  = was below ORB Low,  pulled back above, now closes below again
retestBullBreak = orbLocked and afterOrb and wasAboveHigh and close[1] <= orbHigh and close > orbHigh
retestBearBreak = orbLocked and afterOrb and wasBelowLow  and close[1] >= orbLow  and close < orbLow

// Select active mode
activeBullBreak = retest_filter ? retestBullBreak : rawBullBreak
activeBearBreak = retest_filter ? retestBearBreak : rawBearBreak

// Gate with cooldown
bullBreak = activeBullBreak and cooldownOkBull
bearBreak = activeBearBreak and cooldownOkBear

// ─────────────────────────────────────────────
//  SIGNAL EXECUTION
// ─────────────────────────────────────────────
if bullBreak
    barsSinceBull := 0
    label.new(
         bar_index, low - ta.atr(14) * 0.5,
         text      = "▲",
         color     = color.new(color.green, 100),
         textcolor = color.new(color.green, 0),
         style     = label.style_label_up,
         size      = arrowSizeVal())
    if enable_alerts
        alert("ORB Bullish Breakout — " + syminfo.ticker, alert.freq_once_per_bar)

if bearBreak
    barsSinceBear := 0
    label.new(
         bar_index, high + ta.atr(14) * 0.5,
         text      = "▼",
         color     = color.new(color.red, 100),
         textcolor = color.new(color.red, 0),
         style     = label.style_label_down,
         size      = arrowSizeVal())
    if enable_alerts
        alert("ORB Bearish Breakout — " + syminfo.ticker, alert.freq_once_per_bar)

// ─────────────────────────────────────────────
//  BACKGROUND HIGHLIGHT (ORB FORMATION WINDOW)
// ─────────────────────────────────────────────
bgcolor(inOrbWindow ? color.new(color.yellow, 92) : na, title="ORB Formation Window")

// ─────────────────────────────────────────────
//  DATA WINDOW
// ─────────────────────────────────────────────
plot(orbLocked ? orbHigh        : na, title="ORB High",              color=color.new(line_color_high, 0), display=display.data_window)
plot(orbLocked ? orbLow         : na, title="ORB Low",               color=color.new(line_color_low,  0), display=display.data_window)
plot(orbLocked ? barsSinceBull  : na, title="Bars Since Bull Signal", display=display.data_window)
plot(orbLocked ? barsSinceBear  : na, title="Bars Since Bear Signal", display=display.data_window)
````
