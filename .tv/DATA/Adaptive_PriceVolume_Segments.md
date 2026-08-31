<!-- tradingview-pine-id: PUB;1f227d3c219e4518b52d99b2b7dc8b88 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Price-Volume Segments

Source: https://www.tradingview.com/script/fa8AuERg-Adaptive-Price-Volume-Segments/

## Description

This indicator combines Price and Volume data to map out market structure.

While standard charts only show whether price went up or down, this indicator reveals the exact price levels where the highest trading activity (volume) took place.

By identifying where major institutional market participants (banks, hedge funds) have placed their orders, making high-probability trading decisions becomes much clearer.

The 3 Main Visual Components on Your Chart
1. Dashed Lines (Point of Control / POC)
What it is: A dotted horizontal line assigned to each individual cluster. It highlights the single most important price level within that section.

Why it matters: This represents the exact price where the maximum contract quantity was traded.

How to trade it:

If price is trading above this line, it acts as dynamic Support.

If price is trading below this line, it acts as dynamic Resistance.

2. Horizontal Histogram Bars (Volume Profile Boxes)
Long Bars (High Volume Nodes): Indicate price ranges with heavy trading competition between buyers and sellers. When price returns here, it tends to stall or consolidate.

Short Bars or Gaps (Low Volume Nodes): Indicate price levels with low market interest. Price usually moves through these zones very rapidly.

3. Total Volume Readouts
Located on the far-right edge of each cluster (e.g., Total: 1.5M).

Displays the total accumulated volume traded within that entire price segment, helping you determine which price zones hold the most institutional liquidity.

3 Core Trading Strategies
Strategy 1: POC Bounce (Support & Resistance Entries)
Watch how price approaches a segment's POC (dashed line).

If price drops into a POC from above and forms a bullish reaction pattern, look for BUY opportunities.

Place your Stop Loss just below that cluster's boundary and target the next higher cluster's POC.

Strategy 2: Low-Volume Acceleration (Vacuum Zones)
Identify the gaps or short bars between two dense volume profiles.

When price breaks into this low-volume zone, it typically moves quickly toward the next high-volume area due to lack of order friction.

Use these zones to catch high-momentum breakout trades.

Strategy 3: Trend Continuation
If price breaks out of a cluster and holds above it, it confirms trend strength.

As long as price stays above the current cluster's POC, the prevailing Uptrend remains intact.

Key Settings Breakdown
Historical Depth (Default: 200): The lookback window of candles analyzed. Use 100–200 for day trading/scalping, or 300–500 for swing trading.

Total Segments (Default: 5): Divides the price range into 5 distinct clusters to keep the chart clean and readable.

Right Offset (Default: 10): Shifts the volume profile histograms to the right side of active price bars, keeping your main chart clear.

---

## Source Code

````pine
//@version=6
indicator("Adaptive Price-Volume Segments", "APV Profile", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// High-Contrast Palette Optimized for Light/White Chart Backgrounds
//---------------------------------------------------------------------------------------------------------------------}
var color[] LIGHT_CANVAS_PALETTE = array.from(
     #0039A6, // Deep Ocean Blue
     #C62828, // Crimson Red
     #1B5E20, // Dark Emerald Green
     #E65100, // Rich Amber Orange
     #4A148C, // Deep Violet
     #006064, // Slate Teal
     #F57F17, // Burnt Yellow
     #AD1457, // Deep Rose Pink
     #3E2723, // Espresso Brown
     #263238  // Dark Charcoal
 )

//---------------------------------------------------------------------------------------------------------------------}
// Configuration Inputs
//---------------------------------------------------------------------------------------------------------------------}
grp_alg      = "Grouping Parameters"
depthBars    = input.int(200, "Historical Depth (Bars)", minval = 10, group = grp_alg, tooltip = "Number of historical bars used for price partition.")
groupCount   = input.int(5, "Total Segments", minval = 2, maxval = 10, group = grp_alg, tooltip = "Number of distinct price clusters to calculate.")
maxLoops     = input.int(40, "Optimization Iterations", minval = 5, maxval = 50, group = grp_alg)

grp_draw     = "Histogram & Visual Layout"
gridBins     = input.int(20, "Bins per Segment", minval = 2, group = grp_draw, tooltip = "Vertical resolution for segment volume distribution.")
profileSpan  = input.int(40, "Max Histogram Width", minval = 5, group = grp_draw)
rightGap     = input.int(10, "Right Plot Margin", group = grp_draw)
drawMarkers  = input.bool(true, "Display Price Markers", group = grp_draw)
markerScale  = input.string(size.small, "Marker Scale", options = [size.tiny, size.small, size.normal, size.large, size.huge], group = grp_draw)

//---------------------------------------------------------------------------------------------------------------------}
// Custom Weighted Clustering Engine
//---------------------------------------------------------------------------------------------------------------------{
f_runPartitionEngine(int depth, int numK, int totalIters) =>
    float[] priceData = array.new_float(0)
    float[] volumeData = array.new_float(0)
    float pMin = 1e10, pMax = -1e10
    
    for idx = 0 to depth - 1
        float pVal = hl2[idx]
        float vVal = volume[idx]
        priceData.push(pVal)
        volumeData.push(vVal)
        pMin := math.min(pMin, pVal)
        pMax := math.max(pMax, pVal)
            
    float[] clusterCenters = array.new_float(numK)
    float intervalStep = (pMax - pMin) / (numK + 1)
    for idx = 0 to numK - 1
        clusterCenters.set(idx, pMin + (idx + 1) * intervalStep)
        
    int[] mappedIndices = array.new_int(depth, 0)
    
    for loop = 1 to totalIters
        for idx = 0 to depth - 1
            float currentPrice = priceData.get(idx)
            int targetGroup = 0
            float shortestDist = 1e10
            for kIdx = 0 to numK - 1
                float distance = math.abs(currentPrice - clusterCenters.get(kIdx))
                if distance < shortestDist
                    shortestDist := distance
                    targetGroup := kIdx
            mappedIndices.set(idx, targetGroup)
            
        float[] volWeightedSum = array.new_float(numK, 0.0)
        float[] sumVolume = array.new_float(numK, 0.0)
        
        for idx = 0 to depth - 1
            int assignedGroup = mappedIndices.get(idx)
            volWeightedSum.set(assignedGroup, volWeightedSum.get(assignedGroup) + priceData.get(idx) * volumeData.get(idx))
            sumVolume.set(assignedGroup, sumVolume.get(assignedGroup) + volumeData.get(idx))
            
        for kIdx = 0 to numK - 1
            if sumVolume.get(kIdx) > 0
                clusterCenters.set(kIdx, volWeightedSum.get(kIdx) / sumVolume.get(kIdx))
    
    [mappedIndices, clusterCenters]

//---------------------------------------------------------------------------------------------------------------------}
// Drawing and Graphic Management
//---------------------------------------------------------------------------------------------------------------------{
var box[] drawBoxes = array.new_box()
var label[] drawLabels = array.new_label()
var line[] drawLines = array.new_line()

if barstate.islast
    // Clear graphic objects from previous calculation
    if drawBoxes.size() > 0
        for item in drawBoxes
            item.delete()
        drawBoxes.clear()
        
    if drawLabels.size() > 0
        for item in drawLabels
            item.delete()
        drawLabels.clear()
        
    if drawLines.size() > 0
        for item in drawLines
            item.delete()
        drawLines.clear()

    // Execute clustering calculation
    [mappedIndices, clusterCenters] = f_runPartitionEngine(depthBars, groupCount, maxLoops)

    int leftBoundaryIdx = bar_index - depthBars + 1
    int profileStartBar = bar_index + rightGap

    int metricReserveCount = groupCount * 2
    int activeLabelCounter = 0

    for segmentId = 0 to groupCount - 1
        color activeColor = LIGHT_CANVAS_PALETTE.get(segmentId % LIGHT_CANVAS_PALETTE.size())
        
        float[] segPrices = array.new_float(0)
        float[] segVolumes = array.new_float(0)
        float[] segHighs  = array.new_float(0)
        float[] segLows   = array.new_float(0)
        
        float segMin = 1e10, segMax = -1e10
        float segVolumeSum = 0.0
        
        for idx = 0 to depthBars - 1
            if mappedIndices.get(idx) == segmentId
                float priceVal = hl2[idx], volVal = volume[idx], highVal = high[idx], lowVal = low[idx]
                segPrices.push(priceVal)
                segVolumes.push(volVal)
                segHighs.push(highVal)
                segLows.push(lowVal)
                
                segMin := math.min(segMin, lowVal)
                segMax := math.max(segMax, highVal)
                segVolumeSum += volVal
                
                if drawMarkers and activeLabelCounter < (500 - metricReserveCount)
                    drawLabels.push(label.new(bar_index - idx, priceVal, "•", 
                         color = #00000000, 
                         textcolor = activeColor, 
                         style = label.style_label_center, 
                         size = markerScale))
                    activeLabelCounter += 1

        if segPrices.size() > 0
            float[] binVolumes = array.new_float(gridBins, 0.0)
            float binHeight = (segMax - segMin) / gridBins
            if binHeight == 0
                binHeight := syminfo.mintick
                
            for idx = 0 to segPrices.size() - 1
                float candleH = segHighs.get(idx), candleL = segLows.get(idx), candleV = segVolumes.get(idx)
                float priceSpan = math.max(candleH - candleL, syminfo.mintick)
                
                for bIdx = 0 to gridBins - 1
                    float binFloor = segMin + bIdx * binHeight
                    float binCeil = binFloor + binHeight
                    float intersL = math.max(candleL, binFloor)
                    float intersH = math.min(candleH, binCeil)
                    if intersH > intersL
                        binVolumes.set(bIdx, binVolumes.get(bIdx) + candleV * (intersH - intersL) / priceSpan)
                
            float maxVolumeInBin = binVolumes.max()
            int peakBinIndex = binVolumes.indexof(maxVolumeInBin)
            
            for bIdx = 0 to gridBins - 1
                if drawBoxes.size() >= 500
                    break
                float binVol = binVolumes.get(bIdx)
                if binVol == 0
                    continue
                    
                float yLower = segMin + bIdx * binHeight
                float yUpper = yLower + binHeight
                int binLength = int((binVol / maxVolumeInBin) * profileSpan)
                int profileEndBar = profileStartBar + binLength
                bool isMaxPeak = (bIdx == peakBinIndex)
                
                // Opacity tuned for sharp light-background visibility
                color boxFill = isMaxPeak ? activeColor : color.new(activeColor, 68)
                
                drawBoxes.push(box.new(profileStartBar, yUpper, profileEndBar, yLower, bgcolor = boxFill, border_color = isMaxPeak ? activeColor : #00000000))
                    
                if isMaxPeak
                    float pocPrice = (yUpper + yLower) / 2
                    drawLines.push(line.new(leftBoundaryIdx, pocPrice, profileStartBar, pocPrice, color = activeColor, width = 1, style = line.style_dashed))

                    drawLabels.push(label.new(leftBoundaryIdx, pocPrice, str.tostring(binVol, format.volume), 
                         color = #00000000, textcolor = activeColor, style = label.style_label_right, size = size.small))
                         
                    drawLabels.push(label.new(profileEndBar, pocPrice, "Vol: " + str.tostring(segVolumeSum, format.volume), 
                         color = #00000000, textcolor = activeColor, style = label.style_label_left, size = size.small))
````
