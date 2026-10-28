# ICT HTF/BIAS

- url: https://www.tradingview.com/script/XEd8N7AW-ICT-HTF-BIAS/
- type: indicator
- pine_id: PUB;0fb325d07a334759b8b03ea25e9ea108
- version: 1.0

## Description

ICT HTF/BIAS — Full Guide
What this indicator does

ICT HTF/BIAS plots multi-timeframe ICT PD Arrays (FVGs + Order Blocks) and provides a compact bias table that helps you quickly determine directional context across your selected timeframes.

It is designed to stay simple, readable, and ICT-based, while avoiding misleading signals.

Key features
1) ICT PD Arrays included

FVG (Fair Value Gap): classic ICT 3-candle imbalance (gap).

Order Blocks (OB): detected via BOS logic + pivot structure, then searching back for the last opposite candle as the OB anchor.

2) HTF confirmed zones (non-misleading behavior)

Zones are added only on the HTF close (confirmed higher timeframe bar).
This avoids “in-progress HTF candle” noise and reduces false/temporary zones.

3) SHOW vs CALC (decoupled by design)

Each TF has two independent depth controls:

Max SHOW = how many zones you want to draw on the chart (keep your chart clean).

Max CALC = how many zones the table/bias is allowed to analyze (keep your bias logic robust).

This prevents a common problem: changing how many boxes you display changes your bias output.
In this script, your bias can remain stable even if you hide most boxes.

4) Compact Bias Table (fast read)

The table shows:

FVG status: IN / OUT / N/A

OB status: IN / OUT / N/A

BIAS: ↑ / ↓ / “-”

GLOBAL bias: weighted across TF1..TF4

How to read the bias
Per-Timeframe Bias rules (ICT-based, simple)

For each timeframe:

If price is IN an OB (within CALC depth) → bias = OB direction

Else if price is IN a FVG (within CALC depth) → bias = FVG direction

Else fallback to the most recent direction (OB preferred, otherwise FVG)

GLOBAL bias (weighted)

The GLOBAL row uses a weighted sum:

TF1 weight = 1

TF2 weight = 2

TF3 weight = 3

TF4 weight = 4

Score > 0 → bullish global bias
Score < 0 → bearish global bias
Score = 0 → neutral

Chart TF “Guard” (prevents false LTF readings)

TradingView has limitations when requesting very low TF data from a much higher chart timeframe.
To avoid showing incorrect LTF (1m/5m/15m) statuses when you’re on a high chart TF, the script can display a small warning banner and treat certain LTF rows as N/A when appropriate.

Purpose: never show false information.

Recommended usage (most user friendly)
Step 1 — Choose your “Entry TF”

As a rule of thumb (ICT):

The lowest TF in your set should match your entry timeframe, or be close to it.

Examples:

Intraday / Scalping

TF1=1m, TF2=5m, TF3=15m, TF4=1H
(Use chart TF 1m–15m for best LTF accuracy.)

Higher timeframe trading

TF1=1H, TF2=4H, TF3=1D, TF4=1W
(Then you naturally don’t care about 1m/5m.)

Step 2 — Keep your chart clean with SHOW vs CALC

A practical approach:

Max SHOW: 1–2 (clean chart)

Max CALC: 3–10 (more stable bias/table logic)

Main settings (quick explanation)
Timeframes (Rows)

Enable TFx: enable/disable each row timeframe

Show Boxes TFx: show/hide zones for that timeframe

Max SHOW / Max CALC

Max SHOW FVG / OB: visual draw limit

Max CALC FVG / OB: depth used by table and bias

Box Width (Per TF)

HTF bars: width scales by HTF size

Chart bars: fixed width in chart bars

OB Logic

Pivot length (BOS): higher = stricter / fewer OBs

OB lookback: how many HTF bars to search for the OB anchor candle

Notes / limitations

This is a context + confluence tool, not a “signal generator.”

LTF accuracy depends on chart TF; the Guard exists specifically to prevent misleading outputs.

One-line summary

ICT HTF/BIAS: multi-TF ICT PD Arrays + a clean bias table with SHOW vs CALC separation, so you can keep charts minimal while keeping bias logic consistent.

## Source Code

````pine
//@version=6
indicator("ICT HTF/BIAS", overlay=true, max_boxes_count=500, max_labels_count=500)
//──────────────────────────────────────────────────────────────────────────────
// INPUTS
//──────────────────────────────────────────────────────────────────────────────
gTF = "Timeframes (Rows)"

// TF1
en1     = input.bool(true,  "Enable TF1", group=gTF)
tf1     = input.timeframe("1", "TF1 (default 1m)", group=gTF)
show1   = input.bool(true,  "Show Boxes TF1", group=gTF)
maxShowF1 = input.int(1, "Max SHOW FVG TF1", minval=0, maxval=50, group=gTF)
maxShowO1 = input.int(1, "Max SHOW OB  TF1", minval=0, maxval=50, group=gTF)
maxCalcF1 = input.int(1, "Max CALC FVG TF1", minval=0, maxval=50, group=gTF)
maxCalcO1 = input.int(1, "Max CALC OB  TF1", minval=0, maxval=50, group=gTF)

// TF2
en2     = input.bool(true,  "Enable TF2", group=gTF)
tf2     = input.timeframe("5", "TF2 (default 5m)", group=gTF)
show2   = input.bool(true,  "Show Boxes TF2", group=gTF)
maxShowF2 = input.int(1, "Max SHOW FVG TF2", minval=0, maxval=50, group=gTF)
maxShowO2 = input.int(1, "Max SHOW OB  TF2", minval=0, maxval=50, group=gTF)
maxCalcF2 = input.int(1, "Max CALC FVG TF2", minval=0, maxval=50, group=gTF)
maxCalcO2 = input.int(1, "Max CALC OB  TF2", minval=0, maxval=50, group=gTF)

// TF3
en3     = input.bool(true,  "Enable TF3", group=gTF)
tf3     = input.timeframe("15", "TF3 (default 15m)", group=gTF)
show3   = input.bool(true,  "Show Boxes TF3", group=gTF)
maxShowF3 = input.int(1, "Max SHOW FVG TF3", minval=0, maxval=50, group=gTF)
maxShowO3 = input.int(1, "Max SHOW OB  TF3", minval=0, maxval=50, group=gTF)
maxCalcF3 = input.int(1, "Max CALC FVG TF3", minval=0, maxval=50, group=gTF)
maxCalcO3 = input.int(1, "Max CALC OB  TF3", minval=0, maxval=50, group=gTF)

// TF4
en4     = input.bool(true,  "Enable TF4", group=gTF)
tf4     = input.timeframe("60", "TF4 (default 1H)", group=gTF)
show4   = input.bool(true,  "Show Boxes TF4", group=gTF)
maxShowF4 = input.int(1, "Max SHOW FVG TF4", minval=0, maxval=50, group=gTF)
maxShowO4 = input.int(1, "Max SHOW OB  TF4", minval=0, maxval=50, group=gTF)
maxCalcF4 = input.int(1, "Max CALC FVG TF4", minval=0, maxval=50, group=gTF)
maxCalcO4 = input.int(1, "Max CALC OB  TF4", minval=0, maxval=50, group=gTF)

gW = "Box Width (Per TF)"
wMode1 = input.string("HTF bars", "Width mode TF1", options=["HTF bars","Chart bars"], group=gW)
wVal1  = input.int(15, "Width value TF1", minval=1, maxval=5000, group=gW)
wMode2 = input.string("HTF bars", "Width mode TF2", options=["HTF bars","Chart bars"], group=gW)
wVal2  = input.int(15, "Width value TF2", minval=1, maxval=5000, group=gW)
wMode3 = input.string("HTF bars", "Width mode TF3", options=["HTF bars","Chart bars"], group=gW)
wVal3  = input.int(7, "Width value TF3", minval=1, maxval=5000, group=gW)
wMode4 = input.string("HTF bars", "Width mode TF4", options=["HTF bars","Chart bars"], group=gW)
wVal4  = input.int(7, "Width value TF4", minval=1, maxval=5000, group=gW)

gDRAW = "Draw"
showFVG = input.bool(true, "Show FVG", group=gDRAW)
showOB  = input.bool(true, "Show Order Blocks", group=gDRAW)
borderTrans = input.int(100, "Border Transparency (100 = invisible)", minval=0, maxval=100, group=gDRAW)
fvgBullCol  = input.color(color.new(color.teal, 80),  "FVG Bull Fill", group=gDRAW)
fvgBearCol  = input.color(color.new(color.red,  80),  "FVG Bear Fill", group=gDRAW)
obBullCol   = input.color(color.new(color.green,82),  "OB Bull Fill",  group=gDRAW)
obBearCol   = input.color(color.new(color.orange,82), "OB Bear Fill",  group=gDRAW)

gTEXT = "Box Text"
showBoxText = input.bool(true, "Show Box Text", group=gTEXT)
txtColor    = input.color(color.white, "Text Color", group=gTEXT)
txtSizeOpt  = input.string("Small", "Text Size", options=["Auto","Tiny","Small","Normal","Large"], group=gTEXT)
txtPosOpt   = input.string("Top Right", "Text Position", options=["Top Left","Top Right","Bottom Left","Bottom Right","Center"], group=gTEXT)

gOB = "Order Block Logic"
obPivotLen = input.int(1, "OB Pivot Length (BOS)", minval=1, maxval=10, group=gOB)
obLookback = input.int(100, "OB Search Lookback (HTF bars)", minval=5, maxval=300, group=gOB)

gTBL = "Table"
showTable = input.bool(true, "Show Table", group=gTBL)
tblPosOpt = input.string("Middle Right", "Table Position", options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=gTBL)
tblBg     = input.color(color.black, "Table BG", group=gTBL)
tblBgTr   = input.int(65, "Table BG Transparency", minval=0, maxval=100, group=gTBL)
tblTxt    = input.color(color.white, "Table Text", group=gTBL)
okUpBg    = input.color(color.new(color.green, 70), "Bull BG", group=gTBL)
okDnBg    = input.color(color.new(color.red,   70), "Bear BG", group=gTBL)
outBg     = input.color(color.new(color.gray,  85), "Neutral BG", group=gTBL)
naBg      = input.color(color.new(color.black, 80), "N/A BG", group=gTBL)

//──────────────────────────────────────────────────────────────────────────────
// SESSIONS (ALL) — UI like your screenshot + default UTC-5
//──────────────────────────────────────────────────────────────────────────────
gSESS = "SESSION LEVELS (ALL)"

// Timezone selector (default UTC-5). Note: Etc/GMT+5 == UTC-5 (sign is reversed in Etc/GMT)
sessTZOpt = input.string("UTC-5 (New York)", "Timezone",
     options=["UTC-5 (New York)","UTC-4","UTC-6","UTC-7","UTC-8","UTC","Exchange"],
     group=gSESS)

f_sessTZ(string opt) =>
    switch opt
        "UTC-5 (New York)" => "Etc/GMT+5"
        "UTC-4"            => "Etc/GMT+4"
        "UTC-6"            => "Etc/GMT+6"
        "UTC-7"            => "Etc/GMT+7"
        "UTC-8"            => "Etc/GMT+8"
        "UTC"              => "Etc/GMT"
        => syminfo.timezone

sessTZ = f_sessTZ(sessTZOpt)

maxSessKeep  = input.int(20, "Max stored sessions (per session)", minval=5, maxval=200, group=gSESS)
takenByWick  = input.bool(true, "Taken by wick (ICT sweep)", group=gSESS)

// Checkbox + session range on the same line (inline)
enAsia   = input.bool(true,  "Asia",     group=gSESS, inline="A")
sessAsia = input.session("2000-0000,0200-0500", "",  group=gSESS, inline="A")

enLondon   = input.bool(true, "London",  group=gSESS, inline="L")
sessLondon = input.session("0200-0500", "",         group=gSESS, inline="L")

enNYAM   = input.bool(true,  "NY AM",    group=gSESS, inline="N1")
sessNYAM = input.session("0930-1100", "",           group=gSESS, inline="N1")

enNYL   = input.bool(true,   "NY Lunch", group=gSESS, inline="N2")
sessNYL = input.session("1200-1300", "",            group=gSESS, inline="N2")

enNYPM   = input.bool(true,  "NY PM",    group=gSESS, inline="N3")
sessNYPM = input.session("1330-1600", "",           group=gSESS, inline="N3")

//──────────────────────────────────────────────────────────────────────────────
// HELPERS
//──────────────────────────────────────────────────────────────────────────────
f_tblPos(p) =>
    switch p
        "Top Left"      => position.top_left
        "Middle Left"   => position.middle_left
        "Bottom Left"   => position.bottom_left
        "Bottom Right"  => position.bottom_right
        "Middle Right"  => position.middle_right
        => position.top_right

f_txtSize(s) =>
    switch s
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.large

f_alignFrom(p) =>
    string ha = text.align_right
    string va = text.align_top
    if p == "Top Left"
        ha := text.align_left
        va := text.align_top
    else if p == "Top Right"
        ha := text.align_right
        va := text.align_top
    else if p == "Bottom Left"
        ha := text.align_left
        va := text.align_bottom
    else if p == "Bottom Right"
        ha := text.align_right
        va := text.align_bottom
    else
        ha := text.align_center
        va := text.align_center
    [ha, va]

f_tfLabel(tfStr) =>
    if tfStr == "D"
        "D"
    else if tfStr == "W"
        "W"
    else if tfStr == "M"
        "M"
    else
        float n = str.tonumber(tfStr)
        if na(n)
            tfStr
        else
            int nInt = int(n)
            if nInt >= 60 and (nInt % 60) == 0
                str.tostring(int(nInt / 60)) + "H"
            else
                str.tostring(nInt) + "m"

borderCol(c) => color.new(c, borderTrans)

[hAlign, vAlign] = f_alignFrom(txtPosOpt)
txtSz = f_txtSize(txtSizeOpt)
cellBgBase = color.new(tblBg, tblBgTr)

chartSec = timeframe.in_seconds(timeframe.period)
chartMs  = chartSec * 1000

f_tfSeconds(string tfStr) =>
    float s = timeframe.in_seconds(tfStr)
    na(s) ? 0.0 : s

f_widthBarsOnChart(string tfStr, string mode, int val) =>
    if mode == "Chart bars"
        math.max(val, 1)
    else
        float tfSec = f_tfSeconds(tfStr)
        float ratio = (tfSec > 0 and chartSec > 0) ? (tfSec / chartSec) : 1.0
        int wb = int(math.round(val * ratio))
        math.max(wb, 1)

xRightFrom(int t0, int widthBarsChart) => t0 + (widthBarsChart * chartMs)

f_inZone(px, top, bot) =>
    not na(top) and not na(bot) and px <= top and px >= bot

f_fmtPrice(float v) =>
    na(v) ? "N/A" : str.tostring(v, format.mintick)

//──────────────────────────────────────────────────────────────────────────────
// SESSION TRACKER (timezone + previous sessions only + taken invalidation)
//──────────────────────────────────────────────────────────────────────────────
f_sessProc(string sessStr, string tz, bool takenByWick,
           float curH, float curL, bool wasIn,
           float[] sHigh, float[] sLow, bool[] hTaken, bool[] lTaken, int[] sTend,
           int maxKeep) =>

    bool inSess = not na(time(timeframe.period, sessStr, tz))

    float cH = curH
    float cL = curL
    if inSess
        cH := na(cH) ? high : math.max(cH, high)
        cL := na(cL) ? low  : math.min(cL, low)

    bool sessClosed = wasIn and not inSess
    if sessClosed and not na(cH) and not na(cL)
        array.unshift(sHigh, cH)
        array.unshift(sLow,  cL)
        array.unshift(hTaken, false)
        array.unshift(lTaken, false)
        array.unshift(sTend, time[1])

        while array.size(sHigh) > maxKeep
            array.pop(sHigh)
            array.pop(sLow)
            array.pop(hTaken)
            array.pop(lTaken)
            array.pop(sTend)

        cH := na
        cL := na

    // Mark "taken" only AFTER the level exists (stored sessions)
    int n = array.size(sHigh)
    if n > 0
        for i = 0 to n - 1
            float hh = array.get(sHigh, i)
            float ll = array.get(sLow,  i)

            bool ht = array.get(hTaken, i)
            bool lt = array.get(lTaken, i)

            if takenByWick
                if not ht and high >= hh
                    array.set(hTaken, i, true)
                if not lt and low <= ll
                    array.set(lTaken, i, true)
            else
                // Close-based "taken"
                if not ht and close >= hh
                    array.set(hTaken, i, true)
                if not lt and close <= ll
                    array.set(lTaken, i, true)

    [cH, cL, inSess]

f_lastUntakenHL(float[] sHigh, float[] sLow, bool[] hTaken, bool[] lTaken) =>
    float uH = na
    float uL = na
    int n = array.size(sHigh)
    if n > 0
        for i = 0 to n - 1
            if na(uH) and not array.get(hTaken, i)
                uH := array.get(sHigh, i)
            if na(uL) and not array.get(lTaken, i)
                uL := array.get(sLow, i)
    [uH, uL]

f_pickNearestHigh(float px,
    float hA, string lA,
    float hB, string lB,
    float hC, string lC,
    float hD, string lD,
    float hE, string lE) =>
    float best = na
    string bestLbl = "N/A"
    float dBest = na

    if not na(hA) and hA > px
        float d = hA - px
        if na(dBest) or d < dBest
            dBest := d, best := hA, bestLbl := lA
    if not na(hB) and hB > px
        float d = hB - px
        if na(dBest) or d < dBest
            dBest := d, best := hB, bestLbl := lB
    if not na(hC) and hC > px
        float d = hC - px
        if na(dBest) or d < dBest
            dBest := d, best := hC, bestLbl := lC
    if not na(hD) and hD > px
        float d = hD - px
        if na(dBest) or d < dBest
            dBest := d, best := hD, bestLbl := lD
    if not na(hE) and hE > px
        float d = hE - px
        if na(dBest) or d < dBest
            dBest := d, best := hE, bestLbl := lE

    [best, bestLbl]

f_pickNearestLow(float px,
    float lA, string sA,
    float lB, string sB,
    float lC, string sC,
    float lD, string sD,
    float lE, string sE) =>
    float best = na
    string bestLbl = "N/A"
    float dBest = na

    if not na(lA) and lA < px
        float d = px - lA
        if na(dBest) or d < dBest
            dBest := d, best := lA, bestLbl := sA
    if not na(lB) and lB < px
        float d = px - lB
        if na(dBest) or d < dBest
            dBest := d, best := lB, bestLbl := sB
    if not na(lC) and lC < px
        float d = px - lC
        if na(dBest) or d < dBest
            dBest := d, best := lC, bestLbl := sC
    if not na(lD) and lD < px
        float d = px - lD
        if na(dBest) or d < dBest
            dBest := d, best := lD, bestLbl := sD
    if not na(lE) and lE < px
        float d = px - lE
        if na(dBest) or d < dBest
            dBest := d, best := lE, bestLbl := sE

    [best, bestLbl]

//──────────────────────────────────────────────────────────────────────────────
// SESSION STORAGE (one set per session)
//──────────────────────────────────────────────────────────────────────────────
var float[] sHighA = array.new_float()
var float[] sLowA  = array.new_float()
var bool[]  hTakenA= array.new_bool()
var bool[]  lTakenA= array.new_bool()
var int[]   sTendA = array.new_int()
var float curHA = na
var float curLA = na
var bool  wasInA = false

var float[] sHighL = array.new_float()
var float[] sLowL  = array.new_float()
var bool[]  hTakenL= array.new_bool()
var bool[]  lTakenL= array.new_bool()
var int[]   sTendL = array.new_int()
var float curHL = na
var float curLL = na
var bool  wasInL = false

var float[] sHighN1 = array.new_float()
var float[] sLowN1  = array.new_float()
var bool[]  hTakenN1= array.new_bool()
var bool[]  lTakenN1= array.new_bool()
var int[]   sTendN1 = array.new_int()
var float curHN1 = na
var float curLN1 = na
var bool  wasInN1 = false

var float[] sHighN2 = array.new_float()
var float[] sLowN2  = array.new_float()
var bool[]  hTakenN2= array.new_bool()
var bool[]  lTakenN2= array.new_bool()
var int[]   sTendN2 = array.new_int()
var float curHN2 = na
var float curLN2 = na
var bool  wasInN2 = false

var float[] sHighN3 = array.new_float()
var float[] sLowN3  = array.new_float()
var bool[]  hTakenN3= array.new_bool()
var bool[]  lTakenN3= array.new_bool()
var int[]   sTendN3 = array.new_int()
var float curHN3 = na
var float curLN3 = na
var bool  wasInN3 = false

//──────────────────────────────────────────────────────────────────────────────
// Update all sessions each bar (only if enabled; otherwise keep wasIn=false)
// IMPORTANT: Tuple destructuring uses "=" and DECLARES variables.
// So: do NOT pre-declare (float aH = na) before doing [aH,aL,aW] = ...
//──────────────────────────────────────────────────────────────────────────────

// Asia
if enAsia
    [aH, aL, aW] = f_sessProc(sessAsia, sessTZ, takenByWick, curHA, curLA, wasInA, sHighA, sLowA, hTakenA, lTakenA, sTendA, maxSessKeep)
    curHA  := aH
    curLA  := aL
    wasInA := aW
else
    wasInA := false

// London
if enLondon
    [lH, lL, lW] = f_sessProc(sessLondon, sessTZ, takenByWick, curHL, curLL, wasInL, sHighL, sLowL, hTakenL, lTakenL, sTendL, maxSessKeep)
    curHL  := lH
    curLL  := lL
    wasInL := lW
else
    wasInL := false

// NY AM
if enNYAM
    [n1H, n1L, n1W] = f_sessProc(sessNYAM, sessTZ, takenByWick, curHN1, curLN1, wasInN1, sHighN1, sLowN1, hTakenN1, lTakenN1, sTendN1, maxSessKeep)
    curHN1  := n1H
    curLN1  := n1L
    wasInN1 := n1W
else
    wasInN1 := false

// NY Lunch
if enNYL
    [n2H, n2L, n2W] = f_sessProc(sessNYL, sessTZ, takenByWick, curHN2, curLN2, wasInN2, sHighN2, sLowN2, hTakenN2, lTakenN2, sTendN2, maxSessKeep)
    curHN2  := n2H
    curLN2  := n2L
    wasInN2 := n2W
else
    wasInN2 := false

// NY PM
if enNYPM
    [n3H, n3L, n3W] = f_sessProc(sessNYPM, sessTZ, takenByWick, curHN3, curLN3, wasInN3, sHighN3, sLowN3, hTakenN3, lTakenN3, sTendN3, maxSessKeep)
    curHN3  := n3H
    curLN3  := n3L
    wasInN3 := n3W
else
    wasInN3 := false

// Untaken H/L per session (no shadowing, tuple in global scope)

// outputs (used later)
float uHA  = na
float uLA  = na
float uHL  = na
float uLL  = na
float uHN1 = na
float uLN1 = na
float uHN2 = na
float uLN2 = na
float uHN3 = na
float uLN3 = na

// tuple assignment in global scope (DO NOT pre-declare t* vars)
[tHA,  tLA ] = f_lastUntakenHL(sHighA,  sLowA,  hTakenA,  lTakenA)
[tHL,  tLL ] = f_lastUntakenHL(sHighL,  sLowL,  hTakenL,  lTakenL)
[tHN1, tLN1] = f_lastUntakenHL(sHighN1, sLowN1, hTakenN1, lTakenN1)
[tHN2, tLN2] = f_lastUntakenHL(sHighN2, sLowN2, hTakenN2, lTakenN2)
[tHN3, tLN3] = f_lastUntakenHL(sHighN3, sLowN3, hTakenN3, lTakenN3)

// mask by enable flags
if not enAsia
    tHA := na
    tLA := na
if not enLondon
    tHL := na
    tLL := na
if not enNYAM
    tHN1 := na
    tLN1 := na
if not enNYL
    tHN2 := na
    tLN2 := na
if not enNYPM
    tHN3 := na
    tLN3 := na

// commit -> outputs
uHA  := tHA
uLA  := tLA
uHL  := tHL
uLL  := tLL
uHN1 := tHN1
uLN1 := tLN1
uHN2 := tHN2
uLN2 := tLN2
uHN3 := tHN3
uLN3 := tLN3

// Nearest across sessions (relative to current price)
float pxSess = close

[nearHigh, nearHighLbl] = f_pickNearestHigh(pxSess, uHA, "Asia", uHL, "London", uHN1, "NY AM", uHN2, "NY Lunch", uHN3, "NY PM")
[nearLow,  nearLowLbl ] = f_pickNearestLow (pxSess, uLA, "Asia", uLL, "London", uLN1, "NY AM", uLN2, "NY Lunch", uLN3, "NY PM")

// Distance (points) before hit
float distHighPts = na(nearHigh) ? na : (nearHigh - pxSess)   // > 0
float distLowPts  = na(nearLow)  ? na : (pxSess - nearLow)    // > 0

string nearHighTxt = na(distHighPts) ? "N/A" : (nearHighLbl + " H  " + str.tostring(distHighPts, format.mintick) + " pts")
string nearLowTxt  = na(distLowPts)  ? "N/A" : (nearLowLbl  + " L  " + str.tostring(distLowPts,  format.mintick) + " pts")


//──────────────────────────────────────────────────────────────────────────────
// CHART-TF GUARD (Option A)
//──────────────────────────────────────────────────────────────────────────────
f_guardOK(string tfStr) =>
    float rowSec = f_tfSeconds(tfStr)
    rowSec > 0 and chartSec > 0 and chartSec <= rowSec

bool g1 = f_guardOK(tf1)
bool g2 = f_guardOK(tf2)
bool g3 = f_guardOK(tf3)
bool g4 = f_guardOK(tf4)

bool en1G = en1 and g1
bool en2G = en2 and g2
bool en3G = en3 and g3
bool en4G = en4 and g4

f_clearZones(box[] bx, float[] topA, float[] botA, int[] dirA, int[] t0A) =>
    int i = array.size(bx) - 1
    while i >= 0
        box b = array.get(bx, i)
        if not na(b)
            box.delete(b)
        i -= 1
    array.clear(bx), array.clear(topA), array.clear(botA), array.clear(dirA), array.clear(t0A)

f_isDuplicate(int newDir, float top, float bot, int t0,
              float[] topArr, float[] botArr, int[] dirArr, int[] t0Arr) =>
    int lim = array.size(dirArr)
    lim := math.min(lim, array.size(topArr))
    lim := math.min(lim, array.size(botArr))
    lim := math.min(lim, array.size(t0Arr))
    if lim <= 0
        false
    else
        int maxScan = math.min(lim, 25)
        bool dup = false
        for i = 0 to maxScan - 1
            int   d  = array.get(dirArr, i)
            int   tt = array.get(t0Arr,  i)
            float tp = array.get(topArr, i)
            float bt = array.get(botArr, i)
            bool same = (d == newDir) and (tt == t0) and (math.abs(tp - top) <= syminfo.mintick) and (math.abs(bt - bot) <= syminfo.mintick)
            if same
                dup := true
                break
        dup

//──────────────────────────────────────────────────────────────────────────────
// HTF ENGINE (inside request.security)
//──────────────────────────────────────────────────────────────────────────────
f_htf_state(int pivLen, int obLb) =>
    bool bullFVG = low > high[2]
    bool bearFVG = high < low[2]

    int   fNewDir = bullFVG ? 1 : bearFVG ? -1 : 0
    float fTop    = na
    float fBot    = na
    int   fT0     = na

    if bullFVG
        fTop := low
        fBot := high[2]
        fT0  := time[2]
    if bearFVG
        fTop := low[2]
        fBot := high
        fT0  := time[2]

    float ph = ta.pivothigh(high, pivLen, pivLen)
    float pl = ta.pivotlow(low,  pivLen, pivLen)

    var float lastH = na
    var float lastL = na
    if not na(ph)
        lastH := ph
    if not na(pl)
        lastL := pl

    bool bosUp = not na(lastH) and close > lastH
    bool bosDn = not na(lastL) and close < lastL

    int   oNewDir = 0
    float oTop    = na
    float oBot    = na
    int   oT0     = na
    bool  found   = false

    if bosUp
        for i = 1 to obLb
            if not found and close[i] < open[i]
                oNewDir := 1
                oTop    := high[i]
                oBot    := low[i]
                oT0     := time[i]
                found   := true

    if bosDn
        for i = 1 to obLb
            if not found and close[i] > open[i]
                oNewDir := -1
                oTop    := high[i]
                oBot    := low[i]
                oT0     := time[i]
                found   := true

    [fNewDir, fTop, fBot, fT0, oNewDir, oTop, oBot, oT0, time, close]

//──────────────────────────────────────────────────────────────────────────────
// ARRAYS (per TF)
//──────────────────────────────────────────────────────────────────────────────
var box[]   fvgBx1 = array.new_box()
var float[] fvgTop1= array.new_float()
var float[] fvgBot1= array.new_float()
var int[]   fvgDir1= array.new_int()
var int[]   fvgT01 = array.new_int()
var int     lastT1 = na

var box[]   obBx1  = array.new_box()
var float[] obTop1 = array.new_float()
var float[] obBot1 = array.new_float()
var int[]   obDir1 = array.new_int()
var int[]   obT01  = array.new_int()

var box[]   fvgBx2 = array.new_box()
var float[] fvgTop2= array.new_float()
var float[] fvgBot2= array.new_float()
var int[]   fvgDir2= array.new_int()
var int[]   fvgT02 = array.new_int()
var int     lastT2 = na

var box[]   obBx2  = array.new_box()
var float[] obTop2 = array.new_float()
var float[] obBot2 = array.new_float()
var int[]   obDir2 = array.new_int()
var int[]   obT02  = array.new_int()

var box[]   fvgBx3 = array.new_box()
var float[] fvgTop3= array.new_float()
var float[] fvgBot3= array.new_float()
var int[]   fvgDir3= array.new_int()
var int[]   fvgT03 = array.new_int()
var int     lastT3 = na

var box[]   obBx3  = array.new_box()
var float[] obTop3 = array.new_float()
var float[] obBot3 = array.new_float()
var int[]   obDir3 = array.new_int()
var int[]   obT03  = array.new_int()

var box[]   fvgBx4 = array.new_box()
var float[] fvgTop4= array.new_float()
var float[] fvgBot4= array.new_float()
var int[]   fvgDir4= array.new_int()
var int[]   fvgT04 = array.new_int()
var int     lastT4 = na

var box[]   obBx4  = array.new_box()
var float[] obTop4 = array.new_float()
var float[] obBot4 = array.new_float()
var int[]   obDir4 = array.new_int()
var int[]   obT04  = array.new_int()

//──────────────────────────────────────────────────────────────────────────────
// BOX CREATION
//──────────────────────────────────────────────────────────────────────────────
f_makeFVGBox(string tfStr, int widthBarsChart, int dir, int t0, float top, float bot) =>
    string tfLbl = f_tfLabel(tfStr)
    string side  = dir == 1 ? "BULL" : "BEAR"
    string name  = "FVG " + tfLbl + " " + side
    color  col   = dir == 1 ? fvgBullCol : fvgBearCol
    box.new(left=t0, top=top, right=xRightFrom(t0, widthBarsChart), bottom=bot,
        xloc=xloc.bar_time,
        bgcolor=col, border_color=borderCol(col),
        text=showBoxText ? name : "", text_color=txtColor, text_size=txtSz,
        text_halign=hAlign, text_valign=vAlign)

f_makeOBBox(string tfStr, int widthBarsChart, int dir, int t0, float top, float bot) =>
    string tfLbl = f_tfLabel(tfStr)
    string side  = dir == 1 ? "BULL" : "BEAR"
    string name  = "OB " + tfLbl + " " + side
    color  col   = dir == 1 ? obBullCol : obBearCol
    box.new(left=t0, top=top, right=xRightFrom(t0, widthBarsChart), bottom=bot,
        xloc=xloc.bar_time,
        bgcolor=col, border_color=borderCol(col),
        text=showBoxText ? name : "", text_color=txtColor, text_size=txtSz,
        text_halign=hAlign, text_valign=vAlign)

//──────────────────────────────────────────────────────────────────────────────
// CAP (store max)
//──────────────────────────────────────────────────────────────────────────────
f_cap(int maxKeep, box[] boxArr, float[] topArr, float[] botArr, int[] dirArr, int[] t0Arr) =>
    while array.size(dirArr) > maxKeep
        box b = array.pop(boxArr)
        if not na(b)
            box.delete(b)
        array.pop(topArr), array.pop(botArr), array.pop(dirArr), array.pop(t0Arr)

//──────────────────────────────────────────────────────────────────────────────
// VISIBILITY REBUILD
//──────────────────────────────────────────────────────────────────────────────
f_rebuildVisibilityFVG(string tfStr, int widthBarsChart, bool showBoxes, int maxShow,
     box[] boxArr, float[] topArr, float[] botArr, int[] dirArr, int[] t0Arr) =>

    int nd = array.size(dirArr)
    int nb = array.size(boxArr)
    if nb < nd
        for k = nb to nd - 1
            array.push(boxArr, na)

    int n = array.size(boxArr)
    int lim = math.min(n, array.size(topArr))
    lim := math.min(lim, array.size(botArr))
    lim := math.min(lim, array.size(dirArr))
    lim := math.min(lim, array.size(t0Arr))

    if lim > 0
        for i = 0 to lim - 1
            box   b  = array.get(boxArr, i)
            float tp = array.get(topArr, i)
            float bt = array.get(botArr, i)
            int   d  = array.get(dirArr, i)
            int   t0 = array.get(t0Arr, i)

            bool wantDraw = showFVG and showBoxes and (i < maxShow)
            if not wantDraw
                if not na(b)
                    box.delete(b)
                array.set(boxArr, i, na)
            else
                if na(b)
                    box nbx = f_makeFVGBox(tfStr, widthBarsChart, d, t0, tp, bt)
                    array.set(boxArr, i, nbx)

f_rebuildVisibilityOB(string tfStr, int widthBarsChart, bool showBoxes, int maxShow,
     box[] boxArr, float[] topArr, float[] botArr, int[] dirArr, int[] t0Arr) =>

    int nd = array.size(dirArr)
    int nb = array.size(boxArr)
    if nb < nd
        for k = nb to nd - 1
            array.push(boxArr, na)

    int n = array.size(boxArr)
    int lim = math.min(n, array.size(topArr))
    lim := math.min(lim, array.size(botArr))
    lim := math.min(lim, array.size(dirArr))
    lim := math.min(lim, array.size(t0Arr))

    if lim > 0
        for i = 0 to lim - 1
            box   b  = array.get(boxArr, i)
            float tp = array.get(topArr, i)
            float bt = array.get(botArr, i)
            int   d  = array.get(dirArr, i)
            int   t0 = array.get(t0Arr, i)

            bool wantDraw = showOB and showBoxes and (i < maxShow)
            if not wantDraw
                if not na(b)
                    box.delete(b)
                array.set(boxArr, i, na)
            else
                if na(b)
                    box nbx = f_makeOBBox(tfStr, widthBarsChart, d, t0, tp, bt)
                    array.set(boxArr, i, nbx)

//──────────────────────────────────────────────────────────────────────────────
// INVALIDATION ON HTF CLOSE ONLY
//──────────────────────────────────────────────────────────────────────────────
f_invalidateOnClose(bool tfChanged, float cHTF, box[] boxArr, float[] topArr, float[] botArr, int[] dirArr, int[] t0Arr) =>
    if tfChanged
        int i = array.size(dirArr) - 1
        while i >= 0
            int   d   = array.get(dirArr, i)
            float tp  = array.get(topArr, i)
            float bt  = array.get(botArr, i)
            box   b   = array.get(boxArr, i)

            bool kill = (d == 1 and cHTF < bt) or (d == -1 and cHTF > tp)
            if kill
                if not na(b)
                    box.delete(b)
                array.remove(boxArr, i)
                array.remove(topArr, i)
                array.remove(botArr, i)
                array.remove(dirArr, i)
                array.remove(t0Arr, i)
            i -= 1

//──────────────────────────────────────────────────────────────────────────────
// ADD ZONE
//──────────────────────────────────────────────────────────────────────────────
f_addZone(bool tfChanged, bool showType, bool showBoxes, string tfStr, int widthBarsChart, int maxStore,
    int newDir, float top, float bot, int t0,
    box[] boxArr, float[] topArr, float[] botArr, int[] dirArr, int[] t0Arr,
    bool isFVG) =>

    if tfChanged and showType and newDir != 0 and not na(top) and not na(bot) and not na(t0)
        bool dup = f_isDuplicate(newDir, top, bot, t0, topArr, botArr, dirArr, t0Arr)
        if not dup
            array.unshift(topArr, top)
            array.unshift(botArr, bot)
            array.unshift(dirArr, newDir)
            array.unshift(t0Arr, t0)

            box nb = na
            if showBoxes
                if isFVG
                    nb := f_makeFVGBox(tfStr, widthBarsChart, newDir, t0, top, bot)
                else
                    nb := f_makeOBBox(tfStr, widthBarsChart, newDir, t0, top, bot)

            array.unshift(boxArr, nb)
            f_cap(maxStore, boxArr, topArr, botArr, dirArr, t0Arr)

//──────────────────────────────────────────────────────────────────────────────
// STATUS + BIAS HELPERS (CALC-limited)
//──────────────────────────────────────────────────────────────────────────────
f_statusAny(float px, float[] topArr, float[] botArr, int[] dirArr, int maxCalc) =>
    int n = array.size(dirArr)
    int lim = math.min(n, maxCalc)
    if lim <= 0
        ["N/A", 0]
    else
        int hitDir = 0
        for i = 0 to lim - 1
            float t = array.get(topArr, i)
            float b = array.get(botArr, i)
            if f_inZone(px, t, b)
                hitDir := array.get(dirArr, i)
                break

        string st = "OUT"
        int dRet = 0
        if hitDir != 0
            st := "IN"
            dRet := hitDir
        [st, dRet]

f_lastDirLimited(int[] dirArr, int maxCalc) =>
    int n = array.size(dirArr)
    int lim = math.min(n, maxCalc)
    lim > 0 ? array.get(dirArr, 0) : 0

f_biasTF(float px,
    float[] fTopArr, float[] fBotArr, int[] fDirArr, int maxCalcF,
    float[] oTopArr, float[] oBotArr, int[] oDirArr, int maxCalcO) =>

    int bias = 0

    int no = array.size(oDirArr)
    int lo = math.min(no, maxCalcO)
    if lo > 0
        for i = 0 to lo - 1
            float t = array.get(oTopArr, i)
            float b = array.get(oBotArr, i)
            if f_inZone(px, t, b)
                bias := array.get(oDirArr, i)
                break

    if bias == 0
        int nf = array.size(fDirArr)
        int lf = math.min(nf, maxCalcF)
        if lf > 0
            for i = 0 to lf - 1
                float t = array.get(fTopArr, i)
                float b = array.get(fBotArr, i)
                if f_inZone(px, t, b)
                    bias := array.get(fDirArr, i)
                    break

    if bias == 0
        int ldOB  = f_lastDirLimited(oDirArr, maxCalcO)
        int ldFVG = f_lastDirLimited(fDirArr, maxCalcF)
        bias := (ldOB != 0) ? ldOB : ldFVG

    bias

string ARROW_UP   = "↑"
string ARROW_DOWN = "↓"

f_cellText(string st, int d) =>
    st == "IN" ? ("IN " + (d == 1 ? ARROW_UP : d == -1 ? ARROW_DOWN : "")) : st

f_cellBg(string st, int d) =>
    st == "N/A" ? naBg : st == "OUT" ? outBg : (d == 1 ? okUpBg : d == -1 ? okDnBg : outBg)

f_biasTxt(int d) =>
    d == 1 ? ARROW_UP : d == -1 ? ARROW_DOWN : "-"

f_biasBg(int d) =>
    d == 1 ? okUpBg : d == -1 ? okDnBg : outBg

//──────────────────────────────────────────────────────────────────────────────
// PROCESS TF
//──────────────────────────────────────────────────────────────────────────────
procTF(bool en, string tfStr, bool showBoxes, int widthBarsChart,
       int maxShowF, int maxShowO, int maxCalcF, int maxCalcO, int lastTref,
       box[] fBx, float[] fTopA, float[] fBotA, int[] fDirA, int[] fT0A,
       box[] oBx, float[] oTopA, float[] oBotA, int[] oDirA, int[] oT0A) =>

    [fNewDir, fTop, fBot, fT0, oNewDir, oTop, oBot, oT0, tHTF, cHTF] = request.security(syminfo.tickerid, tfStr, f_htf_state(obPivotLen, obLookback), barmerge.gaps_off, barmerge.lookahead_off)

    int  newLast   = lastTref
    bool tfChanged = en and not na(tHTF) and (na(newLast) or tHTF != newLast)
    if tfChanged
        newLast := tHTF

    if en
        int maxStoreF = math.max(maxShowF, maxCalcF)
        int maxStoreO = math.max(maxShowO, maxCalcO)

        f_addZone(tfChanged, showFVG, showBoxes, tfStr, widthBarsChart, maxStoreF, fNewDir, fTop, fBot, fT0, fBx, fTopA, fBotA, fDirA, fT0A, true)
        f_addZone(tfChanged, showOB,  showBoxes, tfStr, widthBarsChart, maxStoreO, oNewDir, oTop, oBot, oT0, oBx, oTopA, oBotA, oDirA, oT0A, false)

        f_invalidateOnClose(tfChanged, cHTF, fBx, fTopA, fBotA, fDirA, fT0A)
        f_invalidateOnClose(tfChanged, cHTF, oBx, oTopA, oBotA, oDirA, oT0A)

        f_rebuildVisibilityFVG(tfStr, widthBarsChart, showBoxes, maxShowF, fBx, fTopA, fBotA, fDirA, fT0A)
        f_rebuildVisibilityOB (tfStr, widthBarsChart, showBoxes, maxShowO, oBx, oTopA, oBotA, oDirA, oT0A)

    newLast

// width bars on chart (per TF)
w1 = f_widthBarsOnChart(tf1, wMode1, wVal1)
w2 = f_widthBarsOnChart(tf2, wMode2, wVal2)
w3 = f_widthBarsOnChart(tf3, wMode3, wVal3)
w4 = f_widthBarsOnChart(tf4, wMode4, wVal4)

// If enabled by user but blocked by guard, clear + reset lastT
if en1 and not en1G
    f_clearZones(fvgBx1, fvgTop1, fvgBot1, fvgDir1, fvgT01)
    f_clearZones(obBx1,  obTop1,  obBot1,  obDir1,  obT01)
    lastT1 := na
if en2 and not en2G
    f_clearZones(fvgBx2, fvgTop2, fvgBot2, fvgDir2, fvgT02)
    f_clearZones(obBx2,  obTop2,  obBot2,  obDir2,  obT02)
    lastT2 := na
if en3 and not en3G
    f_clearZones(fvgBx3, fvgTop3, fvgBot3, fvgDir3, fvgT03)
    f_clearZones(obBx3,  obTop3,  obBot3,  obDir3,  obT03)
    lastT3 := na
if en4 and not en4G
    f_clearZones(fvgBx4, fvgTop4, fvgBot4, fvgDir4, fvgT04)
    f_clearZones(obBx4,  obTop4,  obBot4,  obDir4,  obT04)
    lastT4 := na

// run TFs (guarded enables)
lastT1 := procTF(en1G, tf1, show1, w1, maxShowF1, maxShowO1, maxCalcF1, maxCalcO1, lastT1, fvgBx1, fvgTop1, fvgBot1, fvgDir1, fvgT01, obBx1, obTop1, obBot1, obDir1, obT01)
lastT2 := procTF(en2G, tf2, show2, w2, maxShowF2, maxShowO2, maxCalcF2, maxCalcO2, lastT2, fvgBx2, fvgTop2, fvgBot2, fvgDir2, fvgT02, obBx2, obTop2, obBot2, obDir2, obT02)
lastT3 := procTF(en3G, tf3, show3, w3, maxShowF3, maxShowO3, maxCalcF3, maxCalcO3, lastT3, fvgBx3, fvgTop3, fvgBot3, fvgDir3, fvgT03, obBx3, obTop3, obBot3, obDir3, obT03)
lastT4 := procTF(en4G, tf4, show4, w4, maxShowF4, maxShowO4, maxCalcF4, maxCalcO4, lastT4, fvgBx4, fvgTop4, fvgBot4, fvgDir4, fvgT04, obBx4, obTop4, obBot4, obDir4, obT04)

//──────────────────────────────────────────────────────────────────────────────
// TABLE (COMPACT + GLOBAL WEIGHTED) - CALC-limited + NEAREST row
// Rows: Header + GLOBAL + TF1..TF4 + NEAREST
//──────────────────────────────────────────────────────────────────────────────
float px = close

[fSt1, fInD1] = f_statusAny(px, fvgTop1, fvgBot1, fvgDir1, maxCalcF1)
[oSt1, oInD1] = f_statusAny(px, obTop1,  obBot1,  obDir1, maxCalcO1)
[fSt2, fInD2] = f_statusAny(px, fvgTop2, fvgBot2, fvgDir2, maxCalcF2)
[oSt2, oInD2] = f_statusAny(px, obTop2,  obBot2,  obDir2, maxCalcO2)
[fSt3, fInD3] = f_statusAny(px, fvgTop3, fvgBot3, fvgDir3, maxCalcF3)
[oSt3, oInD3] = f_statusAny(px, obTop3,  obBot3,  obDir3, maxCalcO3)
[fSt4, fInD4] = f_statusAny(px, fvgTop4, fvgBot4, fvgDir4, maxCalcF4)
[oSt4, oInD4] = f_statusAny(px, obTop4,  obBot4,  obDir4, maxCalcO4)

int b1 = en1G ? f_biasTF(px, fvgTop1, fvgBot1, fvgDir1, maxCalcF1, obTop1, obBot1, obDir1, maxCalcO1) : 0
int b2 = en2G ? f_biasTF(px, fvgTop2, fvgBot2, fvgDir2, maxCalcF2, obTop2, obBot2, obDir2, maxCalcO2) : 0
int b3 = en3G ? f_biasTF(px, fvgTop3, fvgBot3, fvgDir3, maxCalcF3, obTop3, obBot3, obDir3, maxCalcO3) : 0
int b4 = en4G ? f_biasTF(px, fvgTop4, fvgBot4, fvgDir4, maxCalcF4, obTop4, obBot4, obDir4, maxCalcO4) : 0

int score = 0
score += en1G ? (1 * b1) : 0
score += en2G ? (2 * b2) : 0
score += en3G ? (3 * b3) : 0
score += en4G ? (4 * b4) : 0

int gDir = score > 0 ? 1 : score < 0 ? -1 : 0

string gTFtxt = "GLOBAL (" + str.tostring(score) + ")"
string gFtxt  = "F:" + str.tostring(maxCalcF1) + "/" + str.tostring(maxCalcF2) + "/" + str.tostring(maxCalcF3) + "/" + str.tostring(maxCalcF4)
string gOtxt  = "O:" + str.tostring(maxCalcO1) + "/" + str.tostring(maxCalcO2) + "/" + str.tostring(maxCalcO3) + "/" + str.tostring(maxCalcO4)

color gBiasBg = f_biasBg(gDir)

var table tb = na
if showTable and na(tb)
    tb := table.new(f_tblPos(tblPosOpt), 4, 7, border_width=1)

if showTable and not na(tb)
    table.cell(tb, 0, 0, "TF",   text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 1, 0, "FVG",  text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 2, 0, "OB",   text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 3, 0, "BIAS", text_color=tblTxt, bgcolor=cellBgBase)

    table.cell(tb, 0, 1, gTFtxt,          text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 1, 1, gFtxt,           text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 2, 1, gOtxt,           text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 3, 1, f_biasTxt(gDir), text_color=tblTxt, bgcolor=gBiasBg)

    table.cell(tb, 0, 2, f_tfLabel(tf1), text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 1, 2, en1G ? f_cellText(fSt1, fInD1) : "N/A", text_color=tblTxt, bgcolor=en1G ? f_cellBg(fSt1, fInD1) : naBg)
    table.cell(tb, 2, 2, en1G ? f_cellText(oSt1, oInD1) : "N/A", text_color=tblTxt, bgcolor=en1G ? f_cellBg(oSt1, oInD1) : naBg)
    table.cell(tb, 3, 2, en1G ? f_biasTxt(b1) : "-",            text_color=tblTxt, bgcolor=en1G ? f_biasBg(b1) : outBg)

    table.cell(tb, 0, 3, f_tfLabel(tf2), text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 1, 3, en2G ? f_cellText(fSt2, fInD2) : "N/A", text_color=tblTxt, bgcolor=en2G ? f_cellBg(fSt2, fInD2) : naBg)
    table.cell(tb, 2, 3, en2G ? f_cellText(oSt2, oInD2) : "N/A", text_color=tblTxt, bgcolor=en2G ? f_cellBg(oSt2, oInD2) : naBg)
    table.cell(tb, 3, 3, en2G ? f_biasTxt(b2) : "-",            text_color=tblTxt, bgcolor=en2G ? f_biasBg(b2) : outBg)

    table.cell(tb, 0, 4, f_tfLabel(tf3), text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 1, 4, en3G ? f_cellText(fSt3, fInD3) : "N/A", text_color=tblTxt, bgcolor=en3G ? f_cellBg(fSt3, fInD3) : naBg)
    table.cell(tb, 2, 4, en3G ? f_cellText(oSt3, oInD3) : "N/A", text_color=tblTxt, bgcolor=en3G ? f_cellBg(oSt3, oInD3) : naBg)
    table.cell(tb, 3, 4, en3G ? f_biasTxt(b3) : "-",            text_color=tblTxt, bgcolor=en3G ? f_biasBg(b3) : outBg)

    table.cell(tb, 0, 5, f_tfLabel(tf4), text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 1, 5, en4G ? f_cellText(fSt4, fInD4) : "N/A", text_color=tblTxt, bgcolor=en4G ? f_cellBg(fSt4, fInD4) : naBg)
    table.cell(tb, 2, 5, en4G ? f_cellText(oSt4, oInD4) : "N/A", text_color=tblTxt, bgcolor=en4G ? f_cellBg(oSt4, oInD4) : naBg)
    table.cell(tb, 3, 5, en4G ? f_biasTxt(b4) : "-",            text_color=tblTxt, bgcolor=en4G ? f_biasBg(b4) : outBg)

    table.cell(tb, 0, 6, "NEAREST",   text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 1, 6, nearHighTxt, text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 2, 6, nearLowTxt,  text_color=tblTxt, bgcolor=cellBgBase)
    table.cell(tb, 3, 6, "-",         text_color=tblTxt, bgcolor=cellBgBase)

//──────────────────────────────────────────────────────────────────────────────
// GUARD WARNING BANNER (top-center, screen anchored) - NO LABELS ON CANDLES
//──────────────────────────────────────────────────────────────────────────────
bool anyGuardOff = (en1 and not en1G) or (en2 and not en2G) or (en3 and not en3G) or (en4 and not en4G)

var table warnTb = na
if barstate.islast
    if anyGuardOff
        if na(warnTb)
            warnTb := table.new(position.top_center, 1, 1, border_width=1)
        table.cell(warnTb, 0, 0,
            "LTF disabled on this chart TF\nUse a lower chart TF for accurate LTF rows",
            text_color=color.white,
            bgcolor=color.new(color.black, 62))
    else
        if not na(warnTb)
            table.delete(warnTb)
            warnTb := na
````
