# Volume Spike Aftershock Planner [AGPro Series]

- url: https://www.tradingview.com/script/ERDJPvCK-Volume-Spike-Aftershock-Planner-AGPro-Series/
- type: indicator
- pine_id: PUB;9f5a8c9439fc4066b83bc925e0bd2aed
- version: 4.0

## Description

Volume Spike Aftershock Planner [AGPro Series]

🧠 Core Idea

After a volume spike, is price actually defending the impulse, absorbing it, or losing control completely?


📌 Overview / What it does

Volume Spike Aftershock Planner [AGPro Series] is designed to evaluate what happens after an abnormal volume expansion candle appears on the chart. Instead of stopping at the spike itself, the script studies the post-impulse behavior and organizes that structure into a readable decision-support framework.

The script maps a spike anchor, an active aftershock band, a failure boundary, and a target-room reference. It also produces contextual labels, right-side price tags, and a compact information panel that summarizes the current aftershock condition with a rule-based score.

This script does not attempt to predict the next candle, automate entries, or generate guaranteed continuation signals. It is an analytical visualization tool that helps users judge whether the spike is still being respected, partially absorbed, or fully invalidated.


🎯 Purpose & Design Philosophy

This script was built to solve a common gap in volume analysis.

Most traders can see when volume suddenly expands. The harder question is what to do with that information after the impulse bar closes. A large volume candle can lead to continuation, rejection, absorption, or complete failure, and those outcomes do not deserve the same interpretation.

This tool helps traders who want a more structured way to read post-spike behavior. It supports a patient, evidence-based mindset by focusing on participation quality, impulse defense, failure thresholds, and available room rather than hype or prediction.


⚡ Why This Script Is Different

Most volume tools focus on spike detection, raw histogram expansion, or one-bar climax alerts.

This script does NOT stop at identifying unusual participation.

Instead, it tracks the aftershock environment that forms after the spike, measures whether price is holding the impulse anchor, maps when the move is being absorbed, and highlights when the context has either matured or failed. The result is not just a volume event marker, but a structured framework for interpreting what the spike still means.


⚙️ Methodology

1. Context Detection
The script scans for abnormal volume participation and range expansion relative to recent behavior. It also reviews body quality so that weak, indecisive candles are filtered more carefully.

2. Reference Mapping
Once a valid spike is confirmed, the script establishes a spike anchor and builds an aftershock band around that reference. It also defines a failure boundary and a room projection.

3. Reaction Evaluation
Price is then evaluated relative to the anchor and surrounding rails. The script checks whether the impulse is being defended, fading back through the anchor, or failing beyond the allowed structure.

4. Visual Output
The final output includes the aftershock band, anchor reference, room line, failure line, event labels, right-side tags, optional bar coloring, and a dashboard panel that summarizes the current state.


🗺️ How to Read the Chart

Zones:
The aftershock band represents the active post-spike area where the market is being evaluated. It is the main structure zone for interpreting whether the impulse still matters.

Labels:
Labels mark important contextual events such as bull spike, bear spike, holding behavior, absorbed behavior, target review, and failure.

Colors:
Teal highlights constructive bullish behavior or defended impulse structure.
Pink highlights bearish structure, invalidation, or failed context.
Gold highlights review areas such as absorption or target-room interaction.
Indigo highlights the spike anchor reference.

Panel:
The panel summarizes the spike state, the Aftershock Score, participation quality, available room, and the current action state.


🚦 Signals & States

• Bull Spike → A bullish high-participation impulse anchor has been detected.
• Bear Spike → A bearish high-participation impulse anchor has been detected.
• Holding → Price is still defending the impulse structure after the spike.
• Aftershock Ready → The post-spike condition is strong enough to deserve active attention.
• Absorbed → Price has moved back through the anchor and the impulse is losing control.
• Target Review → The projected first room objective has been reached and context should be reassessed.
• Failed → The active aftershock structure has broken down beyond the allowed limit.
• Wait Spike → No valid active spike context is currently available.
• Expired → The spike is too old to remain actionable within the current framework.


🔔 Alerts Logic

Alerts can trigger when a new bullish or bearish spike is detected, when price begins to hold the impulse, when the aftershock condition becomes ready, when the move becomes absorbed, when target room is reached, or when the context fails.

These alerts are attention markers only. They highlight a structural event inside the script logic. They are not trade instructions, automated entries, or guarantees of follow-through.


🧩 Confluence Logic

The context becomes stronger when multiple conditions align at the same time.

For example, a high relative-volume spike with strong candle expansion, defended anchor structure, stable participation decay, and clear room beyond the band creates a much stronger environment than a spike that immediately collapses back through its reference level.

This confluence logic is what separates a meaningful aftershock structure from a noisy one-bar event.


📊 When to Use

• Markets with reliable volume behavior
• Crypto pairs with clean participation swings
• Stocks and indices with readable impulse candles
• Breakout or breakdown follow-through evaluation
• Continuation review after a strong reaction candle
• 1H, 4H, and 1D chart studies where impulse quality matters


⚠️ When NOT to Use

• Illiquid symbols with distorted or unreliable volume
• Extremely noisy low-range environments
• Symbols where volume feed quality is poor
• Isolated one-bar anomalies with no structural follow-through
• Extreme volatility conditions where impulse rails become unstable too quickly


🎛️ Key Inputs

• Relative Volume Length → Controls the participation baseline used for spike comparison.
• Minimum Relative Volume → Controls how large the volume expansion must be before the candle qualifies as a spike.
• Minimum Range Ratio → Controls how much price expansion is required.
• Minimum Body Ratio → Filters out weak spike candles with poor body commitment.
• Aftershock Band ATR → Controls the depth of the active aftershock zone.
• Failure Buffer → Controls how far price can move before the spike idea is considered broken.
• Minimum Ready Score → Controls how strict the script is before showing stronger actionable states.
• Visual Settings → Control labels, panel location, theme, font size, and optional chart styling.


🖥️ Interface & Visual Design

The visual design is built around clarity at first glance.

The panel gives a fast structural summary without forcing the user to inspect every line manually. The chart layer uses premium contrast and a clear hierarchy so the aftershock band, anchor, failure boundary, and room references remain readable without overwhelming the candles.

The goal is not decoration. The goal is clean interpretation under live market conditions.


🧪 Practical Usage Workflow

1. Read the panel to understand the current spike state and score.
2. Check whether a valid spike anchor and aftershock band are active.
3. Evaluate whether price is holding, absorbed, or failing relative to the anchor.
4. Review available room and decide whether the current context is mature, early, or already extended.
5. Use labels and tags as structured context markers, not as automatic commands.


🔍 Interpretation Guidelines

Treat the script as a structured reading framework.

A stronger score suggests that the spike had better participation, cleaner range expansion, and more stable post-spike structure. A weaker score suggests that the move may be losing informational value.

An absorbed state does not mean reversal is guaranteed. It means the original impulse is no longer being defended as cleanly as before.

A target-review state does not mean the move must stop. It means the first projected room objective has already been reached and the user should reassess the context rather than assuming endless continuation.


🚫 What This Script Is NOT

This script is not a prediction engine.
It is not a financial advice tool.
It is not an automated trading system.
It is not a broker integration.
It does not place orders.
It does not guarantee continuation, reversal, or profitability.


⚠️ Limitations & Transparency

This script is rule-based and depends on the quality of the underlying market data.

Timeframe changes can materially alter how spikes, bands, and room projections appear. High-volatility environments can also reduce the stability of post-spike structures. In thin or distorted markets, volume expansion may look meaningful while carrying very little analytical value.

The script should always be interpreted in broader market context rather than in isolation.


🧠 Market Context Notes

Volume spikes are often strongest when they appear at meaningful structure transitions, liquidity shifts, or expansion points where the market is forced to reveal intent.

That said, not every spike represents sustainable conviction. Some are exhaustion bursts, some are absorption events, and some are temporary reactions inside a larger opposing structure. The aftershock behavior is often more important than the spike itself.


🧾 Use Case Examples

Example 1:
Price breaks above a local range with a large bullish volume surge. The script marks a bull spike, price holds above the anchor, and the panel shifts into a stronger aftershock state. This suggests the impulse still deserves attention.

Example 2:
Price prints a large bearish impulse, but then quickly moves back through the anchor. The script shifts into an absorbed condition, signaling that the original downside impulse is losing control.

Example 3:
A high-volume move expands sharply, then reaches the target-room area. The script marks target review, reminding the user to reassess the move rather than assuming continuation is still efficient.


🧱 System Philosophy

AGPro Series tools are designed as decision-support frameworks, not signal vending machines.

The philosophy is simple: map structure clearly, make states readable, reduce noise, and help the user think better around live price behavior.


🔐 Non-Promise Statement

This script does not promise certainty.

It does not promise that a volume spike will continue, reverse, hold, or fail in any predetermined way. It simply organizes the available structure so the user can evaluate the situation with more clarity.


📉 Risk Disclosure

Trading and investing involve risk.

Market conditions can change quickly, and any analytical tool can produce outputs that become invalid under new volatility, liquidity, or structural conditions. Users remain fully responsible for their own decisions, risk management, and execution.

This script is provided for educational and analytical purposes only. It is not financial advice.


📚 Educational Note

This tool is most useful when treated as a market-reading assistant.

The best results usually come from combining it with broader structure analysis, liquidity awareness, and disciplined risk management rather than using it as a standalone trigger system.

## Source Code

````pine
// --------------------------------------------------
// Volume Spike Aftershock Planner [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Volume Spike Aftershock Planner maps abnormal volume impulse candles,
// tracks whether the move is being held, absorbed, or faded, and organizes
// participation decay, hold quality, target room and failure risk into a
// 0-100 aftershock score, a clear next-action state and a persistent hold-rate
// proof layer for volume spikes, price action, volatility context, continuation
// review and absorption-risk planning.
// --------------------------------------------------

//@version=6
indicator("Volume Spike Aftershock Planner [AGPro Series]",
     shorttitle = "AG Pro VSA",
     overlay = true,
     max_boxes_count = 50,
     max_lines_count = 140,
     max_labels_count = 220)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_SPIKE = "Spike Detection"
G_AFTER = "Aftershock Logic"
G_PROOF = "Confirm-Rate Proof"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

volumeLength = input.int(30, "Relative Volume Length", minval = 5, maxval = 300, group = G_SPIKE,
     tooltip = "Lookback used to compare the current volume impulse against recent average participation.")
spikeVolumeThreshold = input.float(2.10, "Minimum Relative Volume", minval = 0.50, maxval = 10.0, step = 0.05, group = G_SPIKE,
     tooltip = "Minimum relative volume required before a candle can qualify as a spike anchor.")
rangeLength = input.int(20, "Range Impulse Length", minval = 5, maxval = 300, group = G_SPIKE,
     tooltip = "Lookback used to compare the spike candle range against recent average range.")
spikeRangeThreshold = input.float(1.45, "Minimum Range Ratio", minval = 0.50, maxval = 10.0, step = 0.05, group = G_SPIKE,
     tooltip = "Minimum current range divided by average range required before the candle can qualify as a meaningful impulse.")
minBodyRatio = input.float(0.48, "Minimum Body / Range", minval = 0.05, maxval = 0.95, step = 0.01, group = G_SPIKE,
     tooltip = "Minimum body-to-range ratio required to avoid scoring weak, indecisive high-volume candles as true spike anchors.")
atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_SPIKE,
     tooltip = "ATR length used to normalize aftershock band depth, hold rails, failure shelves, labels, and room calculations.")

minReadyScore = input.int(66, "Minimum Ready Score", minval = 1, maxval = 100, group = G_AFTER,
     tooltip = "Minimum 0-100 score required before the aftershock context becomes READY.")
bandDepthAtr = input.float(0.55, "Aftershock Band ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_AFTER,
     tooltip = "ATR depth used to build the aftershock band around the spike anchor.")
holdBufferAtr = input.float(0.06, "Hold Buffer ATR", minval = 0.00, maxval = 1.0, step = 0.01, group = G_AFTER,
     tooltip = "ATR buffer applied to the hold rail. Price should hold beyond this rail to keep the impulse intact.")
absorbBufferAtr = input.float(0.12, "Absorption Buffer ATR", minval = 0.00, maxval = 2.0, step = 0.01, group = G_AFTER,
     tooltip = "ATR buffer beyond the spike anchor used to classify the move as absorbed rather than cleanly held.")
failureBufferAtr = input.float(0.20, "Failure Buffer ATR", minval = 0.00, maxval = 2.0, step = 0.01, group = G_AFTER,
     tooltip = "ATR shelf beyond the opposite side of the spike where the active aftershock idea fully fails.")
targetRoomAtr = input.float(0.85, "Target Room ATR", minval = 0.10, maxval = 5.0, step = 0.05, group = G_AFTER,
     tooltip = "ATR distance beyond the spike extreme used to estimate the first target-room review area.")
roomLookback = input.int(72, "Room Lookback", minval = 10, maxval = 500, group = G_AFTER,
     tooltip = "Lookback used to compare the active target-room reference against nearby structure.")
maxSpikeAge = input.int(96, "Maximum Spike Age", minval = 5, maxval = 600, group = G_AFTER,
     tooltip = "Maximum bars a spike anchor can remain active before it expires.")

proofWindow = input.int(6, "Proof Hold Window Bars", minval = 3, maxval = 120, group = G_PROOF,
     tooltip = "Bars a spike anchor must defend its hold rail to be counted as a held spike in the Hold Rate proof statistic.")

showAftershockBand = input.bool(true, "Show Aftershock Band", group = G_VISUAL,
     tooltip = "Shows the post-spike aftershock band used to review whether the impulse is being held or absorbed.")
showBandText = input.bool(true, "Show Centered Band Badge", group = G_VISUAL,
     tooltip = "Shows a separate centered badge inside the aftershock band for cleaner chart readability.")
showSpikeAnchor = input.bool(true, "Show Spike Anchor", group = G_VISUAL,
     tooltip = "Shows the main spike anchor price that separates holding from absorption review.")
showHoldRail = input.bool(true, "Show Hold Rail", group = G_VISUAL,
     tooltip = "Shows the rail price should defend to keep the impulse intact.")
showFailureRail = input.bool(true, "Show Failure Rail", group = G_VISUAL,
     tooltip = "Shows where the active aftershock context fails.")
showRoomRail = input.bool(true, "Show Target-Room Rail", group = G_VISUAL,
     tooltip = "Shows the first target-room review reference after the spike.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows spike, holding, absorbed, target-room, and failed labels on the chart.")
showSpikeLabels = input.bool(true, "Show Spike Labels", group = G_VISUAL,
     tooltip = "Shows labels when a new volume spike anchor is detected.")
showHoldingLabels = input.bool(true, "Show Holding Labels", group = G_VISUAL,
     tooltip = "Shows labels when the aftershock is holding its directional impulse.")
showAbsorbedLabels = input.bool(true, "Show Absorbed Labels", group = G_VISUAL,
     tooltip = "Shows labels when the spike begins to lose directional hold and becomes absorbed.")
showRoomLabels = input.bool(true, "Show Room Labels", group = G_VISUAL,
     tooltip = "Shows labels when price reaches the target-room review area.")
showFailedLabels = input.bool(true, "Show Failed Labels", group = G_VISUAL,
     tooltip = "Shows labels when the active aftershock context fails.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for the spike anchor, failure rail, and target-room reference.")
rightTagMode = input.string("Compact", "Right Tag Detail Mode", options = ["Compact", "Full"], group = G_VISUAL,
     tooltip = "Compact uses shorter text; Full uses descriptive text. Both modes retain all four owned active rail badges.")
rightTagMinGapAtr = input.float(0.55, "Right Tag Minimum Gap ATR", minval = 0.10, maxval = 3.00, step = 0.05, group = G_VISUAL,
     tooltip = "Base ATR separation for the active rail badge column. Final spacing expands automatically with the selected label font size.")
showBarColors = input.bool(false, "Color Bars By State", group = G_VISUAL,
     tooltip = "Colors bars lightly according to the active aftershock state.")
projectionBars = input.int(76, "Projection Bars", minval = 5, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars used for projected boxes, rails, and right-side tags.")
labelCooldownBars = input.int(52, "Label Cooldown Bars", minval = 1, maxval = 120, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 4, maxval = 80, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart.")
eventMemoryBars = input.int(140, "Event Label Memory Bars", minval = 20, maxval = 1000, group = G_VISUAL,
     tooltip = "Maximum age of historical event labels. Older labels are removed so stale spike events do not dominate the current chart.")
labelOffsetAtr = input.float(0.78, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset so labels remain readable above or below candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate", "Light"], group = G_PANEL,
     tooltip = "Controls dashboard theme for dark, slate, or light chart layouts.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

alertSpike = input.bool(true, "Alert: Spike Anchor", group = G_ALERTS,
     tooltip = "Enables alerts when a new abnormal volume spike anchor is detected.")
alertHolding = input.bool(true, "Alert: Holding State", group = G_ALERTS,
     tooltip = "Enables alerts when the impulse is holding after the spike.")
alertReady = input.bool(true, "Alert: Ready State", group = G_ALERTS,
     tooltip = "Enables alerts when the active aftershock context reaches READY conditions.")
alertAbsorbed = input.bool(true, "Alert: Absorbed", group = G_ALERTS,
     tooltip = "Enables alerts when the active spike begins to lose directional hold and becomes absorbed.")
alertRoom = input.bool(false, "Alert: Target Room", group = G_ALERTS,
     tooltip = "Enables alerts when price reaches the target-room review reference.")
alertFailed = input.bool(true, "Alert: Failed", group = G_ALERTS,
     tooltip = "Enables alerts when the active aftershock context fails.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBg = color.rgb(15, 23, 42)
panelBgSlate = color.rgb(30, 41, 59)
panelBgLight = color.rgb(248, 250, 252)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
panelLabelLight = color.rgb(71, 85, 105)
panelValueLight = color.rgb(15, 23, 42)
bullColor = color.rgb(34, 197, 166)
bearColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
darkText = color.rgb(17, 24, 39)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    float safeValue = na(value) ? minValue : value
    math.max(minValue, math.min(maxValue, safeValue))

f_text_on(color bg) =>
    float bright = (color.r(bg) * 299 + color.g(bg) * 587 + color.b(bg) * 114) / 1000
    bright >= 145 ? darkText : headerText

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_grade(int score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 50 ? "C" : "D"

f_size(string sizeInput) =>
    switch sizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_panel_position(string posInput) =>
    switch posInput
        "Top Left" => position.top_left
        "Middle Right" => position.middle_right
        "Middle Left" => position.middle_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_panel_bg(string themeInput) =>
    themeInput == "Light" ? panelBgLight : themeInput == "Slate" ? panelBgSlate : panelBg

f_panel_label(string themeInput) =>
    themeInput == "Light" ? panelLabelLight : panelLabelCol

f_panel_value(string themeInput) =>
    themeInput == "Light" ? panelValueLight : panelValueCol

f_price(float value) =>
    str.tostring(value, format.mintick)

f_set_label(label lbl, int x, float y, string txt, color bg, color tx, string sizeInput) =>
    label.set_x(lbl, x)
    label.set_y(lbl, y)
    label.set_text(lbl, txt)
    label.set_color(lbl, bg)
    label.set_textcolor(lbl, tx)
    label.set_size(lbl, f_size(sizeInput))
    label.set_style(lbl, label.style_label_center)

f_hide_label(label lbl) =>
    label.set_text(lbl, "")
    label.set_color(lbl, color.new(color.white, 100))
    label.set_textcolor(lbl, color.new(color.white, 100))
    label.set_x(lbl, bar_index)
    label.set_y(lbl, close)

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput))

// --------------------------------------------------
// Core calculations
// --------------------------------------------------
atr = ta.atr(atrLength)
atrSafe = math.max(nz(atr, ta.tr(true)), syminfo.mintick)
volAvg = ta.sma(volume, volumeLength)
rvol = volAvg > 0.0 ? volume / volAvg : 1.0
barRange = math.max(high - low, syminfo.mintick)
avgRange = ta.sma(barRange, rangeLength)
rangeRatio = avgRange > 0.0 ? barRange / avgRange : 1.0
bodyRatio = math.abs(close - open) / barRange
closeLocation = (close - low) / barRange

bullSpikeRaw = rvol >= spikeVolumeThreshold and rangeRatio >= spikeRangeThreshold and bodyRatio >= minBodyRatio and close > open and closeLocation >= 0.60
bearSpikeRaw = rvol >= spikeVolumeThreshold and rangeRatio >= spikeRangeThreshold and bodyRatio >= minBodyRatio and close < open and closeLocation <= 0.40
newSpike = (bullSpikeRaw or bearSpikeRaw) and not (bullSpikeRaw[1] or bearSpikeRaw[1])

recentHigh = ta.highest(high[1], roomLookback)
recentLow = ta.lowest(low[1], roomLookback)

// --------------------------------------------------
// Active spike state
// --------------------------------------------------
var bool hasSpike = false
var int activeDir = 0
var int spikeBar = na
var float spikeHigh = na
var float spikeLow = na
var float spikeAnchor = na
var float bandTop = na
var float bandBottom = na
var float holdRail = na
var float absorbRail = na
var float failureRail = na
var float roomRail = na
var float spikeRvol = na
var bool roomReached = false
var bool absorbed = false
var bool failed = false
var int lastLabelBar = na

// Hold-rate proof layer
var bool proofPending = false
var int proofDir = 0
var float proofHold = na
var int proofStartBar = na
var int proofTotal = 0
var int proofWin = 0

if newSpike
    hasSpike := true
    activeDir := bullSpikeRaw ? 1 : -1
    spikeBar := bar_index
    spikeHigh := high
    spikeLow := low
    spikeAnchor := close
    spikeDepth = math.min(barRange * 0.38, atrSafe * bandDepthAtr)
    bandTop := activeDir == 1 ? high : close + spikeDepth
    bandBottom := activeDir == 1 ? close - spikeDepth : low
    holdRail := activeDir == 1 ? bandBottom + atrSafe * holdBufferAtr : bandTop - atrSafe * holdBufferAtr
    absorbRail := activeDir == 1 ? spikeAnchor - atrSafe * absorbBufferAtr : spikeAnchor + atrSafe * absorbBufferAtr
    failureRail := activeDir == 1 ? low - atrSafe * failureBufferAtr : high + atrSafe * failureBufferAtr
    roomCandidate = activeDir == 1 ? math.max(high + atrSafe * targetRoomAtr, recentHigh) : math.min(low - atrSafe * targetRoomAtr, recentLow)
    roomRail := roomCandidate
    spikeRvol := rvol
    roomReached := false
    absorbed := false
    failed := false

// Arm the hold proof when a fresh spike anchor is confirmed
if newSpike and barstate.isconfirmed
    proofPending := true
    proofDir := activeDir
    proofHold := holdRail
    proofStartBar := bar_index

spikeAge = hasSpike and not na(spikeBar) ? bar_index - spikeBar : na
expired = hasSpike and spikeAge > maxSpikeAge

holding = hasSpike and not expired and not failed and (activeDir == 1 ? close >= holdRail : close <= holdRail)
if hasSpike and not expired and not failed
    if activeDir == 1 and close < absorbRail
        absorbed := true
    if activeDir == -1 and close > absorbRail
        absorbed := true
    if activeDir == 1 and close < failureRail
        failed := true
    if activeDir == -1 and close > failureRail
        failed := true
    if activeDir == 1 and high >= roomRail
        roomReached := true
    if activeDir == -1 and low <= roomRail
        roomReached := true

// Resolve the hold proof: losing the hold rail within the window is a non-hold;
// defending the hold rail through the window counts as a held spike.
if proofPending and barstate.isconfirmed and bar_index > proofStartBar
    bool pLost = proofDir == 1 ? close < proofHold : close > proofHold
    bool pHeld = bar_index - proofStartBar >= proofWindow
    if pLost
        proofTotal += 1
        proofPending := false
    else if pHeld
        proofTotal += 1
        proofWin += 1
        proofPending := false

float holdRate = proofTotal > 0 ? 100.0 * proofWin / proofTotal : na

activeAftershock = hasSpike and not expired and not failed
rightEdge = bar_index + projectionBars

// --------------------------------------------------
// Score and states
// --------------------------------------------------
volumeScore = hasSpike ? f_clamp(spikeRvol / spikeVolumeThreshold * 28.0, 0.0, 28.0) : 0.0
rangeScore = hasSpike ? f_clamp(rangeRatio / spikeRangeThreshold * 20.0, 0.0, 20.0) : 0.0
bodyScore = hasSpike ? f_clamp(bodyRatio / math.max(minBodyRatio, 0.01) * 16.0, 0.0, 16.0) : 0.0
holdScore = hasSpike ? activeDir == 1 ? f_clamp((close - holdRail) / math.max(spikeHigh - holdRail, syminfo.mintick) * 18.0, 0.0, 18.0) : f_clamp((holdRail - close) / math.max(holdRail - spikeLow, syminfo.mintick) * 18.0, 0.0, 18.0) : 0.0
decayRatio = hasSpike and spikeRvol > 0.0 ? rvol / spikeRvol : na
decayScore = hasSpike ? f_clamp((1.0 - math.abs(nz(decayRatio, 0.0) - 0.55) / 0.55) * 12.0, 0.0, 12.0) : 0.0
roomScore = hasSpike ? activeDir == 1 ? f_clamp((roomRail - close) / atrSafe * 3.0, 0.0, 12.0) : f_clamp((close - roomRail) / atrSafe * 3.0, 0.0, 12.0) : 0.0
agePenalty = hasSpike ? f_clamp(spikeAge / math.max(maxSpikeAge, 1) * 8.0, 0.0, 8.0) : 0.0
absorbPenalty = absorbed ? 12.0 : 0.0
rawScore = volumeScore + rangeScore + bodyScore + holdScore + decayScore + roomScore - agePenalty - absorbPenalty
aftershockScore = hasSpike and not expired ? f_score(rawScore) : 0
grade = f_grade(aftershockScore)

spikeState = not hasSpike ? "No Spike" : expired ? "Expired" : failed ? "Failed" : activeDir == 1 ? "Bull Aftershock" : "Bear Aftershock"
participationText = hasSpike and not expired ? "RVOL " + str.tostring(nz(decayRatio, 0.0), "0.00") + " | Spike " + str.tostring(spikeRvol, "0.00") : "n/a"
roomText = hasSpike and activeAftershock ? str.tostring(math.abs(roomRail - close) / atrSafe, "0.00") + " ATR" : "n/a"
readyState = activeAftershock and holding and not absorbed and not roomReached and aftershockScore >= minReadyScore

actionState = "Wait Spike"
if expired
    actionState := "Expired"
else if failed
    actionState := "Failed"
else if roomReached
    actionState := "Target Review"
else if readyState
    actionState := "Aftershock Ready"
else if absorbed
    actionState := "Absorbed"
else if holding
    actionState := "Holding"

stateColor = not hasSpike or expired ? neutralColor : failed ? bearColor : readyState ? bullColor : absorbed ? accentColor : activeDir == 1 ? bullColor : bearColor
actionColor = actionState == "Aftershock Ready" ? bullColor : actionState == "Failed" ? bearColor : actionState == "Absorbed" or actionState == "Target Review" ? neutralColor : actionState == "Holding" ? stateColor : accentColor
scoreText = hasSpike and not expired ? str.tostring(aftershockScore) + "/100  " + grade : "n/a"
holdRateText = na(holdRate) ? "Building" : str.tostring(math.round(holdRate)) + "% (" + str.tostring(proofTotal) + ")"
holdRateColor = na(holdRate) ? f_panel_value(panelTheme) : holdRate >= 55.0 ? bullColor : holdRate >= 40.0 ? neutralColor : bearColor

spikePrev = bar_index > 0 ? hasSpike[1] : false
holdingPrev = bar_index > 0 ? holding[1] : false
absorbedPrev = bar_index > 0 ? absorbed[1] : false
roomPrev = bar_index > 0 ? roomReached[1] : false
failedPrev = bar_index > 0 ? failed[1] : false
readyPrev = bar_index > 0 ? readyState[1] : false

spikeEvent = hasSpike and not spikePrev
holdingEvent = holding and not holdingPrev
absorbedEvent = absorbed and not absorbedPrev
roomEvent = roomReached and not roomPrev
failedEvent = failed and not failedPrev
readyEvent = readyState and not readyPrev

// --------------------------------------------------
// Drawings
// --------------------------------------------------
var box bandBox = na
var line anchorLine = na
var line holdLine = na
var line failLine = na
var line roomLine = na
var label bandBadge = label.new(bar_index, close, "", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = accentColor, textcolor = headerText, size = size.normal, textalign = text.align_center)

bandMid = activeAftershock ? (bandTop + bandBottom) * 0.50 : close
badgeX = activeAftershock ? int(math.round(spikeBar + (rightEdge - spikeBar) * 0.55)) : bar_index

if activeAftershock and showAftershockBand
    if na(bandBox)
        bandBox := box.new(spikeBar, bandTop, rightEdge, bandBottom, xloc = xloc.bar_index, bgcolor = color.new(stateColor, 86), border_color = color.new(stateColor, 26), border_width = 1)
    else
        box.set_lefttop(bandBox, spikeBar, bandTop)
        box.set_rightbottom(bandBox, rightEdge, bandBottom)
        box.set_bgcolor(bandBox, color.new(stateColor, 86))
        box.set_border_color(bandBox, color.new(stateColor, 26))
    if showBandText
        f_set_label(bandBadge, badgeX, bandMid, "Aftershock Band", color.new(stateColor, 0), f_text_on(stateColor), labelSizeInput)
    else
        f_hide_label(bandBadge)
else
    if not na(bandBox)
        box.delete(bandBox)
        bandBox := na
    f_hide_label(bandBadge)

if activeAftershock and showSpikeAnchor
    if na(anchorLine)
        anchorLine := line.new(spikeBar, spikeAnchor, rightEdge, spikeAnchor, xloc = xloc.bar_index, extend = extend.none, color = accentColor, width = 2)
    else
        line.set_xy1(anchorLine, spikeBar, spikeAnchor)
        line.set_xy2(anchorLine, rightEdge, spikeAnchor)
else
    if not na(anchorLine)
        line.delete(anchorLine)
        anchorLine := na

if activeAftershock and showHoldRail
    if na(holdLine)
        holdLine := line.new(spikeBar, holdRail, rightEdge, holdRail, xloc = xloc.bar_index, extend = extend.none, color = stateColor, width = 1)
    else
        line.set_xy1(holdLine, spikeBar, holdRail)
        line.set_xy2(holdLine, rightEdge, holdRail)
        line.set_color(holdLine, stateColor)
else
    if not na(holdLine)
        line.delete(holdLine)
        holdLine := na

if activeAftershock and showFailureRail
    if na(failLine)
        failLine := line.new(spikeBar, failureRail, rightEdge, failureRail, xloc = xloc.bar_index, extend = extend.none, color = bearColor, width = 1, style = line.style_dashed)
    else
        line.set_xy1(failLine, spikeBar, failureRail)
        line.set_xy2(failLine, rightEdge, failureRail)
else
    if not na(failLine)
        line.delete(failLine)
        failLine := na

if activeAftershock and showRoomRail
    if na(roomLine)
        roomLine := line.new(spikeBar, roomRail, rightEdge, roomRail, xloc = xloc.bar_index, extend = extend.none, color = neutralColor, width = 1)
    else
        line.set_xy1(roomLine, spikeBar, roomRail)
        line.set_xy2(roomLine, rightEdge, roomRail)
else
    if not na(roomLine)
        line.delete(roomLine)
        roomLine := na

// --------------------------------------------------
// Labels
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
eventFontMult = labelSizeInput == "Large" ? 1.28 : labelSizeInput == "Normal" ? 1.08 : labelSizeInput == "Small" ? 0.90 : 0.76
labelOffset = atrSafe * labelOffsetAtr * eventFontMult
var array<label> eventLabels = array.new<label>()

f_push_label(label newLabel) =>
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

if array.size(eventLabels) > 0
    cleanupIdx = array.size(eventLabels) - 1
    while cleanupIdx >= 0
        oldLabel = array.get(eventLabels, cleanupIdx)
        oldX = label.get_x(oldLabel)
        if bar_index - oldX > eventMemoryBars
            label.delete(oldLabel)
            array.remove(eventLabels, cleanupIdx)
        cleanupIdx -= 1

canEventLabel = na(lastLabelBar) or bar_index - lastLabelBar >= labelCooldownBars

if showEventLabels and showSpikeLabels and newSpike and canEventLabel
    bool bullEvent = bullSpikeRaw
    color spikeBg = bullEvent ? bullColor : bearColor
    label newLabel = label.new(bar_index, bullEvent ? low - labelOffset : high + labelOffset, bullEvent ? "BULL SPIKE | ANCHOR" : "BEAR SPIKE | ANCHOR", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = spikeBg, textcolor = f_text_on(spikeBg), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showHoldingLabels and holdingEvent and canEventLabel
    bool bullEvent = activeDir == 1
    label newLabel = label.new(bar_index, bullEvent ? low - labelOffset : high + labelOffset, "HOLDING | DEFENDED", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = stateColor, textcolor = f_text_on(stateColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showAbsorbedLabels and absorbedEvent and canEventLabel
    bool bullEvent = activeDir == 1
    label newLabel = label.new(bar_index, bullEvent ? low - labelOffset : high + labelOffset, "ABSORBED | ANCHOR LOST", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showRoomLabels and roomEvent and canEventLabel
    bool bullEvent = activeDir == 1
    label newLabel = label.new(bar_index, bullEvent ? high + labelOffset : low - labelOffset, "TARGET REVIEW | REACHED", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_down : label.style_label_up, color = neutralColor, textcolor = f_text_on(neutralColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

if showEventLabels and showFailedLabels and failedEvent and canEventLabel
    bool bullEvent = activeDir == 1
    label newLabel = label.new(bar_index, bullEvent ? low - labelOffset : high + labelOffset, "FAILED | IMPULSE LOST", xloc = xloc.bar_index, yloc = yloc.price, style = bullEvent ? label.style_label_up : label.style_label_down, color = bearColor, textcolor = f_text_on(bearColor), size = labelSize)
    f_push_label(newLabel)
    lastLabelBar := bar_index

// --------------------------------------------------
// Right-side tags
// --------------------------------------------------
var label anchorTag = na
var label failTag = na
var label roomTag = na
var label holdTag = na
var line anchorConnector = na
var line holdConnector = na
var line failConnector = na
var line roomConnector = na

f_update_tag(label tag, int x, float y, string txt, color bg, color txtCol) =>
    label result = tag
    if na(result)
        result := label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = bg, textcolor = txtCol, size = labelSize)
    else
        label.set_x(result, x)
        label.set_y(result, y)
        label.set_text(result, txt)
        label.set_color(result, bg)
        label.set_textcolor(result, txtCol)
        label.set_size(result, labelSize)
    result

f_update_connector(line guide, int x1, float y1, int x2, float y2, color guideColor) =>
    line result = guide
    if na(result)
        result := line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = guideColor, width = 2)
    else
        line.set_xy1(result, x1, y1)
        line.set_xy2(result, x2, y2)
        line.set_color(result, guideColor)
        line.set_width(result, 2)
    result

if showRightTags and activeAftershock
    tagFontMult = labelSizeInput == "Large" ? 1.32 : labelSizeInput == "Normal" ? 1.10 : labelSizeInput == "Small" ? 0.92 : 0.78
    tagGap = math.max(atrSafe * rightTagMinGapAtr * tagFontMult, syminfo.mintick * 20.0)
    tagX = rightEdge + 8
    tagJoinX = tagX - 1
    failY = failureRail
    holdY = activeDir == 1 ? math.max(holdRail, failY + tagGap) : math.min(holdRail, failY - tagGap)
    anchorY = activeDir == 1 ? math.max(spikeAnchor, holdY + tagGap) : math.min(spikeAnchor, holdY - tagGap)
    roomY = activeDir == 1 ? math.max(roomRail, anchorY + tagGap) : math.min(roomRail, anchorY - tagGap)
    compactTags = rightTagMode == "Compact"
    anchorText = (compactTags ? "ANCHOR | " : "Spike Anchor | ") + f_price(spikeAnchor)
    holdText = (compactTags ? "HOLD | " : "Hold Rail | ") + f_price(holdRail)
    failText = (compactTags ? "FAIL | " : "Failure Rail | ") + f_price(failureRail)
    roomTextTag = (compactTags ? "ROOM | " : "Target Room | ") + f_price(roomRail)
    anchorTag := f_update_tag(anchorTag, tagX, anchorY, anchorText, accentColor, f_text_on(accentColor))
    holdTag := f_update_tag(holdTag, tagX, holdY, holdText, stateColor, f_text_on(stateColor))
    failTag := f_update_tag(failTag, tagX, failY, failText, bearColor, f_text_on(bearColor))
    roomTag := f_update_tag(roomTag, tagX, roomY, roomTextTag, neutralColor, f_text_on(neutralColor))
    anchorConnector := f_update_connector(anchorConnector, rightEdge, spikeAnchor, tagJoinX, anchorY, color.new(accentColor, 6))
    holdConnector := f_update_connector(holdConnector, rightEdge, holdRail, tagJoinX, holdY, color.new(stateColor, 6))
    failConnector := f_update_connector(failConnector, rightEdge, failureRail, tagJoinX, failY, color.new(bearColor, 6))
    roomConnector := f_update_connector(roomConnector, rightEdge, roomRail, tagJoinX, roomY, color.new(neutralColor, 6))
else
    if not na(anchorTag)
        label.delete(anchorTag)
        anchorTag := na
    if not na(failTag)
        label.delete(failTag)
        failTag := na
    if not na(roomTag)
        label.delete(roomTag)
        roomTag := na
    if not na(holdTag)
        label.delete(holdTag)
        holdTag := na
    if not na(anchorConnector)
        line.delete(anchorConnector)
        anchorConnector := na
    if not na(holdConnector)
        line.delete(holdConnector)
        holdConnector := na
    if not na(failConnector)
        line.delete(failConnector)
        failConnector := na
    if not na(roomConnector)
        line.delete(roomConnector)
        roomConnector := na

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBodyBg = f_panel_bg(panelTheme)
panelLeftBg = panelTheme == "Light" ? color.rgb(226, 232, 240) : panelBorder
panelLabel = f_panel_label(panelTheme)
panelValue = f_panel_value(panelTheme)

var table panel = table.new(f_panel_position(panelPositionInput), 2, 7, border_width = 1, border_color = panelBorder, frame_color = panelBorder, frame_width = 1)

if barstate.islast
    table.set_position(panel, f_panel_position(panelPositionInput))
    if showPanel
        table.clear(panel, 0, 0, 1, 6)
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Volume Spike Aftershock Planner", headerText, headerBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 1, "Spike", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 1, spikeState, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 2, "Aftershock Score", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 2, scoreText, f_text_on(stateColor), stateColor, panelFontSizeInput)
        f_panel_cell(panel, 0, 3, "Participation", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 3, participationText, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 4, "Room", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 4, roomText, panelValue, panelBodyBg, panelFontSizeInput)
        f_panel_cell(panel, 0, 5, "Action", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 5, actionState, f_text_on(actionColor), actionColor, panelFontSizeInput)
        f_panel_cell(panel, 0, 6, "Hold Rate", panelLabel, panelLeftBg, panelFontSizeInput)
        f_panel_cell(panel, 1, 6, holdRateText, holdRateColor, panelBodyBg, panelFontSizeInput)
    else
        table.clear(panel, 0, 0, 1, 6)

barStateColor = actionState == "Aftershock Ready" ? color.new(stateColor, 72) : actionState == "Holding" ? color.new(stateColor, 78) : actionState == "Failed" ? color.new(bearColor, 70) : actionState == "Absorbed" ? color.new(neutralColor, 78) : na
barcolor(showBarColors ? barStateColor : na)

// --------------------------------------------------
// Alerts
// --------------------------------------------------
alertcondition(alertSpike and spikeEvent and activeDir == 1, "Bull Spike", "AG Pro VSA: A bullish volume spike anchor has been detected on {{ticker}}.")
alertcondition(alertSpike and spikeEvent and activeDir == -1, "Bear Spike", "AG Pro VSA: A bearish volume spike anchor has been detected on {{ticker}}.")
alertcondition(alertHolding and holdingEvent, "Holding", "AG Pro VSA: The active aftershock is holding the spike impulse on {{ticker}}.")
alertcondition(alertReady and readyEvent, "Aftershock Ready", "AG Pro VSA: The active volume spike aftershock context is ready on {{ticker}}.")
alertcondition(alertAbsorbed and absorbedEvent, "Absorbed", "AG Pro VSA: The active spike is being absorbed back through its anchor on {{ticker}}.")
alertcondition(alertRoom and roomEvent, "Target Review", "AG Pro VSA: Price reached the active target-room review area on {{ticker}}.")
alertcondition(alertFailed and failedEvent, "Failed", "AG Pro VSA: The active volume spike aftershock context has failed on {{ticker}}.")
````
