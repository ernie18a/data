# Path Signature Regime Engine

- url: https://www.tradingview.com/script/jgBZpqwC-Path-Signature-Regime-Engine/
- type: indicator
- pine_id: PUB;3a884c9b816c49968fc7a5a115246f51
- version: 1.0

## Description

# Path Signature Regime Engine (PSRE) 

**What it does**

Path Signature Regime Engine reads the *geometry* of recent price action and
labels the current market state as **Trending up**, **Trending down**,
**Range / chop**, or **Turning (reversion)**. Instead of smoothing price with a
moving average, it measures the shape of the path itself using the low-order
**path signature** — a description of a curve by its iterated integrals from
rough-path theory.

Two terms do the work:

- **Level 1 — drift:** the net displacement of the path over a lookback window.
- **Level 2 — Lévy area:** the signed area the path sweeps relative to its own
  chord. A path that keeps curling the same way (a trend) accumulates area; a
  path that oscillates back and forth (a range) cancels it out. The sign and
  size of this area is the core regime signal.

Both terms are turned into 0–100 percentiles over a rolling window, so the read
adapts to each symbol and timeframe automatically.

**How it works (one method, three views — not a mashup)**

This is deliberately **not** a bundle of independent indicators stitched
together. Every component calls the same internal routine that computes the
drift + Lévy-area read. The "extra" layers are that single computation pointed
at different data:

- **Chart timeframe** — the primary regime read.
- **Multi-timeframe confluence** — the *identical* read evaluated on two higher
  timeframes (default 1H and 4H). It is reported as **agreement** ("aligned
  2/3"), explicitly *not* as independent confirmation, because nested
  timeframes share information. "Aligned" requires at least two of the three
  views to agree with the chart.
- **Cross-asset comparison** — the same iterated-integral area computed between
  *two return streams* (your symbol and a benchmark) instead of price-vs-time.
  This yields a geometric lead/lag read plus a relative-strength sign.

Because the higher-timeframe and cross-asset views are projections of one
geometric primitive rather than separate tools, they reinforce a single
conclusion: what is the path doing, and does that hold up when seen from a
slower clock or against a related instrument.

**The honesty layer (why this differs from a typical regime indicator)**

Markets are noisy, so the engine carries its own reality checks rather than
asking you to take the colours on faith:

- **In-sample base rates** — for each regime it tracks, on the history loaded
  on your chart, how often price actually continued over a chosen horizon, with
  sample counts shown.
- **"Aligned vs not"** — a side-by-side that can reveal the multi-timeframe
  layer adding *nothing* on a given instrument (if the two numbers are equal,
  alignment isn't helping — and the panel will tell you so).
- **Transition log** — a table of recent regime flips with their realised
  forward return (in ATR units) and a ✓/✗ result. With one toggle it also
  emits `log:*` series so you can right-click → *Export chart data* and study
  the full transition history offline.

These are descriptive statistics on past data, not predictions.

**How to use it**

1. Add it to any chart. It reads the chart's own symbol, so it works on any
   market — equities, futures, FX, crypto, indices.
2. Defaults are tuned for **NIFTY** (benchmark `NSE:BANKNIFTY`, same trading
   session). For any other asset, open settings group **4 · Cross-asset
   comparison** and set a benchmark that trades in the *same hours* as your
   instrument, and adjust the two higher timeframes in group **3** relative to
   your working timeframe.
3. Read the panel top-down: regime → strength → bias → path quality →
   timeframe agreement → relative strength → flow tilt → base rates.
4. Treat the output as **context**, not a trade trigger. The base-rate rows are
   there so you can judge, per instrument and timeframe, whether the read has
   any historical edge before relying on it.
5. Optional alerts fire on a new reversion setup and on any regime change.

**Inputs are organised in workflow order:** Data & source, Signature engine,
Multi-timeframe confluence, Cross-asset comparison, Regime base-rate study,
Transition log, Appearance. The panel theme adapts to your chart background
luminance for readability on light or dark themes.

**Concept credits**

The mathematics is not mine; the implementation and the regime/honesty
framework are. Path signatures and the Lévy-area interpretation come from the
rough-path and signature-method literature:

- K.-T. Chen — iterated integrals (1957).
- T. Lyons — rough-path theory and the path signature (1998).
- I. Chevyrev & A. Kormilitzin — *A Primer on the Signature Method in Machine
  Learning*.
- J. Morrill, A. Fermanian, P. Kidger & T. Lyons — *A Generalised Signature
  Method for Time Series* (the basepoint + time augmentation used here).

Only the interpretable Levels 1–2 are computed directly from cumulative sums.
This is a descriptive geometric read, not a full signature and not a machine-
learning model.

---

## Disclaimer (include at the end of the description)

This script is an educational and analytical tool. It is **not financial
advice**, not a recommendation to buy or sell, and not a signal service. All
statistics it shows (base rates, transition forward returns) are **in-sample**,
computed close-to-close on the history loaded on your chart, with no execution
costs or slippage, and are **not** a backtest and **not** a forecast. Past
behaviour does not guarantee future results. Test thoroughly and trade your own
plan and risk.

## Source Code

````pine
//@version=6
// This source code is subject to the terms of the Mozilla Public License 2.0
// © YourTradingViewUsername   <-- replace with your TradingView handle before publishing
//
// =====================================================================
//  PATH SIGNATURE REGIME ENGINE  (PSRE)
// ---------------------------------------------------------------------
//  WHAT IT DOES
//  Reads the GEOMETRY of recent price action and classifies it into a
//  regime — trending, balanced (range/chop), or turning (reversion) —
//  using the low-order PATH SIGNATURE of the price path. The signature's
//  Level-1 term is net drift; its Level-2 term is the signed swept area
//  (the Levy area), which curls when a path trends and cancels when it
//  oscillates. One single computation of these two terms is reused as a
//  unified lens across three views: the chart timeframe, two higher
//  timeframes (confluence), and a second asset (relative lead-lag).
//
//  WHY THE PARTS BELONG TOGETHER (not a mashup of separate indicators)
//  Every layer calls ONE function, f_read(), which computes the same
//  drift + Levy-area read. The multi-timeframe layer is that identical
//  read evaluated on higher timeframes; the cross-asset layer is the same
//  iterated-integral area computed between two return streams instead of
//  price-vs-time. Nothing here is a standard off-the-shelf oscillator
//  bolted on — the timeframe and cross-asset views are projections of a
//  single geometric primitive, which is the point of the engine.
//
//  HONESTY LAYER
//  Markets are noisy, so the engine ships with its own reality checks:
//  per-regime IN-SAMPLE follow-through base rates, an "aligned vs not"
//  comparison that can expose the multi-timeframe layer adding nothing,
//  and a transition log you can export to study where (if anywhere) the
//  read has an edge. This is a DESCRIPTIVE tool. It does not forecast and
//  it is not a signal generator on its own.
//
//  CONCEPT CREDITS (the authors of the underlying mathematics)
//    K.-T. Chen — iterated integrals (1957).
//    T. Lyons — rough-path theory and the path signature (1998).
//    I. Chevyrev & A. Kormilitzin — the signature method in machine
//      learning, incl. the Levy-area interpretation.
//    J. Morrill, A. Fermanian, P. Kidger & T. Lyons — the generalised
//      signature method (basepoint + time augmentation used here).
//  This script applies only the interpretable Levels 1-2 directly from
//  cumulative sums; it is not a full signature and not an ML model.
//
//  DEFAULTS are set for NIFTY (benchmark NSE:BANKNIFTY, same session).
//  The script reads THIS chart's symbol, so it works on any asset in any
//  market — change the benchmark and timeframes in settings for your asset.
//
//  Not financial advice. Educational/analytical tool. Test before use.
// =====================================================================
indicator("Path Signature Regime Engine", "PSRE", overlay = true,
     max_labels_count = 50, max_lines_count = 50, max_boxes_count = 50, max_bars_back = 1000)

// =====================================================================
//  INPUTS  (grouped in workflow order)
// =====================================================================
g1 = "1 · Data & price source"
srcSel   = input.string("close", "Price source", options = ["close","hl2","ohlc4","hlc3"], group = g1,
             tooltip = "The engine reads THIS chart's symbol, so it works on any asset in any market. This selects which price series within each bar builds the path.")
volMode  = input.string("Auto", "Volume feed (flow tilt)", options = ["Auto","Force on","Force off"], group = g1,
             tooltip = "Auto disables the volume tilt on symbols without usable volume. The tilt is signed BAR volume only — a coarse proxy, NOT order-flow imbalance.")

g2 = "2 · Signature engine"
winN     = input.int(40,  "Path window (bars)", minval = 8, maxval = 300, group = g2,
             tooltip = "Bars forming the path the signature is read over. Larger = slower, smoother regimes.")
normWin  = input.int(250, "Normalisation window", minval = 50, maxval = 1000, group = g2,
             tooltip = "History used to convert raw signature terms into 0-100 percentiles, so the read adapts per asset and timeframe.")
trendP   = input.float(60, "Trend-strength threshold (percentile)", minval = 50, maxval = 95, group = g2,
             tooltip = "Above this percentile of |drift| the path is treated as directional.")
areaP    = input.float(60, "Levy-area threshold (percentile)", minval = 50, maxval = 95, group = g2,
             tooltip = "Above this percentile of |Levy area| the path is curling strongly (trend); near zero = balanced.")

g3 = "3 · Multi-timeframe confluence"
useMTF     = input.bool(true, "Enable multi-timeframe read", group = g3)
tfA        = input.timeframe("60",  "Higher timeframe A", group = g3,
             tooltip = "Default 1H. Set relative to your working timeframe.")
tfB        = input.timeframe("240", "Higher timeframe B", group = g3,
             tooltip = "Default 4H. Set relative to your working timeframe.")
confirmHTF = input.bool(true, "Confirm higher timeframes on close", group = g3,
             tooltip = "ON uses the last CLOSED chart bar's alignment (lags one bar, less flip-flop). Higher-TF reads use lookahead OFF, so no future data; the live HTF bar still updates intrabar.")

g4 = "4 · Cross-asset comparison"
useCross = input.bool(true, "Enable cross-asset read", group = g4)
benchSym = input.symbol("NSE:BANKNIFTY", "Benchmark symbol", group = g4,
             tooltip = "Default set for NIFTY (NSE:BANKNIFTY, same trading session). Change to a symbol relevant to YOUR asset — ideally one that trades in the same hours. If unavailable or out of session, this row shows a dash.")

g5 = "5 · Regime base-rate study"
fwdLook  = input.int(10, "Follow-through horizon (bars)", minval = 3, maxval = 60, group = g5,
             tooltip = "Bars ahead used to measure IN-SAMPLE whether each regime continued. A study aid on loaded history, not a forecast.")

g6 = "6 · Transition log"
showLog   = input.bool(false, "Show transition-log table", group = g6)
logRows   = input.int(10, "Rows to display", minval = 1, maxval = 20, group = g6)
logPos    = input.string("Bottom Left", "Log position", options = ["Bottom Left","Bottom Right","Top Left","Top Right","Middle Left"], group = g6)
logExport = input.bool(true, "Emit exportable log series (Data Window)", group = g6,
             tooltip = "Adds 'log:*' series carrying each resolved transition's stats on the bar it resolves. Right-click > Export chart data, then keep rows where log:fwdRet_atr is non-empty.")

g7 = "7 · Appearance"
themeOpt = input.string("Auto", "Theme", options = ["Auto","Dark","Light"], group = g7,
             tooltip = "Auto adapts panel colours to your chart background luminance for readability on any theme.")
showPanel= input.bool(true, "Decision panel", group = g7)
panelPos = input.string("Top Right", "Panel position", options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = g7)
showRib  = input.bool(true, "Regime ribbon", group = g7)
showMarks= input.bool(true, "Reversion-setup markers", group = g7)

// =====================================================================
//  ADAPTIVE THEME  (luminance-based, works on any background colour)
// =====================================================================
f_lum(c) => na(c) ? 0.0 : (0.299*color.r(c) + 0.587*color.g(c) + 0.114*color.b(c)) / 255
isLight  = themeOpt == "Light" or (themeOpt == "Auto" and f_lum(chart.bg_color) > 0.6)
txtCol   = isLight ? #0a0a0a : #f0f0f0
txtDim   = isLight ? #555555 : #9aa0a6
hdrBg    = isLight ? #e8eaed : #1f2933
cellBg   = isLight ? #f5f6f7 : #131722
frameCol = isLight ? #c0c4c8 : #2a2e39
cUp  = #26a69a
cDn  = #ef5350
cBal = #f0b132
cRev = #42a5f5
txtOn(c) => f_lum(c) > 0.6 ? #0a0a0a : #ffffff

// =====================================================================
//  DATA
//   srcBase = chart-context source for the cross-asset / range / flow
//   blocks. f_read() derives its OWN source from built-ins so it stays
//   correct when evaluated on another timeframe or symbol.
// =====================================================================
srcBase = srcSel == "hl2" ? hl2 : srcSel == "ohlc4" ? ohlc4 : srcSel == "hlc3" ? hlc3 : close
volCum  = ta.cum(nz(volume))
volSeen = volCum > 0 and not na(volume)
volHi50 = ta.highest(nz(volume), 50)
hasVol  = volSeen and volHi50 > 0
useVol  = volMode == "Force on" ? true : volMode == "Force off" ? false : hasVol

// =====================================================================
//  CORE PATH READ  —  time-augmented signature, Levels 1-2
//   Returns: driftPct, areaPct, dir(+/-1), areaSign(+/-1), efficiency.
//   Iterated integrals via cumulative-sum windowing with basepoint
//   anchoring (Morrill et al.); left-point discretisation. All ta.* calls
//   run every bar so the function is consistent under request.security.
// =====================================================================
f_read() =>
    _src    = srcSel == "hl2" ? hl2 : srcSel == "ohlc4" ? ohlc4 : srcSel == "hlc3" ? hlc3 : close
    _ret    = _src - _src[1]
    _atr    = ta.atr(14)
    _smaAbs = ta.sma(math.abs(_ret), winN)
    _atrN   = _atr > 0 ? _atr : _smaAbs
    _nX1    = _atrN > 0 ? _ret / _atrN : _ret          // price channel (scale-normalised)
    _nX2    = 1.0 / winN                                // time channel (constant step)
    _cX1    = ta.cum(_nX1)
    _cX2    = ta.cum(_nX2)
    _S1     = _cX1 - nz(_cX1[winN])                     // net drift over window
    _S2     = _cX2 - nz(_cX2[winN])
    _cp12   = ta.cum(nz(_cX1[1]) * _nX2)
    _cp21   = ta.cum(nz(_cX2[1]) * _nX1)
    _a1     = nz(_cX1[winN])
    _a2     = nz(_cX2[winN])
    _S12    = (_cp12 - nz(_cp12[winN])) - _a1 * (_cX2 - nz(_cX2[winN]))
    _S21    = (_cp21 - nz(_cp21[winN])) - _a2 * (_cX1 - nz(_cX1[winN]))
    _levy   = 0.5 * (_S12 - _S21)                       // signed swept (Levy) area
    _step   = math.sqrt(_nX1*_nX1 + _nX2*_nX2)
    _cLen   = ta.cum(_step)
    _pLen   = _cLen - nz(_cLen[winN])
    _eff    = _pLen > 0 ? math.sqrt(_S1*_S1 + _S2*_S2) / _pLen : 0.0   // 0..1 path straightness
    _dPct   = ta.percentrank(math.abs(_S1),   normWin)
    _aPct   = ta.percentrank(math.abs(_levy), normWin)
    [_dPct, _aPct, _S1 >= 0 ? 1 : -1, _levy >= 0 ? 1 : -1, _eff]

[driftPct, areaPct, dir, areaSign, efficiency] = f_read()

// =====================================================================
//  REGIME CLASSIFICATION
//   REVERSION requires three confirmations to stay selective: (1) Levy-area
//   sign flip after a strong curl, (2) drift momentum fading, (3) price
//   stretched to a window range extreme.
// =====================================================================
driftPctMax    = ta.highest(driftPct, 5)
driftWeakening = driftPct < driftPctMax - 8 and driftPctMax >= trendP
hiWin    = ta.highest(high, winN)
loWin    = ta.lowest(low, winN)
rangePos = (hiWin - loWin) > 0 ? (srcBase - loWin) / (hiWin - loWin) : 0.5
atExtreme = rangePos >= 0.80 or rangePos <= 0.20

strongTrend = driftPct >= trendP and areaPct >= areaP
areaFlip    = areaSign != areaSign[1] and nz(areaPct[1]) >= areaP and driftWeakening and atExtreme

regime = "BALANCED"
if strongTrend
    regime := dir > 0 ? "TREND UP" : "TREND DOWN"
else if areaFlip
    regime := "REVERSION"
else if driftPct >= trendP
    regime := dir > 0 ? "TREND UP" : "TREND DOWN"
regCol = regime == "TREND UP" ? cUp : regime == "TREND DOWN" ? cDn : regime == "REVERSION" ? cRev : cBal

// =====================================================================
//  MULTI-TIMEFRAME CONFLUENCE  (same read on higher timeframes)
//   Reported as AGREEMENT, not independent confirmation: nested timeframes
//   share information. "Aligned" requires >= 2 of 3 views to agree.
// =====================================================================
[dPctA, aPctA, dirA, asA, effA] = request.security(syminfo.tickerid, tfA, f_read(), lookahead = barmerge.lookahead_off)
[dPctB, aPctB, dirB, asB, effB] = request.security(syminfo.tickerid, tfB, f_read(), lookahead = barmerge.lookahead_off)

voteP = driftPct >= trendP ? dir  : 0
voteA = dPctA    >= trendP ? dirA : 0
voteB = dPctB    >= trendP ? dirB : 0
upVotes = (voteP > 0 ? 1 : 0) + (voteA > 0 ? 1 : 0) + (voteB > 0 ? 1 : 0)
dnVotes = (voteP < 0 ? 1 : 0) + (voteA < 0 ? 1 : 0) + (voteB < 0 ? 1 : 0)
mtfDir   = upVotes > dnVotes ? 1 : dnVotes > upVotes ? -1 : 0
mtfCount = math.max(upVotes, dnVotes)
alignedRawI = (useMTF and mtfCount >= 2 and ((dir > 0 and mtfDir > 0) or (dir < 0 and mtfDir < 0))) ? 1 : 0
alignedI    = confirmHTF ? nz(alignedRawI[1]) : alignedRawI
aligned     = alignedI == 1
mtfTxt = not useMTF ? "—" : mtfDir == 0 ? "mixed" : (mtfDir > 0 ? "up " : "down ") + str.tostring(mtfCount) + "/3"

// =====================================================================
//  CROSS-ASSET COMPARISON  (Levy area between two return streams)
//   Positive area = this symbol's increments tend to lead the benchmark's
//   within the window (geometric lead, normalisation-sensitive). Plus a
//   relative-strength sign from the two drifts.
// =====================================================================
bRaw = request.security(benchSym, timeframe.period, close, lookahead = barmerge.lookahead_off)
crossOK = useCross and not na(bRaw) and not na(bRaw[1])
aRet = srcBase - srcBase[1]
bRet = nz(bRaw) - nz(bRaw[1])
aN = ta.sma(math.abs(aRet), winN)
bN = ta.sma(math.abs(bRet), winN)
cX1 = aN > 0 ? aRet / aN : 0.0
cX2 = bN > 0 ? bRet / bN : 0.0
ccX1 = ta.cum(cX1)
ccX2 = ta.cum(cX2)
ccp12 = ta.cum(nz(ccX1[1]) * cX2)
ccp21 = ta.cum(nz(ccX2[1]) * cX1)
cAn1 = nz(ccX1[winN])
cAn2 = nz(ccX2[winN])
cS12 = (ccp12 - nz(ccp12[winN])) - cAn1 * (ccX2 - nz(ccX2[winN]))
cS21 = (ccp21 - nz(ccp21[winN])) - cAn2 * (ccX1 - nz(ccX1[winN]))
crossLevy = 0.5 * (cS12 - cS21)
crossPct  = ta.percentrank(math.abs(crossLevy), normWin)
relStrength = (ccX1 - nz(ccX1[winN])) - (ccX2 - nz(ccX2[winN]))
crossTxt = not crossOK ? "—" : crossPct < 50 ? "in step" : crossLevy > 0 ? "leads" : "lags"
relTxt   = not crossOK ? "—" : relStrength > 0 ? "outperforming" : "underperforming"

// =====================================================================
//  FLOW TILT  (signed bar volume — coarse proxy, NOT order flow)
// =====================================================================
flowRaw = (aRet > 0 ? 1.0 : aRet < 0 ? -1.0 : 0.0) * nz(volume)
flowCum = ta.cum(flowRaw)
flowSum = flowCum - nz(flowCum[winN])
flowTxt = not useVol ? "—" : flowSum > 0 ? "net buying" : flowSum < 0 ? "net selling" : "flat"

// =====================================================================
//  PLAIN-LANGUAGE READ
// =====================================================================
regWord  = regime == "TREND UP" ? "Trending up" : regime == "TREND DOWN" ? "Trending down" : regime == "REVERSION" ? "Turning" : "Range / chop"
strWord  = driftPct >= 80 ? "Strong" : driftPct >= trendP ? "Moderate" : "Weak"
biasWord = regime == "REVERSION" ? "Fade the extreme" : (regime == "TREND UP" or regime == "TREND DOWN") ? "Go with the trend" : "Stand aside"
effWord  = efficiency >= 0.5 ? "clean path" : efficiency >= 0.3 ? "some chop" : "very choppy"

// =====================================================================
//  IN-SAMPLE BASE RATES  (historical follow-through, NOT a forecast)
//   (a) per-direction trend continuation over fwdLook bars,
//   (b) continuation when MTF-aligned vs not — exposes whether the
//       multi-timeframe layer earns its place on THIS chart.
// =====================================================================
var int nUp  = 0
var int okUp = 0
var int nDn  = 0
var int okDn = 0
var int nAl  = 0
var int okAl = 0
var int nNal = 0
var int okNal = 0
regPast = regime[fwdLook]
if barstate.isconfirmed and bar_index > normWin + fwdLook and not na(regPast)
    contin = srcBase - srcBase[fwdLook]
    expDir = dir[fwdLook]
    won    = (expDir > 0 and contin > 0) or (expDir < 0 and contin < 0)
    if regPast == "TREND UP"
        nUp  := nUp + 1
        okUp := okUp + (contin > 0 ? 1 : 0)
    if regPast == "TREND DOWN"
        nDn  := nDn + 1
        okDn := okDn + (contin < 0 ? 1 : 0)
    if regPast == "TREND UP" or regPast == "TREND DOWN"
        if nz(alignedI[fwdLook]) == 1
            nAl  := nAl + 1
            okAl := okAl + (won ? 1 : 0)
        else
            nNal  := nNal + 1
            okNal := okNal + (won ? 1 : 0)
upHit  = nUp  > 0 ? 100.0*okUp /nUp  : na
dnHit  = nDn  > 0 ? 100.0*okDn /nDn  : na
alHit  = nAl  > 0 ? 100.0*okAl /nAl  : na
nalHit = nNal > 0 ? 100.0*okNal/nNal : na

// =====================================================================
//  PRICE-PANE VISUALS
// =====================================================================
ribCol = showRib ? color.new(regCol, 80) : na
plotshape(showRib, "Regime ribbon", style = shape.square, location = location.bottom, color = ribCol, size = size.tiny)
plotshape(showMarks and regime == "REVERSION" and rangePos >= 0.5, "Fade up", style = shape.triangledown, location = location.abovebar, color = cDn, size = size.tiny)
plotshape(showMarks and regime == "REVERSION" and rangePos < 0.5,  "Fade down", style = shape.triangleup, location = location.belowbar, color = cUp, size = size.tiny)

plot(driftPct,   "Drift percentile", display = display.data_window)
plot(areaPct,    "Area percentile",  display = display.data_window)
plot(efficiency, "Path efficiency",  display = display.data_window)
plot(useMTF ? mtfDir : na,   "MTF direction", display = display.data_window)
plot(useMTF ? mtfCount : na, "MTF agreement", display = display.data_window)
plot(crossOK ? crossLevy : na,   "Cross Levy area", display = display.data_window)
plot(crossOK ? relStrength : na, "Relative strength", display = display.data_window)

// =====================================================================
//  DECISION PANEL
// =====================================================================
posV = panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : panelPos == "Bottom Left" ? position.bottom_left : panelPos == "Middle Right" ? position.middle_right : position.top_right
var table pnl = table.new(posV, 2, 14, border_width = 1, frame_width = 1, frame_color = frameCol)
prow(r, k, v, vbg) =>
    table.cell(pnl, 0, r, k, text_color = txtDim, text_size = size.small, text_halign = text.align_left,  bgcolor = cellBg)
    table.cell(pnl, 1, r, v, text_color = txtOn(vbg), text_size = size.small, text_halign = text.align_right, bgcolor = color.new(vbg, 12))

if showPanel and barstate.islast
    table.cell(pnl, 0, 0, "PATH READ", text_color = txtCol, text_size = size.normal, bgcolor = hdrBg)
    table.cell(pnl, 1, 0, regWord, text_color = txtOn(regCol), text_size = size.normal, bgcolor = color.new(regCol, 0))
    int ri = 1
    prow(ri, "Strength", strWord, driftPct >= 80 ? cUp : driftPct >= trendP ? cBal : color.gray)
    ri := ri + 1
    prow(ri, "Bias", biasWord, regime == "REVERSION" ? cRev : (regime == "TREND UP" or regime == "TREND DOWN") ? cUp : cBal)
    ri := ri + 1
    prow(ri, "Path", effWord, efficiency >= 0.5 ? cUp : efficiency >= 0.3 ? cBal : cDn)
    ri := ri + 1
    if useMTF
        prow(ri, "Timeframes", mtfTxt + (aligned ? "  aligned" : ""), mtfDir == 0 ? color.gray : aligned ? cUp : cBal)
        ri := ri + 1
    if crossOK
        prow(ri, "Vs " + benchSym, crossTxt, crossPct >= 50 ? cBal : color.gray)
        ri := ri + 1
        prow(ri, "Rel strength", relTxt, relStrength > 0 ? cUp : cDn)
        ri := ri + 1
    if useVol
        prow(ri, "Flow tilt", flowTxt, flowSum > 0 ? cUp : flowSum < 0 ? cDn : color.gray)
        ri := ri + 1
    prow(ri, "Trend-up cont. (in-sample)", na(upHit) ? "—" : str.tostring(math.round(upHit)) + "% (" + str.tostring(nUp) + ")", na(upHit) ? color.gray : upHit >= 50 ? cUp : cDn)
    ri := ri + 1
    prow(ri, "Trend-dn cont. (in-sample)", na(dnHit) ? "—" : str.tostring(math.round(dnHit)) + "% (" + str.tostring(nDn) + ")", na(dnHit) ? color.gray : dnHit >= 50 ? cUp : cDn)
    ri := ri + 1
    if useMTF
        alText = (na(alHit) ? "—" : str.tostring(math.round(alHit)) + "%") + " / " + (na(nalHit) ? "—" : str.tostring(math.round(nalHit)) + "%")
        prow(ri, "Aligned vs not", alText, na(alHit) ? color.gray : nz(alHit) > nz(nalHit) ? cUp : cBal)
        ri := ri + 1
    table.cell(pnl, 0, ri, "Descriptive read · in-sample stats · not a forecast", text_color = txtDim, text_size = size.tiny, text_halign = text.align_left, bgcolor = cellBg)
    table.cell(pnl, 1, ri, "", bgcolor = cellBg)

// =====================================================================
//  REGIME-TRANSITION LOG
//   A transition that occurred fwdLook bars ago "resolves" now: its forward
//   return is known. On resolution we (a) push to an on-chart table and
//   (b) emit 'log:*' series so the full history exports via right-click >
//   Export chart data for offline study. Returns are close-to-close,
//   in-sample, no costs — a study aid, not a backtest and not a forecast.
// =====================================================================
atr14 = ta.atr(14)
f_short(r) => r == "TREND UP" ? "UP" : r == "TREND DOWN" ? "DN" : r == "REVERSION" ? "REV" : "BAL"
f_code(r)  => r == "TREND UP" ? 1 : r == "TREND DOWN" ? -1 : r == "REVERSION" ? 2 : 0

txnResolved = barstate.isconfirmed and bar_index > normWin + fwdLook + 1 and regime[fwdLook] != regime[fwdLook + 1]
xFrom   = regime[fwdLook + 1]
xTo     = regime[fwdLook]
xDirT   = dir[fwdLook]
xDriftT = driftPct[fwdLook]
xAreaT  = areaPct[fwdLook]
xAlignT = nz(alignedI[fwdLook])
xAtr0   = nz(atr14[fwdLook])
xFwdRaw = srcBase - srcBase[fwdLook]
xFwdAtr = xAtr0 > 0 ? xFwdRaw / xAtr0 : na
xWon = xTo == "TREND UP" ? (xFwdRaw > 0 ? 1 : 0) : xTo == "TREND DOWN" ? (xFwdRaw < 0 ? 1 : 0) : xTo == "REVERSION" ? (((xDirT > 0 and xFwdRaw < 0) or (xDirT < 0 and xFwdRaw > 0)) ? 1 : 0) : -1

var logTime  = array.new<int>()
var logFrom  = array.new<string>()
var logTo    = array.new<string>()
var logDrift = array.new<float>()
var logAlign = array.new<int>()
var logFwd   = array.new<float>()
var logWon   = array.new<int>()
if txnResolved
    array.push(logTime,  time[fwdLook])
    array.push(logFrom,  f_short(xFrom))
    array.push(logTo,    f_short(xTo))
    array.push(logDrift, xDriftT)
    array.push(logAlign, xAlignT)
    array.push(logFwd,   xFwdAtr)
    array.push(logWon,   xWon)
    if array.size(logTime) > 300
        array.shift(logTime)
        array.shift(logFrom)
        array.shift(logTo)
        array.shift(logDrift)
        array.shift(logAlign)
        array.shift(logFwd)
        array.shift(logWon)

plot(logExport and txnResolved ? f_code(xFrom) : na, "log:from 1up/-1dn/2rev/0bal", display = display.data_window)
plot(logExport and txnResolved ? f_code(xTo)   : na, "log:to",           display = display.data_window)
plot(logExport and txnResolved ? xDirT         : na, "log:dir",          display = display.data_window)
plot(logExport and txnResolved ? xDriftT       : na, "log:drift_pct",    display = display.data_window)
plot(logExport and txnResolved ? xAreaT        : na, "log:area_pct",     display = display.data_window)
plot(logExport and txnResolved ? xAlignT       : na, "log:aligned",      display = display.data_window)
plot(logExport and txnResolved ? xFwdAtr       : na, "log:fwdRet_atr",   display = display.data_window)
plot(logExport and txnResolved ? xWon          : na, "log:won 1/0/-1na", display = display.data_window)
plot(logExport and txnResolved ? time[fwdLook] : na, "log:txn_time_ms",  display = display.data_window)

logPosV = logPos == "Bottom Right" ? position.bottom_right : logPos == "Top Left" ? position.top_left : logPos == "Top Right" ? position.top_right : logPos == "Middle Left" ? position.middle_left : position.bottom_left
var table logTbl = table.new(logPosV, 6, 22, border_width = 1, frame_width = 1, frame_color = frameCol)
if showLog and barstate.islast
    table.cell(logTbl, 0, 0, "TIME",     text_color = txtCol, text_size = size.tiny, bgcolor = hdrBg)
    table.cell(logTbl, 1, 0, "FROM→TO",  text_color = txtCol, text_size = size.tiny, bgcolor = hdrBg)
    table.cell(logTbl, 2, 0, "DRIFT%",   text_color = txtCol, text_size = size.tiny, bgcolor = hdrBg)
    table.cell(logTbl, 3, 0, "ALGN",     text_color = txtCol, text_size = size.tiny, bgcolor = hdrBg)
    table.cell(logTbl, 4, 0, "FWD(ATR)", text_color = txtCol, text_size = size.tiny, bgcolor = hdrBg)
    table.cell(logTbl, 5, 0, "RES",      text_color = txtCol, text_size = size.tiny, bgcolor = hdrBg)
    int n = array.size(logTime)
    if n == 0
        table.cell(logTbl, 0, 1, "no transitions yet", text_color = txtDim, text_size = size.tiny, bgcolor = cellBg)
    else
        int rows = math.min(logRows, n)
        for i = 0 to rows - 1
            idx = n - 1 - i
            tms = array.get(logTime,  idx)
            frm = array.get(logFrom,  idx)
            tto = array.get(logTo,    idx)
            dft = array.get(logDrift, idx)
            aln = array.get(logAlign, idx)
            fwd = array.get(logFwd,   idx)
            wn  = array.get(logWon,   idx)
            wnTxt  = wn == 1 ? "✓" : wn == 0 ? "✗" : "—"
            wnCol  = wn == 1 ? cUp : wn == 0 ? cDn : color.gray
            fwdCol = na(fwd) ? color.gray : fwd > 0 ? cUp : cDn
            r = i + 1
            table.cell(logTbl, 0, r, str.format_time(tms, "MM-dd HH:mm", syminfo.timezone), text_color = txtDim, text_size = size.tiny, bgcolor = cellBg)
            table.cell(logTbl, 1, r, frm + "→" + tto, text_color = txtCol, text_size = size.tiny, bgcolor = cellBg)
            table.cell(logTbl, 2, r, str.tostring(math.round(dft)), text_color = txtDim, text_size = size.tiny, bgcolor = cellBg)
            table.cell(logTbl, 3, r, aln == 1 ? "yes" : "no", text_color = aln == 1 ? cUp : txtDim, text_size = size.tiny, bgcolor = cellBg)
            table.cell(logTbl, 4, r, na(fwd) ? "—" : str.tostring(fwd, "#.##"), text_color = txtOn(fwdCol), text_size = size.tiny, bgcolor = color.new(fwdCol, 25))
            table.cell(logTbl, 5, r, wnTxt, text_color = txtOn(wnCol), text_size = size.tiny, bgcolor = color.new(wnCol, 25))

// =====================================================================
//  ALERTS
// =====================================================================
var string prevReg = na
regChanged = not na(prevReg) and prevReg != regime
if barstate.isconfirmed
    prevReg := regime
alertcondition(regime == "REVERSION" and regime[1] != "REVERSION", "Reversion setup", "PSRE: momentum turning on {{ticker}} {{interval}}")
alert(regChanged ? "PSRE regime: " + regime + " | drift=" + str.tostring(math.round(driftPct)) + "% | MTF=" + mtfTxt + " | " + syminfo.ticker + " " + timeframe.period : na, alert.freq_once_per_bar_close)
````
