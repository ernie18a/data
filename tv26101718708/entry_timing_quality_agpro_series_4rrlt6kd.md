# Entry Timing Quality [AGPro Series]

- url: https://www.tradingview.com/script/4RRLT6kD-Entry-Timing-Quality-AGPro-Series/
- type: indicator
- pine_id: PUB;1028a5cc820e4c6e9f9b48d493b786cd
- version: 4.0

## Description

Entry Timing Quality [AGPro Series]

🧠 Core Idea

Is the current setup timing early, improving, in-window, late, or already exhausted?


📌 Overview / What it does

Entry Timing Quality is a chart-first execution timing tool built to evaluate when a setup deserves attention from a timing perspective.

The script produces a 0-100 Timing Score, a timing window, an invalidation rail, target-side room context, early / improving / prime / late / exhausted state labels, a momentum clock marker, alert conditions, and a clean AGPro panel.

It does not predict price direction, automate execution, print directional commands, or replace a trader's own setup model. Its purpose is to organize timing quality after a setup thesis already exists.


🎯 Purpose & Design Philosophy

This script was built for traders who already see a possible setup but need a cleaner way to judge whether the timing is too early, becoming actionable, already extended, or no longer fresh.

The gap it fills is specific: many tools show entries, signals, levels, or broad readiness states, but they do not isolate the timing phase of a setup.

The design supports a disciplined execution-review mindset: timing first, risk context second, action only after independent confirmation.


⚡ Why This Script Is Different

Most tools focus on printing entries, highlighting generic signals, or building full trade plans.

This script does NOT act as a full Entry Execution Readiness system, Position Planner, Reward Room Analyzer, or directional signal indicator.

Instead, it answers a narrower timing question: is the setup still early, improving into a better timing window, in a prime timing phase, late, exhausted, or structurally invalidated?


⚙️ Methodology

1. Context Detection

The script detects the active timing side automatically from trend structure, or lets the user force long-side or short-side timing review.

2. Reference Mapping

It maps a timing window around the active trigger reference, an invalidation rail from recent structure, a late timing rail, and target-side reference room.

3. Reaction Evaluation

The model scores trigger proximity, candle efficiency, pullback maturity, momentum reset, volatility expansion, risk distance, and target-side room.

4. Visual Output

The chart displays the active timing window, target-side room context, invalidation rail, late timing rail, momentum clock marker, event labels, alerts, and the AGPro panel.


🗺️ How to Read the Chart

Zones = the timing window and target-side room context.

Invalidation rail = the structural level that weakens or resets the current timing read.

Late timing rail = the area where timing may become extended rather than fresh.

Labels = compact markers for Early, Improving, Prime, Late, Exhausted, and Invalidated states.

Colors = teal for stronger long-side timing context, pink for short-side or invalidation context, amber for early or late caution, and indigo for improving timing.

Panel = the fast decision cockpit showing Timing Score, Window State, Momentum Phase, Risk Distance, and Action.


🚦 Signals & States

• PRIME -> timing score and confirmation conditions align inside or near the active timing window.

• IMPROVING -> timing is building but has not reached the Prime threshold.

• EARLY -> the setup exists, but timing still needs cleaner proximity, reset, or candle quality.

• LATE -> price has stretched away from the timing window and may be less fresh.

• EXHAUSTED -> extension, pullback damage, or momentum heat suggests the timing phase needs reset.

• INVALIDATED -> price closed beyond the structural invalidation rail.


🔔 Alerts Logic

Prime Timing alerts trigger when the state upgrades into Prime Timing.

Improving Timing alerts trigger when the setup moves into an active monitoring state.

Late / Exhausted alerts trigger when the timing phase becomes stretched or no longer fresh.

Invalidation alerts trigger when price closes beyond the active invalidation rail.

Alerts are attention markers. They are not trading instructions.


🧩 Confluence Logic

Timing quality improves when trigger proximity, candle efficiency, pullback maturity, momentum reset, stable volatility, trend support, and target-side room align.

The score is intentionally multi-factor so a single candle or a single trend condition cannot dominate the timing read.


📊 When to Use

• Pullback timing reviews

• Trend continuation setups that need timing discipline

• Breakout continuation setups after a reset

• Execution-review workflows where a setup thesis already exists

• Charts where the user wants to avoid chasing late movement


⚠️ When NOT to Use

• Very low-liquidity symbols

• Extremely noisy sideways markets

• News-shock volatility spikes

• Charts where no independent setup thesis exists

• Situations where exact broker-level execution rules are required


🎛️ Key Inputs

• Timing Side -> Auto, Long Timing, or Short Timing review mode.

• Sensitivity -> adjusts how early or selective the timing model becomes.

• Timing Lookback -> affects structure references, pullback maturity, risk distance, and target-side room.

• Minimum Prime Timing Score -> sets the threshold required for Prime Timing.

• Confirmation Mode -> controls how much candle, trend, and momentum confirmation is required.

• Label Cooldown / Max Visible Labels -> controls label density and chart cleanliness.

• Visual settings -> control timing window, momentum clock marker, label offsets, and font sizes.

• Panel settings -> control panel visibility, location, theme, and font size.


🖥️ Interface & Visual Design

The panel follows the AGPro public-release standard with one merged blue header row containing only the script name.

The chart is designed to feel active but not crowded. It uses one timing window, one invalidation rail, one late rail, target-side room context, a compact momentum clock marker, and controlled event labels.

Label and panel font sizes are adjustable, with Normal as the default.


🧪 Practical Usage Workflow

1. Read the panel Timing Score and Window State.

2. Check whether price is inside, near, late beyond, or away from the timing window.

3. Review the Momentum Phase to see whether timing is resetting, expanding, hot, or cooling.

4. Compare Risk Distance with target-side room context.

5. Treat Prime Timing as a review state, not as an automatic execution command.


🔍 Interpretation Guidelines

A high Timing Score means the modeled timing conditions are cleaner than usual according to the script's rules.

An Improving state can be useful because it shows timing is building but not yet fully aligned.

A Late or Exhausted state does not mean price must reverse. It means the timing read is no longer fresh and should be reviewed with extra caution.

The best interpretation comes from reading score, state, momentum phase, risk distance, and invalidation together.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a full position-sizing planner

• Not a directional command system

• Not a full reward-room or target-planning tool


⚠️ Limitations & Transparency

The model is rule-based and depends on recent structure, ATR, moving-average context, candle behavior, and RSI-based momentum reset.

Different timeframes can produce different timing windows and invalidation rails.

Fast volatility expansion can move a setup from Improving to Late quickly.

No rule-based tool can know future price behavior, order-book conditions, spreads, or a user's execution plan.


🧠 Market Context Notes

Timing is most useful when read together with broader market structure, liquidity, trend condition, volatility, and session context.

A setup can have good direction but poor timing.

A setup can also have a clean timing window but poor broader context.


🧾 Use Case Examples

When price pulls back near the timing window, momentum resets, candle quality improves, and risk distance remains controlled, the state may move from Early to Improving or Prime.

When price stretches far beyond the late rail while momentum becomes hot, the script may mark Late or Exhausted rather than encouraging the user to chase.

When price closes beyond the invalidation rail, the active timing read is marked as Invalidated.


🧱 System Philosophy

AGPro tools are designed to convert visible chart information into structured decision context.

This script follows that philosophy by separating timing quality from generic signals, full trade planning, or prediction language.


🔐 Non-Promise Statement

No script can provide certainty.

No timing score can guarantee a future outcome.

This tool organizes visible timing conditions so users can perform a more structured review.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, execution, risk management, and decisions.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the script to study how timing improves, becomes prime, stretches late, exhausts, or invalidates around a structured execution window.

## Source Code

````pine
// -------------------------------------------------
// Entry Timing Quality [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Entry Timing Quality is an execution-readiness timing tool that evaluates
// whether a setup is early, improving, in-window, late, or exhausted. It uses
// trigger proximity, candle efficiency, pullback maturity, momentum reset,
// volatility expansion, risk distance, and target-side room to create a
// neutral 0-100 Timing Score, plus a persistent prime-hit-rate proof layer,
// without printing entry instructions.
// -------------------------------------------------

//@version=6
indicator("Entry Timing Quality [AGPro Series]",
     shorttitle = "AG Pro ETQ",
     overlay = true,
     max_labels_count = 60,
     max_lines_count = 10,
     max_boxes_count = 4)

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
color targetBlue    = color.rgb(59, 130, 246)
color darkText      = color.rgb(17, 24, 39)

string groupCore   = "Core Timing Engine"
string groupProof  = "Confirm-Rate Proof"
string groupVisual = "Visual Design"
string groupPanel  = "AGPro Panel"
string groupAlerts = "Alerts"

string timingSide = input.string("Auto", "Timing Side", options = ["Auto", "Long Timing", "Short Timing"], group = groupCore, tooltip = "Select Auto to infer the active timing side from trend context, or force a long-side or short-side timing review for your own setup thesis.")
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupCore, tooltip = "Controls how selective the timing model is. Conservative waits for cleaner timing windows; Aggressive reacts earlier with wider tolerance.")
int lookback = input.int(55, "Timing Lookback", minval = 20, maxval = 200, group = groupCore, tooltip = "Bars used to evaluate pullback maturity, structure references, momentum reset, risk distance, and target-side room.")
int minimumPrimeScore = input.int(72, "Minimum Prime Timing Score", minval = 50, maxval = 95, group = groupCore, tooltip = "Minimum 0-100 Timing Score required before the state can become Prime Timing.")
string confirmationMode = input.string("Balanced", "Confirmation Mode", options = ["Early", "Balanced", "Strict"], group = groupCore, tooltip = "Defines how much candle quality, momentum reset, and trend support must align before the timing state can become Prime Timing.")
int cooldownBars = input.int(50, "Label Cooldown Bars", minval = 10, maxval = 100, group = groupCore, tooltip = "Minimum spacing between repeated timing labels. The publication default preserves meaningful history without crowding the active plan.")
int maxVisibleLabels = input.int(5, "Max Visible Labels", minval = 4, maxval = 12, group = groupCore, tooltip = "Maximum number of historical timing labels kept on the chart.")

int proofWindow = input.int(30, "Proof Window Bars", minval = 4, maxval = 250, group = groupProof, tooltip = "Bars used to resolve each prime-hit-rate proof sample. A win is recorded when, after a Prime Timing event, price reaches one risk-distance in the timing direction before closing beyond the invalidation rail.")

bool showWindow = input.bool(true, "Show Timing Window", group = groupVisual, tooltip = "Displays the active timing window, late rail, invalidation rail, and target-side reference room.")
bool showWindowBadges = input.bool(true, "Show Centered Window Badges", group = groupVisual, tooltip = "Shows separate centered labels for timing window and target room without embedding text directly into boxes.")
bool showLabels = input.bool(true, "Show Timing Labels", group = groupVisual, tooltip = "Displays controlled on-chart timing labels with phase and score context.")
bool showClockMarker = input.bool(true, "Show Momentum Clock Marker", group = groupVisual, tooltip = "Displays a compact marker near the current timing window that summarizes the active momentum phase.")
bool showScoreTag = input.bool(false, "Show Right-Side Score Tag", group = groupVisual, tooltip = "Shows a compact right-side score tag. Disabled by default because the panel and event labels already display timing score.")
bool adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = groupVisual, tooltip = "Shortens window projection on higher timeframes so timing zones and tags remain balanced.")
int projectionBars = input.int(22, "Window Projection Bars", minval = 10, maxval = 80, group = groupVisual, tooltip = "How far the active timing window and reference rails project to the right side of the chart.")
float labelOffsetAtr = input.float(1.05, "Label Offset (ATR)", minval = 0.2, maxval = 3.0, step = 0.05, group = groupVisual, tooltip = "ATR-based distance used to place labels outside the candle cluster so they remain readable.")
float labelLaneSpreadAtr = input.float(0.52, "Label Lane Spread (ATR)", minval = 0.20, maxval = 2.50, step = 0.05, group = groupVisual, tooltip = "Adds vertical spacing between nearby timing labels without making the chart sparse.")
int labelShiftBars = input.int(7, "Label Stagger Bars", minval = 0, maxval = 20, group = groupVisual, tooltip = "Shifts nearby timing labels left or right to reduce overlap.")
string labelDetail = input.string("Balanced", "Label Detail", options = ["Balanced", "Full"], group = groupVisual, tooltip = "Controls label text depth. Balanced keeps labels compact; Full adds timing side and risk context.")
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupVisual, tooltip = "Controls all chart labels, centered badges, and right-side tags. Normal is the default publication setting.")

bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AGPro timing panel. The panel is enabled by default for publication-ready presentation.")
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Selects the on-chart position of the AGPro timing panel.")
string panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = groupPanel, tooltip = "Controls the panel color theme while keeping the standard AGPro blue header row.")
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default publication setting.")

bool enablePrimeAlert = input.bool(true, "Enable Prime Timing Alert", group = groupAlerts, tooltip = "Allows alert conditions when the timing state upgrades into Prime Timing. Alerts are attention markers, not trade instructions.")
bool enableEarlyAlert = input.bool(true, "Enable Improving Timing Alert", group = groupAlerts, tooltip = "Allows alert conditions when timing improves from Early or Waiting into Improving Timing.")
bool enableLateAlert = input.bool(true, "Enable Late / Exhausted Alert", group = groupAlerts, tooltip = "Allows alert conditions when timing becomes late or exhausted.")
bool enableInvalidAlert = input.bool(true, "Enable Timing Invalidation Alert", group = groupAlerts, tooltip = "Allows alert conditions when price closes beyond the timing invalidation rail.")

f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_size(string value) =>
    switch value
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_panel_pos(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(245, 247, 250) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_alt_bg() =>
    panelTheme == "Clean Light" ? color.rgb(241, 245, 249) : panelTheme == "Slate" ? color.rgb(37, 49, 70) : color.rgb(20, 31, 52)

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_state_rank(string stateValue) =>
    switch stateValue
        "PRIME" => 5
        "IMPROVING" => 4
        "EARLY" => 3
        "LATE" => 2
        "EXHAUSTED" => 1
        "INVALIDATED" => 0
        => 2

f_score_text(float value) =>
    str.tostring(math.round(value), "#")

f_value_text(float value) =>
    str.tostring(value, "#.#")

f_update_center_label(label id, int x, float y, string txt, color bg, color txtColor) =>
    label.set_xy(id, x, y)
    label.set_text(id, txt)
    label.set_color(id, bg)
    label.set_textcolor(id, txtColor)
    label.set_size(id, f_size(labelFontSize))
    label.set_style(id, label.style_label_center)
    label.set_textalign(id, text.align_center)

int fastLen = sensitivity == "Conservative" ? 34 : sensitivity == "Aggressive" ? 13 : 21
int slowLen = sensitivity == "Conservative" ? 89 : sensitivity == "Aggressive" ? 34 : 55
float windowAtr = sensitivity == "Conservative" ? 0.50 : sensitivity == "Aggressive" ? 0.86 : 0.66
float lateAtr = sensitivity == "Conservative" ? 1.85 : sensitivity == "Aggressive" ? 2.70 : 2.20
float riskBufferAtr = sensitivity == "Conservative" ? 0.22 : sensitivity == "Aggressive" ? 0.10 : 0.16
float targetAtrFallback = sensitivity == "Conservative" ? 2.35 : sensitivity == "Aggressive" ? 1.65 : 1.95

float atrRaw = ta.atr(14)
float safeAtrBase = nz(atrRaw, high - low)
float safeAtr = math.max(safeAtrBase, syminfo.mintick)
float atrAverage = ta.sma(atrRaw, lookback)
float atrRatio = safeAtr / math.max(nz(atrAverage, safeAtr), syminfo.mintick)

float emaFast = ta.ema(close, fastLen)
float emaSlow = ta.ema(close, slowLen)
float emaSlope = emaFast - nz(emaFast[5], emaFast)
float rsiValue = ta.rsi(close, 14)
float rsiBasis = ta.ema(rsiValue, 5)
bool rsiResetLong = rsiValue > rsiBasis and rsiValue > 45 and rsiValue < 72
bool rsiResetShort = rsiValue < rsiBasis and rsiValue < 55 and rsiValue > 28

int autoBiasRaw = close >= emaFast and emaFast >= emaSlow ? 1 : close <= emaFast and emaFast <= emaSlow ? -1 : 0
var int heldAutoBias = 0
heldAutoBias := autoBiasRaw != 0 ? autoBiasRaw : nz(heldAutoBias[1], close >= emaSlow ? 1 : -1)
int setupBias = timingSide == "Long Timing" ? 1 : timingSide == "Short Timing" ? -1 : heldAutoBias
bool isLongTiming = setupBias == 1

int riskLookback = math.max(8, int(math.round(lookback * 0.55)))
float recentLow = nz(ta.lowest(low[1], riskLookback), low)
float recentHigh = nz(ta.highest(high[1], riskLookback), high)
float obstacleHigh = nz(ta.highest(high[1], lookback), high)
float obstacleLow = nz(ta.lowest(low[1], lookback), low)
float pullbackHigh = ta.highest(high, lookback)
float pullbackLow = ta.lowest(low, lookback)
float labelClearTopSeries = ta.highest(high, 5)
float labelClearBottomSeries = ta.lowest(low, 5)

float invalidation = isLongTiming ? recentLow - safeAtr * riskBufferAtr : recentHigh + safeAtr * riskBufferAtr
float targetCandidate = isLongTiming ? obstacleHigh : obstacleLow
float targetFallback = isLongTiming ? close + safeAtr * targetAtrFallback : close - safeAtr * targetAtrFallback
float targetReference = isLongTiming ? math.max(targetCandidate, targetFallback) : math.min(targetCandidate, targetFallback)

float riskDistance = math.max(math.abs(close - invalidation), syminfo.mintick)
float targetRoom = math.max(math.abs(targetReference - close), syminfo.mintick)
float riskAtr = riskDistance / safeAtr
float targetR = targetRoom / riskDistance

float triggerLine = emaFast
float windowTop = triggerLine + safeAtr * windowAtr
float windowBottom = triggerLine - safeAtr * windowAtr
float lateRail = isLongTiming ? triggerLine + safeAtr * lateAtr : triggerLine - safeAtr * lateAtr
float targetTop = math.max(close, targetReference)
float targetBottom = math.min(close, targetReference)

float distanceToTriggerAtr = math.abs(close - triggerLine) / safeAtr
float extensionAtr = isLongTiming ? (close - triggerLine) / safeAtr : (triggerLine - close) / safeAtr
bool insideWindow = close <= windowTop and close >= windowBottom
bool nearWindow = distanceToTriggerAtr <= windowAtr * 1.55
bool lateExtension = extensionAtr > lateAtr * 0.78
bool exhaustedExtension = extensionAtr > lateAtr * 1.08

float pullbackDepth = isLongTiming ? (pullbackHigh - low) / safeAtr : (high - pullbackLow) / safeAtr
float pullbackMaturity = f_clamp(pullbackDepth / math.max(lateAtr, 0.1), 0.0, 1.0)
bool pullbackTooDeep = pullbackDepth > lateAtr * 1.65
bool roomTooThin = targetR < 0.70
bool riskTooWide = riskAtr > 4.00

float barRange = math.max(high - low, syminfo.mintick)
float bodySize = math.abs(close - open)
float bodyEfficiency = f_clamp(bodySize / barRange, 0.0, 1.0)
float closeLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
float directionalClose = isLongTiming ? closeLocation : 1.0 - closeLocation
bool candleAgrees = isLongTiming ? close >= open : close <= open

bool trendAligned = isLongTiming ? emaFast > emaSlow and close > emaSlow : emaFast < emaSlow and close < emaSlow
bool trendPartial = isLongTiming ? close > emaFast or emaFast > emaSlow : close < emaFast or emaFast < emaSlow
bool trendSlopeAligned = isLongTiming ? emaSlope > 0 : emaSlope < 0
bool momentumReset = isLongTiming ? rsiResetLong : rsiResetShort
bool momentumExpanding = isLongTiming ? rsiValue > nz(rsiValue[1], rsiValue) : rsiValue < nz(rsiValue[1], rsiValue)
bool momentumHot = isLongTiming ? rsiValue >= 72 : rsiValue <= 28

float proximityScore = f_clamp(24.0 - distanceToTriggerAtr * 11.0, 0.0, 24.0)
float candleScore = bodyEfficiency * 10.0 + directionalClose * 6.0 + (candleAgrees ? 4.0 : 0.0)
float pullbackScore = f_clamp(18.0 - math.abs(pullbackMaturity - 0.62) * 24.0, 0.0, 18.0)
float momentumScore = (momentumReset ? 14.0 : 4.0) + (momentumExpanding ? 6.0 : 0.0) - (momentumHot ? 5.0 : 0.0)
float volScore = f_clamp(14.0 - math.abs(atrRatio - 1.05) * 14.0, 0.0, 14.0)
float riskRoomScore = f_clamp((targetR - 0.70) / 1.45 * 12.0, 0.0, 12.0)
float trendScore = (trendAligned ? 8.0 : trendPartial ? 4.0 : 0.0) + (trendSlopeAligned ? 4.0 : 0.0)

float timingRaw = proximityScore + candleScore + pullbackScore + momentumScore + volScore + riskRoomScore + trendScore
float timingPenalty = lateExtension ? 13.0 : 0.0
timingPenalty += exhaustedExtension ? 18.0 : 0.0
timingPenalty += pullbackTooDeep ? 12.0 : 0.0
timingPenalty += momentumHot ? 8.0 : 0.0
timingPenalty += targetR < 0.55 ? 18.0 : targetR < 0.75 ? 10.0 : 0.0
timingPenalty += riskAtr > 4.00 ? 16.0 : riskAtr > 3.00 ? 10.0 : 0.0
bool exhaustionPressure = exhaustedExtension or pullbackTooDeep or (momentumHot and not nearWindow)
float timingScoreRaw = f_clamp(timingRaw - timingPenalty, 0.0, 100.0)
float timingScore = exhaustionPressure ? math.min(timingScoreRaw, 62.0) : lateExtension ? math.min(timingScoreRaw, 68.0) : timingScoreRaw

bool strictConfirm = trendAligned and trendSlopeAligned and candleAgrees and momentumReset and insideWindow and targetR >= 1.05
bool balancedConfirm = (trendAligned or trendSlopeAligned) and candleAgrees and momentumReset and nearWindow and targetR >= 0.90
bool earlyConfirm = trendPartial and directionalClose >= 0.48 and nearWindow and targetR >= 0.75
bool isConfirmed = confirmationMode == "Strict" ? strictConfirm : confirmationMode == "Early" ? earlyConfirm : balancedConfirm

bool isInvalidated = isLongTiming ? close < invalidation : close > invalidation
bool isExhausted = exhaustionPressure
string windowState = isInvalidated ? "INVALIDATED" : isExhausted ? "EXHAUSTED" : lateExtension ? "LATE" : roomTooThin or riskTooWide ? "EARLY" : timingScore >= minimumPrimeScore and isConfirmed ? "PRIME" : timingScore >= minimumPrimeScore - 10 ? "IMPROVING" : "EARLY"
string momentumPhase = isInvalidated ? "Invalidated" : momentumHot ? "Hot / Extended" : momentumReset and momentumExpanding ? "Reset Expanding" : momentumReset ? "Reset" : momentumExpanding ? "Building" : "Cooling"
string nextAction = windowState == "PRIME" ? "Review timing checklist" : roomTooThin ? "Wait for more room" : riskTooWide ? "Wait for tighter risk" : windowState == "IMPROVING" ? "Monitor timing window" : windowState == "EARLY" ? "Wait for timing reset" : windowState == "LATE" ? "Avoid chasing timing" : windowState == "EXHAUSTED" ? "Let timing reset" : "Reset the setup"

color stateColor = windowState == "PRIME" ? (isLongTiming ? bullColor : bearColor) : windowState == "IMPROVING" ? accentColor : windowState == "EARLY" ? neutralColor : windowState == "INVALIDATED" ? bearColor : panelLabelCol
string timingText = isLongTiming ? "Long Timing" : "Short Timing"
string riskText = str.tostring(riskAtr, "#.##") + " ATR"
string riskShortText = str.tostring(riskAtr, "#.##") + "A"
string targetText = str.tostring(targetR, "#.##") + "R"

var string previousState = "EARLY"
bool primeStateEvent = barstate.isconfirmed and windowState == "PRIME" and previousState != "PRIME"
bool improvingStateEvent = barstate.isconfirmed and windowState == "IMPROVING" and f_state_rank(previousState) < f_state_rank("IMPROVING")
bool lateStateEvent = barstate.isconfirmed and (windowState == "LATE" or windowState == "EXHAUSTED") and previousState != windowState
bool invalidStateEvent = barstate.isconfirmed and windowState == "INVALIDATED" and previousState != "INVALIDATED"

bool primeEvent = enablePrimeAlert and primeStateEvent
bool earlyEvent = enableEarlyAlert and improvingStateEvent
bool lateEvent = enableLateAlert and lateStateEvent
bool invalidEvent = enableInvalidAlert and invalidStateEvent

// -------------------------------------------------
// Prime-Hit-Rate Proof
// On a Prime Timing event, a win is recorded when price reaches one
// risk-distance in the timing direction before closing beyond the invalidation
// rail (a balanced one-risk target-versus-stop test). Samples that resolve
// neither target nor stop inside the window are left unresolved and uncounted.
// -------------------------------------------------
var bool proofPending = false
var int proofDir = 0
var float proofTarget = na
var float proofStop = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

if primeStateEvent and not proofPending
    proofPending := true
    proofDir := isLongTiming ? 1 : -1
    proofTarget := close + (isLongTiming ? 1 : -1) * riskDistance
    proofStop := invalidation
    proofStartBar := bar_index

if proofPending and barstate.isconfirmed and bar_index > proofStartBar
    bool proofFav = proofDir == 1 ? high >= proofTarget : low <= proofTarget
    bool proofStopped = proofDir == 1 ? close < proofStop : close > proofStop
    bool proofExp = bar_index - proofStartBar >= proofWindow
    if proofFav and proofStopped
        proofTotal += 1
        proofPending := false
    else if proofFav
        proofTotal += 1
        proofWin += 1
        proofPending := false
    else if proofStopped
        proofTotal += 1
        proofPending := false
    else if proofExp
        proofPending := false

float primeHitRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na
string primeHitRateText = na(primeHitRate) ? "Building" : str.tostring(math.round(primeHitRate)) + "% (" + str.tostring(proofTotal) + ")"
color primeHitRateColor = na(primeHitRate) ? f_panel_value() : primeHitRate >= 55.0 ? bullColor : primeHitRate >= 40.0 ? neutralColor : bearColor

alertcondition(primeEvent, "Entry Timing Quality Prime Timing", "Entry Timing Quality: timing upgraded to Prime Timing. This is an attention marker, not a trade instruction.")
alertcondition(earlyEvent, "Entry Timing Quality Improving Timing", "Entry Timing Quality: timing improved into an active monitoring state.")
alertcondition(lateEvent, "Entry Timing Quality Late or Exhausted", "Entry Timing Quality: timing became late or exhausted. Review context before acting.")
alertcondition(invalidEvent, "Entry Timing Quality Invalidated", "Entry Timing Quality: price closed beyond the timing invalidation rail.")

var box timingWindowBox = na
var box targetRoomBox = na
var line invalidationRail = na
var line lateTimingRail = na
var label timingWindowBadge = na
var label targetRoomBadge = na
var label invalidationTag = na
var label clockTag = na
var label scoreTag = na

if barstate.islast
    int forwardBars = adaptiveProjection and not timeframe.isintraday ? math.max(14, int(math.round(projectionBars * 0.70))) : projectionBars
    int zoneLeft = math.max(bar_index - 3, 0)
    int zoneRight = bar_index + forwardBars
    int zoneCenter = bar_index + int(math.round(forwardBars * 0.50))
    int timingBadgeX = bar_index + int(math.round(forwardBars * 0.32))
    int targetBadgeX = bar_index + int(math.round(forwardBars * 0.72))
    string scoreText = (isLongTiming ? "LONG " : "SHORT ") + windowState + " | Q " + f_score_text(timingScore)
    if showWindow
        if na(timingWindowBox)
            timingWindowBox := box.new(left = zoneLeft, top = windowTop, right = zoneRight, bottom = windowBottom, xloc = xloc.bar_index, border_color = color.new(accentColor, 20), bgcolor = color.new(accentColor, 90))
        else
            box.set_left(timingWindowBox, zoneLeft)
            box.set_right(timingWindowBox, zoneRight)
            box.set_top(timingWindowBox, windowTop)
            box.set_bottom(timingWindowBox, windowBottom)
            box.set_bgcolor(timingWindowBox, color.new(accentColor, 90))
            box.set_border_color(timingWindowBox, color.new(accentColor, 20))

        if na(targetRoomBox)
            targetRoomBox := box.new(left = zoneLeft, top = targetTop, right = zoneRight, bottom = targetBottom, xloc = xloc.bar_index, border_color = color.new(stateColor, 40), bgcolor = color.new(stateColor, 95))
        else
            box.set_left(targetRoomBox, zoneLeft)
            box.set_right(targetRoomBox, zoneRight)
            box.set_top(targetRoomBox, targetTop)
            box.set_bottom(targetRoomBox, targetBottom)
            box.set_bgcolor(targetRoomBox, color.new(stateColor, 95))
            box.set_border_color(targetRoomBox, color.new(stateColor, 40))

        if showWindowBadges
            float timingBadgeY = (windowTop + windowBottom) * 0.5
            float targetBadgeY = (targetTop + targetBottom) * 0.5
            string timingBadgeText = (isLongTiming ? "LONG" : "SHORT") + " TIMING | " + windowState + " " + f_score_text(timingScore)
            string targetBadgeText = "TARGET ROOM | " + targetText
            if na(timingWindowBadge)
                timingWindowBadge := label.new(timingBadgeX, timingBadgeY, timingBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(accentColor, 8), textcolor = f_text_on(accentColor), size = f_size(labelFontSize), textalign = text.align_center)
            else
                f_update_center_label(timingWindowBadge, timingBadgeX, timingBadgeY, timingBadgeText, color.new(accentColor, 8), f_text_on(accentColor))
            if na(targetRoomBadge)
                targetRoomBadge := label.new(targetBadgeX, targetBadgeY, targetBadgeText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(targetBlue, 8), textcolor = f_text_on(targetBlue), size = f_size(labelFontSize), textalign = text.align_center)
            else
                f_update_center_label(targetRoomBadge, targetBadgeX, targetBadgeY, targetBadgeText, color.new(targetBlue, 8), f_text_on(targetBlue))
        else
            if not na(timingWindowBadge)
                label.delete(timingWindowBadge)
                timingWindowBadge := na
            if not na(targetRoomBadge)
                label.delete(targetRoomBadge)
                targetRoomBadge := na

        if na(invalidationRail)
            invalidationRail := line.new(x1 = zoneLeft, y1 = invalidation, x2 = zoneRight, y2 = invalidation, xloc = xloc.bar_index, extend = extend.none, color = color.new(bearColor, 0), style = line.style_dashed, width = 2)
        else
            line.set_xy1(invalidationRail, zoneLeft, invalidation)
            line.set_xy2(invalidationRail, zoneRight, invalidation)
            line.set_color(invalidationRail, color.new(bearColor, 0))
            line.set_width(invalidationRail, 2)

        if na(lateTimingRail)
            lateTimingRail := line.new(x1 = zoneLeft, y1 = lateRail, x2 = zoneRight, y2 = lateRail, xloc = xloc.bar_index, extend = extend.none, color = color.new(neutralColor, 0), style = line.style_dotted, width = 2)
        else
            line.set_xy1(lateTimingRail, zoneLeft, lateRail)
            line.set_xy2(lateTimingRail, zoneRight, lateRail)
            line.set_color(lateTimingRail, color.new(neutralColor, 0))
            line.set_width(lateTimingRail, 2)

        if na(invalidationTag)
            invalidationTag := label.new(zoneRight, invalidation, "INVALIDATION | " + str.tostring(invalidation, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 8), textcolor = f_text_on(bearColor), size = f_size(labelFontSize))
        else
            label.set_xy(invalidationTag, zoneRight, invalidation)
            label.set_text(invalidationTag, "INVALIDATION | " + str.tostring(invalidation, format.mintick))
            label.set_color(invalidationTag, color.new(bearColor, 8))
            label.set_textcolor(invalidationTag, f_text_on(bearColor))
            label.set_size(invalidationTag, f_size(labelFontSize))

        float scoreY = isLongTiming ? windowTop + safeAtr * 0.55 : windowBottom - safeAtr * 0.55
        if showScoreTag and na(scoreTag)
            scoreTag := label.new(zoneRight + 3, scoreY, scoreText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(stateColor, 8), textcolor = f_text_on(stateColor), size = f_size(labelFontSize))
        else if showScoreTag
            label.set_xy(scoreTag, zoneRight + 3, scoreY)
            label.set_text(scoreTag, scoreText)
            label.set_color(scoreTag, color.new(stateColor, 8))
            label.set_textcolor(scoreTag, f_text_on(stateColor))
            label.set_size(scoreTag, f_size(labelFontSize))
        else if not na(scoreTag)
            label.delete(scoreTag)
            scoreTag := na

        if showClockMarker
            string clockText = "TIMING LIMIT " + str.tostring(lateRail, format.mintick) + " | " + momentumPhase
            float clockY = isLongTiming ? lateRail + safeAtr * 0.72 : lateRail - safeAtr * 0.72
            if na(clockTag)
                clockTag := label.new(zoneRight + 2, clockY, clockText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(neutralColor, 10), textcolor = f_text_on(neutralColor), size = f_size(labelFontSize))
            else
                label.set_xy(clockTag, zoneRight + 2, clockY)
                label.set_text(clockTag, clockText)
                label.set_color(clockTag, color.new(neutralColor, 10))
                label.set_textcolor(clockTag, f_text_on(neutralColor))
                label.set_size(clockTag, f_size(labelFontSize))
        else if not na(clockTag)
            label.delete(clockTag)
            clockTag := na
    else
        if not na(timingWindowBox)
            box.delete(timingWindowBox)
            timingWindowBox := na
        if not na(targetRoomBox)
            box.delete(targetRoomBox)
            targetRoomBox := na
        if not na(timingWindowBadge)
            label.delete(timingWindowBadge)
            timingWindowBadge := na
        if not na(targetRoomBadge)
            label.delete(targetRoomBadge)
            targetRoomBadge := na
        if not na(invalidationRail)
            line.delete(invalidationRail)
            invalidationRail := na
        if not na(lateTimingRail)
            line.delete(lateTimingRail)
            lateTimingRail := na
        if not na(invalidationTag)
            label.delete(invalidationTag)
            invalidationTag := na
        if not na(clockTag)
            label.delete(clockTag)
            clockTag := na
        if not na(scoreTag)
            label.delete(scoreTag)
            scoreTag := na

var array<label> timingLabels = array.new<label>()
var int lastLabelBar = na
var int labelSlotCounter = 0
var string lastVisualState = ""
var float lastVisualScore = na
var int lastVisualBias = 0

bool majorTimingEvent = primeStateEvent or lateStateEvent or invalidStateEvent
bool regularLabelDue = windowState != "EXHAUSTED" and windowState != "INVALIDATED" and (na(lastLabelBar) or bar_index - lastLabelBar >= cooldownBars)
bool sameVisualContext = windowState == lastVisualState and setupBias == lastVisualBias
bool scoreMovedEnough = na(lastVisualScore) or math.abs(timingScore - lastVisualScore) >= 9.0
bool sameStateSpacedEnough = na(lastLabelBar) or bar_index - lastLabelBar >= cooldownBars * 3
bool smartLabelAllowed = not sameVisualContext or scoreMovedEnough or sameStateSpacedEnough

if showLabels and barstate.isconfirmed and (majorTimingEvent or regularLabelDue) and smartLabelAllowed
    int labelLane = labelSlotCounter % 4
    bool clusteredLabel = not na(lastLabelBar) and bar_index - lastLabelBar <= math.max(4, int(math.round(cooldownBars * 0.60)))
    float clusterBoost = clusteredLabel ? 0.30 : 0.0
    float laneOffset = labelOffsetAtr + labelLane * labelLaneSpreadAtr + clusterBoost
    int labelXShift = labelShiftBars == 0 ? 0 : labelLane == 0 ? -labelShiftBars * 2 : labelLane == 1 ? -labelShiftBars : labelLane == 2 ? labelShiftBars : labelShiftBars * 2
    int labelX = math.max(bar_index + labelXShift, 0)
    float labelClearTop = labelClearTopSeries
    float labelClearBottom = labelClearBottomSeries
    float labelY = isLongTiming ? labelClearBottom - safeAtr * laneOffset : labelClearTop + safeAtr * laneOffset
    string eventSide = isLongTiming ? "LONG" : "SHORT"
    string labelText = labelDetail == "Full" ? eventSide + " " + windowState + " | Q " + f_score_text(timingScore) + "\n" + momentumPhase + "\nRisk " + riskText + " | Room " + targetText : eventSide + " " + windowState + " | Q " + f_score_text(timingScore) + "\nRisk " + riskText
    label newLabel = label.new(labelX, labelY, labelText, xloc = xloc.bar_index, yloc = yloc.price, style = isLongTiming ? label.style_label_up : label.style_label_down, color = color.new(stateColor, 6), textcolor = f_text_on(stateColor), size = f_size(labelFontSize))
    array.push(timingLabels, newLabel)
    labelSlotCounter += 1
    lastLabelBar := bar_index
    lastVisualState := windowState
    lastVisualScore := timingScore
    lastVisualBias := setupBias
    while array.size(timingLabels) > maxVisibleLabels
        label oldLabel = array.shift(timingLabels)
        label.delete(oldLabel)

var table infoPanel = table.new(f_panel_pos(panelLocation), 2, 7, bgcolor = f_panel_bg(), border_width = 1, border_color = f_panel_border(), frame_width = 1, frame_color = f_panel_border())

if barstate.islast
    table.set_position(infoPanel, f_panel_pos(panelLocation))
    table.clear(infoPanel, 0, 0, 1, 6)
    if showPanel
        panelSize = f_size(panelFontSize)
        table.cell(infoPanel, 0, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.cell(infoPanel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        table.cell(infoPanel, 0, 0, "AG Pro Entry Timing Quality", text_color = headerText, bgcolor = headerBg, text_size = panelSize, text_halign = text.align_center)
        table.cell(infoPanel, 0, 1, "Timing Score", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(infoPanel, 1, 1, f_score_text(timingScore) + "/100", text_color = stateColor, bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(infoPanel, 0, 2, "Window State", text_color = f_panel_label(), bgcolor = f_panel_alt_bg(), text_size = panelSize)
        table.cell(infoPanel, 1, 2, windowState + " | " + timingText, text_color = stateColor, bgcolor = f_panel_alt_bg(), text_size = panelSize)
        table.cell(infoPanel, 0, 3, "Momentum Phase", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(infoPanel, 1, 3, momentumPhase + " | RSI " + f_value_text(rsiValue), text_color = f_panel_value(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(infoPanel, 0, 4, "Risk Distance", text_color = f_panel_label(), bgcolor = f_panel_alt_bg(), text_size = panelSize)
        table.cell(infoPanel, 1, 4, riskText + " | Room " + targetText, text_color = f_panel_value(), bgcolor = f_panel_alt_bg(), text_size = panelSize)
        table.cell(infoPanel, 0, 5, "Prime Hit Rate", text_color = f_panel_label(), bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(infoPanel, 1, 5, primeHitRateText, text_color = primeHitRateColor, bgcolor = f_panel_bg(), text_size = panelSize)
        table.cell(infoPanel, 0, 6, "Action", text_color = f_panel_label(), bgcolor = f_panel_alt_bg(), text_size = panelSize)
        table.cell(infoPanel, 1, 6, nextAction, text_color = stateColor, bgcolor = f_panel_alt_bg(), text_size = panelSize)

previousState := windowState
````
