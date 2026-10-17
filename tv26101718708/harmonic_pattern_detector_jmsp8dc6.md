# Harmonic Pattern Detector

- url: https://www.tradingview.com/script/jmsP8DC6-Harmonic-Pattern-Detector/
- type: indicator
- pine_id: PUB;a37fb683a8644af3b0d5d72f56425a76
- version: 1.0

## Description

Track the historical Harmonic Pattern and predict the next D point.

## Source Code

````pine
//@version=6
// Harmonic Pattern Detector v4
// ▸ 과거: XABCD 완성 패턴 표시
// ▸ 현재: XABC 확인 시 D 예상 선행 표시 (실시간)

indicator("Harmonic Pattern Detector v4", overlay=true, max_lines_count=500, max_labels_count=300, max_boxes_count=200)

// ══════════════ INPUTS ══════════════
grp_g = "🔍 일반 설정"
zigzagDepth    = input.int(8, "ZigZag Depth", minval=3, maxval=20, group=grp_g)
fibTolerance   = input.float(0.10, "Fibonacci Tolerance", minval=0.01, maxval=0.20, step=0.01, group=grp_g)
showLabels     = input.bool(true, "X/A/B/C/D 라벨 표시", group=grp_g)
showLiveD      = input.bool(true, "D 예상 지점 선행 표시", group=grp_g)

grp_f = "📏 스윙 크기 필터"
minBarsBetween = input.int(5, "Pivot 간 최소 봉수", minval=1, maxval=50, group=grp_f)
minTotalBars   = input.int(20, "X→D 전체 패턴 최소 봉수", minval=5, maxval=200, group=grp_f)

grp_p = "📊 활성화할 패턴"
enableGartley   = input.bool(true, "Gartley",   group=grp_p)
enableBat       = input.bool(true, "Bat",       group=grp_p)
enableButterfly = input.bool(true, "Butterfly", group=grp_p)
enableCrab      = input.bool(true, "Crab",      group=grp_p)
enableCypher    = input.bool(true, "Cypher",    group=grp_p)
enableShark     = input.bool(true, "Shark",     group=grp_p)

grp_c = "🎨 색상"
colorGartley   = input.color(color.rgb(0,   191, 255, 85), "Gartley",   group=grp_c)
colorBat       = input.color(color.rgb(255, 102,   0, 85), "Bat",       group=grp_c)
colorButterfly = input.color(color.rgb(170,   0, 255, 85), "Butterfly", group=grp_c)
colorCrab      = input.color(color.rgb(255,  51, 102, 85), "Crab",      group=grp_c)
colorCypher    = input.color(color.rgb(0,   204, 136, 85), "Cypher",    group=grp_c)
colorShark     = input.color(color.rgb(255, 215,   0, 85), "Shark",     group=grp_c)

// ══════════════ PIVOTS ══════════════
pivotHi = ta.pivothigh(high, zigzagDepth, zigzagDepth)
pivotLo = ta.pivotlow(low,  zigzagDepth, zigzagDepth)

var float[] swPrices = array.new_float(0)
var int[]   swBars   = array.new_int(0)
var bool[]  swIsHigh = array.new_bool(0)
newSwing = false

if not na(pivotHi)
    b = bar_index - zigzagDepth
    p = pivotHi
    sz = array.size(swBars)
    if sz > 0 and array.last(swIsHigh)
        if p > array.last(swPrices)
            array.set(swPrices, sz - 1, p)
            array.set(swBars,   sz - 1, b)
    else
        array.push(swPrices, p)
        array.push(swBars,   b)
        array.push(swIsHigh, true)
        newSwing := true
    if array.size(swBars) > 60
        array.shift(swPrices)
        array.shift(swBars)
        array.shift(swIsHigh)

if not na(pivotLo)
    b = bar_index - zigzagDepth
    p = pivotLo
    sz = array.size(swBars)
    if sz > 0 and not array.last(swIsHigh)
        if p < array.last(swPrices)
            array.set(swPrices, sz - 1, p)
            array.set(swBars,   sz - 1, b)
    else
        array.push(swPrices, p)
        array.push(swBars,   b)
        array.push(swIsHigh, false)
        newSwing := true
    if array.size(swBars) > 60
        array.shift(swPrices)
        array.shift(swBars)
        array.shift(swIsHigh)

// ══════════════ UTILS ══════════════
inRange(val, tgt, tol) => val >= tgt - tol and val <= tgt + tol

getCol(nm) =>
    col = color.gray
    if str.contains(nm, "Gartley")
        col := colorGartley
    else if str.contains(nm, "Bat")
        col := colorBat
    else if str.contains(nm, "Butterfly")
        col := colorButterfly
    else if str.contains(nm, "Crab")
        col := colorCrab
    else if str.contains(nm, "Cypher")
        col := colorCypher
    else if str.contains(nm, "Shark")
        col := colorShark
    col

// ══════════════ RATIO CHECKS ══════════════
chkGartley(xP, aP, bP, cP) =>
    r1 = math.abs(aP - xP) != 0 ? math.abs(bP - aP) / math.abs(aP - xP) : 0.0
    r2 = math.abs(bP - aP) != 0 ? math.abs(cP - bP) / math.abs(bP - aP) : 0.0
    (inRange(r1, 0.618, fibTolerance) or inRange(r1, 0.500, fibTolerance)) and (inRange(r2, 0.382, fibTolerance) or inRange(r2, 0.618, fibTolerance) or inRange(r2, 0.886, fibTolerance))

chkBat(xP, aP, bP, cP) =>
    r1 = math.abs(aP - xP) != 0 ? math.abs(bP - aP) / math.abs(aP - xP) : 0.0
    r2 = math.abs(bP - aP) != 0 ? math.abs(cP - bP) / math.abs(bP - aP) : 0.0
    (inRange(r1, 0.382, fibTolerance) or inRange(r1, 0.500, fibTolerance)) and (inRange(r2, 0.786, fibTolerance) or inRange(r2, 0.886, fibTolerance))

chkButterfly(xP, aP, bP, cP) =>
    r1 = math.abs(aP - xP) != 0 ? math.abs(bP - aP) / math.abs(aP - xP) : 0.0
    r2 = math.abs(bP - aP) != 0 ? math.abs(cP - bP) / math.abs(bP - aP) : 0.0
    (inRange(r1, 0.786, fibTolerance) or inRange(r1, 0.618, fibTolerance)) and (inRange(r2, 0.382, fibTolerance) or inRange(r2, 0.618, fibTolerance) or inRange(r2, 0.886, fibTolerance) or inRange(r2, 1.272, fibTolerance))

chkCrab(xP, aP, bP, cP) =>
    r1 = math.abs(aP - xP) != 0 ? math.abs(bP - aP) / math.abs(aP - xP) : 0.0
    r2 = math.abs(bP - aP) != 0 ? math.abs(cP - bP) / math.abs(bP - aP) : 0.0
    (inRange(r1, 0.382, fibTolerance) or inRange(r1, 0.500, fibTolerance) or inRange(r1, 0.618, fibTolerance)) and (inRange(r2, 0.786, fibTolerance) or inRange(r2, 0.886, fibTolerance))

chkCypher(xP, aP, bP, cP) =>
    r1 = math.abs(aP - xP) != 0 ? math.abs(bP - aP) / math.abs(aP - xP) : 0.0
    r2 = math.abs(bP - aP) != 0 ? math.abs(cP - bP) / math.abs(bP - aP) : 0.0
    (inRange(r1, 0.382, fibTolerance) or inRange(r1, 0.500, fibTolerance) or inRange(r1, 0.618, fibTolerance)) and (inRange(r2, 1.130, fibTolerance) or inRange(r2, 1.272, fibTolerance) or inRange(r2, 1.414, fibTolerance))

chkShark(xP, aP, bP, cP) =>
    r1 = math.abs(aP - xP) != 0 ? math.abs(bP - aP) / math.abs(aP - xP) : 0.0
    r2 = math.abs(bP - aP) != 0 ? math.abs(cP - bP) / math.abs(bP - aP) : 0.0
    (inRange(r1, 0.886, fibTolerance) or inRange(r1, 1.000, fibTolerance) or inRange(r1, 1.130, fibTolerance)) and (inRange(r2, 1.272, fibTolerance) or inRange(r2, 1.618, fibTolerance) or inRange(r2, 2.000, fibTolerance))

runChecks(xP, aP, bP, cP, isBull) =>
    pf = false
    pn = ""
    if not pf and enableGartley and chkGartley(xP, aP, bP, cP)
        pf := true
        pn := isBull ? "Bullish Gartley" : "Bearish Gartley"
    if not pf and enableBat and chkBat(xP, aP, bP, cP)
        pf := true
        pn := isBull ? "Bullish Bat" : "Bearish Bat"
    if not pf and enableButterfly and chkButterfly(xP, aP, bP, cP)
        pf := true
        pn := isBull ? "Bullish Butterfly" : "Bearish Butterfly"
    if not pf and enableCrab and chkCrab(xP, aP, bP, cP)
        pf := true
        pn := isBull ? "Bullish Crab" : "Bearish Crab"
    if not pf and enableCypher and chkCypher(xP, aP, bP, cP)
        pf := true
        pn := isBull ? "Bullish Cypher" : "Bearish Cypher"
    if not pf and enableShark and chkShark(xP, aP, bP, cP)
        pf := true
        pn := isBull ? "Bullish Shark" : "Bearish Shark"
    [pf, pn]

calcD(pn, xP, aP, isBull) =>
    xa    = math.abs(aP - xP)
    ratio = str.contains(pn, "Butterfly") ? 1.272 : str.contains(pn, "Crab") ? 1.618 : str.contains(pn, "Bat") ? 0.886 : str.contains(pn, "Shark") ? 0.886 : 0.786
    isBull ? aP - xa * ratio : aP + xa * ratio

// ══════════════ DRAW – 완성 패턴 ══════════════
drawCompleted(xP, aP, bP, cP, dP, xB, aB, bB, cB, dB, col, nm, isBull) =>
    line.new(xB, xP, aB, aP, color=col, width=2)
    line.new(aB, aP, bB, bP, color=col, width=2)
    line.new(bB, bP, cB, cP, color=col, width=2)
    line.new(cB, cP, dB, dP, color=col, width=2)
    line.new(xB, xP, dB, dP, color=color.new(col, 65), width=1, style=line.style_dashed)
    if showLabels
        label.new(xB, xP, "X", style=label.style_label_center, color=color.new(col, 50), textcolor=color.white, size=size.tiny)
        label.new(aB, aP, "A", style=label.style_label_center, color=color.new(col, 50), textcolor=color.white, size=size.tiny)
        label.new(bB, bP, "B", style=label.style_label_center, color=color.new(col, 50), textcolor=color.white, size=size.tiny)
        label.new(cB, cP, "C", style=label.style_label_center, color=color.new(col, 50), textcolor=color.white, size=size.tiny)
        label.new(dB, dP, "D\n" + nm, style=isBull ? label.style_label_up : label.style_label_down, color=col, textcolor=color.white, size=size.small)

// ══════════════ 선행 D 오브젝트 (전역 var) ══════════════
// ※ CE10088: var 전역변수 재할당(:=)은 반드시 전역 스코프(if 블록)에서만 가능
// ※ line/label/box.delete()는 함수 내에서도 OK
var line  lvXA = na
var line  lvAB = na
var line  lvBC = na
var line  lvCD = na
var line  lvHr = na
var label lvLX = na
var label lvLA = na
var label lvLB = na
var label lvLC = na
var label lvLD = na
var box   lvBx = na

// delete는 함수 내에서 가능 → 중복 제거용 함수
clearLive() =>
    if not na(lvXA)
        line.delete(lvXA)
    if not na(lvAB)
        line.delete(lvAB)
    if not na(lvBC)
        line.delete(lvBC)
    if not na(lvCD)
        line.delete(lvCD)
    if not na(lvHr)
        line.delete(lvHr)
    if not na(lvLX)
        label.delete(lvLX)
    if not na(lvLA)
        label.delete(lvLA)
    if not na(lvLB)
        label.delete(lvLB)
    if not na(lvLC)
        label.delete(lvLC)
    if not na(lvLD)
        label.delete(lvLD)
    if not na(lvBx)
        box.delete(lvBx)

// ══════════════ DETECTION STATE ══════════════
var int lastDBar  = -1
var int lastLvBar = -1

// ══════════════ 완성 패턴 (새 스윙 발생 시) ══════════════
if newSwing
    sz = array.size(swBars)
    if sz >= 5
        xB = array.get(swBars,   sz-5)
        aB = array.get(swBars,   sz-4)
        bB = array.get(swBars,   sz-3)
        cB = array.get(swBars,   sz-2)
        dB = array.get(swBars,   sz-1)
        xP = array.get(swPrices, sz-5)
        aP = array.get(swPrices, sz-4)
        bP = array.get(swPrices, sz-3)
        cP = array.get(swPrices, sz-2)
        dP = array.get(swPrices, sz-1)
        sizeOK = (aB-xB) >= minBarsBetween and (bB-aB) >= minBarsBetween and (cB-bB) >= minBarsBetween and (dB-cB) >= minBarsBetween and (dB-xB) >= minTotalBars
        if sizeOK and dB != lastDBar
            if xP < aP and bP < aP and cP > bP and dP < cP
                [pf, pn] = runChecks(xP, aP, bP, cP, true)
                if pf
                    lastDBar := dB
                    clearLive()
                    drawCompleted(xP, aP, bP, cP, dP, xB, aB, bB, cB, dB, getCol(pn), pn, true)
            if xP > aP and bP > aP and cP < bP and dP > cP
                [pf, pn] = runChecks(xP, aP, bP, cP, false)
                if pf
                    lastDBar := dB
                    clearLive()
                    drawCompleted(xP, aP, bP, cP, dP, xB, aB, bB, cB, dB, getCol(pn), pn, false)

// ══════════════ 선행 D 표시 (최신봉 실시간) ══════════════
if showLiveD and barstate.islast
    sz = array.size(swBars)
    if sz >= 4
        xB4 = array.get(swBars,   sz-4)
        aB4 = array.get(swBars,   sz-3)
        bB4 = array.get(swBars,   sz-2)
        cB4 = array.get(swBars,   sz-1)
        xP4 = array.get(swPrices, sz-4)
        aP4 = array.get(swPrices, sz-3)
        bP4 = array.get(swPrices, sz-2)
        cP4 = array.get(swPrices, sz-1)
        sizeOK4 = (aB4-xB4) >= minBarsBetween and (bB4-aB4) >= minBarsBetween and (cB4-bB4) >= minBarsBetween
        if sizeOK4
            isBull4 = xP4 < aP4 and bP4 < aP4 and cP4 > bP4
            isBear4 = xP4 > aP4 and bP4 > aP4 and cP4 < bP4
            if isBull4 or isBear4
                [pf4, pn4] = runChecks(xP4, aP4, bP4, cP4, isBull4)
                if pf4 and cB4 != lastLvBar
                    lastLvBar := cB4
                    dEst = calcD(pn4, xP4, aP4, isBull4)
                    col4  = getCol(pn4)
                    dCol  = color.new(col4, 30)
                    ghost = color.new(col4, 70)
                    proj  = bar_index + 5
                    mg    = dEst * 0.005
                    clearLive()
                    // ※ lv* 재할당은 전역 스코프이므로 CE10088 없음
                    lvXA := line.new(xB4, xP4, aB4, aP4, color=dCol, width=2)
                    lvAB := line.new(aB4, aP4, bB4, bP4, color=dCol, width=2)
                    lvBC := line.new(bB4, bP4, cB4, cP4, color=dCol, width=2)
                    lvCD := line.new(cB4, cP4, proj, dEst, color=dCol, width=2, style=line.style_arrow_right)
                    lvHr := line.new(proj, dEst, proj+30, dEst, color=dCol, width=1, style=line.style_dashed)
                    lvBx := box.new(proj, dEst+mg, proj+30, dEst-mg, border_color=dCol, bgcolor=color.new(col4, 85), border_style=line.style_dashed)
                    if showLabels
                        lvLX := label.new(xB4, xP4, "X", style=label.style_label_center, color=ghost, textcolor=color.white, size=size.tiny)
                        lvLA := label.new(aB4, aP4, "A", style=label.style_label_center, color=ghost, textcolor=color.white, size=size.tiny)
                        lvLB := label.new(bB4, bP4, "B", style=label.style_label_center, color=ghost, textcolor=color.white, size=size.tiny)
                        lvLC := label.new(cB4, cP4, "C", style=label.style_label_center, color=ghost, textcolor=color.white, size=size.tiny)
                        lvLD := label.new(proj, dEst, "D?\n" + pn4 + "\n" + str.tostring(math.round(dEst, 2)), style=isBull4 ? label.style_label_up : label.style_label_down, color=dCol, textcolor=color.white, size=size.small)
````
