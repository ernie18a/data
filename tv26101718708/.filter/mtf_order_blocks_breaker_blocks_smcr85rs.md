# MTF Order Blocks & Breaker Blocks

- url: https://www.tradingview.com/script/sMcR85rs/
- type: indicator
- pine_id: PUB;3cbdd6b9756941c4bdb1956b12f55615
- version: 1.0

## Description

Track institutional Order Blocks and Breaker Blocks across up to 3 timeframes at once — without ever switching charts.

Order Blocks mark the last opposite candle before an impulsive move, highlighting where smart money positioned before the push. Breaker Blocks are Order Blocks that price has closed through, flipping their bias and turning old support into resistance.

Each block is validated by a configurable Impulse Ratio, so only moves backed by a strong confirmation candle get plotted — filtering out the noise.

Features
- Up to 3 independent timeframes per type (OBs and BBs), each fully configurable
- Adjustable bullish/bearish colors per slot
- Impulse Ratio filter for high-quality zones only
- Three mitigation styles: Greyed Out, Keep Colored, or Hide once a zone is tapped
- Clean timeframe labels (e.g. "60 OB", "240 BB") — toggle on/off
- Max-blocks-per-slot control to keep your chart tidy

Built for SMC and orderflow traders who want clean multi-timeframe context on a single chart.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════════

indicator("MTF Order Blocks & Breaker Blocks", "MTF OB & BB", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ════════════════════════════════════════════════════════════════════════════════

string GRP_OB_S1  = "── OB Slot 1 ──"
string GRP_OB_S2  = "── OB Slot 2 ──"
string GRP_OB_S3  = "── OB Slot 3 ──"

string GRP_BB_S1  = "── BB Slot 1 ──"
string GRP_BB_S2  = "── BB Slot 2 ──"
string GRP_BB_S3  = "── BB Slot 3 ──"

string GRP_OB_GEN  = "═══════ OB Settings ═══════"
string GRP_BB_GEN  = "═══════ BB Settings ═══════"

string TT_TF       = "Timeframe for this slot. Lower than chart TF = ignored."
string TT_MITIG    = "Greyed Out = grey + dotted. Keep Colored = original color, lines stop. Hide = completely remove from chart."
string TT_LABEL    = "On = e.g. '60 OB'. Off = no label."
string TT_IMPULSE  = "Confirmation candle must be at least X times the size of the OB candle."

// ════════════════════════════════════════════════════════════════════════════════
// INPUTS: OB SLOTS
// ════════════════════════════════════════════════════════════════════════════════

ob1_enable = input.bool(true,  "Enable Slot 1", group=GRP_OB_S1)
ob1_tf     = input.timeframe("60", "Timeframe",  group=GRP_OB_S1, tooltip=TT_TF)
ob1_bull   = input.color(color.new(color.green, 70), "Bullish", group=GRP_OB_S1, inline="o1")
ob1_bear   = input.color(color.new(color.red,   70), "Bearish", group=GRP_OB_S1, inline="o1")

ob2_enable = input.bool(true,  "Enable Slot 2", group=GRP_OB_S2)
ob2_tf     = input.timeframe("240", "Timeframe", group=GRP_OB_S2, tooltip=TT_TF)
ob2_bull   = input.color(color.new(color.teal,   70), "Bullish", group=GRP_OB_S2, inline="o2")
ob2_bear   = input.color(color.new(color.maroon, 70), "Bearish", group=GRP_OB_S2, inline="o2")

ob3_enable = input.bool(false, "Enable Slot 3", group=GRP_OB_S3)
ob3_tf     = input.timeframe("D", "Timeframe",   group=GRP_OB_S3, tooltip=TT_TF)
ob3_bull   = input.color(color.new(color.lime,    70), "Bullish", group=GRP_OB_S3, inline="o3")
ob3_bear   = input.color(color.new(color.fuchsia, 70), "Bearish", group=GRP_OB_S3, inline="o3")

// OB General Settings
ob_max_count    = input.int(5, "Max OBs per Slot", minval=1, maxval=10, group=GRP_OB_GEN)
ob_mitig_style  = input.string("Greyed Out", "Mitigated OB Style", options=["Greyed Out", "Keep Colored", "Hide"], group=GRP_OB_GEN, tooltip=TT_MITIG)
ob_label_mode   = input.string("On", "OB Label", options=["On", "Off"], group=GRP_OB_GEN, tooltip=TT_LABEL)
ob_min_impulse  = input.float(1.5, "Min Impulse Ratio", minval=1.0, maxval=5.0, step=0.1, group=GRP_OB_GEN, tooltip=TT_IMPULSE)

// ════════════════════════════════════════════════════════════════════════════════
// INPUTS: BB SLOTS
// ════════════════════════════════════════════════════════════════════════════════

bb1_enable = input.bool(true,  "Enable Slot 1", group=GRP_BB_S1)
bb1_tf     = input.timeframe("60", "Timeframe",  group=GRP_BB_S1, tooltip=TT_TF)
bb1_bull   = input.color(color.new(color.lime,    70), "Bullish", group=GRP_BB_S1, inline="b1")
bb1_bear   = input.color(color.new(color.fuchsia, 70), "Bearish", group=GRP_BB_S1, inline="b1")

bb2_enable = input.bool(true,  "Enable Slot 2", group=GRP_BB_S2)
bb2_tf     = input.timeframe("240", "Timeframe", group=GRP_BB_S2, tooltip=TT_TF)
bb2_bull   = input.color(color.new(color.lime,    70), "Bullish", group=GRP_BB_S2, inline="b2")
bb2_bear   = input.color(color.new(color.fuchsia, 70), "Bearish", group=GRP_BB_S2, inline="b2")

bb3_enable = input.bool(false, "Enable Slot 3", group=GRP_BB_S3)
bb3_tf     = input.timeframe("D", "Timeframe",   group=GRP_BB_S3, tooltip=TT_TF)
bb3_bull   = input.color(color.new(color.lime,    70), "Bullish", group=GRP_BB_S3, inline="b3")
bb3_bear   = input.color(color.new(color.fuchsia, 70), "Bearish", group=GRP_BB_S3, inline="b3")

// BB General Settings
bb_max_count    = input.int(5, "Max BBs per Slot", minval=1, maxval=10, group=GRP_BB_GEN)
bb_mitig_style  = input.string("Greyed Out", "Mitigated BB Style", options=["Greyed Out", "Keep Colored", "Hide"], group=GRP_BB_GEN, tooltip=TT_MITIG)
bb_label_mode   = input.string("On", "BB Label", options=["On", "Off"], group=GRP_BB_GEN, tooltip=TT_LABEL)
bb_min_impulse  = input.float(1.5, "Min Impulse Ratio", minval=1.0, maxval=5.0, step=0.1, group=GRP_BB_GEN, tooltip=TT_IMPULSE)

// ════════════════════════════════════════════════════════════════════════════════
// TYPES
// ════════════════════════════════════════════════════════════════════════════════

type BarRef
    float price = na
    int   idx   = na

type HTFBar
    BarRef o
    BarRef h
    BarRef l
    BarRef c

type SlotState
    string tf
    array<HTFBar> bars
    HTFBar        current
    float         prevTop = na

type OB
    float    top
    float    bottom
    int      topIdx
    int      btmIdx
    bool     isBullish
    bool     mitigated
    line     lnTop
    line     lnMid
    line     lnBtm
    linefill fill
    label    lbl

type PotentialOB
    float top
    float bottom
    int   topIdx
    int   btmIdx
    bool  isBullish
    bool  broken

// ════════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ════════════════════════════════════════════════════════════════════════════════

makeBar() =>
    HTFBar.new(BarRef.new(open, bar_index), BarRef.new(high, bar_index), BarRef.new(low, bar_index), BarRef.new(close, bar_index))

makeSlot(string tf) =>
    SlotState.new(tf, array.new<HTFBar>(), makeBar(), na)

updateCurrent(HTFBar bar) =>
    if high > bar.h.price
        bar.h.price := high
        bar.h.idx   := bar_index
    if low < bar.l.price
        bar.l.price := low
        bar.l.idx   := bar_index
    bar.c.price := close
    bar.c.idx   := bar_index
    int(na)

rollSlot(SlotState slot, int historySize) =>
    if slot.bars.size() >= historySize
        slot.bars.pop()
    slot.bars.unshift(slot.current)
    slot.current := makeBar()
    int(na)

buildLabelText(string tfLabel, string typeLabel) =>
    tfLabel + " " + typeLabel

// ════════════════════════════════════════════════════════════════════════════════
// OB VISUAL HELPERS
// ════════════════════════════════════════════════════════════════════════════════

createOB(float top, float btm, int topIdx, int btmIdx, bool isBull, color col, string tfLabel, string typeLabel, string labelMode) =>
    midPrice = math.avg(top, btm)
    midIdx   = math.ceil(math.avg(topIdx, btmIdx))

    lnTop = isBull ? line.new(topIdx, top, bar_index + 5, top, color=color.new(col, 50)) : line.new(topIdx, top, bar_index + 5, top, color=color.new(col, 50), width=2)
    lnMid = line.new(midIdx, midPrice, bar_index + 5, midPrice, style=line.style_dotted, color=color.new(col, 25))
    lnBtm = isBull ? line.new(btmIdx, btm, bar_index + 5, btm, color=color.new(col, 50), width=2) : line.new(btmIdx, btm, bar_index + 5, btm, color=color.new(col, 50))
    fill  = linefill.new(lnTop, lnBtm, color.new(col, 85))

    label lbl = na
    if labelMode != "Off"
        lblText = buildLabelText(tfLabel, typeLabel)
        lbl := label.new(bar_index + 1, midPrice, lblText, style=label.style_label_left, color=color(na), textcolor=color.white, size=size.small)

    OB.new(top, btm, topIdx, btmIdx, isBull, false, lnTop, lnMid, lnBtm, fill, lbl)

extendOB(OB o) =>
    o.lnTop.set_x2(bar_index + 5)
    o.lnMid.set_x2(bar_index + 5)
    o.lnBtm.set_x2(bar_index + 5)
    if not na(o.lbl)
        o.lbl.set_x(bar_index + 1)
    int(na)

greyOutOB(OB o) =>
    o.fill.set_color(color.new(color.gray, 90))
    o.lnTop.set_color(color.new(color.gray, 70))
    o.lnMid.set_color(color.new(color.gray, 70))
    o.lnBtm.set_color(color.new(color.gray, 70))
    o.lnTop.set_style(line.style_dotted)
    o.lnBtm.set_style(line.style_dotted)
    int(na)

freezeOB(OB o) =>
    o.lnTop.set_x2(bar_index)
    o.lnMid.set_x2(bar_index)
    o.lnBtm.set_x2(bar_index)
    if not na(o.lbl)
        label.delete(o.lbl)
    int(na)

deleteOB(OB o) =>
    line.delete(o.lnTop)
    line.delete(o.lnMid)
    line.delete(o.lnBtm)
    linefill.delete(o.fill)
    if not na(o.lbl)
        label.delete(o.lbl)
    int(na)

applyMitigationStyle(OB o, string mitigStyle) =>
    if mitigStyle == "Hide"
        deleteOB(o)
    else
        freezeOB(o)
        if mitigStyle == "Greyed Out"
            greyOutOB(o)
    int(na)

trimOBList(array<OB> list, int maxCount) =>
    while list.size() > maxCount * 2
        oldest = list.shift()
        deleteOB(oldest)

    unmitCount = 0
    for o in list
        if not o.mitigated
            unmitCount += 1

    if unmitCount > maxCount
        toRemove = unmitCount - maxCount
        for i = 0 to list.size() - 1
            if toRemove <= 0
                break
            o = list.get(i)
            if not o.mitigated
                deleteOB(o)
                list.remove(i)
                toRemove -= 1
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// OB MANAGEMENT
// ════════════════════════════════════════════════════════════════════════════════

manageOBs(array<OB> list, SlotState slot, float obTop, float obBtm, int obTopIdx, int obBtmIdx, bool obValid, bool obBullish, color bullCol, color bearCol, int maxCount, string tfLabel, string mitigStyle, string labelMode) =>
    if obValid and obTop > obBtm
        if na(slot.prevTop) or obTop != slot.prevTop
            col = obBullish ? bullCol : bearCol
            newOB = createOB(obTop, obBtm, obTopIdx, obBtmIdx, obBullish, col, tfLabel, "OB", labelMode)
            list.push(newOB)
            slot.prevTop := obTop

    if list.size() > 0
        for i = list.size() - 1 to 0
            o = list.get(i)
            if not o.mitigated
                extendOB(o)
                if bar_index > math.max(o.topIdx, o.btmIdx) + 1
                    mitTouch = o.isBullish ? (low <= o.top) : (high >= o.bottom)
                    if mitTouch
                        o.mitigated := true
                        applyMitigationStyle(o, mitigStyle)
                        if mitigStyle == "Hide"
                            list.remove(i)

    trimOBList(list, maxCount)
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// BB MANAGEMENT (Breaker Blocks)
// ════════════════════════════════════════════════════════════════════════════════

manageBBs(array<OB> list, array<PotentialOB> potentials, HTFBar closedBar, color bullCol, color bearCol, int maxCount, string tfLabel, string mitigStyle, string labelMode) =>
    for pot in potentials
        if not pot.broken
            if pot.isBullish and closedBar.c.price < pot.bottom
                pot.broken := true
                newBB = createOB(pot.top, pot.bottom, pot.topIdx, pot.btmIdx, false, bearCol, tfLabel, "BB", labelMode)
                list.push(newBB)
            else if not pot.isBullish and closedBar.c.price > pot.top
                pot.broken := true
                newBB = createOB(pot.top, pot.bottom, pot.topIdx, pot.btmIdx, true, bullCol, tfLabel, "BB", labelMode)
                list.push(newBB)

    if list.size() > 0
        for i = list.size() - 1 to 0
            b = list.get(i)
            if not b.mitigated
                extendOB(b)
                if bar_index > math.max(b.topIdx, b.btmIdx) + 1
                    mitTouch = b.isBullish ? (low <= b.top) : (high >= b.bottom)
                    if mitTouch
                        b.mitigated := true
                        applyMitigationStyle(b, mitigStyle)
                        if mitigStyle == "Hide"
                            list.remove(i)

    while potentials.size() > 30
        potentials.shift()

    trimOBList(list, maxCount)
    int(na)

updateBBList(array<OB> list, string mitigStyle) =>
    if list.size() > 0
        for i = list.size() - 1 to 0
            b = list.get(i)
            if not b.mitigated
                extendOB(b)
                if bar_index > math.max(b.topIdx, b.btmIdx) + 1
                    mitTouch = b.isBullish ? (low <= b.top) : (high >= b.bottom)
                    if mitTouch
                        b.mitigated := true
                        applyMitigationStyle(b, mitigStyle)
                        if mitigStyle == "Hide"
                            list.remove(i)
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// SLOT STATE
// ════════════════════════════════════════════════════════════════════════════════

var SlotState obS1 = makeSlot(ob1_tf)
var SlotState obS2 = makeSlot(ob2_tf)
var SlotState obS3 = makeSlot(ob3_tf)

var array<OB> ob1List = array.new<OB>()
var array<OB> ob2List = array.new<OB>()
var array<OB> ob3List = array.new<OB>()

var SlotState bbS1 = makeSlot(bb1_tf)
var SlotState bbS2 = makeSlot(bb2_tf)
var SlotState bbS3 = makeSlot(bb3_tf)

var array<OB> bb1List = array.new<OB>()
var array<OB> bb2List = array.new<OB>()
var array<OB> bb3List = array.new<OB>()

var array<PotentialOB> bb1Pot = array.new<PotentialOB>()
var array<PotentialOB> bb2Pot = array.new<PotentialOB>()
var array<PotentialOB> bb3Pot = array.new<PotentialOB>()

// ════════════════════════════════════════════════════════════════════════════════
// PROCESS OB SLOT
// ════════════════════════════════════════════════════════════════════════════════

processOBSlot(SlotState slot, array<OB> list, color bullCol, color bearCol, int maxCount, string mitigStyle, string labelMode, float minImpulse) =>
    obTop = float(na), obBtm = float(na), obTopIdx = int(na), obBtmIdx = int(na)
    obValid = false, obBullish = false

    if timeframe.change(slot.tf)
        rollSlot(slot, 3)

        if slot.bars.size() >= 2
            b0 = slot.bars.get(0)
            b1 = slot.bars.get(1)

            obSize = b1.h.price - b1.l.price
            impulseSize = b0.h.price - b0.l.price
            impulseValid = impulseSize >= obSize * minImpulse

            if b1.c.price < b1.o.price and b0.c.price > b1.h.price and impulseValid
                obValid := true
                obBullish := true
                obTop := b1.h.price
                obBtm := b1.l.price
                obTopIdx := b1.h.idx
                obBtmIdx := b1.l.idx

            if b1.c.price > b1.o.price and b0.c.price < b1.l.price and impulseValid
                obValid := true
                obBullish := false
                obTop := b1.h.price
                obBtm := b1.l.price
                obTopIdx := b1.h.idx
                obBtmIdx := b1.l.idx
    else
        updateCurrent(slot.current)

    manageOBs(list, slot, obTop, obBtm, obTopIdx, obBtmIdx, obValid, obBullish, bullCol, bearCol, maxCount, slot.tf, mitigStyle, labelMode)
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// PROCESS BB SLOT
// ════════════════════════════════════════════════════════════════════════════════

processBBSlot(SlotState slot, array<OB> list, array<PotentialOB> potentials, color bullCol, color bearCol, int maxCount, string mitigStyle, string labelMode, float minImpulse) =>
    var HTFBar closedBar = makeBar()
    bool barJustClosed = false

    if timeframe.change(slot.tf)
        rollSlot(slot, 3)
        if slot.bars.size() >= 1
            closedBar := slot.bars.get(0)
            barJustClosed := true

        if slot.bars.size() >= 2
            b0 = slot.bars.get(0)
            b1 = slot.bars.get(1)

            obSize = b1.h.price - b1.l.price
            impulseSize = b0.h.price - b0.l.price
            impulseValid = impulseSize >= obSize * minImpulse

            if b1.c.price < b1.o.price and b0.c.price > b1.h.price and impulseValid
                potentials.push(PotentialOB.new(b1.h.price, b1.l.price, b1.h.idx, b1.l.idx, true, false))

            if b1.c.price > b1.o.price and b0.c.price < b1.l.price and impulseValid
                potentials.push(PotentialOB.new(b1.h.price, b1.l.price, b1.h.idx, b1.l.idx, false, false))
    else
        updateCurrent(slot.current)

    if barJustClosed
        manageBBs(list, potentials, closedBar, bullCol, bearCol, maxCount, slot.tf, mitigStyle, labelMode)
    else
        updateBBList(list, mitigStyle)
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// EXECUTE
// ════════════════════════════════════════════════════════════════════════════════

if ob1_enable
    processOBSlot(obS1, ob1List, ob1_bull, ob1_bear, ob_max_count, ob_mitig_style, ob_label_mode, ob_min_impulse)
if ob2_enable
    processOBSlot(obS2, ob2List, ob2_bull, ob2_bear, ob_max_count, ob_mitig_style, ob_label_mode, ob_min_impulse)
if ob3_enable
    processOBSlot(obS3, ob3List, ob3_bull, ob3_bear, ob_max_count, ob_mitig_style, ob_label_mode, ob_min_impulse)

if bb1_enable
    processBBSlot(bbS1, bb1List, bb1Pot, bb1_bull, bb1_bear, bb_max_count, bb_mitig_style, bb_label_mode, bb_min_impulse)
if bb2_enable
    processBBSlot(bbS2, bb2List, bb2Pot, bb2_bull, bb2_bear, bb_max_count, bb_mitig_style, bb_label_mode, bb_min_impulse)
if bb3_enable
    processBBSlot(bbS3, bb3List, bb3Pot, bb3_bull, bb3_bear, bb_max_count, bb_mitig_style, bb_label_mode, bb_min_impulse)
````
