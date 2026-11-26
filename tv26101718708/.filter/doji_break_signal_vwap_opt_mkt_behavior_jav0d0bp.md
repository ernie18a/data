# Doji Break Signal + VWAP + Opt Mkt Behavior

- url: https://www.tradingview.com/script/jAV0d0BP-Doji-Break-Signal-VWAP-Opt-Mkt-Behavior/
- type: indicator
- pine_id: PUB;9794e37df9ec435b93b5216739f53cfd
- version: 1.0

## Description

The Doji Break Signal + VWAP + Opt Mkt Behavior is a comprehensive TradingView indicator
built on Pine Script v6 that combines multiple analytical approaches into a single overlay tool.
Designed for active traders who need clear, actionable signals without switching between dozens
of separate indicators, it integrates Doji candlestick breakout logic, EMA stack analysis, VWAP
anchoring with standard deviation bands, engulfing pattern recognition, mean reversion detection,
and an innovative Options Market Behavior filter. The indicator operates in overlay mode, meaning
all visual elements render directly on your price chart without requiring a separate pane.
At its core, the indicator follows a structured philosophy: a Doji candle represents market
indecision, and when price breaks out of the Doji range, it signals the beginning of a directional
move. This simple yet powerful concept is enhanced by requiring EMA-based distance filters to
prevent entries when price is overextended, and optional VWAP filtering to ensure trades align with
institutional volume-weighted value. Beyond the primary Doji breakout signals, the indicator
provides six additional signal types — engulfing patterns, breakouts, pullbacks, reversions, fake
breakout warnings, and VWAP-specific signals — giving traders a complete toolkit for reading
market structure in real time.

## Source Code

````pine
//@version=6
indicator("Doji Break Signal + VWAP + Opt Mkt Behavior", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// =====================================================
// INPUTS
// =====================================================
dojiBodyPercent   = input.float(10,   "Doji Body % of Range", minval=1, maxval=50)
hardStopPoints    = input.float(15,   "Hard Stop Loss (points)")
exitOffsetPoints  = input.float(10,   "Exit Offset (points)")
ema30AtrLimitBuy  = input.float(2.5,  "Max EMA30 ATR Distance - BUY (+ve limit)")
ema30AtrLimitSell = input.float(-2.5, "Max EMA30 ATR Distance - SELL (-ve limit)")

enableBuy         = input.bool(true,  "Enable Buy Signals",    group="Signal Settings")
enableSell        = input.bool(true,  "Enable Sell Signals",   group="Signal Settings")

showPrices        = input.bool(true,  "Show Prices on Labels",  group="Label Settings")
showSignalLabels  = input.bool(true,  "Show Buy/Sell Labels",   group="Label Settings")
showExitLabels    = input.bool(true,  "Show Exit Labels",        group="Label Settings")
showAtrLabels     = input.bool(true,  "Show ATR Labels on EMAs", group="Label Settings")

showEngulfing     = input.bool(true,  "Show Engulfing Signals", group="Engulfing Settings")
reversalThreshold = input.float(80,   "Min Reversal Chance % for Strong Signal", minval=0, maxval=100, group="Engulfing Settings")
nearEmaAtrMult    = input.float(0.5,  "Near EMA5/10 ATR Multiple", minval=0.1, maxval=5, group="Engulfing Settings")

showTrendSignals       = input.bool(true,  "Show Breakout/Pullback Signals", group="Trend Signals")
breakoutBodyAtrMult    = input.float(1.2,  "Breakout Candle Min Body (xATR)", minval=0.1, maxval=5, group="Trend Signals")
pullbackMaxBodyAtrMult = input.float(0.8,  "Pullback Candle Max Body (xATR)", minval=0.1, maxval=5, group="Trend Signals")

showReversionSignals    = input.bool(true,  "Show Positive/Negative Reversion Signals", group="Reversion Signals")
minStretchAtrReversion  = input.float(1.5,  "Min |ATR30 Stretch| for Reversion", minval=0, group="Reversion Signals")
requireReversionConfirm = input.bool(true,  "Require Confirming Candle Close", group="Reversion Signals")
requireEma5Reclaim      = input.bool(true,  "Require Price Reclaim EMA5", group="Reversion Signals")
reversionCooldownBars   = input.int(5,      "Min Bars Between Reversion Signals", minval=0, group="Reversion Signals")

showFakeBreakout        = input.bool(true,  "Show Fake Breakout Signals", group="Fake Breakout")
fakeBreakoutLookback    = input.int(3,      "Bars to Confirm Fake Breakout", minval=1, maxval=20, group="Fake Breakout")

// =====================================================
// OPTIONS MARKET BEHAVIOR INPUTS
// =====================================================
showOptMktBehavior = input.bool(true, "Show Options Market Behavior", group="Options Market Behavior")
optAtrLongLen      = input.int(50,    "Baseline ATR Length (Slow)", minval=20, group="Options Market Behavior")
optBuyerThreshold  = input.float(1.3, "Buyer Mkt Trigger (Ratio > x)", step=0.1, group="Options Market Behavior", tooltip="If 14 ATR is 30% greater than Baseline ATR")
optSellerThreshold = input.float(0.8, "Seller Mkt Trigger (Ratio < x)", step=0.1, group="Options Market Behavior", tooltip="If 14 ATR is 20% less than Baseline ATR")

// =====================================================
// VWAP INPUTS
// =====================================================
showVwap          = input.bool(true,  "Show VWAP",                    group="VWAP Settings")
showVwapBands     = input.bool(true,  "Show VWAP Standard Deviation Bands",  group="VWAP Settings")
vwapSd1           = input.bool(true,  "Show 1 SD Band",                group="VWAP Settings")
vwapSd2           = input.bool(true,  "Show 2 SD Band",                group="VWAP Settings")
vwapSd3           = input.bool(false, "Show 3 SD Band",                group="VWAP Settings")
vwapBandOpacity   = input.int(90,     "Band Fill Opacity (0-100)",     minval=0, maxval=100, group="VWAP Settings")
vwapLineWidth     = input.int(2,      "VWAP Line Width",               minval=1, maxval=4, group="VWAP Settings")

showVwapSignals   = input.bool(true,  "Show VWAP Signals",             group="VWAP Signals")
vwapTouchAtrMult  = input.float(0.3,  "VWAP Touch Distance (xATR)",    minval=0.05, maxval=2, group="VWAP Signals")
vwapBounceConfirm = input.bool(true,  "Require Bounce Confirmation",   group="VWAP Signals")
vwapReversionSd   = input.float(2.0,  "VWAP Reversion Trigger (xSD)",  minval=1.0, maxval=4.0, group="VWAP Signals")
vwapSignalCooldown= input.int(5,      "Min Bars Between VWAP Signals", minval=0, group="VWAP Signals")

useVwapFilter     = input.bool(false, "Filter Doji Signals by VWAP",   group="VWAP Filter")
vwapFilterSide    = input.string("Both", "VWAP Filter Side", options=["Both", "Above Only", "Below Only"], group="VWAP Filter")

// =====================================================
// INDICATORS (compute once, reuse everywhere)
// =====================================================
ema5  = ta.ema(close, 5)
ema10 = ta.ema(close, 10)
ema20 = ta.ema(close, 20)
ema30 = ta.ema(close, 30)
atr14 = ta.atr(14)

// OPTIONS MARKET BEHAVIOR LOGIC
atrLong       = ta.atr(optAtrLongLen)
atrRatio      = atrLong > 0 ? atr14 / atrLong : 1.0
optMktState   = atrRatio >= optBuyerThreshold ? "BUYER" : atrRatio <= optSellerThreshold ? "SELLER" : "NEUTRAL"
optMktColor   = atrRatio >= optBuyerThreshold ? color.lime : atrRatio <= optSellerThreshold ? color.red : color.gray

// Multiplication is cheaper than division — precompute inverse once
invAtr = atr14 > 0 ? 1.0 / atr14 : 0.0

gap5  = close - ema5
gap10 = close - ema10
gap20 = close - ema20
gap30 = close - ema30

atrMult5  = gap5  * invAtr
atrMult10 = gap10 * invAtr
atrMult20 = gap20 * invAtr
atrMult30 = gap30 * invAtr

absAtrMult30 = math.abs(atrMult30)   // cached — used 4x later

// EMA stack min/max — compute once, reuse in engulfing + breakout + fake breakout
slowEmaMin = math.min(ema20, ema30)
slowEmaMax = math.max(ema20, ema30)
allEmaMin  = math.min(math.min(ema5, ema10), slowEmaMin)
allEmaMax  = math.max(math.max(ema5, ema10), slowEmaMax)

// Candle geometry — computed once, reused in doji + engulfing + breakout + pullback
candleRange = high - low
bodySize    = math.abs(close - open)
bullishBody = close > open
bearishBody = close < open

// =====================================================
// VWAP CALCULATION (True VWAP with Standard Deviation Bands)
// =====================================================
typicalPrice = hlc3
sumSrc  = ta.cum(typicalPrice * volume)
sumVol  = ta.cum(volume)
sumSrc2 = ta.cum(typicalPrice * typicalPrice * volume)

vwapValue = sumVol > 0 ? sumSrc / sumVol : close

// True VWAP standard deviation: sqrt(E[X^2] - E[X]^2)
vwapVariance = sumVol > 0 ? math.max(0, sumSrc2 / sumVol - vwapValue * vwapValue) : 0
vwapStdDev   = math.sqrt(vwapVariance)

vwapUpper1 = vwapValue + vwapStdDev
vwapLower1 = vwapValue - vwapStdDev
vwapUpper2 = vwapValue + 2 * vwapStdDev
vwapLower2 = vwapValue - 2 * vwapStdDev
vwapUpper3 = vwapValue + 3 * vwapStdDev
vwapLower3 = vwapValue - 3 * vwapStdDev

// VWAP distance in ATR terms
vwapGap     = close - vwapValue
vwapAtrMult = vwapGap * invAtr
absVwapAtrMult = math.abs(vwapAtrMult)

// VWAP touch detection
vwapTouchDist = vwapTouchAtrMult * atr14
touchedVwapFromAbove = low <= vwapValue + vwapTouchDist and low >= vwapValue - vwapTouchDist and close[1] > vwapValue
touchedVwapFromBelow = high >= vwapValue - vwapTouchDist and high <= vwapValue + vwapTouchDist and close[1] < vwapValue

// VWAP bounce signals
vwapBullBounce = touchedVwapFromBelow and (not vwapBounceConfirm or (bullishBody and close > vwapValue))
vwapBearBounce = touchedVwapFromAbove and (not vwapBounceConfirm or (bearishBody and close < vwapValue))

// VWAP reversion signals (price stretched beyond x SD and showing reversal)
stretchedAboveVwap = close > vwapValue + vwapReversionSd * vwapStdDev
stretchedBelowVwap = close < vwapValue - vwapReversionSd * vwapStdDev

vwapReversionLong  = stretchedBelowVwap and bullishBody and close > close[1] and close > vwapValue
vwapReversionShort = stretchedAboveVwap and bearishBody and close < close[1] and close < vwapValue

// VWAP signal cooldown
var int lastVwapBullBar = na
var int lastVwapBearBar = na

vwapBullSignal = vwapBullBounce and (na(lastVwapBullBar) or bar_index - lastVwapBullBar >= vwapSignalCooldown)
vwapBearSignal = vwapBearBounce and (na(lastVwapBearBar) or bar_index - lastVwapBearBar >= vwapSignalCooldown)

vwapRevLongSignal  = vwapReversionLong  and (na(lastVwapBullBar) or bar_index - lastVwapBullBar >= vwapSignalCooldown)
vwapRevShortSignal = vwapReversionShort and (na(lastVwapBearBar) or bar_index - lastVwapBearBar >= vwapSignalCooldown)

if vwapBullSignal or vwapRevLongSignal
    lastVwapBullBar := bar_index
if vwapBearSignal or vwapRevShortSignal
    lastVwapBearBar := bar_index

// VWAP filter for doji signals
vwapFilterPass = useVwapFilter ? (vwapFilterSide == "Both" or (vwapFilterSide == "Above Only" and close > vwapValue) or (vwapFilterSide == "Below Only" and close < vwapValue)) : true

// =====================================================
// REVERSAL CHANCE
// =====================================================
bullStack = ema5 > ema10 and ema10 > ema20 and ema20 > ema30
bearStack = ema5 < ema10 and ema10 < ema20 and ema20 < ema30
partStack = (ema5 > ema20 and ema10 > ema30) or (ema5 < ema20 and ema10 < ema30)
emaDirScore = bullStack or bearStack ? 25 : partStack ? 15 : 5

atrStretch25 = math.min(absAtrMult30 / 3.0, 1.0) * 25

ema510GapNow  = math.abs(ema5 - ema10)
ema510GapPrev = math.abs(ema5[1] - ema10[1])
momFadeScore  = ema510GapNow < ema510GapPrev ? 25 : 0

absBuyLimit  = math.abs(ema30AtrLimitBuy)
absSellLimit = math.abs(ema30AtrLimitSell)
buyLimitDist  = absBuyLimit  > 0 ? absAtrMult30 / absBuyLimit  : 0.0
sellLimitDist = absSellLimit > 0 ? absAtrMult30 / absSellLimit : 0.0
limitProx = math.min(math.max(buyLimitDist, sellLimitDist), 1.0) * 25

reversalScore          = math.min(math.round(emaDirScore + atrStretch25 + momFadeScore + limitProx), 100)
reversalAboveThreshold = reversalScore >= reversalThreshold

// =====================================================
// DOJI
// =====================================================
isDoji = candleRange > 0 and (bodySize / candleRange) * 100 <= dojiBodyPercent

// =====================================================
// ENGULFING
// =====================================================
prevBear = close[1] < open[1]
prevBull = close[1] > open[1]

bullishEngulf = bullishBody and prevBear and open <= close[1] and close >= open[1]
bearishEngulf = bearishBody and prevBull and open >= close[1] and close <= open[1]

nearFastEmaDist = math.min(math.abs(close - ema5), math.abs(close - ema10))
nearFastEmas    = nearFastEmaDist <= nearEmaAtrMult * atr14

bullishEngulfBelowEma = bullishEngulf and high < slowEmaMin and nearFastEmas
bearishEngulfAboveEma = bearishEngulf and low  > slowEmaMax and nearFastEmas

strongBullEngulf = bullishEngulfBelowEma and reversalAboveThreshold
strongBearEngulf = bearishEngulfAboveEma and reversalAboveThreshold

// =====================================================
// TREND CONTINUATION
// =====================================================
bodyAtrOk     = bodySize >= breakoutBodyAtrMult    * atr14
pullbackAtrOk = bodySize <= pullbackMaxBodyAtrMult * atr14

bullishBreakout = bullishBody and bodyAtrOk and low  <= allEmaMax and close > allEmaMax
bearishBreakout = bearishBody and bodyAtrOk and high >= allEmaMin and close < allEmaMin

emaTouch = (low <= ema10 and high >= ema10) or (low <= ema20 and high >= ema20)

bullishPullback = bullStack and emaTouch and pullbackAtrOk
bearishPullback = bearStack and emaTouch and pullbackAtrOk

// =====================================================
// REVERSION
// =====================================================
stretchOk = absAtrMult30 >= minStretchAtrReversion

positiveReversionRaw = atrMult30 < 0 and reversalAboveThreshold and stretchOk and (not requireReversionConfirm or (close > open and close > close[1])) and (not requireEma5Reclaim or close > ema5)
negativeReversionRaw = atrMult30 > 0 and reversalAboveThreshold and stretchOk and (not requireReversionConfirm or (close < open and close < close[1])) and (not requireEma5Reclaim or close < ema5)

var int lastPosRevBar = na
var int lastNegRevBar = na

positiveReversion = positiveReversionRaw and (na(lastPosRevBar) or bar_index - lastPosRevBar >= reversionCooldownBars)
negativeReversion = negativeReversionRaw and (na(lastNegRevBar) or bar_index - lastNegRevBar >= reversionCooldownBars)

if positiveReversion
    lastPosRevBar := bar_index
if negativeReversion
    lastNegRevBar := bar_index

// =====================================================
// FAKE BREAKOUT  (consolidated pending-state resets)
// =====================================================
var int  lastBullBreakoutBar = na
var int  lastBearBreakoutBar = na
var bool bullBreakoutPending = false
var bool bearBreakoutPending = false

if bullishBreakout
    lastBullBreakoutBar := bar_index
    bullBreakoutPending := true
if bearishBreakout
    lastBearBreakoutBar := bar_index
    bearBreakoutPending := true

barsSinceBull = bar_index - lastBullBreakoutBar
barsSinceBear = bar_index - lastBearBreakoutBar

fakeBullBreakout = bullBreakoutPending and barsSinceBull > 0 and barsSinceBull <= fakeBreakoutLookback and close < allEmaMax
fakeBearBreakout = bearBreakoutPending and barsSinceBear > 0 and barsSinceBear <= fakeBreakoutLookback and close > allEmaMin

if fakeBullBreakout or (bullBreakoutPending and barsSinceBull > fakeBreakoutLookback)
    bullBreakoutPending := false
if fakeBearBreakout or (bearBreakoutPending and barsSinceBear > fakeBreakoutLookback)
    bearBreakoutPending := false

// =====================================================
// DAY TRACKING
// =====================================================
newDay = ta.change(time("D")) != 0

var float dayTotalRange  = 0.0
var int   dayCandleCount = 0
var float dayHigh        = na
var float dayLow         = na

if newDay
    dayTotalRange  := 0.0
    dayCandleCount := 0
    dayHigh        := high
    dayLow         := low
else
    dayHigh := math.max(nz(dayHigh, high), high)
    dayLow  := math.min(nz(dayLow,  low),  low)

dayTotalRange  += candleRange
dayCandleCount += 1
currentDayAvgRange = dayCandleCount > 0 ? dayTotalRange / dayCandleCount : 0.0

// =====================================================
// DOJI STATE & DRAWINGS
// =====================================================
var float dHigh    = na
var float dLow     = na
var int   dBar     = na
var bool  buyUsed  = false
var bool  sellUsed = false

var line  ln044 = na
var line  ln05  = na
var line  ln618 = na
var label lb044 = na
var label lb05  = na
var label lb618 = na
var box   dBox  = na

if newDay
    buyUsed  := false
    sellUsed := false

if isDoji
    dHigh    := high
    dLow     := low
    dBar     := bar_index
    buyUsed  := false
    sellUsed := false

    fr     = dHigh - dLow
    lvl044 = dLow + fr * 0.44
    lvl05  = dLow + fr * 0.5
    lvl618 = dLow + fr * 0.618

    line.delete(ln044)
    line.delete(ln05)
    line.delete(ln618)
    label.delete(lb044)
    label.delete(lb05)
    label.delete(lb618)
    box.delete(dBox)

    ln044 := line.new(bar_index, lvl044, bar_index, lvl044, color=color.red,    width=1, style=line.style_dashed, extend=extend.right)
    ln05  := line.new(bar_index, lvl05,  bar_index, lvl05,  color=color.yellow, width=1, style=line.style_dashed, extend=extend.right)
    ln618 := line.new(bar_index, lvl618, bar_index, lvl618, color=color.green,  width=1, style=line.style_dashed, extend=extend.right)

    lb044 := label.new(bar_index, lvl044, "0.44",  color=color.new(color.red,    80), textcolor=color.red,    style=label.style_label_left, size=size.small)
    lb05  := label.new(bar_index, lvl05,  "0.5",   color=color.new(color.yellow, 80), textcolor=color.yellow, style=label.style_label_left, size=size.small)
    lb618 := label.new(bar_index, lvl618, "0.618", color=color.new(color.green,  80), textcolor=color.green,  style=label.style_label_left, size=size.small)

    dBox := box.new(bar_index, dHigh, bar_index, dLow, border_color=color.gray, border_width=1, bgcolor=color.new(color.gray, 85))

if not na(dBox)
    box.set_right(dBox, bar_index)
    if not na(lb044)
        label.set_x(lb044, bar_index)
        label.set_x(lb05,  bar_index)
        label.set_x(lb618, bar_index)

// =====================================================
// SIGNAL CONDITIONS (with VWAP filter)
// =====================================================
dojiActive = not na(dBar) and bar_index > dBar + 1

buySignal  = enableBuy  and dojiActive and not buyUsed  and high > dHigh and close > close[1] and atrMult30 < ema30AtrLimitBuy and vwapFilterPass
sellSignal = enableSell and dojiActive and not sellUsed and low  < dLow  and close < close[1] and atrMult30 > ema30AtrLimitSell and vwapFilterPass

if buySignal
    buyUsed := true
if sellSignal
    sellUsed := true

// =====================================================
// POSITION TRACKING
// =====================================================
var int   pos    = 0
var float ePrice = na
var float eDHigh = na
var float eDLow  = na
var int   eBar   = na

if buySignal
    pos := 1, ePrice := dHigh, eDHigh := dHigh, eDLow := dLow, eBar := bar_index
if sellSignal
    pos := -1, ePrice := dLow, eDHigh := dHigh, eDLow := dLow, eBar := bar_index

// =====================================================
// EXIT CONDITIONS (2-BAR CONFIRMATION)
// =====================================================
var bool   pendingLong   = false
var bool   pendingShort  = false
var string pendingReason = ""
var float  exitPriceLong  = na
var float  exitPriceShort = na
exitLong   = false
exitShort  = false
exitReason = ""

afterEntry = not na(eBar) and bar_index > eBar

if pos == 1 and afterEntry
    cond1 = close < eDHigh
    cond2 = low   < close[1] - exitOffsetPoints
    cond3 = low  <= ePrice   - hardStopPoints
    anyExit = cond1 or cond2 or cond3
    if anyExit
        if pendingLong
            exitLong      := true
            exitReason    := pendingReason
            exitPriceLong := cond1 ? close : cond2 ? close[1] - exitOffsetPoints : ePrice - hardStopPoints
            pendingLong   := false
            pendingReason := ""
        else
            pendingLong   := true
            pendingReason := cond1 ? "Back In Doji" : cond2 ? "Prev Close -" + str.tostring(exitOffsetPoints) + "pts" : "Hard Stop"
    else
        pendingLong   := false
        pendingReason := ""

if pos == -1 and afterEntry
    cond1 = close > eDLow
    cond2 = high  > close[1] + exitOffsetPoints
    cond3 = high >= ePrice   + hardStopPoints
    anyExit = cond1 or cond2 or cond3
    if anyExit
        if pendingShort
            exitShort      := true
            exitReason     := pendingReason
            exitPriceShort := cond1 ? close : cond2 ? close[1] + exitOffsetPoints : ePrice + hardStopPoints
            pendingShort   := false
            pendingReason  := ""
        else
            pendingShort  := true
            pendingReason := cond1 ? "Back In Doji" : cond2 ? "Prev Close +" + str.tostring(exitOffsetPoints) + "pts" : "Hard Stop"
    else
        pendingShort  := false
        pendingReason := ""

if exitLong
    pos := 0, ePrice := na, eDHigh := na, eDLow := na, eBar := na, pendingLong := false
if exitShort
    pos := 0, ePrice := na, eDHigh := na, eDLow := na, eBar := na, pendingShort := false

// =====================================================
// EMA PLOTS
// =====================================================
plot(ema5,  title="EMA 5",  color=color.yellow,  linewidth=1)
plot(ema10, title="EMA 10", color=color.aqua,    linewidth=1)
plot(ema20, title="EMA 20", color=color.orange,  linewidth=1)
plot(ema30, title="EMA 30", color=color.fuchsia, linewidth=2)

// =====================================================
// VWAP PLOTS & BANDS
// =====================================================
plot(showVwap ? vwapValue : na, title="VWAP", color=color.white, linewidth=vwapLineWidth)

plot(showVwapBands and vwapSd3 ? vwapUpper3 : na, title="VWAP +3 SD", color=color.new(color.blue, 70), linewidth=1)
plot(showVwapBands and vwapSd3 ? vwapLower3 : na, title="VWAP -3 SD", color=color.new(color.blue, 70), linewidth=1)
plot(showVwapBands and vwapSd2 ? vwapUpper2 : na, title="VWAP +2 SD", color=color.new(color.blue, 60), linewidth=1)
plot(showVwapBands and vwapSd2 ? vwapLower2 : na, title="VWAP -2 SD", color=color.new(color.blue, 60), linewidth=1)
plot(showVwapBands and vwapSd1 ? vwapUpper1 : na, title="VWAP +1 SD", color=color.new(color.blue, 50), linewidth=1)
plot(showVwapBands and vwapSd1 ? vwapLower1 : na, title="VWAP -1 SD", color=color.new(color.blue, 50), linewidth=1)

var box vwapBox3 = na
var box vwapBox2 = na
var box vwapBox1 = na

bandOpacity3 = math.round((100 - vwapBandOpacity) * 2.55)
bandOpacity2 = math.round((100 - vwapBandOpacity + 10) * 2.55)
bandOpacity1 = math.round((100 - vwapBandOpacity + 20) * 2.55)

if showVwapBands and barstate.islast
    box.delete(vwapBox3)
    box.delete(vwapBox2)
    box.delete(vwapBox1)
    
    if vwapSd3
        vwapBox3 := box.new(bar_index - 500, vwapUpper3, bar_index, vwapLower3, bgcolor=color.new(color.blue, math.min(bandOpacity3, 95)), border_color=color.new(color.blue, 100))
    if vwapSd2
        vwapBox2 := box.new(bar_index - 500, vwapUpper2, bar_index, vwapLower2, bgcolor=color.new(color.blue, math.min(bandOpacity2, 90)), border_color=color.new(color.blue, 100))
    if vwapSd1
        vwapBox1 := box.new(bar_index - 500, vwapUpper1, bar_index, vwapLower1, bgcolor=color.new(color.blue, math.min(bandOpacity1, 85)), border_color=color.new(color.blue, 100))

// =====================================================
// ATR LABELS
// =====================================================
var label aL5 = na, var label aL10 = na, var label aL20 = na, var label aL30 = na, var label aLVwap = na

if barstate.islast and showAtrLabels
    t5    = "EMA5: "  + str.tostring(math.round(atrMult5,  1)) + "x"
    t10   = "EMA10: " + str.tostring(math.round(atrMult10, 1)) + "x"
    t20   = "EMA20: " + str.tostring(math.round(atrMult20, 1)) + "x"
    t30   = "EMA30: " + str.tostring(math.round(atrMult30, 1)) + "x"
    tVwap = "VWAP: "  + str.tostring(math.round(vwapAtrMult, 1)) + "x"
    
    if na(aL5)
        aL5    := label.new(bar_index + 2, ema5,     t5,    color=color.new(color.yellow,  80), textcolor=color.yellow,  style=label.style_label_left, size=size.small)
        aL10   := label.new(bar_index + 2, ema10,    t10,   color=color.new(color.aqua,    80), textcolor=color.aqua,    style=label.style_label_left, size=size.small)
        aL20   := label.new(bar_index + 2, ema20,    t20,   color=color.new(color.orange,  80), textcolor=color.orange,  style=label.style_label_left, size=size.small)
        aL30   := label.new(bar_index + 2, ema30,    t30,   color=color.new(color.fuchsia, 80), textcolor=color.fuchsia, style=label.style_label_left, size=size.small)
        aLVwap := label.new(bar_index + 2, vwapValue, tVwap, color=color.new(color.white,   80), textcolor=color.white,   style=label.style_label_left, size=size.small)
    else
        label.set_xy(aL5,    bar_index + 2, ema5),     label.set_text(aL5,    t5)
        label.set_xy(aL10,   bar_index + 2, ema10),    label.set_text(aL10,   t10)
        label.set_xy(aL20,   bar_index + 2, ema20),    label.set_text(aL20,   t20)
        label.set_xy(aL30,   bar_index + 2, ema30),    label.set_text(aL30,   t30)
        label.set_xy(aLVwap, bar_index + 2, vwapValue), label.set_text(aLVwap, tVwap)

// =====================================================
// SIGNAL MARKERS & LABELS
// =====================================================
plotshape(isDoji, title="Doji", style=shape.diamond, location=location.abovebar, color=color.gray, text="DOJI", size=size.tiny)

plotshape(showEngulfing and bullishEngulfBelowEma and not strongBullEngulf, "Bull Engulf", shape.triangleup,   location.belowbar, color.lime, text="BULL\nENGULF", textcolor=color.white, size=size.tiny)
plotshape(showEngulfing and bearishEngulfAboveEma and not strongBearEngulf, "Bear Engulf", shape.triangledown, location.abovebar, color.red,  text="BEAR\nENGULF", textcolor=color.white, size=size.tiny)
plotshape(showEngulfing and strongBullEngulf, "STRONG Bull", shape.triangleup,   location.belowbar, color.lime, text="STRONG\nBUY",  textcolor=color.black, size=size.small)
plotshape(showEngulfing and strongBearEngulf, "STRONG Bear", shape.triangledown, location.abovebar, color.red,  text="STRONG\nSELL", textcolor=color.white, size=size.small)

if showEngulfing and strongBullEngulf
    label.new(bar_index, low,  "STRONG BUY\n"  + str.tostring(reversalScore) + "%", color=color.new(color.lime, 10), textcolor=color.black, style=label.style_label_up,   size=size.small)
if showEngulfing and strongBearEngulf
    label.new(bar_index, high, "STRONG SELL\n" + str.tostring(reversalScore) + "%", color=color.new(color.red,  10), textcolor=color.white, style=label.style_label_down, size=size.small)

plotshape(showTrendSignals and bullishBreakout, "Bull Breakout", shape.arrowup,   location.belowbar, color.blue,   text="BREAKOUT", textcolor=color.white, size=size.small)
plotshape(showTrendSignals and bearishBreakout, "Bear Breakout", shape.arrowdown, location.abovebar, color.blue,   text="BREAKOUT", textcolor=color.white, size=size.small)
plotshape(showTrendSignals and bullishPullback, "Bull Pullback", shape.circle, location.belowbar, color.yellow, text="PULLBACK", textcolor=color.black, size=size.tiny)
plotshape(showTrendSignals and bearishPullback, "Bear Pullback", shape.circle, location.abovebar, color.yellow, text="PULLBACK", textcolor=color.black, size=size.tiny)

plotshape(showReversionSignals and positiveReversion, "Pos Reversion", shape.labelup,   location.belowbar, color.teal,   text="REVERSION+", textcolor=color.white, size=size.small)
plotshape(showReversionSignals and negativeReversion, "Neg Reversion", shape.labeldown, location.abovebar, color.maroon, text="REVERSION-", textcolor=color.white, size=size.small)

plotshape(showFakeBreakout and fakeBullBreakout, "Fake Bull", shape.xcross, location.abovebar, color.fuchsia, text="FAKE", textcolor=color.white, size=size.small)
plotshape(showFakeBreakout and fakeBearBreakout, "Fake Bear", shape.xcross, location.belowbar, color.fuchsia, text="FAKE", textcolor=color.white, size=size.small)

plotshape(showVwapSignals and vwapBullSignal and not vwapRevLongSignal, "VWAP Bull Bounce", shape.triangleup, location.belowbar, color=color.new(color.white, 20), text="VWAP\nBOUNCE", textcolor=color.black, size=size.tiny)
plotshape(showVwapSignals and vwapBearSignal and not vwapRevShortSignal, "VWAP Bear Bounce", shape.triangledown, location.abovebar, color=color.new(color.white, 20), text="VWAP\nBOUNCE", textcolor=color.black, size=size.tiny)

plotshape(showVwapSignals and vwapRevLongSignal,  "VWAP Reversion Long",  shape.labelup,   location.belowbar, color=color.new(color.teal, 10), text="VWAP\nREV+", textcolor=color.white, size=size.small)
plotshape(showVwapSignals and vwapRevShortSignal, "VWAP Reversion Short", shape.labeldown, location.abovebar, color=color.new(color.maroon, 10), text="VWAP\nREV-", textcolor=color.white, size=size.small)

if showVwapSignals and vwapRevLongSignal
    label.new(bar_index, low, "VWAP REVERSION+\n" + str.tostring(math.round(vwapAtrMult, 1)) + "x ATR", color=color.new(color.teal, 20), textcolor=color.white, style=label.style_label_up, size=size.tiny)
if showVwapSignals and vwapRevShortSignal
    label.new(bar_index, high, "VWAP REVERSION-\n" + str.tostring(math.round(vwapAtrMult, 1)) + "x ATR", color=color.new(color.maroon, 20), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if showSignalLabels and buySignal
    label.new(bar_index, low,  showPrices ? "BUY @ "  + str.tostring(dHigh, format.mintick) : "BUY",  color=color.green,  textcolor=color.white, style=label.style_label_up,   size=size.normal)
if showSignalLabels and sellSignal
    label.new(bar_index, high, showPrices ? "SELL @ " + str.tostring(dLow,  format.mintick) : "SELL", color=color.red,    textcolor=color.white, style=label.style_label_down, size=size.normal)

if showExitLabels and exitLong
    label.new(bar_index, high, showPrices ? "EXIT LONG @ "  + str.tostring(exitPriceLong,  format.mintick) + " (" + exitReason + ")" : "EXIT LONG",  color=color.orange, textcolor=color.white, style=label.style_label_down, size=size.normal)
if showExitLabels and exitShort
    label.new(bar_index, low,  showPrices ? "EXIT SHORT @ " + str.tostring(exitPriceShort, format.mintick) + " (" + exitReason + ")" : "EXIT SHORT", color=color.orange, textcolor=color.white, style=label.style_label_up,   size=size.normal)

// =====================================================
// DASHBOARD  (Replaced Buy/Sell Pts with Trend/Pyramid/Exit Logic)
// =====================================================
var table dash = table.new(position.top_right, 2, 14, border_width=2, frame_width=2, frame_color=color.white, border_color=color.gray)

if barstate.islast
    revLabel = reversalScore >= 75 ? "HIGH " + str.tostring(reversalScore) + "%" : reversalScore >= 45 ? "MED  " + str.tostring(reversalScore) + "%" : "LOW  " + str.tostring(reversalScore) + "%"
    revColor = reversalScore >= 75 ? color.red : reversalScore >= 45 ? color.orange : color.lime
    posText  = pos == 1 ? "LONG" : pos == -1 ? "SHORT" : "FLAT"
    posColor = pos == 1 ? color.lime : pos == -1 ? color.red : color.gray
    atrWarn  = atrMult30 > ema30AtrLimitBuy or atrMult30 < ema30AtrLimitSell
    
    vwapZone = close > vwapUpper2 ? "+2 SD" : close > vwapUpper1 ? "+1 SD" : close > vwapValue ? "ABOVE" : close > vwapLower1 ? "BELOW" : close > vwapLower2 ? "-1 SD" : "-2 SD"
    vwapZoneColor = close > vwapUpper1 ? color.red : close > vwapValue ? color.lime : close > vwapLower1 ? color.orange : color.red

    // --- NEW PYRAMID & EXIT LOGIC ---
    trendStateText = bullStack ? "BULL STACK" : bearStack ? "BEAR STACK" : "CHOPPY/FLAT"
    trendStateCol  = bullStack ? color.lime : bearStack ? color.red : color.gray

    nearEmaForAdd = (bullStack or bearStack) and (math.abs(atrMult10) <= 0.5 or math.abs(atrMult20) <= 0.5)
    pyramidText = (trendStateText == "CHOPPY/FLAT") ? "NO TREND" : nearEmaForAdd ? "ADD ON PULLBACK" : "WAIT / TRAIL"
    pyramidColor = (trendStateText == "CHOPPY/FLAT") ? color.gray : nearEmaForAdd ? color.aqua : color.yellow

    isStretched = absAtrMult30 >= 2.5
    isVwapExtreme = close > vwapUpper2 or close < vwapLower2
    isReverting = (pos == 1 and negativeReversion) or (pos == -1 and positiveReversion)
    isFaking = (pos == 1 and fakeBullBreakout) or (pos == -1 and fakeBearBreakout)
    
    exitText = pos == 0 ? "N/A" : isFaking ? "FAKE OUT!" : isReverting ? "REVERSION!" : isStretched ? "PARTIAL (ATR)" : isVwapExtreme ? "PARTIAL (VWAP)" : "HOLD"
    exitColor = pos == 0 ? color.gray : isFaking ? color.fuchsia : isReverting ? color.maroon : (isStretched or isVwapExtreme) ? color.orange : color.lime

    table.cell(dash, 0, 0, "Position",        bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 0, posText, bgcolor=color.black, text_color=posColor)
    table.cell(dash, 0, 1, "Entry Price",     bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 1, na(ePrice) ? "-" : str.tostring(ePrice, format.mintick), bgcolor=color.black, text_color=color.aqua)
    table.cell(dash, 0, 2, "Doji Range",      bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 2, na(dHigh) ? "-" : str.tostring(dLow, format.mintick) + " - " + str.tostring(dHigh, format.mintick), bgcolor=color.black, text_color=color.yellow)
    
    // NEW ROWS replacing Buy/Sell Pts
    table.cell(dash, 0, 3, "Trend Stack",     bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 3, trendStateText,     bgcolor=color.black, text_color=trendStateCol)
    table.cell(dash, 0, 4, "Pyramid Action",  bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 4, pyramidText,        bgcolor=color.black, text_color=pyramidColor)
    table.cell(dash, 0, 5, "Exit Trigger",    bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 5, exitText,           bgcolor=color.black, text_color=exitColor)

    table.cell(dash, 0, 6, "Gap 5/10/20/30",  bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 6, str.tostring(math.round(gap5,1)) + " / " + str.tostring(math.round(gap10,1)) + " / " + str.tostring(math.round(gap20,1)) + " / " + str.tostring(math.round(gap30,1)), bgcolor=color.black, text_color=color.aqua)
    table.cell(dash, 0, 7, "ATR 5/10/20/30",  bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 7, str.tostring(math.round(atrMult5,1)) + "x / " + str.tostring(math.round(atrMult10,1)) + "x / " + str.tostring(math.round(atrMult20,1)) + "x / " + str.tostring(math.round(atrMult30,1)) + "x", bgcolor=color.black, text_color=atrWarn ? color.red : color.yellow)
    table.cell(dash, 0, 8, "Avg Candle Range", bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 8, str.tostring(math.round(currentDayAvgRange,1)) + " pts", bgcolor=color.black, text_color=currentDayAvgRange > atr14 ? color.lime : color.yellow)
    table.cell(dash, 0, 9, "Reversal Chance",  bgcolor=color.rgb(60,20,20), text_color=color.white)
    table.cell(dash, 1, 9, revLabel,            bgcolor=color.rgb(20,20,20), text_color=revColor)
    table.cell(dash, 0, 10, "VWAP Value",       bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 10, str.tostring(vwapValue, format.mintick) + " (" + str.tostring(math.round(vwapAtrMult,1)) + "x)", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 0, 11, "VWAP Zone",       bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 11, vwapZone,           bgcolor=color.black, text_color=vwapZoneColor)
    
    // OPTIONS MARKET BEHAVIOR ROWS
    table.cell(dash, 0, 12, "ATR Ratio (14/"+str.tostring(optAtrLongLen)+")", bgcolor=color.rgb(40,40,40), text_color=color.white)
    table.cell(dash, 1, 12, str.tostring(math.round(atrRatio, 2)), bgcolor=color.black, text_color=color.aqua)
    table.cell(dash, 0, 13, "Options Mkt Type", bgcolor=optMktColor, text_color=color.white)
    table.cell(dash, 1, 13, optMktState,        bgcolor=color.black, text_color=optMktColor)

// =====================================================
// ALERTS
// =====================================================
alertcondition(buySignal,  title="Doji Buy",   message="BUY  - High broke above Doji High")
alertcondition(sellSignal, title="Doji Sell",  message="SELL - Low broke below Doji Low")
alertcondition(exitLong,   title="Exit Long",  message="EXIT LONG  - Structural exit")
alertcondition(exitShort,  title="Exit Short", message="EXIT SHORT - Structural exit")
alertcondition(bullishEngulfBelowEma, title="Bullish Engulfing Below EMAs", message="BULLISH ENGULFING - formed below all EMAs")
alertcondition(bearishEngulfAboveEma, title="Bearish Engulfing Above EMAs", message="BEARISH ENGULFING - formed above all EMAs")
alertcondition(strongBullEngulf, title="STRONG Bullish Engulfing", message="STRONG BUY - Engulfing below all EMAs + Reversal Chance >= threshold")
alertcondition(strongBearEngulf, title="STRONG Bearish Engulfing", message="STRONG SELL - Engulfing above all EMAs + Reversal Chance >= threshold")
alertcondition(bullishBreakout,  title="Bullish EMA Stack Breakout", message="BREAKOUT - Strong candle closed above entire EMA stack")
alertcondition(bearishBreakout,  title="Bearish EMA Stack Breakout", message="BREAKOUT - Strong candle closed below entire EMA stack")
alertcondition(bullishPullback,  title="Bullish EMA Pullback", message="PULLBACK - Price tapped EMA10/20 support in an uptrend")
alertcondition(bearishPullback,  title="Bearish EMA Pullback", message="PULLBACK - Price tapped EMA10/20 resistance in a downtrend")
alertcondition(positiveReversion, title="Positive Reversion", message="REVERSION+ - Price stretched below EMA30, Reversal Chance crossed above threshold")
alertcondition(negativeReversion, title="Negative Reversion", message="REVERSION- - Price stretched above EMA30, Reversal Chance crossed above threshold")
alertcondition(fakeBullBreakout, title="Fake Bullish Breakout", message="FAKE BREAKOUT - Bullish breakout failed, price closed back inside EMA stack")
alertcondition(fakeBearBreakout, title="Fake Bearish Breakout", message="FAKE BREAKOUT - Bearish breakout failed, price closed back inside EMA stack")

alertcondition(vwapBullSignal,      title="VWAP Bull Bounce",      message="VWAP BOUNCE - Price bounced off VWAP from below")
alertcondition(vwapBearSignal,      title="VWAP Bear Bounce",      message="VWAP BOUNCE - Price rejected off VWAP from above")
alertcondition(vwapRevLongSignal,   title="VWAP Reversion Long",   message="VWAP REVERSION+ - Price stretched below VWAP and reversing back")
alertcondition(vwapRevShortSignal,  title="VWAP Reversion Short",  message="VWAP REVERSION- - Price stretched above VWAP and reversing back")
````
