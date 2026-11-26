# OBSIDIAN

- url: https://www.tradingview.com/script/DGkWh99n-OBSIDIAN/
- type: indicator
- pine_id: PUB;ab6b4f2d063d46a9afb1c472096c75fb
- version: 1.0

## Description

Welcome to the OBSIDIAN indicator, This system was built to help traders identify market structures, momentum shifts etc.. with greater clarity. However, before you add this tool to your charts, we need to have a serious, unfiltered conversation about the risk management and market reality.

Let's be completely honest: [b]There is no indicator on Tradingview or anywhere else in the world that boasts 100% accuracy.[/b] The markets are chaotic environment driven by human psychology, algorithmic shifts, and unexpected macroeconomic events.

Obsidian is just a data processing tool, not a crystal ball, it highlights statistical probabilities, not guaranteed outcomes.

If you blindly take every signal in this indicator prints , you will lose your hard-earned money,

An indicator which perform flawlessly in a trending market might get chopped to pieces in a sideways, consolidating market.

To protect your capital and grow as a trader, treat OBSIDIAN as a supporting framework, not a standalone decision maker.

you are the risk manager. Protect your capital first, trade safely, and let the edge play out over time.

## Source Code

````pine
//@version=6
indicator("OBSIDIAN", overlay=true, max_labels_count=500)

//━━━━━━━━━━━ INPUTS ━━━━━━━━━━━//
len1 = input.int(9, "TEMA 1")
len2 = input.int(14, "TEMA 2")
len3 = input.int(20, "TEMA 3")
len4 = input.int(50, "TEMA 4")
len5 = input.int(70, "TEMA 5")
len6 = input.int(100, "TEMA 6")

zLookback = input.int(20, "Z Score Lookback")
adxFast = input.int(9, "ADX Fast")
adxSlow = input.int(14, "ADX Slow")

//━━━━━━━━━━━ POC DRIFT SETTINGS ━━━━━━━━━━━//
pocDriftLen = input.int(8, "POC Drift Length")

//━━━━━━━━━━━ ROLLING POC INPUTS ━━━━━━━━━━━//
pocLookback = input.int(100, "Rolling POC Lookback")
pocBins = input.int(16, "POC Bins", minval=8, maxval=30)

//━━━━━━━━━━━ VALUE AREA SETTINGS ━━━━━━━━━━━//
valueLength = input.int(50, "Value Area Length", minval=10)
showValueArea = input.bool(true, "Show Value Area")

//━━━━━━━━━━━ COMPRESSION SETTINGS ━━━━━━━━━━━//
compressionLen = input.int(20, "Compression Length")
compressionFactor = input.float(0.7, "Compression Threshold")

//━━━━━━━━━━━ LIQUIDITY POOL SETTINGS ━━━━━━━━━━━//

swingLen = input.int(5, "Liquidity Swing Length")

//━━━━━━━━━━━ VOLUME Z-SCORE ━━━━━━━━━━━//
volSma = ta.sma(volume, 20)
volStd = ta.stdev(volume, 20)
volZ = volStd != 0 ? (volume - volSma) / volStd : 0
isVolSpike = volZ > 1.2

//━━━━━━━━━━━ TEMA FUNCTION ━━━━━━━━━━━//
tema(src, len)=>
    e1 = ta.ema(src, len)
    e2 = ta.ema(e1, len)
    e3 = ta.ema(e2, len)
    3 * e1 - 3 * e2 + e3

//━━━━━━━━━━━ COMPOSITE TEMA ━━━━━━━━━━━//
t1 = tema(close, len1)
t2 = tema(close, len2)
t3 = tema(close, len3)
t4 = tema(close, len4)
t5 = tema(close, len5)
t6 = tema(close, len6)

compTEMA = (t1 + t2 + t3 + t4 + t5 + t6) / 6

velocity = compTEMA - compTEMA[1]
accel = velocity - velocity[1]

accelSma = ta.sma(accel, zLookback)
accelStd = ta.stdev(accel, zLookback)
zScore = accelStd != 0 ? (accel - accelSma) / accelStd : 0

temaBull = close > compTEMA

//━━━━━━━━━━━ MULTI ADX ━━━━━━━━━━━//
[p1, m1, a1] = ta.dmi(adxFast, adxFast)
[p2, m2, a2] = ta.dmi(adxSlow, adxSlow)

multiADX = ((a1 * 2) + a2) / 3
normADX = math.min(multiADX / 50.0, 1.0)

//━━━━━━━━━━━ RSI STACK ━━━━━━━━━━━//
rsiFast = ta.rsi(close, 9) - 50
rsiMed  = ta.rsi(close, 14) - 50
rsiSlow = ta.rsi(close, 20) - 50

rsiBull = rsiFast > 0 and rsiMed > 0 and rsiSlow > 0
rsiSlope = rsiMed - rsiMed[1]

//━━━━━━━━━━━ OPTIMIZED ROLLING POC ENGINE ━━━━━━━━━━━//

priceHigh = ta.highest(high, pocLookback)
priceLow  = ta.lowest(low, pocLookback)
priceRange = priceHigh - priceLow

float pocLevel = na

if priceRange > 0
    binSize = priceRange / pocBins
    
    // create volume bins
    float maxVol = 0.0
    
    for i = 0 to pocBins - 1
        float binVol = 0.0
        binLow = priceLow + i * binSize
        binHigh = binLow + binSize
        
        for j = 0 to pocLookback - 1
            price = close[j]
            if price >= binLow and price < binHigh
                binVol += volume[j]
        
        if binVol > maxVol
            maxVol := binVol
            pocLevel := (binLow + binHigh) / 2

//━━━━━━━━━━━ VALUE AREA ENGINE ━━━━━━━━━━━//

valueRange = ta.stdev(close, valueLength)

vah = pocLevel + valueRange
val = pocLevel - valueRange

//━━━━━━━━━━━ POC DRIFT ENGINE ━━━━━━━━━━━//

pocDrift = pocLevel - pocLevel[pocDriftLen]

pocDriftUp = pocDrift > 0
pocDriftDown = pocDrift < 0

pocDriftStrength = math.abs(pocDrift)

strongDrift = pocDriftStrength > syminfo.mintick * 10

//━━━━━━━━━━━ VALUE BIAS (TEMA vs POC) ━━━━━━━━━━━//

valueBull = compTEMA > pocLevel
valueBear = compTEMA < pocLevel

//━━━━━━━━━━━ VALUE SHIFT EVENTS (Filtered) ━━━━━━━━━━━//

strongTrend = multiADX > 20

pocBullCross = ta.crossover(compTEMA, pocLevel) and strongTrend
pocBearCross = ta.crossunder(compTEMA, pocLevel) and strongTrend

//━━━━━━━━━━━ VALUE BREAK DETECTION ━━━━━━━━━━━//

bullBreak = close > vah and close[1] <= vah
bearBreak = close < val and close[1] >= val

//━━━━━━━━━━━ VALUE MIGRATION ENGINE ━━━━━━━━━━━//

strongDriftFilter = pocDriftStrength > syminfo.mintick * 10

valueMigrationBull =
     pocDriftUp and
     valueBull and
     bullBreak and
     strongDriftFilter

valueMigrationBear =
     pocDriftDown and
     valueBear and
     bearBreak and
     strongDriftFilter

//━━━━━━━━━━━ MARKET PHASE ━━━━━━━━━━━//
isSqueeze = multiADX < 18
isExpansion = multiADX > 23 and multiADX > multiADX[1]

//━━━━━━━━━━━ LIQUIDITY VACUUM ENGINE ━━━━━━━━━━━//

barRange = high - low
avgRange = ta.sma(barRange, 20)

rangeExpansion = barRange > avgRange * 1.5

distanceFromPOC = math.abs(close - pocLevel)
avgDistance = ta.sma(math.abs(close - pocLevel), 20)

vacuumMove = distanceFromPOC > avgDistance * 1.3

liquidityVacuum = rangeExpansion and vacuumMove

//━━━━━━━━━━━ COMPRESSION DETECTOR ━━━━━━━━━━━//

avgRangeCompression = ta.sma(barRange, compressionLen)

compression = barRange < avgRangeCompression * compressionFactor

compressionCount = math.sum(compression ? 1 : 0, 6)

compressionZone = compressionCount >= 4

//━━━━━━━━━━━ LIQUIDITY POOLS (SWING LEVELS) ━━━━━━━━━━━//

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow = ta.pivotlow(low, swingLen, swingLen)

var float liquidityHigh = na
var float liquidityLow = na

if not na(swingHigh)
    liquidityHigh := swingHigh

if not na(swingLow)
    liquidityLow := swingLow

//━━━━━━━━━━━ SMART LIQUIDITY TRAP DETECTOR ━━━━━━━━━━━//

bullTrap =
     high > liquidityHigh and
     close < liquidityHigh and
     barRange > avgRangeCompression

bearTrap =
     low < liquidityLow and
     close > liquidityLow and
     barRange > avgRangeCompression

//━━━━━━━━━━━ VACUUM IGNITION DETECTOR ━━━━━━━━━━━//

vacuumStart = liquidityVacuum and not liquidityVacuum[1] and multiADX > 20

//━━━━━━━━━━━ SIGNAL SCORING ━━━━━━━━━━━//
trendScore = temaBull ? 20.0 : 0.0
rsiScore   = rsiBull ? 20.0 : 0.0
volScore   = isVolSpike ? 20.0 : 0.0
adxScore   = normADX * 20.0

momentumScoreRaw = zScore * 5.0
momentumScore = math.max(math.min(momentumScoreRaw, 20.0), -20.0)

totalScoreRaw = trendScore + rsiScore + volScore + adxScore + momentumScore
score = math.max(math.min(totalScoreRaw, 100.0), 0.0)

//━━━━━━━━━━━ MASTER SIGNALS ━━━━━━━━━━━//
longSignal = score > 70 and not isSqueeze and rsiSlope > 0
shortSignal = score > 70 and not isSqueeze and rsiSlope < 0

//━━━━━━━━━━━ VISUALS ━━━━━━━━━━━//

trendColor = temaBull ? color.lime : color.red

// Thin line (default)
plot(compTEMA,
     title="Trend Spine Thin",
     color=color.new(trendColor, isExpansion ? 100 : 0),
     linewidth=2)

// Thick line (only when expansion)
plot(compTEMA,
     title="Trend Spine Thick",
     color=color.new(trendColor, isExpansion ? 0 : 100),
     linewidth=5)

bgcolor(isSqueeze ? color.new(#7d8191, 90) : na)

plotshape(longSignal,
     title="Long Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.small)

plotshape(shortSignal,
     title="Short Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small)

plotshape(pocBullCross,
     title="POC Bullish Shift",
     location=location.belowbar,
     color=color.aqua,
     style=shape.circle,
     size=size.tiny)

plotshape(pocBearCross,
     title="POC Bearish Shift",
     location=location.abovebar,
     color=color.orange,
     style=shape.circle,
     size=size.tiny)

plotshape(vacuumStart,
     title="Vacuum Ignition",
     location=location.abovebar,
     color=color.purple,
     style=shape.diamond,
     size=size.tiny)

plotshape(bullTrap,
     title="Bull Liquidity Trap",
     location=location.abovebar,
     color=color.red,
     style=shape.xcross,
     size=size.small)

plotshape(bearTrap,
     title="Bear Liquidity Trap",
     location=location.belowbar,
     color=color.lime,
     style=shape.xcross,
     size=size.small)

//━━━━━━━━━━━ VALUE MIGRATION ARROWS ━━━━━━━━━━━//

plotshape(valueMigrationBull,
     title="Value Migration Bull",
     location=location.belowbar,
     style=shape.labelup,
     text="⬆",
     color=color.lime,
     textcolor=color.black,
     size=size.small)

plotshape(valueMigrationBear,
     title="Value Migration Bear",
     location=location.abovebar,
     style=shape.labeldown,
     text="⬇",
     color=color.red,
     textcolor=color.white,
     size=size.small)

//━━━━━━━━━━━ MARKET PHASE COLOR ENGINE ━━━━━━━━━━━//

phaseColor =
     liquidityVacuum ? color.new(color.purple, 85) :
     compressionZone ? color.new(color.blue, 90) :
     na

bgcolor(phaseColor)

//━━━━━━━━━━━ SCORE LABEL ━━━━━━━━━━━//
var label powerLabel = na

//━━━━━━━━━━━ POC DRIFT COLOR ━━━━━━━━━━━//

pocColor =
     pocDriftUp and strongDrift ? color.lime :
     pocDriftDown and strongDrift ? color.red :
     color.orange

plot(pocLevel,
     title="Rolling POC",
     color=pocColor,
     linewidth=2,
     style=plot.style_stepline)

//━━━━━━━━━━━ VALUE AREA PLOTS ━━━━━━━━━━━//

plot(showValueArea ? vah : na,
     title="VAH",
     color=color.new(color.green, 0),
     linewidth=1)

plot(showValueArea ? val : na,
     title="VAL",
     color=color.new(color.red, 0),
     linewidth=1)

if barstate.islast
    if not na(powerLabel)
        label.delete(powerLabel)
    powerLabel := label.new(
        bar_index,
        high,
        "Power: " + str.tostring(math.round(score, 1)),
        style=label.style_label_down,
        color=color.new(color.black, 70),
        textcolor=color.white)
````
