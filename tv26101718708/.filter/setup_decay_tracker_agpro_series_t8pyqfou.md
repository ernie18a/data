# Setup Decay Tracker [AGPro Series]

- url: https://www.tradingview.com/script/T8PyQfOu-Setup-Decay-Tracker-AGPro-Series/
- type: indicator
- pine_id: PUB;fbb74388c92c4a0183a955500ec3698a
- version: 4.0

## Description

Setup Decay Tracker [AGPro Series]


🧠 Core Idea

Is a once-valid setup still healthy, or is its quality decaying over time?


📌 Overview / What it does

Setup Decay Tracker is a chart-first execution planning tool built to evaluate what happens after a setup has already started forming. Instead of treating every trigger as equally useful, it separates the process into two stages: setup validation and post-validation quality decay.

The script builds an active decay band, validation rail, follow-through rail, invalidation shelf, expiry marker, state labels, and a compact planning panel. Its purpose is to show whether the active setup is still valid, starting to fade, entering decay review, expiring, reclaiming its trigger side, or invalidating.

It does not predict price, automate trades, or issue buy/sell commands. Alerts and labels are attention markers designed to help traders review setup quality within broader market context.


🎯 Purpose & Design Philosophy

This script was built for traders who already understand that the first setup trigger is only the beginning of the decision process. A setup can look valid at first, then lose quality because time passes, momentum fades, volatility contracts, follow-through stalls, or price loses and reclaims the trigger side.

The gap it fills is post-validation review. Many tools mark a trigger, but fewer tools ask whether that trigger is aging well after it becomes valid. Setup Decay Tracker focuses on that question with a clean visual workflow.

The design supports a planning mindset: validate first, monitor quality second, review decay third.


⚡ Why This Script Is Different

Most tools focus on the moment a signal appears.

This script does NOT behave like a generic signal generator, broad regime classifier, support/resistance map, order-block map, or simple breakout alert.

Instead, it tracks the lifecycle of one active setup after validation. It asks whether the setup is still earning its place on the chart by measuring time risk, follow-through, momentum loss, volatility loss, trigger-side reclaim behavior, and invalidation context.


⚙️ Methodology

1. Context Detection

The script identifies the evaluation side using trend and range context, or the user can force long-side or short-side tracking.

2. Setup Validation

A trigger starts tracking, but the setup is not treated as fully valid until it reaches minimum favorable ATR travel and a validation-quality threshold.

3. Decay Evaluation

After validation, the script measures the active setup with a 0-100 decay model based on time risk, momentum loss, volatility loss, failed follow-through, and reclaim behavior.

4. Visual Output

The result appears as a decay band, validation rail, follow-through rail, invalidation shelf, expiry marker, compact labels, and a premium AGPro planning panel.


🗺️ How to Read the Chart

Zones = the active setup decay band between the follow-through reference and the invalidation shelf.

Labels = state changes such as TRACK, VALID, WATCH, DECAY, RECLAIM, EXPIRED, and INVALID.

Colors = teal for healthier states, gold for watch states, pink/red for decay review or invalidation pressure, and indigo for validation or reclaim context.

Panel = the decision summary showing Decay Score, Time Risk, Follow-Through, Invalidation, and Action.


🚦 Signals & States

• TRACK → a new setup is being monitored for validation

• VALID → the setup reached minimum quality and decay tracking is active

• STILL VALID → decay score remains low and follow-through is still acceptable

• QUALITY WATCH → quality is fading, but the setup has not reached decay review

• DECAY REVIEW → the setup has enough quality decay to deserve closer review

• RECLAIM → price recovered the trigger side after temporary loss

• EXPIRED → the setup aged beyond the active decay window or reached expiry-level decay

• INVALID → the invalidation shelf was crossed inside this rule set


🔔 Alerts Logic

The script includes alerts for:

• New setup tracking
• Setup validation
• Quality watch state
• Decay review state
• Trigger-side reclaim
• Setup expiry
• Setup invalidation

Alerts are attention markers. They are not trade instructions and should be interpreted with market structure, liquidity, volatility, and timeframe context.


🧩 Confluence Logic

The decay model becomes more meaningful when several conditions align.

When time risk rises, follow-through remains weak, momentum fades, volatility contracts, and price struggles around the trigger side, the setup decay context becomes stronger.

When follow-through improves, the trigger side holds, volatility remains healthy, and momentum stays directional, the setup remains cleaner.


📊 When to Use

• Breakout setups that need post-trigger validation

• Trend-reclaim setups where quality can fade after the first reclaim

• Continuation contexts where follow-through matters

• Active trade planning where invalidation and target references need to stay visible

• Markets where setup aging and time risk are part of the decision process


⚠️ When NOT to Use

• Extremely low-liquidity symbols

• Very noisy micro timeframes where triggers appear too frequently

• News-driven candles where normal volatility logic becomes distorted

• Markets with large gaps that make ATR-based validation less stable

• Situations where the user expects automatic entries, exits, or guaranteed outcomes


🎛️ Key Inputs

• Evaluation Side → chooses Auto, Long Setup, or Short Setup tracking

• Trigger Model → controls whether tracking starts from range acceptance, trend reclaim, or impulse continuation

• Sensitivity → changes how strict validation and decay response should be

• Setup Lookback → defines the recent structure window used for trigger context

• Validation Travel ATR → sets the minimum favorable movement needed before a setup is considered valid

• Decay Tracking Bars → controls how long a validated setup remains active

• Follow-Through Target ATR → defines the progress reference used inside the decay model

• Invalidation Buffer ATR → builds the invalidation shelf beyond the trigger candle

• Label and Panel Font Size → controls visual readability


🖥️ Interface & Visual Design

The interface is built around a clean chart-first layout. The decay band gives the setup a visible lifecycle area, while the centered band label summarizes the active state without requiring a dashboard-only workflow.

The panel is compact and decision-focused. Its first row follows the AGPro standard: one merged blue header row containing only the panel title. Panel location, panel theme, and panel font size are adjustable.

Labels are intentionally moderate. The script uses event labels plus sparse context labels so the chart stays alive without becoming crowded.


🧪 Practical Usage Workflow

1. Read the panel and check the active state.

2. Confirm whether the setup is validating, still valid, in watch state, in decay review, expired, or invalidated.

3. Check the decay band, validation rail, follow-through rail, and invalidation shelf.

4. Review labels for the most recent state change.

5. Interpret the output with broader market context before making any decision.


🔍 Interpretation Guidelines

Think of the Decay Score as a quality-loss meter, not a directional forecast.

A low Decay Score suggests that the setup is still holding its validation context.

A rising Decay Score suggests that time, weak progress, fading momentum, volatility loss, or trigger-side instability are reducing setup quality.

A Decay Review state means the setup deserves attention. It does not mean price must reverse or that a trade must be closed.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not an auto-trading system

• Not a guaranteed signal tool

• Not a generic support/resistance map

• Not a broad market regime classifier


⚠️ Limitations & Transparency

ATR-based rails can behave differently across markets, timeframes, and volatility regimes.

Fast news moves, thin liquidity, and wide spreads can distort validation and decay readings.

No rule-based tool can fully understand every market condition. The output should be read as structured context, not certainty.


🧠 Market Context Notes

Setup decay often matters most when the first trigger was valid but follow-through becomes uncertain. A setup can remain technically alive while losing momentum, time efficiency, or volatility support.

The script focuses on that middle zone between “still valid” and “clearly invalidated.”


🧾 Use Case Examples

When price breaks a recent range, validates with minimum travel, then stalls for many bars without reaching the follow-through rail, the Decay Score can rise into watch or review context.

When price temporarily loses the trigger side and then reclaims it, the script marks reclaim context and continues monitoring quality rather than treating the setup as automatically clean.

When price crosses the invalidation shelf, the setup is marked invalid inside this rule set.


🧱 System Philosophy

Setup Decay Tracker follows the AGPro planning approach: the best public tools should help traders make a decision, not simply show another signal.

The script is designed to answer practical questions:

Is this setup valid?
How much quality has it lost?
Where is the invalidation?
Is follow-through still acceptable?
What should I review now?


🔐 Non-Promise Statement

This script does not provide certainty.

It does not guarantee outcomes.

It provides a structured way to monitor setup quality decay after validation.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, decisions, risk management, and trade execution.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use the tool to study how setup quality changes after the first valid trigger. The most useful reading often comes from comparing the panel state, decay band, labels, and broader market context together.

## Source Code

````pine
// -------------------------------------------------
// Setup Decay Tracker [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Setup Decay Tracker is a chart-first execution failure planner that studies
// whether a once-valid setup is losing quality over time. It separates initial
// setup validation from later quality decay, then maps time risk, follow-through,
// momentum loss, volatility loss, reclaim behavior, target context, and
// invalidation into a clean public-free decision engine. Version 1.4 removes
// event and projection overlaps while enforcing exclusive terminal outcomes.
// -------------------------------------------------

//@version=6
indicator("Setup Decay Tracker [AGPro Series]",
     shorttitle = "AG SDT",
     overlay = true,
     max_labels_count = 120,
     max_boxes_count = 20,
     max_lines_count = 20)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
dangerColor   = color.rgb(239, 68, 68)
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttSide = "Selects the side used for setup validation and decay tracking. Auto follows trend and range context; manual modes keep the tracker fixed to long-side or short-side evaluation."
ttTrigger = "Selects the setup trigger family. A trigger only starts tracking; the script waits for validation before judging decay."
ttSensitivity = "Controls how quickly validation and decay logic react. Reactive is faster, Conservative requires stronger setup quality and slower decay confirmation."
ttLookback = "Lookback used to define the recent setup boundary, range context, and trigger reference."
ttAtr = "ATR length used for volatility-normalized rails, label offsets, decay band size, and score calculations."
ttTrend = "EMA length used to evaluate directional context. It supports the setup-quality model but is not a standalone signal."
ttVolume = "Volume baseline used to estimate participation during setup validation and later follow-through. Symbols with missing volume receive a neutral reading."
ttConfirm = "Close Confirmed waits for closed bars before labels and alerts. Live Updating can react before the candle closes."
ttValidationBars = "Number of bars expected for the setup to prove it is valid before decay tracking becomes meaningful."
ttValidationTravel = "Minimum favorable ATR travel required before a tracked setup can be marked as valid."
ttValidationScore = "Minimum 0-100 validation quality required before the script starts decay tracking."
ttMaxTrack = "Maximum number of bars a validated setup can remain active before expiry logic becomes dominant."
ttFollowTarget = "ATR-based follow-through reference used to decide whether the setup is still making enough progress after validation."
ttInvalidation = "ATR buffer beyond the trigger candle used to create the invalidation shelf for the tracked setup."
ttWatchScore = "Decay score at which the setup moves from still-valid tracking into quality-watch context."
ttReviewScore = "Decay score at which the setup moves into decay-review context. This is an attention marker, not a trade instruction."
ttExpiryScore = "Decay score that can expire a validated setup after the early review window has matured."
ttMomentum = "Lookback used to compare current directional progress with prior progress. Loss of directional push raises decay pressure."
ttVolatility = "ATR baseline used to detect whether volatility support is fading after the setup has already become valid."
ttShowBand = "Shows the active setup decay band between the follow-through rail and invalidation shelf. A filled centered badge summarizes the current decay state."
ttShowRails = "Shows the trigger reference, validation rail, follow-through rail, and invalidation shelf for the active setup."
ttShowExpiry = "Shows the expiry marker at the end of the active decay window."
ttPriorBands = "Keeps a small number of prior decay bands as subtle context when a new setup starts."
ttPriorCount = "Maximum number of prior decay bands retained on the chart."
ttForward = "Number of bars used to project the active decay band and rails to the right."
ttRightTags = "Displays compact right-side tags for follow-through, trigger, and invalidation references."
ttLabels = "Shows setup, validation, decay downgrade, reclaim, expiry, and invalidation labels on the chart."
ttContextLabels = "Adds sparse still-valid or watch-state labels while a setup remains active so the chart does not look empty between major events."
ttLabelMode = "Compact keeps event labels short for publication screenshots. Detailed adds an extra state line."
ttCooldown = "Minimum bars between event labels. Higher values reduce visual density."
ttContextSpacing = "Minimum spacing between sparse context labels while the setup remains active."
ttMaxLabels = "Maximum chart labels retained. Older labels are removed first for performance and readability."
ttOffset = "ATR-based vertical offset used to keep labels away from candle bodies."
ttLabelScore = "Adds the current 0-100 decay score to chart labels."
ttLabelSize = "Controls all chart label, right-side tag, and decay-band badge sizes. Normal is the recommended publication default."
ttPanel = "Shows or hides the AG Pro planning panel. The panel is visible by default for public-release readability."
ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between dark and light chart-friendly themes."
ttPanelFont = "Controls panel text size. Normal is the recommended publication default."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Setup Validation Engine"
sideMode = input.string("Auto", "Evaluation Side", options = ["Auto", "Long Setup", "Short Setup"], group = groupEngine, tooltip = ttSide)
triggerModel = input.string("Range Acceptance", "Trigger Model", options = ["Range Acceptance", "Trend Reclaim", "Impulse Continuation"], group = groupEngine, tooltip = ttTrigger)
sensitivity = input.string("Balanced", "Sensitivity", options = ["Conservative", "Balanced", "Reactive"], group = groupEngine, tooltip = ttSensitivity)
setupLookback = input.int(34, "Setup Lookback", minval = 8, maxval = 180, group = groupEngine, tooltip = ttLookback)
atrLength = input.int(14, "ATR Length", minval = 3, maxval = 100, group = groupEngine, tooltip = ttAtr)
trendLength = input.int(55, "Trend Context EMA", minval = 8, maxval = 240, group = groupEngine, tooltip = ttTrend)
volumeLength = input.int(20, "Volume Baseline", minval = 5, maxval = 120, group = groupEngine, tooltip = ttVolume)
confirmationMode = input.string("Close Confirmed", "Confirmation Mode", options = ["Close Confirmed", "Live Updating"], group = groupEngine, tooltip = ttConfirm)

groupScoring = "Decay Score Model"
validationBars = input.int(10, "Validation Window Bars", minval = 3, maxval = 60, group = groupScoring, tooltip = ttValidationBars)
validationTravelAtr = input.float(0.80, "Validation Travel ATR", minval = 0.15, maxval = 4.00, step = 0.05, group = groupScoring, tooltip = ttValidationTravel)
minimumValidationScore = input.int(58, "Minimum Validation Score", minval = 30, maxval = 90, group = groupScoring, tooltip = ttValidationScore)
maxTrackingBars = input.int(42, "Decay Tracking Bars", minval = 12, maxval = 180, group = groupScoring, tooltip = ttMaxTrack)
followThroughAtr = input.float(2.10, "Follow-Through Target ATR", minval = 0.50, maxval = 8.00, step = 0.05, group = groupScoring, tooltip = ttFollowTarget)
invalidationBufferAtr = input.float(0.30, "Invalidation Buffer ATR", minval = 0.00, maxval = 3.00, step = 0.05, group = groupScoring, tooltip = ttInvalidation)
watchDecayScore = input.int(44, "Quality Watch Score", minval = 20, maxval = 75, group = groupScoring, tooltip = ttWatchScore)
reviewDecayScore = input.int(62, "Decay Review Score", minval = 35, maxval = 90, group = groupScoring, tooltip = ttReviewScore)
expiryDecayScore = input.int(78, "Expiry Decay Score", minval = 55, maxval = 98, group = groupScoring, tooltip = ttExpiryScore)
momentumLookback = input.int(8, "Momentum Loss Lookback", minval = 3, maxval = 50, group = groupScoring, tooltip = ttMomentum)
volatilityLookback = input.int(34, "Volatility Decay Baseline", minval = 10, maxval = 150, group = groupScoring, tooltip = ttVolatility)

groupVisual = "Chart Visuals"
showDecayBand = input.bool(true, "Show Decay Band", group = groupVisual, tooltip = ttShowBand)
showGuideRails = input.bool(true, "Show Setup Rails", group = groupVisual, tooltip = ttShowRails)
showRightTags = input.bool(true, "Show Right-Side Tags", group = groupVisual, tooltip = ttRightTags)
showExpiryMarker = input.bool(true, "Show Expiry Marker", group = groupVisual, tooltip = ttShowExpiry)
showPriorBands = input.bool(false, "Show Prior Decay Bands", group = groupVisual, tooltip = ttPriorBands)
priorBandCount = input.int(2, "Max Prior Bands", minval = 0, maxval = 10, group = groupVisual, tooltip = ttPriorCount)
forwardBars = input.int(30, "Forward Projection Bars", minval = 8, maxval = 120, group = groupVisual, tooltip = ttForward)

groupLabels = "Labels"
showLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showContextLabels = input.bool(true, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
labelTextMode = input.string("Compact", "Label Text Mode", options = ["Compact", "Detailed"], group = groupLabels, tooltip = ttLabelMode)
labelCooldownBars = input.int(18, "Label Cooldown Bars", minval = 1, maxval = 80, group = groupLabels, tooltip = ttCooldown)
contextSpacingBars = input.int(42, "Context Label Spacing", minval = 8, maxval = 160, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(10, "Max Visible Labels", minval = 4, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
labelOffsetAtr = input.float(1.15, "Label Offset ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = groupLabels, tooltip = ttOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelFontSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttPanel)
panelLocation = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.min(math.max(value, minValue), maxValue)

f_norm_high_good(float value, float weak, float strong) =>
    span = strong - weak
    span == 0.0 ? 0.0 : f_clamp((value - weak) / span * 100.0, 0.0, 100.0)

f_norm_low_good(float value, float good, float bad) =>
    span = bad - good
    span == 0.0 ? 0.0 : f_clamp((bad - value) / span * 100.0, 0.0, 100.0)

f_text_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_pos(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

f_text_on(color bgColor) =>
    bright = (color.r(bgColor) * 299 + color.g(bgColor) * 587 + color.b(bgColor) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_panel_bg(string theme) =>
    theme == "Light" ? color.rgb(248, 250, 252) : panelBg

f_panel_border(string theme) =>
    theme == "Light" ? color.rgb(186, 198, 214) : panelBorder

f_panel_label(string theme) =>
    theme == "Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Light" ? color.rgb(15, 23, 42) : panelValueCol

f_row_bg(string theme, int row) =>
    evenRow = row % 2 == 0
    theme == "Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_decay_color(float scoreValue) =>
    scoreValue >= expiryDecayScore ? dangerColor : scoreValue >= reviewDecayScore ? bearColor : scoreValue >= watchDecayScore ? neutralColor : bullColor

f_state_color(string stateText) =>
    switch stateText
        "Still Valid" => bullColor
        "Validating" => accentColor
        "Quality Watch" => neutralColor
        "Decay Review" => bearColor
        "Expired" => dangerColor
        "Invalidated" => dangerColor
        "Reclaimed" => accentColor
        => panelLabelCol

f_decay_band(float scoreValue) =>
    scoreValue >= 78.0 ? "EXPIRED" : scoreValue >= 62.0 ? "REVIEW" : scoreValue >= 44.0 ? "WATCH" : "LOW"

f_trim_labels(array<label> labels, int maxCount) =>
    while array.size(labels) > maxCount
        oldLabel = array.shift(labels)
        label.delete(oldLabel)

f_trim_boxes(array<box> boxes, int maxCount) =>
    while array.size(boxes) > maxCount
        oldBox = array.shift(boxes)
        box.delete(oldBox)

f_set_row(table target, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    rowBg = f_row_bg(theme, row)
    table.cell(target, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_left)
    table.cell(target, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_text_size(fontSize), text_halign = text.align_right)

f_set_label(label tag, int x, float y, string txt, color bg, styleValue, textSize) =>
    label.set_xy(tag, x, y)
    label.set_text(tag, txt)
    label.set_color(tag, color.new(bg, 0))
    label.set_textcolor(tag, f_text_on(bg))
    label.set_style(tag, styleValue)
    label.set_size(tag, textSize)
    label.set_textalign(tag, text.align_center)

f_label_text(string codeText, string detailText, int scoreValue) =>
    scoreText = showLabelScore ? "\nScore " + str.tostring(scoreValue) : ""
    labelTextMode == "Compact" ? codeText + scoreText : codeText + scoreText + "\n" + detailText

f_add_label(array<label> labels, string textValue, float labelY, bool abovePrice, color labelColor, string tipText) =>
    newLabel = label.new(x = bar_index,
         y = labelY,
         text = textValue,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = abovePrice ? label.style_label_down : label.style_label_up,
         color = color.new(labelColor, 8),
         textcolor = f_text_on(labelColor),
         size = f_text_size(labelFontSize),
         tooltip = tipText,
         textalign = text.align_center)
    array.push(labels, newLabel)
    f_trim_labels(labels, maxVisibleLabels)
    newLabel

// -------------------------------------------------
// Core Measurements
// -------------------------------------------------
confirmedBar = confirmationMode == "Close Confirmed" ? barstate.isconfirmed : true
atr = ta.atr(atrLength)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
atrBase = nz(ta.sma(atr, volatilityLookback), safeAtr)
trendBasis = ta.ema(close, trendLength)
fastTrend = ta.ema(close, math.max(2, int(math.round(trendLength * 0.45))))
trendSlope = trendBasis - nz(trendBasis[5], trendBasis)
volumeAverage = ta.sma(nz(volume, 0.0), volumeLength)
volumeRatio = volumeAverage > 0.0 ? nz(volume, 0.0) / volumeAverage : 1.0
volumeReady = na(volume) or volumeAverage <= 0.0 ? 1.0 : volumeRatio
priorHigh = nz(ta.highest(high[1], setupLookback), high)
priorLow = nz(ta.lowest(low[1], setupLookback), low)
rangeHigh = nz(ta.highest(high, setupLookback), high)
rangeLow = nz(ta.lowest(low, setupLookback), low)
rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangePosition = f_clamp((close - rangeLow) / rangeSpan, 0.0, 1.0)
candleRange = math.max(high - low, syminfo.mintick)
bodyAtr = math.abs(close - open) / safeAtr
closeLocation = f_clamp((close - low) / candleRange, 0.0, 1.0)

sensitivityFactor = sensitivity == "Reactive" ? 0.86 : sensitivity == "Conservative" ? 1.16 : 1.00
decaySensitivity = sensitivity == "Reactive" ? 1.16 : sensitivity == "Conservative" ? 0.88 : 1.00
autoLong = fastTrend >= trendBasis and trendSlope >= 0.0 ? true : fastTrend <= trendBasis and trendSlope <= 0.0 ? false : rangePosition >= 0.50
selectedLong = sideMode == "Long Setup" ? true : sideMode == "Short Setup" ? false : autoLong

longRangeTrigger = close > priorHigh and nz(close[1], close) <= priorHigh
shortRangeTrigger = close < priorLow and nz(close[1], close) >= priorLow
longReclaimTrigger = close > trendBasis and nz(close[1], close) <= nz(trendBasis[1], trendBasis) and closeLocation >= 0.58
shortReclaimTrigger = close < trendBasis and nz(close[1], close) >= nz(trendBasis[1], trendBasis) and closeLocation <= 0.42
longImpulseTrigger = close > open and close > nz(high[1], high) and bodyAtr >= 0.45 * sensitivityFactor and closeLocation >= 0.60
shortImpulseTrigger = close < open and close < nz(low[1], low) and bodyAtr >= 0.45 * sensitivityFactor and closeLocation <= 0.40
rawLongTrigger = triggerModel == "Range Acceptance" ? longRangeTrigger : triggerModel == "Trend Reclaim" ? longReclaimTrigger : longImpulseTrigger
rawShortTrigger = triggerModel == "Range Acceptance" ? shortRangeTrigger : triggerModel == "Trend Reclaim" ? shortReclaimTrigger : shortImpulseTrigger

// -------------------------------------------------
// Setup State
// -------------------------------------------------
var bool hasSetup = false
var bool activeLong = true
var bool setupValidated = false
var bool invalidated = false
var bool expired = false
var bool lostTrigger = false
var bool reclaimSeen = false
var bool watchMarked = false
var bool reviewMarked = false
var int triggerBar = na
var int validationBar = na
var int lastEventLabelBar = na
var int lastContextLabelBar = na
var float triggerPrice = na
var float triggerAtr = na
var float validationAtr = na
var float riskShelf = na
var float validationRail = na
var float followThroughRail = na
var float activeBest = na
var string lastState = "Waiting"
var int lastDecayScore = 0
var int resolvedBar = na
var int resolvedDecayScore = na
var label trackEventLabel = na
var label reviewEventLabel = na
var int reviewEventBar = na
var box activeBand = na
var line triggerLine = na
var line validationLine = na
var line followLine = na
var line riskLine = na
var line expiryLine = na
var label bandBadge = na
var label followTag = na
var label validationTag = na
var label triggerTag = na
var label riskTag = na
var label expiryTag = na
var array<label> eventLabels = array.new<label>()
var array<box> priorBands = array.new<box>()
var array<label> priorBadges = array.new<label>()

setupAgeForStart = hasSetup and not na(triggerBar) ? bar_index - triggerBar : 0
canStartSetup = not hasSetup or invalidated or expired or setupAgeForStart > maxTrackingBars + validationBars
newTrigger = confirmedBar and canStartSetup and (selectedLong ? rawLongTrigger : rawShortTrigger)

validationEvent = false
invalidationEvent = false
reclaimEvent = false
expiryEvent = false

if newTrigger
    if not na(activeBand)
        if showPriorBands and priorBandCount > 0
            memoryColor = f_state_color(lastState)
            box.set_bgcolor(activeBand, color.new(memoryColor, 95))
            box.set_border_color(activeBand, color.new(memoryColor, 76))
            array.push(priorBands, activeBand)
            if not na(bandBadge)
                oldCenterX = int(math.round((box.get_left(activeBand) + box.get_right(activeBand)) * 0.5))
                oldCenterY = (box.get_top(activeBand) + box.get_bottom(activeBand)) * 0.5
                memoryText = (activeLong ? "LONG" : "SHORT") + " MEMORY\n" + str.upper(lastState) + " | DECAY " + str.tostring(lastDecayScore)
                f_set_label(bandBadge, oldCenterX, oldCenterY, memoryText, memoryColor, label.style_label_center, f_text_size(labelFontSize))
                array.push(priorBadges, bandBadge)
                bandBadge := na
            while array.size(priorBands) > priorBandCount
                box.delete(array.shift(priorBands))
                if array.size(priorBadges) > 0
                    label.delete(array.shift(priorBadges))
        else
            box.delete(activeBand)
        activeBand := na
    if not na(bandBadge)
        label.delete(bandBadge)
        bandBadge := na

    hasSetup := true
    activeLong := selectedLong
    setupValidated := false
    invalidated := false
    expired := false
    lostTrigger := false
    reclaimSeen := false
    watchMarked := false
    reviewMarked := false
    triggerBar := bar_index
    validationBar := na
    resolvedBar := na
    resolvedDecayScore := na
    trackEventLabel := na
    reviewEventLabel := na
    reviewEventBar := na
    triggerPrice := close
    triggerAtr := safeAtr
    validationAtr := na
    riskShelf := activeLong ? low - safeAtr * invalidationBufferAtr : high + safeAtr * invalidationBufferAtr
    validationRail := triggerPrice + (activeLong ? 1.0 : -1.0) * safeAtr * validationTravelAtr
    followThroughRail := triggerPrice + (activeLong ? 1.0 : -1.0) * safeAtr * followThroughAtr
    activeBest := activeLong ? high : low
    lastState := "Validating"

if hasSetup and not invalidated and not expired
    activeBest := activeLong ? math.max(nz(activeBest, high), high) : math.min(nz(activeBest, low), low)
    lostNow = activeLong ? close < triggerPrice : close > triggerPrice
    lostTrigger := lostTrigger or lostNow
    regainedNow = activeLong ? close >= triggerPrice : close <= triggerPrice
    reclaimEvent := confirmedBar and setupValidated and lostTrigger and regainedNow and not reclaimSeen and not invalidated and not expired
    reclaimSeen := reclaimSeen or reclaimEvent

setupAge = hasSetup and not na(triggerBar) ? math.max(bar_index - triggerBar, 0) : 0
validAge = setupValidated and not na(validationBar) ? math.max(bar_index - validationBar, 0) : 0
effectiveSetupAge = hasSetup and not na(triggerBar) and (invalidated or expired) and not na(resolvedBar) ? math.max(resolvedBar - triggerBar, 0) : setupAge
effectiveValidAge = setupValidated and not na(validationBar) and (invalidated or expired) and not na(resolvedBar) ? math.max(resolvedBar - validationBar, 0) : validAge
setupAtr = math.max(nz(triggerAtr, safeAtr), syminfo.mintick)
favorableDistance = hasSetup ? (activeLong ? math.max(activeBest - triggerPrice, 0.0) : math.max(triggerPrice - activeBest, 0.0)) : 0.0
closeFavorableDistance = hasSetup ? (activeLong ? math.max(close - triggerPrice, 0.0) : math.max(triggerPrice - close, 0.0)) : 0.0
favorableAtr = favorableDistance / setupAtr
closeProgressAtr = closeFavorableDistance / setupAtr
directionalCloseQuality = activeLong ? closeLocation : 1.0 - closeLocation
triggerSideHeld = hasSetup and (activeLong ? close >= triggerPrice : close <= triggerPrice)
invalidatedNow = hasSetup and not invalidated and not expired and confirmedBar and (activeLong ? close <= riskShelf : close >= riskShelf)
invalidated := invalidated or invalidatedNow
invalidationEvent := invalidatedNow
if invalidatedNow
    resolvedBar := bar_index

travelValidationScore = f_norm_high_good(favorableAtr, validationTravelAtr * 0.35, validationTravelAtr * 1.35)
closeValidationScore = triggerSideHeld ? f_clamp(directionalCloseQuality * 100.0, 0.0, 100.0) : 15.0
trendValidationScore = activeLong ? (close >= trendBasis ? 76.0 : 34.0) : (close <= trendBasis ? 76.0 : 34.0)
volumeValidationScore = f_norm_high_good(volumeReady, 0.70, 1.35)
validationQuality = int(math.round(f_clamp(travelValidationScore * 0.42 + closeValidationScore * 0.24 + trendValidationScore * 0.20 + volumeValidationScore * 0.14, 0.0, 100.0)))
validationReady = hasSetup and not setupValidated and not invalidated and confirmedBar and setupAge <= validationBars and setupAge > 0 and favorableAtr >= validationTravelAtr and validationQuality >= minimumValidationScore and triggerSideHeld

if validationReady
    setupValidated := true
    validationBar := bar_index
    validationAtr := safeAtr
    validationEvent := true

validationExpiryNow = hasSetup and not setupValidated and setupAge > validationBars and not invalidated and not expired and confirmedBar
if validationExpiryNow
    expired := true
    expiryEvent := true
    resolvedBar := bar_index

currentMove = activeLong ? close - nz(close[momentumLookback], close) : nz(close[momentumLookback], close) - close
priorMove = activeLong ? nz(close[momentumLookback], close) - nz(close[momentumLookback * 2], nz(close[momentumLookback], close)) : nz(close[momentumLookback * 2], nz(close[momentumLookback], close)) - nz(close[momentumLookback], close)
currentMoveAtr = currentMove / safeAtr
priorMoveAtr = priorMove / safeAtr
momentumLoss = f_norm_high_good((priorMoveAtr - currentMoveAtr) * decaySensitivity, -0.10, 1.10)
momentumLoss := currentMoveAtr < 0.0 ? math.max(momentumLoss, 78.0) : momentumLoss

atrReference = math.max(nz(validationAtr, setupAtr), syminfo.mintick)
setupVolRatio = safeAtr / atrReference
baselineVolRatio = atrBase > 0.0 ? safeAtr / atrBase : 1.0
volatilityLoss = f_clamp(f_norm_low_good(setupVolRatio, 0.88, 0.55) * 0.68 + f_norm_low_good(baselineVolRatio, 0.90, 0.58) * 0.32, 0.0, 100.0)

timeRisk = setupValidated ? f_norm_high_good(float(effectiveValidAge), float(math.max(1, maxTrackingBars / 3)), float(maxTrackingBars)) : f_norm_high_good(float(effectiveSetupAge), float(validationBars), float(validationBars + 4))
followThroughProgress = f_norm_high_good(favorableAtr, validationTravelAtr, followThroughAtr)
failedProgress = setupValidated ? 100.0 - followThroughProgress : 100.0 - travelValidationScore
reclaimPenalty = lostTrigger ? (reclaimSeen ? 34.0 : 88.0) : 8.0
decayScoreRaw = setupValidated ? timeRisk * 0.22 + momentumLoss * 0.24 + volatilityLoss * 0.16 + failedProgress * 0.26 + reclaimPenalty * 0.12 : 100.0 - validationQuality
decayScore = int(math.round(f_clamp(invalidated ? 100.0 : decayScoreRaw, 0.0, 100.0)))
qualityScore = 100 - decayScore

expiryCondition = setupValidated and not invalidated and (validAge >= maxTrackingBars or (decayScore >= expiryDecayScore and validAge >= validationBars))
if confirmedBar and expiryCondition and not expired
    expired := true
    expiryEvent := true
    resolvedBar := bar_index

if expired
    decayScore := math.max(decayScore, expiryDecayScore)
    qualityScore := 100 - decayScore

if (invalidated or expired) and na(resolvedDecayScore)
    resolvedDecayScore := invalidated ? 100 : decayScore
if invalidated or expired
    decayScore := resolvedDecayScore
    qualityScore := 100 - decayScore

watchEvent = setupValidated and confirmedBar and not invalidated and not expired and not watchMarked and decayScore >= watchDecayScore and decayScore < reviewDecayScore
reviewEvent = setupValidated and confirmedBar and not invalidated and not expired and not reviewMarked and decayScore >= reviewDecayScore
watchMarked := watchMarked or watchEvent or reviewEvent
reviewMarked := reviewMarked or reviewEvent

stateText = "Waiting"
if hasSetup
    if invalidated
        stateText := "Invalidated"
    else if expired
        stateText := "Expired"
    else if not setupValidated
        stateText := "Validating"
    else if reclaimEvent
        stateText := "Reclaimed"
    else if decayScore >= reviewDecayScore
        stateText := "Decay Review"
    else if decayScore >= watchDecayScore
        stateText := "Quality Watch"
    else
        stateText := "Still Valid"

actionText = switch stateText
    "Still Valid" => "Keep tracking"
    "Validating" => "Wait validation"
    "Quality Watch" => "Watch decay"
    "Decay Review" => "Review setup"
    "Expired" => "Setup expired"
    "Invalidated" => "Setup invalidated"
    "Reclaimed" => "Monitor reclaim"
    => "Wait setup"

// -------------------------------------------------
// Follow-through proof (Confirm Rate)
// -------------------------------------------------
// When a setup is validated, does it reach the follow-through target before its
// invalidation shelf is crossed or the decay window expires? Counted once per
// validated setup. An invalidation first, or a window expiry with no target hit,
// is treated as not-followed (conservative).
var int ftTotal = 0
var int ftWon = 0
var array<int> ftDirections = array.new<int>()
var array<float> ftTargets = array.new<float>()
var array<float> ftShelves = array.new<float>()
var array<int> ftStartBars = array.new<int>()

if barstate.isconfirmed
    pendingAtOpen = array.size(ftDirections)
    if pendingAtOpen > 0
        for step = 0 to pendingAtOpen - 1
            i = pendingAtOpen - 1 - step
            proofDir = array.get(ftDirections, i)
            proofTarget = array.get(ftTargets, i)
            proofShelf = array.get(ftShelves, i)
            proofStart = array.get(ftStartBars, i)
            if bar_index > proofStart
                broke = proofDir > 0 ? close <= proofShelf : close >= proofShelf
                reached = proofDir > 0 ? high >= proofTarget : low <= proofTarget
                timedOut = bar_index - proofStart >= maxTrackingBars
                if broke or reached or timedOut
                    ftTotal += 1
                    if reached and not broke
                        ftWon += 1
                    array.remove(ftDirections, i)
                    array.remove(ftTargets, i)
                    array.remove(ftShelves, i)
                    array.remove(ftStartBars, i)
    if validationEvent and not na(followThroughRail) and not na(riskShelf)
        array.push(ftDirections, activeLong ? 1 : -1)
        array.push(ftTargets, followThroughRail)
        array.push(ftShelves, riskShelf)
        array.push(ftStartBars, bar_index)

float ftRate = ftTotal > 0 ? ftWon / ftTotal * 100.0 : na
string followRateRead = ftTotal > 0 ? str.tostring(math.round(ftRate)) + "% (" + str.tostring(ftTotal) + ")" : "Building"

// -------------------------------------------------
// Chart Visuals
// -------------------------------------------------
stateColor = f_state_color(stateText)
liveBandRight = hasSetup ? math.min(bar_index + forwardBars, triggerBar + validationBars + maxTrackingBars) : bar_index + forwardBars
terminalState = invalidated or expired
bandRight = hasSetup ? (terminalState ? nz(resolvedBar, bar_index) : liveBandRight) : bar_index + forwardBars
expiryX = hasSetup ? triggerBar + validationBars + maxTrackingBars : bar_index
bandPadding = setupAtr * 0.10
bandTop = hasSetup ? math.max(followThroughRail, riskShelf) + bandPadding : high
bandBottom = hasSetup ? math.min(followThroughRail, riskShelf) - bandPadding : low
projectionBadgeLeft = terminalState ? triggerBar : math.min(bandRight, bar_index + 2)
bandCenterX = hasSetup ? int(math.round((projectionBadgeLeft + bandRight) * 0.5)) : bar_index
bandCenterY = (bandTop + bandBottom) * 0.5
directionText = activeLong ? "LONG" : "SHORT"
ageText = setupValidated ? str.tostring(effectiveValidAge) + "/" + str.tostring(maxTrackingBars) : str.tostring(effectiveSetupAge) + "/" + str.tostring(validationBars)
bandText = hasSetup ? directionText + " | " + str.upper(stateText) + "\n" + (setupValidated or terminalState ? "Decay " + str.tostring(decayScore) : "Quality " + str.tostring(validationQuality)) + " | Age " + ageText : ""

if showDecayBand and hasSetup
    bandBg = color.new(stateColor, stateText == "Decay Review" or stateText == "Expired" ? 86 : 91)
    bandBorder = color.new(stateColor, stateText == "Still Valid" ? 38 : 20)
    if na(activeBand)
        activeBand := box.new(triggerBar, bandTop, bandRight, bandBottom, xloc = xloc.bar_index, bgcolor = bandBg, border_color = bandBorder, border_width = 1)
    else
        box.set_lefttop(activeBand, triggerBar, bandTop)
        box.set_rightbottom(activeBand, bandRight, bandBottom)
        box.set_bgcolor(activeBand, bandBg)
        box.set_border_color(activeBand, bandBorder)
    if na(bandBadge)
        bandBadge := label.new(bandCenterX, bandCenterY, "", xloc = xloc.bar_index, style = label.style_label_center, color = stateColor, textcolor = f_text_on(stateColor), size = f_text_size(labelFontSize))
    f_set_label(bandBadge, bandCenterX, bandCenterY, bandText, stateColor, label.style_label_center, f_text_size(labelFontSize))
else
    if not na(activeBand)
        box.delete(activeBand)
        activeBand := na
    if not na(bandBadge)
        label.delete(bandBadge)
        bandBadge := na

if showGuideRails and hasSetup
    if na(triggerLine)
        triggerLine := line.new(triggerBar, triggerPrice, bandRight, triggerPrice, xloc = xloc.bar_index, color = color.new(accentColor, 25), width = 1, style = line.style_dotted)
    else
        line.set_xy1(triggerLine, triggerBar, triggerPrice)
        line.set_xy2(triggerLine, bandRight, triggerPrice)
    if na(validationLine)
        validationLine := line.new(triggerBar, validationRail, bandRight, validationRail, xloc = xloc.bar_index, color = color.new(neutralColor, 20), width = 1, style = line.style_dashed)
    else
        line.set_xy1(validationLine, triggerBar, validationRail)
        line.set_xy2(validationLine, bandRight, validationRail)
    if na(followLine)
        followLine := line.new(triggerBar, followThroughRail, bandRight, followThroughRail, xloc = xloc.bar_index, color = color.new(bullColor, 15), width = 1, style = line.style_solid)
    else
        line.set_xy1(followLine, triggerBar, followThroughRail)
        line.set_xy2(followLine, bandRight, followThroughRail)
    if na(riskLine)
        riskLine := line.new(triggerBar, riskShelf, bandRight, riskShelf, xloc = xloc.bar_index, color = color.new(dangerColor, 10), width = 1, style = line.style_solid)
    else
        line.set_xy1(riskLine, triggerBar, riskShelf)
        line.set_xy2(riskLine, bandRight, riskShelf)
    if showRightTags
        tagSize = f_text_size(labelFontSize)
        if na(followTag)
            followTag := label.new(bandRight + 1, followThroughRail, "", xloc = xloc.bar_index, style = label.style_label_left, color = bullColor, textcolor = f_text_on(bullColor), size = tagSize)
        f_set_label(followTag, bandRight + 1, followThroughRail, "Follow " + str.tostring(followThroughRail, format.mintick), bullColor, label.style_label_left, tagSize)
        if na(validationTag)
            validationTag := label.new(bandRight + 6, validationRail, "", xloc = xloc.bar_index, style = label.style_label_left, color = neutralColor, textcolor = f_text_on(neutralColor), size = tagSize)
        f_set_label(validationTag, bandRight + 6, validationRail, "Validate " + str.tostring(validationRail, format.mintick), neutralColor, label.style_label_left, tagSize)
        if na(triggerTag)
            triggerTag := label.new(bandRight + 1, triggerPrice, "", xloc = xloc.bar_index, style = label.style_label_left, color = accentColor, textcolor = f_text_on(accentColor), size = tagSize)
        f_set_label(triggerTag, bandRight + 1, triggerPrice, "Trigger " + str.tostring(triggerPrice, format.mintick), accentColor, label.style_label_left, tagSize)
        if na(riskTag)
            riskTag := label.new(bandRight + 1, riskShelf, "", xloc = xloc.bar_index, style = label.style_label_left, color = dangerColor, textcolor = f_text_on(dangerColor), size = tagSize)
        f_set_label(riskTag, bandRight + 1, riskShelf, "Invalid " + str.tostring(riskShelf, format.mintick), dangerColor, label.style_label_left, tagSize)
    else
        if not na(followTag)
            label.delete(followTag)
            followTag := na
        if not na(validationTag)
            label.delete(validationTag)
            validationTag := na
        if not na(triggerTag)
            label.delete(triggerTag)
            triggerTag := na
        if not na(riskTag)
            label.delete(riskTag)
            riskTag := na
else
    if not na(triggerLine)
        line.delete(triggerLine)
        triggerLine := na
    if not na(validationLine)
        line.delete(validationLine)
        validationLine := na
    if not na(followLine)
        line.delete(followLine)
        followLine := na
    if not na(riskLine)
        line.delete(riskLine)
        riskLine := na
    if not na(followTag)
        label.delete(followTag)
        followTag := na
    if not na(validationTag)
        label.delete(validationTag)
        validationTag := na
    if not na(triggerTag)
        label.delete(triggerTag)
        triggerTag := na
    if not na(riskTag)
        label.delete(riskTag)
        riskTag := na

if showExpiryMarker and hasSetup and not terminalState
    if na(expiryLine)
        expiryLine := line.new(expiryX, bandTop, expiryX, bandBottom, xloc = xloc.bar_index, color = color.new(stateColor, 35), width = 1, style = line.style_dashed)
    else
        line.set_xy1(expiryLine, expiryX, bandTop)
        line.set_xy2(expiryLine, expiryX, bandBottom)
        line.set_color(expiryLine, color.new(stateColor, 35))
    if na(expiryTag)
        expiryTag := label.new(expiryX, bandTop + setupAtr * 0.30, "", xloc = xloc.bar_index, style = label.style_label_down, color = stateColor, textcolor = f_text_on(stateColor), size = f_text_size(labelFontSize))
    f_set_label(expiryTag, expiryX, bandTop + setupAtr * 0.30, "Expiry " + str.tostring(maxTrackingBars) + " bars", stateColor, label.style_label_down, f_text_size(labelFontSize))
else
    if not na(expiryLine)
        line.delete(expiryLine)
        expiryLine := na
    if not na(expiryTag)
        label.delete(expiryTag)
        expiryTag := na

if not showPriorBands or priorBandCount == 0
    if array.size(priorBands) > 0
        for idx = 0 to array.size(priorBands) - 1
            box.delete(array.get(priorBands, idx))
        array.clear(priorBands)
    if array.size(priorBadges) > 0
        for idx = 0 to array.size(priorBadges) - 1
            label.delete(array.get(priorBadges, idx))
        array.clear(priorBadges)

// -------------------------------------------------
// Labels
// -------------------------------------------------
labelAbove = hasSetup ? activeLong : true
eventY = labelAbove ? high + safeAtr * labelOffsetAtr : low - safeAtr * labelOffsetAtr
validationY = labelAbove ? high + safeAtr * (labelOffsetAtr + 0.25) : low - safeAtr * (labelOffsetAtr + 0.25)
trackY = labelAbove ? high + safeAtr * (labelOffsetAtr + 0.50) : low - safeAtr * (labelOffsetAtr + 0.50)
terminalY = labelAbove ? high + safeAtr * (labelOffsetAtr + 0.75) : low - safeAtr * (labelOffsetAtr + 0.75)
labelReady = na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars
rapidEventBars = math.max(2, int(math.round(labelCooldownBars * 0.30)))

if showLabels and newTrigger
    textValue = f_label_text("Track Setup", activeLong ? "Long-side setup tracker started" : "Short-side setup tracker started", decayScore)
    trackEventLabel := f_add_label(eventLabels, textValue, trackY, labelAbove, accentColor, "A new setup is being tracked for validation before decay scoring starts.")
    lastEventLabelBar := bar_index

if showLabels and validationEvent
    rapidValidation = not na(trackEventLabel) and bar_index - triggerBar <= rapidEventBars
    if rapidValidation
        trackIndex = array.indexof(eventLabels, trackEventLabel)
        if trackIndex >= 0
            array.remove(eventLabels, trackIndex)
        label.delete(trackEventLabel)
    trackEventLabel := na
    textValue = f_label_text("Setup Valid", "Setup quality is valid enough to start decay tracking", decayScore)
    f_add_label(eventLabels, textValue, validationY, labelAbove, bullColor, "The setup reached the validation travel and quality threshold. Decay tracking is now active.")
    lastEventLabelBar := bar_index

if showLabels and invalidationEvent
    rapidTerminal = not na(reviewEventLabel) and not na(reviewEventBar) and bar_index - reviewEventBar <= rapidEventBars
    if rapidTerminal
        reviewIndex = array.indexof(eventLabels, reviewEventLabel)
        if reviewIndex >= 0
            array.remove(eventLabels, reviewIndex)
        label.delete(reviewEventLabel)
    reviewEventLabel := na
    reviewEventBar := na
    textValue = f_label_text("Invalidated", "Invalidation shelf crossed", decayScore)
    f_add_label(eventLabels, textValue, terminalY, labelAbove, dangerColor, "The tracked setup closed beyond its invalidation shelf inside this rule set.")
    lastEventLabelBar := bar_index

if showLabels and reviewEvent
    textValue = f_label_text("Decay Review", "Setup quality has moved into review context", decayScore)
    reviewEventLabel := f_add_label(eventLabels, textValue, terminalY, labelAbove, bearColor, "The decay score crossed the review threshold. This is an attention marker, not a trade instruction.")
    reviewEventBar := bar_index
    lastEventLabelBar := bar_index

if showLabels and watchEvent and not reviewEvent and labelReady
    textValue = f_label_text("Quality Watch", "Setup quality is starting to fade", decayScore)
    f_add_label(eventLabels, textValue, eventY, labelAbove, neutralColor, "The decay score crossed the watch threshold while the setup remains active.")
    lastEventLabelBar := bar_index

if showLabels and reclaimEvent and labelReady
    textValue = f_label_text("Reclaim", "Trigger side recovered after temporary loss", decayScore)
    f_add_label(eventLabels, textValue, eventY, labelAbove, accentColor, "Price reclaimed the trigger side after losing it. Reclaim context can reduce, but not remove, decay pressure.")
    lastEventLabelBar := bar_index

if showLabels and expiryEvent
    rapidTerminal = not na(reviewEventLabel) and not na(reviewEventBar) and bar_index - reviewEventBar <= rapidEventBars
    if rapidTerminal
        reviewIndex = array.indexof(eventLabels, reviewEventLabel)
        if reviewIndex >= 0
            array.remove(eventLabels, reviewIndex)
        label.delete(reviewEventLabel)
    reviewEventLabel := na
    reviewEventBar := na
    textValue = f_label_text("Expired", "Decay window has matured", decayScore)
    f_add_label(eventLabels, textValue, terminalY, labelAbove, dangerColor, "The active setup reached its expiry condition inside the decay-tracking model.")
    lastEventLabelBar := bar_index

majorEvent = newTrigger or validationEvent or invalidationEvent or reviewEvent or watchEvent or reclaimEvent or expiryEvent
contextReady = (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars) and (na(lastEventLabelBar) or bar_index - lastEventLabelBar >= labelCooldownBars)
contextState = stateText == "Still Valid" or stateText == "Quality Watch" or stateText == "Decay Review" or stateText == "Validating"
minimumContextAge = math.max(2, int(math.round(validationBars * 0.50)))

if showContextLabels and hasSetup and confirmedBar and contextReady and not majorEvent and contextState and (setupValidated or setupAge >= minimumContextAge)
    contextCode = stateText == "Still Valid" ? "Still Valid" : stateText == "Quality Watch" ? "Quality Watch" : stateText == "Decay Review" ? "Decay Review" : "Validation Check"
    textValue = f_label_text(contextCode, "Sparse setup decay context", decayScore)
    f_add_label(eventLabels, textValue, eventY, labelAbove, color.new(stateColor, 0), "Sparse context label showing the active setup decay state and score.")
    lastContextLabelBar := bar_index

plotshape(validationEvent and activeLong, title = "Long Setup Validated", style = shape.circle, location = location.abovebar, color = color.new(bullColor, 0), size = size.tiny, display = display.data_window)
plotshape(validationEvent and not activeLong, title = "Short Setup Validated", style = shape.circle, location = location.belowbar, color = color.new(bullColor, 0), size = size.tiny, display = display.data_window)
plotshape(reviewEvent and activeLong, title = "Long Decay Review", style = shape.diamond, location = location.abovebar, color = color.new(bearColor, 0), size = size.tiny, display = display.data_window)
plotshape(reviewEvent and not activeLong, title = "Short Decay Review", style = shape.diamond, location = location.belowbar, color = color.new(bearColor, 0), size = size.tiny, display = display.data_window)

// -------------------------------------------------
// Data Window
// -------------------------------------------------
plot(decayScore, title = "Decay Score", color = f_decay_color(decayScore), display = display.data_window)
plot(qualityScore, title = "Remaining Setup Quality", color = bullColor, display = display.data_window)
plot(timeRisk, title = "Time Risk", color = neutralColor, display = display.data_window)
plot(followThroughProgress, title = "Follow-Through Progress", color = accentColor, display = display.data_window)
plot(momentumLoss, title = "Momentum Loss", color = bearColor, display = display.data_window)
plot(volatilityLoss, title = "Volatility Loss", color = dangerColor, display = display.data_window)
plot(ftRate, title = "Follow-Through Rate", color = bullColor, display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
panelSize = panelFontSize
panelShell = f_panel_bg(panelTheme)
panelFrame = f_panel_border(panelTheme)
panelValue = f_panel_value(panelTheme)
bullPanelText = panelTheme == "Light" ? color.rgb(5, 105, 88) : bullColor
bearPanelText = panelTheme == "Light" ? color.rgb(190, 24, 93) : bearColor
neutralPanelText = panelTheme == "Light" ? color.rgb(146, 92, 10) : neutralColor
accentPanelText = panelTheme == "Light" ? color.rgb(67, 56, 202) : accentColor
dangerPanelText = panelTheme == "Light" ? color.rgb(185, 28, 28) : dangerColor
statePanelColor = stateColor == bullColor ? bullPanelText : stateColor == bearColor ? bearPanelText : stateColor == neutralColor ? neutralPanelText : stateColor == accentColor ? accentPanelText : stateColor == dangerColor ? dangerPanelText : panelValue
decayPanelColor = decayScore >= expiryDecayScore ? dangerPanelText : decayScore >= reviewDecayScore ? bearPanelText : decayScore >= watchDecayScore ? neutralPanelText : bullPanelText
decayText = hasSetup ? str.tostring(decayScore) + "/100 | " + f_decay_band(decayScore) : "-"
stateRead = hasSetup ? directionText + " | " + str.upper(stateText) : "WAITING"
timeText = hasSetup ? str.tostring(int(math.round(timeRisk))) + "/100" : "-"
followText = hasSetup ? str.tostring(favorableAtr, "#.00") + " / " + str.tostring(followThroughAtr, "#.00") + " ATR" : "-"
invalidationText = hasSetup ? (invalidated ? "BROKEN" : str.tostring(math.abs(close - riskShelf) / setupAtr, "#.00") + " ATR") : "-"
barsRead = hasSetup ? (setupValidated ? str.tostring(effectiveValidAge) + " / " + str.tostring(maxTrackingBars) : str.tostring(effectiveSetupAge) + " / " + str.tostring(validationBars)) : "-"
workflowRead = str.upper(actionText)
followRateCol = na(ftRate) ? panelValue : ftRate >= 60.0 ? bullPanelText : ftRate >= 45.0 ? neutralPanelText : bearPanelText

var table infoPanel = na
var string panelLocationCache = ""
var string panelThemeCache = ""

if not showPanel and not na(infoPanel)
    table.delete(infoPanel)
    infoPanel := na
    panelLocationCache := ""
    panelThemeCache := ""

if showPanel and (na(infoPanel) or panelLocationCache != panelLocation or panelThemeCache != panelTheme)
    if not na(infoPanel)
        table.delete(infoPanel)
    infoPanel := table.new(f_panel_pos(panelLocation), 2, 9, bgcolor = panelShell, frame_color = panelFrame, frame_width = 1, border_color = panelFrame, border_width = 1)
    panelLocationCache := panelLocation
    panelThemeCache := panelTheme

if showPanel and barstate.islast and not na(infoPanel)
    table.clear(infoPanel, 0, 0, 1, 8)
    table.merge_cells(infoPanel, 0, 0, 1, 0)
    table.cell(infoPanel, 0, 0, "AG Pro Setup Decay Tracker", text_color = headerText, bgcolor = headerBg, text_size = f_text_size(panelSize), text_halign = text.align_center)
    f_set_row(infoPanel, 1, "State", stateRead, statePanelColor, panelTheme, panelSize)
    f_set_row(infoPanel, 2, "Decay Score", decayText, decayPanelColor, panelTheme, panelSize)
    f_set_row(infoPanel, 3, "Time Risk", timeText, timeRisk >= 70.0 ? bearPanelText : timeRisk >= 45.0 ? neutralPanelText : panelValue, panelTheme, panelSize)
    f_set_row(infoPanel, 4, "Follow-Through", followText, followThroughProgress >= 70.0 ? bullPanelText : followThroughProgress >= 35.0 ? neutralPanelText : panelValue, panelTheme, panelSize)
    f_set_row(infoPanel, 5, "Target Proof", followRateRead, followRateCol, panelTheme, panelSize)
    f_set_row(infoPanel, 6, "Invalidation", invalidationText, invalidated ? dangerPanelText : panelValue, panelTheme, panelSize)
    f_set_row(infoPanel, 7, "Bars Active", barsRead, accentPanelText, panelTheme, panelSize)
    f_set_row(infoPanel, 8, "Workflow", workflowRead, statePanelColor, panelTheme, panelSize)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(newTrigger, title = "Setup Decay Tracker Started", message = "Setup Decay Tracker: a new setup is being tracked for validation.")
alertcondition(validationEvent, title = "Setup Decay Tracker Validated", message = "Setup Decay Tracker: the setup reached validation quality and decay tracking is active.")
alertcondition(watchEvent, title = "Setup Decay Quality Watch", message = "Setup Decay Tracker: setup quality has moved into watch context.")
alertcondition(reviewEvent, title = "Setup Decay Review", message = "Setup Decay Tracker: decay-review context is active. This is an attention marker, not a trade instruction.")
alertcondition(reclaimEvent, title = "Setup Decay Reclaim", message = "Setup Decay Tracker: price reclaimed the trigger side after temporary loss.")
alertcondition(expiryEvent, title = "Setup Decay Expired", message = "Setup Decay Tracker: the active setup reached its expiry condition.")
alertcondition(invalidationEvent, title = "Setup Decay Invalidated", message = "Setup Decay Tracker: the tracked setup crossed its invalidation shelf.")

if confirmedBar
    lastState := stateText
    lastDecayScore := decayScore
````
