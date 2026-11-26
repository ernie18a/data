# Built by Baid- ORB(Sep-May, EMA21 Trend Filter)

- url: https://www.tradingview.com/script/rRzqzsZE-Built-by-Baid-ORB-Sep-May-EMA21-Trend-Filter/
- type: indicator
- pine_id: PUB;c8f79dff6e2546caabc41975b264ca3a
- version: 1.0

## Description

ORB Seasonal Strategy (Sep-May, EMA21 Trend Filter)

OVERVIEW

This indicator implements a seasonal opening-range breakout (ORB) system
designed for index futures (built and tested on MNQ / Micro Nasdaq-100).
It combines four simple, mechanical rules into a single signal:

  1. A daily trend filter (EMA21 of the prior day's close)
  2. A 15-minute opening range measured at the US cash market open
  3. A breakout trigger that only fires in the direction of the trend
  4. A seasonal filter that skips the historically weakest months

The goal is not to predict the market, but to take a well-defined breakout
only when the recent trend and the time of year are both favorable, and to
skip everything else.

HOW IT WORKS

Daily Trend Filter
  Each day, the script checks the previous day's closing price against its
  own 21-day EMA. If the prior close is above the EMA, only long signals
  are allowed that day. If below, only short signals are allowed. This
  uses the prior day's confirmed value only, so it does not repaint.

Opening Range
  The script watches the first 15 minutes after the US cash market opens
  (9:30-9:45 AM ET) and records the high and low reached in that window.
  This becomes the "opening range" for the day.

Breakout Entry
  From 9:45 AM to 3:30 PM ET, the script watches for a candle to CLOSE
  beyond the opening range (not just wick through it). A close above the
  range high is a long signal; a close below the range low is a short
  signal -- but only if that direction matches today's trend filter.

Seasonal Filter
  Backtesting showed this specific strategy performs meaningfully worse,
  on average, from June through August than the rest of the year. The
  script optionally skips signals entirely during those three months
  (toggle: "Enable Season Filter").

Stop Loss / Target
  Once a signal fires: stop-loss is set at the opposite side of the
  opening range; target is set at a configurable multiple of that same
  distance (default 2.0x, i.e. reward is twice the risk).

One Trade Per Day
  Only the first qualifying breakout of the day is signaled. If a
  breakout occurs but is filtered out (wrong season, or against the
  trend), the script marks it as a "NO ENTRY" event and will not
  signal again that day, matching how the underlying strategy was
  designed and tested.

WHAT YOU'LL SEE ON THE CHART

  - A shaded box marking each day's opening range
  - Green up-triangle = long signal, red down-triangle = short signal
  - Dashed red/green lines showing the calculated stop and target once a
    signal fires
  - Orange "NO ENTRY" labels explaining why a breakout was skipped
    (out of season, or against the trend)
  - A background tint showing today's trend direction at a glance
  - An info table (top-right) summarizing season status, trend
    direction, today's range size, and whether a trade has already
    triggered

SETTINGS

  Opening Range Minutes     - length of the opening range window (default 15)
  Target R-Multiple         - reward as a multiple of risk (default 2.0)
  Enable Season Filter      - skip Jun/Jul/Aug (default on)
  Enable Daily Trend Filter - require trend alignment (default on)
  Daily Trend EMA Length    - length of the daily EMA (default 21)
  Display toggles           - show/hide the range box, SL/TP lines, and
                               no-entry labels independently

ALERTS

Three alert conditions are built in:
  - "ORB Buy Signal"        - fires only on long entries
  - "ORB Sell Signal"       - fires only on short entries
  - "ORB Any Entry Signal"  - fires on either

To set one up: click the Alert icon, choose this indicator as the
condition, select one of the three signals above, and set the trigger
to "Once Per Bar Close" so alerts fire only on confirmed candles.

INTENDED USE

Built for a 5-minute chart on MNQ. The opening-range and breakout
windows are anchored to US Eastern Time internally, so the signals
trigger at the correct real-world moments regardless of what timezone
your chart is displaying.

This script is a decision-support and alerting tool, not an automated
trading system -- it does not place orders. All entries, position
sizing, and risk management remain the trader's responsibility.

DISCLAIMER

This script is provided for informational and educational purposes
only and does not constitute financial advice. Past performance shown
in any backtest does not guarantee future results. Trade at your own
risk.

## Source Code

````pine
//@version=6
indicator("Built by Baid- ORB(Sep-May, EMA21 Trend Filter)", overlay=true, max_lines_count=200, max_labels_count=200)

// =============================================================================
// INPUTS
// =============================================================================
orMinutes      = input.int(15, "Opening Range Minutes", minval=5, group="Range")
rMultiple      = input.float(2.0, "Target R-Multiple (Target = R x Risk)", minval=0.5, step=0.25, group="Range")

seasonFilterOn = input.bool(true, "Enable Season Filter (Sep-May only)", group="Filters")
trendFilterOn  = input.bool(true, "Enable Daily Trend Filter (EMA21)", group="Filters")
emaLen         = input.int(21, "Daily Trend EMA Length", group="Filters")

showRangeBox   = input.bool(true, "Show Opening Range Box", group="Display")
showSLTP       = input.bool(true, "Show SL/TP Lines", group="Display")
showSkipLabels = input.bool(true, "Show 'No Entry' Labels", group="Display")

// =============================================================================
// SESSION / TIME WINDOWS (all times in exchange's local session, America/New_York)
// =============================================================================
rangeSession = input.session("0930-0945", "Opening Range Window (ET)", group="Session")
tradeSession = input.session("0945-1530", "Breakout Window (ET)", group="Session")
eodHour      = input.int(15, "Force-Close Hour (ET, 24h)", group="Session")
eodMinute    = input.int(55, "Force-Close Minute (ET)", group="Session")

inRangeWin  = not na(time(timeframe.period, rangeSession, "America/New_York"))
inTradeWin  = not na(time(timeframe.period, tradeSession, "America/New_York"))

etTime  = time("D", "America/New_York")
etHour  = hour(etTime)
etMin   = minute(etTime)
isEOD   = (etHour > eodHour) or (etHour == eodHour and etMin >= eodMinute)

// =============================================================================
// SEASON FILTER: Sep(9) - May(5), skip Jun/Jul/Aug -- anchored to NY time
// =============================================================================
m = month(timenow, "America/New_York")
mBar = month(time, "America/New_York")
inSeason = not seasonFilterOn or (mBar == 9 or mBar == 10 or mBar == 11 or mBar == 12 or mBar == 1 or mBar == 2 or mBar == 3 or mBar == 4 or mBar == 5)

// =============================================================================
// DAILY TREND FILTER: prior completed day's close vs its EMA(21), avoids repaint
// =============================================================================
dailyClosePrior = request.security(syminfo.tickerid, "1D", close[1], lookahead=barmerge.lookahead_off)
dailyEmaPrior   = request.security(syminfo.tickerid, "1D", ta.ema(close, emaLen)[1], lookahead=barmerge.lookahead_off)
trendUp   = dailyClosePrior > dailyEmaPrior
trendDown = dailyClosePrior < dailyEmaPrior
trendOK(isLong) => not trendFilterOn or (isLong and trendUp) or (not isLong and trendDown)

// =============================================================================
// OPENING RANGE TRACKING (resets each new day)
// =============================================================================
var float rangeHigh = na
var float rangeLow  = na
var bool  rangeReady = false
var bool  tradedToday = false
var box   rangeBox = na

newDay = ta.change(time("D", "America/New_York")) != 0
if newDay
    rangeHigh := na
    rangeLow  := na
    rangeReady := false
    tradedToday := false

if inRangeWin
    rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
    rangeLow  := na(rangeLow)  ? low  : math.min(rangeLow, low)
    rangeReady := true
    if showRangeBox
        if na(rangeBox)
            rangeBox := box.new(bar_index, rangeHigh, bar_index, rangeLow, border_color=color.new(color.gray,40), bgcolor=color.new(color.gray,90))
        else
            box.set_top(rangeBox, rangeHigh)
            box.set_bottom(rangeBox, rangeLow)
            box.set_right(rangeBox, bar_index)

// extend the range box across the trade window once range-building ends
if inTradeWin and not na(rangeBox)
    box.set_right(rangeBox, bar_index)

// =============================================================================
// ENTRY LOGIC (one signal per day, only inside the breakout window)
// =============================================================================
longBreak  = rangeReady and inTradeWin and not tradedToday and close > rangeHigh
shortBreak = rangeReady and inTradeWin and not tradedToday and close < rangeLow

longSignal  = longBreak  and inSeason and trendOK(true)
shortSignal = shortBreak and inSeason and trendOK(false)

// a breakout occurred but was filtered out -> "no entry" case
skippedLong  = longBreak  and not (inSeason and trendOK(true))
skippedShort = shortBreak and not (inSeason and trendOK(false))

if longSignal or shortSignal
    tradedToday := true
if skippedLong or skippedShort
    tradedToday := true   // only ever flag the FIRST breakout of the day, same as the live rule

// =============================================================================
// SL / TP CALCULATION FOR DISPLAY
// =============================================================================
var float slPrice = na
var float tpPrice = na
var line slLine = na
var line tpLine = na
var line enLine = na

if longSignal
    riskDist = close - rangeLow
    slPrice := rangeLow
    tpPrice := close + rMultiple * riskDist
if shortSignal
    riskDist = rangeHigh - close
    slPrice := rangeHigh
    tpPrice := close - rMultiple * riskDist

if (longSignal or shortSignal) and showSLTP
    line.delete(slLine)
    line.delete(tpLine)
    line.delete(enLine)
    slLine := line.new(bar_index, slPrice, bar_index + 20, slPrice, color=color.red, style=line.style_dashed, width=1)
    tpLine := line.new(bar_index, tpPrice, bar_index + 20, tpPrice, color=color.green, style=line.style_dashed, width=1)
    enLine := line.new(bar_index, close, bar_index + 20, close, color=color.blue, style=line.style_dotted, width=1)
    label.new(bar_index, tpPrice, "TP " + str.tostring(tpPrice, format.mintick), style=label.style_label_down, color=color.new(color.green,80), textcolor=color.green, size=size.small)
    label.new(bar_index, slPrice, "SL " + str.tostring(slPrice, format.mintick), style=label.style_label_up, color=color.new(color.red,80), textcolor=color.red, size=size.small)

// =============================================================================
// PLOTTING
// =============================================================================
plotshape(longSignal,  title="BUY",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.green,0), size=size.normal, text="BUY")
plotshape(shortSignal, title="SELL", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0),   size=size.normal, text="SELL")

if showSkipLabels and (skippedLong or skippedShort)
    reason = not inSeason ? "Out of season" : "Counter-trend"
    label.new(bar_index, skippedLong ? high : low, "NO ENTRY\n(" + reason + ")",
              style=skippedLong ? label.style_label_down : label.style_label_up,
              color=color.new(color.orange,85), textcolor=color.orange, size=size.small)

// background tint: green = long-only day, red = short-only day, gray = out of season / filter off
bgcolor(trendFilterOn and inSeason ? (trendUp ? color.new(color.green,92) : color.new(color.red,92)) : na)

// =============================================================================
// ALERTS
// =============================================================================
alertcondition(longSignal,  title="ORB Buy Signal",  message="ORB BUY signal on {{ticker}} @ {{close}}. Check chart for SL/TP levels.")
alertcondition(shortSignal, title="ORB Sell Signal",  message="ORB SELL signal on {{ticker}} @ {{close}}. Check chart for SL/TP levels.")
alertcondition(longSignal or shortSignal, title="ORB Any Entry Signal", message="ORB entry signal on {{ticker}} @ {{close}} -- {{time}}")

// =============================================================================
// INFO TABLE (current state at a glance)
// =============================================================================
var table info = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black,20), border_color=color.gray, border_width=1)
if barstate.islast
    table.cell(info, 0, 0, "Season", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, inSeason ? "IN (Sep-May)" : "OUT (Jun-Aug)", text_color=inSeason ? color.lime : color.orange, text_size=size.small)
    table.cell(info, 0, 1, "Daily Trend", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, trendUp ? "UP (longs only)" : "DOWN (shorts only)", text_color=trendUp ? color.lime : color.red, text_size=size.small)
    table.cell(info, 0, 2, "Range", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, na(rangeHigh) ? "building..." : str.tostring(rangeHigh - rangeLow, format.mintick) + " pts", text_color=color.white, text_size=size.small)
    table.cell(info, 0, 3, "Traded Today", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 3, tradedToday ? "YES" : "NO", text_color=tradedToday ? color.gray : color.yellow, text_size=size.small)
````
