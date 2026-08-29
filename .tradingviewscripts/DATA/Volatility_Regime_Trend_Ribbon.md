<!-- tradingview-pine-id: PUB;3b76f4d7fdc64c55a304d1520cae7514 -->
<!-- tradingviewscripts-format: 1 -->
# Volatility Regime Trend Ribbon

Source: https://www.tradingview.com/script/mVpQKSuk-Volatility-Regime-Trend-Ribbon-Pineify/

## Description

Volatility Regime Trend Ribbon

Overview
This overlay adapts smoothing as markets change. It ranks ATR, selects a regime, and adjusts trend speed and ribbon width.

Key Features

[*]Three ATR percentile regimes.

[*]Regime-specific trend lengths and band scales.

[*]Optional colors, confirmed markers, and alerts.

How It Works
ATR is ranked over a rolling window. Low ranks select low volatility, high ranks select high volatility, and middle ranks select normal volatility. Warm-up uses the normal state.

The selected length drives a recursive EMA-style center. Ribbon edges equal the center plus or minus ATR times the base multiplier and regime scale. This is a price boundary, not a statistical confidence interval. Direction turns bullish after a confirmed close above the upper edge, bearish below the lower edge, and otherwise retains its prior state.

Trading Ideas and Insights
Colors separate quiet, ordinary, and elevated ranges. A band exit can frame a direction change; movement inside stays unresolved. Gaps or thin trading can add lag and false transitions. No output is an automatic trade.

How Multiple Indicators Work Together
ATR measures range, percentile rank adds context, adaptive smoothing changes speed, and the band supplies the direction threshold. They form one engine without external data.

Unique Aspects
The original design links volatility to smoothing speed and band scale, not just color. Retained direction inside the band adds hysteresis; alerts distinguish regime and direction changes.

How to Use

[*]Apply it to a liquid market and let the percentile window warm up.

[*]Tune lengths and band scales for the symbol and timeframe.

[*]Read center color as direction and ribbon color as regime.

[*]Use confirmed alerts with independent risk controls.

Customization
ATR Length controls range sensitivity; Percentile Lookback controls context. Thresholds define states, lengths set speed, and band inputs set transition distance. Display layers are optional. Current values can change intrabar; markers and alerts require a confirmed close.

Conclusion
This ribbon organizes volatility regime and ATR percentile context for 15-minute to daily charts. It uses past and present data, remains lagging and parameter-sensitive, and makes no performance claim.

---

## Source Code

````pine
//@version=6
indicator("Volatility Regime Trend Ribbon", overlay = true)

string groupRegime = "Volatility Regime"
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupRegime)
int percentileLookback = input.int(100, "ATR Percentile Lookback", minval = 30, maxval = 500, group = groupRegime)
float lowThreshold = input.float(33.0, "Low Volatility Threshold", minval = 5.0, maxval = 45.0, step = 1.0, group = groupRegime)
float highThreshold = input.float(67.0, "High Volatility Threshold", minval = 55.0, maxval = 95.0, step = 1.0, group = groupRegime)

string groupTrend = "Adaptive Trend"
sourceInput = input.source(hlc3, "Trend Source", group = groupTrend)
int lowVolLength = input.int(18, "Low Volatility Length", minval = 2, maxval = 100, group = groupTrend)
int normalVolLength = input.int(28, "Normal Volatility Length", minval = 3, maxval = 150, group = groupTrend)
int highVolLength = input.int(42, "High Volatility Length", minval = 5, maxval = 250, group = groupTrend)

string groupBand = "Confidence Band"
float bandMultiplier = input.float(1.0, "Base ATR Multiplier", minval = 0.1, maxval = 5.0, step = 0.1, group = groupBand)
float lowVolBandScale = input.float(0.75, "Low Volatility Band Scale", minval = 0.25, maxval = 3.0, step = 0.05, group = groupBand)
float normalVolBandScale = input.float(1.0, "Normal Volatility Band Scale", minval = 0.25, maxval = 3.0, step = 0.05, group = groupBand)
float highVolBandScale = input.float(1.35, "High Volatility Band Scale", minval = 0.25, maxval = 3.0, step = 0.05, group = groupBand)

string groupDisplay = "Display"
bool showRibbon = input.bool(true, "Show Confidence Band", group = groupDisplay)
bool showMarkers = input.bool(true, "Show Confirmed Direction Markers", group = groupDisplay)
bool colorBars = input.bool(false, "Color Bars by Direction", group = groupDisplay)

float atrValue = ta.atr(atrLength)
float atrPercentile = ta.percentrank(atrValue, percentileLookback)
int volatilityRegime = na(atrPercentile) ? 1 : atrPercentile <= lowThreshold ? 0 : atrPercentile >= highThreshold ? 2 : 1
int adaptiveLength = volatilityRegime == 0 ? lowVolLength : volatilityRegime == 2 ? highVolLength : normalVolLength
float regimeBandScale = volatilityRegime == 0 ? lowVolBandScale : volatilityRegime == 2 ? highVolBandScale : normalVolBandScale
float smoothingAlpha = 2.0 / (adaptiveLength + 1.0)

var float adaptiveTrend = na
adaptiveTrend := na(adaptiveTrend[1]) ? sourceInput : adaptiveTrend[1] + smoothingAlpha * (sourceInput - adaptiveTrend[1])

float bandWidth = na(atrValue) ? na : atrValue * bandMultiplier * regimeBandScale
float upperBand = adaptiveTrend + bandWidth
float lowerBand = adaptiveTrend - bandWidth

var int trendDirection = 0
trendDirection := na(upperBand) or na(lowerBand) ? nz(trendDirection[1], 0) : close > upperBand ? 1 : close < lowerBand ? -1 : nz(trendDirection[1], 0)

bool bullishSwitch = barstate.isconfirmed and trendDirection == 1 and trendDirection[1] != 1
bool bearishSwitch = barstate.isconfirmed and trendDirection == -1 and trendDirection[1] != -1
bool regimeSwitch = barstate.isconfirmed and not na(atrPercentile) and not na(volatilityRegime[1]) and volatilityRegime != volatilityRegime[1]

color regimeColor = volatilityRegime == 0 ? color.teal : volatilityRegime == 2 ? color.orange : color.blue
color directionColor = trendDirection == 1 ? color.lime : trendDirection == -1 ? color.red : color.gray
color centerColor = color.new(directionColor, 0)
color bandEdgeColor = color.new(regimeColor, 20)
color ribbonColor = color.new(regimeColor, trendDirection == 0 ? 90 : 84)

plot(adaptiveTrend, "Adaptive Trend", color = centerColor, linewidth = 2)
upperPlot = plot(showRibbon ? upperBand : na, "Upper Confidence Band", color = bandEdgeColor, linewidth = 1)
lowerPlot = plot(showRibbon ? lowerBand : na, "Lower Confidence Band", color = bandEdgeColor, linewidth = 1)
fill(upperPlot, lowerPlot, color = ribbonColor, title = "Volatility Regime Confidence Band")

plotshape(showMarkers and bullishSwitch, title = "Confirmed Bullish Direction Switch", style = shape.triangleup, location = location.belowbar, color = color.lime, size = size.tiny, text = "Up")
plotshape(showMarkers and bearishSwitch, title = "Confirmed Bearish Direction Switch", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny, text = "Dn")
barcolor(colorBars ? color.new(directionColor, 55) : na, title = "Trend Direction Bar Color")

alertcondition(bullishSwitch, "Bullish Trend Direction Switch", "Volatility Regime Trend Ribbon confirmed a bullish direction switch.")
alertcondition(bearishSwitch, "Bearish Trend Direction Switch", "Volatility Regime Trend Ribbon confirmed a bearish direction switch.")
alertcondition(regimeSwitch, "Volatility Regime Switch", "Volatility Regime Trend Ribbon confirmed a volatility regime switch.")
````
