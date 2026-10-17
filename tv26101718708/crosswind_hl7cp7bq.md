# Crosswind

- url: https://www.tradingview.com/script/Hl7cp7Bq-Crosswind/
- type: indicator
- pine_id: PUB;9341ce183063488a901e0d133c3fb9bf
- version: 1.0

## Description

CROSSWIND
Crosswind is a signal and trade management indicator built on EMA crossovers, but the crossover itself is only the starting point. Most crossover systems break down in two predictable places. They enter on the cross, which is very often the worst price in the whole move, and they exit at a fixed percentage target, which caps the rare large trends that are supposed to pay for all the small losers. Crosswind addresses both problems and then reports every result net of trading costs, so you can judge whether an edge actually survives the fee schedule.

THREE TIMEFRAME PRESETS
Selecting a trading style sets the EMA pair for you. 15 Min Scalping uses 9 and 21. 1 Hour Swing uses 13 and 48. Daily Trend uses 15 and 150. The preset also sets the width of the trailing stop, since noise that is meaningless on a daily chart will repeatedly eject you from a position on a 15 minute chart.

TREND FILTER
A 200 period SMA gates direction. Long signals are only considered while price trades above it and short signals only while price trades below it. The chart background shades faint green above and faint red below so the active regime is visible at a glance.

TWO SIGNAL MODES
Crossover mode fires when the fast EMA crosses the slow EMA in the direction of the trend filter.
Pullback mode waits. After the fast EMA crosses above the slow EMA, no signal is issued yet. The indicator waits for price to retrace into the slow EMA and then close back across it, within a window of bars that you control. You are buying the first dip after trend confirmation rather than the extension itself. Fewer signals, but a materially better average entry, and your initial stop sits closer to structure.

OPTIONAL MACD CONFIRMATION
A standard MACD can be required to agree with the signal direction. It reduces frequency and filters some counter momentum entries.

HOW A TRADE IS MANAGED
Risk is measured in R, where 1R is the initial stop distance of 2x ATR. Every number the indicator reports is expressed in these units, which makes results comparable across symbols and volatility regimes.
A trade passes through three stages.
Initial stop. Placed 2x ATR from entry. Nothing moves while the trade is proving itself.
Breakeven. Once the trade reaches 1R in your favour, the stop advances to entry plus the full round trip cost plus a small cushion. This is a real breakeven, not a nominal one, so a trade stopped at this stage does not quietly book a small loss.
Trail. Once the trade reaches 1.5R, a chandelier trail arms. It tracks the highest high reached since entry, offset by an ATR multiple, and it only ever ratchets in your favour. The stop line turns blue when the trail is live, so the current stage is always obvious on the chart.
There is no fixed profit target by default. A winning trade runs until the trail takes it out. If you want a cap for comparison purposes you can set a hard target expressed in R.
An alternative EMA trail is included, which follows the slow EMA with an ATR buffer, for traders who prefer a moving average exit.

COST ACCOUNTING
Fees and slippage are charged per side against the actual entry and exit prices, so cost scales properly with price rather than being a flat assumption. Funding is optional and charged per eight hours held, scaled by your chart timeframe. Defaults assume 0.06 percent taker fees and 0.02 percent slippage. Lower the fee if you post maker orders.
This matters more than most traders expect. Cost per trade is roughly twice the round trip percentage divided by the stop distance. On a daily chart with a wide stop this rounds to almost nothing. On a 15 minute chart with a tight ATR it can exceed a tenth of an R on every single trade, which is enough to turn a system with a respectable win rate into a losing one.

READING THE LABEL
The status label reports the live trade state and the closed trade record. Net R and average R per trade are the headline numbers. Gross R and cost drag are shown alongside them deliberately. If cost drag is consuming a large fraction of gross R, the honest conclusion is that the configuration trades too frequently for the size of its edge, and the fix is a stricter entry filter rather than a cleverer exit.
Best and worst trade, win rate, and the outcome of the most recent trade are also shown. Trend following configurations typically produce a win rate below fifty percent while remaining profitable, because the winners are much larger than the losers. Judge the system on average R, not on win rate.

ALERTS
Five alert conditions are available. Long signal, short signal, either signal, stop or trail hit, and trail armed.

THE CONFIGURATION I USE
1 Hour Swing preset with signal mode set to Pullback, and the reversal option left off so that an opposite signal does not close and flip an open position. Trades finish on their own stop or trail, and the next signal is only taken once flat. This produces a lower trade count with cleaner entries and lets the trail do the work of deciding when a move is over.

LIMITATIONS WORTH KNOWING
Signals evaluate on bar close. Stop resolution uses the level carried in from the previous bar before the trail updates on the current bar, which avoids look ahead but means the trail lags by one bar. When a single bar's range covers both the stop and a hard target, the result is scored as a stop, because OHLC data cannot reveal which level was reached first. The statistics are a study of signal quality, not a full backtest, and they assume constant risk per trade with no position sizing or compounding.

This indicator is a tool for analysis and is not financial advice. Test any configuration on your own market and timeframe before risking capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MonkeyPhone

//@version=6
indicator("Crosswind", "CROSSWIND i4", overlay = true)

// ============================================================================
// INPUTS
// ============================================================================

tfStyle     = input.string("Daily Trend", "Trading Style", options = ["15 Min Scalping", "1 Hour Swing", "Daily Trend"], group = "Core")
entryMode   = input.string("Pullback", "Signal Mode", options = ["Crossover", "Pullback"], group = "Core")
allowFlip   = input.bool(true, "Opposite signal closes an open trade and reverses", group = "Core")

trendLen    = input.int(200, "Trend SMA Length", minval = 1, group = "Filters")
useMacd     = input.bool(true, "MACD Confirmation", group = "Filters")
macdFast    = input.int(12, "MACD Fast", minval = 1, group = "Filters")
macdSlow    = input.int(26, "MACD Slow", minval = 1, group = "Filters")
macdSig     = input.int(9, "MACD Signal", minval = 1, group = "Filters")

lateBars    = input.int(3, "Late-Signal Window — bars after cross (scalping only)", minval = 0, group = "Timing")
pullWin     = input.int(20, "Pullback Valid Window — bars after cross", minval = 1, group = "Timing")

atrLen      = input.int(14, "ATR Length", minval = 1, group = "Risk")
atrMult     = input.float(2.0, "Initial Stop ATR Multiple", minval = 0.1, step = 0.1, group = "Risk")

feeSide     = input.float(0.06, "Fee % Per Side", minval = 0, step = 0.005, group = "Costs")
slipSide    = input.float(0.02, "Slippage % Per Side", minval = 0, step = 0.005, group = "Costs")
fundPct     = input.float(0.0, "Funding % Per 8h — 0 = ignore", minval = 0, step = 0.001, group = "Costs")

exitStyle   = input.string("Adaptive Trail", "Exit Style", options = ["Adaptive Trail", "EMA Trail", "Initial Stop Only"], group = "Exit")
beAtR       = input.float(1.0, "Move Stop To Breakeven At (R) — 0 = off", minval = 0, step = 0.1, group = "Exit")
beOffR      = input.float(0.1, "Breakeven Cushion Above Costs (R)", minval = 0, step = 0.05, group = "Exit")
trailAtR    = input.float(1.5, "Start Trailing At (R)", minval = 0, step = 0.1, group = "Exit")
trailMultIn = input.float(0, "Trail ATR Multiple — 0 = auto by style", minval = 0, step = 0.1, group = "Exit")
finalTgtR   = input.float(0, "Hard Target (R) — 0 = ride it", minval = 0, step = 0.5, group = "Exit")

showLevels  = input.bool(true, "Plot Stop / Target While Trade Is Open", group = "Display")
showBg      = input.bool(true, "Shade Trend Background", group = "Display")
showCrosses = input.bool(true, "Mark Raw EMA Crosses", group = "Display")
showStatus  = input.bool(true, "Show Status Label", group = "Display")

// ============================================================================
// PRESETS + CALCS
// ============================================================================

scalp     = tfStyle == "15 Min Scalping"
fastLen   = tfStyle == "15 Min Scalping" ? 9 : tfStyle == "1 Hour Swing" ? 13 : 15
slowLen   = tfStyle == "15 Min Scalping" ? 21 : tfStyle == "1 Hour Swing" ? 48 : 150
trailAuto = tfStyle == "15 Min Scalping" ? 2.0 : tfStyle == "1 Hour Swing" ? 3.0 : 3.5
trailMult = trailMultIn > 0 ? trailMultIn : trailAuto

sideCost = (feeSide + slipSide) / 100.0
barHrs   = timeframe.in_seconds() / 3600.0

fastEma = ta.ema(close, fastLen)
slowEma = ta.ema(close, slowLen)
trendMa = ta.sma(close, trendLen)
atrVal  = ta.atr(atrLen)

[macdLine, sigLine, hist] = ta.macd(close, macdFast, macdSlow, macdSig)

warm      = not na(trendMa) and not na(slowEma) and not na(atrVal) and atrVal > 0
longMacd  = not useMacd or (nz(macdLine) > nz(sigLine) and nz(hist) > 0)
shortMacd = not useMacd or (nz(macdLine) < nz(sigLine) and nz(hist) < 0)

up   = warm and close > trendMa
down = warm and close < trendMa

goldX  = ta.crossover(fastEma, slowEma)
deathX = ta.crossunder(fastEma, slowEma)

var int sinceGold  = 9999
var int sinceDeath = 9999
sinceGold  := goldX ? 0 : math.min(sinceGold + 1, 9999)
sinceDeath := deathX ? 0 : math.min(sinceDeath + 1, 9999)

lateLong  = scalp and sinceGold > 0 and sinceGold <= lateBars and fastEma > slowEma
lateShort = scalp and sinceDeath > 0 and sinceDeath <= lateBars and fastEma < slowEma

pullLong  = fastEma > slowEma and ta.crossover(close, slowEma) and sinceGold <= pullWin
pullShort = fastEma < slowEma and ta.crossunder(close, slowEma) and sinceDeath <= pullWin

rawLong  = entryMode == "Crossover" ? (goldX or lateLong) : pullLong
rawShort = entryMode == "Crossover" ? (deathX or lateShort) : pullShort

longSig  = up and rawLong and longMacd
shortSig = down and rawShort and shortMacd

// ============================================================================
// TRADE STATE
// ============================================================================

var int    posDir  = 0
var float  entryPx = na
var float  riskU   = na
var float  stopPx  = na
var float  peakPx  = na
var bool   beDone  = false
var bool   trailOn = false
var int    barsIn  = 0

var int    nTrades   = 0
var int    nWins     = 0
var float  sumNetR   = 0.0
var float  sumGrossR = 0.0
var float  sumCostR  = 0.0
var float  bestR     = na
var float  worstR    = na
var float  lastR     = na
var string lastOut   = "-"

// --- step 1: resolve against the stop carried in from the previous bar ---

tgtPx = finalTgtR <= 0 or na(entryPx) or posDir == 0 ? na : posDir == 1 ? entryPx + finalTgtR * riskU : entryPx - finalTgtR * riskU

hitStop = posDir != 0 and not na(stopPx) and (posDir == 1 ? low <= stopPx : high >= stopPx)
hitTgt  = posDir != 0 and not na(tgtPx) and (posDir == 1 ? high >= tgtPx : low <= tgtPx) and not hitStop

closeNow = hitStop or hitTgt
closePx  = hitStop ? stopPx : hitTgt ? tgtPx : na
closeTag = not closeNow ? "-" : hitTgt ? "TARGET" : trailOn ? "TRAIL" : beDone ? "BREAKEVEN" : "STOP"

// --- step 2: manage the trade if it survived ---

alive = posDir != 0 and not closeNow

peakPx := not alive ? peakPx : posDir == 1 ? math.max(peakPx, high) : math.min(peakPx, low)
mfeR    = not alive or na(riskU) ? na : posDir == 1 ? (peakPx - entryPx) / riskU : (entryPx - peakPx) / riskU

beDone  := alive and beAtR > 0 and not na(mfeR) and mfeR >= beAtR ? true : beDone
trailOn := alive and exitStyle != "Initial Stop Only" and not na(mfeR) and mfeR >= trailAtR ? true : trailOn

roundCostR = na(entryPx) or na(riskU) ? 0.0 : 2.0 * entryPx * sideCost / riskU
beLevel    = na(entryPx) ? na : posDir == 1 ? entryPx + (roundCostR + beOffR) * riskU : entryPx - (roundCostR + beOffR) * riskU
chandPx    = not alive ? na : posDir == 1 ? peakPx - trailMult * atrVal : peakPx + trailMult * atrVal
emaPx      = not alive ? na : posDir == 1 ? slowEma - 0.5 * atrVal : slowEma + 0.5 * atrVal
trailPx    = exitStyle == "EMA Trail" ? emaPx : chandPx

floorV = posDir == 1 ? -1e12 : 1e12
candBe = alive and beDone ? beLevel : floorV
candTr = alive and trailOn ? trailPx : floorV

stopPx := not alive ? stopPx : posDir == 1 ? math.max(stopPx, candBe, candTr) : math.min(stopPx, candBe, candTr)

// --- step 3: settle, apply costs, then look for a new signal ---

posDir := closeNow ? 0 : posDir

dirBefore = posDir
newLong   = longSig and (dirBefore == 0 or (allowFlip and dirBefore == -1))
newShort  = shortSig and (dirBefore == 0 or (allowFlip and dirBefore == 1))
flipOut   = (newLong or newShort) and dirBefore != 0

exitPx  = closeNow ? closePx : flipOut ? close : na
exitDir = closeNow ? (hitStop or hitTgt ? (na(entryPx) ? 0 : (stopPx > entryPx or hitTgt ? 1 : 1)) : 0) : 0
sideNow = closeNow ? (peakPx >= entryPx ? (posDir == 0 ? (entryPx <= exitPx ? 1 : -1) : posDir) : posDir) : dirBefore

grossR = na(exitPx) or na(entryPx) or na(riskU) ? na : sideNow == 1 ? (exitPx - entryPx) / riskU : (entryPx - exitPx) / riskU
hrsHeld = (barsIn + 1) * barHrs
fundR   = fundPct <= 0 or na(entryPx) or na(riskU) ? 0.0 : entryPx * (fundPct / 100.0) * hrsHeld / 8.0 / riskU
costR   = na(exitPx) or na(riskU) ? na : (entryPx + exitPx) * sideCost / riskU + fundR
netR    = na(grossR) ? na : grossR - costR

booked = not na(netR)

nTrades   := booked ? nTrades + 1 : nTrades
nWins     := booked and netR > 0 ? nWins + 1 : nWins
sumNetR   := booked ? sumNetR + netR : sumNetR
sumGrossR := booked ? sumGrossR + grossR : sumGrossR
sumCostR  := booked ? sumCostR + costR : sumCostR
bestR     := booked ? (na(bestR) ? netR : math.max(bestR, netR)) : bestR
worstR    := booked ? (na(worstR) ? netR : math.min(worstR, netR)) : worstR
lastR     := booked ? netR : lastR
lastOut   := closeNow ? closeTag : flipOut ? "FLIP" : lastOut

posDir  := newLong ? 1 : newShort ? -1 : posDir
entryPx := newLong or newShort ? close : posDir == 0 ? na : entryPx
riskU   := newLong or newShort ? atrVal * atrMult : posDir == 0 ? na : riskU
stopPx  := newLong ? close - atrVal * atrMult : newShort ? close + atrVal * atrMult : posDir == 0 ? na : stopPx
peakPx  := newLong or newShort ? close : posDir == 0 ? na : peakPx
beDone  := newLong or newShort or posDir == 0 ? false : beDone
trailOn := newLong or newShort or posDir == 0 ? false : trailOn
barsIn  := newLong or newShort ? 0 : posDir == 0 ? 0 : barsIn + 1

// ============================================================================
// PLOTS
// ============================================================================

dispTgt  = finalTgtR <= 0 or posDir == 0 or na(entryPx) ? na : posDir == 1 ? entryPx + finalTgtR * riskU : entryPx - finalTgtR * riskU
lineStop = showLevels and posDir != 0 ? stopPx : na
lineTgt  = showLevels and posDir != 0 ? dispTgt : na
lineEnt  = showLevels and posDir != 0 ? entryPx : na

plot(fastEma, "Fast EMA", color = color.new(color.green, 0), linewidth = 2)
plot(slowEma, "Slow EMA", color = color.new(color.red, 0), linewidth = 2)
plot(trendMa, "Trend SMA", color = color.new(color.orange, 0), linewidth = 2)

plot(lineEnt, "Entry", color = color.new(color.gray, 0), style = plot.style_cross)
plot(lineStop, "Stop", color = trailOn ? color.new(color.blue, 0) : color.new(color.red, 0), style = plot.style_cross)
plot(lineTgt, "Hard Target", color = color.new(color.teal, 0), style = plot.style_cross)

plotshape(newLong, "Long Signal", shape.triangleup, location.belowbar, color.new(color.green, 0), size = size.small)
plotshape(newShort, "Short Signal", shape.triangledown, location.abovebar, color.new(color.red, 0), size = size.small)

plotshape(booked and netR > 0, "Win Exit", shape.xcross, location.belowbar, color.new(color.teal, 0), size = size.small)
plotshape(booked and netR <= 0, "Loss Exit", shape.xcross, location.abovebar, color.new(color.red, 0), size = size.small)

plotshape(showCrosses and goldX, "Golden Cross", shape.circle, location.belowbar, color.new(#B8860B, 0), size = size.tiny)
plotshape(showCrosses and deathX, "Death Cross", shape.circle, location.abovebar, color.new(color.purple, 0), size = size.tiny)

bgcolor(showBg and up ? color.new(color.green, 95) : showBg and down ? color.new(color.red, 95) : na)

// ============================================================================
// STATUS
// ============================================================================

openGross = posDir == 0 or na(entryPx) or na(riskU) ? na : posDir == 1 ? (close - entryPx) / riskU : (entryPx - close) / riskU
openNet   = na(openGross) ? na : openGross - 2.0 * entryPx * sideCost / riskU
runMfe    = posDir == 0 or na(peakPx) or na(riskU) ? na : posDir == 1 ? (peakPx - entryPx) / riskU : (entryPx - peakPx) / riskU
winPct    = nTrades == 0 ? na : 100.0 * nWins / nTrades
avgNet    = nTrades == 0 ? na : sumNetR / nTrades
avgCost   = nTrades == 0 ? na : sumCostR / nTrades
stage     = posDir == 0 ? "flat" : trailOn ? "trailing" : beDone ? "breakeven" : "initial stop"
sideTxt   = posDir == 1 ? "LONG" : posDir == -1 ? "SHORT" : "none"

f(x, d) => na(x) ? "-" : str.tostring(x, d)

statTxt = "Crosswind " + tfStyle + "\nside: " + sideTxt + (posDir == 0 ? "" : "  (" + str.tostring(barsIn) + " bars, " + stage + ")") + "\nentry: " + f(entryPx, format.mintick) + "   stop: " + f(stopPx, format.mintick) + "\nopen R net: " + f(openNet, "#.##") + "   peak R: " + f(runMfe, "#.##") + "\n— closed, net of costs —\ntrades: " + str.tostring(nTrades) + "   win: " + f(winPct, "#.#") + "%" + "\nnet R: " + f(sumNetR, "#.##") + "   avg: " + f(avgNet, "#.##") + "R" + "\ngross R: " + f(sumGrossR, "#.##") + "   cost drag: " + f(sumCostR, "#.##") + "R" + "\ncost/trade: " + f(avgCost, "#.###") + "R" + "\nbest: " + f(bestR, "#.##") + "R   worst: " + f(worstR, "#.##") + "R" + "\nlast: " + lastOut + " (" + f(lastR, "#.##") + "R net)"

var label stat = na
if showStatus and barstate.islast
    label.delete(stat)
    stat := label.new(bar_index, high, statTxt, color = color.white, textcolor = color.black, style = label.style_label_left, size = size.normal)

        // ============================================================================
        // ALERTS
        // ============================================================================

alertcondition(newLong, "Crosswind Long", "Crosswind LONG signal")
alertcondition(newShort, "Crosswind Short", "Crosswind SHORT signal")
alertcondition(newLong or newShort, "Crosswind Any Signal", "Crosswind signal fired")
alertcondition(hitStop, "Crosswind Stop Or Trail Hit", "Crosswind stop hit")
alertcondition(trailOn and not trailOn[1], "Crosswind Trail Armed", "Crosswind trail is now active")
````
