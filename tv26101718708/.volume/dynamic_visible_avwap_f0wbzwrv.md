# Dynamic Visible AVWAP

- url: https://www.tradingview.com/script/F0wbzwRV-Dynamic-Visible-AVWAP/
- type: indicator
- pine_id: PUB;b8b4387b4d774ee993c2cb99b2597c4e
- version: 1.0

## Description

Dynamic Visible AVWAP is a visible-range anchored VWAP tool designed to help traders read active price interaction with important visible swing areas.

The script automatically anchors AVWAP lines from the highest high and/or lowest low inside the currently visible chart range. This makes the tool dynamic: when the visible chart area changes, the anchors are recalculated from the new visible range.

Additional AVWAPs can be enabled with the AVWAP Count setting. When more than one AVWAP is selected, the script adds extra anchors from the next valid swing highs or swing lows. This allows multiple AVWAP references to be displayed at the same time, creating a clearer view of potential confluence zones.

[b]Main features:[/b]

Dynamic AVWAP based on the currently visible chart range
Long, Short, or All display modes
Optional multiple AVWAPs per side
Optional deviation channels around each AVWAP
Optional channel fill
Separate style controls for AVWAP lines, channels, arrows, and anchor text
Optional anchor arrows and custom anchor label text
Adjustable text size for anchor labels
Optimized line budgeting to keep the script stable when multiple AVWAPs are displayed

[b]How it can be used:[/b]

Dynamic Visible AVWAP can help identify areas where price is interacting with volume-weighted mean levels from important visible swing points. These levels may be useful for context, confluence, pullback analysis, trend continuation review, or mean-reversion observation.

[b]Important note:[/b]

The anchors are based on the currently visible chart range. If you zoom, scroll, or change the visible area of the chart, the AVWAP anchors may change because the script recalculates the highest high, lowest low, and additional swing anchors from the new visible range.

[i]This indicator should be used together with broader market analysis, such as structure, volume, liquidity, higher-timeframe levels, and personal risk management.[/i]

## Source Code

````pine
//@version=6
// SPDX-License-Identifier: MPL-2.0
// This source code is subject to the Mozilla Public License 2.0: https://mozilla.org/MPL/2.0/

indicator("Dynamic Visible AVWAP", overlay=true, max_bars_back=5000, max_lines_count=500, max_labels_count=50)

// Inputs
groupMain = "Dynamic AVWAP"
mode = input.string("All", "Mode", options=["All", "Long", "Short"], group=groupMain)
src = input.source(hlc3, "VWAP Source", group=groupMain)
avwapCount = input.int(1, "AVWAP Count Per Side", minval=1, maxval=8, group=groupMain, tooltip="Minimum: 1. Maximum: 8. 1 draws only the primary visible-range AVWAP per side. Higher values add additional AVWAPs from the next valid swing highs or swing lows.")

groupChannel = "Channels"
showChannels = input.bool(true, "Show Channels", group=groupChannel)
bandsMultiplier = input.float(2.0, "Bands Multiplier", minval=0.0001, step=0.1, group=groupChannel)
fillChannel = input.bool(false, "Fill Channel", group=groupChannel)
channelFillColor = input.color(color.white, "Channel Fill Color", group=groupChannel)
channelFillTransparency = input.int(90, "Channel Fill Transparency", minval=0, maxval=100, group=groupChannel)

groupLabels = "Labels"
showAnchorArrows = input.bool(false, "Show Anchor Arrows", group=groupLabels)
showAnchorText = input.bool(false, "Show Anchor Text", group=groupLabels)
anchorLabelText = input.string("AVWAP", "Anchor Label Text", group=groupLabels, tooltip="Text displayed next to each anchor point when Show Anchor Text is enabled. Text can be displayed with or without anchor arrows.")
anchorTextSize = input.string("Large", "Anchor Text Size", options=["Tiny", "Small", "Normal", "Large"], group=groupLabels)
fallingArrowColor = input.color(color.rgb(0, 90, 255), "Falling Arrow Color", group=groupLabels)
risingArrowColor = input.color(color.white, "Rising Arrow Color", group=groupLabels)

groupStyle = "Style"
vwapColor = input.color(color.rgb(0, 90, 255), "VWAP Color", group=groupStyle)
channelColor = input.color(color.white, "Channel Color", group=groupStyle)
vwapWidth = input.int(2, "VWAP Width", minval=1, maxval=5, group=groupStyle)
channelWidth = input.int(1, "Channel Width", minval=1, maxval=4, group=groupStyle)

// Settings
const int scanBars = 4900
const int swingStrength = 5
const int maxSegmentsPerPath = 100
const int maxDrawableLines = 460

// Storage
var array<line> dynLines = array.new<line>()
var array<label> dynLabels = array.new<label>()
var array<linefill> dynFills = array.new<linefill>()

f_text_size(string selectedSize) =>
    selectedSize == "Tiny" ? size.tiny : selectedSize == "Small" ? size.small : selectedSize == "Normal" ? size.normal : size.large

f_clear_lines(array<line> store) =>
    while array.size(store) > 0
        line.delete(array.pop(store))

f_clear_labels(array<label> store) =>
    while array.size(store) > 0
        label.delete(array.pop(store))

f_clear_fills(array<linefill> store) =>
    while array.size(store) > 0
        linefill.delete(array.pop(store))

f_add_segment(array<line> store, int x1, float y1, int x2, float y2, color col, int width) =>
    line newLine = na

    if not na(y1) and not na(y2) and x1 != x2
        newLine := line.new(x1=x1, y1=y1, x2=x2, y2=y2, xloc=xloc.bar_index, extend=extend.none, color=col, style=line.style_solid, width=width)
        array.push(store, newLine)

    newLine

f_add_fill(array<linefill> fillStore, line upperLine, line lowerLine) =>
    if fillChannel and not na(upperLine) and not na(lowerLine)
        array.push(fillStore, linefill.new(upperLine, lowerLine, color.new(channelFillColor, channelFillTransparency)))

f_has_offset(array<int> offsets, int off) =>
    bool found = false

    if array.size(offsets) > 0
        for i = 0 to array.size(offsets) - 1
            if array.get(offsets, i) == off
                found := true

    found

f_is_visible(int off) =>
    time[off] >= chart.left_visible_bar_time and time[off] <= chart.right_visible_bar_time

f_is_swing_high(int off, int strength, int limit) =>
    bool ok = not na(off) and off - strength >= 0 and off + strength <= limit

    if ok
        for k = 1 to strength
            ok := ok and high[off] > high[off - k] and high[off] >= high[off + k]

    ok

f_is_swing_low(int off, int strength, int limit) =>
    bool ok = not na(off) and off - strength >= 0 and off + strength <= limit

    if ok
        for k = 1 to strength
            ok := ok and low[off] < low[off - k] and low[off] <= low[off + k]

    ok

f_find_next_lower_swing_high(array<int> candidates, array<int> selectedOffsets, float previousLevel) =>
    int bestOff = na
    float bestLevel = na

    if not na(previousLevel) and array.size(candidates) > 0
        for i = 0 to array.size(candidates) - 1
            int off = array.get(candidates, i)
            bool validCandidate = not f_has_offset(selectedOffsets, off) and high[off] < previousLevel

            if validCandidate
                if na(bestLevel) or high[off] > bestLevel
                    bestLevel := high[off]
                    bestOff := off

    bestOff

f_find_next_higher_swing_low(array<int> candidates, array<int> selectedOffsets, float previousLevel) =>
    int bestOff = na
    float bestLevel = na

    if not na(previousLevel) and array.size(candidates) > 0
        for i = 0 to array.size(candidates) - 1
            int off = array.get(candidates, i)
            bool validCandidate = not f_has_offset(selectedOffsets, off) and low[off] > previousLevel

            if validCandidate
                if na(bestLevel) or low[off] < bestLevel
                    bestLevel := low[off]
                    bestOff := off

    bestOff

f_add_anchor_label(array<label> labelStore, int anchorOff, bool isHighAnchor, int rank, color baseLabelColor) =>
    bool shouldDrawLabel = showAnchorArrows or showAnchorText

    if shouldDrawLabel and not na(anchorOff) and anchorOff >= 0
        int labelX = bar_index - anchorOff
        float labelY = isHighAnchor ? high[anchorOff] : low[anchorOff]

        string arrowText = showAnchorArrows ? isHighAnchor ? "⥥" : "⥣" : ""
        string rankTextWithArrow = showAnchorArrows and rank > 1 ? str.tostring(rank) : ""
        string rankTextWithoutArrow = not showAnchorArrows and showAnchorText and rank > 1 ? str.tostring(rank) + " " : ""
        string customText = showAnchorText and anchorLabelText != "" ? anchorLabelText : ""

        string spacer = showAnchorArrows and showAnchorText and anchorLabelText != "" ? " " : ""
        string labelText = arrowText + rankTextWithArrow + spacer + rankTextWithoutArrow + customText

        if labelText != ""
            int fade = math.min(75, (rank - 1) * 18)
            color activeLabelColor = color.new(baseLabelColor, fade)

            array.push(labelStore, label.new(x=labelX, y=labelY, text=labelText, xloc=xloc.bar_index, style=label.style_none, color=color.new(activeLabelColor, 100), textcolor=activeLabelColor, size=f_text_size(anchorTextSize)))

f_draw_avwap_from_anchor(array<line> lineStore, array<label> labelStore, array<linefill> fillStore, int anchorOff, int endOff, bool isHighAnchor, int rank, int maxSegments, color baseLabelColor) =>
    if not na(anchorOff) and not na(endOff) and anchorOff >= endOff and anchorOff >= 0 and endOff >= 0
        bool needChannelLines = showChannels or fillChannel

        float cumPV = 0.0
        float cumPV2 = 0.0
        float cumV = 0.0

        float prevVwap = na
        float prevUpper = na
        float prevLower = na
        int prevX = na

        int barsFromAnchor = anchorOff - endOff + 1
        float rawStep = barsFromAnchor * 1.0 / maxSegments
        int stepBars = math.max(1, int(math.ceil(rawStep)))

        int fade = math.min(75, (rank - 1) * 18)
        color activeVwapColor = color.new(vwapColor, fade)
        color activeChannelBaseColor = color.new(channelColor, fade)
        int activeVwapWidth = rank == 1 ? vwapWidth : math.max(1, vwapWidth - 1)

        for i = 0 to barsFromAnchor - 1
            int o = anchorOff - i

            float price = nz(src[o], hlc3[o])
            float vol = na(volume[o]) or volume[o] <= 0.0 ? 1.0 : volume[o]

            cumPV += price * vol
            cumV += vol

            if needChannelLines
                cumPV2 += price * price * vol

            float avwap = cumV > 0.0 ? cumPV / cumV : na
            float variance = needChannelLines and cumV > 0.0 ? math.max(cumPV2 / cumV - avwap * avwap, 0.0) : na
            float deviation = not na(variance) ? math.sqrt(variance) : na

            float upper = needChannelLines and not na(avwap) and not na(deviation) ? avwap + deviation * bandsMultiplier : na
            float lower = needChannelLines and not na(avwap) and not na(deviation) ? avwap - deviation * bandsMultiplier : na

            bool drawPoint = i % stepBars == 0 or o == endOff

            if drawPoint and not na(avwap)
                int x = bar_index - o

                if not na(prevX)
                    f_add_segment(lineStore, prevX, prevVwap, x, avwap, activeVwapColor, activeVwapWidth)

                    if needChannelLines
                        color activeChannelColor = showChannels ? activeChannelBaseColor : color.new(activeChannelBaseColor, 100)
                        int activeChannelWidth = showChannels ? channelWidth : 1

                        line upperLine = f_add_segment(lineStore, prevX, prevUpper, x, upper, activeChannelColor, activeChannelWidth)
                        line lowerLine = f_add_segment(lineStore, prevX, prevLower, x, lower, activeChannelColor, activeChannelWidth)

                        f_add_fill(fillStore, upperLine, lowerLine)

                prevX := x
                prevVwap := avwap
                prevUpper := upper
                prevLower := lower

        f_add_anchor_label(labelStore, anchorOff, isHighAnchor, rank, baseLabelColor)

// Main calculation
if barstate.islast
    f_clear_fills(dynFills)
    f_clear_lines(dynLines)
    f_clear_labels(dynLabels)

    int scanLimit = math.min(scanBars, bar_index)

    float highestVisible = na
    float lowestVisible = na
    int highestOff = na
    int lowestOff = na
    int rightVisibleOff = na

    bool showShortAvwap = mode == "All" or mode == "Short"
    bool showLongAvwap = mode == "All" or mode == "Long"
    bool needExtraAnchors = avwapCount > 1

    array<int> swingHighCandidates = array.new<int>()
    array<int> swingLowCandidates = array.new<int>()

    for off = 0 to scanLimit
        bool inVisible = f_is_visible(off)

        if inVisible
            if na(rightVisibleOff) or off < rightVisibleOff
                rightVisibleOff := off

            if showShortAvwap and (na(highestVisible) or high[off] > highestVisible)
                highestVisible := high[off]
                highestOff := off

            if showLongAvwap and (na(lowestVisible) or low[off] < lowestVisible)
                lowestVisible := low[off]
                lowestOff := off

            if needExtraAnchors and showShortAvwap and f_is_swing_high(off, swingStrength, scanLimit)
                array.push(swingHighCandidates, off)

            if needExtraAnchors and showLongAvwap and f_is_swing_low(off, swingStrength, scanLimit)
                array.push(swingLowCandidates, off)

    if na(rightVisibleOff)
        rightVisibleOff := 0

    array<int> shortAnchors = array.new<int>()
    array<int> longAnchors = array.new<int>()

    if showShortAvwap and not na(highestOff)
        array.push(shortAnchors, highestOff)

        float previousShortLevel = highestVisible

        if needExtraAnchors
            for n = 2 to avwapCount
                int nextShortOff = f_find_next_lower_swing_high(swingHighCandidates, shortAnchors, previousShortLevel)

                if not na(nextShortOff)
                    array.push(shortAnchors, nextShortOff)
                    previousShortLevel := high[nextShortOff]

    if showLongAvwap and not na(lowestOff)
        array.push(longAnchors, lowestOff)

        float previousLongLevel = lowestVisible

        if needExtraAnchors
            for n = 2 to avwapCount
                int nextLongOff = f_find_next_higher_swing_low(swingLowCandidates, longAnchors, previousLongLevel)

                if not na(nextLongOff)
                    array.push(longAnchors, nextLongOff)
                    previousLongLevel := low[nextLongOff]

    int activePaths = array.size(shortAnchors) + array.size(longAnchors)
    bool needChannelLinesForBudget = showChannels or fillChannel
    int linesPerSegment = needChannelLinesForBudget ? 3 : 1
    int dynamicSegmentsPerPath = activePaths > 0 ? int(math.floor(maxDrawableLines / math.max(1, activePaths * linesPerSegment))) : maxSegmentsPerPath
    dynamicSegmentsPerPath := math.max(6, math.min(maxSegmentsPerPath, dynamicSegmentsPerPath))

    if array.size(shortAnchors) > 0
        for i = 0 to array.size(shortAnchors) - 1
            int anchorOff = array.get(shortAnchors, i)
            f_draw_avwap_from_anchor(dynLines, dynLabels, dynFills, anchorOff, rightVisibleOff, true, i + 1, dynamicSegmentsPerPath, fallingArrowColor)

    if array.size(longAnchors) > 0
        for i = 0 to array.size(longAnchors) - 1
            int anchorOff = array.get(longAnchors, i)
            f_draw_avwap_from_anchor(dynLines, dynLabels, dynFills, anchorOff, rightVisibleOff, false, i + 1, dynamicSegmentsPerPath, risingArrowColor)
````
