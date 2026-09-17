<!-- tradingview-pine-id: PUB;1ea315db85954502b7cffac93496c4f9 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# Execution-Aware Trend [BSL]

Source: https://www.tradingview.com/script/Z9O5w3SG-Execution-Aware-Trend-BSL/

## Description

Execution-Aware Trend is a deliberately ordinary trend-and-breakout strategy
whose main product is visible testing discipline. It answers “what did this
exact ruleset simulate after declared costs, next-tick execution and a fixed
sample split?” It does not predict the next move and does not claim an edge.

This is an original BarState Labs implementation created from an independent
written specification. It does not reproduce another publication’s source,
defaults, interface, chart grammar or report.

HOW IT WORKS

Trend qualification uses a fast and slow EMA. A long setup requires the fast
EMA above the slow EMA and the slow EMA above its value at the configured slope
lookback. The short rule is symmetric. Equality qualifies neither side.

Entry and exit channels always exclude the current bar:

`entryHigh = highest(high[1], entry length)`

`entryLow = lowest(low[1], entry length)`

`exitHigh = highest(high[1], exit length)`

`exitLow = lowest(low[1], exit length)`

A confirmed close beyond the prior entry channel creates a market-entry
intent only when the matching trend filter qualifies. There is no pyramiding
and no same-calculation reversal.

The close-risk line uses ATR and confirmed closes. For a long position, the
highest observed close is tracked and the line is the greater of its previous
value and `peak close - ATR multiple × ATR`. It therefore never loosens. The
short rule is symmetric and never rises. A channel breach or a confirmed close
through the risk line creates a market-close intent.

EXECUTION MODEL AND COSTS

Orders are not processed on the signal bar’s close. The strategy keeps
TradingView’s normal next-tick behavior, which on historical bars normally
means a fill at the following bar’s open. The declaration includes:

- 0.10% commission per filled order;
- 2 ticks of slippage per market fill;
- 10% of equity order size;
- no pyramiding and no simulated leverage;
- no calculation on every tick or on order fills.

These are generic examples, not estimates for a particular broker or market.
Users must replace them in Properties. The panel cannot detect a manual
Properties override, so it labels them declaration defaults. Simulated fills
do not model liquidity, spread variation, queue position, rejected orders or
market impact.

SAMPLE WINDOWS

The same signal parameters can be viewed as Full history, In-sample or
Out-of-sample. The default split is 2024-01-01 UTC. In-sample ends immediately
before the split; out-of-sample begins at the split. No entry is allowed
outside the selected window, and an open position is closed by a normal delayed
market intent when the window ends.

One visible split does not prove that a user avoided tuning after seeing the
result. The script exposes the boundary; it cannot enforce research behavior.
A visible 100-closed-trade gate is a sample-size warning, not statistical
proof.

CONFIRMED AND STANDARD-CHART BOUNDARIES

New orders require a confirmed bar and `chart.is_standard`. On Heikin Ashi,
Renko, Kagi, Line Break, Range, Point & Figure and other non-standard charts,
the script displays `NON-STANDARD — NO ORDERS` and creates no trades.

The script uses only the current chart symbol and timeframe. It makes no
external requests, uses no lookahead and does not force same-bar-close fills.
Exchange or broker feed corrections can still rebuild historical standard
OHLC after reload.

OUTPUTS

The chart shows fast and slow EMAs, optional prior-bar entry and exit channels,
the active close-risk line, optional sample background and confirmed intent
markers. Compact and Full panels expose state, sample, split, fill model,
declaration costs, closed trades, the 100-trade gate, net result, average closed
trade and maximum drawdown.

Hidden machine-readable plots expose:

- Confirmed entry intent: +1, -1 or 0;
- Confirmed exit intent: +1, -1 or 0;
- Selected sample: 1 or 0;
- OOS flag: 1 or 0.

Order calls contain explicit alert messages, so TradingView order-fill alerts
can identify the simulated action, size, ticker and resulting strategy
position. They are diagnostics, not recommendations.

LIMITATIONS

- Positive net profit is not a design requirement or evidence of robustness.
- Results depend on symbol, feed, timeframe, loaded history, Properties and
  inputs.
- Close-confirmed risk exits can gap on the next simulated fill.
- Commission and slippage defaults are not a complete transaction-cost model.
- One in-sample/out-of-sample split is not walk-forward validation.
- The 100-trade gate does not establish significance or future performance.
- Backtests are simulations and are not trading advice or expected returns.

VALIDATION

The candidate passed 16 deterministic Python fixtures and a 16/16 live Pine
harness. Manual TradingView checks covered BTCUSDT and AAPL on daily and
intraday charts, 187 BTCUSDT 30-minute and 103 AAPL hourly trades, unchanged
parameters across IS/OOS, higher costs, reload parity, realtime confirmation,
daily Bar Replay, zero orders on Heikin Ashi, the order-fill alert dialog,
390 × 844 rendering and Pine Profiler. The profiler observed 32,614 executions
on DJI daily history with 0.6 seconds total runtime.

The validation intentionally retains unfavorable evidence: BTCUSDT 30-minute
Full history returned about -3.70%, AAPL hourly Full history about -2.63%, and
AAPL daily OOS about -1.83%. No parameter was retuned after these observations.

ORIGINALITY AND SOURCE

Category demand was selected from dated popularity metadata. No protected,
invite-only or closed source was accessed, and no compared script’s source was
imported. EMA, ATR, prior-bar channels and sample splitting are standard,
transparent building blocks. The implementation is released under MPL 2.0.

CHANGELOG

v1.0.0

- Initial open-source release candidate.
- Symmetric confirmed-close trend and prior-channel entries.
- Non-loosening ATR close-risk line with delayed market exits.
- Explicit commission, slippage, sample split and standard-chart guard.
- Compact/Full evidence panels, signed intent exports and order-fill messages.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © BarState Labs
//@version=6
strategy("Execution-Aware Trend [BSL]", shorttitle = "BSL Exec Trend", overlay = true,
     initial_capital = 100000, currency = currency.USD,
     default_qty_type = strategy.percent_of_equity, default_qty_value = 10,
     pyramiding = 0, commission_type = strategy.commission.percent,
     commission_value = 0.10, slippage = 2,
     process_orders_on_close = false, calc_on_every_tick = false,
     calc_on_order_fills = false, margin_long = 100, margin_short = 100,
     max_bars_back = 1000)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_TREND = "01 · Define trend"
string GROUP_BREAKOUT = "02 · Trigger breakouts"
string GROUP_RISK = "03 · Control close risk"
string GROUP_SAMPLE = "04 · Choose sample"
string GROUP_DISPLAY = "05 · Display"

int fastLength = input.int(50, "Fast EMA length", minval = 2, maxval = 300, group = GROUP_TREND)
int slowLength = input.int(200, "Slow EMA length", minval = 10, maxval = 600, group = GROUP_TREND)
int slopeLookback = input.int(20, "Slow EMA slope lookback, bars", minval = 1, maxval = 100, group = GROUP_TREND,
     tooltip = "The slow EMA must also rise or fall across this lookback. Equality qualifies neither direction.")
string directionMode = input.string("Both", "Trade direction",
     options = ["Both", "Long only", "Short only"], group = GROUP_TREND)

int entryLength = input.int(20, "Entry channel lookback, bars", minval = 2, maxval = 200, group = GROUP_BREAKOUT,
     tooltip = "A confirmed close must break the highest or lowest value from prior bars. The current bar is always excluded.")
int exitLength = input.int(10, "Exit channel lookback, bars", minval = 2, maxval = 100, group = GROUP_BREAKOUT)

int atrLength = input.int(14, "ATR length", minval = 2, maxval = 100, group = GROUP_RISK)
float atrMultiple = input.float(3.0, "Close-risk distance, ATR", minval = 0.5,
     maxval = 10.0, step = 0.25, group = GROUP_RISK,
     tooltip = "Tracks the most favorable confirmed close and never loosens. Exits remain next-tick market simulations, so gaps are possible.")

string sampleMode = input.string("Full history", "Active sample",
     options = ["Full history", "In-sample", "Out-of-sample"], group = GROUP_SAMPLE,
     tooltip = "Full history opens with the largest available sample. It is a descriptive starting point, not validation. Switch to Out-of-sample without changing signal parameters to challenge the result.")
int sampleStart = input.time(timestamp("01 Jan 2018 00:00 +0000"), "Sample start", group = GROUP_SAMPLE)
int sampleSplit = input.time(timestamp("01 Jan 2024 00:00 +0000"), "In/OOS split", group = GROUP_SAMPLE)
int sampleEnd = input.time(timestamp("01 Jan 2099 00:00 +0000"), "Sample end", group = GROUP_SAMPLE)

bool showChannels = input.bool(true, "Show prior-bar channels", group = GROUP_DISPLAY,
     tooltip = "Shows the levels used by the breakout rules. Entry channels are darker than exit channels.")
bool showSampleBackground = input.bool(true, "Shade out-of-sample bars", group = GROUP_DISPLAY)
string panelDensity = input.string("Compact", "Panel detail",
     options = ["Compact", "Full"], group = GROUP_DISPLAY,
     tooltip = "Compact keeps the chart readable. Full adds the window, signal parameters, current trend/position, active risk and override reminder.")
string panelPositionInput = input.string("Auto", "Panel position", options = ["Auto", "Top right", "Bottom right"],
     group = GROUP_DISPLAY, tooltip = "Auto keeps the panel opposite the latest price within the visible chart range.")

// ─────────────────────────────────────────────────────────────────────────────
// Palette and helpers
// ─────────────────────────────────────────────────────────────────────────────
color COLOR_BG = color.rgb(11, 14, 13)
color COLOR_PANEL = color.rgb(20, 25, 23)
color COLOR_TEXT = color.rgb(242, 239, 232)
color COLOR_MUTED = color.rgb(156, 161, 154)
color COLOR_GREEN = color.rgb(82, 211, 151)
color COLOR_RED = color.rgb(239, 107, 107)
color COLOR_AMBER = color.rgb(235, 184, 87)
color COLOR_BLUE = color.rgb(104, 167, 255)
color COLOR_LINE = color.new(COLOR_MUTED, 70)

f_percent(float value) =>
    na(value) ? "N/A" : str.tostring(value, "#.##") + "%"

f_price(float value) =>
    na(value) ? "N/A" : str.tostring(value, format.mintick)

f_date(int value) =>
    str.format_time(value, "yyyy-MM-dd", "UTC")

f_status(bool valid, bool standard, bool ready, bool active) =>
    not valid ? "CONFIG ERROR" : not standard ? "NON-STANDARD · NO ORDERS" :
     not ready ? "WARMUP" : not active ? "OUTSIDE SAMPLE" : "ACTIVE"

f_status_color(bool valid, bool standard, bool ready, bool active) =>
    not valid or not standard ? COLOR_RED : not ready or not active ? COLOR_AMBER : COLOR_GREEN

// ─────────────────────────────────────────────────────────────────────────────
// Signal and sample contract
// ─────────────────────────────────────────────────────────────────────────────
bool configValid = fastLength < slowLength and exitLength < entryLength and
     sampleStart < sampleSplit and sampleSplit < sampleEnd

float fastEma = ta.ema(close, fastLength)
float slowEma = ta.ema(close, slowLength)
float atr = ta.atr(atrLength)

// The [1] series offset ensures the current bar cannot define its own channel.
float priorEntryHigh = ta.highest(high[1], entryLength)
float priorEntryLow = ta.lowest(low[1], entryLength)
float priorExitHigh = ta.highest(high[1], exitLength)
float priorExitLow = ta.lowest(low[1], exitLength)

bool ready = not na(fastEma) and not na(slowEma[slopeLookback]) and not na(atr) and
     not na(priorEntryHigh) and not na(priorEntryLow) and
     not na(priorExitHigh) and not na(priorExitLow)

bool withinBounds = time >= sampleStart and time <= sampleEnd
bool inSample = withinBounds and time < sampleSplit
bool outOfSample = withinBounds and time >= sampleSplit
bool sampleActive = switch sampleMode
    "Full history" => withinBounds
    "In-sample" => inSample
    => outOfSample

bool trendUp = ready and fastEma > slowEma and slowEma > slowEma[slopeLookback]
bool trendDown = ready and fastEma < slowEma and slowEma < slowEma[slopeLookback]
bool allowLong = directionMode != "Short only"
bool allowShort = directionMode != "Long only"
bool flat = strategy.position_size == 0
bool orderEligible = chart.is_standard and configValid and ready and sampleActive and barstate.isconfirmed

bool longIntent = orderEligible and flat and allowLong and trendUp and close > priorEntryHigh
bool shortIntent = orderEligible and flat and allowShort and trendDown and close < priorEntryLow

if longIntent
    strategy.entry("Long", strategy.long, comment = "LE",
         alert_message = "BSL-003 simulated LONG fill. Verify costs, sample and next-tick execution.")
else if shortIntent
    strategy.entry("Short", strategy.short, comment = "SE",
         alert_message = "BSL-003 simulated SHORT fill. Verify costs, sample and next-tick execution.")

// ─────────────────────────────────────────────────────────────────────────────
// Monotonic close-risk line and exits
// ─────────────────────────────────────────────────────────────────────────────
var float longPeakClose = na
var float shortTroughClose = na
var float longRisk = na
var float shortRisk = na

bool longPosition = strategy.position_size > 0
bool shortPosition = strategy.position_size < 0
bool newLongPosition = longPosition and nz(strategy.position_size[1]) <= 0
bool newShortPosition = shortPosition and nz(strategy.position_size[1]) >= 0
bool newlyFlat = flat and nz(strategy.position_size[1]) != 0

if newLongPosition
    longPeakClose := close
    longRisk := strategy.position_avg_price - atrMultiple * atr
    shortTroughClose := na
    shortRisk := na
else if longPosition
    longPeakClose := math.max(nz(longPeakClose, close), close)
    float candidateLongRisk = longPeakClose - atrMultiple * atr
    longRisk := math.max(nz(longRisk, candidateLongRisk), candidateLongRisk)

if newShortPosition
    shortTroughClose := close
    shortRisk := strategy.position_avg_price + atrMultiple * atr
    longPeakClose := na
    longRisk := na
else if shortPosition
    shortTroughClose := math.min(nz(shortTroughClose, close), close)
    float candidateShortRisk = shortTroughClose + atrMultiple * atr
    shortRisk := math.min(nz(shortRisk, candidateShortRisk), candidateShortRisk)

bool boundaryExit = barstate.isconfirmed and not flat and
     (not chart.is_standard or not configValid or not sampleActive)
bool longRiskExit = barstate.isconfirmed and longPosition and not na(longRisk) and close <= longRisk
bool shortRiskExit = barstate.isconfirmed and shortPosition and not na(shortRisk) and close >= shortRisk
bool longChannelExit = barstate.isconfirmed and longPosition and close < priorExitLow
bool shortChannelExit = barstate.isconfirmed and shortPosition and close > priorExitHigh

bool longExitIntent = longPosition and (boundaryExit or longRiskExit or longChannelExit)
bool shortExitIntent = shortPosition and (boundaryExit or shortRiskExit or shortChannelExit)

if boundaryExit
    strategy.close_all(comment = "BND",
         alert_message = "BSL-003 simulated boundary close. The fill retains next-tick delay.")
else if longExitIntent
    string longExitReason = longRiskExit ? "LX-R" : "LX-C"
    strategy.close("Long", comment = longExitReason,
         alert_message = "BSL-003 simulated LONG close. The fill retains next-tick delay.")
else if shortExitIntent
    string shortExitReason = shortRiskExit ? "SX-R" : "SX-C"
    strategy.close("Short", comment = shortExitReason,
         alert_message = "BSL-003 simulated SHORT close. The fill retains next-tick delay.")

if newlyFlat
    longPeakClose := na
    shortTroughClose := na
    longRisk := na
    shortRisk := na

// ─────────────────────────────────────────────────────────────────────────────
// Visual and machine-readable outputs
// ─────────────────────────────────────────────────────────────────────────────
plot(fastEma, "Fast EMA", color = COLOR_GREEN, linewidth = 2)
plot(slowEma, "Slow EMA", color = COLOR_AMBER, linewidth = 2)
plot(showChannels ? priorEntryHigh : na, "Prior entry high", color = color.new(COLOR_GREEN, 62), style = plot.style_stepline)
plot(showChannels ? priorEntryLow : na, "Prior entry low", color = color.new(COLOR_RED, 62), style = plot.style_stepline)
plot(showChannels ? priorExitHigh : na, "Prior exit high", color = color.new(COLOR_MUTED, 82), style = plot.style_stepline)
plot(showChannels ? priorExitLow : na, "Prior exit low", color = color.new(COLOR_MUTED, 82), style = plot.style_stepline)
plot(longPosition ? longRisk : shortPosition ? shortRisk : na, "Active close-risk line",
     color = COLOR_BLUE, linewidth = 2, style = plot.style_stepline)

plotshape(longIntent, "Long entry intent", shape.triangleup, location.belowbar,
     COLOR_GREEN, size = size.tiny, text = "L")
plotshape(shortIntent, "Short entry intent", shape.triangledown, location.abovebar,
     COLOR_RED, size = size.tiny, text = "S")
plotshape(longExitIntent, "Long exit intent", shape.xcross, location.abovebar,
     COLOR_AMBER, size = size.tiny, text = "X")
plotshape(shortExitIntent, "Short exit intent", shape.xcross, location.belowbar,
     COLOR_AMBER, size = size.tiny, text = "X")

plot(longIntent ? 1 : shortIntent ? -1 : 0, "Confirmed entry intent", display = display.none)
plot(longExitIntent ? 1 : shortExitIntent ? -1 : 0, "Confirmed exit intent", display = display.none)
plot(sampleActive ? 1 : 0, "Selected sample", display = display.none)
plot(outOfSample ? 1 : 0, "OOS flag", display = display.none)

color sampleBackground = showSampleBackground and outOfSample ? color.new(COLOR_BLUE, 93) : na
bgcolor(not chart.is_standard ? color.new(COLOR_RED, 84) : sampleBackground,
     title = "Sample / chart-type background")

// ─────────────────────────────────────────────────────────────────────────────
// Method panel
// ─────────────────────────────────────────────────────────────────────────────
int closedTrades = strategy.closedtrades
bool samplePass = closedTrades >= 100
string stateName = f_status(configValid, chart.is_standard, ready, sampleActive)
color stateColor = f_status_color(configValid, chart.is_standard, ready, sampleActive)
string trendName = trendUp ? "UP" : trendDown ? "DOWN" : "NEUTRAL"
string positionName = longPosition ? "LONG" : shortPosition ? "SHORT" : "FLAT"
float activeRisk = longPosition ? longRisk : shortPosition ? shortRisk : na

bool inVisibleWindow = time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
var float visibleWindowHigh = na
var float visibleWindowLow = na
var float visibleWindowRightClose = na
if inVisibleWindow
    visibleWindowHigh := na(visibleWindowHigh) ? high : math.max(visibleWindowHigh, high)
    visibleWindowLow := na(visibleWindowLow) ? low : math.min(visibleWindowLow, low)
    visibleWindowRightClose := close

float visibleWindowMid = not na(visibleWindowHigh) and not na(visibleWindowLow) ?
     (visibleWindowHigh + visibleWindowLow) / 2.0 : na
string automaticPanelPosition = not na(visibleWindowMid) and visibleWindowRightClose > visibleWindowMid ?
     position.bottom_right : position.top_right
string resolvedPanelPosition = panelPositionInput == "Top right" ? position.top_right :
     panelPositionInput == "Bottom right" ? position.bottom_right : automaticPanelPosition

int panelRows = panelDensity == "Full" ? 16 : 10
var table panel = table.new(position.top_right, 2, panelRows, bgcolor = COLOR_PANEL,
     frame_color = COLOR_LINE, frame_width = 1, border_color = COLOR_LINE, border_width = 1)

if barstate.isfirst
    table.merge_cells(panel, 0, 0, 1, 0)
    table.merge_cells(panel, 0, panelRows - 1, 1, panelRows - 1)

// Strategies with calc_on_every_tick = false do not execute on an open realtime
// bar. Populate the panel on the last confirmed historical bar as well so the
// publication chart never shows an uninitialized table while BTC trades live.
if barstate.islastconfirmedhistory or barstate.islast
    table.set_position(panel, resolvedPanelPosition)
    table.cell(panel, 0, 0, "BSL / EXECUTION-AWARE TREND",
         text_color = COLOR_TEXT, bgcolor = COLOR_BG, text_halign = text.align_left)
    table.cell(panel, 0, 1, "STATUS", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 1, stateName, text_color = stateColor, text_halign = text.align_right)
    table.cell(panel, 0, 2, "SAMPLE", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 2, sampleMode, text_color = COLOR_TEXT, text_halign = text.align_right)
    table.cell(panel, 0, 3, "OOS SPLIT", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 3, f_date(sampleSplit), text_color = COLOR_TEXT, text_halign = text.align_right)
    table.cell(panel, 0, 4, "FILL MODEL", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 4, "NEXT TICK / NEXT BAR", text_color = COLOR_AMBER, text_halign = text.align_right)
    table.cell(panel, 0, 5, "DECL. COSTS", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 5, "0.10% + 2 TICKS", text_color = COLOR_AMBER, text_halign = text.align_right)
    table.cell(panel, 0, 6, "CLOSED TRADES", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 6, str.tostring(closedTrades) + " · " + (samplePass ? "≥100 PASS" : "<100 WARN"),
         text_color = samplePass ? COLOR_GREEN : COLOR_AMBER, text_halign = text.align_right)
    table.cell(panel, 0, 7, "NET / AVG", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 7, f_percent(strategy.netprofit_percent) + " / " + f_percent(strategy.avg_trade_percent),
         text_color = strategy.netprofit >= 0 ? COLOR_GREEN : COLOR_RED, text_halign = text.align_right)
    table.cell(panel, 0, 8, "MAX DRAWDOWN", text_color = COLOR_MUTED, text_halign = text.align_left)
    table.cell(panel, 1, 8, f_percent(strategy.max_drawdown_percent), text_color = COLOR_RED,
         text_halign = text.align_right)

    bool fullPanel = panelDensity == "Full"
    if fullPanel
        table.cell(panel, 0, 9, "WINDOW", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 9, f_date(sampleStart) + " → " + f_date(sampleEnd),
             text_color = COLOR_TEXT, text_halign = text.align_right)
        table.cell(panel, 0, 10, "EMA / SLOPE", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 10, str.tostring(fastLength) + "/" + str.tostring(slowLength) +
             " / " + str.tostring(slopeLookback), text_color = COLOR_TEXT, text_halign = text.align_right)
        table.cell(panel, 0, 11, "CHANNELS", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 11, str.tostring(entryLength) + " / " + str.tostring(exitLength),
             text_color = COLOR_TEXT, text_halign = text.align_right)
        table.cell(panel, 0, 12, "TREND / POSITION", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 12, trendName + " / " + positionName,
             text_color = COLOR_TEXT, text_halign = text.align_right)
        table.cell(panel, 0, 13, "ACTIVE RISK", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 13, f_price(activeRisk), text_color = COLOR_BLUE, text_halign = text.align_right)
        table.cell(panel, 0, 14, "OVERRIDES", text_color = COLOR_MUTED, text_halign = text.align_left)
        table.cell(panel, 1, 14, "CHECK PROPERTIES", text_color = COLOR_AMBER,
             text_halign = text.align_right)
    int footerRow = fullPanel ? 15 : 9
    table.cell(panel, 0, footerRow, "Simulation ≠ live execution.", text_color = COLOR_MUTED,
         bgcolor = COLOR_BG, text_halign = text.align_left)
````
