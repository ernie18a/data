# TQHQ Script

- url: https://www.tradingview.com/script/IDP4kwJM-TQHQ-Script/
- type: indicator
- pine_id: PUB;fa848112984248c0af7abc08f6f0bbec
- version: 3.0

## Description

This is a TradingView Pine Script indicator that shows prompts directly inside the chart


It uses the 20 SMA and 200 SMA for signal logic


The script does not draw the SMA lines, because they can already be on the chart


On the 2-minute chart it looks for:


20>200 crossover


20<200 crossover


then a very large candle after the crossover to confirm the move




It gives:


ENTRY LONG when 20 SMA crosses above 200 SMA and a huge bullish candle appears above both SMAs


ENTRY SHORT when 20 SMA crosses below 200 SMA and a huge bearish candle appears below both SMAs




It only allows the entry signal within a small number of bars after the crossover


It also limits it to one entry per crossover so there is less noise


On the 5-minute chart it looks for a Super Candle


A Super Candle means:


the new candle is the opposite color of the previous one


it is bigger in body size


it closes past the previous candle’s open


optionally it can also break the previous high or low




The script only works during market hours


The goal is to show only stronger, cleaner entry setups and avoid too many weak prompts

## Source Code

````pine
//@version=6
indicator("2m Immediate Breakout Entry + 5m Super Candle", overlay=true)

// =========================
// SETTINGS
// =========================
fastLen = input.int(20, "Fast SMA", minval=1)
slowLen = input.int(200, "Slow SMA", minval=1)

// 2m narrow-state logic
narrowGapPct = input.float(0.50, "Narrow SMA Gap %", step=0.05)
slopeLookback = input.int(8, "Slope Lookback", minval=1)
parallelSlopeDiffPct = input.float(0.25, "Parallel Slope Difference %", step=0.05)
recentNarrowLookback = input.int(50, "Recent Narrow Lookback Bars", minval=1)
minGapPct = input.float(0.35, "Minimum Gap % To Count As Expansion", step=0.05)

// 2m breakout candle quality
bodyLookback = input.int(40, "Average Body Lookback", minval=1)
hugeBodyMultiplier = input.float(1.50, "Huge Candle Body Multiplier", step=0.05)
atrLen = input.int(14, "ATR Length", minval=1)
atrMultiplier = input.float(1.00, "Candle ATR Multiplier", step=0.05)
bodyToRangeMin = input.float(0.55, "Minimum Body % Of Total Range", step=0.05)
closeNearExtremePct = input.float(0.30, "Close Near High/Low %", step=0.05)

// 5m super candle settings
showSuperCandle = input.bool(true, "Show 5m Super Candle")
superBodyMultiplier = input.float(1.15, "Super Candle Body vs Previous", step=0.05)
superNeedsCloseThroughPrevOpen = input.bool(true, "Super Candle must close beyond previous open")
requireSuperBreak = input.bool(false, "Super Candle must also break previous high/low")
superMinBodyVsAverage = input.float(1.00, "Super Candle Body vs Average", step=0.05)

// Session
marketSession = input.session("0930-1600", "Market Hours")
requireInSession = input.bool(true, "Require Market Hours")

// Visuals
showNarrowMarkers = input.bool(false, "Show Narrow-State Markers")
showEntrySignals = input.bool(true, "Show 2m Entry Signals")

// =========================
// TIMEFRAME GATES
// =========================
is2MinChart = timeframe.period == "2"
is5MinChart = timeframe.period == "5"

// =========================
// SESSION
// =========================
inSession = not na(time(timeframe.period, marketSession))
sessionOk = requireInSession ? inSession : true

// =========================
// SMAS
// =========================
sma20 = ta.sma(close, fastLen)
sma200 = ta.sma(close, slowLen)

upperSMA = math.max(sma20, sma200)
lowerSMA = math.min(sma20, sma200)

// =========================
// SHARED CANDLE STATS
// =========================
bodySize = math.abs(close - open)
avgBody = ta.sma(bodySize, bodyLookback)
candleRange = high - low
atrValue = ta.atr(atrLen)

bullishCandle = close > open
bearishCandle = close < open

bodyPctOfRange = candleRange > 0 ? bodySize / candleRange : 0.0
closeNearHigh = candleRange > 0 ? ((high - close) / candleRange <= closeNearExtremePct) : false
closeNearLow = candleRange > 0 ? ((close - low) / candleRange <= closeNearExtremePct) : false

// =========================
// 2M NARROW STATE
// =========================
gapPct = sma200 != 0 ? math.abs(sma20 - sma200) / sma200 * 100 : 0.0

sma20SlopePct = sma20[slopeLookback] != 0 ? ((sma20 - sma20[slopeLookback]) / sma20[slopeLookback]) * 100 : 0.0
sma200SlopePct = sma200[slopeLookback] != 0 ? ((sma200 - sma200[slopeLookback]) / sma200[slopeLookback]) * 100 : 0.0

parallelState = math.abs(sma20SlopePct - sma200SlopePct) <= parallelSlopeDiffPct
narrowState = gapPct <= narrowGapPct and parallelState

barsSinceNarrow = ta.barssince(narrowState)
recentNarrow = not na(barsSinceNarrow) and barsSinceNarrow <= recentNarrowLookback

gapIncreasing = gapPct > gapPct[1]
gapExpansionStarted = gapPct > minGapPct and gapIncreasing

trendLong = sma20 > sma200
trendShort = sma20 < sma200

// =========================
// 2M BREAKOUT CANDLE QUALITY
// immediate trigger on breakout candle
// =========================
bodyAboveOneSMA = (open > sma20 and close > sma20) or (open > sma200 and close > sma200)
bodyBelowOneSMA = (open < sma20 and close < sma20) or (open < sma200 and close < sma200)

bodyAboveBothSMAs = open > upperSMA and close > upperSMA
bodyBelowBothSMAs = open < lowerSMA and close < lowerSMA

hugeStrongBull = (
    bullishCandle and
    bodySize > avgBody * hugeBodyMultiplier and
    candleRange > atrValue * atrMultiplier and
    bodyPctOfRange >= bodyToRangeMin and
    closeNearHigh and
    bodyAboveBothSMAs
)

hugeStrongBear = (
    bearishCandle and
    bodySize > avgBody * hugeBodyMultiplier and
    candleRange > atrValue * atrMultiplier and
    bodyPctOfRange >= bodyToRangeMin and
    closeNearLow and
    bodyBelowBothSMAs
)

// =========================
// 2M IMMEDIATE ENTRY SIGNALS
// fire on breakout candle, not later
// one signal per breakout cycle
// =========================
var bool longSignalTaken = false
var bool shortSignalTaken = false

if is2MinChart and narrowState
    longSignalTaken := false
    shortSignalTaken := false

entryLong = (
    is2MinChart and
    sessionOk and
    recentNarrow and
    gapExpansionStarted and
    trendLong and
    hugeStrongBull and
    not longSignalTaken
)

entryShort = (
    is2MinChart and
    sessionOk and
    recentNarrow and
    gapExpansionStarted and
    trendShort and
    hugeStrongBear and
    not shortSignalTaken
)

if entryLong
    longSignalTaken := true

if entryShort
    shortSignalTaken := true

// =========================
// 5M SUPER CANDLE
// unchanged logic
// =========================
prevBodySize = bodySize[1]
prevBullish = close[1] > open[1]
prevBearish = close[1] < open[1]

bodyOvertakesPrevious = bodySize > prevBodySize * superBodyMultiplier
bodyAboveAverage = bodySize > avgBody * superMinBodyVsAverage

bullCloseRule = superNeedsCloseThroughPrevOpen ? close > open[1] : true
bearCloseRule = superNeedsCloseThroughPrevOpen ? close < open[1] : true

bullBreakRule = requireSuperBreak ? high > high[1] : true
bearBreakRule = requireSuperBreak ? low < low[1] : true

bullSuperCandle = (
    is5MinChart and
    sessionOk and
    showSuperCandle and
    prevBearish and
    bullishCandle and
    bodyOvertakesPrevious and
    bodyAboveAverage and
    bullCloseRule and
    bullBreakRule
)

bearSuperCandle = (
    is5MinChart and
    sessionOk and
    showSuperCandle and
    prevBullish and
    bearishCandle and
    bodyOvertakesPrevious and
    bodyAboveAverage and
    bearCloseRule and
    bearBreakRule
)

// =========================
// VISUALS
// =========================
plotshape(
    showNarrowMarkers and narrowState and is2MinChart,
    title="NARROW",
    style=shape.circle,
    location=location.belowbar,
    color=color.gray,
    size=size.tiny
)

plotshape(
    showEntrySignals and entryLong,
    title="ENTRY LONG",
    style=shape.labelup,
    location=location.belowbar,
    color=color.green,
    text="ENTRY LONG",
    textcolor=color.white,
    size=size.large
)

plotshape(
    showEntrySignals and entryShort,
    title="ENTRY SHORT",
    style=shape.labeldown,
    location=location.abovebar,
    color=color.red,
    text="ENTRY SHORT",
    textcolor=color.white,
    size=size.large
)

plotshape(
    bullSuperCandle,
    title="Bullish Super Candle",
    style=shape.labeldown,
    location=location.abovebar,
    color=color.lime,
    text="SUPER CANDLE",
    textcolor=color.black,
    size=size.small
)

plotshape(
    bearSuperCandle,
    title="Bearish Super Candle",
    style=shape.labeldown,
    location=location.abovebar,
    color=color.red,
    text="SUPER CANDLE",
    textcolor=color.white,
    size=size.small
)

// =========================
// ALERTS
// =========================
alertcondition(entryLong, title="ENTRY LONG", message="2m ENTRY LONG: Immediate breakout candle after narrow SMA state")
alertcondition(entryShort, title="ENTRY SHORT", message="2m ENTRY SHORT: Immediate breakout candle after narrow SMA state")

alertcondition(bullSuperCandle, title="Bullish Super Candle", message="5m SUPER CANDLE: Bullish candle overtook previous bearish candle")
alertcondition(bearSuperCandle, title="Bearish Super Candle", message="5m SUPER CANDLE: Bearish candle overtook previous bullish candle")
````
