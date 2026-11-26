# FVGs (with strebgth values)

- url: https://www.tradingview.com/script/Kdsqszwl-FVGs-with-strebgth-values/
- type: indicator
- pine_id: PUB;b07865ca73414bf99928c6f37e7835af
- version: 1.0

## Description

Graded FVGs – Percentage Strength

A smarter Fair Value Gap indicator designed to filter out weak, low-quality gaps and focus on the FVGs that actually matter.

Unlike standard FVG indicators that plot nearly every imbalance on the chart, this indicator uses a dynamic percentage-based strength system to rank each Fair Value Gap using displacement, gap size, trend direction, liquidity behaviour, structure, and optional volume confirmation.

The result is a much cleaner chart with far more relevant FVGs.

What Is a Fair Value Gap (FVG)?

A Fair Value Gap is an imbalance in price delivery created when price moves aggressively in one direction.

A bullish FVG forms when:

The current candle’s low is above the high from 2 candles earlier.

A bearish FVG forms when:

The current candle’s high is below the low from 2 candles earlier.

These gaps often act as:

Areas of institutional interest
Rebalancing zones
Continuation entries
Reversal zones
Liquidity attraction points

However, most FVG indicators plot every imbalance, including weak and meaningless gaps.

This indicator solves that problem.

How This Indicator Works

Instead of simply plotting every FVG, this indicator gives each FVG a percentage strength score.

The score is based on multiple conditions including:

Gap size relative to ATR
Displacement candle strength
EMA trend alignment
Liquidity sweep behaviour
Structure breaks
Volume confirmation (optional)

Each condition increases the overall FVG quality score.

The final result is displayed as:

Bull FVG 75%
Bear FVG 88%

inside the zone itself.

Strength Percentage Meaning
30–40%

Weak FVG

Usually smaller imbalances.
Can still work in trending conditions but less reliable.

Best used for:

Scalping
Aggressive entries
Lower timeframe continuation trades
50–70%

Strong FVG

The ideal balance between:

frequency
quality
readability

Usually formed with:

decent displacement
trend alignment
healthy imbalance size

Best used for:

Intraday trading
Gold scalping
Forex
Indices

This is the recommended range.

80–100%

Elite FVG

Very strong institutional-style imbalance.

Usually formed with:

powerful displacement
trend continuation
strong imbalance size
liquidity sweep or structure confirmation

These appear less often but are typically the highest quality zones.

Best used for:

swing trades
HTF entries
major continuation setups
confluence trading
Colour Grading

The indicator automatically grades the strength visually.

Standard Zones

Normal bullish or bearish imbalance zones.

Strong Zones

Brighter colours showing stronger imbalance conditions.

Elite Zones

Highest-quality zones with strongest confirmation.

This allows you to identify stronger opportunities instantly without reading every percentage value.

Best Ways To Use This Indicator
1. Trend Continuation Entries

One of the best uses.

Look for:

bullish FVGs above EMAs
bearish FVGs below EMAs

Wait for price to retrace into the FVG and react.

This often provides:

continuation entries
reduced drawdown entries
lower risk entries
2. Liquidity Sweep + FVG

Very powerful setup.

Example:

price sweeps a previous low
aggressive bullish candle forms
bullish FVG appears

This often signals:

liquidity grab
institutional reversal
market shift

Enable:

Use Liquidity Sweep In Strength

for this style.

3. BOS / CHoCH Confirmation

Strong FVGs after:

Break of Structure
Change of Character

are typically higher probability.

Recommended:

Use alongside market structure
Use with order blocks
Use with liquidity zones
4. Session Trading

FVGs work extremely well during:

London Open
New York Open
New York Killzone

Especially on:

XAUUSD
NASDAQ
US30
GBPJPY

Avoid weak overnight low-volume sessions.

Best Settings By Market
XAUUSD (Gold)
1 Minute Scalping

Recommended:

Minimum Strength %: 40
Use Trend Score: ON
Use Structure Score: OFF
Use Volume Score: OFF
Use Sweep Score: OFF

Why?
Gold produces huge amounts of imbalance.
Volume filters can become too restrictive.

5 Minute Gold

Recommended:

Minimum Strength %: 50
Use Trend Score: ON
Use Sweep Score: ON
Use Structure Score: OFF

This gives cleaner zones while still producing enough setups.

Forex Pairs

Best on:

GBPJPY
EURUSD
GBPUSD
AUDUSD

Recommended:

Minimum Strength %: 50–60
Use Trend Score: ON
Use Structure Score: ON

Forex tends to respect cleaner structure-based FVGs.

Indices (NAS100 / US30)

Recommended:

Minimum Strength %: 55–70
Use Trend Score: ON
Use Sweep Score: ON

Indices respond well to displacement and liquidity sweeps.

Higher Timeframes (1H / 4H / Daily)

Recommended:

Minimum Strength %: 70+
Use All Filters: ON

Higher timeframe FVGs are stronger and fewer are needed.

Understanding The Settings
Minimum FVG Strength %

Controls how selective the indicator becomes.

Lower values:

more FVGs
more aggressive
more clutter

Higher values:

cleaner chart
fewer signals
stronger quality

Recommended:

40–60%
Use EMA Trend In Strength

Adds strength when:

bullish FVGs are above EMAs
bearish FVGs are below EMAs

Highly recommended for trending markets.

Use Structure Break In Strength

Adds strength if price breaks recent highs/lows.

Useful for:

structure traders
BOS traders
smart money concepts

Can become restrictive on low timeframes.

Use Liquidity Sweep In Strength

Adds strength if the market sweeps liquidity before the FVG forms.

One of the most powerful confirmations.

Recommended for:

reversals
smart money concepts
gold scalping
Use Volume In Strength

Uses above-average volume to increase FVG quality.

Useful on:

indices
stocks
futures

Less useful on:

spot forex
some gold brokers
Extend Active Gaps

Keeps active FVGs extending into current price.

Recommended ON.

This helps track:

live mitigation
future reactions
unfilled imbalance
Delete Filled FVGs

Automatically removes fully mitigated zones.

Recommended ON for clean charts.

Turn OFF if you want to study historical reactions.

Trading Tips
Best Results Come From Confluence

Do not trade FVGs alone.

Combine with:

liquidity sweeps
BOS
CHoCH
order blocks
session highs/lows
HTF bias
Stronger Is Not Always Better

An 80% FVG is not automatically a winning trade.

Market context matters more than the score itself.

Lower Timeframes Need Looser Settings

1m and 5m charts require:

lower strength thresholds
fewer filters

otherwise the chart becomes too restrictive.

Recommended Beginner Setup

Perfect balance between:

clean charts
enough setups
strong quality
Minimum Strength %: 45
Trend Score: ON
Sweep Score: OFF
Structure Score: OFF
Volume Score: OFF

Works extremely well on:

Gold
NASDAQ
GBPJPY
EURUSD
Final Notes

This indicator is designed to help traders focus on:

higher quality imbalance zones
cleaner charts
institutional-style price delivery
smarter FVG filtering

It is not intended to predict the market alone.

The best results come when combining this tool with:

market structure
liquidity
trend
session timing
risk management

Used correctly, this indicator can dramatically reduce chart clutter while improving the quality of the FVGs you trade.

## Source Code

````pine
//@version=5
indicator("Graded FVGs - Percentage Strength", overlay=true, max_boxes_count=500)

// Inputs
showBullish = input.bool(true, "Show Bullish FVGs")
showBearish = input.bool(true, "Show Bearish FVGs")

minStrengthPercent = input.int(40, "Minimum FVG Strength %", minval=10, maxval=100)

atrLength = input.int(14, "ATR Length")
smallGapAtr = input.float(0.05, "Minimum Gap ATR", step=0.01)
largeGapAtr = input.float(0.20, "Large Gap ATR", step=0.01)
displacementAtr = input.float(0.70, "Displacement ATR", step=0.05)

useVolumeScore = input.bool(false, "Use Volume In Strength")
volumeLength = input.int(20, "Volume MA Length")
volumeMultiplier = input.float(1.20, "Volume Multiplier", step=0.05)

useTrendScore = input.bool(true, "Use EMA Trend In Strength")
fastEmaLength = input.int(20, "Fast EMA")
slowEmaLength = input.int(50, "Slow EMA")

useStructureScore = input.bool(false, "Use Structure Break In Strength")
structureLookback = input.int(10, "Structure Lookback")

useSweepScore = input.bool(false, "Use Liquidity Sweep In Strength")
sweepLookback = input.int(8, "Sweep Lookback")

deleteFilledGaps = input.bool(true, "Delete Filled FVGs")
extendActiveGaps = input.bool(true, "Extend Active Gaps")
maxActiveGaps = input.int(40, "Maximum Active FVGs", minval=1, maxval=100)

showEMAs = input.bool(true, "Show EMAs")

bullColour = input.color(color.new(color.green, 82), "Bullish FVG Colour")
bearColour = input.color(color.new(color.red, 82), "Bearish FVG Colour")
strongBullColour = input.color(color.new(color.lime, 72), "Strong Bullish FVG Colour")
strongBearColour = input.color(color.new(color.orange, 72), "Strong Bearish FVG Colour")
eliteBullColour = input.color(color.new(color.aqua, 68), "Elite Bullish FVG Colour")
eliteBearColour = input.color(color.new(color.fuchsia, 68), "Elite Bearish FVG Colour")

textColour = input.color(color.white, "Zone Text Colour")
mitigatedColour = input.color(color.new(color.gray, 90), "Mitigated Colour")

// Calculations
atr = ta.atr(atrLength)
volMA = ta.sma(volume, volumeLength)

fastEMA = ta.ema(close, fastEmaLength)
slowEMA = ta.ema(close, slowEmaLength)

plot(showEMAs ? fastEMA : na, "Fast EMA", color=color.new(color.blue, 0))
plot(showEMAs ? slowEMA : na, "Slow EMA", color=color.new(color.orange, 0))

// FVG logic
bullishFVG = low > high[2]
bearishFVG = high < low[2]

bullTop = low
bullBottom = high[2]

bearTop = low[2]
bearBottom = high

bullGapSize = bullishFVG ? bullTop - bullBottom : 0.0
bearGapSize = bearishFVG ? bearTop - bearBottom : 0.0

middleCandleRange = high[1] - low[1]

// Strength conditions
bullTrend = close > fastEMA and fastEMA > slowEMA
bearTrend = close < fastEMA and fastEMA < slowEMA

bullStructure = close > ta.highest(high, structureLookback)[1]
bearStructure = close < ta.lowest(low, structureLookback)[1]

bullSweep = low[1] < ta.lowest(low, sweepLookback)[2] and close[1] > open[1]
bearSweep = high[1] > ta.highest(high, sweepLookback)[2] and close[1] < open[1]

volumeStrong = volume[1] > volMA[1] * volumeMultiplier

// Percentage strength function
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
        score += _isBull ? bullTrend ? 1 : 0 : bearTrend ? 1 : 0

    if useStructureScore
        maxScore += 1
        score += _isBull ? bullStructure ? 1 : 0 : bearStructure ? 1 : 0

    if useSweepScore
        maxScore += 1
        score += _isBull ? bullSweep ? 1 : 0 : bearSweep ? 1 : 0

    math.round((score / maxScore) * 100)

bullStrength = bullishFVG ? getStrengthPercent(bullGapSize, true) : 0
bearStrength = bearishFVG ? getStrengthPercent(bearGapSize, false) : 0

validBullFVG = showBullish and bullishFVG and bullStrength >= minStrengthPercent
validBearFVG = showBearish and bearishFVG and bearStrength >= minStrengthPercent

getBullBoxColour(_strength) =>
    _strength >= 85 ? eliteBullColour : _strength >= 65 ? strongBullColour : bullColour

getBearBoxColour(_strength) =>
    _strength >= 85 ? eliteBearColour : _strength >= 65 ? strongBearColour : bearColour

// Arrays
var box[] fvgBoxes = array.new_box()
var float[] fvgTops = array.new_float()
var float[] fvgBottoms = array.new_float()
var bool[] fvgIsBull = array.new_bool()
var bool[] fvgActive = array.new_bool()

// Create bullish FVG
if validBullFVG
    txt = "Bull FVG " + str.tostring(bullStrength) + "%"
    b = box.new(left=bar_index - 2, right=bar_index, top=bullTop, bottom=bullBottom, bgcolor=getBullBoxColour(bullStrength), border_color=color.new(color.green, 0), text=txt, text_color=textColour, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_center)

    array.push(fvgBoxes, b)
    array.push(fvgTops, bullTop)
    array.push(fvgBottoms, bullBottom)
    array.push(fvgIsBull, true)
    array.push(fvgActive, true)

// Create bearish FVG
if validBearFVG
    txt = "Bear FVG " + str.tostring(bearStrength) + "%"
    b = box.new(left=bar_index - 2, right=bar_index, top=bearTop, bottom=bearBottom, bgcolor=getBearBoxColour(bearStrength), border_color=color.new(color.red, 0), text=txt, text_color=textColour, text_size=size.tiny, text_halign=text.align_right, text_valign=text.align_center)

    array.push(fvgBoxes, b)
    array.push(fvgTops, bearTop)
    array.push(fvgBottoms, bearBottom)
    array.push(fvgIsBull, false)
    array.push(fvgActive, true)

// Manage FVGs
i = array.size(fvgBoxes) - 1

while i >= 0
    b = array.get(fvgBoxes, i)
    top = array.get(fvgTops, i)
    bottom = array.get(fvgBottoms, i)
    isBull = array.get(fvgIsBull, i)
    active = array.get(fvgActive, i)

    filled = isBull ? low <= bottom : high >= top

    if active and extendActiveGaps
        box.set_right(b, bar_index)

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
            box.set_right(b, bar_index)

    i -= 1

// Limit active zones
while array.size(fvgBoxes) > maxActiveGaps
    oldBox = array.shift(fvgBoxes)
    box.delete(oldBox)

    array.shift(fvgTops)
    array.shift(fvgBottoms)
    array.shift(fvgIsBull)
    array.shift(fvgActive)

// Alerts
alertcondition(validBullFVG, "Bullish FVG", "Bullish percentage strength FVG formed")
alertcondition(validBearFVG, "Bearish FVG", "Bearish percentage strength FVG formed")
````
