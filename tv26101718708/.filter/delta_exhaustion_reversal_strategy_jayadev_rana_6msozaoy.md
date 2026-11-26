# Delta Exhaustion Reversal Strategy [Jayadev Rana]

- url: https://www.tradingview.com/script/6MsOzaoy-Delta-Exhaustion-Reversal-Strategy-Jayadev-Rana/
- type: strategy
- pine_id: PUB;b6967adb29374529868efd2b48a5852e
- version: 1.0

## Description

WHAT IT IS

Delta Exhaustion Reversal Strategy looks for the moment a push into a new extreme runs out of aggressive participation. It estimates the volume delta of every chart bar from lower-timeframe data, accumulates it into a cumulative volume delta (CVD), and trades against a fresh extreme only when CVD fails to confirm it and the bar itself shows effort without result. Entries wait for a confirmation close. Exits combine a structure stop, an R-multiple target, a delta-reclaim exit and a time stop.

HOW IT WORKS

1. Intrabar delta. For each chart bar the script requests the lower-timeframe bars inside it (automatic choice: 1 minute for charts up to 5 minutes, 5 minutes up to 1 hour, 15 minutes up to 4 hours, 60 minutes above; or set manually) and sums up-bar volume minus down-bar volume. Where no intrabar data exists (older history) the bar's own direction and volume are used as a proxy, and the status table says which source is active. CVD is the running sum of bar delta.

2. Exhaustion bar. A bearish exhaustion needs all of the following on the same bar: the high is the highest high of the lookback window; CVD is below its own highest value of the previous window (price made a new high, buying pressure did not); the bar delta is positive while the close sits in the lower part of the bar's range (buyers were aggressive but could not hold the gains); and ATR(14) ranks above a minimum percentile so dead markets are skipped. The bullish exhaustion is the mirror image.

3. Confirmation. The setup stays pending for a few bars. A short is taken only when a later bar closes below the midpoint of the exhaustion bar; a long only when a later bar closes above it. If price trades beyond the exhaustion extreme while the setup is pending, the setup is cancelled.

4. Risk and exits. The stop is placed beyond the exhaustion bar's extreme plus an ATR buffer. The target is a fixed R multiple of that risk. Position size is computed from the stop distance and the risk-per-trade percentage of equity, capped at half of equity notional so no leverage is used. Two additional exits protect the trade: a delta-reclaim exit closes a losing position once delta has run against it for a set number of consecutive bars (the other side has taken control again), and a time stop closes anything that has not resolved within the maximum holding period.

ON THE CHART

Diamonds and coloured bars mark exhaustion bars, with an optional label showing the bar delta and CVD. BUY and SELL labels mark entries, a cross marks every exit, and the active stop and target are drawn while a position is open. The status table reports the delta source, current delta and CVD, ATR percentile, pending setup, open position, stop and target, adverse-delta count and the closed-trade count. Data-window plots expose bar delta, CVD and the ATR percentile.

STRATEGY PROPERTIES USED

Initial capital 10,000. Commission 0.05% per side. Slippage 2 ticks. Orders are filled on the next bar open after the signal bar closes. No pyramiding. Position size from risk per trade (default 1% of equity) with a notional cap of 50% of equity. These are defaults; adjust them to the instrument and account you trade.

INPUTS

Delta engine: intrabar timeframe, extreme and divergence lookback, effort-failure close position, minimum ATR percentile, confirmation window.
Risk: risk per trade, stop buffer, target R multiple, delta-reclaim bars, time stop, long and short switches.
Display: CVD labels, status table.

ALERTS

The strategy calls alert() on long entry, short entry, position close and on every exhaustion bar. Create an alert on the strategy and choose the alert() events.

INTENDED USE

Liquid instruments with real volume (futures, large-cap stocks, major crypto pairs) on 5 minute to 4 hour charts. Volume delta from lower-timeframe bars is an estimate, not true bid-ask data, and on symbols without volume the delta is meaningless.

LIMITATIONS

TradingView serves a limited amount of intrabar history, so the delta estimate is only available on the most recent part of the chart; before that the strategy runs on the bar proxy. The exhaustion conditions are strict, so trade frequency is low. Results depend heavily on the symbol, timeframe and the lower timeframe chosen. Backtest fills, commission and slippage are approximations of live trading.

This script is published for study and research. It is not financial advice and past performance does not guarantee future results.

## Source Code

````pine
//@version=6
// ============================================================================
//  Delta Exhaustion Reversal Strategy [Jayadev Rana]
//  Intrabar volume delta (lower-timeframe up-volume minus down-volume) is
//  accumulated into a rolling CVD. A reversal setup needs three things on the
//  same bar: price at a fresh N-bar extreme, CVD failing to confirm that
//  extreme (divergence) and "effort without result" (aggressive delta but a
//  close in the wrong part of the bar). The trade is only taken after a
//  confirmation close through the exhaustion bar midpoint. Exits: ATR-buffered
//  structure stop, R-multiple target, delta-reclaim exit and a time stop.
//  Position size is derived from the stop distance and a risk % of equity.
// ============================================================================
strategy("Delta Exhaustion Reversal Strategy [Jayadev Rana]", shorttitle = "DERS", overlay = true, initial_capital = 10000, default_qty_type = strategy.fixed, default_qty_value = 1, commission_type = strategy.commission.percent, commission_value = 0.05, slippage = 2, pyramiding = 0, margin_long = 100, margin_short = 100, calc_on_every_tick = false, process_orders_on_close = false, max_labels_count = 200)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gD = "Delta engine"
ltfIn   = input.string("Auto", "Intrabar timeframe", options = ["Auto", "1", "5", "15", "60"], group = gD, tooltip = "Lower timeframe used to estimate the bar delta. Auto picks 1m for charts up to 5m, 5m up to 1h, 15m up to 4h and 60m above. The intrabar history TradingView serves is limited, so the first part of the chart has no delta.")
cvdLen  = input.int(20, "Extreme / divergence lookback", minval = 5, maxval = 200, group = gD, tooltip = "Price must print the highest high (lowest low) of this many bars while CVD stays below (above) its own prior extreme.")
effort  = input.float(0.40, "Effort-failure close position", minval = 0.1, maxval = 0.5, step = 0.05, group = gD, tooltip = "For a bearish exhaustion the delta must be positive while the close sits in the bottom part of the bar: (close-low)/(high-low) below this value. Mirrored for bullish.")
minAtrP = input.float(25, "Minimum ATR percentile", minval = 0, maxval = 90, step = 5, group = gD, tooltip = "No setups when ATR(14) ranks below this percentile of the last 200 bars.")
waitBars = input.int(3, "Confirmation window (bars)", minval = 1, maxval = 10, group = gD)

gR = "Risk"
riskPct = input.float(1.0, "Risk per trade (% of equity)", minval = 0.1, maxval = 5, step = 0.1, group = gR)
stopBuf = input.float(0.5, "Stop buffer beyond exhaustion bar (ATR x)", minval = 0, maxval = 3, step = 0.1, group = gR)
tgtR    = input.float(2.0, "Target (R multiple)", minval = 0.5, maxval = 10, step = 0.5, group = gR)
reclaim = input.int(3, "Delta reclaim exit (consecutive adverse delta bars)", minval = 1, maxval = 10, group = gR, tooltip = "If delta turns against the position for this many consecutive bars while the trade is under water, the position is closed.")
timeStop = input.int(30, "Time stop (bars)", minval = 5, maxval = 500, group = gR)
allowL  = input.bool(true, "Allow longs", group = gR)
allowS  = input.bool(true, "Allow shorts", group = gR)

gV = "Display"
showCvd = input.bool(true, "CVD label on exhaustion bars", group = gV)
showTbl = input.bool(true, "Status table", group = gV)

// ───────────────────────────── 2. Intrabar delta ─────────────────────────────
chartSec = timeframe.in_seconds(timeframe.period)
autoTf   = chartSec <= 300 ? "1" : chartSec <= 3600 ? "5" : chartSec <= 14400 ? "15" : "60"
wantTf   = ltfIn == "Auto" ? autoTf : ltfIn
ltf      = timeframe.in_seconds(wantTf) < chartSec ? wantTf : timeframe.period
dArr     = request.security_lower_tf(syminfo.tickerid, ltf, close > open ? volume : close < open ? -volume : 0.0)
hasIntra = array.size(dArr) > 0
delta    = hasIntra ? array.sum(dArr) : (close > open ? volume : close < open ? -volume : 0.0)
cvd      = ta.cum(delta)
atr      = ta.atr(14)
atrP     = ta.percentrank(atr, 200)
rng      = high - low
cpos     = rng > 0 ? (close - low) / rng : 0.5

hiN      = ta.highest(high, cvdLen)
loN      = ta.lowest(low, cvdLen)
cvdHiPrev = ta.highest(cvd, cvdLen)[1]
cvdLoPrev = ta.lowest(cvd, cvdLen)[1]

bearDiv  = high >= hiN and cvd < cvdHiPrev
bullDiv  = low <= loN and cvd > cvdLoPrev
bearEff  = delta > 0 and cpos < effort
bullEff  = delta < 0 and cpos > 1 - effort
volOk    = atrP >= minAtrP
exhBear  = bearDiv and bearEff and volOk
exhBull  = bullDiv and bullEff and volOk

// ───────────────────────────── 3. Pending setup + confirmation ─────────────────────────────
var int   pendDir  = 0
var int   pendBar  = 0
var float pendHi   = na
var float pendLo   = na
var float pendMid  = na
if exhBear
    pendDir := -1
    pendBar := bar_index
    pendHi  := high
    pendLo  := low
    pendMid := (high + low) / 2
else if exhBull
    pendDir := 1
    pendBar := bar_index
    pendHi  := high
    pendLo  := low
    pendMid := (high + low) / 2
expired = pendDir != 0 and bar_index - pendBar > waitBars
if expired
    pendDir := 0
confShort = pendDir == -1 and bar_index > pendBar and close < pendMid and allowS
confLong  = pendDir == 1 and bar_index > pendBar and close > pendMid and allowL
// an opposite exhaustion while pending cancels the first setup
if pendDir == -1 and high > pendHi
    pendDir := 0
if pendDir == 1 and low < pendLo
    pendDir := 0

// ───────────────────────────── 4. Orders ─────────────────────────────
var float stopPx = na
var float tgtPx  = na
var float riskPx = na
var int   entryBar = 0
var int   advCount = 0
flat = strategy.position_size == 0

if flat and confShort
    stopPx := pendHi + stopBuf * atr
    riskPx := stopPx - close
    tgtPx  := close - tgtR * riskPx
    qty    = riskPx > 0 ? math.min(strategy.equity * riskPct / 100 / riskPx, strategy.equity * 0.5 / close) : na
    if not na(qty) and qty > 0
        strategy.entry("Short", strategy.short, qty = qty, comment = "SELL")
        entryBar := bar_index
        advCount := 0
        pendDir  := 0
if flat and confLong
    stopPx := pendLo - stopBuf * atr
    riskPx := close - stopPx
    tgtPx  := close + tgtR * riskPx
    qty    = riskPx > 0 ? math.min(strategy.equity * riskPct / 100 / riskPx, strategy.equity * 0.5 / close) : na
    if not na(qty) and qty > 0
        strategy.entry("Long", strategy.long, qty = qty, comment = "BUY")
        entryBar := bar_index
        advCount := 0
        pendDir  := 0

inLong  = strategy.position_size > 0
inShort = strategy.position_size < 0
if inLong
    advCount := delta < 0 ? advCount + 1 : 0
if inShort
    advCount := delta > 0 ? advCount + 1 : 0
underWater = inLong ? close < strategy.position_avg_price : inShort ? close > strategy.position_avg_price : false
reclaimExit = (inLong or inShort) and underWater and advCount >= reclaim
timeExit    = (inLong or inShort) and bar_index - entryBar >= timeStop

if inLong
    strategy.exit("Long exit", "Long", stop = stopPx, limit = tgtPx, comment_loss = "STOP", comment_profit = "TARGET")
    if reclaimExit
        strategy.close("Long", comment = "DELTA RECLAIM")
    else if timeExit
        strategy.close("Long", comment = "TIME")
if inShort
    strategy.exit("Short exit", "Short", stop = stopPx, limit = tgtPx, comment_loss = "STOP", comment_profit = "TARGET")
    if reclaimExit
        strategy.close("Short", comment = "DELTA RECLAIM")
    else if timeExit
        strategy.close("Short", comment = "TIME")

// ───────────────────────────── 5. Visuals ─────────────────────────────
cBull = color.new(#26a69a, 0)
cBear = color.new(#ef5350, 0)
plotshape(exhBear, "Bearish exhaustion", shape.diamond, location.abovebar, color.new(cBear, 40), size = size.tiny)
plotshape(exhBull, "Bullish exhaustion", shape.diamond, location.belowbar, color.new(cBull, 40), size = size.tiny)
longEntry  = inLong and not inLong[1]
shortEntry = inShort and not inShort[1]
plotshape(longEntry, "BUY", shape.labelup, location.belowbar, cBull, text = "BUY", textcolor = color.white, size = size.small)
plotshape(shortEntry, "SELL", shape.labeldown, location.abovebar, cBear, text = "SELL", textcolor = color.white, size = size.small)
exitBar = flat and not flat[1]
plotshape(exitBar, "EXIT", shape.xcross, location.absolute, color.new(#ffeb3b, 0), size = size.tiny)
plot(not flat ? stopPx : na, "Stop", cBear, 1, plot.style_linebr)
plot(not flat ? tgtPx : na, "Target", cBull, 1, plot.style_linebr)
plot(delta, "Bar delta", display = display.data_window)
plot(cvd, "CVD", display = display.data_window)
plot(atrP, "ATR percentile", display = display.data_window)
barcolor(exhBear ? color.new(cBear, 30) : exhBull ? color.new(cBull, 30) : na)
if showCvd and (exhBear or exhBull)
    label.new(bar_index, exhBear ? high : low, "d " + str.tostring(delta, "#") + "\ncvd " + str.tostring(cvd, "#"), style = exhBear ? label.style_label_down : label.style_label_up, color = color.new(color.black, 40), textcolor = color.white, size = size.tiny)

var table tbl = na
row(int r, string a, string b, color tc = color.white) =>
    table.cell(tbl, 0, r, a, text_color = color.new(color.white, 20), text_halign = text.align_left, text_size = size.small)
    table.cell(tbl, 1, r, b, text_color = tc, text_size = size.small)
if showTbl and (barstate.islastconfirmedhistory or barstate.isrealtime)
    if na(tbl)
        tbl := table.new(position.top_right, 2, 8, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
    row(0, "Delta source", hasIntra ? "intrabar " + ltf : "bar proxy (no intrabar data)")
    row(1, "Bar delta / CVD", str.tostring(delta, "#") + " / " + str.tostring(cvd, "#"), delta > 0 ? cBull : cBear)
    row(2, "ATR percentile", str.tostring(atrP, "#") + (volOk ? " ok" : " below min"), volOk ? color.white : color.new(color.white, 50))
    row(3, "Setup", pendDir == -1 ? "bearish pending" : pendDir == 1 ? "bullish pending" : "none", pendDir == -1 ? cBear : pendDir == 1 ? cBull : color.white)
    row(4, "Position", inLong ? "LONG" : inShort ? "SHORT" : "flat", inLong ? cBull : inShort ? cBear : color.white)
    row(5, "Stop / target", not flat ? str.tostring(stopPx, format.mintick) + " / " + str.tostring(tgtPx, format.mintick) : "-")
    row(6, "Adverse delta bars", str.tostring(advCount) + " of " + str.tostring(reclaim))
    row(7, "Closed trades", str.tostring(strategy.closedtrades) + "  (" + str.tostring(strategy.wintrades) + " wins)")

// ───────────────────────────── 6. Alerts ─────────────────────────────
if longEntry
    alert("Delta Exhaustion: long entry on " + syminfo.ticker, alert.freq_once_per_bar_close)
if shortEntry
    alert("Delta Exhaustion: short entry on " + syminfo.ticker, alert.freq_once_per_bar_close)
if exitBar
    alert("Delta Exhaustion: position closed on " + syminfo.ticker, alert.freq_once_per_bar_close)
if exhBear or exhBull
    alert("Delta Exhaustion: exhaustion bar printed on " + syminfo.ticker + ", waiting for confirmation", alert.freq_once_per_bar_close)
````
