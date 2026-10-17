# TASET

- url: https://www.tradingview.com/script/7GGNEPIb-TASET/
- type: indicator
- pine_id: PUB;1d625b5d1b274af7b5870c2a80d7120c
- version: 1.0

## Description

Break of Structure (BOS)
Order Blocks (OB)
Liquidity Zones
Fair Value Gaps (FVG)

## Source Code

````pine
//@version=5
indicator("NAK + ELFNaAan pro vip v 2", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

// ======================================================================
// PART 0: Nasser Al-Kalbani - S/R + Signal Strategy
// ======================================================================

// ─── INPUTS ───────────────────────────────────────────────────────────────────
left        = input.int(50,  "Left Bars",    minval=1)
right       = input.int(25,  "Right Bars",   minval=1)
quick_right = input.int(5,   "Quick Right",  minval=1)
src_type    = input.string("Close", "Source", options=["Close","High/Low"])

rsi_len     = input.int(14,   "RSI Length",        minval=1)
rsi_ob      = input.float(70, "RSI Overbought",    minval=50, maxval=100)
rsi_os      = input.float(30, "RSI Oversold",      minval=0,  maxval=50)
rsi_near_ob = input.float(60, "RSI Near OB (min)", minval=50, maxval=70)
space_pct   = input.float(0.3,"Min S/R Space %",   minval=0.05, step=0.05)

// ─── S/R LEVELS ───────────────────────────────────────────────────────────────
src_high = src_type == "Close" ? close : high
src_low  = src_type == "Close" ? close : low

ph  = ta.pivothigh(src_high, left, right)
pl  = ta.pivotlow (src_low,  left, right)
qph = ta.pivothigh(src_high, left, quick_right)
qpl = ta.pivotlow (src_low,  left, quick_right)

level1 = ta.valuewhen(qph, src_high[quick_right], 0)
level2 = ta.valuewhen(qpl, src_low [quick_right], 0)
level3 = ta.valuewhen(ph,  src_high[right], 0)
level4 = ta.valuewhen(pl,  src_low [right], 0)
level5 = ta.valuewhen(ph,  src_high[right], 1)
level6 = ta.valuewhen(pl,  src_low [right], 1)
level7 = ta.valuewhen(ph,  src_high[right], 2)
level8 = ta.valuewhen(pl,  src_low [right], 2)

c(l) => close >= l ? color.green : color.red

plot(level1, "QR High", color=c(level1), style=plot.style_line, linewidth=1, show_last=1, trackprice=true)
plot(level2, "QR Low",  color=c(level2), style=plot.style_line, linewidth=1, show_last=1, trackprice=true)
plot(level3, "R1",      color=c(level3), style=plot.style_line, linewidth=2, show_last=1, trackprice=true)
plot(level4, "S1",      color=c(level4), style=plot.style_line, linewidth=2, show_last=1, trackprice=true)
plot(level5, "R2",      color=c(level5), style=plot.style_line, linewidth=1, show_last=1, trackprice=true)
plot(level6, "S2",      color=c(level6), style=plot.style_line, linewidth=1, show_last=1, trackprice=true)
plot(level7, "R3",      color=c(level7), style=plot.style_line, linewidth=1, show_last=1, trackprice=true)
plot(level8, "S3",      color=c(level8), style=plot.style_line, linewidth=1, show_last=1, trackprice=true)

// ─── RSI ──────────────────────────────────────────────────────────────────────
rsi = ta.rsi(close, rsi_len)

// ─── DIVERGENCE ───────────────────────────────────────────────────────────────
ph_div = ta.pivothigh(high, 5, 5)
pl_div = ta.pivotlow (low,  5, 5)
ph_rsi = ta.pivothigh(rsi,  5, 5)
pl_rsi = ta.pivotlow (rsi,  5, 5)

price_top1 = ta.valuewhen(ph_div, high[5], 0)
price_top2 = ta.valuewhen(ph_div, high[5], 1)
rsi_top1   = ta.valuewhen(ph_rsi, rsi[5],  0)
rsi_top2   = ta.valuewhen(ph_rsi, rsi[5],  1)

price_bot1 = ta.valuewhen(pl_div, low[5],  0)
price_bot2 = ta.valuewhen(pl_div, low[5],  1)
rsi_bot1   = ta.valuewhen(pl_rsi, rsi[5],  0)
rsi_bot2   = ta.valuewhen(pl_rsi, rsi[5],  1)

bear_div = ph_div and (price_top1 > price_top2) and (rsi_top1 < rsi_top2)
bull_div = pl_div and (price_bot1 < price_bot2) and (rsi_bot1 > rsi_bot2)

// ─── خط الدايفرجنس ────────────────────────────────────────────────────────────
if bear_div
    line.new(bar_index - 5, price_top2, bar_index, price_top1, color=color.new(color.orange, 0), width=1, style=line.style_dashed)

if bull_div
    line.new(bar_index - 5, price_bot2, bar_index, price_bot1, color=color.new(color.aqua, 0), width=1, style=line.style_dashed)

// ─── NEAR S/R ─────────────────────────────────────────────────────────────────
near(lvl) => math.abs(close - lvl) / lvl * 100 < space_pct

nearResistance = near(level1) or near(level3) or near(level5) or near(level7)
nearSupport    = near(level2) or near(level4) or near(level6) or near(level8)

// ─── SPACE ────────────────────────────────────────────────────────────────────
res_level = level3
sup_level = level4
space_ok  = res_level > sup_level and (res_level - sup_level) / sup_level * 100 > space_pct

// ─── TAIL BREAK ───────────────────────────────────────────────────────────────
tail_break_res = high > res_level and close < res_level
tail_break_sup = low  < sup_level and close > sup_level

// ─── RAW SIGNALS ──────────────────────────────────────────────────────────────
raw_sell = (tail_break_res or nearResistance) and space_ok and (rsi >= rsi_near_ob or bear_div) and (rsi >= rsi_near_ob and rsi < rsi[1])
raw_buy  = (tail_break_sup or nearSupport)    and space_ok and (rsi <= rsi_os or bull_div)       and (rsi <= rsi_os and rsi > rsi[1])

// ─── منع التكرار ──────────────────────────────────────────────────────────────
var bool prev_sell = false
var bool prev_buy  = false

sell_signal = raw_sell and not prev_sell
buy_signal  = raw_buy  and not prev_buy

prev_sell := raw_sell
prev_buy  := raw_buy

// ─── PLOT SIGNALS ─────────────────────────────────────────────────────────────
plotshape(buy_signal, "BUY",   shape.triangleup, location.belowbar, color=color.new(color.green, 0), size=size.tiny)
plotshape(buy_signal, "BUY_N", shape.labeldown,  location.belowbar, color=color.new(color.green, 100), textcolor=color.new(color.green, 0), text="N", size=size.tiny)

plotshape(sell_signal, "SELL",   shape.triangledown, location.abovebar, color=color.new(color.red, 0), size=size.tiny)
plotshape(sell_signal, "SELL_N", shape.labelup,      location.abovebar, color=color.new(color.red, 100), textcolor=color.new(color.red, 0), text="N", size=size.tiny)

// ─── DIVERGENCE MARKERS ───────────────────────────────────────────────────────
plotshape(bear_div and not sell_signal, "Bear Div", shape.triangledown, location.abovebar, color=color.new(color.orange, 40), size=size.tiny, text="n")
plotshape(bull_div and not buy_signal,  "Bull Div", shape.triangleup,   location.belowbar, color=color.new(color.aqua, 40),   size=size.tiny, text="n")

// ─── RSI TABLE ────────────────────────────────────────────────────────────────
var table info = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 70), border_width=1)

if barstate.islast
    table.cell(info, 0, 0, "RSI",      text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, str.tostring(math.round(rsi, 1)), text_color=rsi >= rsi_ob ? color.red : rsi <= rsi_os ? color.lime : color.white, text_size=size.small)
    table.cell(info, 0, 1, "Bear Div", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, bear_div ? "✓" : "–", text_color=bear_div ? color.orange : color.gray, text_size=size.small)
    table.cell(info, 0, 2, "Bull Div", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, bull_div ? "✓" : "–", text_color=bull_div ? color.aqua : color.gray, text_size=size.small)
    table.cell(info, 0, 3, "Space OK", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 3, space_ok ? "✓" : "–", text_color=space_ok ? color.lime : color.gray, text_size=size.small)

// ─── WATERMARK ────────────────────────────────────────────────────────────────
var table wm = table.new(position.bottom_center, 1, 1, bgcolor=color.new(color.black, 100))

if barstate.islast
    table.cell(wm, 0, 0, "Nasser Al-Kalbani", text_color=color.new(color.gray, 60), text_size=size.tiny)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(sell_signal, "SELL Signal - NAK", "🔴 SELL Signal")
alertcondition(buy_signal,  "BUY Signal - NAK",  "🟢 BUY Signal")

// ======================================================================
// PART 1: ELFNaAaN Order Blocks & FVG Indicator (Original Code)
// ======================================================================

//---------------------------------------------------------------------------------------------------------------------
// CONSTANTS
//---------------------------------------------------------------------------------------------------------------------
BULLISH = +1
BEARISH = -1
MONO_BULLISH = #b2b5be
MONO_BEARISH = #5d606b
ATR = 'Atr'
RANGE = 'Cumulative Mean Range'
CLOSE = 'Close'
HIGHLOW = 'High/Low'
COLORED = 'Colored'
MONOCHROME = 'Monochrome'
BLOCKS_GROUP = 'Order Blocks'
var int SWING_LENGTH_DEFAULT = 50

//---------------------------------------------------------------------------------------------------------------------
// INPUTS - Order Blocks
//---------------------------------------------------------------------------------------------------------------------
styleInput = COLORED // ثابت

// ✅ إخفاء Order Blocks
showInternalOrderBlocksInput = true
internalOrderBlocksSizeInput = 10

showSwingOrderBlocksInput = true
swingOrderBlocksSizeInput = 10

orderBlockFilterInput = ATR // ثابت
orderBlockMitigationInput = HIGHLOW // ثابت

// ✅ Internal Bullish OB
showInternalBullishOb = true
internalBullishOrderBlockColor = color.new(#3179f5, 80)

// ✅ Internal Bearish OB
showInternalBearishOb = true
internalBearishOrderBlockColor = color.new(#f77c80, 80)

// ✅ Bullish OB
showBullishOb = true
swingBullishOrderBlockColor = color.new(#1848cc, 80)

// ✅ Bearish OB
showBearishOb = true
swingBearishOrderBlockColor = color.new(#b22833, 80)

//---------------------------------------------------------------------------------------------------------------------
// TYPES
//---------------------------------------------------------------------------------------------------------------------
type alerts
    bool internalBullishOrderBlock = false
    bool internalBearishOrderBlock = false
    bool swingBullishOrderBlock = false
    bool swingBearishOrderBlock = false

type pivot
    float currentLevel
    float lastLevel
    bool crossed
    int barTime = time
    int barIndex = bar_index

type orderBlock
    float barHigh
    float barLow
    int barTime
    int bias

//---------------------------------------------------------------------------------------------------------------------
// VARIABLES - Order Blocks
//---------------------------------------------------------------------------------------------------------------------
var pivot swingHigh = pivot.new(na, na, false)
var pivot swingLow = pivot.new(na, na, false)
var pivot internalHigh = pivot.new(na, na, false)
var pivot internalLow = pivot.new(na, na, false)

var array<orderBlock> swingOrderBlocks = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks = array.new<orderBlock>()
var array<box> swingOrderBlocksBoxes = array.new<box>()
var array<box> internalOrderBlocksBoxes = array.new<box>()

// 🟢 إضافات لإظهار كلمة OB
var array<label> swingOrderBlocksLabels = array.new<label>()
var array<label> internalOrderBlocksLabels = array.new<label>()

var swingBullColor = styleInput == MONOCHROME ? MONO_BULLISH : swingBullishOrderBlockColor
var swingBearColor = styleInput == MONOCHROME ? MONO_BEARISH : swingBearishOrderBlockColor
var internalBullColor = styleInput == MONOCHROME ? MONO_BULLISH : internalBullishOrderBlockColor
var internalBearColor = styleInput == MONOCHROME ? MONO_BEARISH : internalBearishOrderBlockColor

if barstate.isfirst
    if showSwingOrderBlocksInput
        for _ = 1 to swingOrderBlocksSizeInput
            swingOrderBlocksBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right))
            swingOrderBlocksLabels.push(label.new(na, na, "", xloc = xloc.bar_time))
    if showInternalOrderBlocksInput
        for _ = 1 to internalOrderBlocksSizeInput
            internalOrderBlocksBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right))
            internalOrderBlocksLabels.push(label.new(na, na, "", xloc = xloc.bar_time))

bearishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : high
bullishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : low
atrMeasure = ta.atr(200)
volatilityMeasure = orderBlockFilterInput == ATR ? atrMeasure : ta.cum(ta.tr) / bar_index
highVolatilityBar = (high - low) >= (2 * volatilityMeasure)
parsedHigh = highVolatilityBar ? low : high
parsedLow = highVolatilityBar ? high : low

var array<float> parsedHighs = array.new<float>()
var array<float> parsedLows = array.new<float>()
var array<float> highs = array.new<float>()
var array<float> lows = array.new<float>()
var array<int> times = array.new<int>()
parsedHighs.push(parsedHigh)
parsedLows.push(parsedLow)
highs.push(high)
lows.push(low)
times.push(time)

alerts currentAlerts = alerts.new()

//---------------------------------------------------------------------------------------------------------------------
// STRUCTURE DETECTION
//---------------------------------------------------------------------------------------------------------------------
BULLISH_LEG = 1
BEARISH_LEG = 0

leg(int size) =>
    var l = 0
    newLegHigh = high[size] > ta.highest(size)
    newLegLow = low[size] < ta.lowest(size)
    if newLegHigh
        l := BEARISH_LEG
    else if newLegLow
        l := BULLISH_LEG
    l

startOfNewLeg(int l) => ta.change(l) != 0
startOfBearishLeg(int l) => ta.change(l) == -1
startOfBullishLeg(int l) => ta.change(l) == +1

getCurrentStructure(int size, bool internal) =>
    currentLeg = leg(size)
    newPivot = startOfNewLeg(currentLeg)
    pivotLow = startOfBullishLeg(currentLeg)
    pivotHigh = startOfBearishLeg(currentLeg)
    if newPivot
        if pivotLow
            pivot p = internal ? internalLow : swingLow
            p.lastLevel := p.currentLevel
            p.currentLevel := low[size]
            p.crossed := false
            p.barTime := time[size]
            p.barIndex := bar_index[size]
        else
            pivot p = internal ? internalHigh : swingHigh
            p.lastLevel := p.currentLevel
            p.currentLevel := high[size]
            p.crossed := false
            p.barTime := time[size]
            p.barIndex := bar_index[size]

//---------------------------------------------------------------------------------------------------------------------
// ORDER BLOCKS
//---------------------------------------------------------------------------------------------------------------------
storeOrdeBlock(pivot p_ivot, bool internal, int bias) =>
    array<float> a = na
    int parsedIndex = na
    if bias == BEARISH
        a := parsedHighs.slice(p_ivot.barIndex, bar_index)
        parsedIndex := p_ivot.barIndex + a.indexof(a.max())
    else
        a := parsedLows.slice(p_ivot.barIndex, bar_index)
        parsedIndex := p_ivot.barIndex + a.indexof(a.min())
    ob = orderBlock.new(parsedHighs.get(parsedIndex), parsedLows.get(parsedIndex), times.get(parsedIndex), bias)
    array<orderBlock> blocks = internal ? internalOrderBlocks : swingOrderBlocks
    if blocks.size() >= 100
        blocks.pop()
    blocks.unshift(ob)

deleteOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    for [index, ob] in orderBlocks
        bool crossedOB = false
        if bearishOrderBlockMitigationSource > ob.barHigh and ob.bias == BEARISH
            crossedOB := true
            if internal
                currentAlerts.internalBearishOrderBlock := true
            else
                currentAlerts.swingBearishOrderBlock := true
        else if bullishOrderBlockMitigationSource < ob.barLow and ob.bias == BULLISH
            crossedOB := true
            if internal
                currentAlerts.internalBullishOrderBlock := true
            else
                currentAlerts.swingBullishOrderBlock := true
        if crossedOB
            orderBlocks.remove(index)

drawOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    if orderBlocks.size() > 0
        maxCount = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput
        array<orderBlock> parsedOrderBlocks = orderBlocks.slice(0, math.min(maxCount, orderBlocks.size()))
        array<box> boxes = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes
        array<label> labels = internal ? internalOrderBlocksLabels : swingOrderBlocksLabels
        for [i, ob] in parsedOrderBlocks
            // ✅ احترام مربعات الاختيار (دايمًا، بغض النظر عن الـ Style)
            bool allowDraw =
                 (internal and ((ob.bias == BEARISH and showInternalBearishOb) or (ob.bias == BULLISH and showInternalBullishOb))) or
                 (not internal and ((ob.bias == BEARISH and showBearishOb) or (ob.bias == BULLISH and showBullishOb)))
            if not allowDraw
                continue

            color boxColor = color.new(color.black, 0)
            if styleInput == MONOCHROME
                boxColor := ob.bias == BEARISH ? color.new(MONO_BEARISH, 80) : color.new(MONO_BULLISH, 80)
            else
                if internal
                    boxColor := ob.bias == BEARISH ? internalBearColor : internalBullColor
                else
                    boxColor := ob.bias == BEARISH ? swingBearColor : swingBullColor

            b = boxes.get(i)
            b.set_top_left_point(chart.point.new(ob.barTime, na, ob.barHigh))
            b.set_bottom_right_point(chart.point.new(last_bar_time, na, ob.barLow))
            b.set_border_color(internal ? na : boxColor)
            b.set_bgcolor(boxColor)

            // 🟢 "OB" في المنتصف باللون الأبيض فقط (بدون خلفية)
            lbl = labels.get(i)
            label.set_x(lbl, (ob.barTime + last_bar_time) / 2)
            label.set_y(lbl, (ob.barHigh + ob.barLow) / 2)
            label.set_text(lbl, "OB")
            label.set_style(lbl, label.style_label_center)
            label.set_textcolor(lbl, color.rgb(255, 255, 255, 25))
            label.set_color(lbl, color.new(color.white, 100))
            label.set_size(lbl, size.large)

//---------------------------------------------------------------------------------------------------------------------
// EXECUTION
//---------------------------------------------------------------------------------------------------------------------
getCurrentStructure(SWING_LENGTH_DEFAULT, false)
getCurrentStructure(5, true)
displayStructure(bool internal) =>
    p = internal ? internalHigh : swingHigh
    if ta.crossover(close, p.currentLevel) and not p.crossed
        p.crossed := true
        storeOrdeBlock(p, internal, BULLISH)
    p := internal ? internalLow : swingLow
    if ta.crossunder(close, p.currentLevel) and not p.crossed
        p.crossed := true
        storeOrdeBlock(p, internal, BEARISH)
displayStructure(true)
displayStructure(false)

if showInternalOrderBlocksInput
    deleteOrderBlocks(true)
if showSwingOrderBlocksInput
    deleteOrderBlocks(false)

if barstate.islastconfirmedhistory or barstate.islast
    if showInternalOrderBlocksInput
        drawOrderBlocks(true)
    if showSwingOrderBlocksInput
        drawOrderBlocks(false)

//---------------------------------------------------------------------------------------------------------------------
// ALERTS
//---------------------------------------------------------------------------------------------------------------------
alertcondition(currentAlerts.internalBullishOrderBlock, 'Bullish Internal OB Breakout', 'Price broke bullish internal OB')
alertcondition(currentAlerts.internalBearishOrderBlock, 'Bearish Internal OB Breakout', 'Price broke bearish internal OB')
alertcondition(currentAlerts.swingBullishOrderBlock, 'Bullish Swing OB Breakout', 'Price broke bullish swing OB')
alertcondition(currentAlerts.swingBearishOrderBlock, 'Bearish Swing OB Breakout', 'Price broke bearish swing OB')

// =========================
//      Fear Value Gap UI
// =========================

// ✅ إخفاء Fear Value Gap
isFvgToShow          = true

// ✅ Bullish FVG Color + checkbox
showBullishFvg = true
bullishFvgColor      = color.new(color.green, 50)

// ✅ Bearish FVG Color + checkbox
showBearishFvg = true
bearishFvgColor      = color.new(color.red,   50)

// ✅ Mitigated FVG Color + checkbox
showMitigatedFvg = true
mitigatedFvgColor    = color.new(color.gray,  50)

fvgHistoryNbr        = 10
isMitigatedFvgToReduce = false

// =========================
//      Arrays / State
// =========================
var array<box>  fvgBoxes       = array.new_box(0)
var array<bool> fvgTypes       = array.new_bool(0)   // true = bullish, false = bearish
var array<label> fvgLabels     = array.new_label(0)
var array<bool> isFvgMitigated = array.new_bool(0)

// =========================
//      Helper: Draw / Update
// =========================
FVGDraw(_boxes, _fvgTypes, _isFvgMitigated, _fvgLabels) =>
    // Loop into all values of the array
    for [index, value] in _boxes
        // Bullish FVG
        if (array.get(_fvgTypes, index))
            // fully mitigated?
            if (low <= box.get_bottom(value))
                array.remove(_boxes, index)
                array.remove(_fvgTypes, index)
                array.remove(_isFvgMitigated, index)
                label.delete(array.get(_fvgLabels, index))
                array.remove(_fvgLabels, index)
                box.delete(value)
            else
                if (low < box.get_top(value))
                    if (showMitigatedFvg)
                        box.set_bgcolor(value, mitigatedFvgColor)

                    // Mitigated FVG Alert (like the original)
                    if (not array.get(_isFvgMitigated, index))
                        alert("FVG has been mitigated", alert.freq_once_per_bar)
                        array.set(_isFvgMitigated, index, true)

                    // Reduce box height if enabled
                    if (isMitigatedFvgToReduce)
                        box.set_top(value, low)

                box.set_right(value, bar_index)
                label.set_x(array.get(_fvgLabels, index), (box.get_left(value) + box.get_right(value)) / 2 )
                label.set_y(array.get(_fvgLabels, index), box.get_top(value) - (box.get_top(value) - box.get_bottom(value)) / 2)

        // Bearish FVG
        else
            // fully mitigated?
            if (high >= box.get_top(value))
                array.remove(_boxes, index)
                array.remove(_fvgTypes, index)
                array.remove(_isFvgMitigated, index)
                label.delete(array.get(_fvgLabels, index))
                array.remove(_fvgLabels, index)
                box.delete(value)
            else
                if (high > box.get_bottom(value))
                    if (showMitigatedFvg)
                        box.set_bgcolor(value, mitigatedFvgColor)

                    // Mitigated FVG Alert (like the original)
                    if (not array.get(_isFvgMitigated, index))
                        alert("FVG has been mitigated", alert.freq_once_per_bar)
                        array.set(_isFvgMitigated, index, true)

                    // Reduce box height if enabled
                    if (isMitigatedFvgToReduce)
                        box.set_bottom(value, high)

                box.set_right(value, bar_index)
                label.set_x(array.get(_fvgLabels, index), (box.get_left(value) + box.get_right(value)) / 2 )
                label.set_y(array.get(_fvgLabels, index), box.get_top(value) - (box.get_top(value) - box.get_bottom(value)) / 2)

// =========================
//      FVG Detection (same logic)
// =========================
isBullishFVG = high[3] < low[1]
isBearishFVG = low[3] > high[1]

// Bullish FVG process
if (isBullishFVG and isFvgToShow and showBullishFvg)
    box _box   = box.new(left=bar_index - 2, top=low[1], right=bar_index[1], bottom=high[3],
                         border_style=line.style_solid, border_width=1,
                         bgcolor=bullishFvgColor, border_color=color.new(color.green, 100))
    label _lbl = label.new(math.ceil((_box.get_left() + _box.get_right()) / 2),
                           _box.get_top() - (_box.get_top() - _box.get_bottom()) / 2,
                           text="FVG", style=label.style_none, textcolor=color.white)
    array.push(fvgBoxes, _box)
    array.push(fvgTypes, true)
    array.push(isFvgMitigated, false)
    array.push(fvgLabels, _lbl)

    // cap history same as original
    if (array.size(fvgBoxes) > fvgHistoryNbr + 1)
        box.delete(array.get(fvgBoxes, 0))
        label.delete(array.get(fvgLabels, 0))
        array.remove(fvgLabels, 0)
        array.remove(fvgBoxes, 0)
        array.remove(fvgTypes, 0)
        array.remove(isFvgMitigated, 0)

// Bearish FVG process
if (isBearishFVG and isFvgToShow and showBearishFvg)
    box _box   = box.new(left=bar_index - 2, top=low[3], right=bar_index[1], bottom=high[1],
                         border_style=line.style_solid, border_width=1,
                         bgcolor=bearishFvgColor, border_color=color.new(color.red, 100))
    label _lbl = label.new(math.ceil((_box.get_left() + _box.get_right()) / 2),
                           _box.get_top() - (_box.get_top() - _box.get_bottom()) / 2,
                           text="FVG", style=label.style_none, textcolor=color.white)
    array.push(fvgBoxes, _box)
    array.push(fvgTypes, false)
    array.push(isFvgMitigated, false)
    array.push(fvgLabels, _lbl)

    // cap history same as original
    if (array.size(fvgBoxes) > fvgHistoryNbr + 1)
        box.delete(array.get(fvgBoxes, 0))
        label.delete(array.get(fvgLabels, 0))
        array.remove(fvgLabels, 0)
        array.remove(fvgBoxes, 0)
        array.remove(fvgTypes, 0)
        array.remove(isFvgMitigated, 0)

// Draw / update all FVGs
FVGDraw(fvgBoxes, fvgTypes, isFvgMitigated, fvgLabels)

// ======================================================================
// PART 2: ICT Turtle Soup | Flux Charts Indicator (Original Code)
// ======================================================================

const bool DEBUG = false
const int maxDistanceToLastBar = 4900 // Affects Running Time
const int atrLen = 5
const bool maxTPLastHour = false

var initRun = true

mssOffset = 10

// ✅ تغيير اسم القسم إلى Time Frame
higherTimeframe = input.timeframe("240", "Higher Timeframe", group = "Time Frame")

breakoutMethod = "Wick"
entryMethod = "Classic"
dbgTPSLVersion = "Default"
dbgLabelSize = DEBUG ? "Small" : "Normal"
lblSize = (dbgLabelSize == "Small" ? size.small : dbgLabelSize == "Normal" ? size.normal : size.tiny)

showHL = false
showLiqGrabs = true
showTPSL = true

tpslMethod = "Dynamic"
riskAmount = "Low"
customSLATRMult = DEBUG ? 6.5 : 6.5
tpPercent = 0.3
slPercent = 0.4

RR = DEBUG ? 0.9 : 0.9

slATRMult = riskAmount == "Highest" ? 10 : riskAmount == "High" ? 6.5 : riskAmount == "Normal" ? 5.5 : riskAmount == "Low" ? 3.5 : riskAmount == "Lowest" ? 1.15 : customSLATRMult

backtestDisplayEnabled = true
backtestingLocation = "Top Center"
fillBackgrounds = true
screenerColor = #1B1F2B

highColor = color.green
lowColor = color.red
textColor = color.white

buyAlertEnabled = true
sellAlertEnabled = true
tpAlertEnabled = true
slAlertEnabled = true

buyAlertTick = false
sellAlertTick = false
tpAlertTick = false
slAlertTick = false

type Sweep
    int startTime
    int endTime
    string side
    float price

type TurtleSoup
    string state
    int startTime

    int lastHour = na
    float lastHourHigh = na
    float lastHourLow = na
    Sweep brokenSweep = na
    float slTarget
    float tpTarget
    string entryType
    int entryTime
    int exitTime
    float entryPrice
    float exitPrice
    int dayEndedBeforeExit

var lineX = array.new<line>()
var boxX = array.new<box>()
var labelX = array.new<label>()

var TurtleSoup[] tsList = array.new<TurtleSoup>(0)
var TurtleSoup lastTS = na

atr = ta.atr(atrLen)

diffPercent (float val1, float val2) =>
    (math.abs(val1 - val2) / val2) * 100.0

getPosition (positionText) =>
    if positionText == "Top Right"
        position.top_right
    else if positionText == "Top Center"
        position.top_center
    else if positionText == "Right Center"
        position.middle_right
    else if positionText == "Left Center"
        position.middle_left
    else if positionText == "Bottom Center"
        position.bottom_center
    else if positionText == "Middle Center"
        position.middle_center

tfInMin = timeframe.in_seconds() / 60

//#region Liqs
if timeframe.in_seconds(higherTimeframe) <= timeframe.in_seconds()
    runtime.error("Higher timeframe must be higher than current timeframe.")
int htfMins = timeframe.in_seconds(higherTimeframe) / 60
int barLength = htfMins / tfInMin
float high12 = ta.highest(barLength)
float low12 = ta.lowest(barLength)
float highMSS = ta.highest(mssOffset)
float lowMSS = ta.lowest(mssOffset)
int lastHourTime = time[barLength]
//#endregion

//#region Turtle Soup
var highBreaks = 0
var lowBreaks = 0

if bar_index > last_bar_index - maxDistanceToLastBar
    if true
        // Find Session Start
        createNewTS = true
        if not na(lastTS)
            if na(lastTS.exitPrice)
                createNewTS := false // Don't enter if a trade is already entered
                
        if createNewTS
            newTS = TurtleSoup.new("Waiting For Liquidity Break", time)
            newTS.lastHourHigh := high12
            newTS.lastHourLow := low12
            newTS.lastHour := lastHourTime
            tsList.unshift(newTS)
            lastTS := newTS
            log.info("New Turtle Soup")

        if not na(lastTS)
            // Find Liquidity Breaks
            if lastTS.state == "Waiting For Liquidity Break"
                log.info("Wait For Liq Grab")
                if time > lastTS.startTime
                    if (breakoutMethod == "Close" ? close : low) < lastTS.lastHourLow
                        log.info("Sellside Liq Grab")
                        if entryMethod == "Classic" or highBreaks > lowBreaks
                            lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Sellside", lastTS.lastHourLow)
                            lastTS.entryType := "Long"
                        else if highBreaks <= lowBreaks
                            lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Sellside", lastTS.lastHourLow)
                            lastTS.entryType := "Short"

                        lastTS.state := "Waiting For Execution"
                    
                    else if (breakoutMethod == "Close" ? close : high) > lastTS.lastHourHigh
                        log.info("Buyside Liq Grab")
                        if entryMethod == "Classic" or highBreaks <= lowBreaks
                            lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Buyside", lastTS.lastHourHigh)
                            lastTS.entryType := "Short"
                        else if highBreaks > lowBreaks
                            lastTS.brokenSweep := Sweep.new(lastTS.lastHour, time, "Buyside", lastTS.lastHourHigh)
                            lastTS.entryType := "Long"
                        lastTS.state := "Waiting For Execution"
            // Execute
            if lastTS.state == "Waiting For Execution"
                if time > lastTS.brokenSweep.endTime
                    log.info("MSS Execution")
                    if lastTS.entryType == "Short"
                        if (breakoutMethod == "Close" ? close : low) < lowMSS[1]
                            sellAlertTick := true
                            lastTS.state := "Entry Taken"
                            lastTS.entryTime := time
                            lastTS.entryPrice := (breakoutMethod == "Close" ? close : lowMSS[1])
                            if tpslMethod == "Fixed"
                                lastTS.slTarget := lastTS.entryPrice * (1 + slPercent / 100.0)
                                lastTS.tpTarget := lastTS.entryPrice * (1 - tpPercent / 100.0)
                            else
                                lastTS.slTarget := highMSS + atr * slATRMult
                                lastTS.tpTarget := lastTS.entryPrice - (math.abs(lastTS.entryPrice - lastTS.slTarget) * RR)
                    else // Long
                        if (breakoutMethod == "Close" ? close : high) > highMSS[1]
                            buyAlertTick := true
                            lastTS.state := "Entry Taken"
                            lastTS.entryTime := time
                            lastTS.entryPrice := (breakoutMethod == "Close" ? close : highMSS[1])
                            if tpslMethod == "Fixed"
                                lastTS.slTarget := lastTS.entryPrice * (1 - slPercent / 100.0)
                                lastTS.tpTarget := lastTS.entryPrice * (1 + tpPercent / 100.0)
                            else
                                lastTS.slTarget := lowMSS - atr * slATRMult
                                lastTS.tpTarget := lastTS.entryPrice + (math.abs(lastTS.entryPrice - lastTS.slTarget) * RR)
    
    // Entry Taken
    if not na(lastTS)
        if lastTS.state == "Entry Taken"
            log.info("Entry Taken")
            if tpslMethod == "Fixed"
                // Take Profit
                if lastTS.entryType == "Long" and ((high / lastTS.entryPrice) - 1) * 100 >= tpPercent
                    tpAlertTick := true
                    lastTS.exitPrice := lastTS.entryPrice * (1 + tpPercent / 100.0)
                    lastTS.exitTime := time
                    lastTS.state := "Take Profit"
                    highBreaks += 1
                if lastTS.entryType == "Short" and ((low / lastTS.entryPrice) - 1) * 100 <= -tpPercent
                    tpAlertTick := true
                    lastTS.exitPrice := lastTS.entryPrice * (1 - tpPercent / 100.0)
                    lastTS.exitTime := time
                    lastTS.state := "Take Profit"
                    lowBreaks += 1
                
                // Stop Loss
                if lastTS.entryType == "Long" and ((low / lastTS.entryPrice) - 1) * 100 <= -slPercent
                    slAlertTick := true
                    lastTS.exitPrice := lastTS.entryPrice * (1 - slPercent / 100.0)
                    lastTS.exitTime := time
                    lastTS.state := "Stop Loss"
                    highBreaks -= 1
                if lastTS.entryType == "Short" and ((high / lastTS.entryPrice) - 1) * 100 >= slPercent
                    slAlertTick := true
                    lastTS.exitPrice := lastTS.entryPrice * (1 + slPercent / 100.0)
                    lastTS.exitTime := time
                    lastTS.state := "Stop Loss"
                    lowBreaks -= 1
            else
                // Take Profit
                if lastTS.entryType == "Long" and ((maxTPLastHour and high >= lastTS.lastHourHigh) or high >= lastTS.tpTarget)
                    tpAlertTick := true
                    lastTS.exitPrice := (high >= math.max(lastTS.lastHourHigh, lastTS.tpTarget) ? math.max(lastTS.lastHourHigh, lastTS.tpTarget) : math.min(lastTS.lastHourHigh, lastTS.tpTarget))
                    lastTS.exitTime := time
                    lastTS.state := "Take Profit"
                    highBreaks += 1
                if lastTS.entryType == "Short" and ((maxTPLastHour and low <= lastTS.lastHourLow) or low <= lastTS.tpTarget)
                    tpAlertTick := true
                    lastTS.exitPrice := (low <= math.min(lastTS.lastHourLow, lastTS.tpTarget) ? math.min(lastTS.lastHourLow, lastTS.tpTarget) : math.max(lastTS.lastHourLow, lastTS.tpTarget))
                    lastTS.exitTime := time
                    lastTS.state := "Take Profit"
                    lowBreaks += 1
                
                // Stop Loss
                if lastTS.entryType == "Long" and low <= lastTS.slTarget
                    slAlertTick := true
                    lastTS.exitPrice := lastTS.slTarget
                    lastTS.exitTime := time
                    lastTS.state := "Stop Loss"
                    highBreaks -= 1
                if lastTS.entryType == "Short" and high >= lastTS.slTarget
                    slAlertTick := true
                    lastTS.exitPrice := lastTS.slTarget
                    lastTS.exitTime := time
                    lastTS.state := "Stop Loss"
                    lowBreaks -= 1
//#endregion

//#region Render Turtle Soups

renderTopSL = false
renderBottomSL = false
renderTopTP = false
renderBottomTP = false

if not na(lastTS)
    if lastTS.state == "Stop Loss" and time >= lastTS.exitTime
        if lastTS.entryType == "Long"
            renderBottomSL := true
        else
            renderTopSL := true
        lastTS.state := "Done"
    if lastTS.state == "Take Profit"
        if lastTS.entryType == "Long"
            renderTopTP := true
        else
            renderBottomTP := true
        lastTS.state := "Done"

//#endregion

//#region Alerts

if barstate.islastconfirmedhistory
    initRun := false

alertcondition(buyAlertTick and not initRun, "Turtle Soup Buy Signal", "")
alertcondition(sellAlertTick and not initRun, "Turtle Soup Sell Signal", "")
alertcondition(tpAlertTick and not initRun, "Turtle Soup Take-Profit Signal", "")
alertcondition(slAlertTick and not initRun, "Turtle Soup Stop-Loss Signal", "")

if not initRun
    if buyAlertTick and buyAlertEnabled
        alert("Turtle Soup Buy Signal")
    if sellAlertTick and sellAlertEnabled
        alert("Turtle Soup Sell Signal")
    
    if tpAlertTick and tpAlertEnabled
        alert("Turtle Soup Take-Profit Signal")
    if slAlertTick and slAlertEnabled
        alert("Turtle Soup Stop-Loss Signal")

//#endregion

if barstate.isconfirmed
    if lineX.size() > 0
        for i = 0 to lineX.size() - 1
            line.delete(lineX.get(i))

    if boxX.size() > 0
        for i = 0 to boxX.size() - 1
            box.delete(boxX.get(i))
    
    if labelX.size() > 0
        for i = 0 to labelX.size() - 1
            label.delete(labelX.get(i))

    lineX.clear()
    boxX.clear()
    labelX.clear()
    
    if tsList.size() > 0
        for i = 0 to math.min(125, tsList.size() - 1)
            curTS = tsList.get(i)

            // Target Liquidity
            if not na(curTS.brokenSweep) and showHL
                offset = atr / 3.0
                if curTS.brokenSweep.price == curTS.lastHourHigh
                    boxX.push(box.new(curTS.brokenSweep.startTime, curTS.lastHourHigh + offset, curTS.brokenSweep.endTime, curTS.lastHourHigh - offset, text = "TARGET LIQUIDITY (" + str.tostring(higherTimeframe) + ")", text_color = textColor, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(highColor, 50), text_size = size.small))
                else
                    boxX.push(box.new(curTS.brokenSweep.startTime, curTS.lastHourLow + offset, curTS.brokenSweep.endTime, curTS.lastHourLow - offset, text = "TARGET LIQUIDITY (" + str.tostring(higherTimeframe) + ")", text_color = textColor, xloc = xloc.bar_time, border_width = 0, bgcolor = color.new(lowColor, 50), text_size = size.small))

            // Liq Grab
            if not na(curTS.brokenSweep) and showLiqGrabs
                if curTS.brokenSweep.price == curTS.lastHourHigh
                    labelX.push(label.new(curTS.brokenSweep.endTime, high, yloc = yloc.abovebar, xloc = xloc.bar_time, style = label.style_circle, size = size.tiny, color = color.new(lowColor, 50)))
                else
                    labelX.push(label.new(curTS.brokenSweep.endTime, low, yloc = yloc.belowbar, xloc = xloc.bar_time, style = label.style_circle, size = size.tiny, color = color.new(highColor, 50)))

// Keep script valid
plot(na)

import Fontiramisu/fontilab/12 as fontilab

//
// ===========================
// Linear Regression Channel
// ===========================

// ✅ التعديل 2: إخفاء Length و Source
lengthInput = 100
sourceInput = close

// ✅ التعديل 3: إخفاء قسم Channel 1 Settings و Display Settings
group1 = "Channel 1 Settings"
useUpperDevInput = true
upperMultInput   = 2.5
useLowerDevInput = true
lowerMultInput   = 2.5

group2 = "Display Settings"
showPearsonInput = true
extendLeftInput  = false
extendRightInput = false

extendStyle = extend.none
if extendLeftInput and extendRightInput
    extendStyle := extend.both
else if extendLeftInput
    extendStyle := extend.left
else if extendRightInput
    extendStyle := extend.right

// ✅ إخفاء Style - Channel 1
group3 = "Style - Channel 1"
colorUpper = color.rgb(31, 60, 248)
colorLower = color.rgb(31, 60, 248)

// ✅ إخفاء Style - Channel 1 Lines
group3b = "Style - Channel 1 Lines"
baseColorInput   = color.rgb(31, 60, 248)
upperWidthInput  = 3
baseWidthInput   = 1
lowerWidthInput  = 3
upperStyleOpt    = "solid"
baseStyleOpt     = "solid"
lowerStyleOpt    = "solid"

//---------------------------- FUNCTIONS ----------------------------//

calcSlope(source, length) =>
    max_bars_back(source, 5000)
    if not barstate.islast or length <= 1
        [float(na), float(na), float(na)]
    else
        sumX = 0.0
        sumY = 0.0
        sumXSqr = 0.0
        sumXY = 0.0
        for i = 0 to length - 1
            val = source[i]
            per = i + 1.0
            sumX += per
            sumY += val
            sumXSqr += per * per
            sumXY += val * per
        slope = (length * sumXY - sumX * sumY) / (length * sumXSqr - sumX * sumX)
        average = sumY / length
        intercept = average - slope * sumX / length + slope
        [slope, average, intercept]

//---------------------------- MAIN CALC ----------------------------//

[s, a, i] = calcSlope(sourceInput, lengthInput)
startPrice = i + s * (lengthInput - 1)
endPrice = i

// دالة نمط الخطوط (موجودة لاحقًا أيضًا – نعيد استعمالها)
get_line_style(opt) =>
    opt == "solid" ? line.style_solid : opt == "dotted" ? line.style_dotted : line.style_dashed

var line baseLine = na
if na(baseLine) and not na(startPrice)
    baseLine := line.new(bar_index - lengthInput + 1, startPrice, bar_index, endPrice, width=baseWidthInput, extend=extendStyle, color=baseColorInput, style=get_line_style(baseStyleOpt))
else
    line.set_xy1(baseLine, bar_index - lengthInput + 1, startPrice)
    line.set_xy2(baseLine, bar_index, endPrice)
    line.set_width(baseLine, baseWidthInput)
    line.set_style(baseLine, get_line_style(baseStyleOpt))
    line.set_color(baseLine, baseColorInput)

calcDev(source, length, slope, average, intercept) =>
    upDev = 0.0
    dnDev = 0.0
    stdDevAcc = 0.0
    dsxx = 0.0
    dsyy = 0.0
    dsxy = 0.0
    periods = length - 1
    daY = intercept + slope * periods / 2
    val = intercept
    for j = 0 to periods
        price = high[j] - val
        if price > upDev
            upDev := price
        price := val - low[j]
        if price > dnDev
            dnDev := price
        price := source[j]
        dxt = price - average
        dyt = val - daY
        price -= val
        stdDevAcc += price * price
        dsxx += dxt * dxt
        dsyy += dyt * dyt
        dsxy += dxt * dyt
        val += slope
    stdDev = math.sqrt(stdDevAcc / (periods == 0 ? 1 : periods))
    pearsonR = dsxx == 0 or dsyy == 0 ? 0 : dsxy / math.sqrt(dsxx * dsyy)
    [stdDev, pearsonR, upDev, dnDev]

[stdDev, pearsonR, upDev, dnDev] = calcDev(sourceInput, lengthInput, s, a, i)

upperStartPrice = startPrice + (useUpperDevInput ? upperMultInput * stdDev : upDev)
upperEndPrice = endPrice + (useUpperDevInput ? upperMultInput * stdDev : upDev)
var line upper = na

lowerStartPrice = startPrice + (useLowerDevInput ? -lowerMultInput * stdDev : -dnDev)
lowerEndPrice = endPrice + (useLowerDevInput ? -lowerMultInput * stdDev : -dnDev)
var line lower = na

if na(upper) and not na(upperStartPrice)
    upper := line.new(bar_index - lengthInput + 1, upperStartPrice, bar_index, upperEndPrice, width=upperWidthInput, extend=extendStyle, color=color.new(colorUpper, 0), style=get_line_style(upperStyleOpt))
else
    line.set_xy1(upper, bar_index - lengthInput + 1, upperStartPrice)
    line.set_xy2(upper, bar_index, upperEndPrice)
    line.set_width(upper, upperWidthInput)
    line.set_style(upper, get_line_style(upperStyleOpt))
    line.set_color(upper, color.new(colorUpper, 0))

if na(lower) and not na(lowerStartPrice)
    lower := line.new(bar_index - lengthInput + 1, lowerStartPrice, bar_index, lowerEndPrice, width=lowerWidthInput, extend=extendStyle, color=color.new(colorLower, 0), style=get_line_style(lowerStyleOpt))
else
    line.set_xy1(lower, bar_index - lengthInput + 1, lowerStartPrice)
    line.set_xy2(lower, bar_index, lowerEndPrice)
    line.set_width(lower, lowerWidthInput)
    line.set_style(lower, get_line_style(lowerStyleOpt))
    line.set_color(lower, color.new(colorLower, 0))

//---------------------------- FILL & ALERTS ----------------------------//

linefill.new(upper, baseLine, color=color.new(colorUpper, 100))
linefill.new(baseLine, lower, color=color.new(colorLower, 100))

float trend = math.sign(startPrice - endPrice)

alertcondition(sourceInput > line.get_price(upper, bar_index) or sourceInput < line.get_price(lower, bar_index), 
     title='Regression Channel Exited', 
     message="The price movement has exited Regression Channel's bounds")

alertcondition(trend[1] >= 0 and trend < 0, 
     title='Switched to Uptrend',   
     message='The Regression Channel trend switched from Downtrend to Uptrend')

alertcondition(trend[1] <= 0 and trend > 0, 
     title='Switched to Downtrend', 
     message='The Regression Channel trend switched from Uptrend to Downtrend')

// ----------------------------- الإعدادات الأساسية -----------------------------
base_price_input = input.float(3886, title="السعر الأساسي")
is_peak          = input.bool(false, title="هل السعر قمة؟")
num_lines        = input.int(75, title="عدد الخطوط", minval=1, maxval=250)
point_multiplier = input.float(10.0, title="مضاعف النقطة")

// ألوان/عرض/نمط الخطوط
main_line_color      = input.color(color.new(#a7abad, 60), title="لون الخطوط الرئيسية")
main_line_width      = input.int(2, title="عرض الخطوط الرئيسية", minval=1, maxval=5)
main_line_style_opt  = input.string("solid", title="نمط الخطوط الرئيسية", options=["solid","dotted","dashed"])

half_line_color      = input.color(color.new(#a7abad, 60), title="لون خطوط المنتصف")
half_line_width      = input.int(2, title="عرض خطوط المنتصف", minval=1, maxval=5)
half_line_style_opt  = input.string("dotted", title="نمط خطوط المنتصف", options=["solid","dotted","dashed"])

// إعدادات الخط المرجعي
show_reference_line  = input.bool(true, title="إظهار الخط المرجعي (السعر الأساسي)")
reference_color      = input.color(color.new(#f62548, 60), title="لون الخط المرجعي")
reference_width      = input.int(2, title="عرض الخط المرجعي", minval=1, maxval=5)
reference_style_opt  = input.string("solid", title="نمط الخط المرجعي", options=["solid","dotted","dashed"])

// ===========================
// قسم محاور 21 المضاف
// ===========================

// ✅ إعدادات محاور 21
show_21_axes = input.bool(false, "إظهار محاور 21", group="محاور 21")
axes_21_color = input.color(color.new(#FF6B00, 60), "لون محاور 21", group="محاور 21")
axes_21_width = input.int(1, "عرض محاور 21", minval=1, maxval=5, group="محاور 21")
axes_21_style = input.string("solid", "نمط محاور 21", options=["solid","dotted","dashed"], group="محاور 21")

// رسم خطوط محاور 21
if barstate.isfirst and show_21_axes
    start_value = 21
    end_value = 5500
    current_value = start_value
    
    while current_value <= end_value
        line.new(bar_index, current_value, bar_index, current_value, extend=extend.right, color=axes_21_color, style=get_line_style(axes_21_style), width=axes_21_width)
                
                
        current_value := current_value + 21

// ----------------------------- دوال مساعدة -----------------------------
digital_root(price) =>
    int_price = math.round(math.abs(price))
    1 + (int_price - 1) % 9

get_triangle_value(root) =>
    root == 1 or root == 4 or root == 7 ? 120 :
     root == 2 or root == 5 or root == 8 ? 150 :
     root == 3 or root == 6 or root == 9 ? 180 : 120

// إعادة استخدام دالة نمط الخطوط
// get_line_style(opt) موجودة فوق

// ----------------------------- الحسابات -----------------------------
root                   = digital_root(base_price_input)
triangle_value         = get_triangle_value(root)
adjusted_triangle_value = triangle_value / point_multiplier
direction              = is_peak ? -1 : 1

// ----------------------------- الرسم -----------------------------

if barstate.isfirst
    // رسم الخط المرجعي
    if show_reference_line
        line.new(bar_index, base_price_input, bar_index, base_price_input, extend=extend.right, color=reference_color, style=get_line_style(reference_style_opt), width=reference_width)

    // رسم الخطوط الرئيسية وخطوط المنتصف
    for i = 1 to num_lines
        main_level = base_price_input + (i * adjusted_triangle_value * direction)
        half_level = base_price_input + ((i - 0.5) * adjusted_triangle_value * direction)
        line.new(bar_index, main_level, bar_index, main_level, extend=extend.right, color=main_line_color, style=get_line_style(main_line_style_opt), width=main_line_width)
        line.new(bar_index, half_level, bar_index, half_level, extend=extend.right, color=half_line_color, style=get_line_style(half_line_style_opt), width=half_line_width)

// ===========================
// Log Regression Channel [UAlgo]
// ===========================

// ✅ إخفاء Style - Channel 2
groupLogStyle = "Style - Channel 2"
logRegColorInput = color.rgb(31, 60, 248)
logDevColorInput = color.rgb(31, 60, 248)
logRegWidthInput = 2
logDevWidthInput = 3
logRegStyleOpt   = "solid"
logDevStyleOpt   = "solid"

// ✅ بقية الإعدادات مخفية
source_input = close
length_input = 100
multiplier_input = 2
label_color = color.red
label_size_option = 'small'

var float[] series_price = array.new_float(length_input)
var int[] series_time = array.new_int(length_input)

array.unshift(series_price, source_input)
array.pop(series_price)
array.unshift(series_time, bar_index)
array.pop(series_time)

var line[] reg_lines = array.new_line()
var line[] dev_up_lines = array.new_line()
var line[] dev_down_lines = array.new_line()

var label r_squared_label = label.new(x = na, y = na, style = label.style_label_upper_right, color = #00000000, textcolor = color.new(#FF1493, 0), size=size.large, textalign = text.align_right)

float[] dev_up_series = array.new_float()
float[] dev_down_series = array.new_float()

var int line_step = na
var int line_count = na

if barstate.isfirst
    line_count := math.min(length_input, 250)
    for i = 0 to line_count - 1
        array.unshift(reg_lines, line.new(x1=na, y1=na, x2=na, y2=na, color=logRegColorInput, style=get_line_style(logRegStyleOpt), width = logRegWidthInput))
    if length_input > 250
        line_step := math.ceil(length_input / 250)
    else
        line_step := 1
    for i = 0 to math.floor(line_count / 2) - 1
        array.unshift(dev_up_lines,   line.new(x1=na, y1=na, x2=na, y2=na, color=logDevColorInput, style=get_line_style(logDevStyleOpt), width = logDevWidthInput))
        array.unshift(dev_down_lines, line.new(x1=na, y1=na, x2=na, y2=na, color=logDevColorInput, style=get_line_style(logDevStyleOpt), width = logDevWidthInput))

if barstate.islast
    int _length_price = array.size(series_price)
    int _length_time = array.size(series_time)
    float[] _log_price_array = array.new_float(_length_price)
    float[] _log_time_array = array.new_float(_length_time)
    
    for _index = 0 to _length_price - 1
        array.set(_log_price_array, _index, math.log(array.get(series_price, _index)))
        array.set(_log_time_array, _index, math.log(array.get(series_time, _index)))

    float _total_log_time = array.sum(_log_time_array)
    float _total_log_price = array.sum(_log_price_array)
    float _total_log_time_price = 0.0
    float _total_log_time_sq = 0.0
    float _total_log_price_sq = 0.0

    if _length_price == _length_time
        for _index = 0 to _length_price - 1
            float _log_time_val = nz(array.get(_log_time_array, _index))
            float _log_price_val = nz(array.get(_log_price_array, _index))
            _total_log_time_price := _total_log_time_price + _log_time_val * _log_price_val
            _total_log_time_sq := _total_log_time_sq + math.pow(_log_time_val, 2)
            _total_log_price_sq := _total_log_price_sq + math.pow(_log_price_val, 2)
            _total_log_price_sq

    float _intercept = (_total_log_price * _total_log_time_sq - _total_log_time * _total_log_time_price) / (_length_time * _total_log_time_sq - math.pow(_total_log_time, 2))
    float _slope_coef = (_length_time * _total_log_time_price - _total_log_time * _total_log_price) / (_length_time * _total_log_time_sq - math.pow(_total_log_time, 2))

    float[] _predictions_array = array.new_float()

    for _index = 0 to _length_price - 1
        float _predicted_val = _intercept + _slope_coef * array.get(_log_time_array, _index)
        array.push(_predictions_array, _predicted_val)

    _slope = (array.get(_predictions_array, 0) - array.get(_predictions_array, _length_price - 1)) / (array.get(_log_time_array, 0) - array.get(_log_time_array, _length_time - 1))
    _mean_log_price = array.avg(_log_price_array)

    float _sum_squared_residuals = 0.0
    float _sum_squared_totals = 0.0

    for _index = 0 to _length_price - 1
        float _predicted = array.get(_predictions_array, _index)
        float _log_price_val = array.get(_log_price_array, _index)
        _sum_squared_residuals := _sum_squared_residuals + math.pow(_predicted - _log_price_val, 2)
        _sum_squared_totals := _sum_squared_totals + math.pow(_mean_log_price - _log_price_val, 2)
        _sum_squared_totals

    _r_squared = 1 - _sum_squared_residuals / _sum_squared_totals

    float _sum_squared_errors = 0

    for _index = 0 to _length_price - 1
        _sum_squared_errors += math.pow(array.get(_predictions_array, _index) - array.get(_log_price_array, _index), 2)

    _std_dev = math.sqrt(_sum_squared_errors / _length_price)

    for i = 0 to array.size(_predictions_array) - 1
        array.push(dev_up_series, math.exp(array.get(_predictions_array, i) + multiplier_input * _std_dev))
        array.push(dev_down_series, math.exp(array.get(_predictions_array, i) - multiplier_input * _std_dev))

    for i = 0 to array.size(_predictions_array) - 2 - line_step by line_step
        line.set_xy1(array.get(reg_lines, i / line_step), x=bar_index - i, y=math.exp(array.get(_predictions_array, i)))
        line.set_xy2(array.get(reg_lines, i / line_step), x=bar_index - i - line_step, y=math.exp(array.get(_predictions_array, i + line_step)))

    for i = 0 to array.size(dev_up_series) - 2 - line_step by line_step * 2
        line.set_xy1(array.get(dev_up_lines, i / (line_step * 2)), x=bar_index - i, y=array.get(dev_up_series, i))
        line.set_xy2(array.get(dev_up_lines, i / (line_step * 2)), x=bar_index - i - line_step, y=array.get(dev_up_series, i + line_step))
        line.set_xy1(array.get(dev_down_lines, i / (line_step * 2)), x=bar_index - i, y=array.get(dev_down_series, i))
        line.set_xy2(array.get(dev_down_lines, i / (line_step * 2)), x=bar_index - i - line_step, y=array.get(dev_down_series, i + line_step))

// كل المدخلات مخفية الآن - صارت متغيرات عادية
PP = 5  // Pivot Period of Order Blocks Detector

ShZ = false
ZLS = line.style_solid
ZLC = #2484bb
ZLW = 1
    
ShL = false
LC = #0a378a
        
MajorBuBoSLine_Show = 'On'
MajorBuBoSLine_Style = line.style_solid
MajorBuBoSLine_Color = color.rgb(8, 149, 48)

MajorBeBoSLine_Show = 'On'
MajorBeBoSLine_Style = line.style_solid
MajorBeBoSLine_Color = color.rgb(236, 4, 4)

MinorBuBoSLine_Show = 'Off'
MinorBuBoSLine_Style = line.style_dashed
MinorBuBoSLine_Color = color.black

MinorBeBoSLine_Show = 'Off'
MinorBeBoSLine_Style = line.style_dashed
MinorBeBoSLine_Color = color.black

MajorBuChoChLine_Show = 'On'
MajorBuChoChLine_Style = line.style_solid
MajorBuChoChLine_Color = color.rgb(8, 149, 48)

MajorBeChoChLine_Show = 'On'
MajorBeChoChLine_Style = line.style_solid
MajorBeChoChLine_Color = color.rgb(236, 4, 4)

MinorBuChoChLine_Show = 'Off'
MinorBuChoChLine_Style = line.style_dashed
MinorBuChoChLine_Color = color.black

MinorBeChoChLine_Show = 'Off'
MinorBeChoChLine_Style = line.style_dashed
MinorBeChoChLine_Color = color.black

// ================================
// التعديلات الجديدة لتجنب التعارض
// ================================

// استخدام arrays خاصة للرسم لتجنب التعارض
var line[] majorBosLines = array.new<line>()
var line[] majorChoChLines = array.new<line>()
var line[] minorBosLines = array.new<line>()
var line[] minorChoChLines = array.new<line>()

var label[] majorBosLabels = array.new<label>()
var label[] majorChoChLabels = array.new<label>()
var label[] minorBosLabels = array.new<label>()
var label[] minorChoChLabels = array.new<label>()
var label[] zigzagLabels = array.new<label>()
var line[] zigzagLines = array.new<line>()

// تنظيف الخطوط القديمة بشكل منتظم
cleanOldLines() =>
    if array.size(majorBosLines) > 50
        line.delete(array.shift(majorBosLines))
    if array.size(majorChoChLines) > 50
        line.delete(array.shift(majorChoChLines))
    if array.size(minorBosLines) > 50
        line.delete(array.shift(minorBosLines))
    if array.size(minorChoChLines) > 50
        line.delete(array.shift(minorChoChLines))
        
    if array.size(majorBosLabels) > 50
        label.delete(array.shift(majorBosLabels))
    if array.size(majorChoChLabels) > 50
        label.delete(array.shift(majorChoChLabels))
    if array.size(minorBosLabels) > 50
        label.delete(array.shift(minorBosLabels))
    if array.size(minorChoChLabels) > 50
        label.delete(array.shift(minorChoChLabels))
    if array.size(zigzagLabels) > 100
        label.delete(array.shift(zigzagLabels))
    if array.size(zigzagLines) > 100
        line.delete(array.shift(zigzagLines))

// دالة الرسم الآمن للخطوط
drawSafeLine(float price, int startIndex, string lineType, string trendType) =>
    cleanOldLines()
    
    color lineColor = color.white
    string lineText = ""
    string lineStyle = line.style_solid
    string labelPos = label.style_label_down  // التصحيح هنا
    
    // تحديد الإعدادات حسب النوع
    if lineType == "MajorBoS"
        if trendType == "Bull"
            if MajorBuBoSLine_Show == 'On'
                lineColor := MajorBuBoSLine_Color
                lineStyle := MajorBuBoSLine_Style
                lineText := "BoS"
        else
            if MajorBeBoSLine_Show == 'On'
                lineColor := MajorBeBoSLine_Color
                lineStyle := MajorBeBoSLine_Style  // التصحيح هنا
                lineText := "BoS"
                labelPos := label.style_label_up
                
    else if lineType == "MajorChoCh"
        if trendType == "Bull"
            if MajorBuChoChLine_Show == 'On'
                lineColor := MajorBuChoChLine_Color
                lineStyle := MajorBuChoChLine_Style
                lineText := "ChoCh"
        else
            if MajorBeChoChLine_Show == 'On'
                lineColor := MajorBeChoChLine_Color
                lineStyle := MajorBeChoChLine_Style
                lineText := "ChoCh"
                labelPos := label.style_label_up
    
    else if lineType == "MinorBoS"
        if trendType == "Bull"
            if MinorBuBoSLine_Show == 'On'
                lineColor := MinorBuBoSLine_Color
                lineStyle := MinorBuBoSLine_Style
                lineText := "Minor BoS"
        else
            if MinorBeBoSLine_Show == 'On'
                lineColor := MinorBeBoSLine_Color
                lineStyle := MinorBeBoSLine_Style
                lineText := "Minor BoS"
                labelPos := label.style_label_up
                
    else if lineType == "MinorChoCh"
        if trendType == "Bull"
            if MinorBuChoChLine_Show == 'On'
                lineColor := MinorBuChoChLine_Color
                lineStyle := MinorBuChoChLine_Style
                lineText := "Minor ChoCh"
        else
            if MinorBeChoChLine_Show == 'On'
                lineColor := MinorBeChoChLine_Color
                lineStyle := MinorBeChoChLine_Style
                lineText := "Minor ChoCh"
                labelPos := label.style_label_up
    
    // الرسم الفعلي
    if lineColor != color.white
        newLine = line.new(startIndex, price, bar_index, price, style = lineStyle, color = lineColor)
        newLabel = label.new((startIndex + bar_index) / 2, price, text = lineText, 
                           color = color.rgb(0, 0, 0, 100), textcolor = lineColor, 
                           style = labelPos, size = size.normal)
        
        // تخزين في المصفوفات المناسبة
        if lineType == "MajorBoS"
            array.push(majorBosLines, newLine)
            array.push(majorBosLabels, newLabel)
        else if lineType == "MajorChoCh"
            array.push(majorChoChLines, newLine)
            array.push(majorChoChLabels, newLabel)
        else if lineType == "MinorBoS"
            array.push(minorBosLines, newLine)
            array.push(minorBosLabels, newLabel)
        else if lineType == "MinorChoCh"
            array.push(minorChoChLines, newLine)
            array.push(minorChoChLabels, newLabel)

// دالة الرسم الآمن للـ ZigZag
drawZigZagSafe(int x1, float y1, int x2, float y2, string t1) =>
    if ShZ
        newZZLine = line.new(x1, y1, x2, y2, color = ZLC, style = ZLS, width = ZLW)
        array.push(zigzagLines, newZZLine)
    
    if ShL
        labelStyle = t1 == "L" or t1 == "LL" or t1 == "HL" or t1 == "mL" or t1 == "mLL" or t1 == "mHL" or t1 == "ML" or t1 == "MLL" or t1 == "MHL" ? 
             label.style_label_up : label.style_label_down
        newZZLabel = label.new(x = x2, y = y2, text = t1, color = color.rgb(255, 255, 255, 100), 
             style = labelStyle, textcolor = LC, size = size.small)
        array.push(zigzagLabels, newZZLabel)

// ... (بقية الكود يبقى كما هو بدون تغيير)

//Variables

    //ZigZag Data
Open = open
High = high
Low = low
Close = close 
Bar_Index = bar_index
ATR1 = ta.atr(55)
var ArrayType = array.new_string()
var ArrayValue = array.new_float()
var ArrayIndex = array.new_int()
var ArrayTypeAdv = array.new_string()
var ArrayValueAdv = array.new_float()
var ArrayIndexAdv = array.new_int()  
PASS = 0
HighPivot = ta.pivothigh(PP, PP)
LowPivot = ta.pivotlow(PP, PP)
HighValue = ta.valuewhen(HighPivot, High[PP], 0)
LowValue = ta.valuewhen(LowPivot, Low[PP], 0)
HighIndex = ta.valuewhen(HighPivot, Bar_Index[PP], 0)
LowIndex = ta.valuewhen(LowPivot, Bar_Index[PP], 0)
Correct_HighPivot = 0.0
Correct_LowPivot = 0.0

    //Major Levels
var float Major_HighLevel = na
var float Major_LowLevel = na

var int Major_HighIndex = na
var int Major_LowIndex = na

var string Major_HighType = na
var string Major_LowType = na

    //Minor Levels
var float Minor_HighLevel = na
var float Minor_LowLevel = na

var int Minor_HighIndex = na
var int Minor_LowIndex = na

var string Minor_HighType = na
var string Minor_LowType = na

var int LockDetecteM_MinorLvL = 0

    //
var bool Lock0 = true
var bool Lock1 = true

// Detecte Major & Minor Pivot
// Order Blocks Data
    //Major
var int LastMHH = 0
var int Last02MHH = 0
var int LastMLH = 0

var int LastMLL = 0
var int Last02MLL = 0
var int LastMHL = 0
    //Minor
var int LastmHH = 0
var int Last02mHH = 0
var int LastmLH = 0

var int LastmLL = 0
var int Last02mLL = 0
var int LastmHL = 0

/////////////////////////////
// Last Pivot First Point////
/////////////////////////////
var string LastPivotType = na
var int LastPivotIndex = 0

var string LastPivotType02 = na
var int LastPivotIndex02 = 0

    //Major 01
var float MajorHighValue01 = na
var int MajorHighIndex01 = na
var string MajorHighType01 = ''

var float MajorLowValue01 = na
var int MajorLowIndex01 = na
var string MajorLowType01 = ''

    //Minor 01
var float MinorHighValue01 = na
var int MinorHighIndex01 = na
var string MinorHighType01 = ''

var float MinorLowValue01 = na
var int MinorLowIndex01 = na
var string MinorLowType01 = ''

/////////////////////////////////////
//One to the Last Pivot First Point//
/////////////////////////////////////
    //Major 02
var float MajorHighValue02 = na
var int MajorHighIndex02 = na
var string MajorHighType02 = ''

var float MajorLowValue02 = na
var int MajorLowIndex02 = na
var string MajorLowType02 = ''

    //Minor 02
var float MinorHighValue02 = na
var int MinorHighIndex02 = na
var string MinorHighType02 = ''

var float MinorLowValue02 = na
var int MinorLowIndex02 = na
var string MinorLowType02 = ''

    //Major 02 Change Type Pivot
var float MajorHighValue02Ch = na
var int MajorHighIndex02Ch = na
var string MajorHighType02Ch = ''

var float MajorLowValue02Ch = na
var int MajorLowIndex02Ch = na
var string MajorLowType02Ch = ''

    // BoS & ChoCh Data
        //Major
var bool Bullish_Major_ChoCh = false
var bool Bullish_Major_BoS = false

var bool Bearish_Major_ChoCh = false
var bool Bearish_Major_BoS = false

var BoS_MajorType = array.new_string()
var BoS_MajorIndex = array.new_int()

var ChoCh_MajorType = array.new_string()
var ChoCh_MajorIndex = array.new_int()

var int LockBreak_M = 0 

        //Minor
var bool Bullish_Minor_ChoCh = false
var bool Bullish_Minor_BoS = false

var bool Bearish_Minor_ChoCh = false
var bool Bearish_Minor_BoS = false

var BoS_MinorType = array.new_string()
var BoS_MinorIndex = array.new_int()

var ChoCh_MinorType = array.new_string()
var ChoCh_MinorIndex = array.new_int()

var int LockBreak_m = 0 

    //Trend Data

var string ExternalTrend = 'No Trend'
var string InternalTrend = 'No Trend'

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////Calculation/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //{Zig Zag}
if HighPivot and LowPivot
    if ArrayType.size() == 0
        PASS := 1
    else if ArrayType.size() >= 1
        if ((ArrayType.get(ArrayType.size() - 1)) == "L" or
             (ArrayType.get(ArrayType.size() - 1)) == "LL")
            if LowPivot < ArrayValue.get(ArrayType.size() - 1)
                array.remove(ArrayType, ArrayType.size() - 1)
                array.remove(ArrayValue, ArrayValue.size() - 1)
                array.remove(ArrayIndex, ArrayIndex.size() - 1) 
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < LowValue ? "HL" : "LL" : "L")
                array.push(ArrayValue, LowValue)
                array.push(ArrayIndex, LowIndex)
                Correct_LowPivot := LowValue
            else 
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < HighValue ? "HH" : "LH" : "H")
                array.push(ArrayValue, HighValue)
                array.push(ArrayIndex, HighIndex)
            Correct_HighPivot := HighValue  
        else if (ArrayType.get(ArrayType.size() - 1)) == "H" or 
             (ArrayType.get(ArrayType.size() - 1)) == "HH"
            if HighPivot > ArrayValue.get(ArrayType.size() - 1)
                array.remove(ArrayType, ArrayType.size() - 1)
                array.remove(ArrayValue, ArrayValue.size() - 1)
                array.remove(ArrayIndex, ArrayIndex.size() - 1)
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < HighValue ? "HH" : "LH" : "H")
                array.push(ArrayValue, HighValue)
                array.push(ArrayIndex, HighIndex)
                Correct_HighPivot := HighValue  
            else 
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < LowValue ? "HL" : "LL" : "L")
                array.push(ArrayValue, LowValue)
                array.push(ArrayIndex, LowIndex)
            Correct_LowPivot := LowValue    
        else if (ArrayType.get(ArrayType.size() - 1)) == "LH"
            if HighPivot < ArrayValue.get(ArrayType.size() - 1)
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < LowValue ? "HL" : "LL" : "L")
                array.push(ArrayValue, LowValue)
                array.push(ArrayIndex, LowIndex)
                Correct_LowPivot := LowValue 
            else if HighPivot > ArrayValue.get(ArrayType.size() - 1)
                if close < ArrayValue.get(ArrayType.size() - 1)
                    array.remove(ArrayType, ArrayType.size() - 1)
                    array.remove(ArrayValue, ArrayValue.size() - 1)
                    array.remove(ArrayIndex, ArrayIndex.size() - 1)
                    array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < HighValue ? "HH" : "LH" : "H")
                    array.push(ArrayValue, HighValue)
                    array.push(ArrayIndex, HighIndex)
                    Correct_HighPivot := HighValue  
                else if close > ArrayValue.get(ArrayType.size() - 1)
                    array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < LowValue ? "HL" : "LL" : "L")
                    array.push(ArrayValue, LowValue)
                    array.push(ArrayIndex, LowIndex)
                    Correct_LowPivot := LowValue
        else if (ArrayType.get(ArrayType.size() - 1)) == "HL"
            if LowPivot > ArrayValue.get(ArrayType.size() - 1)
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < HighValue ? "HH" : "LH" : "H")
                array.push(ArrayValue, HighValue)
                array.push(ArrayIndex, HighIndex)
                Correct_HighPivot := HighValue                       
            else if LowPivot < ArrayValue.get(ArrayType.size() - 1)
                if close > ArrayValue.get(ArrayType.size() - 1)
                    array.remove(ArrayType, ArrayType.size() - 1)
                    array.remove(ArrayValue, ArrayValue.size() - 1)
                    array.remove(ArrayIndex, ArrayIndex.size() - 1) 
                    array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < LowValue ? "HL" : "LL" : "L")
                    array.push(ArrayValue, LowValue)
                    array.push(ArrayIndex, LowIndex)
                    Correct_LowPivot := LowValue
                else if close < ArrayValue.get(ArrayType.size() - 1)
                    array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < HighValue ? "HH" : "LH" : "H")
                    array.push(ArrayValue, HighValue)
                    array.push(ArrayIndex, HighIndex)
                    Correct_HighPivot := HighValue                         
else if HighPivot 
    if ArrayType.size() == 0
        array.insert(ArrayType, 0, "H")
        array.insert(ArrayValue, 0, HighValue)
        array.insert(ArrayIndex, 0, HighIndex)
        Correct_HighPivot := HighValue
    else if ArrayType.size() >= 1
        if ((ArrayType.get(ArrayType.size() - 1)) == "L" or
             (ArrayType.get(ArrayType.size() - 1)) == "HL" or
             (ArrayType.get(ArrayType.size() - 1)) == "LL")
            if HighPivot > ArrayValue.get(ArrayType.size() - 1)
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < HighValue ? "HH" : "LH" : "H")
                array.push(ArrayValue, HighValue)
                array.push(ArrayIndex, HighIndex)
                Correct_HighPivot := HighValue
            else if HighPivot < ArrayValue.get(ArrayType.size() - 1)
                array.remove(ArrayType, ArrayType.size() - 1)
                array.remove(ArrayValue, ArrayValue.size() - 1)
                array.remove(ArrayIndex, ArrayIndex.size() - 1) 
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < LowValue ? "HL" : "LL" : "L")
                array.push(ArrayValue, LowValue)
                array.push(ArrayIndex, LowIndex)
                Correct_LowPivot := LowValue                         
        else if (ArrayType.get(ArrayType.size() - 1)) == "H" or 
             (ArrayType.get(ArrayType.size() - 1)) == "HH" or 
             (ArrayType.get(ArrayType.size() - 1)) == "LH"
            if (ArrayValue.get(ArrayValue.size() - 1)) < HighValue
                array.remove(ArrayType, ArrayType.size() - 1)
                array.remove(ArrayValue, ArrayValue.size() - 1)
                array.remove(ArrayIndex, ArrayIndex.size() - 1)
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < HighValue ? "HH" : "LH" : "H")
                array.push(ArrayValue, HighValue)
                array.push(ArrayIndex, HighIndex)
                Correct_HighPivot := HighValue               
else if LowPivot 
    if ArrayType.size() == 0
        array.insert(ArrayType, 0, "L")
        array.insert(ArrayValue, 0, LowValue)
        array.insert(ArrayIndex, 0, LowIndex)
        Correct_LowPivot := LowValue
    else if ArrayType.size() >= 1
        if (ArrayType.get(ArrayType.size() - 1)) == "H" or 
             (ArrayType.get(ArrayType.size() - 1)) == "HH" or 
             (ArrayType.get(ArrayType.size() - 1)) == "LH"
            if LowPivot < ArrayValue.get(ArrayType.size() - 1)
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < LowValue ? "HL" : "LL" : "L")
                array.push(ArrayValue, LowValue)
                array.push(ArrayIndex, LowIndex)
                Correct_LowPivot := LowValue
            else if LowPivot > ArrayValue.get(ArrayType.size() - 1)
                array.remove(ArrayType, ArrayType.size() - 1)
                array.remove(ArrayValue, ArrayValue.size() - 1)
                array.remove(ArrayIndex, ArrayIndex.size() - 1)
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < HighValue ? "HH" : "LH" : "H")
                array.push(ArrayValue, HighValue)
                array.push(ArrayIndex, HighIndex)
                Correct_HighPivot := HighValue                        
        else if (ArrayType.get(ArrayType.size() - 1)) == "L" or 
             (ArrayType.get(ArrayType.size() - 1)) == "HL" or 
             (ArrayType.get(ArrayType.size() - 1)) == "LL"
            if (ArrayValue.get(ArrayValue.size() - 1)) > LowValue
                array.remove(ArrayType, ArrayType.size() - 1)
                array.remove(ArrayValue, ArrayValue.size() - 1)
                array.remove(ArrayIndex, ArrayIndex.size() - 1) 
                array.push(ArrayType, ArrayType.size() > 2 ? ArrayValue.get(ArrayType.size() - 2) < LowValue ? "HL" : "LL" : "L")
                array.push(ArrayValue, LowValue)
                array.push(ArrayIndex, LowIndex)
                Correct_LowPivot := LowValue

    //{Zig Zag Advance}

        //first Major & Minor Detector
if ArrayType.size() == 2
    if ArrayType.get(0) == 'H'
        Major_HighLevel := ArrayValue.get(0)
        Major_LowLevel := ArrayValue.get(1)
        Major_HighIndex := ArrayIndex.get(0)
        Major_LowIndex := ArrayIndex.get(1)
        Major_HighType := ArrayType.get(0)
        Major_LowType := ArrayType.get(1)
    else if ArrayType.get(0) == 'L'
        Major_HighLevel := ArrayValue.get(1)
        Major_LowLevel := ArrayValue.get(0) 
        Major_HighIndex := ArrayIndex.get(1)
        Major_LowIndex := ArrayIndex.get(0)
        Major_HighType := ArrayType.get(1)
        Major_LowType := ArrayType.get(0)

        //Making Copies of Arrays

if ArrayValue.size() == 1
    if Lock0
        array.insert(ArrayTypeAdv, 0, 'M' + ArrayType.get(0))
        array.insert(ArrayValueAdv, 0, ArrayValue.get(0))
        array.insert(ArrayIndexAdv, 0, ArrayIndex.get(0))   
        Lock0 := false

if ArrayValue.size() == 2
    if Lock1
        array.insert(ArrayTypeAdv, 1, 'M' + ArrayType.get(1))
        array.insert(ArrayValueAdv, 1, ArrayValue.get(1))
        array.insert(ArrayIndexAdv, 1, ArrayIndex.get(1))   
        Lock1 := false

if ArrayValue.size() > 1
    if ArrayValue.get(ArrayValue.size() - 1)[1] != ArrayValue.get(ArrayValue.size() - 1)
        if str.substring(ArrayType.get(ArrayType.size() - 1)[1], str.length(ArrayType.get(ArrayType.size() - 1)) - 1) != 
             str.substring(ArrayType.get(ArrayType.size() - 1), str.length(ArrayType.get(ArrayType.size() - 1)) - 1)
            array.push(ArrayTypeAdv, 'm' + ArrayType.get(ArrayType.size() - 1))
            array.push(ArrayValueAdv, ArrayValue.get(ArrayValue.size() - 1))
            array.push(ArrayIndexAdv, ArrayIndex.get(ArrayIndex.size() - 1))
        else if str.substring(ArrayType.get(ArrayType.size() - 1)[1], str.length(ArrayType.get(ArrayType.size() - 1)) - 1) == 
             str.substring(ArrayType.get(ArrayType.size() - 1), str.length(ArrayType.get(ArrayType.size() - 1)) - 1)
            array.remove(ArrayValueAdv, ArrayValueAdv.size() - 1)
            array.remove(ArrayIndexAdv, ArrayIndexAdv.size() - 1)
            array.push(ArrayValueAdv, ArrayValue.get(ArrayValue.size() - 1))
            array.push(ArrayIndexAdv, ArrayIndex.get(ArrayIndex.size() - 1))

        //All Major & Minor Pivot Detector 

if ArrayValueAdv.size() > 1
            //High Major Detector
    if close > Major_HighLevel
        if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mL'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('ML')
            Major_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHL'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('M' + ArrayType.get(ArrayType.size() - 1))      
            Major_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) 
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLL'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('M' + ArrayType.get(ArrayType.size() - 1)) 
            Major_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLH' or ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHH' or 
             ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MLH' or ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MHH' 
            if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mHL'
                ArrayTypeAdv.remove(ArrayTypeAdv.size() - 2)
                ArrayTypeAdv.insert(ArrayValueAdv.size() - 2, 'M' + ArrayType.get(ArrayType.size() - 2))      
                Major_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                Major_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                Major_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
            else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mLL'
                ArrayTypeAdv.remove(ArrayTypeAdv.size() - 2)
                ArrayTypeAdv.insert(ArrayValueAdv.size() - 2, 'M' + ArrayType.get(ArrayType.size() - 2))
                Major_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                Major_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                Major_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    if ArrayValueAdv.get(ArrayValueAdv.size() - 1) > Major_HighLevel
        if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mH'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('MH')
            Major_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLH'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('M' + ArrayType.get(ArrayType.size() - 1))  
            Major_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)     
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHH' or ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MHH'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('M' + ArrayType.get(ArrayType.size() - 1))
            Major_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)

            //Low Major Detector
    if close < Major_LowLevel
        if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mH'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('MH')
            Major_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLH'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('M' + ArrayType.get(ArrayType.size() - 1))      
            Major_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHH'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('M' + ArrayType.get(ArrayType.size() - 1))
            Major_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHL' or ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLL' or 
             ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MHL' or ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MLL'
            if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mLH'
                ArrayTypeAdv.remove(ArrayTypeAdv.size() - 2)
                ArrayTypeAdv.insert(ArrayValueAdv.size() - 2, 'M' + ArrayType.get(ArrayType.size() - 2))      
                Major_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                Major_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                Major_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
            else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mHH'
                ArrayTypeAdv.remove(ArrayTypeAdv.size() - 2)
                ArrayTypeAdv.insert(ArrayValueAdv.size() - 2, 'M' + ArrayType.get(ArrayType.size() - 2))
                Major_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                Major_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                Major_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    if ArrayValueAdv.get(ArrayValueAdv.size() - 1) < Major_LowLevel
        if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mL'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('ML')
            Major_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)

        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHL'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('M' + ArrayType.get(ArrayType.size() - 1)) 
            Major_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLL' or ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MLL'
            ArrayTypeAdv.remove(ArrayTypeAdv.size() - 1)
            ArrayTypeAdv.push('M' + ArrayType.get(ArrayType.size() - 1))
            Major_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
            Major_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
            Major_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)

if ArrayTypeAdv.size() >= 2
    X1 = ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
    Y1 = ArrayValueAdv.get(ArrayIndexAdv.size() - 2)
    X2 = ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
    Y2 = ArrayValueAdv.get(ArrayIndexAdv.size() - 1)
    T1 = ArrayTypeAdv.get(ArrayIndexAdv.size() - 1)

    // استخدام الدالة الآمنة للرسم بدلاً من الرسم المباشر
    drawZigZagSafe(X1, Y1, X2, Y2, T1)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Get Pivot Data
        //Last Pivot Data
if ArrayTypeAdv.size() > 1
    LastPivotType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
    LastPivotIndex := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
    LastPivotType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
    LastPivotIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        //Major
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MHH'
        MajorHighValue01 := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
        MajorHighIndex01 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
        MajorHighType01 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        LastMHH := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)

    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MLH'
        MajorHighValue01 := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
        MajorHighIndex01 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
        MajorHighType01 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        LastMLH := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MLL'
        MajorLowValue01 := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
        MajorLowIndex01 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
        MajorLowType01 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        LastMLL := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'MHL'
        MajorLowValue01 := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
        MajorLowIndex01 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
        MajorLowType01 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        LastMHL := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
    
        //Minor
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHH'
        MinorHighValue01 := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
        MinorHighIndex01 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
        MinorHighType01 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        LastmHH := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLH'
        MinorHighValue01 := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
        MinorHighIndex01 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
        MinorHighType01 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        LastmLH := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLL'
        MinorLowValue01 := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
        MinorLowIndex01 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
        MinorLowType01 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        LastmLL := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHL'
        MinorLowValue01 := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
        MinorLowIndex01 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
        MinorLowType01 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
        LastmHL := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)

    //One to the Last Pivot Data
if ArrayTypeAdv.size() > 1
        //Major
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'MHH'
        MajorHighValue02 := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
        MajorHighIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        MajorHighType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'MLH'
        MajorHighValue02 := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
        MajorHighIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        MajorHighType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'MLL'
        MajorLowValue02 := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
        MajorLowIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        MajorLowType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'MHL'
        MajorLowValue02 := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
        MajorLowIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        MajorLowType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    
        //Minor
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mHH'
        MinorHighValue02 := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
        MinorHighIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        MinorHighType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mLH'
        MinorHighValue02 := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
        MinorHighIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        MinorHighType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mLL'
        MinorLowValue02 := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
        MinorLowIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        MinorLowType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mHL'
        MinorLowValue02 := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
        MinorLowIndex02 := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
        MinorLowType02 := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

        // Change Pivot Type to Major
    if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) != ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)[1] // Change Pivot Type to Major
        //Major
        if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'MHH'
            MajorHighValue02Ch := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
            MajorHighIndex02Ch := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
            MajorHighType02Ch := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

        if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'MLH'
            MajorHighValue02Ch := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
            MajorHighIndex02Ch := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
            MajorHighType02Ch := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

        if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'MLL'
            MajorLowValue02Ch := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
            MajorLowIndex02Ch := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
            MajorLowType02Ch := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

        if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'MHL'
            MajorLowValue02Ch := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
            MajorLowIndex02Ch := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
            MajorLowType02Ch := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    // Detecte Minor level

if ArrayTypeAdv.size() > 2  
    LockDetecteM_MinorLvL := 1
    if str.pos(ArrayTypeAdv.get(ArrayTypeAdv.size() - 1), 'm') == 0 and
     str.pos(ArrayTypeAdv.get(ArrayTypeAdv.size() - 2), 'm') == 0 and
     str.pos(ArrayTypeAdv.get(ArrayTypeAdv.size() - 3), 'M') == 0
        if str.pos(ArrayTypeAdv.get(ArrayTypeAdv.size() - 1), 'H') == 2
            Minor_HighLevel := ArrayValueAdv.get(ArrayTypeAdv.size() - 1)
            Minor_LowLevel := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
            Minor_HighIndex := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
            Minor_LowIndex := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
            Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
            Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
        else if str.pos(ArrayTypeAdv.get(ArrayTypeAdv.size() - 1), 'L') == 2
            Minor_HighLevel := ArrayValueAdv.get(ArrayTypeAdv.size() - 2)
            Minor_LowLevel := ArrayValueAdv.get(ArrayTypeAdv.size() - 1) 
            Minor_HighIndex := ArrayIndexAdv.get(ArrayTypeAdv.size() - 2)
            Minor_LowIndex := ArrayIndexAdv.get(ArrayTypeAdv.size() - 1)
            Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
            Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
    if LockDetecteM_MinorLvL == 1
        //High Minor Detector
        if close > Minor_HighLevel

            if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHL'     
                Minor_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
                Minor_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
                Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) 
            else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLL'
                Minor_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
                Minor_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
                Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
            else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLH' or ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHH'
                if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mHL'     
                    Minor_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                    Minor_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                    Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
                else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mLL'
                    Minor_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                    Minor_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                    Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
                    

        if ArrayValueAdv.get(ArrayValueAdv.size() - 1) > Minor_HighLevel

            if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLH' 
                Minor_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
                Minor_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
                Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) 
                Minor_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                Minor_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)                    
            else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHH'
                Minor_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
                Minor_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
                Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
                Minor_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                Minor_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

        //Low Minor Detector
        if close < Minor_LowLevel

            if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLH'     
                Minor_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
                Minor_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
                Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
            else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHH'
                Minor_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
                Minor_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
                Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
            else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHL' or ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLL'
                if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mLH'     
                    Minor_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                    Minor_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                    Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
                else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 2) == 'mHH'
                    Minor_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                    Minor_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                    Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

        if ArrayValueAdv.get(ArrayValueAdv.size() - 1) < Minor_LowLevel
            if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mHL' 
                Minor_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
                Minor_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
                Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
                Minor_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                Minor_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)
            else if ArrayTypeAdv.get(ArrayTypeAdv.size() - 1) == 'mLL' 
                Minor_LowLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 1)
                Minor_LowIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 1)
                Minor_LowType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 1)
                Minor_HighLevel := ArrayValueAdv.get(ArrayValueAdv.size() - 2)
                Minor_HighIndex := ArrayIndexAdv.get(ArrayIndexAdv.size() - 2)
                Minor_HighType := ArrayTypeAdv.get(ArrayTypeAdv.size() - 2)

    //Reset Minor Levels
    if str.pos(ArrayTypeAdv.get(ArrayTypeAdv.size() - 1), 'M') == 0
        LockDetecteM_MinorLvL := 0
        Minor_HighLevel := na
        Minor_LowLevel := na
        Minor_HighIndex := na
        Minor_LowIndex := na
        Minor_HighType := na
        Minor_LowType := na
        InternalTrend := 'No Trend'

    //ChoCh and BoS Detector
        //Bos and ChoCh Line
            //Major

if ta.crossover(close, Major_HighLevel) and LockBreak_M != Major_HighIndex // Bullish BoS Detector
    if (ExternalTrend == 'No Trend' or ExternalTrend == 'Up Trend')
        Bullish_Major_BoS := true
        BoS_MajorType.push('Bull Major BoS')
        BoS_MajorIndex.push(bar_index)
        LockBreak_M := Major_HighIndex
        ExternalTrend := 'Up Trend'
        // استخدام الدالة الجديدة للرسم الآمن
        drawSafeLine(Major_HighLevel, Major_HighIndex, "MajorBoS", "Bull")
    else if ExternalTrend == 'Down Trend' // Bullish ChoCh Detector
        Bullish_Major_ChoCh := true
        ChoCh_MajorType.push('Bull Major ChoCh')
        ChoCh_MajorIndex.push(bar_index)
        LockBreak_M := Major_HighIndex
        ExternalTrend := 'Up Trend'
        // استخدام الدالة الجديدة للرسم الآمن
        drawSafeLine(Major_HighLevel, Major_HighIndex, "MajorChoCh", "Bull")
else
    Bullish_Major_ChoCh := false
    Bullish_Major_BoS := false 

if ta.crossunder(close, Major_LowLevel) and LockBreak_M != Major_LowIndex // Bearish BoS Detector
    if ExternalTrend == 'No Trend' or ExternalTrend == 'Down Trend'
        Bearish_Major_BoS := true
        BoS_MajorType.push('Bear Major BoS')
        BoS_MajorIndex.push(bar_index)
        LockBreak_M := Major_LowIndex
        ExternalTrend := 'Down Trend'
        // استخدام الدالة الجديدة للرسم الآمن
        drawSafeLine(Major_LowLevel, Major_LowIndex, "MajorBoS", "Bear")
    else if ExternalTrend == 'Up Trend' // Bearish ChoCh Detector
        Bearish_Major_ChoCh := true
        ChoCh_MajorType.push('Bear Major ChoCh')
        ChoCh_MajorIndex.push(bar_index)
        LockBreak_M := Major_LowIndex
        ExternalTrend := 'Down Trend'
        // استخدام الدالة الجديدة للرسم الآمن
        drawSafeLine(Major_LowLevel, Major_LowIndex, "MajorChoCh", "Bear")
else 
    Bearish_Major_ChoCh := false 
    Bearish_Major_BoS := false

            //Minor

if Minor_HighLevel < close and LockBreak_m != Minor_HighIndex // Bullish BoS Detector
    if (InternalTrend == 'No Trend' or InternalTrend == 'Up Trend') 
        Bullish_Minor_BoS := true
        BoS_MinorType.push('Bull Minor BoS')
        BoS_MinorIndex.push(bar_index)
        LockBreak_m := Minor_HighIndex
        InternalTrend := 'Up Trend'
        // استخدام الدالة الجديدة للرسم الآمن
        drawSafeLine(Minor_HighLevel, Minor_HighIndex, "MinorBoS", "Bull")
    else if InternalTrend == 'Down Trend' // Bullish ChoCh Detector
        Bullish_Minor_ChoCh := true
        ChoCh_MinorType.push('Bull Minor ChoCh')
        ChoCh_MinorIndex.push(bar_index)
        LockBreak_m := Minor_HighIndex
        InternalTrend := 'Up Trend'
        // استخدام الدالة الجديدة للرسم الآمن
        drawSafeLine(Minor_HighLevel, Minor_HighIndex, "MinorChoCh", "Bull")
else 
    Bullish_Minor_ChoCh := false
    Bullish_Minor_BoS := false

if Minor_LowLevel > close and LockBreak_m != Minor_LowIndex // Bearish BoS Detector
    if InternalTrend == 'No Trend' or InternalTrend == 'Down Trend'
        Bearish_Minor_BoS := true
        BoS_MinorType.push('Bear Minor BoS')
        BoS_MinorIndex.push(bar_index)
        LockBreak_m := Minor_LowIndex
        InternalTrend := 'Down Trend'
        // استخدام الدالة الجديدة للرسم الآمن
        drawSafeLine(Minor_LowLevel, Minor_LowIndex, "MinorBoS", "Bear")
    else if InternalTrend == 'Up Trend' // Bearish ChoCh Detector
        Bearish_Minor_ChoCh := true
        ChoCh_MinorType.push('Bear Minor ChoCh')
        ChoCh_MinorIndex.push(bar_index)
        LockBreak_m := Minor_LowIndex
        InternalTrend := 'Down Trend'
        // استخدام الدالة الجديدة للرسم الآمن
        drawSafeLine(Minor_LowLevel, Minor_LowIndex, "MinorChoCh", "Bear")
else
    Bearish_Minor_ChoCh := false
    Bearish_Minor_BoS := false

// تنظيف نهائي عند إغلاق الشارت
if barstate.islast
    cleanOldLines()

// HIDDEN SETTINGS (Internal use only)
//
swing_length = 10
history_of_demand_to_keep = 20
box_width = 2.5

supply_color = color.new(#f74316, 20)
supply_outline_color = color.new(color.white, 75)
demand_color = color.new(#05ec69, 20)
demand_outline_color = color.new(color.white, 75)
bos_label_color = color.white
poi_label_color = color.white

//
// FUNCTIONS
//

f_array_add_pop(array, new_value_to_add) =>
    array.unshift(array, new_value_to_add)
    array.pop(array)

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
        box.delete(array.get(box_array, array.size(box_array) - 1))
        f_array_add_pop(box_array, box.new(left=box_left, top=box_top, right=box_right, bottom=box_bottom, border_color=supply_outline_color,
             bgcolor=supply_color, extend=extend.right, text='SUPPLY', text_halign=text.align_center, text_valign=text.align_center, text_color=poi_label_color, text_size=size.small, xloc=xloc.bar_index))
        
        box.delete(array.get(label_array, array.size(label_array) - 1))
        f_array_add_pop(label_array, box.new(left=box_left, top=poi, right=box_right, bottom=poi, border_color=color.new(poi_label_color,90),
             bgcolor=color.new(poi_label_color,90), extend=extend.right, text='POI', text_halign=text.align_left, text_valign=text.align_center, text_color=poi_label_color, text_size=size.small, xloc=xloc.bar_index))

    else if box_type == -1 and okay_to_draw
        box.delete(array.get(box_array, array.size(box_array) - 1))
        f_array_add_pop(box_array, box.new(left=box_left, top=box_top, right=box_right, bottom=box_bottom, border_color=demand_outline_color,
             bgcolor=demand_color, extend=extend.right, text='DEMAND', text_halign=text.align_center, text_valign=text.align_center, text_color=poi_label_color, text_size=size.small, xloc=xloc.bar_index))
        
        box.delete(array.get(label_array, array.size(label_array) - 1))
        f_array_add_pop(label_array, box.new(left=box_left, top=poi, right=box_right, bottom=poi, border_color=color.new(poi_label_color,90),
             bgcolor=color.new(poi_label_color,90), extend=extend.right, text='POI', text_halign=text.align_left, text_valign=text.align_center, text_color=poi_label_color, text_size=size.small, xloc=xloc.bar_index))

// تم تعديل هذه الدالة لإخفاء BOS مع الحفاظ على المنطق
f_sd_to_bos(box_array, bos_array, label_array, zone_type) =>
    if zone_type == 1
        for i = 0 to array.size(box_array) - 1
            level_to_break = box.get_top(array.get(box_array,i))
            if close >= level_to_break
                // تم التعليق على إنشاء BOS لإخفائه مع الحفاظ على المنطق
                // copied_box = box.copy(array.get(box_array,i))
                // f_array_add_pop(bos_array, copied_box)
                // mid = (box.get_top(array.get(box_array,i)) + box.get_bottom(array.get(box_array,i))) / 2
                // box.set_top(array.get(bos_array,0), mid)
                // box.set_bottom(array.get(bos_array,0), mid)
                // box.set_extend(array.get(bos_array,0), extend.none)
                // box.set_right(array.get(bos_array,0), bar_index)
                // box.set_text(array.get(bos_array,0), 'BOS')
                // box.set_text_color(array.get(bos_array,0), bos_label_color)
                // box.set_text_size(array.get(bos_array,0), size.small)
                // box.set_text_halign(array.get(bos_array,0), text.align_center)
                // box.set_text_valign(array.get(bos_array,0), text.align_center)
                box.delete(array.get(box_array, i))
                box.delete(array.get(label_array, i))

    if zone_type == -1
        for i = 0 to array.size(box_array) - 1
            level_to_break = box.get_bottom(array.get(box_array,i))
            if close <= level_to_break
                // تم التعليق على إنشاء BOS لإخفائه مع الحفاظ على المنطق
                // copied_box = box.copy(array.get(box_array,i))
                // f_array_add_pop(bos_array, copied_box)
                // mid = (box.get_top(array.get(box_array,i)) + box.get_bottom(array.get(box_array,i))) / 2
                // box.set_top(array.get(bos_array,0), mid)
                // box.set_bottom(array.get(bos_array,0), mid)
                // box.set_extend(array.get(bos_array,0), extend.none)
                // box.set_right(array.get(bos_array,0), bar_index)
                // box.set_text(array.get(bos_array,0), 'BOS')
                // box.set_text_color(array.get(bos_array,0), bos_label_color)
                // box.set_text_size(array.get(bos_array,0), size.small)
                // box.set_text_halign(array.get(bos_array,0), text.align_center)
                // box.set_text_valign(array.get(bos_array,0), text.align_center)
                box.delete(array.get(box_array, i))
                box.delete(array.get(label_array, i))

f_extend_box_endpoint(box_array) =>
    for i = 0 to array.size(box_array) - 1
        box.set_right(array.get(box_array, i), bar_index + 100)

//
// CALCULATIONS
//

atr2 = ta.atr(50)
swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low = ta.pivotlow(low, swing_length, swing_length)

var swing_high_values = array.new_float(5, 0.00)
var swing_low_values = array.new_float(5, 0.00)
var swing_high_bns = array.new_int(5, 0)
var swing_low_bns = array.new_int(5, 0)

var current_supply_box = array.new_box(history_of_demand_to_keep, na)
var current_demand_box = array.new_box(history_of_demand_to_keep, na)
var current_supply_poi = array.new_box(history_of_demand_to_keep, na)
var current_demand_poi = array.new_box(history_of_demand_to_keep, na)

// تم إبقاء المصفوفات لكن لن تستخدم لعرض BOS
var supply_bos = array.new_box(5, na)
var demand_bos = array.new_box(5, na)

//
// MAIN LOGIC
//

if not na(swing_high)
    f_array_add_pop(swing_high_values, swing_high)
    f_array_add_pop(swing_high_bns, bar_index[swing_length])
    f_supply_demand(swing_high_values, swing_high_bns, current_supply_box, current_supply_poi, 1, atr)

else if not na(swing_low)
    f_array_add_pop(swing_low_values, swing_low)
    f_array_add_pop(swing_low_bns, bar_index[swing_length])
    f_supply_demand(swing_low_values, swing_low_bns, current_demand_box, current_demand_poi, -1, atr)

// استمرار استدعاء الدوال للحفاظ على المنطق لكن BOS مخفي
f_sd_to_bos(current_supply_box, supply_bos, current_supply_poi, 1)
f_sd_to_bos(current_demand_box, demand_bos, current_demand_poi, -1)

f_extend_box_endpoint(current_supply_box)
f_extend_box_endpoint(current_demand_box)




const bool DEBUG1 = false
const int maxBoxesCount = 500
const int maxRowSize = 50



// الإعدادات المرئية فقط
analyzeBars = input.int(200, "عدد الشموع المطلوب حساب الفوليوم فيها", minval = 1, maxval = 1000, group = "General Configuration")
POCEnabled = input.bool(false, "POC Line", group = "Style")

// إخفاء جميع الإعدادات الأخرى
rowCount = 30
volumeWeight = "Normal"
dbgMode = "Normal"
dbgSwingLen = 20
alignSetting = "Left"
POCLineStyle = "____"
POCLineWidth = 2
POCLineColor = color.yellow
bullishColor = color.green
bearishColor = color.red
intersectionBody = false

type rowType
    float top
    float bottom
    int startIndex
    int endIndex
    float totalVolume = 0
    float bullVolume = 0
    float bearVolume = 0

    box bullBox = na
    box bearBox = na

type barType
    float o = open
    float c = close
    float h = high
    float l = low
    float v = volume

var float validPivotHigh = 0
validPivotHigh := nz(ta.pivothigh(dbgSwingLen, dbgSwingLen), validPivotHigh)

var float validPivotLow = 0
validPivotLow := nz(ta.pivotlow(dbgSwingLen, dbgSwingLen), validPivotLow)

float top = (dbgMode == "Normal" ? ta.highest(analyzeBars) : validPivotHigh)
float bottom = (dbgMode == "Normal" ? ta.lowest(analyzeBars) : validPivotLow)

float step = (top - bottom) / rowCount
float gap = rowCount < 100 ? (step / 3.0) : 0

safeDeleteRow (rowType row) =>
    box.delete(row.bullBox)
    box.delete(row.bearBox)

var array<rowType> rows = na
if not na(rows)
    for i = 0 to rows.size() - 1
        safeDeleteRow(rows.get(i))

rows := array.new<rowType>(rowCount)
for x = 0 to rowCount - 1
    rowTop = top - step * x
    rows.set(x, rowType.new(rowTop, rowTop - step))

doIntersect (candleTop, candleBottom, rowType row) =>
    if (candleBottom > row.top)
        false
    else if (candleTop < row.bottom)
        false
    else
        true

var float maxVolumeSize = 0
var float minVolumeSize = 0

f_lin_interpolate(x0, y0, x1, y1, x) =>
    y0 + (x - x0) * (y1 - y0) / (x1 - x0)

renderRow (startIndex, flip, rowType row) =>
    totalSize = f_lin_interpolate(minVolumeSize, 1, maxVolumeSize, maxRowSize, row.totalVolume)
    bullSize = math.round((row.bullVolume / row.totalVolume) * totalSize)
    bearSize = math.round((row.bearVolume / row.totalVolume) * totalSize)
    row.startIndex := startIndex
    if not flip
        row.endIndex := startIndex + bullSize + bearSize
        row.bullBox := box.new(startIndex, row.top - gap / 2.0, startIndex + bullSize, row.bottom + gap / 2.0, bgcolor = bullishColor, border_color = color.black, border_width = 0)
        if bearSize > 0
            row.bearBox := box.new(startIndex + bullSize, row.top - gap / 2.0, startIndex + bullSize + bearSize, row.bottom + gap / 2.0, bgcolor = bearishColor, border_color = color.black, border_width = 0)
    else
        row.endIndex := startIndex - bullSize - bearSize
        row.bullBox := box.new(startIndex, row.top - gap / 2.0, startIndex - bullSize, row.bottom + gap / 2.0, bgcolor = bullishColor, border_color = color.black, border_width = 0)
        if bearSize > 0
            row.bearBox := box.new(startIndex- bullSize, row.top - gap / 2.0, startIndex - bullSize - bearSize, row.bottom + gap / 2.0, bgcolor = bearishColor, border_color = color.black, border_width = 0)

curIndex = bar_index

var line POCLine = na
const float weightImpact = 0.85

if barstate.islast
    if rows.size() > 0
        for i = 0 to analyzeBars
            for j = 0 to rows.size() - 1
                curRow = rows.get(j)
                vol = volume[i]
                
                if volumeWeight == "Recent"
                    vol := ((vol * weightImpact) / (i + 1)) + (vol * (1.0 - weightImpact))
                
                if volumeWeight == "Past"
                    vol := ((vol * weightImpact) * ((i + 1) / analyzeBars)) + (vol * (1.0 - weightImpact))
                
                if doIntersect(intersectionBody ? math.max(open[i], close[i]) : high[i], intersectionBody ? math.min(open[i], close[i]) : low[i], curRow)
                    if close[i] > open[i]
                        curRow.bullVolume += vol
                    else
                        curRow.bearVolume += vol
                    curRow.totalVolume += vol
    //
    rowType maxVolRow = na
    if rows.size() > 0
        maxVolumeSize := 0
        minVolumeSize := rows.get(0).totalVolume
        
        for i = 0 to rows.size() - 1
            curRow = rows.get(i)
            maxVolumeSize := math.max(maxVolumeSize, curRow.totalVolume)
            if curRow.totalVolume == maxVolumeSize
                maxVolRow := curRow
            minVolumeSize := math.min(minVolumeSize, curRow.totalVolume)

        for i = 0 to rows.size() - 1
            curRow = rows.get(i)
            startIndex = alignSetting == "Right" ? (curIndex - analyzeBars + 1) : (curIndex + 120)
            renderRow(startIndex, alignSetting == "Right" ? false : true, curRow)
    
    line.delete(POCLine)
    if not na(maxVolRow)
        maxRowMid = (maxVolRow.top + maxVolRow.bottom) / 2.0
        if POCEnabled
            if alignSetting == "left"
                POCLine := line.new(maxVolRow.endIndex, maxRowMid, bar_index, maxRowMid, extend = extend.right, width = POCLineWidth, color = POCLineColor, style = POCLineStyle == "____" ? line.style_solid : POCLineStyle == "----" ? line.style_dashed : line.style_dotted)
            else
                POCLine := line.new(bar_index, maxRowMid, maxVolRow.endIndex, maxRowMid, extend = extend.left, width = POCLineWidth, color = POCLineColor, style = POCLineStyle == "____" ? line.style_solid : POCLineStyle == "----" ? line.style_dashed : line.style_dotted)

// ======================================================================
// PART 3: Advanced UT-Trail System Pro [identityKa]
// ======================================================================

// ==========================================
// 1. USER INPUTS (GLOBAL ENGLISH)
// ==========================================
grp1 = "⚙️ UT-Trail Settings"
ut_a = input.float(2.0, title="Base Key Value (Sensitivity)", step=0.5, group=grp1)
ut_c = input.int(10, title="ATR Period", minval=1, group=grp1)
h = input.bool(true, title="Use Heikin-Ashi Filtering", group=grp1, tooltip="Filters out market noise. (Tip: Turn off for absolute zero-lag on 1m/5m charts).")

grp2 = "🧠 Auto-Adaptive AI"
auto_adapt = input.bool(true, "Auto-Adapt to Timeframe", group=grp2, tooltip="Automatically speeds up the sensitivity on lower timeframes (15m, 1H) to eliminate lag.")

grp3 = "🎯 Take-Profit & Theme"
show_tp = input.bool(true, "Show Auto Take-Profit Targets", group=grp3)
tp1_mult = input.float(1.5, "TP1 Multiplier (ATR)", group=grp3)
tp2_mult = input.float(3.0, "TP2 Multiplier (ATR)", group=grp3)
col_buy = input.color(#00ffbb, title="Buy Signal (Green)", group=grp3)
col_sell = input.color(#ff1744, title="Sell Signal (Red)", group=grp3)

grp4 = "📊 HUD Dashboard Settings"
show_dash = input.bool(true, "Show Dashboard", group=grp4)
dash_pos = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group=grp4)
dash_size = input.string("Small", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grp4)

// ==========================================
// 2. AUTO-ADAPTIVE TIMEFRAME ENGINE
// ==========================================
tf_mins = timeframe.in_seconds(timeframe.period) / 60

float dyn_a = ut_a
string mode_str = "SWING (Macro)"

if auto_adapt
    if tf_mins <= 15
        dyn_a := math.max(0.5, ut_a * 0.6)
        mode_str := "SCALP (Micro)"
    else if tf_mins <= 60
        dyn_a := math.max(0.5, ut_a * 0.8)
        mode_str := "DAY (Intraday)"

// ==========================================
// 3. MATHEMATICAL ENGINE (ATR & HA)
// ==========================================
ut_src = h ? request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead=barmerge.lookahead_off) : close

ut_atr = ta.atr(ut_c)
nLoss = dyn_a * ut_atr

var float xATRTrailingStop = 0.0
xATRTrailingStop := ut_src > nz(xATRTrailingStop[1], 0) and ut_src[1] > nz(xATRTrailingStop[1], 0) ? math.max(nz(xATRTrailingStop[1]), ut_src - nLoss) : ut_src < nz(xATRTrailingStop[1], 0) and ut_src[1] < nz(xATRTrailingStop[1], 0) ? math.min(nz(xATRTrailingStop[1]), ut_src + nLoss) : ut_src > nz(xATRTrailingStop[1], 0) ? ut_src - nLoss : ut_src + nLoss

var int ut_pos = 0
ut_pos := ut_src[1] < nz(xATRTrailingStop[1], 0) and ut_src > nz(xATRTrailingStop[1], 0) ? 1 : ut_src[1] > nz(xATRTrailingStop[1], 0) and ut_src < nz(xATRTrailingStop[1], 0) ? -1 : nz(ut_pos[1], 0)

ut_ema = ta.ema(ut_src, 1)
above = ta.crossover(ut_ema, xATRTrailingStop)
below = ta.crossunder(ut_ema, xATRTrailingStop)

valid_buy = ut_src > xATRTrailingStop and above
valid_sell = ut_src < xATRTrailingStop and below

// ==========================================
// 4. VISUALIZATION: LINES & LABELS
// ==========================================
trail_color = ut_pos == 1 ? col_buy : col_sell
plot(xATRTrailingStop, title="Trailing Stop Line", color=trail_color, linewidth=2, style=plot.style_stepline)
barcolor(ut_pos == 1 ? col_buy : col_sell, title="Trend Candle Colors")

plotshape(valid_buy, title="BUY", text="BUY", style=shape.labelup, location=location.belowbar, color=col_buy, textcolor=color.black, size=size.small)
plotshape(valid_sell, title="SELL", text="SELL", style=shape.labeldown, location=location.abovebar, color=col_sell, textcolor=color.white, size=size.small)

// ==========================================
// 5. AUTO TAKE-PROFIT ENGINE
// ==========================================
var line[] tp_lines = array.new_line()
var label[] tp_labels = array.new_label()

if valid_buy or valid_sell
    if array.size(tp_lines) > 0
        for i = 0 to array.size(tp_lines) - 1
            line.delete(array.get(tp_lines, i))
            label.delete(array.get(tp_labels, i))
        array.clear(tp_lines)
        array.clear(tp_labels)

    if show_tp
        is_b = valid_buy
        tp1_val = is_b ? close + (ut_atr * tp1_mult) : close - (ut_atr * tp1_mult)
        tp2_val = is_b ? close + (ut_atr * tp2_mult) : close - (ut_atr * tp2_mult)
        
        l1 = line.new(bar_index, tp1_val, bar_index + 30, tp1_val, color=color.gray, style=line.style_dashed)
        lbl1 = label.new(bar_index + 30, tp1_val, "TP1", color=color.new(color.white,100), textcolor=color.gray, style=label.style_label_left, size=size.small)
        
        l2 = line.new(bar_index, tp2_val, bar_index + 30, tp2_val, color=is_b ? col_buy : col_sell, style=line.style_dashed)
        lbl2 = label.new(bar_index + 30, tp2_val, "TP2", color=color.new(color.white,100), textcolor=is_b ? col_buy : col_sell, style=label.style_label_left, size=size.small)
        
        array.push(tp_lines, l1), array.push(tp_labels, lbl1)
        array.push(tp_lines, l2), array.push(tp_labels, lbl2)

// ==========================================
// 6. HUD DASHBOARD & AI LOGIC
// ==========================================
var string p_pos = dash_pos == "Top Right" ? position.top_right : dash_pos == "Top Left" ? position.top_left : dash_pos == "Bottom Right" ? position.bottom_right : dash_pos == "Bottom Left" ? position.bottom_left : dash_pos == "Middle Right" ? position.middle_right : position.middle_left
var string p_size = dash_size == "Tiny" ? size.tiny : dash_size == "Small" ? size.small : dash_size == "Normal" ? size.normal : size.large

var table hud = table.new(p_pos, 2, 4, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 80))

bool is_testing_stop = (ut_pos == 1 and close < xATRTrailingStop + (ut_atr * 0.2)) or (ut_pos == -1 and close > xATRTrailingStop - (ut_atr * 0.2))
string ai_suggestion = is_testing_stop ? "Dangerous" : ut_pos == 1 ? "LONG" : "SHORT"
color ai_color = ai_suggestion == "LONG" ? col_buy : ai_suggestion == "SHORT" ? col_sell : color.new(#ff9800, 0)

if barstate.islast and show_dash
    table.cell(hud, 0, 0, "ENGINE MODE", text_color=color.gray, text_size=p_size)
    table.cell(hud, 1, 0, mode_str, text_color=color.yellow, text_size=p_size)
    
    table.cell(hud, 0, 1, "UT-TRAIL STATE", text_color=color.gray, text_size=p_size)
    table.cell(hud, 1, 1, ut_pos == 1 ? "BULLISH" : "BEARISH", text_color=ut_pos == 1 ? col_buy : col_sell, text_size=p_size)
    
    table.cell(hud, 0, 2, "VOLATILITY (ATR)", text_color=color.gray, text_size=p_size)
    table.cell(hud, 1, 2, str.tostring(ut_atr, "#.####"), text_color=color.white, text_size=p_size)

    table.cell(hud, 0, 3, "AI SUGGESTION", text_color=color.gray, text_size=p_size)
    table.cell(hud, 1, 3, ai_suggestion, text_color=ai_color, text_size=p_size)

// ==========================================
// 7. ALERTS
// ==========================================
alertcondition(valid_buy, "🟢 BUY System", "identityKa: Valid BUY Signal!")
alertcondition(valid_sell, "🔴 SELL System", "identityKa: Valid SELL Signal!")
````
