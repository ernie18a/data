# Volume-Range Context Classifier [IEF]

- url: https://www.tradingview.com/script/4Az7t6IG-Volume-Range-Context-Classifier-IEF/
- type: indicator
- pine_id: PUB;25df309a5d414b21ba1544c26c22c154
- version: 1.0

## Description

Volume-Range Context Classifier (VRCC) is an open-source analytical indicator that classifies bars using three directly observable inputs: relative volume, true range, and the closing price's location within the bar. It is inspired by the general effort-versus-result concept used in volume-spread analysis, but it does not claim to identify institutions, accumulation, distribution, or future reversals.

WHAT MAKES THIS IMPLEMENTATION USEFUL

Instead of comparing volume and range only with fixed multiples of their moving averages, VRCC standardizes both measurements as z-scores. This makes its thresholds more comparable across instruments and changing volatility regimes. The classifications are mutually exclusive and include directional close-location tests, an optional EMA context filter, and prior structure levels that exclude the current bar.

The indicator distinguishes four conditions:

• Volume-backed expansion: Unusually high volume and range, a directional close, and a confirmed close beyond the previous structure range.
• High effort / low result: Unusually high volume without correspondingly wide range and with a relatively small real body.
• Low effort / high result: Unusually low volume accompanied by unusually wide range. This describes the bar only; it does not imply a cause.
• Quiet compression: Both volume and range are unusually low. This display is disabled by default to reduce clutter.

HOW TO USE IT

Use the markers as context, not as entries or exits. A marker reports how the completed bar compares with its recent baseline. The dashboard displays the current volume z-score, range z-score, close location, and classification. Prior structure levels and the optional EMA help users interpret directional expansion events.

Thresholds should be adjusted for the instrument and timeframe being studied. Volume quality differs between markets; on symbols without meaningful centralized volume, results may be based on tick volume or otherwise be less informative.

REPAINTING AND LIMITATIONS

With Confirm signals only after bar close enabled, classifications appear only on confirmed bars and do not use future data. Prior structure calculations explicitly exclude the current bar. If confirmation is disabled, conditions can appear and disappear while the live bar develops.

These classifications are descriptive heuristics. They do not reveal participant identity, distinguish genuine from false breakouts, predict reversals, or measure trade performance. No backtest or profitability claim is made. The script is intended for research and educational chart analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IndicatorEliteFlow

//@version=6
indicator("Volume-Range Context Classifier [IEF]", shorttitle="VRCC [IEF]", overlay=true, max_labels_count=300)

// Original rules-based volume/range classifier. It describes observable bar
// conditions; it does not infer participant identity or predict performance.
groupBaseline = "Baselines"
baselineLength = input.int(50, "Baseline length", minval=10, group=groupBaseline)
structureLength = input.int(20, "Prior structure lookback", minval=5, group=groupBaseline)
volumeZThreshold = input.float(1.5, "Unusual-volume z-score", minval=0.5, step=0.1, group=groupBaseline)
rangeZThreshold = input.float(1.2, "Unusual-range z-score", minval=0.5, step=0.1, group=groupBaseline)
quietZThreshold = input.float(-0.6, "Quiet-condition z-score", maxval=0.0, step=0.1, group=groupBaseline)

groupContext = "Context filters"
useTrendFilter = input.bool(true, "Use EMA context for directional events", group=groupContext)
trendLength = input.int(50, "EMA length", minval=2, group=groupContext)
minCloseLocation = input.float(0.65, "Minimum directional close location", minval=0.5, maxval=1.0, step=0.05, group=groupContext)
confirmOnClose = input.bool(true, "Confirm signals only after bar close", group=groupContext)

groupDisplay = "Display"
showExpansion = input.bool(true, "Show volume-backed expansions", group=groupDisplay)
showAbsorption = input.bool(true, "Show high-effort / low-result bars", group=groupDisplay)
showEase = input.bool(true, "Show low-effort / high-result bars", group=groupDisplay)
showQuiet = input.bool(false, "Show quiet compression bars", group=groupDisplay)
showStructure = input.bool(true, "Plot prior structure levels", group=groupDisplay)
showDashboard = input.bool(true, "Show current-bar dashboard", group=groupDisplay)

f_zscore(float value, int length) =>
    float mean = ta.sma(value, length)
    float deviation = ta.stdev(value, length)
    deviation > 0 ? (value - mean) / deviation : 0.0

float trueRange = ta.tr(true)
float volumeZ = f_zscore(volume, baselineLength)
float rangeZ = f_zscore(trueRange, baselineLength)
float barSpan = math.max(high - low, syminfo.mintick)
float closeLocation = (close - low) / barSpan
float directionalBody = math.abs(close - open) / barSpan
float trendEma = ta.ema(close, trendLength)
float priorHigh = ta.highest(high, structureLength)[1]
float priorLow = ta.lowest(low, structureLength)[1]

bool enoughHistory = not na(volumeZ) and not na(rangeZ) and not na(priorHigh) and not na(priorLow)
bool confirmed = not confirmOnClose or barstate.isconfirmed
bool highVolume = volumeZ >= volumeZThreshold
bool lowVolume = volumeZ <= quietZThreshold
bool wideRange = rangeZ >= rangeZThreshold
bool narrowRange = rangeZ <= quietZThreshold
bool closesHigh = closeLocation >= minCloseLocation
bool closesLow = closeLocation <= 1.0 - minCloseLocation
bool bullishContext = not useTrendFilter or close >= trendEma
bool bearishContext = not useTrendFilter or close <= trendEma

bool bullExpansion = enoughHistory and confirmed and highVolume and wideRange and closesHigh and close > priorHigh and bullishContext
bool bearExpansion = enoughHistory and confirmed and highVolume and wideRange and closesLow and close < priorLow and bearishContext
bool highEffortLowResult = enoughHistory and confirmed and highVolume and not wideRange and directionalBody < 0.45
bool lowEffortHighResult = enoughHistory and confirmed and lowVolume and wideRange and not bullExpansion and not bearExpansion
bool quietCompression = enoughHistory and confirmed and lowVolume and narrowRange

plot(showStructure ? priorHigh : na, "Prior range high", color=color.new(color.teal, 70), style=plot.style_stepline)
plot(showStructure ? priorLow : na, "Prior range low", color=color.new(color.orange, 70), style=plot.style_stepline)
plot(useTrendFilter ? trendEma : na, "Context EMA", color=color.new(color.silver, 35))
plotshape(showExpansion and bullExpansion, "Bullish volume-backed expansion", shape.labelup, location.belowbar, color=color.new(color.teal, 0), text="EXP+", textcolor=color.white, size=size.tiny)
plotshape(showExpansion and bearExpansion, "Bearish volume-backed expansion", shape.labeldown, location.abovebar, color=color.new(color.orange, 0), text="EXP-", textcolor=color.white, size=size.tiny)
plotshape(showAbsorption and highEffortLowResult, "High effort / low result", shape.square, location.abovebar, color=color.new(color.purple, 0), text="HE/LR", textcolor=color.white, size=size.tiny)
plotshape(showEase and lowEffortHighResult, "Low effort / high result", shape.diamond, location.belowbar, color=color.new(color.blue, 0), text="LE/HR", textcolor=color.white, size=size.tiny)
plotshape(showQuiet and quietCompression, "Quiet compression", shape.circle, location.belowbar, color=color.new(color.gray, 20), text="Q", textcolor=color.white, size=size.tiny)

alertcondition(bullExpansion, "Bullish volume-backed expansion", "VRCC: bullish volume-backed expansion on {{ticker}} {{interval}}")
alertcondition(bearExpansion, "Bearish volume-backed expansion", "VRCC: bearish volume-backed expansion on {{ticker}} {{interval}}")
alertcondition(highEffortLowResult, "High effort / low result", "VRCC: high-effort / low-result condition on {{ticker}} {{interval}}")
alertcondition(lowEffortHighResult, "Low effort / high result", "VRCC: low-effort / high-result condition on {{ticker}} {{interval}}")

var table dashboard = table.new(position.top_right, 2, 5, border_width=1)
if barstate.islast
    if showDashboard
        string state = bullExpansion ? "Expansion +" : bearExpansion ? "Expansion -" : highEffortLowResult ? "High effort / low result" : lowEffortHighResult ? "Low effort / high result" : quietCompression ? "Quiet compression" : "Unclassified"
        color stateColor = bullExpansion ? color.teal : bearExpansion ? color.orange : highEffortLowResult ? color.purple : lowEffortHighResult ? color.blue : color.gray
        table.cell(dashboard, 0, 0, "VRCC", bgcolor=color.new(color.black, 10), text_color=color.white)
        table.cell(dashboard, 1, 0, state, bgcolor=color.new(stateColor, 15), text_color=color.white)
        table.cell(dashboard, 0, 1, "Volume z", text_color=color.silver)
        table.cell(dashboard, 1, 1, str.tostring(volumeZ, "#.##"), text_color=color.white)
        table.cell(dashboard, 0, 2, "Range z", text_color=color.silver)
        table.cell(dashboard, 1, 2, str.tostring(rangeZ, "#.##"), text_color=color.white)
        table.cell(dashboard, 0, 3, "Close location", text_color=color.silver)
        table.cell(dashboard, 1, 3, str.tostring(closeLocation * 100.0, "#") + "%", text_color=color.white)
        table.cell(dashboard, 0, 4, "Bar status", text_color=color.silver)
        table.cell(dashboard, 1, 4, barstate.isconfirmed ? "Confirmed" : "Developing", text_color=barstate.isconfirmed ? color.white : color.yellow)
    else
        table.clear(dashboard, 0, 0, 1, 4)
````
