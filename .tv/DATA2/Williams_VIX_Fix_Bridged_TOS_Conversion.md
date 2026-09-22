<!-- tradingview-pine-id: PUB;3ce468b90ab34cc09bdf474d1f43e858 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Williams VIX Fix Bridged - TOS Conversion

Source: https://www.tradingview.com/script/GQhegIcX-Williams-VIX-Fix-Bridged-TOS-Conversion/

## Description

This indicator is a synthetic fear/volatility gauge for any stock or ETF. It combines Larry Williams’ VIX Fix with adaptive Bridge Bands.

What each line means
Cyan line — WVF: Measures how far the current low has fallen from the highest closing price during the previous 22 bars.
Red upper band: An unusually high-volatility boundary.
Green lower band: An unusually low-volatility boundary.
Gray dotted middle line: Halfway between the upper and lower Bridge Bands.
Green/red trend line: Midpoint between the highest and lowest WVF readings over 63 bars.
Colored cloud: Shows the volatility regime determined by WVF’s position relative to its 63-bar trend.
Basic interpretation
WVF position	Meaning
Rising WVF	Fear and downside volatility are increasing
Falling WVF	Fear is declining and price conditions are calming
Above red upper band	Potential panic/capitulation and possible market bottom
Below green lower band	Extremely calm conditions and possible market top
Above dotted midpoint	Higher-volatility half of the range
Below dotted midpoint	Lower-volatility half of the range

The dotted midpoint is especially useful because it gives you an earlier regime reference than waiting for WVF to reach an extreme band.

For example:

WVF crosses above the dotted line: volatility is expanding; be more cautious with long positions.
WVF remains above the dotted line and approaches the red band: fear is accelerating.
WVF spikes above the red band and then falls back underneath it: possible exhaustion and reversal setup.
WVF crosses below the dotted line: fear is contracting and conditions may be improving for bullish trades.
What makes the bands adaptive

The indicator calculates a Hurst-style measurement:

Near 0.50: bands behave more like Bollinger Bands.
Farther from 0.50: the Bridge Range receives more weight.
This allows the bands to adapt between choppy/mean-reverting and strongly trending conditions.
The timeframe matters

The inputs measure bars, not necessarily days:

On a daily chart, 22 means approximately 22 trading days.
On a one-hour chart, 22 means 22 hourly candles.
On a five-minute chart, it means 22 five-minute candles.

For your swing-trading strategy, I would primarily read it on the daily chart. Use it as a market-condition filter alongside price structure, expected moves and volume—not as an automatic buy signal.

One warning about this specific code: it names WVF > trend as “bullish” and colors the cloud green. Normally, WVF above trend means elevated fear/risk-off conditions, so the cloud colors may feel backward. The mathematical lines are fine, but I would interpret the cyan WVF and dotted midpoint directly rather than assuming green always means bullish.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © armstrongwestmit


//@version=6

indicator("Williams VIX Fix Bridged - TOS Conversion", shorttitle="WVF", overlay=false, max_bars_back=500)
//==================================================
int n = input.int(22, "VIX Fix Length", minval=2)
int trendLength = input.int(63, "Trend Length", minval=2)
float threshold = input.float(0.50, "Bridge Mid Threshold", minval=0.0, maxval=1.0, step=0.05)
int length = input.int(15, "Bridge Length", minval=2)
string trendMethod = input.string("Simple", "Trend Method", options=["Simple", "Donchian"])
int trendConfirmLength = input.int(1, "Trend Confirmation Length", minval=1)

//==================================================
// VIX FIX
//==================================================
float highestClose = ta.highest(close, n)
float wvf = highestClose != 0 ? (highestClose - low) / highestClose * 100 : na

//==================================================
// BRIDGE RANGE
//==================================================
int lengthMinus1 = length - 1
float slope = (wvf - wvf[lengthMinus1]) / lengthMinus1

float minDiff = na
float maxDiff = na

if not na(wvf[lengthMinus1])
    minDiff := 10000000.0
    maxDiff := -10000000.0

    for i = 0 to lengthMinus1
        float difference = wvf[lengthMinus1 - i] - (wvf[lengthMinus1] + slope * i)
        minDiff := math.min(minDiff, difference)
        maxDiff := math.max(maxDiff, difference)

float bridgeRangeBottom = wvf + minDiff
float bridgeRangeTop = wvf + maxDiff

//==================================================
// HURST EXPONENT
//==================================================
float wvfHigh = ta.highest(wvf, length)
float wvfLow = ta.lowest(wvf, length)
float wvfRange = wvfHigh - wvfLow
float wvfChange = math.abs(wvf - wvf[1])
float atrWvf = ta.rma(wvfChange, length)
float logLength = math.log(length)

float hurst = atrWvf > 0 and wvfRange > 0 ?
     (math.log(wvfRange) - math.log(atrWvf)) / logLength :
     0.50

//==================================================
// BOLLINGER COMPONENT
// Sample standard deviation matches the TOS script.
//==================================================
float sampleDeviation = ta.stdev(wvf, length, false)
float weightedAverage = ta.wma(wvf, length)

float bbBottom = weightedAverage - sampleDeviation * 2
float bbTop = weightedAverage + sampleDeviation * 2

//==================================================
// WVF TREND
// Both methods in the supplied TOS code calculate
// the same Donchian midpoint.
//==================================================
float simpleTrend = ta.lowest(wvf, trendLength) +
     (ta.highest(wvf, trendLength) - ta.lowest(wvf, trendLength)) / 2

float donchianTrend =
     (ta.highest(wvf, trendLength) + ta.lowest(wvf, trendLength)) / 2

float wvfTrend = trendMethod == "Donchian" ? donchianTrend : simpleTrend

bool trendBullish = wvf > wvfTrend

float confirmationAverage =
     ta.sma(trendBullish ? 1.0 : 0.0, trendConfirmLength)

bool trendConfirmed = trendConfirmLength > 1 ?
     confirmationAverage >= 1.0 :
     trendBullish

//==================================================
// FINAL BRIDGE BANDS
//==================================================
float hurstWeight = math.abs(hurst * 2 - 1)

float bridgeBottom =
     bbBottom + (bridgeRangeBottom - bbBottom) * hurstWeight

float bridgeTop =
     bbTop - (bbTop - bridgeRangeTop) * hurstWeight

// This is the dotted middle line from TOS.
float bridgeMid =
     bridgeBottom + (bridgeTop - bridgeBottom) * threshold

//==================================================
// PLOTS
//==================================================
plot(
     wvf,
     title="WVF",
     color=color.aqua,
     linewidth=3
)

plot(
     wvfTrend,
     title="WVF Trend",
     color=trendConfirmed ? color.lime : color.red,
     linewidth=3
)

bottomPlot = plot(
     bridgeBottom,
     title="Bridge Bottom",
     color=color.lime,
     linewidth=3
)

topPlot = plot(
     bridgeTop,
     title="Bridge Top",
     color=color.red,
     linewidth=3
)

midPlot = plot(
     bridgeMid,
     title="Bridge Mid – Dotted",
     color=color.gray,
     linewidth=2,
     linestyle=plot.linestyle_dotted
)

//==================================================
// CLOUDS
//==================================================
color cloudColor = trendConfirmed ?
     color.new(color.green, 82) :
     color.new(color.red, 82)

fill(topPlot, midPlot, color=cloudColor, title="Upper Cloud")
fill(midPlot, bottomPlot, color=cloudColor, title="Lower Cloud")

//==================================================
// ALERTS
//==================================================
bool crossAboveTop = ta.crossover(wvf, bridgeTop)
bool crossBelowBottom = ta.crossunder(wvf, bridgeBottom)
bool extremeHigh = wvf > bridgeTop
bool extremeLow = wvf < bridgeBottom

alertcondition(
     crossAboveTop,
     title="WVF Crossed Above Top Bridge",
     message="WVF EXTREME: Crossed above top bridge – potential market bottom"
)

alertcondition(
     crossBelowBottom,
     title="WVF Crossed Below Bottom Bridge",
     message="WVF EXTREME: Crossed below bottom bridge – potential market top"
)

alertcondition(
     extremeHigh and hurst < 0.45,
     title="Mean-Reversion Setup",
     message="Extreme high volatility in a mean-reverting regime"
)

alertcondition(
     extremeLow and hurst > 0.55,
     title="Trend Warning",
     message="Low volatility while a trending regime is active"
)
````
