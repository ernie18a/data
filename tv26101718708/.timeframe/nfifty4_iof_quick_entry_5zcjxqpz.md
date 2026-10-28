# NFIFTY4 IOF Quick Entry 

- url: https://www.tradingview.com/script/5zcJxqpz-NFIFTY4-IOF-Quick-Entry/
- type: indicator
- pine_id: PUB;f60bd1829d0a44089e857c71146efb79
- version: 1.0

## Description

IOF Quick Entry — v2.0
Institutional Order Flow Zone Scanner with Trade Lifecycle Tracking

What it does
IOF Quick Entry automatically detects Institutional Order Flow zones across up to 3 timeframes simultaneously and tracks every trade from entry to close — no manual zone drawing, no repainting, no guesswork.
The system is built on the IBI (Impulse → Base → Impulse) pattern. When institutions place large limit orders, they leave consolidation clusters between two strong impulse candles. These clusters become high-probability zones where unfilled institutional orders are still sitting. When price returns, those orders get filled — and that reaction is your trade.

Zone Detection

Detects demand and supply zones on confirmed, closed bars only — zones never form on a live candle
Supports LTF, ITF, and HTF simultaneously (default 5m / 15m / 60m, fully configurable)
Body-close invalidation — wicks never kill a zone, only a full body close through the far extreme does
Zones auto-extend right until invalidated

Entry Plan

Entry at OF 0% — the body/wick junction, the purest institutional entry point
Stop loss placed at the far wick extreme plus a configurable tick buffer
TP1, TP2, TP3 at 1×, 2×, 3× zone height beyond entry
Contract count auto-calculated from your dollar risk input using the formula: floor( [symbol="NGM:RISK"]NGM:RISK[/symbol] ÷ (SL ticks × tick value) ) — works on MNQ, MES, MGC, ES, NQ, GC and any other futures instrument automatically

Trade Lifecycle (Phase 3)

Every zone arms automatically when price enters proximity
Fills when price wicks through the entry level
Closes as WIN, LOSS, or BE based on which levels are hit on confirmed bars
Trail-compiled R — win R is the average of all TPs hit, not just the last one
Block re-arm after loss option — zone won't fire again after producing a loss
Arm cooldown between successive trades on the same zone

Performance Dashboard

Shows last 20 trades with: side (L/S), timeframe, entry price, stop price, contracts, dollar risk, SL ticks, and result
Live status row showing currently ARMED and ACTIVE trades
Totals footer: Wins / Losses / BE / Win Rate % / Total R / Net $
Win rate calculated as W ÷ (W+L) — breakevens excluded from denominator


Instruments
Designed for futures. Tested on MNQ, MES, MGC, ES, NQ, GC. Contract sizing auto-adapts to any instrument via syminfo — no manual configuration needed.
No repainting
All zone detection and trade lifecycle processing runs exclusively on barstate.isconfirmed. Zones are stamped with historical bar timestamps. What you see on the chart is exactly what would have appeared in real time.

This indicator does not provide financial advice. Past performance of detected zones does not guarantee future results. Always manage risk and validate setups independently before trading.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════════
// IOF QUICK ENTRY — v2.0
// ─────────────────────────────────────────────────────────────────────────────
// v2.0 adds Phase 3 trade lifecycle tracking + performance dashboard.
//
// Zone Detection : IBI (Impulse→Base→Impulse) on confirmed bars, 3 TFs
// Entry          : OF 0% — body/wick junction
// SL             : far wick extreme + tick buffer
// TPs            : 1× / 2× / 3× zone height beyond entry
// Sizing         : floor( $risk / (SL ticks × tick value) ) capped at max
// Lifecycle      : ARMED(0) → ACTIVE(1) → WIN(2) / LOSS(3) / BE(4)
// Dashboard      : Last 100 trades — entry price, side, TF, cts, $ risk,
//                  outcome, R, totals (W/L/BE/WR/Total R/Total $)
// ═══════════════════════════════════════════════════════════════════════════════
indicator("IOF Quick Entry — v2.0", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — INPUTS
// ─────────────────────────────────────────────────────────────────────────────

grpTF  = "Timeframes"
useLTF = input.bool(true,  "Use LTF", group=grpTF, inline="ltf")
ltf_tf = input.timeframe("5",  "",    group=grpTF, inline="ltf")
useITF = input.bool(false, "Use ITF", group=grpTF, inline="itf")
itf_tf = input.timeframe("15", "",    group=grpTF, inline="itf")
useHTF = input.bool(false, "Use HTF", group=grpTF, inline="htf")
htf_tf = input.timeframe("60", "",    group=grpTF, inline="htf")

grpDet            = "Zone Detection"
ltfBaseMinWickPct = input.float(50.0, "LTF Base Min Wick %",    minval=1.0, maxval=99.0, step=0.5, group=grpDet)
ltfImpMinBodyPct  = input.float(50.0, "LTF Impulse Min Body %", minval=1.0, maxval=99.0, step=0.5, group=grpDet)
itfBaseMinWickPct = input.float(50.0, "ITF Base Min Wick %",    minval=1.0, maxval=99.0, step=0.5, group=grpDet)
itfImpMinBodyPct  = input.float(50.0, "ITF Impulse Min Body %", minval=1.0, maxval=99.0, step=0.5, group=grpDet)
htfBaseMinWickPct = input.float(50.0, "HTF Base Min Wick %",    minval=1.0, maxval=99.0, step=0.5, group=grpDet)
htfImpMinBodyPct  = input.float(50.0, "HTF Impulse Min Body %", minval=1.0, maxval=99.0, step=0.5, group=grpDet)
maxBaseCandles    = input.int(10, "Max Base Candles", minval=1, maxval=25, group=grpDet)
useStrictImpulse  = input.bool(false, "Strict Impulse Mode", group=grpDet)

grpDisp     = "Zone Display"
zoneTransp  = input.int(80,  "Zone Fill Transparency", minval=0, maxval=100, group=grpDisp)
showMid     = input.bool(true,  "Show Midline",       group=grpDisp)
extendZone  = input.bool(true,  "Extend Zones Right", group=grpDisp)
showZoneLbl = input.bool(true,  "Show Zone Labels",   group=grpDisp)
colLtfDem   = input.color(color.green,                "LTF Demand", group=grpDisp, inline="c1")
colLtfSup   = input.color(color.red,                  "LTF Supply", group=grpDisp, inline="c1")
colItfDem   = input.color(color.new(color.teal,   0), "ITF Demand", group=grpDisp, inline="c2")
colItfSup   = input.color(color.new(color.maroon, 0), "ITF Supply", group=grpDisp, inline="c2")
colHtfDem   = input.color(color.new(color.blue,   0), "HTF Demand", group=grpDisp, inline="c3")
colHtfSup   = input.color(color.new(color.purple, 0), "HTF Supply", group=grpDisp, inline="c3")

grpPlan      = "Entry Plan"
dollarRisk   = input.float(100.0, "Dollar Risk Per Trade ($)", minval=1.0, maxval=10000.0, step=10.0, group=grpPlan)
maxContracts = input.int(20,    "Max Contracts Cap",                  minval=1,    maxval=200,   group=grpPlan)
slBufTicks   = input.int(2,     "SL Buffer (ticks beyond far wick)",  minval=0,    maxval=20,    group=grpPlan)
numTPs       = input.int(3,     "Number of TPs",                      minval=1,    maxval=5,     group=grpPlan)
tpMult       = input.float(1.0, "TP Step (x zone height)",            minval=0.25, maxval=5.0,   step=0.25, group=grpPlan)
armProx      = input.float(3.0, "Arm Proximity (x zone height)",      minval=0.5,  maxval=20.0,  step=0.5,  group=grpPlan)
maxPlans     = input.int(5,     "Max Visible Plans",                   minval=1,    maxval=20,    group=grpPlan)
colEntry     = input.color(color.green, "Entry Line (LONG)",  group=grpPlan, inline="pl")
colEntShort  = input.color(color.red,   "Entry Line (SHORT)", group=grpPlan, inline="pl")
colSL        = input.color(color.red,   "SL Line",  group=grpPlan)
colTP        = input.color(color.aqua,  "TP Lines", group=grpPlan)

grpLC        = "Trade Lifecycle"
trackTrades  = input.bool(true,  "Track Trades (Phase 3)", group=grpLC, tooltip="Enables ARMED→ACTIVE→WIN/LOSS/BE lifecycle on confirmed bars.")
maxPastTrades= input.int(20,    "Max Past Trades Stored",  minval=5,  maxval=100, group=grpLC)
armCooldown  = input.int(2,     "Arm Cooldown Bars",        minval=0,  maxval=20,  group=grpLC, tooltip="Min bars between arming new trades from same zone.")
blockReArm   = input.bool(false,"Block Re-Arm After Loss",  group=grpLC, tooltip="Zone that produced a LOSS won't re-arm while that trade is still stored.")
colWin       = input.color(color.new(color.green,  20), "WIN color",  group=grpLC, inline="oc")
colBE        = input.color(color.new(color.orange, 20), "BE color",   group=grpLC, inline="oc")
colLoss      = input.color(color.new(color.red,    20), "LOSS color", group=grpLC, inline="oc")
showMarkers  = input.bool(true, "Show TP/SL Markers on Chart", group=grpLC)

grpDash      = "Dashboard"
showDash     = input.bool(true, "Show Performance Dashboard", group=grpDash)
dashPos      = input.string("top_right", "Dashboard Position", options=["top_right","top_left","bottom_right","bottom_left"], group=grpDash)
dashRows     = input.int(20,  "Max Rows Shown", minval=5, maxval=50,  group=grpDash)
dashSize     = input.string("small", "Text Size", options=["tiny","small","normal"], group=grpDash)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — HELPERS
// ─────────────────────────────────────────────────────────────────────────────

f_tfLabel(tfStr) =>
    string lbl = tfStr
    if tfStr == "1"
        lbl := "1m"
    else if tfStr == "2"
        lbl := "2m"
    else if tfStr == "3"
        lbl := "3m"
    else if tfStr == "5"
        lbl := "5m"
    else if tfStr == "15"
        lbl := "15m"
    else if tfStr == "30"
        lbl := "30m"
    else if tfStr == "60"
        lbl := "1H"
    else if tfStr == "240"
        lbl := "4H"
    else if tfStr == "D"
        lbl := "D"
    else if tfStr == "W"
        lbl := "W"
    lbl

f_fillColor(isDem, tfIdx) =>
    color c = color.gray
    if tfIdx == 1
        c := isDem ? colLtfDem : colLtfSup
    else if tfIdx == 2
        c := isDem ? colItfDem : colItfSup
    else if tfIdx == 3
        c := isDem ? colHtfDem : colHtfSup
    c

f_zTop(isDem, bodyHi, bodyLo, wickHi, wickLo) =>
    isDem ? bodyHi : wickHi

f_zBot(isDem, bodyHi, bodyLo, wickHi, wickLo) =>
    isDem ? wickLo : bodyLo

f_entry(isDem, bodyHi, bodyLo) =>
    isDem ? bodyLo : bodyHi

f_sl(isDem, wickHi, wickLo, bufTicks) =>
    float buf = bufTicks * syminfo.mintick
    isDem ? wickLo - buf : wickHi + buf

f_txtSize(s) =>
    s == "tiny" ? size.tiny : s == "normal" ? size.normal : size.small

f_dashTblPos(p) =>
    p == "top_left"     ? position.top_left     :
     p == "bottom_right" ? position.bottom_right :
     p == "bottom_left"  ? position.bottom_left  : position.top_right

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — DATA FETCHING
// ─────────────────────────────────────────────────────────────────────────────

[ltfO, ltfH, ltfL, ltfC] = request.security(syminfo.tickerid, ltf_tf, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_off)
ltfTime = request.security(syminfo.tickerid, ltf_tf, time, barmerge.gaps_off, barmerge.lookahead_off)

[itfO, itfH, itfL, itfC] = request.security(syminfo.tickerid, itf_tf, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_off)
itfTime = request.security(syminfo.tickerid, itf_tf, time, barmerge.gaps_off, barmerge.lookahead_off)

[htfO, htfH, htfL, htfC] = request.security(syminfo.tickerid, htf_tf, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_off)
htfTime = request.security(syminfo.tickerid, htf_tf, time, barmerge.gaps_off, barmerge.lookahead_off)

bool ltfNewConfirmed = ta.change(ltfTime) != 0 and barstate.isconfirmed
bool itfNewConfirmed = ta.change(itfTime) != 0 and barstate.isconfirmed
bool htfNewConfirmed = ta.change(htfTime) != 0 and barstate.isconfirmed

ltfBody      = math.abs(ltfC - ltfO)
ltfRange     = ltfH - ltfL
ltfWickPct   = ltfRange > 0 ? (ltfRange - ltfBody) / ltfRange * 100.0 : 0.0
ltfBodyPct   = ltfRange > 0 ? ltfBody / ltfRange * 100.0 : 0.0
ltfIsBase    = ltfWickPct >= ltfBaseMinWickPct
ltfIsImpulse = useStrictImpulse ? ltfBodyPct >= ltfImpMinBodyPct : not ltfIsBase
ltfImpBull   = ltfIsImpulse and ltfC > ltfO

itfBody      = math.abs(itfC - itfO)
itfRange     = itfH - itfL
itfWickPct   = itfRange > 0 ? (itfRange - itfBody) / itfRange * 100.0 : 0.0
itfBodyPct   = itfRange > 0 ? itfBody / itfRange * 100.0 : 0.0
itfIsBase    = itfWickPct >= itfBaseMinWickPct
itfIsImpulse = useStrictImpulse ? itfBodyPct >= itfImpMinBodyPct : not itfIsBase
itfImpBull   = itfIsImpulse and itfC > itfO

htfBody      = math.abs(htfC - htfO)
htfRange     = htfH - htfL
htfWickPct   = htfRange > 0 ? (htfRange - htfBody) / htfRange * 100.0 : 0.0
htfBodyPct   = htfRange > 0 ? htfBody / htfRange * 100.0 : 0.0
htfIsBase    = htfWickPct >= htfBaseMinWickPct
htfIsImpulse = useStrictImpulse ? htfBodyPct >= htfImpMinBodyPct : not htfIsBase
htfImpBull   = htfIsImpulse and htfC > htfO

string ltfLabel = f_tfLabel(ltf_tf)
string itfLabel = f_tfLabel(itf_tf)
string htfLabel = f_tfLabel(htf_tf)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 — ZONE STORAGE
// ─────────────────────────────────────────────────────────────────────────────

var bool  ltfInCl = false
var int   ltfClCnt = 0
var int   ltfClStartT = na
var float ltfClBLo = na
var float ltfClBHi = na
var float ltfClWLo = na
var float ltfClWHi = na

var box[]   ltfBoxes  = array.new_box()
var line[]  ltfMids   = array.new_line()
var label[] ltfLbls   = array.new_label()
var float[] ltfBHi    = array.new_float()
var float[] ltfBLo    = array.new_float()
var float[] ltfWHi    = array.new_float()
var float[] ltfWLo    = array.new_float()
var bool[]  ltfIsDem  = array.new_bool()
var bool[]  ltfActive = array.new_bool()
var int[]   ltfLastArm= array.new_int()    // bar_index of last arm per zone
var bool[]  ltfHasLoss= array.new_bool()   // zone has an unresolved loss
var line[]  ltfPEnt   = array.new_line()
var line[]  ltfPSL    = array.new_line()
var line[]  ltfPT1    = array.new_line()
var line[]  ltfPT2    = array.new_line()
var line[]  ltfPT3    = array.new_line()
var line[]  ltfPT4    = array.new_line()
var line[]  ltfPT5    = array.new_line()
var label[] ltfPLbl   = array.new_label()
var bool[]  ltfPArm   = array.new_bool()

var bool  itfInCl = false
var int   itfClCnt = 0
var int   itfClStartT = na
var float itfClBLo = na
var float itfClBHi = na
var float itfClWLo = na
var float itfClWHi = na

var box[]   itfBoxes  = array.new_box()
var line[]  itfMids   = array.new_line()
var label[] itfLbls   = array.new_label()
var float[] itfBHi    = array.new_float()
var float[] itfBLo    = array.new_float()
var float[] itfWHi    = array.new_float()
var float[] itfWLo    = array.new_float()
var bool[]  itfIsDem  = array.new_bool()
var bool[]  itfActive = array.new_bool()
var int[]   itfLastArm= array.new_int()
var bool[]  itfHasLoss= array.new_bool()
var line[]  itfPEnt   = array.new_line()
var line[]  itfPSL    = array.new_line()
var line[]  itfPT1    = array.new_line()
var line[]  itfPT2    = array.new_line()
var line[]  itfPT3    = array.new_line()
var line[]  itfPT4    = array.new_line()
var line[]  itfPT5    = array.new_line()
var label[] itfPLbl   = array.new_label()
var bool[]  itfPArm   = array.new_bool()

var bool  htfInCl = false
var int   htfClCnt = 0
var int   htfClStartT = na
var float htfClBLo = na
var float htfClBHi = na
var float htfClWLo = na
var float htfClWHi = na

var box[]   htfBoxes  = array.new_box()
var line[]  htfMids   = array.new_line()
var label[] htfLbls   = array.new_label()
var float[] htfBHi    = array.new_float()
var float[] htfBLo    = array.new_float()
var float[] htfWHi    = array.new_float()
var float[] htfWLo    = array.new_float()
var bool[]  htfIsDem  = array.new_bool()
var bool[]  htfActive = array.new_bool()
var int[]   htfLastArm= array.new_int()
var bool[]  htfHasLoss= array.new_bool()
var line[]  htfPEnt   = array.new_line()
var line[]  htfPSL    = array.new_line()
var line[]  htfPT1    = array.new_line()
var line[]  htfPT2    = array.new_line()
var line[]  htfPT3    = array.new_line()
var line[]  htfPT4    = array.new_line()
var line[]  htfPT5    = array.new_line()
var label[] htfPLbl   = array.new_label()
var bool[]  htfPArm   = array.new_bool()

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 — TRADE RECORD ARRAYS (Phase 3 lifecycle)
// States: 0=ARMED 1=ACTIVE 2=WIN 3=LOSS 4=BE
// ─────────────────────────────────────────────────────────────────────────────

var int[]    trState     = array.new_int()
var bool[]   trIsDem     = array.new_bool()
var float[]  trEntry     = array.new_float()
var float[]  trSL        = array.new_float()
var float[]  trTp1       = array.new_float()
var float[]  trTp2       = array.new_float()
var float[]  trTp3       = array.new_float()
var int[]    trContracts = array.new_int()
var float[]  trDolRisk   = array.new_float()
var float[]  trSlTicks   = array.new_float()
var float[]  trTickVal   = array.new_float()
var string[] trTfLbl     = array.new_string()
var int[]    trHighTp    = array.new_int()     // highest TP hit so far (0=none)
var int[]    trZoneIdx   = array.new_int()     // index into zone array
var int[]    trZoneTF    = array.new_int()     // 1=LTF 2=ITF 3=HTF
var bool[]   trBEMoved   = array.new_bool()    // stop moved to BE?
// visual handles
var line[]   trLineEnt   = array.new_line()
var line[]   trLineSL    = array.new_line()
var line[]   trLineTp1   = array.new_line()
var line[]   trLineTp2   = array.new_line()
var line[]   trLineTp3   = array.new_line()
var label[]  trLabel     = array.new_label()

var int[] lastArmedBarArr = array.from(0)   // CE10088 workaround: array-of-1 for mutable global in function

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6 — ZONE EMIT
// ─────────────────────────────────────────────────────────────────────────────

f_emit(tfIdx, isDem, bodyHi, bodyLo, wickHi, wickLo, clStartT, tfLbl,
       bxArr, mdArr, lbArr, bHiArr, bLoArr, wHiArr, wLoArr, demArr, actArr,
       lastArmArr, hasLossArr,
       peArr, psArr, t1Arr, t2Arr, t3Arr, t4Arr, t5Arr, plArr, paArr) =>
    float zTop  = f_zTop(isDem, bodyHi, bodyLo, wickHi, wickLo)
    float zBot  = f_zBot(isDem, bodyHi, bodyLo, wickHi, wickLo)
    float midY  = (zTop + zBot) * 0.5
    color fillC = color.new(f_fillColor(isDem, tfIdx), zoneTransp)
    color bordC = color.new(f_fillColor(isDem, tfIdx), 0)
    ext  = extendZone ? extend.right : extend.none
    box   bx    = box.new(clStartT, zTop, time, zBot, xloc=xloc.bar_time, border_color=bordC, bgcolor=fillC, extend=ext)
    line  md    = showMid ? line.new(clStartT, midY, time, midY, xloc=xloc.bar_time, color=color.new(color.white, 0), style=line.style_dashed, extend=ext) : na
    label lb    = showZoneLbl ? label.new(clStartT, midY, (isDem ? "D " : "S ") + tfLbl, xloc=xloc.bar_time, style=label.style_label_center, textcolor=color.white, color=color.new(color.black, 30), size=size.small) : na
    array.push(bxArr,      bx)
    array.push(mdArr,      md)
    array.push(lbArr,      lb)
    array.push(bHiArr,     bodyHi)
    array.push(bLoArr,     bodyLo)
    array.push(wHiArr,     wickHi)
    array.push(wLoArr,     wickLo)
    array.push(demArr,     isDem)
    array.push(actArr,     true)
    array.push(lastArmArr, -999)
    array.push(hasLossArr, false)
    array.push(peArr,      line(na))
    array.push(psArr,      line(na))
    array.push(t1Arr,      line(na))
    array.push(t2Arr,      line(na))
    array.push(t3Arr,      line(na))
    array.push(t4Arr,      line(na))
    array.push(t5Arr,      line(na))
    array.push(plArr,      label(na))
    array.push(paArr,      false)
    0

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 7 — IBI DETECTION
// ─────────────────────────────────────────────────────────────────────────────

if useLTF and ltfNewConfirmed
    if not ltfInCl and ltfIsBase and ltfIsImpulse[1]
        ltfInCl := true
        ltfClCnt := 1
        ltfClStartT := ltfTime
        ltfClBLo := math.min(ltfO, ltfC)
        ltfClBHi := math.max(ltfO, ltfC)
        ltfClWLo := ltfL
        ltfClWHi := ltfH
    else if ltfInCl and ltfIsBase
        if ltfClCnt + 1 > maxBaseCandles
            ltfInCl := false
            ltfClCnt := 0
        else
            ltfClCnt    += 1
            ltfClBLo    := math.min(ltfClBLo, math.min(ltfO, ltfC))
            ltfClBHi    := math.max(ltfClBHi, math.max(ltfO, ltfC))
            ltfClWLo    := math.min(ltfClWLo, ltfL)
            ltfClWHi    := math.max(ltfClWHi, ltfH)
    else if ltfInCl and not ltfIsBase and ltfIsImpulse and ltfClCnt > 0
        f_emit(1, ltfImpBull, ltfClBHi, ltfClBLo, ltfClWHi, ltfClWLo, ltfClStartT, ltfLabel,
               ltfBoxes, ltfMids, ltfLbls, ltfBHi, ltfBLo, ltfWHi, ltfWLo, ltfIsDem, ltfActive,
               ltfLastArm, ltfHasLoss,
               ltfPEnt, ltfPSL, ltfPT1, ltfPT2, ltfPT3, ltfPT4, ltfPT5, ltfPLbl, ltfPArm)
        ltfInCl := false
        ltfClCnt := 0

if useITF and itfNewConfirmed
    if not itfInCl and itfIsBase and itfIsImpulse[1]
        itfInCl := true
        itfClCnt := 1
        itfClStartT := itfTime
        itfClBLo := math.min(itfO, itfC)
        itfClBHi := math.max(itfO, itfC)
        itfClWLo := itfL
        itfClWHi := itfH
    else if itfInCl and itfIsBase
        if itfClCnt + 1 > maxBaseCandles
            itfInCl := false
            itfClCnt := 0
        else
            itfClCnt    += 1
            itfClBLo    := math.min(itfClBLo, math.min(itfO, itfC))
            itfClBHi    := math.max(itfClBHi, math.max(itfO, itfC))
            itfClWLo    := math.min(itfClWLo, itfL)
            itfClWHi    := math.max(itfClWHi, itfH)
    else if itfInCl and not itfIsBase and itfIsImpulse and itfClCnt > 0
        f_emit(2, itfImpBull, itfClBHi, itfClBLo, itfClWHi, itfClWLo, itfClStartT, itfLabel,
               itfBoxes, itfMids, itfLbls, itfBHi, itfBLo, itfWHi, itfWLo, itfIsDem, itfActive,
               itfLastArm, itfHasLoss,
               itfPEnt, itfPSL, itfPT1, itfPT2, itfPT3, itfPT4, itfPT5, itfPLbl, itfPArm)
        itfInCl := false
        itfClCnt := 0

if useHTF and htfNewConfirmed
    if not htfInCl and htfIsBase and htfIsImpulse[1]
        htfInCl := true
        htfClCnt := 1
        htfClStartT := htfTime
        htfClBLo := math.min(htfO, htfC)
        htfClBHi := math.max(htfO, htfC)
        htfClWLo := htfL
        htfClWHi := htfH
    else if htfInCl and htfIsBase
        if htfClCnt + 1 > maxBaseCandles
            htfInCl := false
            htfClCnt := 0
        else
            htfClCnt    += 1
            htfClBLo    := math.min(htfClBLo, math.min(htfO, htfC))
            htfClBHi    := math.max(htfClBHi, math.max(htfO, htfC))
            htfClWLo    := math.min(htfClWLo, htfL)
            htfClWHi    := math.max(htfClWHi, htfH)
    else if htfInCl and not htfIsBase and htfIsImpulse and htfClCnt > 0
        f_emit(3, htfImpBull, htfClBHi, htfClBLo, htfClWHi, htfClWLo, htfClStartT, htfLabel,
               htfBoxes, htfMids, htfLbls, htfBHi, htfBLo, htfWHi, htfWLo, htfIsDem, htfActive,
               htfLastArm, htfHasLoss,
               htfPEnt, htfPSL, htfPT1, htfPT2, htfPT3, htfPT4, htfPT5, htfPLbl, htfPArm)
        htfInCl := false
        htfClCnt := 0

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 8 — ZONE INVALIDATION (confirmed bars only)
// ─────────────────────────────────────────────────────────────────────────────

f_invalidate(bxArr, mdArr, lbArr, demArr, wHiArr, wLoArr, actArr,
             peArr, psArr, t1Arr, t2Arr, t3Arr, t4Arr, t5Arr, plArr, paArr) =>
    int N = array.size(bxArr)
    if N > 0
        for i = 0 to N - 1
            if array.get(actArr, i)
                bool  isDem = array.get(demArr, i)
                float wHi   = array.get(wHiArr, i)
                float wLo   = array.get(wLoArr, i)
                bool  inv   = isDem ? math.min(open, close) < wLo : math.max(open, close) > wHi
                if inv
                    box bx = array.get(bxArr, i)
                    if not na(bx)
                        box.delete(bx)
                    line ml = array.get(mdArr, i)
                    if not na(ml)
                        line.delete(ml)
                    label lb = array.get(lbArr, i)
                    if not na(lb)
                        label.delete(lb)
                    line e = array.get(peArr, i)
                    if not na(e)
                        line.delete(e)
                    line s = array.get(psArr, i)
                    if not na(s)
                        line.delete(s)
                    line l1 = array.get(t1Arr, i)
                    if not na(l1)
                        line.delete(l1)
                    line l2 = array.get(t2Arr, i)
                    if not na(l2)
                        line.delete(l2)
                    line l3 = array.get(t3Arr, i)
                    if not na(l3)
                        line.delete(l3)
                    line l4 = array.get(t4Arr, i)
                    if not na(l4)
                        line.delete(l4)
                    line l5 = array.get(t5Arr, i)
                    if not na(l5)
                        line.delete(l5)
                    label pl = array.get(plArr, i)
                    if not na(pl)
                        label.delete(pl)
                    array.set(paArr,  i, false)
                    array.set(actArr, i, false)
    0

if barstate.isconfirmed
    f_invalidate(ltfBoxes, ltfMids, ltfLbls, ltfIsDem, ltfWHi, ltfWLo, ltfActive,
                 ltfPEnt, ltfPSL, ltfPT1, ltfPT2, ltfPT3, ltfPT4, ltfPT5, ltfPLbl, ltfPArm)
    f_invalidate(itfBoxes, itfMids, itfLbls, itfIsDem, itfWHi, itfWLo, itfActive,
                 itfPEnt, itfPSL, itfPT1, itfPT2, itfPT3, itfPT4, itfPT5, itfPLbl, itfPArm)
    f_invalidate(htfBoxes, htfMids, htfLbls, htfIsDem, htfWHi, htfWLo, htfActive,
                 htfPEnt, htfPSL, htfPT1, htfPT2, htfPT3, htfPT4, htfPT5, htfPLbl, htfPArm)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 9 — PHASE 3 LIFECYCLE (confirmed bars)
// PASS A: advance ARMED→ACTIVE, check TPs, check SL, close trades
// PASS C: scan zones for new arm candidates
// ─────────────────────────────────────────────────────────────────────────────

f_computeContracts(isDem, bodyHi, bodyLo, wickHi, wickLo) =>
    float ent     = f_entry(isDem, bodyHi, bodyLo)
    float slP     = f_sl(isDem, wickHi, wickLo, slBufTicks)
    float slDist  = math.abs(ent - slP)
    float slTicks = syminfo.mintick > 0 ? slDist / syminfo.mintick : 0.0
    float tVal    = syminfo.pointvalue * syminfo.mintick
    int   cts     = 0
    if slTicks > 0 and tVal > 0
        cts := math.min(int(math.floor(dollarRisk / (slTicks * tVal))), maxContracts)
    [cts, slTicks, tVal, ent, slP]

// Helper: does a zone already have an ARMED or ACTIVE trade?
f_zoneHasLiveTrade(zTF, zIdx) =>
    bool found = false
    int tN = array.size(trState)
    if tN > 0
        for ti = 0 to tN - 1
            int st = array.get(trState, ti)
            if (st == 0 or st == 1) and array.get(trZoneTF, ti) == zTF and array.get(trZoneIdx, ti) == zIdx
                found := true
                break
    found

// Helper: does a zone have an unresolved LOSS in stored trades?
f_zoneHasStoredLoss(zTF, zIdx) =>
    bool found = false
    int tN = array.size(trState)
    if tN > 0
        for ti = 0 to tN - 1
            if array.get(trState, ti) == 3 and array.get(trZoneTF, ti) == zTF and array.get(trZoneIdx, ti) == zIdx
                found := true
                break
    found

// ── PASS A — advance active trades ──────────────────────────────────────────
if trackTrades and barstate.isconfirmed
    int tN = array.size(trState)
    if tN > 0
        for ti = 0 to tN - 1
            int st = array.get(trState, ti)
            if st == 0  // ARMED — check for entry fill
                bool isDem = array.get(trIsDem, ti)
                float ent  = array.get(trEntry, ti)
                // Fill: wick touches entry level
                bool filled = isDem ? low <= ent : high >= ent
                if filled
                    array.set(trState, ti, 1)  // → ACTIVE
            if array.get(trState, ti) == 1  // ACTIVE — check TPs then SL
                bool  isDem  = array.get(trIsDem, ti)
                float ent    = array.get(trEntry, ti)
                float slP    = array.get(trSL, ti)
                float tp1    = array.get(trTp1, ti)
                float tp2    = array.get(trTp2, ti)
                float tp3    = array.get(trTp3, ti)
                int   prevHi = array.get(trHighTp, ti)
                int   nTPs   = numTPs

                // Check TP progression on prior bar (prevHigh only advances on closed bar)
                bool tp1hit = isDem ? high >= tp1 : low <= tp1
                bool tp2hit = isDem ? high >= tp2 : low <= tp2
                bool tp3hit = isDem ? high >= tp3 : low <= tp3
                int  newHi  = prevHi
                if nTPs >= 1 and tp1hit and newHi < 1
                    newHi := 1
                if nTPs >= 2 and tp2hit and newHi < 2
                    newHi := 2
                if nTPs >= 3 and tp3hit and newHi < 3
                    newHi := 3
                array.set(trHighTp, ti, newHi)

                // Check SL (body close through SL — conservative)
                bool slHit = isDem ? math.min(open, close) < slP : math.max(open, close) > slP
                if slHit
                    // SL wins tiebreak per D5
                    int outcome = 3  // LOSS
                    if newHi >= 2
                        outcome := 2  // WIN — TP2+ hit before SL
                    else if newHi == 1
                        outcome := 4  // BE — TP1 hit then stopped
                    array.set(trState, ti, outcome)
                    // Mark chart
                    if showMarkers
                        string mTxt = outcome == 2 ? "✓ WIN" : outcome == 4 ? "~ BE" : "✗ LOSS"
                        color  mCol = outcome == 2 ? colWin : outcome == 4 ? colBE : colLoss
                        label.new(bar_index, slP, mTxt, style=label.style_label_up, color=mCol, textcolor=color.white, size=size.tiny)
                    // Update zone loss flag
                    if outcome == 3
                        int zTF  = array.get(trZoneTF,  ti)
                        int zIdx = array.get(trZoneIdx, ti)
                        if zTF == 1
                            int N = array.size(ltfHasLoss)
                            if zIdx < N
                                array.set(ltfHasLoss, zIdx, true)
                        else if zTF == 2
                            int N = array.size(itfHasLoss)
                            if zIdx < N
                                array.set(itfHasLoss, zIdx, true)
                        else if zTF == 3
                            int N = array.size(htfHasLoss)
                            if zIdx < N
                                array.set(htfHasLoss, zIdx, true)
                else
                    // Check final TP hit = WIN
                    bool finalTP = (nTPs >= 3 and tp3hit) or (nTPs == 2 and tp2hit) or (nTPs == 1 and tp1hit)
                    if finalTP and newHi >= nTPs
                        array.set(trState, ti, 2)  // WIN
                        if showMarkers
                            float tpY = nTPs == 3 ? tp3 : nTPs == 2 ? tp2 : tp1
                            label.new(bar_index, tpY, "✓ WIN", style=label.style_label_down, color=colWin, textcolor=color.white, size=size.tiny)

// ── PASS C — arm new trades from active zones ───────────────────────────────
f_armFromZones(tfIdx, tfLbl,
               bHiArr, bLoArr, wHiArr, wLoArr, demArr, actArr, lastArmArr, hasLossArr) =>
    int N = array.size(actArr)
    if N > 0
        for i = 0 to N - 1
            if array.get(actArr, i)
                bool  isDem  = array.get(demArr,  i)
                float bodyHi = array.get(bHiArr,  i)
                float bodyLo = array.get(bLoArr,  i)
                float wickHi = array.get(wHiArr,  i)
                float wickLo = array.get(wLoArr,  i)
                float ent    = f_entry(isDem, bodyHi, bodyLo)
                float zTop   = f_zTop(isDem, bodyHi, bodyLo, wickHi, wickLo)
                float zBot   = f_zBot(isDem, bodyHi, bodyLo, wickHi, wickLo)
                float zH     = math.abs(zTop - zBot)
                if zH > 0
                    float dist    = math.abs(close - ent)
                    bool  inProx  = dist <= armProx * zH
                    bool  priceOk = isDem ? close > ent : close < ent
                    bool  coolOk  = (bar_index - array.get(lastArmArr, i)) >= armCooldown
                    bool  lossOk  = not blockReArm or not array.get(hasLossArr, i)
                    bool  noLive  = not f_zoneHasLiveTrade(tfIdx, i)
                    if inProx and priceOk and coolOk and lossOk and noLive
                        [cts, slTicks, tVal, entP, slP] = f_computeContracts(isDem, bodyHi, bodyLo, wickHi, wickLo)
                        if cts > 0
                            float tp1 = isDem ? entP + zH * tpMult       : entP - zH * tpMult
                            float tp2 = isDem ? entP + zH * tpMult * 2.0 : entP - zH * tpMult * 2.0
                            float tp3 = isDem ? entP + zH * tpMult * 3.0 : entP - zH * tpMult * 3.0
                            float actRisk = slTicks * tVal * cts
                            // Push new trade record
                            array.push(trState,     0)
                            array.push(trIsDem,     isDem)
                            array.push(trEntry,     entP)
                            array.push(trSL,        slP)
                            array.push(trTp1,       tp1)
                            array.push(trTp2,       tp2)
                            array.push(trTp3,       tp3)
                            array.push(trContracts, cts)
                            array.push(trDolRisk,   actRisk)
                            array.push(trSlTicks,   slTicks)
                            array.push(trTickVal,   tVal)
                            array.push(trTfLbl,     tfLbl)
                            array.push(trHighTp,    0)
                            array.push(trZoneIdx,   i)
                            array.push(trZoneTF,    tfIdx)
                            array.push(trBEMoved,   false)
                            array.push(trLineEnt,   line(na))
                            array.push(trLineSL,    line(na))
                            array.push(trLineTp1,   line(na))
                            array.push(trLineTp2,   line(na))
                            array.push(trLineTp3,   line(na))
                            array.push(trLabel,     label(na))
                            array.set(lastArmArr, i, bar_index)
                            array.set(lastArmedBarArr, 0, bar_index)
    0

if trackTrades and barstate.isconfirmed
    f_armFromZones(1, ltfLabel, ltfBHi, ltfBLo, ltfWHi, ltfWLo, ltfIsDem, ltfActive, ltfLastArm, ltfHasLoss)
    f_armFromZones(2, itfLabel, itfBHi, itfBLo, itfWHi, itfWLo, itfIsDem, itfActive, itfLastArm, itfHasLoss)
    f_armFromZones(3, htfLabel, htfBHi, htfBLo, htfWHi, htfWLo, htfIsDem, htfActive, htfLastArm, htfHasLoss)

// ── PASS D — FIFO eviction beyond maxPastTrades ──────────────────────────────
if trackTrades and barstate.isconfirmed
    // Count closed trades
    int closed = 0
    int tN = array.size(trState)
    if tN > 0
        for ti = 0 to tN - 1
            int st = array.get(trState, ti)
            if st >= 2
                closed += 1
    // Evict oldest closed trade if over cap
    if closed > maxPastTrades
        int tN2 = array.size(trState)
        if tN2 > 0
            int oldestIdx = -1
            for ti = 0 to tN2 - 1
                int st = array.get(trState, ti)
                if st >= 2
                    oldestIdx := ti
                    break
            if oldestIdx >= 0
                // Delete visuals
                line el = array.get(trLineEnt, oldestIdx)
                if not na(el)
                    line.delete(el)
                line sl2 = array.get(trLineSL, oldestIdx)
                if not na(sl2)
                    line.delete(sl2)
                line t1 = array.get(trLineTp1, oldestIdx)
                if not na(t1)
                    line.delete(t1)
                line t2 = array.get(trLineTp2, oldestIdx)
                if not na(t2)
                    line.delete(t2)
                line t3 = array.get(trLineTp3, oldestIdx)
                if not na(t3)
                    line.delete(t3)
                label tl = array.get(trLabel, oldestIdx)
                if not na(tl)
                    label.delete(tl)
                // Remove from all arrays
                array.remove(trState,     oldestIdx)
                array.remove(trIsDem,     oldestIdx)
                array.remove(trEntry,     oldestIdx)
                array.remove(trSL,        oldestIdx)
                array.remove(trTp1,       oldestIdx)
                array.remove(trTp2,       oldestIdx)
                array.remove(trTp3,       oldestIdx)
                array.remove(trContracts, oldestIdx)
                array.remove(trDolRisk,   oldestIdx)
                array.remove(trSlTicks,   oldestIdx)
                array.remove(trTickVal,   oldestIdx)
                array.remove(trTfLbl,     oldestIdx)
                array.remove(trHighTp,    oldestIdx)
                array.remove(trZoneIdx,   oldestIdx)
                array.remove(trZoneTF,    oldestIdx)
                array.remove(trBEMoved,   oldestIdx)
                array.remove(trLineEnt,   oldestIdx)
                array.remove(trLineSL,    oldestIdx)
                array.remove(trLineTp1,   oldestIdx)
                array.remove(trLineTp2,   oldestIdx)
                array.remove(trLineTp3,   oldestIdx)
                array.remove(trLabel,     oldestIdx)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 10 — LIVE PLAN RENDERER (barstate.islast)
// ─────────────────────────────────────────────────────────────────────────────

f_renderPlans(demArr, bHiArr, bLoArr, wHiArr, wLoArr, actArr,
              peArr, psArr, t1Arr, t2Arr, t3Arr, t4Arr, t5Arr, plArr, paArr) =>
    int N = array.size(actArr)
    if N > 0
        var int[]   candIdx  = array.new_int()
        var float[] candDist = array.new_float()
        array.clear(candIdx)
        array.clear(candDist)

        for i = 0 to N - 1
            if array.get(actArr, i)
                bool  isDem  = array.get(demArr,  i)
                float bodyHi = array.get(bHiArr,  i)
                float bodyLo = array.get(bLoArr,  i)
                float wickHi = array.get(wHiArr,  i)
                float wickLo = array.get(wLoArr,  i)
                float ent    = f_entry(isDem, bodyHi, bodyLo)
                float zTop   = f_zTop(isDem, bodyHi, bodyLo, wickHi, wickLo)
                float zBot   = f_zBot(isDem, bodyHi, bodyLo, wickHi, wickLo)
                float zH     = math.abs(zTop - zBot)
                if zH > 0
                    float dist    = math.abs(close - ent)
                    bool  inProx  = dist <= armProx * zH
                    bool  priceOk = isDem ? close > ent : close < ent
                    if inProx and priceOk
                        array.push(candIdx,  i)
                        array.push(candDist, dist)

        int cN = array.size(candIdx)
        if cN > 1
            for a = 0 to cN - 2
                for b = a + 1 to cN - 1
                    if array.get(candDist, b) < array.get(candDist, a)
                        int   ti = array.get(candIdx,  a)
                        float td = array.get(candDist, a)
                        array.set(candIdx,  a, array.get(candIdx,  b))
                        array.set(candDist, a, array.get(candDist, b))
                        array.set(candIdx,  b, ti)
                        array.set(candDist, b, td)

        int rendered = 0
        int cSize    = array.size(candIdx)
        if cSize > 0
            for ci = 0 to cSize - 1
                if rendered >= maxPlans
                    break
                int   i      = array.get(candIdx, ci)
                bool  isDem  = array.get(demArr,  i)
                float bodyHi = array.get(bHiArr,  i)
                float bodyLo = array.get(bLoArr,  i)
                float wickHi = array.get(wHiArr,  i)
                float wickLo = array.get(wLoArr,  i)
                float ent    = f_entry(isDem, bodyHi, bodyLo)
                float slP    = f_sl(isDem, wickHi, wickLo, slBufTicks)
                float zTop   = f_zTop(isDem, bodyHi, bodyLo, wickHi, wickLo)
                float zBot   = f_zBot(isDem, bodyHi, bodyLo, wickHi, wickLo)
                float zH     = math.abs(zTop - zBot)
                float slDist  = math.abs(ent - slP)
                float slTicks = syminfo.mintick > 0 ? slDist / syminfo.mintick : 0.0
                float tickVal = syminfo.pointvalue * syminfo.mintick
                int   cts     = 0
                if slTicks > 0 and tickVal > 0
                    cts := math.min(int(math.floor(dollarRisk / (slTicks * tickVal))), maxContracts)

                line  oe = array.get(peArr, i)
                if not na(oe)
                    line.delete(oe)
                line  os = array.get(psArr, i)
                if not na(os)
                    line.delete(os)
                line  o1 = array.get(t1Arr, i)
                if not na(o1)
                    line.delete(o1)
                line  o2 = array.get(t2Arr, i)
                if not na(o2)
                    line.delete(o2)
                line  o3 = array.get(t3Arr, i)
                if not na(o3)
                    line.delete(o3)
                line  o4 = array.get(t4Arr, i)
                if not na(o4)
                    line.delete(o4)
                line  o5 = array.get(t5Arr, i)
                if not na(o5)
                    line.delete(o5)
                label ol = array.get(plArr, i)
                if not na(ol)
                    label.delete(ol)

                int barW = int(time - time[1])
                int x1   = time
                int x2   = time + barW * 8
                color eCol = isDem ? colEntry : colEntShort
                array.set(peArr, i, line.new(x1, ent, x2, ent, xloc=xloc.bar_time, color=eCol,  width=2))
                array.set(psArr, i, line.new(x1, slP, x2, slP, xloc=xloc.bar_time, color=colSL, width=1))

                float tp1 = isDem ? ent + zH * tpMult       : ent - zH * tpMult
                float tp2 = isDem ? ent + zH * tpMult * 2.0 : ent - zH * tpMult * 2.0
                float tp3 = isDem ? ent + zH * tpMult * 3.0 : ent - zH * tpMult * 3.0
                float tp4 = isDem ? ent + zH * tpMult * 4.0 : ent - zH * tpMult * 4.0
                float tp5 = isDem ? ent + zH * tpMult * 5.0 : ent - zH * tpMult * 5.0

                array.set(t1Arr, i, numTPs >= 1 ? line.new(x1, tp1, x2, tp1, xloc=xloc.bar_time, color=colTP, width=1) : line(na))
                array.set(t2Arr, i, numTPs >= 2 ? line.new(x1, tp2, x2, tp2, xloc=xloc.bar_time, color=colTP, width=1) : line(na))
                array.set(t3Arr, i, numTPs >= 3 ? line.new(x1, tp3, x2, tp3, xloc=xloc.bar_time, color=colTP, width=1) : line(na))
                array.set(t4Arr, i, numTPs >= 4 ? line.new(x1, tp4, x2, tp4, xloc=xloc.bar_time, color=colTP, width=1) : line(na))
                array.set(t5Arr, i, numTPs >= 5 ? line.new(x1, tp5, x2, tp5, xloc=xloc.bar_time, color=colTP, width=1) : line(na))

                float actualRisk = slTicks * tickVal * cts
                string lText = (isDem ? "L " : "S ") + str.tostring(cts) + "cts  $" + str.tostring(math.round(actualRisk))
                array.set(plArr, i, label.new(x2, ent, lText, xloc=xloc.bar_time,
                                              style=label.style_label_left,
                                              textcolor=color.white,
                                              color=color.new(color.black, 20),
                                              size=size.small))
                array.set(paArr, i, true)
                rendered += 1

        for i = 0 to N - 1
            if array.get(actArr, i) and array.get(paArr, i)
                bool stillIn = false
                int  cSz     = array.size(candIdx)
                if cSz > 0
                    for ci = 0 to cSz - 1
                        if array.get(candIdx, ci) == i
                            stillIn := true
                            break
                if not stillIn
                    line  ce = array.get(peArr, i)
                    if not na(ce)
                        line.delete(ce)
                    line  cs = array.get(psArr, i)
                    if not na(cs)
                        line.delete(cs)
                    line  c1 = array.get(t1Arr, i)
                    if not na(c1)
                        line.delete(c1)
                    line  c2 = array.get(t2Arr, i)
                    if not na(c2)
                        line.delete(c2)
                    line  c3 = array.get(t3Arr, i)
                    if not na(c3)
                        line.delete(c3)
                    line  c4 = array.get(t4Arr, i)
                    if not na(c4)
                        line.delete(c4)
                    line  c5 = array.get(t5Arr, i)
                    if not na(c5)
                        line.delete(c5)
                    label cl = array.get(plArr, i)
                    if not na(cl)
                        label.delete(cl)
                    array.set(paArr, i, false)
    0

if barstate.islast
    f_renderPlans(ltfIsDem, ltfBHi, ltfBLo, ltfWHi, ltfWLo, ltfActive,
                  ltfPEnt, ltfPSL, ltfPT1, ltfPT2, ltfPT3, ltfPT4, ltfPT5, ltfPLbl, ltfPArm)
    f_renderPlans(itfIsDem, itfBHi, itfBLo, itfWHi, itfWLo, itfActive,
                  itfPEnt, itfPSL, itfPT1, itfPT2, itfPT3, itfPT4, itfPT5, itfPLbl, itfPArm)
    f_renderPlans(htfIsDem, htfBHi, htfBLo, htfWHi, htfWLo, htfActive,
                  htfPEnt, htfPSL, htfPT1, htfPT2, htfPT3, htfPT4, htfPT5, htfPLbl, htfPArm)

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 11 — PERFORMANCE DASHBOARD (barstate.islast)
// Columns: # | Side | TF | Entry | SL | Cts | $Risk | SLticks | Result | R
// Footer:  Totals — W / L / BE / WR% / Total R / Net $
// ─────────────────────────────────────────────────────────────────────────────

if showDash and barstate.islast
    // ── Compute stats ────────────────────────────────────────────────────────
    int   wins   = 0
    int   losses = 0
    int   bes    = 0
    int   armed  = 0
    int   active = 0
    float totR   = 0.0
    float totDol = 0.0

    int tN = array.size(trState)
    if tN > 0
        for ti = 0 to tN - 1
            int st = array.get(trState, ti)
            if st == 0
                armed += 1
            else if st == 1
                active += 1
            else if st == 2
                wins   += 1
                int   hi   = array.get(trHighTp, ti)
                float tVal = array.get(trTickVal, ti)
                float slTk = array.get(trSlTicks, ti)
                int   cts  = array.get(trContracts, ti)
                // Trail-compiled R: average of TPs hit
                float entP = array.get(trEntry, ti)
                float tp1v = array.get(trTp1, ti)
                float tp2v = array.get(trTp2, ti)
                float tp3v = array.get(trTp3, ti)
                bool  dem  = array.get(trIsDem, ti)
                float zH   = math.abs(tp1v - entP) / tpMult
                float r1   = slTk > 0 ? math.abs(tp1v - entP) / (slTk * syminfo.mintick) : 0.0
                float r2   = slTk > 0 ? math.abs(tp2v - entP) / (slTk * syminfo.mintick) : 0.0
                float r3   = slTk > 0 ? math.abs(tp3v - entP) / (slTk * syminfo.mintick) : 0.0
                float trR  = hi >= 3 ? (r1 + r2 + r3) / 3.0 : hi == 2 ? (r1 + r2) / 2.0 : r1
                totR   += trR
                totDol += trR * slTk * tVal * cts
            else if st == 3
                losses += 1
                totR   -= 1.0
                totDol -= array.get(trDolRisk, ti)
            else if st == 4
                bes += 1
                // BE = 0R, 0$

    int   closed = wins + losses + bes
    float wr     = (wins + losses) > 0 ? wins / float(wins + losses) * 100.0 : 0.0

    // ── Build dashboard table ────────────────────────────────────────────────
    int    nCols    = 10
    int    nRows    = math.min(tN, dashRows) + 3  // header + data + totals + live
    string tSz      = f_txtSize(dashSize)
    color  hBg      = color.new(#1A1A2E, 10)
    color  rowBg1   = color.new(#0D0D1A, 20)
    color  rowBg2   = color.new(#111128, 20)
    color  totBg    = color.new(#252540, 10)

    var table dash = table.new(f_dashTblPos(dashPos), nCols, nRows + 4,
                               border_color=color.new(color.gray, 60), border_width=1,
                               frame_color=color.new(#F0B429, 20), frame_width=1)

    // ── Header row ───────────────────────────────────────────────────────────
    table.cell(dash, 0, 0, "IOF v2.0",    bgcolor=hBg, text_color=#F0B429, text_size=tSz, text_halign=text.align_center)
    table.cell(dash, 1, 0, "#",           bgcolor=hBg, text_color=color.gray, text_size=tSz)
    table.cell(dash, 2, 0, "SIDE",        bgcolor=hBg, text_color=color.gray, text_size=tSz)
    table.cell(dash, 3, 0, "TF",          bgcolor=hBg, text_color=color.gray, text_size=tSz)
    table.cell(dash, 4, 0, "ENTRY",       bgcolor=hBg, text_color=color.gray, text_size=tSz)
    table.cell(dash, 5, 0, "SL",          bgcolor=hBg, text_color=color.gray, text_size=tSz)
    table.cell(dash, 6, 0, "CTS",         bgcolor=hBg, text_color=color.gray, text_size=tSz)
    table.cell(dash, 7, 0, "$RISK",       bgcolor=hBg, text_color=color.gray, text_size=tSz)
    table.cell(dash, 8, 0, "SL TICKS",   bgcolor=hBg, text_color=color.gray, text_size=tSz)
    table.cell(dash, 9, 0, "RESULT",      bgcolor=hBg, text_color=color.gray, text_size=tSz)

    // ── Live status row ───────────────────────────────────────────────────────
    string liveStr = str.tostring(armed) + " armed · " + str.tostring(active) + " active"
    table.cell(dash, 0, 1, "LIVE",    bgcolor=color.new(#003020, 20), text_color=color.new(#00C896, 0), text_size=tSz, text_halign=text.align_center)
    table.cell(dash, 1, 1, liveStr,   bgcolor=color.new(#003020, 20), text_color=color.white, text_size=tSz)
    table.merge_cells(dash, 1, 1, 9, 1)

    // ── Trade rows (most recent first) ────────────────────────────────────────
    int rowIdx = 2
    if tN > 0
        // Walk backwards so most recent is at top
        int startTi = tN - 1
        int endTi   = math.max(0, tN - dashRows)
        for ti = startTi to endTi
            int   st     = array.get(trState,     ti)
            bool  isDem  = array.get(trIsDem,     ti)
            float entP   = array.get(trEntry,     ti)
            float slP    = array.get(trSL,        ti)
            int   cts    = int(array.get(trContracts, ti))
            float dRisk  = array.get(trDolRisk,   ti)
            float slTk   = array.get(trSlTicks,   ti)
            string tfL   = array.get(trTfLbl,     ti)
            int   hiTp   = array.get(trHighTp,    ti)

            string sideStr = isDem ? "L" : "S"
            color  sideCl  = isDem ? color.new(color.green, 20) : color.new(color.red, 20)
            string entStr  = str.tostring(math.round(entP, 2))
            string slStr   = str.tostring(math.round(slP, 2))
            string ctsStr  = str.tostring(cts)
            string riskStr = "$" + str.tostring(math.round(dRisk))
            string tkStr   = str.tostring(math.round(slTk, 1))

            string resStr  = ""
            color  resCl   = rowBg1
            color  resTxt  = color.white

            if st == 0
                resStr := "◯ ARMED"
                resCl  := color.new(#F0B429, 60)
                resTxt := color.new(#F0B429, 0)
            else if st == 1
                resStr := "● ACTIVE"
                resCl  := color.new(#4FA3E0, 60)
                resTxt := color.new(#4FA3E0, 0)
            else if st == 2
                // Compute R for display
                float tp1v = array.get(trTp1, ti)
                float tp2v = array.get(trTp2, ti)
                float tp3v = array.get(trTp3, ti)
                float r1   = slTk > 0 ? math.abs(tp1v - entP) / (slTk * syminfo.mintick) : 0.0
                float r2   = slTk > 0 ? math.abs(tp2v - entP) / (slTk * syminfo.mintick) : 0.0
                float r3   = slTk > 0 ? math.abs(tp3v - entP) / (slTk * syminfo.mintick) : 0.0
                float trR  = hiTp >= 3 ? (r1+r2+r3)/3.0 : hiTp == 2 ? (r1+r2)/2.0 : r1
                resStr := "✓ WIN  +" + str.tostring(math.round(trR, 2)) + "R"
                resCl  := colWin
                resTxt := color.white
            else if st == 3
                resStr := "✗ LOSS  -1R"
                resCl  := colLoss
                resTxt := color.white
            else if st == 4
                resStr := "~ BE  0R"
                resCl  := colBE
                resTxt := color.white

            color rowBg = rowIdx % 2 == 0 ? rowBg1 : rowBg2
            table.cell(dash, 0, rowIdx, str.tostring(ti + 1), bgcolor=rowBg,   text_color=color.gray,  text_size=tSz)
            table.cell(dash, 1, rowIdx, "",                   bgcolor=rowBg,   text_color=color.gray,  text_size=tSz)
            table.cell(dash, 2, rowIdx, sideStr,              bgcolor=sideCl,  text_color=color.white, text_size=tSz, text_halign=text.align_center)
            table.cell(dash, 3, rowIdx, tfL,                  bgcolor=rowBg,   text_color=color.white, text_size=tSz, text_halign=text.align_center)
            table.cell(dash, 4, rowIdx, entStr,               bgcolor=rowBg,   text_color=color.white, text_size=tSz, text_halign=text.align_center)
            table.cell(dash, 5, rowIdx, slStr,                bgcolor=rowBg,   text_color=#E94560,     text_size=tSz, text_halign=text.align_center)
            table.cell(dash, 6, rowIdx, ctsStr,               bgcolor=rowBg,   text_color=#F0B429,     text_size=tSz, text_halign=text.align_center)
            table.cell(dash, 7, rowIdx, riskStr,              bgcolor=rowBg,   text_color=#F0B429,     text_size=tSz, text_halign=text.align_center)
            table.cell(dash, 8, rowIdx, tkStr,                bgcolor=rowBg,   text_color=color.gray,  text_size=tSz, text_halign=text.align_center)
            table.cell(dash, 9, rowIdx, resStr,               bgcolor=resCl,   text_color=resTxt,      text_size=tSz, text_halign=text.align_center)
            rowIdx += 1

    // ── Totals row ────────────────────────────────────────────────────────────
    string wrStr  = str.tostring(math.round(wr, 1)) + "%"
    string totRStr= (totR >= 0 ? "+" : "") + str.tostring(math.round(totR, 2)) + "R"
    string netStr = (totDol >= 0 ? "+$" : "-$") + str.tostring(math.round(math.abs(totDol)))
    color  totRCl = totR >= 0 ? color.new(color.green, 40) : color.new(color.red, 40)
    color  netCl  = totDol >= 0 ? color.new(color.green, 40) : color.new(color.red, 40)

    int tr = rowIdx
    table.cell(dash, 0, tr, "TOTALS",                   bgcolor=totBg, text_color=#F0B429, text_size=tSz, text_halign=text.align_center)
    table.cell(dash, 1, tr, "W:" + str.tostring(wins),  bgcolor=totBg, text_color=color.new(color.green, 0), text_size=tSz, text_halign=text.align_center)
    table.cell(dash, 2, tr, "L:" + str.tostring(losses),bgcolor=totBg, text_color=color.new(color.red, 0),   text_size=tSz, text_halign=text.align_center)
    table.cell(dash, 3, tr, "BE:" + str.tostring(bes),  bgcolor=totBg, text_color=color.new(color.orange, 0),text_size=tSz, text_halign=text.align_center)
    table.cell(dash, 4, tr, "WR:" + wrStr,              bgcolor=totBg, text_color=color.white, text_size=tSz, text_halign=text.align_center)
    table.merge_cells(dash, 4, tr, 5, tr)
    table.cell(dash, 6, tr, "Trades:" + str.tostring(closed), bgcolor=totBg, text_color=color.white, text_size=tSz, text_halign=text.align_center)
    table.merge_cells(dash, 6, tr, 7, tr)
    table.cell(dash, 8, tr, totRStr,                    bgcolor=totRCl, text_color=color.white, text_size=tSz, text_halign=text.align_center)
    table.cell(dash, 9, tr, netStr,                     bgcolor=netCl,  text_color=color.white, text_size=tSz, text_halign=text.align_center)
````
