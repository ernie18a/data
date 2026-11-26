# Reaction Weighted Support Resistance [Pineify]

- url: https://www.tradingview.com/script/mi7UPDe5-Reaction-Weighted-Support-Resistance-Pineify/
- type: indicator
- pine_id: PUB;5c994df4e855482e90aa9b7fabf0ef64
- version: 1.0

## Description

[b]Reaction Weighted Support Resistance [Pineify][/b]

[b]Overview[/b]
Builds ATR-scaled support and resistance zones from confirmed swing pivots. Opacity encodes decayed completed reactions and bounded relative-volume context. It organizes chart evidence without forecasting price or performance.

[b]Problem Definition[/b]
A common baseline draws one line per pivot and adds strength for every return. It scores shallow drift and decisive rejection equally, while old tests can dominate after conditions change. The map becomes crowded, and counts do not explain what happened after contact. The required invariant is a bounded set of areas weighted by subsequent displacement, participation context, and recency without assuming repetition.

[b]Design Rationale[/b]
Confirmed pivots replace immediate extrema; zones begin at confirmation, not at the earlier swing bar. ATR width replaces fixed ticks, but geometry is frozen from known volatility. Nearby same-side zones merge only under a height cap. Touch count was rejected: entry opens a finite window, favorable movement is normalized by touch-time ATR, and bounded volume adjusts credibility without claiming directional flow. Decay fades stale reactions. The tradeoff is lag in exchange for auditable path memory.

[b]Key Features[/b]
[list]
[*]Confirmed pivot zones with ATR geometry.

[*]Completed reaction scoring, volume context, and half-life decay.

[*]Width-limited merging and bounded zone capacity.

[*]Close invalidation, strength opacity, optional visuals, dashboard, and alerts.
[/list]

[b]How It Works[/b]
The engine reads chart OHLC, ATR, and average volume. Confirmed pivot lows create support and highs create resistance. Width is a fraction of pivot-time ATR; signals are not shifted backward.

A same-side candidate merges only below the height limit. Its center is score-weighted, so weak evidence cannot freely drag an established zone. Otherwise it is added; capacity removes the weakest.

A completed entry after cooldown stores ATR and bounded volume credibility, then tracks the best favorable extreme. Support measures upward displacement; resistance measures downward displacement. The result is floored at zero, ATR-normalized, capped, and volume-weighted. Missing volume uses a neutral fallback.

Each completed bar applies half-life decay; a saturating transform maps score to opacity. A close beyond the zone and ATR buffer invalidates it. Warm-up needs ATR, optional volume average, and pivot confirmation. Unclosed bars do not mutate state or fire alerts.

[b]How Multiple Indicators Work Together[/b]
The components form one chain: pivots supply location, ATR supplies scale, the path window separates reaction from touch, volume changes confidence, decay tests recency, and invalidation bounds life. Without the window this becomes touch counting; without decay old history dominates; without ATR markets lose comparable units. The boxes expose the combined state rather than stacking unrelated signals.

[b]Trading Ideas and Insights[/b]
Compare areas instead of assuming they will hold. Opaque support means prior completed visits produced larger, more recent upward reactions under this model; resistance is symmetric. Observe approach, overlap, departure, and confirmed failure. Entry alerts focus review above the strength threshold, while invalidation ends stored context. They do not define direction, size, execution, return, or reversal probability.

[b]Unique Aspects[/b]
Each touch creates a bounded episode whose later displacement, touch-time volatility, volume credibility, and age update one state. Merging is score-weighted and width-limited. Teal and rose encode role, opacity encodes strength, amber marks failure, and the dashboard exposes scores and evaluated touches. This is an independent implementation; retrieved descriptions defined only the baseline, and no source code was reused.

[b]How to Use[/b]
[list=1]
[*]Choose pivot lengths for the intended swing horizon.

[*]Set width and merge limits so boxes remain useful areas.

[*]Read opacity with score and evaluated touches; faint zones have little evidence.

[*]Use alerts as review prompts with separate execution and risk rules.

[*]Review several market regimes before using the context.
[/list]

[b]Customization[/b]
Short pivot windows create more candidates; long windows are selective and slower. Width and merge controls set geometry. The evaluation window favors immediate or slower reactions. Half-life controls memory, not signal speed. The invalidation buffer sets tolerated close penetration. Volume length changes its baseline; alert strength changes qualification. Secondary markers, bar colors, and dashboard can be disabled.

[b]Assumptions and Limitations[/b]
Pivots are delayed. ATR gaps can distort geometry. Forex or synthetic feeds may supply tick volume or no usable series, so fallback removes participation discrimination. Favorable extremes summarize path outcome, not order flow, causality, liquidity, or execution. Results depend on settings; capacity can evict weak areas. Close invalidation can lag gaps, while intrabar penetration is insufficient. The model does not predict bounces, trade, model costs, or establish profitability. Non-standard and illiquid charts need separate review.

[b]Conclusion[/b]
Prominence depends on completed, volatility-normalized reactions, bounded volume context, and recency. Evidence fades, geometry stays controlled, and confirmed invalidation ends the zone. Historical reaction remains inspectable context, not certainty.

## Source Code

````pine
//@version=6
indicator("Reaction Weighted Support Resistance [Pineify]", overlay = true, max_boxes_count = 30)

string groupEngine = "Reaction Zone Engine"
int pivotLeft = input.int(5, "Pivot Left Bars", minval = 2, maxval = 20, group = groupEngine)
int pivotRight = input.int(5, "Pivot Right Bars", minval = 2, maxval = 20, group = groupEngine)
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine)
float zoneHalfWidthAtr = input.float(0.22, "Zone Half Width (ATR)", minval = 0.05, maxval = 1.00, step = 0.01, group = groupEngine)
float mergeDistanceAtr = input.float(0.45, "Merge Distance (ATR)", minval = 0.10, maxval = 2.00, step = 0.05, group = groupEngine)
float maximumZoneHeightAtr = input.float(1.25, "Maximum Merged Height (ATR)", minval = 0.30, maxval = 4.00, step = 0.05, group = groupEngine)
int reactionWindow = input.int(6, "Post-Touch Evaluation Bars", minval = 2, maxval = 30, group = groupEngine)
int decayHalfLife = input.int(120, "Strength Decay Half-Life Bars", minval = 20, maxval = 1000, group = groupEngine)
float invalidationBufferAtr = input.float(0.15, "Close Invalidation Buffer (ATR)", minval = 0.00, maxval = 1.00, step = 0.05, group = groupEngine)
int maximumZonesPerSide = input.int(6, "Maximum Zones Per Side", minval = 2, maxval = 12, group = groupEngine)
int volumeLength = input.int(20, "Relative Volume Length", minval = 5, maxval = 200, group = groupEngine)
float alertStrength = input.float(55.0, "High Strength Alert Threshold", minval = 20.0, maxval = 90.0, step = 5.0, group = groupEngine)

string groupVisual = "Visual System"
bool showZones = input.bool(true, "Show Reaction Zones", group = groupVisual)
bool showTouchEvents = input.bool(false, "Show Evaluated Touches", group = groupVisual)
bool showInvalidations = input.bool(true, "Show Zone Invalidations", group = groupVisual)
bool colorBars = input.bool(false, "Color Bars Inside Strong Zones", group = groupVisual)
bool showDashboard = input.bool(true, "Show Zone Dashboard", group = groupVisual)

color supportColor = color.rgb(13, 181, 171)
color supportBright = color.rgb(45, 212, 191)
color resistanceColor = color.rgb(225, 70, 118)
color resistanceBright = color.rgb(251, 113, 133)
color invalidColor = color.rgb(245, 158, 11)
color neutralColor = color.rgb(148, 163, 184)

f_strength(float rawScore) =>
    100.0 * (1.0 - math.exp(-math.max(rawScore, 0.0) / 3.0))

float atr = ta.atr(atrLength)
float atrFloor = math.max(nz(atr), syminfo.mintick)
float volumeMean = ta.sma(volume, volumeLength)
bool volumeReady = not na(volume) and not na(volumeMean) and volumeMean > 0
float relativeVolume = volumeReady ? volume / volumeMean : 1.0
float volumeCredibility = math.min(math.max(relativeVolume / 2.0, 0.25), 1.0)
float decayFactor = math.pow(0.5, 1.0 / decayHalfLife)

float pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)
float pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
float pivotAtr = atr[pivotRight]
bool confirmedPivotHigh = barstate.isconfirmed and not na(pivotHigh) and not na(pivotAtr)
bool confirmedPivotLow = barstate.isconfirmed and not na(pivotLow) and not na(pivotAtr)

var array<float> zoneCenters = array.new_float()
var array<float> zoneHalves = array.new_float()
var array<float> zoneScores = array.new_float()
var array<int> zoneTypes = array.new_int()
var array<int> zoneCreatedBars = array.new_int()
var array<int> zoneLastTouches = array.new_int()
var array<int> zoneTouchCounts = array.new_int()
var array<int> zoneEvaluationStarts = array.new_int()
var array<float> zoneEvaluationExtremes = array.new_float()
var array<float> zoneEvaluationCenters = array.new_float()
var array<float> zoneEvaluationAtrs = array.new_float()
var array<float> zoneEvaluationVolumes = array.new_float()
var array<bool> zoneWasInside = array.new_bool()
var array<box> zoneBoxes = array.new_box()

bool supportInvalidated = false
bool resistanceInvalidated = false
bool supportTouchEvaluated = false
bool resistanceTouchEvaluated = false

if barstate.isconfirmed and array.size(zoneCenters) > 0
    for zoneIndex = array.size(zoneCenters) - 1 to 0
        float center = array.get(zoneCenters, zoneIndex)
        float halfWidth = array.get(zoneHalves, zoneIndex)
        float lowerBoundary = center - halfWidth
        float upperBoundary = center + halfWidth
        int zoneType = array.get(zoneTypes, zoneIndex)
        float decayedScore = array.get(zoneScores, zoneIndex) * decayFactor
        int evaluationStart = array.get(zoneEvaluationStarts, zoneIndex)
        bool wasInside = array.get(zoneWasInside, zoneIndex)
        bool overlapsZone = low <= upperBoundary and high >= lowerBoundary
        bool invalidated = zoneType == 1 ? close < lowerBoundary - invalidationBufferAtr * atrFloor : close > upperBoundary + invalidationBufferAtr * atrFloor

        if invalidated
            box oldBox = array.get(zoneBoxes, zoneIndex)
            box.delete(oldBox)
            supportInvalidated := supportInvalidated or zoneType == 1
            resistanceInvalidated := resistanceInvalidated or zoneType == -1
            array.remove(zoneCenters, zoneIndex)
            array.remove(zoneHalves, zoneIndex)
            array.remove(zoneScores, zoneIndex)
            array.remove(zoneTypes, zoneIndex)
            array.remove(zoneCreatedBars, zoneIndex)
            array.remove(zoneLastTouches, zoneIndex)
            array.remove(zoneTouchCounts, zoneIndex)
            array.remove(zoneEvaluationStarts, zoneIndex)
            array.remove(zoneEvaluationExtremes, zoneIndex)
            array.remove(zoneEvaluationCenters, zoneIndex)
            array.remove(zoneEvaluationAtrs, zoneIndex)
            array.remove(zoneEvaluationVolumes, zoneIndex)
            array.remove(zoneWasInside, zoneIndex)
            array.remove(zoneBoxes, zoneIndex)
        else
            if evaluationStart >= 0 and bar_index > evaluationStart
                float evaluationExtreme = array.get(zoneEvaluationExtremes, zoneIndex)
                evaluationExtreme := zoneType == 1 ? math.max(evaluationExtreme, high) : math.min(evaluationExtreme, low)
                array.set(zoneEvaluationExtremes, zoneIndex, evaluationExtreme)
                if bar_index - evaluationStart >= reactionWindow
                    float evaluationCenter = array.get(zoneEvaluationCenters, zoneIndex)
                    float evaluationAtr = math.max(array.get(zoneEvaluationAtrs, zoneIndex), syminfo.mintick)
                    float reactionDisplacement = zoneType == 1 ? math.max(evaluationExtreme - evaluationCenter, 0.0) / evaluationAtr : math.max(evaluationCenter - evaluationExtreme, 0.0) / evaluationAtr
                    float boundedDisplacement = math.min(reactionDisplacement, 4.0)
                    float reactionVolumeCredibility = array.get(zoneEvaluationVolumes, zoneIndex)
                    float reactionQuality = boundedDisplacement * (0.75 + 0.50 * reactionVolumeCredibility)
                    decayedScore += reactionQuality
                    array.set(zoneTouchCounts, zoneIndex, array.get(zoneTouchCounts, zoneIndex) + 1)
                    array.set(zoneEvaluationStarts, zoneIndex, -1)
                    supportTouchEvaluated := supportTouchEvaluated or zoneType == 1
                    resistanceTouchEvaluated := resistanceTouchEvaluated or zoneType == -1

            int lastTouch = array.get(zoneLastTouches, zoneIndex)
            bool cooldownComplete = lastTouch < 0 or bar_index - lastTouch > reactionWindow + 2
            bool enteredZone = overlapsZone and not wasInside
            if array.get(zoneEvaluationStarts, zoneIndex) < 0 and enteredZone and cooldownComplete
                array.set(zoneEvaluationStarts, zoneIndex, bar_index)
                array.set(zoneEvaluationExtremes, zoneIndex, center)
                array.set(zoneEvaluationCenters, zoneIndex, center)
                array.set(zoneEvaluationAtrs, zoneIndex, atrFloor)
                array.set(zoneEvaluationVolumes, zoneIndex, volumeCredibility)
                array.set(zoneLastTouches, zoneIndex, bar_index)

            array.set(zoneScores, zoneIndex, decayedScore)
            array.set(zoneWasInside, zoneIndex, overlapsZone)

if barstate.isconfirmed
    for candidateNumber = 0 to 1
        int candidateType = candidateNumber == 0 ? 1 : -1
        bool hasCandidate = candidateType == 1 ? confirmedPivotLow : confirmedPivotHigh
        float candidatePrice = candidateType == 1 ? pivotLow : pivotHigh
        if hasCandidate
            float candidateHalf = math.max(pivotAtr * zoneHalfWidthAtr, syminfo.mintick)
            float candidateLower = candidatePrice - candidateHalf
            float candidateUpper = candidatePrice + candidateHalf
            int mergeIndex = -1
            float nearestDistance = 1e10

            if array.size(zoneCenters) > 0
                for searchIndex = 0 to array.size(zoneCenters) - 1
                    if array.get(zoneTypes, searchIndex) == candidateType
                        float existingCenter = array.get(zoneCenters, searchIndex)
                        float existingHalf = array.get(zoneHalves, searchIndex)
                        float mergedLower = math.min(existingCenter - existingHalf, candidateLower)
                        float mergedUpper = math.max(existingCenter + existingHalf, candidateUpper)
                        float distance = math.abs(existingCenter - candidatePrice)
                        bool withinDistance = distance <= mergeDistanceAtr * pivotAtr
                        bool withinHeightLimit = mergedUpper - mergedLower <= maximumZoneHeightAtr * pivotAtr
                        if withinDistance and withinHeightLimit and distance < nearestDistance
                            mergeIndex := searchIndex
                            nearestDistance := distance

            float seedScore = 0.35
            if mergeIndex >= 0
                float oldCenter = array.get(zoneCenters, mergeIndex)
                float oldHalf = array.get(zoneHalves, mergeIndex)
                float oldScore = array.get(zoneScores, mergeIndex)
                float oldLower = oldCenter - oldHalf
                float oldUpper = oldCenter + oldHalf
                float combinedLower = math.min(oldLower, candidateLower)
                float combinedUpper = math.max(oldUpper, candidateUpper)
                float oldWeight = math.max(oldScore, seedScore)
                float mergedCenter = (oldCenter * oldWeight + candidatePrice * seedScore) / (oldWeight + seedScore)
                float mergedHalf = math.max(mergedCenter - combinedLower, combinedUpper - mergedCenter)
                array.set(zoneCenters, mergeIndex, mergedCenter)
                array.set(zoneHalves, mergeIndex, mergedHalf)
                array.set(zoneScores, mergeIndex, oldScore + seedScore)
                box mergedBox = array.get(zoneBoxes, mergeIndex)
                box.set_top(mergedBox, mergedCenter + mergedHalf)
                box.set_bottom(mergedBox, mergedCenter - mergedHalf)
            else
                color candidateColor = candidateType == 1 ? supportColor : resistanceColor
                box newBox = box.new(left = bar_index, top = candidateUpper, right = bar_index + 1, bottom = candidateLower, xloc = xloc.bar_index, extend = showZones ? extend.right : extend.none, border_color = showZones ? color.new(candidateColor, 44) : na, border_width = 1, bgcolor = showZones ? color.new(candidateColor, 88) : na)
                array.push(zoneCenters, candidatePrice)
                array.push(zoneHalves, candidateHalf)
                array.push(zoneScores, seedScore)
                array.push(zoneTypes, candidateType)
                array.push(zoneCreatedBars, bar_index)
                array.push(zoneLastTouches, -1)
                array.push(zoneTouchCounts, 0)
                array.push(zoneEvaluationStarts, -1)
                array.push(zoneEvaluationExtremes, candidatePrice)
                array.push(zoneEvaluationCenters, candidatePrice)
                array.push(zoneEvaluationAtrs, pivotAtr)
                array.push(zoneEvaluationVolumes, 1.0)
                array.push(zoneWasInside, false)
                array.push(zoneBoxes, newBox)

            int sameTypeCount = 0
            int weakestIndex = -1
            float weakestScore = 1e10
            if array.size(zoneCenters) > 0
                for limitIndex = 0 to array.size(zoneCenters) - 1
                    if array.get(zoneTypes, limitIndex) == candidateType
                        sameTypeCount += 1
                        float limitScore = array.get(zoneScores, limitIndex)
                        if limitScore < weakestScore
                            weakestScore := limitScore
                            weakestIndex := limitIndex

            if sameTypeCount > maximumZonesPerSide and weakestIndex >= 0
                box weakestBox = array.get(zoneBoxes, weakestIndex)
                box.delete(weakestBox)
                array.remove(zoneCenters, weakestIndex)
                array.remove(zoneHalves, weakestIndex)
                array.remove(zoneScores, weakestIndex)
                array.remove(zoneTypes, weakestIndex)
                array.remove(zoneCreatedBars, weakestIndex)
                array.remove(zoneLastTouches, weakestIndex)
                array.remove(zoneTouchCounts, weakestIndex)
                array.remove(zoneEvaluationStarts, weakestIndex)
                array.remove(zoneEvaluationExtremes, weakestIndex)
                array.remove(zoneEvaluationCenters, weakestIndex)
                array.remove(zoneEvaluationAtrs, weakestIndex)
                array.remove(zoneEvaluationVolumes, weakestIndex)
                array.remove(zoneWasInside, weakestIndex)
                array.remove(zoneBoxes, weakestIndex)

bool inStrongSupport = false
bool inStrongResistance = false
float strongestSupport = na
float strongestResistance = na
int strongestSupportTouches = 0
int strongestResistanceTouches = 0
int supportZoneCount = 0
int resistanceZoneCount = 0

if array.size(zoneCenters) > 0
    for displayIndex = 0 to array.size(zoneCenters) - 1
        float displayCenter = array.get(zoneCenters, displayIndex)
        float displayHalf = array.get(zoneHalves, displayIndex)
        int displayType = array.get(zoneTypes, displayIndex)
        float displayStrength = f_strength(array.get(zoneScores, displayIndex))
        int displayTouches = array.get(zoneTouchCounts, displayIndex)
        float displayLower = displayCenter - displayHalf
        float displayUpper = displayCenter + displayHalf
        bool overlapsDisplayZone = low <= displayUpper and high >= displayLower
        color displayColor = displayType == 1 ? supportColor : resistanceColor
        color displayBright = displayType == 1 ? supportBright : resistanceBright
        int fillTransparency = int(math.round(math.max(46.0, 92.0 - displayStrength * 0.46)))
        int borderTransparency = int(math.round(math.max(8.0, 66.0 - displayStrength * 0.55)))
        box displayBox = array.get(zoneBoxes, displayIndex)
        box.set_right(displayBox, bar_index + 1)
        box.set_extend(displayBox, showZones ? extend.right : extend.none)
        box.set_bgcolor(displayBox, showZones ? color.new(displayColor, fillTransparency) : na)
        box.set_border_color(displayBox, showZones ? color.new(displayBright, borderTransparency) : na)

        if displayType == 1
            supportZoneCount += 1
            inStrongSupport := inStrongSupport or (overlapsDisplayZone and displayStrength >= alertStrength)
            if na(strongestSupport) or displayStrength > strongestSupport
                strongestSupport := displayStrength
                strongestSupportTouches := displayTouches
        else
            resistanceZoneCount += 1
            inStrongResistance := inStrongResistance or (overlapsDisplayZone and displayStrength >= alertStrength)
            if na(strongestResistance) or displayStrength > strongestResistance
                strongestResistance := displayStrength
                strongestResistanceTouches := displayTouches

bool inStrongZone = inStrongSupport or inStrongResistance
bool enteredStrongZone = barstate.isconfirmed and inStrongZone and not inStrongZone[1]
bool confirmedInvalidation = barstate.isconfirmed and (supportInvalidated or resistanceInvalidated)

plotshape(showTouchEvents and supportTouchEvaluated, title = "Support Touch Evaluated", style = shape.circle, location = location.belowbar, color = color.new(supportBright, 12), size = size.tiny, text = "R")
plotshape(showTouchEvents and resistanceTouchEvaluated, title = "Resistance Touch Evaluated", style = shape.circle, location = location.abovebar, color = color.new(resistanceBright, 12), size = size.tiny, text = "R")
plotshape(showInvalidations and supportInvalidated, title = "Support Zone Invalidated", style = shape.xcross, location = location.belowbar, color = invalidColor, size = size.small, text = "X")
plotshape(showInvalidations and resistanceInvalidated, title = "Resistance Zone Invalidated", style = shape.xcross, location = location.abovebar, color = invalidColor, size = size.small, text = "X")
barcolor(colorBars ? inStrongSupport ? color.new(supportColor, 24) : inStrongResistance ? color.new(resistanceColor, 24) : na : na, title = "Strong Reaction Zone Bar Color")

string supportStrengthText = not na(strongestSupport) ? str.tostring(strongestSupport, "#.0") + " / " + str.tostring(strongestSupportTouches) : "NA"
string resistanceStrengthText = not na(strongestResistance) ? str.tostring(strongestResistance, "#.0") + " / " + str.tostring(strongestResistanceTouches) : "NA"
string currentState = inStrongSupport ? "AT STRONG SUPPORT" : inStrongResistance ? "AT STRONG RESISTANCE" : "BETWEEN ZONES"
color currentStateColor = inStrongSupport ? supportBright : inStrongResistance ? resistanceBright : neutralColor

var table dashboard = table.new(position.top_right, 2, 5, frame_color = color.new(neutralColor, 48), frame_width = 1, border_color = color.new(neutralColor, 76), border_width = 1)
if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "REACTION ZONES", text_color = color.white, bgcolor = color.new(currentStateColor, 15), text_size = size.small)
        table.cell(dashboard, 1, 0, currentState, text_color = color.white, bgcolor = color.new(currentStateColor, 15), text_size = size.small)
        table.cell(dashboard, 0, 1, "Strongest Support", text_color = neutralColor, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 1, 1, supportStrengthText, text_color = supportBright, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 0, 2, "Strongest Resistance", text_color = neutralColor, bgcolor = color.new(color.black, 88))
        table.cell(dashboard, 1, 2, resistanceStrengthText, text_color = resistanceBright, bgcolor = color.new(color.black, 88))
        table.cell(dashboard, 0, 3, "Active S / R", text_color = neutralColor, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 1, 3, str.tostring(supportZoneCount) + " / " + str.tostring(resistanceZoneCount), text_color = color.white, bgcolor = color.new(color.black, 84))
        table.cell(dashboard, 0, 4, "Volume Input", text_color = neutralColor, bgcolor = color.new(color.black, 88))
        table.cell(dashboard, 1, 4, volumeReady ? "RELATIVE" : "NEUTRAL FALLBACK", text_color = volumeReady ? color.white : invalidColor, bgcolor = color.new(color.black, 88))
    else
        table.clear(dashboard, 0, 0, 1, 4)

alertcondition(enteredStrongZone, "Entered High Strength Reaction Zone", "Price entered an active support or resistance zone whose decayed reaction strength is above the configured threshold.")
alertcondition(confirmedInvalidation, "Reaction Zone Invalidated", "A confirmed close breached an active reaction zone beyond its ATR invalidation buffer.")
````
