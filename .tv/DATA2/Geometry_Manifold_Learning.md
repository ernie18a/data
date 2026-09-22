<!-- tradingview-pine-id: PUB;611c98f129da458d94ef51c16421abf7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Geometry | Manifold Learning

Source: https://www.tradingview.com/script/Pgyjq3AJ-Geometry-Manifold-Learning/

## Description

Geometry | Manifold Learning (GML) is an experimental market-structure indicator that analyzes price movement from a geometric perspective.

Traditional technical indicators often reduce market behavior to trend, momentum, volatility, or moving averages. GML takes a different approach: it treats recent price observations as points belonging to a locally evolving geometric structure, or "manifold."

The objective is not to predict future prices. Instead, the indicator attempts to describe the current structure of price movement by measuring:

• Geodesic path behavior
• Local price curvature
• Tangent projection
• Local neighborhood density using k-nearest-neighbor concepts
• Intrinsic dimensionality
• Normalized embedding direction
• Local geometric mean

These measurements are combined into a multi-component oscillator designed to help traders study whether recent price action is relatively directional, compressed, dispersed, curved, or undergoing a structural transition.

Core Concept
Financial prices do not always move efficiently from one level to another.
For example, price may begin at 100 and end at 105.
The direct displacement is only 5 points, but the actual path could have travelled:
100 → 103 → 101 → 106 → 102 → 105
The total distance travelled is substantially greater than the final displacement.

GML uses this distinction between direct displacement and travelled path as one way of describing the geometry of recent price action.

A relatively direct path may indicate more organized directional movement, while a large travelled path relative to displacement can indicate a more complex or inefficient local structure.
This concept forms the foundation of the indicator's Geodesic Ratio.

1. Geodesic Ratio

The indicator calculates two distances over the selected embedding window.
Euclidean Distance:
The absolute difference between the current price and the price at the opposite end of the observation window.

Geodesic Distance:
The cumulative absolute movement between consecutive observations within the same window.
The ratio is then calculated conceptually as:
Geodesic Ratio = Travelled Path / Direct Displacement
A larger ratio means price travelled a relatively complicated path to reach its current location.
A smaller ratio represents a more direct path.
The ratio is normalized using its historical mean and standard deviation to produce the displayed Geodesic Ratio Z-score.

Interpretation
Positive/high readings can indicate that the recent path is relatively complex or indirect.
Negative/low readings indicate that the path is relatively more linear compared with its recent behavior.
This measurement should not independently be interpreted as bullish or bearish. It describes the geometry of the path rather than its direction.

2. Local Curvature
GML estimates local curvature using first- and second-order changes in price.

The first difference measures local price movement, while the second difference measures how rapidly that movement itself is changing.
Conceptually, high curvature represents a sharper local bend in the price path.
The raw curvature measurement is normalized into a Z-score relative to its recent history.

Interpretation
Higher positive Curvature Z-scores indicate that the current local bend is unusually large compared with recent observations.

Lower readings indicate a relatively smoother local trajectory.

High curvature does NOT automatically indicate a market reversal.

It simply identifies an area where the local geometry of price has changed more sharply than normal.

The Curvature Threshold input controls how unusual curvature must become before it qualifies as a high-curvature condition within the signal logic.

3. Tangent Projection
The Tangent Projection measures the position of current price relative to a locally smoothed price structure.

The script calculates a local mean and standard deviation over the selected smoothing period and normalizes the current deviation from that local mean.

This creates a standardized representation of where price currently sits relative to its recent local structure.

General interpretation

Above zero:
Price is positioned above its local mean.

Below zero:
Price is positioned below its local mean.

Movement toward zero:
Price is returning toward its local center.

Movement away from zero:
Price is extending farther away from the local center.

The reversal logic additionally examines whether a negative tangent projection has begun recovering.

4. k-Nearest-Neighborhood Distance

The indicator compares the current price with observations inside the selected embedding window and identifies nearby observations based on absolute price distance.

The average distance of the nearest observations provides a local neighborhood-radius estimate.

This value is then normalized relative to its recent history.

Interpretation

Negative kNN Z-score:
The local neighborhood is relatively tight compared with recent conditions.

Positive kNN Z-score:
The local neighborhood is relatively dispersed.

This can be thought of as a geometric measure of local price concentration rather than a conventional volatility indicator.

The signal engine uses this information to distinguish between tighter and looser local structures.

5. Intrinsic Dimensionality
Intrinsic Dimensionality attempts to estimate how the local observations populate the surrounding price neighborhood.

The indicator compares the proportion of observations located inside:

Radius R and Radius 2R

The change in neighborhood occupancy as the radius expands provides a simplified estimate of local dimensional structure.

The result is bounded according to the configured k-nearest-neighbor setting and normalized for visualization.

Interpretation

Rather than giving a direct bullish/bearish signal, Intrinsic Dimensionality is intended as a structural diagnostic.
Changes in this value can indicate that the local organization of price observations is changing.
It is best interpreted together with the other geometric measurements rather than independently.

6. Embedding Coordinate
GML also calculates a directional coordinate from the signed movement of price relative to the total travelled geodesic distance.

The value is bounded between -1 and +1 and subsequently smoothed.

This produces the Embedding Coordinate displayed as an area plot.

General interpretation

Toward +1:
Recent movement is increasingly aligned in the positive direction.

Toward -1:
Recent movement is increasingly aligned in the negative direction.

Around zero:
Directional movement is more balanced relative to the travelled path.

The script specifically monitors transitions through -0.5 and +0.5 as components of its signal logic.

7. Geodesic Mean
The yellow Geodesic Mean displayed on the main price chart is the simple average of the selected price source across the embedding window.

It provides a price-level reference alongside the geometric measurements displayed in the oscillator pane.

It should not be interpreted as a standalone entry or exit signal.

Signal Logic
GML includes two types of visual signals.

R — Manifold Reversal

The green "R" marker represents a potential local structural reversal condition.
It requires several conditions to occur together:

• Local curvature is unusually high
• The embedding coordinate crosses upward through its lower structural region
• The local kNN neighborhood is relatively tight
• Tangent projection is still negative but recovering

The purpose of combining these conditions is to identify situations where price has experienced significant local bending while its embedded directional structure begins recovering from a negative region.

An R marker does not mean that price must reverse.
It indicates that the script's specific geometric reversal conditions have occurred simultaneously.

C — Manifold Continuation
The red "C" marker represents a potential directional continuation condition.
It requires:

• A relatively linear geodesic path
• The embedding coordinate crossing downward through its upper structural region
• A relatively loose kNN neighborhood
This combination is intended to identify a different geometric regime from the reversal condition.
The C marker should therefore be interpreted as a structural continuation condition generated by the model, not as a guaranteed short signal.

How to Read the Indicator
Instead of focusing on a single line, GML is designed to be interpreted as a collection of geometric measurements.

A practical workflow is:

Step 1 — Observe the Embedding Coordinate
Start with the green/red area plot.
Watch how the coordinate behaves around:
+0.5
0
-0.5
Movement from an extreme region toward the center can indicate a change in the directional organization of the recent path.

Step 2 — Check Curvature
Next, examine Local Curvature.
A curvature expansion indicates that price is bending more sharply than it normally has during the current observation period.
High curvature combined with a change in embedding direction can be more informative than curvature alone.

Step 3 — Examine Neighborhood Structure
Use kNN Tightness to determine whether recent observations are relatively concentrated or dispersed.
This helps distinguish different local geometric environments.

Step 4 — Check Tangent Projection
Tangent Projection helps determine where price sits relative to its recent local structure.
For example, a negative tangent projection that begins rising can indicate recovery toward the local center.

Step 5 — Examine Geodesic Behavior
Use the Geodesic Ratio Z-score to understand whether the current price path is relatively direct or unusually indirect.

This provides additional context regarding the efficiency and complexity of recent movement.

Step 6 — Use Signals as Confluence
R and C markers are intentionally generated from multiple conditions.
They are best treated as indications that a specific combination of geometric conditions has occurred rather than as automatic trade instructions.

Users can combine GML with their own analysis of:

• Market structure
• Support and resistance
• Trend direction
• Volume
• Volatility
• Risk management

How Traders Can Use GML
GML can be used in several ways.

Structural Reversal Analysis
Look for situations where curvature expands while the embedding coordinate begins recovering from an extreme region.

This can help identify areas where the geometry of recent price movement is changing.

Trend/Path Quality Analysis

The Geodesic Ratio can help distinguish relatively direct price movement from more complicated paths.

This can provide additional context when evaluating an existing trend.

Compression and Dispersion Analysis
kNN neighborhood measurements provide information about whether recent observations are relatively concentrated or dispersed.

This can help characterize the local market regime.

Confirmation Tool

GML can also be used as a secondary analytical layer alongside an existing trading methodology.

For example, a trader may first identify a setup using market structure and then examine whether GML shows a corresponding change in curvature, embedding direction, or neighborhood structure.

Inputs
Embedding Dimension (N)
Defines the number of recent observations used to construct the local geometric window.
Lower values make the measurements more sensitive to recent price changes.
Higher values analyze a broader local structure and generally produce slower-changing measurements.
Default: 20

k-Nearest Neighbors
Controls the dimensional normalization/reference used by the local-neighborhood calculations.
Default: 5

Smoothing Length
Controls smoothing of the embedding coordinate and the local window used by the tangent-related calculation.
Lower values respond more quickly.
Higher values produce smoother measurements.
Default: 5

Curvature Threshold
Controls the Z-score threshold required for curvature to qualify as unusually high within the reversal condition.
Higher values require more extreme curvature.
Default: 0.5

Price Source
Available sources include:
Close
Open
HL2
HLC3
OHLC4
Default: HLC3
Changing the source changes the price series used by the geometric calculations.

Display Controls
Individual components can be enabled or disabled from the settings:
Show Geodesic Distance
Show Local Curvature
Show Tangent Projection
Show Intrinsic Dimensionality
Show Geodesic Mean on Price Chart
Show Signals

This allows users to simplify the display and focus on the measurements relevant to their analysis.

Information Table

The table in the upper-right corner provides the current values of several important measurements:
Geo Ratio
Curvature Z-score
Tangent Projection
Intrinsic Dimension
Embedding Coordinate
kNN Average Distance
Geodesic Mean
The table is intended to provide a compact numerical view of the current geometric state.

Alerts
The indicator provides alert conditions for:
Manifold Reversal
and
Manifold Continuation

Users can create TradingView alerts from these conditions if they want to monitor when the corresponding geometric setup occurs.

An alert indicates that the defined conditions were satisfied; it does not guarantee that the subsequent market movement will follow any particular direction or magnitude.

Why This Indicator Is Different
GML is not intended to be another conventional oscillator created by combining RSI, MACD, or moving-average crossover conditions.

Its primary calculations are built around geometric characteristics of the recent price path:

• travelled path versus direct displacement
• local curvature
• local tangent/deviation
• nearest-neighborhood distances
• neighborhood scaling
• directional embedding

These measurements are combined to provide a different representation of local market structure.

The purpose is to explore how the geometry of recent price observations changes over time rather than attempting to directly forecast future prices.

Important Limitations

GML is a simplified application of geometric and manifold-inspired concepts to a one-dimensional market price series.

It should not be interpreted as a full academic manifold-learning implementation such as Isomap, locally linear embedding, diffusion maps, or another high-dimensional machine-learning algorithm.

The kNN, geodesic, curvature, dimensionality, and embedding calculations used here are purpose-built approximations designed for real-time chart analysis within Pine Script.

Market prices are noisy and non-stationary. Similar geometric conditions can lead to different outcomes under different market environments.
Signals may also occur during sideways markets, volatile periods, news events, gaps, or other abnormal conditions.
No geometric measurement can determine future market direction with certainty.

Recommended Usage
GML is best used as an analytical and confluence tool rather than as a standalone trading system.
Users should evaluate signals in the context of their own:
market structure analysis, risk tolerance, instrument, timeframe, execution method, and risk-management rules.
Different instruments and timeframes can produce substantially different geometric behavior, so users are encouraged to study the indicator across historical market conditions before incorporating it into their process.

Educational Purpose
Geometry | Manifold Learning is provided as an analytical and educational tool for studying price behavior.
It does not provide investment advice, does not guarantee trading performance, and does not predict future market outcomes.
The calculations describe mathematical properties of historical and current price observations. Any trading decision and associated risk remain the responsibility of the user.

---

## Source Code

````pine
//@version=6
indicator("Geometry | Manifold Learning", shorttitle="GML", overlay=false, max_bars_back=500)

int vecLen = input.int(20, "Embedding Dimension (N)", minval=5, maxval=50)
int kNeighbors = input.int(5, "k-Nearest Neighbors", minval=2, maxval=15)
int smoothLen = input.int(5, "Smoothing Length", minval=1, maxval=20)
float curvThresh = input.float(0.5, "Curvature Threshold", minval=0.1, maxval=2.0, step=0.1)
string srcType = input.string("HLC3", "Price Source", options=["Close", "Open", "HL2", "HLC3", "OHLC4"])

bool showGeo = input.bool(true, "Show Geodesic Distance")
bool showCurv = input.bool(true, "Show Local Curvature")
bool showTan = input.bool(true, "Show Tangent Projection")
bool showDim = input.bool(true, "Show Intrinsic Dimensionality")
bool showMean = input.bool(true, "Show Geodesic Mean on Price Chart")
bool showSig = input.bool(true, "Show Signals")

float src = switch srcType
    "Close" => close
    "Open" => open
    "HL2" => hl2
    "OHLC4" => ohlc4
    => hlc3

float tempMin1 = 1e10
float tempMin2 = 1e10
float tempMin3 = 1e10
float tempMin4 = 1e10
float tempMin5 = 1e10

for i = 1 to vecLen - 1
    float dist = math.abs(src - src[i])
    if dist < tempMin1
        tempMin5 := tempMin4
        tempMin4 := tempMin3
        tempMin3 := tempMin2
        tempMin2 := tempMin1
        tempMin1 := dist
    else if dist < tempMin2
        tempMin5 := tempMin4
        tempMin4 := tempMin3
        tempMin3 := tempMin2
        tempMin2 := dist
    else if dist < tempMin3
        tempMin5 := tempMin4
        tempMin4 := tempMin3
        tempMin3 := dist
    else if dist < tempMin4
        tempMin5 := tempMin4
        tempMin4 := dist
    else if dist < tempMin5
        tempMin5 := dist

float knnAvg = (tempMin1 + tempMin2 + tempMin3 + tempMin4 + tempMin5) / 5.0

float euclidean = math.abs(src - src[vecLen - 1])
float geodesic = 0.0

for i = 0 to vecLen - 2
    geodesic += math.abs(src[i] - src[i + 1])

float geoRatio = euclidean > 0.0 ? geodesic / euclidean : 1.0
float geoMean = ta.sma(geoRatio, vecLen * 2)
float geoStd = ta.stdev(geoRatio, vecLen * 2)
float geoZ = geoStd > 0.0 ? (geoRatio - geoMean) / geoStd : 0.0
float priceGeoMean = ta.sma(src, vecLen)

float dp = src - src[1]
float ddp = src - 2.0 * src[1] + src[2]
float curvDenom = math.pow(1.0 + dp * dp, 1.5)
float curvature = curvDenom > 0.0 ? math.abs(ddp) / curvDenom : 0.0
float curvMean = ta.sma(curvature, vecLen)
float curvStd = ta.stdev(curvature, vecLen)
float curvZ = curvStd > 0.0 ? (curvature - curvMean) / curvStd : 0.0

float tanMu = ta.sma(src, smoothLen)
float tanDev = src - tanMu
float tanNorm = ta.stdev(src, smoothLen)
float tanProj = tanNorm > 0.0 ? tanDev / tanNorm : 0.0

float radius = knnAvg
float radius2 = 2.0 * radius
int countR = 0
int countR2 = 0
int totalPairs = 0

for i = 1 to vecLen - 1
    float d = math.abs(src - src[i])
    totalPairs += 1
    if d <= radius
        countR += 1
    if d <= radius2
        countR2 += 1

float cr = totalPairs > 0 ? float(countR) / float(totalPairs) : 0.0001
float cr2 = totalPairs > 0 ? float(countR2) / float(totalPairs) : 0.0001
float intrDim = cr > 0.0 and cr2 > 0.0 ? math.log(cr2 / cr) / math.log(2.0) : 1.0

intrDim := math.max(math.min(intrDim, float(kNeighbors)), 0.0)

float intrDimNorm = (intrDim / float(kNeighbors)) * 2.0 - 1.0

float signedPath = 0.0

for i = 0 to vecLen - 2
    signedPath += src[i] - src[i + 1]

float embedCoord = geodesic > 0.0 ? signedPath / geodesic : 0.0
embedCoord := math.max(math.min(embedCoord, 1.0), -1.0)

float embedSmooth = ta.sma(embedCoord, smoothLen)
float knnMean = ta.sma(knnAvg, vecLen * 2)
float knnStdDev = ta.stdev(knnAvg, vecLen * 2)
float knnZ = knnStdDev > 0.0 ? (knnAvg - knnMean) / knnStdDev : 0.0

bool highCurv = curvZ > curvThresh
bool knnTight = knnZ < 0.0
bool knnLoose = knnZ > 0.5
bool embedTrough = ta.crossover(embedSmooth, -0.5)
bool embedPeak = ta.crossunder(embedSmooth, 0.5)
bool tanRecovery = tanProj > tanProj[1] and tanProj < 0.0
bool linearPath = geoZ < -0.5

bool gmlBuy = highCurv and embedTrough and knnTight and tanRecovery
bool gmlSell = linearPath and embedPeak and knnLoose

color colGeo = geoZ >= 0.0 ? color.new(color.orange, 20) : color.new(color.teal, 20)
color colCurv = curvZ > curvThresh ? color.new(color.red, 15) : color.new(color.lime, 35)
color colTan = tanProj >= 0.0 ? color.new(color.aqua, 20) : color.new(color.fuchsia, 20)
color colDim = color.new(color.yellow, 20)
color colEmbed = embedSmooth >= 0.0 ? color.new(color.lime, 30) : color.new(color.red, 30)
color colKnn = knnZ > 0.0 ? color.new(color.orange, 40) : color.new(color.teal, 40)

hline(0.0, "Zero", color.new(color.white, 65), hline.style_dashed)
hline(1.0, "Upper", color.new(color.white, 82), hline.style_dotted)
hline(-1.0, "Lower", color.new(color.white, 82), hline.style_dotted)
hline(0.5, "+0.5", color.new(color.gray, 80), hline.style_dotted)
hline(-0.5, "-0.5", color.new(color.gray, 80), hline.style_dotted)

plot(showGeo ? geoZ : na, title="Geodesic Ratio (z)", color=colGeo, linewidth=2)
plot(showCurv ? curvZ : na, title="Local Curvature (z)", color=colCurv, linewidth=1, style=plot.style_histogram)
plot(showTan ? tanProj : na, title="Tangent Projection", color=colTan, linewidth=2)
plot(embedSmooth, title="Embedding Coordinate", color=colEmbed, linewidth=2, style=plot.style_area)
plot(showDim ? intrDimNorm : na, title="Intrinsic Dimensionality (norm)", color=colDim, linewidth=1, style=plot.style_stepline)
plot(knnZ * 0.5, title="kNN Tightness (z, scaled)", color=colKnn, linewidth=1)
plot(showMean ? priceGeoMean : na, title="Geodesic Mean (Price)", color=color.new(color.yellow, 20), linewidth=2, force_overlay=true)

plotshape(showSig and gmlBuy ? embedSmooth : na, title="Manifold Reversal Buy", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.normal, text="R")
plotshape(showSig and gmlSell ? embedSmooth : na, title="Manifold Continuation Sell", style=shape.triangledown, location=location.absolute, color=color.red, size=size.normal, text="C")

alertcondition(gmlBuy, "GML Manifold Reversal", "Manifold Learning: Reversal detected on price manifold")
alertcondition(gmlSell, "GML Manifold Continuation", "Manifold Learning: Linear continuation detected")

var table infoTable = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 65), border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    table.cell(infoTable, 0, 0, "GML Metric", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 1, 0, "Value", text_color=color.silver, text_size=size.small)
    table.cell(infoTable, 0, 1, "Geo Ratio", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(geoRatio, "#.0000"), text_color=color.orange, text_size=size.small)
    table.cell(infoTable, 0, 2, "Curvature (z)", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(curvZ, "#.0000"), text_color=curvZ > curvThresh ? color.red : color.lime, text_size=size.small)
    table.cell(infoTable, 0, 3, "Tangent Proj", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(tanProj, "#.0000"), text_color=tanProj >= 0.0 ? color.aqua : color.fuchsia, text_size=size.small)
    table.cell(infoTable, 0, 4, "Intr. Dim", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(intrDim, "#.00"), text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 5, "Embed Coord", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 5, str.tostring(embedSmooth, "#.0000"), text_color=embedSmooth >= 0.0 ? color.lime : color.red, text_size=size.small)
    table.cell(infoTable, 0, 6, "kNN Avg Dist", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 6, str.tostring(knnAvg, "#.00"), text_color=color.teal, text_size=size.small)
    table.cell(infoTable, 0, 7, "Geo Mean", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 7, str.tostring(priceGeoMean, "#.00"), text_color=color.yellow, text_size=size.small)
````
