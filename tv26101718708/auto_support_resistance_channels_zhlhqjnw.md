# Auto Support Resistance Channels

- url: https://www.tradingview.com/script/zhlHqJnW-Auto-Support-Resistance-Channels/
- type: indicator
- pine_id: PUB;221dec4d7217455589cbd95b111bc436
- version: 1.0

## Description

Auto Support Resistance Channels

This indicator builds support and resistance zones from confirmed pivot structure and then ranks those zones using a multi-factor scoring model. Its purpose is not simply to mark swing highs and lows, but to convert repeated price interaction into structured channels that reflect how often a level formed, how price reacted from it, and how well it held over time.

This script is inspired by the support/resistance concepts and earlier implementations shared by LonesomeTheBlue. The current version extends that idea with a custom zone construction and scoring model, including pivot clustering, reaction-based weighting, and structural filtering. The implementation and logic have been independently developed and differ from the original approach.

The script begins by detecting confirmed pivot highs and pivot lows using a user-defined pivot length. Each pivot becomes a candidate anchor point for a future zone. Around every pivot, the indicator creates an initial price band whose width is scaled by ATR. This makes the zone size adaptive to current market volatility rather than fixed in ticks or points.

From there, the script groups nearby pivots into shared zones. If multiple pivots occur within the allowed ATR-based distance, they are treated as evidence of the same structural area. This allows the indicator to build broader support or resistance channels from repeated interaction instead of drawing isolated single-price levels.

What distinguishes the script is its scoring framework. Each candidate zone receives a base score from the number of pivots it contains, but that is only the starting point. The script also evaluates the post-pivot reaction: if price moves away from a pivot with sufficient impulse, measured in ATR, and does so without excessive early retracement, that pivot contributes additional reaction score to the zone. In other words, zones are rewarded not only for existing, but for producing meaningful rejection.

The script then applies several penalties that reduce the quality score of weaker zones. If price later closes through the zone, the score is reduced. If candle bodies spend time inside the zone, suggesting acceptance rather than rejection, the score is reduced further. If candles repeatedly close inside the zone, the script applies an additional penalty. These filters are designed to separate cleaner structural rejection zones from areas where price trades through too freely.

A further contextual filter evaluates where the zone sits inside the recent trading range. Zones near the middle of the range can receive a penalty, reflecting the idea that mid-range levels are often less structurally meaningful than levels formed near the outer edges of a swing. Conversely, zones closer to the recent range high or low can receive a swing bonus, which increases the score of edge-of-range structures.

After all candidate zones are scored, the script checks for similar or overlapping zones and merges them where appropriate. It then selects the highest-scoring non-overlapping zones, up to the user-defined display limit. The final result is a ranked map of support and resistance channels, with color intensity reflecting the relative zone score.

This makes the indicator different from simple pivot-based support and resistance tools. It does not plot every swing point indiscriminately. Instead, it evaluates whether repeated pivot clustering, clean reaction, and subsequent holding behavior justify promoting an area into a displayed channel.

Key concepts implemented in the script:

Confirmed pivot high and pivot low detection
ATR-based adaptive zone width
Clustering of nearby pivots into shared zones
Reaction scoring based on post-pivot excursion and retracement quality
Penalties for breaks, dwell inside the zone, and closes inside the zone
Context filter using recent range position
Optional swing-edge bonus for zones near range extremes
Selection of top-ranked non-overlapping zones

How to use:

The plotted boxes represent the highest-ranked support and resistance areas found within the active lookback. Wider ATR multipliers create broader zones, while higher pivot lengths make the script more selective. Increasing the reaction requirements makes the indicator focus more on pivots that produced stronger directional rejection. Increasing the penalty weights makes the scoring stricter and reduces tolerance for zones that price trades through frequently.

Auto Lookback can be used to reset the analysis at the start of each new day, while Manual Lookback keeps the zone construction tied to a fixed historical window. The color gradient helps distinguish relatively weaker zones from stronger ones based on the script’s internal score.

This indicator does not predict future price direction and does not generate standalone trade signals. It is designed to formalize support and resistance channel construction into a repeatable process based on pivot clustering, reaction quality, and subsequent price behavior.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JuniorQTrader inspired by LonesomeTheBlue
//@version=6
indicator('Auto Support Resistance Channels', overlay = true, max_bars_back = 5000, max_lines_count = 500, max_boxes_count = 500)

// =========================
// INPUTS
// =========================
pivot_length = input.int(10, 'Pivot Length', minval = 1, tooltip = 'Number of bars used on each side to confirm a pivot high or pivot low. Higher values produce fewer but more significant pivots.', group = 'Main Settings')

manuallookback = input.int(300, 'Manual Lookback', minval = 50, tooltip = 'Number of historical bars used for zone construction when Auto Lookback is disabled.', group = 'Lookback Settings')
autolookback = input.bool(false, 'Auto Lookback', tooltip = 'Automatically resets the lookback at the start of each new day based on the selected timezone.', group = 'Lookback Settings')

timezone = input.string('UTC-0', 'Timezone', ['UTC-12', 'UTC-11', 'UTC-10', 'UTC-9', 'UTC-8', 'UTC-7', 'UTC-6', 'UTC-5', 'UTC-4', 'UTC-3', 'UTC-2', 'UTC-1', 'UTC-0', 'UTC+1', 'UTC+2', 'UTC+3', 'UTC+4', 'UTC+5', 'UTC+6', 'UTC+7', 'UTC+8', 'UTC+9', 'UTC+10', 'UTC+11', 'UTC+12'], tooltip = 'Timezone used to determine daily reset timing when Auto Lookback is enabled.', group = 'Lookback Settings')

atrmult = input.float(0.5, 'Support Resistance Zone ATR Multiplier', minval = 0.1, step = 0.1, tooltip = 'Controls the initial zone width around each pivot using ATR. Higher values create wider zones.', group = 'Main Settings')
atrLen = 14

pivotweight = input.int(5, 'Pivot Weight', minval = 1, tooltip = 'Base score contribution added for each pivot included in a zone.', group = 'Zone Strength Settings')
breakweight = input.int(3, 'Break Weight', minval = 0, tooltip = 'Penalty applied each time price closes through the zone from one side to the other.', group = 'Zone Strength Settings')
dwellweight = input.int(2, 'Dwell Penalty Weight', minval = 0, tooltip = 'Penalty applied when candle bodies remain inside the zone, indicating weak rejection.', group = 'Zone Strength Settings')
closeinsideweight = input.int(3, 'Close Inside Penalty Weight', minval = 0, tooltip = 'Penalty applied when candles close inside the zone, suggesting acceptance rather than rejection.', group = 'Zone Strength Settings')
reactionweight = input.int(4, 'Reaction Weight', minval = 0, tooltip = 'Multiplier used for pivot reaction scoring. Higher values reward stronger post-pivot moves more heavily.', group = 'Zone Strength Settings')

min_pivots = input.int(1, 'Minimum Pivots In Zone', minval = 1, tooltip = 'Minimum number of pivots required for a zone to be considered valid.', group = 'Main Settings')
top_zones = input.int(10, 'Top Zones To Draw', minval = 1, maxval = 20, tooltip = 'Maximum number of highest-scoring non-overlapping zones to display on the chart.', group = 'Main Settings')

reactionBars = input.int(12, 'Reaction Bars', minval = 2, tooltip = 'Number of bars after a pivot used to evaluate the strength of the price reaction.', group = 'Zone Strength Settings')
reactionATR = input.float(1.2, 'Min Reaction In ATR', minval = 0.1, step = 0.1, tooltip = 'Minimum excursion from the pivot, measured in ATR, required for a reaction to count as meaningful.', group = 'Zone Strength Settings')
reactionRetraceFrac = input.float(0.5, 'Max Early Retrace Fraction', minval = 0.0, maxval = 1.0, step = 0.05, tooltip = 'Maximum allowed early retracement as a fraction of the initial excursion. Lower values require cleaner reactions.', group = 'Zone Strength Settings')

mergeATRFrac = input.float(0.8, 'Zone Merge Threshold (ATR frac)', minval = 0.1, step = 0.1, tooltip = 'Controls how close two zones must be to be merged together, relative to ATR.', group = 'Main Settings')
middlepenalty = input.int(0, 'Middle Of Range Penalty', minval = 0, tooltip = 'Penalty applied to zones located near the middle of the recent price range, where levels are often less meaningful.', group = 'Zone Strength Settings')
rangeLookback = input.int(150, 'Range Penalty Lookback', minval = 20, tooltip = 'Lookback period used to calculate the recent price range for middle-range penalty and swing-edge bonus.', group = 'Zone Strength Settings')
rangeMidFrac = input.float(0.18, 'Middle Range Threshold', minval = 0.01, maxval = 0.5, step = 0.01, tooltip = 'Defines how close a zone must be to the center of the recent range to receive the middle-range penalty.', group = 'Zone Strength Settings')

// NEW
swingbonus = input.float(0, 'Swing Bonus Max', minval = 0.0, step = 0.5, tooltip = 'Maximum bonus awarded to zones positioned near the edges of the recent price range.', group = 'Zone Strength Settings')
swingEdgeFrac = input.float(0.20, 'Swing Edge Threshold', minval = 0.01, maxval = 0.5, step = 0.01, tooltip = 'Defines how close a zone must be to the recent range high or low to qualify for swing bonus.', group = 'Zone Strength Settings')

zoneColorMin = input.color(color.rgb(255, 235, 59, 50), 'Zone Min Score Color', tooltip = 'Color used for the lowest-scoring zones in the score gradient.', group = 'Color Settings')
zoneColorMax = input.color(color.rgb(255, 82, 82, 50), 'Zone Max Score Color', tooltip = 'Color used for the highest-scoring zones in the score gradient.', group = 'Color Settings')

pivothigh_color = input.color(color.red, 'Pivot High Color', tooltip = 'Color used to plot pivot high markers.', group = 'Color Settings')
pivotlow_color  = input.color(color.green, 'Pivot Low Color', tooltip = 'Color used to plot pivot low markers.', group = 'Color Settings')

// =========================
// PIVOTS
// =========================
pivothigh = ta.pivothigh(pivot_length, pivot_length)
pivotlow  = ta.pivotlow(pivot_length, pivot_length)

plotshape(pivothigh, 'Pivot Highs', shape.triangledown, location.abovebar, color = pivothigh_color, offset = -pivot_length, size = size.tiny)
plotshape(pivotlow, 'Pivot Lows',  shape.triangleup,   location.belowbar, color = pivotlow_color,  offset = -pivot_length, size = size.tiny)

// =========================
// LOOKBACK
// =========================
var int lookback = 0

if autolookback
    lookback += 1
else
    lookback := manuallookback

if ta.change(dayofweek(time, timezone)) != 0 and autolookback
    lookback := 0

// =========================
// ARRAYS
// =========================
var float[] pivotarray_y = array.new<float>()
var int[]   pivotarray_x = array.new<int>()
var int[]   pivotarray_type = array.new<int>()     // +1 high, -1 low
var float[] pivotarray_reaction = array.new<float>()

atr = ta.atr(atrLen)
zone_width = atr * atrmult

// =========================
// REACTION SCORE PER PIVOT
// =========================
calc_pivot_reaction_score(float pivotPrice, int pivotType, int pivotBar) =>
    float score = 0.0
    int barsAvailable = bar_index - pivotBar
    int n = math.min(reactionBars, barsAvailable)

    if n > 1
        float atrAtPivot = nz(atr[barsAvailable], atr)
        float excursion = 0.0
        float badRetrace = 0.0

        if pivotType == -1
            // pivot low -> want move up
            float bestHigh = high[n]
            float worstLowAfter = low[n]
            for k = 0 to n - 1
                bestHigh := math.max(bestHigh, high[k])
                worstLowAfter := math.min(worstLowAfter, low[k])
            excursion := bestHigh - pivotPrice
            badRetrace := math.max(0.0, pivotPrice - worstLowAfter)
        else
            // pivot high -> want move down
            float bestLow = low[n]
            float worstHighAfter = high[n]
            for k = 0 to n - 1
                bestLow := math.min(bestLow, low[k])
                worstHighAfter := math.max(worstHighAfter, high[k])
            excursion := pivotPrice - bestLow
            badRetrace := math.max(0.0, worstHighAfter - pivotPrice)

        bool enoughImpulse = excursion >= atrAtPivot * reactionATR
        bool retraceOk = badRetrace <= excursion * reactionRetraceFrac

        if enoughImpulse and retraceOk
            score := (excursion / atrAtPivot) * reactionweight

    score

if bool(pivothigh)
    int pBar = bar_index - pivot_length
    float pPrice = pivothigh
    float rScore = calc_pivot_reaction_score(pPrice, +1, pBar)
    array.push(pivotarray_y, pPrice)
    array.push(pivotarray_x, pBar)
    array.push(pivotarray_type, +1)
    array.push(pivotarray_reaction, rScore)

if bool(pivotlow)
    int pBar = bar_index - pivot_length
    float pPrice = pivotlow
    float rScore = calc_pivot_reaction_score(pPrice, -1, pBar)
    array.push(pivotarray_y, pPrice)
    array.push(pivotarray_x, pBar)
    array.push(pivotarray_type, -1)
    array.push(pivotarray_reaction, rScore)

// =========================
// REMOVE OLD PIVOTS
// =========================
if array.size(pivotarray_y) > 0
    for i = array.size(pivotarray_x) - 1 to 0 by 1
        pivotBar = array.get(pivotarray_x, i)
        if bar_index - pivotBar > lookback
            array.remove(pivotarray_x, i)
            array.remove(pivotarray_y, i)
            array.remove(pivotarray_type, i)
            array.remove(pivotarray_reaction, i)

// =========================
// BUILD ZONE FROM PIVOT
// =========================
get_zone_from_pivot(int pivotIndex) =>
    if array.size(pivotarray_y) > 0
        float center = array.get(pivotarray_y, pivotIndex)
        int zoneStart = array.get(pivotarray_x, pivotIndex)
        float zoneLow = center
        float zoneHigh = center
        int count = 0
        float totalReaction = 0.0
        int pivotsInZone = 0

        float zw = nz(zone_width[bar_index - zoneStart], zone_width)

        for j = 0 to array.size(pivotarray_y) - 1 by 1
            float other = array.get(pivotarray_y, j)
            int other_x = array.get(pivotarray_x, j)

            if math.abs(other - center) <= zw
                zoneLow := math.min(zoneLow, other)
                zoneHigh := math.max(zoneHigh, other)
                count += pivotweight
                totalReaction += array.get(pivotarray_reaction, j)
                pivotsInZone += 1
                if other_x < zoneStart
                    zoneStart := other_x

        [zoneLow, zoneHigh, zoneStart, count, totalReaction, pivotsInZone]

// =========================
// ZONE QUALITY METRICS
// =========================
count_zone_metrics(float zLow, float zHigh, int zStart) =>
    int breaks = 0
    int dwell = 0
    int closeInside = 0
    int barsToCheck = math.min(bar_index - zStart, lookback)

    if barsToCheck > 0
        for y = 0 to barsToCheck - 1 by 1
            bool brokeAbove = close[y + 1] <= zHigh and close[y] > zHigh
            bool brokeBelow = close[y + 1] >= zLow and close[y] < zLow
            if brokeAbove or brokeBelow
                breaks += breakweight

            bool bodyInside = open[y] <= zHigh and open[y] >= zLow and close[y] <= zHigh and close[y] >= zLow
            bool closeIn = close[y] <= zHigh and close[y] >= zLow

            if bodyInside
                dwell += dwellweight
            if closeIn
                closeInside += closeinsideweight

    [breaks, dwell, closeInside]

calc_middle_penalty(float zLow, float zHigh) =>
    float hh = ta.highest(high, rangeLookback)
    float ll = ta.lowest(low, rangeLookback)
    float rangeH = hh - ll
    float zMid = (zLow + zHigh) * 0.5
    float rangeMid = (hh + ll) * 0.5

    float penalty = 0.0
    if rangeH > syminfo.mintick
        if math.abs(zMid - rangeMid) <= rangeH * rangeMidFrac
            penalty := middlepenalty
    penalty

// =========================
// SWING BONUS
// =========================
calc_swing_bonus(float zLow, float zHigh) =>
    float hh = ta.highest(high, rangeLookback)
    float ll = ta.lowest(low, rangeLookback)
    float rangeH = hh - ll
    float zMid = (zLow + zHigh) * 0.5

    float bonus = 0.0

    if rangeH > syminfo.mintick
        float distToHigh = math.abs(hh - zMid)
        float distToLow = math.abs(zMid - ll)
        float minDist = math.min(distToHigh, distToLow)

        float edgeThreshold = rangeH * swingEdgeFrac

        if minDist <= edgeThreshold
            float closeness = 1.0 - (minDist / edgeThreshold)
            bonus := closeness * swingbonus

    bonus

// =========================
// SIMILAR ZONE CHECK
// =========================
var float[] zone_lows   = array.new<float>()
var float[] zone_highs  = array.new<float>()
var float[] zone_scores = array.new<float>()
var int[]   zone_starts = array.new<int>()

find_similar_zone_index(float newLow, float newHigh) =>
    int idx = -1
    float newMid = (newLow + newHigh) * 0.5
    float newHeight = math.max(newHigh - newLow, syminfo.mintick)

    if array.size(zone_lows) > 0
        for i = 0 to array.size(zone_lows) - 1 by 1
            float exLow = array.get(zone_lows, i)
            float exHigh = array.get(zone_highs, i)
            float exMid = (exLow + exHigh) * 0.5
            float exHeight = math.max(exHigh - exLow, syminfo.mintick)

            float dist = math.abs(newMid - exMid)
            float threshold = math.max(newHeight, exHeight) + atr * mergeATRFrac

            if dist <= threshold * 0.5
                idx := i
                break

    idx

// =========================
// BUILD CANDIDATE ZONES
// =========================
bool newPivot = bool(pivothigh) or bool(pivotlow)

if newPivot
    array.clear(zone_lows)
    array.clear(zone_highs)
    array.clear(zone_scores)
    array.clear(zone_starts)

    for i = 0 to array.size(pivotarray_y) - 1 by 1
        [zLow, zHigh, zStart, zBaseCount, zReaction, zPivots] = get_zone_from_pivot(i)

        if zPivots >= min_pivots and zReaction > 0
            [zBreaks, zDwell, zCloseInside] = count_zone_metrics(zLow, zHigh, zStart)
            float zMidPenalty = calc_middle_penalty(zLow, zHigh)
            float zSwingBonus = calc_swing_bonus(zLow, zHigh)

            float zScore = zBaseCount + zReaction + zSwingBonus - zBreaks - zDwell - zCloseInside - zMidPenalty

            int similarIdx = find_similar_zone_index(zLow, zHigh)

            if similarIdx == -1
                array.push(zone_lows, zLow)
                array.push(zone_highs, zHigh)
                array.push(zone_scores, zScore)
                array.push(zone_starts, zStart)
            else
                float oldLow = array.get(zone_lows, similarIdx)
                float oldHigh = array.get(zone_highs, similarIdx)
                float oldScore = array.get(zone_scores, similarIdx)
                int oldStart = array.get(zone_starts, similarIdx)

                float mergedLow = math.min(oldLow, zLow)
                float mergedHigh = math.max(oldHigh, zHigh)
                float mergedScore = math.max(oldScore, zScore)
                int mergedStart = math.min(oldStart, zStart)

                array.set(zone_lows, similarIdx, mergedLow)
                array.set(zone_highs, similarIdx, mergedHigh)
                array.set(zone_scores, similarIdx, mergedScore)
                array.set(zone_starts, similarIdx, mergedStart)

// =========================
// FINAL NON-OVERLAPPING ZONES
// =========================
var float[] final_zone_lows   = array.new<float>()
var float[] final_zone_highs  = array.new<float>()
var float[] final_zone_scores = array.new<float>()
var int[]   final_zone_starts = array.new<int>()

zones_overlap(float low1, float high1, float low2, float high2) =>
    math.max(low1, low2) <= math.min(high1, high2)

if newPivot and array.size(zone_lows) > 0
    array.clear(final_zone_lows)
    array.clear(final_zone_highs)
    array.clear(final_zone_scores)
    array.clear(final_zone_starts)

    bool[] used = array.new<bool>()
    for i = 0 to array.size(zone_lows) - 1 by 1
        array.push(used, false)

    for pick = 0 to array.size(zone_lows) - 1 by 1
        if array.size(final_zone_lows) >= top_zones
            break

        int bestIndex = -1
        float bestScore = -1000000.0

        for i = 0 to array.size(zone_scores) - 1 by 1
            float s = array.get(zone_scores, i)
            bool alreadyUsed = array.get(used, i)

            if not alreadyUsed and s > bestScore
                bestScore := s
                bestIndex := i

        if bestIndex == -1
            break

        float bestLow = array.get(zone_lows, bestIndex)
        float bestHigh = array.get(zone_highs, bestIndex)
        float bestZoneScore = array.get(zone_scores, bestIndex)
        int bestZoneStart = array.get(zone_starts, bestIndex)

        array.push(final_zone_lows, bestLow)
        array.push(final_zone_highs, bestHigh)
        array.push(final_zone_scores, bestZoneScore)
        array.push(final_zone_starts, bestZoneStart)

        for i = 0 to array.size(zone_lows) - 1 by 1
            if not array.get(used, i)
                float testLow = array.get(zone_lows, i)
                float testHigh = array.get(zone_highs, i)

                if zones_overlap(bestLow, bestHigh, testLow, testHigh)
                    array.set(used, i, true)

// =========================
// DRAW
// =========================
var box[] sr_boxes = array.new_box()

if barstate.islast
    if array.size(sr_boxes) > 0
        for i = 0 to array.size(sr_boxes) - 1 by 1
            box.delete(array.get(sr_boxes, i))
        array.clear(sr_boxes)

    if array.size(final_zone_starts) > 0
        float minScore = array.get(final_zone_scores, 0)
        float maxScore = array.get(final_zone_scores, 0)

        if array.size(final_zone_scores) > 1
            for i = 1 to array.size(final_zone_scores) - 1 by 1
                float s = array.get(final_zone_scores, i)
                minScore := math.min(minScore, s)
                maxScore := math.max(maxScore, s)

        for i = 0 to array.size(final_zone_starts) - 1 by 1
            int x = array.get(final_zone_starts, i)
            float top = array.get(final_zone_highs, i)
            float bottom = array.get(final_zone_lows, i)
            float score = array.get(final_zone_scores, i)

            color zoneColor = color.from_gradient(score, minScore, maxScore, zoneColorMin, zoneColorMax)

            box zone_box = box.new( x, top, bar_index, bottom, border_color = zoneColor, extend = extend.right, bgcolor = zoneColor)
            array.push(sr_boxes, zone_box)
````
