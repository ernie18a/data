# Volatility Cooldown Planner [AGPro Series]

- url: https://www.tradingview.com/script/HkjzYr6T-Volatility-Cooldown-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;ab8b8177844242df826c3e81af030097
- version: 7.0

## Description

Volatility Cooldown Planner [AGPro Series]

🧠 Core Idea

Has volatility cooled down enough to read the chart again?


📌 Overview / What it does

Volatility Cooldown Planner [AGPro Series] is a chart-first volatility risk and readiness tool built for the period after a sharp ATR spike, wide-range candle, or large wick event.

Instead of printing another directional signal, the script asks whether the market is still unstable, cooling, ready for review, or readable again. It produces a spike box, a forward cooldown band, spike rails, unsafe volatility warnings, readiness labels, alerts, and a clean AGPro planning panel.

The script does not predict news events, identify hidden catalysts, automate decisions, or tell users what to buy or sell. Its role is to organize post-spike volatility context into a readable decision workflow.


🎯 Purpose & Design Philosophy

This script was built for traders who often face the same problem after sudden volatility: the chart is active, but not always readable.

Many tools focus on volatility expansion, squeeze release, regime classification, or breakout confirmation. Those can be useful, but they do not always answer the practical question that appears after a spike: should the trader keep reading this structure now, or wait until volatility load normalizes?

The design philosophy is simple: after unstable volatility, the first decision is not direction. The first decision is whether the chart is clean enough to evaluate.


⚡ Why This Script Is Different

Most volatility tools focus on detecting expansion, squeeze release, high ATR regimes, or dramatic candles.

This script does NOT try to detect news events, does not clone a volatility expansion planner, does not act as a stop-run model, and does not classify broad volatility cycles.

Instead, it studies the cooling process after the spike. The main output is a 0-100 Cooldown Score and a next-action state that separates UNSAFE, TOO EARLY, COOLING, READINESS REVIEW, and CHART READABLE conditions.


⚙️ Methodology

1. Spike Detection
The engine identifies spike context using ATR Load, single-bar range expansion, and dominant wick size.

2. Cooldown Mapping
When a spike appears, the script draws a spike box and a forward cooldown band. The band becomes the active review area for post-spike readability.

3. Readiness Evaluation
The model scores ATR load normalization, range contraction, time decay, close-to-close stability, and wick pressure.

4. Visual Output
The planner displays the active state through labels, rails, band color, alert conditions, and a compact AGPro panel.


🗺️ How to Read the Chart

Spike Box = the original volatility shock area.

Cooldown Band = the forward review window where the script evaluates whether volatility is becoming readable again.

Spike Rails = the upper and lower reference boundaries from the spike event. They are volatility context rails, not entry or stop instructions.

Readability Trail = an optional lightweight dot layer for users who want extra chart presence between major labels. It is disabled by default for a cleaner publication preset.

Unsafe Label = volatility has reloaded before cooldown completed.

Ready / Readable Labels = the cooldown score has reached a stronger review state.

Panel = a compact decision view showing Spike State, Cooldown Score, Volatility Load, Readiness, Action, and Best View.


🚦 Signals & States

• SPIKE → a new volatility shock has been registered.

• UNSAFE → volatility reloaded before the cooldown process became stable.

• TOO EARLY → not enough bars have passed after the spike.

• COOLING → volatility is improving, but readiness is not strong enough yet.

• READINESS REVIEW → conditions are strong enough to review the chart again.

• CHART READABLE → ATR load has normalized and the cooldown score is strong.


🔔 Alerts Logic

Volatility Spike Registered triggers when ATR load, range expansion, or wick pressure qualifies as a spike event.

Unsafe Volatility Reload triggers when volatility expands again during the active cooldown window.

Cooldown Readiness Review triggers when the cooldown score reaches the readiness threshold.

Chart Readable After Cooldown triggers when volatility load and cooldown quality both reach the strongest readable state.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The strongest cooldown state appears when multiple conditions align:

ATR load falls toward the target area, recent ranges contract, close-to-close movement stabilizes, wick pressure fades, and enough time has passed after the spike.

When these conditions align, the chart becomes more readable under the script's rules. This does not create certainty or directional prediction.


📊 When to Use

• After sharp ATR spikes

• After wide-range candles

• After large wick events

• After fast liquidation-style movement

• During post-event stabilization

• When the chart feels too unstable to interpret cleanly

• Best visual fit: 4H charts and intraday-swing volatility review

• Daily charts can work for broader context, but they may look more sparse because fewer cooldown events appear


⚠️ When NOT to Use

• Very low-liquidity markets

• Illiquid sessions with unreliable candle structure

• Extreme news volatility where conditions keep changing quickly

• Symbols with irregular gaps or poor feed quality

• As a standalone directional entry system


🎛️ Key Inputs

• Sensitivity → controls how demanding spike detection is.

• ATR Length → normalizes spike size and label offsets.

• ATR Baseline Length → defines the local volatility baseline.

• Cooldown Review Window → controls how long the spike remains under review.

• Cooldown Target ATR Load → defines the internal volatility load target for readability.

• Readiness Score Threshold → defines when the panel can mark readiness review.

• Visual settings → control spike boxes, cooldown bands, rails, markers, and background warnings.

• Readability Trail → optional subtle chart presence during active cooldown or elevated volatility.

• Label and Panel Font Size → control chart labels and panel readability.


🖥️ Interface & Visual Design

The interface is designed to stay chart-first.

The spike box explains where the instability started. The cooldown band shows the active review window. The centered band label gives the current state without forcing the user into a lower-pane dashboard.

The default visual preset keeps the chart calmer by hiding standalone spike event labels, sparse context labels, label scores, readable-upgrade follow-up labels, and the optional readability trail. Users can enable those layers when they want a denser visual review.

The AGPro panel follows the public-release standard with one merged blue header row containing only the panel title. The remaining rows focus on decision context rather than raw data overload, including a Best View row that points users toward the 4H chart when needed.


🧪 Practical Usage Workflow

1. Read the panel Readiness and Action fields.

2. Start with a 4H chart when preparing a visual review or publication screenshot.

3. Check whether the chart is still inside an active cooldown band.

4. Watch Volatility Load and Cooldown Score.

5. Treat UNSAFE as a warning that the chart may still be unstable.

6. Treat READINESS REVIEW or CHART READABLE as a prompt to evaluate broader structure, not as an automatic trade command.


🔍 Interpretation Guidelines

A high cooldown score means volatility has normalized under the script's rule set.

It does not mean price must continue, reverse, or respect the spike rails.

The best use is as a readability filter after unstable movement. It helps the trader decide whether the market is still too hot, cooling, or clean enough to study again.


🚫 What This Script Is NOT

• Not a prediction engine

• Not financial advice

• Not auto trading

• Not guaranteed signals

• Not a news-event detector

• Not a volatility expansion breakout tool

• Not a stop-run or liquidity-sweep model


⚠️ Limitations & Transparency

This script uses standard TradingView OHLCV data and ATR-based measurements.

It cannot identify the real-world cause of volatility. It cannot know whether a spike came from news, liquidation, session flow, thin liquidity, or normal order flow.

Timeframe selection, symbol liquidity, session structure, and volatility regime can affect how quickly cooldown states appear. The default preset is visually best suited to 4H charts; lower timeframes may require stricter inputs, while Daily charts may naturally show fewer events.


🧠 Market Context Notes

Volatility often becomes hardest to interpret immediately after a sharp event.

Some spikes create clean follow-through. Others create unstable noise, whipsaw, or delayed normalization.

This planner focuses on the cooling process, not the directional outcome.


🧾 Use Case Examples

When a wide candle appears and the panel shows UNSAFE, the trader can wait for volatility load to normalize before interpreting follow-through.

When a spike box remains active but the score rises into READINESS REVIEW, the trader can compare the cooldown band with broader structure, trend, liquidity, and personal execution rules.

When the panel reaches CHART READABLE, the market is no longer classified as overheated by the script, but the user still needs independent context.


🧱 System Philosophy

AGPro tools are designed to convert market structure into decision context.

This script follows that philosophy by turning post-spike volatility into a readable workflow: identify the shock, monitor the cooldown, evaluate the readiness state, and avoid treating every fast move as immediately actionable.


🔐 Non-Promise Statement

No script can remove uncertainty.

No cooldown state guarantees that the next move will be clean.

The output is a structured analytical context, not certainty.


📉 Risk Disclosure

Trading involves risk.

Users are responsible for their own analysis, risk management, and decisions.

This script is for educational and analytical use only and does not provide financial advice.


📚 Educational Note

Use the planner to study how volatility behaves after spikes, how long different symbols take to normalize, and how readability changes across timeframes.

## Source Code

````pine
// -------------------------------------------------
// Volatility Cooldown Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.2
//
// Volatility Cooldown Planner is a chart-first volatility risk and readiness
// tool that evaluates whether the market has cooled down after an ATR spike,
// wide-range candle, or large wick event. It converts spike pressure, range
// contraction, time decay, close stability, and volatility load into a 0-100
// cooldown score with a clear NOISY / COOLING / ACTIVE REVIEW / READABLE state
// framework for patient volatility review. Version 2.2 strengthens confirmed
// readiness events, regime-call proof sampling, active-zone lifecycle handling,
// and input safety while preserving the original volatility review workflow.
// -------------------------------------------------

//@version=6
indicator("Volatility Cooldown Planner [AGPro Series]",
     shorttitle       = "AG Pro VCP",
     overlay          = true,
     max_boxes_count  = 40,
     max_lines_count  = 50,
     max_labels_count = 140)

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

// -------------------------------------------------
// Tooltips
// -------------------------------------------------
ttSensitivity = "Controls how demanding the planner is when registering volatility spike context. Strict waits for stronger ATR load, range expansion, or wick pressure."
ttConfirm = "Confirmed Close waits for a closed bar before registering spike and readiness events. Realtime allows earlier chart feedback while the current bar is still forming."
ttAtrLen = "ATR length used to normalize spike size, range load, label offsets, and volatility readiness."
ttAtrBaseLen = "Lookback used to define the local ATR baseline. Volatility Load compares current ATR against this baseline."
ttContractionLen = "Lookback used to measure whether the recent range has contracted after the spike event."
ttStabilityLen = "Lookback used to measure close-to-close stability after the spike. Lower movement improves cooldown quality."
ttAtrSpike = "ATR Load required to register a volatility spike. Higher values reduce spike frequency."
ttRangeSpike = "Single-bar range measured in ATR that can register a spike even when the ATR average has not fully expanded yet."
ttWickSpike = "Dominant wick size measured in ATR that can register unstable volatility context."
ttCooldownWindow = "Number of bars used as the active cooldown review window after a spike."
ttMinCooldown = "Minimum bars that should pass before the planner can show a stronger readiness state."
ttTargetLoad = "ATR Load level considered acceptable for chart readability after a spike. This is an analytical volatility target, not a price target."
ttReadyScore = "Minimum 0-100 cooldown score required before the planner can mark active readiness review."
ttRearm = "Minimum bars before a new spike box can be created. Higher values reduce repeated boxes."
ttSpikeBox = "Shows the original spike box. The active label is displayed as a solid badge for readability."
ttCooldownBand = "Shows the forward cooldown band where the market is being evaluated for readability."
ttRails = "Shows the upper and lower spike rails used as volatility reference boundaries. They are not trade entry or stop instructions."
ttRailTags = "Shows solid right-edge tags attached to the active spike high and low rails. Historical rail tags are not retained, which keeps the chart cleaner."
ttUnsafeBg = "Adds a subtle background warning when volatility reloads before cooldown is complete. Disabled by default for cleaner publication screenshots."
ttBandOpacity = "Controls cooldown band transparency. Higher values make the band lighter and keep candle structure easier to read."
ttReadabilityTrail = "Shows a lightweight dotted readiness trail during active cooldown or elevated volatility."
ttTrailSpacing = "Controls spacing between readability trail dots."
ttLabels = "Shows the main noisy, active review, and readable labels. Labels are offset away from candles for cleaner screenshots."
ttSpikeLabels = "Shows standalone SPIKE labels above volatility events. Disabled by default because the spike box already marks the event."
ttReadableUpgrade = "Shows a second READABLE label if an active cooldown first prints ACTIVE REVIEW and later improves. Disabled by default for a cleaner publication preset."
ttContextLabels = "Adds sparse context labels during the active cooldown window. Disabled by default for a cleaner public-release chart."
ttSmallMarkers = "Shows small markers for spike and readiness events. Disabled by default because labels carry the main visual story."
ttLabelCooldown = "Minimum bars between major event labels. Higher values reduce visual repetition in noisy markets."
ttContextSpacing = "Minimum bars between sparse cooldown context labels."
ttMaxLabels = "Maximum number of visible event labels retained. Older labels are removed first for performance."
ttMaxZones = "Maximum number of spike and cooldown visual structures retained on the chart."
ttLabelOffset = "ATR-based vertical offset used to keep labels above or below candle bodies and wicks."
ttLabelScore = "Adds the 0-100 cooldown score to readiness and context labels."
ttLabelSize = "Font size for all on-chart labels and solid zone badges. Normal is the default publication setting."
ttShowPanel = "Shows or hides the AG Pro planning panel. It is shown by default for public-release readability."
ttPanelLocation = "Moves the AG Pro panel to the preferred chart location."
ttPanelTheme = "Switches the panel between AGPro dark and clean light themes."
ttPanelFont = "Font size for the AG Pro panel. Normal is the recommended publication default."
ttAlerts = "Enables alert conditions for spike, noisy reload, active review, and chart-readable states."
ttShowProof = "Shows the confirmation-anchored proof layer in the panel: Follow, Hold, React, and Flip rates that measure how stable the calm and noisy volatility regimes identified by this planner have been on the current symbol and timeframe. Follow and Hold mean the regime persisted; Flip means it changed within the horizon. These are historical stability rates, not predictions."
ttProofHorizon = "Number of bars each volatility-regime window is tracked forward to measure whether the calm or noisy classification persisted or flipped."
ttReactBars = "Number of bars a regime must persist after a window opens to count as an early React (short-term stability)."

// -------------------------------------------------
// Inputs
// -------------------------------------------------
groupEngine = "Volatility Spike Engine"
sensitivityInput = input.string("Balanced", "Sensitivity", options = ["Responsive", "Balanced", "Strict"], group = groupEngine, tooltip = ttSensitivity)
confirmationMode = input.string("Confirmed Close", "Confirmation Mode", options = ["Confirmed Close", "Realtime"], group = groupEngine, tooltip = ttConfirm)
atrLen = input.int(14, "ATR Length", minval = 5, maxval = 100, group = groupEngine, tooltip = ttAtrLen)
atrBaseLen = input.int(55, "ATR Baseline Length", minval = 10, maxval = 300, group = groupEngine, tooltip = ttAtrBaseLen)
contractionLen = input.int(8, "Range Contraction Lookback", minval = 2, maxval = 60, group = groupEngine, tooltip = ttContractionLen)
stabilityLen = input.int(5, "Close Stability Lookback", minval = 2, maxval = 50, group = groupEngine, tooltip = ttStabilityLen)

groupSpike = "Spike Qualification"
atrSpikeMultiplier = input.float(1.55, "ATR Spike Load", minval = 1.05, maxval = 4.00, step = 0.05, group = groupSpike, tooltip = ttAtrSpike)
rangeSpikeAtr = input.float(1.65, "Range Spike ATR", minval = 0.50, maxval = 6.00, step = 0.05, group = groupSpike, tooltip = ttRangeSpike)
wickSpikeAtr = input.float(0.82, "Wick Spike ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupSpike, tooltip = ttWickSpike)
spikeRearmBars = input.int(24, "Spike Re-Arm Bars", minval = 1, maxval = 100, group = groupSpike, tooltip = ttRearm)

groupScoring = "Cooldown Readiness"
cooldownWindow = input.int(28, "Cooldown Review Window", minval = 8, maxval = 120, group = groupScoring, tooltip = ttCooldownWindow)
minimumCooldownBars = input.int(5, "Minimum Cooldown Bars", minval = 1, maxval = 40, group = groupScoring, tooltip = ttMinCooldown)
targetAtrLoad = input.float(1.12, "Cooldown Target ATR Load", minval = 0.60, maxval = 2.50, step = 0.02, group = groupScoring, tooltip = ttTargetLoad)
minimumReadyScore = input.int(70, "Readiness Score Threshold", minval = 40, maxval = 95, group = groupScoring, tooltip = ttReadyScore)

groupVisual = "Chart Visuals"
showSpikeBox = input.bool(true, "Show Spike Box", group = groupVisual, tooltip = ttSpikeBox)
showCooldownBand = input.bool(true, "Show Cooldown Band", group = groupVisual, tooltip = ttCooldownBand)
showReadabilityRails = input.bool(true, "Show Spike Rails", group = groupVisual, tooltip = ttRails)
showRailTags = input.bool(true, "Show Rail Tags", group = groupVisual, tooltip = ttRailTags)
railTagOffsetBars = input.int(1, "Rail Tag Offset Bars", minval = 1, maxval = 40, group = groupVisual, tooltip = "Horizontal offset added beyond the cooldown window for the active high and low rail tags.")
showUnsafeBackground = input.bool(false, "Show Noisy Volatility Background", group = groupVisual, tooltip = ttUnsafeBg)
showSmallMarkers = input.bool(false, "Show Small Markers", group = groupVisual, tooltip = ttSmallMarkers)
showReadabilityTrail = input.bool(true, "Show Readability Trail", group = groupVisual, tooltip = ttReadabilityTrail)
trailSpacingBars = input.int(12, "Readability Trail Spacing", minval = 1, maxval = 24, group = groupVisual, tooltip = ttTrailSpacing)
boxTransparency = input.int(89, "Band Transparency", minval = 72, maxval = 96, group = groupVisual, tooltip = ttBandOpacity)

groupLabels = "Labels"
showEventLabels = input.bool(true, "Show Event Labels", group = groupLabels, tooltip = ttLabels)
showSpikeEventLabels = input.bool(false, "Show Spike Event Labels", group = groupLabels, tooltip = ttSpikeLabels)
showReadableUpgradeLabels = input.bool(false, "Show Readable Upgrade Labels", group = groupLabels, tooltip = ttReadableUpgrade)
showContextLabels = input.bool(false, "Show Sparse Context Labels", group = groupLabels, tooltip = ttContextLabels)
labelCooldownBars = input.int(34, "Label Cooldown Bars", minval = 1, maxval = 120, group = groupLabels, tooltip = ttLabelCooldown)
contextSpacingBars = input.int(96, "Context Label Spacing", minval = 4, maxval = 180, group = groupLabels, tooltip = ttContextSpacing)
maxVisibleLabels = input.int(8, "Max Visible Labels", minval = 3, maxval = 80, group = groupLabels, tooltip = ttMaxLabels)
maxVisibleZones = input.int(1, "Max Visible Zones", minval = 1, maxval = 20, group = groupLabels, tooltip = ttMaxZones)
labelOffsetAtr = input.float(1.05, "Label Offset ATR", minval = 0.10, maxval = 4.00, step = 0.05, group = groupLabels, tooltip = ttLabelOffset)
showLabelScore = input.bool(true, "Show Label Score", group = groupLabels, tooltip = ttLabelScore)
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupLabels, tooltip = ttLabelSize)

groupPanel = "Panel"
showPanel = input.bool(true, "Show Panel", group = groupPanel, tooltip = ttShowPanel)
panelLocationInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = groupPanel, tooltip = ttPanelLocation)
panelThemeInput = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Clean Light"], group = groupPanel, tooltip = ttPanelTheme)
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = groupPanel, tooltip = ttPanelFont)

groupProof = "Proof"
showProof = input.bool(true, "Show Proof Layer", group = groupProof, tooltip = ttShowProof)
proofHorizonBars = input.int(24, "Proof Horizon Bars", minval = 5, maxval = 240, group = groupProof, tooltip = ttProofHorizon)
reactBars = input.int(3, "Reaction Window Bars", minval = 1, maxval = 60, group = groupProof, tooltip = ttReactBars)

groupAlerts = "Alerts"
alertCooldownStates = input.bool(true, "Alert on Cooldown States", group = groupAlerts, tooltip = ttAlerts)

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

f_label_size(string sizeText) =>
    switch sizeText
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posText) =>
    switch posText
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_panel_bg(string theme, bool alt) =>
    theme == "Clean Light" ? (alt ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : (alt ? color.rgb(20, 31, 52) : panelBg)

f_panel_border(string theme) =>
    theme == "Clean Light" ? color.rgb(148, 163, 184) : panelBorder

f_panel_label(string theme) =>
    theme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value(string theme) =>
    theme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_score_text(float score) =>
    na(score) ? "n/a" : str.tostring(int(math.round(score)))

f_pct(float value) =>
    str.tostring(int(math.round(value))) + "%"

f_rate_color(float value) =>
    value >= 55 ? bullColor : value >= 40 ? neutralColor : bearColor

f_flip_color(float value) =>
    value <= 30 ? bullColor : value <= 55 ? neutralColor : bearColor

f_ratio_text(float ratioValue) =>
    na(ratioValue) ? "n/a" : str.tostring(ratioValue, "#.##") + "x"

f_tier_text(float score) =>
    na(score) ? "n/a" : score >= 84 ? "A" : score >= 72 ? "B" : score >= 58 ? "C" : "D"

f_state_color(string stateText) =>
    switch stateText
        "CHART READABLE" => bullColor
        "ACTIVE REVIEW" => accentColor
        "NOISY" => bearColor
        "TOO EARLY" => neutralColor
        "COOLING" => neutralColor
        => panelValueCol

f_band_color(string stateText) =>
    switch stateText
        "CHART READABLE" => bullColor
        "ACTIVE REVIEW" => accentColor
        "NOISY" => bearColor
        "TOO EARLY" => neutralColor
        "COOLING" => neutralColor
        => panelLabelCol

f_action_text(string stateText) =>
    switch stateText
        "NOISY" => "Stand Aside"
        "TOO EARLY" => "Let Spike Cool"
        "COOLING" => "Wait Stability"
        "ACTIVE REVIEW" => "Review Chart"
        "CHART READABLE" => "Read Context"
        => "Monitor"

f_zone_text(string stateText, float scoreValue) =>
    compactState = stateText == "CHART READABLE" ? "READABLE" : stateText == "ACTIVE REVIEW" ? "ACTIVE\nREVIEW" : stateText
    compactState + "\n" + f_score_text(scoreValue)

f_panel_row(table panelId, int row, string leftText, string rightText, color rightColor, string theme, string fontSize) =>
    rowBg = f_panel_bg(theme, row % 2 == 0)
    table.cell(panelId, 0, row, leftText, text_color = f_panel_label(theme), bgcolor = rowBg, text_size = f_label_size(fontSize))
    table.cell(panelId, 1, row, rightText, text_color = rightColor, bgcolor = rowBg, text_size = f_label_size(fontSize), text_halign = text.align_right)

f_keep_label(array<label> labelArray, label labelId, int maxCount) =>
    array.push(labelArray, labelId)
    while array.size(labelArray) > maxCount
        oldLabel = array.shift(labelArray)
        label.delete(oldLabel)

f_keep_box(array<box> boxArray, box boxId, int maxCount) =>
    array.push(boxArray, boxId)
    while array.size(boxArray) > maxCount
        oldBox = array.shift(boxArray)
        box.delete(oldBox)

f_keep_line(array<line> lineArray, line lineId, int maxCount) =>
    array.push(lineArray, lineId)
    while array.size(lineArray) > maxCount
        oldLine = array.shift(lineArray)
        line.delete(oldLine)

f_delete_label(label item) =>
    if not na(item)
        label.delete(item)

// -------------------------------------------------
// Core calculations
// -------------------------------------------------
confirmedOk = confirmationMode == "Realtime" or barstate.isconfirmed
hasPrevBar = not na(close[1])

atr = ta.atr(atrLen)
safeAtr = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
atrBaseRaw = ta.sma(atr, atrBaseLen)
atrBase = not na(atrBaseRaw) and atrBaseRaw > 0.0 ? atrBaseRaw : safeAtr
barRange = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
dominantWick = math.max(upperWick, lowerWick)
atrLoad = safeAtr / math.max(atrBase, syminfo.mintick)
rangeAtr = barRange / safeAtr
wickAtr = dominantWick / safeAtr
closeMoveAtr = hasPrevBar ? math.abs(close - close[1]) / safeAtr : 0.0
rangeSma = nz(ta.sma(barRange, contractionLen), barRange)
stabilityMove = nz(ta.sma(closeMoveAtr, stabilityLen), closeMoveAtr)

sensitivityFactor = sensitivityInput == "Responsive" ? 0.90 : sensitivityInput == "Strict" ? 1.12 : 1.0
rawAtrSpikeGate = atrSpikeMultiplier * sensitivityFactor
effectiveTargetAtrLoad = math.min(targetAtrLoad, math.max(rawAtrSpikeGate - 0.05, 0.05))
atrSpikeGate = math.max(rawAtrSpikeGate, effectiveTargetAtrLoad + 0.05)
rangeSpikeGate = rangeSpikeAtr * sensitivityFactor
wickSpikeGate = wickSpikeAtr * sensitivityFactor
readyGate = f_clamp(minimumReadyScore + (sensitivityInput == "Strict" ? 4.0 : sensitivityInput == "Responsive" ? -4.0 : 0.0), 40.0, 95.0)
readableGate = math.min(100.0, readyGate + 8.0)
reloadGate = math.max(atrSpikeGate * 0.92, effectiveTargetAtrLoad + 0.18)
effectiveCooldownWindow = math.max(cooldownWindow, 2)
effectiveMinimumCooldownBars = math.min(minimumCooldownBars, effectiveCooldownWindow - 1)
engineWarmup = math.max(atrBaseLen + atrLen, math.max(contractionLen, stabilityLen)) + 2
engineReady = bar_index > engineWarmup

atrSpike = atrLoad >= atrSpikeGate
rangeSpike = rangeAtr >= rangeSpikeGate
wickSpike = wickAtr >= wickSpikeGate
spikeCandidate = confirmedOk and engineReady and (atrSpike or rangeSpike or wickSpike)

// -------------------------------------------------
// Confirmation-anchored proof (volatility-regime persistence)
// -------------------------------------------------
var int proofTotal = 0
var int proofFollow = 0
var int proofHold = 0
var int proofReact = 0
var int proofFlip = 0
var bool pEvalActive = false
var bool proofSeeded = false
var int pEvalState = 0
var int pEvalStart = na
var bool pReacted = false
var bool pFollowed = false

bool regimeNoisyVol = atrLoad >= reloadGate or rangeAtr >= rangeSpikeGate or wickAtr >= wickSpikeGate
int volRegimeState = regimeNoisyVol ? 1 : 0
int proofWarmup = math.max(engineWarmup, atrBaseLen + atrLen + 5)
int effectiveReactBars = math.min(reactBars, math.max(proofHorizonBars - 1, 1))
int proofFollowBars = math.min(proofHorizonBars, math.max(effectiveReactBars + 1, int(math.round(proofHorizonBars * 0.5))))

if barstate.isconfirmed and bar_index > proofWarmup
    bool regimeChanged = pEvalActive and volRegimeState != pEvalState

    if pEvalActive
        int heldBars = bar_index - pEvalStart

        if not regimeChanged and heldBars >= effectiveReactBars
            pReacted := true
        if not regimeChanged and heldBars >= proofFollowBars
            pFollowed := true

        bool horizonDone = heldBars >= proofHorizonBars
        if regimeChanged or horizonDone
            proofTotal := proofTotal + 1
            if pFollowed
                proofFollow := proofFollow + 1
            if horizonDone and not regimeChanged
                proofHold := proofHold + 1
            if pReacted
                proofReact := proofReact + 1
            if regimeChanged
                proofFlip := proofFlip + 1
            pEvalActive := false

    // Seed the first valid regime once. Subsequent samples begin only when the
    // confirmed binary volatility regime changes, preventing repeated sampling
    // of one unchanged regime after every completed horizon.
    bool confirmedRegimeCall = not proofSeeded or volRegimeState != nz(volRegimeState[1], volRegimeState)
    if confirmedRegimeCall and not pEvalActive
        pEvalActive := true
        proofSeeded := true
        pEvalState := volRegimeState
        pEvalStart := bar_index
        pReacted := false
        pFollowed := false

float followRate = proofTotal > 0 ? proofFollow * 100.0 / proofTotal : 0.0
float holdRate = proofTotal > 0 ? proofHold * 100.0 / proofTotal : 0.0
float reactRate = proofTotal > 0 ? proofReact * 100.0 / proofTotal : 0.0
float flipRate = proofTotal > 0 ? proofFlip * 100.0 / proofTotal : 0.0

// -------------------------------------------------
// Active spike context
// -------------------------------------------------
var int activeSpikeBar = na
var float activeSpikeHigh = na
var float activeSpikeLow = na
var float activeSpikeRange = na
var float activeSpikeAtrLoad = na
var bool activeReviewPrinted = false
var bool activeReadablePrinted = false
var int lastSpikeBar = na
var int lastContextLabelBar = na
var int lastNoisyAlertBar = na

var box activeSpikeBox = na
var box activeCooldownBox = na
var line activeUpperRail = na
var line activeLowerRail = na
var label activeSpikeBadge = na
var label activeCooldownBadge = na
var label upperRailTag = na
var label lowerRailTag = na

var array<label> eventLabels = array.new_label()
var array<label> zoneLabels = array.new_label()
var array<box> visualBoxes = array.new_box()
var array<line> visualLines = array.new_line()

hasActiveBeforeNew = not na(activeSpikeBar) and bar_index - activeSpikeBar <= effectiveCooldownWindow
canOpenSpike = na(lastSpikeBar) or bar_index - lastSpikeBar >= spikeRearmBars or not hasActiveBeforeNew
newSpikeSignal = spikeCandidate and canOpenSpike

if newSpikeSignal
    f_delete_label(upperRailTag)
    f_delete_label(lowerRailTag)
    activeSpikeBox := na
    activeCooldownBox := na
    activeUpperRail := na
    activeLowerRail := na
    activeSpikeBadge := na
    activeCooldownBadge := na
    upperRailTag := na
    lowerRailTag := na
    activeSpikeBar := bar_index
    activeSpikeHigh := high
    activeSpikeLow := low
    activeSpikeRange := barRange
    activeSpikeAtrLoad := atrLoad
    activeReviewPrinted := false
    activeReadablePrinted := false
    lastSpikeBar := bar_index

    boxPad = safeAtr * 0.08
    spikeTop = activeSpikeHigh + boxPad
    spikeBottom = activeSpikeLow - boxPad
    cooldownRight = bar_index + effectiveCooldownWindow

    if showSpikeBox
        activeSpikeBox := box.new(left = bar_index, top = spikeTop, right = bar_index + 2, bottom = spikeBottom, xloc = xloc.bar_index, border_color = color.new(neutralColor, 28), bgcolor = color.new(neutralColor, 90), border_width = 1)
        f_keep_box(visualBoxes, activeSpikeBox, maxVisibleZones * 2)

    if showCooldownBand
        activeCooldownBox := box.new(left = bar_index, top = spikeTop, right = cooldownRight, bottom = spikeBottom, xloc = xloc.bar_index, border_color = color.new(accentColor, 48), bgcolor = color.new(accentColor, boxTransparency), border_width = 1)
        f_keep_box(visualBoxes, activeCooldownBox, maxVisibleZones * 2)

    if showReadabilityRails
        railRight = cooldownRight + 1
        activeUpperRail := line.new(x1 = bar_index, y1 = activeSpikeHigh, x2 = railRight, y2 = activeSpikeHigh, xloc = xloc.bar_index, color = color.new(bearColor, 18), style = line.style_dashed, width = 2)
        activeLowerRail := line.new(x1 = bar_index, y1 = activeSpikeLow, x2 = railRight, y2 = activeSpikeLow, xloc = xloc.bar_index, color = color.new(bullColor, 18), style = line.style_dashed, width = 2)
        f_keep_line(visualLines, activeUpperRail, maxVisibleZones * 2)
        f_keep_line(visualLines, activeLowerRail, maxVisibleZones * 2)

hasActiveSpike = not na(activeSpikeBar) and bar_index - activeSpikeBar <= effectiveCooldownWindow
barsSinceSpike = hasActiveSpike ? bar_index - activeSpikeBar : na
contractionRatio = hasActiveSpike and activeSpikeRange > 0.0 ? rangeSma / activeSpikeRange : na
loadScore = hasActiveSpike ? f_norm_low_good(atrLoad, effectiveTargetAtrLoad, atrSpikeGate) : na
contractionScore = hasActiveSpike ? f_norm_low_good(contractionRatio, 0.34, 0.92) : na
timeScore = hasActiveSpike ? f_norm_high_good(barsSinceSpike * 1.0, effectiveMinimumCooldownBars * 1.0, effectiveCooldownWindow * 1.0) : na
stabilityScore = hasActiveSpike ? f_norm_low_good(stabilityMove, 0.10, 0.85) : na
wickScore = hasActiveSpike ? f_norm_low_good(wickAtr, 0.10, wickSpikeGate) : na
cooldownScoreRaw = hasActiveSpike ? loadScore * 0.32 + contractionScore * 0.24 + timeScore * 0.18 + stabilityScore * 0.16 + wickScore * 0.10 : na
cooldownScore = hasActiveSpike ? f_clamp(cooldownScoreRaw, 0.0, 100.0) : na

reloadRisk = hasActiveSpike and barsSinceSpike > 0 and (atrLoad >= reloadGate or rangeAtr >= rangeSpikeGate or wickAtr >= wickSpikeGate)
tooEarly = hasActiveSpike and barsSinceSpike < effectiveMinimumCooldownBars
chartReadable = hasActiveSpike and not reloadRisk and not tooEarly and cooldownScore >= readableGate and atrLoad <= effectiveTargetAtrLoad
activeReview = hasActiveSpike and not reloadRisk and not tooEarly and cooldownScore >= readyGate

readinessState = not hasActiveSpike ? "NO SPIKE" : reloadRisk ? "NOISY" : tooEarly ? "TOO EARLY" : chartReadable ? "CHART READABLE" : activeReview ? "ACTIVE REVIEW" : "COOLING"
spikeStateText = hasActiveSpike ? "Spike " + str.tostring(barsSinceSpike) + " bars ago" : "No active spike"
loadStateText = atrLoad >= reloadGate ? "Reload" : atrLoad > effectiveTargetAtrLoad + 0.18 ? "High" : atrLoad > effectiveTargetAtrLoad ? "Cooling" : "Normal"
actionText = f_action_text(readinessState)

reviewSignal = confirmedOk and hasActiveSpike and not activeReviewPrinted and (readinessState == "ACTIVE REVIEW" or readinessState == "CHART READABLE")
readableSignal = confirmedOk and hasActiveSpike and not activeReadablePrinted and readinessState == "CHART READABLE"
noisySignal = confirmedOk and reloadRisk and (na(lastNoisyAlertBar) or bar_index - lastNoisyAlertBar >= labelCooldownBars)
coolingContextSignal = confirmedOk and hasActiveSpike and showContextLabels and readinessState != "NOISY" and readinessState != "CHART READABLE" and not reviewSignal and (na(lastContextLabelBar) or bar_index - lastContextLabelBar >= contextSpacingBars)

if reviewSignal
    activeReviewPrinted := true

if readableSignal
    activeReadablePrinted := true

if noisySignal
    lastNoisyAlertBar := bar_index

// -------------------------------------------------
// Visual updates
// -------------------------------------------------
if hasActiveSpike
    stateColor = f_band_color(readinessState)
    zoneText = f_zone_text(readinessState, cooldownScore)
    pad = safeAtr * 0.08
    activeTop = activeSpikeHigh + pad
    activeBottom = activeSpikeLow - pad
    zoneMid = (activeTop + activeBottom) * 0.5
    cooldownRight = activeSpikeBar + effectiveCooldownWindow
    upperRailTagX = cooldownRight + railTagOffsetBars
    lowerRailTagX = upperRailTagX + 3
    badgeX = activeSpikeBar + int(math.round(effectiveCooldownWindow * 0.55))

    if not na(activeCooldownBox)
        box.set_right(activeCooldownBox, cooldownRight)
        box.set_top(activeCooldownBox, activeTop)
        box.set_bottom(activeCooldownBox, activeBottom)
        box.set_bgcolor(activeCooldownBox, color.new(stateColor, boxTransparency))
        box.set_border_color(activeCooldownBox, color.new(stateColor, readinessState == "NOISY" ? 18 : 44))

    if not na(activeSpikeBox)
        box.set_top(activeSpikeBox, activeTop)
        box.set_bottom(activeSpikeBox, activeBottom)
        box.set_border_color(activeSpikeBox, color.new(neutralColor, 28))

    if na(activeCooldownBadge)
        activeCooldownBadge := label.new(badgeX, zoneMid, zoneText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.new(stateColor, 0), textcolor = readinessState == "TOO EARLY" or readinessState == "COOLING" ? color.rgb(15, 23, 42) : headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        f_keep_label(zoneLabels, activeCooldownBadge, maxVisibleZones * 2)
    else
        label.set_xy(activeCooldownBadge, badgeX, zoneMid)
        label.set_text(activeCooldownBadge, zoneText)
        label.set_color(activeCooldownBadge, color.new(stateColor, 0))
        label.set_textcolor(activeCooldownBadge, readinessState == "TOO EARLY" or readinessState == "COOLING" ? color.rgb(15, 23, 42) : headerText)
        label.set_size(activeCooldownBadge, f_label_size(labelSizeInput))

    if na(activeSpikeBadge)
        activeSpikeBadge := label.new(activeSpikeBar, activeTop, "SPIKE\n" + f_ratio_text(activeSpikeAtrLoad), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_down, color = color.new(neutralColor, 0), textcolor = color.rgb(15, 23, 42), size = f_label_size(labelSizeInput), textalign = text.align_center)
        f_keep_label(zoneLabels, activeSpikeBadge, maxVisibleZones * 2)
    else
        label.set_xy(activeSpikeBadge, activeSpikeBar, activeTop)
        label.set_text(activeSpikeBadge, "SPIKE\n" + f_ratio_text(activeSpikeAtrLoad))
        label.set_color(activeSpikeBadge, color.new(neutralColor, 0))
        label.set_textcolor(activeSpikeBadge, color.rgb(15, 23, 42))
        label.set_size(activeSpikeBadge, f_label_size(labelSizeInput))

    if not na(activeUpperRail)
        line.set_x2(activeUpperRail, upperRailTagX)
        line.set_y1(activeUpperRail, activeSpikeHigh)
        line.set_y2(activeUpperRail, activeSpikeHigh)
        line.set_color(activeUpperRail, color.new(bearColor, readinessState == "NOISY" ? 8 : 20))
        line.set_width(activeUpperRail, 2)

    if not na(activeLowerRail)
        line.set_x2(activeLowerRail, lowerRailTagX)
        line.set_y1(activeLowerRail, activeSpikeLow)
        line.set_y2(activeLowerRail, activeSpikeLow)
        line.set_color(activeLowerRail, color.new(bullColor, readinessState == "CHART READABLE" ? 8 : 20))
        line.set_width(activeLowerRail, 2)

    if showRailTags and showReadabilityRails
        upperText = "High rail\n" + str.tostring(activeSpikeHigh, format.mintick)
        lowerText = "Low rail\n" + str.tostring(activeSpikeLow, format.mintick)
        if na(upperRailTag)
            upperRailTag := label.new(upperRailTagX, activeSpikeHigh, upperText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bearColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(upperRailTag, upperRailTagX, activeSpikeHigh)
            label.set_text(upperRailTag, upperText)
            label.set_color(upperRailTag, color.new(bearColor, 0))
            label.set_textcolor(upperRailTag, headerText)
            label.set_size(upperRailTag, f_label_size(labelSizeInput))
        if na(lowerRailTag)
            lowerRailTag := label.new(lowerRailTagX, activeSpikeLow, lowerText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(bullColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
        else
            label.set_xy(lowerRailTag, lowerRailTagX, activeSpikeLow)
            label.set_text(lowerRailTag, lowerText)
            label.set_color(lowerRailTag, color.new(bullColor, 0))
            label.set_textcolor(lowerRailTag, headerText)
            label.set_size(lowerRailTag, f_label_size(labelSizeInput))
    else
        f_delete_label(upperRailTag)
        f_delete_label(lowerRailTag)
        upperRailTag := na
        lowerRailTag := na
else
    f_delete_label(upperRailTag)
    f_delete_label(lowerRailTag)
    activeSpikeBox := na
    activeCooldownBox := na
    activeUpperRail := na
    activeLowerRail := na
    activeSpikeBadge := na
    activeCooldownBadge := na
    upperRailTag := na
    lowerRailTag := na

if showEventLabels and showSpikeEventLabels and newSpikeSignal
    spikeY = high + safeAtr * labelOffsetAtr
    spikeLabel = label.new(bar_index, spikeY, "SPIKE\n" + f_ratio_text(atrLoad), xloc = xloc.bar_index, style = label.style_label_down, color = color.new(neutralColor, 0), textcolor = color.rgb(15, 23, 42), size = f_label_size(labelSizeInput), textalign = text.align_center)
    f_keep_label(eventLabels, spikeLabel, maxVisibleLabels)

if showEventLabels and noisySignal
    noisyY = high + safeAtr * labelOffsetAtr
    noisyLabel = label.new(bar_index, noisyY, "NOISY\n" + f_ratio_text(atrLoad), xloc = xloc.bar_index, style = label.style_label_down, color = color.new(bearColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    f_keep_label(eventLabels, noisyLabel, maxVisibleLabels)

if showEventLabels and reviewSignal
    readyY = low - safeAtr * labelOffsetAtr
    readyText = readinessState == "CHART READABLE" ? "READABLE" : "ACTIVE\nREVIEW"
    readyText := showLabelScore ? readyText + "\n" + f_score_text(cooldownScore) : readyText
    readyLabel = label.new(bar_index, readyY, readyText, xloc = xloc.bar_index, style = label.style_label_up, color = color.new(f_state_color(readinessState), 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    f_keep_label(eventLabels, readyLabel, maxVisibleLabels)

if showEventLabels and showReadableUpgradeLabels and readableSignal and not reviewSignal
    readableY = low - safeAtr * labelOffsetAtr
    readableText = showLabelScore ? "READABLE\n" + f_score_text(cooldownScore) : "READABLE"
    readableLabel = label.new(bar_index, readableY, readableText, xloc = xloc.bar_index, style = label.style_label_up, color = color.new(bullColor, 0), textcolor = headerText, size = f_label_size(labelSizeInput), textalign = text.align_center)
    f_keep_label(eventLabels, readableLabel, maxVisibleLabels)

if coolingContextSignal
    contextY = high + safeAtr * (labelOffsetAtr * 0.85)
    contextText = readinessState == "TOO EARLY" ? "EARLY" : "COOLING"
    contextText := showLabelScore ? contextText + "\n" + f_score_text(cooldownScore) : contextText
    contextLabel = label.new(bar_index, contextY, contextText, xloc = xloc.bar_index, style = label.style_label_down, color = color.new(f_state_color(readinessState), 0), textcolor = color.rgb(15, 23, 42), size = f_label_size(labelSizeInput), textalign = text.align_center)
    f_keep_label(eventLabels, contextLabel, maxVisibleLabels)
    lastContextLabelBar := bar_index

plotshape(showSmallMarkers and newSpikeSignal, title = "Volatility Spike Marker", style = shape.diamond, location = location.abovebar, color = color.new(neutralColor, 0), size = size.tiny)
plotshape(showSmallMarkers and reviewSignal, title = "Cooldown Review Marker", style = shape.diamond, location = location.belowbar, color = color.new(f_state_color(readinessState), 0), size = size.tiny)

trailActive = showReadabilityTrail and hasActiveSpike and bar_index % trailSpacingBars == 0
trailAbove = readinessState == "NOISY" or loadStateText == "Reload"
trailY = trailAbove ? high + safeAtr * (labelOffsetAtr * 0.38) : low - safeAtr * (labelOffsetAtr * 0.38)
trailColor = hasActiveSpike ? f_state_color(readinessState) : atrLoad > reloadGate ? bearColor : atrLoad > effectiveTargetAtrLoad ? neutralColor : accentColor
plot(trailActive ? trailY : na, title = "Cooldown Readability Trail", color = color.new(trailColor, 12), style = plot.style_circles, linewidth = 2)
bgcolor(showUnsafeBackground and readinessState == "NOISY" ? color.new(bearColor, 92) : na)

// -------------------------------------------------
// Data window
// -------------------------------------------------
plot(cooldownScore, title = "Cooldown Score", color = f_state_color(readinessState), display = display.data_window)
plot(atrLoad, title = "ATR Load", color = atrLoad >= reloadGate ? bearColor : neutralColor, display = display.data_window)
plot(rangeAtr, title = "Range ATR", color = accentColor, display = display.data_window)
plot(stabilityMove, title = "Close Stability ATR", color = bullColor, display = display.data_window)
plot(followRate, title = "Follow Rate", display = display.data_window)
plot(holdRate, title = "Hold Rate", display = display.data_window)
plot(reactRate, title = "React Rate", display = display.data_window)
plot(flipRate, title = "Flip Rate", display = display.data_window)
plot(volRegimeState, title = "Volatility Regime State", display = display.data_window)
plot(hasActiveSpike ? barsSinceSpike : na, title = "Bars Since Spike", display = display.data_window)
plot(hasActiveSpike ? contractionRatio : na, title = "Contraction Ratio", display = display.data_window)

// -------------------------------------------------
// Panel
// -------------------------------------------------
int panelRowCount = showProof ? 13 : 8
var table panel = table.new(position.top_right, 2, panelRowCount, bgcolor = panelBg, frame_color = panelBorder, frame_width = 1, border_width = 1, border_color = panelBorder)
var bool panelHeaderMerged = false

if not panelHeaderMerged
    table.merge_cells(panel, 0, 0, 1, 0)
    panelHeaderMerged := true

proofSampleText = proofTotal > 0 ? "n = " + str.tostring(proofTotal) : "building"
followText = proofTotal > 0 ? f_pct(followRate) : "-"
holdText = proofTotal > 0 ? f_pct(holdRate) : "-"
reactText = proofTotal > 0 ? f_pct(reactRate) : "-"
flipText = proofTotal > 0 ? f_pct(flipRate) : "-"
followCol = proofTotal > 0 ? f_rate_color(followRate) : f_panel_value(panelThemeInput)
holdCol = proofTotal > 0 ? f_rate_color(holdRate) : f_panel_value(panelThemeInput)
reactCol = proofTotal > 0 ? f_rate_color(reactRate) : f_panel_value(panelThemeInput)
flipCol = proofTotal > 0 ? f_flip_color(flipRate) : f_panel_value(panelThemeInput)

if barstate.islast
    table.set_position(panel, f_panel_position(panelLocationInput))
    table.set_frame_color(panel, f_panel_border(panelThemeInput))
    table.set_border_color(panel, f_panel_border(panelThemeInput))
    if showPanel
        table.clear(panel, 0, 0, 1, panelRowCount - 1)
        table.merge_cells(panel, 0, 0, 1, 0)
        table.cell(panel, 0, 0, "AG Pro Volatility Cooldown Planner", text_color = headerText, bgcolor = headerBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_center)

        isFourHourChart = timeframe.isintraday and timeframe.multiplier == 240
        spikeColor = hasActiveSpike ? neutralColor : f_panel_value(panelThemeInput)
        scoreColor = hasActiveSpike ? f_state_color(readinessState) : f_panel_value(panelThemeInput)
        loadColor = loadStateText == "Reload" ? bearColor : loadStateText == "High" ? neutralColor : loadStateText == "Cooling" ? accentColor : bullColor
        readinessColor = f_state_color(readinessState)
        actionColor = readinessColor
        bestViewColor = isFourHourChart ? bullColor : accentColor

        scoreText = hasActiveSpike ? f_score_text(cooldownScore) + " / 100 | " + f_tier_text(cooldownScore) : "Waiting"
        loadText = f_ratio_text(atrLoad) + " | " + loadStateText
        rangeText = str.tostring(rangeAtr, "#.##") + " ATR"
        stabilityText = str.tostring(stabilityMove, "#.##") + " ATR"
        readinessText = hasActiveSpike ? readinessState : "Waiting"
        actionPanelText = hasActiveSpike ? actionText : "Monitor"
        bestViewText = isFourHourChart ? "4H Active" : "Use 4H"

        f_panel_row(panel, 1, "Spike State", spikeStateText, spikeColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 2, "Cooldown Score", scoreText, scoreColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 3, "Volatility Load", loadText, loadColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 4, "Range Pressure", rangeText, rangeAtr >= rangeSpikeGate ? neutralColor : bullColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 5, "Close Stability", stabilityText, stabilityMove <= 0.35 ? bullColor : neutralColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 6, "Readiness", readinessText, readinessColor, panelThemeInput, panelFontSizeInput)
        f_panel_row(panel, 7, "Action", actionPanelText + " | " + bestViewText, actionColor, panelThemeInput, panelFontSizeInput)
        if showProof
            color proofHeadBg = f_panel_bg(panelThemeInput, true)
            table.cell(panel, 0, 8, "Proof @ Confirm", text_color = accentColor, bgcolor = proofHeadBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_left)
            table.cell(panel, 1, 8, proofSampleText, text_color = f_panel_label(panelThemeInput), bgcolor = proofHeadBg, text_size = f_label_size(panelFontSizeInput), text_halign = text.align_right)
            f_panel_row(panel, 9, "Follow Rate", followText, followCol, panelThemeInput, panelFontSizeInput)
            f_panel_row(panel, 10, "Hold Rate", holdText, holdCol, panelThemeInput, panelFontSizeInput)
            f_panel_row(panel, 11, "React Rate", reactText, reactCol, panelThemeInput, panelFontSizeInput)
            f_panel_row(panel, 12, "Flip Rate", flipText, flipCol, panelThemeInput, panelFontSizeInput)
    else
        table.clear(panel, 0, 0, 1, panelRowCount - 1)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(alertCooldownStates and newSpikeSignal, "Volatility Spike Registered", "Volatility Cooldown Planner: volatility spike context registered.")
alertcondition(alertCooldownStates and noisySignal, "Noisy Volatility Reload", "Volatility Cooldown Planner: volatility reloaded before cooldown completed.")
alertcondition(alertCooldownStates and reviewSignal, "Cooldown Active Review", "Volatility Cooldown Planner: cooldown score reached the active review threshold.")
alertcondition(alertCooldownStates and readableSignal, "Chart Readable After Cooldown", "Volatility Cooldown Planner: volatility load and cooldown score reached the chart-readable state.")
````
