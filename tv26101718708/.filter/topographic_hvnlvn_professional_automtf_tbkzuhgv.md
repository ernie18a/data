# Topographic HVN/LVN Professional (Auto-MTF)

- url: https://www.tradingview.com/script/tBkZuHGV/
- type: indicator
- pine_id: PUB;855268615d3244cc860462a7724e719b
- version: 5.0

## Description

Description
Overview
Traditional volume profiles often generate highly fragmented High Volume Nodes (HVNs) and Low Volume Nodes (LVNs) based purely on rigid local comparisons. This script completely revolutionizes node detection by introducing Topographic Prominence—an advanced cartographic algorithm used to measure the height of mountain peaks and the depth of valleys relative to their surrounding macro-structures.

By calculating the true geometric distribution of lower-timeframe data, this indicator charts institutional-grade support, resistance, and liquidity vacuums directly on your chart, fully automated.

Key Features
True Topographic Prominence Engine: Instead of just comparing a price level to its immediate neighbors, the script "walks" up and down the volume flanks to isolate major market crests and structural air pockets. It captures major volume shelves (including the POC) within broader distributions.

Fully Automated Multi-Timeframe (Auto-MTF): No more broken profiles or memory crashes when switching charts. The script dynamically adapts its internal granularity calculation in the background based on your selected macro timeframe (e.g., pulling 1-minute data for Daily profiles, 5-minute data for Weekly profiles, etc.).

Dynamic Laser-Precise Box Boundaries: The drawn zones do not use arbitrary fixed heights. The thickness of each HVN and LVN box expands organically until volume drops or recovers by your exact user-defined percentage threshold, precisely framing the high-interest or low-interest execution zones.

Adaptive Smoothing: Integrated moving average filters allow you to smoothly bridge micro-peaks into broad institutional macro-nodes or keep it hyper-detailed for granular scalping setups.

Inputs & Customization
Calculation Timeframe: Choose the macro anchor period (D for Daily, W for Weekly, M for Monthly).

Profile Resolution (Rows): Adjust the vertical precision of the volume distribution grid.

Profile Smoothing (Ticks): Smooth the histogram to filter out raw market noise.

HVN/LVN Prominence %: Define how aggressively a peak must stand out or how deep a valley must plunge to qualify as a structural level.

HVN/LVN Box Thickness: Control how tightly or broadly the execution zones wrap around the core structure.

How to Trade It
HVN Areas (Green Boxes): Major areas of price acceptance and consolidation. Look for retests to act as strong institutional support or resistance magnets.

LVN Areas (Red Boxes): Major liquidity vacuums or rejection zones. Price tends to slice through these areas very rapidly due to a lack of historical transaction history. Perfect for target placement or spotting sudden breakout velocity.

Feel free to use this text as the body of your script's release note or description field!

## Source Code

````pine
//@version=6
indicator("Topographic HVN/LVN Professional (Gradient Auto-MTF)", overlay=true, max_boxes_count=500, max_bars_back=5000)

// --- Settings ---
i_mode       = input.string("Precise MTF (D/W/M)", title="Calculation Mode", options=["Precise MTF (D/W/M)", "Current TF Lookback Bars"], tooltip="Choose whether to calculate based on Daily/Weekly/Monthly macro periods with precise lower timeframes, or based on a fixed number of lookback bars on the current chart.")
i_tf         = input.timeframe("D", title="Calculation Timeframe", options=["D", "W", "M"], tooltip="Used only in Precise MTF mode. Determines the macro anchor period.")
i_lookback   = input.int(300, title="Lookback Bars Count", minval=10, maxval=2000, tooltip="Used only in Current TF Lookback Bars mode. Number of historical bars to calculate from the current real-time bar.")
i_rows       = input.int(200, title="Profile Resolution (Rows)", minval=30, maxval=300, tooltip="Number of price rows/bins in the profile grid. Higher values increase vertical accuracy.")

grpNodeSet   = "Advanced Node Parameters (Topography)"
i_smooth     = input.int(5, "Profile Smoothing (Ticks)", minval=1, maxval=51, step=1, group=grpNodeSet, tooltip="Applies a moving average to the profile histogram to merge micro-peaks and isolate broad macro-nodes.")
i_hvnProm    = input.float(15.0, "HVN Prominence %", minval=1.0, maxval=90.0, step=1.0, group=grpNodeSet, tooltip="Topographic Prominence: How much a volume peak must stand out relative to its surrounding valleys to be considered an HVN.")
i_hvnWidth   = input.float(5.0, "HVN Box Thickness (% drop)", minval=1.0, maxval=90.0, step=1.0, group=grpNodeSet, tooltip="The box expands vertically from the peak until the volume drops by this percentage relative to the peak's volume.")
i_lvnProm    = input.float(15.0, "LVN Prominence %", minval=1.0, maxval=90.0, step=1.0, group=grpNodeSet, tooltip="How deep a volume valley must be compared to its adjacent peaks to be considered an LVN.")
i_lvnWidth   = input.float(5.0, "LVN Box Thickness (% rise)", minval=1.0, maxval=90.0, step=1.0, group=grpNodeSet, tooltip="The box expands vertically from the valley until the volume recovers by this percentage relative to the adjacent peaks.")

grpStyle     = "Box Aesthetics"
i_showHVN    = input.bool(true, title="Show HVN Areas", group=grpStyle)
i_showLVN    = input.bool(true, title="Show LVN Areas", group=grpStyle)
i_colorHVN   = input.color(#2196f3, title="HVN Base Color (Blue)", group=grpStyle) 
i_colorLVN   = input.color(#f44336, title="LVN Base Color (Red)", group=grpStyle)

// --- Auto-Granularity Assignment ---
getLTF(string macro) =>
    string ltf = "1"
    if macro == "W"
        ltf := "5"
    else if macro == "M"
        ltf := "15"
    ltf

resolvedLTF = getLTF(i_tf)

// --- Persistent Variables & Arrays ---
var map<int, float> volMap = map.new<int, float>()
var array<box> drawnBoxes = array.new<box>()
var int mtfStartIdx = na
var float p_trueHigh = na
var float p_trueLow  = na

currentSessionId = i_mode + "-" + (i_mode == "Precise MTF (D/W/M)" ? i_tf : str.tostring(i_lookback))
var string lastSessionId = ""

isNewPeriod = timeframe.change(i_tf)

if isNewPeriod or (currentSessionId != lastSessionId)
    mtfStartIdx := bar_index
    map.clear(volMap)
    p_trueHigh := na
    p_trueLow  := na

lastSessionId := currentSessionId

// --- Lower Timeframe Data Request ---
curr_highs   = request.security_lower_tf(syminfo.tickerid, resolvedLTF, expression=high)
curr_lows    = request.security_lower_tf(syminfo.tickerid, resolvedLTF, expression=low)
curr_volumes = request.security_lower_tf(syminfo.tickerid, resolvedLTF, expression=volume)

// --- Logic 1: Progressive Accumulation (Precise MTF Mode) ---
if i_mode == "Precise MTF (D/W/M)"
    if (last_bar_index - bar_index) <= 1500 and array.size(curr_highs) > 0
        for i = 0 to array.size(curr_highs) - 1
            float h = array.get(curr_highs, i)
            float l = array.get(curr_lows, i)
            float v = nz(array.get(curr_volumes, i), 0.0)

            p_trueHigh := math.max(nz(p_trueHigh, h), h)
            p_trueLow  := math.min(nz(p_trueLow, l), l)

            int h_tick = math.round(h / syminfo.mintick)
            int l_tick = math.round(l / syminfo.mintick)
            int span = math.max(1, h_tick - l_tick)
            
            for t = l_tick to h_tick
                map.put(volMap, t, nz(map.get(volMap, t), 0.0) + (v / span))

// --- Logic 2: Standard Loop (Current TF Lookback Bars Mode) ---
if i_mode == "Current TF Lookback Bars" and barstate.islast
    map.clear(volMap)
    p_trueHigh := na
    p_trueLow  := na
    
    int startLookback = math.max(0, bar_index - i_lookback + 1)
    for b = startLookback to bar_index
        float h = high[bar_index - b]
        float l = low[bar_index - b]
        float v = nz(volume[bar_index - b], 0.0)
        
        p_trueHigh := math.max(nz(p_trueHigh, h), h)
        p_trueLow  := math.min(nz(p_trueLow, l), l)
        
        int h_tick = math.round(h / syminfo.mintick)
        int l_tick = math.round(l / syminfo.mintick)
        int span = math.max(1, h_tick - l_tick)
        
        for t = l_tick to h_tick
            map.put(volMap, t, nz(map.get(volMap, t), 0.0) + (v / span))

// --- Unified Rendering Engine ---
if barstate.islast and map.size(volMap) > 0
    if array.size(drawnBoxes) > 0
        for box_id in drawnBoxes
            box.delete(box_id)
        array.clear(drawnBoxes)

    float trueHigh = p_trueHigh
    float trueLow  = p_trueLow
    int leftBoundary = i_mode == "Current TF Lookback Bars" ? math.max(0, bar_index - i_lookback + 1) : nz(mtfStartIdx, bar_index)

    int baseHvnTrans = int(color.t(i_colorHVN))
    int baseLvnTrans = int(color.t(i_colorLVN))

    if not na(trueHigh) and not na(trueLow) and trueHigh > trueLow
        float priceRange = trueHigh - trueLow
        float step = priceRange / i_rows
        a_vol = array.new_float(i_rows, 0.0)
        
        array<int> map_keys = map.keys(volMap)
        for i = 0 to array.size(map_keys) - 1
            int tick_key = array.get(map_keys, i)
            float vol = map.get(volMap, tick_key)
            float price = tick_key * syminfo.mintick
            int row = math.floor((price - trueLow) / step)
            row := math.max(0, math.min(row, i_rows - 1))
            array.set(a_vol, row, array.get(a_vol, row) + vol)
            
        smoothedV = array.new_float(i_rows, 0.0)
        int smoothHalf = math.floor(i_smooth / 2)
        
        for i = 0 to i_rows - 1
            float sum = 0.0
            int count = 0
            for k = math.max(0, i - smoothHalf) to math.min(i_rows - 1, i + smoothHalf)
                sum += array.get(a_vol, k)
                count += 1
            array.set(smoothedV, i, sum / count)

        float avgVol = array.sum(smoothedV) / i_rows

        for i = 1 to i_rows - 2
            float v = array.get(smoothedV, i)
            int left  = i - 1
            int right = i + 1
            float v_left  = array.get(smoothedV, left)
            float v_right = array.get(smoothedV, right)
            
            bool leftLower   = v_left < v or (v_left == v and v > avgVol)
            bool rightLower  = v_right < v or (v_right == v and v > avgVol)
            bool leftHigher  = v_left > v or (v_left == v and v <= avgVol)
            bool rightHigher = v_right > v or (v_right == v and v <= avgVol)

            // --- Topographic HVN Structural Calculation ---
            if i_showHVN and leftLower and rightLower and v > 0
                float min_L = v
                int k_left = left
                while k_left >= 0
                    float vk = array.get(smoothedV, k_left)
                    if vk > v
                        break
                    min_L := math.min(min_L, vk)
                    k_left := k_left - 1
                    
                float min_R = v
                for k = right to i_rows - 1
                    float vk = array.get(smoothedV, k)
                    if vk > v
                        break
                    min_R := math.min(min_R, vk)

                if ((v - min_L) / v * 100.0) >= i_hvnProm and ((v - min_R) / v * 100.0) >= i_hvnProm
                    float localCutoff = v * (100.0 - i_hvnWidth) / 100.0
                    int up_idx = right - 1
                    while up_idx < i_rows - 1
                        if array.get(smoothedV, up_idx + 1) < localCutoff
                            break
                        up_idx += 1
                    int dn_idx = left + 1
                    while dn_idx > 0
                        if array.get(smoothedV, dn_idx - 1) < localCutoff
                            break
                        dn_idx -= 1
                        
                    int center_idx = math.round((up_idx + dn_idx) / 2.0)
                    int half_span = math.max(1, center_idx - dn_idx)
                    
                    for step_layer = 1 to 5
                        int layer_offset = math.round(half_span * (step_layer / 5.0))
                        int l_up = math.min(up_idx, center_idx + layer_offset)
                        int l_dn = math.max(dn_idx, center_idx - layer_offset)
                        
                        float boxTop = trueLow + (l_up * step) + step
                        float boxBot = trueLow + (l_dn * step)
                        
                        // FIXED: Sostituito math.clamp con la logica nativa max/min
                        int dynamicTrans = math.max(0, math.min(100, baseHvnTrans + math.round((5 - step_layer) * 15)))
                        
                        box hvnBox = box.new(left=leftBoundary, top=boxTop, right=bar_index, bottom=boxBot, border_color=na, bgcolor=color.new(i_colorHVN, dynamicTrans))
                        array.push(drawnBoxes, hvnBox)
                
            // --- Topographic LVN Structural Calculation ---
            if i_showLVN and leftHigher and rightHigher
                float max_L = v
                int k_left = left
                while k_left >= 0
                    float vk = array.get(smoothedV, k_left)
                    if vk < v
                        break
                    max_L := math.max(max_L, vk)
                    k_left := k_left - 1
                    
                float max_R = v
                for k = right to i_rows - 1
                    float vk = array.get(smoothedV, k)
                    if vk < v
                        break
                    max_R := math.max(max_R, vk)

                float rise_L = max_L > 0 ? (max_L - v) / max_L * 100.0 : 0.0
                float rise_R = max_R > 0 ? (max_R - v) / max_R * 100.0 : 0.0

                if math.min(rise_L, rise_R) >= i_lvnProm
                    float localCutoff = v + (math.min(max_L, max_R) - v) * (i_lvnWidth / 100.0)
                    int up_idx = right - 1
                    while up_idx < i_rows - 1
                        if array.get(smoothedV, up_idx + 1) > localCutoff
                            break
                        up_idx += 1
                    int dn_idx = left + 1
                    while dn_idx > 0
                        if array.get(smoothedV, dn_idx - 1) > localCutoff
                            break
                        dn_idx -= 1
                        
                    int center_idx = math.round((up_idx + dn_idx) / 2.0)
                    int half_span = math.max(1, center_idx - dn_idx)
                    
                    for step_layer = 1 to 5
                        int layer_offset = math.round(half_span * (step_layer / 5.0))
                        int l_up = math.min(up_idx, center_idx + layer_offset)
                        int l_dn = math.max(dn_idx, center_idx - layer_offset)
                        
                        float boxTop = trueLow + (l_up * step) + step
                        float boxBot = trueLow + (l_dn * step)
                        
                        // FIXED: Sostituito math.clamp con la logica nativa max/min
                        int dynamicTrans = math.max(0, math.min(100, baseLvnTrans + math.round((step_layer - 1) * 15)))
                        
                        box lvnBox = box.new(left=leftBoundary, top=boxTop, right=bar_index, bottom=boxBot, border_color=na, bgcolor=color.new(i_colorLVN, dynamicTrans))
                        array.push(drawnBoxes, lvnBox)
````
