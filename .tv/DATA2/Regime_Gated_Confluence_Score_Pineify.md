<!-- tradingview-pine-id: PUB;e989a7a82c2844b4ba0f9eeb685e5772 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Regime Gated Confluence Score [Pineify]

Source: https://www.tradingview.com/script/m99Sdj2H-Regime-Gated-Confluence-Score-Pineify/

## Description

Regime Gated Confluence Score [Pineify]

Overview
This pane indicator combines trend, momentum, and volume after a four-state gate selects meaning and weight. The main score and dashboard reconcile signed contributions.

Problem Definition
Fixed-weight confluence hides a regime error. Positive RSI may confirm a trend but mark extension in a range. EMA separation can persist after efficient travel ends. Relative volume shows participation, not acceptance. A permanent sum can stay strong when path efficiency is low, factors disagree, or ATR leaves its baseline, so users cannot tell whether magnitude reflects agreement or one dominant input.

Design Rationale
ATR-normalized EMA separation and slope measure trend across price scales. Centered RSI supplies momentum; RANGE reverses it to express a fade. Volume pressure combines capped relative volume with close location without claiming aggressor flow. EMA spread and path efficiency classify structure; ATR versus baseline identifies displacement. Lower hold thresholds add hysteresis. A trained model would add hidden data assumptions, while fixed weights preserve the failure. Explicit rules accept sensitivity and lag for auditability.

Key Features

[*]Four regimes with hysteresis.

[*]Standardized trend, RSI, and participation factors.

[*]Regime weights, range inversion, missing-volume renormalization, conflict attenuation, exact contribution totals, and confirmed alerts.

How It Works
EMA spread and fast-EMA change are normalized by ATR, blended 65/35, and clipped to -1 through +1. RSI is centered at 50, divided by 25, and clipped. Volume multiplies close location inside the bar by relative volume capped at 2.5 times baseline, then smooths it. If fewer than 80% of volume-window bars are usable, volume is omitted.

Trend strength is absolute normalized EMA spread. Path efficiency divides net movement by total one-bar movement. ATR relative to baseline measures displacement. VOLATILE has priority until its lower hold level clears. Otherwise, strong separation and efficiency enter TREND, weak evidence enters RANGE, and unresolved evidence is TRANSITION.

Trend/momentum/volume weights are 55/30/15 in TREND, 15/60/25 in RANGE, 40/35/25 in VOLATILE, and 35/40/25 in TRANSITION. RANGE reverses only RSI. Missing volume removes its weight and renormalizes the others. Agreement divides absolute net contribution by total absolute contribution and sets a 0.55-to-1 gate; VOLATILE adds an ATR penalty. Gated components sum to the score. Warm-up or invalid threshold and EMA ordering blocks output with a diagnostic.

How Multiple Indicators Work Together
Trend estimates structure, momentum locates bounded pressure, and volume tests participation plus bar acceptance. The regime interprets them before combination. Without range inversion, extension becomes a continuation vote; without trend, brief momentum can dominate; without volume, weights must be renormalized. Agreement converts remaining conflict into lower magnitude rather than hiding it.

Trading Ideas and Insights
Use the score as context, not an order. A confirmed threshold cross during TREND identifies aligned conditions. In RANGE, check whether trend or volume opposes inverted momentum before considering a fade. In VOLATILE, a compressed gate shows ATR displacement discounting the raw sum. A strong component beside a modest total indicates conflict.

Unique Aspects
The contribution is the sequence of classification, interpretation change, weighting, and attenuation. RANGE reverses momentum while other factors can veto it; hysteresis separates trend entry from persistence; missing volume is removed; and agreement scales every component so the ledger equals the score. The halo shows magnitude, the background shows regime, and the table exposes construction.

How to Use
Start with defaults and compare the regime label with visible path behavior. Wait for warm-up. Keep the ledger visible to see whether structure, oscillator pressure, or participation drives direction. Use confirmed alerts when closing-state transitions matter. Contribution lines are diagnostic; the halo and background form the primary view. Omitted volume means a disclosed two-factor score.

Customization
EMA lengths and slope lookback control structural response; RSI length controls momentum sensitivity. Volume baseline and smoothing trade speed for stability. Regime length changes path efficiency and the ATR baseline. Entry thresholds must exceed hold thresholds. Raising the score threshold reduces alert frequency but does not establish better forecasting. Visual switches change display only.

Assumptions and Limitations
The script uses chart OHLC and reported volume. Exchange, tick, and absent volume differ; close-location volume is only a proxy. EMA, ATR, RSI, and rolling baselines lag. RANGE can fade a breakout, hysteresis can delay exits, and attenuation can suppress an early shock.

Realtime factors, regime, colors, and score can change before close; alerts require confirmation. No request calls, future data, pivots, or negative offsets are used. The script does not model liquidity, news, sizing, entries, stops, or exits. Thresholds do not establish expected return. Sparse bars and unreliable volume can distort evidence.

Conclusion
This replaces a fixed sum with an inspectable state process. The score and ledger show weights, conflict attenuation, and missing-data effects. Keep separate risk and execution rules.

.

---

## Source Code

````pine
//@version=6
indicator("Regime Gated Confluence Score [Pineify]", overlay = false)

string GROUP_FACTORS = "Factor Engine"
string GROUP_REGIME = "Regime Gate"
string GROUP_VISUALS = "Visuals"

int fastLength = input.int(21, "Fast EMA length", minval = 2, maxval = 300, group = GROUP_FACTORS)
int slowLength = input.int(55, "Slow EMA length", minval = 3, maxval = 500, group = GROUP_FACTORS)
int slopeLength = input.int(5, "Trend slope lookback", minval = 1, maxval = 100, group = GROUP_FACTORS)
int momentumLength = input.int(14, "RSI momentum length", minval = 2, maxval = 200, group = GROUP_FACTORS)
int volumeLength = input.int(20, "Volume baseline length", minval = 2, maxval = 300, group = GROUP_FACTORS)
int volumeSmoothLength = input.int(5, "Volume pressure smoothing", minval = 1, maxval = 100, group = GROUP_FACTORS)
int atrLength = input.int(14, "ATR normalization length", minval = 2, maxval = 200, group = GROUP_FACTORS)

int regimeLength = input.int(34, "Regime evidence length", minval = 10, maxval = 300, group = GROUP_REGIME)
float trendEnterStrength = input.float(0.55, "Trend entry: EMA spread / ATR", minval = 0.10, maxval = 5.00, step = 0.05, group = GROUP_REGIME)
float trendExitStrength = input.float(0.35, "Trend hold: EMA spread / ATR", minval = 0.05, maxval = 4.00, step = 0.05, group = GROUP_REGIME)
float trendEnterEfficiency = input.float(0.32, "Trend entry: path efficiency", minval = 0.05, maxval = 1.00, step = 0.01, group = GROUP_REGIME)
float trendExitEfficiency = input.float(0.20, "Trend hold: path efficiency", minval = 0.01, maxval = 1.00, step = 0.01, group = GROUP_REGIME)
float rangeStrengthMax = input.float(0.25, "Range entry: maximum EMA spread / ATR", minval = 0.05, maxval = 2.00, step = 0.05, group = GROUP_REGIME)
float rangeEfficiencyMax = input.float(0.18, "Range entry: maximum path efficiency", minval = 0.01, maxval = 0.80, step = 0.01, group = GROUP_REGIME)
float shockEnterRatio = input.float(1.55, "Volatility shock entry: ATR / baseline", minval = 1.05, maxval = 5.00, step = 0.05, group = GROUP_REGIME)
float shockExitRatio = input.float(1.25, "Volatility shock hold: ATR / baseline", minval = 1.00, maxval = 4.00, step = 0.05, group = GROUP_REGIME)
float directionThreshold = input.float(55.0, "Directional score threshold", minval = 10.0, maxval = 90.0, step = 1.0, group = GROUP_REGIME)

bool showScoreHalo = input.bool(true, "Show score halo", group = GROUP_VISUALS)
bool showRegimeBackground = input.bool(true, "Show regime background", group = GROUP_VISUALS)
bool showContributions = input.bool(false, "Show contribution lines", group = GROUP_VISUALS)
bool showCoherence = input.bool(false, "Show agreement line", group = GROUP_VISUALS)
bool showDashboard = input.bool(true, "Show contribution dashboard", group = GROUP_VISUALS)

clamp(float value, float lower, float upper) =>
    math.max(lower, math.min(upper, value))

valueText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0")

ratioText(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.00")

float atrValue = ta.atr(atrLength)
float atrBaseline = ta.sma(atrValue, regimeLength)
float safeAtr = not na(atrValue) and atrValue > syminfo.mintick ? atrValue : na

float fastEma = ta.ema(close, fastLength)
float slowEma = ta.ema(close, slowLength)
float spreadComponent = not na(safeAtr) ? (fastEma - slowEma) / safeAtr : na
float slopeComponent = not na(safeAtr) ? (fastEma - fastEma[slopeLength]) / (safeAtr * math.sqrt(slopeLength)) : na
float trendFactor = not na(spreadComponent) and not na(slopeComponent) ? clamp(spreadComponent * 0.65 + slopeComponent * 0.35, -1.0, 1.0) : na
float trendStrength = not na(spreadComponent) ? math.abs(spreadComponent) : na

float rsiValue = ta.rsi(close, momentumLength)
float momentumFactor = not na(rsiValue) ? clamp((rsiValue - 50.0) / 25.0, -1.0, 1.0) : na

bool volumeBarValid = not na(volume) and volume > 0.0
float volumeBaseline = ta.sma(volumeBarValid ? volume : 0.0, volumeLength)
float volumeCoverage = ta.sma(volumeBarValid ? 1.0 : 0.0, volumeLength)
bool volumeAvailable = not na(volumeBaseline) and volumeBaseline > 0.0 and volumeCoverage >= 0.80
float barRange = high - low
float closeLocation = barRange > syminfo.mintick ? clamp((2.0 * close - high - low) / barRange, -1.0, 1.0) : 0.0
float relativeVolume = volumeAvailable ? clamp(volume / volumeBaseline, 0.0, 2.5) : 0.0
float volumePulse = volumeAvailable ? closeLocation * relativeVolume / 2.5 : 0.0
float volumeFactorRaw = ta.ema(volumePulse, volumeSmoothLength)
float volumeFactor = volumeAvailable ? clamp(volumeFactorRaw, -1.0, 1.0) : 0.0

float pathStep = math.abs(ta.change(close))
float pathTravel = ta.sma(pathStep, regimeLength) * regimeLength
float netTravel = math.abs(close - close[regimeLength])
float pathEfficiency = not na(pathTravel) and pathTravel > syminfo.mintick ? clamp(netTravel / pathTravel, 0.0, 1.0) : na
float volatilityRatio = not na(atrBaseline) and atrBaseline > syminfo.mintick ? atrValue / atrBaseline : na

bool thresholdsOrdered = trendExitStrength <= trendEnterStrength and trendExitEfficiency <= trendEnterEfficiency and shockExitRatio <= shockEnterRatio
bool engineReady = thresholdsOrdered and slowLength > fastLength and not na(trendFactor) and not na(momentumFactor) and not na(pathEfficiency) and not na(volatilityRatio)

var int regime = 0
if engineReady
    if volatilityRatio >= shockEnterRatio
        regime := 2
    else if regime == 2 and volatilityRatio > shockExitRatio
        regime := 2
    else
        bool trendEntry = trendStrength >= trendEnterStrength and pathEfficiency >= trendEnterEfficiency
        bool trendHold = trendStrength >= trendExitStrength and pathEfficiency >= trendExitEfficiency
        bool rangeEntry = trendStrength <= rangeStrengthMax or pathEfficiency <= rangeEfficiencyMax
        if trendEntry or (regime == 1 and trendHold)
            regime := 1
        else if rangeEntry
            regime := -1
        else
            regime := 0
else
    regime := 0

float trendWeight = regime == 1 ? 0.55 : regime == -1 ? 0.15 : regime == 2 ? 0.40 : 0.35
float momentumWeight = regime == 1 ? 0.30 : regime == -1 ? 0.60 : regime == 2 ? 0.35 : 0.40
float volumeWeight = regime == 1 ? 0.15 : regime == -1 ? 0.25 : 0.25
float activeWeight = trendWeight + momentumWeight + (volumeAvailable ? volumeWeight : 0.0)
float normalizedTrendWeight = activeWeight > 0.0 ? trendWeight / activeWeight : na
float normalizedMomentumWeight = activeWeight > 0.0 ? momentumWeight / activeWeight : na
float normalizedVolumeWeight = activeWeight > 0.0 and volumeAvailable ? volumeWeight / activeWeight : 0.0

float effectiveMomentum = regime == -1 ? -momentumFactor : momentumFactor
float rawTrendContribution = engineReady and activeWeight > 0.0 ? trendFactor * trendWeight / activeWeight : na
float rawMomentumContribution = engineReady and activeWeight > 0.0 ? effectiveMomentum * momentumWeight / activeWeight : na
float rawVolumeContribution = engineReady and activeWeight > 0.0 and volumeAvailable ? volumeFactor * volumeWeight / activeWeight : 0.0
float rawScore = rawTrendContribution + rawMomentumContribution + rawVolumeContribution
float weightedMagnitude = math.abs(rawTrendContribution) + math.abs(rawMomentumContribution) + math.abs(rawVolumeContribution)
float agreement = engineReady and weightedMagnitude > 0.000001 ? clamp(math.abs(rawScore) / weightedMagnitude, 0.0, 1.0) : 0.0
float agreementGate = 0.55 + 0.45 * agreement
float volatilityGate = regime == 2 ? clamp(shockEnterRatio / volatilityRatio, 0.45, 1.0) : 1.0
float scoreGate = agreementGate * volatilityGate

float trendContribution = engineReady ? rawTrendContribution * scoreGate * 100.0 : na
float momentumContribution = engineReady ? rawMomentumContribution * scoreGate * 100.0 : na
float volumeContribution = engineReady ? rawVolumeContribution * scoreGate * 100.0 : na
float score = engineReady ? trendContribution + momentumContribution + volumeContribution : na

string regimeText = not engineReady ? "WARM-UP / INPUTS" : regime == 1 ? "TREND" : regime == -1 ? "RANGE" : regime == 2 ? "VOLATILE" : "TRANSITION"
string momentumMode = regime == -1 ? "FADE" : "FOLLOW"
string diagnostic = not thresholdsOrdered ? "CHECK THRESHOLD ORDER" : slowLength <= fastLength ? "SLOW EMA MUST EXCEED FAST" : not engineReady ? "WARM-UP" : not volumeAvailable ? "VOLUME OMITTED" : "ACTIVE"

color bullColor = color.rgb(23, 190, 187)
color bearColor = color.rgb(235, 74, 111)
color trendColor = color.rgb(62, 132, 255)
color momentumColor = color.rgb(176, 103, 255)
color volumeColor = color.rgb(246, 168, 55)
color rangeColor = color.rgb(240, 190, 62)
color volatileColor = color.rgb(239, 92, 72)
color neutralColor = color.rgb(132, 145, 160)
color scoreColor = na(score) ? neutralColor : color.from_gradient(score, -100.0, 100.0, bearColor, bullColor)
color regimeColor = regime == 1 ? trendColor : regime == -1 ? rangeColor : regime == 2 ? volatileColor : neutralColor

hline(0.0, "Neutral axis", color = color.new(chart.fg_color, 72))
hline(directionThreshold, "Bullish threshold", color = color.new(bullColor, 55), linestyle = hline.style_dashed)
hline(-directionThreshold, "Bearish threshold", color = color.new(bearColor, 55), linestyle = hline.style_dashed)
hline(100.0, "Upper bound", color = color.new(chart.fg_color, 92))
hline(-100.0, "Lower bound", color = color.new(chart.fg_color, 92))

plot(showScoreHalo ? score : na, "Score halo", color = color.new(scoreColor, 76), linewidth = 5, style = plot.style_area, histbase = 0.0)
plot(score, "Regime-gated confluence", color = scoreColor, linewidth = 3)
plot(showContributions ? trendContribution : na, "Trend contribution", color = color.new(trendColor, 10), linewidth = 1)
plot(showContributions ? momentumContribution : na, "Momentum contribution", color = color.new(momentumColor, 10), linewidth = 1)
plot(showContributions ? volumeContribution : na, "Volume contribution", color = color.new(volumeColor, 10), linewidth = 1)
plot(showCoherence and engineReady ? agreement * 100.0 : na, "Factor agreement", color = color.new(chart.fg_color, 18), linewidth = 1)
bgcolor(showRegimeBackground and engineReady ? color.new(regimeColor, 91) : na, title = "Regime background")

var table dashboard = table.new(position.top_right, 3, 9, bgcolor = color.new(chart.bg_color, 4), frame_color = color.new(chart.fg_color, 65), frame_width = 1, border_color = color.new(chart.fg_color, 86))
if barstate.islast
    table.clear(dashboard, 0, 0, 2, 8)
    if showDashboard
        table.cell(dashboard, 0, 0, "REGIME GATE", text_color = color.white, bgcolor = color.new(regimeColor, 4), text_size = size.small)
        table.cell(dashboard, 1, 0, regimeText, text_color = color.white, bgcolor = color.new(regimeColor, 4), text_size = size.small)
        table.cell(dashboard, 2, 0, diagnostic, text_color = color.white, bgcolor = color.new(regimeColor, 4), text_size = size.small)
        table.cell(dashboard, 0, 1, "Score", text_color = chart.fg_color, text_size = size.small)
        table.cell(dashboard, 1, 1, valueText(score), text_color = scoreColor, text_size = size.small)
        table.cell(dashboard, 2, 1, "Gate " + ratioText(scoreGate), text_color = neutralColor, text_size = size.small)
        table.cell(dashboard, 0, 2, "Trend", text_color = trendColor, text_size = size.small)
        table.cell(dashboard, 1, 2, valueText(trendContribution), text_color = trendColor, text_size = size.small)
        table.cell(dashboard, 2, 2, str.tostring(normalizedTrendWeight * 100.0, "#") + "%", text_color = neutralColor, text_size = size.small)
        table.cell(dashboard, 0, 3, "Momentum", text_color = momentumColor, text_size = size.small)
        table.cell(dashboard, 1, 3, valueText(momentumContribution), text_color = momentumColor, text_size = size.small)
        table.cell(dashboard, 2, 3, momentumMode + " " + str.tostring(normalizedMomentumWeight * 100.0, "#") + "%", text_color = neutralColor, text_size = size.small)
        table.cell(dashboard, 0, 4, "Volume", text_color = volumeColor, text_size = size.small)
        table.cell(dashboard, 1, 4, valueText(volumeContribution), text_color = volumeColor, text_size = size.small)
        table.cell(dashboard, 2, 4, volumeAvailable ? str.tostring(normalizedVolumeWeight * 100.0, "#") + "%" : "OMITTED", text_color = volumeAvailable ? neutralColor : bearColor, text_size = size.small)
        table.cell(dashboard, 0, 5, "Agreement", text_color = chart.fg_color, text_size = size.small)
        table.cell(dashboard, 1, 5, valueText(agreement * 100.0) + "%", text_color = scoreColor, text_size = size.small)
        table.cell(dashboard, 2, 5, "attenuation", text_color = neutralColor, text_size = size.small)
        table.cell(dashboard, 0, 6, "Trend evidence", text_color = chart.fg_color, text_size = size.small)
        table.cell(dashboard, 1, 6, ratioText(trendStrength), text_color = trendColor, text_size = size.small)
        table.cell(dashboard, 2, 6, "eff " + ratioText(pathEfficiency), text_color = neutralColor, text_size = size.small)
        table.cell(dashboard, 0, 7, "ATR regime", text_color = chart.fg_color, text_size = size.small)
        table.cell(dashboard, 1, 7, ratioText(volatilityRatio), text_color = regime == 2 ? volatileColor : neutralColor, text_size = size.small)
        table.cell(dashboard, 2, 7, "x baseline", text_color = neutralColor, text_size = size.small)
        table.cell(dashboard, 0, 8, "Bounds", text_color = chart.fg_color, text_size = size.small)
        table.cell(dashboard, 1, 8, "+" + valueText(directionThreshold), text_color = bullColor, text_size = size.small)
        table.cell(dashboard, 2, 8, "-" + valueText(directionThreshold), text_color = bearColor, text_size = size.small)

bool scoreCrossedBullish = ta.crossover(score, directionThreshold)
bool scoreCrossedBearish = ta.crossunder(score, -directionThreshold)
bool regimeChanged = barstate.isconfirmed and engineReady and engineReady[1] and regime != regime[1]
bool bullishThresholdCross = barstate.isconfirmed and scoreCrossedBullish
bool bearishThresholdCross = barstate.isconfirmed and scoreCrossedBearish

alertcondition(regimeChanged, "Regime gate changed", "Regime Gated Confluence Score: the confirmed regime gate changed.")
alertcondition(bullishThresholdCross, "Bullish score threshold crossed", "Regime Gated Confluence Score: the confirmed score crossed above the bullish threshold.")
alertcondition(bearishThresholdCross, "Bearish score threshold crossed", "Regime Gated Confluence Score: the confirmed score crossed below the bearish threshold.")
````
