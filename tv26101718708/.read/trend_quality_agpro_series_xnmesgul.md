# Trend Quality [AGPro Series]

- url: https://www.tradingview.com/script/XNmESgul-Trend-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;7691a15e871a42598c04dd6584dc7b18
- version: 4.0

## Description

Trend Quality [AGPro Series]

Trend Quality [AGPro Series] fuses three independent regime dimensions — ADX directional strength, Kaufman Efficiency Ratio, and ATR-normalized EMA slope — into a single 0–100 composite Trend Quality Score. A hysteresis + confirmation + cooldown gate turns that score into a stable TREND / CHOP regime, enhanced with HTF confirmation, lifecycle phases, score velocity, breakout grading, directional dominance, and a full adaptive on-chart quality window. The goal is simple: replace noisy "is this a trend?" guessing with a transparent, multi-dimensional, low-lag quality reading you can read in one glance.


🎯 OVERVIEW

Most trend filters fail at the same thing — they tell you a trend exists, but not whether that trend is clean, accelerating, fading, or already exhausted. Trend Quality answers the harder question. Every bar is scored on three independent dimensions that each measure a different physical property of price movement:

•  ADX — directional strength (how strongly one side dominates)
•  Kaufman Efficiency Ratio (ER) — path efficiency (how little wasted motion)
•  ATR-normalized EMA slope — normalized trend velocity (how fast, relative to volatility)

These three signals are combined into one 0–100 Trend Quality Score. A hysteresis band + confirmation bars + cooldown filter convert that score into a stable TREND / CHOP regime — no single-bar flipping, no false recovery wicks. On top of the core regime, the indicator layers Score Velocity, Lifecycle phases (Emerging → Confirmed → Exhausting), Breakout Quality grading (A / B / C), directional dominance, and a visual Quality Window that tracks the active trend zone and projects it forward.


💎 UNIQUE EDGE

What separates Trend Quality from a standard ADX filter, an EMA slope indicator, or a generic regime meter:

•  Tri-factor fusion (not a single metric) — ADX alone misses path quality; ER alone misses direction; slope alone misses choppy-but-strong moves. Weighted fusion (45% ADX, 35% ER, 20% Slope) neutralizes each component's blind spot.

•  Stable regime, not a flickering line — the TREND / CHOP state passes through a 3-layer filter: hysteresis band around the threshold, N confirmation bars, and a cooldown window after every transition. The result is a regime reading that holds through pullbacks without flipping.

•  Score Velocity Engine — a second-derivative layer that watches how fast the score itself is changing. Surges flag momentum ignition; collapses flag quality breakdown before price confirms it. A bearish divergence detector fires when price makes new highs while quality is fading.

•  Lifecycle phases — inside every TREND regime, the script distinguishes Emerging (young, fresh, accelerating), Confirmed (mature, stable, above buffer), and Exhausting (score rolling over from a peak). This lets you see whether you are entering early, running mid-trend, or catching the end.

•  Breakout Quality Badge (A / B / C) — every CHOP → TREND transition receives a graded badge based on composite score plus velocity bonus. Grade A breakouts are rare and have an optional dedicated alert.

•  HTF confirmation with Auto-HTF mapping — the same engine runs on a higher timeframe. When LTF is trending but HTF is not, the regime is marked BLOCKED (not forced to CHOP) so you retain full transparency about why the regime is gated.

•  Adaptive Quality Window — a live rectangular zone that tracks the full trend's high/low from its start bar, projects forward, shows ceiling/floor projection labels, and preserves historical windows with directional color coding (green for up-trends, pink for down-trends, amber for HTF-blocked trends).


🧪 METHODOLOGY

Core composite score (every bar, LTF):
Score = 100 × (0.45 × ADX_norm  +  0.35 × ER_norm  +  0.20 × Slope_norm)

•  ADX_norm      = min(ADX / 50, 1)
•  ER_norm       = |close − close[N]| / (SMA(|Δclose|, N) × N)
•  Slope_norm    = min(|EMA − EMA[1]| / ATR × 10, 1)

Regime gating:
•  Hysteresis: +3 above threshold to enter TREND, −3 below to enter CHOP
•  Confirmation: N consecutive bars above/below the hysteresis band
•  Cooldown: N bars after every regime flip where no new flip is allowed

MTF confirmation (optional, default ON):
The same core function is called via request.security on the HTF (Auto: 30m→4H, 4H→Daily, Daily→Weekly, Weekly→Monthly in Strict mode). When LTF=TREND but HTF=CHOP, the regime is tagged BLOCKED — a transparent third state that is neither forced-CHOP nor accepted-TREND.

Lifecycle logic:
•  Emerging: TREND is young (bars since start ≤ Emerging Bars) OR score slope ≥ 0 and score below buffer
•  Confirmed: score ≥ threshold + Confirmed Buffer AND HTF passes (optional)
•  Exhausting: score slope < 0 AND pullback from peak ≥ Exhaustion Pullback

Score velocity:
velocity = score − score[velocityLen]   (default 5-bar look-back)

Breakout quality grading:
bqScore = score + velocity_bonus  (bonus: +15 if vel>15, +7 if vel>5, else 0)
A ≥ 82, B ≥ 67, C < 67


🔔 SIGNALS & ALERTS

The script exposes 12 alert conditions — all moderator-safe, educational, non-solicitating:

•  CHOP → TREND / TREND → CHOP   regime flips with LTF+HTF context
•  Strong Trend                 composite conviction threshold
•  HTF Blocked / HTF Unblocked  third-state transparency events
•  Emerging / Confirmed / Exhausting Trend   lifecycle phase changes
•  Velocity Surge / Velocity Collapse   second-derivative extremes
•  Grade-A Breakout             rare high-conviction breakouts
•  Bearish Divergence           price up, quality down warning

On-chart visual events (also filterable via inputs):
•  Breakout Quality badge (A / B / C) at every CHOP → TREND
•  Bearish divergence ⚠ marker at trend peaks where quality fades
•  State tag near backbone: EMERGING / CONFIRMED / EXHAUSTING / HTF BLOCKED
•  Quality Window label: ACTIVE + phase
•  Projection labels on the right edge: QUALITY CEILING / TREND FLOOR

All badge and warning labels are gated with an 8-bar cooldown so the chart stays clean even on repeated intra-swing triggers.


⚙️ KEY INPUTS

Core engine:
•  ADX Length (14) — directional strength look-back
•  Efficiency Length (20) — ER path-efficiency window
•  Slope EMA Length (50) — trend backbone reference
•  ATR Length (14) — volatility normalization
•  TREND Threshold (55) — composite score level to enter TREND
•  Confirmation Bars (1) — bars of persistence before flipping
•  Strong Trend Offset (15) — extra score above threshold for STRONG tag

MTF:
•  HTF Confirmation (ON) — enable/disable HTF gate
•  Auto HTF (ON, Strict) — smart HTF mapping per chart TF
•  Manual HTF (240) — override timeframe

Stability:
•  Change Cooldown Bars (2) — lock-out window after any regime flip

Lifecycle:
•  Emerging Phase Bars (4) — max trend age to stay Emerging
•  Confirmed Buffer (8.0) — score must clear threshold+buffer
•  Exhaustion Pullback (4.0) — peak-to-current drop to flag Exhausting

Visual Overlay:
•  Backbone + Glow + Zone + State Candles + Quality Window + Historical Windows + Projection Box + Guides + Midline (all toggleable)

Panel, Theme, Layout, Help rows, Alerts, Score Velocity Engine, Breakout Quality Badge, Divergence Detector — every layer has its own input group and can be shown/hidden independently.


📘 HOW TO USE

Read-in-one-glance panel (standard AGPro format):
•  Blue header row: script title
•  Line 2: REGIME / LIFECYCLE · Score N/100 · Velocity state
•  Line 3: LTF regime · Direction · Directional Dominance
•  Line 4: HTF regime · MTF PASS/BLOCKED · Active Window state · Streak

Quick playbook:
1.  CHOP on LTF → wait. No setup, no commitment.
2.  CHOP → TREND transition with Grade A badge + HTF PASS → highest-conviction regime start.
3.  CONFIRMED phase with DOM HIGH and rising score → the middle of the trend, usually the cleanest section.
4.  Velocity COLLAPSE or EXHAUSTING phase with bearish divergence ⚠ → quality is deteriorating; reduce exposure or tighten stops.
5.  HTF BLOCKED amber window → LTF trend exists but higher timeframe disagrees; treat as lower-conviction and be aware of mean-reversion risk.

The indicator does NOT issue buy/sell signals, does NOT define entry/exit prices, and is NOT a strategy. It is a regime-quality reading — a context layer you pair with your own trade management.


⚠️ LIMITATIONS & TRANSPARENCY

•  Trend-quality indicators are inherently trend-following. In low-volatility ranges the score can stay above threshold on minor moves; in very fast markets the score can lag by 1–3 bars while the filters stabilize.
•  HTF confirmation introduces a natural HTF delay. This is intentional (it removes noise) but means the HTF gate may lift several LTF bars after price has already moved.
•  All composite signals rely on look-backs (ADX 14, ER 20, Slope EMA 50, ATR 14). On very short intraday timeframes with low bar counts these need calibration.
•  Lifecycle phases are structural readings, not predictions. EXHAUSTING means the score is rolling over — not that price must reverse.
•  Past performance of any visual regime does not imply future performance. Charts showing clean historical windows are illustrative of the indicator's logic, not trading results.
•  No repainting on historical bars. The HTF call uses lookahead_off and barmerge.gaps_off. Score and regime values on closed bars are final.


🛡️ RISK DISCLOSURE

This script is published as an educational and analytical tool. It does not provide financial advice, does not generate trade signals of any kind, and must not be used as a standalone decision system. Markets involve substantial risk of loss. Past behavior of any market regime, indicator output, or historical visual window is no guarantee of future results. Always combine any indicator with independent risk management, position sizing, a tested plan, and — where appropriate — the guidance of a licensed professional. You are solely responsible for any trading decisions you make.

## Source Code

````pine
// -------------------------------------------------
// Trend Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 3.7
//
// Quantitative trend-quality analyzer that blends ADX directional strength,
// Kaufman Efficiency Ratio and ATR-normalized EMA slope into a 0-100 trend
// quality score. It maps TREND, CHOP, EMERGING, CONFIRMED and EXHAUSTING
// phases with HTF confirmation, velocity context, a trend hold-rate proof,
// active quality zones, controlled labels and a premium status panel for
// discretionary trend analysis, breakout filtering and market regime
// interpretation.
// This is an analytical visualization tool, not a prediction engine and not
// financial advice.
// Version 3.7 refreshes the publication presentation only. Core calculations,
// alerts, inputs and runtime behavior remain unchanged.
// -------------------------------------------------

//@version=6
indicator("Trend Quality [AGPro Series]",
     shorttitle       = "AG TQ",
     overlay          = true,
     max_labels_count = 220,
     max_lines_count  = 80,
     max_boxes_count  = 80)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
// Brand
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
// Panel
panelBgD      = color.rgb(15, 23, 42)
panelBorderD  = color.rgb(51, 65, 85)
panelLabelD   = color.rgb(148, 163, 184)
panelValueD   = color.rgb(226, 232, 240)
panelBgL      = color.rgb(248, 250, 252)
panelBorderL  = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueL   = color.rgb(15, 23, 42)
// States
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupCore  = "Core Engine"
groupMtf   = "MTF Confirmation"
groupLife  = "Lifecycle"
groupViz   = "Visuals"
groupPanel = "Panel"
groupAlert = "Alerts"

adxLen = input.int(14, "ADX Length", minval = 2, maxval = 80, group = groupCore,
     tooltip = "Length used for ADX directional-strength measurement. Higher values smooth the strength reading; lower values react faster.")

erLen = input.int(20, "Efficiency Length", minval = 2, maxval = 120, group = groupCore,
     tooltip = "Lookback used for Kaufman Efficiency Ratio. Higher values reward cleaner directional travel across a wider window.")

slopeLen = input.int(50, "Slope EMA Length", minval = 2, maxval = 300, group = groupCore,
     tooltip = "EMA length used for ATR-normalized trend slope. Longer values emphasize structural direction; shorter values react faster.")

atrLen = input.int(14, "ATR Length", minval = 1, maxval = 100, group = groupCore,
     tooltip = "ATR length used to normalize EMA slope and to size visual zones.")

trendThreshold = input.float(55.0, "Trend Threshold", minval = 1.0, maxval = 99.0, step = 0.5, group = groupCore,
     tooltip = "Minimum composite quality score required before a TREND regime can qualify.")

confirmBars = input.int(2, "Confirmation Bars", minval = 1, maxval = 10, group = groupCore,
     tooltip = "Number of consecutive bars required to confirm a regime transition. Higher values reduce noisy flips.")

hysteresis = input.float(3.0, "Hysteresis Buffer", minval = 0.0, maxval = 20.0, step = 0.5, group = groupCore,
     tooltip = "Buffer around the trend threshold used to stabilize TREND and CHOP transitions.")

useHTF = input.bool(true, "Use HTF Confirmation", group = groupMtf,
     tooltip = "When enabled, TREND status requires higher-timeframe agreement unless HTF mode is disabled.")

autoHTF = input.bool(true, "Auto HTF", group = groupMtf,
     tooltip = "Automatically selects a higher timeframe based on the chart timeframe.")

manualHTF = input.timeframe("240", "Manual HTF", group = groupMtf,
     tooltip = "Higher timeframe used when Auto HTF is disabled.")

strongOffset = input.float(14.0, "Strong Trend Offset", minval = 5.0, maxval = 35.0, step = 0.5, group = groupLife,
     tooltip = "Score distance above the trend threshold required for a strong confirmed trend classification.")

emergingBars = input.int(5, "Emerging Phase Bars", minval = 1, maxval = 30, group = groupLife,
     tooltip = "Maximum age of a new trend that can be classified as EMERGING.")

velocityLen = input.int(5, "Velocity Lookback", minval = 2, maxval = 30, group = groupLife,
     tooltip = "Lookback used to measure score velocity. Positive velocity means quality is improving; negative velocity means quality is fading.")

fadeVelocity = input.float(-5.0, "Exhaustion Velocity", minval = -30.0, maxval = -1.0, step = 0.5, group = groupLife,
     tooltip = "Velocity level below which an active trend can be classified as EXHAUSTING.")

proofHoldBars = input.int(8, "Trend Hold Proof Bars", minval = 3, maxval = 60, group = groupLife,
     tooltip = "Bars a confirmed trend must survive without collapsing back to CHOP to count as a hold in the Trend Hold proof. This is a historical track record, not a prediction.")

showBackbone = input.bool(true, "Show Trend Backbone", group = groupViz,
     tooltip = "Plots the EMA backbone colored by current trend quality state.")

showQualityZone = input.bool(true, "Show Quality Zone", group = groupViz,
     tooltip = "Draws an ATR-scaled zone around the backbone when trend quality is active or recently confirmed.")

showTransitionLabels = input.bool(true, "Show Transition Labels", group = groupViz,
     tooltip = "Shows compact labels for meaningful TREND, CHOP, CONFIRMED and EXHAUSTING transitions.")

labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = groupViz,
     tooltip = "Controls label frequency. Minimal shows only confirmed/exhausting trend labels. Balanced adds important trend lifecycle transitions. Detailed also adds HTF-block context labels.")

labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupViz,
     tooltip = "Font size for on-chart labels. Default Normal follows the AGPro Series visual standard.")

minLabelGapBars = input.int(22, "Minimum Label Gap (bars)", minval = 1, maxval = 120, group = groupViz,
     tooltip = "Minimum bar distance between transition labels. This avoids stacked labels around the same swing.")

showRightTag = input.bool(true, "Show Right-Edge State Tag", group = groupViz,
     tooltip = "Shows a compact live state tag near the right edge with phase, score and velocity.")

showStateCandles = input.bool(false, "Tint Candles by State", group = groupViz,
     tooltip = "Optionally tints candles during active trend-quality regimes. Disabled by default for a cleaner publication view.")

zoneAtrMult = input.float(0.85, "Quality Zone Width (ATR)", minval = 0.10, maxval = 3.00, step = 0.05, group = groupViz,
     tooltip = "ATR multiplier used to size the quality zone around the backbone.")

showPanel = input.bool(true, "Show Panel", group = groupPanel,
     tooltip = "Displays the on-chart Trend Quality panel with score, phase, HTF state, velocity, hold rate and component context. Enabled by default.")

panelPosition = input.string("Top Right", "Panel Position",
     options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"],
     group = groupPanel,
     tooltip = "Anchor position for the status panel.")

panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel,
     tooltip = "Panel color theme. Dark is the default publication style; Light is useful on bright chart layouts.")

panelSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel,
     tooltip = "Font size used inside the panel.")

enableAlerts = input.bool(true, "Enable Alert Conditions", group = groupAlert,
     tooltip = "Enables TradingView alert conditions for regime, lifecycle and velocity events.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_pos(p) =>
    switch p
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

f_auto_htf() =>
    sec = timeframe.in_seconds(timeframe.period)
    sec <= 15 * 60 ? "60" :
     sec <= 60 * 60 ? "240" :
     sec <= 4 * 60 * 60 ? "D" :
     sec <= 24 * 60 * 60 ? "W" :
     "M"

f_meter(v) =>
    v >= 85 ? "A+" :
     v >= 75 ? "A" :
     v >= 65 ? "B" :
     v >= 50 ? "C" :
     v >= 35 ? "D" :
     "E"

f_panel_bg(isLight, alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : panelBgL) : (alt ? color.rgb(24, 35, 55) : panelBgD)

f_panel_label(isLight) =>
    isLight ? panelLabelL : panelLabelD

f_panel_value(isLight) =>
    isLight ? panelValueL : panelValueD

// -------------------------------------------------
// Core Score Function
// -------------------------------------------------
f_quality_score(simple int _adxLen, simple int _erLen, simple int _slopeLen, simple int _atrLen) =>
    [pdi, mdi, adxVal] = ta.dmi(_adxLen, _adxLen)
    adxScore = f_clamp(adxVal / 50.0, 0.0, 1.0)

    erMove = math.abs(close - close[_erLen])
    erNoise = 0.0
    for i = 0 to _erLen - 1
        erNoise += math.abs(close[i] - close[i + 1])
    erRaw = erNoise > 0 ? erMove / erNoise : 0.0
    erScore = f_clamp(erRaw, 0.0, 1.0)

    emaVal = ta.ema(close, _slopeLen)
    atrVal = ta.atr(_atrLen)
    slopeRaw = math.abs(emaVal - emaVal[1])
    slopeScore = atrVal > 0 ? f_clamp((slopeRaw / atrVal) * 10.0, 0.0, 1.0) : 0.0

    score = 100.0 * (0.45 * adxScore + 0.35 * erScore + 0.20 * slopeScore)
    dirUp = pdi >= mdi
    [score, dirUp, adxScore * 100.0, erScore * 100.0, slopeScore * 100.0, emaVal, atrVal]

[scoreRaw, dirUp, adxComponent, erComponent, slopeComponent, backbone, atr] = f_quality_score(adxLen, erLen, slopeLen, atrLen)

htf = autoHTF ? f_auto_htf() : manualHTF
[scoreHTF, dirUpHTF, htfAdxComponent, htfErComponent, htfSlopeComponent, htfBackbone, htfAtr] = request.security(syminfo.tickerid, htf, f_quality_score(adxLen, erLen, slopeLen, atrLen), barmerge.gaps_off, barmerge.lookahead_off)
htfTrend = scoreHTF >= trendThreshold
htfPass = not useHTF or htfTrend

// -------------------------------------------------
// Regime Engine
// -------------------------------------------------
trendCandidate = scoreRaw >= trendThreshold + hysteresis
chopCandidate = scoreRaw <= trendThreshold - hysteresis

var int trendCount = 0
var int chopCount = 0
var int regime = 0

trendCount := trendCandidate ? trendCount + 1 : 0
chopCount := chopCandidate ? chopCount + 1 : 0

if regime == 0 and trendCount >= confirmBars and htfPass
    regime := 1
else if regime == 1 and chopCount >= confirmBars
    regime := 0

blockedByHTF = useHTF and trendCandidate and not htfTrend
isTrend = regime == 1
isChop = not isTrend
isStrong = isTrend and scoreRaw >= trendThreshold + strongOffset

var int trendAge = 0
trendAge := isTrend ? (regime[1] == 1 ? trendAge[1] + 1 : 1) : 0

scoreVelocity = scoreRaw - nz(scoreRaw[velocityLen], scoreRaw)

phase = isChop ? "CHOP" :
     trendAge <= emergingBars ? "EMERGING" :
     scoreVelocity <= fadeVelocity ? "EXHAUSTING" :
     isStrong ? "CONFIRMED" :
     "TREND"

phaseColor = blockedByHTF ? neutralColor :
     phase == "CONFIRMED" ? bullColor :
     phase == "EMERGING" ? neutralColor :
     phase == "EXHAUSTING" ? bearColor :
     phase == "TREND" ? (dirUp ? bullColor : bearColor) :
     color.rgb(100, 116, 139)

dirText = dirUp ? "Up" : "Down"
htfText = useHTF ? (htfPass ? "PASS" : "BLOCK") : "OFF"
actionText = blockedByHTF ? "HTF BLOCK" :
     phase == "CONFIRMED" ? "MONITOR" :
     phase == "EMERGING" ? "BUILDING" :
     phase == "EXHAUSTING" ? "REVIEW" :
     phase == "TREND" ? "TREND" :
     "WAIT"

// Transition booleans (defined here so the proof and labels can share them)
trendStart = isTrend and not isTrend[1]
trendEnd = isChop and not isChop[1]
confirmedStart = phase == "CONFIRMED" and phase[1] != "CONFIRMED"
exhaustStart = phase == "EXHAUSTING" and phase[1] != "EXHAUSTING"
blockedStart = blockedByHTF and not blockedByHTF[1]

// -------------------------------------------------
// Trend hold-rate proof (Confirm Rate)
// -------------------------------------------------
var int  trTotal    = 0
var int  trHeld     = 0
var bool pendActive = false
var int  pendLeft   = 0

if barstate.isconfirmed
    if pendActive
        if isChop
            trTotal += 1
            pendActive := false
            pendLeft := 0
        else if pendLeft <= 1
            trTotal += 1
            trHeld += 1
            pendActive := false
            pendLeft := 0
        else
            pendLeft -= 1
    if trendStart and not pendActive
        pendActive := true
        pendLeft := proofHoldBars

trendHoldRate = trTotal > 0 ? trHeld / trTotal * 100.0 : na

// -------------------------------------------------
// Visual Overlay
// -------------------------------------------------
labelSize = f_size(labelSizeInput)
zoneActive = showQualityZone and (isTrend or blockedByHTF)
zoneUpper = zoneActive ? backbone + atr * zoneAtrMult : na
zoneLower = zoneActive ? backbone - atr * zoneAtrMult : na

pBackboneGlow = plot(showBackbone ? backbone : na,
     title = "Trend Quality Backbone",
     color = color.new(phaseColor, isTrend or blockedByHTF ? 8 : 34),
     linewidth = 2)

pZoneUpper = plot(zoneUpper, "Quality Zone Upper", color = color.new(phaseColor, 70), linewidth = 1)
pZoneLower = plot(zoneLower, "Quality Zone Lower", color = color.new(phaseColor, 70), linewidth = 1)
fill(pZoneUpper, pZoneLower, color = zoneActive ? color.new(phaseColor, isTrend ? 83 : 90) : na, title = "Quality Zone Fill")

barcolor(showStateCandles and isTrend ? color.new(phaseColor, 62) : na)

// -------------------------------------------------
// Labels
// -------------------------------------------------
var array<label> transitionLabels = array.new<label>()
var int lastLabelBar = na
var label rightTag = na

f_keep_transition_label(lbl) =>
    array.push(transitionLabels, lbl)
    while array.size(transitionLabels) > 18
        old = array.shift(transitionLabels)
        if not na(old)
            label.delete(old)

barsOk = na(lastLabelBar) or bar_index - lastLabelBar >= minLabelGapBars
densityOk = labelDensity == "Minimal" ? (confirmedStart or exhaustStart) :
     labelDensity == "Balanced" ? (trendStart or confirmedStart or exhaustStart) :
     (trendStart or trendEnd or confirmedStart or exhaustStart or blockedStart)

if showTransitionLabels and barsOk and densityOk
    isUpLabel = dirUp
    y = isUpLabel ? high + atr * 0.85 : low - atr * 0.85
    style = isUpLabel ? label.style_label_down : label.style_label_up
    txt = blockedStart ? "HTF Block" :
         confirmedStart ? "Confirmed Trend" :
         exhaustStart ? "Exhausting Trend" :
         trendEnd ? "Chop Returns" :
         "Trend Building"
    detail = labelDensity == "Detailed" ? "\nScore " + str.tostring(scoreRaw, "#") + " | HTF " + htfText + " | Vel " + str.tostring(scoreVelocity, "#.#") : "\nScore " + str.tostring(scoreRaw, "#") + " | " + dirText
    lbl = label.new(bar_index, y, txt + detail,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = style,
         color = color.new(phaseColor, 4),
         textcolor = phase == "EMERGING" or blockedStart ? color.rgb(17, 24, 39) : headerText,
         size = labelSize,
         tooltip = "Trend Quality transition label. It marks a confirmed regime or lifecycle change, not a prediction or trade instruction.")
    f_keep_transition_label(lbl)
    lastLabelBar := bar_index

if showRightTag and barstate.islast
    if not na(rightTag)
        label.delete(rightTag)
    tagX = bar_index + 8
    tagY = backbone + (dirUp ? atr * 1.05 : -atr * 1.05)
    tagTxt = phase + " | Score " + str.tostring(scoreRaw, "#") + " | Vel " + str.tostring(scoreVelocity, "#.#")
    rightTag := label.new(tagX, tagY, tagTxt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_left,
         color = color.new(phaseColor, 0),
         textcolor = phase == "EMERGING" or blockedByHTF ? color.rgb(17, 24, 39) : headerText,
         size = labelSize)
else if not showRightTag and not na(rightTag)
    label.delete(rightTag)
    rightTag := na

// Tiny state markers add context without label clutter.
plotshape(trendStart, title = "Trend Start Marker", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny)
plotshape(exhaustStart, title = "Exhausting Marker", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny)
plotshape(blockedStart, title = "HTF Block Marker", style = shape.square, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelSize = f_size(panelSizeInput)
isLightPanel = panelTheme == "Light"
panelBg = f_panel_bg(isLightPanel, false)
panelAltBg = f_panel_bg(isLightPanel, true)
panelBorder = isLightPanel ? panelBorderL : panelBorderD
panelLabelCol = f_panel_label(isLightPanel)
panelValueCol = f_panel_value(isLightPanel)
darkText = color.rgb(17, 24, 39)

holdRateText = trTotal > 0 ? str.tostring(int(math.round(trendHoldRate))) + "% (" + str.tostring(trTotal) + ")" : "Building"
holdRateColor = na(trendHoldRate) ? panelValueCol : trendHoldRate >= 55 ? bullColor : trendHoldRate >= 40 ? neutralColor : bearColor

var table panel = na

if showPanel and na(panel)
    panel := table.new(f_pos(panelPosition), 2, 8, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
    table.cell(panel, 0, 0, "AG Pro Trend Quality", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na

if showPanel and not na(panel) and barstate.islast
    table.set_position(panel, f_pos(panelPosition))
    table.clear(panel, 0, 1, 1, 7)

    actionBg = actionText == "WAIT" ? panelAltBg : phaseColor
    actionTc = actionText == "WAIT" ? panelValueCol : (phase == "EMERGING" or blockedByHTF ? darkText : headerText)

    table.cell(panel, 0, 1, "Phase", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, phase, text_color = phaseColor, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 2, "Action", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, actionText, text_color = actionTc, bgcolor = actionBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 3, "Score", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, str.tostring(scoreRaw, "#") + " / 100  " + f_meter(scoreRaw), text_color = scoreRaw >= trendThreshold ? bullColor : neutralColor, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 4, "Trend Hold", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, holdRateText, text_color = holdRateColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 5, "HTF / Dir", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 5, htfText + " / " + dirText, text_color = htfPass ? panelValueCol : neutralColor, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

    table.cell(panel, 0, 6, "Velocity", text_color = panelLabelCol, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 6, str.tostring(scoreVelocity, "#.#"), text_color = scoreVelocity >= 0 ? bullColor : bearColor, bgcolor = panelAltBg, text_size = panelSize, text_halign = text.align_right)

    compText = "ADX " + str.tostring(adxComponent, "#") + " | ER " + str.tostring(erComponent, "#") + " | SLP " + str.tostring(slopeComponent, "#")
    table.cell(panel, 0, 7, "Components", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_left)
    table.cell(panel, 1, 7, compText, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize, text_halign = text.align_right)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(enableAlerts and trendStart, "Trend Quality: Trend Building", "Trend Quality: trend regime started.")
alertcondition(enableAlerts and confirmedStart, "Trend Quality: Confirmed Trend", "Trend Quality: trend quality confirmed.")
alertcondition(enableAlerts and exhaustStart, "Trend Quality: Exhausting Trend", "Trend Quality: trend quality is exhausting.")
alertcondition(enableAlerts and trendEnd, "Trend Quality: Chop Returns", "Trend Quality: chop regime returned.")
alertcondition(enableAlerts and blockedStart, "Trend Quality: HTF Block", "Trend Quality: LTF trend is blocked by HTF context.")

// Hidden reference plots
plot(scoreRaw, "Trend Quality Score", display = display.none)
plot(scoreHTF, "HTF Trend Quality Score", display = display.none)
plot(scoreVelocity, "Score Velocity", display = display.none)
plot(trendHoldRate, "Trend Hold Rate", display = display.none)
plot(regime, "Trend Regime", display = display.none)
````
