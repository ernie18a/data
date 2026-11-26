# VCP Pro nilesh

- url: https://www.tradingview.com/script/8WCSS9MA-VCP-Pro-nilesh/
- type: indicator
- pine_id: PUB;af173226fe9a4c33a89724ed867d1c8f
- version: 1.0

## Description

compression is the technical indicator in which it shows the moove before the price

## Source Code

````pine
//@version=5
// =============================================================================
// VCP PRO — COMPRESSION + VOLUME DRY-UP ENGINE  (TradingView port)
// Faithful port of E1 (Compression) + E3 (Volume Dry-up), combined view.
//
// E1 Compression score = weighted blend of 5 volatility estimators, each
//    percentile-ranked over `pctWin` and inverted (low vol = high compression):
//      VCR 0.30 | Parkinson 0.20 | Garman-Klass 0.20 | BBWidth 0.20 | HV 0.10
//    + convergence bonus when >=4 estimators sit below the 20th pct.
//
// E3 Volume score = 0.50*(1-pctVDU) + 0.30*(1-normEntropy) + 0.20*persistence
//    + elite bonus (VDU<0.50 sustained).
//
// Timeframe-aware: 504/20/10/sqrt(252) are DAILY defaults. On intraday the
// engine auto-derives bar-equivalent windows and the annualization factor so
// the statistics stay valid. Override any of them manually if you want.
// =============================================================================
indicator("VCP Pro — Compression + Volume Dry-up", overlay=false, max_labels_count=500)

// ----------------------------------------------------------------------------
// TIMEFRAME-AWARE DEFAULTS
// Daily spec: pctWin=504, volMA=20, entWin=10, annualization=sqrt(252).
// We scale windows by how many of THIS timeframe's bars make a trading day,
// and set annualization to sqrt(bars per year) for HV.
// ----------------------------------------------------------------------------
barsPerDay() =>
    // crude but robust: minutes in a 6.25h NSE session / chart minutes; 1 for >=daily
    tfm = timeframe.in_seconds() / 60.0
    timeframe.isintraday ? math.max(1.0, 375.0 / tfm) : 1.0

bpd          = barsPerDay()
autoTune     = input.bool(true, "Auto-tune windows to timeframe", group="Timeframe",
                 tooltip="ON: 504/20/10-day windows are converted to bar-equivalents on intraday, and HV annualization uses bars/year. OFF: use the raw bar counts below.")
pctWinD      = input.int(504, "Percentile window (days)", minval=60, group="Timeframe")
volMAD       = input.int(20,  "Volume MA (days)",         minval=5,  group="Timeframe")
entWinD      = input.int(10,  "Entropy window (days)",    minval=5,  group="Timeframe")

// Single simple-int expression each (no later reassignment) so they stay
// valid as loop bounds and ta.* length arguments. Cap folded into expression.
pctWin = math.min(autoTune ? int(math.round(pctWinD * bpd)) : pctWinD, 5000)
volMA  = autoTune ? int(math.round(volMAD  * bpd)) : volMAD
entWin = autoTune ? int(math.round(entWinD * bpd)) : entWinD
barsPerYear = autoTune ? (252.0 * bpd) : 252.0

// ----------------------------------------------------------------------------
// WEIGHTS (match spec)
// ----------------------------------------------------------------------------
grpW   = "Weights (compression)"
wVCR   = input.float(0.30, "VCR",          group=grpW)
wPark  = input.float(0.20, "Parkinson",    group=grpW)
wGK    = input.float(0.20, "Garman-Klass", group=grpW)
wBB    = input.float(0.20, "Bollinger BW", group=grpW)
wHV    = input.float(0.10, "HV",           group=grpW)

grpVW  = "Weights (volume)"
wVDU   = input.float(0.50, "VDU magnitude",  group=grpVW)
wEnt   = input.float(0.30, "Entropy consist",group=grpVW)
wPers  = input.float(0.20, "Persistence",    group=grpVW)
persMax= input.int(20, "Persistence cap (bars)", minval=5, group=grpVW)

grpT   = "Thresholds"
elitePctl = input.int(30, "Persistence percentile (<)", minval=5, maxval=50, group=grpT)
coilLo    = input.int(70, "Coil: scores must exceed", minval=50, maxval=95, group=grpT,
              tooltip="Both compression AND volume score must clear this for COIL ACTIVE.")

// ----------------------------------------------------------------------------
// HELPER — rolling percentile rank (0..1): fraction of window <= current
// ----------------------------------------------------------------------------
pctRank01(src, len) =>
    cnt = 0
    tot = 0
    for i = 0 to len - 1
        v = src[i]
        if not na(v)
            tot += 1
            if v <= src
                cnt += 1
    tot > 0 ? cnt / tot : na

ln2 = math.log(2)

// ----------------------------------------------------------------------------
// E1 — FIVE VOLATILITY ESTIMATORS
// ----------------------------------------------------------------------------
// 1. VCR = ATR(5)/ATR(20), Wilder smoothing (ta.atr uses RMA = Wilder)
atr5  = ta.atr(5)
atr20 = ta.atr(20)
vcr   = atr20 != 0 ? atr5 / atr20 : na

// 2. Parkinson: (1/(4 ln2)) * mean( ln(H/L)^2 )
parkBar = math.pow(math.log(high / low), 2)
parkVar = (1.0 / (4.0 * ln2)) * ta.sma(parkBar, 20)
park    = math.sqrt(math.max(parkVar, 0))

// 3. Garman-Klass: 0.5 ln(H/L)^2 - (2 ln2 - 1) ln(C/O)^2  -- clip per-bar at 0
gkBar   = 0.5 * math.pow(math.log(high / low), 2) - (2.0 * ln2 - 1.0) * math.pow(math.log(close / open), 2)
gkBarC  = math.max(gkBar, 0)                       // AUDIT FIX: clip before mean
gkVar   = ta.sma(gkBarC, 20)
gk      = math.sqrt(math.max(gkVar, 0))

// 4. Bollinger Bandwidth = 4*sigma20 / MA20
ma20    = ta.sma(close, 20)
sd20    = ta.stdev(close, 20)
bbw     = ma20 != 0 ? 4.0 * sd20 / ma20 : na

// 5. HV = sqrt(barsPerYear) * stdev(log returns, 20)
logret  = math.log(close / close[1])
hv      = math.sqrt(barsPerYear) * ta.stdev(logret, 20)

// percentile-rank each, invert (1 - pct) => compression contribution
cVCR  = na(vcr)  ? na : 1 - pctRank01(vcr,  pctWin)
cPark = na(park) ? na : 1 - pctRank01(park, pctWin)
cGK   = na(gk)   ? na : 1 - pctRank01(gk,   pctWin)
cBB   = na(bbw)  ? na : 1 - pctRank01(bbw,  pctWin)
cHV   = na(hv)   ? na : 1 - pctRank01(hv,   pctWin)

compRaw = wVCR*cVCR + wPark*cPark + wGK*cGK + wBB*cBB + wHV*cHV
compScore = na(compRaw) ? na : 100.0 * compRaw

// convergence bonus: >=4 estimators below 20th pct (i.e. compression contrib > 0.80)
belowCount = (cVCR > 0.80 ? 1 : 0) + (cPark > 0.80 ? 1 : 0) + (cGK > 0.80 ? 1 : 0) + (cBB > 0.80 ? 1 : 0) + (cHV > 0.80 ? 1 : 0)
compScore := not na(compScore) and belowCount >= 4 ? math.min(100, compScore + 4) : compScore

// ----------------------------------------------------------------------------
// E3 — VOLUME DRY-UP
// ----------------------------------------------------------------------------
// 1. VDU = volume / SMA(volume, volMA)
volSMA = ta.sma(volume, volMA)
vdu    = volSMA != 0 ? volume / volSMA : na
pctVDU = na(vdu) ? na : pctRank01(vdu, pctWin)

// 2. Shannon entropy of last entWin volumes, normalized by log2(entWin)
shVolEntropy() =>
    tot = 0.0
    for i = 0 to entWin - 1
        v = volume[i]
        tot += na(v) ? 0 : v
    H = 0.0
    if tot > 0
        for i = 0 to entWin - 1
            v = volume[i]
            p = na(v) ? 0 : v / tot
            if p > 0
                H -= p * (math.log(p) / ln2)   // log base 2
    H
entropy   = shVolEntropy()
maxEnt    = math.log(entWin) / ln2
normEnt   = maxEnt > 0 ? entropy / maxEnt : na

// 3. persistence: consecutive bars with pctVDU below `elitePctl`/100
quiet = not na(pctVDU) and pctVDU < (elitePctl / 100.0)
var int persDays = 0
persDays := quiet ? persDays + 1 : 0
persComp = math.min(persDays, persMax) / float(persMax)

volRaw   = wVDU*(1 - pctVDU) + wEnt*(1 - normEnt) + wPers*persComp
volScore = na(volRaw) ? na : 100.0 * volRaw

// 4. elite signal: VDU < 0.50 sustained >= 5 bars  => +8
var int eliteCnt = 0
eliteCnt := (not na(vdu) and vdu < 0.50) ? eliteCnt + 1 : 0
eliteOn  = eliteCnt >= 5
volScore := not na(volScore) and eliteOn ? math.min(100, volScore + 8) : volScore

// ----------------------------------------------------------------------------
// COMBINED COIL STATE — both engines must agree
// ----------------------------------------------------------------------------
coilActive = not na(compScore) and not na(volScore) and compScore >= coilLo and volScore >= coilLo

// ----------------------------------------------------------------------------
// VISUALS — separate pane, two score lines (IPE dark-neon)
// Compression = cyan, Volume dry-up = teal. Threshold + coil shading in-pane.
// ----------------------------------------------------------------------------
cTeal = color.new(#00FFC8, 0)
cCyan = color.new(#00E5FF, 0)
cDead = color.new(#3A3F4B, 0)
cElite= color.new(#FF1493, 0)

// the two score lines
plot(compScore, "Compression score", color=cCyan, linewidth=2)
plot(volScore,  "Volume dry-up score", color=cTeal, linewidth=2)

// threshold + bounds
hline(coilLo, "Coil threshold", color=color.new(#FF1493, 40), linestyle=hline.style_dashed)
hline(100, "", color=color.new(color.gray, 80))
hline(0,   "", color=color.new(color.gray, 80))

// shade the pane background when BOTH lines clear the threshold (coil active)
bgcolor(coilActive ? color.new(cTeal, 90) : na)

// onset / elite markers along the pane bottom
coilStart = coilActive and not coilActive[1]
plotshape(coilStart, title="coil onset", style=shape.circle, location=location.bottom, color=cTeal, size=size.tiny)
plotshape(eliteOn and not eliteOn[1], title="elite dry-up", style=shape.diamond, location=location.bottom, color=cElite, size=size.tiny)

var table tbl = table.new(position.top_right, 2, 8, border_width=1)
bg = color.new(#101216, 0)
f(x) => str.tostring(x, "#.0")
if barstate.islast
    statusTxt = coilActive ? "COIL ACTIVE" : "—"
    statusCol = coilActive ? cTeal : color.gray
    table.cell(tbl, 0, 0, "VCP PRO",      text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(tbl, 1, 0, statusTxt,      text_color=statusCol,   bgcolor=bg, text_size=size.small)
    table.cell(tbl, 0, 1, "Compression",  text_color=cCyan,       bgcolor=bg, text_size=size.small)
    table.cell(tbl, 1, 1, f(compScore),   text_color=compScore>=coilLo?cCyan:color.white, bgcolor=bg, text_size=size.small)
    table.cell(tbl, 0, 2, "Volume dry-up",text_color=cTeal,       bgcolor=bg, text_size=size.small)
    table.cell(tbl, 1, 2, f(volScore),    text_color=volScore>=coilLo?cTeal:color.white, bgcolor=bg, text_size=size.small)
    table.cell(tbl, 0, 3, "VCR",          text_color=color.gray,  bgcolor=bg, text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(vcr,"#.00"), text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(tbl, 0, 4, "Conv (>=4)",   text_color=color.gray,  bgcolor=bg, text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(belowCount), text_color=belowCount>=4?cCyan:color.white, bgcolor=bg, text_size=size.small)
    table.cell(tbl, 0, 5, "VDU",          text_color=color.gray,  bgcolor=bg, text_size=size.small)
    table.cell(tbl, 1, 5, str.tostring(vdu,"#.00"), text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(tbl, 0, 6, "Persist bars", text_color=color.gray,  bgcolor=bg, text_size=size.small)
    table.cell(tbl, 1, 6, str.tostring(persDays), text_color=color.white, bgcolor=bg, text_size=size.small)
    table.cell(tbl, 0, 7, "Elite dry-up", text_color=color.gray,  bgcolor=bg, text_size=size.small)
    table.cell(tbl, 1, 7, eliteOn?"YES":"no", text_color=eliteOn?cElite:color.gray, bgcolor=bg, text_size=size.small)

alertcondition(coilActive and not coilActive[1], "VCP Coil Active", "VCP Pro: compression + volume dry-up coil formed")
````
