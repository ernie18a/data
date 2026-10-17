# Swing from stochastic with alert

- url: https://www.tradingview.com/script/0tnoFAw7-Swing-from-stochastic-with-alert/
- type: indicator
- pine_id: PUB;4e274213e94345aaa73aab7d4f8a5b1b
- version: 1.0

## Description

Stochastic ZigZag [SH/SL] — How It Works
This indicator uses the Stochastic %K (9,3,3) to identify and confirm Swing Highs and Swing Lows on the price chart, then connects them with a ZigZag line.
Swing Detection Logic

When %K crosses below 20 → enters "seeking Low" mode, tracking the lowest price. Once %K crosses above 80, that lowest point is confirmed as a Swing Low (SL)
When %K crosses above 80 → enters "seeking High" mode, tracking the highest price. Once %K crosses below 20, that highest point is confirmed as a Swing High (SH)
If the same swing type repeats before the opposite appears, only the more extreme value is kept

Visual Output

ZigZag line connecting alternating SH and SL points (customizable color, width, style)
Tiny SH / SL labels at each confirmed swing point
Dashed horizontal level lines extending right from each confirmed SH and SL (last 3 of each shown); a level line ends at the bar where price closes through it

## Source Code

````pine
//@version=5
indicator("Stochastic ZigZag [SH/SL]", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────
// INPUTS - Stochastic
// ─────────────────────────────────────────
i_kLen        = input.int(9,  "Stochastic %K Length", minval=1, group="Stochastic")
i_kSmooth     = input.int(3,  "%K Smoothing",         minval=1, group="Stochastic")
i_dSmooth     = input.int(3,  "%D Smoothing",         minval=1, group="Stochastic")

// ─────────────────────────────────────────
// INPUTS - ZigZag Style
// ─────────────────────────────────────────
i_showZigzag   = input.bool(true,  "Show ZigZag Lines",    group="ZigZag Style")
i_zigColor     = input.color(color.orange, "ZigZag Color", group="ZigZag Style")
i_zigWidth     = input.int(2,  "ZigZag Width", minval=1, maxval=5, group="ZigZag Style")
i_zigStyle     = input.string("Solid", "ZigZag Line Style",
     options=["Solid", "Dashed", "Dotted"],                 group="ZigZag Style")
i_maxLines     = input.int(50, "Max ZigZag Lines", minval=5, maxval=500, group="ZigZag Style")

// ─────────────────────────────────────────
// INPUTS - Labels
// ─────────────────────────────────────────
i_showLabels   = input.bool(true, "Show SH/SL Labels", group="Labels")

// ─────────────────────────────────────────
// INPUTS - Level Lines
// ─────────────────────────────────────────
i_showLevels    = input.bool(true, "Show SH/SL Level Lines",      group="Level Lines")
i_levelWidth    = input.int(1,     "Level Line Width", minval=1, maxval=4, group="Level Lines")
i_shLevelColor  = input.color(color.new(color.red,   50), "SH Level Color", group="Level Lines")
i_slLevelColor  = input.color(color.new(color.green, 50), "SL Level Color", group="Level Lines")
i_maxLevelKeep  = input.int(3, "Max SH/SL Levels to Show", minval=1, maxval=10, group="Level Lines")

// ─────────────────────────────────────────
// INPUTS - Alerts
// ─────────────────────────────────────────
i_alertNewSH    = input.bool(true, "Alert: New Swing High Confirmed",    group="Alerts")
i_alertNewSL    = input.bool(true, "Alert: New Swing Low Confirmed",     group="Alerts")
i_alertBreakSH  = input.bool(true, "Alert: Price Close Above SH Level",  group="Alerts")
i_alertBreakSL  = input.bool(true, "Alert: Price Close Below SL Level",  group="Alerts")

// ─────────────────────────────────────────
// STOCHASTIC
// ─────────────────────────────────────────
kRaw = ta.stoch(close, high, low, i_kLen)
kVal = ta.sma(kRaw, i_kSmooth)

crossOver80  = ta.crossover(kVal,  80)
crossUnder20 = ta.crossunder(kVal, 20)

// ─────────────────────────────────────────
// HELPER: แปลง string → line style
// ─────────────────────────────────────────
getLineStyle(string s) =>
    s == "Dashed" ? line.style_dashed :
     s == "Dotted" ? line.style_dotted :
     line.style_solid

// ─────────────────────────────────────────
// STATE VARIABLES
// ─────────────────────────────────────────
var int   mode        = 0
var float bestLow     = na
var int   bestLowIdx  = na
var float bestHigh    = na
var int   bestHighIdx = na

// ─────────────────────────────────────────
// SWING ARRAYS
// ─────────────────────────────────────────
var int[]   swingType  = array.new_int()
var float[] swingPrice = array.new_float()
var int[]   swingIdx   = array.new_int()

// ─────────────────────────────────────────
// LINE / LABEL ARRAYS
// ─────────────────────────────────────────
var line[]  zigzagLines = array.new_line()
var label[] swingLabels = array.new_label()

// Level line arrays แยก SH / SL
var line[]  shLevelLines  = array.new_line()
var float[] shLevelPrices = array.new_float()
var line[]  slLevelLines  = array.new_line()
var float[] slLevelPrices = array.new_float()

// ─────────────────────────────────────────
// HELPER: เพิ่ม swing / replace ถ้าซ้ำชนิดเดิม
// ─────────────────────────────────────────
addSwing(int sType, float sPrice, int sIdx) =>
    int   lastType  = array.size(swingType)  > 0 ? array.get(swingType,  array.size(swingType)  - 1) : na
    float lastPrice = array.size(swingPrice) > 0 ? array.get(swingPrice, array.size(swingPrice) - 1) : na

    if na(lastType) or lastType != sType
        array.push(swingType,  sType)
        array.push(swingPrice, sPrice)
        array.push(swingIdx,   sIdx)
    else
        bool replace = (sType == 1  and sPrice > lastPrice) or
                       (sType == -1 and sPrice < lastPrice)
        if replace
            array.set(swingType,  array.size(swingType)  - 1, sType)
            array.set(swingPrice, array.size(swingPrice) - 1, sPrice)
            array.set(swingIdx,   array.size(swingIdx)   - 1, sIdx)

// ─────────────────────────────────────────
// HELPER: เพิ่ม Level Line ใหม่
// ─────────────────────────────────────────
addLevelLine(int sType, float sPrice, int sIdx) =>
    if i_showLevels
        color lvColor = sType == 1 ? i_shLevelColor : i_slLevelColor
        line lv = line.new(sIdx, sPrice, sIdx + 1, sPrice,
             xloc   = xloc.bar_index,
             color  = lvColor,
             width  = i_levelWidth,
             style  = line.style_dashed,
             extend = extend.right)
        if sType == 1
            array.push(shLevelLines,  lv)
            array.push(shLevelPrices, sPrice)
            if array.size(shLevelLines) > i_maxLevelKeep
                line.delete(array.shift(shLevelLines))
                array.shift(shLevelPrices)
        else
            array.push(slLevelLines,  lv)
            array.push(slLevelPrices, sPrice)
            if array.size(slLevelLines) > i_maxLevelKeep
                line.delete(array.shift(slLevelLines))
                array.shift(slLevelPrices)

// ─────────────────────────────────────────
// HELPER: ตรวจ SH level breaks → return true ถ้า break เกิดขึ้น
// ─────────────────────────────────────────
checkSHBreaks() =>
    bool broken = false
    if array.size(shLevelLines) > 0
        for i = array.size(shLevelLines) - 1 to 0
            float lvPrice = array.get(shLevelPrices, i)
            line  lvLine  = array.get(shLevelLines,  i)
            if close > lvPrice
                line.set_x2(lvLine, bar_index)
                line.set_extend(lvLine, extend.none)
                array.remove(shLevelLines,  i)
                array.remove(shLevelPrices, i)
                broken := true
    broken

// ─────────────────────────────────────────
// HELPER: ตรวจ SL level breaks → return true ถ้า break เกิดขึ้น
// ─────────────────────────────────────────
checkSLBreaks() =>
    bool broken = false
    if array.size(slLevelLines) > 0
        for i = array.size(slLevelLines) - 1 to 0
            float lvPrice = array.get(slLevelPrices, i)
            line  lvLine  = array.get(slLevelLines,  i)
            if close < lvPrice
                line.set_x2(lvLine, bar_index)
                line.set_extend(lvLine, extend.none)
                array.remove(slLevelLines,  i)
                array.remove(slLevelPrices, i)
                broken := true
    broken

// ─────────────────────────────────────────
// HELPER: วาด ZigZag + Label
// ─────────────────────────────────────────
drawZigzag() =>
    int sz = array.size(swingType)
    if sz >= 2
        int   i1 = array.get(swingIdx,   sz - 2)
        float p1 = array.get(swingPrice, sz - 2)
        int   i2 = array.get(swingIdx,   sz - 1)
        float p2 = array.get(swingPrice, sz - 1)
        int   t2 = array.get(swingType,  sz - 1)

        if i_showZigzag
            line ln = line.new(i1, p1, i2, p2,
                 xloc  = xloc.bar_index,
                 color = i_zigColor,
                 width = i_zigWidth,
                 style = getLineStyle(i_zigStyle))
            array.push(zigzagLines, ln)
            if array.size(zigzagLines) > i_maxLines
                line.delete(array.shift(zigzagLines))

        if i_showLabels
            string lbTxt   = t2 == 1 ? "SH" : "SL"
            color  lbColor = t2 == 1 ? color.red : color.green
            label lb = label.new(i2, p2,
                 text      = lbTxt,
                 xloc      = xloc.bar_index,
                 style     = t2 == 1 ? label.style_label_down : label.style_label_up,
                 color     = lbColor,
                 textcolor = color.white,
                 size      = size.tiny)
            array.push(swingLabels, lb)
            if array.size(swingLabels) > i_maxLines
                label.delete(array.shift(swingLabels))

// ─────────────────────────────────────────
// MAIN LOGIC
// ─────────────────────────────────────────
var bool trigNewSH   = false
var bool trigNewSL   = false
var bool trigBreakSH = false
var bool trigBreakSL = false

trigNewSH   := false
trigNewSL   := false

// %K ตัดลงผ่าน 20 → ยืนยัน Swing High + เริ่มโหมดหา Low
if crossUnder20
    if mode == 2 and not na(bestHigh)
        addSwing(1, bestHigh, bestHighIdx)
        drawZigzag()
        addLevelLine(1, bestHigh, bestHighIdx)
        trigNewSH := true
    mode       := 1
    bestLow    := low
    bestLowIdx := bar_index

// %K ตัดขึ้นผ่าน 80 → ยืนยัน Swing Low + เริ่มโหมดหา High
if crossOver80
    if mode == 1 and not na(bestLow)
        addSwing(-1, bestLow, bestLowIdx)
        drawZigzag()
        addLevelLine(-1, bestLow, bestLowIdx)
        trigNewSL := true
    mode        := 2
    bestHigh    := high
    bestHighIdx := bar_index

// อัปเดต best Low
if mode == 1
    if na(bestLow) or low < bestLow
        bestLow    := low
        bestLowIdx := bar_index

// อัปเดต best High
if mode == 2
    if na(bestHigh) or high > bestHigh
        bestHigh    := high
        bestHighIdx := bar_index

// ตรวจ breakout ใน global scope รับ return value จาก function
trigBreakSH := checkSHBreaks()
trigBreakSL := checkSLBreaks()

// ─────────────────────────────────────────
// ALERT CONDITIONS (แยก condition อิสระ)
// ─────────────────────────────────────────
alertcondition(trigNewSH   and i_alertNewSH,   "New Swing High",       "🔴 Swing High Confirmed")
alertcondition(trigNewSL   and i_alertNewSL,   "New Swing Low",        "🟢 Swing Low Confirmed")
alertcondition(trigBreakSH and i_alertBreakSH, "Price Break Above SH", "⚡ Price closed ABOVE Swing High level")
alertcondition(trigBreakSL and i_alertBreakSL, "Price Break Below SL", "⚡ Price closed BELOW Swing Low level")

// Alert รวมทุกอย่าง
alertcondition(
     (trigNewSH   and i_alertNewSH)   or
     (trigNewSL   and i_alertNewSL)   or
     (trigBreakSH and i_alertBreakSH) or
     (trigBreakSL and i_alertBreakSL),
     "All Alerts",
     "🔔 ZigZag Alert Triggered")
````
