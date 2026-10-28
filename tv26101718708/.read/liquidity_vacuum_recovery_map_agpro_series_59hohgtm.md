# Liquidity Vacuum Recovery Map [AGPro Series]

- url: https://www.tradingview.com/script/59HoHgtm-Liquidity-Vacuum-Recovery-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;6b12622ad99f46d696e2c826a27e8eaa
- version: 4.0

## Description

Liquidity Vacuum Recovery Map [AGPro Series]

🧠 Core Idea

Did price leave a liquidity vacuum, and is the market repairing that vacuum or rejecting the repair attempt?


📌 Overview / What it does

Liquidity Vacuum Recovery Map is a price-action visualization tool built to study displacement, imbalance, liquidity void behavior, and repair progress after a strong directional candle.

The script identifies high-quality displacement candles, builds an active vacuum zone from the body of that move, tracks how deeply price revisits the zone, measures repair progress, highlights rejection risk, and summarizes the full recovery context inside a compact AG Pro panel.

It does not predict future price, automate trades, or claim that every vacuum must be filled. It is a structured map for reading whether a thin participation area is still open, partially repaired, fully repaired, or being rejected.


🎯 Purpose & Design Philosophy

Many traders can see a fast displacement move after it happens.

The harder question is what comes next:

Is the market repairing the move, respecting the void, or rejecting the return into that area?

This script was built to answer that question visually. It helps traders read imbalance recovery, repair quality, rejection pressure, and next-context conditions without turning the chart into a generic signal board.


⚡ Why This Script Is Different

Most liquidity void tools focus on drawing static gaps, imbalance boxes, or historical void areas.

This script does NOT treat a vacuum as a passive rectangle on the chart.

Instead, it tracks the life cycle of the vacuum after displacement: creation, first repair, half repair, full repair, and rejection risk. The focus is not only where the vacuum is. The focus is whether the market is actively repairing it or refusing to repair it.


⚙️ Methodology

1. Displacement Detection

The script reviews candle range expansion, candle body commitment, close drive, and volume participation to identify a meaningful displacement candle.

2. Vacuum Zone Mapping

When the displacement qualifies, the script builds a vacuum zone from the strongest portion of the candle body. Bullish displacement leaves a repair zone below price. Bearish displacement leaves a repair zone above price.

3. Repair Progress Tracking

The script tracks how far price penetrates back into the active vacuum zone and converts that movement into a repair progress percentage.

4. Rejection Evaluation

If price enters the zone but moves away before full repair, the script evaluates whether the repair attempt is being rejected.

5. Quality Scoring

Vacuum quality combines range expansion, body commitment, close drive, and volume participation into a 0-100 score.

6. Visual Output

The chart displays the active vacuum zone, repair progress fill, midpoint reference, right-side repair tags, event labels, alerts, and a compact AG Pro decision panel.


🗺️ How to Read the Chart

Liquidity Vacuum Zone = the thin participation area left behind by a strong displacement candle.

Repair Progress Fill = the portion of the vacuum that price has already revisited.

VAC HIGH / VAC LOW = the active upper and lower boundaries of the vacuum zone.

REPAIR tag = the current repair progress score on the right side of the chart.

VACUUM OPEN = a qualified vacuum exists, but repair has not meaningfully started.

REPAIRING = price has started revisiting the vacuum zone.

REPAIR COMPLETE = price has repaired most or all of the active vacuum.

REJECTION RISK = price entered the vacuum zone but moved away before full repair.

Panel = summarizes vacuum state, quality score, vacuum type, repair progress, rejection risk, target zone, and next context.


🚦 Signals & States

• BULL VACUUM LEFT → bullish displacement created a vacuum below price.

• BEAR VACUUM LEFT → bearish displacement created a vacuum above price.

• REPAIR START → price has started entering the active vacuum zone.

• REPAIR HALF → price has repaired at least half of the active vacuum zone.

• REPAIR COMPLETE → price has repaired most or all of the active vacuum zone.

• REPAIR REJECTION → price entered the vacuum zone but rejected away before full repair.


🔔 Alerts Logic

Alerts can trigger when a qualified vacuum is created, repair starts, half repair is reached, full repair is reached, or repair rejection appears.

These alerts are attention markers only.

They are not trade instructions, entry signals, exit signals, or guaranteed outcomes.


🧩 Confluence Logic

The context becomes stronger when a high-quality displacement candle creates a clear vacuum, price revisits the zone, repair progress reaches a meaningful threshold, and rejection risk remains low.

The context becomes weaker when the vacuum is old, repair progress is incomplete, and price repeatedly rejects away from the zone.


📊 When to Use

• After strong displacement candles

• During imbalance and liquidity void analysis

• Around fast breakout or breakdown moves

• When evaluating whether a move is being repaired

• When studying continuation versus retracement behavior

• On liquid markets where candles and volume are meaningful


⚠️ When NOT to Use

• In extremely low-liquidity markets

• During highly erratic news candles

• On symbols with unreliable volume data

• When price is moving in tiny noisy candles without displacement

• As a standalone buy or sell system


🎛️ Key Inputs

• Minimum Displacement Range → controls how large a candle must be relative to average range.

• Minimum Body / Range → controls how committed the displacement candle body must be.

• Minimum Close Drive → controls how strongly the candle must close toward its direction.

• Vacuum Zone Body Share → controls how deep the vacuum zone is drawn inside the displacement body.

• Repair Start / Half / Complete Percent → controls the repair progress thresholds.

• Rejection Buffer ATR → controls how far price must move away before rejection risk is detected.

• Projection Bars → controls how far the active zone extends to the right.

• Label and Panel Font Size → controls chart readability.


🖥️ Interface & Visual Design

The visual design is built around one active story:

Where is the vacuum, how much of it has been repaired, and what is the current repair state?

The zone creates the main map, the repair fill shows progress, right-side tags keep the structure readable, event labels mark important moments, and the AG Pro panel summarizes the decision context.


🧪 Practical Usage Workflow

1. Read the panel first.

2. Check whether the script shows an active vacuum.

3. Review the vacuum quality score.

4. Look at repair progress.

5. Check whether rejection risk is low, medium, or high.

6. Use the vacuum boundaries as context areas, not automatic trade levels.

7. Confirm the broader market structure independently.


🔍 Interpretation Guidelines

A vacuum left behind by strong displacement can remain open for a long time.

Repair progress means price has revisited part of the zone.

Full repair means the active vacuum has mostly been revisited.

Rejection risk means the market attempted to repair the zone but moved away before completing the repair.

None of these states guarantee what happens next.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not a financial advice tool.

It is not an automated trading system.

It does not guarantee that price will fill a vacuum.

It does not guarantee continuation after rejection.

It does not replace risk management or independent analysis.


⚠️ Limitations & Transparency

Vacuum detection depends on candle behavior, volatility, volume, and timeframe.

Different timeframes may show different vacuum structures.

Some markets repair quickly, while others leave open void areas for long periods.

Volume-based scoring may be less reliable on symbols with incomplete or synthetic volume.

High volatility can create visually large zones that should be interpreted with extra caution.


🧠 Market Context Notes

Liquidity vacuums are most useful when interpreted as participation gaps rather than guaranteed magnets.

A repaired vacuum can signal that the market revisited a prior thin area.

A rejected vacuum can signal that the market respected the displacement path and refused deeper repair.

The best interpretation comes from combining vacuum context with structure, volatility, liquidity, and higher-timeframe conditions.


🧾 Use Case Examples

When price leaves a strong bullish displacement candle and later returns into the vacuum zone, traders can monitor whether repair progress increases smoothly or gets rejected near the upper part of the zone.

When price leaves a strong bearish displacement candle and later returns into the vacuum zone, traders can monitor whether the market fully repairs the move or rejects back below the zone.

When repair progress reaches half repair but rejection risk rises, the active context may become more fragile.


🧱 System Philosophy

Liquidity Vacuum Recovery Map is part of the AGPro Series approach:

Build visual tools that explain market context clearly, avoid hype, avoid prediction claims, and support structured decision-making.

The goal is not to tell users what to do.

The goal is to help users see what the market is doing more clearly.


🔐 Non-Promise Statement

No script can remove uncertainty from trading.

This tool does not promise accuracy, certainty, profitability, or future performance.


📉 Risk Disclosure

Trading involves risk.

Market conditions can change quickly.

Users are responsible for their own decisions, position sizing, risk management, and interpretation.

This script is for educational and analytical purposes only and does not provide financial advice.


📚 Educational Note

Use this script as a structured way to study displacement, liquidity vacuum behavior, repair progress, and rejection context.

The most valuable output is not a single label.

The value is the full map: vacuum, repair, rejection, quality, and next context.

## Source Code

````pine
// --------------------------------------------------
// Liquidity Vacuum Recovery Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.4
//
// Liquidity Vacuum Recovery Map detects strong displacement candles that leave
// a thin participation area behind, builds a live vacuum zone, tracks whether
// price is repairing that zone, and summarizes repair progress, rejection risk,
// target area, vacuum type, and quality score in a compact AG Pro panel. Its
// owned milestone badge consolidates each vacuum's recovery story while dynamic
// boundary guides keep thin-zone labels readable without losing price ownership.
// --------------------------------------------------

//@version=6
indicator("Liquidity Vacuum Recovery Map [AGPro Series]",
     shorttitle = "AG Pro LVR",
     overlay = true,
     max_boxes_count = 50,
     max_lines_count = 100,
     max_labels_count = 220)

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
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
zoneBorder    = color.rgb(99, 102, 241)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_VACUUM = "Vacuum Engine"
G_REPAIR = "Recovery Logic"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_VACUUM, tooltip = "ATR length used to normalize displacement strength, zone thickness, label spacing, repair distance, and rejection buffers.")
rangeLength = input.int(30, "Average Range Length", minval = 5, maxval = 300, group = G_VACUUM, tooltip = "Average candle range length used to compare the current candle against normal movement.")
volumeLength = input.int(30, "Volume Average Length", minval = 2, maxval = 300, group = G_VACUUM, tooltip = "Volume average length used to estimate whether the displacement had meaningful participation.")
minImpulseRange = input.float(1.45, "Minimum Displacement Range", minval = 0.40, maxval = 8.0, step = 0.05, group = G_VACUUM, tooltip = "Current candle range divided by average range required before a liquidity vacuum can be created.")
minBodyRatio = input.float(0.58, "Minimum Body / Range", minval = 0.10, maxval = 0.95, step = 0.01, group = G_VACUUM, tooltip = "Minimum candle body-to-range ratio required before displacement can qualify as a vacuum source.")
minCloseDrive = input.float(0.68, "Minimum Close Drive", minval = 0.50, maxval = 0.98, step = 0.01, group = G_VACUUM, tooltip = "How close the candle must close toward its direction. Higher values create fewer but stronger vacuum zones.")
volumeConfirmRatio = input.float(1.00, "Volume Confirm Ratio", minval = 0.10, maxval = 10.0, step = 0.05, group = G_VACUUM, tooltip = "Current volume divided by average volume needed for full volume-participation credit.")
minVacuumScore = input.int(62, "Minimum Vacuum Score", minval = 1, maxval = 100, group = G_VACUUM, tooltip = "Minimum 0-100 score required before a displacement candle becomes an active liquidity vacuum.")
zoneBodyShare = input.float(0.72, "Vacuum Zone Body Share", minval = 0.25, maxval = 0.95, step = 0.01, group = G_VACUUM, tooltip = "Portion of the displacement body used to build the repair zone. Larger values draw a deeper vacuum area.")

repairStartPct = input.int(18, "Repair Start Percent", minval = 1, maxval = 80, group = G_REPAIR, tooltip = "Minimum zone penetration percent required before repair is considered started.")
repairHalfPct = input.int(50, "Repair Half Percent", minval = 20, maxval = 95, group = G_REPAIR, tooltip = "Repair progress percent used to classify a half-repaired vacuum.")
repairDonePct = input.int(92, "Repair Done Percent", minval = 55, maxval = 100, group = G_REPAIR, tooltip = "Repair progress percent required before the vacuum is treated as repaired.")
rejectionBufferAtr = input.float(0.22, "Rejection Buffer ATR", minval = 0.00, maxval = 3.0, step = 0.01, group = G_REPAIR, tooltip = "ATR buffer outside the vacuum zone used to identify a repair rejection after price has already entered the zone.")
maxVacuumAge = input.int(220, "Maximum Vacuum Age", minval = 20, maxval = 1000, group = G_REPAIR, tooltip = "Maximum number of bars an active vacuum zone can remain active before expiring.")
cooldownAfterVacuum = input.int(12, "New Vacuum Cooldown", minval = 0, maxval = 200, group = G_REPAIR, tooltip = "Minimum bars between new vacuum zones. Helps prevent noisy charts during rapid displacement clusters.")

showVacuumZone = input.bool(true, "Show Vacuum Zone", group = G_VISUAL, tooltip = "Shows the active liquidity vacuum zone left behind by a displacement candle.")
showRepairFill = input.bool(true, "Show Repair Progress Fill", group = G_VISUAL, tooltip = "Shows how much of the active vacuum has been repaired by price revisiting the zone.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL, tooltip = "Shows vacuum-left, repair-start, repair-half, repair-reject, and repair-done event labels.")
showRightTags = input.bool(true, "Show Owned Boundary Tags", group = G_VISUAL, tooltip = "Shows VAC HIGH and VAC LOW badges with automatic staggering and connector guides when the active zone becomes too thin.")
showBarColors = input.bool(false, "Color Bars By Vacuum State", group = G_VISUAL, tooltip = "Colors bars lightly according to active repair or rejection context.")
projectionBars = input.int(72, "Projection Bars", minval = 10, maxval = 400, group = G_VISUAL, tooltip = "Number of bars used for projected zones, rails, and right-side tags.")
adaptiveProjection = input.bool(true, "Adaptive HTF Projection", group = G_VISUAL, tooltip = "Automatically widens visual projection on higher timeframes so zones remain readable.")
eventScoreFloor = input.int(75, "Minimum Historical Event Score", minval = 1, maxval = 100, group = G_VISUAL, tooltip = "Minimum vacuum quality required for a historical milestone badge. The active zone and panel remain visible regardless of this filter.")
labelCooldownBars = input.int(54, "Historical Event Cooldown", minval = 1, maxval = 140, group = G_VISUAL, tooltip = "Minimum spacing between separate historical vacuum badges. Milestones from one vacuum update the same badge instead of creating duplicates.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 3, maxval = 20, group = G_VISUAL, tooltip = "Maximum number of completed or active vacuum milestone badges retained on the chart.")
labelOffsetAtr = input.float(0.78, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL, tooltip = "ATR-based event-badge offset. Additional spacing is applied automatically for larger font sizes.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_VISUAL, tooltip = "Controls chart labels, centered badges, and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL, tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = G_PANEL, tooltip = "Controls dashboard location.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = G_PANEL, tooltip = "Controls dashboard theme while preserving the single blue header row.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PANEL, tooltip = "Controls dashboard font size.")

alertVacuum = input.bool(true, "Alert: Vacuum Created", group = G_ALERTS, tooltip = "Enables alerts when a qualified liquidity vacuum is created.")
alertRepairStart = input.bool(true, "Alert: Repair Started", group = G_ALERTS, tooltip = "Enables alerts when price starts repairing the active vacuum zone.")
alertRepairHalf = input.bool(true, "Alert: Half Repair", group = G_ALERTS, tooltip = "Enables alerts when repair progress reaches the half-repair threshold.")
alertRepairDone = input.bool(true, "Alert: Repair Done", group = G_ALERTS, tooltip = "Enables alerts when repair progress reaches the repaired threshold.")
alertRepairFail = input.bool(true, "Alert: Repair Rejection", group = G_ALERTS, tooltip = "Enables alerts when price rejects away from the active vacuum after entering the repair zone.")

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

// Luminance-aware contrast text (target luminance 145)
f_lum(color c)      => 0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)
f_text_on(color bg) => f_lum(bg) > 145 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

f_size(string sizeInput) =>
    sizeInput == "Tiny" ? size.tiny :
     sizeInput == "Small" ? size.small :
     sizeInput == "Large" ? size.large :
     sizeInput == "Huge" ? size.huge : size.normal

f_pos(string posInput) =>
    posInput == "Top Left" ? position.top_left :
     posInput == "Top Center" ? position.top_center :
     posInput == "Middle Left" ? position.middle_left :
     posInput == "Middle Center" ? position.middle_center :
     posInput == "Middle Right" ? position.middle_right :
     posInput == "Bottom Left" ? position.bottom_left :
     posInput == "Bottom Center" ? position.bottom_center :
     posInput == "Bottom Right" ? position.bottom_right : position.top_right

f_panel_bg() =>
    panelTheme == "Clean Light" ? color.rgb(241, 245, 249) : panelTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_alt_bg(int row) =>
    bool evenRow = row % 2 == 0
    panelTheme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : panelTheme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_border() =>
    panelTheme == "Clean Light" ? color.rgb(148, 163, 184) : panelTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    panelTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    panelTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#") + "%"

f_dir_text(int dir) =>
    dir == 1 ? "Bull vacuum" : dir == -1 ? "Bear vacuum" : "n/a"

f_state_color(string state) =>
    state == "REPAIR DONE" ? bullColor :
     state == "REPAIRING" ? accentColor :
     state == "REJECTION RISK" ? bearColor :
     state == "VACUUM OPEN" ? neutralColor :
     state == "EXPIRED" ? panelLabelCol : panelValueCol

f_risk_text(int riskScore) =>
    riskScore >= 70 ? "High" : riskScore >= 40 ? "Medium" : "Low"

f_event_set(label id, int x, float y, string txt, color bg, bool up, string sizeInput) =>
    label result = id
    if na(result)
        result := label.new(x, y, txt, xloc = xloc.bar_index, yloc = yloc.price, style = up ? label.style_label_up : label.style_label_down, textcolor = f_text_on(bg), color = bg, size = f_size(sizeInput))
    else
        label.set_xy(result, x, y)
        label.set_text(result, txt)
        label.set_style(result, up ? label.style_label_up : label.style_label_down)
        label.set_textcolor(result, f_text_on(bg))
        label.set_color(result, bg)
        label.set_size(result, f_size(sizeInput))
    result

f_trim_labels(array<label> labels, int keep) =>
    while array.size(labels) > keep
        label old = array.shift(labels)
        if not na(old)
            label.delete(old)

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput, string alignInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput), text_halign = alignInput == "left" ? text.align_left : alignInput == "right" ? text.align_right : text.align_center)

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
atr = ta.atr(atrLength)
safeAtr = math.max(atr, syminfo.mintick)
avgRange = ta.sma(high - low, rangeLength)
safeAvgRange = math.max(avgRange, syminfo.mintick)
barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyRatio = body / barRange
rangeRatio = barRange / safeAvgRange
closeDriveBull = (close - low) / barRange
closeDriveBear = (high - close) / barRange
volAvg = ta.sma(volume, volumeLength)
volRatio = na(volAvg) or volAvg <= 0.0 ? 1.0 : volume / volAvg

bodyScore = f_clamp(bodyRatio / math.max(minBodyRatio, 0.01) * 100.0, 0.0, 100.0)
rangeScore = f_clamp(rangeRatio / math.max(minImpulseRange, 0.01) * 100.0, 0.0, 100.0)
volumeScore = f_clamp(volRatio / math.max(volumeConfirmRatio, 0.01) * 100.0, 0.0, 100.0)
bullDriveScore = f_clamp(closeDriveBull / math.max(minCloseDrive, 0.01) * 100.0, 0.0, 100.0)
bearDriveScore = f_clamp(closeDriveBear / math.max(minCloseDrive, 0.01) * 100.0, 0.0, 100.0)

bullScore = f_score(rangeScore * 0.30 + bodyScore * 0.28 + volumeScore * 0.18 + bullDriveScore * 0.24)
bearScore = f_score(rangeScore * 0.30 + bodyScore * 0.28 + volumeScore * 0.18 + bearDriveScore * 0.24)

wideEnough = rangeRatio >= minImpulseRange
bodyEnough = bodyRatio >= minBodyRatio
bullVacuumRaw = close > open and wideEnough and bodyEnough and closeDriveBull >= minCloseDrive
bearVacuumRaw = close < open and wideEnough and bodyEnough and closeDriveBear >= minCloseDrive

var int activeDir = 0
var int activeStart = na
var float activeTop = na
var float activeBottom = na
var int activeQuality = 0
var float repairExtreme = na
var bool repairStartedMemory = false
var bool repairHalfMemory = false
var bool repairDoneMemory = false
var bool rejectionMemory = false
var int lastVacuumBar = na

canCreate = na(lastVacuumBar) or bar_index - lastVacuumBar >= cooldownAfterVacuum
newBullVacuum = bullVacuumRaw and bullScore >= minVacuumScore and canCreate
newBearVacuum = bearVacuumRaw and bearScore >= minVacuumScore and canCreate

if newBullVacuum or newBearVacuum
    activeDir := newBullVacuum ? 1 : -1
    activeStart := bar_index
    activeQuality := newBullVacuum ? bullScore : bearScore
    float bodyHigh = math.max(open, close)
    float bodyLow = math.min(open, close)
    float bodyHeight = math.max(bodyHigh - bodyLow, syminfo.mintick)
    if activeDir == 1
        activeTop := bodyHigh - bodyHeight * (1.0 - zoneBodyShare)
        activeBottom := bodyLow
        repairExtreme := activeTop
    else
        activeTop := bodyHigh
        activeBottom := bodyLow + bodyHeight * (1.0 - zoneBodyShare)
        repairExtreme := activeBottom
    if activeTop < activeBottom
        float swap = activeTop
        activeTop := activeBottom
        activeBottom := swap
    repairStartedMemory := false
    repairHalfMemory := false
    repairDoneMemory := false
    rejectionMemory := false
    lastVacuumBar := bar_index

activeHeight = not na(activeTop) and not na(activeBottom) ? math.max(activeTop - activeBottom, syminfo.mintick) : na
activeAge = not na(activeStart) ? bar_index - activeStart : na
isActive = activeDir != 0 and not na(activeTop) and not na(activeBottom) and not na(activeStart) and activeAge <= maxVacuumAge

if isActive and bar_index > activeStart
    if activeDir == 1
        repairExtreme := math.min(nz(repairExtreme, activeTop), low)
    else
        repairExtreme := math.max(nz(repairExtreme, activeBottom), high)

repairProgress = not isActive or na(activeHeight) ? na :
     activeDir == 1 ? f_clamp((activeTop - repairExtreme) / activeHeight * 100.0, 0.0, 100.0) :
     f_clamp((repairExtreme - activeBottom) / activeHeight * 100.0, 0.0, 100.0)

repairLevel = not isActive or na(repairProgress) ? na :
     activeDir == 1 ? activeTop - activeHeight * repairProgress / 100.0 :
     activeBottom + activeHeight * repairProgress / 100.0

repairStarted = isActive and not na(repairProgress) and repairProgress >= repairStartPct
repairHalf = isActive and not na(repairProgress) and repairProgress >= repairHalfPct
repairDone = isActive and not na(repairProgress) and repairProgress >= repairDonePct

rejectAway = isActive and repairStarted and not repairDone and (activeDir == 1 and close > activeTop + rejectionBufferAtr * safeAtr or activeDir == -1 and close < activeBottom - rejectionBufferAtr * safeAtr)

agePressure = isActive and not na(activeAge) ? f_clamp(activeAge / math.max(maxVacuumAge, 1) * 100.0, 0.0, 100.0) : 0.0
unfinished = isActive and not na(repairProgress) ? 100.0 - repairProgress : 100.0
rejectionScore = f_score((rejectAway ? 70.0 : 0.0) + unfinished * 0.18 + agePressure * 0.12)

vacuumState = not isActive ? "NO ACTIVE VACUUM" :
     repairDone ? "REPAIR DONE" :
     rejectAway ? "REJECTION RISK" :
     repairStarted ? "REPAIRING" : "VACUUM OPEN"

targetText = not isActive ? "n/a" : activeDir == 1 ? f_price(activeBottom) : f_price(activeTop)
nextContext = not isActive ? "Wait for displacement" :
     repairDone ? "Vacuum repaired" :
     rejectAway ? "Respect rejection" :
     repairHalf ? "Track final repair" :
     repairStarted ? "Monitor repair path" : "Watch first repair"

newRepairStart = repairStarted and not repairStartedMemory
newRepairHalf = repairHalf and not repairHalfMemory
newRepairDone = repairDone and not repairDoneMemory
newReject = rejectAway and not rejectionMemory

if newRepairStart
    repairStartedMemory := true
if newRepairHalf
    repairHalfMemory := true
if newRepairDone
    repairDoneMemory := true
if newReject
    rejectionMemory := true
if not isActive and activeDir != 0
    activeDir := 0

// --------------------------------------------------
// Visual State
// --------------------------------------------------
var box vacuumBox = na
var box repairBox = na
var line topLine = na
var line bottomLine = na
var line topTagGuide = na
var line bottomTagGuide = na
var label topTag = na
var label bottomTag = na
var label vacuumBadge = na
var array<label> eventLabels = array.new<label>()
var label activeEventLabel = na
var int lastPrintedEventBar = na

labelSize = f_size(labelSizeInput)
zoneColor = activeDir == 1 ? bullColor : activeDir == -1 ? bearColor : accentColor
repairColor = repairDone ? bullColor : rejectAway ? bearColor : repairStarted ? accentColor : neutralColor
fontLaneAtr = labelSizeInput == "Huge" ? 0.42 : labelSizeInput == "Large" ? 0.30 : labelSizeInput == "Normal" ? 0.20 : labelSizeInput == "Small" ? 0.12 : 0.08
eventOffset = safeAtr * (labelOffsetAtr + fontLaneAtr)

if showEventLabels
    if newBullVacuum or newBearVacuum
        activeEventLabel := na
        bool eventQualityReady = activeQuality >= eventScoreFloor
        bool eventCooldownReady = na(lastPrintedEventBar) or bar_index - lastPrintedEventBar >= labelCooldownBars
        if eventQualityReady and eventCooldownReady
            bool badgeUp = activeDir == 1
            float badgeY = badgeUp ? low - eventOffset : high + eventOffset
            color badgeColor = activeDir == 1 ? bullColor : bearColor
            string badgeText = activeDir == 1 ? "BULL VACUUM | Q " + str.tostring(activeQuality) : "BEAR VACUUM | Q " + str.tostring(activeQuality)
            activeEventLabel := f_event_set(na, bar_index, badgeY, badgeText, badgeColor, badgeUp, labelSizeInput)
            array.push(eventLabels, activeEventLabel)
            f_trim_labels(eventLabels, maxEventLabels)
            lastPrintedEventBar := bar_index
    if newRepairStart and not na(activeEventLabel)
        bool badgeUp = activeDir == 1
        activeEventLabel := f_event_set(activeEventLabel, bar_index, badgeUp ? low - eventOffset : high + eventOffset, "REPAIR START | " + f_pct(repairProgress), accentColor, badgeUp, labelSizeInput)
    if newRepairHalf and not na(activeEventLabel)
        bool badgeUp = activeDir == 1
        activeEventLabel := f_event_set(activeEventLabel, bar_index, badgeUp ? low - eventOffset : high + eventOffset, "REPAIR HALF | " + f_pct(repairProgress), neutralColor, badgeUp, labelSizeInput)
    if newRepairDone and not na(activeEventLabel)
        bool badgeUp = activeDir == 1
        activeEventLabel := f_event_set(activeEventLabel, bar_index, badgeUp ? low - eventOffset : high + eventOffset, "REPAIR DONE | " + f_pct(repairProgress), bullColor, badgeUp, labelSizeInput)
    if newReject and not na(activeEventLabel)
        bool badgeUp = activeDir == -1
        activeEventLabel := f_event_set(activeEventLabel, bar_index, badgeUp ? low - eventOffset : high + eventOffset, "REPAIR REJECT | R " + str.tostring(rejectionScore), bearColor, badgeUp, labelSizeInput)

if not showEventLabels and array.size(eventLabels) > 0
    while array.size(eventLabels) > 0
        label oldEvent = array.pop(eventLabels)
        label.delete(oldEvent)
    activeEventLabel := na

if barstate.islast
    if not na(vacuumBox)
        box.delete(vacuumBox)
    if not na(repairBox)
        box.delete(repairBox)
    if not na(topLine)
        line.delete(topLine)
    if not na(bottomLine)
        line.delete(bottomLine)
    if not na(topTagGuide)
        line.delete(topTagGuide)
    if not na(bottomTagGuide)
        line.delete(bottomTagGuide)
    if not na(topTag)
        label.delete(topTag)
    if not na(bottomTag)
        label.delete(bottomTag)
    if not na(vacuumBadge)
        label.delete(vacuumBadge)
    vacuumBox := na
    repairBox := na
    topLine := na
    bottomLine := na
    topTagGuide := na
    bottomTagGuide := na
    topTag := na
    bottomTag := na
    vacuumBadge := na
    if isActive
        int projectionBoost = adaptiveProjection ? timeframe.isweekly ? 2 : timeframe.ismonthly ? 3 : 1 : 1
        int leftX = activeStart
        int rightX = bar_index + projectionBars * projectionBoost
        int guideBars = 6 * projectionBoost
        int railEndX = math.max(leftX + 2, rightX - guideBars)
        int badgeX = int(math.round((leftX + railEndX) / 2.0))
        float mid = math.avg(activeTop, activeBottom)
        if showVacuumZone
            vacuumBox := box.new(leftX, activeTop, railEndX, activeBottom, bgcolor = color.new(zoneColor, 86), border_color = color.new(zoneBorder, 12), border_width = 1)
        if showRepairFill and showVacuumZone and repairStarted and not na(repairLevel)
            float fillTop = activeDir == 1 ? activeTop : repairLevel
            float fillBottom = activeDir == 1 ? repairLevel : activeBottom
            repairBox := box.new(leftX, fillTop, railEndX, fillBottom, bgcolor = color.new(repairColor, 76), border_color = color.new(repairColor, 22), border_width = 1)
        if showVacuumZone
            vacuumBadge := label.new(badgeX, mid, "VACUUM | REPAIR " + f_pct(repairProgress), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, textcolor = f_text_on(zoneColor), color = zoneColor, size = labelSize, textalign = text.align_center)
        if showRightTags
            float tagGapAtr = labelSizeInput == "Huge" ? 1.10 : labelSizeInput == "Large" ? 0.90 : labelSizeInput == "Normal" ? 0.72 : labelSizeInput == "Small" ? 0.58 : 0.48
            float minTagGap = safeAtr * tagGapAtr
            bool staggerTags = activeHeight < minTagGap
            float topTagY = staggerTags ? mid + minTagGap * 0.5 : activeTop
            float bottomTagY = staggerTags ? mid - minTagGap * 0.5 : activeBottom
            topLine := line.new(leftX, activeTop, railEndX, activeTop, color = bearColor, width = 1)
            bottomLine := line.new(leftX, activeBottom, railEndX, activeBottom, color = bullColor, width = 1)
            topTagGuide := line.new(railEndX, activeTop, rightX, topTagY, color = bearColor, width = 2)
            bottomTagGuide := line.new(railEndX, activeBottom, rightX, bottomTagY, color = bullColor, width = 2)
            topTag := label.new(rightX, topTagY, "VAC HIGH " + f_price(activeTop), style = label.style_label_left, textcolor = f_text_on(bearColor), color = bearColor, size = labelSize)
            bottomTag := label.new(rightX, bottomTagY, "VAC LOW " + f_price(activeBottom), style = label.style_label_left, textcolor = f_text_on(bullColor), color = bullColor, size = labelSize)

barCol = not showBarColors ? na :
     vacuumState == "REPAIR DONE" ? color.new(bullColor, 70) :
     vacuumState == "REJECTION RISK" ? color.new(bearColor, 70) :
     vacuumState == "REPAIRING" ? color.new(accentColor, 74) :
     vacuumState == "VACUUM OPEN" ? color.new(neutralColor, 78) : na
barcolor(barCol)

// --------------------------------------------------
// Panel
// --------------------------------------------------
var table panel = table.new(f_pos(panelPositionInput), 2, 8, bgcolor = f_panel_bg(), border_color = f_panel_border(), frame_color = f_panel_border(), border_width = 1, frame_width = 1)

if barstate.islast
    table.set_position(panel, f_pos(panelPositionInput))
    table.clear(panel, 0, 0, 1, 7)
    if showPanel
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Liquidity Vacuum Recovery Map", f_text_on(headerBg), headerBg, panelFontSizeInput, "center")
        f_panel_cell(panel, 0, 1, "Vacuum State", f_panel_label(), f_panel_alt_bg(1), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 1, vacuumState, f_state_color(vacuumState), f_panel_alt_bg(1), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 2, "Quality Score", f_panel_label(), f_panel_alt_bg(2), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 2, isActive ? str.tostring(activeQuality) : "n/a", f_panel_value(), f_panel_alt_bg(2), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 3, "Vacuum Type", f_panel_label(), f_panel_alt_bg(3), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 3, f_dir_text(activeDir), f_panel_value(), f_panel_alt_bg(3), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 4, "Repair Progress", f_panel_label(), f_panel_alt_bg(4), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 4, f_pct(repairProgress), repairColor, f_panel_alt_bg(4), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 5, "Rejection Risk", f_panel_label(), f_panel_alt_bg(5), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 5, isActive ? f_risk_text(rejectionScore) + " / " + str.tostring(rejectionScore) : "n/a", rejectionScore >= 70 ? bearColor : rejectionScore >= 40 ? neutralColor : bullColor, f_panel_alt_bg(5), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 6, "Target Zone", f_panel_label(), f_panel_alt_bg(6), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 6, targetText, f_panel_value(), f_panel_alt_bg(6), panelFontSizeInput, "right")
        f_panel_cell(panel, 0, 7, "Next Context", f_panel_label(), f_panel_alt_bg(7), panelFontSizeInput, "left")
        f_panel_cell(panel, 1, 7, nextContext, f_panel_value(), f_panel_alt_bg(7), panelFontSizeInput, "right")

// --------------------------------------------------
// Alerts
// --------------------------------------------------
vacuumCreatedEvent = newBullVacuum or newBearVacuum
repairStartEvent = newRepairStart
repairHalfEvent = newRepairHalf
repairDoneEvent = newRepairDone
repairRejectEvent = newReject

alertcondition(alertVacuum and vacuumCreatedEvent, "Liquidity Vacuum Created", "A qualified liquidity vacuum has been created.")
alertcondition(alertRepairStart and repairStartEvent, "Vacuum Repair Started", "Price has started repairing the active liquidity vacuum.")
alertcondition(alertRepairHalf and repairHalfEvent, "Vacuum Half Repair", "Repair progress reached the half-repair threshold.")
alertcondition(alertRepairDone and repairDoneEvent, "Vacuum Repair Done", "Repair progress reached the repaired threshold.")
alertcondition(alertRepairFail and repairRejectEvent, "Vacuum Repair Rejection", "Price rejected away from the active vacuum after entering the repair zone.")
````
