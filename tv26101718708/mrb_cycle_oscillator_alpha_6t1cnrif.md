# MRB Cycle Oscillator Alpha

- url: https://www.tradingview.com/script/6T1cNrif/
- type: indicator
- pine_id: PUB;3e623ab887c04fa2b9c7c8ef7db20df1
- version: 1.0

## Description

**Overview**
The "MRB Cycle Oscillator Alpha" is a highly advanced, multi-dimensional momentum and trend-analysis tool. It is not just another MACD; it upgrades traditional momentum concepts by combining Triple Exponential Smoothing (TES), mathematically derived momentum "Cycle Candles," RSI-confluent Bollinger Bands, and an ADX/DMI-driven background. This provides traders with a unified dashboard for trend direction, momentum strength, and mean-reversion zones without cluttering the main chart.

**What makes it original? (Core Concepts)**
This script brings originality to the Community Scripts by fusing several independent mathematical concepts into a single cohesive oscillator:
1. **TES-MACD (Triple Exponential Smoothing):** Instead of standard EMAs, this indicator calculates the MACD utilizing a custom Triple Exponential Smoothing (TES) algorithm. This significantly reduces market noise and lag compared to a traditional MACD.
2. **Momentum Cycle Candles:** Instead of displaying a raw oscillator line, the script extracts the open, high, low, and close values directly from the TES-MACD's historical delta. It then applies a custom smoothing algorithm to generate "Cycle Candles." This unique transformation visualizes momentum shifts and trend persistence much more clearly than a standard line or histogram.
3. **RSI-Dynamic Bollinger Bands:** Bollinger Bands are applied directly to the oscillator (users can choose to base it on the MACD Line EMA or the Signal Line TES). Furthermore, the outer bands dynamically change color based on the traditional chart's RSI values (e.g., turning green when RSI is overbought, red when oversold). This provides a dual-confirmation for extreme conditions.
4. **ADX/DMI Background Matrix:** The indicator calculates ADX and ±DI in the background. If the ADX crosses a user-defined threshold, the chart background changes color based on the dominant DI (green for uptrends, red for downtrends). This acts as a macro-trend filter.

**How to use it**
* **Trend Confirmation:** Use the background color (driven by ADX/DMI) to filter your trades. Only look for long setups when the background is green, and short setups when red.
* **Momentum Shifts:** Watch the color and body of the Cycle Candles in the oscillator pane. A transition from red to green indicates a shift to bullish momentum.
* **Overextended Zones (Mean Reversion):** When the Cycle Candles pierce the outer Bollinger Bands, AND the bands themselves change color (triggered by RSI extremes), it signals a highly overextended market, warning of a potential reversal or pullback.

**Customization**
Every element is modular. Traders can disable the Cycle Candles view in favor of a standard line, toggle the Bollinger Bands, adjust the RSI thresholds for band coloring, and fine-tune the ADX/DMI periods for background filtering.

## Source Code

````pine
//@version=6
indicator("MRB Cycle Oscillator Alpha", overlay=false)

// TES MA Calculation Function
ema(src, length) =>
    alpha = 2 / (length + 1)
    ema = 0.0
    ema := alpha * src + (1 - alpha) * nz(ema[1], src)

tes(src, length) =>
    ema(ema(ema(src, length), length), length)

// --- inputs ---
fastLength = input.int(3, title="TES-MACD Fast Length", minval=1)
slowLength = input.int(10, title="TES-MACD Slow Length", minval=1)
signalLength = input.int(1, title="TES-MACD Signal Length", minval=1)
showSignalLine = input.bool(false, title="Show Signal Line")
macdLineColor = input.color(color.aqua, title="TES-MACD Line Color")
signalLineColor = input.color(color.red, title="TES-MACD Signal Line Color")
zeroLineColor = input.color(color.gray, title="Zero Line Color")
signalPlotOffset = input.int(2, title="Signal Line Plot Offset (Bars)", minval=-500, maxval=500)

// Option: show MACD line (user can toggle line visibility)
showMacdLine = input.bool(false, title="Show MACD Line (optional)")

// Bollinger Band Parameters
bbLength = input.int(89, title="BB Period (TES-MACD)", minval=1)
bbStdDev = input.float(1.618, title="BB Standard Deviation (Outer Band)", minval=0.1)
bbStdDev2 = input.float(1.618, title="BB Standard Deviation (Inner Band)", minval=0.1)
showBB = input.bool(true, title="Show Bollinger Bands")
bbFillColor = input.color(color.new(color.blue, 90), title="BB Fill Color")
bbType = input.string("MACD Line EMA", title="BB Basis", options=["MACD Line EMA", "Signal Line TES"])
showBBMiddle = input.bool(false, title="Show BB Middle Line")

// RSI Parameters
rsiLength = input.int(21, title="RSI Length", minval=1)
rsiOverbought = input.float(70, title="RSI Overbought Level", minval=0, maxval=100)
rsiOversold = input.float(30, title="RSI Oversold Level", minval=0, maxval=100)
rsiBandColorDefault = input.color(color.gray, title="BB Band Default Color (RSI Neutral)")

// ADX/DMI Background Color Parameters
adxPeriod = input.int(8, title="ADX Period (for Background Color)", minval=1)
diPeriod = input.int(13, title="+DI/-DI Period (for Background Color)", minval=1)
adxSmoothingPeriod = input.int(8, title="ADX Smoothing Period (for Background Color)", minval=1)
adxThreshold = input.float(25.0, title="ADX Threshold (for Trend Background)", minval=0)
colorUptrendBg = input.color(color.new(color.green, 50), title="Uptrend Background Color (Transparency)")
colorDowntrendBg = input.color(color.new(color.red, 50), title="Downtrend Background Color (Transparency)")
colorNeutralBg = input.color(color.new(color.gray, 70), title="Neutral/Weak Trend Background Color (Transparency)")

// --- TES-based MACD Calculation ---
fastTES = tes(close, fastLength)
slowTES = tes(close, slowLength)
macdLine = fastTES - slowTES
signalLine = tes(macdLine, signalLength)

// --- Cycle Candles Calculation for the MACD Line Itself ---
var float cycle_open = na
var float cycle_close = na
var float cycle_high = na
var float cycle_low = na

macd_pseudo_open = macdLine[1]
macd_pseudo_close = macdLine
macd_pseudo_high = math.max(macdLine, macdLine[1])
macd_pseudo_low = math.min(macdLine, macdLine[1])

cycle_close := (macd_pseudo_open + macd_pseudo_high + macd_pseudo_low + macd_pseudo_close) / 4
cycle_open := na(cycle_open[1]) ? (macd_pseudo_open + macd_pseudo_close) / 2 : (cycle_open[1] + cycle_close[1]) / 2
cycle_high := math.max(macd_pseudo_high, math.max(cycle_open, cycle_close))
cycle_low := math.min(macd_pseudo_low, math.min(cycle_open, cycle_close))

// --- Display Type: Default is Cycle Candles (Toggleable) ---
macdDisplayType = input.string("Cycle Candles", title="Oscillator Display Type", options=["Line", "Cycle Candles"])

// Cycle Candle Color Settings
cycleBullColor = input.color(color.new(color.green, 0), title="Cycle Candle Bullish Color")
cycleBearColor = input.color(color.new(color.red, 0), title="Cycle Candle Bearish Color")

// --- Plots ---
// MACD Line (optional display)
plot(showMacdLine ? macdLine : (macdDisplayType == "Line" ? macdLine : na), color=macdLineColor, title="TES-MACD Line")

// Cycle Candles (selected or default)
colorCycleBody = cycle_close >= cycle_open ? cycleBullColor : cycleBearColor
plotcandle(macdDisplayType == "Cycle Candles" ? cycle_open : na,
           macdDisplayType == "Cycle Candles" ? cycle_high : na,
           macdDisplayType == "Cycle Candles" ? cycle_low : na,
           macdDisplayType == "Cycle Candles" ? cycle_close : na,
           title="Momentum Cycle Candles",
           color=colorCycleBody,
           wickcolor=colorCycleBody,
           bordercolor=colorCycleBody,
           display=display.pane)

// Signal Line (offset applied)
plot(showSignalLine ? signalLine : na, color=signalLineColor, title="TES-MACD Signal Line", offset=signalPlotOffset)

// Zero Line
hline(0, title="Zero Line", color=zeroLineColor, linestyle=hline.style_dotted)

// --- Bollinger Band Calculation ---
basis_macd_ema = ta.ema(macdLine, bbLength)
dev_macd_ema = ta.stdev(macdLine, bbLength)
upperBand_macd_ema = basis_macd_ema + dev_macd_ema * bbStdDev
lowerBand_macd_ema = basis_macd_ema - dev_macd_ema * bbStdDev
upperBand2_macd_ema = basis_macd_ema + dev_macd_ema * bbStdDev2
lowerBand2_macd_ema = basis_macd_ema - dev_macd_ema * bbStdDev2

basis_signal_tes = signalLine
dev_signal_tes = ta.stdev(signalLine, bbLength)
upperBand_signal_tes = basis_signal_tes + dev_signal_tes * bbStdDev
lowerBand_signal_tes = basis_signal_tes - dev_signal_tes * bbStdDev
upperBand2_signal_tes = basis_signal_tes + dev_signal_tes * bbStdDev2
lowerBand2_signal_tes = basis_signal_tes - dev_signal_tes * bbStdDev2

var float currentUpperBand = na
var float currentLowerBand = na
var float currentUpperBand2 = na
var float currentLowerBand2 = na
var float currentBasis = na

if bbType == "MACD Line EMA"
    currentUpperBand := upperBand_macd_ema
    currentLowerBand := lowerBand_macd_ema
    currentUpperBand2 := upperBand2_macd_ema
    currentLowerBand2 := lowerBand2_macd_ema
    currentBasis := basis_macd_ema
else
    currentUpperBand := upperBand_signal_tes
    currentLowerBand := lowerBand_signal_tes
    currentUpperBand2 := upperBand2_signal_tes
    currentLowerBand2 := lowerBand2_signal_tes
    currentBasis := basis_signal_tes

// --- RSI Calculation ---
rsi_val = ta.rsi(close, rsiLength)

var color bbBandColorDynamic = rsiBandColorDefault
if rsi_val >= rsiOverbought
    bbBandColorDynamic := color.green
else if rsi_val <= rsiOversold
    bbBandColorDynamic := color.red
else
    bbBandColorDynamic := rsiBandColorDefault

var color circleBandColor = na
if rsi_val >= rsiOverbought
    circleBandColor := color.rgb(126, 242, 10)
else if rsi_val <= rsiOversold
    circleBandColor := color.rgb(247, 7, 15)
else
    circleBandColor := color.new(color.blue, 100)

upperPlot = plot(showBB ? currentUpperBand : na, color=circleBandColor, title="Upper Band", style=plot.style_circles, linewidth=2, offset=(bbType == "Signal Line TES" ? signalPlotOffset : 0))
lowerPlot = plot(showBB ? currentLowerBand : na, color=circleBandColor, title="Lower Band", style=plot.style_circles, linewidth=2, offset=(bbType == "Signal Line TES" ? signalPlotOffset : 0))

upperPlot2 = plot(showBB ? currentUpperBand2 : na, color=bbBandColorDynamic, title="Upper Band 2", offset=(bbType == "Signal Line TES" ? signalPlotOffset : 0))
lowerPlot2 = plot(showBB ? currentLowerBand2 : na, color=bbBandColorDynamic, title="Lower Band 2", offset=(bbType == "Signal Line TES" ? signalPlotOffset : 0))

plot(showBB and showBBMiddle ? currentBasis : na, color=bbBandColorDynamic, title="BB Middle Line", style=plot.style_line, linewidth=1, offset=(bbType == "Signal Line TES" ? signalPlotOffset : 0))

fill(upperPlot, lowerPlot, color=showBB ? bbFillColor : na, title="Band Fill")

// --- ADX/DMI Calculation (for Background Color) ---
tr_adx = math.max(math.max(high - low, math.abs(high - close[1])), math.abs(low - close[1]))
up_adx = high - high[1]
down_adx = low[1] - low
plusDM_adx = (up_adx > down_adx and up_adx > 0) ? up_adx : 0
minusDM_adx = (down_adx > up_adx and down_adx > 0) ? down_adx : 0

smoothedTR_adx = ta.rma(tr_adx, diPeriod)
smoothedPlusDM_adx = ta.rma(plusDM_adx, diPeriod)
smoothedMinusDM_adx = ta.rma(minusDM_adx, diPeriod)

plusDI_adx = smoothedTR_adx == 0 ? 0 : 100 * (smoothedPlusDM_adx / smoothedTR_adx)
minusDI_adx = smoothedTR_adx == 0 ? 0 : 100 * (smoothedMinusDM_adx / smoothedTR_adx)

sumDI_adx = plusDI_adx + minusDI_adx
dx_adx = sumDI_adx == 0 ? 0 : 100 * (math.abs(plusDI_adx - minusDI_adx) / sumDI_adx)

adx_val = ta.rma(dx_adx, adxSmoothingPeriod)

var color bgColor = na
if adx_val > adxThreshold
    if plusDI_adx > minusDI_adx
        bgColor := colorUptrendBg
    else if minusDI_adx > plusDI_adx
        bgColor := colorDowntrendBg
    else
        bgColor := colorNeutralBg
else
    bgColor := colorNeutralBg

bgcolor(bgColor)
````
