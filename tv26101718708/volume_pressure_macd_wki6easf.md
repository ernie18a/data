# Volume Pressure MACD

- url: https://www.tradingview.com/script/WKi6easF/
- type: indicator
- pine_id: PUB;6f4a010b62e549089c744a1f7812fda5
- version: 2.0

## Description

Volume Pressure MACD is a momentum indicator built on the MACD framework, 
extended with three independent volume analysis layers that work together 
to weight each signal by the quality and direction of volume participation — 
not just its size.

The core idea: a price move backed by high volume is more meaningful than 
the same move on thin volume. But volume size alone is incomplete — 
a large-volume candle where price closes near the low tells a very different 
story than one where price closes near the high. This indicator attempts to 
capture both dimensions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BACKGROUND — WHY THREE VOLUME LAYERS?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Standard MACD is calculated purely from price EMAs and ignores volume entirely. 
Most volume-weighted MACD variants address this by multiplying the MACD value 
by a simple volume ratio — more volume means a stronger signal. That approach 
has a limitation: it treats all high-volume candles equally, whether the close 
was bullish or bearish within the candle.

Volume Pressure MACD uses three separate volume inputs, each measuring a 
different aspect of market participation:

LAYER 1 — VOLUME FACTOR
Measures how current volume compares to its recent average using a power 
function (math.pow). The Volume Effect input controls the exponent, which 
determines how aggressively above-average volume amplifies the MACD and how 
much below-average volume dampens it. At 0.1 the effect is subtle and smooth; 
higher values make the indicator more reactive to volume spikes. This layer 
answers the question: how much volume is there?

LAYER 2 — VOLUME PRESSURE SCORE
This is the differentiating layer. For each bar, it calculates how much of 
the total volume was spent by buyers versus sellers, based on where the 
closing price lands relative to the bar's high-low range:

  Buy Pressure  = Volume × (Close - Low)  / (High - Low)
  Sell Pressure = Volume × (High - Close) / (High - Low)
  Net Pressure  = Buy Pressure - Sell Pressure

A candle that closes at its high assigns nearly all volume to buyers. 
A candle that closes at its low assigns nearly all volume to sellers. 
A doji near the midpoint splits volume roughly equally and contributes 
minimal pressure in either direction.

The net pressure is normalized against its recent average and then applied 
as a secondary weight on the MACD — clamped to a ±30% influence so it 
modulates rather than dominates the output. This layer answers the question: 
in which direction was volume being used?

LAYER 3 — VOLUME MOMENTUM
Compares a 5-bar volume average against a 20-bar volume average to determine 
whether market participation is currently expanding or contracting. This does 
not affect the MACD calculation itself — instead it drives the 4-tone histogram 
coloring, giving a visual indication of whether the current MACD move is 
occurring on growing or fading volume. This layer answers the question: 
is volume increasing or decreasing?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DYNAMIC ZONE SYSTEM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
One of the practical problems with MACD-based indicators is that fixed 
overbought/oversold lines are meaningless across different assets and 
timeframes. MACD values on a 5-minute chart of a low-priced asset can be 
a fraction of a unit, while the same indicator on a weekly chart of a 
high-priced asset can reach thousands. Static horizontal lines cannot 
account for this.

The zone system in this indicator is fully dynamic:

- The upper boundary (Strong Bull) is set to the highest MACD value 
  over the Zone Lookback period, floored at zero
- The lower boundary (Strong Bear) is set to the lowest MACD value 
  over the Zone Lookback period, capped at zero
- The Weak/Strong boundary is calculated as a percentage of those 
  extremes, controlled by the Weak/Strong Split input
- All four zone boundaries automatically adjust as new bars print 
  and as you switch between timeframes or assets

Zone definitions:
  Strong Bull — MACD is in the upper portion of its recent historical 
                range; momentum is extended to the upside
  Weak Bull   — MACD is positive but has not yet reached historically 
                elevated levels; upward momentum is present but moderate
  Weak Bear   — MACD is negative but within the lower portion of its 
                recent range; downward momentum is present but moderate  
  Strong Bear — MACD is deep in its recent historical range; momentum 
                is extended to the downside

The zones are color-filled between their boundaries and labeled at the 
right edge of the chart for easy reading. Bull zones are drawn in green 
tones and are mathematically prevented from crossing below zero. Bear zones 
are drawn in red tones and are mathematically prevented from crossing above 
zero, so the zone layout always remains logically consistent regardless of 
MACD behavior.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HISTOGRAM COLORING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
The histogram uses four distinct colors based on the combination of MACD 
direction and volume momentum, allowing you to read both momentum and 
participation at a glance:

  Dark green  — histogram above zero + volume momentum expanding
                (positive momentum with growing participation)
  Light green — histogram above zero + volume momentum contracting
                (positive momentum but participation fading)
  Dark red    — histogram below zero + volume momentum expanding
                (negative momentum with growing participation)
  Light red   — histogram below zero + volume momentum contracting
                (negative momentum but participation fading)

The transition from dark to light (or vice versa) within the same direction 
can be an early indication of momentum exhaustion or resumption.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SIGNAL TYPES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▲ BUY triangle (green, bottom) 
  MACD crosses above Signal line AND volume exceeds the average 
  by the Strong Volume Multiplier threshold. Both conditions must 
  be true simultaneously.

▼ SELL triangle (red, top)
  MACD crosses below Signal line AND volume exceeds the average 
  by the Strong Volume Multiplier threshold. Both conditions must 
  be true simultaneously.

+ Cross marker on MACD line
  All MACD/Signal crossovers, regardless of volume. Plotted directly 
  at the crossover price level on the indicator, not at the top or 
  bottom of the pane.

M↑ circle (teal) — Bullish divergence on the MACD line
  Price makes a lower low while MACD makes a higher low, 
  detected using asymmetric pivot logic.

M↓ circle (fuchsia) — Bearish divergence on the MACD line
  Price makes a higher high while MACD makes a lower high.

H↑ diamond (yellow) — Bullish divergence on the Histogram
  Price makes a lower low while the histogram makes a higher low.

H↓ diamond (orange) — Bearish divergence on the Histogram
  Price makes a higher high while the histogram makes a lower high.

Note: MACD line divergence and histogram divergence are calculated 
independently. When both trigger together it may indicate a stronger 
divergence condition. When only one triggers it can reflect early or 
partial divergence development.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INFO TABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A live data table in the top-right corner displays four values 
for the most recent closed bar:

Diff         — the current distance between the MACD and Signal lines, 
               with a directional arrow showing which is above the other
Vol Factor   — the current volume multiplier relative to the average. 
               Values above 1.0 indicate above-average volume (green); 
               values below 1.0 indicate below-average volume (red)
Vol Momentum — whether the 5-bar volume average is above or below 
               the 20-bar average (Rising / Falling)
Vol Pressure — the net directional pressure score for the current bar 
               (Buy / Sell / Neutral), based on the pressure calculation 
               described above

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INPUT REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fast EMA                 — fast EMA length for classic MACD (default 12)
Slow EMA                 — slow EMA length for classic MACD (default 26)
Signal EMA               — signal line EMA length (default 9)
MACD Smooth              — additional EMA smoothing applied to the 
                           volume-weighted MACD line (default 3)
Volume SMA Length        — lookback for calculating average volume, 
                           used in both Volume Factor and Pressure Score
Volume Effect            — exponent controlling how strongly volume 
                           scales the MACD; lower = smoother (default 0.1)
Strong Volume Multiplier — volume must exceed average × this value 
                           for BUY/SELL triangles to appear (default 1.5)
Divergence Lookback      — pivot bar count for divergence detection; 
                           higher values find fewer but more significant 
                           divergences (default 5)
Zone Lookback Bars       — how many bars are used to define the dynamic 
                           zone boundaries (default 100)
Weak/Strong Split        — the percentage point within the zone range 
                           where weak ends and strong begins (default 0.35)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPATIBILITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Works on all asset classes including equities, cryptocurrency, forex, 
commodities, and indices. Compatible with all timeframes. The dynamic 
zone system and volume pressure calculation are designed to produce 
meaningful output regardless of the absolute price or volume scale 
of the instrument.

Pine Script v5.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano


//@version=6
indicator('Volume Pressure MACD', shorttitle = 'VW-MACD', overlay = false)

//══════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════
fastLen = input.int(12, 'Fast EMA', minval = 1)
slowLen = input.int(26, 'Slow EMA', minval = 1)
signalLen = input.int(9, 'Signal EMA', minval = 1)
smoothLen = input.int(3, 'MACD Smooth', minval = 1)

volLen = input.int(5, 'Volume SMA Length', minval = 1)
volPower = input.float(0.1, 'Volume Effect', step = 0.1)
strongMult = input.float(1.5, 'Strong Volume Multiplier', step = 0.1)

divLookback = input.int(5, 'Divergence Lookback', minval = 1, maxval = 50, group = 'Divergence')
showBullDiv = input.bool(true, 'Show Bullish Divergence (MACD)', group = 'Divergence')
showBearDiv = input.bool(true, 'Show Bearish Divergence (MACD)', group = 'Divergence')
showBullDivH = input.bool(true, 'Show Bullish Divergence (Histogram)', group = 'Divergence')
showBearDivH = input.bool(true, 'Show Bearish Divergence (Histogram)', group = 'Divergence')

//══════════════════════════════════════════════
// CLASSIC MACD
//══════════════════════════════════════════════
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

macdClassic = fastEMA - slowEMA

//══════════════════════════════════════════════
// VOLUME FACTOR
//══════════════════════════════════════════════
avgVol = ta.sma(volume, volLen)

volFactorRaw = avgVol > 0 ? volume / avgVol : 1.0

volFactor = math.pow(volFactorRaw, volPower)

//══════════════════════════════════════════════
// VOLUME PRESSURE SCORE
//══════════════════════════════════════════════
buyPressure = volume * (close - low) / (high - low + 0.0001)
sellPressure = volume * (high - close) / (high - low + 0.0001)
netPressure = buyPressure - sellPressure
avgPressure = ta.sma(math.abs(netPressure), volLen)
pressureScore = avgPressure > 0 ? netPressure / avgPressure : 0

//══════════════════════════════════════════════
// VOLUME WEIGHTED MACD
//══════════════════════════════════════════════
//pressureWeight = 1 + math.clamp(pressureScore * 0.1, -0.3, 0.3)
pressureWeight = 1 + math.max(-0.3, math.min(0.3, pressureScore * 0.1))
macd = ta.ema(macdClassic * volFactor * pressureWeight, smoothLen)

signal = ta.ema(macd, signalLen)

hist = macd - signal

//══════════════════════════════════════════════
// VOLUME MOMENTUM
//══════════════════════════════════════════════
volSma1 = ta.sma(volume, 5)
volSma2 = ta.sma(volume, 20)
volMomentum = volSma1 / volSma2

//══════════════════════════════════════════════
// HISTOGRAM COLOR (4 TONES)
//══════════════════════════════════════════════
histColor = hist >= 0 ? volMomentum >= 1 ? color.new(#089981, 0) : color.new(#ace5dc, 0) : volMomentum >= 1 ? color.new(#f23645, 0) : color.new(#f8bbd0, 0)

//══════════════════════════════════════════════
// STRONG VOLUME DETECTION
//══════════════════════════════════════════════
strongVolume = volume > avgVol * strongMult

bullCross = ta.crossover(macd, signal)
bearCross = ta.crossunder(macd, signal)

strongBull = bullCross and strongVolume
strongBear = bearCross and strongVolume

//══════════════════════════════════════════════
// DIVERGENCE — MACD line (asymmetric pivot)
//══════════════════════════════════════════════
leftBars = math.max(divLookback / 2, 2)
rightBars = divLookback

pricePivotLow = ta.pivotlow(low, leftBars, rightBars)
pricePivotHigh = ta.pivothigh(high, leftBars, rightBars)
macdPivotLow = ta.pivotlow(macd, leftBars, rightBars)
macdPivotHigh = ta.pivothigh(macd, leftBars, rightBars)

bullDivMACD = false
if not na(pricePivotLow) and not na(macdPivotLow)
    prevPriceLow = ta.valuewhen(not na(pricePivotLow), pricePivotLow, 1)
    prevMacdLow = ta.valuewhen(not na(macdPivotLow), macdPivotLow, 1)
    if pricePivotLow < prevPriceLow and macdPivotLow > prevMacdLow
        bullDivMACD := true
        bullDivMACD

bearDivMACD = false
if not na(pricePivotHigh) and not na(macdPivotHigh)
    prevPriceHigh = ta.valuewhen(not na(pricePivotHigh), pricePivotHigh, 1)
    prevMacdHigh = ta.valuewhen(not na(macdPivotHigh), macdPivotHigh, 1)
    if pricePivotHigh > prevPriceHigh and macdPivotHigh < prevMacdHigh
        bearDivMACD := true
        bearDivMACD

//══════════════════════════════════════════════
// DIVERGENCE — Histogram (asymmetric pivot)
//══════════════════════════════════════════════
histPivotLow = ta.pivotlow(hist, leftBars, rightBars)
histPivotHigh = ta.pivothigh(hist, leftBars, rightBars)

bullDivHist = false
if not na(pricePivotLow) and not na(histPivotLow)
    prevPriceLow = ta.valuewhen(not na(pricePivotLow), pricePivotLow, 1)
    prevHistLow = ta.valuewhen(not na(histPivotLow), histPivotLow, 1)
    if pricePivotLow < prevPriceLow and histPivotLow > prevHistLow
        bullDivHist := true
        bullDivHist

bearDivHist = false
if not na(pricePivotHigh) and not na(histPivotHigh)
    prevPriceHigh = ta.valuewhen(not na(pricePivotHigh), pricePivotHigh, 1)
    prevHistHigh = ta.valuewhen(not na(histPivotHigh), histPivotHigh, 1)
    if pricePivotHigh > prevPriceHigh and histPivotHigh < prevHistHigh
        bearDivHist := true
        bearDivHist

//══════════════════════════════════════════════
// PLOTS
//══════════════════════════════════════════════
hline(0, 'Zero Line', color = color.gray)

plot(hist, title = 'Histogram', style = plot.style_columns, color = histColor, linewidth = 2)

plot(macd, title = 'VW-MACD', color = color.blue, linewidth = 1)

plot(signal, title = 'Signal', color = color.orange, linewidth = 1)

//══════════════════════════════════════════════
// SIGNALS
//══════════════════════════════════════════════
plotshape(strongBull, title = 'Strong Buy', location = location.bottom, style = shape.triangleup, size = size.tiny, color = color.lime, text = 'BUY')

plotshape(strongBear, title = 'Strong Sell', location = location.top, style = shape.triangledown, size = size.tiny, color = color.red, text = 'SELL')

plot(bullCross ? macd : na, title = 'Bull Cross', style = plot.style_cross, linewidth = 3, color = color.blue)

plot(bearCross ? macd : na, title = 'Bear Cross', style = plot.style_cross, linewidth = 3, color = color.orange)

plotshape(showBullDiv and bullDivMACD, title = 'Bullish Div (MACD)', location = location.bottom, style = shape.circle, size = size.small, color = color.new(color.teal, 0), text = 'M↑', textcolor = color.teal, offset = -rightBars)

plotshape(showBearDiv and bearDivMACD, title = 'Bearish Div (MACD)', location = location.bottom, style = shape.circle, size = size.small, color = color.new(color.fuchsia, 0), text = 'M↓', textcolor = color.fuchsia, offset = -rightBars)

plotshape(showBullDivH and bullDivHist, title = 'Bullish Div (Hist)', location = location.top, style = shape.diamond, size = size.small, color = color.new(color.yellow, 0), text = 'H↑', textcolor = color.yellow, offset = -rightBars)

plotshape(showBearDivH and bearDivHist, title = 'Bearish Div (Hist)', location = location.top, style = shape.diamond, size = size.small, color = color.new(color.orange, 0), text = 'H↓', textcolor = color.orange, offset = -rightBars)

//══════════════════════════════════════════════
// INFO TABLE
//══════════════════════════════════════════════
var table t = table.new(position.top_right, 2, 5, border_width = 1)

macdDiff = macd - signal
isBullish = macd > signal
arrowSymbol = isBullish ? '▲' : '▼'
arrowColor = isBullish ? color.lime : color.red

volMomLabel = volMomentum >= 1 ? '↑ Rising' : '↓ Falling'
volMomColor = volMomentum >= 1 ? color.lime : color.orange

volFactorColor = volFactor >= 1.0 ? color.lime : color.red
volFactorLabel = volFactor >= 1.0 ? str.tostring(volFactor, '#.##') + ' High Vol' : str.tostring(volFactor, '#.##') + ' Low Vol'

pressureLabel = pressureScore > 0.5 ? '↑ Buy' : pressureScore < -0.5 ? '↓ Sell' : '→ Neutral'
pressureColor = pressureScore > 0.5 ? color.lime : pressureScore < -0.5 ? color.red : color.yellow

if barstate.islast
    table.cell(t, 0, 0, 'Metric', bgcolor = color.gray, text_color = color.white, text_size = size.tiny)
    table.cell(t, 1, 0, 'Value', bgcolor = color.gray, text_color = color.white, text_size = size.tiny)

    table.cell(t, 0, 1, 'Diff ' + arrowSymbol, text_color = color.white, text_size = size.tiny)
    table.cell(t, 1, 1, str.tostring(macdDiff, format.mintick), text_color = arrowColor, text_size = size.tiny)

    table.cell(t, 0, 2, 'Vol Factor', text_color = color.white, text_size = size.tiny)
    table.cell(t, 1, 2, volFactorLabel, text_color = volFactorColor, text_size = size.tiny)

    table.cell(t, 0, 3, 'Vol Momentum', text_color = color.white, text_size = size.tiny)
    table.cell(t, 1, 3, volMomLabel, text_color = volMomColor, text_size = size.tiny)

    table.cell(t, 0, 4, 'Vol Pressure', text_color = color.white, text_size = size.tiny)
    table.cell(t, 1, 4, pressureLabel, text_color = pressureColor, text_size = size.tiny)

//══════════════════════════════════════════════
// DYNAMIC ZONE LEVELS
//══════════════════════════════════════════════
zoneLookback = input.int(100, 'Zone Lookback Bars', minval = 10, maxval = 500, group = 'Zones')
weakSplit = input.float(0.35, 'Weak/Strong Split', minval = 0.1, maxval = 0.9, step = 0.05, group = 'Zones', tooltip = '0.35 = lower 35% of range is Weak, upper 65% is Strong')

macdPeak = math.max(ta.highest(macd, zoneLookback), 0)
macdTrough = math.min(ta.lowest(macd, zoneLookback), 0)

bullWeakLine = math.max(macdPeak * weakSplit, 0)
bearWeakLine = math.min(macdTrough * weakSplit, 0)

bullWeakLinePlot = plot(bullWeakLine, 'Weak Bull Line', color = color.new(#ace5dc, 75), linewidth = 1)
bullStrongLinePlot = plot(macdPeak, 'Strong Bull Line', color = color.new(#089981, 20), linewidth = 1)
bearWeakLinePlot = plot(bearWeakLine, 'Weak Bear Line', color = color.new(#f8bbd0, 75), linewidth = 1)
bearStrongLinePlot = plot(macdTrough, 'Strong Bear Line', color = color.new(#f23645, 20), linewidth = 1)
zeroLinePlot = plot(0, display = display.none)

fill(zeroLinePlot, bullWeakLinePlot, color = color.new(#ace5dc, 75), title = 'Weak Bull Zone')
fill(bullWeakLinePlot, bullStrongLinePlot, color = color.new(#089981, 75), title = 'Strong Bull Zone')
fill(zeroLinePlot, bearWeakLinePlot, color = color.new(#f8bbd0, 75), title = 'Weak Bear Zone')
fill(bearWeakLinePlot, bearStrongLinePlot, color = color.new(#f23645, 75), title = 'Strong Bear Zone')

var label lbWB = na
var label lbSB = na
var label lbWBr = na
var label lbSBr = na

if barstate.islast
    label.delete(lbWB)
    label.delete(lbSB)
    label.delete(lbWBr)
    label.delete(lbSBr)
    lbWB := label.new(bar_index + 5, (bullWeakLine + 0) / 2, 'Weak Bull', style = label.style_none, textcolor = color.new(#ace5dc, 0), size = size.small)
    lbSB := label.new(bar_index + 5, (macdPeak + bullWeakLine) / 2, 'Strong Bull', style = label.style_none, textcolor = color.new(#089981, 0), size = size.small)
    lbWBr := label.new(bar_index + 5, (bearWeakLine + 0) / 2, 'Weak Bear', style = label.style_none, textcolor = color.new(#f8bbd0, 0), size = size.small)
    lbSBr := label.new(bar_index + 5, (macdTrough + bearWeakLine) / 2, 'Strong Bear', style = label.style_none, textcolor = color.new(#f23645, 0), size = size.small)
    lbSBr
````
