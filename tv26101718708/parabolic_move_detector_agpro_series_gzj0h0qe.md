# Parabolic Move Detector [AGPro Series]

- url: https://www.tradingview.com/script/GZj0H0Qe-Parabolic-Move-Detector-AGPro-Series/
- type: indicator
- pine_id: PUB;db5c0a11d34c4e95a4c9262aa8b43ca9
- version: 4.0

## Description

🚀 Parabolic Move Detector [AGPro Series]

A dedicated framework for identifying, measuring, and classifying parabolic price acceleration across any asset and any timeframe. Built on a single transparent metric — Parabolic Pace — the tool objectively detects the start bar of a parabolic move, tracks its age, scores its intensity on a 0-100 scale, classifies its lifecycle phase, and contextualizes each move against the asset's own historical parabolic events.


🔹 OVERVIEW

Parabolic moves are notoriously difficult to recognize in real time. By the time they look obvious, the move is already late-stage. Conventional momentum tools (RSI, MACD, standard ROC) measure speed, not the underlying structural character of a parabolic move. They fire constantly on ordinary trends and miss what makes a parabolic move structurally different: the rate at which price is covering ATR-sized distance per bar.

Parabolic Move Detector closes that gap with a single, transparent metric. It measures how many ATRs price has moved per bar over a configurable lookback window. That is the literal mathematical definition of a parabolic move: sustained directional travel at an unusual speed relative to recent volatility. The framework auto-calibrates per timeframe and per asset, so a 15m memecoin pump and a 1D large-cap rally are measured with the same structural definition.


🔹 UNIQUE EDGE

Most acceleration or momentum indicators in the public space fall into two buckets: oscillators with hardcoded thresholds that need retuning per symbol, or composite "trend strength" meters that blur acceleration into raw trend direction. This tool is different in four concrete ways:

1. Single-metric detection engine. The entire detection pipeline is driven by one transparent number: Parabolic Pace = cumulative price move divided by cumulative ATR over the lookback. No percentiles, no hidden regressions, no black-box composite. This makes the tool easy to audit, fast to calibrate, and consistent across assets.

2. ATR-normalized by design. Because pace is expressed in ATRs per bar, it is inherently timeframe-adaptive and asset-adaptive. No need to retune for BTC vs a thin-volume altcoin, or for 15m vs 1W.

3. Four-phase state machine. Each move is classified through a deterministic lifecycle — Accelerating → Peaking → Decelerating → Exhaustion — with explicit transition conditions rather than heuristic labels. This turns a vague concept ("it looks parabolic") into a reproducible state with measurable transitions.

4. Per-asset historical statistics. The tool logs every completed parabolic cycle on the current chart, filters out micro-events, and reports the average duration and average drawdown from peak. That gives structural context no oscillator provides: what has this specific asset actually done the last N times it went parabolic.


🔹 METHODOLOGY

Core detection pipeline:

• Pace is computed as (close − close[N]) divided by (ATR14 × N), where N is the lookback window. The result is the number of ATRs traveled per bar.
• Pace is lightly smoothed with a short SMA to reduce single-bar noise.
• Detection triggers when smoothed pace exceeds the Pace Threshold and the move is directionally up.
• A minimum-duration filter requires the pace condition to persist for N consecutive bars before confirming the start, eliminating single-bar spikes.
• A post-move cooldown prevents the same move being re-detected as multiple events.

State machine transitions:

• Idle → Accelerating : pace sustained above threshold for the minimum duration.
• Accelerating → Peaking : Acceleration Score drops >20% from its cycle peak while still elevated.
• Any phase → Decelerating : score drops below 40% of cycle peak.
• Decelerating → Exhaustion : pace rolls over below half-threshold, and the move has lived at least 6 bars.
• Exhaustion → Idle : cooldown bars elapsed and score collapsed.

Acceleration Score (0-100) is a direct function of pace: score rises linearly with pace and receives a small persistence bonus for sustained upward momentum, capped at 100.

Historical statistics:
Each time a full cycle closes on the chart, the tool checks whether the move traveled at least the minimum ATRs from start to peak. If it qualifies, duration (start bar to peak bar) and drawdown from move high to subsequent low are averaged into rolling per-asset statistics.


🔹 STATES AND VISUALS

• Parabolic Zone : gradient background across the active move. Color reflects phase (brand blue in Accelerating, indigo in Peaking, amber in Decelerating). Intensity scales with Acceleration Score.
• Parabolic Start label : marks the confirmed start bar of a new move.
• Peaking / Decelerating labels : mark phase transitions. Labels are automatically suppressed within a confluence window to prevent stacking.
• Exhaustion label : marks the bar where the move has structurally collapsed.
• Duration Projection : dotted forward line sized to the asset's historical average parabolic duration, shown only while a move is active.


🔹 KEY INPUTS

Detection group:
• Pace Lookback — window over which parabolic pace is measured.
• Pace Threshold — minimum ATRs-per-bar required to qualify as parabolic.
• Minimum Move Duration — bars of sustained pace required before confirming a start.
• Minimum Event Size — minimum ATR-normalized move size required to log an event in historical statistics.
• Post-Move Cooldown — minimum bars after a completed move before a new one can start.

Historical Stats group:
• Show Duration Projection — toggle the forward projection line.
• Projection Length — forward projection cap in bars.

Visuals group:
• Parabolic Zone Background, Ambient Score Tint, Parabolic Start Label, Exhaustion Warning Label, Phase Transition Labels — all independently toggleable.

Style group:
• Label Size, Panel Size, Help Text Size — default Normal.
• Panel Location — six anchor positions.
• Panel Theme — Dark or Light.

Alerts group:
• Parabolic Start, Peaking Phase Reached, Exhaustion Detected — individually toggleable alerts.


🔹 HOW TO USE

• On any asset and any timeframe, wait for a confirmed Accelerating phase. The Parabolic Start label marks the reference bar.
• Track the Acceleration Score as the move develops. A score climbing toward 60-100 indicates a textbook parabolic.
• Compare Move Age against the panel's Avg Duration statistic. Moves significantly older than the asset's historical average are in late-cycle territory.
• Compare Move Change % against the Avg Reversal statistic for post-move drawdown context.
• Watch for the Peaking transition — this is the first structural deceleration, not a reversal call.
• The Exhaustion state marks where pace has decisively collapsed and the move is structurally over.
• Combine with your existing trend, structure, or volume framework. This tool is designed to complement directional analysis, not replace it.


🔹 LIMITATIONS AND TRANSPARENCY

• The tool detects and classifies acceleration structure. It does not predict reversals, tops, or bottoms. Avg Reversal is a post-cycle statistic computed from completed events on the current chart, not a forward-looking forecast.
• Historical statistics require completed cycles on the chart. Newly loaded symbols with few prior parabolic events will show low sample sizes until more cycles complete.
• The tool confirms a move only after pace has been sustained for the minimum duration. The start label is therefore plotted retroactively on its true start bar, which is the correct academic behavior for a sustained-condition detector.
• All computations are on confirmed bar close logic. No repainting of historical signals once a bar closes.
• The Pace metric requires a valid ATR reading, so at least 14+ bars of history are needed before the tool becomes active on a fresh chart.


🔹 RISK DISCLOSURE

This script is an analytical tool provided for educational and research purposes only. It is not a trading strategy, not financial advice, and does not generate buy or sell recommendations. Trading any market involves substantial risk of loss. All decisions and their consequences are the sole responsibility of the user. Past behavior of parabolic cycles on any asset does not guarantee future behavior.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Parabolic Move Detector [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.8
//
// A parabolic-move decision engine. Instead of only flagging acceleration, it
// judges whether a fast move is still worth riding or is stretched and fading.
// Through a transparent ATR-per-bar pace metric and ATR-normalized stretch from
// a baseline, it builds a 0-100 Parabolic Score, a clear lifecycle state, a
// mean-reversion target, an invalidation reference, a self-measured fade hit
// rate, and a single clean stretch corridor for crypto blow-off moves, altcoin
// pumps, capitulation flushes, high-beta trends, and fast speculative swings.
// ─────────────────────────────────────────────────

//@version=6
indicator("Parabolic Move Detector [AGPro Series]",
     shorttitle       = "AG Pro PMD",
     overlay          = true,
     max_labels_count = 200,
     max_boxes_count  = 40,
     max_lines_count  = 60)

// ─────────────────────────────────────────────────
// AGPro Color Palette
// ─────────────────────────────────────────────────
color headerBg      = color.rgb(37, 99, 235)
color headerText    = color.rgb(245, 247, 250)
color panelBg       = color.rgb(15, 23, 42)
color panelBorder   = color.rgb(51, 65, 85)
color panelLabelCol = color.rgb(148, 163, 184)
color panelValueCol = color.rgb(226, 232, 240)
color bullColor     = color.rgb(34, 197, 166)
color bearColor     = color.rgb(244, 114, 182)
color neutralColor  = color.rgb(245, 189, 92)
color accentColor   = color.rgb(129, 140, 248)
color dangerColor   = color.rgb(239, 68, 68)
color targetBlue    = color.rgb(59, 130, 246)
color darkText      = color.rgb(17, 24, 39)

// ─────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────
string G_ENGINE = "Parabolic Engine"
int lookback        = input.int(10, "Pace Lookback (bars)", minval = 5, maxval = 50, group = G_ENGINE, tooltip = "Window over which parabolic pace (ATR-per-bar acceleration) is measured. Shorter reacts faster; longer smooths.")
float paceThresh    = input.float(0.40, "Pace Threshold (ATR/bar)", minval = 0.15, maxval = 2.0, step = 0.05, group = G_ENGINE, tooltip = "A move qualifies as parabolic when absolute ATR-per-bar pace holds above this level.")
int atrLen          = input.int(14, "ATR Length", minval = 5, maxval = 80, group = G_ENGINE, tooltip = "ATR length used for pace, stretch normalization, rail spacing, and label offsets.")
int fastLen         = input.int(21, "Fast EMA", minval = 3, maxval = 120, group = G_ENGINE, tooltip = "Fast EMA used for context. It does not create standalone buy or sell signals.")
int baseLen         = input.int(55, "Baseline EMA", minval = 8, maxval = 300, group = G_ENGINE, tooltip = "Baseline EMA used as the mean-reversion anchor and the stretch reference.")
int minBars         = input.int(3, "Minimum Move Duration", minval = 2, maxval = 20, group = G_ENGINE, tooltip = "Minimum bars the pace condition must persist before a parabolic context can start.")
int cooldownBars    = input.int(5, "Post-Move Cooldown", minval = 2, maxval = 100, group = G_ENGINE, tooltip = "Minimum waiting period after a context closes before a new parabolic context can start.")

string G_SCORE = "Score & States"
float stretchRideAtr = input.float(2.0, "Ride Stretch (ATR)", minval = 0.5, maxval = 10.0, step = 0.1, group = G_SCORE, tooltip = "Stretch from baseline, in ATR, at which a building context becomes a riding PARABOLIC state.")
float stretchHotAtr  = input.float(4.0, "Stretched Stretch (ATR)", minval = 1.0, maxval = 16.0, step = 0.1, group = G_SCORE, tooltip = "Stretch from baseline, in ATR, at which the move is treated as STRETCHED and chase risk becomes high.")
float paceRefHigh    = input.float(1.20, "Pace Reference (ATR/bar)", minval = 0.40, maxval = 3.0, step = 0.05, group = G_SCORE, tooltip = "Pace level mapped to a full pace score for the 0-100 Parabolic Score.")
float stretchRefHigh = input.float(6.0, "Stretch Reference (ATR)", minval = 2.0, maxval = 20.0, step = 0.5, group = G_SCORE, tooltip = "Stretch level mapped to a full stretch score for the 0-100 Parabolic Score.")
float invalBufferAtr = input.float(1.00, "Invalidation Buffer (ATR)", minval = 0.0, maxval = 3.0, step = 0.05, group = G_SCORE, tooltip = "ATR padding beyond the move extreme that forms the invalidation rail. A close beyond it means the parabola extended further rather than stalling.")
int proofWindowBars  = input.int(10, "Stall Proof Window", minval = 3, maxval = 60, group = G_SCORE, tooltip = "After a FADE SETUP, the engine waits this many bars (or until the invalidation rail breaks) and checks whether the parabolic push stalled instead of extending. Feeds the Stall Rate.")

string G_VISUAL = "Chart Visuals"
bool showCorridor = input.bool(true, "Show Stretch Corridor", group = G_VISUAL, tooltip = "Shows the corridor between price and the mean-reversion target while a parabolic context is active, with a centered state badge.")
bool showRails    = input.bool(true, "Show Target / Invalidation Rails", group = G_VISUAL, tooltip = "Shows the mean-reversion target rail and the invalidation rail behind the parabolic extreme.")
bool showLabels   = input.bool(true, "Show Decision Labels", group = G_VISUAL, tooltip = "Shows compact STRETCHED and FADE SETUP labels with controlled spacing.")
bool showBg       = input.bool(true, "Show State Tint", group = G_VISUAL, tooltip = "Applies a subtle background tint reflecting the active parabolic state.")
bool showEmas     = input.bool(false, "Show EMAs", group = G_VISUAL, tooltip = "Shows the fast and baseline EMAs used for context and mean reference.")
int projectionBars = input.int(30, "Forward Projection Bars", minval = 8, maxval = 160, group = G_VISUAL, tooltip = "How far the corridor and rails project to the right.")
int labelCooldownBars = input.int(10, "Label Cooldown", minval = 1, maxval = 100, group = G_VISUAL, tooltip = "Minimum bars between decision labels.")
int maxVisibleLabels = input.int(6, "Max Visible Labels", minval = 3, maxval = 40, group = G_VISUAL, tooltip = "Maximum number of decision labels retained on the chart.")
float labelOffsetAtr = input.float(0.55, "Label Offset (ATR)", minval = 0.10, maxval = 3.0, step = 0.05, group = G_VISUAL, tooltip = "ATR offset keeping labels off the candles.")
string labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL, tooltip = "Controls decision labels and the centered corridor badge.")

string G_PANEL = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = G_PANEL, tooltip = "Shows or hides the AG Pro decision panel. Enabled by default for public-chart readability.")
string panelLoc = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL, tooltip = "Controls the on-chart panel anchor.")
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL, tooltip = "Controls the panel color theme while preserving the AGPro blue header.")
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL, tooltip = "Controls panel text size.")

string G_ALERTS = "Alerts"
bool alertParabolic = input.bool(true, "Alert: Parabolic", group = G_ALERTS, tooltip = "Alerts when a riding PARABOLIC state is confirmed. Attention marker, not a trade instruction.")
bool alertStretched = input.bool(true, "Alert: Stretched", group = G_ALERTS, tooltip = "Alerts when the move becomes STRETCHED and chase risk is high.")
bool alertFade      = input.bool(true, "Alert: Fade Setup", group = G_ALERTS, tooltip = "Alerts when the move rolls into a FADE SETUP reversal context.")

// ─────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────
f_clamp(float v, float lo, float hi) =>
    math.max(lo, math.min(hi, v))

f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_pos(string s) =>
    switch s
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299.0 + color.g(bg) * 587.0 + color.b(bg) * 114.0) / 1000.0
    bright >= 145.0 ? darkText : headerText

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(245, 247, 250) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_alt() =>
    panelTheme == "Clean Light" ? color.rgb(226, 232, 240) : panelTheme == "Slate" ? color.rgb(37, 49, 70) : color.rgb(20, 31, 52)

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_price(float v) =>
    na(v) ? "-" : str.tostring(v, format.mintick)

f_atr(float v) =>
    na(v) ? "-" : str.tostring(v, "0.0") + " ATR"

f_state_color(string st, int dir) =>
    st == "PARABOLIC" ? (dir > 0 ? bullColor : bearColor) : st == "STRETCHED" ? neutralColor : st == "FADE SETUP" ? dangerColor : st == "BUILDING" ? accentColor : panelLabelCol

f_panel_row(table t, int row, string lbl, string val, color valCol, color bg, string fs) =>
    table.cell(t, 0, row, lbl, text_color = f_panel_label(), bgcolor = bg, text_size = f_size(fs), text_halign = text.align_left)
    table.cell(t, 1, row, val, text_color = valCol, bgcolor = bg, text_size = f_size(fs), text_halign = text.align_right)

// ─────────────────────────────────────────────────
// Core Measurements
// ─────────────────────────────────────────────────
float atrRaw = ta.atr(atrLen)
float safeAtr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)
float emaFast = ta.ema(close, fastLen)
float emaBase = ta.ema(close, baseLen)

float netMove = close - close[lookback]
float pace = safeAtr > 0 and lookback > 0 ? netMove / (safeAtr * lookback) : 0.0
float paceSm = ta.sma(pace, 3)
float paceDelta = paceSm - paceSm[3]
float paceAbs = math.abs(paceSm)
int dirRaw = paceSm >= 0 ? 1 : -1

float stretchAtr = (close - emaBase) / safeAtr

bool rawActive = paceAbs > paceThresh
var int sustained = 0
sustained := rawActive ? nz(sustained[1]) + 1 : 0
bool baseConfirmed = sustained >= minBars

var int barsSince = 1000000
barsSince := nz(barsSince[1]) + 1
bool cooldownOk = barsSince >= cooldownBars
bool activeParabolic = baseConfirmed and cooldownOk

// ─────────────────────────────────────────────────
// State Machine
// ─────────────────────────────────────────────────
var int phase = 0
var int moveDir = 0
var int startBar = na
var float moveExtreme = na
var float peakStretch = 0.0
var int prevPhase = 0

int useDir = phase > 0 ? moveDir : dirRaw
float dirStretch = useDir * stretchAtr

var int accelStreak = 0
bool accelNow = useDir > 0 ? paceDelta > 0 : paceDelta < 0
accelStreak := accelNow ? nz(accelStreak[1]) + 1 : 0

float paceScore = f_clamp(paceAbs / paceRefHigh * 100.0, 0.0, 100.0)
float stretchScoreComp = f_clamp(dirStretch / stretchRefHigh * 100.0, 0.0, 100.0)
float persistScore = math.min(100.0, accelStreak * 12.0)
int parabScore = int(math.round(f_clamp(paceScore * 0.40 + stretchScoreComp * 0.45 + persistScore * 0.15, 0.0, 100.0)))

bool changed = false
int newPhase = phase

if phase > 0
    moveExtreme := moveDir > 0 ? math.max(nz(moveExtreme, high), high) : math.min(nz(moveExtreme, low), low)
    peakStretch := math.max(peakStretch, dirStretch)

bool rolling = moveDir > 0 ? paceDelta < 0 : paceDelta > 0
bool paceDead = paceAbs < paceThresh * 0.5

if phase == 0
    if activeParabolic
        newPhase := 1
        startBar := bar_index - minBars + 1
        moveDir := dirRaw
        moveExtreme := dirRaw > 0 ? high : low
        peakStretch := dirRaw * stretchAtr
        changed := true
else if phase == 1
    if dirStretch >= stretchRideAtr
        newPhase := 2
        changed := true
    else if paceDead and dirStretch < 0.8
        newPhase := 0
        changed := true
else if phase == 2
    if dirStretch >= stretchHotAtr
        newPhase := 3
        changed := true
    else if (rolling and dirStretch >= stretchRideAtr * 0.8 and bar_index - startBar >= minBars) or paceDead
        newPhase := 4
        changed := true
else if phase == 3
    if rolling or paceDead
        newPhase := 4
        changed := true
else if phase == 4
    if dirStretch < 1.0 or (not na(startBar) and bar_index - startBar > 80)
        newPhase := 0
        changed := true

prevPhase := phase
phase := newPhase

if prevPhase > 0 and phase == 0
    barsSince := 0
    moveDir := 0
    startBar := na
    moveExtreme := na
    peakStretch := 0.0

string stateText = phase == 1 ? "BUILDING" : phase == 2 ? "PARABOLIC" : phase == 3 ? "STRETCHED" : phase == 4 ? "FADE SETUP" : "IDLE"
color stateColor = f_state_color(stateText, moveDir)

float meanTarget = emaBase
float fadeRoomAtr = math.abs(close - meanTarget) / safeAtr
float buffer = invalBufferAtr * safeAtr
float invalRef = phase > 0 ? (moveDir > 0 ? moveExtreme + buffer : moveExtreme - buffer) : na

string actionText = phase == 1 ? "Watch acceleration" : phase == 2 ? "Ride with trailing stop" : phase == 3 ? "Chase risk high / trail" : phase == 4 ? "Fade toward mean / reversal risk" : "No parabolic context"

color scoreColor = parabScore >= 70 ? dangerColor : parabScore >= 45 ? neutralColor : phase > 0 ? accentColor : f_panel_value()

// ─────────────────────────────────────────────────
// Stall Rate (Proof Pass)
// ─────────────────────────────────────────────────
// On each FADE SETUP, snapshot the parabolic extreme and direction. The setup
// resolves as a miss if price extends beyond the invalidation rail (the parabola
// kept pushing), otherwise as a hit when it held inside the rail through the
// proof window (the parabolic push stalled). This honestly validates the
// exhaustion read rather than promising a profitable counter-trend trade.
var int sHits = 0
var int sTotal = 0
var bool sPending = false
var int sStart = na
var int sDir = 0
var float sExtreme = na

bool fadeRising = changed and phase == 4

if barstate.isconfirmed
    if fadeRising and not sPending
        sPending := true
        sStart := bar_index
        sDir := moveDir
        sExtreme := moveExtreme
    if sPending and not na(sStart) and bar_index > sStart
        bool extended = sDir > 0 ? high > sExtreme + buffer : low < sExtreme - buffer
        if extended
            sTotal += 1
            sPending := false
        else if bar_index - sStart >= proofWindowBars
            sTotal += 1
            sHits += 1
            sPending := false

float sRate = sTotal > 0 ? sHits / sTotal * 100.0 : na
string stallRateText = sTotal > 0 ? str.tostring(int(math.round(sRate))) + "% (" + str.tostring(sHits) + "/" + str.tostring(sTotal) + ")" : "Building"
color stallRateColor = sTotal == 0 ? neutralColor : sRate >= 60.0 ? bullColor : sRate >= 45.0 ? neutralColor : dangerColor

// ─────────────────────────────────────────────────
// EMAs & State Tint
// ─────────────────────────────────────────────────
plot(showEmas ? emaFast : na, "Fast EMA", color = color.new(accentColor, 50), linewidth = 1)
plot(showEmas ? emaBase : na, "Baseline EMA", color = color.new(targetBlue, 35), linewidth = 1)

bgcolor(showBg and phase > 0 ? color.new(stateColor, phase == 4 ? 85 : 90) : na, title = "State Tint")

// ─────────────────────────────────────────────────
// Corridor, Rails & Centered Badge
// ─────────────────────────────────────────────────
var box corridorBox = na
var label corridorBadge = na
var line targetLine = na
var line targetConnector = na
var label targetTag = na
var line invalLine = na
var line invalConnector = na
var label invalTag = na

if barstate.islast
    int rightX = bar_index + projectionBars
    int railEndX = math.max(bar_index + 2, rightX - 5)
    int midX = bar_index + int(math.round(projectionBars * 0.5))
    float top = math.max(close, meanTarget)
    float bottom = math.min(close, meanTarget)
    float midY = (top + bottom) * 0.5
    float badgeLane = safeAtr * (labelSizeInput == "Huge" ? 1.00 : labelSizeInput == "Large" ? 0.85 : labelSizeInput == "Normal" ? 0.70 : labelSizeInput == "Small" ? 0.58 : 0.48)
    bool railsTight = math.abs(meanTarget - invalRef) < badgeLane * 2.20
    float railOrder = meanTarget >= invalRef ? 1.0 : -1.0
    float targetTagY = railsTight ? meanTarget + railOrder * badgeLane : meanTarget
    float invalTagY = railsTight ? invalRef - railOrder * badgeLane : invalRef

    if showCorridor and phase > 0
        if na(corridorBox)
            corridorBox := box.new(bar_index, top, rightX, bottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 90), border_color = color.new(stateColor, 45), border_width = 1)
        else
            box.set_lefttop(corridorBox, bar_index, top)
            box.set_rightbottom(corridorBox, rightX, bottom)
            box.set_bgcolor(corridorBox, color.new(stateColor, 90))
            box.set_border_color(corridorBox, color.new(stateColor, 45))
        string activeDirText = moveDir > 0 ? "UP" : moveDir < 0 ? "DOWN" : "NEUTRAL"
        string badgeText = "ACTIVE " + stateText + " | " + activeDirText + " | " + str.tostring(parabScore)
        if na(corridorBadge)
            corridorBadge := label.new(midX, midY, badgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 10), textcolor = f_text_on(stateColor), size = f_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(corridorBadge, midX, midY)
            label.set_text(corridorBadge, badgeText)
            label.set_color(corridorBadge, color.new(stateColor, 10))
            label.set_textcolor(corridorBadge, f_text_on(stateColor))
            label.set_size(corridorBadge, f_size(labelSizeInput))
    else
        if not na(corridorBox)
            box.delete(corridorBox)
            corridorBox := na
        if not na(corridorBadge)
            label.delete(corridorBadge)
            corridorBadge := na

    if showRails and phase > 0
        if na(targetLine)
            targetLine := line.new(bar_index, meanTarget, railEndX, meanTarget, xloc = xloc.bar_index, color = color.new(targetBlue, 10), style = line.style_dashed, width = 1)
        else
            line.set_xy1(targetLine, bar_index, meanTarget)
            line.set_xy2(targetLine, railEndX, meanTarget)
            line.set_color(targetLine, color.new(targetBlue, 10))
        if na(targetConnector)
            targetConnector := line.new(railEndX, meanTarget, rightX, targetTagY, xloc = xloc.bar_index, color = color.new(targetBlue, 4), width = 2)
        else
            line.set_xy1(targetConnector, railEndX, meanTarget)
            line.set_xy2(targetConnector, rightX, targetTagY)
            line.set_color(targetConnector, color.new(targetBlue, 4))
        if na(targetTag)
            targetTag := label.new(rightX + 1, targetTagY, "MEAN " + f_price(meanTarget), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(targetBlue, 4), textcolor = f_text_on(targetBlue), size = f_size(labelSizeInput))
        else
            label.set_xy(targetTag, rightX + 1, targetTagY)
            label.set_text(targetTag, "MEAN " + f_price(meanTarget))
            label.set_color(targetTag, color.new(targetBlue, 4))
            label.set_textcolor(targetTag, f_text_on(targetBlue))
            label.set_size(targetTag, f_size(labelSizeInput))
        if na(invalLine)
            invalLine := line.new(bar_index, invalRef, railEndX, invalRef, xloc = xloc.bar_index, color = color.new(dangerColor, 12), style = line.style_dashed, width = 1)
        else
            line.set_xy1(invalLine, bar_index, invalRef)
            line.set_xy2(invalLine, railEndX, invalRef)
            line.set_color(invalLine, color.new(dangerColor, 12))
        if na(invalConnector)
            invalConnector := line.new(railEndX, invalRef, rightX, invalTagY, xloc = xloc.bar_index, color = color.new(dangerColor, 4), width = 2)
        else
            line.set_xy1(invalConnector, railEndX, invalRef)
            line.set_xy2(invalConnector, rightX, invalTagY)
            line.set_color(invalConnector, color.new(dangerColor, 4))
        if na(invalTag)
            invalTag := label.new(rightX + 1, invalTagY, "INVALID " + f_price(invalRef), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 4), textcolor = f_text_on(dangerColor), size = f_size(labelSizeInput))
        else
            label.set_xy(invalTag, rightX + 1, invalTagY)
            label.set_text(invalTag, "INVALID " + f_price(invalRef))
            label.set_color(invalTag, color.new(dangerColor, 4))
            label.set_textcolor(invalTag, f_text_on(dangerColor))
            label.set_size(invalTag, f_size(labelSizeInput))
    else
        if not na(targetLine)
            line.delete(targetLine)
            targetLine := na
        if not na(targetConnector)
            line.delete(targetConnector)
            targetConnector := na
        if not na(targetTag)
            label.delete(targetTag)
            targetTag := na
        if not na(invalLine)
            line.delete(invalLine)
            invalLine := na
        if not na(invalConnector)
            line.delete(invalConnector)
            invalConnector := na
        if not na(invalTag)
            label.delete(invalTag)
            invalTag := na

// ─────────────────────────────────────────────────
// Decision Labels (Y-tracking anti-overlap)
// ─────────────────────────────────────────────────
var array<label> evtLabels = array.new<label>()
var int lastEvtBar = na
var float lastEvtY = na
int labelClusterWindow = 8

f_trim(array<label> arr, int lim) =>
    while array.size(arr) > lim
        label old = array.shift(arr)
        label.delete(old)

bool canEvt = na(lastEvtBar) or bar_index - lastEvtBar >= labelCooldownBars
bool stretchedEvt = changed and phase == 3
bool fadeEvt = changed and phase == 4

if showLabels and barstate.isconfirmed and canEvt and (stretchedEvt or fadeEvt)
    bool above = moveDir > 0
    string txt = fadeEvt ? "FADE EVENT" : "STRETCHED"
    color col = fadeEvt ? dangerColor : neutralColor
    float natY = above ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
    bool clustered = not na(lastEvtBar) and bar_index - lastEvtBar <= labelClusterWindow
    float y = not clustered ? natY : above ? math.max(natY, lastEvtY + safeAtr * 1.10) : math.min(natY, lastEvtY - safeAtr * 1.10)
    label lb = label.new(bar_index, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = above ? label.style_label_down : label.style_label_up, color = color.new(col, 12), textcolor = f_text_on(col), size = f_size(labelSizeInput), textalign = text.align_center)
    array.push(evtLabels, lb)
    f_trim(evtLabels, maxVisibleLabels)
    lastEvtBar := bar_index
    lastEvtY := y

// ─────────────────────────────────────────────────
// Panel
// ─────────────────────────────────────────────────
var table panel = table.new(f_pos(panelLoc), 2, 9, border_width = 1, border_color = f_panel_border(), frame_color = f_panel_border(), frame_width = 1)

if barstate.islast
    table.set_position(panel, f_pos(panelLoc))
    table.clear(panel, 0, 0, 1, 8)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Parabolic Move Detector", text_color = headerText, bgcolor = headerBg, text_size = f_size(panelFontSize), text_halign = text.align_center)

        string dirText = moveDir > 0 ? "Up" : moveDir < 0 ? "Down" : "-"
        string stateVal = phase > 0 ? stateText + " | " + dirText : "IDLE"
        string stretchVal = phase > 0 ? f_atr(dirStretch) + " from mean" : "-"
        string paceVal = str.tostring(paceSm, "0.00") + " ATR/bar"
        string targetVal = phase > 0 ? f_price(meanTarget) + " | " + f_atr(fadeRoomAtr) : "-"
        string invalVal = phase > 0 ? f_price(invalRef) : "-"

        f_panel_row(panel, 1, "Parabolic Score", str.tostring(parabScore) + " / 100", scoreColor, f_panel_bg(), panelFontSize)
        f_panel_row(panel, 2, "State", stateVal, stateColor, f_panel_alt(), panelFontSize)
        f_panel_row(panel, 3, "Stretch", stretchVal, phase > 0 ? scoreColor : f_panel_value(), f_panel_bg(), panelFontSize)
        f_panel_row(panel, 4, "Pace", paceVal, f_panel_value(), f_panel_alt(), panelFontSize)
        f_panel_row(panel, 5, "Mean Target", targetVal, phase > 0 ? targetBlue : f_panel_value(), f_panel_bg(), panelFontSize)
        f_panel_row(panel, 6, "Invalidation", invalVal, phase > 0 ? dangerColor : f_panel_value(), f_panel_alt(), panelFontSize)
        f_panel_row(panel, 7, "Stall Rate", stallRateText, stallRateColor, f_panel_bg(), panelFontSize)
        f_panel_row(panel, 8, "Action", actionText, stateColor, f_panel_alt(), panelFontSize)

// ─────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────
alertcondition(alertParabolic and changed and phase == 2, title = "Parabolic", message = "Parabolic Move Detector: riding PARABOLIC state on {{ticker}} {{interval}}. Attention marker, not a trade instruction.")
alertcondition(alertStretched and changed and phase == 3, title = "Stretched", message = "Parabolic Move Detector: move is STRETCHED, chase risk high on {{ticker}} {{interval}}.")
alertcondition(alertFade and changed and phase == 4, title = "Fade Setup", message = "Parabolic Move Detector: FADE SETUP reversal context on {{ticker}} {{interval}}.")
````
