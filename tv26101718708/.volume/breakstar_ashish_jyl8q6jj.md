# BreakStar - Ashish

- url: https://www.tradingview.com/script/jYl8q6JJ-BreakStar-Ashish/
- type: indicator
- pine_id: PUB;b0fa149c0f334f4992f767eabba9e6ae
- version: 1.0

## Description

BreakStar — Breakout & Morning/Evening Star Signal Filter

Two entry triggers, one unified label:
🟡 BUY (Breakout) — close above the N-bar highest close (close-based Donchian, not high/low — avoids wick-poisoning the channel) on above-average volume.
🟡 BUY (Morning Star) / 🔵 SELL (Evening Star) — classic 3-candle reversal: long directional candle → small star candle → confirmation candle closing ≥50% back into the first candle's body. The 50% penetration threshold is kept strict — it's the core of Bulkowski's documented 78%/71% historical reliability for these patterns.
Exit logic — ATR-tiered trailing stop:
Initial buffer → Chandelier trail (2.5×ATR) → Breakeven lock at 3×ATR profit → Tight trail at prior candle's low at 5×ATR profit. If an opposing reversal pattern fires while in profit, position closes immediately rather than waiting for the trail to catch up.
How to use it:
BreakStar is a first-pass filter, not a mechanical auto-trading system. Apply it to a pre-screened watchlist via Pine Screener. The resulting shortlist — typically 2-10 names per day — then goes through your own judgment layer.

That human layer is where the real edge lives, not in trading every signal blindly.

What it is not:
Not a trend-following MA system. Not a mean-reversion band tool. Blind continuous backtesting produces mediocre results on any single name — as it does for virtually any signal-based filter run without judgment or market-regime context.

## Source Code

````pine
// VOLTRA — Volume + Trend + Reversal Analytics (v9)
// Unified single BUY/SELL signal (Morning/Evening Star no longer gets a separate
// label/color — it's folded in as just another trigger source, shown in dashboard/tooltip
// instead of its own visual treatment). Star pattern tolerances relaxed: starBody2Mult
// loosened to 0.6, volume surge now informational-only for the star trigger (not a hard
// gate), penetration left untouched at 50% since that's the evidentiary core of the pattern.

//@version=6
indicator("VOLTRA", overlay=true, max_labels_count=500)

// ============================================================
// INPUTS
// ============================================================
g1 = "Breakout Core (close-based Donchian)"
donchianLen   = input.int(20, "Breakout Lookback (N-bar highest/lowest CLOSE)", group=g1, minval=5)
requireVolOnBreakout = input.bool(true, "Require Volume Surge to confirm breakout", group=g1)
cooldownBars  = input.int(3, "Min Bars Between Signals (cooldown)", group=g1, minval=0)

g2 = "Volume Engine"
volAvgLen      = input.int(20, "Volume Average Length", group=g2, minval=2)
volSurgeMult   = input.float(1.5, "Volume Surge Multiplier (x average)", group=g2, minval=1.0, step=0.1)

g3 = "Trade Management — Initial SL & Trail"
useTrailingInvalidation = input.bool(true, "Enable Trailing SL after entry", group=g3)
flagStopHit    = input.bool(true, "Flag if price closes back through invalidation level", group=g3)
atrLen              = input.int(14, "ATR Length", group=g3, minval=2)
initialSLBufferATR  = input.float(0.6, "Initial SL buffer below/above signal candle (x ATR)", group=g3, minval=0, step=0.1)
chandelierATRMult   = input.float(2.5, "Trailing SL distance from highest/lowest since entry (x ATR)", group=g3, minval=0.5, step=0.1)

g3b = "Trade Management — Profit Lock Tiers (ATR-based)"
useProfitLock     = input.bool(true, "Enable Profit Lock Tiers", group=g3b)
breakevenLockATR  = input.float(3.0, "Lock SL to breakeven once profit reaches this x ATR", group=g3b, minval=0.5, step=0.1)
tightenATR        = input.float(5.0, "Switch to TIGHT trail once profit reaches this x ATR", group=g3b, minval=0.5, step=0.1)
usePatternExit    = input.bool(true, "Force exit if opposing reversal pattern fires while in profit", group=g3b)
patternExitMinProfitATR = input.float(1.0, "Min profit (x ATR) required for pattern-exit override to apply", group=g3b, minval=0, step=0.1)

g4 = "Morning/Evening Star (high-conviction reversal trigger)"
useStarPattern   = input.bool(true, "Enable Morning/Evening Star Trigger", group=g4)
starTrendCtxLen  = input.int(8, "Bars Back to Confirm Genuine Prior Trend", group=g4, minval=3)
starBody1Mult    = input.float(1.0, "Candle 1 body must be >= this x avg body", group=g4, minval=0.5, step=0.1)
starBody2Mult    = input.float(0.6, "Candle 2 (star) body must be <= this x Candle 1 body (relaxed from 0.5)", group=g4, minval=0.1, step=0.1)
starPenetration  = input.float(0.5, "Candle 3 must close this % into Candle 1 body — kept at 50%, the evidentiary core of the pattern", group=g4, minval=0.1, maxval=1.0, step=0.05)
starVolInformational = input.bool(true, "Volume surge is informational only for star trigger (not a hard gate)", group=g4)

g4b = "Near-Miss Diagnostic (optional, off main signal path)"
showNearMiss = input.bool(false, "Show near-miss diagnostic labels", group=g4b)
nearMissPenetrationTolerance = input.float(15.0, "Only flag if penetration missed by <= this many points", group=g4b, minval=1, maxval=50)
nearMissCooldown = input.int(5, "Min bars between near-miss labels", group=g4b, minval=1)

g5 = "Reversal Pattern Detection (used ONLY for pattern-based forced exit, no standalone label)"
structLen   = input.int(21, "Equilibrium Lookback (HMA, internal use)", group=g5, minval=2)
dispLen     = input.int(21, "Dispersion Lookback (stdev, internal use)", group=g5, minval=2)
bandMult    = input.float(2.0, "Band Multiplier (internal use)", group=g5, minval=0.1, step=0.1)
wickBodyMult  = input.float(2.0, "Wick >= this x Body", group=g5, minval=1.0, step=0.1)
trendCtxLen   = input.int(5, "Bars Back to Judge Prior Micro-Trend", group=g5, minval=2)
engulfSizeMult = input.float(1.3, "Engulf range >= this x avg range", group=g5, minval=1.0, step=0.1)
extremeLookback = input.int(5, "Bars to confirm genuine fresh extreme", group=g5, minval=2)

g6 = "Visuals"
showDashboard = input.bool(false, "Show Dashboard Table", group=g6)
showLabels    = input.bool(true, "Show Labels", group=g6)

colBuy      = input.color(color.new(#FFD700, 0), "BUY/SELL (gold — all trigger sources unified)", group=g6)
colStop     = input.color(color.new(color.red, 0), "Stop-Hit Flag", group=g6)
colPatExit  = input.color(color.new(#FF8C00, 0), "Pattern Exit Flag", group=g6)
colNearMiss = input.color(color.new(#888888, 0), "Near-Miss Diagnostic (gray)", group=g6)

// ============================================================
// VOLUME + ATR
// ============================================================
volAvg   = ta.sma(volume, volAvgLen)
volRatio = volAvg > 0 ? volume / volAvg : 1.0
volSurge = volRatio >= volSurgeMult
atrVal   = ta.atr(atrLen)

// ============================================================
// BREAKOUT CORE — close-based Donchian
// ============================================================
upperDC = ta.highest(close, donchianLen)[1]
lowerDC = ta.lowest(close, donchianLen)[1]

rawBreakoutBull = close > upperDC and (not requireVolOnBreakout or volSurge)
rawBreakoutBear = close < lowerDC and (not requireVolOnBreakout or volSurge)

// ============================================================
// MORNING STAR / EVENING STAR DETECTION
// ============================================================
avgBody = ta.sma(math.abs(close - open), starTrendCtxLen)

c1Body   = math.abs(close[2] - open[2])
c1IsBear = close[2] < open[2]
c1IsBull = close[2] > open[2]
c1Mid    = (open[2] + close[2]) / 2

c2Body  = math.abs(close[1] - open[1])

c3IsBull = close > open
c3IsBear = close < open

priorDowntrend = close[2] < close[2 + starTrendCtxLen]
priorUptrend   = close[2] > close[2 + starTrendCtxLen]

chk_c1Long_bull      = c1Body >= starBody1Mult * avgBody
chk_c2Small_bull     = c2Body <= starBody2Mult * c1Body
chk_penetration_bull = close >= open[2] - (open[2] - close[2]) * starPenetration

isMorningStar = useStarPattern and c1IsBear and chk_c1Long_bull and chk_c2Small_bull and c3IsBull and priorDowntrend and chk_penetration_bull and (starVolInformational or volSurge)

chk_c1Long_bear      = c1Body >= starBody1Mult * avgBody
chk_c2Small_bear     = c2Body <= starBody2Mult * c1Body
chk_penetration_bear = close <= open[2] + (close[2] - open[2]) * (1 - starPenetration)

isEveningStar = useStarPattern and c1IsBull and chk_c1Long_bear and chk_c2Small_bear and c3IsBear and priorUptrend and chk_penetration_bear and (starVolInformational or volSurge)

starLow  = math.min(low[2], low[1], low)
starHigh = math.max(high[2], high[1], high)

// ============================================================
// NEAR-MISS DIAGNOSTIC (tightened — optional, doesn't touch main signal)
// ============================================================
nearMissCandidateBear = useStarPattern and c1IsBull and c3IsBear and priorUptrend and chk_c1Long_bear and chk_c2Small_bear and not isEveningStar
nearMissCandidateBull = useStarPattern and c1IsBear and c3IsBull and priorDowntrend and chk_c1Long_bull and chk_c2Small_bull and not isMorningStar

actualPenetrationBear = (open[2] - close[2]) != 0 ? (open[2] - close) / (open[2] - close[2]) * 100 : 0.0
actualPenetrationBull = (close[2] - open[2]) != 0 ? (close - open[2]) / (close[2] - open[2]) * 100 : 0.0

penetrationGapBear = (100 - starPenetration*100) - actualPenetrationBear
penetrationGapBull = (starPenetration*100) - actualPenetrationBull

isCloseCallBear = nearMissCandidateBear and not chk_penetration_bear and penetrationGapBear <= nearMissPenetrationTolerance and penetrationGapBear > 0
isCloseCallBull = nearMissCandidateBull and not chk_penetration_bull and penetrationGapBull <= nearMissPenetrationTolerance and penetrationGapBull > 0

coreShapeBear = isCloseCallBear
coreShapeBull = isCloseCallBull

var int barsSinceNearMiss = 999
nearMissOK = barsSinceNearMiss >= nearMissCooldown
if coreShapeBear or coreShapeBull
    barsSinceNearMiss := 0
else
    barsSinceNearMiss := barsSinceNearMiss + 1

nearMissReasonBear = "Penetration " + str.tostring(actualPenetrationBear, "#.0") + "% (need >=" + str.tostring(starPenetration*100, "#.0") + "%) — close call"
nearMissReasonBull = "Penetration " + str.tostring(actualPenetrationBull, "#.0") + "% (need >=" + str.tostring(starPenetration*100, "#.0") + "%) — close call"

// ============================================================
// REVERSAL PATTERN DETECTION — internal only, feeds pattern-exit, no standalone label
// ============================================================
eq      = ta.hma(close, structLen)
disp    = ta.stdev(close, dispLen)
upperBand = eq + bandMult * disp
lowerBand = eq - bandMult * disp

body      = math.abs(close - open)
range_    = high - low
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
isBullCandle = close > open
isBearCandle = close < open
isInsideBar  = high < high[1] and low > low[1]

priorDown = close[1] < close[trendCtxLen]
priorUp   = close[1] > close[trendCtxLen]

atUpperBand = high >= upperBand
atLowerBand = low  <= lowerBand

isFreshHigh = high >= ta.highest(high, extremeLookback)
isFreshLow  = low  <= ta.lowest(low, extremeLookback)

avgRange = ta.sma(range_, dispLen)
engulfSizeOK = avgRange > 0 and range_ >= engulfSizeMult * avgRange

isHammer        = lowerWick >= wickBodyMult * body and upperWick <= body and body > 0 and priorDown and atLowerBand and isFreshLow and not isInsideBar
isShootingStar  = upperWick >= wickBodyMult * body and lowerWick <= body and body > 0 and priorUp and atUpperBand and isFreshHigh and not isInsideBar
isBullEngulf    = isBullCandle and close[1] < open[1] and close > open[1] and open < close[1] and atLowerBand and engulfSizeOK
isBearEngulf    = isBearCandle and close[1] > open[1] and close < open[1] and open > close[1] and atUpperBand and engulfSizeOK

bearishReversalNow = isEveningStar or isShootingStar or isBearEngulf
bullishReversalNow = isMorningStar or isHammer or isBullEngulf

// ============================================================
// SIGNAL ARBITRATION + STATE + ATR-TIERED SL
// ============================================================
var int trendState          = 0
var int barsSinceFlip       = 999
var float invalidLevel      = na
var float highestSinceEntry = na
var float lowestSinceEntry  = na
var float entryPrice        = na
var string signalType       = ""
var string slTier           = "-"

canFlipBullStar = isMorningStar and trendState != 1 and barsSinceFlip >= cooldownBars
canFlipBearStar = isEveningStar and trendState != -1 and barsSinceFlip >= cooldownBars

canFlipBullBreakout = rawBreakoutBull and trendState != 1 and barsSinceFlip >= cooldownBars and not canFlipBullStar
canFlipBearBreakout = rawBreakoutBear and trendState != -1 and barsSinceFlip >= cooldownBars and not canFlipBearStar

canFlipBull = canFlipBullStar or canFlipBullBreakout
canFlipBear = canFlipBearStar or canFlipBearBreakout

if canFlipBull
    trendState := 1
    barsSinceFlip := 0
    invalidLevel := (canFlipBullStar ? starLow : low) - initialSLBufferATR * atrVal
    highestSinceEntry := high
    entryPrice := close
    signalType := canFlipBullStar ? "Morning Star" : "Breakout"
    slTier := "Initial"
else if canFlipBear
    trendState := -1
    barsSinceFlip := 0
    invalidLevel := (canFlipBearStar ? starHigh : high) + initialSLBufferATR * atrVal
    lowestSinceEntry := low
    entryPrice := close
    signalType := canFlipBearStar ? "Evening Star" : "Breakout"
    slTier := "Initial"
else
    barsSinceFlip := barsSinceFlip + 1

    if useTrailingInvalidation and trendState == 1
        highestSinceEntry := math.max(nz(highestSinceEntry, high), high)
        profitATR = (close - entryPrice) / atrVal
        chandelierStop = highestSinceEntry - chandelierATRMult * atrVal
        candidateStop = chandelierStop
        if useProfitLock and profitATR >= tightenATR
            candidateStop := math.max(candidateStop, close[1])
            slTier := "Tight (profit-lock)"
        else if useProfitLock and profitATR >= breakevenLockATR
            candidateStop := math.max(candidateStop, entryPrice)
            slTier := "Breakeven Lock"
        else
            slTier := "Trailing"
        invalidLevel := math.max(nz(invalidLevel, candidateStop), candidateStop)

    else if useTrailingInvalidation and trendState == -1
        lowestSinceEntry := math.min(nz(lowestSinceEntry, low), low)
        profitATR = (entryPrice - close) / atrVal
        chandelierStop = lowestSinceEntry + chandelierATRMult * atrVal
        candidateStop = chandelierStop
        if useProfitLock and profitATR >= tightenATR
            candidateStop := math.min(candidateStop, close[1])
            slTier := "Tight (profit-lock)"
        else if useProfitLock and profitATR >= breakevenLockATR
            candidateStop := math.min(candidateStop, entryPrice)
            slTier := "Breakeven Lock"
        else
            slTier := "Trailing"
        invalidLevel := math.min(nz(invalidLevel, candidateStop), candidateStop)

flippedThisBar = canFlipBull or canFlipBear

slBreach = flagStopHit and not flippedThisBar and ((trendState == 1 and close < invalidLevel) or (trendState == -1 and close > invalidLevel))

currentProfitATR = trendState == 1 ? (close - entryPrice) / atrVal : trendState == -1 ? (entryPrice - close) / atrVal : 0.0
patternExit = usePatternExit and not flippedThisBar and currentProfitATR >= patternExitMinProfitATR and ((trendState == 1 and bearishReversalNow) or (trendState == -1 and bullishReversalNow))

stopHit = slBreach or patternExit

if stopHit
    trendState := 0
    invalidLevel := na
    highestSinceEntry := na
    lowestSinceEntry := na
    entryPrice := na
    slTier := "-"

// ============================================================
// CANDLE COLORING — single unified gold for ANY trigger source
// ============================================================
candleColor = flippedThisBar ? colBuy : (isBullCandle ? color.new(color.green, 40) : color.new(color.red, 40))
barcolor(candleColor)

// ============================================================
// PLOTS
// ============================================================
plot(useTrailingInvalidation and trendState != 0 ? invalidLevel : na, "Invalidation Level (SL)", color=color.new(color.orange, 0), style=plot.style_circles, linewidth=2)

// ============================================================
// LABELS — ONE BUY/SELL label regardless of trigger source; source noted in tooltip text
// ============================================================
if showLabels and flippedThisBar
    label.new(bar_index, trendState == 1 ? low - (high-low)*0.6 : high + (high-low)*0.6, text = (trendState == 1 ? "▲ BUY ⚡" : "▼ SELL ⚡") + "\n(" + signalType + ")", style = trendState == 1 ? label.style_label_up : label.style_label_down, color = colBuy, textcolor = color.black, size = size.normal)

if showLabels and slBreach
    label.new(bar_index, close, text = "STOPPED", style = label.style_label_down, color = colStop, textcolor = color.white, size = size.small)

if showLabels and patternExit
    label.new(bar_index, close, text = "PATTERN EXIT (" + str.tostring(currentProfitATR, "#.#") + " ATR profit)", style = label.style_label_down, color = colPatExit, textcolor = color.white, size = size.small)

if showNearMiss and coreShapeBear and not flippedThisBar and nearMissOK
    label.new(bar_index, high + (high-low)*1.2, text = "Near-miss Evening Star:\n" + nearMissReasonBear, style = label.style_label_down, color = colNearMiss, textcolor = color.white, size = size.tiny)

if showNearMiss and coreShapeBull and not flippedThisBar and nearMissOK
    label.new(bar_index, low - (high-low)*1.2, text = "Near-miss Morning Star:\n" + nearMissReasonBull, style = label.style_label_up, color = colNearMiss, textcolor = color.white, size = size.tiny)

// ============================================================
// DASHBOARD
// ============================================================
if showDashboard and barstate.islast
    var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 70), border_width=1)
    table.cell(dash, 0, 0, "VOLTRA v9", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(dash, 1, 0, "", bgcolor=color.new(color.gray, 50))
    table.cell(dash, 0, 1, "Trend State", text_color=color.white)
    table.cell(dash, 1, 1, trendState == 1 ? "LONG" : trendState == -1 ? "SHORT" : "FLAT", text_color = trendState == 1 ? color.lime : trendState == -1 ? color.red : color.gray)
    table.cell(dash, 0, 2, "Signal Source", text_color=color.white)
    table.cell(dash, 1, 2, signalType == "" ? "-" : signalType, text_color=color.aqua)
    table.cell(dash, 0, 3, "SL Tier", text_color=color.white)
    table.cell(dash, 1, 3, slTier, text_color=color.orange)
    table.cell(dash, 0, 4, "Profit (x ATR)", text_color=color.white)
    table.cell(dash, 1, 4, trendState != 0 ? str.tostring(currentProfitATR, "#.##") : "-", text_color = currentProfitATR > 0 ? color.lime : color.red)
    table.cell(dash, 0, 5, "Volume vs Avg", text_color=color.white)
    table.cell(dash, 1, 5, str.tostring(volRatio, "#.##") + "x" + (volSurge ? " (SURGE)" : ""), text_color = volSurge ? color.lime : color.gray)
    table.cell(dash, 0, 6, "Invalidation (SL)", text_color=color.white)
    table.cell(dash, 1, 6, trendState != 0 ? str.tostring(invalidLevel, "#.##") : "-", text_color=color.orange)
    table.cell(dash, 0, 7, "Bars Since Flip", text_color=color.white)
    table.cell(dash, 1, 7, str.tostring(barsSinceFlip), text_color=color.gray)

// ============================================================
// ALERTS
// ============================================================
alertcondition(canFlipBullStar, "VOLTRA Buy (Morning Star)", "VOLTRA: Buy signal — Morning Star")
alertcondition(canFlipBearStar, "VOLTRA Sell (Evening Star)", "VOLTRA: Sell signal — Evening Star")
alertcondition(canFlipBullBreakout, "VOLTRA Buy (Breakout)", "VOLTRA: Buy signal — Breakout")
alertcondition(canFlipBearBreakout, "VOLTRA Sell (Breakout)", "VOLTRA: Sell signal — Breakout")
alertcondition(slBreach, "VOLTRA Stop Hit", "VOLTRA: Invalidation level breached")
alertcondition(patternExit, "VOLTRA Pattern Exit", "VOLTRA: Forced exit on opposing reversal pattern while in profit")
````
