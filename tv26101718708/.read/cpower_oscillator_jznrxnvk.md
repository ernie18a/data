# C-Power Oscillator

- url: https://www.tradingview.com/script/jZnRxNvK/
- type: indicator
- pine_id: PUB;2d7784e1ddab4acf8ffd7ec788f0053f
- version: 5.0

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

## Source Code

````pine
//@version=6
indicator("C-Power Osc. PRO", overlay=false, max_bars_back=500)

// USER SETTINGS
var string G_MAIN = "Main Computational Core"
int candlePeriod = input.int(10, title="Analysis Period (bars)", minval=3, group=G_MAIN)
float deadzoneWidth = input.float(3.0, title="Neutral Deadzone Width (%)", minval=0.0, maxval=50.0, step=0.5, group=G_MAIN)
float logWeight = input.float(50.0, title="Log Structure Weight (%)", minval=0.0, maxval=100.0, step=5.0, group=G_MAIN)

var string G_BOUNDS = "Overbought / Oversold Thresholds"
int obLevel = input.int(60, title="Overbought Level (OB)", minval=50, maxval=100, step=1, group=G_BOUNDS)
int osLevel = input.int(40, title="Oversold Level (OS)", minval=0, maxval=50, step=1, group=G_BOUNDS)

var string G_ALMA = "Line Smoothing (ALMA)"
int almaLength   = input.int(5, title="ALMA: Length", minval=1, group=G_ALMA)
float almaOffset = input.float(0.85, title="ALMA: Offset", minval=0.0, maxval=1.0, step=0.05, group=G_ALMA)
float almaSigma  = input.float(1.50, title="ALMA: Sigma", minval=0.0, step=0.5, group=G_ALMA)

var string G_COLORS = "Color Customization"
color customBullColor = input.color(color.rgb(34, 139, 34, 30), title="Buyers Fill Color", group=G_COLORS)
color customBearColor = input.color(color.rgb(220, 20, 60, 30), title="Sellers Fill Color", group=G_COLORS)
color lineBullColor   = input.color(color.rgb(0, 200, 50), title="Buyers Line Color", group=G_COLORS)
color lineBearColor   = input.color(color.rgb(255, 50, 50), title="Sellers Line Color", group=G_COLORS)

var string G_DIV = "Full Divergence Engine"
int pivotLookback = input.int(4, title="Pivot Lookback Period", minval=1, group=G_DIV)
int minDivRange  = input.int(5, title="Min Bars Between Pivots", minval=2, group=G_DIV)
int maxDivRange  = input.int(60, title="Max Bars Between Pivots", minval=5, group=G_DIV)

bool showRegularBull = input.bool(true, title="Show Regular Bullish (Oscillator)", group=G_DIV)
bool showRegularBear = input.bool(true, title="Show Regular Bearish (Oscillator)", group=G_DIV)
bool showHiddenBull  = input.bool(true, title="Show Hidden Bullish (Oscillator)", group=G_DIV)
bool showHiddenBear  = input.bool(true, title="Show Hidden Bearish (Oscillator)", group=G_DIV)
bool showChartLines  = input.bool(true, title="Show Comparison Lines on Main Price Chart", group=G_DIV)

color regBullColor = input.color(color.rgb(0, 230, 118), title="Regular Bullish Color", group=G_DIV)
color regBearColor = input.color(color.rgb(255, 23, 68), title="Regular Bearish Color", group=G_DIV)
color hidBullColor = input.color(color.rgb(0, 184, 212), title="Hidden Bullish Color", group=G_DIV)
color hidBearColor = input.color(color.rgb(255, 109, 0), title="Hidden Bearish Color", group=G_DIV)

// CORE AUXILIARY MATHEMATICAL FUNCTIONS
f_tanh(float x) =>
    float ax = math.abs(x)
    float t = math.exp(-2.0 * ax)
    float y = (1.0 - t) / (1.0 + t)
    math.sign(x) * y

erf(float x) =>  
    float clampedX = math.max(-4.0, math.min(4.0, x))
    float t = 1.0 / (1.0 + 0.5 * math.abs(clampedX))
    float ans = 1.0 - t * math.exp(-clampedX * clampedX - 1.26551223 + t * (1.00002368 + t * (0.37409196 + t * (0.09678418 + t * (-0.01862880 + t * (0.02788680 + t * (-1.13520398 + t * (1.48851587 + t * (-0.82215223 + t * 0.17087277)))))))))
    clampedX >= 0.0 ? ans : -ans

normCDF(float z) =>
    0.5 * (1.0 + erf(z / math.sqrt(2.0)))

// VOLUME FILTER - ADAPTIVE SMOOTHING
float rawVolume = nz(volume)
float processedVolume = rawVolume

float periodAvgVol = ta.alma(rawVolume, candlePeriod, 0.85, 1)
float rawVolStDev = ta.stdev(rawVolume, candlePeriod)
float volStDev = na(rawVolStDev) or rawVolStDev == 0.0 ? 0.00000001 : rawVolStDev

float maxAllowedVol = periodAvgVol > 0.0 ? periodAvgVol + (4.0 * volStDev) : 0.0

if rawVolume > maxAllowedVol and periodAvgVol > 0.0
    processedVolume := maxAllowedVol

// GKYZ HYBRID CORE
float prev_close = nz(close[1], open)
float effHigh = math.max(high, prev_close)
float effLow  = math.max(math.min(low, prev_close), 0.00000001)

float GK_COEF = 2.0 * math.log(2.0) - 1.0
float overnightReturn = open > 0.0 and prev_close > 0.0 ? 100.0 * math.log(open / prev_close) : 0.0
float overnightVariance = math.pow(overnightReturn, 2.0)

float pct_h_l = effHigh > 0.0 and effLow > 0.0 ? 100.0 * math.log(effHigh / effLow) : 0.0
float pct_c_o = open > 0.0 and close > 0.0 ? 100.0 * math.log(close / open) : 0.0
float gk_core = 0.5 * math.pow(pct_h_l, 2.0) - GK_COEF * math.pow(pct_c_o, 2.0)

float pct_h_c = effHigh > 0.0 and close > 0.0 ? 100.0 * math.log(effHigh / close) : 0.0
float pct_h_o = effHigh > 0.0 and open > 0.0 ? 100.0 * math.log(effHigh / open) : 0.0
float pct_l_c = effLow > 0.0 and close > 0.0 ? 100.0 * math.log(effLow / close) : 0.0
float pct_l_o = effLow > 0.0 and open > 0.0 ? 100.0 * math.log(effLow / open) : 0.0
float rs_core = pct_h_c * pct_h_o + pct_l_c * pct_l_o

float intradayVariance = (math.max(gk_core, 0.0) + math.max(rs_core, 0.0)) / 2.0
float hybrid_element = (0.5 * overnightVariance) + (0.5 * intradayVariance)
float gkyzMeanVariance = ta.alma(hybrid_element, candlePeriod, 0.85, 1.0)
float finalVolatilityPct = na(gkyzMeanVariance) or gkyzMeanVariance < 0.0 ? 0.01 : math.max(math.sqrt(gkyzMeanVariance), 0.01)

// KAUFMAN & FISHER INFORMATION NON-LINEAR VOLATILITY SCALING
float candleSpread = math.abs(close - open)
float priceChangeAbs = math.abs(close - prev_close)
float volWeightedChange = priceChangeAbs * processedVolume
float totalVolWeightedChange = math.sum(volWeightedChange, candlePeriod)

float directionalChange = (close - prev_close) * processedVolume
float netVolWeightedChange = math.sum(directionalChange, candlePeriod)

float rawVWER = totalVolWeightedChange > 0.0 ? math.min(math.abs(netVolWeightedChange) / totalVolWeightedChange, 1.0) : 0.5
float efficiencyRatio = ta.alma(rawVWER, candlePeriod, 0.85, 1.0)

// Fisher Information Scaling
float fisherInf = f_tanh(efficiencyRatio * math.log(1.0 + finalVolatilityPct))
float dynamicLogWeight = logWeight * fisherInf

float midPoint = (open + prev_close) / 2.0
float interBarImbalancePct = close > 0.0 and midPoint > 0.0 ? 100.0 * math.log(close / midPoint) : 0.0
float intraLogImbalancePct = pct_c_o

float w_log = dynamicLogWeight / 100.0
float w_inter = 1.0 - w_log
float priceImbalancePct = (interBarImbalancePct * w_inter) + (intraLogImbalancePct * w_log)

// 2D MAHALANOBIS COVARIANCE ADJUSTMENT
float spreadStDev = math.max(ta.stdev(candleSpread, candlePeriod), 0.00000001)

float volZScore = (processedVolume - periodAvgVol) / volStDev
float spreadZScore = (candleSpread - ta.alma(candleSpread, candlePeriod, 0.85, 1)) / spreadStDev

float expected_XY = ta.alma(processedVolume * candleSpread, candlePeriod, 0.85, 1)
float cov_vol_spread = expected_XY - (periodAvgVol * ta.alma(candleSpread, candlePeriod, 0.85, 1))

float r_corr = cov_vol_spread / math.max(volStDev * spreadStDev, 0.00000001)
float r_clamped = math.max(-0.99, math.min(0.99, r_corr))

float mahalanobis_sq = (1.0 / (1.0 - math.pow(r_clamped, 2.0))) * (math.pow(volZScore, 2.0) + math.pow(spreadZScore, 2.0) - 2.0 * r_clamped * volZScore * spreadZScore)
float mahalanobis_dist = math.sqrt(math.max(mahalanobis_sq, 0.0))

float rawEffortScore = (volZScore > 0.0 and spreadZScore < volZScore) ? mahalanobis_dist : 0.0
float continuousAnomalyWeight = f_tanh(rawEffortScore * 0.5)

float candleRange = high - low
float closePosition = candleRange > 0.0 ? (close - low) / candleRange : 0.5
float volumeFlowDirection = (closePosition - 0.5) * 2.0 
float anomalyAdjustmentPct = volumeFlowDirection * continuousAnomalyWeight * finalVolatilityPct * 0.4

priceImbalancePct := priceImbalancePct + anomalyAdjustmentPct

// RE-BALANCED Z-SCORE & MACRO AGGREGATION
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float totalWicks = upperWick + lowerWick

float z_score = priceImbalancePct / finalVolatilityPct
float directionWeight = normCDF(z_score)

float sumVolume = math.sum(processedVolume, candlePeriod)
bool hasVolume = nz(sumVolume) > 0.0

float p_momentum = (close - open) / math.max(candleSpread, 0.00000001)
float knotAsymmetry = totalWicks > 0.0 ? (lowerWick - upperWick) / totalWicks : 0.0
float gravityShift = (volumeFlowDirection * 0.3) + (knotAsymmetry * 0.15) + (p_momentum * 0.05)
float parabolicPOCFactor = 0.5 + math.max(-0.45, math.min(0.45, gravityShift))

float parabolicAdjustment = (parabolicPOCFactor - 0.5) * 2.0 
float adjDirectionWeight = math.max(0.0, math.min(1.0, directionWeight * 0.6 + (parabolicAdjustment + 1.0) * 0.2))

float buyPowerSeries  = hasVolume ? (processedVolume * adjDirectionWeight) : adjDirectionWeight
float sellPowerSeries = hasVolume ? (processedVolume * (1.0 - adjDirectionWeight)) : (1.0 - adjDirectionWeight)

float totalBuyPower  = math.sum(nz(buyPowerSeries), candlePeriod)
float totalSellPower = math.sum(nz(sellPowerSeries), candlePeriod)
float aggregatePower = totalBuyPower + totalSellPower

float periodHigh = ta.highest(effHigh, candlePeriod)
float periodLow  = ta.lowest(effLow, candlePeriod)

float rawBuyPercent = aggregatePower > 0.0 ? (totalBuyPower / aggregatePower) * 100.0 : 50.0
float finalCentered = rawBuyPercent
 
if finalCentered >= 100.0 and close < periodHigh
    finalCentered := 97.5
if finalCentered <= 0.0 and close > periodLow
    finalCentered := 2.5

float smoothCentered = ta.alma(finalCentered, almaLength, almaOffset, almaSigma)

// NEUTRAL ZONE LOGIC (DEADZONE)
float halfZone = deadzoneWidth / 2.0
float upperDeadThreshold = 50.0 + halfZone
float lowerDeadThreshold = 50.0 - halfZone

if smoothCentered <= upperDeadThreshold and smoothCentered >= lowerDeadThreshold
    smoothCentered := 50.0

// VISUALIZATION
line_100 = plot(100, title="Upper Boundary", display=display.none)
line_OB  = plot(obLevel,   title="Overbought Level (OB)", color=color.new(color.gray, 40), linewidth=1)

plotDeadUpper = plot(upperDeadThreshold, title="Deadzone - Upper Threshold", color=color.rgb(128, 128, 128))
line_50  = plot(50,   title="Equilibrium Line (50%)", color=color.new(color.gray, 30), linewidth=2)
plotDeadLower = plot(lowerDeadThreshold, title="Deadzone - Lower Threshold", color=color.rgb(128, 128, 128))

line_OS  = plot(osLevel,   title="Oversold Level (OS)", color=color.new(color.gray, 40), linewidth=1)
line_0   = plot(0,   title="Lower Boundary", display=display.none)

fill(plotDeadUpper, plotDeadLower, color=color.rgb(128, 128, 128, 85), title="Neutral Zone Background")

color oscLineColor = smoothCentered >= obLevel ? color.rgb(0, 255, 100) : smoothCentered <= osLevel ? color.rgb(255, 0, 0) : (smoothCentered > 50.0 ? lineBullColor : smoothCentered < 50.0 ? lineBearColor : color.gray)
oscPlot = plot(smoothCentered, title="C-Power Line (ALMA)", color=oscLineColor, linewidth=2, style=plot.style_line)

fill(oscPlot, line_50, top_value=100, bottom_value=50, top_color=customBullColor, bottom_color=color.rgb(0,0,0,100), title="Bull Zone Filling")
fill(oscPlot, line_50, top_value=50, bottom_value=0, top_color=color.rgb(0,0,0,100), bottom_color=customBearColor, title="Bear Zone Filling")

// ENGINE DIVERGENCE
float pHiOsc = ta.pivothigh(smoothCentered, pivotLookback, pivotLookback)
float pLoOsc = ta.pivotlow(smoothCentered, pivotLookback, pivotLookback)

// REGULAR BULLISH
bool regBull = false
int regBull_X1 = 0
if not na(pLoOsc)
    for i = minDivRange to maxDivRange
        if not na(pLoOsc[i]) and pLoOsc > pLoOsc[i] and low[pivotLookback] < low[pivotLookback + i]
            regBull := true
            regBull_X1 := i
            break

// REGULAR BEARISH
bool regBear = false
int regBear_X1 = 0
if not na(pHiOsc)
    for i = minDivRange to maxDivRange
        if not na(pHiOsc[i]) and pHiOsc < pHiOsc[i] and high[pivotLookback] > high[pivotLookback + i]
            regBear := true
            regBear_X1 := i
            break

// HIDDEN BULLISH
bool hidBull = false
int hidBull_X1 = 0
if not na(pLoOsc)
    for i = minDivRange to maxDivRange
        if not na(pLoOsc[i]) and pLoOsc < pLoOsc[i] and low[pivotLookback] > low[pivotLookback + i]
            hidBull := true
            hidBull_X1 := i
            break

// HIDDEN BEARISH
bool hidBear = false
int hidBear_X1 = 0
if not na(pHiOsc)
    for i = minDivRange to maxDivRange
        if not na(pHiOsc[i]) and pHiOsc > pHiOsc[i] and high[pivotLookback] < high[pivotLookback + i]
            hidBear := true
            hidBear_X1 := i
            break

if barstate.islast or barstate.isconfirmed
    // Regular Bullish Drawing
    if regBull and showRegularBull
        int x1_bar = bar_index - (regBull_X1 + pivotLookback)
        int x2_bar = bar_index - pivotLookback
        float y_val = smoothCentered[pivotLookback]
        
        line.new(x1=x1_bar, y1=smoothCentered[regBull_X1 + pivotLookback], x2=x2_bar, y2=y_val, color=regBullColor, width=2, style=line.style_solid)
        label.new(x=x2_bar, y=y_val, text="Bull", textcolor=color.white, xloc=xloc.bar_index, yloc=yloc.price, color=regBullColor, style=label.style_label_up, size=size.normal)
        
        if showChartLines
            line.new(x1=x1_bar, y1=low[regBull_X1 + pivotLookback], x2=x2_bar, y2=low[pivotLookback], color=regBullColor, width=2, style=line.style_solid, force_overlay=true)

    // Regular Bearish Drawing
    if regBear and showRegularBear
        int x1_bar = bar_index - (regBear_X1 + pivotLookback)
        int x2_bar = bar_index - pivotLookback
        float y_val = smoothCentered[pivotLookback]
        
        line.new(x1=x1_bar, y1=smoothCentered[regBear_X1 + pivotLookback], x2=x2_bar, y2=y_val, color=regBearColor, width=2, style=line.style_solid)
        label.new(x=x2_bar, y=y_val, text="Bear", textcolor=color.white, xloc=xloc.bar_index, yloc=yloc.price, color=regBearColor, style=label.style_label_down, size=size.normal)
        
        if showChartLines
            line.new(x1=x1_bar, y1=high[regBear_X1 + pivotLookback], x2=x2_bar, y2=high[pivotLookback], color=regBearColor, width=2, style=line.style_solid, force_overlay=true)

    // Hidden Bullish Drawing
    if hidBull and showHiddenBull
        int x1_bar = bar_index - (hidBull_X1 + pivotLookback)
        int x2_bar = bar_index - pivotLookback
        float y_val = smoothCentered[pivotLookback]
        
        line.new(x1=x1_bar, y1=smoothCentered[hidBull_X1 + pivotLookback], x2=x2_bar, y2=y_val, color=hidBullColor, width=1, style=line.style_dashed)
        label.new(x=x2_bar, y=y_val, text="H-Bull", textcolor=color.white, xloc=xloc.bar_index, yloc=yloc.price, color=hidBullColor, style=label.style_label_up, size=size.normal)
        
        if showChartLines
            line.new(x1=x1_bar, y1=low[hidBull_X1 + pivotLookback], x2=x2_bar, y2=low[pivotLookback], color=hidBullColor, width=1, style=line.style_dashed, force_overlay=true)

    // Hidden Bearish Drawing
    if hidBear and showHiddenBear
        int x1_bar = bar_index - (hidBear_X1 + pivotLookback)
        int x2_bar = bar_index - pivotLookback
        float y_val = smoothCentered[pivotLookback]
        
        line.new(x1=x1_bar, y1=smoothCentered[hidBear_X1 + pivotLookback], x2=x2_bar, y2=y_val, color=hidBearColor, width=1, style=line.style_dashed)
        label.new(x=x2_bar, y=y_val, text="H-Bear", textcolor=color.white, xloc=xloc.bar_index, yloc=yloc.price, color=hidBearColor, style=label.style_label_down, size=size.normal)
        
        if showChartLines
            line.new(x1=x1_bar, y1=high[hidBear_X1 + pivotLookback], x2=x2_bar, y2=high[pivotLookback], color=hidBearColor, width=1, style=line.style_dashed, force_overlay=true)
````
