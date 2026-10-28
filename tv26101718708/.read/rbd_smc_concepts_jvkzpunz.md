# RBD SMC Concepts

- url: https://www.tradingview.com/script/jvKZPuNz-RBD-SMC-Concepts/
- type: indicator
- pine_id: PUB;6860dde2b460437f81d1a00dfb5175c4
- version: 2.0

## Description

RBD SMC Concepts is an institutional-grade Smart Money Concepts toolkit that combines higher-timeframe bias detection
  with the four signals professional traders actually use: liquidity sweeps, order blocks, fair value gaps, and
  break-of-structure events — all gated by HTF alignment to filter out counter-trend noise.

  What it does

  The script tracks structure on a higher timeframe and overlays four signal types on your current chart, only
  displaying those that align with the HTF directional bias when the alignment filter is enabled.

  HTF Bias Engine

  Auto-maps your chart timeframe to a logical higher timeframe (5m → 30m, 15m → 1H, 1H → 4H, 4H → D) or override
  manually. Tracks the last three confirmed swing highs and lows on the HTF and labels the bias as:

  - Bullish: Higher Highs + Higher Lows
  - Bearish: Lower Highs + Lower Lows
  - Neutral: any other structure (range / mixed)

  Order Blocks

  On every LTF Break of Structure, marks the last opposing candle as an order block. Bullish OB = last down candle
  before bullish BOS; bearish OB = last up candle before bearish BOS. Boxes auto-mitigate once price returns to them,
  keeping the chart clean.

  Liquidity Sweeps

  Detects wicks that pierce the prior 10-bar swing high or low and close back inside the range. Reported as SSL ↑
  (sell-side liquidity swept, bullish reversal signal) or BSL ↓ (buy-side liquidity swept, bearish reversal signal). A
  close beyond the level is treated as a breakout, not a sweep.

  Fair Value Gaps

  Three-bar imbalances drawn as soft, low-opacity zones in a distinct hue from order blocks. Auto-mitigate when filled.

  BOS / CHoCH Detection

  Continuation breaks (BOS) vs character changes (CHoCH = BOS against the current HTF bias). Surfaced in the dashboard
  rather than as chart clutter.

  Dashboard

  A compact top-right table in TradingView native dark palette shows at a glance:

  - Active HTF and alignment filter state
  - HTF Bias and Structure label (HH+HL / LH+LL / Ranging)
  - Most recent structure event (BOS or CHoCH)
  - Most recent sweep (SSL or BSL)
  - Live count of active order blocks and FVGs

  Position is configurable across 5 anchor points.

  Alignment Filter

  When enabled (default), only signals that align with HTF bias are displayed and alerted on. Bullish sweeps require
  Bullish HTF; bearish sweeps require Bearish HTF; FVGs are hidden if they contradict bias. Toggle off to see all
  signals raw.

  Settings

  - HTF auto-selection or manual override (30m / 1H / 4H / D / W)
  - HTF pivot length (default 10)
  - LTF pivot length for BOS and OB anchor (default 5)
  - Max OBs per side, max FVGs per side
  - Box forward extension in bars
  - Auto-mitigation toggles for OBs and FVGs
  - 4 built-in alerts: bullish sweep, bearish sweep, bullish CHoCH, bearish CHoCH

  How to use

  1. Apply on any timeframe; the HTF is auto-selected
  2. Wait for HTF Bias to read Bullish or Bearish (skip Neutral conditions)
  3. Watch the chart for SSL or BSL sweeps that align with bias
  4. Use mitigated order blocks or FVGs in the rejection zone as entry triggers on a pullback
  5. Stop above the swept high (BSL) or below the swept low (SSL); target the next opposing liquidity pool

  Scope and limitations

  This is a signal-detection and bias-alignment tool, not a buy/sell system. It draws zones and surfaces context; entry
  timing, stop placement, and position sizing are the trader's job. The HTF bias engine uses lookahead_off and confirmed
   pivots, so it does not repaint after the HTF bar closes — however, pivots inherently form pivot_length bars after the
   actual swing, which is a property of the math, not a bug.

  Pine v6. Works across stocks, futures, FX, and crypto on timeframes from 1m to weekly.

  Headers to bold: What it does, HTF Bias Engine, Order Blocks, Liquidity Sweeps, Fair Value Gaps, BOS / CHoCH
  Detection, Dashboard, Alignment Filter, Settings, How to use, Scope and limitations.

## Source Code

````pine
//@version=6
indicator("RBD Smart Money + Auction Map",
     overlay            = true,
     max_boxes_count    = 500,
     max_lines_count    = 500,
     max_labels_count   = 500)

// ══════════════════════════════════════════════════════════════════
// ▸ PALETTE
// ══════════════════════════════════════════════════════════════════
C_BULL       = #26a69a
C_BEAR       = #ef5350
C_FVG_BULL   = #42a5f5
C_FVG_BEAR   = #ab47bc
C_DEMAND     = #00bcd4
C_SUPPLY     = #e91e63
C_BREAKER    = #ff9800
C_NEUTRAL    = #787b86
C_DASH_BG    = #131722
C_DASH_HEAD  = #1e222d
C_DASH_BORD  = #363a45
C_TXT_PRI    = #d1d4dc
C_TXT_SEC    = #787b86

// ══════════════════════════════════════════════════════════════════
// ▸ INPUTS
// ══════════════════════════════════════════════════════════════════
GRP_HTF   = "HTF Bias Engine"
GRP_OB    = "Order Blocks"
GRP_SWEEP = "Liquidity Sweeps"
GRP_FVG   = "Fair Value Gaps"
GRP_SD    = "Supply / Demand Zones"
GRP_DASH  = "Dashboard"

i_htfMode      = input.string("Auto", "HTF Selection", options=["Auto","30","60","240","D","W"], group=GRP_HTF,
     tooltip="Auto mapping: 1m/3m → 1H bias (scalp). 5m → 4H bias (day-trade). 15m/30m/1H → 4H bias. 2H/4H → D bias. D → W bias.")
i_pivotLen     = input.int(10, "HTF Pivot Length", minval=2, group=GRP_HTF)
i_alignFilter  = input.bool(false, "Align LTF signals with HTF bias", group=GRP_HTF,
     tooltip="OFF (default) = all FVGs and sweeps show. ON = only signals aligned with HTF bias.")

i_showOB       = input.bool(true, "Show Order Blocks", group=GRP_OB)
i_obCount      = input.int(3, "Max OBs per side", minval=1, maxval=20, group=GRP_OB)
i_obExtend     = input.int(50, "Box extension (bars)", minval=10, maxval=200, group=GRP_OB)
i_ltfPivLen    = input.int(5, "LTF Pivot Length (BOS / OB anchor)", minval=2, group=GRP_OB)
i_obLifecycle  = input.bool(true, "Track OB lifecycle (FRESH → MB → BB)", group=GRP_OB,
     tooltip="ON: order blocks convert to Mitigation Block when tested, Breaker Block when broken (polarity flips). OFF: delete on first touch.")
i_showLabels   = input.bool(true, "Show zone type labels", group=GRP_OB,
     tooltip="OB+/OB- = fresh order block · MB+/MB- = mitigation block · BB+/BB- = breaker block · Dem/Sup = supply/demand zone.")

i_showSweeps    = input.bool(true,  "Show Liquidity Sweeps (clean stop-hunts only)", group=GRP_SWEEP)
i_sweepPivLen   = input.int (10,    "Pivot length (each side)",       minval=3,   maxval=50, group=GRP_SWEEP,
     tooltip="Bars required on each side to confirm a swing point. The most recent confirmed pivot high/low is treated as the resistance/support being swept. Higher = stricter, only major swings count.")
i_sweepMinPen   = input.float(0.1,  "Min wick penetration (× ATR)",   minval=0.0, step=0.05,  group=GRP_SWEEP,
     tooltip="Wick must push beyond the level by at least this × ATR(20). Filters out 1-tick pokes.")
i_pinRatio      = input.float(2.0,  "Pin bar: wick : body ratio",     minval=1.0, step=0.1,   group=GRP_SWEEP,
     tooltip="Sweep-side wick must be at least N× the body length to qualify as a pin bar.")
i_engulfingOK   = input.bool(true,  "Allow engulfing pattern as sweep", group=GRP_SWEEP,
     tooltip="Bar body engulfs prior bar's body in opposite direction = qualifies even if not a pin bar shape.")

i_showFVG      = input.bool(true, "Show Fair Value Gaps", group=GRP_FVG)
i_fvgCount     = input.int(10, "Max unfilled FVGs (total)", minval=1, maxval=40, group=GRP_FVG,
     tooltip="Total unfilled FVGs visible on chart (combined bullish + bearish), not per side.")
i_mitigateFVG  = input.bool(true, "Auto-remove fully-filled FVGs", group=GRP_FVG,
     tooltip="FVG is removed only when price completely fills the gap (penetrates top to bottom). Wicks that just touch the FVG leave it visible.")

i_showSD       = input.bool(true, "Show Supply / Demand Zones", group=GRP_SD)
i_sdAutoTune   = input.bool(true, "Auto-tune thresholds by timeframe", group=GRP_SD,
     tooltip="ON (default): base/impulse thresholds scale with chart TF (looser on 1m–5m, stricter on 1H+). OFF: use the manual values below.")
i_sdBaseATR    = input.float(0.6, "Manual: Base max range (× ATR)", minval=0.1, step=0.1, group=GRP_SD,
     tooltip="Only used if Auto-tune is OFF.")
i_sdImpATR     = input.float(1.5, "Manual: Impulse min body (× ATR)", minval=0.5, step=0.1, group=GRP_SD,
     tooltip="Only used if Auto-tune is OFF.")
i_sdCount      = input.int(5, "Max S/D zones per side", minval=1, maxval=20, group=GRP_SD)
i_sdExtend     = input.int(40, "S/D box extension (bars)", minval=10, maxval=200, group=GRP_SD)
i_sdMitigate   = input.bool(true, "Auto-remove S/D on touch", group=GRP_SD)

i_showDash     = input.bool(true, "Show Dashboard", group=GRP_DASH)
i_dashPos      = input.string("top_right", "Position",
     options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=GRP_DASH)

// ══════════════════════════════════════════════════════════════════
// ▸ HTF AUTO-MAPPING
// ══════════════════════════════════════════════════════════════════
autoHTF() =>
    string out = "240"
    string cur = timeframe.period
    if cur == "1" or cur == "3"
        out := "60"
    else if cur == "5"
        out := "240"
    else if cur == "15"
        out := "240"
    else if cur == "30"
        out := "240"
    else if cur == "60"
        out := "240"
    else if cur == "120" or cur == "240"
        out := "D"
    else if cur == "D"
        out := "W"
    else
        sec = timeframe.in_seconds(timeframe.period)
        out := sec <= 180 ? "60" : sec <= 3600 ? "240" : sec <= 14400 ? "D" : "W"
    out

htfTF = i_htfMode == "Auto" ? autoHTF() : i_htfMode

// ══════════════════════════════════════════════════════════════════
// ▸ S/D AUTO-TUNE
// ══════════════════════════════════════════════════════════════════
f_autoBaseATR() =>
    sec = timeframe.in_seconds(timeframe.period)
    sec <= 180    ? 0.9  :
     sec <= 300   ? 0.85 :
     sec <= 900   ? 0.8  :
     sec <= 1800  ? 0.7  :
     sec <= 3600  ? 0.6  :
     sec <= 14400 ? 0.5  :
     0.4

f_autoImpATR() =>
    sec = timeframe.in_seconds(timeframe.period)
    sec <= 180    ? 1.0  :
     sec <= 300   ? 1.1  :
     sec <= 900   ? 1.2  :
     sec <= 1800  ? 1.3  :
     sec <= 3600  ? 1.5  :
     sec <= 14400 ? 1.7  :
     2.0

effBaseATR = i_sdAutoTune ? f_autoBaseATR() : i_sdBaseATR
effImpATR  = i_sdAutoTune ? f_autoImpATR()  : i_sdImpATR

// ══════════════════════════════════════════════════════════════════
// ▸ HTF SWING DETECTION + BIAS
// ══════════════════════════════════════════════════════════════════
htfPivHigh = request.security(syminfo.tickerid, htfTF, ta.pivothigh(i_pivotLen, i_pivotLen), lookahead=barmerge.lookahead_off)
htfPivLow  = request.security(syminfo.tickerid, htfTF, ta.pivotlow (i_pivotLen, i_pivotLen), lookahead=barmerge.lookahead_off)

var float pH1 = na, var float pH2 = na, var float pH3 = na
var float pL1 = na, var float pL2 = na, var float pL3 = na

newHigh = not na(htfPivHigh) and (na(pH1) or htfPivHigh != pH1)
newLow  = not na(htfPivLow)  and (na(pL1) or htfPivLow  != pL1)

if newHigh
    pH3 := pH2
    pH2 := pH1
    pH1 := htfPivHigh
if newLow
    pL3 := pL2
    pL2 := pL1
    pL1 := htfPivLow

var string biasStr   = "Neutral"
var string structStr = "Ranging"
var color  biasColor = color.new(C_NEUTRAL, 0)

haveSwings = not na(pH1) and not na(pH2) and not na(pL1) and not na(pL2)
if haveSwings
    if pH1 > pH2 and pL1 > pL2
        biasStr   := "Bullish"
        structStr := "HH + HL"
        biasColor := color.new(C_BULL, 0)
    else if pH1 < pH2 and pL1 < pL2
        biasStr   := "Bearish"
        structStr := "LH + LL"
        biasColor := color.new(C_BEAR, 0)
    else
        biasStr   := "Neutral"
        structStr := "Ranging"
        biasColor := color.new(C_NEUTRAL, 0)

// ══════════════════════════════════════════════════════════════════
// ▸ LTF STRUCTURE — BOS / CHoCH
// ══════════════════════════════════════════════════════════════════
ltfPivH = ta.pivothigh(i_ltfPivLen, i_ltfPivLen)
ltfPivL = ta.pivotlow (i_ltfPivLen, i_ltfPivLen)

var float lastSwingHigh = na
var float lastSwingLow  = na

if not na(ltfPivH)
    lastSwingHigh := ltfPivH
if not na(ltfPivL)
    lastSwingLow := ltfPivL

bullBOS_raw = ta.crossover (close, lastSwingHigh)
bearBOS_raw = ta.crossunder(close, lastSwingLow)
bullBOS = not na(lastSwingHigh) and bullBOS_raw
bearBOS = not na(lastSwingLow)  and bearBOS_raw

isCHoCHBull = bullBOS and biasStr == "Bearish"
isCHoCHBear = bearBOS and biasStr == "Bullish"

var string lastEvent  = "—"
var color  lastEventCol = color.new(C_NEUTRAL, 0)
var int    lastEventBar = na
if isCHoCHBull
    lastEvent := "Bullish CHoCH"
    lastEventCol := color.new(C_BULL, 0)
    lastEventBar := bar_index
else if isCHoCHBear
    lastEvent := "Bearish CHoCH"
    lastEventCol := color.new(C_BEAR, 0)
    lastEventBar := bar_index
else if bullBOS
    lastEvent := "Bullish BOS"
    lastEventCol := color.new(C_BULL, 0)
    lastEventBar := bar_index
else if bearBOS
    lastEvent := "Bearish BOS"
    lastEventCol := color.new(C_BEAR, 0)
    lastEventBar := bar_index

// ══════════════════════════════════════════════════════════════════
// ▸ ORDER BLOCK LIFECYCLE — FRESH(0) → MB(1) → BB(2)
// ══════════════════════════════════════════════════════════════════
var array<box> bullOBs       = array.new<box>()
var array<int> bullOBStates  = array.new<int>()
var array<box> bearOBs       = array.new<box>()
var array<int> bearOBStates  = array.new<int>()

f_lastDownIdx() =>
    int idx = -1
    for i = 1 to 30
        if close[i] < open[i]
            idx := i
            break
    idx

f_lastUpIdx() =>
    int idx = -1
    for i = 1 to 30
        if close[i] > open[i]
            idx := i
            break
    idx

f_obText(int state, bool isBull) =>
    state == 0 ? (isBull ? "OB+" : "OB-") :
     state == 1 ? (isBull ? "MB+" : "MB-") :
     (isBull ? "BB-" : "BB+")

f_obBg(int state, bool isBull) =>
    state == 0 ? (isBull ? color.new(C_BULL, 90) : color.new(C_BEAR, 90)) :
     state == 1 ? (isBull ? color.new(C_BULL, 94) : color.new(C_BEAR, 94)) :
     color.new(C_BREAKER, 90)

f_obBor(int state, bool isBull) =>
    state == 0 ? (isBull ? color.new(C_BULL, 60) : color.new(C_BEAR, 60)) :
     state == 1 ? (isBull ? color.new(C_BULL, 75) : color.new(C_BEAR, 75)) :
     color.new(C_BREAKER, 50)

f_obTxtCol(int state, bool isBull) =>
    state == 2 ? color.new(C_BREAKER, 0) :
     isBull ? color.new(C_BULL, 0) : color.new(C_BEAR, 0)

if i_showOB and i_obLifecycle
    nBull = array.size(bullOBs)
    if nBull > 0
        for i = nBull - 1 to 0
            bx = array.get(bullOBs, i)
            st = array.get(bullOBStates, i)
            if st < 2
                top = box.get_top(bx)
                bot = box.get_bottom(bx)
                newSt = st
                if close < bot
                    newSt := 2
                else if st == 0 and low <= top
                    newSt := 1
                if newSt != st
                    array.set(bullOBStates, i, newSt)
                    box.set_bgcolor(bx, f_obBg(newSt, true))
                    box.set_border_color(bx, f_obBor(newSt, true))
                    if i_showLabels
                        box.set_text(bx, f_obText(newSt, true))
                        box.set_text_color(bx, f_obTxtCol(newSt, true))

    nBear = array.size(bearOBs)
    if nBear > 0
        for i = nBear - 1 to 0
            bx = array.get(bearOBs, i)
            st = array.get(bearOBStates, i)
            if st < 2
                top = box.get_top(bx)
                bot = box.get_bottom(bx)
                newSt = st
                if close > top
                    newSt := 2
                else if st == 0 and high >= bot
                    newSt := 1
                if newSt != st
                    array.set(bearOBStates, i, newSt)
                    box.set_bgcolor(bx, f_obBg(newSt, false))
                    box.set_border_color(bx, f_obBor(newSt, false))
                    if i_showLabels
                        box.set_text(bx, f_obText(newSt, false))
                        box.set_text_color(bx, f_obTxtCol(newSt, false))

if i_showOB and not i_obLifecycle
    nBull = array.size(bullOBs)
    if nBull > 0
        for i = nBull - 1 to 0
            bx = array.get(bullOBs, i)
            if low <= box.get_top(bx)
                box.delete(bx)
                array.remove(bullOBs, i)
                array.remove(bullOBStates, i)
    nBear = array.size(bearOBs)
    if nBear > 0
        for i = nBear - 1 to 0
            bx = array.get(bearOBs, i)
            if high >= box.get_bottom(bx)
                box.delete(bx)
                array.remove(bearOBs, i)
                array.remove(bearOBStates, i)

if i_showOB and bullBOS
    idx = f_lastDownIdx()
    if idx > 0
        labelText = i_showLabels ? f_obText(0, true) : ""
        bx = box.new(left=bar_index[idx], top=high[idx], right=bar_index + i_obExtend, bottom=low[idx],
             bgcolor=f_obBg(0, true), border_color=f_obBor(0, true), border_width=1,
             text=labelText, text_color=f_obTxtCol(0, true), text_size=size.tiny,
             text_halign=text.align_left, text_valign=text.align_top)
        array.push(bullOBs, bx)
        array.push(bullOBStates, 0)
        if array.size(bullOBs) > i_obCount
            box.delete(array.shift(bullOBs))
            array.shift(bullOBStates)

if i_showOB and bearBOS
    idx = f_lastUpIdx()
    if idx > 0
        labelText = i_showLabels ? f_obText(0, false) : ""
        bx = box.new(left=bar_index[idx], top=high[idx], right=bar_index + i_obExtend, bottom=low[idx],
             bgcolor=f_obBg(0, false), border_color=f_obBor(0, false), border_width=1,
             text=labelText, text_color=f_obTxtCol(0, false), text_size=size.tiny,
             text_halign=text.align_left, text_valign=text.align_top)
        array.push(bearOBs, bx)
        array.push(bearOBStates, 0)
        if array.size(bearOBs) > i_obCount
            box.delete(array.shift(bearOBs))
            array.shift(bearOBStates)

// ══════════════════════════════════════════════════════════════════
// ▸ LIQUIDITY SWEEPS — clean stop-hunts at confirmed resistance / support
//   Reference = most recent CONFIRMED PIVOT high/low (price actually reversed there).
//   Requires:
//     1. Wick pierces the pivot (= true resistance / support)
//     2. Penetration depth ≥ min × ATR (no 1-tick pokes)
//     3. Close back on original side of the pivot
//     4. Bar shape: pin bar (wick ≥ N× body) OR engulfing reversal
// ══════════════════════════════════════════════════════════════════
sweepPivH_raw = ta.pivothigh(i_sweepPivLen, i_sweepPivLen)
sweepPivL_raw = ta.pivotlow (i_sweepPivLen, i_sweepPivLen)

var float sweepRefHigh = na
var float sweepRefLow  = na
if not na(sweepPivH_raw)
    sweepRefHigh := sweepPivH_raw
if not na(sweepPivL_raw)
    sweepRefLow := sweepPivL_raw

sweepAtr  = ta.atr(20)
sweepBody = math.abs(close - open)
bodyOrMin = sweepBody > 0 ? sweepBody : syminfo.mintick
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

isPinBull = lowerWick >= i_pinRatio * bodyOrMin
isPinBear = upperWick >= i_pinRatio * bodyOrMin

isEngulfBull = i_engulfingOK and close > open and close[1] < open[1] and close >= open[1]
isEngulfBear = i_engulfingOK and close < open and close[1] > open[1] and close <= open[1]

penDepthBull = na(sweepRefLow)  ? na : sweepRefLow  - low
penDepthBear = na(sweepRefHigh) ? na : high - sweepRefHigh

rawBullSweep = i_showSweeps and not na(sweepRefLow)  and not na(sweepAtr) and low  < sweepRefLow  and close > sweepRefLow  and penDepthBull >= i_sweepMinPen * sweepAtr and (isPinBull or isEngulfBull)
rawBearSweep = i_showSweeps and not na(sweepRefHigh) and not na(sweepAtr) and high > sweepRefHigh and close < sweepRefHigh and penDepthBear >= i_sweepMinPen * sweepAtr and (isPinBear or isEngulfBear)

bullSweep = rawBullSweep and (not i_alignFilter or biasStr == "Bullish")
bearSweep = rawBearSweep and (not i_alignFilter or biasStr == "Bearish")

plotshape(bullSweep, "Bull Sweep", shape.circle, location.belowbar, color.new(C_BULL, 20), size=size.tiny)
plotshape(bearSweep, "Bear Sweep", shape.circle, location.abovebar, color.new(C_BEAR, 20), size=size.tiny)

var string lastSweep    = "—"
var color  lastSweepCol = color.new(C_NEUTRAL, 0)
if bullSweep
    lastSweep    := "SSL ↑"
    lastSweepCol := color.new(C_BULL, 0)
else if bearSweep
    lastSweep    := "BSL ↓"
    lastSweepCol := color.new(C_BEAR, 0)

// ══════════════════════════════════════════════════════════════════
// ▸ FAIR VALUE GAPS — unified total count, full-fill mitigation
// ══════════════════════════════════════════════════════════════════
var array<box> fvgs     = array.new<box>()
var array<int> fvgKinds = array.new<int>()

bullFVG = i_showFVG and low > high[2]
bearFVG = i_showFVG and high < low[2]

showBullFVG = bullFVG and (not i_alignFilter or biasStr != "Bearish")
showBearFVG = bearFVG and (not i_alignFilter or biasStr != "Bullish")

if showBullFVG
    bx = box.new(left=bar_index[2], top=low, right=bar_index + i_obExtend, bottom=high[2],
         bgcolor=color.new(C_FVG_BULL, 94), border_color=color.new(C_FVG_BULL, 80), border_width=1)
    array.push(fvgs, bx)
    array.push(fvgKinds, 0)
    if array.size(fvgs) > i_fvgCount
        box.delete(array.shift(fvgs))
        array.shift(fvgKinds)

if showBearFVG
    bx = box.new(left=bar_index[2], top=low[2], right=bar_index + i_obExtend, bottom=high,
         bgcolor=color.new(C_FVG_BEAR, 94), border_color=color.new(C_FVG_BEAR, 80), border_width=1)
    array.push(fvgs, bx)
    array.push(fvgKinds, 1)
    if array.size(fvgs) > i_fvgCount
        box.delete(array.shift(fvgs))
        array.shift(fvgKinds)

if i_showFVG and i_mitigateFVG
    nF = array.size(fvgs)
    if nF > 0
        for i = nF - 1 to 0
            bx = array.get(fvgs, i)
            kind = array.get(fvgKinds, i)
            filled = kind == 0 ? low <= box.get_bottom(bx) : high >= box.get_top(bx)
            if filled
                box.delete(bx)
                array.remove(fvgs, i)
                array.remove(fvgKinds, i)

// ══════════════════════════════════════════════════════════════════
// ▸ SUPPLY / DEMAND ZONES
// ══════════════════════════════════════════════════════════════════
var array<box> demandZones = array.new<box>()
var array<box> supplyZones = array.new<box>()

atrVal = ta.atr(20)

baseRange   = high[1] - low[1]
impulseBody = math.abs(close - open)
priorDir    = close[2] - close[5]

isBase    = i_showSD and not na(baseRange) and not na(atrVal) and atrVal > 0 and baseRange <= effBaseATR * atrVal
impulseUp = isBase and close > open and impulseBody >= effImpATR * atrVal
impulseDn = isBase and close < open and impulseBody >= effImpATR * atrVal

if i_showSD and i_sdMitigate
    nDem = array.size(demandZones)
    if nDem > 0
        for i = nDem - 1 to 0
            bx = array.get(demandZones, i)
            if low <= box.get_top(bx)
                box.delete(bx)
                array.remove(demandZones, i)
    nSup = array.size(supplyZones)
    if nSup > 0
        for i = nSup - 1 to 0
            bx = array.get(supplyZones, i)
            if high >= box.get_bottom(bx)
                box.delete(bx)
                array.remove(supplyZones, i)

if impulseUp
    sdTxt = i_showLabels ? (priorDir < 0 ? "Dem (DBR)" : "Dem (RBR)") : ""
    bx = box.new(left=bar_index[1], top=high[1], right=bar_index + i_sdExtend, bottom=low[1],
         bgcolor=color.new(C_DEMAND, 90), border_color=color.new(C_DEMAND, 60), border_width=1,
         text=sdTxt, text_color=color.new(C_DEMAND, 0), text_size=size.tiny,
         text_halign=text.align_left, text_valign=text.align_top)
    array.push(demandZones, bx)
    if array.size(demandZones) > i_sdCount
        box.delete(array.shift(demandZones))

if impulseDn
    sdTxt = i_showLabels ? (priorDir > 0 ? "Sup (RBD)" : "Sup (DBD)") : ""
    bx = box.new(left=bar_index[1], top=high[1], right=bar_index + i_sdExtend, bottom=low[1],
         bgcolor=color.new(C_SUPPLY, 90), border_color=color.new(C_SUPPLY, 60), border_width=1,
         text=sdTxt, text_color=color.new(C_SUPPLY, 0), text_size=size.tiny,
         text_halign=text.align_left, text_valign=text.align_top)
    array.push(supplyZones, bx)
    if array.size(supplyZones) > i_sdCount
        box.delete(array.shift(supplyZones))

// ══════════════════════════════════════════════════════════════════
// ▸ DASHBOARD
// ══════════════════════════════════════════════════════════════════
dashPos() =>
    i_dashPos == "top_left"      ? position.top_left      :
     i_dashPos == "bottom_right" ? position.bottom_right  :
     i_dashPos == "bottom_left"  ? position.bottom_left   :
     i_dashPos == "middle_right" ? position.middle_right  :
     position.top_right

var table dash = table.new(dashPos(), 2, 7,
     bgcolor      = color.new(C_DASH_BG, 25),
     border_width = 1,
     border_color = color.new(C_DASH_BORD, 30),
     frame_color  = color.new(C_DASH_BORD, 10),
     frame_width  = 1)

if i_showDash and barstate.islast
    obCount  = array.size(bullOBs)  + array.size(bearOBs)
    fvgCount = array.size(fvgs)
    sdCount  = array.size(demandZones) + array.size(supplyZones)

    table.cell(dash, 0, 0, "SMC  ·  " + htfTF, text_color=color.new(C_TXT_PRI, 0), bgcolor=color.new(C_DASH_HEAD, 20), text_size=size.small)
    table.cell(dash, 1, 0, i_alignFilter ? "ALIGNED" : "ALL",
         text_color = i_alignFilter ? color.new(C_BULL, 0) : color.new(C_NEUTRAL, 0),
         bgcolor    = color.new(C_DASH_HEAD, 20), text_size=size.tiny)

    table.cell(dash, 0, 1, "Bias",      text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 1, biasStr,     text_color=biasColor,                text_size=size.small)

    table.cell(dash, 0, 2, "Structure", text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 2, structStr,   text_color=biasColor,                text_size=size.small)

    table.cell(dash, 0, 3, "Event",     text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 3, lastEvent,   text_color=lastEventCol,             text_size=size.small)

    table.cell(dash, 0, 4, "Sweep",     text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 4, lastSweep,   text_color=lastSweepCol,             text_size=size.small)

    table.cell(dash, 0, 5, "OB/FVG",    text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 5, str.tostring(obCount) + " · " + str.tostring(fvgCount) + " unfilled",
         text_color=color.new(C_TXT_PRI, 0), text_size=size.tiny)

    table.cell(dash, 0, 6, "S/D",       text_color=color.new(C_TXT_SEC, 0), text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(sdCount) + " · " + str.tostring(effBaseATR, "0.00") + "/" + str.tostring(effImpATR, "0.00"),
         text_color=color.new(C_TXT_PRI, 0), text_size=size.tiny)

// ══════════════════════════════════════════════════════════════════
// ▸ ALERTS
// ══════════════════════════════════════════════════════════════════
alertcondition(bullSweep,   "Bullish Liquidity Sweep", "Clean SSL sweep at confirmed support")
alertcondition(bearSweep,   "Bearish Liquidity Sweep", "Clean BSL sweep at confirmed resistance")
alertcondition(isCHoCHBull, "Bullish CHoCH",           "Change of Character to bullish")
alertcondition(isCHoCHBear, "Bearish CHoCH",           "Change of Character to bearish")
````
