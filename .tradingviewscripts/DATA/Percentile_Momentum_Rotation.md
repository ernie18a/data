<!-- tradingview-pine-id: PUB;bdc3d42857db42c294d36ae10334ffeb -->
<!-- tradingviewscripts-format: 1 -->
# Percentile Momentum Rotation

Source: https://www.tradingview.com/script/2lKMTuUg-Percentile-Momentum-Rotation-Pineify/

## Description

Percentile Momentum Rotation

Overview
Percentile Momentum Rotation is a Pine Script v6 oscillator that converts fast, medium, and slow rate of change into a comparable spectrum. It shows a centered score, horizon coherence, a fast-slow wave, and a dashboard for momentum context rather than prediction.

Problem Definition
Raw ROC is a percentage return over one window. An 8-bar ROC has a different range from a 55-bar ROC, and the same value can be ordinary in a volatile regime but unusual in a quiet one. Averaging raw readings lets the largest horizon dominate, while fixed thresholds change meaning with the distribution. The design must retain each horizon's information but remove its local scale before combination.

Design Rationale
Each ROC is ranked against its own history and centered from -100 to +100, avoiding an assumption of normal returns. A z-score was rejected because outliers can distort its mean and deviation; a raw blend was rejected because it keeps the scale mismatch. The centroid is discounted when horizon polarities disagree or ranks spread apart. This favors coherent states but reacts less to an early one-window turn. The visual hierarchy follows these variables: primary score first, explanatory layers second.

Key Features

[*]Three independently normalized ROC percentile streams.

[*]A coherence-weighted composite and fast-slow rotation wave.

[*]A state-colored spectrum, horizon fan, confirmed alerts, and dashboard.

[*]Balanced, fast-focus, and slow-focus weighting.

How It Works
The script calculates percentage ROC over fast, medium, and slow lengths. ta.percentrank compares each current ROC with its configured history. Percentile 50 maps to zero, 100 to +100, and 0 to -100. Positive therefore means high versus that horizon's recent distribution; it does not guarantee a positive raw return.

The centered ranks form a weighted centroid; the three profiles shift emphasis across horizons. Polarity checks whether ranks share a side outside the dead zone, while compactness measures dispersion. Their 0-to-1 coherence controls a 0.55-to-1.00 consistency factor applied to the score.

The wave is half the fast-minus-slow rank difference. Color encodes score direction, halo intensity encodes coherence, and fan width shows dispersion. Output remains empty through warm-up. Visuals update intrabar; diamonds and alerts require bar close.

How Multiple Indicators Work Together
This is one pipeline, not a mashup. ROC supplies horizon change; percentile rank removes local scale; the centroid summarizes location; polarity and dispersion test coherence; and the consistency factor forms the score. The wave exposes lead-lag behavior that the centroid hides, while the fan visualizes disagreement. Removing a stage either removes momentum, restores the comparability problem, or hides confidence.

Trading Ideas and Insights
Upper and lower states organize review of relative momentum expansion. Synchronization means all horizons are unusual versus their own histories, not that a trade must follow. The wave reveals whether fast momentum leads or lags the slow horizon; repeated zero crossings describe unstable context. Confirm with independent structure and risk controls.

Unique Aspects
ROC and percentile rank are standard; the contribution is their information architecture. Each horizon is normalized against itself, then the composite is discounted by both side agreement and compactness. It separates historical location, synchronization, and lead-lag rotation; the same variables control halo, fan, and wave. No retrieved code is reproduced.

How to Use

[*]Allow the slow ROC plus percentile history to warm up.

[*]Start with Balanced and read score, coherence, and wave together.

[*]Treat synchronization as context, then assess price structure and risk separately.

[*]Use confirmed alerts; current-bar plots may move before close.

[*]Disable secondary layers for a cleaner chart.

Customization
Short ROC windows react faster but rotate more often; long windows add persistence and lag. Longer percentile history provides broader context but adapts more slowly after regime shifts. The dead zone sets how much near-median movement is directionless. Rotation thresholds define context and extremes; Synchronization Threshold sets required agreement. Weight profiles change the analytical question, so comparisons should keep settings consistent.

Assumptions and Limitations
The source and available history must be representative enough for ranking. Percentiles are relative: a high rank can occur while raw returns are negative if the decline is milder than recent declines. Results depend on lengths, lookback, and structural breaks. It is lagging and omits volume, execution, fundamentals, and structure. Visuals can change before close; alerts wait for confirmation. No future values or external data are used, but this does not establish performance.

Conclusion
Percentile Momentum Rotation turns incompatible ROC scales into an auditable spectrum. It keeps relative location, coherence, and lead-lag rotation distinct but connected, helping diagnose momentum context without treating thresholds as guaranteed entries.

---

## Source Code

````pine
//@version=6
indicator("Percentile Momentum Rotation", overlay = false, precision = 1)

string groupWindows = "Momentum Windows"
sourceInput = input.source(close, "Source", group = groupWindows)
int fastLength = input.int(8, "Fast ROC Length", minval = 2, maxval = 50, group = groupWindows)
int mediumLength = input.int(21, "Medium ROC Length", minval = 5, maxval = 100, group = groupWindows)
int slowLength = input.int(55, "Slow ROC Length", minval = 10, maxval = 250, group = groupWindows)
int rankLookback = input.int(150, "Percentile Lookback", minval = 50, maxval = 1000, group = groupWindows)
string weightProfile = input.string("Balanced", "Horizon Weighting", options = ["Balanced", "Fast Focus", "Slow Focus"], group = groupWindows)

string groupState = "Rotation State"
float polarityDeadZone = input.float(5.0, "Percentile Dead Zone", minval = 0.0, maxval = 20.0, step = 1.0, group = groupState)
float balanceThreshold = input.float(25.0, "Rotation Threshold", minval = 10.0, maxval = 50.0, step = 1.0, group = groupState)
float strongThreshold = input.float(65.0, "Strong Rotation Threshold", minval = 50.0, maxval = 90.0, step = 1.0, group = groupState)
float syncThreshold = input.float(0.72, "Synchronization Threshold", minval = 0.40, maxval = 0.95, step = 0.01, group = groupState)

string groupVisual = "Visual System"
bool showGlow = input.bool(true, "Show Coherence Halo", group = groupVisual)
bool showHorizonFan = input.bool(true, "Show Horizon Spectrum", group = groupVisual)
bool showRotationWave = input.bool(true, "Show Fast-Slow Rotation Wave", group = groupVisual)
bool showStatePulse = input.bool(true, "Show Synchronized State Pulse", group = groupVisual)
bool showDashboard = input.bool(true, "Show State Dashboard", group = groupVisual)

bool lengthsOrdered = fastLength < mediumLength and mediumLength < slowLength
if barstate.isfirst and not lengthsOrdered
    runtime.error("ROC lengths must satisfy Fast < Medium < Slow.")

f_roc(float source, int length) =>
    not na(source[length]) and source[length] != 0.0 ? 100.0 * (source / source[length] - 1.0) : na

f_polarity(float value, float deadZone) =>
    value > deadZone ? 1.0 : value < -deadZone ? -1.0 : 0.0

float fastRoc = f_roc(sourceInput, fastLength)
float mediumRoc = f_roc(sourceInput, mediumLength)
float slowRoc = f_roc(sourceInput, slowLength)

float fastPercentile = ta.percentrank(fastRoc, rankLookback)
float mediumPercentile = ta.percentrank(mediumRoc, rankLookback)
float slowPercentile = ta.percentrank(slowRoc, rankLookback)
bool ready = not na(fastPercentile) and not na(mediumPercentile) and not na(slowPercentile)

float fastRank = ready ? (fastPercentile - 50.0) * 2.0 : na
float mediumRank = ready ? (mediumPercentile - 50.0) * 2.0 : na
float slowRank = ready ? (slowPercentile - 50.0) * 2.0 : na

float fastWeight = weightProfile == "Fast Focus" ? 1.60 : weightProfile == "Slow Focus" ? 0.75 : 1.00
float mediumWeight = 1.00
float slowWeight = weightProfile == "Slow Focus" ? 1.60 : weightProfile == "Fast Focus" ? 0.75 : 1.00
float totalWeight = fastWeight + mediumWeight + slowWeight

float percentileCentroid = ready ? (fastRank * fastWeight + mediumRank * mediumWeight + slowRank * slowWeight) / totalWeight : na
float rankDispersion = ready ? (math.abs(fastRank - percentileCentroid) + math.abs(mediumRank - percentileCentroid) + math.abs(slowRank - percentileCentroid)) / 3.0 : na
float compactness = ready ? 1.0 - math.min(rankDispersion / 100.0, 1.0) : na

float fastPolarity = ready ? f_polarity(fastRank, polarityDeadZone) : na
float mediumPolarity = ready ? f_polarity(mediumRank, polarityDeadZone) : na
float slowPolarity = ready ? f_polarity(slowRank, polarityDeadZone) : na
float directionalAgreement = ready ? math.abs(fastPolarity + mediumPolarity + slowPolarity) / 3.0 : na
float coherence = ready ? directionalAgreement * (0.35 + 0.65 * compactness) : na

float consistencyWeight = ready ? 0.55 + 0.45 * coherence : na
float rotationScore = ready ? percentileCentroid * consistencyWeight : na
float rotationWave = ready ? (fastRank - slowRank) * 0.5 : na

color upperColor = color.rgb(34, 211, 238)
color lowerColor = color.rgb(244, 63, 94)
color neutralColor = color.rgb(148, 163, 184)
color mediumColor = color.rgb(250, 204, 21)
color slowColor = color.rgb(168, 85, 247)
color scoreColor = not ready ? neutralColor : rotationScore >= 0.0 ? color.from_gradient(rotationScore, 0.0, 100.0, neutralColor, upperColor) : color.from_gradient(rotationScore, -100.0, 0.0, lowerColor, neutralColor)
color waveColor = not ready ? neutralColor : color.from_gradient(rotationWave, -100.0, 100.0, lowerColor, upperColor)
int haloTransparency = ready ? int(math.round(math.max(40.0, 90.0 - coherence * 48.0))) : 100
int fanTransparency = ready ? int(math.round(math.max(78.0, 94.0 - coherence * 12.0))) : 100

topRail = hline(100.0, "Upper Limit", color = color.new(upperColor, 88))
upperRail = hline(strongThreshold, "Strong Upper Rotation", color = color.new(upperColor, 48), linestyle = hline.style_dotted)
balanceTop = hline(balanceThreshold, "Upper Rotation Threshold", color = color.new(neutralColor, 76), linestyle = hline.style_dashed)
zeroRail = hline(0.0, "Balance Line", color = color.new(neutralColor, 54))
balanceBottom = hline(-balanceThreshold, "Lower Rotation Threshold", color = color.new(neutralColor, 76), linestyle = hline.style_dashed)
lowerRail = hline(-strongThreshold, "Strong Lower Rotation", color = color.new(lowerColor, 48), linestyle = hline.style_dotted)
bottomRail = hline(-100.0, "Lower Limit", color = color.new(lowerColor, 88))

fill(topRail, upperRail, color = color.new(upperColor, 92), title = "Upper Extreme Zone")
fill(upperRail, balanceTop, color = color.new(upperColor, 96), title = "Upper Rotation Zone")
fill(balanceTop, balanceBottom, color = color.new(neutralColor, 97), title = "Balance Zone")
fill(balanceBottom, lowerRail, color = color.new(lowerColor, 96), title = "Lower Rotation Zone")
fill(lowerRail, bottomRail, color = color.new(lowerColor, 92), title = "Lower Extreme Zone")

plot(showRotationWave and ready ? rotationWave : na, "Fast-Slow Rotation Wave", style = plot.style_columns, histbase = 0.0, color = color.new(waveColor, 68))
fastPlot = plot(showHorizonFan and ready ? fastRank : na, "Fast ROC Percentile", color = color.new(upperColor, 30), linewidth = 1)
mediumPlot = plot(showHorizonFan and ready ? mediumRank : na, "Medium ROC Percentile", color = color.new(mediumColor, 32), linewidth = 1)
slowPlot = plot(showHorizonFan and ready ? slowRank : na, "Slow ROC Percentile", color = color.new(slowColor, 28), linewidth = 1)
fill(fastPlot, mediumPlot, color = showHorizonFan ? color.new(waveColor, fanTransparency) : na, title = "Fast-Medium Spectrum")
fill(mediumPlot, slowPlot, color = showHorizonFan ? color.new(slowColor, fanTransparency) : na, title = "Medium-Slow Spectrum")

plot(showGlow and ready ? rotationScore : na, "Coherence Halo", color = color.new(scoreColor, haloTransparency), linewidth = 4)
plot(ready ? rotationScore : na, "Percentile Momentum Rotation", color = scoreColor, linewidth = 2)

bool crossedUpperThreshold = ta.crossover(rotationScore, strongThreshold)
bool crossedLowerThreshold = ta.crossunder(rotationScore, -strongThreshold)
bool upperRotation = barstate.isconfirmed and crossedUpperThreshold
bool lowerRotation = barstate.isconfirmed and crossedLowerThreshold
bool synchronizedRotation = barstate.isconfirmed and ready and coherence >= syncThreshold and nz(coherence[1], 0.0) < syncThreshold and math.abs(rotationScore) >= balanceThreshold

plotshape(upperRotation ? rotationScore : na, title = "Confirmed Strong Upper Rotation", style = shape.diamond, location = location.absolute, color = upperColor, size = size.tiny)
plotshape(lowerRotation ? rotationScore : na, title = "Confirmed Strong Lower Rotation", style = shape.diamond, location = location.absolute, color = lowerColor, size = size.tiny)
bgcolor(showStatePulse and ready and coherence >= syncThreshold and math.abs(rotationScore) >= balanceThreshold ? color.new(scoreColor, 91) : na, title = "Synchronized Rotation Pulse")

string stateText = not ready ? "Warming Up" : rotationScore >= strongThreshold ? coherence >= syncThreshold ? "Upper Sync" : "Upper Extreme" : rotationScore >= balanceThreshold ? "Upper Rotation" : rotationScore <= -strongThreshold ? coherence >= syncThreshold ? "Lower Sync" : "Lower Extreme" : rotationScore <= -balanceThreshold ? "Lower Rotation" : "Balanced"
color stateColor = not ready ? color.new(neutralColor, 25) : math.abs(rotationScore) < balanceThreshold ? color.new(neutralColor, 28) : color.new(scoreColor, 18)

var table dashboard = table.new(position.top_right, 2, 6, frame_color = color.new(neutralColor, 55), frame_width = 1, border_color = color.new(neutralColor, 78), border_width = 1)
if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "MOMENTUM ROTATION", text_color = color.white, bgcolor = stateColor, text_size = size.small)
        table.cell(dashboard, 1, 0, stateText, text_color = color.white, bgcolor = stateColor, text_size = size.small)
        table.cell(dashboard, 0, 1, "Rotation", text_color = neutralColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 1, 1, ready ? str.tostring(rotationScore, "#.0") : "NA", text_color = scoreColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 0, 2, "Coherence", text_color = neutralColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 1, 2, ready ? str.tostring(coherence * 100.0, "#.0") + "%" : "NA", text_color = ready ? color.from_gradient(coherence, 0.0, 1.0, neutralColor, upperColor) : neutralColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 0, 3, "Fast", text_color = color.new(upperColor, 0), bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 1, 3, ready ? str.tostring(fastRank, "#.0") : "NA", text_color = color.new(upperColor, 0), bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 0, 4, "Medium", text_color = color.new(mediumColor, 0), bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 1, 4, ready ? str.tostring(mediumRank, "#.0") : "NA", text_color = color.new(mediumColor, 0), bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 0, 5, "Slow", text_color = color.new(slowColor, 0), bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 1, 5, ready ? str.tostring(slowRank, "#.0") : "NA", text_color = color.new(slowColor, 0), bgcolor = color.new(color.black, 82))
    else
        table.clear(dashboard, 0, 0, 1, 5)

alertcondition(upperRotation, "Strong Upper Momentum Rotation", "Percentile Momentum Rotation confirmed a move into the strong upper rotation zone.")
alertcondition(lowerRotation, "Strong Lower Momentum Rotation", "Percentile Momentum Rotation confirmed a move into the strong lower rotation zone.")
alertcondition(synchronizedRotation, "Three-Window Momentum Synchronization", "Percentile Momentum Rotation confirmed synchronized fast, medium, and slow momentum percentiles.")
````
