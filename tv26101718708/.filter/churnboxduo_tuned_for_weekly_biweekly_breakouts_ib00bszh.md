# ChurnBoxDuo -tuned for weekly, bi-weekly breakouts

- url: https://www.tradingview.com/script/iB00bSzh-ChurnBoxDuo-tuned-for-weekly-bi-weekly-breakouts/
- type: indicator
- pine_id: PUB;82e794a9a098444e9a3b4fc57ac6582e
- version: 1.0

## Description

Breakout boxes defined by ALMA ATR delta and ranked by churn bar counts.

## Source Code

````pine
//@version=6
indicator("ChurnBoxDuo", shorttitle="CBoxDuo", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=5000)

// ============================================================
// BOX B v2.6 — DUAL ALMA + KEEP BOXES + ENGULF ATR ICONS
// Fast ALMA 55/89/144 + Slow ALMA 233/377/610
// Each: ChurnBox + 3MA Squeeze + Cross-All-Three + 3MA Engulf
// ChurnBar engine + visuals from proven v1.6
// No BoxA, no clusters, no extensions, no breakout scoring
// v2.1: User inputs added to keep last X closed Fast/Slow churnboxes
// v2.2: Removed Fast/Slow churnbox midlines and related inputs/line objects
// v2.3: Added Fast/Slow Cross-All-3 triangle icons and Engulf vertical lines
// v2.4: Simplified visible MA signals to 3MA engulf triangles only; no vertical lines
// v2.5: Removed Cross-All-3 logic/scoring/alerts and removed ChurnBar icon/dot outputs
// v2.6: Engulf triangle offsets changed from % ATR to × ATR multipliers
// ============================================================


// ═══════════════════════════════════════════════════════════════
// FAST ALMA 55/89/144 — INPUTS
// ═══════════════════════════════════════════════════════════════

gF = "FAST SET — ALMA 55/89/144"
useFast = input.bool(true,  "Enable Fast Set", group=gF)
f1      = input.int(55,  "Fast L1", minval=1, group=gF)
f2      = input.int(89,  "Fast L2", minval=1, group=gF)
f3      = input.int(144, "Fast L3", minval=1, group=gF)
fSmOn   = input.bool(true, "Fast Smooth", group=gF)
fSm1    = input.int(21, "Fast Sm1", minval=1, group=gF)
fSm2    = input.int(21, "Fast Sm2", minval=1, group=gF)
fSm3    = input.int(21, "Fast Sm3", minval=1, group=gF)
fOff    = input.float(0.85, "Fast ALMA Offset", minval=0.0, maxval=1.0, step=0.05, group=gF)
fSig    = input.int(6, "Fast ALMA Sigma", minval=1, maxval=20, group=gF)
fShow1  = input.bool(true, "Show Fast 55",  group=gF)
fShow2  = input.bool(true, "Show Fast 89",  group=gF)
fShow3  = input.bool(true, "Show Fast 144", group=gF)
fCol1   = input.color(color.new(#ffaa00, 30), "Fast 55 Color",  group=gF)
fCol2   = input.color(color.new(#ff6d00, 30), "Fast 89 Color",  group=gF)
fCol3   = input.color(color.new(#ff2b00, 30), "Fast 144 Color", group=gF)
fLw     = input.int(1, "Fast Line Width", minval=1, maxval=5, group=gF)


// ═══════════════════════════════════════════════════════════════
// SLOW ALMA 233/377/610 — INPUTS
// ═══════════════════════════════════════════════════════════════

gS = "SLOW SET — ALMA 233/377/610"
useSlow = input.bool(false, "Enable Slow Set", group=gS)
s1      = input.int(233, "Slow L1", minval=1, group=gS)
s2      = input.int(377, "Slow L2", minval=1, group=gS)
s3      = input.int(610, "Slow L3", minval=1, group=gS)
sSmOn   = input.bool(true, "Slow Smooth", group=gS)
sSm1    = input.int(34, "Slow Sm1", minval=1, group=gS)
sSm2    = input.int(55, "Slow Sm2", minval=1, group=gS)
sSm3    = input.int(89, "Slow Sm3", minval=1, group=gS)
sOff    = input.float(0.85, "Slow ALMA Offset", minval=0.0, maxval=1.0, step=0.05, group=gS)
sSig    = input.int(6, "Slow ALMA Sigma", minval=1, maxval=20, group=gS)
sShow1  = input.bool(true, "Show Slow 233", group=gS)
sShow2  = input.bool(true, "Show Slow 377", group=gS)
sShow3  = input.bool(true, "Show Slow 610", group=gS)
sCol1   = input.color(color.new(#4fc3f7, 30), "Slow 233 Color", group=gS)
sCol2   = input.color(color.new(#29b6f6, 30), "Slow 377 Color", group=gS)
sCol3   = input.color(color.new(#039be5, 30), "Slow 610 Color", group=gS)
sLw     = input.int(2, "Slow Line Width", minval=1, maxval=5, group=gS)


// ═══════════════════════════════════════════════════════════════
// FAST CHURNBOX INPUTS
// ═══════════════════════════════════════════════════════════════

gFCB = "FAST CHURNBOX"
fTol  = input.float(1.9, "Fast Tol × ATR", minval=0.1, maxval=20.0, step=0.1, group=gFCB)
fAtrLen = input.int(55, "Fast ATR Len", minval=1, maxval=500, group=gFCB)
fMinBars = input.int(3, "Fast Min Squeeze Bars", minval=1, maxval=200, group=gFCB)
fGapTol = input.int(0, "Fast Gap Tol Bars", minval=0, maxval=100, group=gFCB)
fShowBox = input.bool(true, "Show Fast Box", group=gFCB)
fKeepBoxes = input.int(40, "Keep Last Fast Boxes", minval=0, maxval=300, group=gFCB)
fFill = input.color(color.new(#e040fb, 60), "Fast Fill", group=gFCB)
fBrd  = input.color(color.new(#e040fb,  0), "Fast Border", group=gFCB)
fBrdW = input.int(2, "Fast Border Width", minval=1, maxval=5, group=gFCB)


// ═══════════════════════════════════════════════════════════════
// SLOW CHURNBOX INPUTS
// ═══════════════════════════════════════════════════════════════

gSCB = "SLOW CHURNBOX"
sTol  = input.float(1.9, "Slow Tol × ATR", minval=0.1, maxval=20.0, step=0.1, group=gSCB)
sAtrLen = input.int(89, "Slow ATR Len", minval=1, maxval=500, group=gSCB)
sMinBars = input.int(3, "Slow Min Squeeze Bars", minval=1, maxval=200, group=gSCB)
sGapTol = input.int(0, "Slow Gap Tol Bars", minval=0, maxval=100, group=gSCB)
sShowBox = input.bool(true, "Show Slow Box", group=gSCB)
sKeepBoxes = input.int(20, "Keep Last Slow Boxes", minval=0, maxval=300, group=gSCB)
sFill = input.color(color.new(#4fc3f7, 75), "Slow Fill", group=gSCB)
sBrd  = input.color(color.new(#4fc3f7,  0), "Slow Border", group=gSCB)
sBrdW = input.int(2, "Slow Border Width", minval=1, maxval=5, group=gSCB)


// ═══════════════════════════════════════════════════════════════
// FAST 3MA SIGNAL INPUTS
// ═══════════════════════════════════════════════════════════════

gF3 = "FAST 3MA SIGNALS"
fSqzMin  = input.int(2, "Fast Squeeze Min Cross", minval=1, maxval=3, group=gF3)
fSqzWin  = input.int(3, "Fast Squeeze Window", minval=1, maxval=20, group=gF3)
fEngCool = input.int(3, "Fast Engulf Cooldown", minval=1, maxval=20, group=gF3)
fSqzWt   = input.float(2.0, "Fast Squeeze Wt", minval=0, maxval=20, step=0.5, group=gF3)
fEngWt   = input.float(3.0, "Fast Engulf Wt", minval=0, maxval=20, step=0.5, group=gF3)
fActWt   = input.float(2.0, "Fast Active Box Wt", minval=0, maxval=20, step=0.5, group=gF3)

gF3V = "FAST 3MA SIGNAL VISUALS"
fShowEngIcon = input.bool(true, "Show Fast 3MA Engulf Triangles", group=gF3V)
fEngIconOffAtr = input.float(0.75, "Fast Engulf Icon Offset × ATR", minval=0.0, maxval=10.0, step=0.05, group=gF3V)
fEngBullIconCol = input.color(color.new(#00e676, 0), "Fast Engulf Bull Triangle", group=gF3V)
fEngBearIconCol = input.color(color.new(#ff1744, 0), "Fast Engulf Bear Triangle", group=gF3V)


// ═══════════════════════════════════════════════════════════════
// SLOW 3MA SIGNAL INPUTS
// ═══════════════════════════════════════════════════════════════

gS3 = "SLOW 3MA SIGNALS"
sSqzMin  = input.int(2, "Slow Squeeze Min Cross", minval=1, maxval=3, group=gS3)
sSqzWin  = input.int(3, "Slow Squeeze Window", minval=1, maxval=20, group=gS3)
sEngCool = input.int(3, "Slow Engulf Cooldown", minval=1, maxval=20, group=gS3)
sSqzWt   = input.float(3.0, "Slow Squeeze Wt", minval=0, maxval=20, step=0.5, group=gS3)
sEngWt   = input.float(4.0, "Slow Engulf Wt", minval=0, maxval=20, step=0.5, group=gS3)
sActWt   = input.float(2.0, "Slow Active Box Wt", minval=0, maxval=20, step=0.5, group=gS3)

gS3V = "SLOW 3MA SIGNAL VISUALS"
sShowEngIcon = input.bool(true, "Show Slow 3MA Engulf Triangles", group=gS3V)
sEngIconOffAtr = input.float(1.00, "Slow Engulf Icon Offset × ATR", minval=0.0, maxval=10.0, step=0.05, group=gS3V)
sEngBullIconCol = input.color(color.new(#00e5ff, 0), "Slow Engulf Bull Triangle", group=gS3V)
sEngBearIconCol = input.color(color.new(#ff9100, 0), "Slow Engulf Bear Triangle", group=gS3V)


// ═══════════════════════════════════════════════════════════════
// CHURNBAR ENGINE INPUTS
// ═══════════════════════════════════════════════════════════════

gCh = "CHURNBAR ENGINE"
chPreset = input.string("Balanced", "Preset", options=["Balanced","Crypto Scalping","Sideways Accumulation","Trend Pullback","Low Liquidity Chop","Breakout Watch","Custom"], group=gCh)
chAtrLen = input.int(14, "Churn ATR Period", minval=3, maxval=200, group=gCh)
chVolLen = input.int(20, "Churn Vol SMA", minval=5, maxval=300, group=gCh)
chVolPct = input.float(120.0, "Churn Min Vol %", minval=20, maxval=500, step=5.0, group=gCh)
chRngPct = input.float(65.0, "Churn Max Rng %", minval=5, maxval=300, step=5.0, group=gCh)
chUseBody = input.bool(false, "Body Compression", group=gCh)
chBodyPct = input.float(50.0, "Max Body %", minval=1, maxval=100, step=5.0, group=gCh)
chCloseOnly = input.bool(false, "Body Range", group=gCh)

gChV = "CHURNBAR BARCOLOR"
chShowCol  = input.bool(true,  "Color ChurnBars", group=gChV)
chColBar   = input.color(color.new(#E8AF34, 0), "ChurnBar Color", group=gChV)

gChL = "CHURNBAR LINES"
chShowLines = input.bool(true, "ChurnBar Mid Lines", group=gChL)
chLineMode  = input.string("Every ChurnBar", "Trigger", options=["Every ChurnBar","First Only"], group=gChL)
chLineExt   = input.int(34, "Extend Bars", minval=1, maxval=500, group=gChL)
chLineKeep  = input.int(120, "Keep Lines", minval=10, maxval=500, group=gChL)
chLineW     = input.int(1, "Line Width", minval=1, maxval=5, group=gChL)
chLineType  = input.string("Dotted", "Line Type", options=["Solid","Dashed","Dotted"], group=gChL)
chLineCol   = input.color(color.new(#E8AF34, 20), "Line Color", group=gChL)


// ═══════════════════════════════════════════════════════════════
// SCORE INPUTS
// ═══════════════════════════════════════════════════════════════

gScore = "SCORING"
scoreThresh = input.float(8.0, "Score Threshold", minval=0, maxval=200, step=0.5, group=gScore)
scoreCool   = input.int(13, "Score Cooldown", minval=0, maxval=500, group=gScore)

gDbg = "DEBUG"
showDbg = input.bool(true, "Show Debug Table", group=gDbg)


// ═══════════════════════════════════════════════════════════════
// HELPERS (no ta.alma or ta.atr inside — Pine v6 requirement)
// ═══════════════════════════════════════════════════════════════

f_lineStyle(string st) => st == "Solid" ? line.style_solid : st == "Dashed" ? line.style_dashed : line.style_dotted

f_addLine(array<line> arr, float y, int x1, int x2, color c, string st, int w, int keep) =>
    if not na(y)
        ln = line.new(x1, y, x2, y, xloc=xloc.bar_index, extend=extend.none, color=c, style=f_lineStyle(st), width=w)
        array.push(arr, ln)
        if array.size(arr) > keep
            line.delete(array.shift(arr))

f_keepBox(array<box> arr, box bx, int keep) =>
    if not na(bx)
        array.push(arr, bx)
        while array.size(arr) > keep
            box oldBox = array.shift(arr)
            if not na(oldBox)
                box.delete(oldBox)



// ═══════════════════════════════════════════════════════════════
// FAST ALMA — GLOBAL SCOPE (ta.alma NOT in UDF)
// ═══════════════════════════════════════════════════════════════

fma1raw = useFast ? ta.alma(close, f1, fOff, fSig) : na
fma2raw = useFast ? ta.alma(close, f2, fOff, fSig) : na
fma3raw = useFast ? ta.alma(close, f3, fOff, fSig) : na

fma1 = useFast ? (fSmOn ? ta.alma(fma1raw, fSm1, fOff, fSig) : fma1raw) : na
fma2 = useFast ? (fSmOn ? ta.alma(fma2raw, fSm2, fOff, fSig) : fma2raw) : na
fma3 = useFast ? (fSmOn ? ta.alma(fma3raw, fSm3, fOff, fSig) : fma3raw) : na

plot(useFast and fShow1 ? fma1 : na, "Fast 55",  color=fCol1, linewidth=fLw)
plot(useFast and fShow2 ? fma2 : na, "Fast 89",  color=fCol2, linewidth=fLw)
plot(useFast and fShow3 ? fma3 : na, "Fast 144", color=fCol3, linewidth=fLw)


// ═══════════════════════════════════════════════════════════════
// SLOW ALMA — GLOBAL SCOPE
// ═══════════════════════════════════════════════════════════════

sma1raw = useSlow ? ta.alma(close, s1, sOff, sSig) : na
sma2raw = useSlow ? ta.alma(close, s2, sOff, sSig) : na
sma3raw = useSlow ? ta.alma(close, s3, sOff, sSig) : na

sma1 = useSlow ? (sSmOn ? ta.alma(sma1raw, sSm1, sOff, sSig) : sma1raw) : na
sma2 = useSlow ? (sSmOn ? ta.alma(sma2raw, sSm2, sOff, sSig) : sma2raw) : na
sma3 = useSlow ? (sSmOn ? ta.alma(sma3raw, sSm3, sOff, sSig) : sma3raw) : na

plot(useSlow and sShow1 ? sma1 : na, "Slow 233", color=sCol1, linewidth=sLw)
plot(useSlow and sShow2 ? sma2 : na, "Slow 377", color=sCol2, linewidth=sLw)
plot(useSlow and sShow3 ? sma3 : na, "Slow 610", color=sCol3, linewidth=sLw)


// ═══════════════════════════════════════════════════════════════
// ATR PRE-COMPUTE (global scope — ta.atr NOT in UDF)
// ═══════════════════════════════════════════════════════════════

fAtr = useFast ? ta.atr(fAtrLen) : na
sAtr = useSlow ? ta.atr(sAtrLen) : na
chAtr = ta.atr(chAtrLen)


// ═══════════════════════════════════════════════════════════════
// CHURNBAR ENGINE (from proven v1.6)
// ═══════════════════════════════════════════════════════════════

useCustom   = chPreset == "Custom"
volPctUse   = useCustom ? chVolPct : chPreset == "Crypto Scalping" ? 140.0 : chPreset == "Sideways Accumulation" ? 115.0 : chPreset == "Trend Pullback" ? 130.0 : chPreset == "Low Liquidity Chop" ? 160.0 : chPreset == "Breakout Watch" ? 125.0 : 120.0
rngPctUse   = useCustom ? chRngPct : chPreset == "Crypto Scalping" ?  75.0 : chPreset == "Sideways Accumulation" ?  60.0 : chPreset == "Trend Pullback" ?  70.0 : chPreset == "Low Liquidity Chop" ?  50.0 : chPreset == "Breakout Watch" ?  70.0 :  65.0
bodyPctUse  = useCustom ? chBodyPct : chPreset == "Crypto Scalping" ?  60.0 : chPreset == "Sideways Accumulation" ?  45.0 : chPreset == "Trend Pullback" ?  55.0 : chPreset == "Low Liquidity Chop" ?  40.0 : chPreset == "Breakout Watch" ?  55.0 :  50.0
useBodyUse  = useCustom ? chUseBody : chPreset == "Sideways Accumulation" or chPreset == "Low Liquidity Chop"

volThresh   = volPctUse / 100.0
rangeThresh = rngPctUse / 100.0
bodyThresh  = bodyPctUse / 100.0

volSMA       = ta.sma(volume, chVolLen)
bodyMid      = (open + close) / 2.0
wickRange    = high - low
bodyRange    = math.abs(close - open)
rangeForTest = chCloseOnly ? bodyRange : wickRange
bodyRatio    = wickRange > 0 ? bodyRange / wickRange : 0.0
bodyOk       = not useBodyUse or bodyRatio <= bodyThresh

barAtrOk     = not na(chAtr) and chAtr > 0
barVolOk     = not na(volSMA) and volSMA > 0
volRatio     = barVolOk ? volume / volSMA : na
rangeAtrRat  = barAtrOk and chAtr > 0 ? rangeForTest / chAtr : na

isChurnBar   = barAtrOk and barVolOk and rangeForTest <= rangeThresh * chAtr and volume >= volThresh * volSMA and bodyOk
churnStart   = isChurnBar and not isChurnBar[1]

// ChurnBar bar coloring only.
// Icon/dot outputs removed in v2.5 for clarity and Style-tab cleanup.
barcolor(chShowCol and isChurnBar ? chColBar : na)

// ChurnBar mid lines
var line[] churnHLines = array.new<line>()
lineTrigger = chLineMode == "Every ChurnBar" ? isChurnBar : churnStart
if chShowLines and lineTrigger
    f_addLine(churnHLines, bodyMid, bar_index, bar_index + chLineExt, chLineCol, chLineType, chLineW, chLineKeep)


// ═══════════════════════════════════════════════════════════════
// FAST CHURNBOX (proven v1.6 engine — inlined)
// ═══════════════════════════════════════════════════════════════

fHiB     = useFast ? math.max(math.max(fma1, fma2), fma3) : na
fLoB     = useFast ? math.min(math.min(fma1, fma2), fma3) : na
fSpanB   = useFast and not na(fHiB) and not na(fLoB) ? fHiB - fLoB : na
fActiveB = useFast and not na(fSpanB) and not na(fAtr) and fAtr > 0 and fSpanB > 0 and fSpanB <= fAtr * fTol

var int   fRunB       = 0
var float fRunHiB     = na
var float fRunLoB     = na
var int   fActiveStB  = na
var int   fRunChurnB  = 0

fRunB := fActiveB ? fRunB + 1 : 0

if fActiveB
    if fRunB == 1
        fRunHiB     := fHiB
        fRunLoB     := fLoB
        fActiveStB  := bar_index
        fRunChurnB  := isChurnBar ? 1 : 0
    else
        fRunHiB    := math.max(fRunHiB, fHiB)
        fRunLoB    := math.min(fRunLoB, fLoB)
        fRunChurnB += isChurnBar ? 1 : 0
else
    fRunHiB     := na
    fRunLoB     := na
    fActiveStB  := na
    fRunChurnB  := 0

fSqueezeB = fRunB >= fMinBars

var float fSqzHiB    = na
var float fSqzLoB    = na
var int   fSqzStartB = na
var int   fSqzBarsB  = 0
var int   fBoxBarsB  = 0
var box   fBox       = na
var box[] fBoxHistory = array.new<box>()
var int   fGapRunB   = 0

if fActiveB
    fGapRunB := 0
    if fSqueezeB
        if na(fBox)
            fSqzStartB := fActiveStB
            fSqzHiB    := fRunHiB
            fSqzLoB    := fRunLoB
            fBoxBarsB  := fRunB
            fSqzBarsB  := fRunB
            if fShowBox
                fBox := box.new(fSqzStartB, fSqzHiB, bar_index, fSqzLoB, xloc=xloc.bar_index, bgcolor=fFill, border_color=fBrd, border_width=fBrdW)
        else
            fSqzHiB   := math.max(fSqzHiB, fHiB)
            fSqzLoB   := math.min(fSqzLoB, fLoB)
            fBoxBarsB += 1
            fSqzBarsB += 1
            if fShowBox
                fBox.set_top(fSqzHiB)
                fBox.set_bottom(fSqzLoB)
                fBox.set_right(bar_index)
    else if not na(fBox)
        fSqzHiB   := math.max(fSqzHiB, fHiB)
        fSqzLoB   := math.min(fSqzLoB, fLoB)
        fBoxBarsB += 1
        if fShowBox
            fBox.set_top(fSqzHiB)
            fBox.set_bottom(fSqzLoB)
            fBox.set_right(bar_index)
else if not na(fBox)
    fGapRunB += 1
    if fGapRunB <= fGapTol
        fBoxBarsB += 1
        if fShowBox
            fBox.set_right(bar_index)
    else
        if not na(fBox)
            if fShowBox
                fBox.set_right(bar_index - fGapRunB)
            f_keepBox(fBoxHistory, fBox, fKeepBoxes)
        fBox       := na
        fGapRunB   := 0
        fBoxBarsB  := 0
        fSqzBarsB  := 0
        fSqzHiB    := na
        fSqzLoB    := na
        fSqzStartB := na
else
    fGapRunB := 0

fBoxLive = not na(fBox)


// ═══════════════════════════════════════════════════════════════
// SLOW CHURNBOX (mirrors fast — proven engine)
// ═══════════════════════════════════════════════════════════════

sHiB     = useSlow ? math.max(math.max(sma1, sma2), sma3) : na
sLoB     = useSlow ? math.min(math.min(sma1, sma2), sma3) : na
sSpanB   = useSlow and not na(sHiB) and not na(sLoB) ? sHiB - sLoB : na
sActiveB = useSlow and not na(sSpanB) and not na(sAtr) and sAtr > 0 and sSpanB > 0 and sSpanB <= sAtr * sTol

var int   sRunB       = 0
var float sRunHiB     = na
var float sRunLoB     = na
var int   sActiveStB  = na
var int   sRunChurnB  = 0

sRunB := sActiveB ? sRunB + 1 : 0

if sActiveB
    if sRunB == 1
        sRunHiB     := sHiB
        sRunLoB     := sLoB
        sActiveStB  := bar_index
        sRunChurnB  := isChurnBar ? 1 : 0
    else
        sRunHiB    := math.max(sRunHiB, sHiB)
        sRunLoB    := math.min(sRunLoB, sLoB)
        sRunChurnB += isChurnBar ? 1 : 0
else
    sRunHiB     := na
    sRunLoB     := na
    sActiveStB  := na
    sRunChurnB  := 0

sSqueezeB = sRunB >= sMinBars

var float sSqzHiB    = na
var float sSqzLoB    = na
var int   sSqzStartB = na
var int   sSqzBarsB  = 0
var int   sBoxBarsB  = 0
var box   sBox       = na
var box[] sBoxHistory = array.new<box>()
var int   sGapRunB   = 0

if sActiveB
    sGapRunB := 0
    if sSqueezeB
        if na(sBox)
            sSqzStartB := sActiveStB
            sSqzHiB    := sRunHiB
            sSqzLoB    := sRunLoB
            sBoxBarsB  := sRunB
            sSqzBarsB  := sRunB
            if sShowBox
                sBox := box.new(sSqzStartB, sSqzHiB, bar_index, sSqzLoB, xloc=xloc.bar_index, bgcolor=sFill, border_color=sBrd, border_width=sBrdW)
        else
            sSqzHiB   := math.max(sSqzHiB, sHiB)
            sSqzLoB   := math.min(sSqzLoB, sLoB)
            sBoxBarsB += 1
            sSqzBarsB += 1
            if sShowBox
                sBox.set_top(sSqzHiB)
                sBox.set_bottom(sSqzLoB)
                sBox.set_right(bar_index)
    else if not na(sBox)
        sSqzHiB   := math.max(sSqzHiB, sHiB)
        sSqzLoB   := math.min(sSqzLoB, sLoB)
        sBoxBarsB += 1
        if sShowBox
            sBox.set_top(sSqzHiB)
            sBox.set_bottom(sSqzLoB)
            sBox.set_right(bar_index)
else if not na(sBox)
    sGapRunB += 1
    if sGapRunB <= sGapTol
        sBoxBarsB += 1
        if sShowBox
            sBox.set_right(bar_index)
    else
        if not na(sBox)
            if sShowBox
                sBox.set_right(bar_index - sGapRunB)
            f_keepBox(sBoxHistory, sBox, sKeepBoxes)
        sBox       := na
        sGapRunB   := 0
        sBoxBarsB  := 0
        sSqzBarsB  := 0
        sSqzHiB    := na
        sSqzLoB    := na
        sSqzStartB := na
else
    sGapRunB := 0

sBoxLive = not na(sBox)


// ═══════════════════════════════════════════════════════════════
// FAST 3MA SIGNALS
// ═══════════════════════════════════════════════════════════════

fC12 = ta.cross(fma1, fma2)
fC13 = ta.cross(fma1, fma3)
fC23 = ta.cross(fma2, fma3)
fB12 = ta.barssince(fC12)
fB13 = ta.barssince(fC13)
fB23 = ta.barssince(fC23)

fCrossCnt = 0
if fB12 <= fSqzWin
    fCrossCnt += 1
if fB13 <= fSqzWin
    fCrossCnt += 1
if fB23 <= fSqzWin
    fCrossCnt += 1

fSqzNow   = fCrossCnt >= fSqzMin
fSqzFirst = fSqzNow and not fSqzNow[1]

fHiMA = math.max(fma1, fma2, fma3)
fLoMA = math.min(fma1, fma2, fma3)
fEngBull = open < fLoMA and close > fHiMA
fEngBear = open > fHiMA and close < fLoMA
fBsinceEng = ta.barssince(fEngBull[1] or fEngBear[1])
fEngSig = (fEngBull or fEngBear) and (na(fBsinceEng) or fBsinceEng >= fEngCool)

// FAST 3MA VISUALS — ENGULF TRIANGLES ONLY
fEngBullSig = useFast and fEngSig and fEngBull
fEngBearSig = useFast and fEngSig and fEngBear

fEngBullY = fShowEngIcon and fEngBullSig and not na(fAtr) ? low  - fAtr * fEngIconOffAtr : na
fEngBearY = fShowEngIcon and fEngBearSig and not na(fAtr) ? high + fAtr * fEngIconOffAtr : na

plotshape(fEngBullY, title="Fast 3MA Engulf Bull", style=shape.triangleup,   location=location.absolute, color=fEngBullIconCol, size=size.small)
plotshape(fEngBearY, title="Fast 3MA Engulf Bear", style=shape.triangledown, location=location.absolute, color=fEngBearIconCol, size=size.small)

fScore = (fBoxLive ? fActWt : 0.0) + (fBoxLive and fSqzFirst ? fSqzWt : 0.0) + (fBoxLive and fEngSig ? fEngWt : 0.0)


// ═══════════════════════════════════════════════════════════════
// SLOW 3MA SIGNALS
// ═══════════════════════════════════════════════════════════════

sC12 = ta.cross(sma1, sma2)
sC13 = ta.cross(sma1, sma3)
sC23 = ta.cross(sma2, sma3)
sB12 = ta.barssince(sC12)
sB13 = ta.barssince(sC13)
sB23 = ta.barssince(sC23)

sCrossCnt = 0
if sB12 <= sSqzWin
    sCrossCnt += 1
if sB13 <= sSqzWin
    sCrossCnt += 1
if sB23 <= sSqzWin
    sCrossCnt += 1

sSqzNow   = sCrossCnt >= sSqzMin
sSqzFirst = sSqzNow and not sSqzNow[1]

sHiMA = math.max(sma1, sma2, sma3)
sLoMA = math.min(sma1, sma2, sma3)
sEngBull = useSlow and open < sLoMA and close > sHiMA
sEngBear = useSlow and open > sHiMA and close < sLoMA
sBsinceEng = ta.barssince(sEngBull[1] or sEngBear[1])
sEngSig = useSlow and (sEngBull or sEngBear) and (na(sBsinceEng) or sBsinceEng >= sEngCool)

// SLOW 3MA VISUALS — ENGULF TRIANGLES ONLY
sEngBullSig = useSlow and sEngSig and sEngBull
sEngBearSig = useSlow and sEngSig and sEngBear

sEngBullY = sShowEngIcon and sEngBullSig and not na(sAtr) ? low  - sAtr * sEngIconOffAtr : na
sEngBearY = sShowEngIcon and sEngBearSig and not na(sAtr) ? high + sAtr * sEngIconOffAtr : na

plotshape(sEngBullY, title="Slow 3MA Engulf Bull", style=shape.triangleup,   location=location.absolute, color=sEngBullIconCol, size=size.normal)
plotshape(sEngBearY, title="Slow 3MA Engulf Bear", style=shape.triangledown, location=location.absolute, color=sEngBearIconCol, size=size.normal)

sScore = useSlow ? ((sBoxLive ? sActWt : 0.0) + (sBoxLive and sSqzFirst ? sSqzWt : 0.0) + (sBoxLive and sEngSig ? sEngWt : 0.0)) : 0.0


// ═══════════════════════════════════════════════════════════════
// COMBINED SCORE
// ═══════════════════════════════════════════════════════════════

totalScore = fScore + sScore

var int lastScoreBar = na
scoreEvent = (fBoxLive or (useSlow and sBoxLive)) and totalScore >= scoreThresh and (na(lastScoreBar) or bar_index - lastScoreBar > scoreCool)
if scoreEvent
    lastScoreBar := bar_index


// ═══════════════════════════════════════════════════════════════
// DEBUG TABLE
// ═══════════════════════════════════════════════════════════════

var table dbg = table.new(position.top_right, 2, 15, bgcolor=color.new(color.black, 80), border_color=color.new(color.white, 80), border_width=1)
if showDbg and barstate.islast
    table.cell(dbg, 0,  0, "BoxB v2.0",     text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  0, chPreset,         text_color=color.new(#E8AF34, 0), text_size=size.tiny)
    table.cell(dbg, 0,  1, "Fast Box",       text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  1, str.tostring(fActiveB) + " / " + str.tostring(fSqueezeB) + " / " + str.tostring(fBoxLive), text_color=fSqueezeB ? color.lime : color.gray, text_size=size.tiny)
    table.cell(dbg, 0,  2, "Fast Sqz/Eng",   text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  2, str.tostring(fSqzFirst) + " / " + str.tostring(fEngSig), text_color=fSqzFirst ? color.lime : color.gray, text_size=size.tiny)
    table.cell(dbg, 0,  3, "Fast Score",     text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  3, str.tostring(fScore, "#.#"), text_color=fScore > 0 ? color.lime : color.gray, text_size=size.tiny)
    table.cell(dbg, 0,  4, "Slow Box",       text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  4, str.tostring(sActiveB) + " / " + str.tostring(sSqueezeB) + " / " + str.tostring(sBoxLive), text_color=sSqueezeB ? color.new(#4fc3f7, 0) : color.gray, text_size=size.tiny)
    table.cell(dbg, 0,  5, "Slow Sqz/Eng",   text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  5, str.tostring(sSqzFirst) + " / " + str.tostring(sEngSig), text_color=sSqzFirst ? color.new(#4fc3f7, 0) : color.gray, text_size=size.tiny)
    table.cell(dbg, 0,  6, "Slow Score",     text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  6, str.tostring(sScore, "#.#"), text_color=sScore > 0 ? color.new(#4fc3f7, 0) : color.gray, text_size=size.tiny)
    table.cell(dbg, 0,  7, "Total Score",    text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  7, str.tostring(totalScore, "#.#") + " / " + str.tostring(scoreThresh, "#.#"), text_color=totalScore >= scoreThresh ? color.lime : color.gray, text_size=size.tiny)
    table.cell(dbg, 0,  8, "ChurnBar",       text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  8, isChurnBar ? "YES" : "—", text_color=isChurnBar ? color.new(#E8AF34, 0) : color.gray, text_size=size.tiny)
    table.cell(dbg, 0,  9, "Vol/ATR",        text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1,  9, str.tostring(barVolOk ? volume/volSMA : 0, "#.##") + "x / " + str.tostring(chAtr, "#.##"), text_size=size.tiny)
    table.cell(dbg, 0, 10, "Fast CrossCnt",  text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1, 10, str.tostring(fCrossCnt) + "/" + str.tostring(fSqzMin), text_color=fCrossCnt >= fSqzMin ? color.lime : color.gray, text_size=size.tiny)
    table.cell(dbg, 0, 11, "Slow CrossCnt",  text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1, 11, str.tostring(sCrossCnt) + "/" + str.tostring(sSqzMin), text_color=sCrossCnt >= sSqzMin ? color.new(#4fc3f7, 0) : color.gray, text_size=size.tiny)
    table.cell(dbg, 0, 12, "Score Event",    text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1, 12, scoreEvent ? "YES" : "—", text_color=scoreEvent ? color.lime : color.gray, text_size=size.tiny)
    table.cell(dbg, 0, 13, "Fast S/D",       text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1, 13, str.tostring(fSqzBarsB) + " / " + str.tostring(nz(bar_index - fSqzStartB + 1)), text_size=size.tiny)
    table.cell(dbg, 0, 14, "Slow S/D",       text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(dbg, 1, 14, str.tostring(sSqzBarsB) + " / " + str.tostring(nz(bar_index - sSqzStartB + 1)), text_size=size.tiny)


// ═══════════════════════════════════════════════════════════════
// SCAN FEEDS
// ═══════════════════════════════════════════════════════════════

plot(useFast and fSqueezeB ? 1 : 0,     "SCAN Fast Squeeze",    display=display.none)
plot(useFast and fBoxLive ? 1 : 0,      "SCAN Fast BoxLive",    display=display.none)
plot(useFast and fSqzFirst ? 1 : 0,     "SCAN Fast SqzFirst",   display=display.none)
plot(useFast and fEngSig ? 1 : 0,       "SCAN Fast Engulf",     display=display.none)
plot(fScore,                            "SCAN Fast Score",      display=display.none)
plot(useSlow and sSqueezeB ? 1 : 0,     "SCAN Slow Squeeze",    display=display.none)
plot(useSlow and sBoxLive ? 1 : 0,      "SCAN Slow BoxLive",    display=display.none)
plot(useSlow and sSqzFirst ? 1 : 0,     "SCAN Slow SqzFirst",   display=display.none)
plot(useSlow and sEngSig ? 1 : 0,       "SCAN Slow Engulf",     display=display.none)
plot(sScore,                            "SCAN Slow Score",      display=display.none)
plot(totalScore,                        "SCAN Total Score",     display=display.none)
plot(scoreEvent ? 1 : 0,                "SCAN Score Event",     display=display.none)
plot(isChurnBar ? 1 : 0,                "SCAN ChurnBar",        display=display.none)


// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════

alertcondition(useFast and fSqueezeB and not fSqueezeB[1] and barstate.isconfirmed, "Fast Squeeze Start", "{{ticker}} — Fast 55/89/144 squeeze started.")
alertcondition(useFast and fSqzFirst and barstate.isconfirmed, "Fast 3MA Squeeze", "{{ticker}} — Fast 3MA squeeze first.")
alertcondition(useFast and fEngSig and barstate.isconfirmed, "Fast 3MA Engulf", "{{ticker}} — Fast 3MA engulf candle.")
alertcondition(useSlow and sSqueezeB and not sSqueezeB[1] and barstate.isconfirmed, "Slow Squeeze Start", "{{ticker}} — Slow 233/377/610 squeeze started.")
alertcondition(useSlow and sSqzFirst and barstate.isconfirmed, "Slow 3MA Squeeze", "{{ticker}} — Slow 3MA squeeze first.")
alertcondition(useSlow and sEngSig and barstate.isconfirmed, "Slow 3MA Engulf", "{{ticker}} — Slow 3MA engulf candle.")
alertcondition(scoreEvent and barstate.isconfirmed, "Score Event", "{{ticker}} — Score crossed threshold.")
````
