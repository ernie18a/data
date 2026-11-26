# Kivra Liquidity Nodes [JOAT]

- url: https://www.tradingview.com/script/K1S0k8tR-Kivra-Liquidity-Nodes-JOAT/
- type: indicator
- pine_id: PUB;a8351e45c51348a8b3f7a6e7a6931d5f
- version: 1.0

## Description

[b]Kivra Liquidity Nodes [JOAT][/b]

[b]Introduction[/b]

Kivra Liquidity Nodes is an open-source right-edge volume profile that finds high-participation price areas inside a configurable lookback window. It distributes each bar's volume across price rows, smooths the result, highlights the point of control, and labels local liquidity nodes.

The problem it solves is volume context. A raw profile can show where trading occurred, but it often becomes visually heavy. Kivra Liquidity Nodes keeps the profile compact, separates bullish and bearish participation estimates, and prioritizes POC, value area, and node labels. The profile is offset to the right of price, while the lookback range and value area remain visible on the active chart so the levels have context.

[image]https://www.tradingview.com/x/VaI4TlOG/[/image]

[b]Core Concepts[/b]

[b]1. Price-Overlap Volume Allocation[/b]

Each bar contributes volume to every row it overlaps. This makes the profile more representative than assigning all volume to a single close price.

[b]2. Participation Split[/b]

The script estimates bullish and bearish participation from candle direction and close location inside the bar range. This is a proxy designed for visual context, not bid/ask delta.

[b]3. Smoothed Node Detection[/b]

Profile rows are smoothed with neighboring rows. Local peaks above an average-volume threshold become liquidity nodes.

[b]4. Value Area Expansion[/b]

The value area expands from the POC until the selected portion of total profile volume is covered.

[b]5. Context Bands and Candle Tinting[/b]

The script shades the full lookback range, marks the value area across the live price region, draws node bands across the profiled window, prints VAH/VAL and POC labels far to the right of the profile to avoid overlap, and can tint candles using a pressure blend from trend location and candle direction.

[b]Features[/b]

[list]
[*][b]Right-edge profile:[/b] Clean horizontal profile projected to the right of the chart
[*][b]POC line and label:[/b] Dashed level marking the highest-volume row
[*][b]POC line and label:[/b] Dashed level marking the highest-volume row with price and row volume
[*][b]VAH and VAL labels:[/b] Right-edge value-area high and low labels with dotted guide lines
[*][b]Value area boxes:[/b] Shaded profile zone plus live-chart value band across the lookback
[*][b]Lookback range box:[/b] Subtle range boundary around the profiled window
[*][b]Bull/bear split bars:[/b] Row coloring estimates directional participation
[*][b]Node labels:[/b] Local high-volume nodes with participation share and volume
[*][b]Node bands:[/b] High-participation node rows project back across the profiled price window
[*][b]Offset label rail:[/b] POC, VAH/VAL, and node labels are projected beyond the histogram so they do not sit on top of the profile
[*][b]Pressure candle tint:[/b] Candles can be softly colored from bearish red to bullish green using trend location and candle direction
[*][b]No-volume fallback:[/b] Uses range proxy when reliable volume is not available
[*][b]Top-right dashboard:[/b] POC, node count, value area width, bias, range, and source
[/list]

[b]Input Parameters[/b]

[b]Calculation:[/b]
[list]
[*]Lookback Bars: Historical bars used for the profile
[*]Profile Rows: Vertical resolution of the profile
[*]Profile Width: Maximum right-edge width
[*]Profile Offset: Distance from current bar to the profile
[*]Value Area Portion: Portion of total profile volume included in value area
[*]Node Threshold: Required row strength for node detection
[*]Node Merge Gap: Distance allowed between merged node peaks
[*]Max Node Labels: Maximum labels drawn for detected nodes
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Use the POC as the dominant participation level in the current lookback.
[b]Step 2:[/b] Use the value area to understand where volume is concentrated.
[b]Step 3:[/b] Watch VAH and VAL as acceptance/rejection boundaries.
[b]Step 4:[/b] Watch labeled nodes as potential reaction or acceptance zones.
[b]Step 5:[/b] Read the dashboard bias and candle tint as context, not as standalone entry signals.

[b]Indicator Limitations[/b]

[list]
[*]Bull/bear participation is an estimate based on candle structure, not exchange bid/ask data
[*]The profile is recalculated on the latest bar and depends on the selected lookback
[*]High node count can add visual density on small screens
[*]Volume data quality varies by market and symbol
[/list]

[b]Originality Statement[/b]

Kivra Liquidity Nodes is original in its compact right-edge implementation combining overlap-based volume allocation, smoothed node detection, value area expansion, participation split visualization, and no-volume fallback logic. It does not copy third-party source code.

[b]Disclaimer[/b]

This open-source indicator is provided for educational and informational purposes only. It is not financial advice. Volume nodes identify historical participation zones and do not guarantee future reactions.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Kivra Liquidity Nodes [JOAT]", "KLN [JOAT]", overlay = true, max_boxes_count = 400, max_lines_count = 200, max_labels_count = 120)

//------------------------------------------------------------------------------
// Original JOAT implementation
// - Overlay liquidity node profile
// - Volume-weighted price bins
// - Local peak clustering and right-side profile rendering
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_table_pos(string choice) =>
    switch choice
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right
        => position.bottom_left

f_table_size(string choice) =>
    switch choice
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_delete_boxes(array<box> bucket) =>
    if array.size(bucket) > 0
        for i = 0 to array.size(bucket) - 1
            box.delete(array.get(bucket, i))
        array.clear(bucket)

f_delete_lines(array<line> bucket) =>
    if array.size(bucket) > 0
        for i = 0 to array.size(bucket) - 1
            line.delete(array.get(bucket, i))
        array.clear(bucket)

f_delete_labels(array<label> bucket) =>
    if array.size(bucket) > 0
        for i = 0 to array.size(bucket) - 1
            label.delete(array.get(bucket, i))
        array.clear(bucket)

//------------------------------------------------------------------------------
// Inputs
//------------------------------------------------------------------------------
groupCalc = "Calculation"
lookbackInput = input.int(180, "Lookback Bars", minval = 40, maxval = 400, group = groupCalc)
rowsInput = input.int(30, "Profile Rows", minval = 12, maxval = 60, group = groupCalc)
widthInput = input.int(52, "Profile Width", minval = 8, maxval = 90, group = groupCalc)
offsetInput = input.int(24, "Profile Offset", minval = 1, maxval = 60, group = groupCalc)
valueAreaInput = input.float(0.70, "Value Area Portion", minval = 0.50, maxval = 0.95, step = 0.05, group = groupCalc)
nodeFactorInput = input.float(1.00, "Node Threshold", minval = 1.00, maxval = 2.50, step = 0.02, group = groupCalc)
mergeGapInput = input.int(0, "Node Merge Gap", minval = 0, maxval = 6, group = groupCalc)
maxNodeInput = input.int(8, "Max Node Labels", minval = 1, maxval = 12, group = groupCalc)

groupVis = "Visual"
showProfileInput = input.bool(true, "Show Volume Profile", group = groupVis)
showValueAreaInput = input.bool(true, "Show Value Area", group = groupVis)
showPocInput = input.bool(true, "Show POC", group = groupVis)
showNodesInput = input.bool(true, "Show Node Labels", group = groupVis)
showDashInput = input.bool(true, "Show Dashboard", group = groupVis)
showRangeInput = input.bool(true, "Show Lookback Range", group = groupVis)
showNodeBandsInput = input.bool(true, "Show Node Bands", group = groupVis)
showCandleTintInput = input.bool(true, "Tint Candles By Profile Bias", group = groupVis)

groupStyle = "Style"
bullInput = input.color(#089981, "Bull Color", group = groupStyle)
bearInput = input.color(#f23645, "Bear Color", group = groupStyle)
neutralInput = input.color(#787b86, "Neutral Color", group = groupStyle)
accentInput = input.color(#ffb020, "POC Accent", group = groupStyle)
nodeHotInput = input.color(#00e5ff, "Node Glow", group = groupStyle)

groupDash = "Dashboard"
dashPosInput = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Bottom Left"], group = groupDash)
dashSizeInput = input.string("Normal", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupDash)

//------------------------------------------------------------------------------
// Persistent draw buckets
//------------------------------------------------------------------------------
var box[] profileBoxes = array.new_box()
var line[] profileLines = array.new_line()
var label[] profileLabels = array.new_label()
var float livePoc = na
var float liveBiasShare = na

var table dash = table.new(f_table_pos(dashPosInput), 2, 7, bgcolor = color.new(#161616, 0), frame_color = color.new(#2E2E2E, 0), frame_width = 1, border_color = color.new(#2E2E2E, 0), border_width = 1)
atrForTint = nz(ta.atr(14), high - low)
emaForTint = ta.ema(close, 34)
barPressure = f_clamp(0.5 + ((close - emaForTint) / math.max(atrForTint, syminfo.mintick)) * 0.16 + (close >= open ? 0.08 : -0.08), 0.0, 1.0)
color candlePressureColor = color.from_gradient(barPressure, 0.0, 1.0, bearInput, bullInput)

//------------------------------------------------------------------------------
// Main profiling routine
//------------------------------------------------------------------------------
rangeHighSeries = ta.highest(high, lookbackInput)
rangeLowSeries = ta.lowest(low, lookbackInput)
volumeProbeSeries = ta.sma(volume, lookbackInput)

canProfile = barstate.islast and bar_index >= lookbackInput - 1

if canProfile
    f_delete_boxes(profileBoxes)
    f_delete_lines(profileLines)
    f_delete_labels(profileLabels)

    float rangeHigh = rangeHighSeries
    float rangeLow = rangeLowSeries
    float rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick)
    float rowSpan = rangeSpan / rowsInput
    int leftEdge = bar_index + offsetInput
    int rightEdge = leftEdge + widthInput

    float volumeProbe = volumeProbeSeries
    bool hasRealVolume = not na(volumeProbe) and volumeProbe > 0.0

    if showRangeInput
        box rangeBox = box.new(bar_index - lookbackInput + 1, rangeHigh, bar_index, rangeLow, xloc = xloc.bar_index, bgcolor = color.new(neutralInput, 96), border_color = color.new(neutralInput, 82), border_width = 1)
        array.push(profileBoxes, rangeBox)

    float[] totalBins = array.new_float(rowsInput, 0.0)
    float[] bullBins = array.new_float(rowsInput, 0.0)
    float[] bearBins = array.new_float(rowsInput, 0.0)

    for i = 0 to lookbackInput - 1
        float h = high[i]
        float l = low[i]
        float o = open[i]
        float c = close[i]
        float barSpan = math.max(h - l, syminfo.mintick)
        float barVol = hasRealVolume ? nz(volume[i], 0.0) : barSpan / syminfo.mintick
        barVol := barVol <= 0.0 ? 1.0 : barVol

        float closePos = f_clamp((c - l) / barSpan, 0.0, 1.0)
        float bullShare = c >= o ? 0.58 + 0.30 * closePos : 0.22 + 0.28 * closePos
        bullShare := f_clamp(bullShare, 0.0, 1.0)
        float bearShare = 1.0 - bullShare

        for r = 0 to rowsInput - 1
            float rowBottom = rangeLow + r * rowSpan
            float rowTop = rowBottom + rowSpan
            float overlapLow = math.max(l, rowBottom)
            float overlapHigh = math.min(h, rowTop)
            float overlap = overlapHigh - overlapLow

            if overlap > 0.0
                float alloc = barVol * (overlap / barSpan)
                array.set(totalBins, r, array.get(totalBins, r) + alloc)
                array.set(bullBins, r, array.get(bullBins, r) + alloc * bullShare)
                array.set(bearBins, r, array.get(bearBins, r) + alloc * bearShare)

    // Kernel smooth the bins so peak nodes stand out without hard edges.
    float[] smoothTotal = array.new_float(rowsInput, 0.0)
    float[] smoothBull = array.new_float(rowsInput, 0.0)
    float[] smoothBear = array.new_float(rowsInput, 0.0)
    float maxBin = 0.0
    float sumBin = 0.0
    int pocIndex = 0

    for r = 0 to rowsInput - 1
        float leftTotal = r > 0 ? array.get(totalBins, r - 1) : array.get(totalBins, r)
        float midTotal = array.get(totalBins, r)
        float rightTotal = r < rowsInput - 1 ? array.get(totalBins, r + 1) : array.get(totalBins, r)
        float smoothT = (leftTotal + 2.0 * midTotal + rightTotal) / 4.0

        float leftBull = r > 0 ? array.get(bullBins, r - 1) : array.get(bullBins, r)
        float midBull = array.get(bullBins, r)
        float rightBull = r < rowsInput - 1 ? array.get(bullBins, r + 1) : array.get(bullBins, r)
        float smoothB = (leftBull + 2.0 * midBull + rightBull) / 4.0

        float leftBear = r > 0 ? array.get(bearBins, r - 1) : array.get(bearBins, r)
        float midBear = array.get(bearBins, r)
        float rightBear = r < rowsInput - 1 ? array.get(bearBins, r + 1) : array.get(bearBins, r)
        float smoothS = (leftBear + 2.0 * midBear + rightBear) / 4.0

        array.set(smoothTotal, r, smoothT)
        array.set(smoothBull, r, smoothB)
        array.set(smoothBear, r, smoothS)

        sumBin += smoothT
        if smoothT > maxBin
            maxBin := smoothT
            pocIndex := r

    float avgBin = sumBin / rowsInput

    // Cluster adjacent local peaks into compact node groups.
    int[] clusterStart = array.new_int()
    int[] clusterEnd = array.new_int()
    int[] clusterPoc = array.new_int()
    float[] clusterVol = array.new_float()
    float[] clusterBull = array.new_float()
    float[] clusterBear = array.new_float()
    float[] clusterPeak = array.new_float()

    for r = 1 to rowsInput - 2
        float current = array.get(smoothTotal, r)
        bool peak = current > array.get(smoothTotal, r - 1) and current >= array.get(smoothTotal, r + 1) and current >= avgBin * nodeFactorInput

        if peak
            int lastCluster = array.size(clusterStart) - 1
            bool newCluster = lastCluster < 0 or r - array.get(clusterEnd, lastCluster) > mergeGapInput

            if newCluster
                array.push(clusterStart, r)
                array.push(clusterEnd, r)
                array.push(clusterPoc, r)
                array.push(clusterVol, current)
                array.push(clusterBull, array.get(smoothBull, r))
                array.push(clusterBear, array.get(smoothBear, r))
                array.push(clusterPeak, current)
            else
                array.set(clusterEnd, lastCluster, r)
                array.set(clusterVol, lastCluster, array.get(clusterVol, lastCluster) + current)
                array.set(clusterBull, lastCluster, array.get(clusterBull, lastCluster) + array.get(smoothBull, r))
                array.set(clusterBear, lastCluster, array.get(clusterBear, lastCluster) + array.get(smoothBear, r))
                if current > array.get(clusterPeak, lastCluster)
                    array.set(clusterPeak, lastCluster, current)
                    array.set(clusterPoc, lastCluster, r)

    // Value area expansion from the POC.
    int vaLow = pocIndex
    int vaHigh = pocIndex
    float vaVol = maxBin

    for step = 0 to rowsInput - 2
        if vaVol / math.max(sumBin, 1.0) >= valueAreaInput
            break

        float leftCandidate = vaLow > 0 ? array.get(smoothTotal, vaLow - 1) : -1.0
        float rightCandidate = vaHigh < rowsInput - 1 ? array.get(smoothTotal, vaHigh + 1) : -1.0

        if rightCandidate >= leftCandidate
            vaHigh += 1
            vaVol += array.get(smoothTotal, vaHigh)
        else
            vaLow -= 1
            vaVol += array.get(smoothTotal, vaLow)

    float pocPrice = rangeLow + (pocIndex + 0.5) * rowSpan
    float vaLowPrice = rangeLow + vaLow * rowSpan
    float vaHighPrice = rangeLow + (vaHigh + 1) * rowSpan
    livePoc := pocPrice
    int labelEdge = rightEdge + 28

    if showValueAreaInput
        box vaRangeBox = box.new(bar_index - lookbackInput + 1, vaHighPrice, leftEdge - 1, vaLowPrice, xloc = xloc.bar_index, bgcolor = color.new(nodeHotInput, 94), border_color = color.new(nodeHotInput, 82), border_width = 1)
        box vaBox = box.new(leftEdge, vaHighPrice, rightEdge, vaLowPrice, xloc = xloc.bar_index, bgcolor = color.new(neutralInput, 92), border_color = color.new(neutralInput, 80), border_width = 1)
        array.push(profileBoxes, vaRangeBox)
        array.push(profileBoxes, vaBox)

    if showPocInput
        line pocLine = line.new(bar_index - lookbackInput + 1, pocPrice, labelEdge, pocPrice, xloc = xloc.bar_index, color = color.new(accentInput, 0), style = line.style_dashed, width = 2)
        array.push(profileLines, pocLine)
        label pocLabel = label.new(labelEdge, pocPrice, "POC\n" + str.tostring(pocPrice, format.mintick) + "\n" + str.tostring(maxBin, format.volume), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(#161616, 6), textcolor = accentInput, size = size.small)
        array.push(profileLabels, pocLabel)
        line vahLine = line.new(bar_index - lookbackInput + 1, vaHighPrice, labelEdge - 4, vaHighPrice, xloc = xloc.bar_index, color = color.new(nodeHotInput, 22), style = line.style_dotted, width = 1)
        line valLine = line.new(bar_index - lookbackInput + 1, vaLowPrice, labelEdge - 4, vaLowPrice, xloc = xloc.bar_index, color = color.new(nodeHotInput, 22), style = line.style_dotted, width = 1)
        label vahLabel = label.new(labelEdge - 4, vaHighPrice, "VAH " + str.tostring(vaHighPrice, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(#161616, 18), textcolor = nodeHotInput, size = size.tiny)
        label valLabel = label.new(labelEdge - 4, vaLowPrice, "VAL " + str.tostring(vaLowPrice, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(#161616, 18), textcolor = nodeHotInput, size = size.tiny)
        array.push(profileLines, vahLine)
        array.push(profileLines, valLine)
        array.push(profileLabels, vahLabel)
        array.push(profileLabels, valLabel)

    // Render the profile rows as split buy/sell bars.
    if showProfileInput and maxBin > 0.0
        for r = 0 to rowsInput - 1
            float rowTotal = array.get(smoothTotal, r)
            if rowTotal > 0.0
                float rowBull = array.get(smoothBull, r)
                float rowBear = array.get(smoothBear, r)
                float rowShare = rowBull / math.max(rowTotal, syminfo.mintick)
                rowShare := f_clamp(rowShare, 0.0, 1.0)

                int rowWidth = math.max(1, int(math.round((rowTotal / maxBin) * widthInput)))
                int bullWidth = math.max(0, int(math.round(rowWidth * rowShare)))
                int bearWidth = math.max(0, rowWidth - bullWidth)

                int rowLeft = leftEdge
                int rowMid = rowLeft + bearWidth
                int rowRight = rowLeft + rowWidth
                float rowTop = rangeLow + (r + 1) * rowSpan
                float rowBottom = rangeLow + r * rowSpan

                bool isPocRow = r == pocIndex
                bool inValueArea = r >= vaLow and r <= vaHigh
                color rowBorder = isPocRow ? accentInput : inValueArea ? color.new(nodeHotInput, 55) : color.new(chart.fg_color, 90)
                color bearTint = isPocRow ? color.new(bearInput, 28) : inValueArea ? color.new(bearInput, 45) : color.new(bearInput, 68)
                color bullTint = isPocRow ? color.new(bullInput, 20) : inValueArea ? color.new(bullInput, 42) : color.new(bullInput, 66)

                if bearWidth > 0
                    box bearBox = box.new(rowLeft, rowTop, rowMid, rowBottom, xloc = xloc.bar_index, bgcolor = bearTint, border_color = rowBorder, border_width = 1)
                    array.push(profileBoxes, bearBox)

                if bullWidth > 0
                    box bullBox = box.new(rowMid, rowTop, rowRight, rowBottom, xloc = xloc.bar_index, bgcolor = bullTint, border_color = rowBorder, border_width = 1)
                    array.push(profileBoxes, bullBox)

    // Cluster labels and guide lines, limited to the most relevant nodes.
    if showNodesInput and array.size(clusterStart) > 0
        for n = 0 to maxNodeInput - 1
            if n < array.size(clusterStart)
                int pocIdx = array.get(clusterPoc, n)
                float clusterV = array.get(clusterVol, n)
                float clusterBullV = array.get(clusterBull, n)
                float clusterBearV = array.get(clusterBear, n)
                float clusterShare = clusterBullV / math.max(clusterBullV + clusterBearV, syminfo.mintick)
                clusterShare := f_clamp(clusterShare, 0.0, 1.0)

                float clusterPrice = rangeLow + (pocIdx + 0.5) * rowSpan
                color nodeGlow = color.from_gradient(clusterShare, 0.0, 1.0, bearInput, nodeHotInput)
                if showNodeBandsInput
                    float bandTop = clusterPrice + rowSpan * 0.48
                    float bandBottom = clusterPrice - rowSpan * 0.48
                    box nodeBand = box.new(bar_index - lookbackInput + 1, bandTop, leftEdge - 1, bandBottom, xloc = xloc.bar_index, bgcolor = color.new(nodeGlow, 94), border_color = color.new(nodeGlow, 78), border_width = 1)
                    array.push(profileBoxes, nodeBand)
                line nodeLine = line.new(rightEdge + 1, clusterPrice, labelEdge - 2, clusterPrice, xloc = xloc.bar_index, color = nodeGlow, style = line.style_dashed, width = 1)
                array.push(profileLines, nodeLine)

                label nodeLabel = label.new(labelEdge - 2 + n * 2, clusterPrice, "Node " + str.tostring(n + 1) + "\n" + str.tostring(clusterPrice, format.mintick) + "\nB " + str.tostring(clusterShare * 100.0, "0") + "% | " + str.tostring(clusterV, format.volume), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(#161616, 10), textcolor = nodeGlow, size = size.tiny)
                array.push(profileLabels, nodeLabel)

    float totalBull = 0.0
    float totalBear = 0.0
    for r = 0 to rowsInput - 1
        totalBull += array.get(smoothBull, r)
        totalBear += array.get(smoothBear, r)

    float biasShare = totalBull / math.max(totalBull + totalBear, syminfo.mintick)
    biasShare := f_clamp(biasShare, 0.0, 1.0)
    liveBiasShare := biasShare
    string biasText = biasShare > 0.55 ? "Bull Bias" : biasShare < 0.45 ? "Bear Bias" : "Balanced"
    color biasColor = color.from_gradient(biasShare, 0.0, 1.0, bearInput, bullInput)

    // Dashboard.
    if showDashInput

        table.cell(dash, 0, 0, "Kivra Liquidity Nodes [JOAT]", text_color = color.new(#DBDBDB, 0), bgcolor = color.new(biasColor, 78), text_halign = text.align_center, text_size = f_table_size(dashSizeInput))
        table.cell(dash, 1, 0, "", bgcolor = color.new(biasColor, 78), text_size = f_table_size(dashSizeInput))

        table.cell(dash, 0, 1, "POC", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
        table.cell(dash, 1, 1, str.tostring(pocPrice, format.mintick), text_color = accentInput, bgcolor = color.new(accentInput, 88), text_size = f_table_size(dashSizeInput))

        table.cell(dash, 0, 2, "Node Count", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
        table.cell(dash, 1, 2, str.tostring(array.size(clusterStart)), text_color = color.new(#DBDBDB, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

        table.cell(dash, 0, 3, "Value Area", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
        table.cell(dash, 1, 3, str.tostring((vaHighPrice - vaLowPrice) / math.max(rangeSpan, syminfo.mintick) * 100.0, "0.0") + "%", text_color = color.new(#DBDBDB, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

        table.cell(dash, 0, 4, "Bias", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
        table.cell(dash, 1, 4, biasText, text_color = biasColor, bgcolor = color.new(biasColor, 88), text_size = f_table_size(dashSizeInput))

        table.cell(dash, 0, 5, "Range", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
        table.cell(dash, 1, 5, str.tostring(rangeSpan, format.mintick), text_color = color.new(#DBDBDB, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

        table.cell(dash, 0, 6, "Source", text_color = color.new(#808080, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))
        table.cell(dash, 1, 6, hasRealVolume ? "Real Volume" : "Range Proxy", text_color = color.new(#DBDBDB, 0), bgcolor = color.new(#161616, 0), text_size = f_table_size(dashSizeInput))

bool pocReclaimUp = barstate.isconfirmed and not na(livePoc) and ta.crossover(close, livePoc)
bool pocReclaimDown = barstate.isconfirmed and not na(livePoc) and ta.crossunder(close, livePoc)
barcolor(showCandleTintInput ? color.new(candlePressureColor, 58) : na, title = "Liquidity Profile Candle Tint")

alertcondition(pocReclaimUp, "KLN POC Reclaim Up", "Kivra Liquidity Nodes [JOAT] close crossed above the live POC on {{ticker}}.")
alertcondition(pocReclaimDown, "KLN POC Reclaim Down", "Kivra Liquidity Nodes [JOAT] close crossed below the live POC on {{ticker}}.")
````
