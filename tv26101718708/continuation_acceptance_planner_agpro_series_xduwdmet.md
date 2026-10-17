# Continuation Acceptance Planner [AGPro Series]

- url: https://www.tradingview.com/script/xDuwDMET-Continuation-Acceptance-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;3799439c8c8e4a4bb396eb362aa34574
- version: 5.0

## Description

Continuation Acceptance Planner [AGPro Series]

🧠 Core Idea

Is this continuation setup being accepted, delayed, or invalidated before the next decision point?


📌 Overview / What it does

Continuation Acceptance Planner is a chart-first continuation planning tool built to evaluate whether a pullback inside an active trend is producing real acceptance or only temporary hesitation.

The script builds a live continuation acceptance band around a trend base, scores the context from 0 to 100, maps the invalidation rail, checks target room against the nearest obstruction, and prints compact state labels such as ACCEPTED, DELAYED, PAUSED, WATCH, and INVALID.

It does not predict future price movement, automate entries, or produce guaranteed trade signals. Its role is to organize continuation context into a cleaner decision framework.


🎯 Purpose & Design Philosophy

This script was built for traders who want to judge continuation quality without turning every trend pullback into a signal.

Most continuation tools focus on bounce detection or trend strength only. This planner focuses on the decision layer: acceptance quality, pullback risk, target room, invalidation context, and the next action state.

The design supports a patient execution mindset. It helps the user ask whether the continuation is actually being accepted, still delayed, temporarily paused, too extended, or losing validity.


⚡ Why This Script Is Different

Most tools focus on generic trend continuation signals after a moving average touch or pullback bounce.

This script does NOT act as a simple buy/sell continuation indicator, and it does not clone a broad trend-continuation quality scanner.

Instead, it treats continuation as a planning problem: price must interact with an acceptance band, show a quality close, maintain enough room before obstruction, and stay above or below a clear invalidation rail.


⚙️ Methodology

1. Context Detection
The script identifies bullish or bearish continuation context using fast, base, and slow EMA alignment plus trend slope.

2. Reference Mapping
It creates a continuation acceptance band around the base EMA and maps the invalidation rail using the band edge, slow EMA, and ATR buffer.

3. Reaction Evaluation
It evaluates pullback depth, close acceptance, volume support, and whether price is delaying, accepting, extending, or moving toward invalidation.

4. Visual Output
The script displays a centered acceptance-band label, invalidation and target guides, compact state labels, and a premium AG Pro planning panel.


🗺️ How to Read the Chart

Zones = the live continuation acceptance band around the trend base.

Labels = accepted, delayed, invalidation, or watch-state markers with optional 0-100 score.

Colors = bullish continuation context uses teal, bearish continuation context uses pink, delayed context uses amber, and risk or invalidation context uses red.

Panel = a compact decision dashboard showing Continuation Score, Acceptance, Pullback Risk, Target Room, and Action.


🚦 Signals & States

• ACCEPTED → continuation context has a qualified acceptance close and enough score to review.

• DELAYED → price is interacting with the acceptance band but has not produced enough clean acceptance.

• PAUSED → the prior continuation side still matters, but the trend stack needs to rebuild before the setup becomes clean again.

• WATCH → continuation context exists, but the setup still needs clearer reaction.

• EXTENDED → price is away from the acceptance band and may be late for clean continuation planning.

• INVALID RISK → price is moving beyond the planner's invalidation rail.


🔔 Alerts Logic

Alerts trigger when continuation acceptance, delayed acceptance, invalidation risk, or blocked target room conditions appear.

Alerts are attention markers only. They are not trade instructions and should be interpreted with the broader chart context.


🧩 Confluence Logic

The strongest continuation context appears when trend alignment, controlled pullback depth, close acceptance, volume support, and clean target room align.

When these components align, the continuation score improves and the panel moves toward a clearer planning state.


📊 When to Use

• Primary timeframe: 1H

• Secondary timeframe: 4H

• Trending markets with structured pullbacks

• Continuation setups after a controlled pause

• Pullbacks into a moving trend base

• Situations where target room and invalidation clarity matter


⚠️ When NOT to Use

• When expecting dense signals on 1D or 1W charts

• Very low liquidity environments

• Extremely noisy sideways conditions

• High-volatility shock moves where trend anchors distort quickly

• Markets with no clean trend alignment


🎛️ Key Inputs

• Sensitivity → changes how strict the acceptance engine is.

• Target Obstruction Lookback → defines the prior obstruction used for target-room evaluation.

• Acceptance Band Width ATR → controls the width of the continuation band.

• Confirmation Mode → defines whether acceptance requires close behavior only, close plus volume, or stricter alignment.

• Label and Panel Settings → control visual density, font size, panel location, and theme.


🖥️ Interface & Visual Design

The panel is designed as a compact planning dashboard, not a data-heavy scanner.

The first row follows the AG Pro blue merged-header standard. The remaining rows focus only on the information needed for continuation planning: score, acceptance, pullback risk, target room, and action.

Chart visuals are intentionally controlled so the acceptance band, invalidation rail, target guide, and labels remain readable.


🧪 Practical Usage Workflow

1. Read the panel state.

2. Check whether price is interacting with the acceptance band.

3. Review the continuation score and pullback risk.

4. Compare target room with the invalidation rail.

5. Use labels and alerts as attention markers, not as automatic decisions.


🔍 Interpretation Guidelines

Think in terms of setup quality, not prediction.

A higher score means the current continuation context has stronger alignment across trend, pullback depth, close behavior, volume, and target room.

A delayed state means the idea is not necessarily invalid, but the chart has not yet produced clean acceptance.

A paused state means the prior continuation context is still nearby, but alignment weakened enough that patience matters more than chasing.

An invalidation-risk state means the continuation structure should be reassessed.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed signal generator

• Not a generic support/resistance or order-block map

• Not a gap continuation planner or breakout acceptance planner


⚠️ Limitations & Transparency

Timeframe differences can change how continuation bands and target-room references appear.

Volatility expansion can move the acceptance band and invalidation rail quickly.

Low-volume or synthetic symbols may reduce the usefulness of the volume component.

All outputs are rule-based and should be interpreted within broader market context.


🧠 Market Context Notes

Continuation planning depends on trend structure, liquidity, volatility, and obstruction distance.

The cleanest cases usually appear when pullbacks are controlled, the acceptance close is clear, and the next obstruction is not too close.

In the current public-release tuning, the script reads cleanest on 1H charts and remains usable on 4H. Daily and weekly charts can still provide context, but they are less expressive for the intended acceptance-versus-delay workflow.


🧾 Use Case Examples

When price pulls back into the acceptance band during a bullish trend and closes back above the base EMA with sufficient target room, the planner may shift toward ACCEPTED.

When price stays inside the band without a clean close, the planner may remain DELAYED.

When price closes beyond the invalidation rail, the planner flags INVALID RISK.


🧱 System Philosophy

The script follows the AGProLabs decision-engine approach: a useful public tool should help traders evaluate validity, strength, risk, target room, and the next action state.

It is built to guide interpretation, not to replace trader judgment.


🔐 Non-Promise Statement

No script can provide certainty.

No output from this script guarantees continuation, reversal, profit, or loss avoidance.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own decisions.

This script does not provide financial advice and should be used only as an educational and analytical tool.


📚 Educational Note

Use the planner to study how continuation acceptance develops across different symbols, sessions, volatility regimes, and timeframes.

## Source Code

````pine
// -------------------------------------------------
// Continuation Acceptance Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Continuation Acceptance Planner turns trend-continuation pullbacks into a
// decision-focused planning map. It scores whether price is accepting a clean
// continuation band, waiting inside the pullback area, extending away from the
// band, or moving toward invalidation while mapping risk rail, target room, and
// next-action context. V1.2 adds a follow-rate proof that shows how often
// accepted continuations historically followed through before invalidation,
// and improves contrast on the lighter acceptance badges, without becoming a
// generic continuation signal indicator.
// V1.3 refreshes the publication presentation only. Core calculations, alerts,
// inputs and runtime behavior remain unchanged.
// -------------------------------------------------

//@version=6
indicator("Continuation Acceptance Planner [AGPro Series]",
     shorttitle = "AG Pro CAP",
     overlay = true,
     max_boxes_count = 80,
     max_labels_count = 240,
     max_lines_count = 120)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
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
color darkText      = color.rgb(17, 24, 39)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
const string TT_SIDE = "Selects the continuation side evaluated by the planner. Auto follows the active EMA stack, while directional modes restrict the planner to one side only."
const string TT_SENS = "Controls how strict the acceptance engine is. Responsive creates more state context, Balanced is the publication default, and Strict requires cleaner closes and stronger trend slope."
const string TT_FAST = "Fast EMA used to measure short-term continuation pressure. It does not create standalone buy or sell signals."
const string TT_BASE = "Base EMA used as the center of the continuation acceptance band."
const string TT_SLOW = "Slow EMA used as broader trend context and part of the invalidation rail."
const string TT_ATR = "ATR normalizes acceptance band width, invalidation rail distance, target room, and label offsets across symbols."
const string TT_VOL = "Volume baseline used to judge participation behind acceptance closes. On low-volume symbols the volume component behaves as context, not a hard filter."
const string TT_LOOKBACK = "Lookback used to locate the nearest prior obstruction in the continuation direction. This becomes the target-room reference."
const string TT_BAND = "ATR width around the base EMA used to build the continuation acceptance band."
const string TT_WINDOW = "Number of bars after a band touch where a close can still qualify as acceptance."
const string TT_DEPTH = "Preferred pullback depth in ATR from the fast EMA. Pullbacks that are too shallow or too deep receive weaker scores."
const string TT_MAX_DEPTH = "Pullbacks deeper than this ATR distance are treated as elevated pullback risk."
const string TT_BUFFER = "ATR buffer placed beyond the acceptance band and slow EMA to draw the invalidation rail."
const string TT_TARGET = "ATR distance considered clean target room before the nearest prior obstruction."
const string TT_CONFIRM = "Defines whether acceptance requires only close behavior, close plus volume support, or stricter close, trend, and room alignment."
const string TT_MIN_SCORE = "Minimum 0-100 score required before accepted continuation labels can appear."
const string TT_WATCH = "Minimum 0-100 score required for wait or watch-state context labels."
const string TT_FOLLOW_WINDOW = "Number of bars an accepted continuation has to follow through in the trend direction within, for the Follow Rate proof. It only measures historical follow-through and is not a forecast."
const string TT_EMA = "Shows or hides the EMA anchors used by the planner."
const string TT_BAND_SHOW = "Shows the live continuation acceptance band with a centered premium label."
const string TT_RAILS = "Shows the active invalidation rail and target obstruction guide."
const string TT_RIGHT = "Shows compact right-edge labels for the risk rail, target-room guide, and active workflow."
const string TT_EVENTS = "Shows accepted, wait, reset, avoid-chase, and watch labels on the chart."
const string TT_SCORE_LABEL = "Adds the 0-100 continuation score to chart labels."
const string TT_DENSITY = "Controls how many historical context labels are retained. Balanced is tuned for public screenshots with around four to five meaningful chart notes."
const string TT_COOLDOWN = "Minimum number of bars between event labels. Higher values reduce clustering."
const string TT_CONTEXT = "Minimum spacing between lighter watch labels. This keeps the chart informative without crowding candles."
const string TT_MAX_LABELS = "Maximum number of visible chart labels retained by the script. Older labels are deleted first for performance."
const string TT_PROJECTION = "Number of bars projected to the right for the acceptance band, invalidation rail, target guide, and right-edge tags."
const string TT_LABEL_OFFSET = "ATR-based vertical offset that keeps event labels away from candle bodies and wicks."
const string TT_LABEL_SIZE = "Controls all visible chart label sizes, including the centered band label. Normal is the recommended public-release default."
const string TT_PANEL_SHOW = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
const string TT_PANEL_LOCATION = "Moves the AG Pro panel to the preferred chart location."
const string TT_PANEL_THEME = "Switches the panel between the premium AGPro dark theme and a clean light theme."
const string TT_PANEL_SIZE = "Controls the font size used inside the AG Pro panel. Normal is the recommended publication default."
const string TT_ALERT = "Minimum continuation score required before alert conditions can trigger."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Continuation Engine"
string sideMode = input.string("Auto", "Continuation Side", options = ["Auto", "Bullish Only", "Bearish Only"], group = groupEngine, tooltip = TT_SIDE)
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = TT_SENS)
int fastEmaLength = input.int(13, "Fast EMA Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_FAST)
int baseEmaLength = input.int(34, "Base EMA Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_BASE)
int slowEmaLength = input.int(89, "Slow EMA Length", minval = 10, maxval = 400, group = groupEngine, tooltip = TT_SLOW)
int atrLength = input.int(14, "ATR Length", minval = 2, maxval = 100, group = groupEngine, tooltip = TT_ATR)
int volumeLength = input.int(34, "Volume Baseline Length", minval = 5, maxval = 200, group = groupEngine, tooltip = TT_VOL)
int targetLookback = input.int(72, "Target Obstruction Lookback", minval = 10, maxval = 300, group = groupEngine, tooltip = TT_LOOKBACK)

string groupPlanner = "Planner Model"
float acceptanceBandAtr = input.float(0.58, "Acceptance Band Width ATR", minval = 0.10, maxval = 2.50, step = 0.01, group = groupPlanner, tooltip = TT_BAND)
int acceptanceWindowBars = input.int(10, "Acceptance Window Bars", minval = 1, maxval = 60, group = groupPlanner, tooltip = TT_WINDOW)
float idealPullbackAtr = input.float(0.85, "Ideal Pullback Depth ATR", minval = 0.05, maxval = 3.00, step = 0.05, group = groupPlanner, tooltip = TT_DEPTH)
float maxPullbackAtr = input.float(2.30, "Deep Pullback Risk ATR", minval = 0.25, maxval = 6.00, step = 0.05, group = groupPlanner, tooltip = TT_MAX_DEPTH)
float riskBufferAtr = input.float(0.22, "Invalidation Rail Buffer ATR", minval = 0.00, maxval = 2.00, step = 0.01, group = groupPlanner, tooltip = TT_BUFFER)
float cleanRoomAtr = input.float(2.20, "Clean Target Room ATR", minval = 0.25, maxval = 8.00, step = 0.05, group = groupPlanner, tooltip = TT_TARGET)
string confirmationMode = input.string("Close Acceptance", "Confirmation Mode", options = ["Realtime Allowed", "Close Acceptance", "Close + Volume", "Strict"], group = groupPlanner, tooltip = TT_CONFIRM)
int acceptedThreshold = input.int(64, "Accepted Threshold", minval = 40, maxval = 95, group = groupPlanner, tooltip = TT_MIN_SCORE)
int watchThreshold = input.int(52, "Watch Threshold", minval = 20, maxval = 90, group = groupPlanner, tooltip = TT_WATCH)
int followWindow = input.int(20, "Follow Proof Window (bars)", minval = 5, maxval = 200, group = groupPlanner, tooltip = TT_FOLLOW_WINDOW)

string groupVisual = "Chart Visuals"
bool showEmaAnchors = input.bool(false, "Show EMA Anchors", group = groupVisual, tooltip = TT_EMA)
bool showAcceptanceBand = input.bool(true, "Show Acceptance Band", group = groupVisual, tooltip = TT_BAND_SHOW)
bool showPlannerRails = input.bool(true, "Show Invalidation / Target Rails", group = groupVisual, tooltip = TT_RAILS)
bool showRightEdgeTags = input.bool(true, "Show Right-Edge Tags", group = groupVisual, tooltip = TT_RIGHT)
bool showEventLabels = input.bool(true, "Show State Labels", group = groupVisual, tooltip = TT_EVENTS)
bool showLabelScore = input.bool(true, "Show Label Score", group = groupVisual, tooltip = TT_SCORE_LABEL)
string labelDensity = input.string("Balanced", "Label Density", options = ["Minimal", "Balanced", "Detailed"], group = groupVisual, tooltip = TT_DENSITY)
int labelCooldownBars = input.int(28, "Event Label Cooldown", minval = 1, maxval = 120, group = groupVisual, tooltip = TT_COOLDOWN)
int contextSpacingBars = input.int(60, "Watch Label Spacing", minval = 5, maxval = 180, group = groupVisual, tooltip = TT_CONTEXT)
int maxVisibleLabels = input.int(7, "Max Visible Labels", minval = 4, maxval = 80, group = groupVisual, tooltip = TT_MAX_LABELS)
int projectionBars = input.int(42, "Forward Projection Bars", minval = 8, maxval = 180, group = groupVisual, tooltip = TT_PROJECTION)
float labelOffsetAtr = input.float(1.20, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = TT_LABEL_OFFSET)
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = TT_LABEL_SIZE)

string groupPanel = "Panel"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = TT_PANEL_SHOW)
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = TT_PANEL_LOCATION)
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = TT_PANEL_THEME)
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = TT_PANEL_SIZE)

string groupAlerts = "Alerts"
int alertScoreThreshold = input.int(64, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = TT_ALERT)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_norm_high_good(float value, float weakValue, float strongValue) =>
    float span = math.max(strongValue - weakValue, 0.000001)
    f_clamp((value - weakValue) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float strongValue, float weakValue) =>
    float span = math.max(weakValue - strongValue, 0.000001)
    f_clamp((weakValue - value) / span * 100.0, 0.0, 100.0)

f_peak_score(float value, float lowValue, float idealValue, float highValue) =>
    float result = 0.0
    if value <= idealValue
        result := f_norm_high_good(value, lowValue, idealValue)
    else
        result := f_norm_low_good(value, idealValue, highValue)
    result

f_text_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string locationInput) =>
    switch locationInput
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt(float value) =>
    na(value) ? "-" : str.tostring(value, "#.##")

f_score_grade(float scoreValue) =>
    string grade = "D"
    if scoreValue >= 86
        grade := "A+"
    else if scoreValue >= 76
        grade := "A"
    else if scoreValue >= 64
        grade := "B"
    else if scoreValue >= 52
        grade := "C"
    grade

f_score_color(float scoreValue) =>
    color result = dangerColor
    if scoreValue >= 76
        result := bullColor
    else if scoreValue >= 64
        result := accentColor
    else if scoreValue >= 52
        result := neutralColor
    result

f_side_color(int dir) =>
    dir == 1 ? bullColor : dir == -1 ? bearColor : neutralColor

f_panel_bg(bool isLight, bool alt) =>
    isLight ? (alt ? color.rgb(241, 245, 249) : color.rgb(248, 250, 252)) : (alt ? color.rgb(20, 31, 52) : panelBg)

f_panel_border(bool isLight) =>
    isLight ? color.rgb(203, 213, 225) : panelBorder

f_panel_label_color(bool isLight) =>
    isLight ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value_color(bool isLight) =>
    isLight ? color.rgb(15, 23, 42) : panelValueCol

f_panel_row(table target, int row, string leftText, string rightText, color rightColor, bool isLight, string fontInput) =>
    color rowBg = f_panel_bg(isLight, row % 2 == 0)
    table.cell(target, 0, row, leftText, text_color = f_panel_label_color(isLight), bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontInput), text_halign = text.align_right)

f_trim_labels(array<label> ids, int limit) =>
    while array.size(ids) > limit
        label.delete(array.shift(ids))

f_state_display(string stateText) =>
    stateText == "ACCEPTED" ? "Accepted" :
     stateText == "DELAYED" ? "Wait Acceptance" :
     stateText == "INVALID RISK" ? "Reset Context" :
     stateText == "EXTENDED" ? "Avoid Chase" :
     stateText == "PAUSED" ? "Rebuild Setup" :
     stateText == "WATCH" ? "Watch Band" :
     "Map Trend"

f_workflow_text(string stateText) =>
    stateText == "ACCEPTED" ? "Review plan" :
     stateText == "DELAYED" ? "Wait acceptance" :
     stateText == "INVALID RISK" ? "Reset context" :
     stateText == "EXTENDED" ? "Avoid chase" :
     stateText == "PAUSED" ? "Let rebuild" :
     stateText == "WATCH" ? "Monitor band" :
     "Map trend"

f_state_color(string stateText, int dir, float scoreValue, bool isLight) =>
    color result = f_panel_value_color(isLight)
    if stateText == "ACCEPTED"
        result := dir == 1 ? bullColor : bearColor
    else if stateText == "DELAYED"
        result := neutralColor
    else if stateText == "INVALID RISK"
        result := dangerColor
    else if stateText == "EXTENDED"
        result := accentColor
    else if stateText == "WATCH"
        result := accentColor
    else if stateText == "PAUSED" or stateText == "NO TREND"
        result := neutralColor
    else
        result := f_score_color(scoreValue)
    result

f_risk_text(string riskValue) =>
    riskValue == "Invalidation" ? "Rail pressure" :
     riskValue == "Deep" ? "Deep pullback" :
     riskValue == "Shallow" ? "Shallow pullback" :
     riskValue == "Balanced" ? "Balanced pullback" :
     "No active trend"

// -------------------------------------------------
// Core Calculations
// -------------------------------------------------
float fastEma = ta.ema(close, fastEmaLength)
float baseEma = ta.ema(close, baseEmaLength)
float slowEma = ta.ema(close, slowEmaLength)
float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, high - low), syminfo.mintick)
float volumeAverage = ta.sma(volume, volumeLength)
float volumeRatio = not na(volumeAverage) and volumeAverage > 0.0 ? volume / volumeAverage : 1.0

float baseSlopeAtr = (baseEma - baseEma[5]) / atr
float minSlopeAtr = sensitivity == "Strict" ? 0.055 : sensitivity == "Responsive" ? -0.015 : 0.015
float closeLocationNeed = sensitivity == "Strict" ? 0.66 : sensitivity == "Responsive" ? 0.55 : 0.60
float volumeNeed = sensitivity == "Strict" ? 1.08 : sensitivity == "Responsive" ? 0.88 : 0.96

bool allowBull = sideMode != "Bearish Only"
bool allowBear = sideMode != "Bullish Only"
bool bullStack = fastEma > baseEma and baseEma > slowEma and baseSlopeAtr >= minSlopeAtr
bool bearStack = fastEma < baseEma and baseEma < slowEma and baseSlopeAtr <= -minSlopeAtr
int candidateDir = allowBull and bullStack ? 1 : allowBear and bearStack ? -1 : 0
int holdContextBars = math.max(acceptanceWindowBars + 2, 8)
float holdContextAtr = math.max(acceptanceBandAtr, riskBufferAtr) + 0.35
bool bullHoldValid = close >= slowEma - atr * holdContextAtr
bool bearHoldValid = close <= slowEma + atr * holdContextAtr
var int persistedDir = 0
var int persistedAge = 1000

if candidateDir != 0
    persistedDir := candidateDir
    persistedAge := 0
else
    if persistedDir != 0
        persistedAge += 1
    bool keepBullContext = persistedDir == 1 and persistedAge <= holdContextBars and bullHoldValid
    bool keepBearContext = persistedDir == -1 and persistedAge <= holdContextBars and bearHoldValid
    if not keepBullContext and not keepBearContext
        persistedDir := 0
        persistedAge := 1000

int activeDir = candidateDir != 0 ? candidateDir : persistedDir
bool heldContext = activeDir != 0 and candidateDir == 0
bool stackQualified = activeDir != 0 and candidateDir == activeDir

float bandTop = baseEma + atr * acceptanceBandAtr
float bandBottom = baseEma - atr * acceptanceBandAtr
bool bandInteraction = activeDir == 1 ? (low <= bandTop and high >= bandBottom) : activeDir == -1 ? (high >= bandBottom and low <= bandTop) : false
int barsSinceBand = ta.barssince(bandInteraction)
bool recentBandInteraction = not na(barsSinceBand) and barsSinceBand <= acceptanceWindowBars

float candleRange = math.max(high - low, syminfo.mintick)
float closeLocation = (close - low) / candleRange
float bearCloseLocation = 1.0 - closeLocation
bool confirmedClose = confirmationMode == "Realtime Allowed" ? true : barstate.isconfirmed
bool volumeSupported = volumeRatio >= volumeNeed

float invalidBull = math.min(bandBottom - atr * riskBufferAtr, slowEma - atr * riskBufferAtr * 0.50)
float invalidBear = math.max(bandTop + atr * riskBufferAtr, slowEma + atr * riskBufferAtr * 0.50)
float invalidRail = activeDir == 1 ? invalidBull : activeDir == -1 ? invalidBear : na
bool invalidRisk = activeDir == 1 ? close < invalidRail : activeDir == -1 ? close > invalidRail : false

float pullbackDepthAtr = activeDir == 1 ? math.max(fastEma - low, 0.0) / atr : activeDir == -1 ? math.max(high - fastEma, 0.0) / atr : na
float depthScoreNorm = activeDir != 0 ? f_peak_score(pullbackDepthAtr, 0.0, idealPullbackAtr, maxPullbackAtr) : 0.0

bool bullCloseAccepted = activeDir == 1 and recentBandInteraction and close > baseEma and closeLocation >= closeLocationNeed and close >= open
bool bearCloseAccepted = activeDir == -1 and recentBandInteraction and close < baseEma and bearCloseLocation >= closeLocationNeed and close <= open
bool closeAcceptedRaw = bullCloseAccepted or bearCloseAccepted

float priorHigh = ta.highest(high, targetLookback)[1]
float priorLow = ta.lowest(low, targetLookback)[1]
float targetObstacle = activeDir == 1 ? nz(priorHigh, high) : activeDir == -1 ? nz(priorLow, low) : na
bool targetClearing = activeDir == 1 ? close > targetObstacle : activeDir == -1 ? close < targetObstacle : false
float roomRaw = activeDir == 1 ? targetObstacle - close : activeDir == -1 ? close - targetObstacle : na
float targetRoomAtr = activeDir != 0 ? (targetClearing ? cleanRoomAtr : math.max(roomRaw, 0.0) / atr) : na
float targetScoreNorm = activeDir != 0 ? (targetClearing ? 100.0 : f_norm_high_good(targetRoomAtr, 0.15, cleanRoomAtr)) : 0.0

float trendStackScore = activeDir != 0 ? (heldContext ? 72.0 : 100.0) : 0.0
float slopeScore = activeDir == 1 ? f_norm_high_good(baseSlopeAtr, minSlopeAtr, minSlopeAtr + 0.18) : activeDir == -1 ? f_norm_high_good(-baseSlopeAtr, minSlopeAtr, minSlopeAtr + 0.18) : 0.0
float trendScore = (trendStackScore * 0.70 + slopeScore * 0.30) * 0.20
float pullbackScore = depthScoreNorm * 0.20
float closeScore = closeAcceptedRaw and stackQualified ? 25.0 : recentBandInteraction and not invalidRisk ? 12.0 : heldContext ? 8.0 : 4.0
float volumeScore = f_clamp(volumeRatio / volumeNeed * 100.0, 0.0, 100.0) * 0.15
float roomScore = targetScoreNorm * 0.20
float continuationScore = activeDir != 0 ? math.round(f_clamp(trendScore + pullbackScore + closeScore + volumeScore + roomScore, 0.0, 100.0)) : 0.0

bool closeModeReady = confirmedClose
bool volumeModeReady = confirmationMode == "Close + Volume" or confirmationMode == "Strict" ? volumeSupported : true
bool strictModeReady = confirmationMode == "Strict" ? (slopeScore >= 60.0 and targetScoreNorm >= 45.0) : true
bool acceptedState = stackQualified and closeModeReady and closeAcceptedRaw and volumeModeReady and strictModeReady and continuationScore >= acceptedThreshold and not invalidRisk
bool delayedState = activeDir != 0 and recentBandInteraction and not acceptedState and not invalidRisk and continuationScore >= watchThreshold
bool extendedState = activeDir == 1 ? close > bandTop + atr * 0.80 and not recentBandInteraction : activeDir == -1 ? close < bandBottom - atr * 0.80 and not recentBandInteraction : false
bool pausedState = heldContext and not invalidRisk and not acceptedState and not delayedState and not extendedState

string acceptanceState = "NO TREND"
if activeDir != 0
    if invalidRisk
        acceptanceState := "INVALID RISK"
    else if acceptedState
        acceptanceState := "ACCEPTED"
    else if delayedState
        acceptanceState := "DELAYED"
    else if extendedState
        acceptanceState := "EXTENDED"
    else if pausedState
        acceptanceState := "PAUSED"
    else
        acceptanceState := "WATCH"

string pullbackRisk = "N/A"
if activeDir != 0
    if invalidRisk
        pullbackRisk := "Invalidation"
    else if pullbackDepthAtr >= maxPullbackAtr
        pullbackRisk := "Deep"
    else if pullbackDepthAtr <= idealPullbackAtr * 0.35
        pullbackRisk := "Shallow"
    else
        pullbackRisk := "Balanced"

string targetRoomText = "N/A"
if activeDir != 0
    if targetClearing
        targetRoomText := "Open / Clearing"
    else if targetRoomAtr < 0.50
        targetRoomText := "Blocked " + f_fmt(targetRoomAtr) + " ATR"
    else
        targetRoomText := f_fmt(targetRoomAtr) + " ATR"

string workflowText = f_workflow_text(acceptanceState)
string stateDisplayText = f_state_display(acceptanceState)
string directionText = activeDir == 1 ? "Bullish" : activeDir == -1 ? "Bearish" : "No trend"
string riskText = f_risk_text(pullbackRisk)
string reviewText = activeDir == 0 ? "No trend / Map trend" : stateDisplayText + " / " + directionText + " / " + targetRoomText

bool isLightPanel = panelTheme == "Light"
color stateColor = f_state_color(acceptanceState, activeDir, continuationScore, isLightPanel)
color sideColor = f_side_color(activeDir)
color scoreColor = activeDir == 0 ? f_panel_value_color(isLightPanel) : f_score_color(continuationScore)
color riskColor = pullbackRisk == "Invalidation" ? dangerColor : pullbackRisk == "Deep" ? neutralColor : pullbackRisk == "Balanced" ? sideColor : f_panel_value_color(isLightPanel)
color roomColor = targetClearing ? sideColor : targetRoomAtr < 0.50 ? neutralColor : accentColor

// -------------------------------------------------
// Follow-rate proof (Confirm Rate)
// -------------------------------------------------
var int   folTotal   = 0
var int   folWon       = 0
var bool  folPend      = false
var int   folDir       = 0
var float folAnchor    = na
var int   folLeft      = 0
float folMargin = atr * 0.75

if barstate.isconfirmed
    if folPend and not na(folAnchor)
        bool favHit = folDir == 1 ? close >= folAnchor + folMargin : close <= folAnchor - folMargin
        bool advHit = (folDir == 1 ? close <= folAnchor - folMargin : close >= folAnchor + folMargin) or invalidRisk
        if favHit
            folTotal += 1
            folWon += 1
            folPend := false
        else if advHit
            folTotal += 1
            folPend := false
        else
            folLeft -= 1
            if folLeft <= 0
                folTotal += 1
                folPend := false
    if acceptedState and not acceptedState[1] and activeDir != 0 and not folPend
        folPend := true
        folDir := activeDir
        folAnchor := close
        folLeft := followWindow

float folRate = folTotal > 0 ? folWon / folTotal * 100.0 : na

plot(showEmaAnchors ? fastEma : na, "Fast EMA", color = color.new(sideColor, 20), linewidth = 1)
plot(showEmaAnchors ? baseEma : na, "Base EMA", color = color.new(accentColor, 10), linewidth = 2)
plot(showEmaAnchors ? slowEma : na, "Slow EMA", color = color.new(neutralColor, 18), linewidth = 2)

// -------------------------------------------------
// Live Planner Visuals
// -------------------------------------------------
var box activeBandBox = na
var label activeBandLabel = na
var line invalidLine = na
var line targetLine = na
var label invalidTag = na
var label targetTag = na
var label workflowTag = na
var array<label> stateLabels = array.new<label>()
var int lastEventLabelBar = na
var int lastWatchLabelBar = na
var string lastPrintedState = ""

int visualLeft = math.max(bar_index - 10, 0)
int visualRight = bar_index + projectionBars
int visualCenterX = int(math.round((visualLeft + visualRight) / 2.0))
float bandCenter = (bandTop + bandBottom) / 2.0
string bandText = stateDisplayText + "\n" + str.tostring(continuationScore, "#") + "/100"
color bandFill = color.new(stateColor, acceptanceState == "ACCEPTED" ? 82 : acceptanceState == "DELAYED" ? 86 : acceptanceState == "INVALID RISK" ? 88 : 90)
color bandBorder = color.new(stateColor, acceptanceState == "INVALID RISK" ? 8 : 28)
color bandLabelBg = color.new(stateColor, acceptanceState == "WATCH" or acceptanceState == "PAUSED" ? 8 : 4)
color bandLabelText = stateColor == neutralColor ? darkText : headerText

if showAcceptanceBand and activeDir != 0 and barstate.islast
    if na(activeBandBox)
        activeBandBox := box.new(visualLeft, bandTop, visualRight, bandBottom, xloc = xloc.bar_index, bgcolor = bandFill, border_color = bandBorder, border_width = 1)
    else
        box.set_lefttop(activeBandBox, visualLeft, bandTop)
        box.set_rightbottom(activeBandBox, visualRight, bandBottom)
        box.set_bgcolor(activeBandBox, bandFill)
        box.set_border_color(activeBandBox, bandBorder)
    if na(activeBandLabel)
        activeBandLabel := label.new(visualCenterX, bandCenter, bandText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = bandLabelBg, textcolor = bandLabelText, size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(activeBandLabel, visualCenterX, bandCenter)
        label.set_text(activeBandLabel, bandText)
        label.set_color(activeBandLabel, bandLabelBg)
        label.set_textcolor(activeBandLabel, bandLabelText)
        label.set_size(activeBandLabel, f_text_size(labelFontSize))
else if (not showAcceptanceBand or activeDir == 0) and not na(activeBandBox)
    box.delete(activeBandBox)
    activeBandBox := na
    if not na(activeBandLabel)
        label.delete(activeBandLabel)
        activeBandLabel := na

if showPlannerRails and activeDir != 0 and barstate.islast
    color railColor = invalidRisk ? dangerColor : color.new(sideColor, 0)
    if na(invalidLine)
        invalidLine := line.new(visualLeft, invalidRail, visualRight, invalidRail, xloc = xloc.bar_index, extend = extend.none, color = railColor, style = line.style_dashed, width = 2)
    else
        line.set_xy1(invalidLine, visualLeft, invalidRail)
        line.set_xy2(invalidLine, visualRight, invalidRail)
        line.set_color(invalidLine, railColor)
    if na(targetLine)
        targetLine := line.new(visualLeft, targetObstacle, visualRight, targetObstacle, xloc = xloc.bar_index, extend = extend.none, color = color.new(accentColor, 0), style = line.style_dotted, width = 2)
    else
        line.set_xy1(targetLine, visualLeft, targetObstacle)
        line.set_xy2(targetLine, visualRight, targetObstacle)
        line.set_color(targetLine, color.new(accentColor, 0))
else if (not showPlannerRails or activeDir == 0) and not na(invalidLine)
    line.delete(invalidLine)
    invalidLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

if showRightEdgeTags and activeDir != 0 and barstate.islast
    int tagX = visualRight + 2
    float tagGap = math.max(atr * 0.82, syminfo.mintick * 10.0)
    bool showWorkflowEdgeTag = not showAcceptanceBand
    float riskY = invalidRail
    float roomY = targetObstacle
    float workflowY = activeDir == 1 ? math.max(bandTop + tagGap, close + tagGap) : math.min(bandBottom - tagGap, close - tagGap)
    if math.abs(roomY - riskY) < tagGap * 1.35
        roomY := activeDir == 1 ? riskY + tagGap * 1.35 : riskY - tagGap * 1.35
    if math.abs(workflowY - roomY) < tagGap * 1.35
        workflowY := activeDir == 1 ? roomY + tagGap * 1.35 : roomY - tagGap * 1.35
    if math.abs(workflowY - riskY) < tagGap * 1.35
        workflowY := activeDir == 1 ? riskY + tagGap * 1.35 : riskY - tagGap * 1.35
    string riskTagText = invalidRisk ? "Reset Rail" : "Risk Rail"
    string targetTagText = targetClearing ? "Room Open" : "Room " + f_fmt(targetRoomAtr) + " ATR"
    string workflowTagText = stateDisplayText
    if na(invalidTag)
        invalidTag := label.new(tagX, riskY, riskTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(invalidRisk ? dangerColor : sideColor, 0), textcolor = headerText, size = f_text_size(labelFontSize))
    else
        label.set_xy(invalidTag, tagX, riskY)
        label.set_text(invalidTag, riskTagText)
        label.set_color(invalidTag, color.new(invalidRisk ? dangerColor : sideColor, 0))
        label.set_textcolor(invalidTag, headerText)
        label.set_size(invalidTag, f_text_size(labelFontSize))
    if na(targetTag)
        targetTag := label.new(tagX, roomY, targetTagText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = headerText, size = f_text_size(labelFontSize))
    else
        label.set_xy(targetTag, tagX, roomY)
        label.set_text(targetTag, targetTagText)
        label.set_color(targetTag, color.new(accentColor, 0))
        label.set_textcolor(targetTag, headerText)
        label.set_size(targetTag, f_text_size(labelFontSize))
    if showWorkflowEdgeTag
        if na(workflowTag)
            workflowTag := label.new(tagX + 4, workflowY, workflowTagText, xloc = xloc.bar_index, yloc = yloc.price, style = activeDir == 1 ? label.style_label_down : label.style_label_up, color = color.new(stateColor, 0), textcolor = bandLabelText, size = f_text_size(labelFontSize))
        else
            label.set_xy(workflowTag, tagX + 4, workflowY)
            label.set_text(workflowTag, workflowTagText)
            label.set_style(workflowTag, activeDir == 1 ? label.style_label_down : label.style_label_up)
            label.set_color(workflowTag, color.new(stateColor, 0))
            label.set_textcolor(workflowTag, bandLabelText)
            label.set_size(workflowTag, f_text_size(labelFontSize))
    else if not na(workflowTag)
        label.delete(workflowTag)
        workflowTag := na
else
    if not na(invalidTag)
        label.delete(invalidTag)
        invalidTag := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na
    if not na(workflowTag)
        label.delete(workflowTag)
        workflowTag := na

// -------------------------------------------------
// Historical State Labels
// -------------------------------------------------
int densityMaxLabels = labelDensity == "Detailed" ? maxVisibleLabels : labelDensity == "Balanced" ? math.min(maxVisibleLabels, 6) : math.min(maxVisibleLabels, 4)
int usedEventGap = labelDensity == "Detailed" ? labelCooldownBars : labelDensity == "Balanced" ? math.max(labelCooldownBars, 28) : math.max(labelCooldownBars, 42)
int usedWatchGap = labelDensity == "Detailed" ? contextSpacingBars : labelDensity == "Balanced" ? math.max(contextSpacingBars, 60) : math.max(contextSpacingBars, 84)
bool eventCooldownReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= usedEventGap
bool watchCooldownReady = na(lastWatchLabelBar) or bar_index - lastWatchLabelBar >= usedWatchGap
bool stateChangedLabel = acceptanceState != lastPrintedState
bool acceptedEvent = showEventLabels and acceptedState and eventCooldownReady and (stateChangedLabel or labelDensity == "Detailed")
bool delayedEvent = showEventLabels and delayedState and eventCooldownReady and (stateChangedLabel or continuationScore >= acceptedThreshold + 4 or labelDensity == "Detailed")
bool invalidEvent = showEventLabels and invalidRisk and eventCooldownReady and (stateChangedLabel or labelDensity != "Minimal")
bool extendedEvent = showEventLabels and extendedState and eventCooldownReady and stateChangedLabel
bool watchEvent = showEventLabels and activeDir != 0 and recentBandInteraction and watchCooldownReady and not acceptedEvent and not delayedEvent and not invalidEvent and not extendedEvent and continuationScore >= watchThreshold and acceptanceState == "WATCH"

if acceptedEvent or delayedEvent or invalidEvent or extendedEvent or watchEvent
    string labelTitle = invalidEvent ? "Reset" : acceptedEvent ? "Accepted" : delayedEvent ? "Wait" : extendedEvent ? "Avoid Chase" : "Watch"
    string scoreText = showLabelScore ? " " + str.tostring(continuationScore, "#") : ""
    string labelDetail = labelDensity == "Detailed" ? "\n" + directionText + " / Room " + f_fmt(targetRoomAtr) + " ATR" : ""
    string labelText = labelTitle + scoreText + labelDetail
    color labelColor = invalidEvent ? dangerColor : acceptedEvent ? sideColor : delayedEvent ? neutralColor : extendedEvent ? accentColor : accentColor
    float labelY = activeDir == 1 ? low - atr * labelOffsetAtr : high + atr * labelOffsetAtr
    labelStyle = activeDir == 1 ? label.style_label_up : label.style_label_down
    color labelTextColor = delayedEvent ? darkText : headerText
    label newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = labelStyle, color = color.new(labelColor, 0), textcolor = labelTextColor, size = f_text_size(labelFontSize), textalign = text.align_center)
    array.push(stateLabels, newLabel)
    f_trim_labels(stateLabels, densityMaxLabels)
    if watchEvent
        lastWatchLabelBar := bar_index
    else
        lastEventLabelBar := bar_index
        lastPrintedState := acceptanceState

// -------------------------------------------------
// Panel
// -------------------------------------------------
string folRateText = folTotal > 0 ? str.tostring(math.round(folRate)) + "% (" + str.tostring(folTotal) + ")" : "Building"
color folRateColor = na(folRate) ? f_panel_value_color(isLightPanel) : folRate >= 60.0 ? bullColor : folRate >= 45.0 ? neutralColor : dangerColor

var table infoPanel = na
var string lastPanelLocation = na
var string lastPanelTheme = na
var bool panelHeaderMerged = false

if barstate.islast
    bool panelNeedsRebuild = na(infoPanel) or lastPanelLocation != panelLocation or lastPanelTheme != panelTheme
    if showPanel and panelNeedsRebuild
        if not na(infoPanel)
            table.delete(infoPanel)
        infoPanel := table.new(f_panel_pos(panelLocation), 2, 8, bgcolor = f_panel_bg(isLightPanel, false), frame_color = f_panel_border(isLightPanel), frame_width = 1, border_color = f_panel_border(isLightPanel), border_width = 1)
        table.cell(infoPanel, 0, 0, "AG Pro Continuation Acceptance Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize))
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        panelHeaderMerged := true
        lastPanelLocation := panelLocation
        lastPanelTheme := panelTheme
    if showPanel and not na(infoPanel)
        if not panelHeaderMerged
            table.merge_cells(infoPanel, 0, 0, 1, 0)
            panelHeaderMerged := true
        table.cell(infoPanel, 0, 0, "AG Pro Continuation Acceptance Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
        string scorePanelText = activeDir == 0 ? "-" : str.tostring(continuationScore, "#") + "/100 " + f_score_grade(continuationScore)
        string directionPanelText = activeDir == 0 ? "No trend" : directionText + (heldContext ? " / Rebuild" : " / Active")
        string roomPanelText = targetRoomText + (activeDir == 0 ? "" : " / " + f_fmt(volumeRatio) + "x V")
        f_panel_row(infoPanel, 1, "Workflow", workflowText, stateColor, isLightPanel, panelFontSize)
        f_panel_row(infoPanel, 2, "Direction Context", directionPanelText, sideColor, isLightPanel, panelFontSize)
        f_panel_row(infoPanel, 3, "Continuation Score", scorePanelText, scoreColor, isLightPanel, panelFontSize)
        f_panel_row(infoPanel, 4, "Follow Rate", folRateText, folRateColor, isLightPanel, panelFontSize)
        f_panel_row(infoPanel, 5, "Acceptance State", stateDisplayText, stateColor, isLightPanel, panelFontSize)
        f_panel_row(infoPanel, 6, "Risk / Room", riskText + " / " + roomPanelText, riskColor, isLightPanel, panelFontSize)
        f_panel_row(infoPanel, 7, "Review", reviewText, stateColor, isLightPanel, panelFontSize)
    else
        if not na(infoPanel)
            table.delete(infoPanel)
            infoPanel := na
            lastPanelLocation := na
            lastPanelTheme := na
            panelHeaderMerged := false

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool alertAccepted = acceptedState and continuationScore >= alertScoreThreshold
bool alertDelayed = delayedState and continuationScore >= alertScoreThreshold
bool alertInvalid = invalidRisk and activeDir != 0
bool alertTargetBlocked = activeDir != 0 and not targetClearing and targetRoomAtr < 0.50 and continuationScore >= watchThreshold

alertcondition(alertAccepted and activeDir == 1, "Bullish Continuation Accepted", "Continuation Acceptance Planner: bullish continuation acceptance context is active. This is an attention marker, not a trade instruction.")
alertcondition(alertAccepted and activeDir == -1, "Bearish Continuation Accepted", "Continuation Acceptance Planner: bearish continuation acceptance context is active. This is an attention marker, not a trade instruction.")
alertcondition(alertDelayed, "Continuation Acceptance Waiting", "Continuation Acceptance Planner: price is waiting inside the continuation acceptance band. This is an attention marker, not a trade instruction.")
alertcondition(alertInvalid, "Continuation Reset Context", "Continuation Acceptance Planner: continuation context is near the invalidation rail. This is an attention marker, not a trade instruction.")
alertcondition(alertTargetBlocked, "Continuation Target Room Limited", "Continuation Acceptance Planner: target room is limited near the next obstruction. This is an attention marker, not a trade instruction.")

plot(continuationScore, "CAP Continuation Score", display = display.none)
plot(float(activeDir), "CAP Active Direction", display = display.none)
plot(folRate, "CAP Follow Rate", display = display.none)
````
