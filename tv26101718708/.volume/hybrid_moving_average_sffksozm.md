# Hybrid Moving Average

- url: https://www.tradingview.com/script/sFfkSozm-Hybrid-Moving-Average/
- type: indicator
- pine_id: PUB;5ff0bb0308b7473989e6ee3b4a147ae4
- version: 1.0

## Description

The [b]Hybrid Moving Average[/b] is a single-line moving average combining aspects of Hull MA, KAMA, VWAP, ALMA, and Heikin-Ashi candles into one adaptive line. 

The aim is to stay smooth during noisy price action, but still react when price starts to move with intent.

[b]HyMA[/b] uses two internal checks.
The first looks for broader agreement across several moving average styles.
The second is faster and looks for signs that price is actively switching trend.

The line only turns bullish or bearish when both checks agree.
[list]
[*]Green = bullish
[*]Red = bearish
[*]Amber = mixed / no clear agreement
[/list]

This helps avoid some of the quick colour flips that can happen when price briefly crosses a normal moving average.

[b]Settings[/b]
[list]
[*]Source - price source used by the indicator
[*]Length - main lookback length. Default 34
[*]Agreement Needed - how much internal agreement is required before the line changes trend colour
[*]Composite Consensus Weight - controls the balance between the slower consensus side and the faster switch side
[*]Composite Stability Deadband ATRs - helps reduce small wiggles in the final line
[*]Cross Pull Strength - controls how strongly price movement affects the faster side
[*]Trend Memory - controls how much the faster side holds its previous direction
[*]Bull / Bear / Neutral Colours - line colours
[/list]

[i][b]Note: [/b]HyMA is intended as a trend filter and visual guide, not a complete trading system on its own.
Lower agreement settings will react faster but may be noisier. Higher agreement settings will be stricter but may confirm later.[/i]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © godzcopilot

//@version=6
indicator('Hybrid Moving Average', 'HyMA', overlay = true)

// Hybrid Moving Average combines adaptive, volume-weighted, Hull, ALMA,
// and Heikin-Ashi structure into one trend line. The line turns bullish or bearish
// only when both its consensus engine and trend-switch engine agree.

groupCore = 'Core'
src = input.source(close, 'Source', group = groupCore)
length = input.int(50, 'Length', minval = 2, group = groupCore)
agreementNeeded = input.int(4, 'Agreement Needed', minval = 2, maxval = 6, group = groupCore)
compositeConsensusWeight = input.float(0.58, 'Composite Consensus Weight', minval = 0.0, maxval = 1.0, step = 0.01, group = groupCore)
stabilityDeadband = input.float(0.04, 'Composite Stability Deadband ATRs', minval = 0.0, maxval = 0.50, step = 0.01, group = groupCore)

groupResponse = 'Trend Switch Response'
crossPull = input.float(0.38, 'Cross Pull Strength', minval = 0.0, maxval = 1.0, step = 0.01, group = groupResponse)
trendMemory = input.float(0.62, 'Trend Memory', minval = 0.05, maxval = 0.95, step = 0.01, group = groupResponse)

groupColors = 'Colors'
bullColor = input.color(#089981, 'Bull', inline = 'c', group = groupColors)
bearColor = input.color(#F23645, 'Bear', inline = 'c', group = groupColors)
neutralColor = input.color(#F7B801, 'Neutral', inline = 'c', group = groupColors)

clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

safeDiv(float numerator, float denominator, float fallback) =>
    math.abs(denominator) > 1e-10 ? numerator / denominator : fallback

hma(float source, int len) =>
    halfLen = math.max(1, int(math.round(len / 2.0)))
    rootLen = math.max(1, int(math.round(math.sqrt(len))))
    ta.wma(2.0 * ta.wma(source, halfLen) - ta.wma(source, len), rootLen)

thma(float source, int len) =>
    thirdLen = math.max(1, int(math.round(len / 3.0)))
    halfLen = math.max(1, int(math.round(len / 2.0)))
    ta.wma(ta.wma(source, thirdLen) * 3.0 - ta.wma(source, halfLen) - ta.wma(source, len), math.max(1, len))

ehma(float source, int len) =>
    halfLen = math.max(1, int(math.round(len / 2.0)))
    rootLen = math.max(1, int(math.round(math.sqrt(len))))
    ta.ema(2.0 * ta.ema(source, halfLen) - ta.ema(source, len), rootLen)

kama(float source, int erLen, int fastLen, int slowLen) =>
    changeAbs = math.abs(source - source[erLen])
    volatility = math.sum(math.abs(ta.change(source)), erLen)
    er = safeDiv(changeAbs, volatility, 0.0)
    fastSC = 2.0 / (fastLen + 1.0)
    slowSC = 2.0 / (slowLen + 1.0)
    sc = math.pow(er * (fastSC - slowSC) + slowSC, 2.0)
    out = 0.0
    out := na(out[1]) ? source : out[1] + sc * (source - out[1])
    out

rollingVwap(int len) =>
    pv = math.sum(hlc3 * volume, len)
    vol = math.sum(volume, len)
    safeDiv(pv, vol, ta.vwma(hlc3, len))

efficiency(float source, int len) =>
    changeAbs = math.abs(source - source[len])
    volatility = math.sum(math.abs(ta.change(source)), len)
    clamp(safeDiv(changeAbs, volatility, 0.0), 0.0, 1.0)

maVote(float source, float maLine) =>
    source > maLine and maLine >= maLine[1] ? 1 : source < maLine and maLine <= maLine[1] ? -1 : source > maLine ? 1 : source < maLine ? -1 : 0

lenBase = math.max(2, length)
lenFast = math.max(2, int(math.round(length * 0.60)))
lenSlow = math.max(lenBase, int(math.round(length * 4.0)))
lenTrigger = math.max(1, int(math.round(length * 0.25)))
lenEfficiency = math.max(2, int(math.round(length * 0.60)))

haClose = (open + high + low + close) / 4.0
haOpen = 0.0
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
haMid = (haOpen + haClose) / 2.0

// Broad consensus engine.
hullLine = hma(src, lenBase)
turboHull = thma(src, lenFast)
kamaLine = kama(src, lenEfficiency, 2, math.max(10, lenBase))
vwapLine = rollingVwap(lenBase)
almaLine = ta.alma(src, lenBase, 0.85, 6.0)
haLine = hma(haMid, lenBase)
slowLine = (ta.alma(src, lenSlow, 0.85, 6.0) + rollingVwap(lenSlow) + kama(src, lenSlow, 4, lenSlow * 2)) / 3.0

voteHull = maVote(close, hullLine)
voteTurbo = maVote(close, turboHull)
voteKama = maVote(close, kamaLine)
voteVwap = maVote(close, vwapLine)
voteAlma = maVote(close, almaLine)
voteHa = haClose > haOpen and close > haLine ? 1 : haClose < haOpen and close < haLine ? -1 : maVote(close, haLine)
voteTotal = voteHull + voteTurbo + voteKama + voteVwap + voteAlma + voteHa

atr = math.max(ta.atr(lenBase), syminfo.mintick)
agreementWeight = math.abs(voteTotal) / 6.0
reactiveWeight = clamp(0.25 + agreementWeight * 0.50 + math.abs(close - slowLine) / atr * 0.08, 0.20, 0.82)
fastConsensus = (hullLine + turboHull + kamaLine) / 3.0
slowConsensus = (vwapLine + almaLine + haLine + slowLine) / 4.0
consensusHybrid = fastConsensus * reactiveWeight + slowConsensus * (1.0 - reactiveWeight)

consensusDirection = voteTotal >= agreementNeeded and close > consensusHybrid ? 1 : voteTotal <= -agreementNeeded and close < consensusHybrid ? -1 : 0

// Faster trend-switch engine.
trigger = ta.ema(src, lenTrigger)
switchHull = hma(src, lenBase)
switchEhull = ehma(src, math.max(2, int(math.round(lenBase * 0.75))))
switchKama = kama(src, lenEfficiency, 2, math.max(8, lenBase))
switchHa = hma(haMid, lenBase)
switchVwap = rollingVwap(lenBase)
rawSwitch = switchHull * 0.28 + switchEhull * 0.18 + switchKama * 0.24 + switchHa * 0.18 + switchVwap * 0.12

trendSwitch = 0.0
switchEr = efficiency(src, lenEfficiency)
switchAtr = math.max(ta.atr(lenBase), syminfo.mintick)
pricePressure = clamp((trigger - nz(trendSwitch[1], rawSwitch)) / switchAtr, -1.0, 1.0)
crossEvent = ta.cross(trigger, nz(trendSwitch[1], rawSwitch))
baseAlpha = clamp((1.0 - trendMemory) + switchEr * 0.18, 0.03, 0.65)
reactiveAlpha = clamp(baseAlpha + math.abs(pricePressure) * 0.12 + (crossEvent ? crossPull : 0.0), 0.03, 0.88)
trendSwitch := na(trendSwitch[1]) ? rawSwitch : trendSwitch[1] + reactiveAlpha * (rawSwitch - trendSwitch[1])

hullVote = switchHull > switchHull[1] ? 1 : switchHull < switchHull[1] ? -1 : 0
kamaVote = src > switchKama ? 1 : src < switchKama ? -1 : 0
haVote = haClose > haOpen ? 1 : haClose < haOpen ? -1 : 0
vwapVote = src > switchVwap ? 1 : src < switchVwap ? -1 : 0
switchVote = trendSwitch > trendSwitch[1] ? 1 : trendSwitch < trendSwitch[1] ? -1 : 0
triggerVote = trigger > trendSwitch ? 1 : trigger < trendSwitch ? -1 : 0
switchVoteTotal = hullVote + kamaVote + haVote + vwapVote + switchVote + triggerVote
switchDirection = switchVoteTotal >= agreementNeeded and close > trendSwitch ? 1 : switchVoteTotal <= -agreementNeeded and close < trendSwitch ? -1 : 0

alignedDirection = consensusDirection == 1 and switchDirection == 1 ? 1 : consensusDirection == -1 and switchDirection == -1 ? -1 : 0
lineColor = alignedDirection == 1 ? bullColor : alignedDirection == -1 ? bearColor : neutralColor

rawComposite = consensusHybrid * compositeConsensusWeight + trendSwitch * (1.0 - compositeConsensusWeight)
deadband = atr * stabilityDeadband
compositeHybrid = 0.0
compositeDelta = rawComposite - nz(compositeHybrid[1], rawComposite)
compositeHybrid := na(compositeHybrid[1]) ? rawComposite : math.abs(compositeDelta) <= deadband ? compositeHybrid[1] : rawComposite - math.sign(compositeDelta) * deadband

bullishTrendChange = alignedDirection == 1 and nz(alignedDirection[1], 0) != 1
bearishTrendChange = alignedDirection == -1 and nz(alignedDirection[1], 0) != -1

plot(compositeHybrid, 'Hybrid Adaptive Trend Average', lineColor, 3)

alertcondition(bullishTrendChange, 'HATA Bullish Trend Change', 'HATA turned bullish on {{exchange}}:{{ticker}} at {{close}}')
alertcondition(bearishTrendChange, 'HATA Bearish Trend Change', 'HATA turned bearish on {{exchange}}:{{ticker}} at {{close}}')
````
