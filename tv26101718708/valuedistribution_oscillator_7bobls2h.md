# Value-Distribution Oscillator

- url: https://www.tradingview.com/script/7bobLS2h-Value-Distribution-Oscillator/
- type: indicator
- pine_id: PUB;14f034124aa748269e6116bc98e187e9
- version: 2.0

## Description

Value-Distribution Oscillator

Overview

A volume-by-price value map expressed as a bounded pane oscillator. It rolls a decaying volume distribution of recent trade, finds the Point of Control (most-traded price) and the Value Area, then plots where price sits inside that value structure on a fixed −50 / +50 scale: 0 = at the POC (fair value), ±25 = the value-area edges (VAH / VAL), ±50 = stretched beyond the developed range. It is a study of acceptance and location — not a directional signal.

Why these parts are ONE tool (mashup rationale)

A volume profile is an overlay that shows where value is; it can't give you, as a single number, how far price has travelled from value or whether that travel reverts. This chains: a decaying distribution builds the map → a position transform turns price into one bounded location reading → a fade flag fires only when price is stretched into the tails and turning back → a calibration harness tests whether stretched-and-reverting readings actually return toward the POC on your instrument. Remove a part and the chain breaks: a profile is just a picture, the transform alone is just a number, the fade alone is an untested claim.

How it works

Each confirmed bar's volume is distributed across a price grid (body weighted heavier than wicks) and the whole grid decays geometrically, so the map tracks recent trade and re-anchors when price leaves its range. The POC is the heaviest level; the Value Area grows outward from the POC to the chosen volume share; the transform maps price piecewise-linearly (POC→0, VAH/VAL→±25, extremes→±50). The harness logs each stretched fade and checks a ≥ k×ATR move back toward the POC a fixed horizon later.

How to use

Read location: near 0 = fair value; the ±25 band = the edge of value; beyond ±40 = stretched into the tails, where reversion setups have context and breakouts that hold signal value migration. Then read the Edge row — fades in the tails only earn their keep if they beat the base rate. Context, never a standalone trigger.

Originality

The POC / Value-Area concept is public (credited below); the original work is the assembly — a decaying-grid distribution, the price-into-value position transform that turns a profile into a series, and the forward base-rate calibration. It's the pane-oscillator counterpart to a volume profile, not a re-skin of one.

Concept credit

Market / Volume Profile, Point of Control and Value-Area framing — J. Peter Steidlmayer and the CBOT Market Profile tradition; value-area / acceptance reading developed further by practitioners such as James Dalton. Implementation, transform and harness are this script's own.

Honesty / limitations

The distribution uses bar ranges, not exchange price-by-price prints or tick data — a probabilistic approximation. The grid decays, so it's a recent-trade view, not a session-anchored profile. Edge figures are in-sample, close-to-close, overlapping windows, no costs — descriptive context, not a backtest. Nothing here predicts direction.

Disclaimer

Research / educational only. NOT financial advice; no guarantee of profitability. Indicators describe past behaviour. Trading carries risk of loss. Test out-of-sample. The author accepts no liability.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// © Market_Logic_India                                                       MPL-2.0
// VALUE-DISTRIBUTION OSCILLATOR                                                           v1.0
// ────────────────────────────────────────────────────────────────────────────────────────────
// OVERVIEW
//   A volume-by-price value map expressed as a bounded pane oscillator. It rolls a decaying
//   volume distribution of recent trade, finds the Point of Control (most-traded price) and the
//   Value Area, then plots WHERE PRICE SITS inside that developing value structure on a fixed
//   -50 / +50 scale. 0 = at the POC (fair value); +/-25 = the value-area edges (VAH / VAL);
//   +/-50 = stretched beyond the developed range. It is an analytical study of acceptance and
//   location - not a directional signal and not a strategy.
//
// WHAT MAKES IT DIFFERENT  (why these parts are ONE tool, not a profile plus an oscillator)
//   A volume profile is an overlay that tells you WHERE value is; it cannot tell you, in a single
//   normalised number, how far price has travelled away from that value or whether such travel
//   has historically snapped back. This script chains four parts to answer exactly that:
//     - A DECAYING VOLUME DISTRIBUTION builds the value map (POC, Value Area, extremes) from the
//       same OHLCV every profile uses, but weighted to recent trade so the map stays current.
//     - A POSITION TRANSFORM turns the raw price into one bounded reading of location relative to
//       POC and the value-area edges - the thing a profile overlay can't give you as a series.
//     - A FADE flag arms only when price is stretched beyond the value area (|reading| high) and
//       rolling back toward it - turning "price left value" into a concrete, located event.
//     - The CALIBRATION HARNESS then tests, on YOUR instrument, whether stretched-and-reverting
//       readings actually return toward the POC - reporting Edge vs the unconditional base rate.
//   A profile without the transform is just a picture; the transform without the fade is just a
//   location number; the fade without calibration is an untested assertion. Chained, they answer
//   one question: is price meaningfully away from value here, and has that reverted before?
//
// HOW IT WORKS
//   1. Each confirmed bar's volume is distributed across a price grid (body weighted heavier than
//      wicks), and the whole grid decays geometrically so the distribution tracks recent trade.
//      The grid re-anchors when price leaves its range.
//   2. The POC is the heaviest grid level; the Value Area is grown outward from the POC until it
//      holds the chosen share of total volume; VAH / VAL are its edges; the window high / low are
//      the extremes.
//   3. The position transform maps price piecewise-linearly: POC -> 0, VAH/VAL -> +/-25, extremes
//      -> +/-50.
//   4. The harness logs each stretched-and-reverting fade and checks a >= k x ATR move back toward
//      the POC a fixed horizon later.
//
// HOW TO USE
//   Read location first: near 0 price is at fair value; in the +/-25 band it is at the edge of
//   value; beyond +/-40 it is stretched into the tails, where mean-reversion setups have the most
//   context (and breakouts that hold there signal genuine value migration). The fade dots mark
//   stretched-and-turning moments. Then read the Edge row - a location read only earns its keep if
//   fades taken in the tails beat the base rate. Context, never a standalone trigger.
//
// UNIVERSAL ACROSS MARKETS  (configurable data source)
//   Price and volume are inputs, so it runs on any instrument and timeframe with volume. Defaults
//   target intraday index futures (e.g. NSE NIFTY). On assets with no real volume the distribution
//   degenerates - prefer a volume-bearing feed.
//
// CONCEPT CREDIT
//   Market / Volume Profile, Point of Control and Value-Area framing - J. Peter Steidlmayer and
//   the CBOT Market Profile tradition; value-area / acceptance reading - developed further by
//   practitioners such as James Dalton. The decaying-grid implementation, the position transform
//   and the calibration harness are this script's own work. Not affiliated with, nor endorsed by,
//   any third party; no third-party code is reused.
//
// HONESTY / LIMITATIONS
//   The distribution is built from bar ranges, not exchange price-by-price prints or tick data, so
//   it is a probabilistic approximation of where volume traded. The grid decays, so the value map
//   is a recent-trade view, not a session-anchored profile. The Edge figures are in-sample, close-
//   to-close, with overlapping forward windows and no costs - descriptive context, not a verified
//   backtest. Nothing here predicts direction.
//
// DISCLAIMER
//   Research and educational tool only. NOT financial advice and NO guarantee of profitability or
//   accuracy. Indicators describe past behaviour; they do not predict the future. Trading carries
//   risk of loss. Test out-of-sample and make your own decisions. The author accepts no liability.
// ══════════════════════════════════════════════════════════════════════════════════════════════
indicator("Value-Distribution Oscillator", "ValueDist", overlay = false, max_labels_count = 120, max_bars_back = 700)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          INPUTS
// ═════════════════════════════════════════════════════════════════════════════════════════
// ── 01 · DATA & SOURCE ──────────────────────────────────────────────────────────────────
g0 = "01 · Data & source"
src    = input.source(close,  "Price source",  group = g0, tooltip = "Series mapped against the value distribution. Works on any symbol / market with volume.")
volSrc = input.source(volume, "Volume source", group = g0, tooltip = "Volume series the distribution is built from.")

// ── 02 · VALUE DISTRIBUTION ─────────────────────────────────────────────────────────────
g1 = "02 · Value distribution"
nBar   = input.int(200, "Lookback (bars)", minval = 30, maxval = 600, step = 10, group = g1, tooltip = "Effective memory of the decaying distribution. Higher = steadier value map; lower = reacts faster.")
nBins  = input.int(72,  "Resolution (bins)", minval = 24, maxval = 140, group = g1, tooltip = "Price levels in the grid. Higher = finer POC/VA but heavier.")
vaPctIn= input.float(70, "Value-area %", minval = 30, maxval = 95, step = 1, group = g1, tooltip = "Share of volume the value area must hold (70 is the Market-Profile convention).")
bodyBias = input.float(0.6, "Body weight", minval = 0.0, maxval = 1.0, step = 0.05, group = g1, tooltip = "How much of each bar's volume is placed in the open-close body vs spread across the wicks.")
padPct = input.float(0.03, "Range pad", minval = 0.0, maxval = 0.5, step = 0.01, group = g1, tooltip = "Extra room added above/below the window range when the grid re-anchors.")

// ── 03 · STRETCH & FADE ─────────────────────────────────────────────────────────────────
g2 = "03 · Stretch & fade"
oscSmooth = input.int(2, "Smoothing (EMA, 1 = off)", minval = 1, maxval = 20, group = g2)
extremeThr = input.float(40, "Stretched beyond (|reading|)", minval = 25, maxval = 50, step = 1, group = g2, tooltip = "A fade arms only when the reading is past this magnitude (deep in the tails) AND turning back toward value.")
showFade = input.bool(true, "Mark stretched fades", group = g2)

// ── 04 · CALIBRATION HARNESS ────────────────────────────────────────────────────────────
g4 = "04 · Calibration harness"
calibOn = input.bool(true, "Run calibration", group = g4, tooltip = "Logs every fade and, a fixed horizon later, checks whether price moved >= k x ATR back toward the POC. Reports Hit %, unconditional Base %, and Edge = Hit - Base.")
calHor  = input.int(10, "Forward horizon (bars)", minval = 2, maxval = 100, group = g4)
calMove = input.float(0.6, "Move threshold (x ATR)", minval = 0.1, step = 0.1, group = g4)
calAtrLen = input.int(14, "ATR length", minval = 1, group = g4)

// ── 05 · VISUAL STYLE ───────────────────────────────────────────────────────────────────
g5 = "05 · Visual style"
visStyle = input.string("Gradient area + glow", "Line style", options = ["Gradient area + glow","Histogram","Line"], group = g5)
colDisc  = input.color(#2ebd85, "Discount", inline = "cc", group = g5)
colPrem  = input.color(#f6465d, "Premium", inline = "cc", group = g5)
colMid   = input.color(#f7c948, "POC midline", group = g5)

// ── 06 · DASHBOARD & THEME ──────────────────────────────────────────────────────────────
g6 = "06 · Dashboard & theme"
showPanel = input.bool(true, "Show dashboard", group = g6)
panelPos  = input.string("Bottom Right", "Dashboard position", options = ["Bottom Left","Bottom Right","Top Left","Top Right","Middle Right"], group = g6)
themeOpt  = input.string("Auto (match chart)", "Theme", options = ["Auto (match chart)","Dark","Light"], group = g6)

float vaPct = vaPctIn / 100.0

// ═════════════════════════════════════════════════════════════════════════════════════════
//                          ENGINE · decaying volume-by-price grid
// ═════════════════════════════════════════════════════════════════════════════════════════
var float[] vbin = array.new_float(nBins, 0.0)
var float gLo = na
var float gHi = na
var float bw  = na

float qDecay = math.exp(-1.0 / math.max(1.0, float(nBar)))
float hh = ta.highest(high, nBar)
float ll = ta.lowest(low, nBar)

// distribute one bar's volume across the grid (body weighted heavier than wicks)
f_add(float[] g, float glo, float binw, int nb, float lo, float hi, float op, float cl, float vol, float bias) =>
    if not na(glo) and binw > 0 and vol > 0 and not na(lo) and not na(hi)
        int b0 = int(math.floor((lo - glo) / binw))
        int b1 = int(math.floor((hi - glo) / binw))
        b0 := math.max(0, math.min(nb - 1, b0))
        b1 := math.max(0, math.min(nb - 1, b1))
        int cnt = math.max(1, b1 - b0 + 1)
        float bodyLo = math.min(op, cl)
        float bodyHi = math.max(op, cl)
        float bodyV = vol * bias
        float wickEach = vol * (1.0 - bias) / cnt
        float bodyDen = math.max(binw, bodyHi - bodyLo)
        for b = b0 to b1
            float binLo = glo + b * binw
            float binHi = binLo + binw
            float ov = math.max(0.0, math.min(binHi, bodyHi) - math.max(binLo, bodyLo))
            array.set(g, b, array.get(g, b) + wickEach + bodyV * ov / bodyDen)

bool needRebuild = na(gLo) or na(bw) or src < gLo or src > gHi
if barstate.isconfirmed
    if needRebuild and not na(hh) and not na(ll) and hh > ll
        gLo := ll * (1.0 - padPct)
        gHi := hh * (1.0 + padPct)
        bw  := (gHi - gLo) / nBins
        array.fill(vbin, 0.0)
        int seedN = math.min(nBar - 1, bar_index)
        for b = seedN to 0
            float w = math.pow(qDecay, b)
            f_add(vbin, gLo, bw, nBins, low[b], high[b], open[b], close[b], nz(volSrc[b]) * w, bodyBias)
    else if not na(bw)
        for i = 0 to nBins - 1
            array.set(vbin, i, array.get(vbin, i) * qDecay)
        f_add(vbin, gLo, bw, nBins, low, high, open, close, nz(volSrc), bodyBias)

// POC + value-area extraction
f_va(float[] g, int nb, float pct) =>
    float total = array.sum(g)
    int poc = 0
    float pv = -1.0
    for i = 0 to nb - 1
        float v = array.get(g, i)
        if v > pv
            pv := v
            poc := i
    int lo = poc
    int hi = poc
    float acc = array.get(g, poc)
    float target = total * pct
    int steps = 0
    while acc < target and (lo > 0 or hi < nb - 1) and steps < nb
        float loV = lo > 0 ? array.get(g, lo - 1) : -1.0
        float hiV = hi < nb - 1 ? array.get(g, hi + 1) : -1.0
        if hiV >= loV
            hi += 1
            acc += math.max(0.0, hiV)
        else
            lo -= 1
            acc += math.max(0.0, loV)
        steps += 1
    [poc, lo, hi]

[pocB, loB, hiB] = f_va(vbin, nBins, vaPct)
float pocPx = not na(gLo) ? gLo + (pocB + 0.5) * bw : na
float vahPx = not na(gLo) ? gLo + (hiB + 1) * bw : na
float valPx = not na(gLo) ? gLo + loB * bw : na
float xhPx  = math.max(nz(hh, src), nz(vahPx, src))
float xlPx  = math.min(nz(ll, src), nz(valPx, src))

// ===== HVN / LVN structure + profile shape =====
hvnK = input.float(1.5, "HVN threshold (x avg bin)", minval = 1.0, step = 0.1, group = "Z2 · Advanced calibration")
lvnK = input.float(0.4, "LVN threshold (x avg bin)", minval = 0.05, maxval = 1.0, step = 0.05, group = "Z2 · Advanced calibration")
float vTot = array.sum(vbin)
float vAvg = nBins > 0 ? vTot / nBins : na
float nearHVN = na
float nearLVN = na
float dHVN = 1e20
float dLVN = 1e20
float loThird = 0.0
float midThird = 0.0
float hiThird = 0.0
if not na(gLo) and not na(bw) and not na(vAvg) and vAvg > 0
    for b = 0 to nBins - 1
        float bv = array.get(vbin, b)
        float bp = gLo + (b + 0.5) * bw
        if bv >= hvnK * vAvg and math.abs(bp - src) < dHVN
            dHVN := math.abs(bp - src)
            nearHVN := bp
        if bv <= lvnK * vAvg and math.abs(bp - src) < dLVN
            dLVN := math.abs(bp - src)
            nearLVN := bp
        if b < nBins / 3
            loThird += bv
        else if b < 2 * nBins / 3
            midThird += bv
        else
            hiThird += bv
int shapeCode = (loThird > hiThird * 1.3 and loThird > midThird) ? -1 : (hiThird > loThird * 1.3 and hiThird > midThird) ? 1 : 0

// position transform: POC -> 0, VAH/VAL -> +/-25, extremes -> +/-50
f_pos(float px, float poc, float vah, float val, float xh, float xl) =>
    float s = 0.0
    if na(px) or na(poc) or na(vah) or na(val)
        s := na
    else if px >= poc
        if px <= vah
            float sp = vah - poc
            s := sp > 0 ? 25.0 * (px - poc) / sp : 0.0
        else
            float sp = xh - vah
            s := sp > 0 ? 25.0 + 25.0 * (px - vah) / sp : 25.0
    else
        if px >= val
            float sp = poc - val
            s := sp > 0 ? -25.0 * (poc - px) / sp : 0.0
        else
            float sp = val - xl
            s := sp > 0 ? -25.0 - 25.0 * (val - px) / sp : -25.0
    na(s) ? na : math.max(-50.0, math.min(50.0, s))

float rawOsc = f_pos(src, pocPx, vahPx, valPx, xhPx, xlPx)
float oscEma = ta.ema(rawOsc, oscSmooth)
float osc = oscSmooth > 1 ? oscEma : rawOsc

// regime label
string loc = na(osc) ? "n/a" : osc > 25 ? "premium" : osc < -25 ? "discount" : "value"

// fade logic (stretched into the tails and rolling back toward value)
float turn = ta.ema(osc, 3)
bool fadeShort = osc >= extremeThr and turn < turn[1]
bool fadeLong  = osc <= -extremeThr and turn > turn[1]

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          PLOTS
// ═════════════════════════════════════════════════════════════════════════════════════════
plot(0.0, "POC glow", color = color.new(colMid, 80), linewidth = 6, display = display.pane)
hline(0, "POC", color = color.new(colMid, 0), linestyle = hline.style_solid)
hline(25, "VAH", color = color.new(colPrem, 55), linestyle = hline.style_dotted)
hline(-25, "VAL", color = color.new(colDisc, 55), linestyle = hline.style_dotted)
hline(50, "High extreme", color = color.new(colPrem, 70), linestyle = hline.style_dashed)
hline(-50, "Low extreme", color = color.new(colDisc, 70), linestyle = hline.style_dashed)

// gradient value zones
pPremEdge = plot(25.0, "z prem edge", color = na, display = display.none, editable = false)
pTop      = plot(50.0, "z top",       color = na, display = display.none, editable = false)
pDiscEdge = plot(-25.0,"z disc edge", color = na, display = display.none, editable = false)
pBot      = plot(-50.0,"z bot",       color = na, display = display.none, editable = false)
fill(pPremEdge, pTop, 50.0, 25.0, color.new(colPrem, 32), color.new(colPrem, 90), title = "Premium zone")
fill(pDiscEdge, pBot, -25.0, -50.0, color.new(colDisc, 90), color.new(colDisc, 32), title = "Discount zone")

// the oscillator line - glow / histogram / area
color oCol = na(osc) ? color.gray : osc > 0 ? colPrem : osc < 0 ? colDisc : color.new(color.gray, 0)
bool isArea = visStyle == "Gradient area + glow"
bool isHist = visStyle == "Histogram"
bool isLine = visStyle == "Line"
bool showLine = isArea or isLine
plot(showLine ? osc : na, "glow outer", color = color.new(oCol, 82), linewidth = 8, display = display.pane)
plot(showLine ? osc : na, "glow inner", color = color.new(oCol, 55), linewidth = 4, display = display.pane)
pMain = plot(showLine ? osc : na, "Position", color = oCol, linewidth = 2, display = display.pane)
plot(isHist ? osc : na, "Histogram", color = color.new(oCol, 25), style = plot.style_columns, display = display.pane)
pBase = plot(isArea ? 0.0 : na, "area base", color = na, display = display.none, editable = false)
fill(pMain, pBase, color = isArea ? color.new(oCol, 80) : na, title = "Area")

plotshape(showFade and fadeShort ? osc : na, "Fade short", shape.triangledown, location.absolute, color.new(colPrem, 0), size = size.tiny)
plotshape(showFade and fadeLong  ? osc : na, "Fade long",  shape.triangleup,   location.absolute, color.new(colDisc, 0), size = size.tiny)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                       CALIBRATION
// ═════════════════════════════════════════════════════════════════════════════════════════
float atrC = ta.atr(calAtrLen)
var int sigN = 0
var int hitN = 0
var int baseTot = 0
var int baseUp = 0
var int baseDn = 0
float fwdMv  = close - close[calHor]
float fwdAtr = atrC[calHor]
if calibOn and barstate.isconfirmed and bar_index > calHor and not na(fwdAtr) and fwdAtr > 0
    if fadeLong[calHor]
        sigN += 1
        if fwdMv >= calMove * fwdAtr
            hitN += 1
    if fadeShort[calHor]
        sigN += 1
        if -fwdMv >= calMove * fwdAtr
            hitN += 1
    baseTot += 1
    if fwdMv >= calMove * fwdAtr
        baseUp += 1
    if -fwdMv >= calMove * fwdAtr
        baseDn += 1

float hitP  = sigN > 0 ? hitN * 100.0 / sigN : na
float baseP = baseTot > 0 ? (baseUp + baseDn) * 100.0 / (2.0 * baseTot) : na
float edge  = (not na(hitP) and not na(baseP)) ? hitP - baseP : na

// ===== FORWARD-STATISTICS UPGRADE  (Wilson interval + significance) =====
f_wilson(float w, float n, float zc) =>
    float r = na
    if n > 0.0
        float pp = w / n
        float den = 1.0 + zc * zc / n
        r := zc * math.sqrt(pp * (1.0 - pp) / n + zc * zc / (4.0 * n * n)) / den
    r
float ciPct   = f_wilson(hitN, sigN, 1.96) * 100.0
bool  sigStar = sigN >= 20 and not na(hitP) and not na(baseP) and (hitP - ciPct) > baseP

// ===== CUSUM event-sampling + Wald-Wolfowitz runs-test + Wilson edge floor =====
cusumK = input.float(1.0, "CUSUM event threshold (x ATR)", minval = 0.1, step = 0.1, group = "Z2 · Advanced calibration")
var float csPos = 0.0
var float csNeg = 0.0
float csRet = close - close[1]
csPos := math.max(0.0, csPos + csRet)
csNeg := math.min(0.0, csNeg + csRet)
bool cusumEvt = not na(atrC) and atrC > 0 and (csPos >= cusumK * atrC or csNeg <= -cusumK * atrC)
if cusumEvt
    csPos := 0.0
    csNeg := 0.0
var array<int>   rtDir  = array.new<int>()
var array<int>   rtBar  = array.new<int>()
var array<float> rtEnt  = array.new<float>()
var array<float> rtAtr0 = array.new<float>()
var int rtPrev = 0
var int rtRuns = 0
var int rtW = 0
var int rtL = 0
if calibOn and barstate.isconfirmed and not na(atrC) and atrC > 0
    if cusumEvt and (fadeLong)
        rtDir.push(1), rtBar.push(bar_index), rtEnt.push(close), rtAtr0.push(atrC)
    if cusumEvt and (fadeShort)
        rtDir.push(-1), rtBar.push(bar_index), rtEnt.push(close), rtAtr0.push(atrC)
    if rtBar.size() > 0
        for i = rtBar.size() - 1 to 0
            if bar_index - rtBar.get(i) >= calHor
                float fwd = (close - rtEnt.get(i)) * rtDir.get(i)
                int wlab = fwd >= calMove * rtAtr0.get(i) ? 1 : -1
                rtRuns := rtPrev == 0 ? 1 : (wlab != rtPrev ? rtRuns + 1 : rtRuns)
                rtPrev := wlab
                rtW := wlab == 1 ? rtW + 1 : rtW
                rtL := wlab == -1 ? rtL + 1 : rtL
                rtDir.remove(i), rtBar.remove(i), rtEnt.remove(i), rtAtr0.remove(i)
float rtNn = rtW + rtL
float rtMu = rtNn > 0 ? 2.0 * rtW * rtL / rtNn + 1.0 : na
float rtVr = rtNn > 1 ? 2.0 * rtW * rtL * (2.0 * rtW * rtL - rtNn) / (rtNn * rtNn * (rtNn - 1.0)) : na
float runsZ = (not na(rtMu) and not na(rtVr) and rtVr > 0) ? (rtRuns - rtMu) / math.sqrt(rtVr) : na
float edgeLB = (not na(hitP) and not na(baseP) and not na(ciPct)) ? (hitP - ciPct) - baseP : na

// ═════════════════════════════════════════════════════════════════════════════════════════
//                              DASHBOARD  (theme-adaptive zebra)
// ═════════════════════════════════════════════════════════════════════════════════════════
f_lum(color cc) => na(cc) ? 0.0 : (0.299 * color.r(cc) + 0.587 * color.g(cc) + 0.114 * color.b(cc))
bool darkUI = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : f_lum(chart.bg_color) < 140
color panelBg = darkUI ? color.rgb(17, 22, 28)    : color.rgb(244, 246, 248)
color rowAlt  = darkUI ? color.rgb(25, 31, 39)    : color.rgb(232, 236, 240)
color txtMain = darkUI ? color.white              : color.rgb(16, 20, 24)
color txtSub  = darkUI ? color.rgb(154, 166, 178) : color.rgb(74, 82, 91)
color txtMut  = darkUI ? color.rgb(110, 120, 132) : color.rgb(140, 148, 156)
color frameC  = darkUI ? color.rgb(58, 70, 84)    : color.rgb(196, 204, 212)
color cPrem2  = darkUI ? colPrem : color.rgb(198, 40, 40)
color cDisc2  = darkUI ? colDisc : color.rgb(14, 124, 90)

f_pos2(string s) => s == "Bottom Left" ? position.bottom_left : s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Middle Right" ? position.middle_right : position.bottom_right
var table T = table.new(f_pos2(panelPos), 2, 10, frame_width = 1, border_width = 1)
f_row(int r, string k, string v, color vc, color rbg) =>
    table.cell(T, 0, r, k, text_color = txtSub, text_size = size.small, text_halign = text.align_left,  bgcolor = rbg)
    table.cell(T, 1, r, v, text_color = vc,     text_size = size.small, text_halign = text.align_right, bgcolor = rbg)

if showPanel and barstate.islast
    table.set_bgcolor(T, panelBg)
    table.set_frame_color(T, frameC)
    table.set_border_color(T, frameC)
    color hdr = color.new(osc > 0 ? colPrem : osc < 0 ? colDisc : color.gray, 0)
    table.cell(T, 0, 0, "VALUE DISTRIBUTION", text_color = f_lum(hdr) > 140 ? color.rgb(10,10,10) : color.white, bgcolor = hdr, text_size = size.small)
    table.cell(T, 1, 0, na(osc) ? "warming" : str.tostring(osc, "+0;-0"), text_color = f_lum(hdr) > 140 ? color.rgb(10,10,10) : color.white, bgcolor = hdr, text_size = size.small)
    f_row(1, "Location", loc, osc > 25 ? cPrem2 : osc < -25 ? cDisc2 : txtMain, rowAlt)
    f_row(2, "POC", na(pocPx) ? "warming" : str.tostring(pocPx, format.mintick), txtMain, panelBg)
    f_row(3, "Fades (n)", str.tostring(sigN), txtMain, rowAlt)
    f_row(4, "Hit %", sigN < 20 ? "warming" : str.tostring(hitP, "0") + "% +/-" + str.tostring(ciPct, "0"), sigN < 20 ? txtMut : txtMain, panelBg)
    f_row(5, "Edge", sigN < 20 or na(edge) ? "warming" : str.tostring(edge, "+0.0;-0.0") + " pts" + (sigStar ? " *" : ""), (sigN < 20 or na(edge)) ? txtMut : edge > 3 ? cDisc2 : edge < -3 ? cPrem2 : txtMain, rowAlt)
    f_row(6, "Runs-Z (streak)", na(runsZ) ? "warming" : str.tostring(runsZ, "0.0"), math.abs(nz(runsZ)) > 2.0 ? cPrem2 : txtMut, panelBg)
    f_row(7, "Edge floor", na(edgeLB) ? "warming" : str.tostring(edgeLB, "+0.0;-0.0"), na(edgeLB) ? txtMut : edgeLB > 0 ? cDisc2 : cPrem2, rowAlt)
    f_row(8, "Profile shape", shapeCode == 1 ? "P (top-heavy)" : shapeCode == -1 ? "b (bottom-heavy)" : "D (balanced)", txtMain, panelBg)
    f_row(9, "HVN / LVN", (na(nearHVN) ? "-" : str.tostring(nearHVN, format.mintick)) + " / " + (na(nearLVN) ? "-" : str.tostring(nearLVN, format.mintick)), txtMain, rowAlt)

// ═════════════════════════════════════════════════════════════════════════════════════════
//                                          ALERTS
// ═════════════════════════════════════════════════════════════════════════════════════════

// ===== IDENTITY STRIP  (name, symbol, timeframe) =====
showId = input.bool(true, "Show identity strip (name, symbol, timeframe)", group = "Z · Identity & exports")
var table idT = table.new(position.bottom_center, 1, 1, force_overlay = true)
if showId and barstate.islast
    color bgI  = chart.bg_color
    float lumI = na(bgI) ? 0.0 : color.r(bgI) * 0.299 + color.g(bgI) * 0.587 + color.b(bgI) * 0.114
    bool  dkI  = themeOpt == "Dark" ? true : themeOpt == "Light" ? false : (na(bgI) or lumI < 140)
    table.cell(idT, 0, 0, "Value-Distribution Oscillator   -   " + syminfo.ticker + "   -   " + timeframe.period, text_color = dkI ? color.new(#c8d0da, 10) : color.new(#2a2f37, 10), text_size = size.small, text_halign = text.align_center, bgcolor = color.new(color.gray, 100))

// ===== EXP_* EXPORTS  (Data Window, generic names for input.source) =====
showEXP = input.bool(true, "Emit EXP_* exports", group = "Z · Identity & exports")
color exC_ = color.new(color.gray, 100)
plot(showEXP ? (osc) : na, "EXP_Osc", color = exC_, display = display.data_window)
plot(showEXP ? (math.max(-100.0, math.min(100.0, osc * 2.0))) : na, "EXP_Bias", color = exC_, display = display.data_window)
plot(showEXP ? (osc > 25 ? 1 : osc < -25 ? -1 : 0) : na, "EXP_Zone", color = exC_, display = display.data_window)
plot(showEXP ? (pocPx) : na, "EXP_POC", color = exC_, display = display.data_window)
plot(showEXP ? (fadeLong ? 1 : fadeShort ? -1 : 0) : na, "EXP_Fade", color = exC_, display = display.data_window)
plot(showEXP ? (edge) : na, "EXP_Edge", color = exC_, display = display.data_window)
plot(showEXP ? (na(osc) ? 0 : 1) : na, "EXP_DataLive", color = exC_, display = display.data_window)

plot(showEXP ? (nearHVN) : na, "EXP_NearHVN", color = exC_, display = display.data_window)
plot(showEXP ? (nearLVN) : na, "EXP_NearLVN", color = exC_, display = display.data_window)
plot(showEXP ? (shapeCode) : na, "EXP_Shape", color = exC_, display = display.data_window)
plot(showEXP ? (runsZ) : na, "EXP_RunsZ", color = exC_, display = display.data_window)
plot(showEXP ? (edgeLB) : na, "EXP_EdgeLB", color = exC_, display = display.data_window)
plot(showEXP ? (cusumEvt ? 1 : 0) : na, "EXP_CUSUM", color = exC_, display = display.data_window)
alertcondition(ta.crossover(osc, 0),  "Cross above POC", "Value Distribution: price crossed above the Point of Control (into premium).")
alertcondition(ta.crossunder(osc, 0), "Cross below POC", "Value Distribution: price crossed below the Point of Control (into discount).")
alertcondition(fadeLong,  "Discount fade",  "Value Distribution: stretched into the discount tail and turning up.")
alertcondition(fadeShort, "Premium fade",   "Value Distribution: stretched into the premium tail and turning down.")
````
