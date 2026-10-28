# Range Control Transfer Map [AGPro Series]

- url: https://www.tradingview.com/script/wFBTRyYa-Range-Control-Transfer-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;4784d3a7986b48a6b6431cca4511247f
- version: 2.0

## Description

Range Control Transfer Map [AGPro Series]

🧠 Core Idea

Who controls the range now, and did control transfer from the buyer side to the seller side or from the seller side to the buyer side?


📌 Overview / What it does

Range Control Transfer Map is a range-control visualization tool built to study sideways markets where price rotates between upper and lower boundaries.

The script builds a mature range, separates it into buyer-control and seller-control zones, maps the internal control transfer band, tracks acceptance through that band, scores transfer quality, monitors failed-transfer risk, and summarizes the current control state in a compact AG Pro panel.

It does not predict future price, automate trades, or claim that a control-transfer event must continue. It is a structured decision-support map for reading range control, acceptance, failed transfer risk, and next-context conditions.

[image]https://www.tradingview.com/x/uB6YrijL/[/image]


🎯 Purpose & Design Philosophy

Many range tools answer only one question:

Where are support and resistance?

This script was built to answer a more useful question:

Who controls the range now?

The design goal is to help traders separate passive sideways movement from meaningful control transfer inside a mature range.

[image]https://www.tradingview.com/x/VjXc89YU/[/image]

⚡ Why This Script Is Different

Most range tools draw a box, mark the high, mark the low, and stop there.

This script does NOT treat every range touch as equally important.

Instead, it divides the range into buyer-control and seller-control halves, watches the midpoint transfer band, checks candle body commitment, reviews volume participation, evaluates range health, and tracks whether the active control side is still protected or starting to fail.

The focus is not only where the range is.

The focus is who is gaining or losing control inside it.


⚙️ Methodology

1. Range Detection

The script identifies a working range using recent high/low structure, ATR-normalized range height, and repeated edge interaction.

2. Range Health Scoring

Range Health combines range height balance, edge-touch behavior, and current position relative to the control line.

3. Control Zone Mapping

The upper half becomes the Seller Control Zone.

The lower half becomes the Buyer Control Zone.

The midpoint area becomes the Control Transfer Band.

4. Transfer Evaluation

When price accepts through the transfer band with enough candle body commitment, the script evaluates whether buyer or seller control has transferred.

5. Transfer Quality Scoring

Transfer Quality combines range health, candle body commitment, and volume participation into a 0-100 score.

6. Failure Risk Review

The script monitors whether the active transfer is losing the transfer band and moving back toward control reset.

7. Visual Output

The chart displays buyer/seller control zones, the control transfer band, active transfer labels, failed-transfer labels, right-side control tags, alerts, and a compact AG Pro panel.


🗺️ How to Read the Chart

Seller Control Zone = the upper half of the mature range where seller-side control is evaluated.

Buyer Control Zone = the lower half of the mature range where buyer-side control is evaluated.

Control Transfer Band = the internal midpoint band where control handoff is judged.

SELLER CONTROL = price has accepted through the transfer band in favor of the seller side.

BUYER CONTROL = price has accepted through the transfer band in favor of the buyer side.

BALANCE = the range is mature, but neither side has clean active control.

RANGE BUILDING = the current structure is not mature enough for control-transfer mapping.

Panel = summarizes control side, transfer quality, range health, failure risk, control zone, and next context.


🚦 Signals & States

• CONTROL TRANSFER UP → buyer-side control transfer detected.

• CONTROL TRANSFER DOWN → seller-side control transfer detected.

• FAILED BUYER CONTROL → buyer-side transfer failed back through the control band.

• FAILED SELLER CONTROL → seller-side transfer failed back through the control band.

• BUYER EDGE CONTROL → price reacts from the lower control side.

• SELLER EDGE CONTROL → price reacts from the upper control side.

• BALANCE → no clean control transfer is active.

• RANGE BUILDING → the structure is not mature enough yet.


🔔 Alerts Logic

Alerts trigger when a major range-control event appears.

• Buyer Control Transfer → buyer-side transfer detected.

• Seller Control Transfer → seller-side transfer detected.

• High-Quality Control Transfer → transfer quality reaches the required threshold.

• Failed Control Transfer → active control transfer loses the control band.

• Buyer Edge Control → optional alert for lower-edge control reaction.

• Seller Edge Control → optional alert for upper-edge control reaction.

Alerts are attention markers, not trade instructions.


🧩 Confluence Logic

The context becomes stronger when:

• The range has enough ATR-normalized height
• The range has repeated edge interaction
• Price accepts through the transfer band
• Candle body commitment supports the transfer direction
• Volume participation is not weak
• Transfer Quality is above the required threshold
• Failure Risk remains low after the transfer
• The panel state agrees with the chart label

When these elements do not align, the script avoids treating every range movement as a meaningful control shift.


📊 When to Use

• Range-control review
• Sideways market analysis
• Buyer/seller control mapping
• Failed transfer review
• Range acceptance study
• Crypto, stocks, futures, forex, and liquid markets
• 15m, 30m, 1H, 4H, and 1D charts


⚠️ When NOT to Use

• Very low-liquidity assets
• Extremely noisy micro timeframes
• Strong news spikes that distort range structure
• Clean one-directional trend environments with no mature range
• Markets where every midpoint cross is being over-interpreted
• Situations where a single label is expected to act as a guaranteed signal


🎛️ Key Inputs

• Range Lookback → defines the recent structure window used for range high, range low, and control line.

• Minimum Range Height ATR → defines the minimum range height required for a meaningful control map.

• Maximum Range Height ATR → prevents very wide structures from being treated as clean range-control maps.

• Use Intraday Adaptive Range → allows intraday charts to keep useful control maps without making higher-timeframe charts too noisy.

• Edge Touch Tolerance ATR → controls how close price must come to a range edge to count as an edge interaction.

• Control Band ATR → controls the thickness of the internal transfer band.

• Minimum Transfer Score → defines the quality threshold for meaningful control transfer.

• Minimum Body / Range → controls how much candle body commitment is required.

• Volume Confirm Ratio → defines how much participation is required for full volume credit.

• Failure Buffer ATR → controls where an active transfer starts to fail.

• Maximum Transfer Age → defines how long an active transfer can remain under review.


🖥️ Interface & Visual Design

The visual hierarchy is built around the active range:

The full range box defines the structure.

The upper half shows seller-control territory.

The lower half shows buyer-control territory.

The transfer band marks the internal handoff area.

Event labels mark control transfer and failed-control states.

Right-side tags keep buyer control, seller control, and transfer references visible.

The AG Pro panel compresses the current range-control context into a fast, readable summary.


🧪 Practical Usage Workflow

1. Read the panel Control Side.

2. Check whether the chart is Range Building, Balance, Buyer Control, or Seller Control.

3. Review where price is relative to the Control Transfer Band.

4. If a transfer label appears, compare it with Transfer Quality.

5. Watch whether Failure Risk remains low or starts rising.

6. Use the buyer and seller control zones as context areas, not automatic trade levels.

7. Confirm with broader market structure, liquidity, volume, and risk planning.


🔍 Interpretation Guidelines

A buyer-control transfer does not guarantee upside continuation.

A seller-control transfer does not guarantee downside continuation.

A failed-transfer label means the active control idea weakened.

A range-building state means the structure is not mature enough yet.

The script is best used as a range-control context layer, not as a standalone trading system.


🚫 What This Script Is NOT

This script is not a prediction engine.

It is not financial advice.

It is not an auto-trading system.

It does not provide guaranteed entry or exit signals.

It is not a simple support/resistance box.

It is not another generic range breakout indicator.


⚠️ Limitations & Transparency

Range quality depends on timeframe and market structure.

Very volatile markets can expand beyond a clean control map.

Low-liquidity symbols may create unreliable edge and transfer behavior.

Choppy markets can create repeated control-transfer attempts.

Volume behavior can differ across crypto, stocks, futures, and forex.


🧠 Market Context Notes

Ranges often move through recognizable control phases:

range building → balance → control transfer → defense → failure or continuation.

This script visualizes that sequence so users can avoid treating every support or resistance touch as equally meaningful.


🧾 Use Case Examples

If price accepts through the transfer band from the lower half, the script may mark CONTROL TRANSFER UP.

If price accepts through the transfer band from the upper half, the script may mark CONTROL TRANSFER DOWN.

If an active buyer-control transfer loses the band, the script may mark FAILED BUYER CONTROL.

If an active seller-control transfer loses the band, the script may mark FAILED SELLER CONTROL.


🧱 System Philosophy

The goal is not to predict the next breakout.

The goal is to understand control inside the range.

This script treats range behavior as a sequence:

structure → control zone → transfer band → acceptance → defense or failure.


🔐 Non-Promise Statement

No control-transfer label guarantees continuation.

No failed-transfer label guarantees reversal.

No range zone guarantees support or resistance.

All outputs should be interpreted as analytical context.


📉 Risk Disclosure

Trading involves risk.

This script is for educational and analytical purposes only.

It does not provide financial advice, investment advice, or guaranteed trading outcomes.

Users are fully responsible for their own decisions, risk management, and trade execution.


📚 Educational Note

Use the script to study how control shifts inside mature ranges.

The most useful question is not only where the range high and low are.

The better question is whether control has actually transferred inside the range.

## Source Code

````pine
// --------------------------------------------------
// Range Control Transfer Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.3
//
// Range Control Transfer Map detects mature sideways structure, separates the
// range into buyer-control and seller-control halves, tracks when acceptance
// transfers across the control line, and summarizes range health, transfer
// quality, failure risk, and next context in a compact decision panel. A
// transfer follow-rate layer reports how often confirmed control transfers
// on this chart actually reached the far edge of the controlled half before
// failing back through the failure line. Version 1.2 added intraday-aware
// range tolerance so 4H and lower charts can keep useful control maps
// without making daily and weekly screenshots too noisy.
// --------------------------------------------------

//@version=6
indicator("Range Control Transfer Map [AGPro Series]",
     shorttitle = "AGP RCTM",
     overlay = true,
     max_boxes_count = 40,
     max_lines_count = 90,
     max_labels_count = 180)

// --------------------------------------------------
// Inputs
// --------------------------------------------------
G_RANGE = "Range Engine"
G_TRANSFER = "Transfer Logic"
G_VISUAL = "Visuals"
G_PANEL = "Panel"
G_ALERTS = "Alerts"

atrLength = input.int(14, "ATR Length", minval = 1, maxval = 300, group = G_RANGE,
     tooltip = "ATR length used to normalize range height, control-band width, labels, shelves, and failure buffers.")
rangeLookback = input.int(84, "Range Lookback", minval = 20, maxval = 500, group = G_RANGE,
     tooltip = "Lookback used to build the active range high, range low, and internal control line.")
minRangeAtr = input.float(1.25, "Minimum Range Height ATR", minval = 0.20, maxval = 20.0, step = 0.05, group = G_RANGE,
     tooltip = "Minimum range height, measured in ATR, required before control-transfer logic becomes active.")
maxRangeAtr = input.float(9.50, "Maximum Range Height ATR", minval = 0.50, maxval = 50.0, step = 0.25, group = G_RANGE,
     tooltip = "Maximum range height, measured in ATR, allowed before the structure is considered too wide for clean range-control planning.")
useIntradayAdaptiveRange = input.bool(true, "Use Intraday Adaptive Range", group = G_RANGE,
     tooltip = "Allows a wider ATR-normalized range on intraday charts while keeping daily and weekly charts stricter.")
intradayRangeMultiplier = input.float(1.25, "Intraday Range Multiplier", minval = 1.00, maxval = 2.00, step = 0.05, group = G_RANGE,
     tooltip = "Multiplier applied to Maximum Range Height ATR on intraday charts only.")
edgeTouchAtr = input.float(0.30, "Edge Touch Tolerance ATR", minval = 0.02, maxval = 2.0, step = 0.01, group = G_RANGE,
     tooltip = "ATR tolerance used to count recent upper and lower range-edge interactions.")
minEdgeTouches = input.int(2, "Minimum Edge Touches", minval = 1, maxval = 20, group = G_RANGE,
     tooltip = "Minimum combined upper and lower edge interactions required before the range is considered mature.")
controlBandAtr = input.float(0.18, "Control Band ATR", minval = 0.02, maxval = 2.0, step = 0.01, group = G_RANGE,
     tooltip = "Half-width around the range midpoint used as the control-transfer acceptance band.")

minTransferScore = input.int(66, "Minimum Transfer Score", minval = 1, maxval = 100, group = G_TRANSFER,
     tooltip = "Minimum 0-100 score required before a control transfer is promoted to a high-quality event.")
minBodyRatio = input.float(0.42, "Minimum Body / Range", minval = 0.05, maxval = 0.95, step = 0.01, group = G_TRANSFER,
     tooltip = "Minimum candle body-to-range ratio required before a control transfer can be treated as meaningful.")
volumeLength = input.int(30, "Volume Average Length", minval = 2, maxval = 300, group = G_TRANSFER,
     tooltip = "Volume average length used to estimate whether the transfer has real participation.")
volumeConfirmRatio = input.float(1.05, "Volume Confirm Ratio", minval = 0.10, maxval = 10.0, step = 0.05, group = G_TRANSFER,
     tooltip = "Current volume divided by average volume needed for full transfer-participation credit.")
failureBufferAtr = input.float(0.22, "Failure Buffer ATR", minval = 0.00, maxval = 2.0, step = 0.01, group = G_TRANSFER,
     tooltip = "ATR buffer beyond the control band where the active transfer begins to fail.")
maxTransferAge = input.int(120, "Maximum Transfer Age", minval = 10, maxval = 800, group = G_TRANSFER,
     tooltip = "Maximum number of bars an active control-transfer state can remain active before it expires.")

showRangeBox = input.bool(true, "Show Range Box", group = G_VISUAL,
     tooltip = "Shows the complete active range structure.")
showControlHalves = input.bool(true, "Show Buyer / Seller Control Halves", group = G_VISUAL,
     tooltip = "Shows the buyer-control and seller-control halves inside the active range.")
showControlBand = input.bool(true, "Show Transfer Band", group = G_VISUAL,
     tooltip = "Shows the midpoint control band that price must accept through before control transfers.")
showCenteredText = input.bool(false, "Show Centered Zone Text", group = G_VISUAL,
     tooltip = "Shows centered text inside the control halves and transfer band.")
showRails = input.bool(true, "Show Edge Rails", group = G_VISUAL,
     tooltip = "Shows upper, lower, and transfer rails.")
showEventLabels = input.bool(true, "Show Event Labels", group = G_VISUAL,
     tooltip = "Shows control transfer, failed transfer, and range-edge control labels.")
showTransferLabels = input.bool(true, "Show Transfer Labels", group = G_VISUAL,
     tooltip = "Shows labels when control transfers across the midpoint band.")
showFailedLabels = input.bool(true, "Show Failed Transfer Labels", group = G_VISUAL,
     tooltip = "Shows labels when the active control transfer fails back through the control band.")
showEdgeLabels = input.bool(false, "Show Edge Control Labels", group = G_VISUAL,
     tooltip = "Shows labels when price reacts from the buyer or seller control side.")
hideLabelsWhenInactive = input.bool(true, "Hide Labels When Range Is Building", group = G_VISUAL,
     tooltip = "Clears retained event labels when the current chart no longer has a mature range. This keeps high-timeframe screenshots cleaner.")
showRightTags = input.bool(true, "Show Right-Side Tags", group = G_VISUAL,
     tooltip = "Shows compact right-side tags for buyer control, seller control, and the active transfer line.")
showBarColors = input.bool(false, "Color Bars By Control", group = G_VISUAL,
     tooltip = "Colors bars lightly according to the active control side.")
projectionBars = input.int(78, "Projection Bars", minval = 10, maxval = 400, group = G_VISUAL,
     tooltip = "Number of bars used for projected boxes, rails, and right-side tags.")
labelCooldownBars = input.int(40, "Label Cooldown Bars", minval = 1, maxval = 140, group = G_VISUAL,
     tooltip = "Minimum spacing between repeated event labels.")
maxEventLabels = input.int(5, "Maximum Event Labels", minval = 4, maxval = 60, group = G_VISUAL,
     tooltip = "Maximum historical event labels retained on the chart.")
labelOffsetAtr = input.float(0.85, "Label Offset ATR", minval = 0.05, maxval = 5.0, step = 0.05, group = G_VISUAL,
     tooltip = "ATR-based label offset, measured from the recent candle cluster, so labels remain readable above or below candles.")
labelSizeInput = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_VISUAL,
     tooltip = "Controls chart label and right-side tag font size.")

showPanel = input.bool(true, "Show Panel", group = G_PANEL,
     tooltip = "Shows or hides the AG Pro dashboard panel.")
panelPositionInput = input.string("Top Right", "Panel Location", options = ["Top Right", "Top Left", "Middle Right", "Middle Left", "Bottom Right", "Bottom Left"], group = G_PANEL,
     tooltip = "Controls dashboard location.")
panelTheme = input.string("Dark", "Panel Theme", options = ["Dark", "Slate"], group = G_PANEL,
     tooltip = "Controls dashboard theme.")
panelFontSizeInput = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large"], group = G_PANEL,
     tooltip = "Controls dashboard font size.")

alertTransfer = input.bool(true, "Alert: Control Transfer", group = G_ALERTS,
     tooltip = "Enables alerts when buyer or seller control transfers across the midpoint band.")
alertReady = input.bool(true, "Alert: High-Quality Transfer", group = G_ALERTS,
     tooltip = "Enables alerts when a control transfer reaches the minimum transfer score.")
alertFailed = input.bool(true, "Alert: Failed Transfer", group = G_ALERTS,
     tooltip = "Enables alerts when the active control transfer fails back through the control band.")
alertEdge = input.bool(false, "Alert: Range Edge Control", group = G_ALERTS,
     tooltip = "Enables alerts when price reacts from the buyer or seller control edge.")

// --------------------------------------------------
// AGPro Color Palette
// --------------------------------------------------
headerBg = color.rgb(37, 99, 235)
headerText = color.rgb(245, 247, 250)
panelBgDark = color.rgb(15, 23, 42)
panelBgSlate = color.rgb(30, 41, 59)
panelBorder = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
buyerColor = color.rgb(34, 197, 166)
sellerColor = color.rgb(244, 114, 182)
neutralColor = color.rgb(245, 189, 92)
accentColor = color.rgb(129, 140, 248)
zoneBorder = color.rgb(99, 102, 241)

// --------------------------------------------------
// Helpers
// --------------------------------------------------
f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_score(float value) =>
    int(math.round(f_clamp(value, 0.0, 100.0)))

f_size(string sizeInput) =>
    result = size.normal
    if sizeInput == "Tiny"
        result := size.tiny
    else if sizeInput == "Small"
        result := size.small
    else if sizeInput == "Large"
        result := size.large
    result

f_pos(string posInput) =>
    result = position.top_right
    if posInput == "Top Left"
        result := position.top_left
    else if posInput == "Middle Right"
        result := position.middle_right
    else if posInput == "Middle Left"
        result := position.middle_left
    else if posInput == "Bottom Right"
        result := position.bottom_right
    else if posInput == "Bottom Left"
        result := position.bottom_left
    result

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

f_ratio(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")

f_side_text(int side) =>
    side == 1 ? "BUYER CONTROL" : side == -1 ? "SELLER CONTROL" : "BALANCE"

f_side_color(int side) =>
    side == 1 ? buyerColor : side == -1 ? sellerColor : neutralColor

// --------------------------------------------------
// Core Calculations
// --------------------------------------------------
atr = ta.atr(atrLength)
safeAtr = math.max(atr, syminfo.mintick)

rangeHigh = ta.highest(high, rangeLookback)
rangeLow = ta.lowest(low, rangeLookback)
rangeHeight = math.max(rangeHigh - rangeLow, syminfo.mintick)
rangeAtr = rangeHeight / safeAtr
controlLine = math.avg(rangeHigh, rangeLow)
controlBandTop = controlLine + controlBandAtr * safeAtr
controlBandBot = controlLine - controlBandAtr * safeAtr

upperTouch = high >= rangeHigh - edgeTouchAtr * safeAtr
lowerTouch = low <= rangeLow + edgeTouchAtr * safeAtr
upperTouchCount = ta.sma(upperTouch ? 1.0 : 0.0, rangeLookback) * rangeLookback
lowerTouchCount = ta.sma(lowerTouch ? 1.0 : 0.0, rangeLookback) * rangeLookback
touchTotal = upperTouchCount + lowerTouchCount

effectiveMaxRangeAtr = useIntradayAdaptiveRange and timeframe.isintraday ? maxRangeAtr * intradayRangeMultiplier : maxRangeAtr
rangeHeightOk = rangeAtr >= minRangeAtr and rangeAtr <= effectiveMaxRangeAtr
rangeTouchOk = touchTotal >= minEdgeTouches
isMatureRange = rangeHeightOk and rangeTouchOk and not na(rangeHigh) and not na(rangeLow)

heightBalance = rangeAtr < minRangeAtr ? rangeAtr / minRangeAtr * 55.0 : rangeAtr > maxRangeAtr ? math.max(0.0, 100.0 - (rangeAtr - maxRangeAtr) / maxRangeAtr * 100.0) : 100.0
touchScore = f_clamp(touchTotal / math.max(minEdgeTouches * 2.0, 1.0) * 100.0, 0.0, 100.0)
midDistance = math.abs(close - controlLine) / math.max(rangeHeight * 0.5, syminfo.mintick)
balanceScore = f_clamp(100.0 - midDistance * 70.0, 0.0, 100.0)
rangeHealth = f_score(heightBalance * 0.38 + touchScore * 0.34 + balanceScore * 0.28)

barRange = math.max(high - low, syminfo.mintick)
body = math.abs(close - open)
bodyRatio = body / barRange
volAvg = ta.sma(volume, volumeLength)
volRatio = na(volAvg) or volAvg <= 0.0 ? 1.0 : volume / volAvg
volScore = f_clamp(volRatio / math.max(volumeConfirmRatio, 0.01) * 100.0, 0.0, 100.0)
bodyScore = f_clamp(bodyRatio / math.max(minBodyRatio, 0.01) * 100.0, 0.0, 100.0)

buyerAcceptance = isMatureRange and close > controlBandTop and bodyRatio >= minBodyRatio
sellerAcceptance = isMatureRange and close < controlBandBot and bodyRatio >= minBodyRatio

var int activeSide = 0
var int transferBar = na
var float transferPrice = na
var int transferQuality = 0

priorSide = nz(activeSide[1], 0)
rawBuyerTransfer = buyerAcceptance and priorSide <= 0
rawSellerTransfer = sellerAcceptance and priorSide >= 0

candidateQuality = f_score(rangeHealth * 0.40 + bodyScore * 0.32 + volScore * 0.28)
buyerTransfer = rawBuyerTransfer and candidateQuality >= math.max(minTransferScore - 12, 1)
sellerTransfer = rawSellerTransfer and candidateQuality >= math.max(minTransferScore - 12, 1)

if buyerTransfer
    activeSide := 1
    transferBar := bar_index
    transferPrice := close
    transferQuality := candidateQuality
else if sellerTransfer
    activeSide := -1
    transferBar := bar_index
    transferPrice := close
    transferQuality := candidateQuality
else if not isMatureRange
    activeSide := 0
    transferBar := na
    transferPrice := na
    transferQuality := 0
else if not na(transferBar) and bar_index - transferBar > maxTransferAge
    activeSide := close > controlLine ? 1 : close < controlLine ? -1 : 0
    transferBar := na
    transferPrice := na
    transferQuality := 0
else
    activeSide := priorSide
    transferBar := nz(transferBar[1], transferBar)
    transferPrice := nz(transferPrice[1], transferPrice)
    transferQuality := nz(transferQuality[1], transferQuality)

buyerFailureLine = controlBandBot - failureBufferAtr * safeAtr
sellerFailureLine = controlBandTop + failureBufferAtr * safeAtr
buyerFailed = activeSide[1] == 1 and close < buyerFailureLine
sellerFailed = activeSide[1] == -1 and close > sellerFailureLine
failedTransfer = buyerFailed or sellerFailed

if failedTransfer
    activeSide := 0
    transferBar := na
    transferPrice := na
    transferQuality := 0

nearUpperEdge = isMatureRange and high >= rangeHigh - edgeTouchAtr * safeAtr
nearLowerEdge = isMatureRange and low <= rangeLow + edgeTouchAtr * safeAtr
sellerEdgeControl = nearUpperEdge and close < open and close < rangeHigh - edgeTouchAtr * safeAtr
buyerEdgeControl = nearLowerEdge and close > open and close > rangeLow + edgeTouchAtr * safeAtr

failureRiskRaw = activeSide == 1 ? f_clamp((controlBandTop - close) / math.max(controlBandTop - buyerFailureLine, syminfo.mintick) * 100.0, 0.0, 100.0) : activeSide == -1 ? f_clamp((close - controlBandBot) / math.max(sellerFailureLine - controlBandBot, syminfo.mintick) * 100.0, 0.0, 100.0) : 45.0
failureRisk = f_score(failureRiskRaw)

rangePosition = f_clamp((close - rangeLow) / rangeHeight * 100.0, 0.0, 100.0)
activeAge = na(transferBar) ? 0 : bar_index - transferBar
highQualityTransfer = (buyerTransfer or sellerTransfer) and candidateQuality >= minTransferScore

// Transfer follow-rate layer: each confirmed control transfer is tracked
// once. It counts as followed when price reaches the far edge of the
// controlled half (the range edge minus the touch tolerance) before
// closing back through the failure line, and as failed when the failure
// line is reclaimed first or the tracking window times out. Target and
// failure levels are frozen at registration, so later range drift cannot
// disturb an open measurement. Resolution runs before registration.
transferConfirmedNew = barstate.isconfirmed and (buyerTransfer or sellerTransfer)
var bool tfTrkOn = false
var int tfTrkDir = 0
var float tfTrkTgt = na
var float tfTrkInv = na
var int tfTrkStart = na
var int transferFollowW = 0
var int transferFollowN = 0
if tfTrkOn
    tfFollowed = tfTrkDir == 1 ? high >= tfTrkTgt : low <= tfTrkTgt
    tfFailed = tfTrkDir == 1 ? close < tfTrkInv : close > tfTrkInv
    tfTimeout = not na(tfTrkStart) and bar_index - tfTrkStart >= maxTransferAge
    if tfFailed or tfTimeout
        transferFollowN += 1
        tfTrkOn := false
    else if tfFollowed
        transferFollowN += 1
        transferFollowW += 1
        tfTrkOn := false
if transferConfirmedNew and not tfTrkOn
    tfTrkOn := true
    tfTrkDir := buyerTransfer ? 1 : -1
    tfTrkTgt := buyerTransfer ? rangeHigh - edgeTouchAtr * safeAtr : rangeLow + edgeTouchAtr * safeAtr
    tfTrkInv := buyerTransfer ? buyerFailureLine : sellerFailureLine
    tfTrkStart := bar_index
transferFollowRate = transferFollowN > 0 ? 100.0 * transferFollowW / transferFollowN : na
transferFollowReady = transferFollowN >= 8

stateText = switch
    not isMatureRange => "RANGE BUILDING"
    activeSide == 1 => "BUYER CONTROL"
    activeSide == -1 => "SELLER CONTROL"
    => "BALANCE"
nextContext = switch
    not isMatureRange => "Wait for mature range"
    failedTransfer => "Control reset"
    activeSide == 1 and failureRisk > 70 => "Defend buyer control"
    activeSide == -1 and failureRisk > 70 => "Defend seller control"
    activeSide == 1 => "Track upper control"
    activeSide == -1 => "Track lower control"
    => "Wait transfer"

// --------------------------------------------------
// Visual Objects
// --------------------------------------------------
labelSize = f_size(labelSizeInput)
rightX = bar_index + projectionBars
leftX = math.max(bar_index - rangeLookback + 1, 0)

var box rangeBox = na
var box buyerBox = na
var box sellerBox = na
var box transferBox = na
var line upperRail = na
var line lowerRail = na
var line controlRail = na
var line transferRail = na
var label buyerTag = na
var label sellerTag = na
var label controlTag = na
var label centerTag = na
var label buyerCenterTag = na
var label sellerCenterTag = na

sellerMid = math.avg(rangeHigh, controlBandTop)
buyerMid = math.avg(rangeLow, controlBandBot)

if barstate.islast
    if isMatureRange and showRangeBox
        if na(rangeBox)
            rangeBox := box.new(leftX, rangeHigh, rightX, rangeLow, bgcolor = color.new(accentColor, 93), border_color = color.new(zoneBorder, 55), border_width = 1)
        else
            box.set_lefttop(rangeBox, leftX, rangeHigh)
            box.set_rightbottom(rangeBox, rightX, rangeLow)
            box.set_bgcolor(rangeBox, color.new(accentColor, 93))
            box.set_border_color(rangeBox, color.new(zoneBorder, 55))
    else if not na(rangeBox)
        box.delete(rangeBox)
        rangeBox := na

    if isMatureRange and showControlHalves
        if na(sellerBox)
            sellerBox := box.new(leftX, rangeHigh, rightX, controlBandTop, bgcolor = color.new(sellerColor, 86), border_color = color.new(sellerColor, 45), border_width = 1)
        else
            box.set_lefttop(sellerBox, leftX, rangeHigh)
            box.set_rightbottom(sellerBox, rightX, controlBandTop)
            box.set_bgcolor(sellerBox, color.new(sellerColor, 86))
            box.set_border_color(sellerBox, color.new(sellerColor, 45))
        if na(buyerBox)
            buyerBox := box.new(leftX, controlBandBot, rightX, rangeLow, bgcolor = color.new(buyerColor, 86), border_color = color.new(buyerColor, 45), border_width = 1)
        else
            box.set_lefttop(buyerBox, leftX, controlBandBot)
            box.set_rightbottom(buyerBox, rightX, rangeLow)
            box.set_bgcolor(buyerBox, color.new(buyerColor, 86))
            box.set_border_color(buyerBox, color.new(buyerColor, 45))
    else
        if not na(sellerBox)
            box.delete(sellerBox)
            sellerBox := na
        if not na(buyerBox)
            box.delete(buyerBox)
            buyerBox := na

    if isMatureRange and showControlBand
        if na(transferBox)
            transferBox := box.new(leftX, controlBandTop, rightX, controlBandBot, bgcolor = color.new(neutralColor, 88), border_color = color.new(neutralColor, 42), border_width = 1)
        else
            box.set_lefttop(transferBox, leftX, controlBandTop)
            box.set_rightbottom(transferBox, rightX, controlBandBot)
            box.set_bgcolor(transferBox, color.new(neutralColor, 88))
            box.set_border_color(transferBox, color.new(neutralColor, 42))
    else if not na(transferBox)
        box.delete(transferBox)
        transferBox := na

    if isMatureRange and showRails
        if na(upperRail)
            upperRail := line.new(leftX, rangeHigh, rightX, rangeHigh, color = color.new(sellerColor, 5), width = 1)
            lowerRail := line.new(leftX, rangeLow, rightX, rangeLow, color = color.new(buyerColor, 5), width = 1)
            controlRail := line.new(leftX, controlLine, rightX, controlLine, color = color.new(accentColor, 20), width = 1, style = line.style_dotted)
            transferY = na(transferPrice) ? controlLine : transferPrice
            transferRail := line.new(leftX, transferY, rightX, transferY, color = color.new(f_side_color(activeSide), 35), width = 1, style = line.style_dashed)
        else
            line.set_xy1(upperRail, leftX, rangeHigh)
            line.set_xy2(upperRail, rightX, rangeHigh)
            line.set_xy1(lowerRail, leftX, rangeLow)
            line.set_xy2(lowerRail, rightX, rangeLow)
            line.set_xy1(controlRail, leftX, controlLine)
            line.set_xy2(controlRail, rightX, controlLine)
            line.set_xy1(transferRail, leftX, na(transferPrice) ? controlLine : transferPrice)
            line.set_xy2(transferRail, rightX, na(transferPrice) ? controlLine : transferPrice)
            line.set_color(transferRail, color.new(f_side_color(activeSide), activeSide == 0 ? 80 : 35))
    else
        if not na(upperRail)
            line.delete(upperRail)
            line.delete(lowerRail)
            line.delete(controlRail)
            line.delete(transferRail)
            upperRail := na
            lowerRail := na
            controlRail := na
            transferRail := na

    if showRightTags and isMatureRange
        if na(sellerTag)
            sellerTag := label.new(rightX, rangeHigh, "SELLER CTRL", style = label.style_label_left, textcolor = color.white, color = sellerColor, size = labelSize)
            buyerTag := label.new(rightX, rangeLow, "BUYER CTRL", style = label.style_label_left, textcolor = color.white, color = buyerColor, size = labelSize)
            controlTag := label.new(rightX, controlLine, "TRANSFER " + str.tostring(rangeHealth), style = label.style_label_left, textcolor = color.white, color = accentColor, size = labelSize)
        else
            label.set_xy(sellerTag, rightX, rangeHigh)
            label.set_text(sellerTag, "SELLER CTRL")
            label.set_color(sellerTag, sellerColor)
            label.set_size(sellerTag, labelSize)
            label.set_xy(buyerTag, rightX, rangeLow)
            label.set_text(buyerTag, "BUYER CTRL")
            label.set_color(buyerTag, buyerColor)
            label.set_size(buyerTag, labelSize)
            label.set_xy(controlTag, rightX, controlLine)
            label.set_text(controlTag, activeSide == 0 ? "BALANCE " + str.tostring(rangeHealth) : (activeSide == 1 ? "BUYER " : "SELLER ") + str.tostring(transferQuality))
            label.set_color(controlTag, f_side_color(activeSide))
            label.set_size(controlTag, labelSize)
    else
        if not na(sellerTag)
            label.delete(sellerTag)
            label.delete(buyerTag)
            label.delete(controlTag)
            sellerTag := na
            buyerTag := na
            controlTag := na

    if showCenteredText and isMatureRange
        centerX = int(math.round((leftX + rightX) * 0.5))
        if na(centerTag)
            centerTag := label.new(centerX, controlLine, "Control Transfer Band", style = label.style_label_center, textcolor = color.white, color = neutralColor, size = labelSize)
            sellerCenterTag := label.new(centerX, sellerMid, "Seller Control Zone", style = label.style_label_center, textcolor = color.white, color = sellerColor, size = labelSize)
            buyerCenterTag := label.new(centerX, buyerMid, "Buyer Control Zone", style = label.style_label_center, textcolor = color.white, color = buyerColor, size = labelSize)
        else
            label.set_xy(centerTag, centerX, controlLine)
            label.set_text(centerTag, "Control Transfer Band")
            label.set_size(centerTag, labelSize)
            label.set_xy(sellerCenterTag, centerX, sellerMid)
            label.set_text(sellerCenterTag, "Seller Control Zone")
            label.set_size(sellerCenterTag, labelSize)
            label.set_xy(buyerCenterTag, centerX, buyerMid)
            label.set_text(buyerCenterTag, "Buyer Control Zone")
            label.set_size(buyerCenterTag, labelSize)
    else
        if not na(centerTag)
            label.delete(centerTag)
            label.delete(sellerCenterTag)
            label.delete(buyerCenterTag)
            centerTag := na
            sellerCenterTag := na
            buyerCenterTag := na

// --------------------------------------------------
// Event Labels
// --------------------------------------------------
var label[] eventLabels = array.new<label>()
var int lastTransferLabel = na
var int lastFailureLabel = na
var int lastEdgeLabel = na

f_add_label(float y, string txt, color bg, styleInput) =>
    newLabel = label.new(bar_index, y, txt, style = styleInput, textcolor = color.white, color = bg, size = labelSize)
    array.push(eventLabels, newLabel)
    if array.size(eventLabels) > maxEventLabels
        label.delete(array.shift(eventLabels))

// Event labels are anchored to the recent candle cluster extremes, not to
// a single bar, so they sit clear of surrounding candles inside the range.
labelBaseLow = ta.lowest(low, 5)
labelBaseHigh = ta.highest(high, 5)

canTransferLabel = na(lastTransferLabel) or bar_index - lastTransferLabel >= labelCooldownBars
canFailureLabel = na(lastFailureLabel) or bar_index - lastFailureLabel >= labelCooldownBars
canEdgeLabel = na(lastEdgeLabel) or bar_index - lastEdgeLabel >= labelCooldownBars

if showEventLabels and showTransferLabels and buyerTransfer and canTransferLabel
    f_add_label(labelBaseLow - labelOffsetAtr * safeAtr, "CONTROL TRANSFER UP | Q " + str.tostring(candidateQuality), buyerColor, label.style_label_up)
    lastTransferLabel := bar_index

if showEventLabels and showTransferLabels and sellerTransfer and canTransferLabel
    f_add_label(labelBaseHigh + labelOffsetAtr * safeAtr, "CONTROL TRANSFER DOWN | Q " + str.tostring(candidateQuality), sellerColor, label.style_label_down)
    lastTransferLabel := bar_index

if showEventLabels and showFailedLabels and failedTransfer and canFailureLabel
    failText = buyerFailed ? "FAILED BUYER CONTROL" : "FAILED SELLER CONTROL"
    failY = buyerFailed ? labelBaseHigh + labelOffsetAtr * safeAtr : labelBaseLow - labelOffsetAtr * safeAtr
    failStyle = buyerFailed ? label.style_label_down : label.style_label_up
    f_add_label(failY, failText + " | R " + str.tostring(failureRisk), neutralColor, failStyle)
    lastFailureLabel := bar_index

if showEventLabels and showEdgeLabels and buyerEdgeControl and canEdgeLabel
    f_add_label(labelBaseLow - labelOffsetAtr * safeAtr, "BUYER EDGE CONTROL | H " + str.tostring(rangeHealth), buyerColor, label.style_label_up)
    lastEdgeLabel := bar_index

if showEventLabels and showEdgeLabels and sellerEdgeControl and canEdgeLabel
    f_add_label(labelBaseHigh + labelOffsetAtr * safeAtr, "SELLER EDGE CONTROL | H " + str.tostring(rangeHealth), sellerColor, label.style_label_down)
    lastEdgeLabel := bar_index

if barstate.islast and hideLabelsWhenInactive and not isMatureRange and array.size(eventLabels) > 0
    for i = 0 to array.size(eventLabels) - 1
        label.delete(array.get(eventLabels, i))
    array.clear(eventLabels)

// --------------------------------------------------
// Panel
// --------------------------------------------------
panelBg = panelTheme == "Slate" ? panelBgSlate : panelBgDark
panelSize = f_size(panelFontSizeInput)
var table panel = na
var string panelPosMemory = ""

if showPanel and (na(panel) or panelPosMemory != panelPositionInput)
    if not na(panel)
        table.delete(panel)
    panel := table.new(f_pos(panelPositionInput), 2, 8, bgcolor = panelBg, border_color = panelBorder, border_width = 1)
    panelPosMemory := panelPositionInput

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosMemory := ""

if showPanel and not na(panel) and barstate.islast
    table.cell(panel, 0, 0, "AG Pro Range Control Transfer Map", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.cell(panel, 1, 0, "", text_color = headerText, bgcolor = headerBg, text_size = panelSize)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, "Control Side", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 1, 1, stateText, text_color = f_side_color(activeSide), bgcolor = panelBg, text_size = panelSize)

    table.cell(panel, 0, 2, "Transfer Quality", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 1, 2, activeSide == 0 ? "n/a" : str.tostring(transferQuality), text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize)

    table.cell(panel, 0, 3, "Range Health", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 1, 3, str.tostring(rangeHealth) + " / " + f_ratio(rangeAtr) + " ATR", text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize)

    table.cell(panel, 0, 4, "Failure Risk", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize)
    riskColor = failureRisk > 70 ? sellerColor : failureRisk < 35 ? buyerColor : neutralColor
    riskText = failureRisk > 70 ? "High" : failureRisk < 35 ? "Low" : "Medium"
    table.cell(panel, 1, 4, activeSide == 0 ? "Not active" : riskText + " / " + str.tostring(failureRisk), text_color = riskColor, bgcolor = panelBg, text_size = panelSize)

    table.cell(panel, 0, 5, "Control Zone", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize)
    zoneText = f_price(rangeLow) + " / " + f_price(controlLine) + " / " + f_price(rangeHigh)
    table.cell(panel, 1, 5, zoneText, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize)

    transferFollowText = transferFollowN == 0 ? "-" : str.tostring(int(math.round(transferFollowRate))) + "%  n=" + str.tostring(transferFollowN)
    transferFollowColor = transferFollowReady ? (transferFollowRate >= 55.0 ? buyerColor : transferFollowRate >= 40.0 ? neutralColor : sellerColor) : panelLabelCol
    table.cell(panel, 0, 6, "Transfer Follow", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 1, 6, transferFollowText, text_color = transferFollowColor, bgcolor = panelBg, text_size = panelSize)

    table.cell(panel, 0, 7, "Next Context", text_color = panelLabelCol, bgcolor = panelBg, text_size = panelSize)
    table.cell(panel, 1, 7, nextContext, text_color = panelValueCol, bgcolor = panelBg, text_size = panelSize)

// --------------------------------------------------
// Bar Colors and Alerts
// --------------------------------------------------
barColor = activeSide == 1 ? color.new(buyerColor, 78) : activeSide == -1 ? color.new(sellerColor, 78) : na
barcolor(showBarColors ? barColor : na)

alertcondition(alertTransfer and buyerTransfer, "Buyer Control Transfer", "Range Control Transfer Map: buyer control transfer detected.")
alertcondition(alertTransfer and sellerTransfer, "Seller Control Transfer", "Range Control Transfer Map: seller control transfer detected.")
alertcondition(alertReady and highQualityTransfer, "High-Quality Control Transfer", "Range Control Transfer Map: high-quality control transfer detected.")
alertcondition(alertFailed and failedTransfer, "Failed Control Transfer", "Range Control Transfer Map: active control transfer failed.")
alertcondition(alertEdge and buyerEdgeControl, "Buyer Edge Control", "Range Control Transfer Map: buyer edge control reaction detected.")
alertcondition(alertEdge and sellerEdgeControl, "Seller Edge Control", "Range Control Transfer Map: seller edge control reaction detected.")
````
