# MTF Rejection Blocks 

- url: https://www.tradingview.com/script/6ioZffAI/
- type: indicator
- pine_id: PUB;8515eb6cb17f4a86bca47d63b10511ef
- version: 1.0

## Description

Spot high-probability rejection zones across up to 3 timeframes at once — without ever switching charts.

A Rejection Block forms at a swing point where price leaves a prominent wick — the footprint of aggressive buyers or sellers defending a level. Instead of the candle body, the zone is drawn between the wick extreme and the body, marking exactly where price got rejected and is likely to react again.

Every block is filtered by a configurable Wick Ratio and Pivot Length, so only clean, well-defined rejections make it onto your chart.

Features
- Up to 3 independent timeframes, each fully configurable
- Adjustable bullish/bearish colors per slot
- Wick Ratio + Pivot Length filters for high-quality zones only
- Three mitigation styles: Greyed Out, Keep Colored, or Hide once a zone is tapped
- Clean timeframe labels (e.g. "60 RB", "240 RB") — toggle on/off
- Max-blocks-per-slot control to keep your chart tidy

Built for SMC and orderflow traders who want clean multi-timeframe rejection context on a single chart.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════════
//  MTF Rejection Blocks [Orderflow-Academy]
// ════════════════════════════════════════════════════════════════════════════════

indicator("MTF Rejection Blocks ", "MTF RB", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ════════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ════════════════════════════════════════════════════════════════════════════════

string GRP_RB_S1  = "── RB Slot 1 ──"
string GRP_RB_S2  = "── RB Slot 2 ──"
string GRP_RB_S3  = "── RB Slot 3 ──"

string GRP_RB_GEN = "═══════ RB Settings ═══════"

string TT_TF      = "Timeframe for this slot. Lower than chart TF = ignored."
string TT_MITIG   = "Greyed Out = grey + dotted. Keep Colored = original color, lines stop. Hide = completely remove from chart."
string TT_LABEL   = "On = e.g. '60 RB'. Off = no label."
string TT_WICK    = "Rejection wick must be at least X times the size of the candle body."
string TT_PIVOT   = "Bars required on each side to confirm a swing high/low. Higher = stronger but fewer swings."

// ════════════════════════════════════════════════════════════════════════════════
// INPUTS: RB SLOTS
// ════════════════════════════════════════════════════════════════════════════════

rb1_enable = input.bool(true,  "Enable Slot 1", group=GRP_RB_S1)
rb1_tf     = input.timeframe("60", "Timeframe",  group=GRP_RB_S1, tooltip=TT_TF)
rb1_bull   = input.color(color.new(color.green, 70), "Bullish", group=GRP_RB_S1, inline="r1")
rb1_bear   = input.color(color.new(color.red,   70), "Bearish", group=GRP_RB_S1, inline="r1")

rb2_enable = input.bool(true,  "Enable Slot 2", group=GRP_RB_S2)
rb2_tf     = input.timeframe("240", "Timeframe", group=GRP_RB_S2, tooltip=TT_TF)
rb2_bull   = input.color(color.new(color.teal,   70), "Bullish", group=GRP_RB_S2, inline="r2")
rb2_bear   = input.color(color.new(color.maroon, 70), "Bearish", group=GRP_RB_S2, inline="r2")

rb3_enable = input.bool(false, "Enable Slot 3", group=GRP_RB_S3)
rb3_tf     = input.timeframe("D", "Timeframe",   group=GRP_RB_S3, tooltip=TT_TF)
rb3_bull   = input.color(color.new(color.lime,    70), "Bullish", group=GRP_RB_S3, inline="r3")
rb3_bear   = input.color(color.new(color.fuchsia, 70), "Bearish", group=GRP_RB_S3, inline="r3")

// RB General Settings
rb_max_count    = input.int(5, "Max RBs per Slot", minval=1, maxval=10, group=GRP_RB_GEN)
rb_pivot_len    = input.int(2, "Pivot Length", minval=1, maxval=10, group=GRP_RB_GEN, tooltip=TT_PIVOT)
rb_min_wick     = input.float(1.5, "Min Wick Ratio", minval=0.5, maxval=10.0, step=0.1, group=GRP_RB_GEN, tooltip=TT_WICK)
rb_mitig_style  = input.string("Greyed Out", "Mitigated RB Style", options=["Greyed Out", "Keep Colored", "Hide"], group=GRP_RB_GEN, tooltip=TT_MITIG)
rb_label_mode   = input.string("On", "RB Label", options=["On", "Off"], group=GRP_RB_GEN, tooltip=TT_LABEL)

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

type RB
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
// RB VISUAL HELPERS
// ════════════════════════════════════════════════════════════════════════════════

createRB(float top, float btm, int topIdx, int btmIdx, bool isBull, color col, string tfLabel, string labelMode) =>
    midPrice = math.avg(top, btm)
    midIdx   = math.ceil(math.avg(topIdx, btmIdx))

    lnTop = isBull ? line.new(topIdx, top, bar_index + 5, top, color=color.new(col, 50)) : line.new(topIdx, top, bar_index + 5, top, color=color.new(col, 50), width=2)
    lnMid = line.new(midIdx, midPrice, bar_index + 5, midPrice, style=line.style_dotted, color=color.new(col, 25))
    lnBtm = isBull ? line.new(btmIdx, btm, bar_index + 5, btm, color=color.new(col, 50), width=2) : line.new(btmIdx, btm, bar_index + 5, btm, color=color.new(col, 50))
    fill  = linefill.new(lnTop, lnBtm, color.new(col, 85))

    label lbl = na
    if labelMode != "Off"
        lblText = buildLabelText(tfLabel, "RB")
        lbl := label.new(bar_index + 1, midPrice, lblText, style=label.style_label_left, color=color(na), textcolor=color.white, size=size.small)

    RB.new(top, btm, topIdx, btmIdx, isBull, false, lnTop, lnMid, lnBtm, fill, lbl)

extendRB(RB r) =>
    r.lnTop.set_x2(bar_index + 5)
    r.lnMid.set_x2(bar_index + 5)
    r.lnBtm.set_x2(bar_index + 5)
    if not na(r.lbl)
        r.lbl.set_x(bar_index + 1)
    int(na)

greyOutRB(RB r) =>
    r.fill.set_color(color.new(color.gray, 90))
    r.lnTop.set_color(color.new(color.gray, 70))
    r.lnMid.set_color(color.new(color.gray, 70))
    r.lnBtm.set_color(color.new(color.gray, 70))
    r.lnTop.set_style(line.style_dotted)
    r.lnBtm.set_style(line.style_dotted)
    int(na)

freezeRB(RB r) =>
    r.lnTop.set_x2(bar_index)
    r.lnMid.set_x2(bar_index)
    r.lnBtm.set_x2(bar_index)
    if not na(r.lbl)
        label.delete(r.lbl)
    int(na)

deleteRB(RB r) =>
    line.delete(r.lnTop)
    line.delete(r.lnMid)
    line.delete(r.lnBtm)
    linefill.delete(r.fill)
    if not na(r.lbl)
        label.delete(r.lbl)
    int(na)

applyMitigationStyle(RB r, string mitigStyle) =>
    if mitigStyle == "Hide"
        deleteRB(r)
    else
        freezeRB(r)
        if mitigStyle == "Greyed Out"
            greyOutRB(r)
    int(na)

trimRBList(array<RB> list, int maxCount) =>
    while list.size() > maxCount * 2
        oldest = list.shift()
        deleteRB(oldest)

    unmitCount = 0
    for r in list
        if not r.mitigated
            unmitCount += 1

    if unmitCount > maxCount
        toRemove = unmitCount - maxCount
        for i = 0 to list.size() - 1
            if toRemove <= 0
                break
            r = list.get(i)
            if not r.mitigated
                deleteRB(r)
                list.remove(i)
                toRemove -= 1
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// RB MANAGEMENT
// ════════════════════════════════════════════════════════════════════════════════

manageRBs(array<RB> list, SlotState slot, float rbTop, float rbBtm, int rbTopIdx, int rbBtmIdx, bool rbValid, bool rbBullish, color bullCol, color bearCol, int maxCount, string tfLabel, string mitigStyle, string labelMode) =>
    if rbValid and rbTop > rbBtm
        if na(slot.prevTop) or rbTop != slot.prevTop
            col = rbBullish ? bullCol : bearCol
            newRB = createRB(rbTop, rbBtm, rbTopIdx, rbBtmIdx, rbBullish, col, tfLabel, labelMode)
            list.push(newRB)
            slot.prevTop := rbTop

    if list.size() > 0
        for i = list.size() - 1 to 0
            r = list.get(i)
            if not r.mitigated
                extendRB(r)
                if bar_index > math.max(r.topIdx, r.btmIdx) + 1
                    mitTouch = r.isBullish ? (low <= r.top) : (high >= r.bottom)
                    if mitTouch
                        r.mitigated := true
                        applyMitigationStyle(r, mitigStyle)
                        if mitigStyle == "Hide"
                            list.remove(i)

    trimRBList(list, maxCount)
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// SLOT STATE
// ════════════════════════════════════════════════════════════════════════════════

var SlotState rbS1 = makeSlot(rb1_tf)
var SlotState rbS2 = makeSlot(rb2_tf)
var SlotState rbS3 = makeSlot(rb3_tf)

var array<RB> rb1List = array.new<RB>()
var array<RB> rb2List = array.new<RB>()
var array<RB> rb3List = array.new<RB>()

// ════════════════════════════════════════════════════════════════════════════════
// PROCESS RB SLOT
// ════════════════════════════════════════════════════════════════════════════════

processRBSlot(SlotState slot, array<RB> list, color bullCol, color bearCol, int maxCount, int pivotLen, float minWick, string mitigStyle, string labelMode) =>
    rbTop = float(na), rbBtm = float(na), rbTopIdx = int(na), rbBtmIdx = int(na)
    rbValid = false, rbBullish = false

    win = 2 * pivotLen + 1

    if timeframe.change(slot.tf)
        rollSlot(slot, win)

        if slot.bars.size() >= win
            center = slot.bars.get(pivotLen)

            // pivot detection
            isPivotHigh = true
            isPivotLow  = true
            for i = 0 to win - 1
                if i != pivotLen
                    other = slot.bars.get(i)
                    if center.h.price <= other.h.price
                        isPivotHigh := false
                    if center.l.price >= other.l.price
                        isPivotLow := false

            body      = math.abs(center.c.price - center.o.price)
            bodyTop   = math.max(center.o.price, center.c.price)
            bodyBtm   = math.min(center.o.price, center.c.price)
            upperWick = center.h.price - bodyTop
            lowerWick = bodyBtm - center.l.price

            // Bearish RB at swing high (prominent upper wick)
            if isPivotHigh and upperWick > 0 and upperWick >= body * minWick
                rbValid := true
                rbBullish := false
                rbTop := center.h.price
                rbBtm := bodyTop
                rbTopIdx := center.h.idx
                rbBtmIdx := center.o.idx

            // Bullish RB at swing low (prominent lower wick)
            else if isPivotLow and lowerWick > 0 and lowerWick >= body * minWick
                rbValid := true
                rbBullish := true
                rbTop := bodyBtm
                rbBtm := center.l.price
                rbTopIdx := center.o.idx
                rbBtmIdx := center.l.idx
    else
        updateCurrent(slot.current)

    manageRBs(list, slot, rbTop, rbBtm, rbTopIdx, rbBtmIdx, rbValid, rbBullish, bullCol, bearCol, maxCount, slot.tf, mitigStyle, labelMode)
    int(na)

// ════════════════════════════════════════════════════════════════════════════════
// EXECUTE
// ════════════════════════════════════════════════════════════════════════════════

if rb1_enable
    processRBSlot(rbS1, rb1List, rb1_bull, rb1_bear, rb_max_count, rb_pivot_len, rb_min_wick, rb_mitig_style, rb_label_mode)
if rb2_enable
    processRBSlot(rbS2, rb2List, rb2_bull, rb2_bear, rb_max_count, rb_pivot_len, rb_min_wick, rb_mitig_style, rb_label_mode)
if rb3_enable
    processRBSlot(rbS3, rb3List, rb3_bull, rb3_bear, rb_max_count, rb_pivot_len, rb_min_wick, rb_mitig_style, rb_label_mode)
````
