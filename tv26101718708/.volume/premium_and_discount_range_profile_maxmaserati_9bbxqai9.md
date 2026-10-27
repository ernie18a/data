# Premium and Discount Range Profile @MaxMaserati

- url: https://www.tradingview.com/script/9BbXqai9-Premium-and-Discount-Range-Profile-MaxMaserati/
- type: indicator
- pine_id: PUB;906f1eb0055848c990485b7bd1982d0a
- version: 1.0

## Description

Premium and Discount Auction Range Footprint Profile

This script builds a live range from the highest high and lowest low of the last N bars, splits it at the midline into premium and discount, and profiles the volume traded inside it. It then reads the volume at each edge to show whether that edge is being rejected, accepted, or exhausted.

─── WHY THESE COMPONENTS TOGETHER ───
A high-low range shows where price is expensive or cheap, but not whether traders defend its edges.
A volume profile shows where volume traded, but not how it relates to the range edges.
Buy and sell volume shows who was aggressive, but not at which level.
Together, each edge gets an auction verdict: rejection, acceptance, or exhaustion.

─── PREMIUM AND DISCOUNT ───
Midline (EQ) = (Highest High + Lowest Low) / 2.
Location = (Close - Lowest Low) / (Highest High - Lowest Low) x 100. Above 50% = PREMIUM, below 50% = DISCOUNT.
The PREMIUM and DISCOUNT labels mark each half. The half holding price is shown at full color.
First Step: a green line prints on the first confirmed bar where the midline starts rising, a red line where it starts falling.

─── FOOTPRINT PROFILE ───
The range is split into bins. With footprint data, each row's buy and sell volume goes into its bin. Without it, volume is spread over the bins each candle touches and split using the candle body and wicks. The largest bin is the POC. Bins above 70% of the POC are HVN, below 30% are LVN.

─── EDGE STATES ───
Top bin HVN with sellers dominant = Strong Rejection. HVN with buyers dominant = Acceptance. LVN = Exhaustion, upgraded to Exhaustion -> Rejection when a seller-dominant node sits in the top 33% of the range. The bottom edge mirrors this.

─── HOW TO USE ───
1. Read the Location row and the highlighted label: PREMIUM or DISCOUNT.
2. Look for shorts in premium and longs in discount.
3. Before a short, check High Edge Status for Strong Rejection or Exhaustion -> Rejection. Before a long, check Low Edge Status.
4. A red First Step in premium supports shorts. A green First Step in discount supports longs.
5. The idea is invalid when that edge shows Acceptance, or a new high or low extends the range.

─── SETTINGS ───
Range Settings - lookback and box length.
Footprint Data - footprint toggle and row size.
Box Settings - box, midline, colors.
Premium and Discount Zones - labels and colors.
Volume Profile and Nodes - bins, width, POC, HVN, LVN.
Volume and AMT Labels - delta labels, edge states, scan depth.
Line Settings - optional high, low, mid plots.
Info Table Settings - table rows including Location.
First Step Signals - step lines and history.

─── NOTES ───
The range, profile, labels and edge states include the live candle and update until it closes. First Step lines print on confirmed bars only. Without footprint data, buy and sell volume are estimates. Built for intraday futures such as ES1! and NQ1!.

## Source Code

````pine
//@version=6
indicator("Premium and Discount Range Profile @MaxMaserati", shorttitle="PD Range @MaxMaserati", overlay=true, max_boxes_count=1, max_lines_count=500, max_labels_count=30, max_bars_back=250)

// ─── TYPES ───
type BoxVolumeLevel
    float price
    float volume
    float buyVolume
    float sellVolume
    bool isPOC

type EnhancedBox
    box boxObj
    float high
    float low
    int startTime
    int endTime
    float totalVolume
    float bullishVolume
    float bearishVolume
    array<BoxVolumeLevel> volumeLevels
    array<line> volumeImprintLines
    line pocLine
    label pocLabel
    label highVolumeLabel
    label lowVolumeLabel
    label topStateLabel
    label btmStateLabel
    float pocPrice
    float pocVolume
    int adaptiveBins
    float binSize
    bool isActive

// ─── RANGE ───
lookback_bars = input.int(50, "Lookback Bars", minval=10, maxval=200, group="Range Settings")
line_length = input.int(20, "Line Length", minval=5, maxval=100, group="Range Settings")

// ─── FOOTPRINT ───
premiumGroup = "Footprint Data (Premium Plan)"
autoDetectPremium = input.bool(true, "Auto-Detect Premium Data", group=premiumGroup, tooltip="Uses exchange footprint data when available. Falls back to standard estimation if unavailable.")
ticksPerRow       = input.int(5, "Premium Ticks Per Row", minval=1, group=premiumGroup, tooltip="Resolution of the internal footprint data being fetched.")

// ─── BOX ───
show_box = input.bool(true, "Show Range Box", group="Box Settings")
show_box_midline = input.bool(true, "Show Box Midline", group="Box Settings")
box_midline_width = input.int(1, "Box Midline Width", minval=1, maxval=3, group="Box Settings")
box_midline_color = input.color(#f48fb1, "Box Midline Color", group="Box Settings")
bullish_box_color = input.color(color.new(color.green, 85), "Bullish Box Color", group="Box Settings")
bearish_box_color = input.color(color.new(color.red, 85), "Bearish Box Color", group="Box Settings")

// ─── PREMIUM AND DISCOUNT ───
pdGroup = "Premium and Discount Zones"
show_pd_labels = input.bool(true, "Show PREMIUM / DISCOUNT / EQ Labels", group=pdGroup, tooltip="PREMIUM = upper half of the range (expensive). DISCOUNT = lower half (cheap). EQ = the midline. The half that holds price is shown at full color, the other half is faded.")
premium_color  = input.color(#ff5252, "Premium", inline="pd1", group=pdGroup)
discount_color = input.color(#00c853, "Discount", inline="pd1", group=pdGroup)

// ─── VOLUME PROFILE ───
volGroup = "Volume Profile and Nodes"
showVolumeImprint = input.bool(true, title="Show Volume Profile", group=volGroup)
ticksPerBin = input.int(30, title="Ticks per Bin", minval=1, maxval=100, group=volGroup, tooltip="Sets how many ticks of price range each bin covers. Lower value = more detail.")
vpMaxWidth = input.int(9, title="Profile Max Width (Bars)", minval=1, maxval=50, group=volGroup, tooltip="Limits how far the profile lines extend visually.")

showPOC = input.bool(true, title="Show Extended POC Line", group=volGroup)
pocWidth = input.int(6, title="POC Node Width", minval=1, maxval=10, group=volGroup)

showHVN = input.bool(true, title="Show HVN Nodes", group=volGroup)
hvnThreshold = input.int(70, title="HVN Threshold (% of Max)", minval=1, maxval=99, group=volGroup)
hvnWidth = input.int(4, title="HVN Line Width", minval=1, maxval=10, group=volGroup)

showLVN = input.bool(true, title="Show LVN Nodes", group=volGroup)
lvnThreshold = input.int(30, title="LVN Threshold (% of Max)", minval=1, maxval=99, group=volGroup)
lvnWidth = input.int(1, title="LVN Line Width", minval=1, maxval=10, group=volGroup)

buyVolColor = input.color(color.new(#00c853, 0), title="Buy Volume Color", group=volGroup)
sellVolColor = input.color(color.new(#f44336, 0), title="Sell Volume Color", group=volGroup)

// ─── LABELS ───
volumeAnalysisGroup = "Volume and AMT Labels"
showVolumeLabels = input.bool(true, title="Show Delta Labels", group=volumeAnalysisGroup)
volumeLabelType = input.string("Volume Labels", title="Label Type", options=["Volume Labels", "Arrow Only"], group=volumeAnalysisGroup)
showAMTStates = input.bool(true, title="Show Edge States", group=volumeAnalysisGroup, tooltip="Evaluates edges for Exhaustion, Acceptance, or Reversal.")
scanZonePct = input.int(33, title="Edge Scan Depth (%)", minval=10, maxval=50, group=volumeAnalysisGroup, tooltip="How deep into the structure (from the edge) the script should scan to find a Rejection HVN.")
volumeLabelSize = input.string("Small", title="Label Size", options=["Tiny", "Small", "Normal"], group=volumeAnalysisGroup)

// ─── LINES ───
show_high_line = input.bool(false, "Show Highest High Line", group="Line Settings")
show_low_line = input.bool(false, "Show Lowest Low Line", group="Line Settings")
show_mid_line = input.bool(false, "Show Mid Line", group="Line Settings")
high_color = input.color(color.yellow, "Highest High Line", group="Line Settings")
low_color = input.color(color.orange, "Lowest Low Line", group="Line Settings")
mid_color = input.color(#f48fb1, "Mid Line", group="Line Settings")

// ─── INFO TABLE ───
infoTableGroup = "Info Table Settings"
show_info_table = input.bool(true, "Show Info Table", group=infoTableGroup)
show_highest_high_row = input.bool(true, "Show Highest High Row", group=infoTableGroup)
show_lowest_low_row = input.bool(true, "Show Lowest Low Row", group=infoTableGroup)
show_mid_row = input.bool(true, "Show Mid Row", group=infoTableGroup)
show_range_row = input.bool(true, "Show Range Row", group=infoTableGroup)
show_location_row = input.bool(true, "Show Location Row", group=infoTableGroup, tooltip="Where price sits in the range. 100% = at the highest high, 0% = at the lowest low. Above 50% = PREMIUM, below 50% = DISCOUNT.")
show_amt_stats = input.bool(true, "Show AMT Edge Stats", group=infoTableGroup)

// ─── FIRST STEP ───
firstStepGroup = "First Step Signals"
show_first_steps = input.bool(true, "Show First Steps", group=firstStepGroup)
show_historical_steps = input.bool(true, "Show All Historical Steps", group=firstStepGroup)
first_step_transparency = input.int(0, "First Step Transparency", minval=0, maxval=95, group=firstStepGroup)

// ─── DATA ───
footprint fp = autoDetectPremium ? request.footprint(ticksPerRow, 70) : na

highest_high = ta.highest(high, lookback_bars)
lowest_low = ta.lowest(low, lookback_bars)
midpoint = (highest_high + lowest_low) / 2

bool midline_going_up = midpoint > midpoint[1]
bool midline_going_down = midpoint < midpoint[1]
bool midline_turned_up = midline_going_up and not midline_going_up[1]
bool midline_turned_down = midline_going_down and not midline_going_down[1]

// ─── HELPERS ───
get_volume_label_size() =>
    switch volumeLabelSize
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        => size.small

format_range_with_units(float range_value) =>
    string unit_suffix = ""
    string formatted_value = ""
    switch syminfo.type
        "forex" =>
            pips_value = range_value * math.pow(10, syminfo.mintick == 0.00001 or syminfo.mintick == 0.001 ? 5 : 4)
            formatted_value := str.tostring(math.round(pips_value), "#")
            unit_suffix := " pips"
        "futures" =>
            formatted_value := str.tostring(range_value, "#.##")
            unit_suffix := " points"
        "index" =>
            formatted_value := str.tostring(range_value, "#.##")
            unit_suffix := " points"
        "stock" =>
            formatted_value := str.tostring(range_value, "#.##")
            unit_suffix := " $"
        "crypto" =>
            formatted_value := str.tostring(range_value, "#.####")
            unit_suffix := syminfo.currency == "USD" ? " $" : ""
        =>
            formatted_value := str.tostring(range_value, "#.####")
            unit_suffix := ""
    formatted_value + unit_suffix

// ─── VOLUME FUNCTIONS ───
initializeVolumeLevels(float boxHigh, float boxLow, int adaptiveBins, float binSize) =>
    levels = array.new<BoxVolumeLevel>()
    for i = 0 to adaptiveBins - 1
        float priceLevel = boxLow + (i * binSize) + (binSize / 2)
        array.push(levels, BoxVolumeLevel.new(priceLevel, 0.0, 0.0, 0.0, false))
    levels

updatePremiumVolume(EnhancedBox eb, float rowPrice, float buyVol, float sellVol, float totalVol) =>
    int bins = array.size(eb.volumeLevels)
    if bins > 0
        int idx = eb.binSize > 0 ? math.min(bins - 1, math.max(0, math.floor((rowPrice - eb.low) / eb.binSize))) : 0
        BoxVolumeLevel lvl = array.get(eb.volumeLevels, idx)
        lvl.volume += totalVol
        lvl.buyVolume += buyVol
        lvl.sellVolume += sellVol

updateVolumeLevels(EnhancedBox eb, float candle_high, float candle_low, float candle_open, float candle_close, float candle_volume) =>
    int bins = array.size(eb.volumeLevels)
    if bins > 0 and candle_volume > 0 and eb.binSize > 0
        float candleRange = candle_high - candle_low
        float pm = candle_close - candle_open
        float pr = math.max(candleRange, syminfo.mintick)
        float bp = math.abs(pm) / pr
        float wr = (candle_high - math.max(candle_open, candle_close)) / pr
        float sr = (math.min(candle_open, candle_close) - candle_low) / pr

        float bv = 0.0
        float sv = 0.0
        if pm > 0
            bv := candle_volume * math.max(0.1, math.min(0.9, 0.5 + (bp * 0.3) - (wr * 0.1)))
            sv := candle_volume - bv
        else if pm < 0
            sv := candle_volume * math.max(0.1, math.min(0.9, 0.5 + (bp * 0.3) - (sr * 0.1)))
            bv := candle_volume - sv
        else
            bv := candle_volume * 0.5
            sv := candle_volume * 0.5

        int iStart = math.max(0, math.floor((candle_low - eb.low) / eb.binSize))
        int iEnd = math.min(bins - 1, math.floor((candle_high - eb.low) / eb.binSize))
        if iEnd >= iStart
            for i = iStart to iEnd
                BoxVolumeLevel lvl = array.get(eb.volumeLevels, i)
                float levelBottom = eb.low + i * eb.binSize
                float levelTop = levelBottom + eb.binSize
                float overlap = math.max(0.0, math.min(candle_high, levelTop) - math.max(candle_low, levelBottom))
                if overlap > 0
                    float oF = overlap / pr
                    lvl.volume += candle_volume * oF
                    lvl.buyVolume += bv * oF
                    lvl.sellVolume += sv * oF

calculatePOC(array<BoxVolumeLevel> levels) =>
    if array.size(levels) == 0
        [float(na), 0.0]
    else
        float maxValue = 0.0
        int pocIndex = 0
        for i = 0 to array.size(levels) - 1
            BoxVolumeLevel lvl = array.get(levels, i)
            lvl.isPOC := false
            if lvl.volume > maxValue
                maxValue := lvl.volume
                pocIndex := i

        if maxValue > 0
            BoxVolumeLevel pocLvl = array.get(levels, pocIndex)
            pocLvl.isPOC := true
            [pocLvl.price, pocLvl.volume]
        else
            BoxVolumeLevel midLvl = array.get(levels, math.floor(array.size(levels) / 2))
            [midLvl.price, 0.0]

drawVolumeNodesAndPOC(EnhancedBox enhancedBox) =>
    if array.size(enhancedBox.volumeLevels) > 0
        if array.size(enhancedBox.volumeImprintLines) > 0
            for ln in enhancedBox.volumeImprintLines
                line.delete(ln)
            array.clear(enhancedBox.volumeImprintLines)
        if not na(enhancedBox.pocLine)
            line.delete(enhancedBox.pocLine)
        if not na(enhancedBox.pocLabel)
            label.delete(enhancedBox.pocLabel)

        float maxValue = 0.0
        for lvl in enhancedBox.volumeLevels
            if lvl.volume > maxValue
                maxValue := lvl.volume

        if maxValue > 0
            int boxLeft = enhancedBox.startTime
            int boxRight = enhancedBox.endTime

            for renderLvl in enhancedBox.volumeLevels
                float tVol = renderLvl.volume
                if tVol > 0
                    bool isPOC = renderLvl.isPOC
                    bool isHVN = not isPOC and tVol >= maxValue * (hvnThreshold / 100.0)
                    bool isLVN = not isPOC and tVol <= maxValue * (lvnThreshold / 100.0)
                    color levelColor = renderLvl.buyVolume >= renderLvl.sellVolume ? buyVolColor : sellVolColor

                    if isPOC and showPOC
                        enhancedBox.pocLine := line.new(x1=boxLeft, y1=renderLvl.price, x2=boxRight, y2=renderLvl.price, color=levelColor, width=2)
                        float pocPct = enhancedBox.totalVolume > 0 ? (enhancedBox.pocVolume / enhancedBox.totalVolume) * 100 : 0.0
                        enhancedBox.pocLabel := label.new(x=boxRight, y=renderLvl.price, text="POC: " + str.tostring(pocPct, "#.##") + "%", style=label.style_label_left, color=color.new(color.white, 100), textcolor=levelColor, size=get_volume_label_size())

                    bool drawLevel = isPOC or (isHVN and showHVN) or (isLVN and showLVN) or (not isHVN and not isLVN)
                    if showVolumeImprint and drawLevel
                        int bLen = math.max(1, math.round((tVol / maxValue) * vpMaxWidth))
                        int bWid = isPOC ? pocWidth : isHVN ? hvnWidth : isLVN ? lvnWidth : 2
                        array.push(enhancedBox.volumeImprintLines, line.new(x1=boxLeft, y1=renderLvl.price, x2=boxLeft + bLen, y2=renderLvl.price, color=levelColor, width=bWid))

createVolumeLabels(EnhancedBox enhancedBox) =>
    if showVolumeLabels
        if not na(enhancedBox.highVolumeLabel)
            label.delete(enhancedBox.highVolumeLabel)
        if not na(enhancedBox.lowVolumeLabel)
            label.delete(enhancedBox.lowVolumeLabel)

        if volumeLabelType == "Volume Labels"
            if enhancedBox.bullishVolume > 0
                enhancedBox.highVolumeLabel := label.new(x=enhancedBox.startTime, y=enhancedBox.high, text=str.tostring(enhancedBox.bullishVolume, format.volume), style=label.style_label_down, size=get_volume_label_size(), color=na, textcolor=buyVolColor)
            if enhancedBox.bearishVolume > 0
                enhancedBox.lowVolumeLabel := label.new(x=enhancedBox.startTime, y=enhancedBox.low, text=str.tostring(enhancedBox.bearishVolume, format.volume), style=label.style_label_up, size=get_volume_label_size(), color=na, textcolor=sellVolColor)
        else if volumeLabelType == "Arrow Only"
            if enhancedBox.bullishVolume > enhancedBox.bearishVolume and enhancedBox.bullishVolume > 0
                enhancedBox.highVolumeLabel := label.new(x=enhancedBox.startTime, y=enhancedBox.high, text="↑", style=label.style_label_down, size=get_volume_label_size(), color=na, textcolor=buyVolColor)
            else if enhancedBox.bearishVolume > enhancedBox.bullishVolume and enhancedBox.bearishVolume > 0
                enhancedBox.lowVolumeLabel := label.new(x=enhancedBox.startTime, y=enhancedBox.low, text="↓", style=label.style_label_up, size=get_volume_label_size(), color=na, textcolor=sellVolColor)

// ─── AMT EDGE SCANNER ───
getAMTEdgeStates(EnhancedBox eb, float hThresh, float lThresh, int scanDepthPct) =>
    float pocV = eb.pocVolume
    int bins = eb.adaptiveBins
    int scanZone = math.max(2, math.round(bins * (scanDepthPct / 100.0)))

    string topTxt = "Neutral"
    color topCol = color.gray
    string btmTxt = "Neutral"
    color btmCol = color.gray

    if array.size(eb.volumeLevels) > 0
        BoxVolumeLevel topLvl = array.get(eb.volumeLevels, bins - 1)
        bool topIsHVN = topLvl.volume >= pocV * (hThresh / 100.0)
        bool topIsLVN = topLvl.volume <= pocV * (lThresh / 100.0)
        bool topIsBearish = topLvl.sellVolume > topLvl.buyVolume

        if topIsHVN and topIsBearish
            topTxt := "Strong Rejection (Bear HVN)"
            topCol := color.red
        else if topIsHVN and not topIsBearish
            topTxt := "Acceptance (Bull HVN)"
            topCol := color.green
        else if topIsLVN
            bool foundBearHVN = false
            if bins > 1
                for i = bins - 2 to math.max(0, bins - scanZone)
                    BoxVolumeLevel zLvl = array.get(eb.volumeLevels, i)
                    bool isLocalBearishNode = (zLvl.volume >= pocV * (hThresh / 100.0) and zLvl.sellVolume > zLvl.buyVolume) or (zLvl.sellVolume > zLvl.buyVolume * 1.5 and zLvl.volume > pocV * 0.2)
                    if isLocalBearishNode
                        foundBearHVN := true
                        break
            if foundBearHVN
                topTxt := "Exhaustion -> Rejection"
                topCol := color.red
            else
                topTxt := "Exhaustion (Tapering)"
                topCol := color.orange

        BoxVolumeLevel btmLvl = array.get(eb.volumeLevels, 0)
        bool btmIsHVN = btmLvl.volume >= pocV * (hThresh / 100.0)
        bool btmIsLVN = btmLvl.volume <= pocV * (lThresh / 100.0)
        bool btmIsBullish = btmLvl.buyVolume > btmLvl.sellVolume

        if btmIsHVN and btmIsBullish
            btmTxt := "Strong Rejection (Bull HVN)"
            btmCol := color.green
        else if btmIsHVN and not btmIsBullish
            btmTxt := "Acceptance (Bear HVN)"
            btmCol := color.red
        else if btmIsLVN
            bool foundBullHVN = false
            if bins > 1
                for i = 1 to math.min(bins - 1, scanZone - 1)
                    BoxVolumeLevel zLvl = array.get(eb.volumeLevels, i)
                    bool isLocalBullishNode = (zLvl.volume >= pocV * (hThresh / 100.0) and zLvl.buyVolume > zLvl.sellVolume) or (zLvl.buyVolume > zLvl.sellVolume * 1.5 and zLvl.volume > pocV * 0.2)
                    if isLocalBullishNode
                        foundBullHVN := true
                        break
            if foundBullHVN
                btmTxt := "Exhaustion -> Rejection"
                btmCol := color.green
            else
                btmTxt := "Exhaustion (Tapering)"
                btmCol := color.orange

    [topTxt, topCol, btmTxt, btmCol]

drawAMTStateLabels(EnhancedBox enhancedBox, string topTxt, color topCol, string btmTxt, color btmCol) =>
    if showAMTStates and array.size(enhancedBox.volumeLevels) > 0
        if not na(enhancedBox.topStateLabel)
            label.delete(enhancedBox.topStateLabel)
        if not na(enhancedBox.btmStateLabel)
            label.delete(enhancedBox.btmStateLabel)
        enhancedBox.topStateLabel := label.new(x=enhancedBox.endTime, y=enhancedBox.high, text=topTxt, style=label.style_label_lower_left, color=color.new(color.white, 100), textcolor=topCol, size=get_volume_label_size())
        enhancedBox.btmStateLabel := label.new(x=enhancedBox.endTime, y=enhancedBox.low, text=btmTxt, style=label.style_label_upper_left, color=color.new(color.white, 100), textcolor=btmCol, size=get_volume_label_size())

updateBoxColor(EnhancedBox enhancedBox) =>
    if not na(enhancedBox.boxObj) and enhancedBox.totalVolume > 0
        box.set_bgcolor(enhancedBox.boxObj, enhancedBox.bullishVolume > enhancedBox.bearishVolume ? bullish_box_color : bearish_box_color)

deleteEnhancedBoxElements(EnhancedBox enhancedBox) =>
    if not na(enhancedBox)
        if not na(enhancedBox.volumeImprintLines) and array.size(enhancedBox.volumeImprintLines) > 0
            for ln in enhancedBox.volumeImprintLines
                line.delete(ln)
            array.clear(enhancedBox.volumeImprintLines)
        if not na(enhancedBox.pocLine)
            line.delete(enhancedBox.pocLine)
        if not na(enhancedBox.pocLabel)
            label.delete(enhancedBox.pocLabel)
        if not na(enhancedBox.highVolumeLabel)
            label.delete(enhancedBox.highVolumeLabel)
        if not na(enhancedBox.lowVolumeLabel)
            label.delete(enhancedBox.lowVolumeLabel)
        if not na(enhancedBox.topStateLabel)
            label.delete(enhancedBox.topStateLabel)
        if not na(enhancedBox.btmStateLabel)
            label.delete(enhancedBox.btmStateLabel)

// ─── GLOBALS ───
var box current_box = na
var line high_line = na
var line low_line = na
var line mid_line = na
var line box_mid_line = na
var EnhancedBox enhanced_box = na

var label premium_lbl = na
var label discount_lbl = na
var label eq_lbl = na

var bool first_step_up_drawn = false
var bool first_step_down_drawn = false
var line first_step_up_line = na
var line first_step_down_line = na

var string g_topTxt = "Neutral"
var color g_topCol = color.gray
var string g_btmTxt = "Neutral"
var color g_btmCol = color.gray

// ─── BOX AND PROFILE ───
if barstate.islast
    if not na(current_box)
        box.delete(current_box)
    if not na(high_line)
        line.delete(high_line)
    if not na(low_line)
        line.delete(low_line)
    if not na(mid_line)
        line.delete(mid_line)
    if not na(box_mid_line)
        line.delete(box_mid_line)
    if not na(premium_lbl)
        label.delete(premium_lbl)
    if not na(discount_lbl)
        label.delete(discount_lbl)
    if not na(eq_lbl)
        label.delete(eq_lbl)
    if not na(enhanced_box)
        deleteEnhancedBoxElements(enhanced_box)

    int left_x = bar_index
    int right_x = bar_index + line_length

    if show_box
        current_box := box.new(left=left_x, top=highest_high, right=right_x, bottom=lowest_low, bgcolor=bullish_box_color, border_color=color.new(color.white, 100), border_width=0)

        float rangeSize = highest_high - lowest_low
        int adaptiveBins = 10
        float binSize = 0.0
        if rangeSize > 0
            float rangeInTicks = rangeSize / syminfo.mintick
            adaptiveBins := math.max(5, math.min(100, math.round(rangeInTicks / ticksPerBin)))
            binSize := rangeSize / adaptiveBins

        enhanced_box := EnhancedBox.new(boxObj=current_box, high=highest_high, low=lowest_low, startTime=left_x, endTime=right_x, totalVolume=0.0, bullishVolume=0.0, bearishVolume=0.0, volumeLevels=initializeVolumeLevels(highest_high, lowest_low, adaptiveBins, binSize), volumeImprintLines=array.new<line>(), pocLine=na, pocLabel=na, highVolumeLabel=na, lowVolumeLabel=na, topStateLabel=na, btmStateLabel=na, pocPrice=na, pocVolume=0.0, adaptiveBins=adaptiveBins, binSize=binSize, isActive=true)

        for i = 0 to lookback_bars - 1
            if bar_index >= i
                float historicalHigh = high[i]
                float historicalLow = low[i]
                if historicalLow <= highest_high and historicalHigh >= lowest_low
                    footprint currentFp = fp[i]
                    if autoDetectPremium and not na(currentFp)
                        array<volume_row> allRows = currentFp.rows()
                        if array.size(allRows) > 0
                            for r in allRows
                                float r_tv = r.total_volume()
                                if r_tv > 0
                                    float r_bp = r.down_price() + ((r.up_price() - r.down_price()) / 2)
                                    if r_bp >= lowest_low and r_bp <= highest_high
                                        updatePremiumVolume(enhanced_box, r_bp, r.buy_volume(), r.sell_volume(), r_tv)
                                        enhanced_box.totalVolume += r_tv
                    else
                        float historicalVolume = volume[i]
                        if not na(historicalVolume) and historicalVolume > 0
                            enhanced_box.totalVolume += historicalVolume
                            updateVolumeLevels(enhanced_box, historicalHigh, historicalLow, open[i], close[i], historicalVolume)

        float totalBullishVolume = 0.0
        float totalBearishVolume = 0.0
        for lvl in enhanced_box.volumeLevels
            totalBullishVolume += lvl.buyVolume
            totalBearishVolume += lvl.sellVolume
        enhanced_box.bullishVolume := totalBullishVolume
        enhanced_box.bearishVolume := totalBearishVolume

        [pocPrice, pocVolume] = calculatePOC(enhanced_box.volumeLevels)
        enhanced_box.pocPrice := pocPrice
        enhanced_box.pocVolume := pocVolume

        [tT, tC, bT, bC] = getAMTEdgeStates(enhanced_box, hvnThreshold, lvnThreshold, scanZonePct)
        g_topTxt := tT
        g_topCol := tC
        g_btmTxt := bT
        g_btmCol := bC

        updateBoxColor(enhanced_box)
        createVolumeLabels(enhanced_box)
        drawVolumeNodesAndPOC(enhanced_box)
        drawAMTStateLabels(enhanced_box, g_topTxt, g_topCol, g_btmTxt, g_btmCol)

        if show_box_midline
            box_mid_line := line.new(x1=left_x, y1=midpoint, x2=right_x, y2=midpoint, color=box_midline_color, width=box_midline_width, style=line.style_dotted)

    if show_pd_labels and highest_high > lowest_low
        bool inPremium  = close > midpoint
        bool inDiscount = close < midpoint
        float premY = (highest_high + midpoint) / 2
        float discY = (lowest_low + midpoint) / 2
        premium_lbl  := label.new(x=right_x, y=premY, text="PREMIUM", style=label.style_label_right, color=color.new(color.white, 100), textcolor=inPremium ? premium_color : color.new(premium_color, 60), size=get_volume_label_size())
        discount_lbl := label.new(x=right_x, y=discY, text="DISCOUNT", style=label.style_label_right, color=color.new(color.white, 100), textcolor=inDiscount ? discount_color : color.new(discount_color, 60), size=get_volume_label_size())
        eq_lbl       := label.new(x=right_x, y=midpoint, text="EQ", style=label.style_label_right, color=color.new(color.white, 100), textcolor=box_midline_color, size=get_volume_label_size())

    if show_high_line
        high_line := line.new(x1=left_x, y1=highest_high, x2=right_x, y2=highest_high, color=high_color, width=2, style=line.style_solid)
    if show_low_line
        low_line := line.new(x1=left_x, y1=lowest_low, x2=right_x, y2=lowest_low, color=low_color, width=2, style=line.style_solid)
    if show_mid_line
        mid_line := line.new(x1=left_x, y1=midpoint, x2=right_x, y2=midpoint, color=mid_color, width=2, style=line.style_dashed)

// ─── FIRST STEP ───
if show_first_steps and barstate.isconfirmed
    if midline_turned_up and not first_step_up_drawn
        if not show_historical_steps and not na(first_step_up_line)
            line.delete(first_step_up_line)
        line step_up_line = line.new(x1=bar_index, y1=midpoint, x2=bar_index + 5, y2=midpoint, color=color.new(color.green, first_step_transparency), width=3, style=line.style_solid)
        first_step_up_drawn := true
        first_step_down_drawn := false
        if not show_historical_steps
            first_step_up_line := step_up_line

    if midline_turned_down and not first_step_down_drawn
        if not show_historical_steps and not na(first_step_down_line)
            line.delete(first_step_down_line)
        line step_down_line = line.new(x1=bar_index, y1=midpoint, x2=bar_index + 5, y2=midpoint, color=color.new(color.red, first_step_transparency), width=3, style=line.style_solid)
        first_step_down_drawn := true
        first_step_up_drawn := false
        if not show_historical_steps
            first_step_down_line := step_down_line

// ─── PLOTS ───
plot(show_high_line ? highest_high : na, "Highest High Level", color=high_color, linewidth=1, trackprice=true)
plot(show_low_line ? lowest_low : na, "Lowest Low Level", color=low_color, linewidth=1, trackprice=true)
plot(show_mid_line ? midpoint : na, "Mid Level", color=mid_color, linewidth=1, trackprice=true)

// ─── INFO TABLE ───
if show_info_table and barstate.islast
    int visibleRows = 0
    if show_highest_high_row
        visibleRows += 1
    if show_lowest_low_row
        visibleRows += 1
    if show_mid_row
        visibleRows += 1
    if show_range_row
        visibleRows += 1
    if show_location_row
        visibleRows += 1
    if show_amt_stats and not na(enhanced_box)
        visibleRows += 3

    if visibleRows > 0
        var table info = table.new(position.top_right, 2, visibleRows, bgcolor=color.new(color.white, 20), border_width=1)
        int currentRow = 0

        if show_highest_high_row
            table.cell(info, 0, currentRow, "Highest High:", text_color=color.black, text_size=size.small)
            table.cell(info, 1, currentRow, str.tostring(highest_high, "#.####"), text_color=high_color, text_size=size.small)
            currentRow += 1

        if show_lowest_low_row
            table.cell(info, 0, currentRow, "Lowest Low:", text_color=color.black, text_size=size.small)
            table.cell(info, 1, currentRow, str.tostring(lowest_low, "#.####"), text_color=low_color, text_size=size.small)
            currentRow += 1

        if show_mid_row
            table.cell(info, 0, currentRow, "Mid:", text_color=color.black, text_size=size.small)
            table.cell(info, 1, currentRow, str.tostring(midpoint, "#.####"), text_color=box_midline_color, text_size=size.small)
            currentRow += 1

        if show_range_row
            table.cell(info, 0, currentRow, "Range:", text_color=color.black, text_size=size.small)
            table.cell(info, 1, currentRow, format_range_with_units(highest_high - lowest_low), text_color=color.gray, text_size=size.small)
            currentRow += 1

        if show_location_row
            float rngSize = highest_high - lowest_low
            float posPct = rngSize > 0 ? (close - lowest_low) / rngSize * 100 : 50.0
            string locTxt = (posPct > 50 ? "PREMIUM " : posPct < 50 ? "DISCOUNT " : "EQ ") + str.tostring(posPct, "#") + "%"
            color locCol = posPct > 50 ? premium_color : posPct < 50 ? discount_color : box_midline_color
            table.cell(info, 0, currentRow, "Location:", text_color=color.black, text_size=size.small)
            table.cell(info, 1, currentRow, locTxt, text_color=locCol, text_size=size.small)
            currentRow += 1

        if show_amt_stats and not na(enhanced_box)
            float pocPct = enhanced_box.totalVolume > 0 ? (enhanced_box.pocVolume / enhanced_box.totalVolume) * 100 : 0.0
            table.cell(info, 0, currentRow, "POC (% of Total):", text_color=color.black, text_size=size.small)
            table.cell(info, 1, currentRow, str.tostring(pocPct, "#.##") + "%", text_color=color.blue, text_size=size.small)
            currentRow += 1

            table.cell(info, 0, currentRow, "High Edge Status:", text_color=color.black, text_size=size.small)
            table.cell(info, 1, currentRow, g_topTxt, text_color=g_topCol, text_size=size.small)
            currentRow += 1

            table.cell(info, 0, currentRow, "Low Edge Status:", text_color=color.black, text_size=size.small)
            table.cell(info, 1, currentRow, g_btmTxt, text_color=g_btmCol, text_size=size.small)
            currentRow += 1
````
