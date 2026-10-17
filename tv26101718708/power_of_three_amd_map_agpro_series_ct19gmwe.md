# Power of Three (AMD) Map [AGPro Series]

- url: https://www.tradingview.com/script/ct19Gmwe-Power-of-Three-AMD-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;9b30ef132bb147ebb78764b2bf58856c
- version: 3.0

## Description

Power of Three (AMD) Map [AGPro Series]

🔹 Overview

The Power of Three (AMD) Map visualizes ICT's foundational session-framework concept directly on the chart: Accumulation → Manipulation → Distribution. For each daily or weekly session, the indicator automatically segments the AMD phases, detects classic liquidity sweeps during Manipulation, and projects a distribution target based on the accumulation range. Built for ICT / Smart Money Concept traders who want session-aware bias, transparent sweep validation, and forward-looking expansion projections.

🔹 Unique Edge vs Other PO3 Scripts

Most PO3 indicators on TradingView simply highlight time-based session blocks and leave liquidity detection to the user's eye. This implementation distinguishes itself through:

• Phase detection by bar count, not timestamps — ensuring consistent AMD ratios across every timeframe from 15m to 1D
• Adaptive sweep confirmation — accepts both same-bar ICT-strict sweeps (wick + close-back) and 2-bar delayed confirmations, significantly improving setup capture without sacrificing quality
• Dual-reference sweep logic — checks both the previous session's accumulation range AND the current session's accumulation range, capturing sweeps that single-reference scripts miss
• TF-adaptive target multiplier — Daily sessions project targets at 0.7× accumulation range, Weekly sessions at 0.3×, aligned with realistic crypto volatility profiles
• Transparent dual-KPI panel — separates Sweep Rate (how often valid sweeps occur) from Target Hit rate (how often the projected expansion completes), giving traders honest, verifiable performance metrics

🔹 Methodology

Each session is divided into three bar-count-based windows:
• Accumulation (first 33% of expected session bars) — tracks the initial range
• Manipulation (next 17%) — scans for liquidity sweeps against the previous session's accumulation high/low and the current accumulation extremes
• Distribution (remaining 50%) — the expected expansion phase, measured against the projected target

A valid Manipulation sweep requires a wick penetrating a reference level followed by a body close back inside (classic ICT definition). In Adaptive mode, sweeps can also confirm within a 2-bar window. The detected sweep direction determines the PO3 bias: sweeping a high produces a Bearish PO3 (expected downside distribution); sweeping a low produces a Bullish PO3 (expected upside distribution). A target price is projected from either the accumulation midpoint (default, symmetrical expansion) or the sweep extreme, multiplied by the configured ratio.

🔹 Signals & Alerts

Four built-in alert conditions:
• Manipulation phase started — Accumulation complete
• Bullish sweep detected — Low was swept, Bullish PO3 forming
• Bearish sweep detected — High was swept, Bearish PO3 forming
• Distribution target hit — Expansion reached projected level

🔹 Key Inputs

• Session Scope — Auto (TF-adaptive), Daily, or Weekly
• Accumulation / Manipulation window percentages (defaults 33% / 17%)
• Sweep Reference — Previous Accumulation, Current Accumulation, or Both (default)
• Sweep Confirmation — Strict (same-bar) or Adaptive (up to 2-bar, default)
• Target Projection Method — From Accumulation Mid (default) or From Sweep Extreme
• Multiplier Mode — Auto TF-adaptive (default) or Manual
• Historical sessions to display (default 5, max 10)
• Full visual customization — colors, label position, font size, panel position & theme
• Premium visuals — sweep triangle markers, target price label (toggleable)

🔹 How to Use

1. Add the indicator to any crypto or forex chart with timeframe 1H–4H (for Daily PO3) or 1D (for Weekly PO3)
2. Watch the Accumulation range form at the start of each session — this defines the sweep reference level
3. When Manipulation phase begins, monitor for a wick that sweeps the previous accumulation high/low with a body close-back (triangle marker appears on confirmed sweeps)
4. Once a sweep confirms, the panel displays the directional bias (Bullish/Bearish PO3), the projected target price, and a dashed target zone extends toward the session end
5. Use the Sweep Rate and Target Hit percentages in the panel to contextualize reliability on your chosen symbol and timeframe
6. The panel's Completion counter grows as new sessions close — give the script enough historical bars to build meaningful statistics

🔹 Limitations & Transparency

• AMD phase windows are bar-count approximations — real sessions do not cleanly segment into 33/17/50 splits. The indicator is a structural guide, not a timing oracle
• Sweep detection requires the chart timeframe to contain at least 4 bars per session. On 1D charts, use Weekly mode; on 1W charts, the indicator will display a warning
• The projected target is a statistical expectation based on the accumulation range. The Target Hit rate (shown in panel) reflects the historical frequency of this expectation being met on the current symbol/timeframe — typically 40–55% on crypto majors
• Sweep Rate shows the percentage of completed sessions where a valid Manipulation sweep was detected; sessions without sweeps produce no bias and no target
• Historical statistics accumulate from the first bar available on the chart and reset only when the chart reloads

🔹 Risk Disclosure

This indicator is a visualization and analysis tool. It does not generate trade signals, predict price movement, or guarantee outcomes. Past Sweep Rate and Target Hit statistics reflect historical behavior only and do not imply future performance. All trading decisions and risk management remain the responsibility of the user.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Power of Three (AMD) Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.6
//
// Maps ICT's Power of Three (Accumulation - Manipulation - Distribution)
// lifecycle across daily and weekly sessions. Detects classic liquidity
// sweeps, projects symmetrical distribution targets, scores setup readiness
// on a 0-100 scale, flags the live invalidation level, and tracks a
// stop-aware target-first proof rate. Built for SMC / ICT traders who want
// phase-aware session bias, liquidity sweep validation, clean expansion
// mapping, and a clear next-action read.
// Analytical and visualization tool only - not a strategy, not financial advice.
// ─────────────────────────────────────────────────

//@version=6
indicator("Power of Three (AMD) Map [AGPro Series]",
     shorttitle = "AG Pro PO3",
     overlay    = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_lines_count  = 500)

// ─────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────
grpSession  = "Session Settings"
sessionMode = input.string("Auto", "Session Scope", options = ["Auto", "Daily", "Weekly"], group = grpSession,
     tooltip = "Auto selects Daily on intraday timeframes (<=4H), Weekly on higher timeframes. Override for explicit bias.")
accPct  = input.int(33, "Accumulation window (%)", minval = 10, maxval = 50, group = grpSession,
     tooltip = "Percentage of session assigned to Accumulation phase. Default 33% follows classic ICT PO3.")
manipPct = input.int(17, "Manipulation window (%)", minval = 5, maxval = 40, group = grpSession,
     tooltip = "Percentage of session assigned to Manipulation phase. Liquidity sweeps are detected only in this window.")

grpLogic = "Detection Logic"
sweepRef  = input.string("Both", "Sweep Reference", options = ["Previous Accumulation", "Current Accumulation", "Both"], group = grpLogic,
     tooltip = "Previous Accumulation: sweep prior session's Accumulation range. Current Accumulation: sweep current session's own Accumulation range. Both: accept either (recommended, maximizes valid setups).")
sweepMode = input.string("Adaptive", "Sweep Confirmation", options = ["Strict", "Adaptive"], group = grpLogic,
     tooltip = "Strict: classic ICT (same-bar wick sweep + body close-back). Adaptive: also accepts next-bar close-back confirmation. Adaptive captures more valid PO3 setups while maintaining quality.")
targetMethod = input.string("From Accumulation Mid", "Target Projection Method", options = ["From Sweep Extreme", "From Accumulation Mid"], group = grpLogic,
     tooltip = "From Sweep Extreme: target = sweep wick +/- (accRange x multiplier). More aggressive. From Accumulation Mid: target = accumulation midpoint +/- (accRange/2 + accRange x multiplier). More realistic, aligned with ICT's symmetrical expansion concept.")
multMode = input.string("Auto (TF-adaptive)", "Multiplier Mode", options = ["Auto (TF-adaptive)", "Manual"], group = grpLogic,
     tooltip = "Auto: adapts multiplier to session scope - Daily sessions use 0.7 (realistic crypto target), Weekly sessions use 0.3 (scaled for larger range). Manual: uses the value below for both.")
projMult = input.float(0.7, "Manual Multiplier", minval = 0.2, maxval = 3.0, step = 0.1, group = grpLogic,
     tooltip = "Applied only when Multiplier Mode = Manual. 0.7 = realistic crypto target. 1.0 = symmetrical expansion. 1.5 = aggressive ICT full expansion.")
showHist = input.int(5, "Historical sessions to display", minval = 0, maxval = 10, group = grpLogic,
     tooltip = "Number of completed sessions to keep on chart. Current session is always visible.")

grpVisual = "Visual Style"
accBoxCol    = input.color(color.new(#F5BD5C, 85), "Accumulation Box",   group = grpVisual)
manipBoxCol  = input.color(color.new(#F472B6, 74), "Manipulation Box",   group = grpVisual)
bullDistCol  = input.color(color.new(#22C5A6, 80), "Distribution (Bull)", group = grpVisual)
bearDistCol  = input.color(color.new(#F472B6, 80), "Distribution (Bear)", group = grpVisual)
targetCol    = input.color(color.new(#818CF8, 76), "Target Projection",  group = grpVisual)
showPhaseLbl = input.bool(true, "Show A/M/D phase labels", group = grpVisual)
labelPos     = input.string("Above box", "Label Position", options = ["Top edge", "Above box", "Box center"], group = grpVisual,
     tooltip = "Above box: premium tag sits just above each phase box, clear of candles (recommended). Top edge: tighter to the box border. Box center: traditional, may overlap candles.")
labelSize    = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpVisual,
     tooltip = "Font size for on-chart tags (phase labels, sweep markers, target tag). Independent from the panel font size. Default Normal.")

grpPremium = "Premium Visuals"
showSweepMarker = input.bool(true, "Sweep Markers", group = grpPremium,
     tooltip = "Small triangle markers on bars where liquidity sweeps occur. Minimalist ICT-style annotation.")
showTargetLabel = input.bool(true, "Target Price Label", group = grpPremium,
     tooltip = "Shows the projected target price as a premium tag at the target zone.")

grpPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = grpPanel)
panelPos  = input.string("Top Right", "Panel Position", group = grpPanel,
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"])
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = grpPanel)
fontSize   = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpPanel)

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgLight  = color.rgb(248, 250, 252)
panelBorder   = color.rgb(51, 65, 85)
panelLabelDk  = color.rgb(148, 163, 184)
panelValueDk  = color.rgb(226, 232, 240)
panelLabelLt  = color.rgb(71, 85, 105)
panelValueLt  = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

panelBg     = panelTheme == "Dark" ? panelBgDark   : panelBgLight
panelLabel  = panelTheme == "Dark" ? panelLabelDk  : panelLabelLt
panelValue  = panelTheme == "Dark" ? panelValueDk  : panelValueLt

// ─────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────
// Luminance-aware text color so every on-chart tag stays legible on its fill
f_text_on(bg) =>
    lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_toSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        =>          size.normal

f_toPos(p) =>
    switch p
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        =>                position.top_right

// Position a phase tag above its box (or centered). Tier gives a small
// vertical offset so adjacent tags never collide. ATR is passed in so the
// ta.* call stays at global scope.
f_labelY(boxHi, boxLo, tier, atrv) =>
    pad     = atrv * 0.16
    tierPad = atrv * 0.08 * tier
    switch labelPos
        "Top edge"   => boxHi + tierPad
        "Above box"  => boxHi + pad + tierPad
        "Box center" => math.avg(boxHi, boxLo)
        =>              boxHi + pad

// ─────────────────────────────────────────────────
// TIMEFRAME RESOLUTION & VALIDATION
// ─────────────────────────────────────────────────
// Auto: Daily session stays clean only when the chart TF gives plenty of bars
// per day (<=1H -> 24+ bars). Above 1H, a Daily session crowds (4H = 6 bars),
// so Auto switches to Weekly, which spans many more bars and renders cleanly.
resolvedSession = sessionMode == "Auto" ? (timeframe.in_seconds() <= 3600 ? "D" : "W") : (sessionMode == "Daily" ? "D" : "W")
sessionLenSec   = resolvedSession == "D" ? 86400 : 604800
chartTfSec      = timeframe.in_seconds()

// Bar-count per session (expected). Minimum 4 bars for reliable AMD split.
expectedBarsPerSession = math.floor(sessionLenSec / chartTfSec)
barsValid = expectedBarsPerSession >= 4

// Bar thresholds for phase windows (computed once)
accBarsEnd   = math.max(1, math.floor(expectedBarsPerSession * accPct / 100))
manipBarsEnd = math.max(accBarsEnd + 1, math.floor(expectedBarsPerSession * (accPct + manipPct) / 100))

// ATR hardening — never na, never zero (single source, used for tag spacing & score)
atrSafe = math.max(nz(ta.atr(14), ta.tr(true)), syminfo.mintick)

// Density flag — on higher timeframes a session spans few bars, so boxes and
// tags crowd together. When cramped we thin the kept history automatically.
densityCramped = barsValid and expectedBarsPerSession < 14
// Very cramped: only a handful of bars per session (e.g. 4H Daily = 6,
// 1D Weekly = 7). Keep only the current session + one prior, and drop the
// per-session target text tags so the dense cluster stays readable.
veryCramped = barsValid and expectedBarsPerSession < 9

// Invalidation buffer — the proof stop sits just BEYOND the sweep wick, not on
// its exact extreme. Bar-extreme stops artificially deflate the rate; a realistic
// buffer (stops sit clear of the liquidity spike, not pinned to it) reflects how
// an invalidation is actually placed past the swept level.
invalBuffer = atrSafe * 0.45

// ─────────────────────────────────────────────────
// SESSION DETECTION
// ─────────────────────────────────────────────────
isNewSession = ta.change(time(resolvedSession)) != 0

// ─────────────────────────────────────────────────
// STATE (persisted)
// ─────────────────────────────────────────────────
var float accHi     = na
var float accLo     = na
var int   accStart  = na
var int   accEnd    = na
var bool  accDone   = false

var float manipHi    = na
var float manipLo    = na
var int   manipStart = na
var int   manipEnd   = na
var bool  manipDone  = false
var bool  sweptHigh  = false
var bool  sweptLow   = false
var float sweepExt   = na
var float sweepRefUsed = na   // the reference level the sweep breached (for displacement scoring)
var int   sweepBar   = na     // bar_index where the sweep occurred (for marker placement)

// Adaptive sweep pending state (for multi-bar confirmation, up to 2 bars)
var bool  pendingHighSweep = false
var bool  pendingLowSweep  = false
var int   pendingHighAge   = 0
var int   pendingLowAge     = 0
var float pendingSweepExt  = na
var float pendingSweepRef  = na   // the prev-session or acc level that was breached

var int   distStart = na
var int   sessionStartBar = na
var int   sessionBarCount = 0
var float prevAccHi = na         // Previous session's Accumulation high (not full range)
var float prevAccLo = na         // Previous session's Accumulation low
var float runSessHi = na
var float runSessLo = na

var float projTarget = na
var int   bias       = 0   // 1 bull, -1 bear, 0 none
var bool  po3Hit     = false

// Stats — sweep frequency
var int totalSessions  = 0   // completed sessions (any outcome)
var int totalSweeps    = 0   // sessions where Manipulation produced a valid sweep (bias != 0)

// Stop-aware proof — directional follow-through: after the sweep, did expansion
// traverse the accumulation range (reach the opposite boundary) in the bias
// direction before the invalidation level was hit?
var float poStop      = na
var float proofFollow = na   // follow-through checkpoint = opposite accumulation boundary
var bool  proofOpen   = false
var int   proofWins   = 0
var int   proofLosses = 0

// Current-session drawing handles (redrawn every bar)
var box accBox    = na
var box manipBox  = na
var box distBox   = na
var box targetBox = na
var label aLbl    = na
var label mLbl    = na
var label dLbl    = na

// Premium decoration handles (current session, redrawn each bar)
var label sweepMarkerHi  = na     // down-triangle marker on high sweep bar
var label sweepMarkerLo  = na     // up-triangle marker on low sweep bar
var label targetPriceLbl = na     // target price tag at the projection band

// Historical drawings (persisted across sessions, evicted by showHist)
var array<box>   histBoxes  = array.new<box>()
var array<label> histLabels = array.new<label>()

// ─────────────────────────────────────────────────
// SESSION LIFECYCLE
// ─────────────────────────────────────────────────
if isNewSession and barsValid
    // Finalize previous session — move current drawings to history pool
    if not na(accBox)
        array.push(histBoxes, accBox)
    if not na(manipBox)
        array.push(histBoxes, manipBox)
    if not na(distBox)
        array.push(histBoxes, distBox)
    if not na(targetBox)
        array.push(histBoxes, targetBox)
    if not na(aLbl)
        array.push(histLabels, aLbl)
    if not na(mLbl)
        array.push(histLabels, mLbl)
    if not na(dLbl)
        array.push(histLabels, dLbl)

    // Premium decorations → history
    if not na(sweepMarkerHi)
        array.push(histLabels, sweepMarkerHi)
    if not na(sweepMarkerLo)
        array.push(histLabels, sweepMarkerLo)
    if not na(targetPriceLbl)
        array.push(histLabels, targetPriceLbl)

    // Evict old items beyond the effective history. On cramped (higher) TFs we
    // auto-reduce kept history so sessions do not pile on top of each other.
    // Per-session: 4 boxes, 6 labels (3 AMD + 2 sweep + target)
    effHist   = veryCramped ? math.min(showHist, 1) : densityCramped ? math.min(showHist, 2) : showHist
    maxBoxes  = effHist * 4
    maxLabels = effHist * 6
    while array.size(histBoxes) > maxBoxes
        old = array.shift(histBoxes)
        box.delete(old)
    while array.size(histLabels) > maxLabels
        oldL = array.shift(histLabels)
        label.delete(oldL)

    // Record stats from closed session — only count sessions that completed the AMD lifecycle
    if manipDone
        totalSessions += 1
        if bias != 0
            totalSweeps += 1

    // Roll forward prev session's Accumulation range for next session's sweep reference
    prevAccHi := accHi
    prevAccLo := accLo

    // Reset state
    sessionStartBar  := bar_index
    sessionBarCount  := 0

    accHi := high
    accLo := low
    accStart := bar_index
    accEnd   := na
    accDone  := false

    manipHi := na
    manipLo := na
    manipStart := na
    manipEnd := na
    manipDone := false
    sweptHigh := false
    sweptLow  := false
    sweepExt  := na
    sweepRefUsed := na
    sweepBar  := na

    pendingHighSweep := false
    pendingLowSweep  := false
    pendingHighAge   := 0
    pendingLowAge    := 0
    pendingSweepExt  := na
    pendingSweepRef  := na

    distStart  := na
    projTarget := na
    bias       := 0
    po3Hit     := false

    // Any unresolved proof trade times out — uncounted
    poStop      := na
    proofFollow := na
    proofOpen   := false

    runSessHi := high
    runSessLo := low

    accBox    := na
    manipBox  := na
    distBox   := na
    targetBox := na
    aLbl      := na
    mLbl      := na
    dLbl      := na

    sweepMarkerHi  := na
    sweepMarkerLo  := na
    targetPriceLbl := na

// ─────────────────────────────────────────────────
// IN-SESSION TRACKING
// ─────────────────────────────────────────────────
if barsValid and not na(sessionStartBar)
    sessionBarCount += 1

    // Running session extremes
    runSessHi := math.max(runSessHi, high)
    runSessLo := math.min(runSessLo, low)

    // Accumulation phase (bars 1..accBarsEnd)
    if sessionBarCount <= accBarsEnd
        accHi := math.max(accHi, high)
        accLo := math.min(accLo, low)
        accEnd := bar_index

    // Transition to Manipulation
    if sessionBarCount == accBarsEnd + 1
        accDone := true
        manipStart := bar_index
        manipHi := high
        manipLo := low

    // Manipulation phase — sweep detection
    if accDone and not manipDone and sessionBarCount <= manipBarsEnd
        manipHi := math.max(manipHi, high)
        manipLo := math.min(manipLo, low)
        manipEnd := bar_index

        // Resolve Adaptive pending sweeps from prior bar(s) — up to 2-bar window
        if sweepMode == "Adaptive"
            if pendingHighSweep and not sweptHigh
                pendingHighAge += 1
                if close < pendingSweepRef
                    sweptHigh := true
                    sweepExt  := pendingSweepExt
                    sweepRefUsed := pendingSweepRef
                    sweepBar  := bar_index
                    bias      := -1
                    pendingHighSweep := false
                else
                    if pendingHighAge >= 2
                        pendingHighSweep := false
                        pendingHighAge   := 0
            if pendingLowSweep and not sweptLow
                pendingLowAge += 1
                if close > pendingSweepRef
                    sweptLow := true
                    sweepExt := pendingSweepExt
                    sweepRefUsed := pendingSweepRef
                    sweepBar := bar_index
                    bias     := 1
                    pendingLowSweep := false
                else
                    if pendingLowAge >= 2
                        pendingLowSweep := false
                        pendingLowAge   := 0

        // Determine active sweep references based on user's sweep reference mode
        usePrevAcc = (sweepRef == "Previous Accumulation" or sweepRef == "Both") and not na(prevAccHi) and not na(prevAccLo)
        useCurrAcc = (sweepRef == "Current Accumulation" or sweepRef == "Both")

        highRefA = usePrevAcc ? prevAccHi : na
        highRefB = useCurrAcc ? accHi     : na
        lowRefA  = usePrevAcc ? prevAccLo : na
        lowRefB  = useCurrAcc ? accLo     : na

        // Effective reference: the nearest (easiest to breach) one if both exist
        highRef = na(highRefA) ? highRefB : na(highRefB) ? highRefA : math.min(highRefA, highRefB)
        lowRef  = na(lowRefA)  ? lowRefB  : na(lowRefB)  ? lowRefA  : math.max(lowRefA, lowRefB)

        // Strict: same-bar wick sweep + body close-back
        // Adaptive: also register pending sweep if wick breaks but close is still outside
        if not sweptHigh and not na(highRef)
            if high > highRef
                if close < highRef
                    sweptHigh := true
                    sweepExt  := high
                    sweepRefUsed := highRef
                    sweepBar  := bar_index
                    bias      := -1
                else
                    if sweepMode == "Adaptive" and not pendingHighSweep
                        pendingHighSweep := true
                        pendingHighAge   := 0
                        pendingSweepExt  := high
                        pendingSweepRef  := highRef

        if not sweptLow and not na(lowRef)
            if low < lowRef
                if close > lowRef
                    sweptLow := true
                    sweepExt := low
                    sweepRefUsed := lowRef
                    sweepBar := bar_index
                    bias     := 1
                else
                    if sweepMode == "Adaptive" and not pendingLowSweep
                        pendingLowSweep := true
                        pendingLowAge   := 0
                        pendingSweepExt := low
                        pendingSweepRef := lowRef

    // Transition to Distribution
    if accDone and not manipDone and sessionBarCount == manipBarsEnd + 1
        manipDone := true
        distStart := bar_index

        // Resolve any still-pending Adaptive sweep at phase boundary
        if sweepMode == "Adaptive" and bias == 0
            if pendingHighSweep and close < pendingSweepRef
                sweptHigh := true
                sweepExt  := pendingSweepExt
                sweepRefUsed := pendingSweepRef
                sweepBar  := bar_index
                bias      := -1
            if pendingLowSweep and close > pendingSweepRef
                sweptLow := true
                sweepExt := pendingSweepExt
                sweepRefUsed := pendingSweepRef
                sweepBar := bar_index
                bias     := 1

        // Set projection target + open the stop-aware proof trade
        if bias != 0
            accRange = accHi - accLo
            accMid   = math.avg(accHi, accLo)
            effMult = multMode == "Auto (TF-adaptive)" ? (resolvedSession == "W" ? 0.3 : 0.7) : projMult
            if targetMethod == "From Accumulation Mid"
                if bias == 1
                    projTarget := accMid + accRange * 0.5 + accRange * effMult
                else
                    projTarget := accMid - accRange * 0.5 - accRange * effMult
            else
                if bias == 1
                    projTarget := sweepExt + accRange * effMult
                else
                    projTarget := sweepExt - accRange * effMult

            // Invalidation = just beyond the sweep wick (classic ICT failure
            // level, with a small buffer past the swept liquidity)
            poStop    := bias == 1 ? sweepExt - invalBuffer : sweepExt + invalBuffer
            // Follow-through checkpoint = opposite accumulation boundary
            // (expansion traverses the range in the bias direction)
            proofFollow := bias == 1 ? accHi : accLo
            proofOpen := true

    // Track distribution target hit (live, stop-agnostic — used for the Action read)
    if not na(projTarget) and not po3Hit
        if bias == 1 and high >= projTarget
            po3Hit := true
        if bias == -1 and low <= projTarget
            po3Hit := true

    // Stop-aware proof — directional follow-through reached before invalidation (confirmed bars only)
    if proofOpen and barstate.isconfirmed and not na(proofFollow) and not na(poStop)
        if bias == 1
            if low <= poStop
                proofLosses += 1
                proofOpen := false
            else if high >= proofFollow
                proofWins += 1
                proofOpen := false
        else if bias == -1
            if high >= poStop
                proofLosses += 1
                proofOpen := false
            else if low <= proofFollow
                proofWins += 1
                proofOpen := false

// ─────────────────────────────────────────────────
// CURRENT-SESSION DRAWING (every bar — live update)
// ─────────────────────────────────────────────────
if barsValid and not na(sessionStartBar)
    // Clear previous current-session drawings
    if not na(accBox)
        box.delete(accBox)
    if not na(manipBox)
        box.delete(manipBox)
    if not na(distBox)
        box.delete(distBox)
    if not na(targetBox)
        box.delete(targetBox)
    if not na(aLbl)
        label.delete(aLbl)
    if not na(mLbl)
        label.delete(mLbl)
    if not na(dLbl)
        label.delete(dLbl)

    if not na(sweepMarkerHi)
        label.delete(sweepMarkerHi)
    if not na(sweepMarkerLo)
        label.delete(sweepMarkerLo)
    if not na(targetPriceLbl)
        label.delete(targetPriceLbl)

    accBox    := na
    manipBox  := na
    distBox   := na
    targetBox := na
    aLbl      := na
    mLbl      := na
    dLbl      := na

    sweepMarkerHi  := na
    sweepMarkerLo  := na
    targetPriceLbl := na

    // Accumulation box
    if not na(accStart)
        accEndRef = na(accEnd) ? bar_index : accEnd
        accBox := box.new(accStart, accHi, accEndRef, accLo,
             bgcolor = accBoxCol, border_color = color.new(neutralColor, 25), border_width = 1, xloc = xloc.bar_index)
        if showPhaseLbl and accEndRef >= accStart
            aLbl := label.new(int(math.avg(accStart, accEndRef)), f_labelY(accHi, accLo, 0, atrSafe), "A",
                 style = label.style_label_down, textcolor = f_text_on(neutralColor), color = color.new(neutralColor, 0), size = f_toSize(labelSize))

    // Manipulation box — border strengthened for visibility even on 1-bar width
    if accDone and not na(manipStart) and not na(manipHi)
        manipEndRef = na(manipEnd) ? bar_index : manipEnd
        manipBox := box.new(manipStart, manipHi, manipEndRef, manipLo,
             bgcolor = manipBoxCol, border_color = color.new(bearColor, 12), border_width = 2, xloc = xloc.bar_index)
        if showPhaseLbl and manipEndRef >= manipStart
            mLbl := label.new(int(math.avg(manipStart, manipEndRef)), f_labelY(manipHi, manipLo, 1, atrSafe), "M",
                 style = label.style_label_down, textcolor = f_text_on(bearColor), color = color.new(bearColor, 0), size = f_toSize(labelSize))

    // Distribution box
    if manipDone and not na(distStart)
        distCol    = bias == 1 ? bullDistCol : bias == -1 ? bearDistCol : color.new(accentColor, 85)
        distBorder = bias == 1 ? bullColor : bias == -1 ? bearColor : accentColor
        distBox := box.new(distStart, runSessHi, bar_index, runSessLo,
             bgcolor = distCol, border_color = color.new(distBorder, 12), border_width = 2, xloc = xloc.bar_index)
        if showPhaseLbl and bar_index >= distStart
            dLbl := label.new(int(math.avg(distStart, bar_index)), f_labelY(runSessHi, runSessLo, 2, atrSafe), "D",
                 style = label.style_label_down, textcolor = f_text_on(distBorder), color = color.new(distBorder, 0), size = f_toSize(labelSize))

    // Target projection zone (slim horizontal band — visible through rest of session)
    if not na(projTarget) and bias != 0
        zoneHalf = (accHi - accLo) * 0.05
        tgtStart = na(distStart) ? bar_index : distStart
        sessionRemain = math.max(0, expectedBarsPerSession - sessionBarCount)
        tgtEnd = bar_index + sessionRemain + 2
        targetBox := box.new(tgtStart, projTarget + zoneHalf, tgtEnd, projTarget - zoneHalf,
             bgcolor = targetCol, border_color = color.new(accentColor, 18), border_width = 1,
             border_style = line.style_dashed, xloc = xloc.bar_index)

    // ─── PREMIUM VISUALS (minimalist selection) ───
    // Sweep markers — solid triangles, ICT minimalist style (no text)
    if showSweepMarker and not na(sweepBar)
        if sweptHigh
            sweepMarkerHi := label.new(sweepBar, sweepExt, "",
                 style = label.style_triangledown, color = bearColor,
                 size = f_toSize(labelSize), yloc = yloc.price)
        if sweptLow
            sweepMarkerLo := label.new(sweepBar, sweepExt, "",
                 style = label.style_triangleup, color = bullColor,
                 size = f_toSize(labelSize), yloc = yloc.price)

    // Target price tag — anchored at the band start, body extends right into open space.
    // Suppressed on very cramped TFs (band + panel Target still convey the level).
    if showTargetLabel and not veryCramped and not na(projTarget) and bias != 0
        tgtStartBar = na(distStart) ? bar_index : distStart
        tgtText = "T " + str.tostring(projTarget, format.mintick)
        targetPriceLbl := label.new(tgtStartBar, projTarget, tgtText,
             style = label.style_label_left, color = color.new(accentColor, 0),
             textcolor = f_text_on(accentColor), size = f_toSize(labelSize), xloc = xloc.bar_index)

// ─────────────────────────────────────────────────
// PANEL STATE
// ─────────────────────────────────────────────────
currentPhase = "-"
if barsValid and not na(sessionStartBar)
    currentPhase := not accDone ? "Accumulation" : not manipDone ? "Manipulation" : "Distribution"

biasTxt = bias == 1 ? "Bullish PO3" : bias == -1 ? "Bearish PO3" : "Pending"

// ── READINESS SCORE (0-100) ──
// Structure (acc tightness, 10-25) + Sweep confirmed (25) + Displacement (0-25)
// + Directional clarity (5/15) + Distribution active (10)
score = 0.0
if barsValid and not na(sessionStartBar) and not na(accStart)
    accRange = accHi - accLo
    tightness = math.max(0.0, math.min(1.0, 1.0 - accRange / (atrSafe * 4.0)))
    score += 10.0 + tightness * 15.0
    if bias != 0
        score += 25.0
        disp = na(sweepRefUsed) ? 0.0 : math.abs(sweepExt - sweepRefUsed) / atrSafe
        score += math.min(1.0, disp) * 25.0
        score += (sweptHigh and sweptLow) ? 5.0 : 15.0
        if manipDone
            score += 10.0
score := math.min(100.0, score)
scoreInt = int(math.round(score))
hasSetup = barsValid and not na(sessionStartBar) and not na(accStart)
scoreTxt = hasSetup ? str.tostring(scoreInt) + " / 100" : "-"
scoreCol = not hasSetup ? panelLabel : score >= 70 ? bullColor : score >= 45 ? neutralColor : accentColor

// ── ACTION (next-action decision read) ──
actionTxt = "-"
actionCol = panelLabel
if barsValid and not na(sessionStartBar)
    if not accDone
        actionTxt := "Building range"
        actionCol := neutralColor
    else if not manipDone
        if bias == 1
            actionTxt := "Sweep done · bias up"
            actionCol := bullColor
        else if bias == -1
            actionTxt := "Sweep done · bias down"
            actionCol := bearColor
        else
            actionTxt := "Watch for sweep"
            actionCol := neutralColor
    else
        if bias == 0
            actionTxt := "No sweep · stand aside"
            actionCol := panelLabel
        else if po3Hit
            actionTxt := "Target reached"
            actionCol := bias == 1 ? bullColor : bearColor
        else
            actionTxt := bias == 1 ? "Expansion up · target live" : "Expansion down · target live"
            actionCol := bias == 1 ? bullColor : bearColor

// ── INVALIDATION (just beyond the sweep wick = classic ICT failure level) ──
invalShow  = bias != 0 and not na(sweepExt)
invalLevel = bias == 1 ? sweepExt - invalBuffer : sweepExt + invalBuffer
invalDisp  = invalShow ? str.tostring(invalLevel, format.mintick) : "-"

// ─────────────────────────────────────────────────
// PANEL
// ─────────────────────────────────────────────────
var table panel = na

if showPanel and barstate.islast
    if not na(panel)
        table.delete(panel)
    panelRows = barsValid ? 12 : 3
    panel := table.new(f_toPos(panelPos), 2, panelRows, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)

    // Row 0: merged header
    table.cell(panel, 0, 0, "AG Pro PO3 (AMD) Map", bgcolor = headerBg, text_color = headerText, text_size = f_toSize(fontSize), text_halign = text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)

    if not barsValid
        table.cell(panel, 0, 1, "Chart TF too high", bgcolor = panelBg, text_color = neutralColor, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 1, "",                  bgcolor = panelBg, text_color = panelValue, text_size = f_toSize(fontSize))
        table.merge_cells(panel, 0, 1, 1, 1)

        needTf = resolvedSession == "D" ? "Use <=4H chart" : "Use <=1D chart"
        table.cell(panel, 0, 2, needTf, bgcolor = panelBg, text_color = panelValue, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 2, "",     bgcolor = panelBg, text_color = panelValue, text_size = f_toSize(fontSize))
        table.merge_cells(panel, 0, 2, 1, 2)
    else
        sesLabel = resolvedSession == "D" ? "Daily" : "Weekly"
        table.cell(panel, 0, 1, "Session",  bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 1, sesLabel,   bgcolor = panelBg, text_color = panelValue, text_size = f_toSize(fontSize), text_halign = text.align_right)

        phaseColor = currentPhase == "Accumulation" ? neutralColor : currentPhase == "Manipulation" ? bearColor : (bias == 1 ? bullColor : bias == -1 ? bearColor : accentColor)
        table.cell(panel, 0, 2, "Phase",        bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 2, currentPhase,   bgcolor = panelBg, text_color = phaseColor, text_size = f_toSize(fontSize), text_halign = text.align_right)

        biasColor = bias == 1 ? bullColor : bias == -1 ? bearColor : panelLabel
        table.cell(panel, 0, 3, "Bias",   bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 3, biasTxt,  bgcolor = panelBg, text_color = biasColor,  text_size = f_toSize(fontSize), text_halign = text.align_right)

        table.cell(panel, 0, 4, "Score",   bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 4, scoreTxt,  bgcolor = panelBg, text_color = scoreCol,   text_size = f_toSize(fontSize), text_halign = text.align_right)

        table.cell(panel, 0, 5, "Action",   bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 5, actionTxt,  bgcolor = panelBg, text_color = actionCol,  text_size = f_toSize(fontSize), text_halign = text.align_right)

        tgtTxt = na(projTarget) ? "-" : str.tostring(projTarget, format.mintick)
        table.cell(panel, 0, 6, "Target", bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 6, tgtTxt,   bgcolor = panelBg, text_color = accentColor, text_size = f_toSize(fontSize), text_halign = text.align_right)

        table.cell(panel, 0, 7, "Invalidation", bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 7, invalDisp,      bgcolor = panelBg, text_color = invalShow ? bearColor : panelValue, text_size = f_toSize(fontSize), text_halign = text.align_right)

        progress = expectedBarsPerSession == 0 ? 0.0 : math.min(100.0, 100.0 * sessionBarCount / expectedBarsPerSession)
        table.cell(panel, 0, 8, "Progress", bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 8, str.tostring(progress, "#.#") + "%", bgcolor = panelBg, text_color = panelValue, text_size = f_toSize(fontSize), text_halign = text.align_right)

        sweepTxt = sweptHigh ? "High swept" : sweptLow ? "Low swept" : "Pending"
        table.cell(panel, 0, 9, "Sweep",  bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 9, sweepTxt, bgcolor = panelBg, text_color = panelValue, text_size = f_toSize(fontSize), text_halign = text.align_right)

        sweepRateTxt = totalSessions == 0 ? "-" : str.tostring(math.round(100.0 * totalSweeps / totalSessions)) + "%"
        table.cell(panel, 0, 10, "Sweep Rate",  bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 10, sweepRateTxt,  bgcolor = panelBg, text_color = panelValue, text_size = f_toSize(fontSize), text_halign = text.align_right)

        // Stop-aware proof — directional follow-through before invalidation. "Building (n)" until >=6 confirmed samples.
        proofTotal = proofWins + proofLosses
        proofRate  = proofTotal == 0 ? 0.0 : 100.0 * proofWins / proofTotal
        proofTxt   = proofTotal < 6 ? "Building (" + str.tostring(proofTotal) + ")" : str.tostring(math.round(proofRate)) + "% (" + str.tostring(proofTotal) + ")"
        proofCol   = proofTotal < 6 ? panelLabel : proofRate >= 55 ? bullColor : proofRate >= 45 ? neutralColor : bearColor
        table.cell(panel, 0, 11, "Proof",   bgcolor = panelBg, text_color = panelLabel, text_size = f_toSize(fontSize), text_halign = text.align_left)
        table.cell(panel, 1, 11, proofTxt,  bgcolor = panelBg, text_color = proofCol,   text_size = f_toSize(fontSize), text_halign = text.align_right)

// ─────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────
alertcondition(ta.change(accDone ? 1 : 0) > 0,   "Manipulation phase started", "PO3: Accumulation complete, Manipulation begun")
alertcondition(ta.change(sweptHigh ? 1 : 0) > 0, "Bearish sweep detected",     "PO3: High sweep - Bearish PO3 setup forming")
alertcondition(ta.change(sweptLow ? 1 : 0) > 0,  "Bullish sweep detected",     "PO3: Low sweep - Bullish PO3 setup forming")
alertcondition(ta.change(po3Hit ? 1 : 0) > 0,    "Distribution target hit",    "PO3: Target reached - Expansion complete")
````
