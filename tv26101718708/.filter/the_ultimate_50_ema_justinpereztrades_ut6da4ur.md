# The Ultimate 50 EMA @JustinPerezTrades

- url: https://www.tradingview.com/script/UT6DA4ur-The-Ultimate-50-EMA-JustinPerezTrades/
- type: indicator
- pine_id: PUB;b6ba85be3a754a7caeb2c9a9882d7732
- version: 1.0

## Description

Ultimate Day Trader — NQ/MNQ Multi-Timeframe 50 EMA Stack

A precision pullback/breakout indicator for NQ and MNQ that only signals when five timeframes of 50 EMAs are stacked in trend order.

Overview

This indicator looks for a specific structural setup on NQ and MNQ futures: a short-term pullback (or push) away from the 1-minute 50 EMA that occurs while the 50 EMA is climbing or falling in a clean, ordered stack across five timeframes (1m, 5m, 10m, 15m, 30m). The idea is to only trade pullbacks that are happening inside a confirmed multi-timeframe trend, rather than reacting to the 1-minute chart in isolation.

It's a signal/alert tool — it plots the EMA stack, marks entries and the exit target on the chart, and can fire alerts. It does not place trades for you.

How it works

Long setup — all of the following must be true at once:

Price is 50–100 points below the 1-minute 50 EMA (a pullback into value, not a full trend break)
5-minute 50 EMA is above the 1-minute 50 EMA
10-minute 50 EMA is above the 5-minute 50 EMA
15-minute 50 EMA is above the 10-minute 50 EMA
30-minute 50 EMA is above the 15-minute 50 EMA

When all five conditions align, the script marks a long entry. The exit target is the 30-minute 50 EMA — the trade is considered closed once price trades up to reach it.

Short setup is the mirror image: price 50–100 points above the 1-minute 50 EMA, with each higher timeframe's 50 EMA stacked below the one before it (5m < 1m, 10m < 5m, 15m < 10m, 30m < 15m). Exit target is the same 30-minute 50 EMA, reached from above.

Entries are edge-triggered — you get one signal per fresh setup, not a repeated marker on every bar the condition happens to remain true.

How to use it
Apply the indicator to a 1-minute chart on NQ or MNQ (front-month continuous contract or a dated expiry). The script checks both conditions and shows a warning label if either isn't met.
Watch the on-chart status table for a live read of: chart/symbol validity, current position state (flat / in long / in short), whether the MTF stack is bullish, bearish, or unaligned, the price's distance from the 1m EMA, and the current exit target level.
Green up-triangles mark long entries, red down-triangles mark short entries; a background tint confirms when the broader EMA stack is aligned even before price reaches the entry zone.
Right-click the chart → Add Alert to get notified on Long Entry, Short Entry, Long Exit, or Short Exit independently.
Inputs
EMA Length — default 50, applies to all five timeframes
Min / Max entry distance from the 1m EMA (points) — default 50 / 100, tuned for NQ/MNQ's typical point range
Restrict signals to NQ/MNQ only — on by default; disable to experiment with the same logic on other instruments
Higher timeframe overrides — 5m/10m/15m/30m are adjustable if you want to test alternate spacing
Display toggles for the EMA plots, stack-aligned background highlight, and the status table
Notes

This script is built BY @JustinPerezTrades specifically around NQ and MNQ's point behavior — the 50–100 point entry zone will not translate directly to instruments with different average ranges. It is a rules-based signal tool, not a guaranteed-profit system, and past alignment of these conditions does not predict future results. Backtest and paper-trade before using it with real capital, and use it alongside your own risk management.

## Source Code

````pine
// ============================================================================
//  Ultimate Day Trader — Multi-Timeframe 50 EMA Stack
//  Tuned for NQ / MNQ (Nasdaq-100 futures) — point-based thresholds only
//  make sense on an instrument that trades in NQ-sized point ranges.
// ----------------------------------------------------------------------------
//  STRATEGY LOGIC (as specified):
//
//  LONG setup:
//    1) Price is 50–100 points BELOW the 1-minute 50 EMA (pullback into value)
//    2) 5-minute  50 EMA > 1-minute  50 EMA
//    3) 10-minute 50 EMA > 5-minute  50 EMA
//    4) 15-minute 50 EMA > 10-minute 50 EMA
//    5) 30-minute 50 EMA > 15-minute 50 EMA
//    -> Exit target: 30-minute 50 EMA
//
//  SHORT setup is the mirror image:
//    1) Price is 50–100 points ABOVE the 1-minute 50 EMA
//    2) 5m EMA < 1m EMA < ... down through 10m < 15m < 30m (each lower EMA
//       is BELOW the next one up)
//    -> Exit target: 30-minute 50 EMA
//
//  IMPORTANT: This script must be applied to a 1-MINUTE chart, on NQ or MNQ
//  (front-month continuous contract e.g. NQ1! / MNQ1!, or a dated contract
//  like NQZ2026). All higher timeframe EMAs are pulled in with
//  request.security(). A warning label appears if the chart timeframe isn't
//  1 minute or the symbol isn't NQ/MNQ (the symbol check can be turned off).
//
//  This is a signal/alert indicator, not an auto-trading strategy — it plots
//  entries, exit targets, and fires alerts; you (or your broker automation)
//  pull the trigger. Nothing here is financial advice — backtest and
//  paper-trade before risking real capital.
// ============================================================================

//@version=6
indicator("Ultimate Day Trader — NQ/MNQ MTF 50 EMA Stack", shorttitle = "The Ultimate 50 EMA (NQ/MNQ)", overlay = true, max_labels_count = 300, max_lines_count = 300)

// ---------------------------------------------------------------------------
// INPUTS
// ---------------------------------------------------------------------------
grpCore = "Core Settings"
emaLen        = input.int(50, "EMA Length", minval = 1, group = grpCore)
minPts        = input.float(50, "Min entry distance from 1m EMA (points)", minval = 0, step = 1, group = grpCore, tooltip = "NQ/MNQ defaults: 50-100 points. Tick size is 0.25, so 50 points = 200 ticks.")
maxPts        = input.float(100, "Max entry distance from 1m EMA (points)", minval = 0, step = 1, group = grpCore)
restrictSymbol = input.bool(true, "Restrict signals to NQ/MNQ symbols only", group = grpCore, tooltip = "When on, entries only fire if the chart's symbol root is NQ or MNQ (any expiry / continuous contract). Turn off to test the same logic on other instruments.")

grpTf = "Higher Timeframes"
tf5  = input.timeframe("5",  "Timeframe 2 (default 5m)",  group = grpTf)
tf10 = input.timeframe("10", "Timeframe 3 (default 10m)", group = grpTf)
tf15 = input.timeframe("15", "Timeframe 4 (default 15m)", group = grpTf)
tf30 = input.timeframe("30", "Timeframe 5 / Exit target (default 30m)", group = grpTf)

grpDisp = "Display"
showEmas       = input.bool(true, "Plot all EMAs", group = grpDisp)
showStackBg    = input.bool(true, "Highlight background when MTF stack is aligned", group = grpDisp)
showTable      = input.bool(true, "Show status table", group = grpDisp)
tablePos       = input.string("Top Right", "Table position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpDisp)

grpAlert = "Alerts"
alertOnEntry = input.bool(true, "Alert on entry signal", group = grpAlert)
alertOnExit  = input.bool(true, "Alert on exit-target touch", group = grpAlert)

// ---------------------------------------------------------------------------
// SETUP GUARD — this strategy is defined relative to a 1-minute NQ/MNQ chart
// ---------------------------------------------------------------------------
isOneMinChart = timeframe.period == "1"
isNqFamily    = syminfo.root == "NQ" or syminfo.root == "MNQ"
symbolOk      = not restrictSymbol or isNqFamily

var label warnLabel = na
tfIssue     = not isOneMinChart
symbolIssue = restrictSymbol and not isNqFamily
hasIssue    = tfIssue or symbolIssue

if hasIssue and barstate.islast
    warnTxt = "⚠ "
    warnTxt := tfIssue ? warnTxt + "Apply to a 1-MINUTE chart. " : warnTxt
    warnTxt := symbolIssue ? warnTxt + "Tuned for NQ/MNQ — current symbol root is " + syminfo.root + "." : warnTxt
    if na(warnLabel)
        warnLabel := label.new(bar_index, high, warnTxt,
             style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.normal)
    else
        label.set_xy(warnLabel, bar_index, high)
        label.set_text(warnLabel, warnTxt)
else if not hasIssue and not na(warnLabel)
    label.delete(warnLabel)
    warnLabel := na

// ---------------------------------------------------------------------------
// EMAs — 1m is native to the chart (must be 1m), higher TFs via request.security
// ---------------------------------------------------------------------------
ema1  = ta.ema(close, emaLen)
ema5  = request.security(syminfo.tickerid, tf5,  ta.ema(close, emaLen), lookahead = barmerge.lookahead_off)
ema10 = request.security(syminfo.tickerid, tf10, ta.ema(close, emaLen), lookahead = barmerge.lookahead_off)
ema15 = request.security(syminfo.tickerid, tf15, ta.ema(close, emaLen), lookahead = barmerge.lookahead_off)
ema30 = request.security(syminfo.tickerid, tf30, ta.ema(close, emaLen), lookahead = barmerge.lookahead_off)

// Note on repaint: higher-timeframe EMA values above will move intrabar as
// the forming 5m/10m/15m/30m candle updates — that is expected/desired for
// a live signal indicator (you want the freshest stack read). Once each
// higher-TF bar closes, its EMA value is locked in like any other indicator.

// ---------------------------------------------------------------------------
// CORE CONDITIONS
// ---------------------------------------------------------------------------
distFromEma1 = ema1 - close   // positive => price below 1m EMA (long side) / negative => price above (short side)

longZone  = distFromEma1 >= minPts and distFromEma1 <= maxPts
shortZone = (-distFromEma1) >= minPts and (-distFromEma1) <= maxPts

bullStack = ema5 > ema1 and ema10 > ema5 and ema15 > ema10 and ema30 > ema15
bearStack = ema5 < ema1 and ema10 < ema5 and ema15 < ema10 and ema30 < ema15

longSetup  = isOneMinChart and symbolOk and longZone  and bullStack
shortSetup = isOneMinChart and symbolOk and shortZone and bearStack

// ---------------------------------------------------------------------------
// TRADE STATE — edge-triggered entries, exit when price reaches the 30m EMA
// ---------------------------------------------------------------------------
var bool inLong  = false
var bool inShort = false
var float exitTarget = na

freshLong  = longSetup  and not inLong  and not inShort
freshShort = shortSetup and not inShort and not inLong

if freshLong
    inLong := true
    inShort := false
    exitTarget := ema30
if freshShort
    inShort := true
    inLong := false
    exitTarget := ema30

longExit  = inLong  and ta.crossover(close, ema30)
shortExit = inShort and ta.crossunder(close, ema30)

if longExit
    inLong := false
    exitTarget := na
if shortExit
    inShort := false
    exitTarget := na

// ---------------------------------------------------------------------------
// PLOTS
// ---------------------------------------------------------------------------
plot(showEmas ? ema1  : na, "1m 50 EMA",  color = color.new(color.gray, 0),      linewidth = 1)
plot(showEmas ? ema5  : na, "5m 50 EMA",  color = color.new(color.blue, 0),      linewidth = 1)
plot(showEmas ? ema10 : na, "10m 50 EMA", color = color.new(color.orange, 0),    linewidth = 1)
plot(showEmas ? ema15 : na, "15m 50 EMA", color = color.new(color.purple, 0),    linewidth = 1)
plot(showEmas ? ema30 : na, "30m 50 EMA — Exit Target", color = color.new(color.fuchsia, 0), linewidth = 2)

bgcolor(showStackBg and bullStack ? color.new(color.green, 92) : na, title = "Bullish stack aligned")
bgcolor(showStackBg and bearStack ? color.new(color.red, 92)   : na, title = "Bearish stack aligned")

plotshape(freshLong,  title = "Long Entry",  style = shape.triangleup,   location = location.belowbar, color = color.new(color.lime, 0),   size = size.small)
plotshape(freshShort, title = "Short Entry", style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0),    size = size.small)
plotshape(longExit,   title = "Long Exit (30m EMA reached)",  style = shape.xcross, location = location.abovebar, color = color.new(color.lime, 0), size = size.tiny)
plotshape(shortExit,  title = "Short Exit (30m EMA reached)", style = shape.xcross, location = location.belowbar, color = color.new(color.red, 0),  size = size.tiny)

if freshLong
    label.new(bar_index, low, "LONG\n" + str.tostring(math.round(distFromEma1)) + " pts", style = label.style_label_up, color = color.new(color.lime, 0), textcolor = color.black, size = size.small)
if freshShort
    label.new(bar_index, high, "SHORT\n" + str.tostring(math.round(-distFromEma1)) + " pts", style = label.style_label_down, color = color.new(color.red, 0), textcolor = color.white, size = size.small)

// ---------------------------------------------------------------------------
// STATUS TABLE
// ---------------------------------------------------------------------------
tablePosition = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table statusTable = showTable ? table.new(tablePosition, 2, 8, border_width = 1) : na

if showTable and barstate.islast
    stateText  = inLong ? "IN LONG" : inShort ? "IN SHORT" : "FLAT"
    stateColor = inLong ? color.new(color.lime, 70) : inShort ? color.new(color.red, 70) : color.new(color.gray, 80)
    stackText  = bullStack ? "BULLISH ✓" : bearStack ? "BEARISH ✓" : "not aligned"
    stackColor = bullStack ? color.new(color.lime, 70) : bearStack ? color.new(color.red, 70) : color.new(color.gray, 85)
    zoneText   = longZone ? "LONG ZONE" : shortZone ? "SHORT ZONE" : "out of zone"

    table.cell(statusTable, 0, 0, "Chart TF / Symbol", text_color = color.white, bgcolor = color.new(#222222, 0))
    table.cell(statusTable, 1, 0, (isOneMinChart ? "1m ✓" : "NOT 1m ✗") + "  /  " + (symbolOk ? syminfo.root + " ✓" : syminfo.root + " ✗"), text_color = (isOneMinChart and symbolOk) ? color.lime : color.red, bgcolor = color.new(#222222, 0))

    table.cell(statusTable, 0, 1, "Position", text_color = color.white, bgcolor = color.new(#222222, 0))
    table.cell(statusTable, 1, 1, stateText, text_color = color.white, bgcolor = stateColor)

    table.cell(statusTable, 0, 2, "MTF Stack", text_color = color.white, bgcolor = color.new(#222222, 0))
    table.cell(statusTable, 1, 2, stackText, text_color = color.white, bgcolor = stackColor)

    table.cell(statusTable, 0, 3, "Price vs 1m EMA", text_color = color.white, bgcolor = color.new(#222222, 0))
    table.cell(statusTable, 1, 3, zoneText + " (" + str.tostring(math.round(distFromEma1)) + " pts)", text_color = color.white, bgcolor = color.new(#222222, 0))

    table.cell(statusTable, 0, 4, "1m / 5m EMA", text_color = color.white, bgcolor = color.new(#222222, 0))
    table.cell(statusTable, 1, 4, str.tostring(ema1, format.mintick) + " / " + str.tostring(ema5, format.mintick), text_color = color.white, bgcolor = color.new(#222222, 0))

    table.cell(statusTable, 0, 5, "10m / 15m EMA", text_color = color.white, bgcolor = color.new(#222222, 0))
    table.cell(statusTable, 1, 5, str.tostring(ema10, format.mintick) + " / " + str.tostring(ema15, format.mintick), text_color = color.white, bgcolor = color.new(#222222, 0))

    table.cell(statusTable, 0, 6, "30m EMA (Exit)", text_color = color.white, bgcolor = color.new(#222222, 0))
    table.cell(statusTable, 1, 6, str.tostring(ema30, format.mintick), text_color = color.white, bgcolor = color.new(#222222, 0))

    table.cell(statusTable, 0, 7, "Exit Target", text_color = color.white, bgcolor = color.new(#222222, 0))
    table.cell(statusTable, 1, 7, na(exitTarget) ? "—" : str.tostring(exitTarget, format.mintick), text_color = color.white, bgcolor = color.new(#222222, 0))

// ---------------------------------------------------------------------------
// ALERTS
// ---------------------------------------------------------------------------
alertcondition(freshLong,  title = "UDT Long Entry",  message = "Ultimate Day Trader (NQ/MNQ): LONG entry — price pulled back into the 50-100pt zone below the 1m 50EMA with a bullish MTF EMA stack (5m>1m, 10m>5m, 15m>10m, 30m>15m). Target: 30m 50EMA.")
alertcondition(freshShort, title = "UDT Short Entry", message = "Ultimate Day Trader (NQ/MNQ): SHORT entry — price pushed into the 50-100pt zone above the 1m 50EMA with a bearish MTF EMA stack (5m<1m, 10m<5m, 15m<10m, 30m<15m). Target: 30m 50EMA.")
alertcondition(longExit,  title = "UDT Long Exit",  message = "Ultimate Day Trader (NQ/MNQ): LONG exit — price reached the 30m 50EMA target.")
alertcondition(shortExit, title = "UDT Short Exit", message = "Ultimate Day Trader (NQ/MNQ): SHORT exit — price reached the 30m 50EMA target.")

if alertOnEntry and (freshLong or freshShort)
    alert(freshLong ? "UDT Long Entry" : "UDT Short Entry", alert.freq_once_per_bar)
if alertOnExit and (longExit or shortExit)
    alert(longExit ? "UDT Long Exit" : "UDT Short Exit", alert.freq_once_per_bar)
````
