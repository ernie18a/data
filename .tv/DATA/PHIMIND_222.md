<!-- tradingview-pine-id: PUB;7ee5874255d947c8894156ad64c15dae -->
<!-- tradingviewscripts-format: 1 -->
# PHIMIND 222

Source: https://www.tradingview.com/script/CMvm4T0P-PHIMIND-222/

## Description

PHIMIND 222 stacks three reads of the same chart and only speaks when
  all three agree.

  WHAT IT DRAWS
  • Supply and demand zones, marked from major swings, with a BOS label
    left behind when price breaks one
  • Volumized order blocks — bull and bear, with the buy/sell volume
    split drawn inside each block and overlapping zones merged
  • Swing structure tagged automatically: HH, LH, HL, LL
  • BUY / SELL labels
  • A rolling table of the last five signals — time, side, price, the
    zone it tapped, the structure, and the bias at the time

  THE SIGNAL
  A signal needs three things to line up:
    1. Price taps a demand zone or bullish order block (or supply /
       bearish for a sell)
    2. The swing is a higher low for a buy, a lower high for a sell
    3. Structure bias agrees — a bull BOS for a buy, bear BOS for a sell

  Turn OFF "Require BOS confirmation" for the looser 2-of-3 version:
  zone plus swing, no bias needed. Fewer misses, more noise.

  SETTINGS WORTH KNOWING
  • Signals-Only Mode — hides zones, blocks and structure tags, leaves
    just the arrows. Start here if the chart feels busy.
  • Swing High/Low Length — the noise filter. Higher = fewer, bigger
    swings. It drives the structure tags and the signals.
  • Zone Count — how far back order blocks are kept on the chart.
  • Zone Invalidation — Wick or Close. Wick kills a zone sooner.

  Works on any symbol and any timeframe. Everything is toggleable, so
  run the full picture or strip it to arrows.

  Built on open-source Smart Money and volumized order-block work from
  the TradingView community. Added here: the three-way confluence gate,
  the automatic HH/LH/HL/LL tagging, Signals-Only mode, and the last-five
  signal table.

  This is a charting tool, not advice. It marks structure and zones — it
  does not know

---

## Source Code

````pine
//@version=6
// PHIMIND 222 - Confluence Engine
// Pine v6 build of the PHIMINDFLOW Confluence Engine, published so it can be
// loaded straight onto a chart. Logic is unchanged from the v5 original.
// Copy of "PHIMINDFLOW - Confluence Engine" + a Last-5 Signals memory table for JARVIS to read.
// The original Confluence Engine is untouched. Additions only: ⑤ JARVIS Memory inputs,
// zone-detail helpers, a rolling last-5 signal store, and an on-chart table.

const bool DEBUG = false
const int maxBoxesCount = 500
const float overlapThresholdPercentage = 0
const int maxDistanceToLastBar = 1750 // Affects Running Time
const int maxOrderBlocks = 30

indicator("PHIMIND 222", overlay = true, max_labels_count = 500, max_boxes_count = maxBoxesCount, max_lines_count = 500, max_bars_back = 5000)

//
// ===================== ① LAYER TOGGLES =====================
//
grpL = "① Layers"
show_smc       = input.bool(true,  "Smart Money (BOS + Supply/Demand)", group = grpL)
show_ob        = input.bool(true,  "Volumized Order Blocks",            group = grpL)
show_structure = input.bool(true,  "Swing Structure (HH/LH/HL/LL)",     group = grpL)
show_signals   = input.bool(true,  "Buy/Sell Signals",                  group = grpL)
signals_only   = input.bool(false, "Signals-Only Mode (hide everything else)", group = grpL, tooltip = "Hides SMC zones, order blocks and structure tags — leaves only the Buy/Sell arrows for a clean chart.")

//
// ===================== ② SMC LITE — SETTINGS (verbatim) =====================
//
swing_length = input.int(10, title = 'Swing High/Low Length', group = 'SMC — Settings', minval = 1, maxval = 50, tooltip = "Major-swing filter. Higher = fewer, bigger swings (less noise). Drives structure tags + signals.")
history_of_demand_to_keep = input.int(20, title = 'History To Keep', group = 'SMC — Settings', minval = 5, maxval = 50)
box_width = input.float(2.5, title = 'Supply/Demand Box Width', group = 'SMC — Settings', minval = 1, maxval = 10, step = 0.5)

show_zigzag = input.bool(false, title = 'Show Zig Zag', group = 'SMC — Visual', inline = '1')
show_price_action_labels = input.bool(false, title = 'Show Price Action Labels', group = 'SMC — Visual', inline = '2')

supply_color = input.color(color.new(#EDEDED,70), title = 'Supply', group = 'SMC — Visual', inline = '3')
supply_outline_color = input.color(color.new(color.white,75), title = 'Outline', group = 'SMC — Visual', inline = '3')

demand_color = input.color(color.new(#00FFFF,70), title = 'Demand', group = 'SMC — Visual', inline = '4')
demand_outline_color = input.color(color.new(color.white,75), title = 'Outline', group = 'SMC — Visual', inline = '4')

bos_label_color = input.color(color.white, title = 'BOS Label', group = 'SMC — Visual', inline = '5')
poi_label_color = input.color(color.white, title = 'POI Label', group = 'SMC — Visual', inline = '7')

swing_type_color = input.color(color.black, title = 'Price Action Label', group = 'SMC — Visual', inline = '8')
zigzag_color = input.color(color.new(#000000,0), title = 'Zig Zag', group = 'SMC — Visual', inline = '9')

//
// ===================== ③ ORDER BLOCKS — SETTINGS (verbatim) =====================
//
showInvalidated = input.bool(true, "Show Historic Zones", group = "Order Blocks", display = display.none)
OBsEnabled = true
orderBlockVolumetricInfo = input.bool(true, "Volumetric Info", group = "Order Blocks", inline="EV", display = display.none)
obEndMethod = input.string("Wick", "Zone Invalidation", options = ["Wick", "Close"],  group = "Order Blocks", display = display.none)
combineOBs = DEBUG ? input.bool(true, "Combine Zones", group = "Order Blocks", display = display.none) : true
maxATRMult = DEBUG ? input.float(3.5,"Max Atr Multiplier", group = "Order Blocks") : 3.5
swingLength = input.int(10, 'Swing Length', minval = 3, tooltip="Swing length is used when finding order block formations. Smaller values will result in finding smaller order blocks.",group = "Order Blocks", display = display.none)
zoneCount = input.string("Low", 'Zone Count', options = ["High", "Medium", "Low", "One"], tooltip = "Number of Order Block Zones to be rendered. Higher options will result in older Order Blocks shown.",  group = "Order Blocks", display = display.none)
bullOrderBlockColor = input(#08998180, 'Bullish', inline = 'obColor', group = 'Order Blocks', display = display.none)
bearOrderBlockColor = input(#f2364680, 'Bearish', inline = 'obColor', group = 'Order Blocks', display = display.none)

bullishOrderBlocks = zoneCount == "One" ? 1 : zoneCount == "Low" ? 3 : zoneCount == "Medium" ? 5 : 10
bearishOrderBlocks = zoneCount == "One" ? 1 : zoneCount == "Low" ? 3 : zoneCount == "Medium" ? 5 : 10

timeframe1Enabled = true
timeframe1 = ""

textColor = input.color(#ffffff80, "Text Color", group = "Order Blocks — Style")
extendZonesBy = DEBUG ? input.int(15, "Extend Zones", group = "Order Blocks — Style", minval = 1, maxval = 30, inline = "ExtendZones") : 15
extendZonesDynamic = DEBUG ? input.bool(true, "Dynamic", group = "Order Blocks — Style", inline = "ExtendZones") : true
combinedText = DEBUG ? input.bool(false, "Combined Text", group = "Order Blocks — Style", inline = "CombinedColor") : false
volumeBarsPlace = DEBUG ? input.string("Left", "Show Volume Bars At", options = ["Left", "Right"], group = "Order Blocks — Style", inline = "volumebars") : "Left"
mirrorVolumeBars = DEBUG ? input.bool(true, "Mirror Volume Bars", group = "Order Blocks — Style", inline = "volumebars") : true

volumeBarsLeftSide = (volumeBarsPlace == "Left")
extendZonesByTime = extendZonesBy * timeframe.in_seconds(timeframe.period) * 1000

atrOB = ta.atr(10) // OB sizing ATR (declared before functions that use it)

//
// ===================== ④ STRUCTURE & SIGNALS — SETTINGS (new) =====================
//
grpS = "④ Structure & Signals"
hh_color   = input.color(color.new(#089981,0), "HH", group = grpS, inline = "s1")
lh_color   = input.color(color.new(#2962ff,0), "LH", group = grpS, inline = "s1")
hl_color   = input.color(color.new(#ff9800,0), "HL", group = grpS, inline = "s2")
ll_color   = input.color(color.new(#f7c948,0), "LL", group = grpS, inline = "s2")
buy_color  = input.color(color.new(#089981,0), "Buy",  group = grpS, inline = "s3")
sell_color = input.color(color.new(#f23645,0), "Sell", group = grpS, inline = "s3")
require_bos = input.bool(true, "Require BOS confirmation (all-3 confluence)", group = grpS, tooltip = "ON = strict ALL-3: zone tap + HL/LH swing + BOS bias must all align. OFF = 2-of-3 (zone + swing only).")

//
// ===================== ⑤ JARVIS MEMORY — SETTINGS (new) =====================
//
grpJ = "⑤ JARVIS Memory"
show_table = input.bool(true, "Show Last-5 Signal Table (JARVIS memory)", group = grpJ, tooltip = "On-chart log of the 5 most recent Buy/Sell signals. This is what JARVIS reads when asked. Auto-scoped to the current symbol + timeframe. Keep ON so JARVIS can see it.")
table_pos_in = input.string("Top Right", "Table Position", options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = grpJ)

//
// ===================== SMC LITE — FUNCTIONS (verbatim) =====================
//
f_array_add_pop(array, new_value_to_add) =>
    array.unshift(array, new_value_to_add)
    array.pop(array)

f_sh_sl_labels(array, swing_type) =>
    var string label_text = na
    if swing_type == 1
        if array.get(array, 0) >= array.get(array, 1)
            label_text := 'HH'
        else
            label_text := 'LH'
        label.new(bar_index - swing_length, array.get(array,0), text = label_text, style=label.style_label_down, textcolor = swing_type_color, color = color.new(swing_type_color, 100), size = size.tiny)
    else if swing_type == -1
        if array.get(array, 0) >= array.get(array, 1)
            label_text := 'HL'
        else
            label_text := 'LL'
        label.new(bar_index - swing_length, array.get(array,0), text = label_text, style=label.style_label_up, textcolor = swing_type_color, color = color.new(swing_type_color, 100), size = size.tiny)

f_check_overlapping(new_poi, box_array, atr) =>
    atr_threshold = atr * 2
    okay_to_draw = true
    for i = 0 to array.size(box_array) - 1
        top = box.get_top(array.get(box_array, i))
        bottom = box.get_bottom(array.get(box_array, i))
        poi = (top + bottom) / 2
        upper_boundary = poi + atr_threshold
        lower_boundary = poi - atr_threshold
        if new_poi >= lower_boundary and new_poi <= upper_boundary
            okay_to_draw := false
            break
        else
            okay_to_draw := true
    okay_to_draw

f_supply_demand(value_array, bn_array, box_array, label_array, box_type, atr) =>
    atr_buffer = atr * (box_width / 10)
    box_left = array.get(bn_array, 0)
    box_right = bar_index
    var float box_top = 0.00
    var float box_bottom = 0.00
    var float poi = 0.00
    if box_type == 1
        box_top := array.get(value_array, 0)
        box_bottom := box_top - atr_buffer
        poi := (box_top + box_bottom) / 2
    else if box_type == -1
        box_bottom := array.get(value_array, 0)
        box_top := box_bottom + atr_buffer
        poi := (box_top + box_bottom) / 2
    okay_to_draw = f_check_overlapping(poi, box_array, atr)
    if box_type == 1 and okay_to_draw
        box.delete( array.get(box_array, array.size(box_array) - 1) )
        f_array_add_pop(box_array, box.new( left = box_left, top = box_top, right = box_right, bottom = box_bottom, border_color = supply_outline_color, bgcolor = supply_color, extend = extend.right, text = 'SUPPLY', text_halign = text.align_center, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))
        box.delete( array.get(label_array, array.size(label_array) - 1) )
        f_array_add_pop(label_array, box.new( left = box_left, top = poi, right = box_right, bottom = poi, border_color = color.new(poi_label_color,90), bgcolor = color.new(poi_label_color,90), extend = extend.right, text = 'POI', text_halign = text.align_left, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))
    else if box_type == -1 and okay_to_draw
        box.delete( array.get(box_array, array.size(box_array) - 1) )
        f_array_add_pop(box_array, box.new( left = box_left, top = box_top, right = box_right, bottom = box_bottom, border_color = demand_outline_color, bgcolor = demand_color, extend = extend.right,  text = 'DEMAND', text_halign = text.align_center, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))
        box.delete( array.get(label_array, array.size(label_array) - 1) )
        f_array_add_pop(label_array, box.new( left = box_left, top = poi, right = box_right, bottom = poi, border_color = color.new(poi_label_color,90), bgcolor = color.new(poi_label_color,90), extend = extend.right,  text = 'POI', text_halign = text.align_left, text_valign = text.align_center, text_color = poi_label_color, text_size = size.small, xloc = xloc.bar_index))

f_sd_to_bos(box_array, bos_array, label_array, zone_type) =>
    if zone_type == 1
        for i = 0 to array.size(box_array) - 1
            level_to_break = box.get_top(array.get(box_array,i))
            if close >= level_to_break
                copied_box = box.copy(array.get(box_array,i))
                f_array_add_pop(bos_array, copied_box)
                mid = (box.get_top(array.get(box_array,i)) + box.get_bottom(array.get(box_array,i))) / 2
                box.set_top(array.get(bos_array,0), mid)
                box.set_bottom(array.get(bos_array,0), mid)
                box.set_extend( array.get(bos_array,0), extend.none)
                box.set_right( array.get(bos_array,0), bar_index)
                box.set_text( array.get(bos_array,0), 'BOS' )
                box.set_text_color( array.get(bos_array,0), bos_label_color)
                box.set_text_size( array.get(bos_array,0), size.small)
                box.set_text_halign( array.get(bos_array,0), text.align_center)
                box.set_text_valign( array.get(bos_array,0), text.align_center)
                box.delete(array.get(box_array, i))
                box.delete(array.get(label_array, i))
    if zone_type == -1
        for i = 0 to array.size(box_array) - 1
            level_to_break = box.get_bottom(array.get(box_array,i))
            if close <= level_to_break
                copied_box = box.copy(array.get(box_array,i))
                f_array_add_pop(bos_array, copied_box)
                mid = (box.get_top(array.get(box_array,i)) + box.get_bottom(array.get(box_array,i))) / 2
                box.set_top(array.get(bos_array,0), mid)
                box.set_bottom(array.get(bos_array,0), mid)
                box.set_extend( array.get(bos_array,0), extend.none)
                box.set_right( array.get(bos_array,0), bar_index)
                box.set_text( array.get(bos_array,0), 'BOS' )
                box.set_text_color( array.get(bos_array,0), bos_label_color)
                box.set_text_size( array.get(bos_array,0), size.small)
                box.set_text_halign( array.get(bos_array,0), text.align_center)
                box.set_text_valign( array.get(bos_array,0), text.align_center)
                box.delete(array.get(box_array, i))
                box.delete(array.get(label_array, i))

f_extend_box_endpoint(box_array) =>
    for i = 0 to array.size(box_array) - 1
        box.set_right(array.get(box_array, i), bar_index + 100)

//
// ===================== ORDER BLOCKS — TYPES (verbatim) =====================
//
type orderBlockInfo
    float top
    float bottom
    float obVolume
    string obType
    int startTime
    float bbVolume
    float obLowVolume
    float obHighVolume
    bool breaker = false
    int breakTime
    string timeframeStr
    bool disabled = false
    string combinedTimeframesStr = na
    bool combined = false

type orderBlock
    orderBlockInfo info
    bool isRendered = false

    box orderBox = na
    box breakerBox = na

    line orderBoxLineTop = na
    line orderBoxLineBottom = na
    line breakerBoxLineTop = na
    line breakerBoxLineBottom = na
    //
    box orderBoxText = na
    box orderBoxPositive = na
    box orderBoxNegative = na

    line orderSeperator = na
    line orderTextSeperator = na

createOrderBlock (orderBlockInfo orderBlockInfoF) =>
    orderBlock newOrderBlock = orderBlock.new(orderBlockInfoF)
    newOrderBlock

safeDeleteOrderBlock (orderBlock orderBlockF) =>
    orderBlockF.isRendered := false

    box.delete(orderBlockF.orderBox)
    box.delete(orderBlockF.breakerBox)
    box.delete(orderBlockF.orderBoxText)
    box.delete(orderBlockF.orderBoxPositive)
    box.delete(orderBlockF.orderBoxNegative)

    line.delete(orderBlockF.orderBoxLineTop)
    line.delete(orderBlockF.orderBoxLineBottom)
    line.delete(orderBlockF.breakerBoxLineTop)
    line.delete(orderBlockF.breakerBoxLineBottom)
    line.delete(orderBlockF.orderSeperator)
    line.delete(orderBlockF.orderTextSeperator)

type timeframeInfo
    int index = na
    string timeframeStr = na
    bool isEnabled = false

    orderBlockInfo[] bullishOrderBlocksList = na
    orderBlockInfo[] bearishOrderBlocksList = na

newTimeframeInfo (index, timeframeStr, isEnabled) =>
    newTFInfo = timeframeInfo.new()
    newTFInfo.index := index
    newTFInfo.isEnabled := isEnabled
    newTFInfo.timeframeStr := timeframeStr

    newTFInfo

type obSwing
    int x = na
    float y = na
    float swingVolume = na
    bool crossed = false

// ____ TYPES END ____

var timeframeInfo[] timeframeInfos = array.from(newTimeframeInfo(1, timeframe1, timeframe1Enabled))
var bullishOrderBlocksList = array.new<orderBlockInfo>(0)
var bearishOrderBlocksList = array.new<orderBlockInfo>(0)

var allOrderBlocksList = array.new<orderBlock>(0)

moveLine(_line, _x, _y, _x2) =>
    line.set_xy1(_line, _x,  _y)
    line.set_xy2(_line, _x2, _y)

moveBox (_box, _topLeftX, _topLeftY, _bottomRightX, _bottomRightY) =>
    box.set_lefttop(_box, _topLeftX, _topLeftY)
    box.set_rightbottom(_box, _bottomRightX, _bottomRightY)

isTimeframeLower (timeframe1F, timeframe2F) =>
    timeframe.in_seconds(timeframe1F) < timeframe.in_seconds(timeframe2F)

getMinTimeframe (timeframe1F, timeframe2F) =>
    if isTimeframeLower(timeframe1F, timeframe2F)
        timeframe1F
    else
        timeframe2F

getMaxTimeframe (timeframe1F, timeframe2F) =>
    if isTimeframeLower(timeframe1F, timeframe2F)
        timeframe2F
    else
        timeframe1F

formatTimeframeString (formatTimeframe) =>
    timeframeF = formatTimeframe == "" ? timeframe.period : formatTimeframe

    if str.contains(timeframeF, "D") or str.contains(timeframeF, "W") or str.contains(timeframeF, "S") or str.contains(timeframeF, "M")
        timeframeF
    else
        seconds = timeframe.in_seconds(timeframeF)
        if seconds >= 3600
            hourCount = int(seconds / 3600)
            str.tostring(hourCount) + " Hour" + (hourCount > 1 ? "s" : "")
        else
            timeframeF + " Min"

betterCross(s1, s2) =>
    string ret = na
    if s1 >= s2 and s1[1] < s2
        ret := "Bull"
    if s1 < s2 and s1[1] >= s2
        ret := "Bear"
    ret

colorWithTransparency (colorF, transparencyX) =>
    color.new(colorF, color.t(colorF) * transparencyX)

createOBBox (boxColor, transparencyX = 1.0, xlocType = xloc.bar_time) =>
    box.new(na, na, na, na, text_size = size.normal, xloc = xlocType, extend = extend.none, bgcolor = colorWithTransparency(boxColor, transparencyX), text_color = textColor, text_halign = text.align_center, border_color = #00000000)

renderOrderBlock (orderBlock ob) =>
    orderBlockInfo info = ob.info
    ob.isRendered := true
    orderColor = ob.info.obType == "Bull" ? bullOrderBlockColor : bearOrderBlockColor

    if OBsEnabled and (not false or not (false and info.breaker)) and not (not showInvalidated and info.breaker)
        ob.orderBox := createOBBox(orderColor, 1.5)
        if ob.info.combined
            ob.orderBox.set_bgcolor(colorWithTransparency(orderColor, 1.1))
        ob.orderBoxText := createOBBox(color.new(color.white, 100))
        if orderBlockVolumetricInfo
            ob.orderBoxPositive := createOBBox(bullOrderBlockColor)
            ob.orderBoxNegative := createOBBox(bearOrderBlockColor)
            ob.orderSeperator := line.new(na,na,na,na,xloc.bar_time,extend.none,textColor,line.style_dashed,1)
            ob.orderTextSeperator := line.new(na,na,na,na,xloc.bar_time,extend.none,textColor,line.style_solid,1)

        zoneSize = extendZonesDynamic ? na(info.breakTime) ? extendZonesByTime : (info.breakTime - info.startTime) : extendZonesByTime
        if na(info.breakTime)
            zoneSize := (time + 1) - info.startTime

        startX = volumeBarsLeftSide ? info.startTime : info.startTime + zoneSize - zoneSize / 3
        maxEndX = volumeBarsLeftSide ? info.startTime + zoneSize / 3 : info.startTime + zoneSize

        moveBox(ob.orderBox, info.startTime, info.top, info.startTime + zoneSize, info.bottom)
        moveBox(ob.orderBoxText, volumeBarsLeftSide ? maxEndX : info.startTime, info.top, volumeBarsLeftSide ? info.startTime + zoneSize : startX, info.bottom)

        percentage = int((math.min(info.obHighVolume, info.obLowVolume) / math.max(info.obHighVolume, info.obLowVolume)) * 100.0)
        OBText = (na(ob.info.combinedTimeframesStr) ? formatTimeframeString(ob.info.timeframeStr) : ob.info.combinedTimeframesStr) + " OB"
        box.set_text(ob.orderBoxText, (orderBlockVolumetricInfo ? str.tostring(ob.info.obVolume, format.volume) + " (" + str.tostring(percentage) + "%)\n" : "") + (combinedText and ob.info.combined ? "[Combined]\n" : "") + OBText)

        if orderBlockVolumetricInfo
            showHighLowBoxText = false

            curEndXHigh = int(math.ceil((info.obHighVolume / info.obVolume) * (maxEndX - startX) + startX))
            curEndXLow = int(math.ceil((info.obLowVolume / info.obVolume) * (maxEndX - startX) + startX))

            moveBox(ob.orderBoxPositive, mirrorVolumeBars ? startX : curEndXLow, info.top, mirrorVolumeBars ? curEndXHigh : maxEndX, (info.bottom + info.top) / 2)
            box.set_text(ob.orderBoxPositive, showHighLowBoxText ? str.tostring(info.obHighVolume, format.volume) : "")

            moveBox(ob.orderBoxNegative, mirrorVolumeBars ? startX : curEndXHigh, info.bottom, mirrorVolumeBars ? curEndXLow : maxEndX, (info.bottom + info.top) / 2)
            box.set_text(ob.orderBoxNegative, showHighLowBoxText ? str.tostring(info.obLowVolume, format.volume) : "")

            moveLine(ob.orderSeperator, volumeBarsLeftSide ? startX : maxEndX, (info.bottom + info.top) / 2, volumeBarsLeftSide ? maxEndX : startX)

            line.set_xy1(ob.orderTextSeperator, volumeBarsLeftSide ? maxEndX : startX, info.top)
            line.set_xy2(ob.orderTextSeperator, volumeBarsLeftSide ? maxEndX : startX, info.bottom)

findOBSwings(len) =>
    var swingType = 0
    var obSwing top = obSwing.new(na, na)
    var obSwing bottom = obSwing.new(na, na)

    upper = ta.highest(len)
    lower = ta.lowest(len)

    swingType := high[len] > upper ? 0 : low[len] < lower ? 1 : swingType

    if swingType == 0 and swingType[1] != 0
        top := obSwing.new(bar_index[len], high[len], volume[len])

    if swingType == 1 and swingType[1] != 1
        bottom := obSwing.new(bar_index[len], low[len], volume[len])

    [top, bottom]

findOrderBlocks () =>
    if bar_index > last_bar_index - maxDistanceToLastBar
        [top, btm] = findOBSwings(swingLength)
        useBody = false
        max = useBody ? math.max(close, open) : high
        min = useBody ? math.min(close, open) : low

        // Bullish Order Block
        bullishBreaked = 0

        if bullishOrderBlocksList.size() > 0
            for i = bullishOrderBlocksList.size() - 1 to 0
                currentOB = bullishOrderBlocksList.get(i)

                if not currentOB.breaker
                    if (obEndMethod == "Wick" ? low : math.min(open, close)) < currentOB.bottom
                        currentOB.breaker := true
                        currentOB.breakTime := time
                        currentOB.bbVolume := volume
                else
                    if high > currentOB.top
                        bullishOrderBlocksList.remove(i)
                    else if i < bullishOrderBlocks and top.y < currentOB.top and top.y > currentOB.bottom
                        bullishBreaked := 1

        if close > top.y and not top.crossed
            top.crossed := true

            boxBtm = max[1]
            boxTop = min[1]
            boxLoc = time[1]

            for i = 1 to (bar_index - top.x) - 1
                boxBtm := math.min(min[i], boxBtm)
                boxTop := boxBtm == min[i] ? max[i] : boxTop
                boxLoc := boxBtm == min[i] ? time[i] : boxLoc

            newOrderBlockInfo = orderBlockInfo.new(boxTop, boxBtm, volume + volume[1] + volume[2], "Bull", boxLoc)
            newOrderBlockInfo.obLowVolume := volume[2]
            newOrderBlockInfo.obHighVolume := volume + volume[1]

            obSize = math.abs(newOrderBlockInfo.top - newOrderBlockInfo.bottom)
            if obSize <= atrOB * maxATRMult
                bullishOrderBlocksList.unshift(newOrderBlockInfo)
                if bullishOrderBlocksList.size() > maxOrderBlocks
                    bullishOrderBlocksList.pop()

        // Bearish Order Block

        bearishBreaked = 0

        if bearishOrderBlocksList.size() > 0
            for i = bearishOrderBlocksList.size() - 1 to 0
                currentOB = bearishOrderBlocksList.get(i)

                if not currentOB.breaker
                    if (obEndMethod == "Wick" ? high : math.max(open, close)) > currentOB.top
                        currentOB.breaker := true
                        currentOB.breakTime := time
                        currentOB.bbVolume := volume
                else
                    if low < currentOB.bottom
                        bearishOrderBlocksList.remove(i)
                    else if i < bearishOrderBlocks and btm.y > currentOB.bottom and btm.y < currentOB.top
                        bearishBreaked := 1

        if close < btm.y and not btm.crossed
            btm.crossed := true

            boxBtm = min[1]
            boxTop = max[1]
            boxLoc = time[1]

            for i = 1 to (bar_index - btm.x) - 1
                boxTop := math.max(max[i], boxTop)
                boxBtm := boxTop == max[i] ? min[i] : boxBtm
                boxLoc := boxTop == max[i] ? time[i] : boxLoc

            newOrderBlockInfo = orderBlockInfo.new(boxTop, boxBtm, volume + volume[1] + volume[2], "Bear", boxLoc)
            newOrderBlockInfo.obLowVolume := volume + volume[1]
            newOrderBlockInfo.obHighVolume := volume[2]

            obSize = math.abs(newOrderBlockInfo.top - newOrderBlockInfo.bottom)
            if obSize <= atrOB * maxATRMult
                bearishOrderBlocksList.unshift(newOrderBlockInfo)
                if bearishOrderBlocksList.size() > maxOrderBlocks
                    bearishOrderBlocksList.pop()
    true

areaOfOB (orderBlockInfo OBInfoF) =>
    float XA1 = OBInfoF.startTime
    float XA2 = na(OBInfoF.breakTime) ? time + 1 : OBInfoF.breakTime
    float YA1 = OBInfoF.top
    float YA2 = OBInfoF.bottom
    float edge1 = math.sqrt((XA2 - XA1) * (XA2 - XA1) + (YA2 - YA2) * (YA2 - YA2))
    float edge2 = math.sqrt((XA2 - XA2) * (XA2 - XA2) + (YA2 - YA1) * (YA2 - YA1))
    float totalArea = edge1 * edge2
    totalArea

doOBsTouch (orderBlockInfo OBInfo1, orderBlockInfo OBInfo2) =>
    float XA1 = OBInfo1.startTime
    float XA2 = na(OBInfo1.breakTime) ? time + 1 : OBInfo1.breakTime
    float YA1 = OBInfo1.top
    float YA2 = OBInfo1.bottom

    float XB1 = OBInfo2.startTime
    float XB2 = na(OBInfo2.breakTime) ? time + 1 : OBInfo2.breakTime
    float YB1 = OBInfo2.top
    float YB2 = OBInfo2.bottom
    float intersectionArea = math.max(0, math.min(XA2, XB2) - math.max(XA1, XB1)) * math.max(0, math.min(YA1, YB1) - math.max(YA2, YB2))
    float unionArea = areaOfOB(OBInfo1) + areaOfOB(OBInfo2) - intersectionArea

    float overlapPercentage = (intersectionArea / unionArea) * 100.0

    if overlapPercentage > overlapThresholdPercentage
        true
    else
        false

isOBValid (orderBlockInfo OBInfo) =>
    valid = true
    if OBInfo.disabled
        valid := false
    valid

combineOBsFunc () =>
    if allOrderBlocksList.size() > 0
        lastCombinations = 999
        while lastCombinations > 0
            lastCombinations := 0
            for i = 0 to allOrderBlocksList.size() - 1
                curOB1 = allOrderBlocksList.get(i)
                for j = 0 to allOrderBlocksList.size() - 1
                    curOB2 = allOrderBlocksList.get(j)
                    if i == j
                        continue
                    if not isOBValid(curOB1.info) or not isOBValid(curOB2.info)
                        continue
                    if curOB1.info.obType != curOB2.info.obType
                        continue
                    if doOBsTouch(curOB1.info, curOB2.info)
                        curOB1.info.disabled := true
                        curOB2.info.disabled := true
                        orderBlock newOB = createOrderBlock(orderBlockInfo.new(math.max(curOB1.info.top, curOB2.info.top), math.min(curOB1.info.bottom, curOB2.info.bottom), curOB1.info.obVolume + curOB2.info.obVolume, curOB1.info.obType))
                        newOB.info.startTime := math.min(curOB1.info.startTime, curOB2.info.startTime)
                        newOB.info.breakTime := math.max(nz(curOB1.info.breakTime), nz(curOB2.info.breakTime))
                        newOB.info.breakTime := newOB.info.breakTime == 0 ? na : newOB.info.breakTime
                        newOB.info.timeframeStr := curOB1.info.timeframeStr

                        newOB.info.obVolume := curOB1.info.obVolume + curOB2.info.obVolume
                        newOB.info.obLowVolume := curOB1.info.obLowVolume + curOB2.info.obLowVolume
                        newOB.info.obHighVolume := curOB1.info.obHighVolume + curOB2.info.obHighVolume
                        newOB.info.bbVolume := nz(curOB1.info.bbVolume, 0) + nz(curOB2.info.bbVolume, 0)
                        newOB.info.breaker := curOB1.info.breaker or curOB2.info.breaker

                        newOB.info.combined := true
                        if timeframe.in_seconds(curOB1.info.timeframeStr) != timeframe.in_seconds(curOB2.info.timeframeStr)
                            newOB.info.combinedTimeframesStr := (na(curOB1.info.combinedTimeframesStr) ? formatTimeframeString(curOB1.info.timeframeStr) : curOB1.info.combinedTimeframesStr) + " & " + (na(curOB2.info.combinedTimeframesStr) ? formatTimeframeString(curOB2.info.timeframeStr) : curOB2.info.combinedTimeframesStr)
                        allOrderBlocksList.unshift(newOB)
                        lastCombinations += 1


reqSeq (timeframeStr) =>
    [bullishOrderBlocksListF, bearishOrderBlocksListF] = request.security(syminfo.tickerid, timeframeStr, [bullishOrderBlocksList, bearishOrderBlocksList])
    [bullishOrderBlocksListF, bearishOrderBlocksListF]

getTFData (timeframeInfo timeframeInfoF, timeframeStr) =>
    if not isTimeframeLower(timeframeInfoF.timeframeStr, timeframe.period) and timeframeInfoF.isEnabled
        [bullishOrderBlocksListF, bearishOrderBlocksListF] = reqSeq(timeframeStr)
        [bullishOrderBlocksListF, bearishOrderBlocksListF]
    else
        [na, na]

handleTimeframeInfo (timeframeInfo timeframeInfoF, bullishOrderBlocksListF, bearishOrderBlocksListF) =>
    if not isTimeframeLower(timeframeInfoF.timeframeStr, timeframe.period) and timeframeInfoF.isEnabled
        timeframeInfoF.bullishOrderBlocksList := bullishOrderBlocksListF
        timeframeInfoF.bearishOrderBlocksList := bearishOrderBlocksListF


handleOrderBlocksFinal () =>
    if DEBUG
        log.info("Bullish OB Count " + str.tostring(bullishOrderBlocksList.size()))
        log.info("Bearish OB Count " + str.tostring(bearishOrderBlocksList.size()))

    if allOrderBlocksList.size () > 0
        for i = 0 to allOrderBlocksList.size() - 1
            safeDeleteOrderBlock(allOrderBlocksList.get(i))
    allOrderBlocksList.clear()

    for i = 0 to timeframeInfos.size() - 1
        curTimeframe = timeframeInfos.get(i)
        if not curTimeframe.isEnabled
            continue
        if curTimeframe.bullishOrderBlocksList.size() > 0
            for j = 0 to math.min(curTimeframe.bullishOrderBlocksList.size() - 1, bullishOrderBlocks - 1)
                orderBlockInfoF = curTimeframe.bullishOrderBlocksList.get(j)
                orderBlockInfoF.timeframeStr := curTimeframe.timeframeStr
                allOrderBlocksList.unshift(createOrderBlock(orderBlockInfo.copy(orderBlockInfoF)))

        if curTimeframe.bearishOrderBlocksList.size() > 0
            for j = 0 to math.min(curTimeframe.bearishOrderBlocksList.size() - 1, bearishOrderBlocks - 1)
                orderBlockInfoF = curTimeframe.bearishOrderBlocksList.get(j)
                orderBlockInfoF.timeframeStr := curTimeframe.timeframeStr
                allOrderBlocksList.unshift(createOrderBlock(orderBlockInfo.copy(orderBlockInfoF)))

    if combineOBs
        combineOBsFunc()

    if allOrderBlocksList.size() > 0
        for i = 0 to allOrderBlocksList.size() - 1
            curOB = allOrderBlocksList.get(i)
            if isOBValid(curOB.info)
                renderOrderBlock(curOB)

//
// ===================== CONFLUENCE — HELPERS (new) =====================
//
f_priceInBullOB(price) =>
    bool hit = false
    if bullishOrderBlocksList.size() > 0
        for i = 0 to bullishOrderBlocksList.size() - 1
            ob = bullishOrderBlocksList.get(i)
            if price <= ob.top and price >= ob.bottom
                hit := true
                break
    hit

f_priceInBearOB(price) =>
    bool hit = false
    if bearishOrderBlocksList.size() > 0
        for i = 0 to bearishOrderBlocksList.size() - 1
            ob = bearishOrderBlocksList.get(i)
            if price <= ob.top and price >= ob.bottom
                hit := true
                break
    hit

f_priceInBoxArray(price, box_array) =>
    bool hit = false
    if array.size(box_array) > 0
        for i = 0 to array.size(box_array) - 1
            b = array.get(box_array, i)
            if not na(b)
                if price <= box.get_top(b) and price >= box.get_bottom(b)
                    hit := true
                    break
    hit

// Zone description for the memory table (which OB/zone the signal tapped)
f_zoneStrBull(price) =>
    string s = "Demand"
    if bullishOrderBlocksList.size() > 0
        for i = 0 to bullishOrderBlocksList.size() - 1
            ob = bullishOrderBlocksList.get(i)
            if price <= ob.top and price >= ob.bottom
                s := "Bull OB " + str.tostring(ob.top, format.mintick) + "-" + str.tostring(ob.bottom, format.mintick)
                break
    s

f_zoneStrBear(price) =>
    string s = "Supply"
    if bearishOrderBlocksList.size() > 0
        for i = 0 to bearishOrderBlocksList.size() - 1
            ob = bearishOrderBlocksList.get(i)
            if price <= ob.top and price >= ob.bottom
                s := "Bear OB " + str.tostring(ob.top, format.mintick) + "-" + str.tostring(ob.bottom, format.mintick)
                break
    s

// ----- Last-5 signal memory (rolling) -----
var sig_time   = array.new_string(5, "")
var sig_side   = array.new_string(5, "")
var sig_price  = array.new_string(5, "")
var sig_zone   = array.new_string(5, "")
var sig_struct = array.new_string(5, "")
var sig_bias   = array.new_string(5, "")

f_pushSig(t, side, pr, zone, st, bs) =>
    array.unshift(sig_time, t)
    array.pop(sig_time)
    array.unshift(sig_side, side)
    array.pop(sig_side)
    array.unshift(sig_price, pr)
    array.pop(sig_price)
    array.unshift(sig_zone, zone)
    array.pop(sig_zone)
    array.unshift(sig_struct, st)
    array.pop(sig_struct)
    array.unshift(sig_bias, bs)
    array.pop(sig_bias)

//
// ===================== SMC LITE — CALCULATIONS (verbatim, with layer gating) =====================
//
atr = ta.atr(50)

swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low = ta.pivotlow(low, swing_length, swing_length)

var swing_high_values = array.new_float(5,0.00)
var swing_low_values = array.new_float(5,0.00)

var swing_high_bns = array.new_int(5,0)
var swing_low_bns = array.new_int(5,0)

var current_supply_box = array.new_box(history_of_demand_to_keep, na)
var current_demand_box = array.new_box(history_of_demand_to_keep, na)

var current_supply_poi = array.new_box(history_of_demand_to_keep, na)
var current_demand_poi = array.new_box(history_of_demand_to_keep, na)

var supply_bos = array.new_box(5, na)
var demand_bos = array.new_box(5, na)

newSwingHigh = not na(swing_high)
newSwingLow  = not na(swing_low)

if newSwingHigh
    f_array_add_pop(swing_high_values, swing_high)
    f_array_add_pop(swing_high_bns, bar_index[swing_length])
    if show_price_action_labels and not signals_only
        f_sh_sl_labels(swing_high_values, 1)
    if show_smc and not signals_only
        f_supply_demand(swing_high_values, swing_high_bns, current_supply_box, current_supply_poi, 1, atr)
    if show_structure and not signals_only
        hi_txt = swing_high_values.get(0) >= swing_high_values.get(1) ? "HH" : "LH"
        label.new(bar_index - swing_length, swing_high, text = hi_txt, style = label.style_label_down, color = hi_txt == "HH" ? hh_color : lh_color, textcolor = color.white, size = size.small)
else if newSwingLow
    f_array_add_pop(swing_low_values, swing_low)
    f_array_add_pop(swing_low_bns, bar_index[swing_length])
    if show_price_action_labels and not signals_only
        f_sh_sl_labels(swing_low_values, -1)
    if show_smc and not signals_only
        f_supply_demand(swing_low_values, swing_low_bns, current_demand_box, current_demand_poi, -1, atr)
    if show_structure and not signals_only
        lo_txt = swing_low_values.get(0) >= swing_low_values.get(1) ? "HL" : "LL"
        label.new(bar_index - swing_length, swing_low, text = lo_txt, style = label.style_label_up, color = lo_txt == "HL" ? hl_color : ll_color, textcolor = color.white, size = size.small)

if show_smc and not signals_only
    f_sd_to_bos(current_supply_box, supply_bos, current_supply_poi, 1)
    f_sd_to_bos(current_demand_box, demand_bos, current_demand_poi, -1)
    f_extend_box_endpoint(current_supply_box)
    f_extend_box_endpoint(current_demand_box)

//ZIG ZAG (verbatim)
h = ta.highest(high, swing_length * 2 + 1)
l = ta.lowest(low, swing_length * 2 + 1)
f_isMin(len) =>
    l == low[len]
f_isMax(len) =>
    h == high[len]

var dirUp = false
var lastLow = high * 100
var lastHigh = 0.0
var timeLow = bar_index
var timeHigh = bar_index
var line li = na

f_drawLine() =>
    _li_color = show_zigzag and not signals_only ? zigzag_color : color.new(#ffffff,100)
    line.new(timeHigh - swing_length, lastHigh, timeLow - swing_length, lastLow, xloc.bar_index, color=_li_color, width=2)

if dirUp
    if f_isMin(swing_length) and low[swing_length] < lastLow
        lastLow := low[swing_length]
        timeLow := bar_index
        line.delete(li)
        li := f_drawLine()
        li
    if f_isMax(swing_length) and high[swing_length] > lastLow
        lastHigh := high[swing_length]
        timeHigh := bar_index
        dirUp := false
        li := f_drawLine()
        li

if not dirUp
    if f_isMax(swing_length) and high[swing_length] > lastHigh
        lastHigh := high[swing_length]
        timeHigh := bar_index
        line.delete(li)
        li := f_drawLine()
        li
    if f_isMin(swing_length) and low[swing_length] < lastHigh
        lastLow := low[swing_length]
        timeLow := bar_index
        dirUp := true
        li := f_drawLine()
        if f_isMax(swing_length) and high[swing_length] > lastLow
            lastHigh := high[swing_length]
            timeHigh := bar_index
            dirUp := false
            li := f_drawLine()
            li

//
// ===================== ORDER BLOCKS — CALCULATIONS (verbatim, render gated) =====================
//
findOrderBlocks()

[bullishOrderBlocksListTimeframe1, bearishOrderBlocksListTimeframe1] = getTFData(timeframeInfos.get(0), timeframe1)

if barstate.isconfirmed
    handleTimeframeInfo(timeframeInfos.get(0), bullishOrderBlocksListTimeframe1, bearishOrderBlocksListTimeframe1)
    if show_ob and not signals_only
        handleOrderBlocksFinal()

//
// ===================== CONFLUENCE — BIAS + SIGNALS (new) =====================
//
var float lastSH = na
var float lastSL = na
var int bias = 0

bullBOS = not na(lastSH) and close > lastSH and close[1] <= lastSH
bearBOS = not na(lastSL) and close < lastSL and close[1] >= lastSL
if bullBOS
    bias := 1
if bearBOS
    bias := -1
if newSwingHigh
    lastSH := swing_high
if newSwingLow
    lastSL := swing_low

zoneOKbuy  = newSwingLow  and (f_priceInBullOB(swing_low)  or f_priceInBoxArray(swing_low,  current_demand_box))
zoneOKsell = newSwingHigh and (f_priceInBearOB(swing_high) or f_priceInBoxArray(swing_high, current_supply_box))

isHL = newSwingLow  and swing_low_values.get(0)  >= swing_low_values.get(1)
isLH = newSwingHigh and swing_high_values.get(0) <  swing_high_values.get(1)

buySignal  = isHL and zoneOKbuy  and (not require_bos or bias ==  1)
sellSignal = isLH and zoneOKsell and (not require_bos or bias == -1)

if show_signals and buySignal
    label.new(bar_index - swing_length, swing_low,  text = "BUY",  style = label.style_label_up,   color = buy_color,  textcolor = color.white, size = size.normal)
if show_signals and sellSignal
    label.new(bar_index - swing_length, swing_high, text = "SELL", style = label.style_label_down, color = sell_color, textcolor = color.white, size = size.normal)

// ----- Record signals into Last-5 memory (most recent first) -----
biasStr = bias == 1 ? "Bull BOS" : bias == -1 ? "Bear BOS" : "-"
if buySignal
    f_pushSig(str.format_time(time[swing_length], "MM-dd HH:mm", syminfo.timezone), "BUY", str.tostring(swing_low, format.mintick), f_zoneStrBull(swing_low), "HL", biasStr)
if sellSignal
    f_pushSig(str.format_time(time[swing_length], "MM-dd HH:mm", syminfo.timezone), "SELL", str.tostring(swing_high, format.mintick), f_zoneStrBear(swing_high), "LH", biasStr)

// ----- Render Last-5 memory table (what JARVIS reads) -----
table_pos = table_pos_in == "Top Right" ? position.top_right : table_pos_in == "Top Left" ? position.top_left : table_pos_in == "Bottom Right" ? position.bottom_right : position.bottom_left
var table jt = na
if barstate.islast
    if not na(jt)
        table.delete(jt)
        jt := na
    if show_table
        jt := table.new(table_pos, 6, 6, border_width = 1, frame_color = color.new(color.gray, 40), frame_width = 1)
        hdr_bg = color.new(#1b1b1b, 0)
        table.cell(jt, 0, 0, "Time",   text_color = color.white, bgcolor = hdr_bg, text_size = size.small)
        table.cell(jt, 1, 0, "Side",   text_color = color.white, bgcolor = hdr_bg, text_size = size.small)
        table.cell(jt, 2, 0, "Price",  text_color = color.white, bgcolor = hdr_bg, text_size = size.small)
        table.cell(jt, 3, 0, "Zone",   text_color = color.white, bgcolor = hdr_bg, text_size = size.small)
        table.cell(jt, 4, 0, "Struct", text_color = color.white, bgcolor = hdr_bg, text_size = size.small)
        table.cell(jt, 5, 0, "Bias",   text_color = color.white, bgcolor = hdr_bg, text_size = size.small)
        for r = 0 to 4
            sside = array.get(sig_side, r)
            side_bg = sside == "BUY" ? color.new(#089981, 0) : sside == "SELL" ? color.new(#f23645, 0) : color.new(color.gray, 60)
            row_bg = color.new(#0e0e0e, 0)
            table.cell(jt, 0, r + 1, array.get(sig_time, r),   text_color = color.white, bgcolor = row_bg, text_size = size.small)
            table.cell(jt, 1, r + 1, sside,                    text_color = color.white, bgcolor = side_bg, text_size = size.small)
            table.cell(jt, 2, r + 1, array.get(sig_price, r),  text_color = color.white, bgcolor = row_bg, text_size = size.small)
            table.cell(jt, 3, r + 1, array.get(sig_zone, r),   text_color = color.white, bgcolor = row_bg, text_size = size.small)
            table.cell(jt, 4, r + 1, array.get(sig_struct, r), text_color = color.white, bgcolor = row_bg, text_size = size.small)
            table.cell(jt, 5, r + 1, array.get(sig_bias, r),   text_color = color.white, bgcolor = row_bg, text_size = size.small)
````
