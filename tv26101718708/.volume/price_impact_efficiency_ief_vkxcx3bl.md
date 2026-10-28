# Price Impact Efficiency [IEF]

- url: https://www.tradingview.com/script/VkxCx3bL-Price-Impact-Efficiency-IEF/
- type: indicator
- pine_id: PUB;b619f63d6c2e410587eabe18bf15bb45
- version: 1.0

## Description

Price Impact Efficiency (PIE) measures absolute price movement relative to volume participation. It presents that relationship as a continuous line with a historical percentile envelope.

CALCULATION
Current absolute close-to-close movement is divided by the prior bar's ATR. Current volume is divided by the mean volume of prior bars. The movement measure is then divided by relative volume, with a configurable volume floor to avoid unstable ratios at very small readings.

The ratio is transformed using log(1 + ratio), which handles zero price movement, then standardized against the mean and standard deviation of prior transformed ratios. Positive scores indicate a larger response per unit of relative volume than the recent baseline; negative scores indicate a smaller response. Zero is the prior transformed-ratio mean, not zero price movement. This is a descriptive ratio, not a causal estimate of market impact.

DISPLAY AND USE
The blue line shows the standardized score. The shaded band shows the 10th and 90th percentiles of prior standardized scores. Amber dots mark scores above this envelope; purple dots mark scores below it. Dot colors describe position within the historical distribution, not bullish or bearish direction.

The compact readout shows the score and the current transformed ratio's percentile rank. Its rank window includes the current observation; the envelope uses prior standardized scores, so the two percentile references differ.

Apply the study to a standard candle chart with volume data and compare readings within the same symbol and timeframe. Use it to examine whether observed price response per relative participation is high or low compared with recent history. Neither condition identifies absorption, exhaustion, participant identity, or a future reversal.

INPUTS AND ALERTS
Prior baseline length (default 30) controls both the prior volume mean and the prior efficiency statistics. ATR length defaults to 14. Percentile lookback defaults to 100. Relative-volume floor defaults to 0.10. Short history produces a warm-up period, and the percentile envelope takes longer to initialize than the main score.

Bar-close confirmation is enabled by default. The developing bar has no confirmed score or dot and its readout remains Pending. Disabling confirmation allows values to change during the open bar. Alerts describe scores at or above +1.5 or at or below -1.5; these fixed alert thresholds are separate from the adaptive percentile envelope.

WHY A SEPARATE PUBLICATION
My Volume-Range Context Classifier assigns discrete bar conditions using volume, range, close location and structure. Normalized Volume Dynamics focuses on time-of-day volume normalization. PIE instead studies a continuous ratio of ATR-normalized close movement to rolling relative volume, standardizes that ratio, and displays its historical distribution. It preserves this distinct research purpose rather than adding another set of bar classifications.

LIMITATIONS
The volume, ATR and standardization references exclude the current bar. Bars with missing or zero volume are excluded. Very small volume is floored, which changes the ratio at that boundary. A constant valid ratio history receives a neutral score when its standard deviation is zero. ATR-normalized close movement can include gaps and is not intrabar range or order-flow imbalance.

Volume quality differs across markets; tick volume represents activity rather than centralized traded volume. Baselines are rolling and do not correct for time-of-day seasonality. Scores depend on chart history, symbol, timeframe and inputs. Percentiles describe the sampled history rather than probabilities of future outcomes. Historical values may change if the data provider revises data. The study makes no performance or predictive accuracy claims.

The Pine v6 source is published under Mozilla Public License 2.0. Intended for education, chart context and research.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IndicatorEliteFlow

//@version=6
indicator("Price Impact Efficiency [IEF]", shorttitle="PIE [IEF]", overlay=false, precision=2)

// This indicator measures the magnitude of price response relative to volume participation.
// It describes observable relationships only. It does not identify participant intent,
// predict reversals, or provide entry and exit signals.

string groupModel = "Model"
int baselineLength = input.int(30, "Prior baseline length", minval=20, group=groupModel)
int rankLength = input.int(100, "Percentile lookback", minval=30, group=groupModel)
int atrLength = input.int(14, "ATR length", minval=2, group=groupModel)
float volumeFloor = input.float(0.10, "Relative-volume floor", minval=0.01, maxval=1.00, step=0.01, group=groupModel,
     tooltip="Prevents very small volume readings from producing unstable ratios.")
bool confirmOnClose = input.bool(true, "Confirm values only after bar close", group=groupModel)

string groupDisplay = "Display"
bool showEnvelope = input.bool(true, "Show prior 10th-90th percentile envelope", group=groupDisplay)
bool showDashboard = input.bool(true, "Show compact readout", group=groupDisplay)

// Baselines use completed prior bars. The current observation cannot alter its own reference.
float priorVolumeMean = ta.sma(volume[1], baselineLength)
float priorAtr = ta.atr(atrLength)[1]
float relativeVolume = priorVolumeMean > 0 and volume > 0 ? volume / priorVolumeMean : na
float normalizedMove = priorAtr > 0 ? math.abs(close - close[1]) / priorAtr : na

// log(1 + ratio) remains defined at zero price movement without an arbitrary negative spike.
float safeParticipation = math.max(relativeVolume, volumeFloor)
float rawEfficiency = normalizedMove / safeParticipation
float logEfficiency = math.log(1.0 + rawEfficiency)

// Standardization also uses only prior observations.
float priorEfficiencyMean = ta.sma(logEfficiency[1], baselineLength)
float priorEfficiencyDev = ta.stdev(logEfficiency[1], baselineLength)
float efficiencyScore = priorEfficiencyDev > 0 ? (logEfficiency - priorEfficiencyMean) / priorEfficiencyDev : not na(priorEfficiencyMean) ? 0.0 : na
float efficiencyPercentile = ta.percentrank(logEfficiency, rankLength)

bool enoughHistory = not na(efficiencyScore) and not na(relativeVolume)
bool valueReady = enoughHistory and (not confirmOnClose or barstate.isconfirmed)
float displayedScore = valueReady ? efficiencyScore : na
// The envelope uses prior scores only and describes the historical distribution.
float lowerEnvelope = ta.percentile_nearest_rank(efficiencyScore[1], rankLength, 10)
float upperEnvelope = ta.percentile_nearest_rank(efficiencyScore[1], rankLength, 90)
hline(0, "Baseline center", color=color.new(color.gray, 65), linestyle=hline.style_dotted)
upperPlot = plot(showEnvelope ? upperEnvelope : na, "Prior 90th percentile", color=color.new(color.blue, 55), linewidth=1)
lowerPlot = plot(showEnvelope ? lowerEnvelope : na, "Prior 10th percentile", color=color.new(color.blue, 55), linewidth=1)
fill(upperPlot, lowerPlot, color=color.new(color.blue, 92), title="Historical response envelope")
plot(displayedScore, "Price-impact efficiency z-score", style=plot.style_linebr, color=color.rgb(35, 130, 200), linewidth=2)
plot(valueReady and efficiencyScore > upperEnvelope ? efficiencyScore : na, "Above historical envelope", style=plot.style_circles, color=color.rgb(215, 145, 35), linewidth=3)
plot(valueReady and efficiencyScore < lowerEnvelope ? efficiencyScore : na, "Below historical envelope", style=plot.style_circles, color=color.rgb(150, 85, 185), linewidth=3)

bool unusuallyHighResponse = valueReady and efficiencyScore >= 1.5
bool unusuallyLowResponse = valueReady and efficiencyScore <= -1.5
alertcondition(unusuallyHighResponse, "Unusually high price response", "PIE: unusually high price response relative to volume on {{ticker}} {{interval}}")
alertcondition(unusuallyLowResponse, "Unusually low price response", "PIE: unusually low price response relative to volume on {{ticker}} {{interval}}")

var table dashboard = table.new(position.top_right, 2, 3, border_width=0)
if barstate.islast
    if showDashboard
        string state = not enoughHistory ? "Building history" : not barstate.isconfirmed and confirmOnClose ? "Developing" : efficiencyScore >= 1.5 ? "High response" : efficiencyScore <= -1.5 ? "Low response" : "Within baseline"
        color stateColor = efficiencyScore >= 1.5 ? color.teal : efficiencyScore <= -1.5 ? color.purple : color.gray
        table.cell(dashboard, 0, 0, "PIE", bgcolor=color.new(color.black, 10), text_color=color.white)
        table.cell(dashboard, 1, 0, state, bgcolor=color.new(stateColor, 15), text_color=color.white)
        table.cell(dashboard, 0, 1, "Efficiency z", text_color=chart.fg_color, bgcolor=chart.bg_color)
        table.cell(dashboard, 1, 1, valueReady ? str.tostring(efficiencyScore, "#.##") : "Pending", text_color=chart.fg_color, bgcolor=chart.bg_color)
        table.cell(dashboard, 0, 2, "Percentile", text_color=chart.fg_color, bgcolor=chart.bg_color)
        table.cell(dashboard, 1, 2, not valueReady ? "Pending" : na(efficiencyPercentile) ? "Building" : str.tostring(efficiencyPercentile, "#") + "%", text_color=chart.fg_color, bgcolor=chart.bg_color)
    else
        table.clear(dashboard, 0, 0, 1, 2)
````
