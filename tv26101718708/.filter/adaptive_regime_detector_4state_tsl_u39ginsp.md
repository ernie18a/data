# Adaptive Regime Detector [4-State] [TSL]

- url: https://www.tradingview.com/script/u39Ginsp-Adaptive-Regime-Detector-4-State-TSL/
- type: indicator
- pine_id: PUB;9185f2efebf4476cb31df2da63f7c2c7
- version: 1.0

## Description

════════════════════════════════════════════════════════════
RELEASE NOTES — paste into TradingView's "Publish update" box
Script: Adaptive Regime Detector [4-State] [TSL]
Version: v1.3 — Volume Z-Score & High-Conviction Alerts
════════════════════════════════════════════════════════════
 
 
v1.3 — Volume Z-Score & High-Conviction Alerts
 
Added a same-time-of-day volume z-score reading to the dashboard, plus a new alert that fires when unusual participation lines up with a favorable regime.
 
The regime engine tells you WHAT kind of market you're in. The anchored VWAP from v1.2 tells you WHERE fair value sits within it. Neither answers WHO is actually showing up at the current bar. A trending regime on thin volume is a different trade than the same regime on conviction flow — and the z-score is what makes that distinction visible at a glance.
 
Implementation matches the standalone Volume Z-Score Readout: the script tracks the volume seen at each bar's position within the session across the trailing 21 sessions, then computes z = (current volume − same-time-of-day mean) / same-time-of-day stdev. The 09:30 cash open is benchmarked against past 09:30 opens, the lunch lull against past lunch lulls. Volume that's "high" only counts as unusual for that specific moment.
 
New "Volume Z-Score" input group:
 
· Show volume z-score row (default on) — adds a row to the dashboard with the live signed z-score, color-coded by tier: gray for |z| under 1.0, blue for 1.0 to 2.0, orange for 2.0 to 3.0, red for 3.0 and above. Displays "—" until at least 5 sessions of data have accumulated at the current slot.
 
· Sessions for baseline (default 21) — number of past sessions used for the mean and stdev calculation. 21 ≈ one trading month.
 
· High-conviction z threshold (default 2.0) — z-score above which counts as unusual enough to alert.
 
· Alert on high-conviction setups (default on) — fires once when the z-score crosses above the threshold WHILE the regime is TREND or TREND+VOL. Uses the same transition-detection pattern as the regime-change alert, so you won't get spammed on every bar where the condition continues to hold.
 
The dashboard auto-resizes between 7 and 8 rows based on whether the z-score row is shown — toggle it off and the table is identical in layout to v1.2. Existing dashboard position and size preferences carry over unchanged.
 
No changes to the regime classification engine or the anchored VWAP. Percentile scoring, the confirmation buffer, VWAP anchor logic, and the existing regime-change alert all behave identically to v1.2. The z-score is additive — disable it and the indicator behaves exactly as it did before the update.

## Source Code

````pine
//@version=6
// =============================================================
//  Adaptive Market Regime Detector  —  4-State, Self-Calibrating
//  Tuned defaults for index futures (NQ / ES) scalping
//  v1.2: Optional Anchored VWAP that auto-anchors to pivots
//  v1.3: Volume Z-Score (same-time-of-day) for conviction read
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
//  Volume Z-Score: same-time-of-day participation reading.
//      Tells you WHO is showing up at the current bar. Alerts
//      fire on high-conviction setups (high z + favorable regime).
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

grpZScore  = "Volume Z-Score"
showZ      = input.bool(true, "Show volume z-score in dashboard", group=grpZScore)
zSessions  = input.int(21, "Sessions for baseline", minval=5, maxval=100, group=grpZScore, tooltip="Number of past sessions used to compute the same-time-of-day volume mean and standard deviation. 21 ≈ one trading month.")
zThreshold = input.float(2.0, "High-conviction z threshold", minval=1.0, maxval=4.0, step=0.1, group=grpZScore, tooltip="Z-score above which counts as 'high conviction' for the alert. 2.0 = roughly the top 2-3% of bars at this time of day.")
zAlertOn   = input.bool(true, "Alert on high-conviction setups", group=grpZScore, tooltip="Fires when the z-score crosses above the threshold while the regime is TREND or TREND+VOL. The setup that combines unusual participation with a favorable regime.")

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

// ---------- Volume Z-Score (same-time-of-day) ----------
// Tracks each bar's position within the session ("slot") and maintains
// a rolling history of the volume seen at THAT EXACT slot across the
// trailing N sessions. The z-score is computed against the same-time-of-day
// mean and stdev — so the 09:30 cash open is compared against past 09:30
// opens, not against the lunch lull or the close. This is what makes
// "unusual volume" meaningful intraday.

// Pine v6 doesn't allow nesting collections inside collections (no
// map<int, array<float>>), so we wrap the per-slot volume array in a
// tiny user-defined type and store THAT in the map.
type VolHist
    array<float> vols

var map<int, VolHist> volHistory = map.new<int, VolHist>()
var int sessionSlot = 0

newSession = ta.change(time("D")) != 0
sessionSlot := newSession ? 0 : sessionSlot + 1

// Make sure this slot has a history wrapper.
if not map.contains(volHistory, sessionSlot)
    hist = VolHist.new()
    hist.vols := array.new<float>(0)
    map.put(volHistory, sessionSlot, hist)

slotHist = map.get(volHistory, sessionSlot)
slotArr  = slotHist.vols

// Compute z-score against history BEFORE adding current bar's volume.
zScore = 0.0
zValid = false
if array.size(slotArr) >= 5
    zMean  = array.avg(slotArr)
    zStdev = array.stdev(slotArr)
    if zStdev > 0
        zScore := (volume - zMean) / zStdev
        zValid := true

// Append current bar's volume to the slot's history (cap at zSessions).
array.push(slotArr, volume)
if array.size(slotArr) > zSessions
    array.shift(slotArr)

// Color tiers for z-score display, based on |z|.
zAbs    = math.abs(zScore)
zCol    = not zValid ? #8b949e : zAbs >= 3.0 ? #f85149 : zAbs >= 2.0 ? #f0883e : zAbs >= 1.0 ? #58a6ff : #8b949e
zLabel  = not zValid ? "—" : (zScore >= 0 ? "+" : "") + str.tostring(zScore, "#.0")

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

// Row count adapts to whether z-score row is shown.
dashRows = showZ ? 8 : 7

var table dash = na
if showDash
    pos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
    dash := table.new(pos, 2, dashRows, bgcolor=#0b1220, border_color=#2a3140, border_width=1, frame_color=#2a3140, frame_width=1)

if barstate.islast and showDash
    table.cell(dash, 0, 0, "REGIME DETECTOR", text_color=#8b949e, text_size=szHead, text_halign=text.align_left)
    table.cell(dash, 1, 0, "", bgcolor=#0b1220)
    table.cell(dash, 0, 1, "State", text_color=#e6edf3, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, 1, regimeShort, text_color=#ffffff, bgcolor=color.new(regimeCol, 70), text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Trend score", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(math.round(trendScore)) + (isTrend ? " ▲" : ""), text_color=isTrend ? #3fb950 : #8b949e, text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Volatility", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(volScore)) + (isVol ? " ▲" : ""), text_color=isVol ? #f0883e : #8b949e, text_size=szData, text_halign=text.align_right)
    // Optional Volume Z row sits between Volatility and Direction.
    // When showZ is off, the rows below shift up by one to keep the table compact.
    rowDir  = showZ ? 5 : 4
    rowConf = showZ ? 6 : 5
    rowNote = showZ ? 7 : 6
    if showZ
        table.cell(dash, 0, 4, "Volume Z", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
        table.cell(dash, 1, 4, zLabel, text_color=zCol, text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, rowDir, "Direction", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, rowDir, up ? "Up +" : "Down −", text_color=up ? #3fb950 : #f85149, text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, rowConf, "Confidence", text_color=#8b949e, text_size=szData, text_halign=text.align_left)
    table.cell(dash, 1, rowConf, str.tostring(confidence) + "%", text_color=#e6edf3, text_size=szData, text_halign=text.align_right)
    table.cell(dash, 0, rowNote, scalpNote, text_color=#58a6ff, text_size=szNote, text_halign=text.align_left)
    table.cell(dash, 1, rowNote, "", bgcolor=#0b1220)

// ---------- Alerts ----------
regimeChanged = regime != regime[1]
if alertOn and regimeChanged and barstate.isconfirmed
    alert("Regime change → " + regimeName + " (confidence " + str.tostring(confidence) + "%)", alert.freq_once_per_bar_close)

alertcondition(regime != regime[1], title="Any regime change", message="Market regime changed")

// High-conviction alert: fires on the bar that z-score crosses above the
// threshold WHILE the regime is already trending. Unusual participation
// inside a favorable environment is the setup worth waking up for.
favorableRegime  = regime == 1 or regime == 2
highConvNow      = zValid and zScore > zThreshold and favorableRegime
highConvBefore   = zValid[1] and zScore[1] > zThreshold and (regime[1] == 1 or regime[1] == 2)
highConvFired    = highConvNow and not highConvBefore

if zAlertOn and highConvFired and barstate.isconfirmed
    convRegimeName = regime == 1 ? "TREND+VOL" : "TREND"
    alert("High-conviction setup → " + convRegimeName + " · z=" + str.tostring(zScore, "#.0") + " · confidence " + str.tostring(confidence) + "%", alert.freq_once_per_bar_close)

alertcondition(highConvNow and not highConvBefore, title="High-conviction setup", message="High volume z-score in a trending regime")
````
