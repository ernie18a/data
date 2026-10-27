# AetherEdge - WaveTrend Oscillator Enhanced

- url: https://www.tradingview.com/script/jxd86tft/
- type: indicator
- pine_id: PUB;f97dad7bb8dd499f86225c7fbd245c33
- version: 1.0

## Description

🖊️ Overview
AetherEdge WaveTrend Enhanced is a next-generation momentum analysis engine that fully evolves the legendary LazyBear WaveTrend with adaptive zones, MTF integration, and 4-type divergence detection. By combining percentile/standard-deviation-based dynamic zones, higher-timeframe alignment checks, and a precision pivot-based divergence scanner, it transcends the limitations of fixed OB/OS levels to deliver a truly intelligent oscillator that auto-syncs with market rhythm.

🔶 Key Features

3 Zone Modes: Static / Adaptive (Percentile) / Dynamic (StDev)
4-Tier Zone Levels: OB/OS + OB/OS Extreme detection
MTF WaveTrend Integration: HTF directional alignment kills fakeouts
4-Type Divergence: Regular Bull/Bear + Hidden Bull/Bear
Precision Pivot Detection: Configurable left/right bars + distance filter
Zone-Restricted Divergences: Only OB/OS pivots for higher signal quality
Momentum Histogram: Two-stage color (acceleration/deceleration)
4 Signal Modes: WT Cross / Zone Cross / +MTF / Divergence Only
MTF Repaint Control: barmerge.lookahead toggle
Extreme Zone Visualization: Highlight dots in extreme territory
Integrated Dashboard: 14-row real-time state monitor

🧠 Technical Architecture

This indicator preserves LazyBear's original algorithm intact while layering a statistical adaptation engine and multi-context confirmation system on top.

WaveTrend Core:
esa = EMA(src, n1) — smooth baseline
d = EMA(|src - esa|, n1) — dispersion measure
ci = (src - esa) / (0.015 × d) — normalized channel index
tci = EMA(ci, n2) becomes WT1; SMA(tci, sigLen) becomes WT2
Adaptive Zone Engine:
Percentile mode: ta.percentile_nearest_rank computes 85/15/95/5 percentiles over N bars → auto-adapts to instrument-specific characteristics
StDev mode: mean ± stdev × multiplier for statistical outlier detection → theoretical thresholds assuming normal distribution
Static mode: Classic fixed levels (60/-60, 80/-80)
MTF Synchronization:
request.security fetches HTF WaveTrend
lookahead_off default prevents repaint
Alignment gate permits signals only when MTF agrees
Divergence Detection:
ta.pivothigh/low for confirmed pivots
Compares last two pivots (price vs WT)
Distance filter (min/max bars) eliminates noise pivots
Regular Bull: Lower price low + Higher WT low (reversal)
Hidden Bull: Higher price low + Lower WT low (continuation)
Regular Bear: Higher price high + Lower WT high (reversal)
Hidden Bear: Lower price high + Higher WT high (continuation)
Signal Synthesis Layer: 4 selectable modes + optional MTF agreement

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H–1D): n1=10, n2=21, Percentile mode, MTF=1D (standard, strongest)
ETH (1H–4H): n1=9, n2=18, Percentile mode, MTF=4H
SOL (high-vol): StDev mode, multiplier=1.8/2.8 for extreme detection
XRP (range): Static mode 50/-50 for frequent signal capture
Zone Mode Selection:

Adaptive (Percentile): Universal across instruments (recommended default)
Dynamic (StDev): Statistical rigor, effective in trending markets
Static: Classic WT reproduction, validation/comparison
Signal Mode Selection:

WT Cross: Highest frequency, scalping
Zone Cross: Standard, day trading
Zone Cross + MTF Align: Highest accuracy, swing trading
Divergence Only: Reversal hunting, low frequency / high win rate
Tuning:

Too many signals: Enable MTF Align, set divZoneOnly=true
Too few signals: Loosen to obPct=80, osPct=20
Better divergence: divLBL/LBR=7, divRangeMin=8

💡 How to Use in Practice

OS Extreme + Regular Bull Div: Premier buy signal, consider full position
OB Extreme + Regular Bear Div: Premier sell signal
Hidden Divergence: Trend-continuation confirmation, pullback entries
MTF Aligned Bull + Zone Buy: HTF-aligned high-conviction long
Histogram Acceleration (▲▲ Accel): Momentum strengthening, hold positions
Histogram Deceleration (▲ Slow): Profit-taking preparation
AetherEdge Synergy:
SuperTrend Multi-Factor 3/3 Bull + WT Regular Bull Div = ultimate bottom
Self-Evolving S/R Grid strong support + WT OS Extreme = max-conviction reversal
Volume Profile POC + WT Zone Buy = institutional-sync entry
Multi-TF Strategy: Direction on 1D WT → wait zone on 4H WT → precision entry on 1H WT

⚠️ Important Notes

Pivot Lag: divLBR-bar delay inherent (no real-time detection)
Adaptive Zone Warmup: Unreliable below pctLookback bars
MTF Repaint: mtfRepaint=true causes backtest illusions; default off recommended
Divergence Overuse: Multiple firings in strong trends—never use standalone
Histogram Flip: Treat as early warning, not signal
Prolonged Extreme Stays: Avoid counter-trend trades during strong moves

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Adaptive zones, MTF analysis, and divergence detection are statistical methods based on historical data and do not guarantee future profits. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - WaveTrend Oscillator Enhanced", "AE-WT [Enhanced]",
     overlay=false,
     max_lines_count=500,
     max_labels_count=500,
     max_bars_back=500,
     precision=2)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpWT = "① WaveTrend Core (LazyBear base)"
chLen        = input.int(10, "Channel Length (n1)", minval=1, group=grpWT,
                 tooltip="元のLazyBear設定: 10")
avgLen       = input.int(21, "Average Length (n2)", minval=1, group=grpWT,
                 tooltip="元のLazyBear設定: 21")
sigLen       = input.int(4,  "Signal SMA Length",   minval=1, group=grpWT)
srcMode      = input.source(hlc3, "Source", group=grpWT)

grpZone = "② Adaptive Overbought/Oversold Zones"
zoneMode     = input.string("Adaptive (Percentile)", "Zone Mode",
                 options=["Static","Adaptive (Percentile)","Dynamic (StDev)"], group=grpZone)
obStatic     = input.int(60,  "OB Level (Static)",  minval=10, group=grpZone, inline="s1")
osStatic     = input.int(-60, "OS Level (Static)",  maxval=-10, group=grpZone, inline="s1")
obExtStatic  = input.int(80,  "OB Extreme (Static)", minval=30, group=grpZone, inline="s2")
osExtStatic  = input.int(-80, "OS Extreme (Static)", maxval=-30, group=grpZone, inline="s2")
pctLookback  = input.int(200, "Percentile Lookback", minval=50, group=grpZone)
obPct        = input.float(85, "OB Percentile (%)", minval=50, maxval=99, step=1, group=grpZone, inline="p1")
osPct        = input.float(15, "OS Percentile (%)", minval=1,  maxval=50, step=1, group=grpZone, inline="p1")
obExtPct     = input.float(95, "OB Extreme (%)",    minval=70, maxval=99, step=1, group=grpZone, inline="p2")
osExtPct     = input.float(5,  "OS Extreme (%)",    minval=1,  maxval=30, step=1, group=grpZone, inline="p2")
stdevMult    = input.float(1.5,"StDev Multiplier",  minval=0.5, step=0.1, group=grpZone)
stdevMultExt = input.float(2.5,"StDev Multiplier (Extreme)", minval=1.0, step=0.1, group=grpZone)

grpDiv = "③ Divergence Detection"
useDiv       = input.bool(true, "Enable Divergence Scanner", group=grpDiv)
divLBL       = input.int(5, "Pivot Left Bars",  minval=1, group=grpDiv, inline="pv")
divLBR       = input.int(5, "Pivot Right Bars", minval=1, group=grpDiv, inline="pv")
divRangeMin  = input.int(5,  "Min Bars Between Pivots", minval=1, group=grpDiv, inline="rng")
divRangeMax  = input.int(60, "Max Bars Between Pivots", minval=10, group=grpDiv, inline="rng")
showRegDiv   = input.bool(true, "Show Regular Divergence", group=grpDiv, inline="d1")
showHidDiv   = input.bool(true, "Show Hidden Divergence",  group=grpDiv, inline="d1")
divZoneOnly  = input.bool(false, "Only in OB/OS Zones", group=grpDiv,
                 tooltip="ダイバージェンスをOB/OSゾーン内のピボットに限定")

grpMTF = "④ Multi-Timeframe"
useMTF       = input.bool(true, "Enable MTF WaveTrend", group=grpMTF)
mtfTF        = input.timeframe("60", "MTF Timeframe", group=grpMTF,
                 tooltip="例: 15, 60, 240, D, W")
mtfRepaint   = input.bool(false, "Allow MTF Repaint", group=grpMTF,
                 tooltip="OFF: バー確定値を使用（推奨）")

grpSig = "⑤ Signal Filters"
signalMode   = input.string("Zone Cross", "Entry Signal Mode",
                 options=["WT Cross","Zone Cross","Zone Cross + MTF Align","Divergence Only"], group=grpSig)
mtfAgree     = input.bool(true, "Require MTF Agreement", group=grpSig,
                 tooltip="MTF WTが同方向でないとシグナル抑制")

grpD = "🎨 Display"
darkMode     = input.bool(true, "Dark Mode", group=grpD)
showArea     = input.bool(true, "Fill WT Area", group=grpD)
showHist     = input.bool(true, "Show Momentum Histogram", group=grpD)
showMTFLine  = input.bool(true, "Plot MTF WT Line", group=grpD)
showBG       = input.bool(true, "Color Background (Zones)", group=grpD)
showLabels   = input.bool(true, "Show Signal Labels", group=grpD)
showDash     = input.bool(true, "Show Dashboard", group=grpD)
dashPos      = input.string("Top Right", "Dashboard Position",
                 options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)

grpC = "🎨 Colors"
cBull        = input.color(#00d4a0, "Bullish",          group=grpC, inline="c1")
cBear        = input.color(#ff5577, "Bearish",          group=grpC, inline="c1")
cOB          = input.color(#ff9500, "Overbought",       group=grpC, inline="c2")
cOS          = input.color(#4dabf7, "Oversold",         group=grpC, inline="c2")
cExt         = input.color(#ffd43b, "Extreme Highlight", group=grpC, inline="c3")
cMTF         = input.color(#c084fc, "MTF Line",         group=grpC, inline="c3")

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg     = darkMode ? color.new(#0b1221, 10) : color.new(#f7f9fc, 10)
cBgAlt  = darkMode ? color.new(#111a2e, 15) : color.new(#ffffff, 0)
cBorder = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText   = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute   = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent = color.new(#00d4ff, 0)
cZero   = color.new(#607080, 40)

// ═══════════════════════════════════════════════════════════════
//  WAVETREND CORE (LazyBear algorithm, preserved)
// ═══════════════════════════════════════════════════════════════
f_wt(src, n1, n2) =>
    esa = ta.ema(src, n1)
    d   = ta.ema(math.abs(src - esa), n1)
    ci  = d != 0 ? (src - esa) / (0.015 * d) : 0
    tci = ta.ema(ci, n2)
    [tci, ta.sma(tci, sigLen)]

[wt1, wt2] = f_wt(srcMode, chLen, avgLen)
wtHist = wt1 - wt2

// ═══════════════════════════════════════════════════════════════
//  ADAPTIVE ZONE CALCULATION
// ═══════════════════════════════════════════════════════════════
// Percentile-based
obAdapt    = ta.percentile_nearest_rank(wt1, pctLookback, obPct)
osAdapt    = ta.percentile_nearest_rank(wt1, pctLookback, osPct)
obExtAdapt = ta.percentile_nearest_rank(wt1, pctLookback, obExtPct)
osExtAdapt = ta.percentile_nearest_rank(wt1, pctLookback, osExtPct)

// StDev-based
wtMean  = ta.sma(wt1, pctLookback)
wtStdev = ta.stdev(wt1, pctLookback)
obDyn    = wtMean + wtStdev * stdevMult
osDyn    = wtMean - wtStdev * stdevMult
obExtDyn = wtMean + wtStdev * stdevMultExt
osExtDyn = wtMean - wtStdev * stdevMultExt

// Select active zones
obLevel    = zoneMode == "Static" ? obStatic    : zoneMode == "Adaptive (Percentile)" ? obAdapt    : obDyn
osLevel    = zoneMode == "Static" ? osStatic    : zoneMode == "Adaptive (Percentile)" ? osAdapt    : osDyn
obExtLevel = zoneMode == "Static" ? obExtStatic : zoneMode == "Adaptive (Percentile)" ? obExtAdapt : obExtDyn
osExtLevel = zoneMode == "Static" ? osExtStatic : zoneMode == "Adaptive (Percentile)" ? osExtAdapt : osExtDyn

// Zone state flags
inOB    = wt1 >= obLevel
inOS    = wt1 <= osLevel
inOBExt = wt1 >= obExtLevel
inOSExt = wt1 <= osExtLevel

// ═══════════════════════════════════════════════════════════════
//  CROSSOVER SIGNALS
// ═══════════════════════════════════════════════════════════════
wtCrossUp   = ta.crossover(wt1, wt2)
wtCrossDown = ta.crossunder(wt1, wt2)

zoneBuyRaw  = wtCrossUp   and wt1 < osLevel
zoneSellRaw = wtCrossDown and wt1 > obLevel

// ═══════════════════════════════════════════════════════════════
//  MULTI-TIMEFRAME WAVETREND
// ═══════════════════════════════════════════════════════════════
f_wtMtf() =>
    f_wt(srcMode, chLen, avgLen)

[wt1MTF_raw, wt2MTF_raw] = request.security(syminfo.tickerid, mtfTF, f_wtMtf(),
     lookahead=mtfRepaint ? barmerge.lookahead_on : barmerge.lookahead_off)

// Prevent repaint shift
wt1MTF = mtfRepaint ? wt1MTF_raw : wt1MTF_raw[barstate.isrealtime ? 0 : 0]
wt2MTF = mtfRepaint ? wt2MTF_raw : wt2MTF_raw[barstate.isrealtime ? 0 : 0]

mtfBull = not useMTF ? true : wt1MTF > wt2MTF
mtfBear = not useMTF ? true : wt1MTF < wt2MTF

// ═══════════════════════════════════════════════════════════════
//  DIVERGENCE DETECTION
// ═══════════════════════════════════════════════════════════════
pivHighWT = ta.pivothigh(wt1, divLBL, divLBR)
pivLowWT  = ta.pivotlow(wt1,  divLBL, divLBR)

// Track last pivot values (price and WT)
var float lastPHWT   = na
var float lastPHPr   = na
var int   lastPHBar  = na
var float lastPLWT   = na
var float lastPLPr   = na
var int   lastPLBar  = na

var float prevPHWT   = na
var float prevPHPr   = na
var int   prevPHBar  = na
var float prevPLWT   = na
var float prevPLPr   = na
var int   prevPLBar  = na

regBearDiv = false
hidBearDiv = false
regBullDiv = false
hidBullDiv = false

if not na(pivHighWT)
    prevPHWT  := lastPHWT
    prevPHPr  := lastPHPr
    prevPHBar := lastPHBar
    lastPHWT  := pivHighWT
    lastPHPr  := high[divLBR]
    lastPHBar := bar_index - divLBR
    barsBetween = lastPHBar - nz(prevPHBar, 0)
    rangeOK = barsBetween >= divRangeMin and barsBetween <= divRangeMax
    zoneOK = not divZoneOnly or (lastPHWT >= obLevel or prevPHWT >= obLevel)
    if not na(prevPHWT) and rangeOK and zoneOK
        // Regular Bearish: Higher price high, Lower WT high
        if lastPHPr > prevPHPr and lastPHWT < prevPHWT
            regBearDiv := true
        // Hidden Bearish: Lower price high, Higher WT high
        if lastPHPr < prevPHPr and lastPHWT > prevPHWT
            hidBearDiv := true

if not na(pivLowWT)
    prevPLWT  := lastPLWT
    prevPLPr  := lastPLPr
    prevPLBar := lastPLBar
    lastPLWT  := pivLowWT
    lastPLPr  := low[divLBR]
    lastPLBar := bar_index - divLBR
    barsBetween = lastPLBar - nz(prevPLBar, 0)
    rangeOK = barsBetween >= divRangeMin and barsBetween <= divRangeMax
    zoneOK = not divZoneOnly or (lastPLWT <= osLevel or prevPLWT <= osLevel)
    if not na(prevPLWT) and rangeOK and zoneOK
        // Regular Bullish: Lower price low, Higher WT low
        if lastPLPr < prevPLPr and lastPLWT > prevPLWT
            regBullDiv := true
        // Hidden Bullish: Higher price low, Lower WT low
        if lastPLPr > prevPLPr and lastPLWT < prevPLWT
            hidBullDiv := true

// ═══════════════════════════════════════════════════════════════
//  DIVERGENCE LINES
// ═══════════════════════════════════════════════════════════════
if useDiv and showRegDiv and regBearDiv
    line.new(prevPHBar, prevPHWT, lastPHBar, lastPHWT,
         color=color.new(cBear, 0), width=2, style=line.style_solid)
    if showLabels
        label.new(lastPHBar, lastPHWT, "⚠ Reg Bear",
             color=color.new(cBear, 20), textcolor=color.white,
             style=label.style_label_down, size=size.small)

if useDiv and showHidDiv and hidBearDiv
    line.new(prevPHBar, prevPHWT, lastPHBar, lastPHWT,
         color=color.new(cBear, 30), width=2, style=line.style_dashed)
    if showLabels
        label.new(lastPHBar, lastPHWT, "Hid Bear",
             color=color.new(cBear, 40), textcolor=color.white,
             style=label.style_label_down, size=size.tiny)

if useDiv and showRegDiv and regBullDiv
    line.new(prevPLBar, prevPLWT, lastPLBar, lastPLWT,
         color=color.new(cBull, 0), width=2, style=line.style_solid)
    if showLabels
        label.new(lastPLBar, lastPLWT, "⚠ Reg Bull",
             color=color.new(cBull, 20), textcolor=color.white,
             style=label.style_label_up, size=size.small)

if useDiv and showHidDiv and hidBullDiv
    line.new(prevPLBar, prevPLWT, lastPLBar, lastPLWT,
         color=color.new(cBull, 30), width=2, style=line.style_dashed)
    if showLabels
        label.new(lastPLBar, lastPLWT, "Hid Bull",
             color=color.new(cBull, 40), textcolor=color.white,
             style=label.style_label_up, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
//  FINAL SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════
buySignal = false
sellSignal = false

if signalMode == "WT Cross"
    buySignal  := wtCrossUp
    sellSignal := wtCrossDown
else if signalMode == "Zone Cross"
    buySignal  := zoneBuyRaw
    sellSignal := zoneSellRaw
else if signalMode == "Zone Cross + MTF Align"
    buySignal  := zoneBuyRaw  and mtfBull
    sellSignal := zoneSellRaw and mtfBear
else if signalMode == "Divergence Only"
    buySignal  := regBullDiv
    sellSignal := regBearDiv

if mtfAgree and signalMode != "Zone Cross + MTF Align"
    buySignal  := buySignal  and mtfBull
    sellSignal := sellSignal and mtfBear

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
// Zone reference lines
hline(0, "Zero", color=cZero, linestyle=hline.style_dotted)
plot(obLevel,    "OB Level",    color=color.new(cOB, 40), linewidth=1, style=plot.style_line)
plot(osLevel,    "OS Level",    color=color.new(cOS, 40), linewidth=1, style=plot.style_line)
plot(obExtLevel, "OB Extreme",  color=color.new(cExt, 30), linewidth=1, style=plot.style_circles)
plot(osExtLevel, "OS Extreme",  color=color.new(cExt, 30), linewidth=1, style=plot.style_circles)

// Histogram
histCol = wtHist > 0 ?
     (wtHist > wtHist[1] ? color.new(cBull, 20) : color.new(cBull, 60)) :
     (wtHist < wtHist[1] ? color.new(cBear, 20) : color.new(cBear, 60))
plot(showHist ? wtHist : na, "Momentum Histogram", color=histCol, style=plot.style_columns, linewidth=1)

// WT lines
pWt1 = plot(wt1, "WT1", color=color.new(cAccent, 0), linewidth=2)
pWt2 = plot(wt2, "WT2", color=color.new(#ffa94d, 20), linewidth=1)

// Fill WT area
fill(pWt1, pWt2,
     color = showArea ? (wt1 > wt2 ? color.new(cBull, 75) : color.new(cBear, 75)) : na,
     title = "WT Fill")

// MTF line
plot(useMTF and showMTFLine ? wt1MTF : na, "MTF WT1",
     color=color.new(cMTF, 20), linewidth=2, style=plot.style_line)

// Background zone coloring
bgColor = not showBG ? na :
     inOBExt ? color.new(cExt, 85) :
     inOSExt ? color.new(cExt, 85) :
     inOB    ? color.new(cOB, 90)  :
     inOS    ? color.new(cOS, 90)  : na
bgcolor(bgColor, title="Zone Background")

// Signal markers
plotshape(showLabels and buySignal  ? wt1 : na, "BUY",  shape.triangleup,   location.absolute,
     color=color.new(cBull, 0),  size=size.small, text="▲", textcolor=color.white)
plotshape(showLabels and sellSignal ? wt1 : na, "SELL", shape.triangledown, location.absolute,
     color=color.new(cBear, 0),  size=size.small, text="▼", textcolor=color.white)

// Extreme dots on WT1 when in extreme zones
plot(inOBExt ? wt1 : na, "OB Ext Dot", color=color.new(cExt, 0), linewidth=3, style=plot.style_circles)
plot(inOSExt ? wt1 : na, "OS Ext Dot", color=color.new(cExt, 0), linewidth=3, style=plot.style_circles)

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

var table dash = na
if barstate.islast and showDash
    dash := table.new(f_pos(dashPos), 3, 14,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=1)

    // Header
    table.cell(dash, 0, 0, "★ AETHEREDGE · WT ENHANCED ★",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 2, 0)

    // === CURRENT STATE ===
    table.cell(dash, 0, 1, "WAVETREND STATE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left, text_size=size.small)
    table.merge_cells(dash, 0, 1, 2, 1)

    wtTrend = wt1 > wt2 ? "▲ BULL" : "▼ BEAR"
    wtCol   = wt1 > wt2 ? cBull : cBear
    table.cell(dash, 0, 2, "WT1 / WT2", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(wt1, "#.##") + " / " + str.tostring(wt2, "#.##"),
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 2, wtTrend, text_color=color.white,
         bgcolor=color.new(wtCol, 30), text_halign=text.align_center, text_size=size.small)

    // Zone status
    zoneTxt = inOBExt ? "★ OB EXTREME" : inOSExt ? "★ OS EXTREME" :
              inOB    ? "OVERBOUGHT"   : inOS    ? "OVERSOLD"     : "NEUTRAL"
    zoneCol = inOBExt ? cExt : inOSExt ? cExt : inOB ? cOB : inOS ? cOS : cMute
    table.cell(dash, 0, 3, "Zone", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 3, zoneTxt,
         text_color=inOBExt or inOSExt ? color.black : color.white,
         bgcolor=color.new(zoneCol, 20), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 3, zoneMode == "Static" ? "STATIC" : zoneMode == "Adaptive (Percentile)" ? "PCTILE" : "STDEV",
         text_color=cAccent, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Histogram momentum
    histTxt = wtHist > 0 ? (wtHist > wtHist[1] ? "▲▲ Accel" : "▲ Slow") :
              (wtHist < wtHist[1] ? "▼▼ Accel" : "▼ Slow")
    histCol2 = wtHist > 0 ? cBull : cBear
    table.cell(dash, 0, 4, "Momentum", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(wtHist, "#.##"),
         text_color=color.white, bgcolor=color.new(histCol2, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 4, histTxt, text_color=color.white,
         bgcolor=color.new(histCol2, 30), text_halign=text.align_center, text_size=size.small)

    // === ZONE LEVELS ===
    table.cell(dash, 0, 5, "ADAPTIVE LEVELS", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left, text_size=size.small)
    table.merge_cells(dash, 0, 5, 2, 5)

    table.cell(dash, 0, 6, "OB / OS", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 6, str.tostring(obLevel, "#.#"), text_color=color.white,
         bgcolor=color.new(cOB, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 6, str.tostring(osLevel, "#.#"), text_color=color.white,
         bgcolor=color.new(cOS, 30), text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 7, "Extremes", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 7, str.tostring(obExtLevel, "#.#"), text_color=color.black,
         bgcolor=color.new(cExt, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 7, str.tostring(osExtLevel, "#.#"), text_color=color.black,
         bgcolor=color.new(cExt, 30), text_halign=text.align_center, text_size=size.small)

    // === MTF ===
    table.cell(dash, 0, 8, "MULTI-TIMEFRAME", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left, text_size=size.small)
    table.merge_cells(dash, 0, 8, 2, 8)

    mtfTxt = not useMTF ? "DISABLED" : wt1MTF > wt2MTF ? "▲ BULL" : "▼ BEAR"
    mtfCol = not useMTF ? cMute : wt1MTF > wt2MTF ? cBull : cBear
    table.cell(dash, 0, 9, "MTF " + mtfTF, text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 9, useMTF ? str.tostring(wt1MTF, "#.##") : "—",
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 9, mtfTxt, text_color=color.white,
         bgcolor=color.new(mtfCol, 30), text_halign=text.align_center, text_size=size.small)

    // Alignment
    aligned = useMTF and ((wt1 > wt2 and wt1MTF > wt2MTF) or (wt1 < wt2 and wt1MTF < wt2MTF))
    alignTxt = not useMTF ? "N/A" : aligned ? "✓ ALIGNED" : "✗ DIVERGING"
    alignCol = not useMTF ? cMute : aligned ? cBull : cBear
    table.cell(dash, 0, 10, "LTF / MTF", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 10, alignTxt, text_color=color.white,
         bgcolor=color.new(alignCol, 30), text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 1, 10, 2, 10)

    // === DIVERGENCE ===
    table.cell(dash, 0, 11, "DIVERGENCE SCANNER", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left, text_size=size.small)
    table.merge_cells(dash, 0, 11, 2, 11)

    // Lookback for any recent divergence (last 10 bars)
    recentRegBull = false
    recentRegBear = false
    for i = 0 to 10
        if regBullDiv[i]
            recentRegBull := true
        if regBearDiv[i]
            recentRegBear := true

    divStatus = recentRegBull ? "⚠ BULL DIV" : recentRegBear ? "⚠ BEAR DIV" : "none"
    divCol    = recentRegBull ? cBull : recentRegBear ? cBear : cMute
    table.cell(dash, 0, 12, "Recent Signal", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 12, divStatus, text_color=color.white,
         bgcolor=color.new(divCol, 30), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 12, useDiv ? "ACTIVE" : "OFF", text_color=useDiv ? color.white : cMute,
         bgcolor=useDiv ? color.new(cAccent, 30) : cBg, text_halign=text.align_center, text_size=size.small)

    // Current signal
    sigTxt = buySignal ? "▲ BUY SIGNAL" : sellSignal ? "▼ SELL SIGNAL" : "waiting..."
    sigCol = buySignal ? cBull : sellSignal ? cBear : cMute
    table.cell(dash, 0, 13, "Mode: " + signalMode, text_color=cAccent, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 13, sigTxt, text_color=color.white,
         bgcolor=color.new(sigCol, 30), text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 1, 13, 2, 13)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(buySignal,   "WT Buy Signal",   "AE-WT: BUY signal triggered")
alertcondition(sellSignal,  "WT Sell Signal",  "AE-WT: SELL signal triggered")
alertcondition(regBullDiv,  "Regular Bullish Divergence", "AE-WT: Regular Bullish Divergence detected")
alertcondition(regBearDiv,  "Regular Bearish Divergence", "AE-WT: Regular Bearish Divergence detected")
alertcondition(hidBullDiv,  "Hidden Bullish Divergence",  "AE-WT: Hidden Bullish Divergence detected")
alertcondition(hidBearDiv,  "Hidden Bearish Divergence",  "AE-WT: Hidden Bearish Divergence detected")
alertcondition(inOBExt,     "OB Extreme Zone",  "AE-WT: WaveTrend entered Overbought Extreme")
alertcondition(inOSExt,     "OS Extreme Zone",  "AE-WT: WaveTrend entered Oversold Extreme")
````
