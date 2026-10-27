# Delta Heiken Ashi - Reversals

- url: https://www.tradingview.com/script/bFvi5mo5-Delta-Heiken-Ashi-Reversals/
- type: indicator
- pine_id: PUB;ca1ef3904d8a41aa91b50050bfd4a9a2
- version: 2.0

## Description

This indicator identifies significant delta pressure reversals on Heiken Ashi candles, marking where sustained buying or selling runs exhaust and flip.
Built on the same delta-colored Heiken Ashi engine as the original indicator, this version adds filtered reversal markers designed to catch meaningful intraday turning points rather than bar-by-bar momentum reads.
How it works:
The indicator tracks "runs" — consecutive periods where estimated delta stays on one side of zero (net buying or net selling). When a run ends and delta flips, the completed run is evaluated against multiple filters. Only significant reversals get marked.
Three filters must all pass:
Run Duration — The prior run must last a minimum number of bars. Brief delta spikes don't count.
Swing Size — Peak delta during the run must exceed a threshold relative to recent delta activity. Weak, indecisive runs are filtered out.
Run Volume — The run's average volume per bar must meet a minimum fraction of the overall average volume. This naturally filters thin overnight sessions where delta is noisy and unreliable.
Separate RTH and OVN settings — Regular Trading Hours and overnight sessions have independent thresholds for run duration, swing size, and volume requirements. OVN moves develop slower and on thinner volume, so they need different parameters. Each session can be toggled on or off independently.
⚠️ Important: This is not true delta. Delta is approximated by attributing each bar's volume based on where price closed within its range. This is directionally useful but it is not actual order flow from Level 2 data.
Pairs well with support/resistance levels, market structure indicators, or any framework where knowing when a move is exhausting adds edge.

## Source Code

````pine
// © TatankaTrading
//@version=6
indicator("Delta Heiken Ashi - Reversals", overlay = true, max_labels_count = 500)

// ============================================================================
// INPUTS
// ============================================================================

g_ha = "═══ Heiken Ashi ═══"
i_show = input.bool(true, "Show HA Candles", group = g_ha)

g_delta = "═══ Delta Engine ═══"
i_deltaLen = input.int(4, "Delta EMA Length", minval = 1, maxval = 30, tooltip = "Smoothing on raw delta. Lower = more responsive, noisier.", group = g_delta)
i_momLen   = input.int(6, "Momentum SMA Length", minval = 2, maxval = 30, tooltip = "Delta's own moving average for momentum classification.", group = g_delta)

g_signals = "═══ Reversal Signals ═══"
i_showSig    = input.bool(true, "Show Reversal Markers", group = g_signals)
i_waitClose  = input.bool(false, "Wait for Bar Close", tooltip = "When enabled, signals only appear after the bar closes. Prevents repainting.", group = g_signals)
i_minBars    = input.int(5, "Min Run Duration (bars)", minval = 2, maxval = 30, group = g_signals)
i_minSwing   = input.float(0.7, "Min Swing Size (0-1)", minval = 0.1, maxval = 0.9, step = 0.05, group = g_signals)
i_minRunVol  = input.float(0.5, "Min Run Volume (0-1)", minval = 0.1, maxval = 2.0, step = 0.1, tooltip = "Run's average volume per bar must exceed this fraction of the overall average volume. Higher = filters thin sessions harder.", group = g_signals)
i_volBaseline = input.int(100, "Volume Baseline Length", minval = 20, maxval = 500, tooltip = "Lookback for overall average volume. Use enough bars to span RTH + OVN so OVN runs are measured against RTH-scale activity.", group = g_signals)
i_rthOnly    = input.bool(true, "RTH Signals Only", tooltip = "Suppress signals outside Regular Trading Hours.", group = g_signals)
i_rthStart   = input.session("0830-1500", "RTH Session", group = g_signals)
i_sigClr     = input.color(color.rgb(255, 230, 0), "Marker Color", group = g_signals)
i_alerts     = input.bool(true, "Enable Alerts", group = g_signals)

g_bear = "═══ Bear Colors ═══"
i_bearStrong = input.color(color.rgb(200, 25, 25),   "Strong",   inline = "b", group = g_bear)
i_bearMod    = input.color(color.rgb(170, 80, 90),    "Moderate", inline = "b", group = g_bear)
i_bearFade   = input.color(color.rgb(140, 120, 130),  "Fading",   inline = "b", group = g_bear)

g_bull = "═══ Bull Colors ═══"
i_bullStrong = input.color(color.rgb(0, 180, 255),    "Strong",   inline = "u", group = g_bull)
i_bullMod    = input.color(color.rgb(60, 130, 175),   "Moderate", inline = "u", group = g_bull)
i_bullFade   = input.color(color.rgb(110, 140, 155),  "Fading",   inline = "u", group = g_bull)

// ============================================================================
// HEIKEN ASHI
// ============================================================================

var float haClose = na
var float haOpen  = na

haClose := (open + high + low + close) / 4.0
haOpen  := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0

float haHigh    = math.max(high, math.max(haOpen, haClose))
float haLow     = math.min(low, math.min(haOpen, haClose))
bool  is_haBear = haClose < haOpen

// ============================================================================
// DELTA ENGINE
// ============================================================================

float barRange = high - low
float deltaRaw = barRange > 0 ? volume * ((close - open) / barRange) : 0.0
float delta    = ta.ema(deltaRaw, i_deltaLen)
float deltaMa  = ta.sma(delta, i_momLen)

float maGap    = delta - deltaMa
float maGapMax = ta.highest(math.abs(maGap), i_momLen * 5)
float maGapPct = maGapMax > 0 ? maGap / maGapMax : 0.0

// ============================================================================
// 3-TIER STATE CLASSIFICATION
// ============================================================================

bool is_contrary = is_haBear ? (delta > 0) : (delta < 0)
bool is_accel    = is_haBear ? (maGapPct < -0.15) : (maGapPct > 0.15)
bool is_decel    = is_haBear ? (maGapPct > 0.15) : (maGapPct < -0.15)

var int state = 1
if is_contrary or is_decel
    state := 0
else if is_accel
    state := 2
else
    state := 1

// ============================================================================
// DELTA RUN TRACKING (with volume accumulation)
// ============================================================================

bool curSide = delta >= 0

var bool  runSide   = true
var int   runLen    = 0
var float runPeak   = 0.0
var float runVolSum = 0.0

bool didFlip = bar_index > 0 and curSide != runSide

// Snapshot completed run metrics before reset
float completedPeak   = didFlip ? runPeak   : 0.0
int   completedLen    = didFlip ? runLen    : 0
float completedVolAvg = didFlip and runLen > 0 ? runVolSum / runLen : 0.0

if didFlip
    runSide   := curSide
    runLen    := 1
    runPeak   := math.abs(delta)
    runVolSum := volume
else
    runLen    += 1
    runPeak   := math.max(runPeak, math.abs(delta))
    runVolSum += volume

// ============================================================================
// SIGNAL FILTERS
// ============================================================================

// --- Swing size: peak delta during run vs recent delta range ---
float recentDeltaRange = ta.highest(math.abs(delta), 60)
float peakThreshold    = recentDeltaRange * i_minSwing

bool passesSwing = didFlip and completedLen >= i_minBars and completedPeak >= peakThreshold

// --- Run volume: avg volume per bar during the run vs overall avg volume ---
float volBaseline  = ta.sma(volume, i_volBaseline)
float volThreshold = volBaseline * i_minRunVol

bool passesVol = completedVolAvg >= volThreshold

// --- RTH filter ---
bool is_inRTH  = not na(time(timeframe.period, i_rthStart))
bool passesRTH = not i_rthOnly or is_inRTH

// --- Bar close filter ---
bool passesClose = not i_waitClose or barstate.isconfirmed

// --- Combined ---
bool showBullX = passesSwing and passesVol and passesRTH and passesClose and curSide
bool showBearX = passesSwing and passesVol and passesRTH and passesClose and not curSide

// ============================================================================
// COLOR
// ============================================================================

color bearClr  = state == 2 ? i_bearStrong : state == 1 ? i_bearMod : i_bearFade
color bullClr  = state == 2 ? i_bullStrong : state == 1 ? i_bullMod : i_bullFade
color finalClr = is_haBear ? bearClr : bullClr

// ============================================================================
// PLOT
// ============================================================================

barcolor(i_show ? color.new(color.black, 100) : na)

plotcandle(
     i_show ? haOpen  : na,
     i_show ? haHigh  : na,
     i_show ? haLow   : na,
     i_show ? haClose : na,
     title       = "Delta HA",
     color       = finalClr,
     wickcolor   = finalClr,
     bordercolor = finalClr)

// ─── Reversal Markers ───────────────────────────────────────────────
MARKER_OFFSET = ta.atr(14) * 0.5

plotshape(
     i_showSig and showBullX ? haLow - MARKER_OFFSET : na,
     title    = "Bull Reversal",
     style    = shape.xcross,
     location = location.absolute,
     color    = i_sigClr,
     size     = size.small)

plotshape(
     i_showSig and showBearX ? haHigh + MARKER_OFFSET : na,
     title    = "Bear Reversal",
     style    = shape.xcross,
     location = location.absolute,
     color    = i_sigClr,
     size     = size.small)

// ============================================================================
// ALERTS
// ============================================================================

if i_alerts and showBullX
    alert("DELTA HA — Significant bull reversal @ " + str.tostring(close, format.mintick) + " | Run: " + str.tostring(completedLen) + " bars", alert.freq_once_per_bar)

if i_alerts and showBearX
    alert("DELTA HA — Significant bear reversal @ " + str.tostring(close, format.mintick) + " | Run: " + str.tostring(completedLen) + " bars", alert.freq_once_per_bar)
````
