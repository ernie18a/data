# Adaptive Regime Detector [4-State] [TSL]

- url: https://www.tradingview.com/script/T0leo5HU-Adaptive-Regime-Detector-4-State-TSL/
- type: indicator
- pine_id: PUB;37fefe73cf674284803dc7f3f61a11ad
- version: 3.0

## Description

════════════════════════════════════════════════════════════
SCRIPT TITLE (the "Title" field when publishing):
  Adaptive Market Regime Detector [4-State]
 
SUGGESTED TAGS:
  regime, trend, volatility, ATR, marketregime, futures,
  efficiencyratio, choppiness, adaptive, context
════════════════════════════════════════════════════════════
 
 
DESCRIPTION (paste into the description box):
────────────────────────────────────────────────────────────
 
Most regime filters answer the wrong question. They tell you a single number — "ADX is 27" — and leave you to guess what that means for the symbol and timeframe in front of you. That threshold was calibrated on one market. Load it somewhere else and it quietly misfires, because volatility and trend distributions are not the same on NQ 1-minute as they are on BTC 4-hour.
 
This indicator takes a different approach. It does not use a single hard-coded threshold anywhere. Instead, every metric is ranked against its own recent distribution using percentile scoring, so the boundary between "trending" and "ranging" recalibrates to whatever chart you put it on. The same script adapts across symbols and timeframes without manual retuning.
 
 
── WHAT IT DOES ──
 
On each confirmed bar, the script measures two independent axes:
 
Trend axis — Kaufman Efficiency Ratio (directional travel divided by total path) combined with an ATR-normalized EMA slope. High when price is making clean directional progress, low when it is grinding sideways.
 
Volatility axis — the percentile rank of ATR combined with the percentile rank of Bollinger Band width. High when ranges are expanding, low when the market is compressed.
 
Crossing those two axes produces four regimes rather than the usual three:
 
• TRENDING + VOLATILE — direction and range together. The momentum environment.
• TRENDING + CALM — orderly directional grind, muted volatility.
• VOLATILE CHOP — wide two-sided candles going nowhere.
• QUIET RANGE — low volatility, no direction.
 
The distinction between a volatile trend and a volatile range is the reason this exists. Most detectors collapse both into one "high volatility" state, but they are opposite trading environments. Splitting them apart is the practically useful part.
 
 
── HOW TO READ IT ──
 
Background shading colors the chart by the active regime. A compact dashboard in the corner shows the live trend score, volatility score, direction, a confidence reading (how decisively the dominant axis clears its threshold), and a one-line note for the current state.
 
 
── ANTI-FLICKER ──
 
A regime only changes after a configurable number of consecutive bars agree (default 3). This trades a few bars of lag for a stable label, so the read does not strobe back and forth in transition zones. All logic runs on confirmed bars; the script does not repaint.
 
 
── SETTINGS ──
 
Percentile lookback — the window each metric is ranked against. Lower it toward 80–100 on the 1-minute, keep it near 120 on the 5-minute and above.
Trend / Volatility percentile thresholds — how far above its own distribution a score must sit to count as trending or volatile. Defaults 60 / 65.
Confirmation bars — agreeing bars required before the label flips. Higher is steadier and slower.
Display — background shading, dashboard, dashboard position, background transparency.
Alerts — fires once per bar close on a confirmed regime change, with the new regime and confidence in the message.
 
Defaults are tuned for index futures (NQ, ES, MNQ, MES) on intraday charts, but because the engine is adaptive it works on forex, crypto, and stocks without retuning.
 
 
── HOW TO USE IT ──
 
This is a context filter, not a signal generator. It tells you which kind of market you are in so you can apply the tactic that fits — momentum in a volatile trend, pullback entries in a calm trend, mean reversion or standing aside in chop, reduced size in a quiet range. Pair it with your own entry trigger and risk plan. The regime read tells you which tool to reach for, not where to click.
 
 
── LIMITATIONS ──
 
It classifies context; it does not predict direction or generate entries. Transitions are inherently fuzzy and the confirmation buffer means the label arrives a few bars after a regime genuinely shifts — that is deliberate. On a freshly loaded chart with little history, the percentile scores can be jumpy until enough bars accumulate to form a stable distribution.
 
 
Open source. The full Pine v6 source is on this page — read it, fork it, adapt it to your own strategy.
 
This script is an analytical tool published for educational purposes. It does not constitute financial advice and does not guarantee any trading outcome. Trading involves substantial risk of loss.

## Source Code

````pine
//@version=6
// =============================================================
//  Adaptive Market Regime Detector  —  4-State, Self-Calibrating
//  Tuned defaults for index futures (NQ / ES) scalping
//  v1.2: Optional Anchored VWAP that auto-anchors to pivots
// =============================================================
//  Engine: percentile-rank scoring (no hard-coded thresholds).
//  Each metric is ranked against its OWN recent distribution,
//  so the same script adapts across symbols and timeframes
//  without re-tuning. Two axes -> four regimes:
//      Trend axis      : Efficiency Ratio + EMA slope
//      Volatility axis : ATR percentile + BB width percentile
//  Anti-flicker: a regime only flips after N agreeing bars.
//  Anchored VWAP: auto-anchors to "Trend start" (default),
//      "Regime change", or "Session open". Built for catching
//      continuation pullbacks to fair value.
//  Non-repainting: all logic on confirmed bars.
// =============================================================

indicator("Adaptive Regime Detector [4-State]", shorttitle="REGIME", overlay=true, max_labels_count=500)

// ---------- Inputs ----------
grpCore   = "Core Engine"
lookback  = input.int(120,  "Percentile lookback (bars)", minval=20,  maxval=500, group=grpCore, tooltip="Window each metric is ranked against. ~120 ≈ half a session on 1-5m futures.")
erLen     = input.int(14,   "Efficiency Ratio length",    minval=2,   maxval=100, group=grpCore)
emaLen    = input.int(50,   "EMA (slope) length",         minval=5,   maxval=200, group=grpCore)
atrLen    = input.int(14,   "ATR length",                 minval=2,   maxval=100, group=grpCore)
bbLen     = input.int(20,   "Bollinger length",           minval=5,   maxval=100, group=grpCore)

grpClass  = "Classification"
trendPct  = input.float(60, "Trend percentile threshold", minval=50, maxval=95, group=grpClass, tooltip="Combined trend score above this percentile = trending.")
volPct    = input.float(65, "Volatility percentile threshold", minval=50, maxval=95, group=grpClass, tooltip="Combined volatility score above this percentile = volatile.")
confirmN  = input.int(3,    "Confirmation bars (anti-flicker)", minval=1, maxval=20, group=grpClass, tooltip="Regime must persist this many bars before the label flips.")

grpVis    = "Display"
showBG    = input.bool(true,  "Shade background by regime", group=grpVis)
showDash  = input.bool(true,  "Show dashboard",             group=grpVis)
dashPos   = input.string("Top Right", "Dashboard position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grpVis)
dashSize  = input.string("Large", "Dashboard size", options=["Small","Normal","Large","Huge"], group=grpVis, tooltip="Text size for the dashboard. Large is the default; bump to Huge on 4K monitors or drop to Small on laptops.")
bgOpacity = input.int(90, "Background transparency", minval=70, maxval=98, group=grpVis)

grpAlert  = "Alerts"
alertOn   = input.bool(true, "Alert on regime change", group=grpAlert)

grpVWAP    = "Anchored VWAP"
showVWAP   = input.bool(true, "Show anchored VWAP", group=grpVWAP)
vwapAnchor = input.string("Trend start", "Auto-anchor on", options=["Trend start","Regime change","Session open"], group=grpVWAP, tooltip="Trend start (default): anchors when entering a trending regime — best for continuation pullback setups. Regime change: anchors on every state shift. Session open: anchors at the start of each day.")
showBands  = input.bool(false, "Show ±1σ bands", group=grpVWAP, tooltip="Standard deviation bands around the VWAP. Useful for spotting overextensions from fair value.")
dimOutside = input.bool(true, "Dim VWAP outside trending regimes", group=grpVWAP, tooltip="Fades the line during CHOP and QUIET, since the continuation logic only really applies in trends.")
vwapCol    = input.color(#f0883e, "VWAP color", group=grpVWAP)
vwapWidth  = input.int(2, "VWAP line width", minval=1, maxval=4, group=grpVWAP)

// ---------- Palette (matches dark theme) ----------
cTrendCalm = color.new(#3fb950, 0)   // green
cTrendVol  = color.new(#58a6ff, 0)   // blue  - trending + volatile (scalper's friend)
cRangeCalm = color.new(#8b949e, 0)   // gray  - quiet chop, low opportunity
cRangeVol  = color.new(#f85149, 0)   // red   - volatile chop, the account-killer

// ---------- Helper: percentile rank of current value in window ----------
pctRank(src, len) =>
    cnt = 0
    for i = 1 to len
        if src[i] <= src
            cnt += 1
    100.0 * cnt / len

// ---------- Trend metrics ----------
// Efficiency Ratio (Kaufman): directional travel / total path. 0..1, high = clean trend.
change   = math.abs(close - close[erLen])
volatility = math.sum(math.abs(close - close[1]), erLen)
er       = volatility != 0 ? change / volatility : 0.0

// EMA slope, normalized by ATR so it's scale-free
ema      = ta.ema(close, emaLen)
atr      = ta.atr(atrLen)
slopeRaw = (ema - ema[3]) / 3
slopeNrm = atr != 0 ? math.abs(slopeRaw) / atr : 0.0

// Combined trend score -> percentile
trendRaw   = er * 0.6 + slopeNrm * 0.4
trendScore = pctRank(trendRaw, lookback)

// ---------- Volatility metrics ----------
atrPct   = pctRank(atr, lookback)
basis    = ta.sma(close, bbLen)
dev      = ta.stdev(close, bbLen)
bbWidth  = basis != 0 ? (4 * dev) / basis : 0.0
bbPct    = pctRank(bbWidth, lookback)
volScore = (atrPct + bbPct) / 2

// ---------- Direction (for trending states) ----------
up       = ema > ema[3]

// ---------- Raw 4-state classification ----------
isTrend  = trendScore >= trendPct
isVol    = volScore   >= volPct

rawState = isTrend and isVol  ? 1 :  // Trending + Volatile
           isTrend and not isVol ? 2 :  // Trending + Calm
           not isTrend and isVol ? 3 :  // Ranging + Volatile (chop)
           4                            // Ranging + Calm

// ---------- Anti-flicker confirmation ----------
var int regime = 4
var int pending = 4
var int pendCnt = 0

if rawState == regime
    pendCnt := 0
    pending := regime
else
    if rawState == pending
        pendCnt += 1
    else
        pending := rawState
        pendCnt := 1
    if pendCnt >= confirmN
        regime := pending
        pendCnt := 0

// confidence: how far the dominant axis sits past its threshold (0..100)
trendDist = math.min(100.0, math.abs(trendScore - trendPct) / (100 - trendPct) * 100)
volDist   = math.min(100.0, math.abs(volScore   - volPct)   / (100 - volPct)   * 100)
confidence = math.round(math.max(trendDist, volDist))

// ---------- Labels / colors per regime ----------
regimeName = regime == 1 ? (up ? "TRENDING UP • VOLATILE" : "TRENDING DOWN • VOLATILE") : regime == 2 ? (up ? "TRENDING UP • CALM" : "TRENDING DOWN • CALM") : regime == 3 ? "VOLATILE CHOP" : "QUIET RANGE"

regimeShort = regime == 1 ? "TREND+VOL" : regime == 2 ? "TREND" : regime == 3 ? "CHOP" : "QUIET"

regimeCol = regime == 1 ? cTrendVol : regime == 2 ? cTrendCalm : regime == 3 ? cRangeVol : cRangeCalm

// scalper guidance
scalpNote = regime == 1 ? "Prime: momentum, ride extensions" : regime == 2 ? "Good: clean pullback entries" : regime == 3 ? "DANGER: stand down / mean-rev only" : "Thin: small size or wait"

// ---------- Anchored VWAP ----------
// Auto-anchors to a meaningful pivot. "Trend start" is the default because
// the most useful anchored VWAP for continuation traders is one drawn from
// the beginning of the current trend leg — pullbacks to that line are the
// textbook entry. The other anchors are available for different workflows.
isTrending   = regime == 1 or regime == 2
trendStart   = isTrending and not (regime[1] == 1 or regime[1] == 2)
sessionStart = ta.change(time("D")) != 0
anchorReset  = vwapAnchor == "Trend start" ? trendStart : vwapAnchor == "Regime change" ? (regime != regime[1]) : sessionStart

var float vwapPV  = 0.0
var float vwapV   = 0.0
var float vwapPV2 = 0.0

if anchorReset
    vwapPV  := 0.0
    vwapV   := 0.0
    vwapPV2 := 0.0

vwapSrc  = hlc3
vwapPV  += vwapSrc * volume
vwapV   += volume
vwapPV2 += vwapSrc * vwapSrc * volume
vwapVal  = vwapV > 0 ? vwapPV / vwapV : na
vwapVar  = vwapV > 0 ? math.max(0, (vwapPV2 / vwapV) - (vwapVal * vwapVal)) : 0.0
vwapStd  = math.sqrt(vwapVar)
vwapUp   = vwapVal + vwapStd
vwapDn   = vwapVal - vwapStd

// Dim the line outside trending regimes — visual cue that continuation logic doesn't apply.
vwapPlotCol = (dimOutside and not isTrending) ? color.new(vwapCol, 70) : vwapCol
bandPlotCol = color.new(vwapPlotCol, 65)

plot(showVWAP ? vwapVal : na, "Anchored VWAP", color=vwapPlotCol, linewidth=vwapWidth)
plot(showVWAP and showBands ? vwapUp : na, "VWAP +1σ", color=bandPlotCol)
plot(showVWAP and showBands ? vwapDn : na, "VWAP −1σ", color=bandPlotCol)

// ---------- Background shading ----------
bgCol = showBG ? color.new(regimeCol, bgOpacity) : na
bgcolor(bgCol, title="Regime BG")

// ---------- Dashboard ----------
// Size tiers scale together so the layout stays balanced.
//   Small  : header tiny   · data small  · note tiny
//   Normal : header small  · data normal · note small
//   Large  : header normal · data large  · note normal   (default — matches the featured image)
//   Huge   : header large  · data huge   · note large
szHead = dashSize == "Small" ? size.tiny : dashSize == "Normal" ? size.small : dashSize == "Large" ? size.normal : size.large
szData = dashSize == "Small" ? size.small : dashSize == "Normal" ? size.normal : dashSize == "Large" ? size.large : size.huge
szNote = dashSize == "Small" ? size.tiny : dashSize == "Normal" ? size.small : dashSize == "Large" ? size.normal : size.large

var table dash = na
if showDash
    pos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
    dash := table.new(pos, 2, 7, bgcolor=#0b1220, border_color=#2a3140, border_width=1, frame_color=#2a3140, frame_width=1)

if barstate.islast and showDash
    table.cell(dash, 0, 0, "REGIME DETECTOR", text_color=#8b949e, text_size=szHead, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", bgcolor=#0b1220)
    table.cell(dash, 0, 1, "State", text_color=#e6edf3, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, 1, regimeShort, text_color=#ffffff, bgcolor=color.new(regimeCol, 70), text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Trend score", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(math.round(trendScore)) + (isTrend ? " ▲" : ""), text_color=isTrend ? #3fb950 : #8b949e, text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Volatility", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(volScore)) + (isVol ? " ▲" : ""), text_color=isVol ? #f0883e : #8b949e, text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Direction", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, 4, up ? "Up +" : "Down −", text_color=up ? #3fb950 : #f85149, text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, 5, "Confidence", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, 5, str.tostring(confidence) + "%", text_color=#e6edf3, text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, 6, scalpNote, text_color=#58a6ff, text_size=szNote, text_halign=text.align_left)
    table.cell(dash, 1, 6, "", bgcolor=#0b1220)

// ---------- Alerts ----------
regimeChanged = regime != regime[1]
if alertOn and regimeChanged and barstate.isconfirmed
    alert("Regime change → " + regimeName + " (confidence " + str.tostring(confidence) + "%)", alert.freq_once_per_bar_close)

alertcondition(regime != regime[1], title="Any regime change", message="Market regime changed")
````
