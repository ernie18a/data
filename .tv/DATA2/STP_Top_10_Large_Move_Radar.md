<!-- tradingview-pine-id: PUB;b567366769e141e793039e9b20011119 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# STP Top 10 Large Move Radar

Source: https://www.tradingview.com/script/cegbgJXd-STP-Top-10-Trade-Opportunity-Scanner-Screener/

## Description

STP Top 10 Trade Opportunity Scanner / Screener

The STP Top 10 Large Move Radar is a multi-symbol market scanner designed to help traders quickly identify stocks showing conditions that may support a larger-than-normal price move.

Instead of reviewing charts individually, the Radar continuously analyzes up to 20 user-selected symbols and ranks the strongest opportunities based on a proprietary scoring system. The highest-ranked symbols are displayed in an easy-to-read Top 10 table.

The system evaluates multiple technical factors, including price trend, EMA alignment, VWAP positioning, RSI, DMI/ADX, buying and selling pressure, Range Oscillator conditions, relative volume, ATR, volatility expansion, squeeze and compression conditions, breakouts and breakdowns, supply and demand proximity, Fair Value Gaps, price movement speed, and overall trend strength.

Radar Table Information

Each ranked symbol includes:

[*]Score: Overall opportunity score from 0–100 based on the combined technical conditions evaluated by the Radar.
[*]Direction: Identifies the current directional bias as BULL, BEAR, or NEUTRAL.
[*]Setup: Identifies conditions such as BREAKOUT, BREAKDOWN, SQZ RELEASE, COMPRESSED, AT S/D, AT FVG, NEAR BREAK, or BUILDING.
[*]RVOL: Measures current volume relative to average volume to identify unusually active symbols.
[*]ATR: Displays the previous completed daily 10-period ATR in dollars to provide context for the symbol's typical daily movement.
[*]ATR Used: During regular market hours, estimates how much of the symbol's daily ATR has been used so far. Before and after the regular session, the Radar identifies the applicable market session instead.
[*]Speed: Measures the magnitude of short-term EMA movement relative to ATR.
[*]T-Strength: Classifies directional trend conditions as Strong, Moderate, Weak, or None.
[*]Evidence: Highlights supporting technical conditions including squeeze activity, breakouts, supply/demand proximity, and Fair Value Gaps.

How Traders Can Use the Radar:

The Radar is designed primarily as an opportunity-discovery tool. A high ranking does not automatically represent a trade entry. Instead, traders can use the Top 10 list to identify which symbols deserve further chart analysis.

For example, a high-scoring bullish symbol showing elevated relative volume, a breakout or squeeze release, increasing speed, and strong trend conditions may warrant closer review for a potential bullish setup. The opposite conditions may identify potential bearish opportunities.

The Radar can be used alongside the STP Elite Prediction System or a trader's existing technical analysis process to confirm chart structure, support and resistance, risk, entry timing, and trade direction before entering a position.

Customizable Symbol List:

Users can configure up to 20 symbols, allowing the Radar to monitor a personal watchlist of stocks, ETFs, or other supported TradingView symbols. The scan timeframe is also configurable, with the default set to 5 minutes.

Dynamic Alerts:

The Radar includes a dynamic alert system for the highest-ranked opportunity. Users can set a minimum score threshold and optionally receive alerts when the leading symbol changes, its direction changes, or it crosses the configured threshold. Alerts include the symbol, direction, opportunity score, relative volume, ATR Used status, and scan timeframe.

Important:

The STP Top 10 Large Move Radar is intended to identify and rank developing technical conditions. Rankings and scores can change as new market data becomes available. A high score does not guarantee a large move and should not be considered a standalone buy or sell signal.

This indicator is intended for educational and informational purposes only and does not constitute financial advice.

---

## Source Code

````pine
//@version=6

indicator("STP Top 10 Large Move Radar", shorttitle="STP Top 10 Radar", overlay=false)

//====================================================
// DISPLAY SETTINGS

//====================================================

groupDisplay = "Display Settings"

tableLocationInput = input.string(

     "Middle Center",

     "Table Location",

     options=["Top Left", "Top Center", "Top Right", "Middle Center", "Bottom Left", "Bottom Center", "Bottom Right"],

     group=groupDisplay,

     display=display.none

)

tablePosition = position.top_right
if tableLocationInput == "Top Left"
    tablePosition := position.top_left
else if tableLocationInput == "Top Center"
    tablePosition := position.top_center
else if tableLocationInput == "Middle Center"
    tablePosition := position.middle_center
else if tableLocationInput == "Bottom Left"
    tablePosition := position.bottom_left
else if tableLocationInput == "Bottom Center"
    tablePosition := position.bottom_center
else if tableLocationInput == "Bottom Right"
    tablePosition := position.bottom_right

//====================================================
// GENERAL SETTINGS
//====================================================

groupGeneral = "General Settings"

scanTimeframe = input.timeframe("5", "Scan Timeframe", group=groupGeneral, display=display.none)

topResults = input.int(10, "Number of Results", minval=1, maxval=20, group=groupGeneral, display=display.none)

minimumAlertScore = input.float(65.0, "Minimum Alert Score", minval=0.0, maxval=100.0, step=1.0, group=groupGeneral, display=display.none)

alertOnlyWhenLeaderChanges = input.bool(true, "Alert Only When Top Symbol Changes", group=groupGeneral, display=display.none)

//====================================================
// INTERNAL CALCULATION SETTINGS
//====================================================

// Trend, Speed and Pressure

actualEmaLength = 21

trendEmaLength = 50

rsiLength = 14

dmiLength = 14

adxSmoothing = 14

minimumAdx = 18.0

speedLookback = 3

pressureLength = 3

roLength = 50

roAtrMultiplier = 1.0

// Volatility and Volume

atrLength = 14

volumeLength = 20

highRelativeVolume = 1.50

targetAtrPercent = 3.0

// Squeeze, Breakout and Structure

compressionLength = 20

bollingerMultiplier = 2.0

keltnerMultiplier = 1.5

compressionMemoryBars = 8

breakoutLength = 20

breakoutProximityPercent = 0.60

structureLookback = 30

zoneAtrDistance = 0.75

fvgLookback = 20

//====================================================
// SYMBOL INPUTS
//====================================================

groupSymbols1 = "Symbols 1 through 10"

symbol01 = input.symbol("AMEX:SPY", "Symbol 1", group=groupSymbols1, display=display.none)

symbol02 = input.symbol("NASDAQ:QQQ", "Symbol 2", group=groupSymbols1, display=display.none)

symbol03 = input.symbol("NASDAQ:AAPL", "Symbol 3", group=groupSymbols1, display=display.none)

symbol04 = input.symbol("NASDAQ:NVDA", "Symbol 4", group=groupSymbols1, display=display.none)

symbol05 = input.symbol("NASDAQ:TSLA", "Symbol 5", group=groupSymbols1, display=display.none)

symbol06 = input.symbol("NASDAQ:TTD", "Symbol 6", group=groupSymbols1, display=display.none)

symbol07 = input.symbol("NASDAQ:META", "Symbol 7", group=groupSymbols1, display=display.none)

symbol08 = input.symbol("NASDAQ:AMZN", "Symbol 8", group=groupSymbols1, display=display.none)

symbol09 = input.symbol("NASDAQ:GOOGL", "Symbol 9", group=groupSymbols1, display=display.none)

symbol10 = input.symbol("NASDAQ:MSFT", "Symbol 10", group=groupSymbols1, display=display.none)

groupSymbols2 = "Symbols 11 through 20"

symbol11 = input.symbol("NASDAQ:PLTR", "Symbol 11", group=groupSymbols2, display=display.none)

symbol12 = input.symbol("NASDAQ:SHOP", "Symbol 12", group=groupSymbols2, display=display.none)

symbol13 = input.symbol("NYSE:UBER", "Symbol 13", group=groupSymbols2, display=display.none)

symbol14 = input.symbol("NASDAQ:AXTI", "Symbol 14", group=groupSymbols2, display=display.none)

symbol15 = input.symbol("NYSE:MRK", "Symbol 15", group=groupSymbols2, display=display.none)

symbol16 = input.symbol("NASDAQ:SOFI", "Symbol 16", group=groupSymbols2, display=display.none)

symbol17 = input.symbol("NASDAQ:CELH", "Symbol 17", group=groupSymbols2, display=display.none)

symbol18 = input.symbol("NYSE:IONQ", "Symbol 18", group=groupSymbols2, display=display.none)

symbol19 = input.symbol("NASDAQ:DKNG", "Symbol 19", group=groupSymbols2, display=display.none)

symbol20 = input.symbol("NASDAQ:NBIS", "Symbol 20", group=groupSymbols2, display=display.none)

//====================================================
// SESSION STATUS
//====================================================

newYorkHour = hour(timenow, "America/New_York")

newYorkMinute = minute(timenow, "America/New_York")

newYorkDayOfWeek = dayofweek(timenow, "America/New_York")

isWeekday = newYorkDayOfWeek != dayofweek.saturday and newYorkDayOfWeek != dayofweek.sunday

isPreMarket = isWeekday and (

     newYorkHour < 9 or

     (newYorkHour == 9 and newYorkMinute < 30)

)

isRegularSession = isWeekday and (

     (newYorkHour > 9 or (newYorkHour == 9 and newYorkMinute >= 30)) and

     newYorkHour < 16

)

isAfterHours = isWeekday and newYorkHour >= 16

//====================================================
// HELPERS
//====================================================

f_clean_symbol(string fullSymbol) =>

    symbolParts = str.split(fullSymbol, ":")

    array.size(symbolParts) > 1 ? array.get(symbolParts, 1) : fullSymbol

f_clamp(float value, float lowValue, float highValue) =>

    math.min(math.max(value, lowValue), highValue)

//====================================================
// ELITE-ALIGNED SCAN ENGINE
//====================================================

f_scan_symbol() =>

    actualEma = ta.ema(close, actualEmaLength)

    trendEma = ta.ema(close, trendEmaLength)

    atrValue = ta.atr(atrLength)

    safeAtr = math.max(nz(atrValue, syminfo.mintick), syminfo.mintick)

    rsiValue = ta.rsi(close, rsiLength)

    [plusDi, minusDi, adxValue] = ta.dmi(dmiLength, adxSmoothing)

    averageVolume = ta.sma(volume, volumeLength)

    relativeVolume = averageVolume > 0.0 ? volume / averageVolume : 0.0

    atrPercent = close > 0.0 ? safeAtr / close * 100.0 : 0.0

    sessionVwap = ta.vwap(hlc3)

    vwapReady = not na(sessionVwap)

    actualSlope = actualEma - actualEma[speedLookback]

    trendSlope = trendEma - trendEma[speedLookback]

    bullBody = math.max(close - open, 0.0)

    bearBody = math.max(open - close, 0.0)

    upperWick = high - math.max(open, close)

    lowerWick = math.min(open, close) - low

    rawBuyPressure = close > open ? bullBody * volume : lowerWick * volume * 0.35

    rawSellPressure = close < open ? bearBody * volume : upperWick * volume * 0.35

    buyPressure = ta.sma(rawBuyPressure, pressureLength)

    sellPressure = ta.sma(rawSellPressure, pressureLength)

    buyersDominant = buyPressure > sellPressure

    sellersDominant = sellPressure > buyPressure

    buyersImproving = buyPressure > nz(buyPressure[1], buyPressure)

    sellersImproving = sellPressure > nz(sellPressure[1], sellPressure)

    pressureScore = 50.0
    if buyersDominant and buyersImproving
        pressureScore := 90.0
    else if buyersDominant
        pressureScore := 70.0
    else if sellersDominant and sellersImproving
        pressureScore := 90.0
    else if sellersDominant
        pressureScore := 70.0

    pressureDirection = buyersDominant ? 1.0 : sellersDominant ? -1.0 : 0.0

    roAtrLength = math.min(roLength * 4, 200)

    roAtr = ta.atr(roAtrLength) * roAtrMultiplier

    roSumWC = 0.0

    roSumW = 0.0

    for roIndex = 0 to roLength - 1

        roCurrent = close[roIndex]

        roPrior = close[roIndex + 1]

        roDelta = math.abs(roCurrent - roPrior)

        roWeight = roPrior != 0.0 ? roDelta / roPrior : 0.0

        roSumWC := roSumWC + roCurrent * roWeight

        roSumW := roSumW + roWeight

    roMA = roSumW != 0.0 ? roSumWC / roSumW : na

    roOsc = not na(roMA) and roAtr != 0.0 ? 100.0 * (close - roMA) / roAtr : 0.0

    roBull = not na(roMA) and close > roMA and roOsc > 0.0

    roBear = not na(roMA) and close < roMA and roOsc < 0.0

    roBullStrong = not na(roMA) and close > roMA + roAtr

    roBearStrong = not na(roMA) and close < roMA - roAtr

    emaBull = close > actualEma and close > trendEma and actualEma > trendEma and actualSlope > 0.0 and trendSlope > 0.0

    emaBear = close < actualEma and close < trendEma and actualEma < trendEma and actualSlope < 0.0 and trendSlope < 0.0

    aboveVwap = not vwapReady or close > sessionVwap

    belowVwap = not vwapReady or close < sessionVwap

    bullEvidence = 0.0

    bullEvidence += close > actualEma ? 2.0 : 0.0

    bullEvidence += close > trendEma ? 2.0 : 0.0

    bullEvidence += actualSlope > 0.0 ? 1.5 : 0.0

    bullEvidence += trendSlope > 0.0 ? 1.5 : 0.0

    bullEvidence += aboveVwap ? 2.0 : 0.0

    bullEvidence += buyersDominant ? 2.0 : 0.0

    bullEvidence += buyersImproving ? 1.0 : 0.0

    bullEvidence += roBull ? 2.0 : 0.0

    bullEvidence += roBullStrong ? 1.0 : 0.0

    bullEvidence += plusDi > minusDi ? 1.0 : 0.0

    bullEvidence += rsiValue >= 52.0 ? 1.0 : 0.0

    bearEvidence = 0.0

    bearEvidence += close < actualEma ? 2.0 : 0.0

    bearEvidence += close < trendEma ? 2.0 : 0.0

    bearEvidence += actualSlope < 0.0 ? 1.5 : 0.0

    bearEvidence += trendSlope < 0.0 ? 1.5 : 0.0

    bearEvidence += belowVwap ? 2.0 : 0.0

    bearEvidence += sellersDominant ? 2.0 : 0.0

    bearEvidence += sellersImproving ? 1.0 : 0.0

    bearEvidence += roBear ? 2.0 : 0.0

    bearEvidence += roBearStrong ? 1.0 : 0.0

    bearEvidence += minusDi > plusDi ? 1.0 : 0.0

    bearEvidence += rsiValue <= 48.0 ? 1.0 : 0.0

    bullState = emaBull and aboveVwap and (buyersDominant or roBull)

    bearState = emaBear and belowVwap and (sellersDominant or roBear)

    bullTurn = close > actualEma and actualSlope > 0.0 and aboveVwap and buyersDominant and roOsc >= 0.0

    bearTurn = close < actualEma and actualSlope < 0.0 and belowVwap and sellersDominant and roOsc <= 0.0

    directionValue = 0.0
    if bullState
        directionValue := 1.0
    else if bearState
        directionValue := -1.0
    else if bullTurn and bullEvidence >= bearEvidence + 2.0
        directionValue := 1.0
    else if bearTurn and bearEvidence >= bullEvidence + 2.0
        directionValue := -1.0
    else if bullEvidence >= bearEvidence + 3.0
        directionValue := 1.0
    else if bearEvidence >= bullEvidence + 3.0
        directionValue := -1.0

    bollingerBasis = ta.sma(close, compressionLength)

    bollingerDeviation = ta.stdev(close, compressionLength) * bollingerMultiplier

    bollingerUpper = bollingerBasis + bollingerDeviation

    bollingerLower = bollingerBasis - bollingerDeviation

    keltnerBasis = ta.ema(close, compressionLength)

    keltnerRange = ta.atr(compressionLength) * keltnerMultiplier

    keltnerUpper = keltnerBasis + keltnerRange

    keltnerLower = keltnerBasis - keltnerRange

    compressionActive = bollingerUpper < keltnerUpper and bollingerLower > keltnerLower

    compressionReleaseEvent = not compressionActive and compressionActive[1]

    barsSinceCompressionRelease = nz(ta.barssince(compressionReleaseEvent), 10000)

    compressionReleased = barsSinceCompressionRelease <= compressionMemoryBars

    priorHigh = ta.highest(high, breakoutLength)[1]

    priorLow = ta.lowest(low, breakoutLength)[1]

    distanceToHighPercent = close > 0.0 and not na(priorHigh) ? math.abs(priorHigh - close) / close * 100.0 : 100.0

    distanceToLowPercent = close > 0.0 and not na(priorLow) ? math.abs(close - priorLow) / close * 100.0 : 100.0

    bullBreakout = not na(priorHigh) and close > priorHigh

    bearBreakout = not na(priorLow) and close < priorLow

    nearBullBreakout = not bullBreakout and distanceToHighPercent <= breakoutProximityPercent

    nearBearBreakout = not bearBreakout and distanceToLowPercent <= breakoutProximityPercent

    demandLevel = ta.lowest(low, structureLookback)

    supplyLevel = ta.highest(high, structureLookback)

    distanceFromDemand = safeAtr > 0.0 ? math.abs(close - demandLevel) / safeAtr : 100.0

    distanceFromSupply = safeAtr > 0.0 ? math.abs(supplyLevel - close) / safeAtr : 100.0

    nearDemand = distanceFromDemand <= zoneAtrDistance

    nearSupply = distanceFromSupply <= zoneAtrDistance

    bullFvgEvent = low > high[2]

    bearFvgEvent = high < low[2]

    bullFvgBottom = ta.valuewhen(bullFvgEvent, high[2], 0)

    bullFvgTop = ta.valuewhen(bullFvgEvent, low, 0)

    bearFvgBottom = ta.valuewhen(bearFvgEvent, high, 0)

    bearFvgTop = ta.valuewhen(bearFvgEvent, low[2], 0)

    bullFvgRecent = nz(ta.barssince(bullFvgEvent), 10000) <= fvgLookback

    bearFvgRecent = nz(ta.barssince(bearFvgEvent), 10000) <= fvgLookback

    nearBullFvg = bullFvgRecent and not na(bullFvgBottom) and not na(bullFvgTop) and close >= bullFvgBottom - safeAtr * 0.50 and close <= bullFvgTop + safeAtr * 0.50

    nearBearFvg = bearFvgRecent and not na(bearFvgBottom) and not na(bearFvgTop) and close >= bearFvgBottom - safeAtr * 0.50 and close <= bearFvgTop + safeAtr * 0.50

    squeezeValue = compressionReleased ? 2.0 : compressionActive ? 1.0 : 0.0

    breakoutValue = 0.0
    if directionValue > 0.0
        breakoutValue := bullBreakout ? 2.0 : nearBullBreakout ? 1.0 : 0.0
    else if directionValue < 0.0
        breakoutValue := bearBreakout ? -2.0 : nearBearBreakout ? -1.0 : 0.0

    structureValue = 0.0
    if directionValue > 0.0 and nearDemand
        structureValue := 1.0
    else if directionValue < 0.0 and nearSupply
        structureValue := -1.0

    fvgValue = 0.0
    if directionValue > 0.0 and nearBullFvg
        fvgValue := 1.0
    else if directionValue < 0.0 and nearBearFvg
        fvgValue := -1.0

    speedRaw = math.abs(actualSlope) / safeAtr

    speedAlignment = 0.25
    if directionValue > 0.0
        speedAlignment := actualSlope > 0.0 ? 1.0 : 0.35
    else if directionValue < 0.0
        speedAlignment := actualSlope < 0.0 ? 1.0 : 0.35

    speedValue = f_clamp(speedRaw * speedAlignment, 0.0, 2.0)

    directionalEvidence = math.max(bullEvidence, bearEvidence)
    opposingEvidence = math.min(bullEvidence, bearEvidence)
    if directionValue > 0.0
        directionalEvidence := bullEvidence
        opposingEvidence := bearEvidence
    else if directionValue < 0.0
        directionalEvidence := bearEvidence
        opposingEvidence := bullEvidence

    evidenceSpread = directionalEvidence - opposingEvidence

    strongTrend = false
    moderateTrend = false
    if directionValue > 0.0
        strongTrend := emaBull and aboveVwap and buyersDominant and (roBull or plusDi > minusDi) and adxValue >= minimumAdx
        moderateTrend := close > actualEma and actualSlope > 0.0 and aboveVwap and evidenceSpread >= 2.0
    else if directionValue < 0.0
        strongTrend := emaBear and belowVwap and sellersDominant and (roBear or minusDi > plusDi) and adxValue >= minimumAdx
        moderateTrend := close < actualEma and actualSlope < 0.0 and belowVwap and evidenceSpread >= 2.0

    trendStrengthValue = 0.0
    if strongTrend
        trendStrengthValue := 3.0
    else if moderateTrend
        trendStrengthValue := 2.0
    else if directionValue != 0.0
        trendStrengthValue := 1.0

    currentRange = high - low

    averageRange = ta.sma(high - low, atrLength)

    rangeExpansion = averageRange > 0.0 ? currentRange / averageRange : 0.0

    volatilityScore = math.min(

         atrPercent / math.max(targetAtrPercent, 0.01) * 8.0,

         8.0

    )

    volumeScore = 0.0
    if relativeVolume >= 3.0
        volumeScore := 10.0
    else if relativeVolume >= 2.0
        volumeScore := 8.0
    else if relativeVolume >= highRelativeVolume
        volumeScore := 6.0
    else if relativeVolume >= 1.0
        volumeScore := 3.0

    expansionScore = 0.0
    if rangeExpansion >= 2.0
        expansionScore := 7.0
    else if rangeExpansion >= 1.50
        expansionScore := 5.0
    else if rangeExpansion >= 1.25
        expansionScore := 3.0

    trendQualityScore = directionValue == 0.0 ? math.min(directionalEvidence * 2.0, 18.0) : math.min(directionalEvidence * 2.4, 32.0)
    alignmentScore = directionValue != 0.0 ? math.min(math.max(evidenceSpread, 0.0) * 2.5, 15.0) : 0.0
    pressureMoveScore = pressureDirection == directionValue and directionValue != 0.0 ? pressureScore / 10.0 : 0.0

    speedMoveScore = math.min(speedValue * 10.0, 10.0)

    setupScore = compressionReleased ? 8.0 : compressionActive ? 4.0 : 0.0
    setupScore += math.abs(breakoutValue) == 2.0 ? 8.0 : math.abs(breakoutValue) == 1.0 ? 4.0 : 0.0

    setupScore += structureValue != 0.0 ? 3.0 : 0.0

    setupScore += fvgValue != 0.0 ? 3.0 : 0.0

    moveScore = f_clamp(

         trendQualityScore +

         alignmentScore +

         pressureMoveScore +

         speedMoveScore +

         volumeScore +

         volatilityScore +

         expansionScore +

         setupScore,

         0.0,

         100.0

    )

    [moveScore, directionValue, relativeVolume, squeezeValue, breakoutValue, structureValue, fvgValue, speedValue, trendStrengthValue]

//====================================================
// DAILY METRICS ENGINE
//====================================================

f_daily_metrics() =>

    dailyAtr = ta.atr(10)

    [dailyAtr[1], high, low]

//====================================================
// SYMBOL ARRAY
//====================================================

symbols = array.from(

     symbol01,

     symbol02,

     symbol03,

     symbol04,

     symbol05,

     symbol06,

     symbol07,

     symbol08,

     symbol09,

     symbol10,

     symbol11,

     symbol12,

     symbol13,

     symbol14,

     symbol15,

     symbol16,

     symbol17,

     symbol18,

     symbol19,

     symbol20

)

//====================================================
// RESULT ARRAYS
//====================================================

scores = array.new_float()

directions = array.new_float()

atrValues = array.new_float()

atrAmountValues = array.new_float()

rvolValues = array.new_float()

squeezeValues = array.new_float()

breakoutValues = array.new_float()

structureValues = array.new_float()

fvgValues = array.new_float()

speedValues = array.new_float()

trendStrengthValues = array.new_float()

//====================================================
// RESULT STORAGE HELPER
//====================================================

f_push_result(

     float resultScore,

     float resultDirection,

     float resultRvol,

     float resultSqueeze,

     float resultBreakout,

     float resultStructure,

     float resultFvg,

     float resultSpeed,

     float resultTrendStrength,

     float resultDailyAtr,

     float resultDailyHigh,

     float resultDailyLow) =>

    resultAtrUsed = resultDailyAtr > 0.0 ? math.max(resultDailyHigh - resultDailyLow, 0.0) / resultDailyAtr * 100.0 : 0.0

    array.push(scores, nz(resultScore, 0.0))

    array.push(directions, nz(resultDirection, 0.0))

    array.push(atrValues, nz(resultAtrUsed, 0.0))

    array.push(atrAmountValues, nz(resultDailyAtr, 0.0))

    array.push(rvolValues, nz(resultRvol, 0.0))

    array.push(squeezeValues, nz(resultSqueeze, 0.0))

    array.push(breakoutValues, nz(resultBreakout, 0.0))

    array.push(structureValues, nz(resultStructure, 0.0))

    array.push(fvgValues, nz(resultFvg, 0.0))

    array.push(speedValues, nz(resultSpeed, 0.0))

    array.push(trendStrengthValues, nz(resultTrendStrength, 0.0))

//====================================================
// REQUEST SYMBOL DATA
//====================================================

[score01, direction01, rvol01, squeeze01, breakout01, structure01, fvg01, speed01, trendStrength01] = request.security(symbol01, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr01, dailyHigh01, dailyLow01] = request.security(symbol01, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score02, direction02, rvol02, squeeze02, breakout02, structure02, fvg02, speed02, trendStrength02] = request.security(symbol02, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr02, dailyHigh02, dailyLow02] = request.security(symbol02, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score03, direction03, rvol03, squeeze03, breakout03, structure03, fvg03, speed03, trendStrength03] = request.security(symbol03, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr03, dailyHigh03, dailyLow03] = request.security(symbol03, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score04, direction04, rvol04, squeeze04, breakout04, structure04, fvg04, speed04, trendStrength04] = request.security(symbol04, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr04, dailyHigh04, dailyLow04] = request.security(symbol04, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score05, direction05, rvol05, squeeze05, breakout05, structure05, fvg05, speed05, trendStrength05] = request.security(symbol05, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr05, dailyHigh05, dailyLow05] = request.security(symbol05, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score06, direction06, rvol06, squeeze06, breakout06, structure06, fvg06, speed06, trendStrength06] = request.security(symbol06, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr06, dailyHigh06, dailyLow06] = request.security(symbol06, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score07, direction07, rvol07, squeeze07, breakout07, structure07, fvg07, speed07, trendStrength07] = request.security(symbol07, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr07, dailyHigh07, dailyLow07] = request.security(symbol07, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score08, direction08, rvol08, squeeze08, breakout08, structure08, fvg08, speed08, trendStrength08] = request.security(symbol08, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr08, dailyHigh08, dailyLow08] = request.security(symbol08, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score09, direction09, rvol09, squeeze09, breakout09, structure09, fvg09, speed09, trendStrength09] = request.security(symbol09, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr09, dailyHigh09, dailyLow09] = request.security(symbol09, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score10, direction10, rvol10, squeeze10, breakout10, structure10, fvg10, speed10, trendStrength10] = request.security(symbol10, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr10, dailyHigh10, dailyLow10] = request.security(symbol10, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score11, direction11, rvol11, squeeze11, breakout11, structure11, fvg11, speed11, trendStrength11] = request.security(symbol11, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr11, dailyHigh11, dailyLow11] = request.security(symbol11, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score12, direction12, rvol12, squeeze12, breakout12, structure12, fvg12, speed12, trendStrength12] = request.security(symbol12, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr12, dailyHigh12, dailyLow12] = request.security(symbol12, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score13, direction13, rvol13, squeeze13, breakout13, structure13, fvg13, speed13, trendStrength13] = request.security(symbol13, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr13, dailyHigh13, dailyLow13] = request.security(symbol13, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score14, direction14, rvol14, squeeze14, breakout14, structure14, fvg14, speed14, trendStrength14] = request.security(symbol14, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr14, dailyHigh14, dailyLow14] = request.security(symbol14, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score15, direction15, rvol15, squeeze15, breakout15, structure15, fvg15, speed15, trendStrength15] = request.security(symbol15, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr15, dailyHigh15, dailyLow15] = request.security(symbol15, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score16, direction16, rvol16, squeeze16, breakout16, structure16, fvg16, speed16, trendStrength16] = request.security(symbol16, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr16, dailyHigh16, dailyLow16] = request.security(symbol16, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score17, direction17, rvol17, squeeze17, breakout17, structure17, fvg17, speed17, trendStrength17] = request.security(symbol17, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr17, dailyHigh17, dailyLow17] = request.security(symbol17, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score18, direction18, rvol18, squeeze18, breakout18, structure18, fvg18, speed18, trendStrength18] = request.security(symbol18, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr18, dailyHigh18, dailyLow18] = request.security(symbol18, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score19, direction19, rvol19, squeeze19, breakout19, structure19, fvg19, speed19, trendStrength19] = request.security(symbol19, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr19, dailyHigh19, dailyLow19] = request.security(symbol19, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

[score20, direction20, rvol20, squeeze20, breakout20, structure20, fvg20, speed20, trendStrength20] = request.security(symbol20, scanTimeframe, f_scan_symbol(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=300)

[dailyAtr20, dailyHigh20, dailyLow20] = request.security(symbol20, "D", f_daily_metrics(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=30)

//====================================================
// STORE RESULTS
//====================================================

f_push_result(score01, direction01, rvol01, squeeze01, breakout01, structure01, fvg01, speed01, trendStrength01, dailyAtr01, dailyHigh01, dailyLow01)

f_push_result(score02, direction02, rvol02, squeeze02, breakout02, structure02, fvg02, speed02, trendStrength02, dailyAtr02, dailyHigh02, dailyLow02)

f_push_result(score03, direction03, rvol03, squeeze03, breakout03, structure03, fvg03, speed03, trendStrength03, dailyAtr03, dailyHigh03, dailyLow03)

f_push_result(score04, direction04, rvol04, squeeze04, breakout04, structure04, fvg04, speed04, trendStrength04, dailyAtr04, dailyHigh04, dailyLow04)

f_push_result(score05, direction05, rvol05, squeeze05, breakout05, structure05, fvg05, speed05, trendStrength05, dailyAtr05, dailyHigh05, dailyLow05)

f_push_result(score06, direction06, rvol06, squeeze06, breakout06, structure06, fvg06, speed06, trendStrength06, dailyAtr06, dailyHigh06, dailyLow06)

f_push_result(score07, direction07, rvol07, squeeze07, breakout07, structure07, fvg07, speed07, trendStrength07, dailyAtr07, dailyHigh07, dailyLow07)

f_push_result(score08, direction08, rvol08, squeeze08, breakout08, structure08, fvg08, speed08, trendStrength08, dailyAtr08, dailyHigh08, dailyLow08)

f_push_result(score09, direction09, rvol09, squeeze09, breakout09, structure09, fvg09, speed09, trendStrength09, dailyAtr09, dailyHigh09, dailyLow09)

f_push_result(score10, direction10, rvol10, squeeze10, breakout10, structure10, fvg10, speed10, trendStrength10, dailyAtr10, dailyHigh10, dailyLow10)

f_push_result(score11, direction11, rvol11, squeeze11, breakout11, structure11, fvg11, speed11, trendStrength11, dailyAtr11, dailyHigh11, dailyLow11)

f_push_result(score12, direction12, rvol12, squeeze12, breakout12, structure12, fvg12, speed12, trendStrength12, dailyAtr12, dailyHigh12, dailyLow12)

f_push_result(score13, direction13, rvol13, squeeze13, breakout13, structure13, fvg13, speed13, trendStrength13, dailyAtr13, dailyHigh13, dailyLow13)

f_push_result(score14, direction14, rvol14, squeeze14, breakout14, structure14, fvg14, speed14, trendStrength14, dailyAtr14, dailyHigh14, dailyLow14)

f_push_result(score15, direction15, rvol15, squeeze15, breakout15, structure15, fvg15, speed15, trendStrength15, dailyAtr15, dailyHigh15, dailyLow15)

f_push_result(score16, direction16, rvol16, squeeze16, breakout16, structure16, fvg16, speed16, trendStrength16, dailyAtr16, dailyHigh16, dailyLow16)

f_push_result(score17, direction17, rvol17, squeeze17, breakout17, structure17, fvg17, speed17, trendStrength17, dailyAtr17, dailyHigh17, dailyLow17)

f_push_result(score18, direction18, rvol18, squeeze18, breakout18, structure18, fvg18, speed18, trendStrength18, dailyAtr18, dailyHigh18, dailyLow18)

f_push_result(score19, direction19, rvol19, squeeze19, breakout19, structure19, fvg19, speed19, trendStrength19, dailyAtr19, dailyHigh19, dailyLow19)

f_push_result(score20, direction20, rvol20, squeeze20, breakout20, structure20, fvg20, speed20, trendStrength20, dailyAtr20, dailyHigh20, dailyLow20)

//====================================================
// SORT RESULTS
//====================================================

sortedIndices = array.sort_indices(scores, order.descending)

//====================================================
// DISPLAY FUNCTIONS
//====================================================

f_direction_text(float value) =>

    value > 0.0 ? "BULL" : value < 0.0 ? "BEAR" : "NEUTRAL"

f_direction_color(float value) =>
    resultColor = color.new(color.gray, 85)
    if value > 0.0
        resultColor := color.new(color.green, 65)
    else if value < 0.0
        resultColor := color.new(color.red, 65)
    resultColor

f_score_color(float value) =>
    resultColor = color.new(color.gray, 85)
    if value >= 80.0
        resultColor := color.new(color.green, 40)
    else if value >= 70.0
        resultColor := color.new(color.green, 60)
    else if value >= 60.0
        resultColor := color.new(color.orange, 55)
    else if value >= 50.0
        resultColor := color.new(color.orange, 72)
    resultColor

f_setup_text(

     float squeezeValue,

     float breakoutValue,

     float structureValue,

     float fvgValue,

     float directionValue) =>

    setupBaseText = "BUILDING"
    if math.abs(breakoutValue) == 2.0
        setupBaseText := directionValue > 0.0 ? "BREAKOUT" : "BREAKDOWN"
    else if squeezeValue == 2.0
        setupBaseText := "SQZ RELEASE"
    else if squeezeValue == 1.0
        setupBaseText := "COMPRESSED"
    else if structureValue != 0.0
        setupBaseText := "AT S/D"
    else if fvgValue != 0.0
        setupBaseText := "AT FVG"
    else if math.abs(breakoutValue) == 1.0
        setupBaseText := "NEAR BREAK"
    else if directionValue == 0.0
        setupBaseText := "WAIT"

    setupArrow = ""
    if directionValue > 0.0
        setupArrow := " ↑"
    else if directionValue < 0.0
        setupArrow := " ↓"

    setupBaseText + setupArrow

f_trend_text(float value) =>
    resultText = "NONE"
    if value == 3.0
        resultText := "STRONG"
    else if value == 2.0
        resultText := "MODERATE"
    else if value == 1.0
        resultText := "WEAK"
    resultText

//====================================================
// TOP 10 TABLE
//====================================================

var table radarTable = table.new(
    tablePosition,
    11,
    22,
    border_width=1,
    frame_width=1
)

if barstate.islast

    table.clear(radarTable, 0, 0, 10, 21)

    headerColor = color.new(color.blue, 10)

    neutralColor = color.new(color.gray, 86)

    table.cell(radarTable, 0, 0, "", height=2)

    table.cell(radarTable, 0, 1, "#", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 1, 1, "Symbol", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 2, 1, "Score", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 3, 1, "Dir", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 4, 1, "Setup", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 5, 1, "RVOL", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 6, 1, "ATR", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 7, 1, "ATR Used", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 8, 1, "Speed", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 9, 1, "T-Strength", text_color=color.white, bgcolor=headerColor)

    table.cell(radarTable, 10, 1, "Evidence", text_color=color.white, bgcolor=headerColor)

    for resultRow = 0 to topResults - 1

        sortedIndex = array.get(sortedIndices, resultRow)

        rowSymbol = f_clean_symbol(array.get(symbols, sortedIndex))

        rowScore = array.get(scores, sortedIndex)

        rowDirection = array.get(directions, sortedIndex)

        rowAtr = array.get(atrValues, sortedIndex)

        rowAtrAmount = array.get(atrAmountValues, sortedIndex)

        rowRvol = array.get(rvolValues, sortedIndex)

        rowSqueeze = array.get(squeezeValues, sortedIndex)

        rowBreakout = array.get(breakoutValues, sortedIndex)

        rowStructure = array.get(structureValues, sortedIndex)

        rowFvg = array.get(fvgValues, sortedIndex)

        rowSpeed = array.get(speedValues, sortedIndex)

        rowTrendStrength = array.get(trendStrengthValues, sortedIndex)

        atrDisplayText = "Closed"
        if isPreMarket
            atrDisplayText := "Pre-Market"
        else if isAfterHours
            atrDisplayText := "After Hours"
        else if isRegularSession
            atrDisplayText := str.tostring(rowAtr, "#") + "%"

        tableRow = resultRow + 2

        scoreBackground = f_score_color(rowScore)

        directionBackground = f_direction_color(rowDirection)

        evidenceText = (

             rowSqueeze > 0.0 ? "SQZ " : ""

        ) + (

             rowBreakout != 0.0 ? "BRK " : ""

        ) + (

             rowStructure != 0.0 ? "S/D " : ""

        ) + (

             rowFvg != 0.0 ? "FVG" : ""

        )

        if str.length(evidenceText) > 0
            evidenceText := str.trim(evidenceText)
            if rowDirection > 0.0
                evidenceText := evidenceText + " ↑"
            else if rowDirection < 0.0
                evidenceText := evidenceText + " ↓"
        else if rowDirection == 0.0
            evidenceText := "MIXED"
        else
            evidenceText := rowDirection > 0.0 ? "TREND ↑" : "TREND ↓"

        table.cell(

             radarTable,

             0,

             tableRow,

             str.tostring(resultRow + 1),

             text_color=color.white,

             bgcolor=neutralColor

        )

        table.cell(

             radarTable,

             1,

             tableRow,

             rowSymbol,

             text_color=color.white,

             bgcolor=neutralColor

        )

        table.cell(

             radarTable,

             2,

             tableRow,

             str.tostring(rowScore, "#.0"),

             text_color=color.white,

             bgcolor=scoreBackground

        )

        table.cell(

             radarTable,

             3,

             tableRow,

             f_direction_text(rowDirection),

             text_color=color.white,

             bgcolor=directionBackground

        )

        table.cell(

             radarTable,

             4,

             tableRow,

             f_setup_text(

                 rowSqueeze,

                 rowBreakout,

                 rowStructure,

                 rowFvg,

                 rowDirection

             ),

             text_color=color.white,

             bgcolor=scoreBackground

        )

        table.cell(

             radarTable,

             5,

             tableRow,

             str.tostring(rowRvol, "#.00") + "x",

             text_color=color.white,

             bgcolor=rowRvol >= highRelativeVolume ? color.new(color.orange, 55) : neutralColor

        )

        table.cell(

             radarTable,

             6,

             tableRow,

             "$" + str.tostring(rowAtrAmount, "#.00"),

             text_color=color.white,

             bgcolor=neutralColor

        )

        table.cell(

             radarTable,

             7,

             tableRow,

             atrDisplayText,

             text_color=color.white,

             bgcolor=neutralColor

        )

        table.cell(

             radarTable,

             8,

             tableRow,

             str.tostring(rowSpeed, "#.00"),

             text_color=color.white,

             bgcolor=rowSpeed >= 0.25 ? color.new(color.orange, 60) : neutralColor

        )

        table.cell(

             radarTable,

             9,

             tableRow,

             f_trend_text(rowTrendStrength),

             text_color=color.white,

             bgcolor=rowTrendStrength >= 3.0 and rowDirection != 0.0 ? directionBackground : neutralColor

        )

        table.cell(

             radarTable,

             10,

             tableRow,

             evidenceText,

             text_color=color.white,

             bgcolor=neutralColor

        )

//====================================================
// DYNAMIC TOP SYMBOL ALERT
//====================================================

topCandidateIndex = array.get(sortedIndices, 0)

topCandidateSymbol = f_clean_symbol(

     array.get(symbols, topCandidateIndex)

)

topCandidateScore = array.get(

     scores,

     topCandidateIndex

)

topCandidateDirection = array.get(

     directions,

     topCandidateIndex

)

topCandidateRvol = array.get(

     rvolValues,

     topCandidateIndex

)

topCandidateAtr = array.get(

     atrValues,

     topCandidateIndex

)

topCandidateAtrText = "Closed"
if isPreMarket
    topCandidateAtrText := "Pre-Market"
else if isAfterHours
    topCandidateAtrText := "After Hours"
else if isRegularSession
    topCandidateAtrText := str.tostring(topCandidateAtr, "#") + "%"

var string previousTopSymbol = ""

var float previousTopScore = 0.0

var float previousTopDirection = 0.0

leaderChanged = topCandidateSymbol != previousTopSymbol

directionChanged = topCandidateDirection != previousTopDirection

thresholdCrossed = (

     topCandidateScore >= minimumAlertScore and

     previousTopScore < minimumAlertScore

)

alertReady = (

     topCandidateScore >= minimumAlertScore and

     (

         not alertOnlyWhenLeaderChanges or

         leaderChanged or

         directionChanged or

         thresholdCrossed

     )

)

if barstate.isrealtime and barstate.isconfirmed and alertReady

    alertMessage = (

         "STP Large Move Radar | " +

         topCandidateSymbol +

         " | Direction: " +

         f_direction_text(topCandidateDirection) +

         " | Score: " +

         str.tostring(topCandidateScore, "#.0") +

         " | RVOL: " +

         str.tostring(topCandidateRvol, "#.00") +

         "x | ATR Used: " +

         topCandidateAtrText +

         " | Timeframe: " +

         scanTimeframe

    )

    alert(

         alertMessage,

         alert.freq_once_per_bar_close

    )

if barstate.isconfirmed

    previousTopSymbol := topCandidateSymbol

    previousTopScore := topCandidateScore

    previousTopDirection := topCandidateDirection
````
