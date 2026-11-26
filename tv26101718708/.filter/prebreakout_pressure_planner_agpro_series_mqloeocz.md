# Pre-Breakout Pressure Planner [AGPro Series]

- url: https://www.tradingview.com/script/MqLOeoCZ-Pre-Breakout-Pressure-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;ad96fe4c163946e6a285655f35c58d8b
- version: 4.0

## Description

Pre-Breakout Pressure Planner [AGPro Series]


🧠 Core Idea

Is pressure building before a breakout, or is the setup still premature?


📌 Overview / What it does

Pre-Breakout Pressure Planner [AGPro Series] is a chart-first breakout readiness tool designed to evaluate pressure before price leaves a range.

The script maps an active pressure box, upper and lower trigger corridors, directional buildup side, volume support, fakeout-risk context, invalidation reference, and target-room projection. These factors are converted into a 0-100 Pressure Score with a clear next-action state such as Bull Pressure, Bear Pressure, Coil Watch, Premature, Fakeout Risk, or Trigger Review.

It does not predict breakouts, automate entries, or confirm post-breakout acceptance. It is built to help traders organize the pre-breakout decision process before reacting to price movement.


🎯 Purpose & Design Philosophy

This script was built for traders who want to evaluate whether a breakout setup is becoming valid before the breakout actually happens.

Many traders notice a range only after price has already moved. This tool focuses on the earlier planning phase: Is the range compressed? Is one side applying pressure? Is volume supportive? Is the candle behavior constructive? Is there fakeout risk near the boundary?

The design supports a planning mindset. It helps the user read pressure quality, risk location, target room, and next-action context without turning the chart into a generic signal board.


⚡ Why This Script Is Different

Most breakout tools focus on the moment price breaks a level.

This script does NOT focus on post-breakout confirmation, measured move corridors, generic support/resistance boxes, or simple buy/sell labels.

Instead, it evaluates the setup before the break. The core question is whether pressure is building in a structured way or whether the range is still too early, too wide, too weak, or vulnerable to a fakeout.

This keeps the concept separate from consolidation breakout tools. The purpose is not to grade a completed breakout. The purpose is to organize the pre-breakout readiness window.


⚙️ Methodology

1. Context Detection
The script builds a live pressure range from prior bars and evaluates whether price remains inside the active box, probes a boundary, or enters a trigger corridor.

2. Reference Mapping
It maps the pressure box, upper trigger corridor, lower trigger corridor, active-side invalidation reference, and projected target-room reference.

3. Reaction Evaluation
The model scores range compression, higher-lows or lower-highs buildup, relative volume behavior, candle pressure, and close location inside the box.

4. Visual Output
The script displays the active pressure box, centered status label, trigger corridors, optional risk/target guides, compact event labels, alerts, and a premium AGPro panel.


🗺️ How to Read the Chart

Pressure Box = the active range where pre-breakout pressure is being evaluated.

Trigger Corridors = narrow upper and lower zones where breakout review becomes relevant.

Risk / Target Guides = active-side invalidation and target-room references used for planning context.

Labels = compact state markers showing pressure, watch, fakeout risk, or trigger-review context.

Colors = teal supports bullish buildup, pink supports bearish buildup, amber marks neutral or developing pressure, and red marks elevated fakeout risk.

Panel = summarizes Pressure Score, Buildup Side, Volume Support, Fakeout Risk, Risk / Target, and Action.


🚦 Signals & States

• Bull Pressure → bullish buildup is forming inside the pressure box near the upper trigger context.

• Bear Pressure → bearish buildup is forming inside the pressure box near the lower trigger context.

• Coil Watch → compression or pressure exists, but the directional side is not clear enough yet.

• Premature → the setup does not yet meet the pressure score or structural requirements.

• Fakeout Risk → a boundary probe appears with weak support, poor candle pressure, or elevated rejection risk.

• Trigger Review → price has entered or crossed a trigger corridor and deserves context review.


🔔 Alerts Logic

Alerts can trigger when bullish pressure appears, bearish pressure appears, fakeout risk appears, or price enters trigger-review context.

Each alert is an attention marker. Alerts are not trade instructions, entry commands, exit commands, or automated strategy rules.


🧩 Confluence Logic

The strongest pressure read appears when multiple conditions align:

Range compression + directional buildup + supportive relative volume + constructive candle pressure + close location near the active trigger side.

When these conditions weaken, the planner can shift toward Coil Watch, Premature, or Fakeout Risk.


📊 When to Use

• Before evaluating a potential range breakout.

• During tight ranges where pressure may be building on one side.

• Around breakout watchlists where fakeout risk needs context.

• During volatility compression before expansion attempts.

• On liquid symbols where ATR, range boundaries, and relative volume are meaningful.


⚠️ When NOT to Use

• Extremely low-liquidity symbols with unreliable candles or volume.

• Very noisy micro-timeframes where range boundaries change too often.

• News-driven volatility spikes where pre-breakout pressure can distort quickly.

• Markets where the recent range is too wide to represent meaningful compression.

• As a standalone reason to enter or exit a trade.


🎛️ Key Inputs

• Pressure Range Lookback → controls the prior range used to build the active pressure box.

• Buildup Slope Lookback → controls how the script measures rising lows or falling highs.

• Sensitivity → changes how strict the compression model is.

• Minimum Pressure Score → sets the score needed for Bull Pressure or Bear Pressure states.

• Volume Support Level → defines constructive relative volume before breakout.

• Trigger Corridor ATR Width → controls the size of the upper and lower trigger corridors.

• Invalidation Buffer ATR → controls the active-side invalidation reference.

• Target Room Multiple → projects target-room context from the pressure range height.

• Visual settings → control boxes, guides, labels, panel visibility, panel location, theme, and font sizes.


🖥️ Interface & Visual Design

The interface is designed to be chart-first.

The main visual object is the active pressure box with a centered status label. Trigger corridors are narrow and controlled so the chart does not become a generic zone map. Event labels are compact, offset away from candles, and limited by cooldown and maximum-visible settings.

The AGPro panel follows the standard publication layout with a single merged blue title row, adjustable panel location, adjustable theme, and adjustable font size.


🧪 Practical Usage Workflow

1. Read the panel Pressure Score and Action.

2. Check whether the pressure box is tight or still too wide.

3. Review the Buildup Side and Volume Support rows.

4. Check whether Fakeout Risk is Low, Moderate, or Elevated.

5. Compare the active trigger corridor with invalidation and target-room context.

6. Treat labels and alerts as attention markers inside broader analysis.


🔍 Interpretation Guidelines

A high Pressure Score means the pre-breakout setup is more organized according to the script's rule set. It does not mean price must break out.

Bull Pressure and Bear Pressure describe directional buildup, not guaranteed direction.

Fakeout Risk means the boundary behavior deserves caution and context review. It does not mean a breakout cannot continue later.

Trigger Review means price is interacting with a corridor. It is a review state, not a command.


🚫 What This Script Is NOT

• Not a prediction engine.

• Not financial advice.

• Not auto trading.

• Not guaranteed signals.

• Not a buy/sell signal service.

• Not a post-breakout confirmation engine.

• Not a generic support/resistance zone map.

• Not an order-block, FVG, or supply/demand scanner.


⚠️ Limitations & Transparency

The script depends on selected lookback values, ATR normalization, relative volume behavior, and current timeframe.

Different symbols may compress differently. Some markets can show pressure for a long time before expansion. Others may probe a boundary and return inside the range several times.

The model is rule-based. Outputs should always be interpreted with broader structure, volatility, liquidity, and trader-defined risk controls.


🧠 Market Context Notes

Pre-breakout pressure is useful because the quality of a range can change before the breakout candle appears.

Rising lows can show pressure toward the upper boundary. Falling highs can show pressure toward the lower boundary. Volume support and candle pressure help judge whether that buildup is constructive or weak.

The script organizes these factors into a clean planner view so the user can decide whether the setup deserves attention, patience, or caution.


🧾 Use Case Examples

When price remains inside a tight range and the panel shifts to Bull Pressure with supported volume, the upper trigger corridor becomes the main review area.

When price presses into a boundary but the panel shows Elevated Fakeout Risk, the user can recognize that the probe may be weak or vulnerable to rejection.

When the score stays low and the state remains Premature, the range may need more time before it deserves attention.


🧱 System Philosophy

Pre-Breakout Pressure Planner follows the AGPro decision-engine approach: a script should help traders evaluate setup quality, risk, target room, and next action without promising an outcome.

The goal is not to add another signal. The goal is to improve the quality of the planning process before the chart forces a decision.


🔐 Non-Promise Statement

No script can guarantee direction, continuation, breakout success, or outcome.

This tool provides structured pre-breakout context only.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk controls, position sizing, and trading decisions.

This script does not provide financial advice, investment advice, or guaranteed trading outcomes.


📚 Educational Note

Use the script to study how pressure builds inside ranges before breakout attempts.

The strongest learning value comes from comparing the panel state, pressure box, trigger corridors, and fakeout-risk labels with the broader chart context.

## Source Code

````pine
// -------------------------------------------------
// Pre-Breakout Pressure Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Pre-Breakout Pressure Planner evaluates range compression, directional
// buildup, relative volume support, candle pressure, close location, trigger
// corridor quality, invalidation, target room, and fakeout risk before a
// breakout occurs. It is built as a pre-breakout planning engine, not as a
// post-breakout confirmation script or generic breakout signal tool.
// -------------------------------------------------

//@version=6
indicator("Pre-Breakout Pressure Planner [AGPro Series]",
     shorttitle = "AG Pro PBP",
     overlay = true,
     max_boxes_count = 90,
     max_labels_count = 180,
     max_lines_count = 90)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
color headerBg      = color.rgb(37, 99, 235)      // #2563EB
color headerText    = color.rgb(245, 247, 250)    // #F5F7FA
color panelBg       = color.rgb(15, 23, 42)       // #0F172A
color panelBorder   = color.rgb(51, 65, 85)       // #334155
color panelLabelCol = color.rgb(148, 163, 184)    // #94A3B8
color panelValueCol = color.rgb(226, 232, 240)    // #E2E8F0
color bullColor     = color.rgb(34, 197, 166)     // #22C5A6
color bearColor     = color.rgb(244, 114, 182)    // #F472B6
color neutralColor  = color.rgb(245, 189, 92)     // #F5BD5C
color accentColor   = color.rgb(129, 140, 248)    // #818CF8
color dangerColor   = color.rgb(239, 68, 68)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
string groupEngine = "Pressure Engine"
int pressureLookback = input.int(34, "Pressure Range Lookback", minval = 12, maxval = 180, group = groupEngine, tooltip = "Defines the prior range used to evaluate pre-breakout pressure. The range is built from previous bars so the current bar can be tested against the active pressure box.")
int slopeLookback = input.int(16, "Buildup Slope Lookback", minval = 6, maxval = 80, group = groupEngine, tooltip = "Measures whether lows are rising into the upper trigger or highs are falling into the lower trigger. This is the main directional buildup component.")
int atrLength = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = "ATR period used to normalize compression, trigger corridor width, label spacing, invalidation buffer, and fakeout tolerance.")
int volumeLength = input.int(20, "Volume Baseline Length", minval = 5, maxval = 150, group = groupEngine, tooltip = "Moving average length used to evaluate whether pre-breakout volume is supportive, light, or rising into the pressure area.")
string sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Aggressive"], group = groupEngine, tooltip = "Controls how selective the pressure model is. Conservative requires tighter compression, while Aggressive allows wider developing ranges.")
string confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = "Close Confirmed prints labels and alerts only after bar close. Live Updating allows the planner to update during the active bar.")

string groupQuality = "Readiness Model"
int minPressureScore = input.int(68, "Minimum Pressure Score", minval = 40, maxval = 95, group = groupQuality, tooltip = "Minimum 0-100 score required before the planner marks bullish or bearish pressure as actionable review context.")
int minWatchScore = input.int(54, "Minimum Watch Score", minval = 30, maxval = 90, group = groupQuality, tooltip = "Minimum 0-100 score required for a developing coil or early pressure watch state.")
float rvolSupportLevel = input.float(1.05, "Volume Support Level", minval = 0.60, maxval = 3.00, step = 0.05, group = groupQuality, tooltip = "Relative volume level used to classify volume as supportive during pre-breakout pressure. This is not a breakout spike requirement.")
float triggerBufferAtr = input.float(0.12, "Trigger Corridor ATR Width", minval = 0.02, maxval = 1.00, step = 0.01, group = groupQuality, tooltip = "ATR-based width added beyond the pressure range boundary to create the upper and lower trigger corridors.")
float invalidationBufferAtr = input.float(0.18, "Invalidation Buffer ATR", minval = 0.00, maxval = 1.50, step = 0.01, group = groupQuality, tooltip = "ATR-based buffer placed beyond the opposite side of the pressure range to estimate invalidation context.")
float targetMultiple = input.float(1.00, "Target Room Multiple", minval = 0.25, maxval = 3.00, step = 0.05, group = groupQuality, tooltip = "Projects target-room context from the pressure range height. The projection is a planning reference, not a price forecast.")
int followProofWindow = input.int(12, "Follow-Through Proof Window", minval = 3, maxval = 80, group = groupQuality, tooltip = "After bullish or bearish pressure is flagged, the planner waits this many bars (or until invalidation) and checks whether price followed through in the buildup direction. Feeds the self-measured Follow-Through rate.")

string groupVisual = "Visual Settings"
bool showPressureBox = input.bool(true, "Show Pressure Box", group = groupVisual, tooltip = "Displays the active pre-breakout pressure box with a centered status label.")
bool showTriggerCorridor = input.bool(true, "Show Trigger Corridor", group = groupVisual, tooltip = "Displays narrow upper and lower corridors around the pressure range where breakout review becomes relevant.")
bool showCorridorLabels = input.bool(true, "Show Centered Corridor Labels", group = groupVisual, tooltip = "Places centered labels inside the upper and lower trigger corridors so the active review zones remain readable.")
bool showPlanningGuides = input.bool(true, "Show Risk / Target Guides", group = groupVisual, tooltip = "Displays active-side trigger, invalidation, and target-room guide lines when a clear buildup side exists.")
bool showFakeoutMarker = input.bool(true, "Show Fakeout Risk Marker", group = groupVisual, tooltip = "Displays a current-bar fakeout-risk marker when a boundary probe has weak support or poor candle pressure.")
bool showLabels = input.bool(true, "Show Event Labels", group = groupVisual, tooltip = "Displays compact pressure, watch, trigger-review, and fakeout-risk labels with controlled spacing.")
bool showEarlyLabels = input.bool(false, "Show Early / Premature Labels", group = groupVisual, tooltip = "When enabled, the script may print early-development labels. Disabled by default to keep publication screenshots cleaner.")
string labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupVisual, tooltip = "Compact labels keep the publication chart clean. Detailed labels show extra pressure context directly on the chart.")
int minHistoricalLabelScore = input.int(58, "Minimum Historical Label Score", minval = 30, maxval = 95, group = groupVisual, tooltip = "Filters low-information historical event badges while leaving the active pressure map and panel visible.")
int labelCooldown = input.int(26, "Label Cooldown Bars", minval = 3, maxval = 80, group = groupVisual, tooltip = "Minimum spacing between recurring event labels. The longer default prevents nearby WATCH and REVIEW badges from clustering.")
int maxVisibleLabels = input.int(4, "Max Visible Labels", minval = 4, maxval = 30, group = groupVisual, tooltip = "Maximum number of recent historical event badges retained on the chart.")
int forwardBars = input.int(28, "Forward Render Bars", minval = 8, maxval = 120, group = groupVisual, tooltip = "Controls how far the pressure box, trigger corridor, and guide lines extend to the right.")
float labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupVisual, tooltip = "Offsets labels away from candles with ATR so they remain readable above or below price.")
float labelStackAtr = input.float(0.55, "Label Stack Offset ATR", minval = 0.00, maxval = 2.00, step = 0.05, group = groupVisual, tooltip = "Adds extra spacing when two labels appear close together on the same side of price.")
string labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupVisual, tooltip = "Controls all chart label sizes, including pressure-box and corridor labels.")

string groupPanel = "Panel Settings"
bool showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = "Shows or hides the AG Pro information panel. The default is visible for publication-ready chart context.")
string panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = "Moves the AGPro summary panel to the preferred chart location.")
string panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = "Switches the panel between the premium dark AGPro theme and a light chart-friendly theme.")
string panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = "Controls panel text size. Normal is the default AGPro publication setting.")

string groupAlerts = "Alerts"
int alertScore = input.int(70, "Minimum Alert Score", minval = 40, maxval = 95, group = groupAlerts, tooltip = "Minimum pressure score required for bullish or bearish pressure alerts.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(_value, _min, _max) =>
    math.max(_min, math.min(_max, _value))

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299.0 + color.g(bg) * 587.0 + color.b(bg) * 114.0) / 1000.0
    bright >= 145.0 ? color.rgb(17, 24, 39) : headerText

f_text_size(_size) =>
    switch _size
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(_pos) =>
    switch _pos
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_fmt(_value) =>
    na(_value) ? "-" : str.tostring(_value, "#.##")

f_fmt_price(_value) =>
    na(_value) ? "-" : str.tostring(_value, format.mintick)

f_score_color(_score) =>
    color result = bearColor
    if _score >= 78
        result := bullColor
    else if _score >= minPressureScore
        result := accentColor
    else if _score >= minWatchScore
        result := neutralColor
    result

f_score_grade(_score) =>
    string result = "E"
    if _score >= 85
        result := "A+"
    else if _score >= 76
        result := "A"
    else if _score >= 66
        result := "B"
    else if _score >= 55
        result := "C"
    else if _score >= 42
        result := "D"
    result

f_panel_row(_panel, _row, _label, _value, _valueColor, _bg, _labelColor, _textSize) =>
    table.cell(_panel, 0, _row, _label, text_color = _labelColor, bgcolor = _bg, text_size = _textSize, text_halign = text.align_left)
    table.cell(_panel, 1, _row, _value, text_color = _valueColor, bgcolor = _bg, text_size = _textSize, text_halign = text.align_right)

// -------------------------------------------------
// Core Model
// -------------------------------------------------
bool confirmedBar = true
if confirmationMode == "Close Confirmed"
    confirmedBar := barstate.isconfirmed

float atrRaw = ta.atr(atrLength)
float atr = math.max(nz(atrRaw, ta.tr(true)), syminfo.mintick)

float upperRaw = ta.highest(high[1], pressureLookback)
float lowerRaw = ta.lowest(low[1], pressureLookback)
bool validRange = not na(upperRaw) and not na(lowerRaw) and upperRaw > lowerRaw
float upperRef = validRange ? upperRaw : high
float lowerRef = validRange ? lowerRaw : low
float rangeHeight = math.max(upperRef - lowerRef, syminfo.mintick)
float rangeMid = (upperRef + lowerRef) * 0.5
float rangeAtr = rangeHeight / atr
float closeLocation = f_clamp((close - lowerRef) / rangeHeight, 0.0, 1.0)

float compressionBadAtr = 2.35
if sensitivity == "Conservative"
    compressionBadAtr := 1.85
else if sensitivity == "Aggressive"
    compressionBadAtr := 2.85
float compressionScore = f_clamp(100.0 - ((rangeAtr - 0.55) / math.max(compressionBadAtr - 0.55, 0.10)) * 100.0, 0.0, 100.0)

float lowLineNow = ta.linreg(low, slopeLookback, 0)
float lowLinePrev = ta.linreg(low, slopeLookback, 1)
float highLineNow = ta.linreg(high, slopeLookback, 0)
float highLinePrev = ta.linreg(high, slopeLookback, 1)
float lowSlope = nz(lowLineNow - lowLinePrev, 0.0)
float highSlope = nz(highLineNow - highLinePrev, 0.0)
float bullSlopeScore = f_clamp(50.0 + (lowSlope / atr) * 650.0, 0.0, 100.0)
float bearSlopeScore = f_clamp(50.0 + (-highSlope / atr) * 650.0, 0.0, 100.0)

float barRange = math.max(high - low, syminfo.mintick)
float bodyEfficiency = math.abs(close - open) / barRange
float barCloseLocation = f_clamp((close - low) / barRange, 0.0, 1.0)
float bullCandleScore = close >= open ? bodyEfficiency * 70.0 + barCloseLocation * 30.0 : barCloseLocation * 35.0
float bearCandleScore = close <= open ? bodyEfficiency * 70.0 + (1.0 - barCloseLocation) * 30.0 : (1.0 - barCloseLocation) * 35.0
float bullCloseScore = closeLocation * 100.0
float bearCloseScore = (1.0 - closeLocation) * 100.0
float bullPressureRaw = bullSlopeScore * 0.42 + bullCloseScore * 0.38 + bullCandleScore * 0.20
float bearPressureRaw = bearSlopeScore * 0.42 + bearCloseScore * 0.38 + bearCandleScore * 0.20
float sideEdge = math.abs(bullPressureRaw - bearPressureRaw)
bool activeLong = bullPressureRaw >= bearPressureRaw
bool neutralSide = sideEdge < 8.0

string sideText = "Neutral Coil"
if not neutralSide and activeLong
    sideText := "Bullish Buildup"
else if not neutralSide and not activeLong
    sideText := "Bearish Buildup"

float directionalSideScore = math.max(bullPressureRaw, bearPressureRaw)
float directionalCloseScore = activeLong ? bullCloseScore : bearCloseScore
float directionalCandleScore = activeLong ? bullCandleScore : bearCandleScore

float volumeBase = nz(ta.sma(volume, volumeLength), volume)
float rvol = volumeBase > 0.0 ? volume / volumeBase : 1.0
float rvolSlope = rvol - nz(rvol[5], rvol)
float rvolLevelScore = f_clamp((rvol - 0.70) / math.max(rvolSupportLevel - 0.70, 0.10) * 70.0, 0.0, 85.0)
float rvolSlopeScore = f_clamp(rvolSlope * 120.0, -25.0, 25.0)
float volumeScore = f_clamp(rvolLevelScore + rvolSlopeScore + 15.0, 0.0, 100.0)
bool volumeSupported = rvol >= rvolSupportLevel or (rvol > 0.90 and rvolSlope > 0.05)

float pressureScore = f_clamp(compressionScore * 0.30 + directionalSideScore * 0.28 + volumeScore * 0.18 + directionalCandleScore * 0.12 + directionalCloseScore * 0.12, 0.0, 100.0)
float triggerWidth = atr * triggerBufferAtr
float invalidationBuffer = atr * invalidationBufferAtr
float activeTrigger = activeLong ? upperRef + triggerWidth : lowerRef - triggerWidth
float activeInvalidation = activeLong ? lowerRef - invalidationBuffer : upperRef + invalidationBuffer
float activeTarget = activeLong ? upperRef + rangeHeight * targetMultiple : lowerRef - rangeHeight * targetMultiple

bool insideRange = close <= upperRef and close >= lowerRef
bool upperProbe = validRange and high > upperRef + triggerWidth and close <= upperRef
bool lowerProbe = validRange and low < lowerRef - triggerWidth and close >= lowerRef
bool upperTriggerReview = validRange and close > upperRef + triggerWidth
bool lowerTriggerReview = validRange and close < lowerRef - triggerWidth
float fakeoutRiskScore = f_clamp((100.0 - directionalCandleScore) * 0.42 + (100.0 - volumeScore) * 0.34 + (rangeAtr > compressionBadAtr ? 14.0 : 0.0) + ((upperProbe or lowerProbe) ? 20.0 : 0.0), 0.0, 100.0)
bool fakeoutRisk = (upperProbe or lowerProbe) and fakeoutRiskScore >= 58.0
bool bullPressure = validRange and insideRange and not fakeoutRisk and not neutralSide and activeLong and pressureScore >= minPressureScore
bool bearPressure = validRange and insideRange and not fakeoutRisk and not neutralSide and not activeLong and pressureScore >= minPressureScore
bool coilWatch = validRange and insideRange and not fakeoutRisk and pressureScore >= minWatchScore and not bullPressure and not bearPressure
bool triggerReview = upperTriggerReview or lowerTriggerReview

string stateText = "Building"
if not validRange
    stateText := "Building"
else if fakeoutRisk
    stateText := "Fakeout Risk"
else if triggerReview and pressureScore >= minWatchScore
    stateText := upperTriggerReview ? "Upper Trigger Review" : "Lower Trigger Review"
else if bullPressure
    stateText := "Bull Pressure"
else if bearPressure
    stateText := "Bear Pressure"
else if coilWatch
    stateText := "Coil Watch"
else
    stateText := "Premature"

string actionText = "Let range develop"
if stateText == "Fakeout Risk"
    actionText := "Check rejection risk"
else if stateText == "Upper Trigger Review"
    actionText := "Review upper trigger"
else if stateText == "Lower Trigger Review"
    actionText := "Review lower trigger"
else if stateText == "Bull Pressure"
    actionText := "Review upper corridor"
else if stateText == "Bear Pressure"
    actionText := "Review lower corridor"
else if stateText == "Coil Watch"
    actionText := "Wait for side clarity"
else if stateText == "Premature"
    actionText := "Wait for pressure"

string volumeText = volumeSupported ? "Supported " + f_fmt(rvol) + "x" : "Light " + f_fmt(rvol) + "x"
string fakeoutText = "Low"
if fakeoutRisk
    fakeoutText := "Elevated"
else if fakeoutRiskScore >= 62.0
    fakeoutText := "Moderate"

string triggerText = neutralSide ? "Both corridors" : activeLong ? "Upper corridor" : "Lower corridor"
string riskTargetText = neutralSide and insideRange ? "Side pending" : "Inv " + f_fmt_price(activeInvalidation) + " / Tgt " + f_fmt_price(activeTarget)
color activeColor = bearColor
if fakeoutRisk
    activeColor := dangerColor
else if neutralSide
    activeColor := neutralColor
else if activeLong
    activeColor := bullColor

// -------------------------------------------------
// Follow-Through Rate (Proof Pass)
// -------------------------------------------------
// When bullish or bearish pressure is flagged, the buildup direction is armed
// with the active invalidation as a reference. The setup resolves as a miss if
// price closes through the invalidation first, or as a hit when the move has
// followed through in the buildup direction after the proof window. Timeouts are
// not counted as losses. This is a transparent, self-measured directional
// follow-through statistic for the pre-breakout lean, not a breakout guarantee.
var int pfHits = 0
var int pfTotal = 0
var bool pfPending = false
var int pfStart = na
var int pfDir = 0
var float pfEntry = na
var float pfInval = na

bool bullRise = bullPressure and not (bullPressure[1] == true)
bool bearRise = bearPressure and not (bearPressure[1] == true)

if barstate.isconfirmed
    if (bullRise or bearRise) and not pfPending
        pfPending := true
        pfStart := bar_index
        pfDir := bullRise ? 1 : -1
        pfEntry := close
        pfInval := activeInvalidation
    if pfPending and not na(pfStart) and bar_index > pfStart
        bool pfStop = pfDir == 1 ? close < pfInval : close > pfInval
        if pfStop
            pfTotal += 1
            pfPending := false
        else if bar_index - pfStart >= followProofWindow
            bool pfFollowed = pfDir == 1 ? close > pfEntry : close < pfEntry
            pfTotal += 1
            if pfFollowed
                pfHits += 1
            pfPending := false

float pfRate = pfTotal > 0 ? pfHits / pfTotal * 100.0 : na
string followRateText = pfTotal > 0 ? str.tostring(int(math.round(pfRate))) + "% (" + str.tostring(pfHits) + "/" + str.tostring(pfTotal) + ")" : "Building"
color followRateColor = pfTotal == 0 ? neutralColor : pfRate >= 60.0 ? bullColor : pfRate >= 45.0 ? neutralColor : bearColor

// -------------------------------------------------
// Chart Objects
// -------------------------------------------------
int leftX = bar_index + 1
int rightX = bar_index + forwardBars
int centerX = int(math.round((leftX + rightX) * 0.5))
string scoreText = str.tostring(math.round(pressureScore)) + "/100"
string boxLabelText = "PRESSURE " + str.tostring(math.round(pressureScore)) + "\n" + sideText + "\n" + stateText

var box pressureBox = na
var box upperCorridorBox = na
var box lowerCorridorBox = na
var label pressureBoxLabel = na
var label upperCorridorLabel = na
var label lowerCorridorLabel = na
var label fakeoutMarker = na
var line triggerLine = na
var line invalidationLine = na
var line targetLine = na
var label invalidationTag = na
var label targetTag = na
var line invalidationConnector = na
var line targetConnector = na

if showPressureBox and validRange
    if na(pressureBox)
        pressureBox := box.new(leftX, upperRef, rightX, lowerRef, xloc = xloc.bar_index, border_color = color.new(activeColor, 15), bgcolor = color.new(activeColor, 91), border_width = 1)
    else
        box.set_left(pressureBox, leftX)
        box.set_right(pressureBox, rightX)
        box.set_top(pressureBox, upperRef)
        box.set_bottom(pressureBox, lowerRef)
        box.set_border_color(pressureBox, color.new(activeColor, 15))
        box.set_bgcolor(pressureBox, color.new(activeColor, 91))
    if na(pressureBoxLabel)
        pressureBoxLabel := label.new(centerX, rangeMid, boxLabelText, xloc = xloc.bar_index, style = label.style_label_center, color = color.new(activeColor, 16), textcolor = f_text_on(activeColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(pressureBoxLabel, centerX, rangeMid)
        label.set_text(pressureBoxLabel, boxLabelText)
        label.set_color(pressureBoxLabel, color.new(activeColor, 16))
        label.set_textcolor(pressureBoxLabel, f_text_on(activeColor))
        label.set_size(pressureBoxLabel, f_text_size(labelFontSize))
        label.set_textalign(pressureBoxLabel, text.align_center)
else
    if not na(pressureBox)
        box.delete(pressureBox)
        pressureBox := na
    if not na(pressureBoxLabel)
        label.delete(pressureBoxLabel)
        pressureBoxLabel := na

if showTriggerCorridor and validRange
    if na(upperCorridorBox)
        upperCorridorBox := box.new(leftX, upperRef + triggerWidth, rightX, upperRef, xloc = xloc.bar_index, border_color = color.new(bullColor, 60), bgcolor = color.new(bullColor, 87), border_width = 1)
    else
        box.set_left(upperCorridorBox, leftX)
        box.set_right(upperCorridorBox, rightX)
        box.set_top(upperCorridorBox, upperRef + triggerWidth)
        box.set_bottom(upperCorridorBox, upperRef)
        box.set_border_color(upperCorridorBox, color.new(bullColor, 60))
        box.set_bgcolor(upperCorridorBox, color.new(bullColor, 87))
    if na(lowerCorridorBox)
        lowerCorridorBox := box.new(leftX, lowerRef, rightX, lowerRef - triggerWidth, xloc = xloc.bar_index, border_color = color.new(bearColor, 60), bgcolor = color.new(bearColor, 87), border_width = 1)
    else
        box.set_left(lowerCorridorBox, leftX)
        box.set_right(lowerCorridorBox, rightX)
        box.set_top(lowerCorridorBox, lowerRef)
        box.set_bottom(lowerCorridorBox, lowerRef - triggerWidth)
        box.set_border_color(lowerCorridorBox, color.new(bearColor, 60))
        box.set_bgcolor(lowerCorridorBox, color.new(bearColor, 87))
else
    if not na(upperCorridorBox)
        box.delete(upperCorridorBox)
        upperCorridorBox := na
    if not na(lowerCorridorBox)
        box.delete(lowerCorridorBox)
        lowerCorridorBox := na

if showTriggerCorridor and showCorridorLabels and validRange
    float upperCorridorMid = upperRef + triggerWidth * 0.5
    float lowerCorridorMid = lowerRef - triggerWidth * 0.5
    if na(upperCorridorLabel)
        upperCorridorLabel := label.new(centerX - 3, upperCorridorMid, "UPPER TRIGGER", xloc = xloc.bar_index, style = label.style_label_center, color = color.new(bullColor, 20), textcolor = f_text_on(bullColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(upperCorridorLabel, centerX - 3, upperCorridorMid)
        label.set_text(upperCorridorLabel, "UPPER TRIGGER")
        label.set_color(upperCorridorLabel, color.new(bullColor, 20))
        label.set_textcolor(upperCorridorLabel, f_text_on(bullColor))
        label.set_size(upperCorridorLabel, f_text_size(labelFontSize))
        label.set_textalign(upperCorridorLabel, text.align_center)
    if na(lowerCorridorLabel)
        lowerCorridorLabel := label.new(centerX + 3, lowerCorridorMid, "LOWER TRIGGER", xloc = xloc.bar_index, style = label.style_label_center, color = color.new(bearColor, 20), textcolor = f_text_on(bearColor), size = f_text_size(labelFontSize), textalign = text.align_center)
    else
        label.set_xy(lowerCorridorLabel, centerX + 3, lowerCorridorMid)
        label.set_text(lowerCorridorLabel, "LOWER TRIGGER")
        label.set_color(lowerCorridorLabel, color.new(bearColor, 20))
        label.set_textcolor(lowerCorridorLabel, f_text_on(bearColor))
        label.set_size(lowerCorridorLabel, f_text_size(labelFontSize))
        label.set_textalign(lowerCorridorLabel, text.align_center)
else
    if not na(upperCorridorLabel)
        label.delete(upperCorridorLabel)
        upperCorridorLabel := na
    if not na(lowerCorridorLabel)
        label.delete(lowerCorridorLabel)
        lowerCorridorLabel := na

bool showActiveGuides = showPlanningGuides and validRange and not neutralSide
if showActiveGuides
    if na(triggerLine)
        triggerLine := line.new(leftX, activeTrigger, rightX, activeTrigger, xloc = xloc.bar_index, color = color.new(activeColor, 5), style = line.style_solid, width = 2)
    else
        line.set_xy1(triggerLine, leftX, activeTrigger)
        line.set_xy2(triggerLine, rightX, activeTrigger)
        line.set_color(triggerLine, color.new(activeColor, 5))
    if na(invalidationLine)
        invalidationLine := line.new(leftX, activeInvalidation, rightX, activeInvalidation, xloc = xloc.bar_index, color = color.new(dangerColor, 10), style = line.style_dashed, width = 1)
    else
        line.set_xy1(invalidationLine, leftX, activeInvalidation)
        line.set_xy2(invalidationLine, rightX, activeInvalidation)
        line.set_color(invalidationLine, color.new(dangerColor, 10))
    if na(targetLine)
        targetLine := line.new(leftX, activeTarget, rightX, activeTarget, xloc = xloc.bar_index, color = color.new(accentColor, 10), style = line.style_dotted, width = 1)
    else
        line.set_xy1(targetLine, leftX, activeTarget)
        line.set_xy2(targetLine, rightX, activeTarget)
        line.set_color(targetLine, color.new(accentColor, 10))
else
    if not na(triggerLine)
        line.delete(triggerLine)
        triggerLine := na
    if not na(invalidationLine)
        line.delete(invalidationLine)
        invalidationLine := na
    if not na(targetLine)
        line.delete(targetLine)
        targetLine := na

if showActiveGuides
    float guideFontMult = labelFontSize == "Large" ? 1.28 : labelFontSize == "Normal" ? 1.08 : labelFontSize == "Small" ? 0.90 : 0.76
    float guideGap = math.max(atr * 0.82 * guideFontMult, syminfo.mintick * 20.0)
    int guideTagX = rightX + 6
    int guideJoinX = guideTagX - 1
    float invalidTagY = activeLong ? math.min(activeInvalidation, activeTrigger - guideGap) : math.max(activeInvalidation, activeTrigger + guideGap)
    float targetTagY = activeLong ? math.max(activeTarget, activeTrigger + guideGap) : math.min(activeTarget, activeTrigger - guideGap)
    string invalidText = "INVALID | " + f_fmt_price(activeInvalidation)
    string targetText = "TARGET | " + f_fmt_price(activeTarget)
    if na(invalidationTag)
        invalidationTag := label.new(guideTagX, invalidTagY, invalidText, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(dangerColor, 0), textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize))
    else
        label.set_xy(invalidationTag, guideTagX, invalidTagY)
        label.set_text(invalidationTag, invalidText)
        label.set_color(invalidationTag, color.new(dangerColor, 0))
        label.set_textcolor(invalidationTag, f_text_on(dangerColor))
        label.set_size(invalidationTag, f_text_size(labelFontSize))
    if na(targetTag)
        targetTag := label.new(guideTagX, targetTagY, targetText, xloc = xloc.bar_index, style = label.style_label_left, color = color.new(accentColor, 0), textcolor = f_text_on(accentColor), size = f_text_size(labelFontSize))
    else
        label.set_xy(targetTag, guideTagX, targetTagY)
        label.set_text(targetTag, targetText)
        label.set_color(targetTag, color.new(accentColor, 0))
        label.set_textcolor(targetTag, f_text_on(accentColor))
        label.set_size(targetTag, f_text_size(labelFontSize))
    if na(invalidationConnector)
        invalidationConnector := line.new(rightX, activeInvalidation, guideJoinX, invalidTagY, xloc = xloc.bar_index, color = color.new(dangerColor, 6), width = 2)
    else
        line.set_xy1(invalidationConnector, rightX, activeInvalidation)
        line.set_xy2(invalidationConnector, guideJoinX, invalidTagY)
        line.set_color(invalidationConnector, color.new(dangerColor, 6))
    if na(targetConnector)
        targetConnector := line.new(rightX, activeTarget, guideJoinX, targetTagY, xloc = xloc.bar_index, color = color.new(accentColor, 6), width = 2)
    else
        line.set_xy1(targetConnector, rightX, activeTarget)
        line.set_xy2(targetConnector, guideJoinX, targetTagY)
        line.set_color(targetConnector, color.new(accentColor, 6))
else
    if not na(invalidationTag)
        label.delete(invalidationTag)
        invalidationTag := na
    if not na(targetTag)
        label.delete(targetTag)
        targetTag := na
    if not na(invalidationConnector)
        line.delete(invalidationConnector)
        invalidationConnector := na
    if not na(targetConnector)
        line.delete(targetConnector)
        targetConnector := na

if showFakeoutMarker and fakeoutRisk and validRange
    bool markerAbove = upperProbe
    float markerY = markerAbove ? high + atr * labelOffsetAtr * 0.70 : low - atr * labelOffsetAtr * 0.70
    markerStyle = markerAbove ? label.style_label_down : label.style_label_up
    if na(fakeoutMarker)
        fakeoutMarker := label.new(bar_index, markerY, "FAKEOUT\nRISK", xloc = xloc.bar_index, style = markerStyle, color = color.new(dangerColor, 4), textcolor = f_text_on(dangerColor), size = f_text_size(labelFontSize), textalign = text.align_center, tooltip = "Fakeout risk marker: boundary probe detected with weak support, poor candle pressure, or elevated rejection context.")
    else
        label.set_xy(fakeoutMarker, bar_index, markerY)
        label.set_text(fakeoutMarker, "FAKEOUT\nRISK")
        label.set_style(fakeoutMarker, markerStyle)
        label.set_color(fakeoutMarker, color.new(dangerColor, 4))
        label.set_textcolor(fakeoutMarker, f_text_on(dangerColor))
        label.set_size(fakeoutMarker, f_text_size(labelFontSize))
        label.set_textalign(fakeoutMarker, text.align_center)
        label.set_tooltip(fakeoutMarker, "Fakeout risk marker: boundary probe detected with weak support, poor candle pressure, or elevated rejection context.")
else
    if not na(fakeoutMarker)
        label.delete(fakeoutMarker)
        fakeoutMarker := na

// -------------------------------------------------
// Event Labels
// -------------------------------------------------
var array<label> eventLabels = array.new<label>()
var int lastLabelBar = na
var int lastUpperLabelBar = na
var int lastLowerLabelBar = na
bool labelReady = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldown
bool earlyLabelAllowed = showEarlyLabels and stateText == "Premature" and pressureScore >= minWatchScore
bool triggerLabelAllowed = triggerReview and pressureScore >= minWatchScore
bool importantLabelState = bullPressure or bearPressure or coilWatch or triggerLabelAllowed or fakeoutRisk or earlyLabelAllowed
bool shouldPrintLabel = showLabels and validRange and confirmedBar and labelReady and importantLabelState and pressureScore >= minHistoricalLabelScore

if shouldPrintLabel
    bool labelLong = upperTriggerReview or bullPressure or (not lowerTriggerReview and activeLong)
    float eventFontMult = labelFontSize == "Large" ? 1.28 : labelFontSize == "Normal" ? 1.08 : labelFontSize == "Small" ? 0.90 : 0.76
    float labelY = labelLong ? low - atr * labelOffsetAtr * eventFontMult : high + atr * labelOffsetAtr * eventFontMult
    bool stackLongLabel = labelLong and not na(lastLowerLabelBar) and bar_index - lastLowerLabelBar <= labelCooldown
    bool stackShortLabel = not labelLong and not na(lastUpperLabelBar) and bar_index - lastUpperLabelBar <= labelCooldown
    if stackLongLabel
        labelY -= atr * labelStackAtr * eventFontMult
    if stackShortLabel
        labelY += atr * labelStackAtr * eventFontMult
    string compactText = "WATCH | " + str.tostring(math.round(pressureScore))
    if stateText == "Bull Pressure"
        compactText := "BULL PRESSURE | " + str.tostring(math.round(pressureScore))
    else if stateText == "Bear Pressure"
        compactText := "BEAR PRESSURE | " + str.tostring(math.round(pressureScore))
    else if stateText == "Fakeout Risk"
        compactText := "FAKEOUT RISK"
    else if stateText == "Upper Trigger Review"
        compactText := "UPPER REVIEW"
    else if stateText == "Lower Trigger Review"
        compactText := "LOWER REVIEW"
    else if stateText == "Premature"
        compactText := "EARLY | " + str.tostring(math.round(pressureScore))
    string detailedText = stateText + "\nScore " + str.tostring(math.round(pressureScore)) + "\n" + sideText
    string labelText = labelTextMode == "Compact" ? compactText : detailedText
    string tooltipText = "Pre-Breakout Pressure Planner\nPressure Score: " + scoreText + "\nBuildup Side: " + sideText + "\nCompression Score: " + str.tostring(math.round(compressionScore)) + "\nVolume: " + volumeText + "\nFakeout Risk: " + fakeoutText + "\nAction: " + actionText
    label newLabel = label.new(bar_index, labelY, labelText, xloc = xloc.bar_index, style = labelLong ? label.style_label_up : label.style_label_down, color = color.new(activeColor, 8), textcolor = f_text_on(activeColor), size = f_text_size(labelFontSize), tooltip = tooltipText, textalign = text.align_center)
    array.push(eventLabels, newLabel)
    lastLabelBar := bar_index
    if labelLong
        lastLowerLabelBar := bar_index
    else
        lastUpperLabelBar := bar_index
    while array.size(eventLabels) > maxVisibleLabels
        label.delete(array.shift(eventLabels))

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table infoPanel = na
var string lastPanelLocation = ""
var string lastPanelTheme = ""

color panelBgActive = panelTheme == "Dark" ? panelBg : color.rgb(248, 250, 252)
color rowBgActive = panelTheme == "Dark" ? color.rgb(17, 24, 39) : color.rgb(241, 245, 249)
color panelLabelActive = panelTheme == "Dark" ? panelLabelCol : color.rgb(71, 85, 105)
color panelValueActive = panelTheme == "Dark" ? panelValueCol : color.rgb(15, 23, 42)
color panelBorderActive = panelTheme == "Dark" ? panelBorder : color.rgb(203, 213, 225)

if showPanel
    if na(infoPanel) or panelLocation != lastPanelLocation or panelTheme != lastPanelTheme
        if not na(infoPanel)
            table.delete(infoPanel)
        infoPanel := table.new(f_panel_pos(panelLocation), 2, 9, bgcolor = panelBgActive, frame_color = panelBorderActive, frame_width = 1, border_color = panelBorderActive, border_width = 1)
        table.merge_cells(infoPanel, 0, 0, 1, 0)
        lastPanelLocation := panelLocation
        lastPanelTheme := panelTheme
    table.cell(infoPanel, 0, 0, "AG Pro Pre-Breakout Pressure Planner", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelFontSize), text_halign = text.align_center)
    f_panel_row(infoPanel, 1, "Pressure Score", scoreText + "  " + f_score_grade(pressureScore), f_score_color(pressureScore), rowBgActive, panelLabelActive, f_text_size(panelFontSize))
    f_panel_row(infoPanel, 2, "Buildup Side", sideText, neutralSide ? neutralColor : activeLong ? bullColor : bearColor, panelBgActive, panelLabelActive, f_text_size(panelFontSize))
    f_panel_row(infoPanel, 3, "Volume Support", volumeText, volumeSupported ? bullColor : neutralColor, rowBgActive, panelLabelActive, f_text_size(panelFontSize))
    f_panel_row(infoPanel, 4, "Fakeout Risk", fakeoutText, fakeoutRisk ? dangerColor : fakeoutRiskScore >= 62.0 ? neutralColor : bullColor, panelBgActive, panelLabelActive, f_text_size(panelFontSize))
    f_panel_row(infoPanel, 5, "Trigger Corridor", triggerText, neutralSide ? neutralColor : activeColor, rowBgActive, panelLabelActive, f_text_size(panelFontSize))
    f_panel_row(infoPanel, 6, "Risk / Target", riskTargetText, neutralSide ? neutralColor : panelValueActive, panelBgActive, panelLabelActive, f_text_size(panelFontSize))
    f_panel_row(infoPanel, 7, "Follow-Through", followRateText, followRateColor, rowBgActive, panelLabelActive, f_text_size(panelFontSize))
    f_panel_row(infoPanel, 8, "Action", actionText, activeColor, panelBgActive, panelLabelActive, f_text_size(panelFontSize))
else
    if not na(infoPanel)
        table.delete(infoPanel)
        infoPanel := na
        lastPanelLocation := ""
        lastPanelTheme := ""

// -------------------------------------------------
// Alerts
// -------------------------------------------------
bool prevBullPressure = bullPressure[1] == true
bool prevBearPressure = bearPressure[1] == true
bool prevFakeoutRisk = fakeoutRisk[1] == true
bool prevTriggerReview = triggerReview[1] == true
bool bullPressureAlert = bullPressure and pressureScore >= alertScore and not prevBullPressure
bool bearPressureAlert = bearPressure and pressureScore >= alertScore and not prevBearPressure
bool fakeoutRiskAlert = fakeoutRisk and not prevFakeoutRisk
bool triggerReviewAlert = triggerReview and pressureScore >= minWatchScore and not prevTriggerReview

alertcondition(bullPressureAlert, "Bullish Pre-Breakout Pressure", "Pre-Breakout Pressure Planner: bullish pressure is building near the upper trigger corridor. This is an attention marker, not a trade instruction.")
alertcondition(bearPressureAlert, "Bearish Pre-Breakout Pressure", "Pre-Breakout Pressure Planner: bearish pressure is building near the lower trigger corridor. This is an attention marker, not a trade instruction.")
alertcondition(fakeoutRiskAlert, "Pre-Breakout Fakeout Risk", "Pre-Breakout Pressure Planner: a boundary probe has weak support or poor candle pressure. Review fakeout risk; this is an attention marker only.")
alertcondition(triggerReviewAlert, "Trigger Corridor Review", "Pre-Breakout Pressure Planner: price has entered or crossed a trigger corridor. Review context; this is an attention marker only.")
````
