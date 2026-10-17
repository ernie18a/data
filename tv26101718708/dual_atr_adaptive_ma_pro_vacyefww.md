# Dual ATR Adaptive MA Pro

- url: https://www.tradingview.com/script/VAcyEFWW/
- type: indicator
- pine_id: PUB;695dc9162da443b6811d039c0d6a62b3
- version: 1.0

## Description

# Dual ATR AMA Pro

**Dual ATR AMA Pro** is a volatility-adaptive trend and risk-orientation indicator based on ATR behavior. The indicator is designed to help traders read market direction, volatility conditions, pullback structure, and possible risk distances directly on the chart.

The main purpose of this tool is not to predict tops or bottoms. Instead, it is designed to help traders wait for confirmation after consolidation phases and trade in the direction of the confirmed market flow.

The indicator combines two ATR-adaptive moving averages, an optional trend regime heatmap, ATR-based bands, and a volatility label that displays current ATR, average ATR, calculated stop size, and a 1:2 take-profit reference.

---

## Core idea

Many moving averages use a fixed length. For example, an EMA 50 always reacts with the same smoothing speed, regardless of whether the market is calm or highly volatile.

Dual ATR AMA Pro uses ATR behavior to adapt the moving average dynamically. When volatility changes, the adaptive average changes its reaction speed.

The idea behind this is simple:

* In stronger movement phases, the adaptive line can react faster.
* In slower or unclear phases, the adaptive line can become smoother.
* The slower adaptive line can be used as a broader trend filter.
* The faster adaptive line can be used as a timing and pullback reference.

This makes the tool useful for traders who do not want to enter during the first impulse of a move, but prefer to wait until the market has confirmed direction after a consolidation.

---

## Main components

The indicator consists of four main parts:

1. **ATR Adaptive MA 1**
2. **ATR Adaptive MA 2**
3. **Trend regime heatmap**
4. **ATR risk label**

---

## ATR Adaptive MA 1

ATR Adaptive MA 1 is the faster line.

It is intended as a short-term timing line. It can help identify pullbacks, reaction points, and short-term changes in flow.

Typical use cases:

* Entry timing after pullbacks
* Visual short-term trend direction
* Dynamic support/resistance in trending phases
* Faster reaction after a new impulse

In a bullish environment, traders may watch whether price pulls back toward ATR MA 1 and then continues upward.

In a bearish environment, traders may watch whether price pulls back toward ATR MA 1 and then continues downward.

ATR MA 1 is usually more reactive and therefore more sensitive to short-term market noise.

---

## ATR Adaptive MA 2

ATR Adaptive MA 2 is the slower line.

It is intended as the broader directional filter. It reacts more slowly and is designed to provide a calmer view of the current market regime.

Typical use cases:

* Main trend direction
* Trade direction filter
* Heatmap basis
* Avoiding early entries during consolidation
* Confirming whether the market has shifted from bullish to bearish, or bearish to bullish

The slow ATR line is especially useful when the trader wants to avoid the first part of a move and only participate after the market has shown a clearer directional flow.

---

## Heatmap logic

The heatmap is used to visualize the current market regime.

The heatmap can be based on:

* ATR MA 1
* ATR MA 2
* Both lines together

The default idea is to use **ATR MA 2** as the heatmap basis because it is calmer and filters out many smaller fluctuations.

A bullish heatmap appears when the selected logic confirms bullish conditions.

A bearish heatmap appears when the selected logic confirms bearish conditions.

There is no neutral background color, so the chart does not get visually interrupted by a gray regime. If the condition is not clearly bullish or bearish, no background color is displayed.

This makes the heatmap useful as a directional filter rather than a direct entry signal.

---

## Suggested interpretation of the heatmap

A green heatmap does not automatically mean “buy now.”

A red heatmap does not automatically mean “sell now.”

Instead, the heatmap should be read as a market condition filter.

Example:

* Green heatmap = long setups may be preferred
* Red heatmap = short setups may be preferred
* No clear heatmap = avoid forcing trades

The indicator is designed to support a more defensive trading style. It helps the trader avoid trading directly inside uncertain transition zones.

---

## Trend protection

Each ATR adaptive line has its own optional trend protection setting.

Trend protection attempts to reduce unnecessary movement in unclear sideways phases and allows the line to react better when the market is actually moving with directional strength.

The practical idea:

* If the market is just moving sideways, the line becomes calmer.
* If the market starts moving with real directional flow, the line can respond more effectively.

This is useful for traders who want to wait for a confirmed movement instead of reacting to every small candle fluctuation.

In the default concept:

* ATR MA 1 can remain more reactive as a timing line.
* ATR MA 2 can use trend protection as a calmer directional filter.

---

## Normal ATR logic vs inverted ATR logic

The indicator includes an optional logic inversion.

In normal mode:

* Higher ATR can make the line react faster.
* Lower ATR can make the line smoother.

In inverted mode:

* Higher ATR can make the line slower.
* Lower ATR can make the line faster.

Normal logic is usually better for following active market movement.

Inverted logic can be useful if the trader wants more stability during volatile phases and does not want the line to react too aggressively.

The default approach is usually to keep inverted logic disabled unless a specific market or strategy requires it.

---

## ATR bands

The indicator can display an ATR band around ATR MA 1.

The band is calculated from ATR and a configurable multiplier.

The band can be used to understand whether price is still moving within a normal volatility area around the fast adaptive line or whether price is stretched away from it.

Possible uses:

* Visual volatility zone
* Pullback area
* Dynamic reaction area
* Context for overextension

The band should not be interpreted as a guaranteed reversal zone. It is a volatility reference.

---

## ATR risk label

The indicator includes an ATR label near the current price.

The label can show:

* Current ATR
* Average ATR over the last selected number of candles
* Stop size based on average ATR
* 1:2 take-profit reference based on the stop size

Example:

ATR 14: 3.880
ATR Ø 50: 4.221
Stop 2x ATR Ø: 8.442
TP 1:2: 16.884

This helps the trader estimate whether the current market volatility fits the planned trade.

For example, if the average ATR over 50 candles is 4.221 points and the stop multiplier is 2.0, the calculated stop reference is approximately 8.442 points.

The 1:2 take-profit reference is then twice the stop size.

This does not mean that the stop or take-profit should be used blindly. The values are intended as volatility-based references and should be combined with market structure, support/resistance, previous highs/lows, session levels, or other trading context.

---

## Example use case: trend continuation after consolidation

A trader may use the indicator in the following way:

1. The market reaches an important level, such as a previous daily high or daily low.
2. Price starts to consolidate.
3. The trader avoids entering during the unclear consolidation phase.
4. ATR MA 2 and the heatmap eventually confirm direction.
5. ATR MA 1 changes in the same direction.
6. A candle closes in the direction of the confirmed flow.
7. The trader looks for a possible setup in the direction of the trend.

This approach is designed for traders who prefer confirmation over early entries.

The goal is not to catch the exact top or bottom, but to avoid unnecessary risk during market transition phases.

---

## Example bullish condition

A possible bullish interpretation could be:

* Price is above ATR MA 2
* ATR MA 2 is rising
* Heatmap is bullish
* ATR MA 1 is rising
* Price pulls back and then continues upward
* Candle confirmation supports the direction

This may suggest that long setups are favored.

---

## Example bearish condition

A possible bearish interpretation could be:

* Price is below ATR MA 2
* ATR MA 2 is falling
* Heatmap is bearish
* ATR MA 1 is falling
* Price pulls back and then continues downward
* Candle confirmation supports the direction

This may suggest that short setups are favored.

---

## Defensive trading concept

The indicator is especially designed for traders who want to protect capital by avoiding unclear early movement.

Instead of trying to enter at the first impulse, the trader can wait for:

* Market structure confirmation
* Heatmap confirmation
* ATR MA 2 direction
* ATR MA 1 timing
* Candle confirmation
* Volatility-based risk reference

This can help reduce emotional entries in consolidation zones.

---

## Why two ATR adaptive averages?

Using only one adaptive average can be too noisy or too slow.

The two-line approach separates the job of each line:

**ATR MA 1:**
Short-term timing and pullback reference.

**ATR MA 2:**
Market regime and directional filter.

This separation makes the tool easier to use because the trader does not need one line to do everything.

---

## What this indicator is not

This indicator is not a guaranteed trading system.

It does not predict future price movement.

It does not provide financial advice.

It should not be used as a standalone buy or sell signal.

It is a visual decision-support tool that helps traders understand trend direction, volatility, possible risk distance, and market regime.

---

## Recommended use

The indicator works best when combined with:

* Market structure
* Previous highs and lows
* Daily highs and daily lows
* Support and resistance
* Supply and demand zones
* Session levels
* Candle confirmation
* Risk management rules

The strongest use case is not entering immediately when the heatmap changes, but waiting for a confirmed pullback or continuation setup in the direction of the selected regime.

---

## Practical trading concept

A possible workflow:

1. Identify the higher-timeframe or session context.
2. Mark important daily highs/lows or consolidation zones.
3. Wait until price leaves the consolidation area.
4. Use ATR MA 2 and heatmap as the directional filter.
5. Use ATR MA 1 for timing.
6. Use ATR average and stop calculation as risk reference.
7. Only take trades where the risk-to-reward structure makes sense.

---

## Risk label explanation

The ATR risk label is included to make volatility more practical.

Instead of guessing stop size, the trader can use the average ATR as a reference.

Example:

If ATR Ø 50 is 4.0 and the stop multiplier is 2.0, then the stop reference is 8.0 points.

If the trader wants a 1:2 setup, the take-profit reference is 16.0 points.

This helps answer an important question before taking a trade:

“Is the current market movement large enough to justify my stop and target?”

---

## Final note

Dual ATR AMA Pro is built for traders who prefer confirmation, structure, and volatility-adjusted risk planning.

The indicator is especially useful for avoiding trades inside uncertain consolidation phases and for waiting until the market shows a cleaner directional flow.

It is best used as a trend, volatility, and risk-orientation tool, not as an automatic signal generator.

## Source Code

````pine
//@version=6
indicator('Dual ATR Adaptive MA Pro', shorttitle = 'Dual ATR AMA Pro', overlay = true, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNKTION: ATR ADAPTIVE MA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrAdaptiveMa(float source, int baseLength, int minLength, int maxLength, int atrLength, int atrSmoothLength, float atrSensitivity, bool invertLogic, bool useTrendProtection, int slopeLength) =>

    atrRaw = ta.atr(atrLength)
    atrBase = ta.ema(atrRaw, atrSmoothLength)

    atrRatioRaw = atrBase != 0.0 ? atrRaw / atrBase : 1.0
    atrRatio = math.max(0.25, math.min(4.0, atrRatioRaw))

    dynamicLengthRaw = invertLogic ? baseLength * atrRatio * atrSensitivity : baseLength / (atrRatio * atrSensitivity)
    dynamicLength = math.max(minLength, math.min(maxLength, dynamicLengthRaw))

    alphaRaw = 2.0 / (dynamicLength + 1.0)

    slope = math.abs(source - source[slopeLength])
    slopeBase = ta.ema(math.abs(source - source[1]), atrSmoothLength)
    trendFactor = slopeBase != 0.0 ? slope / slopeBase : 1.0
    trendFactorClamped = math.max(0.5, math.min(1.5, trendFactor))

    alpha = useTrendProtection ? alphaRaw * trendFactorClamped : alphaRaw

    var float ama = na
    ama := na(ama[1]) ? source : ama[1] + alpha * (source - ama[1])

    [ama, dynamicLength, atrRatio, alpha]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALLGEMEINE INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

generalGroup = 'Allgemein'

showBackgroundMode = input.bool(true, 'Marktmodus als Hintergrund anzeigen', group = generalGroup)

heatmapSource = input.string('ATR MA 2', 'Heatmap Basis', options = ['ATR MA 1', 'ATR MA 2', 'Beide'], group = generalGroup)

bullHeatmapColor = input.color(color.new(color.green, 90), 'Heatmap bullisch', group = generalGroup)
bearHeatmapColor = input.color(color.new(color.red, 90), 'Heatmap bearisch', group = generalGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR LABEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrLabelGroup = 'ATR Label'

showCurrentAtrLabel = input.bool(true, 'ATR Label anzeigen', group = atrLabelGroup)

showSingleCandleAtr = input.bool(true, 'ATR Einzelkerze anzeigen', group = atrLabelGroup)
showAverageAtr = input.bool(true, 'ATR Durchschnitt anzeigen', group = atrLabelGroup)
showStopAtr = input.bool(true, 'Stopgroesse anzeigen', group = atrLabelGroup)

currentAtrLabelLength = input.int(14, 'ATR Laenge', minval = 1, maxval = 200, group = atrLabelGroup)
averageAtrLength = input.int(50, 'ATR Durchschnitt letzte X Kerzen', minval = 1, maxval = 500, group = atrLabelGroup)
stopAtrMultiplier = input.float(2.0, 'Stop Multiplikator ATR Durchschnitt', minval = 0.1, maxval = 10.0, step = 0.1, group = atrLabelGroup)

currentAtrLabelOffset = input.int(10, 'ATR Label Abstand nach rechts', minval = 0, maxval = 100, group = atrLabelGroup)

currentAtrLabelTextColor = input.color(color.white, 'ATR Label Textfarbe', group = atrLabelGroup)
currentAtrLabelBgColor = input.color(color.new(color.black, 20), 'ATR Label Hintergrund', group = atrLabelGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS LINIE 1
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupAtrMa1 = 'ATR Adaptive MA 1 - Schnell'

showAtrMa1 = input.bool(true, 'ATR MA 1 anzeigen', group = groupAtrMa1)
src1 = input.source(close, 'Quelle', group = groupAtrMa1)

baseLength1 = input.int(50, 'Basis Laenge', minval = 1, maxval = 500, group = groupAtrMa1)
minLength1 = input.int(10, 'Minimale Laenge', minval = 1, maxval = 500, group = groupAtrMa1)
maxLength1 = input.int(100, 'Maximale Laenge', minval = 1, maxval = 500, group = groupAtrMa1)

atrLength1 = input.int(14, 'ATR Laenge', minval = 1, maxval = 200, group = groupAtrMa1)
atrSmoothLength1 = input.int(50, 'ATR Vergleichs-Laenge', minval = 1, maxval = 500, group = groupAtrMa1)
atrSensitivity1 = input.float(1.0, 'ATR Sensitivitaet', minval = 0.1, maxval = 5.0, step = 0.1, group = groupAtrMa1)

invertLogic1 = input.bool(false, 'Logik umkehren', group = groupAtrMa1)

useTrendProtection1 = input.bool(false, 'Trendschutz ATA 1 aktivieren', group = groupAtrMa1)
slopeLength1 = input.int(5, 'Steigungslaenge Trendschutz', minval = 1, maxval = 300, group = groupAtrMa1)

ma1ColorUp = input.color(color.lime, 'Farbe steigend', group = groupAtrMa1)
ma1ColorDown = input.color(color.red, 'Farbe fallend', group = groupAtrMa1)
ma1Width = input.int(2, 'Linienstaerke', minval = 1, maxval = 5, group = groupAtrMa1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS LINIE 2
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupAtrMa2 = 'ATR Adaptive MA 2 - Langsam'

showAtrMa2 = input.bool(true, 'ATR MA 2 anzeigen', group = groupAtrMa2)
src2 = input.source(close, 'Quelle', group = groupAtrMa2)

baseLength2 = input.int(100, 'Basis Laenge', minval = 1, maxval = 500, group = groupAtrMa2)
minLength2 = input.int(30, 'Minimale Laenge', minval = 1, maxval = 500, group = groupAtrMa2)
maxLength2 = input.int(200, 'Maximale Laenge', minval = 1, maxval = 500, group = groupAtrMa2)

atrLength2 = input.int(14, 'ATR Laenge', minval = 1, maxval = 200, group = groupAtrMa2)
atrSmoothLength2 = input.int(50, 'ATR Vergleichs-Laenge', minval = 1, maxval = 500, group = groupAtrMa2)
atrSensitivity2 = input.float(1.0, 'ATR Sensitivitaet', minval = 0.1, maxval = 5.0, step = 0.1, group = groupAtrMa2)

invertLogic2 = input.bool(false, 'Logik umkehren', group = groupAtrMa2)

useTrendProtection2 = input.bool(true, 'Trendschutz ATA 2 aktivieren', group = groupAtrMa2)
slopeLength2 = input.int(5, 'Steigungslaenge Trendschutz', minval = 1, maxval = 300, group = groupAtrMa2)

ma2ColorUp = input.color(color.aqua, 'Farbe steigend', group = groupAtrMa2)
ma2ColorDown = input.color(color.orange, 'Farbe fallend', group = groupAtrMa2)
ma2Width = input.int(2, 'Linienstaerke', minval = 1, maxval = 5, group = groupAtrMa2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR BAND UM LINIE 1
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bandGroup = 'ATR Band um MA 1'

showAtrBand = input.bool(true, 'ATR Band anzeigen', group = bandGroup)
bandAtrLength = input.int(14, 'Band ATR Laenge', minval = 1, maxval = 200, group = bandGroup)
bandAtrSmooth = input.int(10, 'Band ATR Glaettung', minval = 1, maxval = 200, group = bandGroup)
bandMultiplier = input.float(1.0, 'ATR Multiplikator', minval = 0.1, maxval = 10.0, step = 0.1, group = bandGroup)

bandColor = input.color(color.new(color.white, 85), 'Band Farbe', group = bandGroup)
upperBandColor = input.color(color.new(color.white, 40), 'Oberes Band', group = bandGroup)
lowerBandColor = input.color(color.new(color.white, 40), 'Unteres Band', group = bandGroup)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BERECHNUNG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[atrMa1, dynLength1, atrRatio1, alpha1] = atrAdaptiveMa(src1, baseLength1, minLength1, maxLength1, atrLength1, atrSmoothLength1, atrSensitivity1, invertLogic1, useTrendProtection1, slopeLength1)

[atrMa2, dynLength2, atrRatio2, alpha2] = atrAdaptiveMa(src2, baseLength2, minLength2, maxLength2, atrLength2, atrSmoothLength2, atrSensitivity2, invertLogic2, useTrendProtection2, slopeLength2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND-/MARKTMODUS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ma1Up = atrMa1 > atrMa1[1]
ma1Down = atrMa1 < atrMa1[1]

ma2Up = atrMa2 > atrMa2[1]
ma2Down = atrMa2 < atrMa2[1]

bullMode = heatmapSource == 'ATR MA 1' ? close > atrMa1 and ma1Up : heatmapSource == 'ATR MA 2' ? close > atrMa2 and ma2Up : close > atrMa1 and close > atrMa2 and atrMa1 > atrMa2 and ma1Up and ma2Up

bearMode = heatmapSource == 'ATR MA 1' ? close < atrMa1 and ma1Down : heatmapSource == 'ATR MA 2' ? close < atrMa2 and ma2Down : close < atrMa1 and close < atrMa2 and atrMa1 < atrMa2 and ma1Down and ma2Down

atrMa1Color = ma1Up ? ma1ColorUp : ma1ColorDown
atrMa2Color = ma2Up ? ma2ColorUp : ma2ColorDown

bgcolor(showBackgroundMode ? bullMode ? bullHeatmapColor : bearMode ? bearHeatmapColor : na : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR BAND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bandAtrRaw = ta.atr(bandAtrLength)
bandAtr = ta.ema(bandAtrRaw, bandAtrSmooth)

upperBand = atrMa1 + bandAtr * bandMultiplier
lowerBand = atrMa1 - bandAtr * bandMultiplier

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotUpperBand = plot(showAtrBand ? upperBand : na, title = 'ATR MA 1 Oberes Band', color = upperBandColor, linewidth = 1)
plotLowerBand = plot(showAtrBand ? lowerBand : na, title = 'ATR MA 1 Unteres Band', color = lowerBandColor, linewidth = 1)

fill(plotUpperBand, plotLowerBand, color = showAtrBand ? bandColor : na, title = 'ATR Band Fill')

plot(showAtrMa1 ? atrMa1 : na, title = 'ATR Adaptive MA 1', color = atrMa1Color, linewidth = math.max(1, ma1Width))
plot(showAtrMa2 ? atrMa2 : na, title = 'ATR Adaptive MA 2', color = atrMa2Color, linewidth = math.max(1, ma2Width))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR LABEL AM AKTUELLEN KURS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

currentAtrValue = ta.atr(currentAtrLabelLength)
averageAtrValue = ta.sma(currentAtrValue, averageAtrLength)
stopAtrValue = averageAtrValue * stopAtrMultiplier
tpAtrValue = stopAtrValue * 2.0

atrLabelText = ''

if showSingleCandleAtr
    atrLabelText := atrLabelText + 'ATR ' + str.tostring(currentAtrLabelLength) + ': ' + str.tostring(currentAtrValue, '#.###')
    atrLabelText

if showAverageAtr
    atrLabelText := atrLabelText + (str.length(atrLabelText) > 0 ? '\n' : '') + 'ATR Ø ' + str.tostring(averageAtrLength) + ': ' + str.tostring(averageAtrValue, '#.###')
    atrLabelText

if showStopAtr
    atrLabelText := atrLabelText + (str.length(atrLabelText) > 0 ? '\n' : '') + 'Stop ' + str.tostring(stopAtrMultiplier, '#.#') + 'x ATR Ø: ' + str.tostring(stopAtrValue, '#.###')
    atrLabelText := atrLabelText + '\nTP 1:2: ' + str.tostring(tpAtrValue, '#.###')
    atrLabelText

var label currentAtrLabel = na

if showCurrentAtrLabel and barstate.islast and str.length(atrLabelText) > 0
    if not na(currentAtrLabel)
        label.delete(currentAtrLabel)

    currentAtrLabel := label.new(x = bar_index + currentAtrLabelOffset, y = close, text = atrLabelText, xloc = xloc.bar_index, yloc = yloc.price, color = currentAtrLabelBgColor, textcolor = currentAtrLabelTextColor, style = label.style_label_left, size = size.small)
    currentAtrLabel

if not showCurrentAtrLabel or str.length(atrLabelText) == 0
    if not na(currentAtrLabel)
        label.delete(currentAtrLabel)
        currentAtrLabel := na
        currentAtrLabel
````
