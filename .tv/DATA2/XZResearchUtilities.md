<!-- tradingview-pine-id: PUB;998395ec0ca842a495c72d6fadea745d -->
<!-- tradingview-pine-version: 7.0 -->
<!-- tradingviewscripts-format: 1 -->
# XZ_Research_Utilities

Source: https://www.tradingview.com/script/MZUTy7lj-XZ-Research-Utilities/

## Description

Library  "XZ_Research_Utilities"
Generic descriptive-statistics and two-column research-table utilities. Contains no XZ trading methodology or analytical authority.

resolvePosition(key)
  Resolves a normalized table-position key.
  Parameters:
    key (string): Position key.
  Returns: Pine table position constant.

resolveTextSize(key)
  Resolves a normalized text-size key.
  Parameters:
    key (string): Size key.
  Returns: Pine size constant.

countEqual(values, target)
  Counts values equal to a target.
  Parameters:
    values (array<int>): Integer observations.
    target (int): Target value.
  Returns: Matching observation count.

countPositive(values)
  Counts values greater than zero.
  Parameters:
    values (array<int>): Integer observations.
  Returns: Positive observation count.

countAtLeast(values, threshold)
  Counts values at or above a threshold.
  Parameters:
    values (array<int>): Integer observations.
    threshold (int): Inclusive threshold.
  Returns: Observation count at/above threshold.

sumInt(values)
  Sums integer observations.
  Parameters:
    values (array<int>): Integer observations.
  Returns: Sum.

selectedStat(values, mode)
  Returns Median or Mean from float observations.
  Parameters:
    values (array<float>): Float observations.
    mode (string): "Median" or "Mean".
  Returns: Selected descriptive statistic or na for an empty sample.

number(value, suffix)
  Formats a numeric result with an optional suffix.
  Parameters:
    value (float): Numeric result.
    suffix (string): Suffix such as d or %.
  Returns: Formatted number or em dash for na.

percent(numerator, denominator)
  Formats numerator/denominator as a percentage.
  Parameters:
    numerator (int): Numerator.
    denominator (int): Denominator.
  Returns: Percentage or em dash when denominator is zero.

createTable(positionKey, rows, backgroundColor, lineColor, showLines)
  Creates a two-column research table.
  Parameters:
    positionKey (string): Normalized table-position key.
    rows (int): Row count.
    backgroundColor (color): Background colour.
    lineColor (color): Frame/border colour.
    showLines (bool): Whether frame and borders are visible.
  Returns: Table handle.

header(id, leftText, rightText, accentColor, textColor, backgroundColor, textSize, leftTooltip, rightTooltip)
  Writes the two-column research header.
  Parameters:
    id (table): Table handle.
    leftText (string): Left header text.
    rightText (string): Right header text.
    accentColor (color): Accent colour.
    textColor (color): Neutral text colour.
    backgroundColor (color): Shared background.
    textSize (string): Normalized text-size key.
    leftTooltip (string): Left-cell tooltip.
    rightTooltip (string): Right-cell tooltip.
  Returns: True after rendering.

row(id, row, labelText, valueText, textColor, accentColor, backgroundColor, textSize, tooltipText, accentValue)
  Writes one label/value research row.
  Parameters:
    id (table): Table handle.
    row (int): Row index.
    labelText (string): Left label.
    valueText (string): Right value.
    textColor (color): Neutral text colour.
    accentColor (color): Optional emphasized value colour.
    backgroundColor (color): Shared background.
    textSize (string): Normalized text-size key.
    tooltipText (string): Shared metric-definition tooltip.
    accentValue (bool): Whether the right value uses accent colour.
  Returns: True after rendering.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steel-Sovereign
//@version=6

//@description XZ Research Utilities v7. Generic descriptive-statistics, bounded-sample, categorical-observation, interval, transition, geometry, bitmask-membership and neutral research-formatting utilities. Contains no indicator-specific event schema, cohort definition, methodology, lifecycle authority or presentation copy.
library("XZ_Research_Utilities", true)

//@function Counts integer observations equal to target.
export countEqual(array<int> values, int target) =>
    int count = 0
    if array.size(values) > 0
        for i = 0 to array.size(values) - 1
            if array.get(values, i) == target
                count += 1
    count

//@function Counts integer observations greater than zero.
export countPositive(array<int> values) =>
    int count = 0
    if array.size(values) > 0
        for i = 0 to array.size(values) - 1
            if array.get(values, i) > 0
                count += 1
    count

//@function Counts integer observations at or above an inclusive threshold.
export countAtLeast(array<int> values, int threshold) =>
    int count = 0
    if array.size(values) > 0
        for i = 0 to array.size(values) - 1
            if array.get(values, i) >= threshold
                count += 1
    count

//@function Sums integer observations.
export sumInt(array<int> values) =>
    int total = 0
    if array.size(values) > 0
        for i = 0 to array.size(values) - 1
            total += array.get(values, i)
    total

//@function Appends one non-na float observation and trims the oldest observations to limit.
export pushFloatLimited(array<float> values, float value, int limit) =>
    if not na(value) and limit > 0
        array.push(values, value)
        while array.size(values) > limit
            array.shift(values)
    array.size(values)

//@function Mean of float observations or na for an empty sample. Uses explicit summation for deterministic parity with existing XZ Research implementations.
export mean(array<float> values) =>
    float result = na
    int n = array.size(values)
    if n > 0
        float total = 0.0
        for i = 0 to n - 1
            total += array.get(values, i)
        result := total / n
    result

//@function Median of float observations or na for an empty sample. Sorts a copy so caller order is preserved.
export median(array<float> values) =>
    float result = na
    int n = array.size(values)
    if n > 0
        array<float> sorted = array.copy(values)
        array.sort(sorted, order.ascending)
        int middle = int(math.floor(n / 2.0))
        result := n % 2 == 1 ? array.get(sorted, middle) : (array.get(sorted, middle - 1) + array.get(sorted, middle)) / 2.0
    result

//@function Returns Median or Mean from float observations.
export selectedStat(array<float> values, string mode) =>
    mode == "Mean" ? mean(values) : median(values)

//@function Formats a numeric result with optional suffix; em dash for na.
export number(float value, string suffix) =>
    na(value) ? "—" : str.tostring(value, "#.##") + suffix

//@function Formats a numeric result with sample N.
export numberWithN(float value, string suffix, int sampleN, string nLabel) =>
    (na(value) ? "N/A" : str.tostring(value, "#.##") + suffix) + " · " + nLabel + " " + str.tostring(sampleN)

//@function Calculates selected Median/Mean and formats it with current sample N.
export selectedStatWithN(array<float> values, string mode, string suffix, string nLabel) =>
    numberWithN(selectedStat(values, mode), suffix, array.size(values), nLabel)

//@function Formats numerator/denominator as a percentage; em dash when denominator is zero.
export percent(int numerator, int denominator) =>
    denominator <= 0 ? "—" : str.tostring(float(numerator) / float(denominator) * 100.0, "#.##") + "%"

//@function Formats numerator/denominator as a percentage with caller-supplied empty text.
export percentOr(int numerator, int denominator, string emptyText) =>
    denominator <= 0 ? emptyText : str.tostring(float(numerator) / float(denominator) * 100.0, "#.##") + "%"

//@function Generic scaled rate. Returns na when denominator is not positive.
export scaledRate(int numerator, int denominator, float scale) =>
    denominator > 0 ? float(numerator) / float(denominator) * scale : na

//@function Converts an integer array to a float array preserving order.
export intArrayToFloat(array<int> values) =>
    array<float> result = array.new_float()
    if array.size(values) > 0
        for i = 0 to array.size(values) - 1
            array.push(result, float(array.get(values, i)))
    result

//==============================================================================
// GENERIC COVERAGE STATE
//==============================================================================

export type CoverageState
    int confirmed_count
    int first_time
    int last_time

export newCoverageState() =>
    CoverageState.new(0, na, na)

export observeCoverage(CoverageState state, int observationTime) =>
    state.confirmed_count += 1
    if na(state.first_time)
        state.first_time := observationTime
    state.last_time := observationTime
    true

export coverageCount(CoverageState state) => state.confirmed_count
export coverageFirstTime(CoverageState state) => state.first_time
export coverageLastTime(CoverageState state) => state.last_time
export coverageElapsedDays(CoverageState state) =>
    not na(state.first_time) and not na(state.last_time) ? float(state.last_time - state.first_time) / 86400000.0 : na

//==============================================================================
// GENERIC CATEGORY COUNTS
//==============================================================================

export type CategoryCountsState
    array<int> counts

export newCategoryCountsState(int categoryCount) =>
    CategoryCountsState.new(array.new_int(categoryCount, 0))

export incrementCategory(CategoryCountsState state, int categoryIndex) =>
    if categoryIndex >= 0 and categoryIndex < array.size(state.counts)
        array.set(state.counts, categoryIndex, array.get(state.counts, categoryIndex) + 1)
    true

export categoryCount(CategoryCountsState state, int categoryIndex) =>
    categoryIndex >= 0 and categoryIndex < array.size(state.counts) ? array.get(state.counts, categoryIndex) : 0

export categoryTotal(CategoryCountsState state, int fromIndex, int toIndex) =>
    int total = 0
    int count = array.size(state.counts)
    if count > 0
        int first = math.max(fromIndex, 0)
        int last = math.min(toIndex, count - 1)
        if last >= first
            for i = first to last
                total += array.get(state.counts, i)
    total

//==============================================================================
// GENERIC DIRECTIONAL BUCKET OBSERVATIONS
//==============================================================================

export type ObservationBucket
    int total
    int positive
    int negative
    array<float> samples

export type BucketSetState
    array<ObservationBucket> buckets

export newBucketSetState(int bucketCount) =>
    array<ObservationBucket> buckets = array.new<ObservationBucket>()
    if bucketCount > 0
        for i = 0 to bucketCount - 1
            array.push(buckets, ObservationBucket.new(0, 0, 0, array.new_float()))
    BucketSetState.new(buckets)

export observeBucket(BucketSetState state, int bucketIndex, int directionCode, float sampleValue, int sampleLimit) =>
    if bucketIndex >= 0 and bucketIndex < array.size(state.buckets)
        ObservationBucket bucket = array.get(state.buckets, bucketIndex)
        bucket.total += 1
        if directionCode > 0
            bucket.positive += 1
        else if directionCode < 0
            bucket.negative += 1
        if not na(sampleValue)
            pushFloatLimited(bucket.samples, sampleValue, sampleLimit)
        array.set(state.buckets, bucketIndex, bucket)
    true

export bucketTotal(BucketSetState state, int bucketIndex) =>
    int result = 0
    if bucketIndex >= 0 and bucketIndex < array.size(state.buckets)
        ObservationBucket bucket = array.get(state.buckets, bucketIndex)
        result := bucket.total
    result

export bucketPositive(BucketSetState state, int bucketIndex) =>
    int result = 0
    if bucketIndex >= 0 and bucketIndex < array.size(state.buckets)
        ObservationBucket bucket = array.get(state.buckets, bucketIndex)
        result := bucket.positive
    result

export bucketNegative(BucketSetState state, int bucketIndex) =>
    int result = 0
    if bucketIndex >= 0 and bucketIndex < array.size(state.buckets)
        ObservationBucket bucket = array.get(state.buckets, bucketIndex)
        result := bucket.negative
    result

export bucketSamples(BucketSetState state, int bucketIndex) =>
    array<float> result = array.new_float()
    if bucketIndex >= 0 and bucketIndex < array.size(state.buckets)
        ObservationBucket bucket = array.get(state.buckets, bucketIndex)
        result := bucket.samples
    result

//==============================================================================
// GENERIC INTERVAL OBSERVATIONS
//==============================================================================

export type IntervalState
    int last_bar
    array<float> samples

export newIntervalState() =>
    IntervalState.new(na, array.new_float())

export observeInterval(IntervalState state, int currentBar, int sampleLimit, bool allowZero) =>
    if not na(currentBar)
        bool eligible = not na(state.last_bar) and (allowZero ? currentBar >= state.last_bar : currentBar > state.last_bar)
        if eligible
            pushFloatLimited(state.samples, float(currentBar - state.last_bar), sampleLimit)
        state.last_bar := currentBar
    true

export intervalSamples(IntervalState state) => state.samples
export intervalLastBar(IntervalState state) => state.last_bar

//==============================================================================
// GENERIC EPISODE OBSERVATIONS
//==============================================================================

export type EpisodeState
    int positive_count
    int negative_count
    int start_bar
    array<float> positive_durations
    array<float> negative_durations

export newEpisodeState() =>
    EpisodeState.new(0, 0, na, array.new_float(), array.new_float())

export beginEpisode(EpisodeState state, int directionCode, int confirmBar) =>
    state.start_bar := confirmBar
    if directionCode > 0
        state.positive_count += 1
    else if directionCode < 0
        state.negative_count += 1
    true

export endEpisode(EpisodeState state, int directionCode, int confirmBar, int sampleLimit) =>
    if not na(state.start_bar) and not na(confirmBar)
        float duration = float(math.max(confirmBar - state.start_bar, 1))
        if directionCode > 0
            pushFloatLimited(state.positive_durations, duration, sampleLimit)
        else if directionCode < 0
            pushFloatLimited(state.negative_durations, duration, sampleLimit)
    state.start_bar := na
    true

export episodePositiveCount(EpisodeState state) => state.positive_count
export episodeNegativeCount(EpisodeState state) => state.negative_count
export episodePositiveDurations(EpisodeState state) => state.positive_durations
export episodeNegativeDurations(EpisodeState state) => state.negative_durations

//==============================================================================
// GENERIC GEOMETRY OBSERVATIONS
//==============================================================================

export type GeometryState
    int positive_count
    int negative_count
    int last_origin_bar
    float last_price
    array<float> confirmation_lags
    array<float> spacings
    array<float> amplitudes_pct

export newGeometryState() =>
    GeometryState.new(0, 0, na, na, array.new_float(), array.new_float(), array.new_float())

export observeGeometry(GeometryState state, bool positiveClass, int originBar, int confirmBar, float price, int sampleLimit) =>
    if positiveClass
        state.positive_count += 1
    else
        state.negative_count += 1

    if not na(originBar) and not na(confirmBar) and confirmBar >= originBar
        pushFloatLimited(state.confirmation_lags, float(confirmBar - originBar), sampleLimit)

    if not na(originBar) and not na(state.last_origin_bar) and originBar > state.last_origin_bar
        pushFloatLimited(state.spacings, float(originBar - state.last_origin_bar), sampleLimit)

    if not na(price) and not na(state.last_price) and state.last_price != 0.0
        pushFloatLimited(state.amplitudes_pct, math.abs(price - state.last_price) / math.abs(state.last_price) * 100.0, sampleLimit)

    state.last_origin_bar := originBar
    state.last_price := price
    true

export geometryPositiveCount(GeometryState state) => state.positive_count
export geometryNegativeCount(GeometryState state) => state.negative_count
export geometryConfirmationLags(GeometryState state) => state.confirmation_lags
export geometrySpacings(GeometryState state) => state.spacings
export geometryAmplitudesPct(GeometryState state) => state.amplitudes_pct

//==============================================================================
// GENERIC TRANSITION TIMERS
//==============================================================================

export type TransitionSlot
    int pending_bar
    int count
    array<float> samples

export type TransitionSetState
    array<TransitionSlot> slots

export newTransitionSetState(int slotCount) =>
    array<TransitionSlot> slots = array.new<TransitionSlot>()
    if slotCount > 0
        for i = 0 to slotCount - 1
            array.push(slots, TransitionSlot.new(na, 0, array.new_float()))
    TransitionSetState.new(slots)

export armTransition(TransitionSetState state, int slotIndex, int sourceBar) =>
    if slotIndex >= 0 and slotIndex < array.size(state.slots)
        TransitionSlot slot = array.get(state.slots, slotIndex)
        slot.pending_bar := sourceBar
        array.set(state.slots, slotIndex, slot)
    true

export consumeTransition(TransitionSetState state, int slotIndex, int destinationBar, int sampleLimit, bool strictlyLater) =>
    bool consumed = false
    if slotIndex >= 0 and slotIndex < array.size(state.slots)
        TransitionSlot slot = array.get(state.slots, slotIndex)
        bool eligible = not na(slot.pending_bar) and not na(destinationBar) and (strictlyLater ? destinationBar > slot.pending_bar : destinationBar >= slot.pending_bar)
        if eligible
            slot.count += 1
            pushFloatLimited(slot.samples, float(destinationBar - slot.pending_bar), sampleLimit)
            slot.pending_bar := na
            array.set(state.slots, slotIndex, slot)
            consumed := true
    consumed

export transitionCount(TransitionSetState state, int slotIndex) =>
    int result = 0
    if slotIndex >= 0 and slotIndex < array.size(state.slots)
        TransitionSlot slot = array.get(state.slots, slotIndex)
        result := slot.count
    result

export transitionSamples(TransitionSetState state, int slotIndex) =>
    array<float> result = array.new_float()
    if slotIndex >= 0 and slotIndex < array.size(state.slots)
        TransitionSlot slot = array.get(state.slots, slotIndex)
        result := slot.samples
    result


//==============================================================================
// GENERIC SINGLE-PENDING BINARY-CATEGORY TRANSITION
//==============================================================================

// One pending source belongs to anonymous caller category 0 or 1. A newer arm replaces the
// older source/category. Consumption records the elapsed sample in the total and in only the
// pending category, then clears it. No event meaning is encoded here.
export type BinaryTransitionState
    int pending_bar
    int pending_category
    int total_count
    array<float> total_samples
    int category0_count
    int category1_count
    array<float> category0_samples
    array<float> category1_samples

export newBinaryTransitionState() =>
    BinaryTransitionState.new(na, -1, 0, array.new_float(), 0, 0, array.new_float(), array.new_float())

export armBinaryTransition(BinaryTransitionState state, int sourceBar, int categoryIndex) =>
    state.pending_bar := sourceBar
    state.pending_category := categoryIndex
    true

export consumeBinaryTransition(BinaryTransitionState state, int destinationBar, int sampleLimit, bool strictlyLater) =>
    bool consumed = false
    bool eligible = not na(state.pending_bar) and not na(destinationBar) and (strictlyLater ? destinationBar > state.pending_bar : destinationBar >= state.pending_bar)
    if eligible
        float elapsed = float(destinationBar - state.pending_bar)
        state.total_count += 1
        pushFloatLimited(state.total_samples, elapsed, sampleLimit)
        if state.pending_category == 0
            state.category0_count += 1
            pushFloatLimited(state.category0_samples, elapsed, sampleLimit)
        else if state.pending_category == 1
            state.category1_count += 1
            pushFloatLimited(state.category1_samples, elapsed, sampleLimit)
        state.pending_bar := na
        state.pending_category := -1
        consumed := true
    consumed

export binaryTransitionCount(BinaryTransitionState state) => state.total_count
export binaryTransitionSamples(BinaryTransitionState state) => state.total_samples
export binaryTransitionCategoryCount(BinaryTransitionState state, int categoryIndex) => categoryIndex == 0 ? state.category0_count : categoryIndex == 1 ? state.category1_count : 0
export binaryTransitionCategorySamples(BinaryTransitionState state, int categoryIndex) => categoryIndex == 0 ? state.category0_samples : categoryIndex == 1 ? state.category1_samples : array.new_float()

//==============================================================================
// GENERIC INTEGER-BITMASK MEMBERSHIP OBSERVATIONS
//==============================================================================

_maskHas(int mask, int memberIndex) =>
    int bit = 1
    if memberIndex > 0
        for i = 1 to memberIndex
            bit *= 2
    mask >= 0 and int(mask / bit) % 2 == 1

_maskCount(int mask, int memberCount) =>
    int result = 0
    if mask >= 0 and memberCount > 0
        for memberIndex = 0 to memberCount - 1
            if _maskHas(mask, memberIndex)
                result += 1
    result

_masksIntersect(int firstMask, int secondMask, int memberCount) =>
    bool result = false
    if firstMask > 0 and secondMask > 0 and memberCount > 0
        for memberIndex = 0 to memberCount - 1
            if _maskHas(firstMask, memberIndex) and _maskHas(secondMask, memberIndex)
                result := true
    result

export type MaskCategoryState
    int category_count
    int member_count
    array<int> category_members
    int exact_count
    int outside_count
    int overlap_count
    int origin_same_count
    int origin_cross_count
    int origin_outside_count
    int consecutive_same_count
    int consecutive_cross_count
    int consecutive_outside_count
    int last_mask

export newMaskCategoryState(int categoryCount, int memberCount) =>
    MaskCategoryState.new(categoryCount, memberCount, array.new_int(categoryCount * memberCount, 0), 0, 0, 0, 0, 0, 0, 0, 0, 0, -1)

export observeMaskCategory(MaskCategoryState state, int categoryIndex, int originMask, int confirmMask) =>
    if confirmMask >= 0
        state.exact_count += 1
        if confirmMask == 0
            state.outside_count += 1
        else
            if _maskCount(confirmMask, state.member_count) > 1
                state.overlap_count += 1
            if categoryIndex >= 0 and categoryIndex < state.category_count
                int base = categoryIndex * state.member_count
                for memberIndex = 0 to state.member_count - 1
                    if _maskHas(confirmMask, memberIndex)
                        int slot = base + memberIndex
                        array.set(state.category_members, slot, array.get(state.category_members, slot) + 1)

        if originMask >= 0
            if originMask == 0 or confirmMask == 0
                state.origin_outside_count += 1
            else if _masksIntersect(originMask, confirmMask, state.member_count)
                state.origin_same_count += 1
            else
                state.origin_cross_count += 1

        if state.last_mask >= 0
            if state.last_mask == 0 or confirmMask == 0
                state.consecutive_outside_count += 1
            else if _masksIntersect(state.last_mask, confirmMask, state.member_count)
                state.consecutive_same_count += 1
            else
                state.consecutive_cross_count += 1
        state.last_mask := confirmMask
    true

export maskCategoryExactCount(MaskCategoryState state) => state.exact_count
export maskCategoryOutsideCount(MaskCategoryState state) => state.outside_count
export maskCategoryOverlapCount(MaskCategoryState state) => state.overlap_count
export maskCategoryOriginSameCount(MaskCategoryState state) => state.origin_same_count
export maskCategoryOriginCrossCount(MaskCategoryState state) => state.origin_cross_count
export maskCategoryOriginOutsideCount(MaskCategoryState state) => state.origin_outside_count
export maskCategoryConsecutiveSameCount(MaskCategoryState state) => state.consecutive_same_count
export maskCategoryConsecutiveCrossCount(MaskCategoryState state) => state.consecutive_cross_count
export maskCategoryConsecutiveOutsideCount(MaskCategoryState state) => state.consecutive_outside_count

export maskCategoryMemberCount(MaskCategoryState state, int categoryIndex, int memberIndex) =>
    int result = 0
    if categoryIndex >= 0 and categoryIndex < state.category_count and memberIndex >= 0 and memberIndex < state.member_count
        result := array.get(state.category_members, categoryIndex * state.member_count + memberIndex)
    result

export maskCategoryText4(MaskCategoryState state, int categoryIndex, string label0, string label1, string label2, string label3) =>
    label0 + " " + str.tostring(maskCategoryMemberCount(state, categoryIndex, 0)) +
     " · " + label1 + " " + str.tostring(maskCategoryMemberCount(state, categoryIndex, 1)) +
     " · " + label2 + " " + str.tostring(maskCategoryMemberCount(state, categoryIndex, 2)) +
     " · " + label3 + " " + str.tostring(maskCategoryMemberCount(state, categoryIndex, 3))

export maskCategoryCombinedText4(MaskCategoryState state, int firstCategoryIndex, int secondCategoryIndex, string label0, string label1, string label2, string label3) =>
    label0 + " " + str.tostring(maskCategoryMemberCount(state, firstCategoryIndex, 0) + maskCategoryMemberCount(state, secondCategoryIndex, 0)) +
     " · " + label1 + " " + str.tostring(maskCategoryMemberCount(state, firstCategoryIndex, 1) + maskCategoryMemberCount(state, secondCategoryIndex, 1)) +
     " · " + label2 + " " + str.tostring(maskCategoryMemberCount(state, firstCategoryIndex, 2) + maskCategoryMemberCount(state, secondCategoryIndex, 2)) +
     " · " + label3 + " " + str.tostring(maskCategoryMemberCount(state, firstCategoryIndex, 3) + maskCategoryMemberCount(state, secondCategoryIndex, 3))

export maskCategoryAllText4(MaskCategoryState state, string label0, string label1, string label2, string label3) =>
    int member0 = 0
    int member1 = 0
    int member2 = 0
    int member3 = 0
    if state.category_count > 0
        for categoryIndex = 0 to state.category_count - 1
            member0 += maskCategoryMemberCount(state, categoryIndex, 0)
            member1 += maskCategoryMemberCount(state, categoryIndex, 1)
            member2 += maskCategoryMemberCount(state, categoryIndex, 2)
            member3 += maskCategoryMemberCount(state, categoryIndex, 3)
    label0 + " " + str.tostring(member0) + " · " + label1 + " " + str.tostring(member1) + " · " + label2 + " " + str.tostring(member2) + " · " + label3 + " " + str.tostring(member3)

export type MaskCountState
    int member_count
    array<int> members
    int exact_count
    int outside_count
    int overlap_count

export newMaskCountState(int memberCount) =>
    MaskCountState.new(memberCount, array.new_int(memberCount, 0), 0, 0, 0)

export observeMask(MaskCountState state, int mask) =>
    if mask >= 0
        state.exact_count += 1
        if mask == 0
            state.outside_count += 1
        else
            if _maskCount(mask, state.member_count) > 1
                state.overlap_count += 1
            for memberIndex = 0 to state.member_count - 1
                if _maskHas(mask, memberIndex)
                    array.set(state.members, memberIndex, array.get(state.members, memberIndex) + 1)
    true

export maskCountMember(MaskCountState state, int memberIndex) =>
    memberIndex >= 0 and memberIndex < state.member_count ? array.get(state.members, memberIndex) : 0

export maskCountOutside(MaskCountState state) => state.outside_count
export maskCountExact(MaskCountState state) => state.exact_count
export maskCountOverlap(MaskCountState state) => state.overlap_count

export maskCountText4(MaskCountState state, string label0, string label1, string label2, string label3) =>
    label0 + " " + str.tostring(maskCountMember(state, 0)) +
     " · " + label1 + " " + str.tostring(maskCountMember(state, 1)) +
     " · " + label2 + " " + str.tostring(maskCountMember(state, 2)) +
     " · " + label3 + " " + str.tostring(maskCountMember(state, 3))

//==============================================================================
// v7 GENERIC RESEARCH TEXT FORMATTERS
//==============================================================================
// These functions only format caller-supplied anonymous counts/states and labels. They contain
// no indicator terminology, event mapping, cohort definition, direction meaning or methodology.

export numberOr(float value, string suffix, string emptyText) =>
    na(value) ? emptyText : str.tostring(value, "#.##") + suffix

export scaledRateText(int numerator, int denominator, float scale, string suffix, string emptyText) =>
    denominator > 0 ? str.tostring(float(numerator) / float(denominator) * scale, "#.##") + suffix : emptyText

export coverageText(CoverageState state, string countSuffix, string elapsedSuffix, string emptyText) =>
    float elapsed = coverageElapsedDays(state)
    str.tostring(coverageCount(state)) + countSuffix + " · " + (na(elapsed) ? emptyText : str.tostring(elapsed, "#.##") + elapsedSuffix)

export categoryText7(CategoryCountsState state, string label0, string label1, string label2, string label3, string label4, string label5, string label6) =>
    label0 + " " + str.tostring(categoryCount(state, 0)) +
     " · " + label1 + " " + str.tostring(categoryCount(state, 1)) +
     " · " + label2 + " " + str.tostring(categoryCount(state, 2)) +
     " · " + label3 + " " + str.tostring(categoryCount(state, 3)) +
     " · " + label4 + " " + str.tostring(categoryCount(state, 4)) +
     " · " + label5 + " " + str.tostring(categoryCount(state, 5)) +
     " · " + label6 + " " + str.tostring(categoryCount(state, 6))

export bucketDirectionText(BucketSetState state, int bucketIndex, string positiveLabel, string negativeLabel) =>
    positiveLabel + " " + str.tostring(bucketPositive(state, bucketIndex)) + " · " + negativeLabel + " " + str.tostring(bucketNegative(state, bucketIndex))

export episodeDirectionText(EpisodeState state, string positiveLabel, string negativeLabel) =>
    positiveLabel + " " + str.tostring(episodePositiveCount(state)) + " · " + negativeLabel + " " + str.tostring(episodeNegativeCount(state))

export geometryPairText(GeometryState firstState, GeometryState secondState, string firstLabel, string secondLabel) =>
    firstLabel + " " + str.tostring(geometryPositiveCount(firstState) + geometryNegativeCount(firstState)) +
     " · " + secondLabel + " " + str.tostring(geometryPositiveCount(secondState) + geometryNegativeCount(secondState))

export geometryFourText(GeometryState firstState, GeometryState secondState, string firstPositiveLabel, string firstNegativeLabel, string secondPositiveLabel, string secondNegativeLabel) =>
    firstPositiveLabel + " " + str.tostring(geometryPositiveCount(firstState)) +
     " · " + firstNegativeLabel + " " + str.tostring(geometryNegativeCount(firstState)) +
     " · " + secondPositiveLabel + " " + str.tostring(geometryPositiveCount(secondState)) +
     " · " + secondNegativeLabel + " " + str.tostring(geometryNegativeCount(secondState))

export maskCategorySummaryText(MaskCategoryState state, string exactLabel, string outsideLabel, string overlapLabel, string emptyPercentText) =>
    str.tostring(maskCategoryExactCount(state)) + " " + exactLabel +
     " · " + outsideLabel + " " + str.tostring(maskCategoryOutsideCount(state)) +
     " · " + overlapLabel + " " + str.tostring(maskCategoryOverlapCount(state)) +
     " (" + percentOr(maskCategoryOverlapCount(state), maskCategoryExactCount(state), emptyPercentText) + ")"

export maskCategorySingleAllText(MaskCategoryState state, int memberIndex, string memberLabel, string outsideLabel) =>
    int total = 0
    if state.category_count > 0
        for categoryIndex = 0 to state.category_count - 1
            total += maskCategoryMemberCount(state, categoryIndex, memberIndex)
    memberLabel + " " + str.tostring(total) + " · " + outsideLabel + " " + str.tostring(maskCategoryOutsideCount(state))

export maskCategorySingleText(MaskCategoryState state, int categoryIndex, int memberIndex, string memberLabel) =>
    memberLabel + " " + str.tostring(maskCategoryMemberCount(state, categoryIndex, memberIndex))

export maskCategoryCombinedSingleText(MaskCategoryState state, int firstCategoryIndex, int secondCategoryIndex, int memberIndex, string memberLabel) =>
    memberLabel + " " + str.tostring(maskCategoryMemberCount(state, firstCategoryIndex, memberIndex) + maskCategoryMemberCount(state, secondCategoryIndex, memberIndex))

export maskCountSingleText(MaskCountState state, int memberIndex, string memberLabel, string outsideLabel) =>
    memberLabel + " " + str.tostring(maskCountMember(state, memberIndex)) + " · " + outsideLabel + " " + str.tostring(maskCountOutside(state))

export maskCategoryOriginRelationText(MaskCategoryState state, string sameLabel, string crossLabel, string outsideLabel) =>
    sameLabel + " " + str.tostring(maskCategoryOriginSameCount(state)) +
     " · " + crossLabel + " " + str.tostring(maskCategoryOriginCrossCount(state)) +
     " · " + outsideLabel + " " + str.tostring(maskCategoryOriginOutsideCount(state))

export maskCategoryConsecutiveRelationText(MaskCategoryState state, string sameLabel, string crossLabel, string outsideLabel) =>
    sameLabel + " " + str.tostring(maskCategoryConsecutiveSameCount(state)) +
     " · " + crossLabel + " " + str.tostring(maskCategoryConsecutiveCrossCount(state)) +
     " · " + outsideLabel + " " + str.tostring(maskCategoryConsecutiveOutsideCount(state))

export maskCategoryAdaptiveAllText(MaskCategoryState state, bool useFourMembers, int singleMemberIndex, string singleLabel, string outsideLabel, string label0, string label1, string label2, string label3) =>
    useFourMembers ? maskCategoryAllText4(state, label0, label1, label2, label3) : maskCategorySingleAllText(state, singleMemberIndex, singleLabel, outsideLabel)

export maskCategoryAdaptiveText(MaskCategoryState state, int categoryIndex, bool useFourMembers, int singleMemberIndex, string singleLabel, string label0, string label1, string label2, string label3) =>
    useFourMembers ? maskCategoryText4(state, categoryIndex, label0, label1, label2, label3) : maskCategorySingleText(state, categoryIndex, singleMemberIndex, singleLabel)

export maskCategoryAdaptiveCombinedText(MaskCategoryState state, int firstCategoryIndex, int secondCategoryIndex, bool useFourMembers, int singleMemberIndex, string singleLabel, string label0, string label1, string label2, string label3) =>
    useFourMembers ? maskCategoryCombinedText4(state, firstCategoryIndex, secondCategoryIndex, label0, label1, label2, label3) : maskCategoryCombinedSingleText(state, firstCategoryIndex, secondCategoryIndex, singleMemberIndex, singleLabel)

export maskCountAdaptiveText(MaskCountState state, bool useFourMembers, int singleMemberIndex, string singleLabel, string outsideLabel, string label0, string label1, string label2, string label3) =>
    useFourMembers ? maskCountText4(state, label0, label1, label2, label3) + " · " + outsideLabel + " " + str.tostring(maskCountOutside(state)) : maskCountSingleText(state, singleMemberIndex, singleLabel, outsideLabel)

export bucketRangeTotal(BucketSetState state, int firstBucketIndex, int lastBucketIndex) =>
    int total = 0
    int first = math.max(firstBucketIndex, 0)
    int last = math.min(lastBucketIndex, array.size(state.buckets) - 1)
    if last >= first
        for bucketIndex = first to last
            total += bucketTotal(state, bucketIndex)
    total

export geometryTotal(GeometryState state) =>
    geometryPositiveCount(state) + geometryNegativeCount(state)
````
