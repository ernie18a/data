# Divergence Stack Scanner [AGPro Series]

- url: https://www.tradingview.com/script/7hSVbN7z-Divergence-Stack-Scanner-AGPro-Series/
- type: indicator
- pine_id: PUB;5bfe6b3a168546d7b913f6dd71295f17
- version: 4.0

## Description

Divergence Stack Scanner [AGPro Series]

🔹 Overview

Divergence Stack Scanner [AGPro Series] scans five independent momentum and volume oscillators simultaneously — RSI, MACD Histogram, CCI, MFI, and OBV — and grades every confirmed pivot by how many of them show regular divergence at the same time. The result is a 0 to 5 STACK score that isolates rare, high-conviction reversal zones which single-divergence tools simply cannot surface.

Most divergence indicators track one oscillator at a time. Strong reversals, however, tend to leave fingerprints across momentum and volume at once. This tool quantifies that confluence in a single, objective number you can act on.

🔸 Unique Edge

What separates this script from the crowded divergence space:

1. Five-oscillator confluence in one engine — not one divergence, five divergences graded together.
2. Strict versus Window classification — a 5/5 STRICT stack (all five on the exact same pivot) is marked with a star flash, while a 5/5 WINDOW stack (all five within a small bar tolerance) is tagged separately. The distinction matters because strict stacks are statistically rarer and sharper.
3. Pressure Zones — a rectangular, SR-style zone is drawn forward from each qualifying pivot, so the reversal level stays visible long after the signal fires.
4. Rolling win-rate panel — the last N decided signals are evaluated N bars forward, and the win percentage is displayed live on the panel.
5. Per-oscillator live state — you see at a glance which oscillators are already in divergence and how long ago they triggered.

🔹 Methodology

Pivots are detected using the standard TradingView pivot method with a configurable lookback (default 5 bars each side, confirmed, non-repainting).

When a pivot is confirmed, the script compares the current pivot price and oscillator value to the previous same-direction pivot:

- Regular bullish divergence: price prints a lower low while the oscillator prints a higher low.
- Regular bearish divergence: price prints a higher high while the oscillator prints a lower high.

This comparison runs independently for RSI, MACD Histogram, CCI, MFI, and OBV. Each oscillator stores the bar index of its most recent divergence. The stack engine then counts how many oscillators have fired within a tolerance window of the current pivot:

- Strict stack (window = 0): all counted oscillators fired on the exact same pivot bar.
- Window stack (window = 1 to N bars): oscillators fired within N bars of each other.

Pressure zones are drawn only when the stack meets a configurable minimum (default 4/5). Zone height is ATR-scaled so it stays proportional across instruments and timeframes. A proximity filter prevents label clutter: once a label is drawn in a given direction, a new label in the same direction within a short window is only drawn if its stack level is strictly higher.

🔸 Signals & Alerts

On-chart signals:
- ★ N/5 STACK label (filled color) — strict same-bar stack at level N.
- N/5 NEAR label (lighter color) — window stack (near-miss of strict).
- Pressure zone rectangle — drawn forward from the pivot for qualifying stacks.

Alerts available:
- 5/5 Strict Stack (bull and bear, separate) — the rarest and sharpest signal.
- Minimum Stack threshold — fires whenever the stack reaches your configured minimum level.

All alerts use alert.freq_once_per_bar_close and include ticker plus timeframe in the message.

🔹 Key Inputs

Core Engine:
- Pivot Lookback — bars each side to confirm a pivot (default 5).
- RSI, MACD, CCI, MFI lengths — standard defaults, all configurable.

Stack Configuration:
- Minimum Stack Level — display threshold (default 3/5).
- Window Tolerance — bar tolerance for near-stacks (default 3).
- Win-Rate Lookback — number of recent signals used for rolling win rate (default 20).
- Win Evaluation Bars — forward bars to decide win or loss (default 10).

Pressure Zones:
- Minimum Stack for Zone (default 4/5) — keeps the chart premium and uncluttered.
- Zone Extend and Height (ATR%) — tune the visual footprint to your taste.
- Max Active Zones — oldest zones are automatically trimmed.

Panel and Theme:
- Location (6 anchors), Dark or Light theme, font size presets.
- Fully brand-consistent AGPro color palette built in.

🔸 How to Use

- Treat 5/5 STRICT stacks as the headline signal. They are rare by construction and typically appear at genuine inflection points.
- Use 4/5 stacks as early-warning context around support, resistance, or higher-timeframe levels.
- Read the per-oscillator live state on the panel. When RSI, MACD, CCI, MFI are all in the same direction and OBV is the last holdout, a full stack is often imminent.
- Pressure zones work well as re-entry or invalidation levels after the initial signal fires.
- The rolling win rate is a sanity check for the current asset and timeframe — if it degrades meaningfully, raise the minimum stack level or widen the pivot lookback.

🔹 Limitations and Transparency

- This is a confluence tool, not a standalone trading system. Divergence by nature can persist in strong trends before any reversal.
- The engine is pivot-based and therefore delayed by the pivot lookback. Labels appear on the bar the pivot is confirmed, not on the pivot itself.
- Win rate is computed on the last N decided signals on the current chart. It is not a backtest, it is an evolving statistic and it does not include slippage, spread, or position sizing.
- Window stacks are lower-confidence than strict stacks by design. The visual distinction is intentional.
- Session-based "Today's Max" uses calendar-day rollover.

🔸 Risk Disclosure

This indicator is a technical analysis tool for research and education. It is not financial advice, not a signal service, and not a trading strategy. Past patterns do not guarantee future behavior. You are solely responsible for your trading decisions, risk management, and position sizing. Always combine any indicator with independent analysis, higher-timeframe context, and strict risk controls.

🔹 Technical Notes

- Pine Script v6, overlay indicator.
- Fully non-repainting. All divergences are evaluated only on confirmed pivots.
- Drawing objects (labels, boxes) are capped to avoid resource overruns.
- MPL 2.0 licensed — open source.

## Source Code

````pine
// -----------------------------------------------------
// Divergence Stack Scanner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.3
//
// Divergence Stack Scanner is a multi-oscillator regular divergence decision
// engine for RSI, MACD Histogram, CCI, MFI, and OBV. It grades confirmed swing
// pivots with a 0-100 readiness score, stack tier, confirmation state, swing
// quality, invalidation level, and follow-through target so traders can judge
// whether divergence confluence is strong enough to matter or just noise.
// v2.1 adds an optional SMT (correlated-pair) divergence module that compares
// the chart symbol against a user-defined correlated symbol. SMT is tracked and
// displayed separately and is NOT added to the 0-5 oscillator stack score.
// v2.2 makes invalidation, follow-through, and expiry terminal outcomes, lets a
// fresh same-side stack replace terminal history, and clarifies panel workflow.
// v2.3 spaces same-side reaction bands without suppressing pivot event labels.
// -----------------------------------------------------

//@version=6
indicator("Divergence Stack Scanner [AGPro Series]",
     shorttitle = "AG Pro DSS",
     overlay = true,
     max_labels_count = 240,
     max_lines_count = 220,
     max_boxes_count = 120)

// -----------------------------------------------------
// Tooltips
// -----------------------------------------------------
const string TT_PIVOT = "Bars on each side required to confirm a price pivot. Higher values reduce noise but confirm later."
const string TT_SENS = "Controls how strict the readiness model is when grading stack confluence, swing quality, confirmation, trend context, and distance from invalidation."
const string TT_MIN_SCORE = "Minimum 0-100 readiness score required before a divergence stack can become READY."
const string TT_CONFIRM = "Pivot Only accepts the confirmed pivot. Close Confirmation requires a close beyond the pivot candle. Strict Close also requires price to reclaim or reject the fast EMA."
const string TT_COOLDOWN = "Minimum bars between same-direction labels. Higher values keep the chart cleaner during dense divergence clusters."
const string TT_MAX_OBJECTS = "Maximum labels, connectors, and decision bands kept visible. Older objects are deleted first."
const string TT_BANDS = "Draws a finite decision band around high-quality regular divergence stacks. These are stack reaction bands, not generic level boxes."
const string TT_LIFECYCLE = "Shows separate invalidation and follow-through labels. Disabled by default because the active event label and alerts already carry the context."
const string TT_PANEL = "Shows or hides the compact AGPro summary panel. Default is enabled for publication readability."
const string TT_PANEL_LOC = "Location of the compact AGPro planning panel."
const string TT_THEME = "Selects a dark or light panel theme while preserving the standard AGPro blue header row."
const string TT_FONT = "Controls table or label text size. Normal is the publication default."
const string TT_SMT = "Optional module. Compares this chart against a correlated symbol for SMT-style divergence (one makes a new high or low, the other does not). SMT is tracked separately and is NOT added to the 0-5 oscillator stack score."
const string TT_SMT_SYM = "The correlated symbol to compare against, for example a sister pair like XAGUSD for an XAUUSD chart, or US30 for a NAS100 chart."
const string TT_SMT_CORR = "Positive for normally same-direction pairs (XAUUSD and XAGUSD, NAS100 and US30). Inverse for normally opposite pairs (for example an index versus a safe-haven)."

// -----------------------------------------------------
// Inputs
// -----------------------------------------------------
grpCore = "Core Engine"
pivotLen = input.int(5, "Pivot Lookback", minval = 2, maxval = 20, group = grpCore, tooltip = TT_PIVOT)
rsiLen = input.int(14, "RSI Length", minval = 2, group = grpCore, tooltip = "RSI length used for the regular divergence stack.")
macdFast = input.int(12, "MACD Fast", minval = 1, group = grpCore, tooltip = "Fast EMA length used by the MACD Histogram divergence leg.")
macdSlow = input.int(26, "MACD Slow", minval = 1, group = grpCore, tooltip = "Slow EMA length used by the MACD Histogram divergence leg.")
macdSig = input.int(9, "MACD Signal", minval = 1, group = grpCore, tooltip = "Signal length used by the MACD Histogram divergence leg.")
cciLen = input.int(20, "CCI Length", minval = 2, group = grpCore, tooltip = "CCI length used for the regular divergence stack.")
mfiLen = input.int(14, "MFI Length", minval = 2, group = grpCore, tooltip = "MFI length used for the regular divergence stack.")

grpDecision = "Decision Engine"
inpSensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = grpDecision, tooltip = TT_SENS)
minStack = input.int(3, "Minimum Stack Level", minval = 1, maxval = 5, group = grpDecision, tooltip = "Minimum oscillator agreement required before a regular divergence stack can be evaluated.")
windowBars = input.int(3, "Window Tolerance (bars)", minval = 0, maxval = 10, group = grpDecision, tooltip = "Bars allowed between oscillator divergence events when classifying a near-stack instead of a strict same-pivot stack.")
showWindow = input.bool(true, "Show Near-Stack Events", group = grpDecision, tooltip = "Allows non-strict divergence stacks captured inside the tolerance window to appear as lower-intensity events.")
minScore = input.int(68, "Minimum Ready Score", minval = 0, maxval = 100, group = grpDecision, tooltip = TT_MIN_SCORE)
confirmMode = input.string("Close Confirmation", "Confirmation Mode", options = ["Pivot Only", "Close Confirmation", "Strict Close"], group = grpDecision, tooltip = TT_CONFIRM)
expiryBars = input.int(34, "Event Expiry Bars", minval = 5, maxval = 200, group = grpDecision, tooltip = "Bars after a READY or WATCH event before the active divergence context is marked as expired.")

grpSMT = "SMT Divergence (Correlated Pair)"
smtEnable = input.bool(false, "Enable SMT Divergence", group = grpSMT, tooltip = TT_SMT)
smtSymbol = input.symbol("OANDA:XAGUSD", "Correlated Symbol", group = grpSMT, tooltip = TT_SMT_SYM)
smtCorrType = input.string("Positive", "Correlation Type", options = ["Positive", "Inverse"], group = grpSMT, tooltip = TT_SMT_CORR)
showSmtLabels = input.bool(true, "Show SMT Labels", group = grpSMT, tooltip = "Shows a separate SMT label on the pivot where a correlated-pair divergence is detected. SMT labels are distinct from the oscillator stack labels.")

grpVisual = "Visual Layout"
showLabels = input.bool(true, "Show Event Labels", group = grpVisual, tooltip = "Shows compact READY and WATCH labels with score, stack side, and hover-level invalidation context.")
labelCooldown = input.int(12, "Same-Side Label Cooldown", minval = 0, maxval = 80, group = grpVisual, tooltip = TT_COOLDOWN)
labelOffsetAtr = input.float(1.05, "Label Offset (ATR)", minval = 0.20, maxval = 4.00, step = 0.05, group = grpVisual, tooltip = "ATR-based offset used so labels sit above or below candles instead of getting buried inside them.")
showConnectors = input.bool(true, "Show Clean Connectors", group = grpVisual, tooltip = "Draws one clean connector between the compared price pivots for accepted regular divergence stacks.")
showLifecycleLabels = input.bool(false, "Show Lifecycle Labels", group = grpVisual, tooltip = TT_LIFECYCLE)
maxVisibleObjects = input.int(24, "Max Visible Objects", minval = 6, maxval = 80, group = grpVisual, tooltip = TT_MAX_OBJECTS)
labelFont = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual, tooltip = TT_FONT)

grpBands = "Stack Reaction Bands"
showBands = input.bool(true, "Show Stack Reaction Bands", group = grpBands, tooltip = TT_BANDS)
bandMinScore = input.int(72, "Band Minimum Score", minval = 0, maxval = 100, group = grpBands, tooltip = "Minimum readiness score required before a forward stack reaction band is drawn.")
bandExtend = input.int(34, "Band Extend Bars", minval = 8, maxval = 160, group = grpBands, tooltip = "How far each stack reaction band extends to the right from the confirmed pivot.")
bandSpacing = input.int(34, "Same-Side Band Spacing", minval = 4, maxval = 160, group = grpBands, tooltip = "Minimum bars between reaction bands in the same direction. Event labels remain available when a nearby duplicate band is filtered.")
bandHeightAtr = input.float(0.34, "Band Height (ATR)", minval = 0.10, maxval = 2.00, step = 0.05, group = grpBands, tooltip = "ATR-based half-height of each stack reaction band.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel, tooltip = TT_PANEL)
panelPos = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = grpPanel, tooltip = TT_PANEL_LOC)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel, tooltip = TT_THEME)
panelFont = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel, tooltip = TT_FONT)

grpAlerts = "Alerts"
alertReady = input.bool(true, "Alert on READY Stack", group = grpAlerts, tooltip = "Enables alerts when a regular divergence stack reaches the READY score and confirmation state.")
alertShift = input.bool(true, "Alert on Confirmed State Shift", group = grpAlerts, tooltip = "Enables alerts when the active stack state changes into a confirmed READY context.")
alertInvalid = input.bool(true, "Alert on Invalidation", group = grpAlerts, tooltip = "Enables alerts when the latest active stack breaks its invalidation level.")
alertFollow = input.bool(true, "Alert on Major Follow-Through", group = grpAlerts, tooltip = "Enables alerts when the latest active stack reaches its projected follow-through target.")
alertSmt = input.bool(true, "Alert on SMT Divergence", group = grpAlerts, tooltip = "Enables alerts when a correlated-pair SMT divergence is detected (only active when the SMT module is enabled).")
alertConfirmation = input.string("Bar Close", "Alert Confirmation", options = ["Bar Close", "Live Updating"], group = grpAlerts, tooltip = "Bar Close gates public alerts to confirmed candles. Live Updating allows intrabar lifecycle alerts for users who intentionally monitor realtime changes.")

// -----------------------------------------------------
// AGPro Color Palette
// -----------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgLight = color.rgb(248, 250, 252)
panelBorder = color.rgb(51, 65, 85)
panelLabelD = color.rgb(148, 163, 184)
panelValueD = color.rgb(226, 232, 240)
panelLabelL = color.rgb(71, 85, 105)
panelValueL = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)

// -----------------------------------------------------
// Helpers
// -----------------------------------------------------
f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string s) =>
    switch s
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_norm(float v, float lo, float hi) =>
    hi == lo ? 0.0 : f_clamp((v - lo) / (hi - lo), 0.0, 1.0)

f_last_float(float[] arr) =>
    array.size(arr) > 0 ? array.get(arr, array.size(arr) - 1) : na

f_prev_float(float[] arr) =>
    array.size(arr) > 1 ? array.get(arr, array.size(arr) - 2) : na

f_prev_int(int[] arr) =>
    array.size(arr) > 1 ? array.get(arr, array.size(arr) - 2) : na

f_push_cap_float(float[] arr, float v, int cap) =>
    array.push(arr, v)
    if array.size(arr) > cap
        array.shift(arr)

f_push_cap_int(int[] arr, int v, int cap) =>
    array.push(arr, v)
    if array.size(arr) > cap
        array.shift(arr)

f_trim_labels(label[] arr, int cap) =>
    while array.size(arr) > cap
        old = array.shift(arr)
        label.delete(old)

f_trim_lines(line[] arr, int cap) =>
    while array.size(arr) > cap
        old = array.shift(arr)
        line.delete(old)

f_trim_boxes(box[] arr, int cap) =>
    while array.size(arr) > cap
        old = array.shift(arr)
        box.delete(old)

f_count(int b1, int b2, int b3, int b4, int b5, int refBar, int win) =>
    int c = 0
    c += not na(b1) and math.abs(refBar - b1) <= win ? 1 : 0
    c += not na(b2) and math.abs(refBar - b2) <= win ? 1 : 0
    c += not na(b3) and math.abs(refBar - b3) <= win ? 1 : 0
    c += not na(b4) and math.abs(refBar - b4) <= win ? 1 : 0
    c += not na(b5) and math.abs(refBar - b5) <= win ? 1 : 0
    c

f_div_bull(float prevP, float prevO, float curP, float curO) =>
    not na(prevP) and not na(prevO) and curP < prevP and curO > prevO

f_div_bear(float prevP, float prevO, float curP, float curO) =>
    not na(prevP) and not na(prevO) and curP > prevP and curO < prevO

f_score(int stack, float swingAtr, float trendScore, bool confirmed, float distanceAtr) =>
    float oscScore = stack * 20.0
    float swingScore = f_norm(swingAtr, 0.25, 1.80) * 100.0
    float confScore = confirmed ? 100.0 : confirmMode == "Pivot Only" ? 78.0 : 38.0
    float distScore = 100.0 - f_norm(distanceAtr, 0.35, 2.70) * 100.0
    float sensAdjust = inpSensitivity == "Conservative" ? -6.0 : inpSensitivity == "Aggressive" ? 5.0 : 0.0
    float raw = oscScore * 0.34 + swingScore * 0.20 + trendScore * 0.15 + confScore * 0.20 + distScore * 0.11 + sensAdjust
    int(math.round(f_clamp(raw, 0.0, 100.0)))

f_tier(int score, bool confirmed) =>
    string result = "NOISE"
    if score >= 82 and confirmed
        result := "PRIME"
    else if score >= minScore and confirmed
        result := "READY"
    else if score >= math.max(0, minScore - 14)
        result := "WATCH"
    result

f_quality_text(float swingAtr) =>
    swingAtr >= 1.45 ? "Strong" : swingAtr >= 0.75 ? "Clean" : swingAtr >= 0.30 ? "Thin" : "Weak"

f_fmt_price(float v) =>
    na(v) ? "-" : str.tostring(v, format.mintick)

labelSz = f_size(labelFont)
panelSz = f_size(panelFont)
panelBg = panelTheme == "Dark" ? panelBgDark : panelBgLight
panelLabel = panelTheme == "Dark" ? panelLabelD : panelLabelL
panelValue = panelTheme == "Dark" ? panelValueD : panelValueL

// -----------------------------------------------------
// Oscillators and context
// -----------------------------------------------------
rsiV = ta.rsi(close, rsiLen)
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
cciV = ta.cci(close, cciLen)
mfiV = ta.mfi(hlc3, mfiLen)
obvV = ta.obv
atr14 = ta.atr(14)
emaFast = ta.ema(close, 34)
emaSlow = ta.ema(close, 89)

// Optional correlated-pair series for the SMT module (non-repainting)
corrHigh = smtEnable ? request.security(smtSymbol, timeframe.period, high, lookahead = barmerge.lookahead_off) : na
corrLow  = smtEnable ? request.security(smtSymbol, timeframe.period, low,  lookahead = barmerge.lookahead_off) : na

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
pivotBar = bar_index - pivotLen

// -----------------------------------------------------
// Pivot storage
// -----------------------------------------------------
var float[] phPrice = array.new_float()
var int[] phBar = array.new_int()
var float[] phRSI = array.new_float()
var float[] phMACD = array.new_float()
var float[] phCCI = array.new_float()
var float[] phMFI = array.new_float()
var float[] phOBV = array.new_float()
var float[] phCorr = array.new_float()

var float[] plPrice = array.new_float()
var int[] plBar = array.new_int()
var float[] plRSI = array.new_float()
var float[] plMACD = array.new_float()
var float[] plCCI = array.new_float()
var float[] plMFI = array.new_float()
var float[] plOBV = array.new_float()
var float[] plCorr = array.new_float()

var int bullBarRSI = na
var int bearBarRSI = na
var int bullBarMACD = na
var int bearBarMACD = na
var int bullBarCCI = na
var int bearBarCCI = na
var int bullBarMFI = na
var int bearBarMFI = na
var int bullBarOBV = na
var int bearBarOBV = na

var int bullSmtBar = na
var int bearSmtBar = na

if not na(ph)
    float prevPrice = f_last_float(phPrice)
    float prevRSI = f_last_float(phRSI)
    float prevMACD = f_last_float(phMACD)
    float prevCCI = f_last_float(phCCI)
    float prevMFI = f_last_float(phMFI)
    float prevOBV = f_last_float(phOBV)
    float curRSI = rsiV[pivotLen]
    float curMACD = macdHist[pivotLen]
    float curCCI = cciV[pivotLen]
    float curMFI = mfiV[pivotLen]
    float curOBV = obvV[pivotLen]

    if f_div_bear(prevPrice, prevRSI, ph, curRSI)
        bearBarRSI := pivotBar
    if f_div_bear(prevPrice, prevMACD, ph, curMACD)
        bearBarMACD := pivotBar
    if f_div_bear(prevPrice, prevCCI, ph, curCCI)
        bearBarCCI := pivotBar
    if f_div_bear(prevPrice, prevMFI, ph, curMFI)
        bearBarMFI := pivotBar
    if f_div_bear(prevPrice, prevOBV, ph, curOBV)
        bearBarOBV := pivotBar

    // SMT (correlated-pair) bearish divergence -- separate from the 5-oscillator stack
    float curCorrHigh = corrHigh[pivotLen]
    float prevCorrHigh = f_last_float(phCorr)
    if smtEnable and not na(prevPrice) and not na(curCorrHigh) and not na(prevCorrHigh)
        bool chartHH = ph > prevPrice
        bool corrHH = curCorrHigh > prevCorrHigh
        if (smtCorrType == "Positive" ? chartHH != corrHH : chartHH == corrHH)
            bearSmtBar := pivotBar

    f_push_cap_float(phPrice, ph, 40)
    f_push_cap_int(phBar, pivotBar, 40)
    f_push_cap_float(phRSI, curRSI, 40)
    f_push_cap_float(phMACD, curMACD, 40)
    f_push_cap_float(phCCI, curCCI, 40)
    f_push_cap_float(phMFI, curMFI, 40)
    f_push_cap_float(phOBV, curOBV, 40)
    f_push_cap_float(phCorr, curCorrHigh, 40)

if not na(pl)
    float prevPrice = f_last_float(plPrice)
    float prevRSI = f_last_float(plRSI)
    float prevMACD = f_last_float(plMACD)
    float prevCCI = f_last_float(plCCI)
    float prevMFI = f_last_float(plMFI)
    float prevOBV = f_last_float(plOBV)
    float curRSI = rsiV[pivotLen]
    float curMACD = macdHist[pivotLen]
    float curCCI = cciV[pivotLen]
    float curMFI = mfiV[pivotLen]
    float curOBV = obvV[pivotLen]

    if f_div_bull(prevPrice, prevRSI, pl, curRSI)
        bullBarRSI := pivotBar
    if f_div_bull(prevPrice, prevMACD, pl, curMACD)
        bullBarMACD := pivotBar
    if f_div_bull(prevPrice, prevCCI, pl, curCCI)
        bullBarCCI := pivotBar
    if f_div_bull(prevPrice, prevMFI, pl, curMFI)
        bullBarMFI := pivotBar
    if f_div_bull(prevPrice, prevOBV, pl, curOBV)
        bullBarOBV := pivotBar

    // SMT (correlated-pair) bullish divergence -- separate from the 5-oscillator stack
    float curCorrLow = corrLow[pivotLen]
    float prevCorrLow = f_last_float(plCorr)
    if smtEnable and not na(prevPrice) and not na(curCorrLow) and not na(prevCorrLow)
        bool chartLL = pl < prevPrice
        bool corrLL = curCorrLow < prevCorrLow
        if (smtCorrType == "Positive" ? chartLL != corrLL : chartLL == corrLL)
            bullSmtBar := pivotBar

    f_push_cap_float(plPrice, pl, 40)
    f_push_cap_int(plBar, pivotBar, 40)
    f_push_cap_float(plRSI, curRSI, 40)
    f_push_cap_float(plMACD, curMACD, 40)
    f_push_cap_float(plCCI, curCCI, 40)
    f_push_cap_float(plMFI, curMFI, 40)
    f_push_cap_float(plOBV, curOBV, 40)
    f_push_cap_float(plCorr, curCorrLow, 40)

// SMT fired on the just-confirmed pivot
bool smtBullNow = not na(pl) and bullSmtBar == pivotBar
bool smtBearNow = not na(ph) and bearSmtBar == pivotBar

var int lastSmtDir = 0
var int lastSmtBar = na
if smtBullNow
    lastSmtDir := 1
    lastSmtBar := pivotBar
if smtBearNow
    lastSmtDir := -1
    lastSmtBar := pivotBar
bool smtActive = smtEnable and lastSmtDir != 0 and not na(lastSmtBar) and bar_index - lastSmtBar <= expiryBars

// -----------------------------------------------------
// Stack evaluation and readiness scoring
// -----------------------------------------------------
bullStackStrict = not na(pl) ? f_count(bullBarRSI, bullBarMACD, bullBarCCI, bullBarMFI, bullBarOBV, pivotBar, 0) : 0
bullStackWindow = not na(pl) ? f_count(bullBarRSI, bullBarMACD, bullBarCCI, bullBarMFI, bullBarOBV, pivotBar, windowBars) : 0
bearStackStrict = not na(ph) ? f_count(bearBarRSI, bearBarMACD, bearBarCCI, bearBarMFI, bearBarOBV, pivotBar, 0) : 0
bearStackWindow = not na(ph) ? f_count(bearBarRSI, bearBarMACD, bearBarCCI, bearBarMFI, bearBarOBV, pivotBar, windowBars) : 0

bullStack = bullStackStrict >= minStack ? bullStackStrict : showWindow and bullStackWindow >= minStack ? bullStackWindow : 0
bearStack = bearStackStrict >= minStack ? bearStackStrict : showWindow and bearStackWindow >= minStack ? bearStackWindow : 0
bullStrict = bullStackStrict >= minStack
bearStrict = bearStackStrict >= minStack
bullFire = not na(pl) and bullStack >= minStack
bearFire = not na(ph) and bearStack >= minStack

float prevLowPrice = bullFire ? f_prev_float(plPrice) : na
int prevLowBar = bullFire ? f_prev_int(plBar) : na
float prevHighPrice = bearFire ? f_prev_float(phPrice) : na
int prevHighBar = bearFire ? f_prev_int(phBar) : na

float atrPivot = math.max(nz(atr14[pivotLen], atr14), syminfo.mintick)
float bullSwingAtr = bullFire and not na(prevLowPrice) ? math.abs(pl - prevLowPrice) / atrPivot : 0.0
float bearSwingAtr = bearFire and not na(prevHighPrice) ? math.abs(ph - prevHighPrice) / atrPivot : 0.0

bool bullConfirmed = confirmMode == "Pivot Only" ? true : confirmMode == "Close Confirmation" ? close > high[pivotLen] : close > high[pivotLen] and close > emaFast
bool bearConfirmed = confirmMode == "Pivot Only" ? true : confirmMode == "Close Confirmation" ? close < low[pivotLen] : close < low[pivotLen] and close < emaFast

float bullTrendScore = emaFast < emaSlow ? 100.0 : close < emaFast ? 68.0 : 42.0
float bearTrendScore = emaFast > emaSlow ? 100.0 : close > emaFast ? 68.0 : 42.0
float bullDistanceAtr = bullFire ? math.abs(close - pl) / math.max(atr14, syminfo.mintick) : 0.0
float bearDistanceAtr = bearFire ? math.abs(close - ph) / math.max(atr14, syminfo.mintick) : 0.0

int bullScore = bullFire ? f_score(bullStack, bullSwingAtr, bullTrendScore, bullConfirmed, bullDistanceAtr) : 0
int bearScore = bearFire ? f_score(bearStack, bearSwingAtr, bearTrendScore, bearConfirmed, bearDistanceAtr) : 0
string bullTier = f_tier(bullScore, bullConfirmed)
string bearTier = f_tier(bearScore, bearConfirmed)

int watchFloor = math.max(0, minScore - 14)
bool bullAccepted = bullFire and bullScore >= watchFloor
bool bearAccepted = bearFire and bearScore >= watchFloor
bool bullReady = bullFire and bullScore >= minScore and bullConfirmed
bool bearReady = bearFire and bearScore >= minScore and bearConfirmed

float lastOppHigh = f_last_float(phPrice)
float lastOppLow = f_last_float(plPrice)
float bullInv = bullFire ? pl - atrPivot * 0.18 : na
float bearInv = bearFire ? ph + atrPivot * 0.18 : na
float bullTarget = bullFire ? not na(lastOppHigh) and lastOppHigh > close ? lastOppHigh : close + atrPivot * math.max(1.35, bullSwingAtr * 1.10) : na
float bearTarget = bearFire ? not na(lastOppLow) and lastOppLow < close ? lastOppLow : close - atrPivot * math.max(1.35, bearSwingAtr * 1.10) : na

// -----------------------------------------------------
// Object lifecycle
// -----------------------------------------------------
var label[] eventLabels = array.new_label()
var line[] connectors = array.new_line()
var box[] decisionBands = array.new_box()
var label[] bandLabels = array.new_label()
var int lastBullLabelBar = na
var int lastBearLabelBar = na
var int lastBullPivotBar = na
var int lastBearPivotBar = na
var int lastBullLabelScore = 0
var int lastBearLabelScore = 0
var int lastBullBandBar = na
var int lastBearBandBar = na

bool bullDraw = showLabels and bullAccepted and (na(lastBullLabelBar) or pivotBar != lastBullPivotBar and pivotBar - lastBullLabelBar > labelCooldown or bullScore >= lastBullLabelScore + 10)
bool bearDraw = showLabels and bearAccepted and (na(lastBearLabelBar) or pivotBar != lastBearPivotBar and pivotBar - lastBearLabelBar > labelCooldown or bearScore >= lastBearLabelScore + 10)

if bullDraw
    string txt = bullTier + " " + str.tostring(bullScore) + "\n" + str.tostring(bullStack) + "/5 BULL"
    string tip = "Invalidation: " + f_fmt_price(bullInv) + "\nTarget: " + f_fmt_price(bullTarget) + "\nSwing: " + f_quality_text(bullSwingAtr)
    color lblCol = bullReady ? bullColor : color.new(bullColor, 26)
    label lb = label.new(pivotBar, pl - atrPivot * labelOffsetAtr, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = lblCol, textcolor = headerText, size = labelSz, tooltip = tip)
    array.push(eventLabels, lb)
    f_trim_labels(eventLabels, maxVisibleObjects)
    lastBullLabelBar := pivotBar
    lastBullPivotBar := pivotBar
    lastBullLabelScore := bullScore

if bearDraw
    string txt = bearTier + " " + str.tostring(bearScore) + "\n" + str.tostring(bearStack) + "/5 BEAR"
    string tip = "Invalidation: " + f_fmt_price(bearInv) + "\nTarget: " + f_fmt_price(bearTarget) + "\nSwing: " + f_quality_text(bearSwingAtr)
    color lblCol = bearReady ? bearColor : color.new(bearColor, 26)
    label lb = label.new(pivotBar, ph + atrPivot * labelOffsetAtr, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = lblCol, textcolor = headerText, size = labelSz, tooltip = tip)
    array.push(eventLabels, lb)
    f_trim_labels(eventLabels, maxVisibleObjects)
    lastBearLabelBar := pivotBar
    lastBearPivotBar := pivotBar
    lastBearLabelScore := bearScore

// SMT labels -- separate module, placed farther out so they never stack on the oscillator labels
if smtEnable and showSmtLabels and smtBullNow
    label lb = label.new(pivotBar, pl - atrPivot * labelOffsetAtr * 1.9, "SMT BULL", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_up, color = accentColor, textcolor = headerText, size = labelSz, tooltip = "Correlated-pair SMT divergence (separate from the oscillator stack).")
    array.push(eventLabels, lb)
    f_trim_labels(eventLabels, maxVisibleObjects)

if smtEnable and showSmtLabels and smtBearNow
    label lb = label.new(pivotBar, ph + atrPivot * labelOffsetAtr * 1.9, "SMT BEAR", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = accentColor, textcolor = headerText, size = labelSz, tooltip = "Correlated-pair SMT divergence (separate from the oscillator stack).")
    array.push(eventLabels, lb)
    f_trim_labels(eventLabels, maxVisibleObjects)

if showConnectors and bullAccepted and not na(prevLowBar) and not na(prevLowPrice)
    line ln = line.new(prevLowBar, prevLowPrice, pivotBar, pl, xloc = xloc.bar_index, extend = extend.none, color = color.new(bullColor, bullReady ? 18 : 48), style = bullStrict ? line.style_solid : line.style_dotted, width = bullReady ? 2 : 1)
    array.push(connectors, ln)
    f_trim_lines(connectors, maxVisibleObjects)

if showConnectors and bearAccepted and not na(prevHighBar) and not na(prevHighPrice)
    line ln = line.new(prevHighBar, prevHighPrice, pivotBar, ph, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, bearReady ? 18 : 48), style = bearStrict ? line.style_solid : line.style_dotted, width = bearReady ? 2 : 1)
    array.push(connectors, ln)
    f_trim_lines(connectors, maxVisibleObjects)

bool bullBandDraw = showBands and bullAccepted and bullScore >= bandMinScore and (na(lastBullBandBar) or pivotBar - lastBullBandBar >= bandSpacing)
bool bearBandDraw = showBands and bearAccepted and bearScore >= bandMinScore and (na(lastBearBandBar) or pivotBar - lastBearBandBar >= bandSpacing)

if bullBandDraw
    float half = atrPivot * bandHeightAtr
    string bandTxt = "BULL REACTION | " + str.tostring(bullStack) + "/5"
    int bandMidX = pivotBar + int(bandExtend / 2)
    box bx = box.new(pivotBar, pl + half, pivotBar + bandExtend, pl - half, xloc = xloc.bar_index, border_color = color.new(bullColor, 22), border_width = 1, bgcolor = color.new(bullColor, 83))
    array.push(decisionBands, bx)
    f_trim_boxes(decisionBands, maxVisibleObjects)
    label bl = label.new(bandMidX, pl, bandTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bullColor, 0), textcolor = headerText, size = labelSz)
    array.push(bandLabels, bl)
    f_trim_labels(bandLabels, maxVisibleObjects)
    lastBullBandBar := pivotBar

if bearBandDraw
    float half = atrPivot * bandHeightAtr
    string bandTxt = "BEAR REACTION | " + str.tostring(bearStack) + "/5"
    int bandMidX = pivotBar + int(bandExtend / 2)
    box bx = box.new(pivotBar, ph + half, pivotBar + bandExtend, ph - half, xloc = xloc.bar_index, border_color = color.new(bearColor, 22), border_width = 1, bgcolor = color.new(bearColor, 83))
    array.push(decisionBands, bx)
    f_trim_boxes(decisionBands, maxVisibleObjects)
    label bl = label.new(bandMidX, ph, bandTxt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(bearColor, 0), textcolor = headerText, size = labelSz)
    array.push(bandLabels, bl)
    f_trim_labels(bandLabels, maxVisibleObjects)
    lastBearBandBar := pivotBar

// -----------------------------------------------------
// Active event, invalidation, and follow-through state
// -----------------------------------------------------
var int activeDir = 0
var int activeBar = na
var int activeScore = na
var int activeStack = na
var float activeInv = na
var float activeTarget = na
var float activeSwing = na
var string activeTier = "NONE"
var bool activeConfirmed = false
var bool activeInvalidated = false
var bool activeFollowed = false

bool newReadyState = bullReady or bearReady
bool priorTerminal = activeDir != 0 and (activeInvalidated or activeFollowed or (not na(activeBar) and bar_index - activeBar > expiryBars))
if bullAccepted and (priorTerminal or activeDir != 1 or bullScore >= nz(activeScore, 0) or bullReady)
    activeDir := 1
    activeBar := pivotBar
    activeScore := bullScore
    activeStack := bullStack
    activeInv := bullInv
    activeTarget := bullTarget
    activeSwing := bullSwingAtr
    activeTier := bullTier
    activeConfirmed := bullConfirmed
    activeInvalidated := false
    activeFollowed := false

if bearAccepted and (priorTerminal or activeDir != -1 or bearScore >= nz(activeScore, 0) or bearReady)
    activeDir := -1
    activeBar := pivotBar
    activeScore := bearScore
    activeStack := bearStack
    activeInv := bearInv
    activeTarget := bearTarget
    activeSwing := bearSwingAtr
    activeTier := bearTier
    activeConfirmed := bearConfirmed
    activeInvalidated := false
    activeFollowed := false

bool activeExpired = activeDir != 0 and not na(activeBar) and bar_index - activeBar > expiryBars
bool invalidNow = false
bool followNow = false
if activeDir == 1 and not activeExpired and not activeInvalidated and not na(activeInv) and low <= activeInv
    invalidNow := true
    activeInvalidated := true
if activeDir == -1 and not activeExpired and not activeInvalidated and not na(activeInv) and high >= activeInv
    invalidNow := true
    activeInvalidated := true
if activeDir == 1 and not activeExpired and not activeFollowed and not activeInvalidated and not na(activeTarget) and high >= activeTarget
    followNow := true
    activeFollowed := true
if activeDir == -1 and not activeExpired and not activeFollowed and not activeInvalidated and not na(activeTarget) and low <= activeTarget
    followNow := true
    activeFollowed := true

if showLabels and showLifecycleLabels and invalidNow
    string txt = "INVALID\nInv " + f_fmt_price(activeInv)
    label lb = label.new(bar_index, activeInv, txt, xloc = xloc.bar_index, yloc = yloc.price, style = activeDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(panelBorder, 0), textcolor = headerText, size = labelSz)
    array.push(eventLabels, lb)
    f_trim_labels(eventLabels, maxVisibleObjects)

if showLabels and showLifecycleLabels and followNow
    string txt = "FOLLOW\nTarget " + f_fmt_price(activeTarget)
    label lb = label.new(bar_index, activeTarget, txt, xloc = xloc.bar_index, yloc = yloc.price, style = activeDir == 1 ? label.style_label_down : label.style_label_up, color = activeDir == 1 ? bullColor : bearColor, textcolor = headerText, size = labelSz)
    array.push(eventLabels, lb)
    f_trim_labels(eventLabels, maxVisibleObjects)

// -----------------------------------------------------
// Panel state
// -----------------------------------------------------
bool activeTerminal = activeInvalidated or activeFollowed or activeExpired
string activeSide = activeDir == 1 ? (activeTerminal ? "Last Bullish Regular" : "Bullish Regular") : activeDir == -1 ? (activeTerminal ? "Last Bearish Regular" : "Bearish Regular") : "None"
string stackText = activeDir == 0 or na(activeStack) ? "-" : str.tostring(activeStack) + "/5 " + activeTier
string swingText = activeDir == 0 or na(activeSwing) ? "-" : f_quality_text(activeSwing) + " / " + str.tostring(activeScore)
string lifecycleText = activeDir == 0 ? "No Event" : activeInvalidated ? "Invalidated" : activeFollowed ? "Target Reached" : activeExpired ? "Expired" : activeConfirmed ? "Confirmed / Active" : "Pending Close"
color lifecycleCol = activeDir == 0 ? panelValue : activeInvalidated ? bearColor : activeFollowed ? bullColor : activeExpired ? panelLabel : activeConfirmed ? (activeDir == 1 ? bullColor : bearColor) : neutralColor
string actionText = "Wait for Stack"
color actionCol = panelLabel

if activeDir != 0
    if activeInvalidated
        actionText := "Scan New Stack"
        actionCol := neutralColor
    else if activeFollowed
        actionText := "Review Follow-Through"
        actionCol := bullColor
    else if activeExpired
        actionText := "Scan New Stack"
        actionCol := neutralColor
    else if activeScore >= minScore and activeConfirmed
        actionText := activeDir == 1 ? "Review Bull Setup" : "Review Bear Setup"
        actionCol := activeDir == 1 ? bullColor : bearColor
    else
        actionText := "Wait Confirmation"
        actionCol := neutralColor

// SMT panel row text (only shown when the module is enabled)
string smtText = not smtActive ? "None" : (lastSmtDir == 1 ? "Bull" : "Bear") + (lastSmtDir == activeDir and activeDir != 0 ? " + Stack" : "")
color smtCol = not smtActive ? panelValue : lastSmtDir == 1 ? bullColor : bearColor

var table pnl = na
if barstate.islast
    if not na(pnl)
        table.delete(pnl)
        pnl := na
    if showPanel
        int nRows = smtEnable ? 7 : 6
        pnl := table.new(f_panel_pos(panelPos), 2, nRows, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
        table.cell(pnl, 0, 0, "AG Pro Divergence Stack Scanner", text_color = headerText, bgcolor = headerBg, text_size = panelSz, text_halign = text.align_center)
        table.cell(pnl, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSz, text_halign = text.align_center)
        table.merge_cells(pnl, 0, 0, 1, 0)
        table.cell(pnl, 0, 1, "Divergence", text_color = panelLabel, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_left)
        table.cell(pnl, 1, 1, activeSide, text_color = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : panelValue, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 2, "Stack / Tier", text_color = panelLabel, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_left)
        table.cell(pnl, 1, 2, stackText, text_color = activeScore >= 82 ? accentColor : activeScore >= minScore ? (activeDir == 1 ? bullColor : bearColor) : panelValue, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 3, "Quality / Score", text_color = panelLabel, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_left)
        table.cell(pnl, 1, 3, swingText, text_color = activeScore >= 82 ? accentColor : activeScore >= minScore ? neutralColor : panelValue, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 4, "Lifecycle", text_color = panelLabel, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_left)
        table.cell(pnl, 1, 4, lifecycleText, text_color = lifecycleCol, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_right)
        table.cell(pnl, 0, 5, "Workflow", text_color = panelLabel, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_left)
        table.cell(pnl, 1, 5, actionText, text_color = actionCol, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_right)
        if smtEnable
            table.cell(pnl, 0, 6, "SMT (corr)", text_color = panelLabel, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_left)
            table.cell(pnl, 1, 6, smtText, text_color = smtCol, bgcolor = panelBg, text_size = panelSz, text_halign = text.align_right)

// -----------------------------------------------------
// Alerts
// -----------------------------------------------------
bool alertBarOk = alertConfirmation == "Live Updating" or barstate.isconfirmed
alertcondition(alertBarOk and alertReady and bullReady, "DSS Bull READY", "Divergence Stack Scanner: Bull READY stack on {{ticker}} {{interval}}.")
alertcondition(alertBarOk and alertReady and bearReady, "DSS Bear READY", "Divergence Stack Scanner: Bear READY stack on {{ticker}} {{interval}}.")
alertcondition(alertBarOk and alertShift and newReadyState, "DSS Confirmed State Shift", "Divergence Stack Scanner: confirmed READY state shift on {{ticker}} {{interval}}.")
alertcondition(alertBarOk and alertInvalid and invalidNow, "DSS Invalidation", "Divergence Stack Scanner: active divergence stack invalidated on {{ticker}} {{interval}}.")
alertcondition(alertBarOk and alertFollow and followNow, "DSS Major Follow-Through", "Divergence Stack Scanner: active divergence stack reached major follow-through on {{ticker}} {{interval}}.")
alertcondition(alertBarOk and alertSmt and smtBullNow, "DSS SMT Bull", "Divergence Stack Scanner: bullish SMT divergence vs correlated pair on {{ticker}} {{interval}}.")
alertcondition(alertBarOk and alertSmt and smtBearNow, "DSS SMT Bear", "Divergence Stack Scanner: bearish SMT divergence vs correlated pair on {{ticker}} {{interval}}.")
````
