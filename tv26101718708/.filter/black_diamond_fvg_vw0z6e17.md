# Black Diamond FVG

- url: https://www.tradingview.com/script/VW0Z6e17-Black-Diamond-FVG/
- type: indicator
- pine_id: PUB;8c2dfcbb4d354ee28a6a80cef381db1e
- version: 2.0

## Description

Black Diamond FVG™
Smart Fair Value Gap Detection & Strength Grading
Overview

Black Diamond FVG™ is an advanced Fair Value Gap indicator designed to eliminate chart clutter and focus on the highest-quality market imbalances.

Unlike traditional FVG indicators that plot every gap regardless of quality, Black Diamond FVG™ analyses each Fair Value Gap and assigns a strength rating based on displacement, gap size, trend alignment, and overall market conditions.

The result is a cleaner chart with fewer low-probability zones and greater focus on institutional-grade imbalances that are more likely to attract price back into them.

Whether you trade Forex, Indices, Gold, Crypto, or Stocks, Black Diamond FVG™ helps traders identify potential reaction zones where price may revisit before continuing its move.

Key Features

✅ Automatic Fair Value Gap Detection

✅ Strength-Graded FVGs

✅ Low, Medium, Strong & Very Strong Ratings

✅ Percentage Strength Score

✅ Bullish & Bearish FVG Identification

✅ Adjustable Extension Length

✅ Auto Removal of Filled FVGs

✅ Customisable Colours & Text

✅ Trend-Based Filtering

✅ Cleaner Charts With Less Noise

✅ Suitable For All Markets & Timeframes

Understanding Fair Value Gaps

A Fair Value Gap (FVG) occurs when aggressive buying or selling creates an imbalance in price delivery.

This typically forms when a strong candle leaves a gap between the high and low of surrounding candles.

These areas often act as magnets for future price movement as the market seeks to rebalance inefficiencies.

However, not all FVGs are equal.

Many FVG indicators display every imbalance, creating hundreds of zones that provide little value.

Black Diamond FVG™ solves this problem by identifying and grading only the most meaningful gaps.

Strength Ratings Explained
Low Strength

These FVGs show minimal imbalance and weaker market participation.

Best used as minor areas of interest rather than primary trading zones.

Medium Strength

Moderate imbalance with reasonable displacement.

Can provide reactions but should ideally be combined with additional confluence.

Strong

Significant imbalance supported by strong market movement.

These often produce higher-quality reactions and continuation opportunities.

Very Strong

The highest-rated Fair Value Gaps.

Typically created during aggressive institutional moves, strong displacement candles, or major momentum shifts.

These are generally the most valuable zones on the chart.

Percentage Strength Score

Every FVG receives a percentage score.

Examples:

• Bull FVG Strong 72%

• Bear FVG Very Strong 88%

• Bull FVG Medium 54%

The higher the percentage, the stronger the imbalance.

Recommended Trading Approach

Black Diamond FVG™ works best when combined with:

Market Structure

Look for:

• Higher Highs (HH)

• Higher Lows (HL)

• Lower Highs (LH)

• Lower Lows (LL)

Trend Direction

Trade bullish FVGs in bullish trends.

Trade bearish FVGs in bearish trends.

Liquidity

Combine FVGs with:

• Liquidity sweeps

• Equal highs

• Equal lows

• Session highs and lows

Confirmation

Wait for:

• Rejection candles

• CHoCH

• BOS

• Market structure shifts

before entering trades.

Best Timeframes
Scalping

1 Minute

3 Minute

5 Minute

Recommended Minimum Strength:
60%+

Intraday Trading

15 Minute

30 Minute

1 Hour

Recommended Minimum Strength:
50%+

Swing Trading

4 Hour

Daily

Weekly

Recommended Minimum Strength:
40%+

Market Recommendations
Gold (XAUUSD)

Recommended Minimum Strength:
60%

Gold produces many imbalances, so filtering weaker zones can significantly improve chart clarity.

Forex

Recommended Minimum Strength:
50%

Provides a good balance between frequency and quality.

Indices

Recommended Minimum Strength:
50–60%

Strong displacement moves often create highly respected FVGs.

Cryptocurrency

Recommended Minimum Strength:
60–70%

Helps eliminate excessive noise caused by volatility.

Suggested Settings
Conservative Trader

Minimum Strength:
70%

Focus:
Only Strong and Very Strong FVGs

Best For:
Swing traders and confirmation traders

Balanced Trader

Minimum Strength:
50%

Focus:
Medium, Strong and Very Strong FVGs

Best For:
Most traders

Aggressive Trader

Minimum Strength:
40%

Focus:
All FVGs

Best For:
Scalpers seeking more opportunities

Risk Disclaimer

Black Diamond FVG™ is an educational and analytical tool only.

It does not provide financial advice, trading recommendations, or guaranteed results.

Trading financial markets involves significant risk and may not be suitable for all investors.

Past performance does not guarantee future results.

Always use proper risk management and never risk more than you can afford to lose.

## Source Code

````pine
//@version=6
indicator("Black Diamond FVG", overlay=true, max_boxes_count=500, scale=scale.right)

//━━━━━━━━━━━━━━━━━━━
// SCALE / OVERLAY FIX
//━━━━━━━━━━━━━━━━━━━
plot(close, title="Price Scale Anchor", display=display.none, force_overlay=true)

//━━━━━━━━━━━━━━━━━━━
// USER SETTINGS
//━━━━━━━━━━━━━━━━━━━
showBullish = input.bool(true, "Show Bullish FVGs")
showBearish = input.bool(true, "Show Bearish FVGs")

showLowStrength = input.bool(true, "Show Low Strength FVGs")
showMediumStrength = input.bool(true, "Show Medium Strength FVGs")
showStrongStrength = input.bool(true, "Show Strong FVGs")
showVeryStrongStrength = input.bool(true, "Show Very Strong FVGs")

minStrengthPercent = input.int(40, "Minimum FVG Strength %", minval=10, maxval=100)
extendPastCurrentBar = input.int(5, "Extend FVGs Past Current Bar", minval=1, maxval=50)
deleteFilledGaps = input.bool(true, "Delete Filled FVGs")
maxActiveGaps = input.int(40, "Maximum Active FVGs", minval=1, maxval=100)

showEMAs = input.bool(true, "Show EMAs")

textSizeInput = input.string("Tiny", "FVG Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"])
fvgTextSize = textSizeInput == "Tiny" ? size.tiny : textSizeInput == "Small" ? size.small : textSizeInput == "Normal" ? size.normal : textSizeInput == "Large" ? size.large : size.huge

//━━━━━━━━━━━━━━━━━━━
// COLOUR SETTINGS
//━━━━━━━━━━━━━━━━━━━
bullZoneColour = input.color(color.new(color.green, 85), "Low Bullish Zone Colour")
mediumBullColour = input.color(color.new(color.green, 80), "Medium Bullish Zone Colour")
strongBullColour = input.color(color.new(color.green, 72), "Strong Bullish Zone Colour")
veryStrongBullColour = input.color(color.new(color.lime, 62), "Very Strong Bullish Zone Colour")

bearZoneColour = input.color(color.new(color.red, 85), "Low Bearish Zone Colour")
mediumBearColour = input.color(color.new(color.red, 80), "Medium Bearish Zone Colour")
strongBearColour = input.color(color.new(color.red, 72), "Strong Bearish Zone Colour")
veryStrongBearColour = input.color(color.new(color.maroon, 62), "Very Strong Bearish Zone Colour")

bullTextColour = input.color(color.lime, "Bullish Text Colour")
bearTextColour = input.color(color.red, "Bearish Text Colour")
bullBorderColour = input.color(color.new(color.lime, 0), "Bullish Border Colour")
bearBorderColour = input.color(color.new(color.red, 0), "Bearish Border Colour")

mitigatedColour = input.color(color.new(color.gray, 90), "Filled FVG Colour")
mitigatedTextColour = input.color(color.gray, "Filled FVG Text Colour")

//━━━━━━━━━━━━━━━━━━━
// HIDDEN ENGINE SETTINGS
//━━━━━━━━━━━━━━━━━━━
atrLength = 14
smallGapAtr = 0.05
largeGapAtr = 0.20
displacementAtr = 0.70

useVolumeScore = false
volumeLength = 20
volumeMultiplier = 1.20

useTrendScore = true
fastEmaLength = 20
slowEmaLength = 50

useStructureScore = false
structureLookback = 10

useSweepScore = false
sweepLookback = 8

//━━━━━━━━━━━━━━━━━━━
// CALCULATIONS
//━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLength)
volMA = ta.sma(volume, volumeLength)

fastEMA = ta.ema(close, fastEmaLength)
slowEMA = ta.ema(close, slowEmaLength)

plot(showEMAs ? fastEMA : na, "Fast EMA", color=color.new(color.blue, 0), force_overlay=true)
plot(showEMAs ? slowEMA : na, "Slow EMA", color=color.new(color.orange, 0), force_overlay=true)

//━━━━━━━━━━━━━━━━━━━
// FVG LOGIC
//━━━━━━━━━━━━━━━━━━━
bullishFVG = low > high[2]
bearishFVG = high < low[2]

bullTop = low
bullBottom = high[2]

bearTop = low[2]
bearBottom = high

bullGapSize = bullishFVG ? bullTop - bullBottom : 0.0
bearGapSize = bearishFVG ? bearTop - bearBottom : 0.0

middleCandleRange = high[1] - low[1]

//━━━━━━━━━━━━━━━━━━━
// STRENGTH CONDITIONS
//━━━━━━━━━━━━━━━━━━━
bullTrend = close > fastEMA and fastEMA > slowEMA
bearTrend = close < fastEMA and fastEMA < slowEMA

bullStructure = close > ta.highest(high, structureLookback)[1]
bearStructure = close < ta.lowest(low, structureLookback)[1]

bullSweep = low[1] < ta.lowest(low, sweepLookback)[2] and close[1] > open[1]
bearSweep = high[1] > ta.highest(high, sweepLookback)[2] and close[1] < open[1]

volumeStrong = volume[1] > volMA[1] * volumeMultiplier

//━━━━━━━━━━━━━━━━━━━
// STRENGTH FUNCTION
//━━━━━━━━━━━━━━━━━━━
getStrengthPercent(_gapSize, _isBull) =>
    score = 0
    maxScore = 3

    score += _gapSize >= atr * smallGapAtr ? 1 : 0
    score += _gapSize >= atr * largeGapAtr ? 1 : 0
    score += middleCandleRange >= atr * displacementAtr ? 1 : 0

    if useVolumeScore
        maxScore += 1
        score += volumeStrong ? 1 : 0

    if useTrendScore
        maxScore += 1
        score += _isBull ? (bullTrend ? 1 : 0) : (bearTrend ? 1 : 0)

    if useStructureScore
        maxScore += 1
        score += _isBull ? (bullStructure ? 1 : 0) : (bearStructure ? 1 : 0)

    if useSweepScore
        maxScore += 1
        score += _isBull ? (bullSweep ? 1 : 0) : (bearSweep ? 1 : 0)

    math.round((score / maxScore) * 100)

//━━━━━━━━━━━━━━━━━━━
// STRENGTH NAMES
//━━━━━━━━━━━━━━━━━━━
getStrengthName(_strength) =>
    _strength < 40 ? "Low" : _strength < 60 ? "Medium" : _strength < 80 ? "Strong" : "Very Strong"

strengthAllowed(_strength) =>
    isLow = _strength < 40
    isMedium = _strength >= 40 and _strength < 60
    isStrong = _strength >= 60 and _strength < 80
    isVeryStrong = _strength >= 80

    (isLow and showLowStrength) or (isMedium and showMediumStrength) or (isStrong and showStrongStrength) or (isVeryStrong and showVeryStrongStrength)

//━━━━━━━━━━━━━━━━━━━
// COLOUR LOGIC
//━━━━━━━━━━━━━━━━━━━
getBullBoxColour(_strength) =>
    _strength < 40 ? bullZoneColour : _strength < 60 ? mediumBullColour : _strength < 80 ? strongBullColour : veryStrongBullColour

getBearBoxColour(_strength) =>
    _strength < 40 ? bearZoneColour : _strength < 60 ? mediumBearColour : _strength < 80 ? strongBearColour : veryStrongBearColour

//━━━━━━━━━━━━━━━━━━━
// STRENGTH VALUES
//━━━━━━━━━━━━━━━━━━━
bullStrength = bullishFVG ? getStrengthPercent(bullGapSize, true) : 0
bearStrength = bearishFVG ? getStrengthPercent(bearGapSize, false) : 0

validBullFVG = showBullish and bullishFVG and bullStrength >= minStrengthPercent and strengthAllowed(bullStrength)
validBearFVG = showBearish and bearishFVG and bearStrength >= minStrengthPercent and strengthAllowed(bearStrength)

//━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━
var box[] fvgBoxes = array.new_box()
var float[] fvgTops = array.new_float()
var float[] fvgBottoms = array.new_float()
var bool[] fvgIsBull = array.new_bool()
var bool[] fvgActive = array.new_bool()

//━━━━━━━━━━━━━━━━━━━
// CREATE BULLISH FVG
//━━━━━━━━━━━━━━━━━━━
if validBullFVG
    bullStrengthName = getStrengthName(bullStrength)
    txt = "Bull FVG " + bullStrengthName + " " + str.tostring(bullStrength) + "%"
    rightEdge = bar_index + extendPastCurrentBar

    b = box.new(left=bar_index - 2, right=rightEdge, top=bullTop, bottom=bullBottom, xloc=xloc.bar_index, bgcolor=getBullBoxColour(bullStrength), border_color=bullBorderColour, text=txt, text_color=bullTextColour, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center, force_overlay=true)

    array.push(fvgBoxes, b)
    array.push(fvgTops, bullTop)
    array.push(fvgBottoms, bullBottom)
    array.push(fvgIsBull, true)
    array.push(fvgActive, true)

//━━━━━━━━━━━━━━━━━━━
// CREATE BEARISH FVG
//━━━━━━━━━━━━━━━━━━━
if validBearFVG
    bearStrengthName = getStrengthName(bearStrength)
    txt = "Bear FVG " + bearStrengthName + " " + str.tostring(bearStrength) + "%"
    rightEdge = bar_index + extendPastCurrentBar

    b = box.new(left=bar_index - 2, right=rightEdge, top=bearTop, bottom=bearBottom, xloc=xloc.bar_index, bgcolor=getBearBoxColour(bearStrength), border_color=bearBorderColour, text=txt, text_color=bearTextColour, text_size=fvgTextSize, text_halign=text.align_right, text_valign=text.align_center, force_overlay=true)

    array.push(fvgBoxes, b)
    array.push(fvgTops, bearTop)
    array.push(fvgBottoms, bearBottom)
    array.push(fvgIsBull, false)
    array.push(fvgActive, true)

//━━━━━━━━━━━━━━━━━━━
// MANAGE ZONES
//━━━━━━━━━━━━━━━━━━━
i = array.size(fvgBoxes) - 1

while i >= 0
    b = array.get(fvgBoxes, i)
    top = array.get(fvgTops, i)
    bottom = array.get(fvgBottoms, i)
    isBull = array.get(fvgIsBull, i)
    active = array.get(fvgActive, i)

    filled = isBull ? low <= bottom : high >= top

    if active
        box.set_right(b, bar_index + extendPastCurrentBar)

    if active and filled
        if deleteFilledGaps
            box.delete(b)
            array.remove(fvgBoxes, i)
            array.remove(fvgTops, i)
            array.remove(fvgBottoms, i)
            array.remove(fvgIsBull, i)
            array.remove(fvgActive, i)
        else
            array.set(fvgActive, i, false)
            box.set_bgcolor(b, mitigatedColour)
            box.set_border_color(b, color.gray)
            box.set_text(b, "Filled FVG")
            box.set_text_color(b, mitigatedTextColour)
            box.set_right(b, bar_index + extendPastCurrentBar)

    i -= 1

//━━━━━━━━━━━━━━━━━━━
// LIMIT ACTIVE ZONES
//━━━━━━━━━━━━━━━━━━━
while array.size(fvgBoxes) > maxActiveGaps
    oldBox = array.shift(fvgBoxes)
    box.delete(oldBox)

    array.shift(fvgTops)
    array.shift(fvgBottoms)
    array.shift(fvgIsBull)
    array.shift(fvgActive)

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(validBullFVG, "Bullish FVG", "Bullish graded FVG formed")
alertcondition(validBearFVG, "Bearish FVG", "Bearish graded FVG formed")
````
