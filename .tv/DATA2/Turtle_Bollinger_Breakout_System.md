<!-- tradingview-pine-id: PUB;6bcf9a515cdb434289664d377b67fa9f -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Turtle Bollinger Breakout System

Source: https://www.tradingview.com/script/E1OhgTQz/

## Description

🐢 Turtle ATR Channel Breakout

Turtle ATR Channel Breakout is a daily trend-following indicator based on an ATR channel breakout variation described in turtle-trading literature.

[image]https://www.tradingview.com/x/TUVAre3E/[/image]

📊 Channel Calculation

* Basis: 350-day Simple Moving Average (SMA) of closing prices
* Volatility: 20-day Average True Range (ATR) using Wilder’s smoothing
* Upper Band: Basis + 7 × ATR
* Lower Band: Basis − 3 × ATR

🐢 Signal Logic

* A bullish turtle signal is generated when the previous confirmed daily close crosses from at or below the upper band to above the upper band.
* A bearish turtle signal is generated when the previous confirmed daily close crosses from at or above the lower band to below the lower band.
* Signals are displayed on the following trading day, ensuring that each breakout is confirmed by a completed daily close.
* Only the first confirmed close across a boundary generates a signal. If price remains outside the channel for multiple consecutive days, no duplicate signals are produced.
* If price returns inside the channel and later crosses the same boundary again, the new crossing is treated as a new breakout event.

⏱️ Daily Confirmation

The indicator always performs its calculations using daily data, regardless of the chart timeframe.

Intraday highs, intraday lows, and the current unconfirmed daily close are not used to confirm breakout signals. This helps prevent temporary intraday moves from being treated as confirmed breakouts.

⚙️ Customization

The script includes:

* Customizable channel colors
* Customizable bullish and bearish turtle-marker colors
* Optional channel filling
* Optional trend-based bar coloring
* Separate alert conditions for bullish and bearish breakouts

⚠️ Important

This indicator is designed to identify trend breakout events only.

It does not define:

* Position sizing
* Stop-loss levels
* Profit targets
* Portfolio allocation
* Trade execution rules

For research and educational purposes only. This indicator does not constitute financial advice or guarantee future results.

---

## Source Code

````pine
//@version=6
// Turtle Bollinger Breakout System
// Bollinger Breakout benchmark system from Curtis Faith, "Way of the Turtle":
// 350-day MA +/- 2.5 standard deviations, enter on a close beyond the band, exit on a close back through the MA.
// Turtle money management (N-based sizing, 2N stop, 0.5N pyramiding, drawdown size reduction),
// alternative exits and trend filters are optional modules layered on top.

indicator("Turtle Bollinger Breakout System", shorttitle="TBB", overlay=true, max_labels_count=500)

// ------------------------------------------------------------------ 1. Channel
g1 = "1. Channel"
preset = input.string("Turtle 350 / 2.5", "Preset", options=["Turtle 350 / 2.5", "Medium 100 / 2.0", "Short 20 / 2.0", "Custom"], group=g1)
lenIn  = input.int(350, "Custom  MA length", minval=2, group=g1)
multIn = input.float(2.5, "Custom  StdDev multiplier", minval=0.1, step=0.1, group=g1)
maType = input.string("SMA", "MA type", options=["SMA", "EMA"], group=g1)
src    = input.source(close, "Source", group=g1)
widthMode = input.string("StdDev", "Channel width", options=["StdDev", "ATR"], group=g1, tooltip="StdDev is the original rule but is not robust: one historical outlier (a crash, a limit move) inflates the channel for the whole lookback. ATR reacts to the same event linearly instead of quadratically and decays out faster.")
atrChMult = input.float(7.0, "    ATR channel multiplier (in N)", minval=0.5, step=0.5, group=g1, tooltip="Only used when Channel width is ATR. The unit is N, the same ATR defined in section 3, so the half-width equals this number of N. 7 matches the ATR Channel Breakout benchmark system.")

length = switch preset
    "Turtle 350 / 2.5" => 350
    "Medium 100 / 2.0" => 100
    "Short 20 / 2.0"   => 20
    => lenIn

mult = switch preset
    "Turtle 350 / 2.5" => 2.5
    "Medium 100 / 2.0" => 2.0
    "Short 20 / 2.0"   => 2.0
    => multIn

// ------------------------------------------------------------------ 2. Rules
g2 = "2. Rules"
allowLong   = input.bool(true,  "Allow longs", group=g2)
allowShort  = input.bool(true,  "Allow shorts", group=g2)
confirmOnly = input.bool(true,  "Confirm signals on bar close only", group=g2)
exitMode    = input.string("Midline (original)", "Exit method", options=["Midline (original)", "Donchian channel", "Trailing N stop"], group=g2, tooltip="Midline is the original rule, but when the channel is much wider than the stop it can never fire. Donchian (10-bar) is the exit the turtles actually traded. Trailing N stop gives back a fixed number of N from the peak.")
exitLen     = input.int(10, "    Donchian exit lookback", minval=1, group=g2)
trailMult   = input.float(3.0, "    Trailing stop (N multiple)", minval=0.5, step=0.5, group=g2)
useStop     = input.bool(true,  "Enable 2N hard stop (not in the original system)", group=g2)
stopMult    = input.float(2.0,  "Stop width (N multiple)", minval=0.5, step=0.5, group=g2)
intrabar    = input.bool(true,  "Trigger stop / exit on intrabar high / low", group=g2)
useAdd      = input.bool(true,  "Enable pyramiding", group=g2)
addStep     = input.float(0.5,  "Add-on step (N multiple)", minval=0.1, step=0.1, group=g2)
maxUnits    = input.int(4,      "Max units", minval=1, maxval=10, group=g2)
trailOnAdd  = input.bool(true,  "Move stop to latest unit after adding", group=g2)

// ------------------------------------------------------------------ 3. Position sizing
g3 = "3. Position Sizing"
atrLen   = input.int(20, "N period (ATR)", minval=1, group=g3)
acctSize = input.float(100000, "Account equity", minval=0, step=1000, group=g3)
riskPct  = input.float(1.0, "Risk per unit (% of equity)", minval=0.01, step=0.1, group=g3)
autoPV   = input.bool(true, "Use symbol point value", group=g3)
pvManual = input.float(1.0, "Manual point value / contract multiplier", minval=0.000001, group=g3)
useDD    = input.bool(false, "Reduce size on drawdown", group=g3, tooltip="Turtle rule: cut the notional account by 20% for every 10% of drawdown, applied successively (10% down -> 0.8x, 20% down -> 0.64x). Drawdown is tracked automatically from a simulated equity curve built out of this indicator's own signals on this symbol, so it reflects one market rather than a whole portfolio.")
ddStep   = input.float(10, "    Drawdown step (%)", minval=1, step=1, group=g3)
ddCut    = input.float(20, "    Size cut per step (%)", minval=1, maxval=99, step=5, group=g3)

// ------------------------------------------------------------------ 4. Trend filters
g4 = "4. Trend Filters"
fSlope    = input.bool(true,  "Midline slope", group=g4)
slopeLen  = input.int(20, "    Slope lookback", minval=1, group=g4)
fTrendMA  = input.bool(false, "Long-term trend MA", group=g4)
trendLen  = input.int(200, "    Trend MA length", minval=2, group=g4)
trendType = input.string("EMA", "    Trend MA type", options=["SMA", "EMA"], group=g4)
fHTF      = input.bool(false, "Higher timeframe trend", group=g4)
htfTF     = input.timeframe("W", "    Higher timeframe", group=g4)
htfLen    = input.int(20, "    HTF MA length", minval=2, group=g4)
fAdx      = input.bool(false, "ADX strength threshold", group=g4)
adxLen    = input.int(14, "    DI length", minval=1, group=g4)
adxSmooth = input.int(14, "    ADX smoothing", minval=1, group=g4)
adxMin    = input.float(20, "    Minimum ADX", minval=0, step=1, group=g4)
fExpand   = input.bool(false, "Require expanding channel", group=g4)
expandLen = input.int(10, "    Bandwidth lookback", minval=1, group=g4)
fLoser    = input.bool(false, "Turtle filter: skip if last breakout was a winner", group=g4)
showBlock = input.bool(true,  "Mark filtered breakouts", group=g4)

// ------------------------------------------------------------------ 5. Display
g5 = "5. Display"
showFill = input.bool(true, "Channel fill", group=g5)
showSig  = input.bool(true, "Entry / exit markers", group=g5)
showStop = input.bool(true, "Stop and exit lines", group=g5)
showBg   = input.bool(true, "Position background", group=g5)
showTbl  = input.bool(true, "Info panel", group=g5)
showStats = input.bool(true, "Signal statistics in panel", group=g5, tooltip="Counts every signal this indicator has generated on the visible history. Fills are assumed at the stop or exit level (at the open if the bar gapped through it) with no slippage or commission, so treat it as a sanity check, not a backtest.")
tblPosIn = input.string("Top Right", "Panel position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=g5)

// ------------------------------------------------------------------ Channel and N
nVal  = ta.atr(atrLen)
basis = maType == "EMA" ? ta.ema(src, length) : ta.sma(src, length)
dev   = widthMode == "ATR" ? atrChMult * nVal : mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

pointVal = autoPV ? syminfo.pointvalue : pvManual

// Half-width expressed in N. Once this exceeds the stop multiple the 2N stop always
// fires before the midline and the original exit rule becomes unreachable.
float widthN = nVal > 0 ? dev / nVal : na

dcLong  = ta.lowest(low, exitLen)[1]
dcShort = ta.highest(high, exitLen)[1]

dataReady = bar_index >= length and not na(basis)
active    = dataReady and (not confirmOnly or barstate.isconfirmed)

// ------------------------------------------------------------------ Filters
// A disabled filter evaluates to true; enabled filters are combined with AND.
slopeUp = not fSlope or basis > basis[slopeLen]
slopeDn = not fSlope or basis < basis[slopeLen]

trendMA = trendType == "EMA" ? ta.ema(close, trendLen) : ta.sma(close, trendLen)
maUp    = not fTrendMA or (close > trendMA and trendMA > trendMA[1])
maDn    = not fTrendMA or (close < trendMA and trendMA < trendMA[1])

f_htfMA() => ta.ema(close, htfLen)
htfMA = request.security(syminfo.tickerid, htfTF, f_htfMA(), lookahead=barmerge.lookahead_off)
htfUp = not fHTF or (not na(htfMA) and close > htfMA)
htfDn = not fHTF or (not na(htfMA) and close < htfMA)

[diP, diM, adxVal] = ta.dmi(adxLen, adxSmooth)
adxOk = not fAdx or adxVal >= adxMin

expandOk = not fExpand or dev > dev[expandLen]

// Original System 1 filter looks at the last breakout, traded or not, so a parallel
// virtual position is tracked below to settle its result.
var bool lastLoser = true
loserOk = not fLoser or lastLoser

okLong  = allowLong  and slopeUp and maUp and htfUp and adxOk and expandOk and loserOk
okShort = allowShort and slopeDn and maDn and htfDn and adxOk and expandOk and loserOk

// ------------------------------------------------------------------ Position state
var int   posDir   = 0
var int   units    = 0
var float entryAvg = na
var float lastAdd  = na
var float entryN   = na
var float stopLvl  = na
var float unitQty  = na
var float peak     = na
var float exitLvl  = na

var int   vDir   = 0
var float vEntry = na
var float vStop  = na

// Simulated equity built from this indicator's own signals, used to drive the
// drawdown size reduction without asking the user for an equity figure.
var float eqCurve  = na
var float eqPeak   = na
var float ddPct    = 0.0
var float ddFactor = 1.0
var float maxDD    = 0.0
var float qtyNow   = na
var int   nTrades  = 0
var int   nWins    = 0

longEntry  = false
shortEntry = false
longAdd    = false
shortAdd   = false
exitEvent  = false
stopHit    = false
blockLong  = false
blockShort = false

f_exitLevel(int dir, float pk) =>
    float lvl = na
    if dir == 1
        lvl := exitMode == "Midline (original)" ? basis : exitMode == "Donchian channel" ? dcLong : pk - trailMult * entryN
    else if dir == -1
        lvl := exitMode == "Midline (original)" ? basis : exitMode == "Donchian channel" ? dcShort : pk + trailMult * entryN
    lvl

if active
    if na(eqCurve)
        eqCurve := acctSize
        eqPeak  := acctSize

    if vDir != 0
        vHit = useStop and not na(vStop) and (vDir == 1 ? (intrabar ? low <= vStop : close <= vStop) : (intrabar ? high >= vStop : close >= vStop))
        if vHit or (vDir == 1 ? close < basis : close > basis)
            vPx = vHit ? vStop : close
            lastLoser := (vDir == 1 ? vPx - vEntry : vEntry - vPx) <= 0
            vDir      := 0
            vEntry    := na
            vStop     := na

    if posDir == 1
        peak := na(peak) ? high : math.max(peak, high)
    else if posDir == -1
        peak := na(peak) ? low : math.min(peak, low)

    exitLvl := f_exitLevel(posDir, peak)

    if posDir == 1
        hitStop = useStop and not na(stopLvl) and (intrabar ? low <= stopLvl : close <= stopLvl)
        hitExit = not na(exitLvl) and (exitMode == "Midline (original)" ? close < exitLvl : intrabar ? low <= exitLvl : close < exitLvl)
        if hitStop or hitExit
            exitEvent := true
            stopHit   := hitStop
    else if posDir == -1
        hitStopS = useStop and not na(stopLvl) and (intrabar ? high >= stopLvl : close >= stopLvl)
        hitExitS = not na(exitLvl) and (exitMode == "Midline (original)" ? close > exitLvl : intrabar ? high >= exitLvl : close > exitLvl)
        if hitStopS or hitExitS
            exitEvent := true
            stopHit   := hitStopS

    if exitEvent
        // Assume the fill happens at the level that was breached, or at the open if the bar gapped through it.
        float fillPx = close
        if stopHit and intrabar
            fillPx := posDir == 1 ? math.min(open, stopLvl) : math.max(open, stopLvl)
        else if not stopHit and intrabar and exitMode != "Midline (original)"
            fillPx := posDir == 1 ? math.min(open, exitLvl) : math.max(open, exitLvl)
        float pnl = (posDir == 1 ? fillPx - entryAvg : entryAvg - fillPx) * nz(unitQty) * units * pointVal
        eqCurve  := eqCurve + pnl
        eqPeak   := math.max(nz(eqPeak, eqCurve), eqCurve)
        nTrades  := nTrades + 1
        nWins    := pnl > 0 ? nWins + 1 : nWins

        posDir   := 0
        units    := 0
        entryAvg := na
        lastAdd  := na
        entryN   := na
        stopLvl  := na
        unitQty  := na
        peak     := na
        exitLvl  := na

    ddPct    := nz(eqPeak) > 0 ? math.max(0.0, (eqPeak - eqCurve) / eqPeak * 100.0) : 0.0
    maxDD    := math.max(maxDD, ddPct)
    ddFactor := useDD and ddStep > 0 ? math.pow(1.0 - ddCut / 100.0, math.floor(ddPct / ddStep)) : 1.0
    qtyNow   := nVal > 0 and pointVal > 0 ? (acctSize * riskPct / 100.0 * ddFactor) / (stopMult * nVal * pointVal) : na

    if posDir == 0 and close > upper
        if okLong
            longEntry := true
            posDir    := 1
            units     := 1
            entryAvg  := close
            lastAdd   := close
            entryN    := nVal
            unitQty   := qtyNow
            stopLvl   := close - stopMult * nVal
            peak      := high
        else
            blockLong := allowLong
    else if posDir == 0 and close < lower
        if okShort
            shortEntry := true
            posDir     := -1
            units      := 1
            entryAvg   := close
            lastAdd    := close
            entryN     := nVal
            unitQty    := qtyNow
            stopLvl    := close + stopMult * nVal
            peak       := low
        else
            blockShort := allowShort

    // Add-on spacing uses the N captured at entry so a drifting N cannot change it.
    if useAdd and units >= 1 and units < maxUnits
        if posDir == 1 and close >= lastAdd + addStep * entryN
            longAdd  := true
            entryAvg := (entryAvg * units + close) / (units + 1)
            units    := units + 1
            lastAdd  := close
            stopLvl  := trailOnAdd ? close - stopMult * entryN : stopLvl
        else if posDir == -1 and close <= lastAdd - addStep * entryN
            shortAdd := true
            entryAvg := (entryAvg * units + close) / (units + 1)
            units    := units + 1
            lastAdd  := close
            stopLvl  := trailOnAdd ? close + stopMult * entryN : stopLvl

    exitLvl := f_exitLevel(posDir, peak)

    if vDir == 0 and close > upper
        vDir   := 1
        vEntry := close
        vStop  := close - stopMult * nVal
    else if vDir == 0 and close < lower
        vDir   := -1
        vEntry := close
        vStop  := close + stopMult * nVal

// ------------------------------------------------------------------ Plots
cUp  = color.new(#26A69A, 0)
cDn  = color.new(#EF5350, 0)
cMid = color.new(#FF9800, 0)

pU = plot(dataReady ? upper : na, "Upper", cUp, 1)
pL = plot(dataReady ? lower : na, "Lower", cDn, 1)
pB = plot(dataReady ? basis : na, "Midline", cMid, 2)

fill(pU, pB, showFill ? color.new(#26A69A, 92) : na, "Upper zone")
fill(pB, pL, showFill ? color.new(#EF5350, 92) : na, "Lower zone")

plot(showStop and posDir != 0 ? stopLvl : na, "Stop", color.new(#EF5350, 25), 1, plot.style_linebr)
plot(showStop and posDir != 0 and exitMode != "Midline (original)" ? exitLvl : na, "Exit level", color.new(#FF9800, 20), 1, plot.style_linebr)
plot(posDir != 0 ? entryAvg : na, "Avg entry", color.new(color.gray, 30), 1, plot.style_linebr)

bgcolor(showBg and posDir == 1 ? color.new(#26A69A, 94) : showBg and posDir == -1 ? color.new(#EF5350, 94) : na, title="Position background")

plotshape(showSig and longEntry,  "Long breakout",  shape.labelup,      location.belowbar, cUp, text="L", textcolor=color.white, size=size.tiny)
plotshape(showSig and shortEntry, "Short breakout", shape.labeldown,    location.abovebar, cDn, text="S", textcolor=color.white, size=size.tiny)
plotshape(showSig and longAdd,    "Long add",       shape.triangleup,   location.belowbar, cUp, size=size.tiny)
plotshape(showSig and shortAdd,   "Short add",      shape.triangledown, location.abovebar, cDn, size=size.tiny)
plotshape(showSig and exitEvent and not stopHit ? close : na, "Rule exit", shape.xcross, location.absolute, cMid, size=size.tiny)
plotshape(showSig and exitEvent and stopHit     ? close : na, "Stop exit", shape.xcross, location.absolute, color.red, size=size.tiny)

plot(fTrendMA ? trendMA : na, "Trend MA", color.new(color.blue, 40), 1)
plot(fHTF ? htfMA : na, "HTF MA", color.new(color.purple, 40), 1, plot.style_stepline)

plotshape(showBlock and blockLong,  "Filtered long breakout",  shape.circle, location.belowbar, color.new(color.gray, 35), size=size.tiny)
plotshape(showBlock and blockShort, "Filtered short breakout", shape.circle, location.abovebar, color.new(color.gray, 35), size=size.tiny)

// ------------------------------------------------------------------ Info panel
tblPos = switch tblPosIn
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    => position.bottom_left

var table tbl = table.new(tblPos, 2, 20, border_width=1, frame_width=1, frame_color=color.new(color.gray, 50), border_color=color.new(color.gray, 70))

f_row(int r, string k, string v, color vc) =>
    table.cell(tbl, 0, r, k, text_color=color.new(color.gray, 10), text_size=size.small, text_halign=text.align_left,  bgcolor=color.new(color.black, 85))
    table.cell(tbl, 1, r, v, text_color=vc,                        text_size=size.small, text_halign=text.align_right, bgcolor=color.new(color.black, 85))

if showTbl and barstate.islast
    stateTxt = posDir == 1 ? "Long" : posDir == -1 ? "Short" : "Flat"
    stateCol = posDir == 1 ? cUp : posDir == -1 ? cDn : color.new(color.gray, 20)
    float totQty  = unitQty * units
    float riskNow = na(stopLvl) or na(totQty) ? na : math.abs(entryAvg - stopLvl) * totQty * pointVal
    float distMid = nVal > 0 ? (close - basis) / nVal : na

    healthy  = exitMode != "Midline (original)" or not useStop or nz(widthN, 0) <= stopMult
    widthCol = healthy ? cUp : nz(widthN, 0) <= stopMult * 2 ? color.orange : cDn
    widthTxt = na(widthN) ? "-" : str.tostring(widthN, "#.#") + " N" + (healthy ? "" : "  stop first")

    f_row(0, "Status", dataReady ? stateTxt : "Needs " + str.tostring(length) + " bars", dataReady ? stateCol : color.orange)
    f_row(1, "Channel", str.tostring(length) + " / " + (widthMode == "ATR" ? str.tostring(atrChMult, "#.#") + " ATR" : str.tostring(mult, "#.##") + " SD"), color.new(color.gray, 10))
    f_row(2, "N (ATR" + str.tostring(atrLen) + ")", str.tostring(nVal, format.mintick), color.new(color.gray, 10))
    f_row(3, "Half-width", widthTxt, widthCol)
    f_row(4, "Exit mode", exitMode, color.new(color.gray, 10))
    f_row(5, "Units", str.tostring(units) + " / " + str.tostring(useAdd ? maxUnits : 1), color.new(color.gray, 10))
    f_row(6, "Qty per unit", na(qtyNow) ? "-" : str.tostring(qtyNow, "#.####"), color.new(color.gray, 10))
    f_row(7, "Drawdown size", not useDD ? "-" : str.tostring(ddFactor, "#.##") + "x  (" + str.tostring(ddPct, "#.#") + "% dd)", not useDD or ddFactor >= 1.0 ? color.new(color.gray, 10) : color.orange)
    f_row(8, "Total qty", na(totQty) ? "-" : str.tostring(totQty, "#.####"), stateCol)
    f_row(9, "Avg entry", na(entryAvg) ? "-" : str.tostring(entryAvg, format.mintick), color.new(color.gray, 10))
    f_row(10, "Exit level", na(exitLvl) ? "-" : str.tostring(exitLvl, format.mintick), na(exitLvl) ? color.new(color.gray, 10) : cMid)
    f_row(11, "Stop / risk", na(stopLvl) ? "-" : str.tostring(stopLvl, format.mintick) + "  (" + str.tostring(riskNow, "#.#") + ")", na(stopLvl) ? color.new(color.gray, 10) : cDn)
    f_row(12, "Dist to mid", na(distMid) ? "-" : str.tostring(distMid, "#.##") + " N", nz(distMid) >= 0 ? cUp : cDn)

    string fltTxt = (fSlope ? "Slope " : "") + (fTrendMA ? "MA" + str.tostring(trendLen) + " " : "") + (fHTF ? htfTF + " " : "") + (fAdx ? "ADX " : "") + (fExpand ? "Expand " : "") + (fLoser ? "LastLoss " : "")
    f_row(13, "Filters on", fltTxt == "" ? "none" : fltTxt, color.new(color.gray, 10))
    f_row(14, "Allowed", (okLong ? "L yes" : "L no") + "   " + (okShort ? "S yes" : "S no"), okLong or okShort ? color.new(color.gray, 10) : color.orange)
    f_row(15, "Last breakout", not fLoser ? "-" : lastLoser ? "loss, allow" : "win, block", not fLoser ? color.new(color.gray, 10) : lastLoser ? cUp : color.orange)

    if showStats
        float netPnl = nz(eqCurve) - acctSize
        float netPct = acctSize > 0 ? netPnl / acctSize * 100.0 : 0.0
        f_row(16, "Signals closed", str.tostring(nTrades), color.new(color.gray, 10))
        f_row(17, "Win rate", nTrades == 0 ? "-" : str.tostring(100.0 * nWins / nTrades, "#.#") + "%  (" + str.tostring(nWins) + "W)", color.new(color.gray, 10))
        f_row(18, "Net P&L", nTrades == 0 ? "-" : str.tostring(netPnl, "#.#") + "  (" + str.tostring(netPct, "#.#") + "%)", netPnl >= 0 ? cUp : cDn)
        f_row(19, "Max drawdown", nTrades == 0 ? "-" : str.tostring(maxDD, "#.#") + "%", maxDD > 0 ? cDn : color.new(color.gray, 10))

// ------------------------------------------------------------------ Alerts
alertcondition(longEntry,  "Long breakout",  "TBB: {{ticker}} closed above the upper band, go long")
alertcondition(shortEntry, "Short breakout", "TBB: {{ticker}} closed below the lower band, go short")
alertcondition(longAdd or shortAdd, "Add unit", "TBB: {{ticker}} add-on level reached")
alertcondition(exitEvent,  "Exit", "TBB: {{ticker}} exit triggered")

if longEntry
    alert("TBB LONG " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | N=" + str.tostring(nVal, format.mintick) + " | stop " + str.tostring(stopLvl, format.mintick), alert.freq_once_per_bar_close)
if shortEntry
    alert("TBB SHORT " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | N=" + str.tostring(nVal, format.mintick) + " | stop " + str.tostring(stopLvl, format.mintick), alert.freq_once_per_bar_close)
if longAdd or shortAdd
    alert("TBB ADD " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | unit " + str.tostring(units), alert.freq_once_per_bar_close)
if exitEvent
    alert("TBB EXIT " + syminfo.ticker + " @ " + str.tostring(close, format.mintick) + " | " + (stopHit ? "2N stop" : "rule exit"), alert.freq_once_per_bar_close)
````
