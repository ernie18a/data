# AI K-Means Clustering [TradingFinder] Machine Learning Zones

- url: https://www.tradingview.com/script/UVPTN1ae-AI-K-Means-Clustering-TradingFinder-Machine-Learning-Zones/
- type: indicator
- pine_id: PUB;555c6975886c4da290fcb871497173c4
- version: 1.0

## Description

🔵[b]Introduction[/b]

K-Means clustering is an unsupervised machine learning algorithm that groups similar data points around repeatedly updated cluster centers. Each observation is assigned to its nearest center, the centers are recalculated, and the process continues until the clusters converge. In financial market analysis, this structure can separate recurring patterns in price movement, trend direction, volume pressure, and volatility without depending entirely on fixed thresholds. As a result, the same candle may be interpreted differently in a quiet market, a directional trend, or a volatility shock, because its meaning is evaluated in relation to the surrounding market data.

This TradingView indicator applies K-Means machine learning through several connected analysis modules. The Market State engine studies trend bias, price slope, and relative volume pressure to classify the current market regime as an active bullish trend, active bearish trend, soft bullish trend, soft bearish trend, neutral range, or low-volume range. It also compares the current cluster with the dominant cluster across recent candles, helping the trend classification remain more stable when a single large candle, temporary spike, or short-lived price reversal appears.

[image]https://www.tradingview.com/x/dHTmfO9j/[/image]

The Price Zones engine clusters pivot points, historical highs, and historical lows to create dynamic K-Means support and resistance zones. Traders can display all price cluster centers, the nearest K-Means zone, or separate support and resistance lines. Raw, Smooth, and Locked Steps modes control how quickly the zones respond to new price data, while the nearest line changes color according to the detected bullish, bearish, or ranging market state. A Stochastic moving average heatmap is also plotted between the outer zones, adding a visual layer for momentum, overbought and oversold conditions, trend strength, and changing market pressure.

The indicator also combines volatility analysis, price action recognition, cluster quality scoring, and alert conditions. The volatility engine uses normalized ATR, candle range, and return volatility to identify low-volatility compression, normal volatility, high volatility, and volatility shock. The Price Action module evaluates the latest closed candle for bullish and bearish zone breakouts, rejection patterns, momentum candles, and indecision near a clustered price level. A dedicated Quality and Reliability section then measures zone strength, cluster fit, zone width, price distance, and RMSE, helping traders understand whether the current machine learning calculations are strong enough for practical analysis or should be treated only as additional market context. 


🔵[b]How to Use[/b]

The easiest way to read this indicator is not to search for one isolated green or red message. Its main value comes from combining several layers of market information: K-Means market state classification, adaptive price zones, price action, volatility conditions, and calculation quality. Each module answers a different question, and the strongest setups usually appear when several modules point in the same direction.

Start with the Market State row in the analysis table. This module applies multidimensional K-Means clustering to trend bias, trend slope, and relative volume pressure. The current cluster shows where the latest market data has been assigned, while the dominant cluster represents the most frequent cluster across the selected state window. The Strength value shows how dominant that cluster is within the recent sample.

[i]The Market State analysis can return the following conditions[/i]:

[list]
[*][i]Active Bullish Trend[/i]: Positive trend structure supported by stronger relative volume.
[*][i]Soft Bullish Trend[/i]: Positive directional structure, but with weaker participation or less convincing momentum.
[image]https://www.tradingview.com/x/ljdtaDkv/[/image]
[*][i]Active Bearish Trend[/i]: Negative trend structure supported by stronger relative volume.
[*][i]Soft Bearish Trend[/i]: Bearish directional structure that still requires confirmation.
[image]https://www.tradingview.com/x/uVUVSGTg/[/image]
[*][i]Neutral Range[/i]: Trend bias and slope are not strong enough to define a clear direction.
[image]https://www.tradingview.com/x/BSR9Ql8U/[/image]
[*][i]Low-Volume Range[/i]: Sideways structure accompanied by relatively weak volume participation.
[image]https://www.tradingview.com/x/8mvKg63f/[/image]
[image]https://www.tradingview.com/x/4TBIuhnv/[/image]
[/list]



The distinction between the current and dominant cluster is important. A single large candle can move the current data point into another cluster, but the dominant state may remain unchanged if the broader recent structure still belongs to the previous market regime. This can help prevent every temporary spike, pullback, or abnormal candle from being interpreted as a complete trend reversal.

The next section is Price Zones. Here, K-Means clustering is applied to historical pivot levels, sampled highs, and sampled lows. Instead of drawing a level from only one swing point, the algorithm groups similar historical prices and calculates a center for each price cluster. These cluster centers become adaptive K-Means price zones that may act as support, resistance, breakout references, or reaction areas.

[image]https://www.tradingview.com/x/VGUZtct2/[/image]

[i]The table displays[/i]:

[list]
[*][i]Near[/i]: The cluster currently closest to price.
[*][i]Strength[/i]: The percentage of sampled price levels assigned to the nearest cluster.
[*][i]Nearest[/i]: The closest stabilized K-Means zone.
[*][i]Support[/i]: The nearest valid cluster center below the market.
[*][i]Resistance[/i]: The nearest valid cluster center above the market.
[/list]

A higher Zone Strength means a larger share of the sampled levels belongs to that cluster. However, this should not be interpreted as a guaranteed support or resistance level. It simply shows that more historical observations were grouped around the same price area.

On the chart, users can choose between three visual approaches. Show All K-Means Zone Centers plots the complete set of clustered price levels. Show Nearest Zone displays only the closest stabilized level, while Show K-Means Support/Resistance plots the nearest support and resistance separately. 

[i]The nearest line changes color with the detected market state[/i]:

[list]
[*]Green indicates a bullish market state.
[*]Red indicates a bearish market state.
[*]Blue indicates a neutral or ranging market state.
[/list]

The zone lines can also be displayed in Raw, Smooth, or Locked Steps mode. Raw mode follows newly calculated cluster centers directly. Smooth mode gradually moves the plotted level toward the new center, creating a more stable visual structure. Locked Steps mode keeps the previous level in place until the new cluster center has moved by a meaningful ATR-based distance.

Between the outer K-Means zones, the indicator draws a Stochastic Moving Average Heatmap. This heatmap is based on a 100-period Stochastic value smoothed with a 50-period exponential moving average. Lower smoothed Stochastic values appear toward the blue and purple side of the color range, middle values move through cyan and green, and higher values progress toward yellow, orange, and red. The heatmap should be read as a visual momentum layer rather than as a standalone buy or sell signal.

[image]https://www.tradingview.com/x/onXC053W/[/image]

[image]https://www.tradingview.com/x/igNOKb2B/[/image]

[image]https://www.tradingview.com/x/HvTvA22H/[/image]

[image]https://www.tradingview.com/x/3ERptH0R/[/image]

The Price Action row studies candle structure in relation to the nearest K-Means zone and recent price behavior. It uses the candle body, upper wick, lower wick, previous high, previous low, and the location of the nearest zone to identify several possible conditions:

[list]
[*]Bullish or bearish zone breakout.
[*]Bullish or bearish rejection from a zone.
[*]Bullish or bearish momentum candle.
[*]Indecision at a K-Means zone.
[*]General indecision.
[*]No clear price action.
[/list]


The Body, Upper Wick Ratio, and Lower Wick Ratio values represent the relative size of the candle body, upper wick, and lower wick compared with the candle’s total range. These values help explain why the indicator classified a candle as momentum, rejection, or indecision. Price Action should always be read together with Market State and Volatility. For example, a bullish momentum candle inside a bearish market state does not automatically create a bullish setup.

The Volatility module runs a separate K-Means model using normalized ATR, candle range percentage, and return volatility. The clustered volatility data is then used to identify four practical market conditions:

[list]
[*][i]Low Volatility Compression[/i]: Market movement has contracted and a future expansion may develop;
[*][i]Normal Volatility[/i]: Current movement is close to its recent reference level;
[*][i]High Volatility[/i]: Price movement is elevated and may require smaller position size or wider risk parameters;
[*][i]Volatility Shock[/i]: Abnormal expansion is present, making immediate entries more sensitive to slippage, unstable movement, and rapid reversals.
[/list]

[image]https://www.tradingview.com/x/2KB3F1Yz/[/image]

Volatility acts as a risk filter for the rest of the analysis. Even when Market State and Price Action point in the same direction, a High Volatility or Volatility Shock reading should reduce the confidence placed on an immediate entry.

Finally, review the Quality row. This section provides an internal assessment of how compact, representative, and consistent the current K-Means calculations are. It does not measure future profitability or win rate. Instead, it evaluates the statistical structure of the active price clusters.



[i]The main values include[/i]:

[list]
[*][i]Price Q[/i]: A combined score based on zone strength, width, fit, and price distance;
[*][i]Trust[/i]: A weighted score combining price-zone quality, market-state dominance, and volatility-cluster dominance;
[*][i]Fit RMSE[/i]: The normalized root mean squared error of the price clusters;
[*][i]Width[/i]: The average dispersion of the nearest cluster around its center;
[*][i]Reliability[/i]: A descriptive grade derived from the internal Trust score.
[/list]

A narrow cluster with reasonable strength and lower fitting error will usually receive a better score than a wide, weak, or poorly fitted cluster. Use this section to decide how much weight should be given to the current analysis. A weak Quality score does not make the chart unusable, but it suggests that the levels and classifications should be treated as secondary context.

[image]https://www.tradingview.com/x/MgXqoaKR/[/image]

[image]https://www.tradingview.com/x/ozPnTpkc/[/image]


🟣[b]Bullish Market Reading[/b]

A bullish setup becomes more meaningful when the market state, K-Means zones, candle behavior, volatility, and quality readings support the same interpretation.

[image]https://www.tradingview.com/x/bRxuEbqC/[/image]

[list]
[*][i]Check the Market State first[/i]: An Active Bullish Trend indicates stronger bullish structure and relative participation. A Soft Bullish Trend still favors the upside, but entries should normally wait for additional confirmation.
[*][i]Locate price relative to the nearest zone[/i]: When price is above the nearest K-Means zone, that level may become an adaptive support reference. A pullback toward the green nearest-zone line can be watched for continuation or rejection behavior.
[*][i]Look for bullish price action[/i]: A Bullish Rejection From Zone suggests that price tested a clustered level and closed with a stronger lower-wick reaction. A Bullish Zone Breakout shows that the candle crossed above the zone with a sufficiently large body. A Bullish Momentum Candle confirms upward pressure, but it is more useful when the Market State is already bullish.
[*][i]Use the support line as a reference, not an automatic entry[/i]: The K-Means support level can help define the area where bullish structure remains valid. A decisive move below it may weaken the long scenario, especially if the Market State also changes.
[*][i]Confirm volatility conditions[/i]: Normal Volatility is generally easier to manage than High Volatility or Volatility Shock. During compression, traders may wait for a confirmed breakout rather than entering before expansion begins.
[*][i]Review Quality and Reliability[/i]: Stronger Quality, Trust, and Zone Strength readings increase the internal consistency of the analysis. Weak scores suggest that the zone may be broad, poorly fitted, or based on a less concentrated cluster.
[/list]

A practical bullish sequence may therefore look like this: the table shows a Soft or Active Bullish Trend, price remains above or retests a green K-Means zone, a bullish rejection or breakout appears, volatility is not classified as a shock, and Quality remains acceptable. None of these elements guarantees continuation, but their alignment creates a clearer bullish context than any single reading alone.


🟣[b]Bearish Market Reading[/b]

Bearish analysis follows the same process in reverse. The objective is to identify whether downward market structure, clustered resistance, candle behavior, and volatility are supporting the same scenario.

[image]https://www.tradingview.com/x/1Ok3UKAB/[/image]

[list]
[*][i]Begin with the Market State[/i]: An Active Bearish Trend represents stronger negative bias, slope, and relative volume pressure. A Soft Bearish Trend favors short-side analysis but still requires confirmation before treating the move as established.
[*][i]Observe price relative to the nearest zone[/i]: When price is below the nearest K-Means zone, that level may act as an adaptive resistance reference. A return toward the red nearest-zone line can be monitored for rejection or continuation.
[*][i]Wait for bearish price action[/i]: A Bearish Rejection From Zone appears when price tests a clustered area and forms a stronger upper-wick reaction. A Bearish Zone Breakout indicates that price has crossed below the zone with a sufficiently large bearish body. A Bearish Momentum Candle carries more weight when the broader Market State is already bearish.
[*][i]Use the resistance line to define context[/i]: The K-Means resistance level can help identify where bearish continuation remains structurally reasonable. A sustained break above it may weaken the short scenario, particularly if Market State also shifts toward bullish or neutral conditions.
[*][i]Do not ignore volatility warnings[/i]: A bearish candle during Volatility Shock may be followed by a sharp continuation, but it can also produce rapid retracement and unstable execution. In this condition, the indicator explicitly favors additional confirmation or reduced risk.
[*][i]Check cluster quality before relying on the level[/i]: A weak or wide price cluster may produce a less precise resistance reference. Higher Quality and Reliability readings indicate a more compact and internally consistent zone, not a guaranteed bearish outcome.
[/list]

A clearer bearish sequence may include a Soft or Active Bearish Trend, price trading below or retesting a red K-Means zone, bearish rejection or breakout behavior, manageable volatility, and an acceptable Quality score. When these components disagree, for example, a bullish momentum candle inside a bearish trend, the table should be read as a warning that momentum alone is not enough to confirm a reversal.

The built-in alert conditions can be used to monitor bullish and bearish K-Means zone breakouts and rejections. Alerts are most useful as notifications that a specific price-action condition has appeared; the final interpretation should still include Market State, Volatility, zone position, and Quality before any trading decision is made.


🔵[b]Settings[/b]

🟣[b]K-Means Engine Settings[/b]

[i]Market State Lookback[/i]: Number of recent bars used to cluster trend bias, slope, and relative volume for market-state classification.

[i]Price Zone Lookback[/i]: Number of recent bars used to build K-Means price zones from pivots, highs, and lows.

[i]Volatility Lookback[/i]: Number of recent bars used to cluster ATR percentage, candle range, and return volatility.

[i]Market State Clusters[/i]: Number of clusters used by the Market State model.

[i]Price Zone Clusters[/i]: Number of price clusters used to calculate adaptive zone centers.

[i]Volatility Clusters[/i]: Number of clusters used by the Volatility model.

[i]Max K-Means Iterations[/i]: Maximum number of center-update cycles allowed during each clustering calculation.

[i]Dominant State Window[/i]: Number of recent cluster assignments used to determine the dominant market state.

[i]Fast Volatility State Window[/i]: Number of recent volatility assignments used to determine the dominant short-term volatility cluster.

[i]Convergence Tolerance[/i]: Minimum center movement required to continue the K-Means iteration; lower values increase precision but may require more processing.

🟣[b]Price Zone Settings[/b]

[i]Pivot Length[/i]: Number of bars used on each side of a candle to confirm pivot highs and pivot lows.

[i]High/Low Sampling Step[/i]: Controls how frequently historical highs and lows are added to the price-zone dataset; lower values use more samples.

[i]Minimum Near-Zone Distance (%)[/i]: Minimum percentage distance used to classify price as testing a K-Means zone.

🟣[b]Execution Control Settings[/b]

[i]Historical Calculation Bars[/i]: Number of recent historical bars on which calculations and visual outputs are processed.

[i]Refresh Every N Bars[/i]: Runs the main K-Means modules once every selected number of bars and always updates them on the latest bar.

🟣[b]Zone Stabilizer Settings[/b]

[i]Zone Plot Mode[/i]: Selects how zone lines are displayed: Raw follows new centers directly, Smooth moves gradually, and Locked Steps updates only after a meaningful price shift.

[i]Zone Smooth Length[/i]: Controls the smoothing speed in Smooth mode; higher values produce slower and more stable zone movement.

[i]Zone Lock ATR Multiplier[/i]: Defines the minimum ATR-based movement required before a zone updates in Locked Steps mode.

[i]Nearest Zone Switch Margin ATR[/i]: Prevents frequent switching between nearby zones by requiring the new zone to be closer by an ATR-based margin.

🟣[b]Display Settings[/b]

[i]Show Analysis Table[/i]: Shows or hides the market analysis table.

[i]Table Text Size[/i]: Sets the size used inside the table.

[i]Table Position[/i]: Selects the table location on the chart.

[i]Show All K-Means Zone Centers[/i]: Displays all calculated K-Means price-zone centers.

[i]Show Nearest Zone[/i]: Displays the stabilized zone closest to the current price, colored by the detected market state.

[i]Show K-Means Support/Resistance[/i]: Displays the nearest clustered support below price and resistance above price.


🔵[b]Conclusion[/b]

This indicator brings K-Means clustering, market state analysis, adaptive price zones, volatility classification, and price action context into one structured workflow. Instead of reducing the chart to a single signal, it separates the market into several readable layers: directional behavior, clustered support and resistance areas, candle reactions, volatility conditions, and the internal quality of the current calculations. This makes it easier to understand whether price is trending, ranging, testing a K-Means zone, reacting to a clustered level, or moving through an unstable volatility phase.

Its strongest use comes from confirmation rather than prediction. A bullish or bearish reading becomes more meaningful when the Market State, nearest K-Means zone, Price Action module, Volatility analysis, and Quality score support the same scenario. When these components disagree, the table highlights that uncertainty instead of hiding it. Used this way, the tool works as a machine learning market analysis framework that helps organize recent price data, compare changing market regimes, and identify areas where further confirmation is still required.

## Source Code

````pine

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingFinder
//@version=6

indicator("AI K-Means Clustering [TradingFinder] Machine Learning Zones", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=5000)


//K-Means Engine Settings

MarketStateLookback  = input.int(120, "Market State Lookback", minval = 50, maxval = 500, group = "K-Means Engine Settings")
zoneLookback         = input.int(180, "Price Zone Lookback", minval = 50, maxval = 700, group = "K-Means Engine Settings")
volLookback          = input.int(60, "Volatility Lookback", minval = 30, maxval = 500, group = "K-Means Engine Settings")
MarketStateK         = input.int(3, "Market State Clusters", minval = 2, maxval = 5, group = "K-Means Engine Settings")
zoneK                = input.int(5, "Price Zone Clusters", minval = 2, maxval = 5, group = "K-Means Engine Settings")
volK                 = input.int(4, "Volatility Clusters", minval = 2, maxval = 5, group = "K-Means Engine Settings")
maxIterations        = input.int(12, "Max K-Means Iterations", minval = 3, maxval = 30, group = "K-Means Engine Settings")
stateWindow          = input.int(25, "Dominant State Window", minval = 5, maxval = 100, group = "K-Means Engine Settings")
volStateWindow       = input.int(5, "Fast Volatility State Window", minval = 1, maxval = 25, group = "K-Means Engine Settings")
convergenceTolerance = input.float(0.0001, "Convergence Tolerance", step = 0.0001, group = "K-Means Engine Settings")


//Price Zone Settings

pivotLen             = input.int(5, "Pivot Length", minval = 2, maxval = 20, group = "Price Zone Settings")
zoneStep             = input.int(4, "High/Low Sampling Step", minval = 1, maxval = 20, group = "Price Zone Settings")
nearZonePctInput     = input.float(0.10, "Minimum Near-Zone Distance (%)", minval = 0.01, maxval = 2.00, step = 0.01, group = "Price Zone Settings")
nearZonePct          = nearZonePctInput / 100.0


//Execution Control Settings

histCalcBars         = input.int(900, "Historical Calculation Bars", minval = 200, maxval = 1500, group = "Execution Control Settings")
refreshEvery         = input.int(10, "Refresh Every N Bars", minval = 1, maxval = 50, group = "Execution Control Settings")


//Zone Stabilizer Settings

zonePlotMode         = input.string("Smooth", "Zone Plot Mode", options=["Raw", "Smooth", "Locked Steps"], group = "Zone Stabilizer Settings")
zoneSmoothLen        = input.int(21, "Zone Smooth Length", minval = 1, maxval = 1000, group = "Zone Stabilizer Settings")
zoneLockAtrMult      = input.float(0.20, "Zone Lock ATR Multiplier", minval = 0.01, maxval = 2.00, step = 0.01, group = "Zone Stabilizer Settings")
nearestSwitchAtrMult = input.float(0.25, "Nearest Zone Switch Margin ATR", minval = 0.01, maxval = 2.00, step = 0.01, group = "Zone Stabilizer Settings")


//Display Settings

showTable             = input.bool(true, "Show Analysis Table", group = "Display Settings")
Size                  = input.string(size.small , 'Table Text Size' , options = [size.small, size.normal, size.large], group = "Display Settings")
Position              = input.string(position.top_right, 'Table Position', options = [position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_center, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], group = "Display Settings")

showAllZones          = input.bool(true, "Show All K-Means Zone Centers", group = "Display Settings")
showNearestZone       = input.bool(false, "Show Nearest Zone", group = "Display Settings")
showSupportResistance = input.bool(false, "Show K-Means Support/Resistance", group = "Display Settings")


//Result Variables


var int MarketStateCurrentCluster = -1
var int MarketStateDominantCluster = -1

var float MarketStateCenterBias = na
var float MarketStateCenterSlope = na
var float MarketStateCenterVolume = na

var float MarketStateCurrentBias = na
var float MarketStateCurrentSlope = na
var float MarketStateCurrentVolume = na

var float MarketStateDominance = na
var float MarketStateSse = na

var int volCurrentCluster = -1
var int volDominantCluster = -1

var float centerAtr = na
var float centerRange = na
var float centerRetVol = na

var float currentAtr = na
var float currentRange = na
var float currentRetVol = na

var float volDominance = na
var float volSse = na

var int zoneCluster = -1

var float nearestZone = na
var float supportZone = na
var float resistanceZone = na

var float zoneDistPct = na
var float zoneSpreadPct = na
var float zoneStrength = na
var float zoneWidthPct = na
var float zoneSse = na

var float zone1 = na
var float zone2 = na
var float zone3 = na
var float zone4 = na
var float zone5 = na

var float plotZone1 = na
var float plotZone2 = na
var float plotZone3 = na
var float plotZone4 = na
var float plotZone5 = na

var float nearestStableTarget = na
var float plotNearestZone = na
var float plotSupportZone = na
var float plotResistanceZone = na

var string MarketStateTxt = "Not Enough Data"
var string MarketStateUse = "Wait"

var string zoneTxt = "Not Enough Data"
var string zoneUse = "Wait for reaction"

var string volTxt = "Not Enough Data"
var string volUse = "Normal system conditions"

var string priceActionTxt = "No Clear Price Action"
var string priceActionUse = "Observation only"

var float paBodyRatio = na
var float paUpperRatio = na
var float paLowerRatio = na


var float zoneRmsePct = na
var float zoneFitScore = na
var float zoneStrengthScore = na
var float zoneWidthScore = na
var float zoneDistanceScore = na
var float priceQualityScore = na
var float calculationTrustScore = na

var string qualityTxt = "Not Enough Data"
var string trustTxt = "Not Enough Data"
var string qualityUse = "Not enough data"



//Sub-functions

Mean(array<float> a) =>
    int n = array.size(a)
    float sum = 0.0

    if n == 0
        na
    else
        for i = 0 to n - 1
            sum += array.get(a, i)

        sum / n


STDEV(array<float> a, float mean) =>
    int n = array.size(a)
    float sumSq = 0.0

    if n <= 1 or na(mean)
        1.0
    else
        for i = 0 to n - 1
            float v = array.get(a, i)
            sumSq += math.pow(v - mean, 2)

        float stdev = math.sqrt(sumSq / n)
        stdev == 0.0 ? 1.0 : stdev

DistancetoCenter_nD(float x, float y, float z, float cx, float cy, float cz, bool useY, bool useZ) =>
    float dx = x - cx
    float dy = useY ? y - cy : 0.0
    float dz = useZ ? z - cz : 0.0

    dx * dx + dy * dy + dz * dz

Fmt(float v) =>
    na(v) ? "n/a" : str.tostring(v, "#.####")


Pct(float v) =>
    na(v) ? "n/a" : str.tostring(v * 100.0, "#.###") + "%"


Price(float v) =>
    na(v) ? "n/a" : str.tostring(v, format.mintick)


Label(int v) =>
    v < 0 ? "n/a" : str.tostring(v)


BG_Color(string txt) =>
    color c = #adbcff

    if str.contains(txt, "Bullish") or str.contains(txt, "Above")
        c  := #02b305
    else if str.contains(txt, "Bearish") or str.contains(txt, "Below")
        c  := color.rgb(236, 0, 47)
    else if str.contains(txt, "Shock") or str.contains(txt, "Avoid") or str.contains(txt, "Danger")
        c  := #ff9800
    else if str.contains(txt, "Range") or str.contains(txt, "Neutral") or str.contains(txt, "Indecision")
        c  := color.rgb(0, 225, 255)
    c

//Quality & Reliability

Clamp_Float(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))


Score_Lower(float value, float badLimit) =>
    float score = na

    if not na(value) and not na(badLimit) and badLimit > 0.0
        score := Clamp_Float(100.0 * (1.0 - value / badLimit), 0.0, 100.0)
    score

Score_Higher(float value, float goodLimit) =>
    float score = na

    if not na(value) and not na(goodLimit) and goodLimit > 0.0
        score := Clamp_Float(100.0 * value / goodLimit, 0.0, 100.0)
    score

Score_Grade(float score) =>
    string txt = "Not Enough Data"

    if not na(score)
        if score >= 80.0
            txt := "Excellent"
        else if score >= 65.0
            txt := "Good"
        else if score >= 50.0
            txt := "Moderate"
        else if score >= 35.0
            txt := "Weak"
        else
            txt := "Poor"
    txt

Trust_Grade(float score) =>
    string txt = "Not Enough Data"

    if not na(score)
        if score >= 80.0
            txt := "Very Reliable"
        else if score >= 65.0
            txt := "Reliable"
        else if score >= 50.0
            txt := "Semi-Reliable"
        else if score >= 35.0
            txt := "Low Reliability"
        else
            txt := "Unreliable"
    txt

Quality_Use(float qualityScore, float trustScore) =>
    string use = "Not enough data"

    if not na(qualityScore) and not na(trustScore)
        if qualityScore >= 75.0 and trustScore >= 75.0
            use := "High confidence; calculations are dependable"
        else if qualityScore >= 60.0 and trustScore >= 60.0
            use := "Usable; confirm with price action"
        else if qualityScore >= 45.0 and trustScore >= 50.0
            use := "Medium confidence; reduce risk"
        else if trustScore >= 35.0
            use := "Low confidence; context only"
        else
            use := "Do not rely on calculations"
    use


Score_BG(float score) =>
    color c = #3f424f

    if not na(score)
        if score >= 80.0
            c := #02b305
        else if score >= 65.0
            c := #28bd2d
        else if score >= 50.0
            c := #0a85e9
        else if score >= 35.0
            c := #ff9800
        else
            c := #fc1d1d
    c

Stabilize_Zone(float raw, float prev, string mode, int len, float atrAbs, float lockMult) =>
    float out = prev

    if na(raw)
        out := prev
    else if na(prev)
        out := raw
    else if mode == "Raw"
        out := raw
    else if mode == "Smooth"
        float alpha = 2.0 / (len + 1.0)
        out := prev + alpha * (raw - prev)
    else
        float minMove = math.max(syminfo.mintick, atrAbs * lockMult)
        out := math.abs(raw - prev) >= minMove ? raw : prev
    out


Stable_Nearest(float raw, float prev, float price, float atrAbs, float marginMult) =>
    float out = prev

    if na(raw)
        out := prev
    else if na(prev)
        out := raw
    else
        float prevDist = math.abs(price - prev)
        float rawDist = math.abs(price - raw)
        float margin = math.max(syminfo.mintick, atrAbs * marginMult)

        out := rawDist + margin < prevDist ? raw : prev
    out



// Complete 3D K-MEANS Engine

Kmeans_3D(float fx, float fy, float fz, bool useY, bool useZ, int lb, int k, int maxIter, int recentWindow, float tolerance) =>
    array<float> rawX = array.new_float()
    array<float> rawY = array.new_float()
    array<float> rawZ = array.new_float()

    int safeLookback = math.min(lb, bar_index + 1)

    for i = 0 to safeLookback - 1
        float xVal = fx[i]
        float yVal = fy[i]
        float zVal = fz[i]

        bool okX = not na(xVal)
        bool okY = not useY or not na(yVal)
        bool okZ = not useZ or not na(zVal)

        if okX and okY and okZ
            array.push(rawX, xVal)
            array.push(rawY, useY ? yVal : 0.0)
            array.push(rawZ, useZ ? zVal : 0.0)

    int n = array.size(rawX)

    int currentLabel = -1
    int dominantLabel = -1

    float domX = na
    float domY = na
    float domZ = na

    float curX = na
    float curY = na
    float curZ = na

    float dominance = na
    float finalSse = na

    if n >= k
        float meanX = Mean(rawX)
        float meanY = Mean(rawY)
        float meanZ = Mean(rawZ)

        float stdX = STDEV(rawX, meanX)
        float stdY = STDEV(rawY, meanY)
        float stdZ = STDEV(rawZ, meanZ)

        array<float> xs = array.new_float()
        array<float> ys = array.new_float()
        array<float> zs = array.new_float()

        for i = 0 to n - 1
            float x = array.get(rawX, i)
            float y = array.get(rawY, i)
            float z = array.get(rawZ, i)

            array.push(xs, (x - meanX) / stdX)
            array.push(ys, useY ? (y - meanY) / stdY : 0.0)
            array.push(zs, useZ ? (z - meanZ) / stdZ : 0.0)

        array<float> centerX = array.new_float(k, 0.0)
        array<float> centerY = array.new_float(k, 0.0)
        array<float> centerZ = array.new_float(k, 0.0)
        array<int> labels = array.new_int(n, 0)

        int firstIdx = 0
        float firstDist = na

        for i = 0 to n - 1
            float d = DistancetoCenter_nD(
                 array.get(xs, i),
                 array.get(ys, i),
                 array.get(zs, i),
                 0.0,
                 0.0,
                 0.0,
                 useY,
                 useZ
            )

            if na(firstDist) or d < firstDist
                firstDist := d
                firstIdx := i

        array.set(centerX, 0, array.get(xs, firstIdx))
        array.set(centerY, 0, array.get(ys, firstIdx))
        array.set(centerZ, 0, array.get(zs, firstIdx))

        for c = 1 to k - 1
            int farIdx = 0
            float farScore = na

            for i = 0 to n - 1
                float x = array.get(xs, i)
                float y = array.get(ys, i)
                float z = array.get(zs, i)

                float nearestExisting = na

                for pc = 0 to c - 1
                    float d = DistancetoCenter_nD(
                         x,
                         y,
                         z,
                         array.get(centerX, pc),
                         array.get(centerY, pc),
                         array.get(centerZ, pc),
                         useY,
                         useZ
                    )

                    if na(nearestExisting) or d < nearestExisting
                        nearestExisting := d

                if na(farScore) or nearestExisting > farScore
                    farScore := nearestExisting
                    farIdx := i

            array.set(centerX, c, array.get(xs, farIdx))
            array.set(centerY, c, array.get(ys, farIdx))
            array.set(centerZ, c, array.get(zs, farIdx))

        for iter = 0 to maxIter - 1
            for i = 0 to n - 1
                float x = array.get(xs, i)
                float y = array.get(ys, i)
                float z = array.get(zs, i)

                int bestCluster = 0
                float bestDist = na

                for c = 0 to k - 1
                    float d = DistancetoCenter_nD(
                         x,
                         y,
                         z,
                         array.get(centerX, c),
                         array.get(centerY, c),
                         array.get(centerZ, c),
                         useY,
                         useZ
                    )

                    if na(bestDist) or d < bestDist
                        bestDist := d
                        bestCluster := c

                array.set(labels, i, bestCluster)

            float centerShift = 0.0

            for c = 0 to k - 1
                float sumX = 0.0
                float sumY = 0.0
                float sumZ = 0.0
                int count = 0

                for i = 0 to n - 1
                    if array.get(labels, i) == c
                        sumX += array.get(xs, i)
                        sumY += array.get(ys, i)
                        sumZ += array.get(zs, i)
                        count += 1

                float oldX = array.get(centerX, c)
                float oldY = array.get(centerY, c)
                float oldZ = array.get(centerZ, c)

                if count > 0
                    float newX = sumX / count
                    float newY = sumY / count
                    float newZ = sumZ / count

                    centerShift += DistancetoCenter_nD(newX, newY, newZ, oldX, oldY, oldZ, useY, useZ)

                    array.set(centerX, c, newX)
                    array.set(centerY, c, newY)
                    array.set(centerZ, c, newZ)
                else
                    int idx = int(math.round(c * (n - 1) / math.max(k - 1, 1)))

                    float newX = array.get(xs, idx)
                    float newY = array.get(ys, idx)
                    float newZ = array.get(zs, idx)

                    centerShift += DistancetoCenter_nD(newX, newY, newZ, oldX, oldY, oldZ, useY, useZ)

                    array.set(centerX, c, newX)
                    array.set(centerY, c, newY)
                    array.set(centerZ, c, newZ)

            if centerShift <= tolerance
                break

        float sse = 0.0

        for i = 0 to n - 1
            float x = array.get(xs, i)
            float y = array.get(ys, i)
            float z = array.get(zs, i)

            int bestCluster = 0
            float bestDist = na

            for c = 0 to k - 1
                float d = DistancetoCenter_nD(
                     x,
                     y,
                     z,
                     array.get(centerX, c),
                     array.get(centerY, c),
                     array.get(centerZ, c),
                     useY,
                     useZ
                )

                if na(bestDist) or d < bestDist
                    bestDist := d
                    bestCluster := c

            array.set(labels, i, bestCluster)
            sse += bestDist

        finalSse := sse / n
        currentLabel := array.get(labels, 0)

        array<int> clusterCounts = array.new_int(k, 0)
        int stateCount = math.min(recentWindow, n)

        for i = 0 to stateCount - 1
            int lab = array.get(labels, i)
            array.set(clusterCounts, lab, array.get(clusterCounts, lab) + 1)

        int bestCount = -1
        int bestCluster = -1

        for c = 0 to k - 1
            int cnt = array.get(clusterCounts, c)

            if cnt > bestCount
                bestCount := cnt
                bestCluster := c

        dominantLabel := bestCluster
        dominance := stateCount > 0 ? bestCount / stateCount : na

        if currentLabel >= 0
            curX := array.get(centerX, currentLabel) * stdX + meanX
            curY := array.get(centerY, currentLabel) * stdY + meanY
            curZ := array.get(centerZ, currentLabel) * stdZ + meanZ

        if dominantLabel >= 0
            domX := array.get(centerX, dominantLabel) * stdX + meanX
            domY := array.get(centerY, dominantLabel) * stdY + meanY
            domZ := array.get(centerZ, dominantLabel) * stdZ + meanZ

    [currentLabel,
         dominantLabel,
         domX,
         domY,
         domZ,
         curX,
         curY,
         curZ,
         dominance,
         finalSse]



//Complete 1D Price-Zone K-MEANS Engine

Kmeans_1D_Zones(float pivotLevel, float h, float l, float c, int lb, int k, int maxIter, float tolerance, int step) =>
    array<float> levels = array.new_float()

    int safeLookback = math.min(lb, bar_index + 1)

    for i = 0 to safeLookback - 1
        float p = pivotLevel[i]

        if not na(p)
            array.push(levels, p)

    for i = 0 to safeLookback - 1
        if i % step == 0
            float hi = h[i]
            float lo = l[i]

            if not na(hi)
                array.push(levels, hi)

            if not na(lo)
                array.push(levels, lo)

    if array.size(levels) < k
        for i = 0 to safeLookback - 1
            float cl = c[i]

            if not na(cl)
                array.push(levels, cl)

    int n = array.size(levels)

    int nearestCluster = -1
    float nearestZone = na
    float supportZone = na
    float resistanceZone = na
    float distancePct = na
    float spreadPct = na
    float nearestStrength = na
    float nearestWidthPct = na
    float finalSse = na

    float z0 = na
    float z1 = na
    float z2 = na
    float z3 = na
    float z4 = na

    if n >= k and not na(c) and c != 0.0
        array<float> sortedLevels = array.copy(levels)
        array.sort(sortedLevels, order.ascending)

        array<float> centers = array.new_float(k, 0.0)
        array<int> labels = array.new_int(n, 0)

        for cluster = 0 to k - 1
            int idx = int(math.round(cluster * (n - 1) / math.max(k - 1, 1)))
            array.set(centers, cluster, array.get(sortedLevels, idx))

        for iter = 0 to maxIter - 1
            for i = 0 to n - 1
                float level = array.get(levels, i)

                int bestCluster = 0
                float bestDist = na

                for cluster = 0 to k - 1
                    float center = array.get(centers, cluster)
                    float dist = math.pow(level - center, 2)

                    if na(bestDist) or dist < bestDist
                        bestDist := dist
                        bestCluster := cluster

                array.set(labels, i, bestCluster)

            float centerShift = 0.0

            for cluster = 0 to k - 1
                float sum = 0.0
                int count = 0

                for i = 0 to n - 1
                    if array.get(labels, i) == cluster
                        sum += array.get(levels, i)
                        count += 1

                float oldCenter = array.get(centers, cluster)

                if count > 0
                    float newCenter = sum / count
                    centerShift += math.pow(newCenter - oldCenter, 2)
                    array.set(centers, cluster, newCenter)
                else
                    int idx = int(math.round(cluster * (n - 1) / math.max(k - 1, 1)))
                    float newCenter = array.get(sortedLevels, idx)
                    centerShift += math.pow(newCenter - oldCenter, 2)
                    array.set(centers, cluster, newCenter)

            if centerShift <= tolerance
                break

        array.sort(centers, order.ascending)

        array<int> counts = array.new_int(k, 0)
        array<float> devSums = array.new_float(k, 0.0)

        float sse = 0.0

        for i = 0 to n - 1
            float level = array.get(levels, i)

            int bestCluster = 0
            float bestDist = na

            for cluster = 0 to k - 1
                float center = array.get(centers, cluster)
                float dist = math.pow(level - center, 2)

                if na(bestDist) or dist < bestDist
                    bestDist := dist
                    bestCluster := cluster

            array.set(labels, i, bestCluster)
            array.set(counts, bestCluster, array.get(counts, bestCluster) + 1)
            array.set(devSums, bestCluster, array.get(devSums, bestCluster) + math.abs(level - array.get(centers, bestCluster)))

            sse += bestDist

        finalSse := sse / n

        float bestPriceDist = na
        float bestSupportDist = na
        float bestResistanceDist = na

        float lowestCenter = array.get(centers, 0)
        float highestCenter = array.get(centers, k - 1)

        for cluster = 0 to k - 1
            float center = array.get(centers, cluster)
            float priceDist = math.abs(c - center)

            if na(bestPriceDist) or priceDist < bestPriceDist
                bestPriceDist := priceDist
                nearestCluster := cluster
                nearestZone := center

            if center <= c
                float supportDist = c - center

                if na(bestSupportDist) or supportDist < bestSupportDist
                    bestSupportDist := supportDist
                    supportZone := center

            if center >= c
                float resistanceDist = center - c

                if na(bestResistanceDist) or resistanceDist < bestResistanceDist
                    bestResistanceDist := resistanceDist
                    resistanceZone := center

        distancePct := not na(nearestZone) ? math.abs(c - nearestZone) / c : na
        spreadPct := (highestCenter - lowestCenter) / c

        if nearestCluster >= 0
            int nearestCount = array.get(counts, nearestCluster)
            float nearestDevSum = array.get(devSums, nearestCluster)

            nearestStrength := nearestCount / n
            nearestWidthPct := nearestCount > 0 ? (nearestDevSum / nearestCount) / c : na

        z0 := k >= 1 ? array.get(centers, 0) : na
        z1 := k >= 2 ? array.get(centers, 1) : na
        z2 := k >= 3 ? array.get(centers, 2) : na
        z3 := k >= 4 ? array.get(centers, 3) : na
        z4 := k >= 5 ? array.get(centers, 4) : na

    [nearestCluster,
         nearestZone,
         supportZone,
         resistanceZone,
         distancePct,
         spreadPct,
         nearestStrength,
         nearestWidthPct,
         finalSse,
         z0,
         z1,
         z2,
         z3,
         z4]


//Analysis Functions

MarketState_analysis(float centerBias, float centerSlope, float centerVolumePressure, float atrRef) =>
    string txt = "Not Enough Data"

    if not na(centerBias) and not na(centerSlope) and not na(centerVolumePressure) and not na(atrRef) and atrRef > 0.0
        float trendScore = centerBias * 0.65 + centerSlope * 0.35
        float threshold = atrRef * 0.15

        bool Bullish = trendScore > threshold
        bool bearish = trendScore < -threshold
        bool highVolume = centerVolumePressure > 1.25
        bool lowVolume = centerVolumePressure < 0.80

        if Bullish and highVolume
            txt := "Active Bullish Trend"
        else if bearish and highVolume
            txt := "Active Bearish Trend"
        else if Bullish
            txt := "Soft Bullish Trend"
        else if bearish
            txt := "Soft Bearish Trend"
        else if lowVolume
            txt := "Low-Volume Range"
        else
            txt := "Neutral Range"
    txt


MarketState_use(string txt) =>
    string use = "Wait"

    if txt == "Active Bullish Trend"
        use := "Prefer long continuation"
    else if txt == "Active Bearish Trend"
        use := "Prefer short continuation"
    else if txt == "Soft Bullish Trend"
        use := "Long only with confirmation"
    else if txt == "Soft Bearish Trend"
        use := "Short only with confirmation"
    else if txt == "Low-Volume Range" or txt == "Neutral Range"
        use := "Mean reversion / wait"
    use


Zone_Analysis(float price, float nearestZone, float distancePct, float supportZone, float resistanceZone, float atrPct) =>
    string txt = "Not Enough Data"

    if not na(nearestZone) and not na(distancePct) and not na(price) and price != 0.0
        float safeAtrPct = na(atrPct) ? nearZonePct : atrPct
        float dynamicNearPct = math.max(nearZonePct, safeAtrPct * 0.35)

        if distancePct <= dynamicNearPct
            txt := "Price Is Testing A K-Means Zone"
        else if price > nearestZone
            txt := "Price Is Above Nearest Zone"
        else
            txt := "Price Is Below Nearest Zone"
    txt


Zone_Use(string txt, float supportZone, float resistanceZone) =>
    string use = "Wait for reaction"

    if txt == "Price Is Testing A K-Means Zone"
        use := "Watch rejection or breakout"
    else if txt == "Price Is Above Nearest Zone"
        use := not na(supportZone) ? "Nearest zone may act as support" : "No valid support below"
    else if txt == "Price Is Below Nearest Zone"
        use := not na(resistanceZone) ? "Nearest zone may act as resistance" : "No valid resistance above"
    use


Vol_Analysis(float centerAtr, float atrRef) =>
    string txt = "Not Enough Data"

    if not na(centerAtr) and not na(atrRef) and atrRef > 0.0
        if centerAtr > atrRef * 1.65
            txt := "Volatility Shock"
        else if centerAtr > atrRef * 1.25
            txt := "High Volatility"
        else if centerAtr < atrRef * 0.75
            txt := "Low Volatility Compression"
        else
            txt := "Normal Volatility"
    txt


Vol_Use(string txt) =>
    string use = "Normal system conditions"

    if txt == "Volatility Shock"
        use := "Avoid entry or reduce risk"
    else if txt == "High Volatility"
        use := "Smaller size / wider stop"
    else if txt == "Low Volatility Compression"
        use := "Prepare for breakout"
    else if txt == "Normal Volatility"
        use := "Normal trading conditions"
    use


PriceActionAnalysis(float o, float h, float l, float c, float prevH, float prevL, float zone, float atrPct) =>
    string txt = "No Clear Price Action"

    float rng = h - l
    float body = math.abs(c - o)

    float upperWick = h - math.max(o, c)
    float lowerWick = math.min(o, c) - l

    float bodyRatio = rng > 0.0 ? body / rng : na
    float upperRatio = rng > 0.0 ? upperWick / rng : na
    float lowerRatio = rng > 0.0 ? lowerWick / rng : na

    bool bull = c > o
    bool bear = c < o

    float safeAtrPct = na(atrPct) ? nearZonePct : atrPct
    float dynamicZonePct = math.max(nearZonePct * 2.0, safeAtrPct * 0.40)

    bool validPrice = not na(c) and c != 0.0
    bool hasZone = not na(zone) and validPrice

    bool lowTouchedZone =
         hasZone ?
         (math.abs(l - zone) / c <= dynamicZonePct or (l <= zone and c > zone)) :
         false

    bool highTouchedZone =
         hasZone ?
         (math.abs(h - zone) / c <= dynamicZonePct or (h >= zone and c < zone)) :
         false

    bool closeNearZone =
         hasZone ?
         math.abs(c - zone) / c <= dynamicZonePct :
         false

    bool BullishRejection =
         bull and
         not na(lowerRatio) and
         not na(upperRatio) and
         not na(bodyRatio) and
         lowerRatio > 0.40 and
         lowerRatio > upperRatio and
         lowerRatio > bodyRatio * 0.80 and
         lowTouchedZone

    bool bearishRejection =
         bear and
         not na(lowerRatio) and
         not na(upperRatio) and
         not na(bodyRatio) and
         upperRatio > 0.40 and
         upperRatio > lowerRatio and
         upperRatio > bodyRatio * 0.80 and
         highTouchedZone

    bool BullishMomentum =
         bull and
         not na(bodyRatio) and
         not na(prevH) and
         bodyRatio > 0.55 and
         c > prevH

    bool bearishMomentum =
         bear and
         not na(bodyRatio) and
         not na(prevL) and
         bodyRatio > 0.55 and
         c < prevL

    bool BullishZoneBreak =
         hasZone and
         bull and
         not na(bodyRatio) and
         bodyRatio > 0.50 and
         o < zone and
         c > zone

    bool bearishZoneBreak =
         hasZone and
         bear and
         not na(bodyRatio) and
         bodyRatio > 0.50 and
         o > zone and
         c < zone

    bool indecision =
         not na(bodyRatio) and
         not na(upperRatio) and
         not na(lowerRatio) and
         bodyRatio < 0.25 and
         upperRatio > 0.25 and
         lowerRatio > 0.25

    if BullishZoneBreak
        txt := "Bullish Zone Breakout"
    else if bearishZoneBreak
        txt := "Bearish Zone Breakout"
    else if BullishRejection
        txt := "Bullish Rejection From Zone"
    else if bearishRejection
        txt := "Bearish Rejection From Zone"
    else if BullishMomentum
        txt := "Bullish Momentum Candle"
    else if bearishMomentum
        txt := "Bearish Momentum Candle"
    else if indecision and closeNearZone
        txt := "Indecision At Zone"
    else if indecision
        txt := "Indecision Candle"
    else
        txt := "No Clear Price Action"
    txt


PriceActionUse(string txt, string MarketStateTxt, string volTxt) =>
    string use = "Observation only"

    bool BullishMarketState = str.contains(MarketStateTxt, "Bullish")
    bool bearishMarketState = str.contains(MarketStateTxt, "Bearish")
    bool rangeMarketState = str.contains(MarketStateTxt, "Range") or str.contains(MarketStateTxt, "Neutral")
    bool dangerousVol = str.contains(volTxt, "Shock") or str.contains(volTxt, "High Volatility")

    if dangerousVol
        use := "Reduce risk; need extra confirmation"
    else if txt == "Bullish Zone Breakout"
        use := BullishMarketState ? "Bullish continuation likely" : "Wait for Bullish pullback"
    else if txt == "Bearish Zone Breakout"
        use := bearishMarketState ? "Bearish continuation likely" : "Wait for bearish pullback"
    else if txt == "Bullish Rejection From Zone"
        use := rangeMarketState or BullishMarketState ? "Bullish reaction is more valid" : "Counter-trend; be careful"
    else if txt == "Bearish Rejection From Zone"
        use := rangeMarketState or bearishMarketState ? "Bearish reaction is more valid" : "Counter-trend; be careful"
    else if txt == "Bullish Momentum Candle"
        use := BullishMarketState ? "Supports Bullish continuation" : "Momentum alone is not enough"
    else if txt == "Bearish Momentum Candle"
        use := bearishMarketState ? "Supports bearish continuation" : "Momentum alone is not enough"
    else if txt == "Indecision At Zone"
        use := "Wait for breakout or rejection"
    else if txt == "Indecision Candle"
        use := "Avoid early entry"
    else
        use := "No clear setup"
    use


//Feature series

emaFast = ta.ema(close, 10)
emaSlow = ta.ema(close, 30)

trendBias = close != 0.0 ? (emaFast - emaSlow) / close : na
trendSlope = close != 0.0 ? (emaSlow - emaSlow[5]) / close : na

volumeSma = ta.sma(volume, 20)
volumePressure = not na(volumeSma) and volumeSma > 0.0 ? volume / volumeSma : 1.0

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)
pivotLevel = not na(pivotHigh) ? pivotHigh : not na(pivotLow) ? pivotLow : na

candleRange = high - low
candleBody = math.abs(close - open)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

bodyRatio = candleRange > 0.0 ? candleBody / candleRange : na
upperWickRatio = candleRange > 0.0 ? upperWick / candleRange : na
lowerWickRatio = candleRange > 0.0 ? lowerWick / candleRange : na

ret = not na(close[1]) and close[1] != 0.0 ? math.log(close / close[1]) : na

atrAbs = ta.atr(14)
atrPercent = close != 0.0 ? atrAbs / close : na
rangePercent = close != 0.0 ? (high - low) / close : na
returnVol = ta.stdev(ret, 20)
atrRef = ta.sma(atrPercent, MarketStateLookback)
volAtrRef = ta.sma(atrPercent, volLookback)


//Execution Control

bool inRecentHistory = bar_index >= last_bar_index - histCalcBars
bool refreshBar = bar_index % refreshEvery == 0
bool shouldRun = inRecentHistory and (refreshBar or barstate.islast)



//Run Mudules

if shouldRun
    [rCurLabel,
         rDomLabel,
         rDomBias,
         rDomSlope,
         rDomVolume,
         rCurBias,
         rCurSlope,
         rCurVolume,
         rDomStrength,
         rSse] = Kmeans_3D(
         trendBias,
         trendSlope,
         volumePressure,
         true,
         true,
         MarketStateLookback,
         MarketStateK,
         maxIterations,
         stateWindow,
         convergenceTolerance)

    MarketStateCurrentCluster := rCurLabel
    MarketStateDominantCluster := rDomLabel

    MarketStateCenterBias := rDomBias
    MarketStateCenterSlope := rDomSlope
    MarketStateCenterVolume := rDomVolume

    MarketStateCurrentBias := rCurBias
    MarketStateCurrentSlope := rCurSlope
    MarketStateCurrentVolume := rCurVolume

    MarketStateDominance := rDomStrength
    MarketStateSse := rSse

    MarketStateTxt := MarketState_analysis(MarketStateCenterBias, MarketStateCenterSlope, MarketStateCenterVolume, atrRef)
    MarketStateUse := MarketState_use(MarketStateTxt)

    [zLabel,
         zNearest,
         zSupport,
         zResistance,
         zDist,
         zSpread,
         zStrength,
         zWidth,
         zSse,
         z0,
         z1,
         z2,
         z3,
         z4] = Kmeans_1D_Zones(
         pivotLevel,
         high,
         low,
         close,
         zoneLookback,
         zoneK,
         maxIterations,
         convergenceTolerance,
         zoneStep)

    zoneCluster := zLabel

    nearestZone := zNearest
    supportZone := zSupport
    resistanceZone := zResistance

    zoneDistPct := zDist
    zoneSpreadPct := zSpread
    zoneStrength := zStrength
    zoneWidthPct := zWidth
    zoneSse := zSse

    zone1 := z0
    zone2 := z1
    zone3 := z2
    zone4 := z3
    zone5 := z4

    zoneTxt := Zone_Analysis(close, plotNearestZone, zoneDistPct, supportZone, resistanceZone, atrPercent)
    zoneUse := Zone_Use(zoneTxt, supportZone, resistanceZone)

    [vCurLabel,
         vDomLabel,
         vDomAtr,
         vDomRange,
         vDomRetVol,
         vCurAtr,
         vCurRange,
         vCurRetVol,
         vDomStrength,
         vSse] = Kmeans_3D(
         atrPercent,
         rangePercent,
         returnVol,
         true,
         true,
         volLookback,
         volK,
         maxIterations,
         volStateWindow,
         convergenceTolerance)

    volCurrentCluster := vCurLabel
    volDominantCluster := vDomLabel

    centerAtr := vDomAtr
    centerRange := vDomRange
    centerRetVol := vDomRetVol

    currentAtr := vCurAtr
    currentRange := vCurRange
    currentRetVol := vCurRetVol

    volDominance := vDomStrength
    volSse := vSse

    volTxt := Vol_Analysis(currentAtr, volAtrRef)
    volUse := Vol_Use(volTxt)

    float safeAtrPctForQuality = na(atrPercent) or atrPercent <= 0.0 ? nearZonePct : atrPercent
    float qualityBadDistance = math.max(safeAtrPctForQuality * 1.25, nearZonePct * 3.0)
    float qualityBadWidth = math.max(safeAtrPctForQuality * 1.00, nearZonePct * 3.0)
    float qualityBadFit = math.max(safeAtrPctForQuality * 1.50, nearZonePct * 4.0)
    float qualityGoodStrength = math.min(0.65, (1.0 / zoneK) * 1.60)

    zoneRmsePct := not na(zoneSse) and zoneSse >= 0.0 and not na(close) and close != 0.0 ? math.sqrt(zoneSse) / close : na
    zoneFitScore := Score_Lower(zoneRmsePct, qualityBadFit)
    zoneStrengthScore := Score_Higher(zoneStrength, qualityGoodStrength)
    zoneWidthScore := Score_Lower(zoneWidthPct, qualityBadWidth)
    zoneDistanceScore := Score_Lower(zoneDistPct, qualityBadDistance)

    float qSum = 0.0
    float qWeight = 0.0

    if not na(zoneStrengthScore)
        qSum += zoneStrengthScore * 0.35
        qWeight += 0.35

    if not na(zoneWidthScore)
        qSum += zoneWidthScore * 0.25
        qWeight += 0.25

    if not na(zoneFitScore)
        qSum += zoneFitScore * 0.25
        qWeight += 0.25

    if not na(zoneDistanceScore)
        qSum += zoneDistanceScore * 0.15
        qWeight += 0.15

    priceQualityScore := qWeight > 0.0 ? qSum / qWeight : na

    float MarketStateTrustScore = not na(MarketStateDominance) ? MarketStateDominance * 100.0 : na
    float volTrustScore = not na(volDominance) ? volDominance * 100.0 : na

    float tSum = 0.0
    float tWeight = 0.0

    if not na(priceQualityScore)
        tSum += priceQualityScore * 0.50
        tWeight += 0.50

    if not na(MarketStateTrustScore)
        tSum += MarketStateTrustScore * 0.25
        tWeight += 0.25

    if not na(volTrustScore)
        tSum += volTrustScore * 0.25
        tWeight += 0.25

    calculationTrustScore := tWeight > 0.0 ? tSum / tWeight : na

    qualityTxt := Score_Grade(priceQualityScore)
    trustTxt := Trust_Grade(calculationTrustScore)
    qualityUse := Quality_Use(priceQualityScore, calculationTrustScore)


    priceActionTxt := PriceActionAnalysis(
         open[0],
         high[0],
         low[0],
         close[0],
         high[1],
         low[1],
         plotNearestZone,
         atrPercent[1]
    )

    priceActionUse := PriceActionUse(priceActionTxt, MarketStateTxt, volTxt)

    paBodyRatio := bodyRatio[1]
    paUpperRatio := upperWickRatio[1]
    paLowerRatio := lowerWickRatio[1]



//Stable Zone Outputs

if inRecentHistory
    plotZone1 := Stabilize_Zone(zone1, plotZone1, zonePlotMode, zoneSmoothLen, atrAbs, zoneLockAtrMult)
    plotZone2 := Stabilize_Zone(zone2, plotZone2, zonePlotMode, zoneSmoothLen, atrAbs, zoneLockAtrMult)
    plotZone3 := Stabilize_Zone(zone3, plotZone3, zonePlotMode, zoneSmoothLen, atrAbs, zoneLockAtrMult)
    plotZone4 := Stabilize_Zone(zone4, plotZone4, zonePlotMode, zoneSmoothLen, atrAbs, zoneLockAtrMult)
    plotZone5 := Stabilize_Zone(zone5, plotZone5, zonePlotMode, zoneSmoothLen, atrAbs, zoneLockAtrMult)

    nearestStableTarget := Stable_Nearest(
         nearestZone,
         nearestStableTarget,
         close,
         atrAbs,
         nearestSwitchAtrMult)

    plotNearestZone := Stabilize_Zone(
         nearestStableTarget,
         plotNearestZone,
         zonePlotMode,
         zoneSmoothLen,
         atrAbs,
         zoneLockAtrMult)

    plotSupportZone := Stabilize_Zone(
         supportZone,
         plotSupportZone,
         zonePlotMode,
         zoneSmoothLen,
         atrAbs,
         zoneLockAtrMult)

    plotResistanceZone := Stabilize_Zone(
         resistanceZone,
         plotResistanceZone,
         zonePlotMode,
         zoneSmoothLen,
         atrAbs,
         zoneLockAtrMult)


//Table

var table Table = table.new(Position, 7, 7, border_width = 1, frame_width = 1, bgcolor = #0d1a3f, frame_color = #1c306d, border_color = #1c306d)

if barstate.islast and showTable
    table.cell(Table, 0, 0, "♦ TradingFinder ♦", text_color=#56cfe0, text_size = Size)
    table.merge_cells(Table, 0, 0, 4, 0)

    table.cell(Table, 0, 1, "Module", text_color=color.white, text_size = Size)
    table.cell(Table, 1, 1, "Cluster", text_color=color.white, text_size = Size)
    table.cell(Table, 2, 1, "Data", text_color=color.white, text_size = Size)
    table.cell(Table, 3, 1, "Analysis", text_color=color.white, text_size = Size)
    table.cell(Table, 4, 1, "Use", text_color=color.white, text_size = Size)

    table.cell(Table, 0, 2, "Market State", text_color=color.white, text_size = Size)
    table.cell(Table, 1, 2, "Cur: " + Label(MarketStateCurrentCluster) +
         "\nDom: " + Label(MarketStateDominantCluster) + "\nStr: " + Pct(MarketStateDominance),
         text_color=color.white, text_size = Size)
    table.cell(Table, 2, 2,
         "Bias: " + Pct(MarketStateCenterBias) +
         "\nSlope: " + Pct(MarketStateCenterSlope) +
         "\nVolP: " + Fmt(MarketStateCenterVolume),
         text_color=color.white, text_size = Size)
    table.cell(Table, 3, 2, MarketStateTxt, text_color = BG_Color(MarketStateTxt), text_size = Size)
    table.cell(Table, 4, 2, MarketStateUse, text_color = BG_Color(MarketStateTxt), text_size = Size)

    table.cell(Table, 0, 3, "Price Zones", text_color=color.white, text_size = Size)
    table.cell(Table, 1, 3,
         "Near: " + Label(zoneCluster) +
         "\nStr: " + Pct(zoneStrength),
         text_color=color.white, text_size = Size)
    table.cell(Table, 2,3,
         "Nearest: " + Price(plotNearestZone) +
         "\nSupport: " + Price(plotSupportZone) +
         "\nResistance: " + Price(plotResistanceZone),
         text_color=color.white, text_size = Size)
    table.cell(Table, 3, 3, zoneTxt, text_color = BG_Color(zoneTxt), text_size = Size)
    table.cell(Table, 4, 3, zoneUse, text_color = BG_Color(zoneTxt), text_size = Size)

    table.cell(Table, 0, 4, "Price Action", text_color=color.white, text_size = Size)
    table.cell(Table, 1, 4, "Closed Candle", text_color=color.white, text_size = Size)
    table.cell(Table, 2, 4,
         "Body: " + Fmt(paBodyRatio) +
         "\nUpW: " + Fmt(paUpperRatio) +
         "\nLowW: " + Fmt(paLowerRatio),
         text_color=color.white, text_size = Size)
    table.cell(Table, 3, 4, priceActionTxt, text_color = BG_Color(priceActionTxt), text_size = Size)
    table.cell(Table, 4, 4, priceActionUse, text_color = BG_Color(priceActionTxt), text_size = Size)

    table.cell(Table, 0, 5, "Volatility", text_color=color.white, text_size = Size)
    table.cell(Table, 1, 5,
         "Cur: " + Label(volCurrentCluster) +
         "\nDom: " + Label(volDominantCluster) +
         "\nStr: " + Pct(volDominance),
         text_color=color.white, text_size = Size)
    table.cell(Table, 2, 5,
         "ATR%: " + Pct(currentAtr) +
         "\nRange%: " + Pct(currentRange) +
         "\nRetVol: " + Pct(currentRetVol),
         text_color=color.white, text_size = Size)
    table.cell(Table, 3, 5, volTxt, text_color = BG_Color(volTxt), text_size = Size)
    table.cell(Table, 4, 5, volUse, text_color = BG_Color(volTxt), text_size = Size)

    table.cell(Table, 0, 6, "Quality", text_color=color.white, text_size = Size)
    table.cell(Table, 1, 6,
         "K: " + str.tostring(MarketStateK) + "/" + str.tostring(zoneK) + "/" + str.tostring(volK) +
         "\nZone Str: " + Pct(zoneStrength),
         text_color=color.white, text_size = Size)
    table.cell(Table, 2, 6,
         "Price Q: " + Pct(priceQualityScore / 100) +
         "\nTrust: " + Pct(calculationTrustScore / 100) +
         "\nFit RMSE: " + Pct(zoneRmsePct),
         text_color= color.white, text_size = Size)
    table.cell(Table, 3, 6,
         "Quality: " + qualityTxt +
         "\nReliability: " + trustTxt +
         "\nWidth: " + Pct(zoneWidthPct),
         text_color= Score_BG(calculationTrustScore), text_size = Size)
    table.cell(Table, 4, 6,
         qualityUse,
         text_color= Score_BG(calculationTrustScore), text_size = Size)


//Visual Outputs


Nearest_KMeans_Color =  inRecentHistory and str.contains(MarketStateTxt, "Bullish") ? color.green :
     inRecentHistory and str.contains(MarketStateTxt, "Bearish") ? color.red :
     inRecentHistory and (str.contains(MarketStateTxt, "Range") or str.contains(MarketStateTxt, "Neutral")) ? color.blue :
     na


p1 = plot(showAllZones and inRecentHistory ? plotZone1 : na, "K-Means Zone 1", color=#787b8647 ,linewidth=1)

plot(showAllZones and inRecentHistory ? plotZone2 : na, "K-Means Zone 2", color=color.new(color.gray, 67), linewidth=1)

p2 = plot(showAllZones and inRecentHistory ? plotZone3 : na, "K-Means Zone 3", color=color.new(color.gray, 62), linewidth=1)

plot(showAllZones and inRecentHistory ? plotZone4 : na, "K-Means Zone 4", color=color.new(color.gray, 67), linewidth=1)

p3 = plot(showAllZones and inRecentHistory ? plotZone5 : na, "K-Means Zone 5", color=color.new(color.gray, 72), linewidth=1)

plot(showNearestZone and inRecentHistory ? plotNearestZone : na, "Nearest K-Means Zone", color=Nearest_KMeans_Color, linewidth=1)

plot(showSupportResistance and inRecentHistory ? plotSupportZone : na, "Nearest K-Means Support", color=color.new(color.green, 10), linewidth=1)

plot(showSupportResistance and inRecentHistory ? plotResistanceZone : na, "Nearest K-Means Resistance", color=color.new(color.red, 10), linewidth=1)

//Oscillator Heat Map on Chart

ColorMap(float Value) =>
    v = math.max(0.0, math.min(100.0, Value))
    rv = 100.0 - v

    color result = na

    if rv < 10.0
        result := color.from_gradient(rv, 0.0, 10.0, #990000, #cc0000)
    else if rv < 20.0
        result := color.from_gradient(rv, 10.0, 20.0, #cc0000, #ff6600)
    else if rv < 30.0
        result := color.from_gradient(rv, 20.0, 30.0, #ff6600, #ffcc00)
    else if rv < 40.0
        result := color.from_gradient(rv, 30.0, 40.0, #ffcc00, #ccff66)
    else if rv < 50.0
        result := color.from_gradient(rv, 40.0, 50.0, #ccff66, #66ff66)
    else if rv < 60.0
        result := color.from_gradient(rv, 50.0, 60.0, #66ff66, #66ffcc)
    else if rv < 70.0
        result := color.from_gradient(rv, 60.0, 70.0, #66ffcc, #33ccff)
    else if rv < 80.0
        result := color.from_gradient(rv, 70.0, 80.0, #33ccff, #3399ff)
    else if rv < 90.0
        result := color.from_gradient(rv, 80.0, 90.0, #3399ff, #0066ff)
    else if rv < 95.0
        result := color.from_gradient(rv, 90.0, 95.0, #0066ff, #4902bb)
    else
        result := color.from_gradient(rv, 95.0, 100.0, #4902bb, #410280)

    result
rsi =  ta.ema(ta.stoch(close, high, low, 100), 50)
fill(p1, p2, showAllZones and inRecentHistory ? plotZone1 : na, showAllZones and inRecentHistory ? plotZone3 : na, color.new(ColorMap(rsi), 50), color.new(ColorMap(rsi), 99))
fill(p2, p3, showAllZones and inRecentHistory ? plotZone5 : na, showAllZones and inRecentHistory ? plotZone3 : na, color.new(ColorMap(rsi), 50), color.new(ColorMap(rsi), 99))

//Alert Conditions

alertcondition(priceActionTxt == "Bullish Zone Breakout", "Bullish K-Means Zone Breakout", "Bullish breakout through a K-Means price zone.")
alertcondition(priceActionTxt == "Bearish Zone Breakout", "Bearish K-Means Zone Breakout", "Bearish breakout through a K-Means price zone.")
alertcondition(priceActionTxt == "Bullish Rejection From Zone", "Bullish K-Means Zone Rejection", "Bullish rejection from a K-Means price zone.")
alertcondition(priceActionTxt == "Bearish Rejection From Zone", "Bearish K-Means Zone Rejection", "Bearish rejection from a K-Means price zone.")
````
