# Ultimate Bull Score - Multi-Factor Bullish Stock Scanner

- url: https://www.tradingview.com/script/o1oT18QZ-Ultimate-Bull-Score-Multi-Factor-Bullish-Stock-Scanner/
- type: indicator
- pine_id: PUB;91a9bdaa52814f2abb32736f47b755a3
- version: 7.0

## Description

Ultimate Bull Score is a multi-factor technical analysis indicator designed to measure the overall bullish strength of a stock using a single 0–100 Bull Score.

Rather than relying on one indicator or chart pattern, Ultimate Bull Score evaluates multiple categories of bullish evidence simultaneously, including:

Trend Strength — moving-average alignment, price position, and trend direction
Momentum & Oscillators — RSI, MACD, Stochastic, Stochastic RSI, CCI, MFI, ROC, Williams %R, PPO, TSI, Ultimate Oscillator, Chaikin Money Flow, Aroon, and related momentum conditions
Volume & Accumulation — relative volume, OBV behavior, and buying-volume characteristics
Bullish Chart Patterns — searches for structures including Bull Flags, Cup & Handle, Ascending Triangles, Falling Wedges, Double Bottoms, Flat Bases, Rounded Bottoms, VCP-style contractions, volatility coils, and breakout/retest setups
Price Structure — higher highs, higher lows, resistance pressure, breakouts, support behavior, and proximity to 52-week highs
Analyst Sentiment — when analyst data is available, incorporates consensus recommendations and potential upside to the average analyst price target

These factors are combined into one easy-to-read Bull Score from 0 to 100.

Score Guide

90–100 — Excellent Bullish Setup
Strong agreement across multiple bullish factors.

75–89 — Strong Bullish Setup
A high-quality setup with substantial bullish confirmation.

60–74 — Bullish
Positive overall conditions, although some confirmation may still be missing.

Below 60 — Weak / Incomplete Setup
Bullish factors are limited or conflicting.

The dashboard breaks the total score into its individual components, making it possible to see whether a stock's strength is coming from trend, oscillators, volume, chart patterns, price structure, or analyst sentiment.

Ultimate Bull Score is also designed for use with Pine Screener, exposing numeric outputs that can be filtered and sorted to help identify the strongest setups in a watchlist or stock universe.

Important: This indicator is intended as a research and screening tool. A high Bull Score does not guarantee that a security will rise. Technical conditions can change rapidly, and the indicator should be used alongside appropriate risk management and independent research.

## Source Code

````pine
//@version=6

indicator("Ultimate Bull Scanner v2 - Growth Quality", shorttitle="Bull v2 GQ", overlay=true, precision=1, max_bars_back=500)



// Based on Ultimate Bull Score V5 - A/D Strength.

// Daily equities / Pine Screener. Five request.* calls.

//

// Raw Bull, risk deductions and Legacy Bull remain scannable,

// but are hidden from the dashboard.

//

// Entry Score retains the former Early Bull calculation.

// Pullback Entry Price is a technical watch level.

//

// Forward growth and estimate revisions are unavailable.

// Missing business factors receive half credit by default,

// but never count toward Business Coverage.

// Maximum observed business coverage: 77.1%.

// Maximum Raw Bull with neutral missing credit: 96.

//

// Financial histories and analyst metadata are not

// point-in-time datasets for historical backtesting.



//====================================================================

// INPUTS

//====================================================================



groupTrend = "1. Trend"

ema9Len = input.int(9, "Fast EMA", minval=3, maxval=30, group=groupTrend)

ema21Len = input.int(21, "Mid EMA", minval=10, maxval=60, group=groupTrend)

sma50Len = input.int(50, "50 SMA", minval=20, maxval=100, group=groupTrend)

sma200Len = input.int(200, "200 SMA", minval=100, maxval=300, group=groupTrend)



groupOsc = "2. Oscillators"

rsiLen = input.int(14, "RSI Length", minval=5, maxval=30, group=groupOsc)

stochLen = input.int(14, "Stochastic Length", minval=5, maxval=30, group=groupOsc)

cciLen = input.int(20, "CCI Length", minval=10, maxval=50, group=groupOsc)

mfiLen = input.int(14, "MFI Length", minval=5, maxval=30, group=groupOsc)

rocLen = input.int(20, "ROC Length", minval=5, maxval=60, group=groupOsc)

williamsLen = input.int(14, "Williams %R Length", minval=5, maxval=30, group=groupOsc)



groupVol = "3. Volume"

volumeLen = input.int(20, "Volume Average", minval=10, maxval=60, group=groupVol)

strongVolumeRatio = input.float(1.30, "Strong Volume Ratio", minval=1, maxval=4, step=0.05, group=groupVol)



groupPattern = "4. Bullish Patterns"

patternLookback = input.int(20, "Pattern Lookback", minval=10, maxval=60, group=groupPattern)

doubleBottomTolerance = input.float(3, "Double Bottom Tolerance %", minval=1, maxval=8, step=0.5, group=groupPattern)

nearResistancePct = input.float(3, "Near Resistance %", minval=0.5, maxval=10, step=0.25, group=groupPattern)

flagMaxRetrace = input.float(40, "Bull Flag Max Retracement %", minval=15, maxval=60, step=5, group=groupPattern)



groupAnalyst = "5. Analyst Sentiment"

useAnalystSentiment = input.bool(true, "Use Analyst Sentiment", group=groupAnalyst)

minimumAnalystCoverage = input.int(3, "Minimum Analyst Ratings", minval=1, maxval=30, group=groupAnalyst)

targetUpsideStrongPct = input.float(15, "Strong Target Upside %", minval=5, maxval=50, group=groupAnalyst)



groupBusiness = "6. Growth / Quality"

neutralMissing = input.bool(true, "Half credit for missing business data", group=groupBusiness)

minimumCoverage = input.float(70, "Minimum business coverage for signals %", minval=0, maxval=100, group=groupBusiness)



groupRS = "7. Relative Strength"

benchmarkTicker = input.string("AMEX:SPY", "Benchmark ticker", group=groupRS, tooltip="Use an exchange-qualified ticker. A sector ETF can replace SPY. Only one benchmark is used.")



groupEntry = "8. Entry / Risk"

entryThreshold = input.float(65, "Entry Score signal minimum", minval=0, maxval=100, group=groupEntry)

entryExtensionMax = input.float(7, "Green extension maximum %", minval=1, maxval=10, group=groupEntry)

extensionStart = input.float(10, "Red extension / penalty starts above %", minval=10, maxval=30, group=groupEntry)

maximumRisk = input.float(10, "Maximum risk deduction for signals", minval=0, maxval=33, group=groupEntry)

pullbackATRAllowance = input.float(0.25, "Pullback price allowance above 21 EMA (ATR)", minval=0, maxval=1, step=0.05, group=groupEntry)

pullbackZoneATR = input.float(0.25, "Near-entry tolerance (ATR)", minval=0, maxval=1, step=0.05, group=groupEntry)



groupDisplay = "9. Display"

strongBullScore = input.int(75, "Strong Bull Score", minval=50, maxval=95, group=groupDisplay)

excellentBullScore = input.int(90, "Excellent Bull Score", minval=70, maxval=100, group=groupDisplay)

showDashboard = input.bool(true, "Show Dashboard", group=groupDisplay)

showFastMAs = input.bool(true, "Show 9/21 EMA", group=groupDisplay)

showPullbackLine = input.bool(false, "Show Pullback Entry Price on chart", group=groupDisplay)

completedBars = input.bool(true, "Use completed bars", group=groupDisplay)



//====================================================================

// HELPERS

//====================================================================



f_clip(float x, float lo, float hi) =>

    math.max(lo, math.min(hi, x))



f_scale(float x, float lo, float hi) =>

    f_clip((x - lo) / (hi - lo), 0, 1)



f_yes(bool condition, float points) =>

    condition ? points : 0.0



f_factor(float fraction, float points) =>

    na(fraction) ? (neutralMissing ? points * 0.5 : 0.0) : points * f_clip(fraction, 0, 1)



f_coverage(float fraction, float points) =>

    na(fraction) ? 0.0 : points



f_growth(float current, float previous) =>

    not na(current) and not na(previous) and previous > 0 ? 100 * (current / previous - 1) : na



f_fmt(float value) =>

    na(value) ? "N/A" : str.tostring(value, "#.0")



f_price(float value) =>

    na(value) ? "N/A" : str.tostring(value, format.mintick)



// Each written call maintains its own quarterly report history.

// gaps_on captures a new report even when its value is unchanged.

f_reports(float event) =>

    var array<float> reports = array.new_float()

    var int lastEvent = na

    if not na(event)

        array.unshift(reports, event)

        if array.size(reports) > 6

            array.pop(reports)

        lastEvent := bar_index

    int n = array.size(reports)

    float current = n > 0 ? array.get(reports, 0) : na

    float previous = n > 1 ? array.get(reports, 1) : na

    float yearAgo = n > 4 ? array.get(reports, 4) : na

    float previousYearAgo = n > 5 ? array.get(reports, 5) : na

    float ttm = n >= 4 ? array.get(reports, 0) + array.get(reports, 1) + array.get(reports, 2) + array.get(reports, 3) : na

    bool fresh = not na(lastEvent) and bar_index - lastEvent <= 150

    [fresh ? current : na, fresh ? previous : na, fresh ? yearAgo : na, fresh ? previousYearAgo : na, fresh ? ttm : na, lastEvent]



f_row(table panel, int row, string label, string value, string status, color bg) =>

    table.cell(panel, 0, row, label, bgcolor=bg, text_color=color.white)

    table.cell(panel, 1, row, value, bgcolor=bg, text_color=color.white)

    table.cell(panel, 2, row, status, bgcolor=bg, text_color=color.white)



//====================================================================

// FIVE DATA REQUESTS

//====================================================================



benchmark = request.security(benchmarkTicker, timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

revEvent = request.financial(syminfo.tickerid, "TOTAL_REVENUE", "FQ", gaps=barmerge.gaps_on, ignore_invalid_symbol=true, currency=syminfo.currency)

epsEvent = request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_DILUTED", "FQ", gaps=barmerge.gaps_on, ignore_invalid_symbol=true, currency=syminfo.currency)

fcfEvent = request.financial(syminfo.tickerid, "FREE_CASH_FLOW", "FQ", gaps=barmerge.gaps_on, ignore_invalid_symbol=true, currency=syminfo.currency)

incomeEvent = request.financial(syminfo.tickerid, "NET_INCOME", "FQ", gaps=barmerge.gaps_on, ignore_invalid_symbol=true, currency=syminfo.currency)



[rev, revPrev, revYA, revPrevYA, revTTM, revBar] = f_reports(revEvent)

[eps, epsPrev, epsYA, epsPrevYA, epsTTM, epsBar] = f_reports(epsEvent)

[fcf, fcfPrev, fcfYA, fcfPrevYA, fcfTTM, fcfBar] = f_reports(fcfEvent)

[income, incomePrev, incomeYA, incomePrevYA, incomeTTM, incomeBar] = f_reports(incomeEvent)



//====================================================================

// ORIGINAL TREND CORE

//====================================================================



ema9 = ta.ema(close, ema9Len)

ema21 = ta.ema(close, ema21Len)

sma50 = ta.sma(close, sma50Len)

sma200 = ta.sma(close, sma200Len)



priceAbove9 = close > ema9

priceAbove21 = close > ema21

priceAbove50 = close > sma50

priceAbove200 = close > sma200



emaStackBull = ema9 > ema21 and ema21 > sma50

majorTrendBull = sma50 > sma200



ema9Rising = ema9 > ema9[3]

ema21Rising = ema21 > ema21[5]

sma50Rising = sma50 > sma50[10]

sma200Rising = sma200 > sma200[20]



//====================================================================

// ORIGINAL OSCILLATORS

//====================================================================



rsi = ta.rsi(close, rsiLen)

rsiBull = rsi >= 55 and rsi <= 75



[macdLine, macdSignal, macdHist] = ta.macd(close, 12, 26, 9)

macdBull = macdLine > macdSignal

macdPositive = macdLine > 0

macdHistRising = macdHist > macdHist[1]



lowestStoch = ta.lowest(low, stochLen)

highestStoch = ta.highest(high, stochLen)

stochK = highestStoch != lowestStoch ? 100 * (close - lowestStoch) / (highestStoch - lowestStoch) : 50

stochD = ta.sma(stochK, 3)

stochBull = stochK > stochD and stochK > 50 and stochK < 90



rsiLow = ta.lowest(rsi, stochLen)

rsiHigh = ta.highest(rsi, stochLen)

stochRsi = rsiHigh != rsiLow ? 100 * (rsi - rsiLow) / (rsiHigh - rsiLow) : 50

stochRsiSignal = ta.sma(stochRsi, 3)

stochRsiBull = stochRsi > stochRsiSignal and stochRsi > 50



cci = ta.cci(hlc3, cciLen)

cciBull = cci > 0 and cci < 200



mfi = ta.mfi(hlc3, mfiLen)

mfiBull = mfi > 50 and mfi < 80



roc = ta.roc(close, rocLen)

rocBull = roc > 0



willHigh = ta.highest(high, williamsLen)

willLow = ta.lowest(low, williamsLen)

willR = willHigh != willLow ? -100 * (willHigh - close) / (willHigh - willLow) : -50

willBull = willR > -50 and willR < -10



ema12 = ta.ema(close, 12)

ema26 = ta.ema(close, 26)

ppo = ema26 != 0 ? (ema12 - ema26) / ema26 * 100 : 0

ppoSignal = ta.ema(ppo, 9)

ppoBull = ppo > ppoSignal and ppo > 0



momentum = close - close[1]

doubleSmoothedMomentum = ta.ema(ta.ema(momentum, 25), 13)

doubleSmoothedAbsMomentum = ta.ema(ta.ema(math.abs(momentum), 25), 13)

tsi = doubleSmoothedAbsMomentum != 0 ? 100 * doubleSmoothedMomentum / doubleSmoothedAbsMomentum : 0

tsiSignal = ta.ema(tsi, 7)

tsiBull = tsi > tsiSignal and tsi > 0



buyingPressure = close - math.min(low, close[1])

trueRangeUO = math.max(high, close[1]) - math.min(low, close[1])



bp7 = math.sum(buyingPressure, 7)

tr7 = math.sum(trueRangeUO, 7)

bp14 = math.sum(buyingPressure, 14)

tr14 = math.sum(trueRangeUO, 14)

bp28 = math.sum(buyingPressure, 28)

tr28 = math.sum(trueRangeUO, 28)



ultimateOsc = tr7 > 0 and tr14 > 0 and tr28 > 0 ? 100 * (4 * bp7 / tr7 + 2 * bp14 / tr14 + bp28 / tr28) / 7 : 50

ultimateBull = ultimateOsc > 50 and ultimateOsc < 75



mfMultiplier = high != low ? ((close - low) - (high - close)) / (high - low) : 0

mfVolume = mfMultiplier * volume

cmfDenominator = math.sum(volume, 20)

cmfNumerator = math.sum(mfVolume, 20)

cmf = cmfDenominator != 0 ? cmfNumerator / cmfDenominator : 0

cmfBull = cmf > 0



barsSinceHigh25 = ta.highestbars(high, 25)

barsSinceLow25 = ta.lowestbars(low, 25)

aroonUp = 100 * (25 - math.abs(barsSinceHigh25)) / 25

aroonDown = 100 * (25 - math.abs(barsSinceLow25)) / 25

aroonBull = aroonUp > aroonDown and aroonUp >= 70



momentumVerdict = macdBull and ppoBull ? "BULLISH" : not macdBull and not ppoBull ? "BEARISH" : "NEUTRAL"

moneyFlowVerdict = mfiBull and cmfBull ? "BULL" : mfi < 50 and cmf <= 0 ? "BEAR" : "NEUTRAL"



//====================================================================

// ORIGINAL VOLUME / A-D

//====================================================================



avgVolume = ta.sma(volume, volumeLen)

volumeRatio = avgVolume > 0 ? volume / avgVolume : na

volumeOK = not na(avgVolume) and avgVolume > 0

strongVolume = not na(volumeRatio) and volumeRatio >= strongVolumeRatio



var float obv = 0

if close > close[1]

    obv += nz(volume, 0)

else if close < close[1]

    obv -= nz(volume, 0)



obvRising = obv > obv[10]

obvEMA = ta.ema(obv, 21)



adMultiplier = high != low ? ((close - low) - (high - close)) / (high - low) : 0

var float adLine = 0

adLine += adMultiplier * nz(volume, 0)



adAverage20 = ta.ema(adLine, 20)

adLow20 = ta.lowest(adLine, 20)

adHigh20 = ta.highest(adLine, 20)

adRange20 = adHigh20 - adLow20



adRangePosition = adRange20 > 0 ? 100 * (adLine - adLow20) / adRange20 : 50

adAboveAverage = adLine > adAverage20

adRising5 = adLine > adLine[5]

adNearHigh20 = adRangePosition >= 80

adBullishDivergence = adLine > adLine[20] and close <= close[20]



adPointScore = (adAboveAverage ? 1 : 0) + (adRising5 ? 1 : 0) + (adNearHigh20 ? 1 : 0) + (adBullishDivergence ? 1 : 0)



adStrength = f_clip(adRangePosition * 0.4 + f_yes(adAboveAverage, 20) + f_yes(adRising5, 20) + f_yes(adBullishDivergence, 20), 0, 100)



adStrengthStatus = adStrength >= 75 ? "STRONG ACCUM." : adStrength >= 56 ? "ACCUMULATION" : adStrength >= 45 ? "NEUTRAL" : adStrength >= 25 ? "DISTRIBUTION" : "STRONG DISTRIB."



//====================================================================

// ORIGINAL PRICE STRUCTURE

//====================================================================



resistance = ta.highest(high[1], patternLookback)

support = ta.lowest(low[1], patternLookback)



distanceToResistance = resistance > 0 ? (resistance - close) / resistance * 100 : na

nearResistance = not na(distanceToResistance) and distanceToResistance >= 0 and distanceToResistance <= nearResistancePct



resistanceBreakout = close > resistance and close[1] <= resistance

higherHigh = high > high[5]

higherLow = low > low[5]

priceAboveSupport = close > support



// Native daily calculation saves one request.

high52 = ta.highest(high, math.min(252, bar_index + 1))

distanceFrom52High = high52 > 0 ? (high52 - close) / high52 * 100 : na

near52High = not na(distanceFrom52High) and distanceFrom52High <= 10



//====================================================================

// ORIGINAL TEN PATTERN APPROXIMATIONS

//====================================================================



// Bull flag.

poleLow = ta.lowest(low[6], 15)

poleHigh = high[5]

poleGainPct = poleLow > 0 ? (poleHigh / poleLow - 1) * 100 : na

flagLow = ta.lowest(low, 5)

poleHeight = poleHigh - poleLow

flagRetracePct = poleHeight > 0 ? (poleHigh - flagLow) / poleHeight * 100 : na

bullFlagPattern = not na(poleGainPct) and poleGainPct >= 8 and not na(flagRetracePct) and flagRetracePct >= 0 and flagRetracePct <= flagMaxRetrace and close > poleLow



// Ascending triangle.

triResistance = ta.highest(high, 12)

lowEarly = ta.lowest(low[6], 6)

lowRecent = ta.lowest(low, 6)



int resistanceTouches = 0

for i = 0 to 11

    float diff = triResistance > 0 ? math.abs(high[i] - triResistance) / triResistance * 100 : na

    if not na(diff) and diff <= 1.5

        resistanceTouches += 1



ascendingTrianglePattern = resistanceTouches >= 2 and lowRecent > lowEarly and close <= triResistance * 1.01



// Falling wedge.

highOld = ta.highest(high[10], 10)

highNew = ta.highest(high, 10)

lowOld = ta.lowest(low[10], 10)

lowNew = ta.lowest(low, 10)



highDropPct = highOld > 0 ? (highOld - highNew) / highOld * 100 : na

lowDropPct = lowOld > 0 ? (lowOld - lowNew) / lowOld * 100 : na

fallingWedgePattern = not na(highDropPct) and not na(lowDropPct) and highDropPct > 0 and lowDropPct > 0 and highDropPct > lowDropPct



// Double bottom.

bottom1 = ta.lowest(low[10], 10)

bottom2 = ta.lowest(low, 10)

bottomDiffPct = bottom1 > 0 ? math.abs(bottom2 - bottom1) / bottom1 * 100 : na

middleHigh = ta.highest(high[5], 10)

doubleBottomPattern = not na(bottomDiffPct) and bottomDiffPct <= doubleBottomTolerance and middleHigh > math.max(bottom1, bottom2) * 1.05 and close > bottom2



// Cup and handle.

cupLeftRim = high[30]

cupRightRim = ta.highest(high, 8)

cupBottom = ta.lowest(low[8], 22)

cupRim = math.max(cupLeftRim, cupRightRim)



cupDepthPct = cupRim > 0 ? (cupRim - cupBottom) / cupRim * 100 : na

rimDiffPct = cupLeftRim > 0 ? math.abs(cupRightRim - cupLeftRim) / cupLeftRim * 100 : na

handleLow = ta.lowest(low, 8)

handleDepthPct = cupRim > 0 ? (cupRim - handleLow) / cupRim * 100 : na



cupHandlePattern = not na(cupDepthPct) and cupDepthPct >= 8 and cupDepthPct <= 40 and not na(rimDiffPct) and rimDiffPct <= 8 and not na(handleDepthPct) and handleDepthPct <= 15



// Volatility coil.

atr14 = ta.atr(14)

atrPct = close > 0 ? atr14 / close * 100 : na

atrPctAvg = ta.sma(atrPct, 20)

range5 = ta.highest(high, 5) - ta.lowest(low, 5)

rangePrev5 = ta.highest(high[5], 5) - ta.lowest(low[5], 5)

volatilityCoil = not na(atrPctAvg) and atrPct < atrPctAvg and rangePrev5 > 0 and range5 < rangePrev5



// Breakout and retest.

priorBreakLevel = ta.highest(high[2], 20)

recentBreakout = close[1] > priorBreakLevel

retestHold = recentBreakout and low <= priorBreakLevel * 1.015 and close >= priorBreakLevel



// Flat base.

baseHigh = ta.highest(high, 10)

baseLow = ta.lowest(low, 10)

baseRangePct = baseLow > 0 ? (baseHigh - baseLow) / baseLow * 100 : na

flatBasePattern = not na(baseRangePct) and baseRangePct <= 8 and close >= baseHigh * 0.97



// Rounded bottom.

leftPrice = close[20]

middlePrice = ta.lowest(close[6], 15)

roundedBottomPattern = leftPrice > middlePrice * 1.05 and close > middlePrice * 1.05 and math.abs(close - leftPrice) / leftPrice * 100 <= 12



// VCP-like contraction.

range20 = ta.highest(high, 20) - ta.lowest(low, 20)

range10 = ta.highest(high, 10) - ta.lowest(low, 10)

range5v = ta.highest(high, 5) - ta.lowest(low, 5)

vcpPattern = range20 > 0 and range10 < range20 * 0.75 and range5v < range10 * 0.75



bestPattern = bullFlagPattern ? "BULL FLAG" : cupHandlePattern ? "CUP/HANDLE" : ascendingTrianglePattern ? "ASC TRIANGLE" : vcpPattern ? "VCP" : volatilityCoil ? "COIL" : doubleBottomPattern ? "DOUBLE BOTTOM" : fallingWedgePattern ? "FALLING WEDGE" : flatBasePattern ? "FLAT BASE" : roundedBottomPattern ? "ROUNDED BOTTOM" : retestHold ? "RETEST HOLD" : "NONE"



//====================================================================

// ORIGINAL TECHNICAL SCORE — SCANNABLE ONLY

//====================================================================



int trendScore = (priceAbove9 ? 2 : 0) + (priceAbove21 ? 2 : 0) + (priceAbove50 ? 3 : 0) + (priceAbove200 ? 3 : 0) + (emaStackBull ? 3 : 0) + (majorTrendBull ? 2 : 0) + (ema9Rising ? 1 : 0) + (ema21Rising ? 1 : 0) + (sma50Rising ? 1 : 0)



int oscillatorPasses = (rsiBull ? 1 : 0) + (macdBull ? 1 : 0) + (macdPositive ? 1 : 0) + (macdHistRising ? 1 : 0) + (stochBull ? 1 : 0) + (stochRsiBull ? 1 : 0) + (cciBull ? 1 : 0) + (mfiBull ? 1 : 0) + (rocBull ? 1 : 0) + (willBull ? 1 : 0) + (ppoBull ? 1 : 0) + (tsiBull ? 1 : 0) + (ultimateBull ? 1 : 0) + (cmfBull ? 1 : 0) + (aroonBull ? 1 : 0)



int oscillatorScore = int(math.round(22.0 * oscillatorPasses / 15))

int volumeScore = (strongVolume ? 4 : 0) + (obvRising ? 5 : 0) + adPointScore



int patternPasses = (bullFlagPattern ? 1 : 0) + (ascendingTrianglePattern ? 1 : 0) + (fallingWedgePattern ? 1 : 0) + (doubleBottomPattern ? 1 : 0) + (cupHandlePattern ? 1 : 0) + (volatilityCoil ? 1 : 0) + (retestHold ? 1 : 0) + (flatBasePattern ? 1 : 0) + (roundedBottomPattern ? 1 : 0) + (vcpPattern ? 1 : 0)



int patternScore = int(math.min(22, patternPasses * 4))

int structureScore = (nearResistance ? 2 : 0) + (resistanceBreakout ? 3 : 0) + (higherHigh ? 2 : 0) + (higherLow ? 2 : 0) + (priceAboveSupport ? 2 : 0) + (near52High ? 2 : 0)



technicalRawScore = trendScore + oscillatorScore + volumeScore + patternScore + structureScore

legacyBullScore = math.min(100, int(math.round(100.0 * technicalRawScore / 88)))

trendPct = 100.0 * trendScore / 18



//====================================================================

// ANALYST SENTIMENT — SEPARATE FROM BULL SCORE

//====================================================================



analystStrongBuy = nz(syminfo.recommendations_buy_strong, 0)

analystBuy = nz(syminfo.recommendations_buy, 0)

analystSell = nz(syminfo.recommendations_sell, 0)

analystStrongSell = nz(syminfo.recommendations_sell_strong, 0)

analystTotal = nz(syminfo.recommendations_total, 0)



analystCoveragePass = analystTotal >= minimumAnalystCoverage

analystConsensusPct = analystTotal > 0 ? (analystStrongBuy * 2 + analystBuy - analystSell - analystStrongSell * 2) / (analystTotal * 2) * 100 : na



analystTargetAverage = syminfo.target_price_average

analystTargetEstimates = nz(syminfo.target_price_estimates, 0)

analystTargetUpsidePct = not na(analystTargetAverage) and close > 0 ? (analystTargetAverage / close - 1) * 100 : na



targetUpsideBullish = analystTargetEstimates > 0 and not na(analystTargetUpsidePct) and analystTargetUpsidePct > 0

targetUpsideStrong = analystTargetEstimates > 0 and not na(analystTargetUpsidePct) and analystTargetUpsidePct >= targetUpsideStrongPct



int analystScore = 0

if useAnalystSentiment and analystCoveragePass

    analystScore += analystConsensusPct >= 60 ? 8 : analystConsensusPct >= 40 ? 6 : analystConsensusPct >= 15 ? 4 : analystConsensusPct >= 0 ? 2 : 0

    analystScore += targetUpsideStrong ? 4 : targetUpsideBullish ? 2 : 0



//====================================================================

// V2 TECHNICAL COMPONENTS

//====================================================================



extension = 100 * (close / ema21 - 1)

mom20 = ta.roc(close, 20)

mom60 = ta.roc(close, 60)

mom10 = ta.roc(close, 10)



rs20 = mom20 - ta.roc(benchmark, 20)

rs60 = mom60 - ta.roc(benchmark, 60)

ratio = benchmark > 0 ? close / benchmark : na

ratioEMA = ta.ema(ratio, 21)



accumulation = ta.sma(close > close[1] and volume > avgVolume ? 1.0 : 0.0, 20)



trendPoints = 20.0 * trendScore / 18

rsPoints = na(rs20) or na(rs60) ? na : 6 * f_scale(rs20, -5, 10) + 6 * f_scale(rs60, -10, 20) + f_yes(ratio > ratioEMA and ratioEMA > ratioEMA[5], 3)

momentumPoints = 6.0 * oscillatorScore / 22 + 2 * f_scale(mom20, 0, 15) + 2 * f_scale(mom60, 0, 30)

accumulationPoints = volumeOK ? 10.0 * volumeScore / 13 : 0

breakoutPoints = 5.0 * patternScore / 22 + 5.0 * structureScore / 13



technicalPoints = trendPoints + rsPoints + momentumPoints + accumulationPoints + breakoutPoints

technicalScore = technicalPoints / 65 * 100



//====================================================================

// GROWTH / QUALITY

//====================================================================



revGrowth = f_growth(rev, revYA)

previousRevGrowth = f_growth(revPrev, revPrevYA)

revAcceleration = revGrowth - previousRevGrowth



incomeAligned = revBar == incomeBar

fcfAligned = revBar == fcfBar



margin = incomeAligned and rev > 0 ? income / rev * 100 : na

marginYA = incomeAligned and revYA > 0 ? incomeYA / revYA * 100 : na

fcfMargin = fcfAligned and rev > 0 ? fcf / rev * 100 : na

fcfMarginYA = fcfAligned and revYA > 0 ? fcfYA / revYA * 100 : na



epsImprovement = na(eps) or na(epsYA) ? na : epsYA > 0 ? f_scale(100 * (eps / epsYA - 1), 0, 40) : eps > 0 ? 1.0 : eps > epsYA ? 0.5 : 0.0

fcfImprovement = na(fcf) or na(fcfYA) ? na : fcfYA > 0 ? f_scale(100 * (fcf / fcfYA - 1), 0, 50) : fcf > 0 ? 1.0 : fcf > fcfYA ? 0.5 : 0.0



revenueLevel = f_scale(revGrowth, 0, 40)

revenueAcceleration = f_scale(revAcceleration, -5, 10)

epsPositive = na(eps) ? na : eps > 0 ? 1.0 : 0.0

marginImprovement = f_scale(margin - marginYA, 0, 5)

fcfLevel = f_scale(fcfMargin, 0, 25)

fcfMarginImprovement = f_scale(fcfMargin - fcfMarginYA, 0, 5)



pe = epsTTM > 0 ? close / epsTTM : na



// Trailing P/E versus revenue growth; not forward PEG.

valuationFraction = not na(pe) and not na(revGrowth) ? revGrowth > 0 ? 1 - f_scale(pe / math.max(revGrowth, 5), 1, 4) : pe <= 15 ? 0.5 : 0.0 : na



revenuePoints = f_factor(revenueLevel, 7) + f_factor(revenueAcceleration, 3)

profitPoints = f_factor(epsPositive, 2) + f_factor(epsImprovement, 3) + f_factor(marginImprovement, 2)

fcfPoints = f_factor(fcfLevel, 3) + f_factor(fcfImprovement, 2) + f_factor(fcfMarginImprovement, 2)

valuationPoints = f_factor(valuationFraction, 3)



// Reserved factors; no historical-growth substitution.

forwardPoints = f_factor(float(na), 5)

revisionPoints = f_factor(float(na), 3)



businessPoints = revenuePoints + profitPoints + fcfPoints + valuationPoints + forwardPoints + revisionPoints

businessScore = businessPoints / 35 * 100



coveragePoints = f_coverage(revenueLevel, 7) + f_coverage(revenueAcceleration, 3) + f_coverage(epsPositive, 2) + f_coverage(epsImprovement, 3) + f_coverage(marginImprovement, 2) + f_coverage(fcfLevel, 3) + f_coverage(fcfImprovement, 2) + f_coverage(fcfMarginImprovement, 2) + f_coverage(valuationFraction, 3)

coverage = coveragePoints / 35 * 100



growthScore = (revenuePoints + f_factor(epsImprovement, 3) + forwardPoints + revisionPoints) / 21 * 100

qualityScore = (f_factor(epsPositive, 2) + f_factor(marginImprovement, 2) + fcfPoints) / 11 * 100

growthEfficiency = (revenuePoints + profitPoints + fcfPoints) / 24 * 100



//====================================================================

// INTERNAL RISK ADJUSTMENTS

// Hidden from dashboard; retained in final Bull Score.

//====================================================================



extensionPenalty = 8 * f_scale(extension, extensionStart, extensionStart + 15)

parabolicPenalty = 5 * math.max(f_scale(mom10, 20, 50), f_scale(mom20, 35, 80))

deteriorationPenalty = f_yes(close > close[10] and rsi < rsi[10], 2.5) + f_yes(volumeOK and close > close[10] and obv < obv[10], 2.5)

revenuePenalty = na(revAcceleration) ? 0 : 5 * f_scale(-revAcceleration, 5, 25)

fcfPenalty = not na(fcf) and not na(fcfYA) and fcf < 0 and fcf < fcfYA ? 5 * f_scale((fcfYA - fcf) / math.max(math.abs(fcfYA), 1) * 100, 0, 100) : 0

valuationPenalty = not na(pe) and not na(revGrowth) and revGrowth < 15 ? 5 * f_scale(pe, 40, 100) * f_scale(15 - revGrowth, 0, 15) : 0



penalty = extensionPenalty + parabolicPenalty + deteriorationPenalty + revenuePenalty + fcfPenalty + valuationPenalty

rawScore = technicalPoints + businessPoints



ready = timeframe.isdaily and timeframe.multiplier == 1 and bar_index >= math.max(252, sma200Len + 20) and not na(rsPoints) and not na(mom60)

finalScore = ready ? f_clip(rawScore - penalty, 0, 100) : na



//====================================================================

// ENTRY SCORE

//====================================================================



// Former Early Bull calculation.

// Rewards newly improving, relatively unextended setups.

// Does not represent a probability of success.



crossAge = ta.barssince(ta.crossover(ema9, ema21))

reclaimAge = ta.barssince(ta.crossover(close, sma50))

rsAge = ta.barssince(ta.crossover(rs20, 0))

slope = ta.roc(ema21, 5)



entryScore = f_yes(ema9 > ema21 and crossAge <= 10, 15) + f_yes(slope > 0 and slope > slope[5], 15) + f_yes(close > sma50 and reclaimAge <= 10, 15) + f_yes(rs20 > 0 and rsAge <= 10, 15) + f_yes(volumeOK and obv > obvEMA and close <= close[10], 10) + f_yes(volumeOK and accumulation > accumulation[5], 10) + f_yes(mom20 > 0 and mom20 > mom20[5], 10) + f_yes(extension >= 0 and extension <= entryExtensionMax, 10)



strongSignal = ready and finalScore >= strongBullScore and coverage >= minimumCoverage and penalty <= maximumRisk and close > ema21 and volumeOK

entrySignal = ready and entryScore >= entryThreshold and coverage >= minimumCoverage and penalty <= maximumRisk and extension >= 0 and extension <= entryExtensionMax and ema9 > ema21 and volumeOK



//====================================================================

// PULLBACK ENTRY PRICE

//====================================================================



// Bull Score determines watch-level eligibility, independently of Entry Score.
// Scores below 50 have no level; 50-64 use conservative 21 EMA support.
// Scores >=65 use dynamic support only while the trend is healthy and rising.
// Otherwise, qualified stocks retain the conservative level for reclaim watches.

pullbackBullQualified = ready and not na(finalScore) and finalScore >= 50 and close > 0 and ema21 > 0 and not na(atr14)
pullbackTrend = pullbackBullQualified and finalScore >= 65 and ema9 > ema21 and ema9Rising and ema21Rising and close > sma50

pullbackNormalSupport = ema21 + atr14 * pullbackATRAllowance
pullbackFastSupport = ema9 + atr14 * 0.10
pullbackMaxPrice = ema21 * (1 + entryExtensionMax / 100)

// Keep the most recent broken resistance for later retests.
// Evaluate history functions on every bar, outside conditional blocks.
pullbackLastBreakout = ta.valuewhen(resistanceBreakout, resistance, 0)
pullbackBreakoutAge = ta.barssince(resistanceBreakout)
pullbackRecentBreakout = not na(pullbackBreakoutAge) and pullbackBreakoutAge <= patternLookback

// Dynamic candidates must be below price, within the extension cap,
// and within 3% of price. Unbroken overhead resistance is never support.
pullbackFastValid = pullbackTrend and pullbackFastSupport <= close and pullbackFastSupport <= pullbackMaxPrice and 100 * (close - pullbackFastSupport) / close <= 3
pullbackResistanceValid = pullbackTrend and not na(resistance) and resistance > 0 and resistance <= close and resistance >= ema21 and resistance <= pullbackMaxPrice and 100 * (close - resistance) / close <= 3
pullbackBreakoutValid = pullbackTrend and pullbackRecentBreakout and not na(pullbackLastBreakout) and pullbackLastBreakout > 0 and pullbackLastBreakout <= close and pullbackLastBreakout >= ema21 and pullbackLastBreakout <= pullbackMaxPrice and 100 * (close - pullbackLastBreakout) / close <= 3

float pullbackDynamicSupport = pullbackNormalSupport
if pullbackFastValid
    pullbackDynamicSupport := math.max(pullbackDynamicSupport, pullbackFastSupport)
if pullbackResistanceValid
    pullbackDynamicSupport := math.max(pullbackDynamicSupport, resistance)
if pullbackBreakoutValid
    pullbackDynamicSupport := math.max(pullbackDynamicSupport, pullbackLastBreakout)

// Preserve the original extension cap. A level above current price is a
// reclaim watch level; it is not automatically an actionable entry signal.
pullbackPrice = pullbackBullQualified ? math.min(pullbackTrend ? pullbackDynamicSupport : pullbackNormalSupport, pullbackMaxPrice) : na

nearPullbackArea = not na(pullbackPrice) and close >= ema21 and close <= pullbackPrice + atr14 * pullbackZoneATR
needsReclaim = not na(pullbackPrice) and close < ema21
pullbackDistance = not na(pullbackPrice) and close > 0 ? math.max(0, 100 * (close - pullbackPrice) / close) : na

pullbackSetup = nearPullbackArea and coverage >= minimumCoverage and penalty <= maximumRisk and volumeOK


// One common offset keeps exported components aligned.

int offset = completedBars and not barstate.isconfirmed ? 1 : 0



//====================================================================

// SCANNABLE PLOTS

// First ten plots become default screener columns.

//====================================================================



plot(finalScore[offset], "Bull Score", display=display.data_window)

plot(ready[offset] ? technicalScore[offset] : na, "Technical 0-100", display=display.data_window)

plot(ready[offset] ? businessScore[offset] : na, "Growth Quality 0-100", display=display.data_window)

plot(ready[offset] ? entryScore[offset] : na, "Entry Score 0-100", display=display.data_window)

plot(extension[offset], "% Above 21 EMA", display=display.data_window)

plot(pullbackPrice[offset], "Pullback Entry Price", display=display.data_window)

plot(coverage[offset], "Business Coverage %", display=display.data_window)

plot(ready[offset] ? rsPoints[offset] / 15 * 100 : na, "Relative Strength 0-100", display=display.data_window)

plot(ready[offset] ? accumulationPoints[offset] * 10 : na, "Accumulation 0-100", display=display.data_window)

plot(adStrength[offset], "A/D Strength", display=display.data_window)



// Hidden dashboard diagnostics remain available to the screener.

plot(ready[offset] ? rawScore[offset] : na, "Raw Bull", display=display.data_window)

plot(penalty[offset], "Risk Deduction 0-33", display=display.data_window)

plot(ready[offset] ? legacyBullScore[offset] : na, "Legacy Bull Score", display=display.data_window)



plot(pullbackDistance[offset], "Pullback Distance %", display=display.data_window)

plot(pullbackSetup[offset] ? 1 : 0, "Pullback Setup Flag", display=display.data_window)

plot(growthScore[offset], "Growth 0-100", display=display.data_window)

plot(qualityScore[offset], "Quality 0-100", display=display.data_window)

plot(growthEfficiency[offset], "Growth Efficiency 0-100", display=display.data_window)

plot(na(valuationFraction[offset]) ? na : valuationFraction[offset] * 100, "Valuation Growth 0-100", display=display.data_window)

plot(revGrowth[offset], "Revenue YoY %", display=display.data_window)

plot(margin[offset], "Net Margin %", display=display.data_window)

plot(fcfMargin[offset], "FCF Margin %", display=display.data_window)



plot(trendPct[offset], "Trend %", display=display.data_window)

plot(oscillatorScore[offset], "Oscillator Score 0-22", display=display.data_window)

plot(volumeScore[offset], "Volume Score 0-13", display=display.data_window)

plot(adPointScore[offset], "A/D Score 0-4", display=display.data_window)

plot(adBullishDivergence[offset] ? 1 : 0, "A/D Bullish Divergence", display=display.data_window)

plot(patternScore[offset], "Pattern Score 0-22", display=display.data_window)

plot(structureScore[offset], "Structure Score 0-13", display=display.data_window)

plot(oscillatorPasses[offset], "Bullish Oscillators", display=display.data_window)

plot(patternPasses[offset], "Bullish Patterns", display=display.data_window)

plot(rsi[offset], "RSI", display=display.data_window)

plot(cmf[offset], "Chaikin Money Flow", display=display.data_window)



// Current analyst snapshots, not historical revision series.

plot(useAnalystSentiment and analystCoveragePass ? analystScore : na, "Analyst Sentiment Score", display=display.data_window)

plot(useAnalystSentiment and analystCoveragePass ? analystConsensusPct : na, "Analyst Consensus %", display=display.data_window)

plot(analystTotal, "Analyst Ratings Count", display=display.data_window)

plot(useAnalystSentiment ? analystTargetUpsidePct : na, "Analyst Target Upside %", display=display.data_window)



plot(strongSignal[offset] ? 1 : 0, "Strong Bull Flag", display=display.data_window)

plot(entrySignal[offset] ? 1 : 0, "Entry Setup Flag", display=display.data_window)

plot(ready[offset] ? 1 : 0, "Daily Data Ready", display=display.data_window)



plot(extensionPenalty[offset], "Extension Deduction 0-8", display=display.data_window)

plot(parabolicPenalty[offset], "Parabolic Deduction 0-5", display=display.data_window)

plot(deteriorationPenalty[offset], "Momentum Deduction 0-5", display=display.data_window)

plot(revenuePenalty[offset], "Revenue Deduction 0-5", display=display.data_window)

plot(fcfPenalty[offset], "FCF Deduction 0-5", display=display.data_window)

plot(valuationPenalty[offset], "Valuation Deduction 0-5", display=display.data_window)



plot(float(na), "Forward Growth - Unavailable", display=display.data_window)

plot(float(na), "Estimate Revisions - Unavailable", display=display.data_window)



//====================================================================

// VISIBLE CHART LINES

//====================================================================



plot(showFastMAs ? ema9[offset] : na, "9 EMA", color=color.aqua, linewidth=2)

plot(showFastMAs ? ema21[offset] : na, "21 EMA", color=color.orange, linewidth=2)

plot(showPullbackLine ? pullbackPrice[offset] : na, "Pullback Entry Line", color=color.lime, linewidth=2, style=plot.style_linebr)



//====================================================================

// COLORFUL DASHBOARD

// Bull Score is the only overall bull rating shown.

// No Raw Bull, Legacy Bull or Risk Deduction rows.

// No allocation labels.

//====================================================================



greenColor = color.rgb(0, 135, 75)

limeColor = color.rgb(75, 155, 35)

yellowColor = color.rgb(190, 145, 0)

redColor = color.rgb(170, 45, 45)

blueColor = color.rgb(35, 100, 190)

purpleColor = color.rgb(115, 65, 175)

cyanColor = color.rgb(0, 125, 155)

tealColor = color.rgb(0, 145, 125)

grayColor = color.rgb(70, 70, 70)

headerColor = color.rgb(25, 25, 35)



var table dashboard = table.new(position.top_right, 3, 23, frame_color=color.gray, frame_width=1, border_width=1)



if barstate.islast and showDashboard

    color totalColor = not ready[offset] ? grayColor : finalScore[offset] >= excellentBullScore ? greenColor : finalScore[offset] >= strongBullScore ? limeColor : finalScore[offset] >= 60 ? yellowColor : redColor



    color technicalColor = not ready[offset] ? grayColor : technicalScore[offset] >= 75 ? blueColor : technicalScore[offset] >= 60 ? yellowColor : redColor

    color businessColor = businessScore[offset] >= 75 ? purpleColor : businessScore[offset] >= 50 ? yellowColor : redColor

    color rsColor = not ready[offset] ? grayColor : rsPoints[offset] >= 11.25 ? cyanColor : rsPoints[offset] >= 7.5 ? yellowColor : redColor

    color entryColor = not ready[offset] ? grayColor : entryScore[offset] >= entryThreshold ? tealColor : entryScore[offset] >= 50 ? yellowColor : redColor



    color extensionColor = extension[offset] > extensionStart ? redColor : extension[offset] >= 0 and extension[offset] <= entryExtensionMax ? greenColor : yellowColor

    color pullbackColor = na(pullbackPrice[offset]) ? grayColor : needsReclaim[offset] ? redColor : pullbackSetup[offset] ? greenColor : yellowColor



    color trendColor = trendScore[offset] >= 15 ? greenColor : trendScore[offset] >= 10 ? yellowColor : redColor

    color oscColor = oscillatorScore[offset] >= 18 ? greenColor : oscillatorScore[offset] >= 12 ? yellowColor : redColor

    color volColor = volumeScore[offset] >= 9 ? greenColor : volumeScore[offset] >= 4 ? yellowColor : redColor

    color adColor = adStrength[offset] >= 75 ? greenColor : adStrength[offset] >= 56 ? limeColor : adStrength[offset] >= 45 ? yellowColor : redColor

    color patternColor = patternScore[offset] >= 15 ? greenColor : patternScore[offset] >= 8 ? yellowColor : redColor

    color structureColor = structureScore[offset] >= 9 ? greenColor : structureScore[offset] >= 6 ? yellowColor : redColor

    color momentumColor = momentumVerdict[offset] == "BULLISH" ? greenColor : momentumVerdict[offset] == "BEARISH" ? redColor : yellowColor

    color flowColor = moneyFlowVerdict[offset] == "BULL" ? greenColor : moneyFlowVerdict[offset] == "BEAR" ? redColor : yellowColor

    color analystColor = not useAnalystSentiment or not analystCoveragePass ? grayColor : analystScore >= 10 ? greenColor : analystScore >= 6 ? yellowColor : redColor



    string totalStatus = not ready[offset] ? "USE 1D / NEED HISTORY" : coverage[offset] < minimumCoverage ? "LIMITED BUSINESS DATA" : not volumeOK[offset] ? "MISSING VOLUME" : finalScore[offset] >= excellentBullScore ? "EXCELLENT" : finalScore[offset] >= strongBullScore ? "STRONG" : finalScore[offset] >= 60 ? "BULLISH" : "WEAK"



    string entryStatus = not ready[offset] ? "N/A" : entrySignal[offset] ? "ENTRY SETUP" : entryScore[offset] >= entryThreshold ? "CHECK FILTERS" : "WATCH"



    string pullbackStatus = na(pullbackPrice[offset]) ? "NO TREND SETUP" : needsReclaim[offset] ? "NEEDS RECLAIM" : nearPullbackArea[offset] ? pullbackSetup[offset] ? "NEAR ENTRY AREA" : "NEAR AREA / CHECK FILTERS" : "WAIT FOR PULLBACK"



    string analystStatus = not useAnalystSentiment ? "DISABLED" : not analystCoveragePass ? "NO DATA" : analystConsensusPct >= 40 ? "STRONG BUY" : analystConsensusPct > 15 ? "BULLISH" : analystConsensusPct >= 0 ? "NEUTRAL" : "BEARISH"



    f_row(dashboard, 0, "ULTIMATE BULL V2", "SCORE / PRICE", "STATUS", headerColor)



    // New v2 information.

    f_row(dashboard, 1, "BULL SCORE", f_fmt(finalScore[offset]) + "/100", totalStatus, totalColor)

    f_row(dashboard, 2, "TECHNICAL", ready[offset] ? f_fmt(technicalScore[offset]) + "/100" : "N/A", "", technicalColor)

    f_row(dashboard, 3, "GROWTH / QUALITY", f_fmt(businessScore[offset]) + "/100", "", businessColor)

    f_row(dashboard, 4, "RELATIVE STRENGTH", ready[offset] ? f_fmt(rsPoints[offset] / 15 * 100) : "N/A", benchmarkTicker, rsColor)

    f_row(dashboard, 5, "ENTRY SCORE", ready[offset] ? f_fmt(entryScore[offset]) + "/100" : "N/A", entryStatus, entryColor)

    f_row(dashboard, 6, "% Above 21 EMA", f_fmt(extension[offset]) + "%", "", extensionColor)

    f_row(dashboard, 7, "PULLBACK ENTRY PRICE", f_price(pullbackPrice[offset]), pullbackStatus, pullbackColor)

    f_row(dashboard, 8, "BUSINESS COVERAGE", f_fmt(coverage[offset]) + "%", coverage[offset] >= minimumCoverage ? "PASS" : "LIMITED DATA", coverage[offset] >= minimumCoverage ? greenColor : yellowColor)

    f_row(dashboard, 9, "FORWARD / REVISIONS", "N/A", "UNAVAILABLE", grayColor)



    // Original technical details.

    f_row(dashboard, 10, "Trend", str.tostring(trendScore[offset]) + "/18", trendScore[offset] >= 15 ? "STRONG BULLISH" : trendScore[offset] >= 10 ? "BULLISH" : "WEAK / BEARISH", trendColor)

    f_row(dashboard, 11, "Oscillators", str.tostring(oscillatorScore[offset]) + "/22", str.tostring(oscillatorPasses[offset]) + "/15 BULL", oscColor)

    f_row(dashboard, 12, "Volume", str.tostring(volumeScore[offset]) + "/13", volumeScore[offset] >= 9 ? "ACCUMULATION" : volumeScore[offset] >= 4 ? "PASS" : "WEAK", volColor)

    f_row(dashboard, 13, "Patterns", str.tostring(patternScore[offset]) + "/22", str.tostring(patternPasses[offset]) + " ACTIVE", patternColor)

    f_row(dashboard, 14, "Structure", str.tostring(structureScore[offset]) + "/13", resistanceBreakout[offset] ? "BREAKOUT" : nearResistance[offset] ? "PRESSING" : "NORMAL", structureColor)

    f_row(dashboard, 15, "RSI", f_fmt(rsi[offset]), rsiBull[offset] ? "BULL" : "NEUTRAL", rsiBull[offset] ? greenColor : yellowColor)

    f_row(dashboard, 16, "Momentum", macdBull[offset] and ppoBull[offset] ? "POSITIVE" : not macdBull[offset] and not ppoBull[offset] ? "NEGATIVE" : "MIXED", momentumVerdict[offset], momentumColor)

    f_row(dashboard, 17, "Money Flow", "MFI " + f_fmt(mfi[offset]), moneyFlowVerdict[offset], flowColor)

    f_row(dashboard, 18, "A/D Strength", f_fmt(adStrength[offset]), adStrengthStatus[offset], adColor)

    f_row(dashboard, 19, "Best Pattern", bestPattern[offset], patternPasses[offset] > 0 ? "BULLISH" : "NONE", patternPasses[offset] > 0 ? greenColor : yellowColor)

    f_row(dashboard, 20, "From 52W High", na(distanceFrom52High[offset]) ? "N/A" : distanceFrom52High[offset] < 0.05 ? "AT HIGH" : f_fmt(distanceFrom52High[offset]) + "% BELOW", near52High[offset] ? "NEAR" : "FAR", near52High[offset] ? greenColor : yellowColor)

    f_row(dashboard, 21, "Analyst Sentiment", useAnalystSentiment and analystCoveragePass ? str.tostring(analystScore) + "/12" : "N/A", analystStatus, analystColor)

    f_row(dashboard, 22, "Analyst Target", useAnalystSentiment ? f_price(analystTargetAverage) : "N/A", useAnalystSentiment and not na(analystTargetUpsidePct) ? f_fmt(analystTargetUpsidePct) + "% UPSIDE" : "NO TARGET", analystColor)



if barstate.islast and not showDashboard

    table.clear(dashboard, 0, 0, 2, 22)



//====================================================================

// ALERTS / SCREENER CONDITIONS

//====================================================================



alertcondition(strongSignal[offset], "Strong Bull", "Bull Scanner v2: Strong Bull conditions on {{ticker}}.")

alertcondition(entrySignal[offset], "Entry Setup", "Bull Scanner v2: Entry setup conditions on {{ticker}}.")

alertcondition(pullbackSetup[offset], "Pullback Entry Area", "Bull Scanner v2: {{ticker}} is near its pullback entry watch area.")
````
