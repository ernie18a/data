# MTF FVG & IFVG

- url: https://www.tradingview.com/script/rnVyPTMO/
- type: indicator
- pine_id: PUB;bf0238f3f8e84f2a82c80ad1dad3b533
- version: 1.0

## Description

Plots Fair Value Gaps and Inverse Fair Value Gaps across up to three independent timeframes each — straight from your execution chart, no timeframe switching.

Fair Value Gaps (FVG)
Three-candle imbalances drawn as clean zones with a 50% midline. Mitigation is fully configurable: choose the depth (%) at which a gap counts as filled, then have it grey out, keep its color, or disappear.

Inverse FVG (IFVG)
Only an untouched FVG that gets cleanly broken inverts into an opposing zone. If price taps the gap before breaking it, the level is considered spent and won't flip — so you only get IFVGs from genuinely respected imbalances, not noise.

Features
- 3 timeframe slots each for FVG and IFVG, individually toggled
- Per-side bull/bear colors
- Adjustable mitigation depth and style
- Max-zone caps to keep charts clean
- Optional labels showing the source timeframe

Built for SMC / orderflow traders who want multi-timeframe context on a single chart.

## Source Code

````pine
//@version=6
indicator("MTF FVG + IFVG", "FVG/IFVG", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
// MTF FVG
// ═══════════════════════════════════════════════════════════════════════════════
fvg_group = "═══════ MTF FVG ═══════"

fvg1_enable = input.bool(true,  "Enable slot 1", group=fvg_group, inline="f1")
fvg1_tf     = input.timeframe("15", "", group=fvg_group, inline="f1")
fvg1_bull_color = input.color(color.new(color.green, 70), "Bull", group=fvg_group, inline="f1c")
fvg1_bear_color = input.color(color.new(color.red, 70),   "Bear", group=fvg_group, inline="f1c")

fvg2_enable = input.bool(false, "Enable slot 2", group=fvg_group, inline="f2")
fvg2_tf     = input.timeframe("60", "", group=fvg_group, inline="f2")
fvg2_bull_color = input.color(color.new(color.teal, 70),   "Bull", group=fvg_group, inline="f2c")
fvg2_bear_color = input.color(color.new(color.maroon, 70), "Bear", group=fvg_group, inline="f2c")

fvg3_enable = input.bool(false, "Enable slot 3", group=fvg_group, inline="f3")
fvg3_tf     = input.timeframe("240", "", group=fvg_group, inline="f3")
fvg3_bull_color = input.color(color.new(color.lime, 70),    "Bull", group=fvg_group, inline="f3c")
fvg3_bear_color = input.color(color.new(color.fuchsia, 70), "Bear", group=fvg_group, inline="f3c")

fvg_max_count = input.int(5, "Max FVGs per slot", minval=1, maxval=10, group=fvg_group)
fvg_mitigation_style = input.string("Greyed out", "Mitigated FVGs", options=["Greyed out", "Keep color", "Hide"], group=fvg_group, tooltip="Greyed out = grey + dotted. Keep color = keeps original color. Hide = removed entirely on mitigation.")
fvg_mit_pct = input.int(0, "Mitigation %", minval=0, maxval=100, step=5, group=fvg_group, tooltip="How far price must travel into the zone for it to count as mitigated. 0 = touch of the near (proximal) edge, 50 = midline, 100 = fully filled (distal edge).")

// ═══════════════════════════════════════════════════════════════════════════════
// MTF INVERSE FVG (Inversion)
//   Only an UNTOUCHED FVG that is cleanly broken (close through the distal edge)
//   inverts its role (bull -> bear IFVG). If the FVG is tapped beforehand, it is
//   consumed and can no longer invert.
// ═══════════════════════════════════════════════════════════════════════════════
ifvg_group = "═══════ MTF Inverse FVG ═══════"

ifvg1_enable = input.bool(true,  "Enable slot 1", group=ifvg_group, inline="i1")
ifvg1_tf     = input.timeframe("60", "", group=ifvg_group, inline="i1")
ifvg1_bull_color = input.color(color.new(color.aqua, 70),   "Bull", group=ifvg_group, inline="i1c")
ifvg1_bear_color = input.color(color.new(color.purple, 70), "Bear", group=ifvg_group, inline="i1c")

ifvg2_enable = input.bool(false, "Enable slot 2", group=ifvg_group, inline="i2")
ifvg2_tf     = input.timeframe("240", "", group=ifvg_group, inline="i2")
ifvg2_bull_color = input.color(color.new(color.aqua, 70),   "Bull", group=ifvg_group, inline="i2c")
ifvg2_bear_color = input.color(color.new(color.purple, 70), "Bear", group=ifvg_group, inline="i2c")

ifvg3_enable = input.bool(false, "Enable slot 3", group=ifvg_group, inline="i3")
ifvg3_tf     = input.timeframe("D", "", group=ifvg_group, inline="i3")
ifvg3_bull_color = input.color(color.new(color.aqua, 70),   "Bull", group=ifvg_group, inline="i3c")
ifvg3_bear_color = input.color(color.new(color.purple, 70), "Bear", group=ifvg_group, inline="i3c")

ifvg_max_count = input.int(5, "Max IFVGs per slot", minval=1, maxval=10, group=ifvg_group)
ifvg_mitigation_style = input.string("Greyed out", "Mitigated IFVGs", options=["Greyed out", "Keep color", "Hide"], group=ifvg_group)
ifvg_show_label = input.bool(true, "Show labels", group=ifvg_group)
ifvg_mit_pct = input.int(0, "Mitigation %", minval=0, maxval=100, step=5, group=ifvg_group, tooltip="How far price must travel into the IFVG zone for it to count as mitigated. 0 = touch of the near (proximal) edge, 50 = midline, 100 = distal edge.")

// ═══════════════════════════════════════════════════════════════════════════════
// TYPES
// ═══════════════════════════════════════════════════════════════════════════════
type HTFBar
    float price = na
    int   idx = na

type HTFBarOHLC
    HTFBar open
    HTFBar high
    HTFBar low
    HTFBar close

type FVG
    float top
    float bottom
    int   topIdx
    int   btmIdx
    bool  isBullish
    bool  mitigated
    line  lnTop
    line  lnMid
    line  lnBtm
    linefill fill
    label lbl

type PotentialFVG
    float top
    float bottom
    int   topIdx
    int   btmIdx
    bool  isBullish
    bool  broken

// ═══════════════════════════════════════════════════════════════════════════════
// MTF FVG FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════
var array<FVG> fvg1_list = array.new<FVG>()
var array<FVG> fvg2_list = array.new<FVG>()
var array<FVG> fvg3_list = array.new<FVG>()

var array<HTFBarOHLC> htfBars1 = array.new<HTFBarOHLC>()
var array<HTFBarOHLC> htfBars2 = array.new<HTFBarOHLC>()
var array<HTFBarOHLC> htfBars3 = array.new<HTFBarOHLC>()

var HTFBar slot1_barOpen = HTFBar.new(open, bar_index)
var HTFBar slot1_barHigh = HTFBar.new(high, bar_index)
var HTFBar slot1_barLow = HTFBar.new(low, bar_index)
var HTFBar slot1_barClose = HTFBar.new(close, bar_index)
var HTFBarOHLC slot1_currentBar = HTFBarOHLC.new(slot1_barOpen, slot1_barHigh, slot1_barLow, slot1_barClose)

var HTFBar slot2_barOpen = HTFBar.new(open, bar_index)
var HTFBar slot2_barHigh = HTFBar.new(high, bar_index)
var HTFBar slot2_barLow = HTFBar.new(low, bar_index)
var HTFBar slot2_barClose = HTFBar.new(close, bar_index)
var HTFBarOHLC slot2_currentBar = HTFBarOHLC.new(slot2_barOpen, slot2_barHigh, slot2_barLow, slot2_barClose)

var HTFBar slot3_barOpen = HTFBar.new(open, bar_index)
var HTFBar slot3_barHigh = HTFBar.new(high, bar_index)
var HTFBar slot3_barLow = HTFBar.new(low, bar_index)
var HTFBar slot3_barClose = HTFBar.new(close, bar_index)
var HTFBarOHLC slot3_currentBar = HTFBarOHLC.new(slot3_barOpen, slot3_barHigh, slot3_barLow, slot3_barClose)

var float prevBullTop1 = na
var float prevBearTop1 = na
var float prevBullTop2 = na
var float prevBearTop2 = na
var float prevBullTop3 = na
var float prevBearTop3 = na

manageFVGsNew(fvgList, bullTop, bullBottom, bullTopIdx, bullBottomIdx, bullValid, bearTop, bearBottom, bearTopIdx, bearBottomIdx, bearValid, prevBullT, prevBearT, bullColor, bearColor, maxCount, tfLabel, mitigationStyle, mitPct) =>
    updatedPrevBullTop = prevBullT
    updatedPrevBearTop = prevBearT

    if bullValid and not na(bullTop) and not na(bullBottom) and bullTop > bullBottom
        isNew = na(prevBullT) or bullTop != prevBullT
        if isNew
            midPrice = math.avg(bullTop, bullBottom)
            midIdx = math.ceil(math.avg(bullTopIdx, bullBottomIdx))
            newFVG = FVG.new()
            newFVG.top       := bullTop
            newFVG.bottom    := bullBottom
            newFVG.topIdx    := bullTopIdx
            newFVG.btmIdx    := bullBottomIdx
            newFVG.isBullish := true
            newFVG.mitigated := false
            newFVG.lnTop     := line.new(bullTopIdx, bullTop, bar_index + 5, bullTop, color=color.new(bullColor, 50))
            newFVG.lnMid     := line.new(midIdx, midPrice, bar_index + 5, midPrice, style=line.style_dotted, color=color.new(bullColor, 25))
            newFVG.lnBtm     := line.new(bullBottomIdx, bullBottom, bar_index + 5, bullBottom, color=color.new(bullColor, 50), width=2)
            newFVG.fill      := linefill.new(newFVG.lnTop, newFVG.lnBtm, color.new(bullColor, 85))
            newFVG.lbl       := label.new(bar_index + 1, midPrice, tfLabel + " FVG", style=label.style_label_left, color=color(na), textcolor=color.white, size=size.small)
            array.push(fvgList, newFVG)
            updatedPrevBullTop := bullTop

    if bearValid and not na(bearTop) and not na(bearBottom) and bearTop > bearBottom
        isNew = na(prevBearT) or bearTop != prevBearT
        if isNew
            midPrice = math.avg(bearTop, bearBottom)
            midIdx = math.ceil(math.avg(bearTopIdx, bearBottomIdx))
            newFVG = FVG.new()
            newFVG.top       := bearTop
            newFVG.bottom    := bearBottom
            newFVG.topIdx    := bearTopIdx
            newFVG.btmIdx    := bearBottomIdx
            newFVG.isBullish := false
            newFVG.mitigated := false
            newFVG.lnTop     := line.new(bearTopIdx, bearTop, bar_index + 5, bearTop, color=color.new(bearColor, 50), width=2)
            newFVG.lnMid     := line.new(midIdx, midPrice, bar_index + 5, midPrice, style=line.style_dotted, color=color.new(bearColor, 25))
            newFVG.lnBtm     := line.new(bearBottomIdx, bearBottom, bar_index + 5, bearBottom, color=color.new(bearColor, 50))
            newFVG.fill      := linefill.new(newFVG.lnTop, newFVG.lnBtm, color.new(bearColor, 85))
            newFVG.lbl       := label.new(bar_index + 1, midPrice, tfLabel + " FVG", style=label.style_label_left, color=color(na), textcolor=color.white, size=size.small)
            array.push(fvgList, newFVG)
            updatedPrevBearTop := bearTop

    if array.size(fvgList) > 0
        for i = array.size(fvgList) - 1 to 0
            fvg = array.get(fvgList, i)
            if not fvg.mitigated
                line.set_x2(fvg.lnTop, bar_index + 5)
                line.set_x2(fvg.lnMid, bar_index + 5)
                line.set_x2(fvg.lnBtm, bar_index + 5)
                label.set_x(fvg.lbl, bar_index + 1)
                if bar_index > math.max(fvg.topIdx, fvg.btmIdx) + 1
                    rng = fvg.top - fvg.bottom
                    hit = fvg.isBullish ? low <= fvg.top - rng * mitPct / 100.0 : high >= fvg.bottom + rng * mitPct / 100.0
                    if hit
                        fvg.mitigated := true
                        if mitigationStyle == "Hide"
                            line.delete(fvg.lnTop)
                            line.delete(fvg.lnMid)
                            line.delete(fvg.lnBtm)
                            linefill.delete(fvg.fill)
                            label.delete(fvg.lbl)
                        else
                            line.set_x2(fvg.lnTop, bar_index)
                            line.set_x2(fvg.lnMid, bar_index)
                            line.set_x2(fvg.lnBtm, bar_index)
                            label.delete(fvg.lbl)
                            if mitigationStyle == "Greyed out"
                                linefill.set_color(fvg.fill, color.new(color.gray, 90))
                                line.set_color(fvg.lnTop, color.new(color.gray, 70))
                                line.set_color(fvg.lnMid, color.new(color.gray, 70))
                                line.set_color(fvg.lnBtm, color.new(color.gray, 70))
                                line.set_style(fvg.lnTop, line.style_dotted)
                                line.set_style(fvg.lnBtm, line.style_dotted)

    unmitigatedCount = 0
    if array.size(fvgList) > 0
        for i = 0 to array.size(fvgList) - 1
            if not array.get(fvgList, i).mitigated
                unmitigatedCount += 1

    while unmitigatedCount > maxCount and array.size(fvgList) > 0
        removed = false
        for i = 0 to array.size(fvgList) - 1
            if not removed
                fvg = array.get(fvgList, i)
                if not fvg.mitigated
                    line.delete(fvg.lnTop)
                    line.delete(fvg.lnMid)
                    line.delete(fvg.lnBtm)
                    linefill.delete(fvg.fill)
                    label.delete(fvg.lbl)
                    array.remove(fvgList, i)
                    unmitigatedCount -= 1
                    removed := true

    while array.size(fvgList) > maxCount * 3
        oldFVG = array.shift(fvgList)
        line.delete(oldFVG.lnTop)
        line.delete(oldFVG.lnMid)
        line.delete(oldFVG.lnBtm)
        linefill.delete(oldFVG.fill)
        label.delete(oldFVG.lbl)

    [updatedPrevBullTop, updatedPrevBearTop]

processFVGSlot(enable, tf, htfBars, currentBar, barOpen, barHigh, barLow, barClose, fvgList, prevBullT, prevBearT, bullColor, bearColor) =>
    // Local copies — function parameters are not reassignable in Pine (CE10175)
    cb = currentBar
    bo = barOpen
    bh = barHigh
    bl = barLow
    bc = barClose
    bTop = float(na)
    bBtm = float(na)
    bTopIdx = int(na)
    bBtmIdx = int(na)
    bValid = false
    brTop = float(na)
    brBtm = float(na)
    brTopIdx = int(na)
    brBtmIdx = int(na)
    brValid = false
    newPBull = prevBullT
    newPBear = prevBearT
    if enable
        if timeframe.change(tf)
            if array.size(htfBars) > 2
                array.pop(htfBars)
            array.unshift(htfBars, cb)
            bo := HTFBar.new(open, bar_index)
            bh := HTFBar.new(high, bar_index)
            bl := HTFBar.new(low, bar_index)
            bc := HTFBar.new(close, bar_index)
            cb := HTFBarOHLC.new(bo, bh, bl, bc)
        else
            if high > bh.price
                bh.price := high
                bh.idx := bar_index
            if low < bl.price
                bl.price := low
                bl.idx := bar_index
            bc.price := close
            bc.idx := bar_index

        if array.size(htfBars) >= 3
            bar0 = array.get(htfBars, 0)
            bar2 = array.get(htfBars, 2)
            if bar0.low.price > bar2.high.price
                bValid := true
                bTop := bar0.low.price
                bBtm := bar2.high.price
                bTopIdx := bar0.low.idx
                bBtmIdx := bar2.high.idx
            if bar0.high.price < bar2.low.price
                brValid := true
                brTop := bar2.low.price
                brBtm := bar0.high.price
                brTopIdx := bar2.low.idx
                brBtmIdx := bar0.high.idx

        [nB, nBr] = manageFVGsNew(fvgList, bTop, bBtm, bTopIdx, bBtmIdx, bValid, brTop, brBtm, brTopIdx, brBtmIdx, brValid, prevBullT, prevBearT, bullColor, bearColor, fvg_max_count, tf, fvg_mitigation_style, fvg_mit_pct)
        newPBull := nB
        newPBear := nBr
    [cb, bo, bh, bl, bc, newPBull, newPBear]

[cb1, bo1, bh1, bl1, bc1, npb1, npbr1] = processFVGSlot(fvg1_enable, fvg1_tf, htfBars1, slot1_currentBar, slot1_barOpen, slot1_barHigh, slot1_barLow, slot1_barClose, fvg1_list, prevBullTop1, prevBearTop1, fvg1_bull_color, fvg1_bear_color)
slot1_currentBar := cb1
slot1_barOpen := bo1
slot1_barHigh := bh1
slot1_barLow := bl1
slot1_barClose := bc1
prevBullTop1 := npb1
prevBearTop1 := npbr1

[cb2, bo2, bh2, bl2, bc2, npb2, npbr2] = processFVGSlot(fvg2_enable, fvg2_tf, htfBars2, slot2_currentBar, slot2_barOpen, slot2_barHigh, slot2_barLow, slot2_barClose, fvg2_list, prevBullTop2, prevBearTop2, fvg2_bull_color, fvg2_bear_color)
slot2_currentBar := cb2
slot2_barOpen := bo2
slot2_barHigh := bh2
slot2_barLow := bl2
slot2_barClose := bc2
prevBullTop2 := npb2
prevBearTop2 := npbr2

[cb3, bo3, bh3, bl3, bc3, npb3, npbr3] = processFVGSlot(fvg3_enable, fvg3_tf, htfBars3, slot3_currentBar, slot3_barOpen, slot3_barHigh, slot3_barLow, slot3_barClose, fvg3_list, prevBullTop3, prevBearTop3, fvg3_bull_color, fvg3_bear_color)
slot3_currentBar := cb3
slot3_barOpen := bo3
slot3_barHigh := bh3
slot3_barLow := bl3
slot3_barClose := bc3
prevBullTop3 := npb3
prevBearTop3 := npbr3

// ═══════════════════════════════════════════════════════════════════════════════
// MTF INVERSE FVG FUNCTIONS (Inversion)
//   An FVG is taken as a candidate. Tested against the first bar after formation:
//     Break (close through distal edge) -> invert.
//     Tap (wick into proximal edge, no break) -> consumed, removed.
// ═══════════════════════════════════════════════════════════════════════════════
var array<FVG> ifvg1_list = array.new<FVG>()
var array<FVG> ifvg2_list = array.new<FVG>()
var array<FVG> ifvg3_list = array.new<FVG>()

var array<PotentialFVG> ifvg1_potentials = array.new<PotentialFVG>()
var array<PotentialFVG> ifvg2_potentials = array.new<PotentialFVG>()
var array<PotentialFVG> ifvg3_potentials = array.new<PotentialFVG>()

var array<HTFBarOHLC> ifvgBars1 = array.new<HTFBarOHLC>()
var array<HTFBarOHLC> ifvgBars2 = array.new<HTFBarOHLC>()
var array<HTFBarOHLC> ifvgBars3 = array.new<HTFBarOHLC>()

var HTFBar ifvg1_barOpen = HTFBar.new(open, bar_index)
var HTFBar ifvg1_barHigh = HTFBar.new(high, bar_index)
var HTFBar ifvg1_barLow = HTFBar.new(low, bar_index)
var HTFBar ifvg1_barClose = HTFBar.new(close, bar_index)
var HTFBarOHLC ifvg1_currentBar = HTFBarOHLC.new(ifvg1_barOpen, ifvg1_barHigh, ifvg1_barLow, ifvg1_barClose)

var HTFBar ifvg2_barOpen = HTFBar.new(open, bar_index)
var HTFBar ifvg2_barHigh = HTFBar.new(high, bar_index)
var HTFBar ifvg2_barLow = HTFBar.new(low, bar_index)
var HTFBar ifvg2_barClose = HTFBar.new(close, bar_index)
var HTFBarOHLC ifvg2_currentBar = HTFBarOHLC.new(ifvg2_barOpen, ifvg2_barHigh, ifvg2_barLow, ifvg2_barClose)

var HTFBar ifvg3_barOpen = HTFBar.new(open, bar_index)
var HTFBar ifvg3_barHigh = HTFBar.new(high, bar_index)
var HTFBar ifvg3_barLow = HTFBar.new(low, bar_index)
var HTFBar ifvg3_barClose = HTFBar.new(close, bar_index)
var HTFBarOHLC ifvg3_currentBar = HTFBarOHLC.new(ifvg3_barOpen, ifvg3_barHigh, ifvg3_barLow, ifvg3_barClose)

// Creates ONE IFVG zone and appends it to the list. Index clamp guards against RE10026.
addIFVG(ifvgList, ifvgTop, ifvgBottom, ifvgTopIdx, ifvgBtmIdx, isBullish, bullColor, bearColor, tfLabel, zoneLabel, showLabel) =>
    if not na(ifvgTop) and not na(ifvgBottom) and ifvgTop > ifvgBottom
        ifvgColor = isBullish ? bullColor : bearColor
        midPrice = math.avg(ifvgTop, ifvgBottom)
        safeTopIdx = math.max(ifvgTopIdx, bar_index - 9000)
        safeBtmIdx = math.max(ifvgBtmIdx, bar_index - 9000)
        safeMidIdx = math.max(math.ceil(math.avg(ifvgTopIdx, ifvgBtmIdx)), bar_index - 9000)
        newIFVG = FVG.new()
        newIFVG.top       := ifvgTop
        newIFVG.bottom    := ifvgBottom
        newIFVG.topIdx    := ifvgTopIdx
        newIFVG.btmIdx    := ifvgBtmIdx
        newIFVG.isBullish := isBullish
        newIFVG.mitigated := false
        if isBullish
            newIFVG.lnTop := line.new(safeTopIdx, ifvgTop, bar_index + 5, ifvgTop, color=color.new(ifvgColor, 50))
            newIFVG.lnMid := line.new(safeMidIdx, midPrice, bar_index + 5, midPrice, style=line.style_dotted, color=color.new(ifvgColor, 25))
            newIFVG.lnBtm := line.new(safeBtmIdx, ifvgBottom, bar_index + 5, ifvgBottom, color=color.new(ifvgColor, 50), width=2)
        else
            newIFVG.lnTop := line.new(safeTopIdx, ifvgTop, bar_index + 5, ifvgTop, color=color.new(ifvgColor, 50), width=2)
            newIFVG.lnMid := line.new(safeMidIdx, midPrice, bar_index + 5, midPrice, style=line.style_dotted, color=color.new(ifvgColor, 25))
            newIFVG.lnBtm := line.new(safeBtmIdx, ifvgBottom, bar_index + 5, ifvgBottom, color=color.new(ifvgColor, 50))
        newIFVG.fill := linefill.new(newIFVG.lnTop, newIFVG.lnBtm, color.new(ifvgColor, 85))
        if showLabel
            newIFVG.lbl := label.new(bar_index + 1, midPrice, tfLabel + " " + zoneLabel, style=label.style_label_left, color=color(na), textcolor=color.white, size=size.small)
        array.push(ifvgList, newIFVG)

// Manages ALL IFVG zones: extend, check mitigation, cap count.
updateIFVGs(ifvgList, maxCount, mitigationStyle, mitPct) =>
    if array.size(ifvgList) > 0
        for i = array.size(ifvgList) - 1 to 0
            ifvg = array.get(ifvgList, i)
            if not ifvg.mitigated
                line.set_x2(ifvg.lnTop, bar_index + 5)
                line.set_x2(ifvg.lnMid, bar_index + 5)
                line.set_x2(ifvg.lnBtm, bar_index + 5)
                if not na(ifvg.lbl)
                    label.set_x(ifvg.lbl, bar_index + 1)
                if bar_index > math.max(ifvg.topIdx, ifvg.btmIdx) + 1
                    rng = ifvg.top - ifvg.bottom
                    hit = ifvg.isBullish ? low <= ifvg.top - rng * mitPct / 100.0 : high >= ifvg.bottom + rng * mitPct / 100.0
                    if hit
                        ifvg.mitigated := true
                        if mitigationStyle == "Hide"
                            line.delete(ifvg.lnTop)
                            line.delete(ifvg.lnMid)
                            line.delete(ifvg.lnBtm)
                            linefill.delete(ifvg.fill)
                            if not na(ifvg.lbl)
                                label.delete(ifvg.lbl)
                        else
                            line.set_x2(ifvg.lnTop, bar_index)
                            line.set_x2(ifvg.lnMid, bar_index)
                            line.set_x2(ifvg.lnBtm, bar_index)
                            if not na(ifvg.lbl)
                                label.delete(ifvg.lbl)
                            if mitigationStyle == "Greyed out"
                                linefill.set_color(ifvg.fill, color.new(color.gray, 90))
                                line.set_color(ifvg.lnTop, color.new(color.gray, 70))
                                line.set_color(ifvg.lnMid, color.new(color.gray, 70))
                                line.set_color(ifvg.lnBtm, color.new(color.gray, 70))
                                line.set_style(ifvg.lnTop, line.style_dotted)
                                line.set_style(ifvg.lnBtm, line.style_dotted)

    unmitigatedCount = 0
    if array.size(ifvgList) > 0
        for i = 0 to array.size(ifvgList) - 1
            if not array.get(ifvgList, i).mitigated
                unmitigatedCount += 1

    while unmitigatedCount > maxCount and array.size(ifvgList) > 0
        removed = false
        for i = 0 to array.size(ifvgList) - 1
            if not removed
                ifvg = array.get(ifvgList, i)
                if not ifvg.mitigated
                    line.delete(ifvg.lnTop)
                    line.delete(ifvg.lnMid)
                    line.delete(ifvg.lnBtm)
                    linefill.delete(ifvg.fill)
                    if not na(ifvg.lbl)
                        label.delete(ifvg.lbl)
                    array.remove(ifvgList, i)
                    unmitigatedCount -= 1
                    removed := true

    while array.size(ifvgList) > maxCount * 3
        oldIFVG = array.shift(ifvgList)
        line.delete(oldIFVG.lnTop)
        line.delete(oldIFVG.lnMid)
        line.delete(oldIFVG.lnBtm)
        linefill.delete(oldIFVG.fill)
        if not na(oldIFVG.lbl)
            label.delete(oldIFVG.lbl)

processIFVGSlot(enable, tf, ifvgBars, currentBar, barOpen, barHigh, barLow, barClose, potentials, ifvgList, bullColor, bearColor) =>
    // Local copies — function parameters are not reassignable in Pine (CE10175)
    cb = currentBar
    bo = barOpen
    bh = barHigh
    bl = barLow
    bc = barClose
    if enable
        if timeframe.change(tf)
            if array.size(ifvgBars) > 4
                array.pop(ifvgBars)
            array.unshift(ifvgBars, cb)
            bo := HTFBar.new(open, bar_index)
            bh := HTFBar.new(high, bar_index)
            bl := HTFBar.new(low, bar_index)
            bc := HTFBar.new(close, bar_index)
            cb := HTFBarOHLC.new(bo, bh, bl, bc)

            if array.size(ifvgBars) >= 4
                bar0 = array.get(ifvgBars, 0)   // first bar AFTER the FVG formation
                bar1 = array.get(ifvgBars, 1)
                bar2 = array.get(ifvgBars, 2)
                bar3 = array.get(ifvgBars, 3)

                bullFvgTop = bar1.low.price
                bullFvgBtm = bar3.high.price
                hasBull = bullFvgTop > bullFvgBtm
                bearFvgTop = bar3.low.price
                bearFvgBtm = bar1.high.price
                hasBear = bearFvgTop > bearFvgBtm

                if hasBull
                    array.push(potentials, PotentialFVG.new(bullFvgTop, bullFvgBtm, bar1.low.idx, bar3.high.idx, true, false))
                if hasBear
                    array.push(potentials, PotentialFVG.new(bearFvgTop, bearFvgBtm, bar3.low.idx, bar1.high.idx, false, false))

                // Lifecycle against bar0: break -> invert. Tap (no break) -> consumed.
                i = array.size(potentials) - 1
                while i >= 0
                    pot = array.get(potentials, i)
                    if pot.isBullish
                        broke  = bar0.close.price < pot.bottom
                        tapped = bar0.low.price  <= pot.top
                        if broke
                            addIFVG(ifvgList, pot.top, pot.bottom, pot.topIdx, pot.btmIdx, false, bullColor, bearColor, tf, "IFVG", ifvg_show_label)
                            array.remove(potentials, i)
                        else if tapped
                            array.remove(potentials, i)
                    else
                        broke  = bar0.close.price > pot.top
                        tapped = bar0.high.price >= pot.bottom
                        if broke
                            addIFVG(ifvgList, pot.top, pot.bottom, pot.topIdx, pot.btmIdx, true, bullColor, bearColor, tf, "IFVG", ifvg_show_label)
                            array.remove(potentials, i)
                        else if tapped
                            array.remove(potentials, i)
                    i -= 1

                while array.size(potentials) > 30
                    array.shift(potentials)
        else
            if high > bh.price
                bh.price := high
                bh.idx := bar_index
            if low < bl.price
                bl.price := low
                bl.idx := bar_index
            bc.price := close
            bc.idx := bar_index

        updateIFVGs(ifvgList, ifvg_max_count, ifvg_mitigation_style, ifvg_mit_pct)
    [cb, bo, bh, bl, bc]

[icb1, ibo1, ibh1, ibl1, ibc1] = processIFVGSlot(ifvg1_enable, ifvg1_tf, ifvgBars1, ifvg1_currentBar, ifvg1_barOpen, ifvg1_barHigh, ifvg1_barLow, ifvg1_barClose, ifvg1_potentials, ifvg1_list, ifvg1_bull_color, ifvg1_bear_color)
ifvg1_currentBar := icb1
ifvg1_barOpen := ibo1
ifvg1_barHigh := ibh1
ifvg1_barLow := ibl1
ifvg1_barClose := ibc1

[icb2, ibo2, ibh2, ibl2, ibc2] = processIFVGSlot(ifvg2_enable, ifvg2_tf, ifvgBars2, ifvg2_currentBar, ifvg2_barOpen, ifvg2_barHigh, ifvg2_barLow, ifvg2_barClose, ifvg2_potentials, ifvg2_list, ifvg2_bull_color, ifvg2_bear_color)
ifvg2_currentBar := icb2
ifvg2_barOpen := ibo2
ifvg2_barHigh := ibh2
ifvg2_barLow := ibl2
ifvg2_barClose := ibc2

[icb3, ibo3, ibh3, ibl3, ibc3] = processIFVGSlot(ifvg3_enable, ifvg3_tf, ifvgBars3, ifvg3_currentBar, ifvg3_barOpen, ifvg3_barHigh, ifvg3_barLow, ifvg3_barClose, ifvg3_potentials, ifvg3_list, ifvg3_bull_color, ifvg3_bear_color)
ifvg3_currentBar := icb3
ifvg3_barOpen := ibo3
ifvg3_barHigh := ibh3
ifvg3_barLow := ibl3
ifvg3_barClose := ibc3
````
