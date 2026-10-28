# Volume Weighted Outlier Bands [Pineify]

- url: https://www.tradingview.com/script/aKdVMbMx-Volume-Weighted-Outlier-Bands-Pineify/
- type: indicator
- pine_id: PUB;45cd52dfe02a45649fd9dfec1e9935ba
- version: 1.0

## Description

[b]Overview[/b]
This robust deviation overlay tests whether relative participation supports an unusual move. A prior-window median and MAD set the baseline; a two-level field narrows on strong volume and widens on thin volume.

[b]Problem Definition[/b]
Standard-deviation bands treat every observation alike. A low-volume wick and a high-volume close can receive the same z-score despite different participation. Mean and deviation also move toward the outlier, changing the yardstick during the event. Fixed bands may hide a supported displacement or exaggerate a thin spike. The task is not to predict reversion, but to separate robust price distance from participation evidence.

[b]Design Rationale[/b]
The preceding window's median resists one unusual price, while median absolute deviation supplies a matching scale. Excluding the current bar preserves one comparison. A volume-weighted average was rejected because it moves the center without classifying participation. Current volume is instead divided by prior median volume, clipped, and square-rooted. This bounded factor scales residual evidence and displayed thresholds without letting one volume burst collapse the field. A coverage gate rejects incomplete histories.

[b]Key Features[/b]
[list]
[*]Prior-window median center and MAD scale.

[*]Relative-volume weighting of score and price bands.

[*]Confirmed supported-outlier and thin-spike states.

[*]Optional markers, wash, bar color, and dashboard.

[*]Confirmed return-to-center alert.
[/list]

[b]How It Works[/b]
Prior completed prices define the median. Their median absolute distance, multiplied by 1.4826, defines robust scale; a near-zero result blocks analysis.

Prior median volume and usable-sample coverage form the participation baseline. Current volume divided by that median is clipped and square-rooted. Raw robust Z is price distance divided by scale; weighted Z multiplies it by this weight.

Thresholds return to price space by dividing scale distance by the same weight. High participation narrows required distance; thin participation widens it. A supported event needs weighted Z beyond the outer threshold and volume above its floor. A thin spike needs raw Z beyond that threshold and volume below its ceiling. Confirmed state persists until another event or a weighted center return. Warm-up, missing volume, low coverage, or degenerate MAD yields no classification. Open bars can move diagnostics, but not states or alerts.

[b]How Multiple Indicators Work Together[/b]
The components form one chain: median defines location, MAD defines comparable distance, median volume defines normal participation, and the bounded weight links volume to residual. Confirmed memory preserves event type. Removing any stage changes the question: distance becomes unstable, loses scale, collapses thin and supported moves, or treats intrabar touches as durable.

[b]Trading Ideas and Insights[/b]
Read the field before markers. Cyan and magenta show participation-adjusted upper and lower distance. Contraction on strong volume means a moderate move carries more participation evidence; expansion on thin volume demands a larger move. Supported states can frame acceptance review and orange thin states can frame rejection review. Neither predicts the next return, and an outlier is not automatically a reversal setup.

[b]Unique Aspects[/b]
Relative volume does not merely recolor a fixed envelope. It changes weighted Z and maps the thresholds back to dynamic price boundaries. Raw Z remains separate, so a large thin-volume spike is visible even when weighted evidence discounts it. The model preserves two questions—how unusual is price, and how much participation supports it—then stores their confirmed outcome.

[b]How to Use[/b]
[list=1]
[*]Choose a lookback representing the local distribution and intended horizon.

[*]Verify consistent volume and wait for coverage and warm-up gates.

[*]Read center, context, and outer bands as a hierarchy; use markers for confirmed type.

[*]Configure supported, thin-spike, or center-return alerts at the desired frequency.

[*]Compare several regimes before assigning discretionary meaning.
[/list]

[b]Customization[/b]
Lookback changes memory and cost. Context and Outlier thresholds set visual and event distance; Center Return controls reset. Thin Ceiling and Supported Floor separate participation classes, not universal truths. Weight limits cap field expansion and contraction. Minimum Coverage rejects sparse data. Display switches hide secondary layers without changing calculations or alerts.

[b]Assumptions and Limitations[/b]
Volume must be meaningful and comparable across the window. Tick volume, synthetic symbols, session changes, contract rolls, missing bars, and unusual auctions can break that assumption. Median and MAD lag regime shifts; near-zero MAD suppresses output. Inputs or loaded history recalculate past values.

Price and volume evolve intrabar, so bands, scores, and dashboard values can change before close. States, markers, and alerts update only on confirmed bars. The model sees aggregate volume, not bid/ask flow, liquidity, or execution. It supplies no target, stop, sizing, backtest, probability, profitability claim, or guarantee of reversion. Gaps may cross several levels, and clipping ignores volume magnitude beyond its limits.

[b]Conclusion[/b]
The overlay keeps robust price distance and participation evidence distinct, then reconnects them through a price-space field and confirmed memory.

## Source Code

````pine
//@version=6
indicator("Volume Weighted Outlier Bands [Pineify]", overlay = true, max_labels_count = 100)

// Calculation inputs
string GROUP_CALC = "Robust Model"
int lookback = input.int(55, "Robust Lookback", minval = 20, maxval = 200, group = GROUP_CALC)
float priceSource = input.source(hlc3, "Price Source", group = GROUP_CALC)
float innerZInput = input.float(1.75, "Context Threshold", minval = 0.75, maxval = 4.0, step = 0.25, group = GROUP_CALC)
float outerZInput = input.float(3.00, "Outlier Threshold", minval = 1.50, maxval = 6.0, step = 0.25, group = GROUP_CALC)
float returnZInput = input.float(0.75, "Center Return Threshold", minval = 0.10, maxval = 2.0, step = 0.05, group = GROUP_CALC)

// Participation inputs
string GROUP_VOLUME = "Participation Weight"
float thinVolume = input.float(0.70, "Thin Volume Ceiling", minval = 0.10, maxval = 1.0, step = 0.05, group = GROUP_VOLUME)
float supportedVolume = input.float(1.20, "Supported Volume Floor", minval = 1.0, maxval = 4.0, step = 0.05, group = GROUP_VOLUME)
float minVolumeWeight = input.float(0.35, "Minimum Volume Weight", minval = 0.10, maxval = 1.0, step = 0.05, group = GROUP_VOLUME)
float maxVolumeWeight = input.float(3.00, "Maximum Volume Weight", minval = 1.0, maxval = 8.0, step = 0.25, group = GROUP_VOLUME)
float minimumCoverage = input.float(0.85, "Minimum Volume Coverage", minval = 0.50, maxval = 1.0, step = 0.05, group = GROUP_VOLUME)

// Display inputs
string GROUP_DISPLAY = "Display"
bool showBandField = input.bool(true, "Show Band Field", group = GROUP_DISPLAY)
bool showEventMarkers = input.bool(true, "Show Event Markers", group = GROUP_DISPLAY)
bool showStateWash = input.bool(true, "Show State Wash", group = GROUP_DISPLAY)
bool colorBars = input.bool(false, "Color Bars by Confirmed State", group = GROUP_DISPLAY)
bool showDashboard = input.bool(true, "Show Dashboard", group = GROUP_DISPLAY)

f_clamp(float value, float floor, float ceiling) =>
    math.max(floor, math.min(ceiling, value))

f_window_median(float source, int length) =>
    array<float> values = array.new<float>()
    for index = 0 to length - 1
        float sample = source[index]
        if not na(sample)
            array.push(values, sample)
    float result = na
    int count = array.size(values)
    if count == length
        array.sort(values)
        int middle = int(math.floor(count * 0.5))
        result := count % 2 == 1 ? array.get(values, middle) : (array.get(values, middle - 1) + array.get(values, middle)) * 0.5
    result

f_window_mad(float source, int length, float center) =>
    array<float> deviations = array.new<float>()
    if not na(center)
        for index = 0 to length - 1
            float sample = source[index]
            if not na(sample)
                array.push(deviations, math.abs(sample - center))
    float result = na
    int count = array.size(deviations)
    if count == length
        array.sort(deviations)
        int middle = int(math.floor(count * 0.5))
        result := count % 2 == 1 ? array.get(deviations, middle) : (array.get(deviations, middle - 1) + array.get(deviations, middle)) * 0.5
    result

// The reference window ends on the previous bar so the current observation cannot pull its own center or scale.
float robustCenter = f_window_median(priceSource[1], lookback)
float rawMad = f_window_mad(priceSource[1], lookback, robustCenter)
float robustScale = rawMad * 1.4826
float volumeMedian = f_window_median(volume[1], lookback)
float volumeCoverage = ta.sma(not na(volume[1]) and volume[1] > 0 ? 1.0 : 0.0, lookback)

bool priceReady = bar_index > lookback and not na(robustCenter) and not na(robustScale) and robustScale > syminfo.mintick * 0.1
bool volumeReady = not na(volume) and volume > 0 and not na(volumeMedian) and volumeMedian > 0 and not na(volumeCoverage) and volumeCoverage >= minimumCoverage
bool analysisReady = priceReady and volumeReady

float relativeVolume = volumeReady ? volume / volumeMedian : na
float boundedRelativeVolume = volumeReady ? f_clamp(relativeVolume, minVolumeWeight, maxVolumeWeight) : na
float participationWeight = volumeReady ? math.sqrt(boundedRelativeVolume) : na

float innerZ = math.min(innerZInput, outerZInput - 0.25)
float returnZ = math.min(returnZInput, innerZ - 0.10)
float rawRobustZ = analysisReady ? (priceSource - robustCenter) / robustScale : na
float weightedZ = analysisReady ? rawRobustZ * participationWeight : na

// Translating score thresholds back into price space makes the field narrow with strong participation and widen with thin participation.
float innerDistance = analysisReady ? robustScale * innerZ / participationWeight : na
float outerDistance = analysisReady ? robustScale * outerZInput / participationWeight : na
float innerUpper = robustCenter + innerDistance
float innerLower = robustCenter - innerDistance
float outerUpper = robustCenter + outerDistance
float outerLower = robustCenter - outerDistance

bool supportedUpperCandidate = analysisReady and weightedZ >= outerZInput and relativeVolume >= supportedVolume
bool supportedLowerCandidate = analysisReady and weightedZ <= -outerZInput and relativeVolume >= supportedVolume
bool thinUpperCandidate = analysisReady and rawRobustZ >= outerZInput and relativeVolume <= thinVolume
bool thinLowerCandidate = analysisReady and rawRobustZ <= -outerZInput and relativeVolume <= thinVolume
bool centerCandidate = analysisReady and math.abs(weightedZ) <= returnZ

// Confirmed state memory prevents developing-bar classifications from becoming persistent events.
var int confirmedState = 0
int stateBeforeUpdate = confirmedState
if barstate.isconfirmed
    if not analysisReady
        confirmedState := 0
    else if supportedUpperCandidate
        confirmedState := 1
    else if supportedLowerCandidate
        confirmedState := -1
    else if thinUpperCandidate
        confirmedState := 2
    else if thinLowerCandidate
        confirmedState := -2
    else if centerCandidate
        confirmedState := 0

bool newSupportedUpper = barstate.isconfirmed and confirmedState == 1 and stateBeforeUpdate != 1
bool newSupportedLower = barstate.isconfirmed and confirmedState == -1 and stateBeforeUpdate != -1
bool newThinUpper = barstate.isconfirmed and confirmedState == 2 and stateBeforeUpdate != 2
bool newThinLower = barstate.isconfirmed and confirmedState == -2 and stateBeforeUpdate != -2
bool returnedToCenter = barstate.isconfirmed and confirmedState == 0 and stateBeforeUpdate != 0 and analysisReady

color upColor = color.rgb(0, 188, 212)
color downColor = color.rgb(216, 27, 96)
color thinColor = color.rgb(255, 152, 0)
color neutralColor = color.rgb(120, 130, 145)

centerPlot = plot(showBandField and priceReady ? robustCenter : na, "Prior-window robust center", color = color.new(neutralColor, 10), linewidth = 2)
innerUpperPlot = plot(showBandField and analysisReady ? innerUpper : na, "Upper context band", color = color.new(upColor, 48), linewidth = 1)
outerUpperPlot = plot(showBandField and analysisReady ? outerUpper : na, "Upper outlier band", color = color.new(upColor, 8), linewidth = 2)
innerLowerPlot = plot(showBandField and analysisReady ? innerLower : na, "Lower context band", color = color.new(downColor, 48), linewidth = 1)
outerLowerPlot = plot(showBandField and analysisReady ? outerLower : na, "Lower outlier band", color = color.new(downColor, 8), linewidth = 2)

fill(outerUpperPlot, innerUpperPlot, color = showBandField ? color.new(upColor, 86) : na, title = "Upper participation field")
fill(innerUpperPlot, centerPlot, color = showBandField ? color.new(upColor, 94) : na, title = "Upper center field")
fill(centerPlot, innerLowerPlot, color = showBandField ? color.new(downColor, 94) : na, title = "Lower center field")
fill(innerLowerPlot, outerLowerPlot, color = showBandField ? color.new(downColor, 86) : na, title = "Lower participation field")

color stateWash = confirmedState == 1 ? color.new(upColor, 92) : confirmedState == -1 ? color.new(downColor, 92) : math.abs(confirmedState) == 2 ? color.new(thinColor, 92) : na
bgcolor(showStateWash ? stateWash : na, title = "Confirmed outlier state wash")

plotshape(showEventMarkers and newSupportedUpper, title = "Supported upper outlier", style = shape.triangleup, location = location.abovebar, color = upColor, size = size.tiny, text = "V+")
plotshape(showEventMarkers and newSupportedLower, title = "Supported lower outlier", style = shape.triangledown, location = location.belowbar, color = downColor, size = size.tiny, text = "V-")
plotshape(showEventMarkers and newThinUpper, title = "Thin upper spike", style = shape.xcross, location = location.abovebar, color = thinColor, size = size.tiny, text = "T")
plotshape(showEventMarkers and newThinLower, title = "Thin lower spike", style = shape.xcross, location = location.belowbar, color = thinColor, size = size.tiny, text = "T")
plotshape(showEventMarkers and returnedToCenter, title = "Return to robust center", style = shape.circle, location = location.abovebar, color = neutralColor, size = size.tiny)

color confirmedBarColor = confirmedState == 1 ? upColor : confirmedState == -1 ? downColor : math.abs(confirmedState) == 2 ? thinColor : na
barcolor(colorBars ? confirmedBarColor : na, title = "Confirmed state bar color")

string stateText = not analysisReady ? "WARMUP / NO VOLUME" : confirmedState == 1 ? "SUPPORTED UPPER" : confirmedState == -1 ? "SUPPORTED LOWER" : confirmedState == 2 ? "THIN UPPER" : confirmedState == -2 ? "THIN LOWER" : "BALANCED"
color stateColor = confirmedState == 1 ? upColor : confirmedState == -1 ? downColor : math.abs(confirmedState) == 2 ? thinColor : neutralColor

var table dashboard = table.new(position.top_right, 2, 5, border_width = 1)
if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "VWOB", text_color = color.white, bgcolor = color.new(stateColor, 25))
        table.cell(dashboard, 1, 0, stateText, text_color = color.white, bgcolor = color.new(stateColor, 25))
        table.cell(dashboard, 0, 1, "Weighted Z", text_color = chart.fg_color)
        table.cell(dashboard, 1, 1, analysisReady ? str.tostring(weightedZ, "#.##") : "n/a", text_color = chart.fg_color)
        table.cell(dashboard, 0, 2, "Raw Z", text_color = chart.fg_color)
        table.cell(dashboard, 1, 2, analysisReady ? str.tostring(rawRobustZ, "#.##") : "n/a", text_color = chart.fg_color)
        table.cell(dashboard, 0, 3, "Relative Volume", text_color = chart.fg_color)
        table.cell(dashboard, 1, 3, volumeReady ? str.tostring(relativeVolume, "#.##x") : "n/a", text_color = chart.fg_color)
        table.cell(dashboard, 0, 4, "Coverage", text_color = chart.fg_color)
        table.cell(dashboard, 1, 4, not na(volumeCoverage) ? str.tostring(volumeCoverage * 100.0, "#") + "%" : "n/a", text_color = chart.fg_color)
    else
        table.clear(dashboard, 0, 0, 1, 4)

alertcondition(newSupportedUpper, "Supported upper outlier", "Volume Weighted Outlier Bands confirmed an upper deviation with participation support.")
alertcondition(newSupportedLower, "Supported lower outlier", "Volume Weighted Outlier Bands confirmed a lower deviation with participation support.")
alertcondition(newThinUpper or newThinLower, "Thin-volume spike", "Volume Weighted Outlier Bands confirmed a robust price outlier on thin relative volume.")
alertcondition(returnedToCenter, "Return to robust center", "Volume Weighted Outlier Bands confirmed a return to its participation-adjusted center zone.")
````
