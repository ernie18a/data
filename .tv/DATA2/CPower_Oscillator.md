<!-- tradingview-pine-id: PUB;2d7784e1ddab4acf8ffd7ec788f0053f -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# C-Power Oscillator

Source: https://www.tradingview.com/script/jZnRxNvK/

## Description

This script is an advanced momentum and volume-flow oscillator named the "C-Power Oscillator".
It is specifically designed to work collaboratively with the primary C-Power indicator by operating as a lower-panel confirmation tool. While the main indicator tracks price structures on the chart, this oscillator uses mathematical statistics and volume to measure the exact strength of buyers (demand) against sellers (supply) on a scale from 0 to 100%.

How the script functions:
1. Volume Spike FilterThe oscillator factors in trading volume but protects itself against anomalous volume anomalies (such as sudden news spikes) that could distort the reading. If the volume of the current candle exceeds the average volume of the analysis period by more than 3.5 times, it is artificially capped at that maximum allowed threshold.

2. Advanced Volatility Modeling (Garman-Klass)Instead of using a standard ATR (Average True Range), this script uses the sophisticated Garman-Klass volatility estimator. This model:
- Evaluates Open, High, Low, and Close prices simultaneously.
- Integrates a gap-adjustment feature to account for overnight or sharp price gaps.
- Provides a highly precise calculation of true market variance within the specified period.

3. Statistical Probability (Z-Score & Gaussian CDF)This is the core engine of the oscillator. The script measures the distance between the current close and the midpoint of the price action (calculated from the open and the previous close).
- It computes a Z-score by dividing this price imbalance by the Garman-Klass volatility.
- Using a built-in mathematical approximation of the Gaussian CDF (Cumulative Distribution Function), it translates the Z-score into a directional probability percentage. This determines whether a price move is statistically significant or just random market noise.

4. Volume/Power Split (Buy Percent Calculation)
- The calculated directional probability is multiplied by the filtered volume, creating distinct series for buyers (buyPowerSeries) and sellers (sellPowerSeries).
- The script sums these forces over the chosen analysis period (default: 10 bars) to calculate what percentage of total market power belongs to the buyers.
- A value of 50% represents perfect equilibrium. Values closer to 100% indicate absolute buyer dominance, while values near 0% indicate absolute seller dominance.

5. ALMA SmoothingTo prevent the indicator line from becoming too jagged and generating false whipsaws, the final percentage is smoothed using an ALMA (Arnaud Legoux Moving Average). ALMA uses a Gaussian distribution filter to eliminate noise and provide a clean line while maintaining minimal lag compared to traditional moving averages.

6. Noise Reduction (Deadzone) & VisualsThe script implements a Deadzone (neutral zone) around the 50% balance line (defaulting to a width of 5%, or 47.5% to 52.5%). If the market power fluctuates within this narrow band, the oscillator flattens the line to exactly 50.0, signaling a clear "no-trend / consolidation" state.

Visual Indicators On Your Panel:
- Line above 50%: The market is controlled by buyers (colored green), accompanied by a green background fill.
- Line below 50%: The market is controlled by sellers (colored red), accompanied by a red background fill.
- Overbought (default: 60) & Oversold (default: 40) Levels: When the line breaches these thresholds, it changes to a bright neon color (bright green or bright red), warning that the current market move is overextended.

Summary - acting as the perfect companion to the C-Power indicator, this oscillator removes the guesswork from volume analysis. By combining price location, statistical probability, and volume filtering, it provides a clean, lag-reduced confirmation of which side actually controls the order flow.

What exactly is the C-Power Oscillator? It’s essentially a "Money Flow Index on steroids"—one that relies not on the visual geometry of candlesticks, but on statistics and probability distribution.

---

## Source Code

````pine
//@version=6
indicator("C-Power Oscillator", overlay=false, max_bars_back=500)

// USER SETTINGS
var string G_MAIN = "Main Computational Core"
int candlePeriod = input.int(10, title="Analysis Period (bars)", minval=2, group=G_MAIN)
float deadzoneWidth = input.float(4.0, title="Neutral Deadzone Width (%)", minval=0.0, maxval=50.0, step=0.5, group=G_MAIN, tooltip="Width of the noise filtering zone around the 50% level. A value of 5.0% means ±2.5% from the center (ranging from 47.5 to 52.5).")

var string G_BOUNDS = "Overbought / Oversold Thresholds"
int obLevel = input.int(62, title="Overbought Level (OB)", minval=50, maxval=100, step=1, group=G_BOUNDS)
int osLevel = input.int(38, title="Oversold Level (OS)", minval=0, maxval=50, step=1, group=G_BOUNDS)

var string G_ALMA = "Line Smoothing (ALMA)"
int almaLength   = input.int(5, title="ALMA: Length", minval=1, group=G_ALMA)
float almaOffset = input.float(0.85, title="ALMA: Offset", minval=0.0, maxval=1.0, step=0.05, group=G_ALMA, tooltip="Values closer to 1.0 reduce lag but decrease smoothness.")
float almaSigma  = input.float(1.5, title="ALMA: Sigma", minval=0.0, step=0.5, group=G_ALMA, tooltip="Higher sigma values increase filter sharpness and smoothness.")

var string G_COLORS = "Color Customization"
color customBullColor = input.color(color.rgb(34, 139, 34, 30), title="Buyers Fill Color", group=G_COLORS)
color customBearColor = input.color(color.rgb(220, 20, 60, 30), title="Sellers Fill Color", group=G_COLORS)
color lineBullColor   = input.color(color.rgb(0, 200, 50), title="Buyers Line Color", group=G_COLORS)
color lineBearColor   = input.color(color.rgb(255, 50, 50), title="Sellers Line Color", group=G_COLORS)

// VOLUME FILTER
float rawVolume = nz(volume)
float processedVolume = rawVolume

float periodAvgVol = ta.alma(rawVolume, candlePeriod, 0.85, 1.0)
float maxAllowedVol = periodAvgVol * 3.5

if rawVolume > maxAllowedVol and periodAvgVol > 0
    processedVolume := maxAllowedVol

// COMPUTATIONAL CORE (HYBRID GK + RS + YZ)
float c_open     = open
float c_high     = high
float c_low      = low
float c_close    = close
float prev_close = nz(close[1], c_open)

float effHigh = math.max(c_high, prev_close)
float effLow  = math.max(math.min(c_low, prev_close), 0.00000001)

// YANG-ZHANG COMPONENT (Opening gap volatility / Overnight Gap)
float log_gap = math.log(c_open / math.max(prev_close, 0.00000001))
float yz_gap_element = math.pow(log_gap, 2.0)

// GARMAN-KLASS COMPONENT (Efficiency of H-L to C-O ratio)
float log_h_l = math.log(effHigh / effLow)
float log_c_o = c_open > 0 ? math.log(c_close / math.max(c_open, 0.00000001)) : 0.0
float gk_core = 0.5 * math.pow(log_h_l, 2.0) - (2.0 * math.log(2.0) - 1.0) * math.pow(log_c_o, 2.0)

// ROGERS-SATCHELL COMPONENT (Resilience to strong trends / Drift-Independent)
float log_h_c = math.log(effHigh / c_close)
float log_h_o = math.log(effHigh / c_open)
float log_l_c = math.log(effLow / c_close)
float log_l_o = math.log(effLow / math.max(c_open, 0.00000001))
float rs_core = log_h_c * log_h_o + log_l_c * log_l_o

// HYBRID SYNTHESIS (50/50 component weighting)
float intraday_core = (math.max(gk_core, 0.0) + math.max(rs_core, 0.0)) / 2.0
float hybrid_element = (0.5 * yz_gap_element) + (0.5 * intraday_core)

// Final volatility calculation for Z-Score
float hybrid_volatility = math.sqrt(math.max(hybrid_element, 0.0)) * c_close
float minVolatility = 0.00000001 * c_close
float finalVolatility = math.max(hybrid_volatility, minVolatility)

// Price imbalance relative to the midpoint of the session
float midPoint = (c_open + prev_close) / 2.0
float priceImbalance = c_close - midPoint

// Calculate direction weight via the Gaussian Cumulative Distribution Function (CDF)
float z_score = priceImbalance / finalVolatility

erf(x) =>
    float t = 1.0 / (1.0 + 0.5 * math.abs(x))
    float ans = 1.0 - t * math.exp(-x * x - 1.26551223 + t * (1.00002368 + t * (0.37409196 + t * (0.09678418 + t * (-0.01862880 + t * (0.02788680 + t * (-1.13520398 + t * (1.48851587 + t * (-0.82215223 + t * 0.17087277)))))))))
    x >= 0 ? ans : -ans

normCDF(z) =>
    0.5 * (1.0 + erf(z / math.sqrt(2.0)))

float directionWeight = normCDF(z_score)

// POWER EXTRACTION AND MACRO AGGREGATION
float sumVolume = math.sum(processedVolume, candlePeriod)
bool hasVolume = nz(sumVolume) > 0

// Consistent series assignment (Volume weighted vs Pure Price Action)
float buyPowerSeries  = hasVolume ? (processedVolume * directionWeight) : directionWeight
float sellPowerSeries = hasVolume ? (processedVolume * (1.0 - directionWeight)) : (1.0 - directionWeight)

float totalBuyPower  = math.sum(nz(buyPowerSeries), candlePeriod)
float totalSellPower = math.sum(nz(sellPowerSeries), candlePeriod)
float aggregatePower = totalBuyPower + totalSellPower

float periodHigh = ta.highest(effHigh, candlePeriod)
float periodLow  = ta.lowest(effLow, candlePeriod)

// Calculate raw buyers percentage power
float rawBuyPercent = aggregatePower > 0.0 ? (totalBuyPower / aggregatePower) * 100.0 : 50.0
  
float finalBuyPercent = rawBuyPercent
if finalBuyPercent >= 100.0 and c_close < periodHigh
    finalBuyPercent := 97.5
if finalBuyPercent <= 0.0 and c_close > periodLow
    finalBuyPercent := 2.5

// Smooth final line using the ALMA filter
float smoothBuyPercent = ta.alma(finalBuyPercent, almaLength, almaOffset, almaSigma)

// NEUTRAL ZONE LOGIC (DEADZONE)
float halfZone = deadzoneWidth / 2.0
float upperDeadThreshold = 50.0 + halfZone
float lowerDeadThreshold = 50.0 - halfZone

if smoothBuyPercent <= upperDeadThreshold and smoothBuyPercent >= lowerDeadThreshold
    smoothBuyPercent := 50.0

// VISUALIZATION
line_100 = plot(100, title="Upper Boundary", display=display.none)
line_OB  = plot(obLevel,  title="Overbought Level (OB)", color=color.new(color.gray, 40), linewidth=1)

plotDeadUpper = plot(upperDeadThreshold, title="Deadzone - Upper Threshold", color=color.rgb(128, 128, 128))
line_50  = plot(50,  title="Equilibrium Line (50%)", color=color.new(color.gray, 30), linewidth=2)
plotDeadLower = plot(lowerDeadThreshold, title="Deadzone - Lower Threshold", color=color.rgb(128, 128, 128))

line_OS  = plot(osLevel,  title="Oversold Level (OS)", color=color.new(color.gray, 40), linewidth=1)
line_0   = plot(0,   title="Lower Boundary", display=display.none)

// Fill the background of the neutral deadzone
fill(plotDeadUpper, plotDeadLower, color=color.rgb(128, 128, 128, 85), title="Neutral Zone Background")

// Dynamic line coloring depending on market trends and statistical extremes
color oscLineColor = smoothBuyPercent >= obLevel ? color.rgb(0, 255, 100) : smoothBuyPercent <= osLevel ? color.rgb(255, 0, 0) : (smoothBuyPercent > 50.0 ? lineBullColor : smoothBuyPercent < 50.0 ? lineBearColor : color.gray)
oscPlot = plot(smoothBuyPercent, title="C-Power Line (ALMA)", color=oscLineColor, linewidth=2, style=plot.style_line)

// Dynamic cloud mapping (Bull Zone vs Bear Zone filling)
fill(oscPlot, line_50, top_value=100, bottom_value=50, top_color=customBullColor, bottom_color=color.rgb(0,0,0,100), title="Bull Zone Filling")
fill(oscPlot, line_50, top_value=50, bottom_value=0, top_color=color.rgb(0,0,0,100), bottom_color=customBearColor, title="Bear Zone Filling")
````
