# AlgoSentry ZigZag Trend [Non-Repaint]

- url: https://www.tradingview.com/script/U7eGgrRu-AlgoSentry-ZigZag-Trend-Non-Repaint/
- type: indicator
- pine_id: PUB;841d6da2796b4bb4a032cbefaeafae7c
- version: 1.0

## Description

AlgoSentry ZigZag Trend is a non-repainting trend and pullback tool. It maps market structure with an adaptive ZigZag, grades each pullback by depth, and confirms trend-continuation signals only on the candle close — so what you see in history is what you would have seen live.

The idea
Many signal indicators repaint: the marker you acted on can shift or vanish after the bar closes, which makes a backtest look better than reality. This script is built to avoid that. Every label and alert is gated to confirmed bar close (barstate.isconfirmed), and the higher-timeframe filter uses lookahead_off. No hindsight.

How it works
- Adaptive ZigZag — pivots are confirmed by an ATR-scaled deviation, so the structure adapts to volatility instead of a fixed percentage.
- Trend context — a slope-colored moving average plus an optional SMA-200 gate define the prevailing trend; signals are only allowed in that direction.
- Chop filter — an ADX regime filter suppresses signals when there is no real trend (sideways, low-ADX conditions).
- Pullback grading — each corrective leg is measured against the prior impulse and colored by depth (red to orange to green) so you can see how deep the retracement is.

The signals, in sequence
1. Red — a correction against the trend begins.
2. Magenta — price tags the moving average inside the correction.
3. Orange — the ZigZag prints a counter-pivot (the pullback turns).
4. Green — confirmed continuation: price resumes in the trend direction after the pullback. This is the main signal, and it locks on bar close.

Key inputs
ZigZag deviation and depth with an ATR adaptive-deviation toggle; ADX filter and minimum strength; SMA-200 trend filter with MA type, length and slope threshold; an optional repaint-safe higher-timeframe filter; a "green requires close beyond pivot" option for stricter entries; a minimal mode that shows only the confirmation markers; and an on-chart dashboard for trend, ADX, SMA-200 state and the last signal.

How to use it
Trade in the direction the tool is showing. Wait for the pullback sequence (red, then magenta or orange), then use the green confirmation as your continuation trigger, with your own structure and risk management. Raise the minimum ADX or enable the higher-timeframe filter to reduce signals in choppy markets; loosen them for more frequent setups. Validate across several instruments and timeframes — do not tune it to a single chart.

Notes
Educational tool for studying trend and pullback structure. It is not financial advice, it does not predict the market, and it does not guarantee any result. Signals are descriptive, not recommendations.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  AlgoSentry — ZigZag Trend Pullback  [v15]
//  Free educational indicator · IS LIES. OOS IS TRUTH.
//  v14: non-repaint (bar-close signals) + AlgoSentry brand visuals.
//  v15: STRUCTURAL false-signal filters (not curve-fit):
//       (1) ADX regime filter  - suppress signals in chop  [ON]
//       (2) ATR-adaptive deviation - zigzag scales to volatility  [ON]
//       (3) Higher-timeframe trend alignment  [opt-in, repaint-safe]
//       (4) GREEN confirmed-break mode (close beyond pivot)  [opt-in]
//  Validate across multiple instruments/timeframes — do not tune to one chart.
// ════════════════════════════════════════════════════════════════════════════
indicator("AlgoSentry ZigZag Trend [Non-Repaint]", overlay=true, max_lines_count=500, max_labels_count=500)

// ── AlgoSentry brand palette ────────────────────────────────────────────────
color AS_MAGENTA = #E61EB4
color AS_GREEN   = #8CE800
color AS_CYAN    = #00E5FF
color AS_GOLD    = #FF9410
color AS_RED     = #FF2D6B
color AS_DIM     = #6B7280
color AS_NAVY    = #0E1226
color AS_WHITE   = #EAF0FA

//======================
// Heikin Ashi (manual)
//======================
ha_close = (open + high + low + close) / 4.0
var float ha_open = na
ha_open := na(ha_open[1]) ? (open + close) / 2.0 : (ha_open[1] + ha_close[1]) / 2.0
ha_high = math.max(high, math.max(ha_open, ha_close))
ha_low  = math.min(low,  math.min(ha_open, ha_close))

//======================
// Inputs
//======================
grpZZ   = "ZigZag"
deviationPct = input.float(0.3, "Deviation % (confirm pivot)", minval=0.00001, step=0.1, group=grpZZ)
depthBars    = input.int(2, "Depth (min bars between pivots)", minval=0, group=grpZZ)
useWicksHA   = input.bool(false, "Use HA High/Low (wicks) for extremes", group=grpZZ)
keepLegN     = input.int(200, "Keep last N ZigZag legs", minval=10, maxval=500, group=grpZZ)

grpQ = "Quality / Filters (reduce false signals)"
useADX        = input.bool(true,  "Filter chop with ADX (only trade real trends)", group=grpQ)
adxLen        = input.int(14, "ADX length", minval=1, group=grpQ)
adxMin        = input.float(22.0, "Min ADX (trend strength)", minval=0.0, step=1.0, group=grpQ)
useAdaptiveDev= input.bool(true,  "Adaptive deviation (scale ZigZag to ATR)", group=grpQ)
atrDevLen     = input.int(14, "ATR length (adaptive dev)", minval=1, group=grpQ)
atrDevMult    = input.float(1.0, "Adaptive dev = ATR% x mult", minval=0.1, step=0.1, group=grpQ)
useHTF        = input.bool(false, "Higher-timeframe trend filter", group=grpQ)
htfTF         = input.timeframe("240", "HTF timeframe", group=grpQ)
confirmGreen  = input.bool(false, "GREEN requires CLOSE beyond pivot (fewer fakeouts)", group=grpQ)

grpVis = "Visual"
baseColor   = input.color(AS_DIM, "Base ZZ Color (neutral)", group=grpVis)
widthZZ     = input.int(2, "ZZ Line Width (base)", minval=1, maxval=5, group=grpVis)
glowMA      = input.bool(true, "MA glow effect", group=grpVis)
showPanel   = input.bool(true, "Show AlgoSentry dashboard", group=grpVis)
showCorrBG  = input.bool(true, "Shade active correction", group=grpVis)

thrRed    = input.float(50.0, "Red if pct < ...",    minval=0.0, step=0.5, group=grpVis)
thrOrange = input.float(35.0, "Orange if pct < ...", minval=0.0, step=0.5, group=grpVis)
thrGreen  = input.float(25.0, "Green if pct < ...",  minval=0.0, step=0.5, group=grpVis)

colRed    = input.color(AS_RED,     "Color: Red tier",    group=grpVis)
colOrange = input.color(AS_GOLD,    "Color: Orange tier", group=grpVis)
colGreen  = input.color(AS_GREEN,   "Color: Green tier",  group=grpVis)
colMagenta= input.color(AS_MAGENTA, "Color: MA-touch tier", group=grpVis)

grpMA = "MA (SLOPE COLOR)"
maLen     = input.int(20, "MA length", minval=1, group=grpMA)
maType    = input.string("EMA", "MA Type", options=["SMA","EMA"], group=grpMA)
maSource  = input.string("Regular", "MA Source", options=["Regular","Heikin Ashi"], group=grpMA)
slopeTh   = input.float(0.04, "Slope Threshold (%) per bar", minval=0.0, step=0.01, group=grpMA)
flatCol   = input.color(AS_DIM,  "Color when no slope", group=grpMA)
slopeCol  = input.color(AS_CYAN, "Color when slope (up/down)", group=grpMA)

slopeOnlyGreen = input.bool(true, "Use slope filter ONLY for GREEN (Mode 4)", group=grpMA)
useSMA200Filter = input.bool(true, "Filter with SMA200 (trend) + show SMA200", group=grpMA)

grpAl = "Alert"
enableAlert = input.bool(true, "Enable Alert (Arrows + alertcondition)", group=grpAl)

alertMode = input.string(
     "All four signals",
     "Signals shown on chart",
     options=[
        "1) Correction vs trend",
        "2) MA touch (magenta)",
        "3) New ZigZag with trend",
        "4) Early break with trend",
        "All four signals"
     ],
     group=grpAl
)

grpFire = "Fire alerts on"
fireRed    = input.bool(false, "1 (red arrow)",     group=grpFire, inline="f1")
fireMagenta= input.bool(true,  "2 (magenta arrow)", group=grpFire, inline="f1")
fireOrange = input.bool(true,  "3 (orange arrow)",  group=grpFire, inline="f2")
fireGreen  = input.bool(false, "4 (green arrow)",   group=grpFire, inline="f2")

signalTier = input.string("Green+Orange+Red", "Signal tier (chart)", options=["Green only","Green+Orange","Green+Orange+Red"], group=grpAl)
fireTier   = input.string("Green+Orange+Red", "Fire tier (alerts)",  options=["Green only","Green+Orange","Green+Orange+Red"], group=grpAl)
arrowSizeOpt = input.string("Huge", "Arrow Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpAl)

grpEB = "Early Break (Mode 4)"
earlyMethod = input.string(
     "Break last ZigZag pivot (last high/low)",
     "Early break method",
     options=["Break last N bars (high/low)","Percent from correction extreme","Break last ZigZag pivot (last high/low)"],
     group=grpEB)
earlyN   = input.int(2, "N bars for break (high/low)", minval=1, group=grpEB)
earlyPct = input.float(35.0, "Percent retrace from correction", minval=0.1, step=0.5, group=grpEB)

//======================
// Helpers
//======================
f_dev_ok(fromPrice, toPrice, devPct) =>
    fromPrice != 0 and math.abs(toPrice - fromPrice) / math.abs(fromPrice) * 100.0 >= devPct

f_tier(pct) =>
    pct < thrGreen ? 3 : pct < thrOrange ? 2 : pct < thrRed ? 1 : 0

f_tier_color(t) =>
    t == 3 ? colGreen : t == 2 ? colOrange : t == 1 ? colRed : baseColor

f_tier_ok(t, mode) =>
    mode == "Green only" ? (t == 3) :
     mode == "Green+Orange" ? (t >= 2) :
     (t >= 1)

f_size(sz) =>
    (
      sz == "Tiny"   ? size.tiny  :
      sz == "Small"  ? size.small :
      sz == "Normal" ? size.normal:
      sz == "Large"  ? size.large :
                       size.huge
    )
arrSize = f_size(arrowSizeOpt)

//======================
// PRICES
//======================
trackPrice = ha_close
extHigh = useWicksHA ? ha_high : trackPrice
extLow  = useWicksHA ? ha_low  : trackPrice
brkHigh = high
brkLow  = low

//======================
// MA + slope
//======================
maSrc = maSource == "Heikin Ashi" ? ha_close : close
ma = maType == "EMA" ? ta.ema(maSrc, maLen) : ta.sma(maSrc, maLen)

slopePct = (not na(ma[1]) and ma[1] != 0) ? math.abs((ma - ma[1]) / ma[1]) * 100.0 : 0.0
hasSlope = slopePct >= slopeTh
maUpRaw   = ma > ma[1]
maDownRaw = ma < ma[1]
slopeUp   = hasSlope and maUpRaw
slopeDown = hasSlope and maDownRaw

maCol = hasSlope ? slopeCol : flatCol
plot(glowMA ? ma : na, "MA glow", color=color.new(maCol, 72), linewidth=7)
plot(ma, "MA", color=maCol, linewidth=2)

//======================
// QUALITY FILTERS (v15)
//======================
// (2) ATR-adaptive deviation — scale the zigzag's confirm threshold to volatility
atrPctDev = ta.atr(atrDevLen) / close * 100.0
devEff = useAdaptiveDev ? math.max(atrPctDev * atrDevMult, 0.00001) : deviationPct

// (1) ADX regime filter — only trade when a real trend exists
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxLen)
adxOK = not useADX or adxVal >= adxMin

// (3) HTF trend filter — repaint-safe (lookahead_off; outputs are bar-close gated)
htfMA = request.security(syminfo.tickerid, htfTF, ta.ema(close, maLen), lookahead=barmerge.lookahead_off)
htfUpOK = not useHTF or close > htfMA
htfDnOK = not useHTF or close < htfMA

//======================
// SMA200 filter
//======================
sma200 = ta.sma(close, 200)
plot(useSMA200Filter ? sma200 : na, "SMA200", color=color.new(AS_GOLD, 35), linewidth=2)

allowUp200   = not useSMA200Filter or ((ma > sma200) and (close > sma200))
allowDown200 = not useSMA200Filter or ((ma < sma200) and (close < sma200))

// master directional gates (SMA200 + HTF + ADX)
gateUp = allowUp200 and htfUpOK and adxOK
gateDn = allowDown200 and htfDnOK and adxOK

trendUpNow = trackPrice > ma
trendDnNow = trackPrice < ma

//======================
// ZigZag State
//======================
var int dir = 0
var float pivotPrice = na
var int   pivotIndex = na
var float legExtreme = na
var int   legExtremeIndex = na
var float lastClosedLegLen = na

var line[] zzLegs = array.new_line()
var line legLine = na

var bool inCorrection = false
var bool wasCorrectionLegPrev = false
var float corrStartPrice = na
var float corrExtreme = na

var float pivotHiReg = na
var float pivotLoReg = na
var float legExtremeHiReg = na
var float legExtremeLoReg = na
var float corrPivotHiReg = na
var float corrPivotLoReg = na

var bool hadRed = false
var bool hadOrange = false
var bool hadPurple = false
var bool tierOkArmed = false

if barstate.isfirst
    pivotPrice := trackPrice
    pivotIndex := bar_index
    legExtreme := trackPrice
    legExtremeIndex := bar_index
    dir := 0
    pivotHiReg := high
    pivotLoReg := low
    legExtremeHiReg := high
    legExtremeLoReg := low

if dir == 0
    if f_dev_ok(pivotPrice, extHigh, devEff)
        dir := +1
        legExtreme := extHigh
        legExtremeIndex := bar_index
        legExtremeHiReg := high
        legExtremeLoReg := low
    else if f_dev_ok(pivotPrice, extLow, devEff)
        dir := -1
        legExtreme := extLow
        legExtremeIndex := bar_index
        legExtremeHiReg := high
        legExtremeLoReg := low

if dir == +1
    if extHigh >= legExtreme
        legExtreme := extHigh
        legExtremeIndex := bar_index
        legExtremeHiReg := high
        legExtremeLoReg := low
else if dir == -1
    if extLow <= legExtreme
        legExtreme := extLow
        legExtremeIndex := bar_index
        legExtremeHiReg := high
        legExtremeLoReg := low

if dir != 0 and not na(pivotPrice)
    if na(legLine)
        legLine := line.new(pivotIndex, pivotPrice, legExtremeIndex, legExtreme, color=baseColor, width=widthZZ)
    else
        line.set_xy1(legLine, pivotIndex, pivotPrice)
        line.set_xy2(legLine, legExtremeIndex, legExtreme)

isCorrectionLegNow = (trendDnNow and dir == +1) or (trendUpNow and dir == -1)

curLegLenAbs = math.abs(legExtreme - pivotPrice)
float livePct = na
if not na(lastClosedLegLen) and lastClosedLegLen > 0
    livePct := curLegLenAbs / lastClosedLegLen * 100.0

liveTier = not na(livePct) ? f_tier(livePct) : 0
liveCol  = f_tier_color(liveTier)

tierOkSignal = f_tier_ok(liveTier, signalTier)
tierOkFire   = f_tier_ok(liveTier, fireTier)

if not na(legLine)
    if isCorrectionLegNow and not na(livePct)
        line.set_color(legLine, liveCol)
        line.set_width(legLine, math.min(widthZZ + 1, 5))
    else
        line.set_color(legLine, baseColor)
        line.set_width(legLine, widthZZ)

corrStartLive = isCorrectionLegNow and not wasCorrectionLegPrev
if corrStartLive
    inCorrection := true
    corrStartPrice := pivotPrice
    corrExtreme := legExtreme
    corrPivotHiReg := pivotHiReg
    corrPivotLoReg := pivotLoReg
    hadRed := false
    hadOrange := false
    hadPurple := false
    tierOkArmed := false

if isCorrectionLegNow and inCorrection
    if trendDnNow
        corrExtreme := na(corrExtreme) ? legExtreme : math.max(corrExtreme, legExtreme)
    else if trendUpNow
        corrExtreme := na(corrExtreme) ? legExtreme : math.min(corrExtreme, legExtreme)

if not isCorrectionLegNow
    inCorrection := false
    corrStartPrice := na
    corrExtreme := na
    hadPurple := false

barsSincePivot = bar_index - pivotIndex
reversal = false
revPrice = trackPrice

if dir == +1
    revPrice := extLow
    reversal := (barsSincePivot >= depthBars) and f_dev_ok(legExtreme, revPrice, devEff) and (revPrice < legExtreme)
else if dir == -1
    revPrice := extHigh
    reversal := (barsSincePivot >= depthBars) and f_dev_ok(legExtreme, revPrice, devEff) and (revPrice > legExtreme)

//======================
// Signals 1/2/3/4
//======================
use1 = alertMode == "1) Correction vs trend"     or alertMode == "All four signals"
use2 = alertMode == "2) MA touch (magenta)"      or alertMode == "All four signals"
use3 = alertMode == "3) New ZigZag with trend"   or alertMode == "All four signals"
use4 = alertMode == "4) Early break with trend"  or alertMode == "All four signals"

slopeOkFor123 = slopeOnlyGreen ? true : hasSlope
dirUp123 = (hasSlope ? slopeUp : maUpRaw)
dirDn123 = (hasSlope ? slopeDown : maDownRaw)
dirAllowed123 = (dirUp123 and gateUp) or (dirDn123 and gateDn)

sig1_base = enableAlert and use1 and corrStartLive and slopeOkFor123 and tierOkSignal and not na(livePct)
sig1      = sig1_base and dirAllowed123

hadRedNow = hadRed or sig1
touchedMA = (low <= ma and high >= ma)
sig2_base = enableAlert and use2 and inCorrection and hadRedNow and (not hadOrange) and (not hadPurple) and touchedMA and slopeOkFor123 and tierOkSignal and not na(livePct)
sig2      = sig2_base and dirAllowed123
if sig2
    hadPurple := true

sig3_base = enableAlert and use3 and inCorrection and reversal and slopeOkFor123 and tierOkSignal and not na(livePct)
sig3      = sig3_base and dirAllowed123

hadOrangeNow = hadOrange or sig3
tierOkArmedNow = tierOkArmed or ((sig1 or sig3) and tierOkSignal)
armedGreenNow = (hadRedNow) and (hadOrangeNow)

//======================
// Early Break (Mode 4)
//======================
earlyBreakN = (
    inCorrection and isCorrectionLegNow and hasSlope and tierOkArmedNow and
    (
      (trendDnNow and trackPrice < ta.lowest(trackPrice[1], earlyN)) or
      (trendUpNow and trackPrice > ta.highest(trackPrice[1], earlyN))
    ))

earlyBreakPct = (
    inCorrection and isCorrectionLegNow and hasSlope and tierOkArmedNow and not na(corrExtreme) and not na(corrStartPrice) and
    (
      (trendDnNow and (corrExtreme - corrStartPrice) > 0 and trackPrice <= (corrExtreme - (corrExtreme - corrStartPrice) * (earlyPct/100.0))) or
      (trendUpNow and (corrStartPrice - corrExtreme) > 0 and trackPrice >= (corrExtreme + (corrStartPrice - corrExtreme) * (earlyPct/100.0)))
    ))

// confirmGreen: require a CLOSE beyond the pivot, not just an intrabar poke
earlyBreakZZPivot = (
    hasSlope and tierOkArmedNow and not na(corrPivotHiReg) and not na(corrPivotLoReg) and
    (
      (trendDnNow and (confirmGreen ? close : brkLow)  < corrPivotLoReg) or
      (trendUpNow and (confirmGreen ? close : brkHigh) > corrPivotHiReg)
    ))

earlyBreak =
     earlyMethod == "Break last ZigZag pivot (last high/low)" ? (armedGreenNow and earlyBreakZZPivot) :
     earlyMethod == "Break last N bars (high/low)" ? (armedGreenNow and earlyBreakN) :
     (armedGreenNow and earlyBreakPct)

sig4_base = enableAlert and use4 and earlyBreak
sig4Up = sig4_base and slopeUp and gateUp
sig4Dn = sig4_base and slopeDown and gateDn
sig4   = sig4Up or sig4Dn

//======================
// Persist arming
//======================
if sig1
    hadRed := true
    tierOkArmed := tierOkArmed or tierOkSignal
if sig3
    hadOrange := true
    tierOkArmed := tierOkArmed or tierOkSignal
if sig3
    hadPurple := false
if sig4 and barstate.isconfirmed
    hadRed := false
    hadOrange := false
    hadPurple := false
    tierOkArmed := false

//======================
// Directional arrow signals
//======================
sig1Up = sig1 and dirUp123 and gateUp
sig1Dn = sig1 and dirDn123 and gateDn
sig2Up = sig2 and dirUp123 and gateUp
sig2Dn = sig2 and dirDn123 and gateDn
sig3Up = sig3 and dirUp123 and gateUp
sig3Dn = sig3 and dirDn123 and gateDn

//======================
// Fire selection
//======================
fireSig1 = (sig1Up or sig1Dn) and fireRed     and tierOkFire
fireSig2 = (sig2Up or sig2Dn) and fireMagenta and tierOkFire
fireSig3 = (sig3Up or sig3Dn) and fireOrange  and tierOkFire
fireSig4 = (sig4Up or sig4Dn) and fireGreen   and tierOkArmedNow

// NON-REPAINT: alerts fire only on confirmed bar close
fireAny = enableAlert and (fireSig1 or fireSig2 or fireSig3 or fireSig4) and barstate.isconfirmed
alertcondition(fireAny, title="FIRE (Auto)", message="AlgoSentry ZigZag: FIRE signal (bar close)")

//======================
// Subtle correction shading (brand)
//======================
bgcolor(showCorrBG and inCorrection and tierOkSignal and not na(livePct) ? color.new(liveCol, 92) : na)

//======================
// Arrow markers — CONFIRMED ON BAR CLOSE (non-repaint)
//======================
atrMark = ta.atr(14)
stepY   = atrMark * 0.35
yUp1 = low  - stepY * 1.00
yUpP = low  - stepY * 1.70
yUp2 = low  - stepY * 2.40
yUp3 = low  - stepY * 3.10
yDn1 = high + stepY * 1.00
yDnP = high + stepY * 1.70
yDn2 = high + stepY * 2.40
yDn3 = high + stepY * 3.10

confirmed = barstate.isconfirmed

// 1 · RED  (correction begins)
if sig1Up and confirmed
    label.new(bar_index, yUp1, "▲", style=label.style_none, textcolor=colRed, size=arrSize)
if sig1Dn and confirmed
    label.new(bar_index, yDn1, "▼", style=label.style_none, textcolor=colRed, size=arrSize)

// 2 · MAGENTA (MA touch)
if sig2Up and confirmed
    label.new(bar_index, yUpP, "▲", style=label.style_none, textcolor=colMagenta, size=arrSize)
if sig2Dn and confirmed
    label.new(bar_index, yDnP, "▼", style=label.style_none, textcolor=colMagenta, size=arrSize)

// 3 · ORANGE (ZigZag reversal)
if sig3Up and confirmed
    label.new(bar_index, yUp2, "▲", style=label.style_none, textcolor=colOrange, size=arrSize)
if sig3Dn and confirmed
    label.new(bar_index, yDn2, "▼", style=label.style_none, textcolor=colOrange, size=arrSize)

// 4 · GREEN (hero entry — filled pointer)
if sig4Up and confirmed
    label.new(bar_index, yUp3, "▲", style=label.style_label_up,   color=colGreen, textcolor=AS_NAVY, size=arrSize)
if sig4Dn and confirmed
    label.new(bar_index, yDn3, "▼", style=label.style_label_down, color=colGreen, textcolor=AS_NAVY, size=arrSize)

//======================
// Last-signal tracking (for panel)
//======================
var string lastSig = "—"
var color  lastSigCol = AS_DIM
if confirmed
    if sig4Up or sig4Dn
        lastSig := "GREEN · entry"
        lastSigCol := colGreen
    else if sig3Up or sig3Dn
        lastSig := "ORANGE · reversal"
        lastSigCol := colOrange
    else if sig2Up or sig2Dn
        lastSig := "MAGENTA · MA touch"
        lastSigCol := colMagenta
    else if sig1Up or sig1Dn
        lastSig := "RED · correction"
        lastSigCol := colRed

//======================
// Reversal finalize
//======================
if reversal
    closedTrendUp = trackPrice > ma
    closedTrendDn = trackPrice < ma
    closedIsCorrection = (closedTrendDn and dir == +1) or (closedTrendUp and dir == -1)
    closedLegLenAbs = math.abs(legExtreme - pivotPrice)

    if not na(legLine) and closedIsCorrection and not na(lastClosedLegLen) and lastClosedLegLen > 0
        closedPct  = closedLegLenAbs / lastClosedLegLen * 100.0
        closedTier = f_tier(closedPct)
        line.set_color(legLine, f_tier_color(closedTier))
        line.set_width(legLine, math.min(widthZZ + 1, 5))
    else
        if not na(legLine)
            line.set_color(legLine, baseColor)
            line.set_width(legLine, widthZZ)

    if not na(legLine)
        array.push(zzLegs, legLine)
        while array.size(zzLegs) > keepLegN
            old = array.shift(zzLegs)
            line.delete(old)

    lastClosedLegLen := closedLegLenAbs
    pivotHiReg := legExtremeHiReg
    pivotLoReg := legExtremeLoReg
    pivotPrice := legExtreme
    pivotIndex := legExtremeIndex
    dir := -dir
    legExtreme := trackPrice
    legExtremeIndex := bar_index
    legExtremeHiReg := high
    legExtremeLoReg := low
    legLine := na
    wasCorrectionLegPrev := false
else
    wasCorrectionLegPrev := isCorrectionLegNow

plot(na)

//======================
// AlgoSentry dashboard panel (brand)
//======================
var table panel = na
if showPanel and barstate.islast
    if na(panel)
        panel := table.new(position.top_right, 2, 7, border_width=1, border_color=color.new(AS_DIM, 55), frame_width=1, frame_color=color.new(AS_MAGENTA, 35))
    trendTxt = trendUpNow ? "UP" : trendDnNow ? "DOWN" : "FLAT"
    trendC   = trendUpNow ? colGreen : trendDnNow ? colRed : AS_DIM
    tierTxt  = inCorrection and not na(livePct) ? (liveTier == 3 ? "GREEN" : liveTier == 2 ? "ORANGE" : liveTier == 1 ? "RED" : "—") : "—"
    adxTxt   = useADX ? str.tostring(adxVal, "#.0") + (adxOK ? " ✓" : " ✕") : "off"
    adxC     = not useADX ? AS_DIM : (adxOK ? colGreen : colRed)
    cBg = color.new(AS_NAVY, 10)
    table.cell(panel, 0, 0, "ALGOSENTRY", text_color=AS_WHITE, bgcolor=AS_MAGENTA, text_size=size.normal, text_halign=text.align_left)
    table.cell(panel, 1, 0, "ZIGZAG",     text_color=AS_WHITE, bgcolor=AS_MAGENTA, text_size=size.normal, text_halign=text.align_right)
    table.cell(panel, 0, 1, "Trend",      text_color=AS_DIM, bgcolor=cBg, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 1, trendTxt,     text_color=trendC, bgcolor=cBg, text_size=size.small, text_halign=text.align_right)
    table.cell(panel, 0, 2, "ADX",        text_color=AS_DIM, bgcolor=cBg, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 2, adxTxt,       text_color=adxC,   bgcolor=cBg, text_size=size.small, text_halign=text.align_right)
    table.cell(panel, 0, 3, "Correction", text_color=AS_DIM, bgcolor=cBg, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 3, tierTxt,      text_color=f_tier_color(liveTier), bgcolor=cBg, text_size=size.small, text_halign=text.align_right)
    table.cell(panel, 0, 4, "SMA200",     text_color=AS_DIM, bgcolor=cBg, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 4, useSMA200Filter ? "ON" : "OFF", text_color=useSMA200Filter ? AS_CYAN : AS_DIM, bgcolor=cBg, text_size=size.small, text_halign=text.align_right)
    table.cell(panel, 0, 5, "Last signal",text_color=AS_DIM, bgcolor=cBg, text_size=size.small, text_halign=text.align_left)
    table.cell(panel, 1, 5, lastSig,      text_color=lastSigCol, bgcolor=cBg, text_size=size.small, text_halign=text.align_right)
    table.cell(panel, 0, 6, "IS LIES.", text_color=color.new(AS_DIM, 10), bgcolor=color.new(AS_NAVY, 0), text_size=size.tiny, text_halign=text.align_left)
    table.cell(panel, 1, 6, "OOS IS TRUTH.", text_color=color.new(AS_MAGENTA, 10), bgcolor=color.new(AS_NAVY, 0), text_size=size.tiny, text_halign=text.align_right)
````
