# Volume Truth Engine V1 [ViZ]

- url: https://www.tradingview.com/script/yj8g7DJx-Volume-Truth-Engine-V1-ViZ/
- type: indicator
- pine_id: PUB;65eabc044b504a65934fd4049c6ed3ea
- version: 2.0

## Description

[b]Volume Truth Engine — Publication Description[/b]
═══════════════════════════════════════

Most volume indicators tell you when volume is high.

This one tells you where it's coming from, whether it's being absorbed, and whether the higher timeframe agrees.

═══════════════════════════════════════

[b]WHAT MAKES THIS DIFFERENT[/b]

Real directional volume Instead of treating volume as a single number per bar, the indicator pulls lower-timeframe data and splits each bar into estimated buy-side and sell-side participation. The difference is delta — and it's the foundation everything else is built on. Most TradingView volume indicators don't do this. The ones that claim to usually use candle-body proxies, which aren't the same thing.

Higher-timeframe confluence, built in Every signal is checked against the higher timeframe automatically. 15m maps to 1H, 1H to 4H, 4H to Daily, and so on. When the HTF agrees with what's happening on your chart, signals are stronger. When it doesn't, you can choose to filter those signals out, flag them with a warning, or score them lower. No more taking "perfect" entries that fight the bigger trend.

The indicator measures its own performance Most indicators imply quality. This one proves it — or admits when it doesn't. A live hit-rate tracker shows whether absorption and spike signals actually predict price movement (1 ATR within 10 bars) on your specific instrument and timeframe. If a signal type underperforms on what you trade, you'll see it. That's rare on TradingView, and it's intentional.

═══════════════════════════════════════

[b]THE SIGNALS[/b]

Trend Flip Arrows — teal and orange triangles Real direction changes, not chop. Require ATR-distance confirmation before firing.

Absorption Diamonds — lime and red [b]ABS[/b] markers The highest-value signal. Price at a swing extreme while delta and volume disagree with the price direction — sellers exhausted at lows, buyers exhausted at highs. Reversal-watch, not reversal-guarantee.

Effort vs. Result — yellow EvR X-marks High volume, small body. Orders being absorbed without price movement. Often precedes reversals at extremes or breakouts at compression points.

Classified Spikes — three types, not one

• [b]BRK [/b]— with-trend breakout spike. Continuation. • [b]CLX[/b] — against-trend climactic spike at extreme. Exhaustion. • [b]ABS[/b] — high-volume small-body absorption spike. Institutional soak.

Confluence Scores — 0/5 to 5/5 next to absorption signals Higher score, higher conviction. A 5/5 means HTF agrees, chart agrees, volume elevated, delta confirms, and location aligns.

═══════════════════════════════════════

[b]HOW TO USE IT[/b]

In a strong trend (chart and HTF aligned) Trust with-trend BRK spikes on pullbacks. Watch CLX spikes near extremes as exhaustion warnings. High-conviction absorption only in the trend direction.

In a range or consolidation Absorption signals at range extremes are your highest-value entries. EvR inside the range often precedes the breakout. Don't chase trend flips here — wait for the state to hold.

When chart and HTF conflict ("CONFLICT ⚠" in the panel) Reduce size or stand aside. Counter-HTF signals historically produce lower-quality outcomes.

Around news and session opens The volume math assumes normal participation. First few bars after major releases can produce signals that reflect news shock rather than order flow. Use discretion.

═══════════════════════════════════════

[b]THE STATS PANEL[/b]

Four sections, scannable in under two seconds.

• Trend Context — chart state, HTF state, and whether they agree • Order Flow — bar delta, ratio, cumulative delta, data source • Volume — Z-Vol with spike flag • Signal Quality — live hit-rate per signal type

Cumulative delta is worth watching specifically. Rising on sideways price means hidden accumulation. Falling on rising price means hidden distribution. The chart hides this. The panel doesn't.

═══════════════════════════════════════

[b]A NOTE ON TRANSPARENCY[/b]

Hit-rate numbers display only after 20 samples accumulate. Before that, the panel shows "building (X/20)" so you know it's tracking but not yet meaningful. The measurement criterion (1 ATR within 10 bars) is one specific definition of success — directional follow-through within a short window. It doesn't measure P&L and doesn't capture slow-developing setups. Treat it as relative quality across signal types, not as a literal edge metric.

If a signal type consistently underperforms on your instrument, that's real information. Adjust accordingly.

═══════════════════════════════════════

[b]HONEST CAVEATS[/b]

The lower-timeframe delta is an approximation, not real tick-by-tick order flow. It's much better than candle-body proxies but it isn't institutional-grade. Volume data quality varies by exchange — forex tick volume in particular is broker-aggregated, not true volume.

This is a decision aid, not a trading system. It surfaces context. The trade decisions are still yours.

═══════════════════════════════════════

[b]WHAT TO DO FIRST[/b]

Load it on an instrument and timeframe you know well. Don't change any settings. Watch how the signals behave on bars you already understand — the breakout from last week, the reversal that caught you off-guard. See whether the indicator agrees with your read or surfaces something you missed.

After a few sessions, the hit-rate tracker will start producing real numbers. That's when the indicator starts working for you specifically.

Or if you want just open Bar Replay in different markets within different market regimes on different timeframes.

Feedback welcome in the comments. Include instrument, timeframe, and screenshot when reporting issues.

Happy trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ViZiV

//@version=6
indicator("Volume Truth Engine V1 [ViZ]", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=1000)

// ============================================================================
// VOLUME TRUTH ENGINE v2
// Adds: HTF confluence, volatility-adaptive thresholds, confluence scoring,
// signal hit-rate tracking.
// ============================================================================


// ============================================================
// SECTION 1: INPUTS
// ============================================================

grpTrend       = "Trend Engine"
trendMode      = input.string("VWMA Trend", "Trend Mode", options=["VWMA Trend", "Anchored VWAP", "Order-Flow Momentum"], group=grpTrend)
trendLength    = input.int(50, "Trend Length", minval=5, group=grpTrend)
vwapAnchor     = input.string("Session", "VWAP Anchor", options=["Session", "Week", "Month"], group=grpTrend)
useAtrFilter   = input.bool(true, "Require ATR-distance confirmation", group=grpTrend)
atrMult        = input.float(0.25, "ATR Distance Multiplier", minval=0.0, step=0.05, group=grpTrend)
confirmOnClose = input.bool(true, "Confirm signals on bar close only", group=grpTrend)

grpVol         = "Volume Engine"
volLookback    = input.int(20, "Volume Lookback", minval=5, group=grpVol)
zSpikeThresh   = input.float(2.0, "Spike Z-Score Threshold", minval=0.5, step=0.1, group=grpVol)
swingLookback  = input.int(20, "Swing Lookback", minval=5, group=grpVol)
swingProx      = input.float(0.5, "Swing Proximity (ATR)", minval=0.1, step=0.1, group=grpVol)

grpAdapt       = "Adaptive Thresholds"
useAdaptive    = input.bool(true, "Use Volatility-Adaptive Thresholds", group=grpAdapt, tooltip="Replaces fixed thresholds with rolling percentiles for self-tuning across instruments.")
adaptLookback  = input.int(100, "Adaptive Lookback", minval=30, group=grpAdapt, tooltip="Bars used for percentile calculation. Longer = more stable, shorter = more reactive.")

grpDelta       = "Delta Engine"
deltaMode      = input.string("Auto LTF", "Delta Source", options=["Auto LTF", "Manual LTF", "Candle Proxy"], group=grpDelta)
manualLtf      = input.timeframe("1", "Manual Lower Timeframe", group=grpDelta)
cumDeltaReset  = input.string("Session", "Cumulative Delta Reset", options=["Session", "Day", "Week", "Never"], group=grpDelta)

grpHtf         = "Higher-Timeframe Confluence"
useHtf         = input.bool(true, "Enable HTF Confluence", group=grpHtf)
htfMode        = input.string("Auto", "HTF Mode", options=["Auto", "Manual"], group=grpHtf)
manualHtf      = input.timeframe("60", "Manual Higher Timeframe", group=grpHtf)
htfFilter      = input.string("Soft", "HTF Filter Mode", options=["Off", "Soft", "Strict"], group=grpHtf, tooltip="Off = all signals show. Soft = against-HTF signals shown with warning marker. Strict = against-HTF signals suppressed entirely.")

grpScore       = "Confluence Scoring"
showScores     = input.bool(true, "Show Confluence Score Labels", group=grpScore)
minScoreShow   = input.int(0, "Minimum Score to Display", minval=0, maxval=5, group=grpScore, tooltip="Hide signals below this confluence score. 0 = show all.")

grpHitRate     = "Signal Hit-Rate Tracking"
useHitRate     = input.bool(true, "Track Signal Hit Rates", group=grpHitRate)
hitRateBars    = input.int(10, "Outcome Window (bars)", minval=3, group=grpHitRate)
hitRateMaxN    = input.int(50, "Rolling Sample Size", minval=10, maxval=200, group=grpHitRate)

grpSig         = "Signal Display"
showTrendFlips = input.bool(true, "Show Trend Flip Arrows", group=grpSig)
showAbsorption = input.bool(true, "Show Absorption Signals", group=grpSig)
showEffort     = input.bool(true, "Show Effort vs Result", group=grpSig)
showSpikes     = input.bool(true, "Show Classified Spikes", group=grpSig)
showVolConf    = input.bool(false, "Show Volume Confirmation Dots", group=grpSig)
colorBars      = input.bool(true, "Color Bars by Trend State", group=grpSig)

grpPanel       = "Data Panel"
showPanel      = input.bool(true, "Show Stats Panel", group=grpPanel)
panelLoc       = input.string("Top Right", "Panel Location", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpPanel)


// ============================================================
// SECTION 2: ADAPTIVE TIMEFRAME MAPPING (LTF & HTF)
// ============================================================

chartTfSec   = timeframe.in_seconds(timeframe.period)
targetLtfSec = math.max(chartTfSec / 20, 60)

autoLtf = targetLtfSec <= 60 ? "1" : targetLtfSec <= 180 ? "3" : targetLtfSec <= 300 ? "5" : targetLtfSec <= 900 ? "15" : targetLtfSec <= 1800 ? "30" : targetLtfSec <= 3600 ? "60" : targetLtfSec <= 14400 ? "240" : "D"

manualLtfSec   = timeframe.in_seconds(manualLtf)
manualLtfValid = manualLtfSec > 0 and manualLtfSec < chartTfSec
ltfToUse       = deltaMode == "Manual LTF" and manualLtfValid ? manualLtf : autoLtf

autoHtf = chartTfSec <= 60 ? "15" : chartTfSec <= 300 ? "30" : chartTfSec <= 900 ? "60" : chartTfSec <= 3600 ? "240" : chartTfSec <= 14400 ? "D" : "W"

manualHtfSec   = timeframe.in_seconds(manualHtf)
manualHtfValid = manualHtfSec > chartTfSec
htfToUse       = htfMode == "Manual" and manualHtfValid ? manualHtf : autoHtf


// ============================================================
// SECTION 3: CORE CALCS
// ============================================================

atr14    = ta.atr(14)
body     = math.abs(close - open)
barRange = high - low
isUp     = close > open
isDown   = close < open

volMean  = ta.sma(volume, volLookback)
volStdev = ta.stdev(volume, volLookback)
zVol     = volStdev > 0 ? (volume - volMean) / volStdev : 0.0
rVol     = volMean  > 0 ? volume / volMean : 1.0

bodyRatio = barRange > 0 ? body / barRange : 0.0


// ============================================================
// SECTION 4: ADAPTIVE THRESHOLDS
// ============================================================

smallBodyThresh = useAdaptive ? ta.percentile_linear_interpolation(bodyRatio, adaptLookback, 30) : 0.35
largeBodyThresh = useAdaptive ? ta.percentile_linear_interpolation(bodyRatio, adaptLookback, 70) : 0.60

absDeltaRatio    = 0.0
deltaThreshAdapt = 0.0


// ============================================================
// SECTION 5: TREND LINE
// ============================================================

vwmaLine = ta.vwma(close, trendLength)

isIntraday    = timeframe.isintraday
sessionAnchor = isIntraday ? session.isfirstbar : timeframe.change("W")
weekAnchor    = timeframe.change("W")
monthAnchor   = timeframe.change("M")

anchorCondition = vwapAnchor == "Session" ? sessionAnchor : vwapAnchor == "Week" ? weekAnchor : monthAnchor

var float vwapNum = na
var float vwapDen = na
if anchorCondition or na(vwapNum)
    vwapNum := 0.0
    vwapDen := 0.0
vwapNum += hlc3 * volume
vwapDen += volume
anchoredVwap = vwapDen > 0 ? vwapNum / vwapDen : close

bodyAvg = ta.sma(body, trendLength)

float trendLine = na
if trendMode == "VWMA Trend"
    trendLine := vwmaLine
else if trendMode == "Anchored VWAP"
    trendLine := anchoredVwap


// ============================================================
// SECTION 6: DELTA ENGINE
// ============================================================

[ltfCloseArr, ltfOpenArr, ltfVolArr] = request.security_lower_tf(syminfo.tickerid, ltfToUse, [close, open, volume])

f_ltfDelta() =>
    float buyV  = 0.0
    float sellV = 0.0
    sz = array.size(ltfCloseArr)
    if sz > 0
        for i = 0 to sz - 1
            c = array.get(ltfCloseArr, i)
            o = array.get(ltfOpenArr,  i)
            v = array.get(ltfVolArr,   i)
            if c > o
                buyV += v
            else if c < o
                sellV += v
            else
                buyV  += v / 2
                sellV += v / 2
    [buyV, sellV]

[ltfBuy, ltfSell] = f_ltfDelta()

proxyDelta = barRange > 0 ? volume * (2 * close - high - low) / barRange : 0.0
proxyBuy   = (volume + proxyDelta) / 2
proxySell  = (volume - proxyDelta) / 2

useProxy   = deltaMode == "Candle Proxy" or array.size(ltfCloseArr) == 0

buyVol     = useProxy ? proxyBuy  : ltfBuy
sellVol    = useProxy ? proxySell : ltfSell
barDelta   = buyVol - sellVol
deltaRatio = (buyVol + sellVol) > 0 ? barDelta / (buyVol + sellVol) : 0.0

absDR            = math.abs(deltaRatio)
deltaThreshAdapt := useAdaptive ? ta.percentile_linear_interpolation(absDR, adaptLookback, 70) : 0.2
deltaThreshUse   = math.max(deltaThreshAdapt, 0.1)

resetCumDelta = cumDeltaReset == "Session" ? sessionAnchor : cumDeltaReset == "Day" ? timeframe.change("D") : cumDeltaReset == "Week" ? timeframe.change("W") : false

var float cumDelta = 0.0
if resetCumDelta
    cumDelta := 0.0
cumDelta += barDelta


// ============================================================
// SECTION 7: TREND STATE MACHINE
// ============================================================

priceAbove = trendMode == "Order-Flow Momentum" ? (isUp and body > bodyAvg) : (not na(trendLine) and close > trendLine)
priceBelow = trendMode == "Order-Flow Momentum" ? (isDown and body > bodyAvg) : (not na(trendLine) and close < trendLine)

atrOk_up = not useAtrFilter or na(trendLine) or (close - trendLine) > atrMult * atr14
atrOk_dn = not useAtrFilter or na(trendLine) or (trendLine - close) > atrMult * atr14

deltaBull = deltaRatio >  0.1
deltaBear = deltaRatio < -0.1

var int trendState = 0
int newState = trendState
if priceAbove and atrOk_up
    newState := deltaBull ? 2 : 1
else if priceBelow and atrOk_dn
    newState := deltaBear ? -2 : -1

if confirmOnClose
    if barstate.isconfirmed
        trendState := newState
else
    trendState := newState

prevState   = nz(trendState[1], 0)
trendFlipUp = trendState > 0 and prevState <= 0 and prevState != trendState
trendFlipDn = trendState < 0 and prevState >= 0 and prevState != trendState


// ============================================================
// SECTION 8: HTF STATE
// ============================================================

f_htfState() =>
    htfVwma   = ta.vwma(close, 50)
    htfDelta  = barRange > 0 ? volume * (2 * close - high - low) / barRange : 0.0
    htfDRatio = volume > 0 ? htfDelta / volume : 0.0
    htfAbove  = close > htfVwma
    htfBelow  = close < htfVwma
    htfBull   = htfDRatio >  0.1
    htfBear   = htfDRatio < -0.1
    int st = 0
    if htfAbove
        st := htfBull ?  2 :  1
    else if htfBelow
        st := htfBear ? -2 : -1
    st

htfStateRaw = request.security(syminfo.tickerid, htfToUse, f_htfState(), lookahead=barmerge.lookahead_off)
htfState    = useHtf ? nz(htfStateRaw[1], 0) : 0

htfBullish = htfState > 0
htfBearish = htfState < 0


// ============================================================
// SECTION 9: ABSORPTION / DIVERGENCE
// ============================================================

swingHigh = ta.highest(high, swingLookback)
swingLow  = ta.lowest(low,  swingLookback)
nearHigh  = (swingHigh - close) <= swingProx * atr14
nearLow   = (close - swingLow)  <= swingProx * atr14

bullAbsorptionRaw = nearLow  and deltaRatio >  deltaThreshUse and zVol > 1.0
bearAbsorptionRaw = nearHigh and deltaRatio < -deltaThreshUse and zVol > 1.0

smallBody         = bodyRatio < smallBodyThresh
largeBody         = bodyRatio > largeBodyThresh
effortNoResultRaw = smallBody and zVol > 1.5


// ============================================================
// SECTION 10: SPIKE CLASSIFICATION
// ============================================================

isSpike       = zVol >= zSpikeThresh
closeNearHigh = barRange > 0 and (high - close) / barRange < 0.25
closeNearLow  = barRange > 0 and (close - low)  / barRange < 0.25

breakoutSpikeUpRaw = isSpike and isUp   and largeBody and closeNearHigh and trendState > 0
breakoutSpikeDnRaw = isSpike and isDown and largeBody and closeNearLow  and trendState < 0

climaxSpikeUpRaw = isSpike and isUp   and largeBody and nearHigh and trendState <= 0
climaxSpikeDnRaw = isSpike and isDown and largeBody and nearLow  and trendState >= 0

absorbSpikeHiRaw = isSpike and smallBody and nearHigh
absorbSpikeLoRaw = isSpike and smallBody and nearLow


// ============================================================
// SECTION 11: CONFLUENCE SCORING
// ============================================================

f_confluenceScore(int sigDir) =>
    int sc = 0
    if useHtf and ((sigDir > 0 and htfBullish) or (sigDir < 0 and htfBearish))
        sc += 1
    if (sigDir > 0 and trendState > 0) or (sigDir < 0 and trendState < 0)
        sc += 1
    if zVol > 1.0
        sc += 1
    if (sigDir > 0 and deltaRatio > 0.1) or (sigDir < 0 and deltaRatio < -0.1)
        sc += 1
    if (sigDir > 0 and nearLow) or (sigDir < 0 and nearHigh)
        sc += 1
    sc

f_htfPasses(int sigDir) =>
    bool passes = true
    if useHtf and htfFilter == "Strict"
        passes := (sigDir > 0 and not htfBearish) or (sigDir < 0 and not htfBullish)
    passes

bullAbsorption = bullAbsorptionRaw and f_htfPasses( 1) and f_confluenceScore( 1) >= minScoreShow
bearAbsorption = bearAbsorptionRaw and f_htfPasses(-1) and f_confluenceScore(-1) >= minScoreShow
effortBull     = effortNoResultRaw and nearLow  and f_htfPasses( 1) and f_confluenceScore( 1) >= minScoreShow
effortBear     = effortNoResultRaw and nearHigh and f_htfPasses(-1) and f_confluenceScore(-1) >= minScoreShow
effortNeutral  = effortNoResultRaw and not nearLow and not nearHigh

breakoutSpikeUp = breakoutSpikeUpRaw and f_htfPasses( 1)
breakoutSpikeDn = breakoutSpikeDnRaw and f_htfPasses(-1)
climaxSpikeUp   = climaxSpikeUpRaw   and f_htfPasses(-1)
climaxSpikeDn   = climaxSpikeDnRaw   and f_htfPasses( 1)
absorbSpikeHi   = absorbSpikeHiRaw   and f_htfPasses(-1)
absorbSpikeLo   = absorbSpikeLoRaw   and f_htfPasses( 1)

softWarnBull = useHtf and htfFilter == "Soft" and htfBearish and (bullAbsorptionRaw or effortBull or breakoutSpikeUpRaw or climaxSpikeDnRaw or absorbSpikeLoRaw)
softWarnBear = useHtf and htfFilter == "Soft" and htfBullish and (bearAbsorptionRaw or effortBear or breakoutSpikeDnRaw or climaxSpikeUpRaw or absorbSpikeHiRaw)


// ============================================================
// SECTION 12: HIT-RATE TRACKER
// ============================================================

var array<int>   absSigBars   = array.new<int>()
var array<int>   absSigDir    = array.new<int>()
var array<float> absSigPrice  = array.new<float>()
var array<float> absSigAtr    = array.new<float>()

var array<int>   spikeSigBars  = array.new<int>()
var array<int>   spikeSigDir   = array.new<int>()
var array<float> spikeSigPrice = array.new<float>()
var array<float> spikeSigAtr   = array.new<float>()

var int absWins   = 0
var int absLosses = 0
var int spkWins   = 0
var int spkLosses = 0

f_registerSignal(array<int> bars, array<int> dirs, array<float> prices, array<float> atrs, int dir) =>
    array.push(bars,   bar_index)
    array.push(dirs,   dir)
    array.push(prices, close)
    array.push(atrs,   atr14)
    if array.size(bars) > hitRateMaxN * 2
        array.shift(bars)
        array.shift(dirs)
        array.shift(prices)
        array.shift(atrs)

if useHitRate and barstate.isconfirmed
    if bullAbsorption
        f_registerSignal(absSigBars, absSigDir, absSigPrice, absSigAtr,  1)
    if bearAbsorption
        f_registerSignal(absSigBars, absSigDir, absSigPrice, absSigAtr, -1)
    if breakoutSpikeUp or climaxSpikeDn or absorbSpikeLo
        f_registerSignal(spikeSigBars, spikeSigDir, spikeSigPrice, spikeSigAtr,  1)
    if breakoutSpikeDn or climaxSpikeUp or absorbSpikeHi
        f_registerSignal(spikeSigBars, spikeSigDir, spikeSigPrice, spikeSigAtr, -1)

rollingHigh = ta.highest(high, hitRateBars + 1)
rollingLow  = ta.lowest(low,  hitRateBars + 1)

f_processQueue(array<int> bars, array<int> dirs, array<float> prices, array<float> atrs, float rHi, float rLo) =>
    int wins   = 0
    int losses = 0
    while array.size(bars) > 0 and (bar_index - array.get(bars, 0)) >= hitRateBars
        sigDir2 = array.get(dirs,   0)
        sigPx   = array.get(prices, 0)
        sigAtr2 = array.get(atrs,   0)
        moveUp    = rHi - sigPx
        moveDn    = sigPx - rLo
        favorable = sigDir2 > 0 ? moveUp : moveDn
        adverse   = sigDir2 > 0 ? moveDn : moveUp
        if adverse >= sigAtr2 and adverse > favorable
            losses += 1
        else if favorable >= sigAtr2
            wins += 1
        else
            losses += 1
        array.shift(bars)
        array.shift(dirs)
        array.shift(prices)
        array.shift(atrs)
    [wins, losses]

[aw, al] = f_processQueue(absSigBars,   absSigDir,   absSigPrice,   absSigAtr,   rollingHigh, rollingLow)
[sw, sl] = f_processQueue(spikeSigBars, spikeSigDir, spikeSigPrice, spikeSigAtr, rollingHigh, rollingLow)

if useHitRate and barstate.isconfirmed
    absWins   += aw
    absLosses += al
    spkWins   += sw
    spkLosses += sl

absTotal  = absWins + absLosses
spkTotal  = spkWins + spkLosses
absHitPct = absTotal > 0 ? 100.0 * absWins / absTotal : 0.0
spkHitPct = spkTotal > 0 ? 100.0 * spkWins / spkTotal : 0.0


// ============================================================
// SECTION 13: BAR COLOR
// ============================================================

stateColor = trendState == 2 ? color.new(color.lime, 0) : trendState == 1 ? color.new(color.lime, 50) : trendState == -1 ? color.new(color.red, 50) : trendState == -2 ? color.new(color.red, 0) : color.new(color.gray, 50)

barcolor(colorBars ? stateColor : na)


// ============================================================
// SECTION 14: TREND LINE PLOT
// ============================================================

plot(trendMode == "VWMA Trend"    ? vwmaLine     : na, "VWMA",          color=color.new(color.blue,   0), linewidth=2)
plot(trendMode == "Anchored VWAP" ? anchoredVwap : na, "Anchored VWAP", color=color.new(color.purple, 0), linewidth=2)


// ============================================================
// SECTION 15: SIGNAL PLOTS
// ============================================================

plotshape(showTrendFlips and trendFlipUp, "Trend Flip Up",   shape.triangleup,   location.belowbar, color.teal,   size=size.small)
plotshape(showTrendFlips and trendFlipDn, "Trend Flip Down", shape.triangledown, location.abovebar, color.orange, size=size.small)

plotshape(showAbsorption and bullAbsorption, "Bull Absorption", shape.diamond, location.belowbar, color.new(color.lime, 0), size=size.small, text="ABS")
plotshape(showAbsorption and bearAbsorption, "Bear Absorption", shape.diamond, location.abovebar, color.new(color.red,  0), size=size.small, text="ABS")

plotshape(showEffort and effortBull,    "Effort Bull",    shape.xcross, location.belowbar, color.new(color.yellow, 0), size=size.tiny, text="EvR")
plotshape(showEffort and effortBear,    "Effort Bear",    shape.xcross, location.abovebar, color.new(color.yellow, 0), size=size.tiny, text="EvR")
plotshape(showEffort and effortNeutral, "Effort Neutral", shape.xcross, location.abovebar, color.new(color.gray, 30),  size=size.tiny, text="EvR")

plotshape(showSpikes and breakoutSpikeUp, "Breakout Spike Up", shape.labelup,   location.belowbar, color.new(color.green,   0), size=size.tiny, text="BRK", textcolor=color.white)
plotshape(showSpikes and breakoutSpikeDn, "Breakout Spike Dn", shape.labeldown, location.abovebar, color.new(color.maroon,  0), size=size.tiny, text="BRK", textcolor=color.white)
plotshape(showSpikes and climaxSpikeUp,   "Climax Up",         shape.labeldown, location.abovebar, color.new(color.orange,  0), size=size.tiny, text="CLX", textcolor=color.white)
plotshape(showSpikes and climaxSpikeDn,   "Climax Dn",         shape.labelup,   location.belowbar, color.new(color.orange,  0), size=size.tiny, text="CLX", textcolor=color.white)
plotshape(showSpikes and absorbSpikeHi,   "Absorb High",       shape.square,    location.abovebar, color.new(color.fuchsia, 0), size=size.tiny, text="ABS", textcolor=color.white)
plotshape(showSpikes and absorbSpikeLo,   "Absorb Low",        shape.square,    location.belowbar, color.new(color.fuchsia, 0), size=size.tiny, text="ABS", textcolor=color.white)

bullConf = showVolConf and isUp   and volume > volMean and not isSpike
bearConf = showVolConf and isDown and volume > volMean and not isSpike
plotshape(bullConf, "Bull Vol Conf", shape.circle, location.belowbar, color.new(color.green, 40), size=size.tiny)
plotshape(bearConf, "Bear Vol Conf", shape.circle, location.abovebar, color.new(color.red,   40), size=size.tiny)

plotshape(softWarnBull, "HTF Warning Bull", shape.flag, location.belowbar, color.new(color.yellow, 30), size=size.tiny)
plotshape(softWarnBear, "HTF Warning Bear", shape.flag, location.abovebar, color.new(color.yellow, 30), size=size.tiny)

if showScores and barstate.isconfirmed
    if bullAbsorption
        score = f_confluenceScore(1)
        label.new(bar_index, low - atr14 * 0.5, str.tostring(score) + "/5", style=label.style_none, textcolor=color.new(color.lime, 0), size=size.small)
    if bearAbsorption
        score = f_confluenceScore(-1)
        label.new(bar_index, high + atr14 * 0.5, str.tostring(score) + "/5", style=label.style_none, textcolor=color.new(color.red, 0), size=size.small)


// ============================================================
// SECTION 16: ALERTS
// ============================================================

// ── Dropdown alerts (TradingView "Create Alert" dialog) ────────────────────
alertcondition(trendFlipUp,
     title   = "Trend Flip Up",
     message = "Trend Flip Bullish — {{ticker}} ({{interval}}) | Price: {{close}}")

alertcondition(trendFlipDn,
     title   = "Trend Flip Down",
     message = "Trend Flip Bearish — {{ticker}} ({{interval}}) | Price: {{close}}")

alertcondition(bullAbsorption,
     title   = "Bullish Absorption",
     message = "Bullish Absorption at Lows — {{ticker}} ({{interval}}) | Price: {{close}} | Vol: {{volume}}")

alertcondition(bearAbsorption,
     title   = "Bearish Absorption",
     message = "Bearish Absorption at Highs — {{ticker}} ({{interval}}) | Price: {{close}} | Vol: {{volume}}")

alertcondition(effortBull or effortBear or effortNeutral,
     title   = "Effort vs Result",
     message = "Effort vs Result — {{ticker}} ({{interval}}) | High volume, small body | Price: {{close}}")

alertcondition(breakoutSpikeUp or breakoutSpikeDn,
     title   = "Breakout Spike",
     message = "Breakout Volume Spike — {{ticker}} ({{interval}}) | Price: {{close}} | Vol: {{volume}}")

alertcondition(climaxSpikeUp or climaxSpikeDn,
     title   = "Climax Spike",
     message = "Climactic Volume Spike — {{ticker}} ({{interval}}) | Price: {{close}} | Vol: {{volume}}")

alertcondition(absorbSpikeHi or absorbSpikeLo,
     title   = "Absorption Spike",
     message = "Absorption Volume Spike — {{ticker}} ({{interval}}) | Price: {{close}} | Vol: {{volume}}")


// ── Readable alerts (auto-fire on signal confirmation) ─────────────────────
f_alertMsg(string sigType, int score) =>
    sigType + " on " + syminfo.ticker + " (" + timeframe.period + ")" +
      "\nPrice: " + str.tostring(close, "#.#####") +
      "\nScore: " + str.tostring(score) + "/5" +
      "\nZ-Vol: " + str.tostring(zVol, "0.00") +
      "\nDelta: " + str.tostring(deltaRatio, "0.00")

if barstate.isconfirmed
    if trendFlipUp
        alert(f_alertMsg("Trend Flip Up", f_confluenceScore(1)), alert.freq_once_per_bar_close)
    if trendFlipDn
        alert(f_alertMsg("Trend Flip Down", f_confluenceScore(-1)), alert.freq_once_per_bar_close)
    if bullAbsorption
        alert(f_alertMsg("Bullish Absorption", f_confluenceScore(1)), alert.freq_once_per_bar_close)
    if bearAbsorption
        alert(f_alertMsg("Bearish Absorption", f_confluenceScore(-1)), alert.freq_once_per_bar_close)




// ============================================================
// SECTION 17: STATS PANEL
// ============================================================

panelPos = panelLoc == "Top Right" ? position.top_right : panelLoc == "Top Left" ? position.top_left : panelLoc == "Bottom Right" ? position.bottom_right : position.bottom_left

var table panel = table.new(panelPos, columns=2, rows=15, border_width=1, border_color=color.new(color.gray, 60), frame_color=color.new(color.gray, 40), frame_width=1)

cHeaderBg  = color.new(#1e2630, 0)
cHeaderTx  = color.new(#ffffff, 0)
cSectionBg = color.new(#2a3441, 0)
cSectionTx = color.new(#9ab0c8, 0)
cLabelBg   = color.new(#1a1f29, 0)
cLabelTx   = color.new(#c8d0db, 0)
cValueBg   = color.new(#252d3a, 0)
cValueTx   = color.new(#ffffff, 0)
cBullBg    = color.new(#0d4f2c, 0)
cBullTx    = color.new(#7fffa8, 0)
cBearBg    = color.new(#5c1a1a, 0)
cBearTx    = color.new(#ff9999, 0)
cNeutralBg = color.new(#3a3a3a, 0)
cNeutralTx = color.new(#cccccc, 0)
cWarnBg    = color.new(#5c4a0d, 0)
cWarnTx    = color.new(#ffd966, 0)

f_stateText(int st) =>
    st == 2 ? "STRONG UP" : st == 1 ? "Weak Up" : st == -1 ? "Weak Down" : st == -2 ? "STRONG DOWN" : "Neutral"

f_stateBg(int st) =>
    st ==  2 ? cBullBg : st ==  1 ? color.new(#1a5c3a, 0) : st == -1 ? color.new(#6e2222, 0) : st == -2 ? cBearBg : cNeutralBg

f_stateTx(int st) =>
    st > 0 ? cBullTx : st < 0 ? cBearTx : cNeutralTx

f_directionalBg(float v) =>
    v > 0 ? cBullBg : v < 0 ? cBearBg : cNeutralBg

f_directionalTx(float v) =>
    v > 0 ? cBullTx : v < 0 ? cBearTx : cNeutralTx

if showPanel and barstate.islast
    table.cell(panel, 0, 0, "VOLUME TRUTH", bgcolor=cHeaderBg, text_color=cHeaderTx, text_size=size.normal)
    table.cell(panel, 1, 0, syminfo.ticker + "  " + timeframe.period, bgcolor=cHeaderBg, text_color=cHeaderTx, text_size=size.normal)

    table.cell(panel, 0, 1, "── TREND CONTEXT ──", bgcolor=cSectionBg, text_color=cSectionTx, text_size=size.small)
    table.cell(panel, 1, 1, "", bgcolor=cSectionBg, text_color=cSectionTx)

    table.cell(panel, 0, 2, "Chart", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.normal)
    table.cell(panel, 1, 2, f_stateText(trendState), bgcolor=f_stateBg(trendState), text_color=f_stateTx(trendState), text_size=size.normal)

    table.cell(panel, 0, 3, "HTF " + (useHtf ? "(" + htfToUse + ")" : ""), bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.normal)
    table.cell(panel, 1, 3, useHtf ? f_stateText(htfState) : "DISABLED", bgcolor=useHtf ? f_stateBg(htfState) : cNeutralBg, text_color=useHtf ? f_stateTx(htfState) : cNeutralTx, text_size=size.normal)

    confluenceText = not useHtf ? "—" : (trendState > 0 and htfState > 0) ? "ALIGNED ▲" : (trendState < 0 and htfState < 0) ? "ALIGNED ▼" : (trendState == 0 or htfState == 0) ? "Mixed" : "CONFLICT ⚠"
    confluenceBg   = not useHtf ? cNeutralBg : (trendState > 0 and htfState > 0) ? cBullBg : (trendState < 0 and htfState < 0) ? cBearBg : (trendState == 0 or htfState == 0) ? cNeutralBg : cWarnBg
    confluenceTx   = not useHtf ? cNeutralTx : (trendState > 0 and htfState > 0) ? cBullTx : (trendState < 0 and htfState < 0) ? cBearTx : (trendState == 0 or htfState == 0) ? cNeutralTx : cWarnTx
    table.cell(panel, 0, 4, "Confluence", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.small)
    table.cell(panel, 1, 4, confluenceText, bgcolor=confluenceBg, text_color=confluenceTx, text_size=size.small)

    table.cell(panel, 0, 5, "── ORDER FLOW ──", bgcolor=cSectionBg, text_color=cSectionTx, text_size=size.small)
    table.cell(panel, 1, 5, "", bgcolor=cSectionBg, text_color=cSectionTx)

    table.cell(panel, 0, 6, "Bar Delta", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.small)
    table.cell(panel, 1, 6, str.tostring(barDelta, "#,###"), bgcolor=f_directionalBg(barDelta), text_color=f_directionalTx(barDelta), text_size=size.small)

    table.cell(panel, 0, 7, "Δ Ratio", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.small)
    table.cell(panel, 1, 7, str.tostring(deltaRatio, "0.00"), bgcolor=f_directionalBg(deltaRatio), text_color=f_directionalTx(deltaRatio), text_size=size.small)

    table.cell(panel, 0, 8, "Cumulative Δ", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.small)
    table.cell(panel, 1, 8, str.tostring(cumDelta, "#,###"), bgcolor=f_directionalBg(cumDelta), text_color=f_directionalTx(cumDelta), text_size=size.small)

    table.cell(panel, 0, 9, "Source", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.small)
    table.cell(panel, 1, 9, useProxy ? "Candle Proxy" : "LTF " + ltfToUse, bgcolor=cValueBg, text_color=cValueTx, text_size=size.small)

    table.cell(panel, 0, 10, "── VOLUME ──", bgcolor=cSectionBg, text_color=cSectionTx, text_size=size.small)
    table.cell(panel, 1, 10, "", bgcolor=cSectionBg, text_color=cSectionTx)

    zVolBg = zVol >= zSpikeThresh ? cWarnBg : zVol >= 1.0 ? color.new(#3a4a5c, 0) : cValueBg
    zVolTx = zVol >= zSpikeThresh ? cWarnTx : cValueTx
    table.cell(panel, 0, 11, "Z-Vol", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.small)
    table.cell(panel, 1, 11, str.tostring(zVol, "0.00") + (zVol >= zSpikeThresh ? "  SPIKE" : ""), bgcolor=zVolBg, text_color=zVolTx, text_size=size.small)

    table.cell(panel, 0, 12, "── SIGNAL QUALITY ──", bgcolor=cSectionBg, text_color=cSectionTx, text_size=size.small)
    table.cell(panel, 1, 12, "1 ATR / 10 bars", bgcolor=cSectionBg, text_color=cSectionTx, text_size=size.small)

    minSampleN = 20

    absDisplayText = not useHitRate ? "tracking off" : absTotal == 0 ? "no signals yet" : absTotal < minSampleN ? "building (" + str.tostring(absTotal) + "/" + str.tostring(minSampleN) + ")" : str.tostring(absHitPct, "0.0") + "%  (n=" + str.tostring(absTotal) + ")"
    absDisplayBg = not useHitRate or absTotal < minSampleN ? cNeutralBg : absHitPct >= 60 ? cBullBg : absHitPct >= 45 ? cValueBg : cBearBg
    absDisplayTx = not useHitRate or absTotal < minSampleN ? cNeutralTx : absHitPct >= 60 ? cBullTx : absHitPct >= 45 ? cValueTx : cBearTx

    table.cell(panel, 0, 13, "Absorption", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.small)
    table.cell(panel, 1, 13, absDisplayText, bgcolor=absDisplayBg, text_color=absDisplayTx, text_size=size.small)

    spkDisplayText = not useHitRate ? "tracking off" : spkTotal == 0 ? "no signals yet" : spkTotal < minSampleN ? "building (" + str.tostring(spkTotal) + "/" + str.tostring(minSampleN) + ")" : str.tostring(spkHitPct, "0.0") + "%  (n=" + str.tostring(spkTotal) + ")"
    spkDisplayBg = not useHitRate or spkTotal < minSampleN ? cNeutralBg : spkHitPct >= 60 ? cBullBg : spkHitPct >= 45 ? cValueBg : cBearBg
    spkDisplayTx = not useHitRate or spkTotal < minSampleN ? cNeutralTx : spkHitPct >= 60 ? cBullTx : spkHitPct >= 45 ? cValueTx : cBearTx

    table.cell(panel, 0, 14, "Spikes", bgcolor=cLabelBg, text_color=cLabelTx, text_size=size.small)
    table.cell(panel, 1, 14, spkDisplayText, bgcolor=spkDisplayBg, text_color=spkDisplayTx, text_size=size.small)
````
