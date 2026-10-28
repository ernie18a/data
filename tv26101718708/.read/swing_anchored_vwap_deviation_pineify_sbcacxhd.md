# Swing Anchored VWAP Deviation [Pineify]

- url: https://www.tradingview.com/script/SBcACxHd-Swing-Anchored-VWAP-Deviation-Pineify/
- type: indicator
- pine_id: PUB;eea69aecc9f4407e96a6695b9aa09fa3
- version: 1.0

## Description

[b]Swing Anchored VWAP Deviation [Pineify][/b]

[b]Overview[/b]
Swing Anchored VWAP Deviation maps volume-weighted equilibrium after a swing. Its line, field, marker, and dashboard encode origin, dispersion, zone, and volume status.
[b]Problem Definition[/b]
Session VWAP resets by time even when the boundary is unrelated to a contextual swing. Manual anchors require hindsight; naive pivot automation can reset on small zigzags or imply knowledge before confirmation. Fixed-width bands also equate distances across tight and dispersed auctions. The invariant needed is a confirmed anchor, statistics beginning at the real swing without an early signal, and distance scaled by post-anchor volume.
[b]Design Rationale[/b]
Confirmed left/right pivots provide structural origins. ATR-scaled distance from the latest opposing pivot filters small candidates; zero disables the gate. After acceptance, a finite replay covers pivot through confirmation, retaining the real statistical origin while delaying visible state until it is knowable. Online weighted moments reduce cancellation versus squared-price sums. Backward plots were rejected as misleading, and reset bars cannot trigger crosses caused only by the new frame.
[b]Key Features[/b]
[list]
[*]Confirmed swing anchors with an ATR prominence gate.
[*]Online volume-weighted mean, variance, and nested bands.
[*]Stable zone colors with optional markers, bar colors, wash, and dashboard.
[*]Close-confirmed crosses and outer entries that ignore reset bars.
[/list]

[b]How It Works[/b]
HLC3 is the default source. On each closed bar, pivots use left/right windows. Distance from the latest opposing pivot is divided by ATR at the pivot bar; if both types confirm, the larger score wins.

Acceptance clears state and processes pivot through confirmation in order. Valid volume weights each sample. Online updates produce total weight, mean, and second moment; deviation is the square root of moment divided by weight. Later bars extend state once. Missing volume has zero weight, with no fallback.

Bands are AVWAP plus or minus selected deviation multiples. Close-to-AVWAP distance divided by deviation supplies sigma; a one-tick floor prevents zero division. Cyan/blue means positive deviation, orange/pink negative, and gray equilibrium. Low anchors are cyan and highs amber. Markers are placed on the swing after confirmation; bands start or jump at confirmation and never backfill.
[b]How Multiple Indicators Work Together[/b]
This is one causal chain, not unrelated signals. Pivot confirmation defines origin; the ATR gate decides replacement; volume weights define equilibrium; weighted variance normalizes distance; and zone state drives visuals and alerts. Without confirmation there is hindsight ambiguity, without the gate there is reset noise, without volume equilibrium changes meaning, and without dispersion raw distances are incomparable.

[b]Trading Ideas and Insights[/b]
Treat AVWAP as context for post-swing acceptance or rejection, not an entry command. Sustained closes on one side show where value is forming. An outer visit is large relative to volume-weighted dispersion, but does not choose continuation over mean reversion. Compare it with structure, liquidity, and holding period. Alerts are observation prompts, not orders or performance claims.

[b]Unique Aspects[/b]
The contribution is confirmation-to-origin replay. Common automation either starts at the later confirmation bar or draws pivot history where the pivot was unknowable. This state includes genuine pivot-to-confirmation observations, yet changes visuals and alerts only after confirmation. Online weighted moments keep center and dispersion together; the opposing-swing gate limits trivial resets; reset suppression separates price movement from a changed frame.

[b]How to Use[/b]
Begin with liquid stocks, futures, or crypto on roughly 15-minute to daily charts. Require Volume Weight ACTIVE in the dashboard. Read AVWAP as current equilibrium, the inner field as ordinary variation, and outer fields as larger normalized displacement. H or L marks the source swing but appears only after the right window completes. Configure each cross and outer-entry alert separately.

[b]Customization[/b]
Left and Right Bars set swing scale and confirmation delay; larger values usually mean fewer, later anchors. Minimum Opposing Swing Distance filters in ATR units: raising it extends anchor life, while zero accepts all candidates. Source selects the weighted sample. Inner choices are 0.5, 1.0, and 1.5; outer choices are 2.0, 2.5, and 3.0. Field, markers, extreme wash, bar colors, and dashboard are independent switches, leaving AVWAP readable alone.

[b]Assumptions and Limitations[/b]
Pivots arrive after Right Bars; marker location is not discovery time. The realtime bar can change AVWAP, variance, bands, colors, and dashboard, while anchors and alerts require a close. Volume must be reliable: absent, synthetic, delayed, or inconsistent data can remove output or distort the center. Results are path- and parameter-dependent because each anchor replaces the prior distribution. ATR gating can miss small turns or admit noisy large ones. Deviation is descriptive, not a probability guarantee, especially for skewed data. The script does not infer orders, profitability, or future price.
[b]Conclusion[/b]
This indicator connects confirmed structure with volume-weighted distance while keeping timing auditable. Statistics originate at the swing, become visible only after confirmation, and expose volume, latency, reset, and realtime limits.

## Source Code

````pine
//@version=6
indicator("Swing Anchored VWAP Deviation [Pineify]", overlay = true, max_labels_count = 100)

string groupAnchor = "Confirmed Swing Anchors"
sourceInput = input.source(hlc3, "Weighted Price Source", group = groupAnchor)
int pivotLeft = input.int(5, "Pivot Left Bars", minval = 2, maxval = 20, group = groupAnchor)
int pivotRight = input.int(5, "Pivot Right Bars", minval = 2, maxval = 20, group = groupAnchor)
int atrLength = input.int(14, "Prominence ATR Length", minval = 2, maxval = 100, group = groupAnchor)
float minimumSwingAtr = input.float(1.0, "Minimum Opposing Swing Distance (ATR)", minval = 0.0, maxval = 10.0, step = 0.25, group = groupAnchor)

string groupBands = "Volume-Weighted Deviation"
float innerMultiplier = input.float(1.0, "Inner Deviation", options = [0.5, 1.0, 1.5], group = groupBands)
float outerMultiplier = input.float(2.0, "Outer Deviation", options = [2.0, 2.5, 3.0], group = groupBands)

string groupVisual = "Visual System"
bool showBands = input.bool(true, "Show Deviation Field", group = groupVisual)
bool showAnchorMarkers = input.bool(true, "Show Confirmed Anchor Markers", group = groupVisual)
bool showExtremeWash = input.bool(true, "Show Outer-Zone Background", group = groupVisual)
bool colorBars = input.bool(false, "Color Bars by Deviation Zone", group = groupVisual)
bool showDashboard = input.bool(true, "Show Anchor Dashboard", group = groupVisual)

f_weightedUpdate(float currentMean, float currentM2, float currentWeight, float sample, float sampleWeight) =>
    float nextMean = currentMean
    float nextM2 = currentM2
    float nextWeight = currentWeight
    if sampleWeight > 0.0 and not na(sample)
        nextWeight := currentWeight + sampleWeight
        if currentWeight <= 0.0 or na(currentMean)
            nextMean := sample
            nextM2 := 0.0
        else
            float delta = sample - currentMean
            nextMean := currentMean + sampleWeight / nextWeight * delta
            nextM2 := currentM2 + sampleWeight * delta * (sample - nextMean)
    [nextMean, nextM2, nextWeight]

float atr = ta.atr(atrLength)
float confirmedHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float confirmedLow = ta.pivotlow(low, pivotLeft, pivotRight)
float pivotAtr = atr[pivotRight]

var float lastConfirmedHigh = na
var float lastConfirmedLow = na
var float weightedMean = na
var float weightedM2 = 0.0
var float totalWeight = 0.0
var int anchorBar = na
var float anchorPrice = na
var int anchorType = 0

bool highCandidate = barstate.isconfirmed and not na(confirmedHigh)
bool lowCandidate = barstate.isconfirmed and not na(confirmedLow)
float highProminence = highCandidate and not na(lastConfirmedLow) and pivotAtr > 0.0 ? (confirmedHigh - lastConfirmedLow) / pivotAtr : highCandidate ? 1000000.0 : na
float lowProminence = lowCandidate and not na(lastConfirmedHigh) and pivotAtr > 0.0 ? (lastConfirmedHigh - confirmedLow) / pivotAtr : lowCandidate ? 1000000.0 : na
bool highAccepted = highCandidate and (na(lastConfirmedLow) or highProminence >= minimumSwingAtr)
bool lowAccepted = lowCandidate and (na(lastConfirmedHigh) or lowProminence >= minimumSwingAtr)
int candidateType = highAccepted and lowAccepted ? (highProminence >= lowProminence ? 1 : -1) : highAccepted ? 1 : lowAccepted ? -1 : 0
float candidatePrice = candidateType == 1 ? confirmedHigh : candidateType == -1 ? confirmedLow : na
bool newAnchor = candidateType != 0

if newAnchor
    weightedMean := na
    weightedM2 := 0.0
    totalWeight := 0.0
    for sequence = 0 to pivotRight
        int historyOffset = pivotRight - sequence
        float sampleWeight = math.max(nz(volume[historyOffset]), 0.0)
        float sample = sourceInput[historyOffset]
        [nextMean, nextM2, nextWeight] = f_weightedUpdate(weightedMean, weightedM2, totalWeight, sample, sampleWeight)
        weightedMean := nextMean
        weightedM2 := nextM2
        totalWeight := nextWeight
    anchorBar := bar_index - pivotRight
    anchorPrice := candidatePrice
    anchorType := candidateType
    if showAnchorMarkers
        label.new(anchorBar, anchorPrice, anchorType == -1 ? "L" : "H", xloc = xloc.bar_index, yloc = yloc.price, style = anchorType == -1 ? label.style_label_up : label.style_label_down, color = anchorType == -1 ? color.rgb(6, 182, 212) : color.rgb(245, 158, 11), textcolor = color.white, size = size.tiny)
else if not na(anchorBar)
    float sampleWeight = math.max(nz(volume), 0.0)
    [nextMean, nextM2, nextWeight] = f_weightedUpdate(weightedMean, weightedM2, totalWeight, sourceInput, sampleWeight)
    weightedMean := nextMean
    weightedM2 := nextM2
    totalWeight := nextWeight

if highCandidate
    lastConfirmedHigh := confirmedHigh
if lowCandidate
    lastConfirmedLow := confirmedLow

bool dataReady = not na(anchorBar) and totalWeight > 0.0 and not na(weightedMean)
float weightedVariance = dataReady ? math.max(weightedM2 / totalWeight, 0.0) : na
float weightedDeviation = dataReady ? math.sqrt(weightedVariance) : na
float deviationFloor = math.max(nz(weightedDeviation), syminfo.mintick)
float deviationZ = dataReady ? (close - weightedMean) / deviationFloor : na
float innerUpper = dataReady ? weightedMean + weightedDeviation * innerMultiplier : na
float innerLower = dataReady ? weightedMean - weightedDeviation * innerMultiplier : na
float outerUpper = dataReady ? weightedMean + weightedDeviation * outerMultiplier : na
float outerLower = dataReady ? weightedMean - weightedDeviation * outerMultiplier : na

color neutralColor = color.rgb(148, 163, 184)
color positiveColor = color.rgb(34, 211, 238)
color positiveExtreme = color.rgb(59, 130, 246)
color negativeColor = color.rgb(251, 146, 60)
color negativeExtreme = color.rgb(244, 63, 94)
color lowAnchorColor = color.rgb(6, 182, 212)
color highAnchorColor = color.rgb(245, 158, 11)
color anchorColor = anchorType == -1 ? lowAnchorColor : anchorType == 1 ? highAnchorColor : neutralColor
int fieldTransparency = dataReady ? int(math.max(78.0, 94.0 - math.min(math.abs(deviationZ), outerMultiplier) * 5.0)) : 100

outerUpperPlot = plot(showBands ? outerUpper : na, "Upper Outer Deviation", color = color.new(positiveExtreme, 48), linewidth = 1)
innerUpperPlot = plot(showBands ? innerUpper : na, "Upper Inner Deviation", color = color.new(positiveColor, 64), linewidth = 1)
innerLowerPlot = plot(showBands ? innerLower : na, "Lower Inner Deviation", color = color.new(negativeColor, 64), linewidth = 1)
outerLowerPlot = plot(showBands ? outerLower : na, "Lower Outer Deviation", color = color.new(negativeExtreme, 48), linewidth = 1)
fill(outerUpperPlot, innerUpperPlot, color = showBands ? color.new(positiveExtreme, fieldTransparency) : na, title = "Upper Deviation Field")
fill(innerUpperPlot, innerLowerPlot, color = showBands ? color.new(neutralColor, 94) : na, title = "Weighted Equilibrium Field")
fill(innerLowerPlot, outerLowerPlot, color = showBands ? color.new(negativeExtreme, fieldTransparency) : na, title = "Lower Deviation Field")
plot(dataReady ? weightedMean : na, "Swing Anchored VWAP", color = anchorColor, linewidth = 3)

bool aboveOuter = dataReady and close > outerUpper
bool belowOuter = dataReady and close < outerLower
color zoneColor = not dataReady ? na : aboveOuter ? positiveExtreme : belowOuter ? negativeExtreme : deviationZ >= innerMultiplier ? positiveColor : deviationZ <= -innerMultiplier ? negativeColor : neutralColor
bgcolor(showExtremeWash and aboveOuter ? color.new(positiveExtreme, 92) : showExtremeWash and belowOuter ? color.new(negativeExtreme, 92) : na, title = "Outer Deviation Wash")
barcolor(colorBars ? color.new(zoneColor, 16) : na, title = "Deviation Zone Bar Color")

string anchorText = anchorType == -1 ? "SWING LOW" : anchorType == 1 ? "SWING HIGH" : "WAITING"
string zoneText = not dataReady ? "NO VOLUME DATA" : aboveOuter ? "ABOVE OUTER" : belowOuter ? "BELOW OUTER" : deviationZ >= innerMultiplier ? "ABOVE INNER" : deviationZ <= -innerMultiplier ? "BELOW INNER" : "EQUILIBRIUM"
int anchorAge = not na(anchorBar) ? bar_index - anchorBar : 0

var table dashboard = table.new(position.top_right, 2, 5, frame_color = color.new(neutralColor, 52), frame_width = 1, border_color = color.new(neutralColor, 78), border_width = 1)
if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "SWING AVWAP", text_color = color.white, bgcolor = color.new(anchorColor, 12), text_size = size.small)
        table.cell(dashboard, 1, 0, anchorText, text_color = color.white, bgcolor = color.new(anchorColor, 12), text_size = size.small)
        table.cell(dashboard, 0, 1, "Zone", text_color = neutralColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 1, 1, zoneText, text_color = dataReady ? zoneColor : neutralColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 0, 2, "Deviation", text_color = neutralColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 1, 2, dataReady ? str.tostring(deviationZ, "#.00") + " sigma" : "NA", text_color = dataReady ? zoneColor : neutralColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 0, 3, "Anchor Age", text_color = neutralColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 1, 3, not na(anchorBar) ? str.tostring(anchorAge) + " bars" : "NA", text_color = anchorColor, bgcolor = color.new(color.black, 82))
        table.cell(dashboard, 0, 4, "Volume Weight", text_color = neutralColor, bgcolor = color.new(color.black, 86))
        table.cell(dashboard, 1, 4, totalWeight > 0.0 ? "ACTIVE" : "UNAVAILABLE", text_color = totalWeight > 0.0 ? positiveColor : negativeExtreme, bgcolor = color.new(color.black, 86))
    else
        table.clear(dashboard, 0, 0, 1, 4)

bool rawCrossAbove = ta.crossover(close, weightedMean)
bool rawCrossBelow = ta.crossunder(close, weightedMean)
bool rawEnterUpper = ta.crossover(close, outerUpper)
bool rawEnterLower = ta.crossunder(close, outerLower)
bool crossAbove = barstate.isconfirmed and dataReady and not newAnchor and rawCrossAbove
bool crossBelow = barstate.isconfirmed and dataReady and not newAnchor and rawCrossBelow
bool enterUpper = barstate.isconfirmed and dataReady and not newAnchor and rawEnterUpper
bool enterLower = barstate.isconfirmed and dataReady and not newAnchor and rawEnterLower

alertcondition(crossAbove, "Price Crossed Above Swing AVWAP", "Price confirmed a cross above the active swing-anchored VWAP.")
alertcondition(crossBelow, "Price Crossed Below Swing AVWAP", "Price confirmed a cross below the active swing-anchored VWAP.")
alertcondition(enterUpper, "Price Entered Upper Outer Deviation", "Price confirmed entry above the upper outer volume-weighted deviation band.")
alertcondition(enterLower, "Price Entered Lower Outer Deviation", "Price confirmed entry below the lower outer volume-weighted deviation band.")
````
