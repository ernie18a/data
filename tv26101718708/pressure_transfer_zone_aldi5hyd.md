# Pressure Transfer Zone

- url: https://www.tradingview.com/script/AlDi5hYd-Pressure-Transfer-Zone/
- type: indicator
- pine_id: PUB;150e4716d5df449e86c914972a29aec6
- version: 1.0

## Description

Many reversal indicators tell you when a market looks stretched. Pressure Transfer Zone asks a harder question: when price returns to the extreme, can the side that drove it there still make meaningful progress?

This indicator was built to identify a specific form of failed continuation. It waits for a strong directional drive, a real retreat, and then a second attempt at the extreme. If that second attempt makes little progress and closes with clear rejection, the script freezes the structure into a decision zone. From there, price must prove that control has actually transferred before a signal is confirmed.

The goal is not to call every top or bottom. The goal is to isolate the moments when a mature move may be losing control, show that process directly on the chart, and give the trader clear confirmation and invalidation levels.

WHO IT IS FOR

Pressure Transfer Zone is designed for intraday, swing, and position traders who use price action and want a more disciplined way to evaluate exhaustion, failed breakouts, failed continuation, and early reversals.

It is designed for liquid stocks, futures, forex, and cryptocurrency on standard candlestick charts. The engine does not run on Heikin Ashi, Renko, or other synthetic chart types because their prices can distort the structure being measured.

THE IDEA BEHIND IT

A strong trend does not end simply because price is overbought, oversold, or extended. Strong moves can remain extended for a long time. What matters is whether the original side can still produce results when it gets another opportunity.

The pattern develops in five stages:

1. A mature directional drive establishes real displacement.
2. Price makes a meaningful retreat away from the extreme.
3. The original side returns for a second attempt.
4. That second attempt produces limited progress and a weaker close.
5. Price confirms the transfer with a qualified break of the selected boundary or, in Sniper mode, with that break followed by a successful first retest.

This is an effort-versus-result test expressed entirely through price. The script does not claim to measure order flow, bid/ask delta, institutional activity, hidden liquidity, or volume pressure.

HOW THE MATHEMATICS WORKS

The first filter is directional efficiency:

Directional efficiency = net directional change / total absolute bar-to-bar movement

A clean drive that travels mostly in one direction receives a higher score. A noisy move that covers a lot of distance but makes little net progress receives a lower score.

The selected Source is used for net displacement and path efficiency. The zone itself is always built from confirmed OHLC prices.

The drive must also meet volatility, range, closing-location, and local-extreme requirements. Under the default pace profiles, it must:

* Produce at least 1.25 ATR of net directional displacement.
* Span at least 2.00 to 2.50 ATR, depending on the selected pace.
* Meet a directional-efficiency threshold of 0.40 to 0.48.
* Close in the outer 28% of the drive range.
* Create a fresh local extreme.

ATR is measured with a 14-bar lookback and frozen when the sequence begins. This prevents later volatility changes from moving the event’s established thresholds.

The retreat must travel at least the greater of 0.55 ATR or 18% of the original drive range, and the closing price must confirm that full retreat distance.

When price returns to the extreme, the second attempt must show deterioration. By default:

* Price must return to within the greater of 0.30 ATR or 8% of the original drive range from the first extreme.
* New progress beyond the first extreme cannot exceed 0.20 ATR.
* The second push cannot exceed 72% of the original drive range.
* The close must migrate away from the first attempt by at least 0.10 ATR.
* Rejection must equal at least the greater of 0.25 ATR or 25% of the developing zone.
* The rejection bar must close within the directional outer 45% of its range.
* The completed zone cannot exceed 60% of the original drive range.

Together, these filters are intended to remove many one-candle reactions, shallow pauses, and weak two-test formations. The model wants to see a legitimate first drive, real separation between attempts, and measurable deterioration on the return.

THE ZONE

Once the second attempt qualifies, the structure is armed and its levels are frozen:

* Outer edge: the most extreme price reached by the two attempts.
* Inner edge: the counter-extreme formed between the two attempts.
* Midpoint: the halfway point of the zone.
* Invalidation: 0.15 ATR beyond the outer edge in the direction of the original move.

For a bullish setup, price must transfer upward after a mature downward drive. For a bearish setup, price must transfer downward after a mature upward drive.

Invalidation requires a confirmed close beyond the buffered outer edge. The invalidation level is structural information, not an automatic stop-loss recommendation.

ENTRY TIMING

Early

Confirms on a qualified close through the zone midpoint. This is the fastest mode and can trigger on the same confirmed bar that arms the zone. It offers earlier recognition with a greater risk of false starts.

Balanced

Confirms on a later qualified close beyond the structural inner edge. Balanced is the default middle ground between earlier recognition and additional structural confirmation.

Sniper

Requires a qualified break of the inner edge followed by the first later retest of that level. The retest must remain shallow and close back in the transfer direction. The first retest decides the setup; a failed first retest cannot become a signal later.

The breakout candle must move in the transfer direction, span at least 0.35 ATR, have a real body covering at least 45% of its range, close within the directional outer 32% of the candle, and finish no more than 0.45 ATR beyond the selected boundary. The final limit is an anti-chase filter.

A valid Sniper retest must stay within 15% of the frozen zone depth, close at least 0.05 ATR back beyond the inner edge, have a directional body covering at least 35% of the candle, and close within the directional outer 40% of its range.

HOW TO READ THE CHART

With the default color palette:

* Amber: the pattern is still developing. It is information, not an entry signal.
* Violet: the structure is complete, armed, and waiting for confirmation.
* Cyan: the action area between the midpoint and inner edge.
* Green: a bullish pressure transfer has been confirmed.
* Red: a bearish pressure transfer has been confirmed.
* Faint gray: an armed setup failed, expired, or was invalidated.

The right-edge label shows the current phase and the next required action. Once the structure is armed, it also displays the confirmation boundary and invalidation price. A diamond appears only when the selected timing mode produces a confirmed trigger.

When Keep Recent Resolved Zones is enabled, the script retains a limited number of recent successful and failed zones. The default is eight, adjustable from one to twelve, so failures remain visible without overwhelming the chart.

PRACTICAL USE

1. Treat an amber zone as a developing idea, not permission to trade.
2. When the zone turns violet, note its direction, confirmation boundary, and invalidation price.
3. Wait for the exact requirement of Early, Balanced, or Sniper mode.
4. Use the broader trend, nearby support and resistance, liquidity, session conditions, and scheduled news as separate context.
5. Apply your own position sizing, stop placement, targets, and trade-management rules.

ADAPTIVE PACE

Auto mode adjusts the engine according to the chart timeframe:

* Fast: 15-minute charts and below.
* Swing: above 15 minutes through 4 hours.
* Position: above 4 hours.

Fast, Swing, and Position can also be selected manually. The selected pace changes the drive and local-extreme lookbacks, minimum drive size, efficiency threshold, formation lifetime, armed lifetime, and Sniper retest window. It does not change the meaning of the pattern.

ALERTS

The indicator includes five alerts:

* Long Zone Armed
* Short Zone Armed
* Long Pressure Transfer
* Short Pressure Transfer
* Pressure Transfer Invalidated

Create alerts using Once Per Bar Close.

Trigger alerts and chart diamonds use the same confirmed-bar event. If an Early setup resolves on the same bar it arms, the temporary armed alert is suppressed so users do not receive a stale or redundant notification.

CONFIRMED-BAR DESIGN

Actionable signals are confirmed only after the chart bar closes. They are not backdated and do not use future data, pivot backpainting, negative offsets, higher-timeframe requests, or lookahead logic.

Amber developing zones are intentionally provisional and can change or disappear because the pattern is not complete. Once a zone turns violet, its structural prices and invalidation level are frozen for that event.

LIMITATIONS

Pressure Transfer Zone identifies structural-exhaustion candidates, not guaranteed reversals. It tracks one active sequence at a time and can miss fast V-shaped turns that never form two separate attempts.

Strong trends can repeatedly invalidate countertrend setups. Thin markets, price gaps, news shocks, and irregular sessions can also reduce the usefulness of ATR-based thresholds.

This is an indicator, not a strategy. It does not place orders, calculate position size, set profit targets, or claim a win rate. Its job is narrower: determine whether the original directional side returned to the extreme, failed to produce enough additional progress, and then met the model’s confirmation rule at a clearly defined price.

## Source Code

````pine
//@version=6
indicator("Pressure Transfer Zone", "PTZ", overlay = true, behind_chart = true, max_bars_back = 500, max_boxes_count = 80, max_labels_count = 20)

// Price-sequence inference only. This script does not infer order flow, delta, or institutional activity.
// Engine: unchanged from the reviewed build — every threshold, state transition, and timing rule is identical.
// Presentation: rebuilt. Direction-encoded zones, live trigger/invalidation level lines, automatic
// trade-plan projection with outcome tracking, and a status dashboard.

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────
const string GROUP_ENGINE = "Engine"
const string GROUP_VISUALS = "Visuals"
const string GROUP_TRADE = "Trade Plan"
const string GROUP_COLORS = "Palette"

float sourceInput = input.source(close, "Source", group = GROUP_ENGINE, tooltip = "Used for directional displacement and path efficiency. Zone geometry always uses confirmed OHLC prices.")
string timingInput = input.string("Balanced", "Entry timing", options = ["Early", "Balanced", "Sniper"], group = GROUP_ENGINE, tooltip = "Early closes through the zone midpoint. Balanced closes beyond the structural edge. Sniper requires the structural break and its first held retest.")
string paceInput = input.string("Auto", "Adaptive pace", options = ["Auto", "Fast", "Swing", "Position"], group = GROUP_ENGINE, tooltip = "Auto scales the engine for 15-minute-and-below, 16-minute-to-4-hour, and above-4-hour charts. Manual choices override that classification.")

bool showFormingZones = input.bool(true, "Show developing zones", group = GROUP_VISUALS, tooltip = "Amber means the two-attempt sequence is still forming and is not actionable.")
bool showResolvedZones = input.bool(true, "Keep recent resolved zones", group = GROUP_VISUALS, tooltip = "Confirmed transfers retain their direction color. Invalidated, expired, and rejected armed zones remain as faint gray records so historical failures do not disappear.")
int resolvedZoneCount = input.int(8, "Resolved zones retained", minval = 1, maxval = 12, group = GROUP_VISUALS, active = showResolvedZones)
bool showLevelLines = input.bool(true, "Show trigger / invalidation levels", group = GROUP_VISUALS, tooltip = "Live price lines for the exact level that triggers the setup and the exact level that kills it, with right-edge price tags.")
bool showActionTag = input.bool(true, "Show right-edge instruction", group = GROUP_VISUALS)
bool showSignalMarkers = input.bool(true, "Show armed + trigger markers", group = GROUP_VISUALS)
bool showBarTint = input.bool(true, "Flash background on trigger bar", group = GROUP_VISUALS)
bool showDashboard = input.bool(true, "Show status dashboard", group = GROUP_VISUALS)
string dashPosInput = input.string("Top right", "Dashboard position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = GROUP_VISUALS, active = showDashboard)

bool showTradePlan = input.bool(true, "Project trade plan on trigger", group = GROUP_TRADE, tooltip = "On every confirmed trigger, projects entry (trigger close), stop (setup invalidation), and a target at the chosen R multiple, then tracks which is hit first. If one bar touches both, the stop is credited first — the conservative read.")
float targetRInput = input.float(2.0, "Target (R multiple)", minval = 0.5, maxval = 10.0, step = 0.5, group = GROUP_TRADE, active = showTradePlan)
int tradeMaxBars = input.int(40, "Max bars to resolve", minval = 5, maxval = 200, group = GROUP_TRADE, active = showTradePlan, tooltip = "If neither stop nor target is reached within this many confirmed bars, the trade closes as a scratch (0R) and is excluded from the win rate.")

color bullishColor = input.color(color.rgb(0, 184, 138), "Bullish", group = GROUP_COLORS)
color bearishColor = input.color(color.rgb(226, 73, 101), "Bearish", group = GROUP_COLORS)
color formingColor = input.color(color.rgb(231, 160, 49), "Forming", group = GROUP_COLORS)
color dangerColor = input.color(color.rgb(255, 82, 82), "Risk / invalidation", group = GROUP_COLORS)
color neutralColor = input.color(color.rgb(123, 132, 148), "Neutral", group = GROUP_COLORS)

//──────────────────────────────────────────────────────────────────────────────
// Adaptive profile
//──────────────────────────────────────────────────────────────────────────────
int chartSeconds = timeframe.in_seconds()
int automaticPace = chartSeconds <= 15 * 60 ? 0 : chartSeconds <= 4 * 60 * 60 ? 1 : 2
int selectedPace = paceInput == "Fast" ? 0 : paceInput == "Swing" ? 1 : paceInput == "Position" ? 2 : automaticPace

int driveLength = selectedPace == 0 ? 20 : selectedPace == 1 ? 16 : 12
int localExtremeLength = selectedPace == 0 ? 6 : selectedPace == 1 ? 5 : 4
float minimumDriveAtr = selectedPace == 0 ? 2.50 : selectedPace == 1 ? 2.25 : 2.00
float minimumEfficiency = selectedPace == 0 ? 0.48 : selectedPace == 1 ? 0.44 : 0.40
int formingLife = selectedPace == 0 ? 16 : selectedPace == 1 ? 14 : 12
int armedLife = selectedPace == 0 ? 18 : selectedPace == 1 ? 16 : 14
int sniperRetestLife = selectedPace == 0 ? 5 : selectedPace == 1 ? 5 : 4

const int ATR_LENGTH = 14
const float MINIMUM_NET_DISPLACEMENT_ATR = 1.25
const float DRIVE_OUTER_CLOSE_FRACTION = 0.72
const float MINIMUM_RETREAT_ATR = 0.55
const float MINIMUM_RETREAT_DRIVE_FRACTION = 0.18
const float MAXIMUM_ZONE_DRIVE_FRACTION = 0.60
const float SECOND_RETURN_PROXIMITY_ATR = 0.30
const float SECOND_RETURN_PROXIMITY_DRIVE = 0.08
const float MAXIMUM_SECOND_PROGRESS_ATR = 0.20
const float MAXIMUM_SECOND_PUSH_DRIVE = 0.72
const float MINIMUM_CLOSE_MIGRATION_ATR = 0.10
const float MINIMUM_REJECTION_ATR = 0.25
const float MINIMUM_REJECTION_ZONE_FRACTION = 0.25
const float INVALIDATION_BUFFER_ATR = 0.15
const float MINIMUM_TRIGGER_RANGE_ATR = 0.35
const float MINIMUM_TRIGGER_BODY_RATIO = 0.45
const float MINIMUM_TRIGGER_CLOSE_LOCATION = 0.68
const float MAXIMUM_TRIGGER_CHASE_ATR = 0.45
const float SNIPER_RETEST_DEPTH_FRACTION = 0.15
const float SNIPER_HOLD_CLEARANCE_ATR = 0.05
const float SNIPER_MINIMUM_BODY_RATIO = 0.35
const float SNIPER_MINIMUM_CLOSE_LOCATION = 0.60
const float SNIPER_LATE_EXTENSION_ATR = 1.25

//──────────────────────────────────────────────────────────────────────────────
// Trade-plan record type
//──────────────────────────────────────────────────────────────────────────────
type TradePlan
    float entry
    float stop
    float target
    int dir
    int openBar
    line entryLine
    line stopLine
    line targetLine
    box riskBox
    box rewardBox
    label planLabel

// Choose the higher-contrast capsule ink using WCAG relative luminance.
f_linear_channel(float channelValue) =>
    float normalized = channelValue / 255.0
    normalized <= 0.04045 ? normalized / 12.92 : math.pow((normalized + 0.055) / 1.055, 2.4)

f_text_color(color backgroundColor) =>
    float backgroundLuma = f_linear_channel(color.r(backgroundColor)) * 0.2126 + f_linear_channel(color.g(backgroundColor)) * 0.7152 + f_linear_channel(color.b(backgroundColor)) * 0.0722
    color darkInk = color.rgb(22, 27, 35)
    float darkLuma = f_linear_channel(color.r(darkInk)) * 0.2126 + f_linear_channel(color.g(darkInk)) * 0.7152 + f_linear_channel(color.b(darkInk)) * 0.0722
    float whiteContrast = 1.05 / (backgroundLuma + 0.05)
    float darkContrast = (math.max(backgroundLuma, darkLuma) + 0.05) / (math.min(backgroundLuma, darkLuma) + 0.05)
    darkContrast >= whiteContrast ? darkInk : color.white

//──────────────────────────────────────────────────────────────────────────────
// Global history-dependent series
//──────────────────────────────────────────────────────────────────────────────
float minimumTick = math.max(nz(syminfo.mintick, 0.00000001), 0.00000001)
float trueRangeSeries = ta.tr(true)
float atrRaw = ta.atr(ATR_LENGTH)
float atrSeries = math.max(nz(atrRaw, nz(trueRangeSeries, minimumTick)), minimumTick)
float sourceChange = math.abs(ta.change(sourceInput))
float grossPath = math.sum(sourceChange, driveLength)
float driveWindowLow = ta.lowest(low, driveLength)
float driveWindowHigh = ta.highest(high, driveLength)
float priorLocalHigh = ta.highest(high[1], localExtremeLength)
float priorLocalLow = ta.lowest(low[1], localExtremeLength)

float bullishNetDisplacement = sourceInput - sourceInput[driveLength]
float bearishNetDisplacement = sourceInput[driveLength] - sourceInput
float bullishDriveRange = high - driveWindowLow
float bearishDriveRange = driveWindowHigh - low
float bullishEfficiency = math.max(bullishNetDisplacement, 0.0) / math.max(nz(grossPath, minimumTick), minimumTick)
float bearishEfficiency = math.max(bearishNetDisplacement, 0.0) / math.max(nz(grossPath, minimumTick), minimumTick)
float bullishDriveCloseLocation = bullishDriveRange > minimumTick ? (close - driveWindowLow) / bullishDriveRange : 0.0
float bearishDriveCloseLocation = bearishDriveRange > minimumTick ? (driveWindowHigh - close) / bearishDriveRange : 0.0

float barRange = math.max(nz(high - low, minimumTick), minimumTick)
float barBodyRatio = math.abs(close - open) / barRange
float bullishCloseLocation = (close - low) / barRange
float bearishCloseLocation = (high - close) / barRange

bool validPriceBar = not na(open) and not na(high) and not na(low) and not na(close)
bool standardChart = chart.is_standard
int requiredWarmup = math.max(ATR_LENGTH + 3, driveLength + localExtremeLength + 3)
bool seriesReady = standardChart and validPriceBar and bar_index >= requiredWarmup and not na(grossPath) and not na(priorLocalHigh) and not na(priorLocalLow) and not na(sourceInput[driveLength])

bool matureUpDrive = seriesReady and bullishNetDisplacement >= atrSeries * MINIMUM_NET_DISPLACEMENT_ATR and bullishDriveRange >= atrSeries * minimumDriveAtr and bullishEfficiency >= minimumEfficiency and bullishDriveCloseLocation >= DRIVE_OUTER_CLOSE_FRACTION and high > priorLocalHigh
bool matureDownDrive = seriesReady and bearishNetDisplacement >= atrSeries * MINIMUM_NET_DISPLACEMENT_ATR and bearishDriveRange >= atrSeries * minimumDriveAtr and bearishEfficiency >= minimumEfficiency and bearishDriveCloseLocation >= DRIVE_OUTER_CLOSE_FRACTION and low < priorLocalLow

//──────────────────────────────────────────────────────────────────────────────
// Trade-plan projection drawn at every confirmed trigger
//──────────────────────────────────────────────────────────────────────────────
f_spawn_trade(float entryPrice, float stopPrice, int dir, color dirColor) =>
    TradePlan result = na
    float risk = math.abs(entryPrice - stopPrice)
    if showTradePlan and risk > minimumTick
        float targetPrice = dir == 1 ? entryPrice + risk * targetRInput : entryPrice - risk * targetRInput
        float riskTop = math.max(entryPrice, stopPrice)
        float riskBottom = math.min(entryPrice, stopPrice)
        float rewardTop = math.max(entryPrice, targetPrice)
        float rewardBottom = math.min(entryPrice, targetPrice)
        int rightEdge = bar_index + 6
        box riskB = box.new(left = bar_index, top = riskTop, right = rightEdge, bottom = riskBottom, xloc = xloc.bar_index, border_color = na, bgcolor = color.new(dangerColor, 88))
        box rewardB = box.new(left = bar_index, top = rewardTop, right = rightEdge, bottom = rewardBottom, xloc = xloc.bar_index, border_color = na, bgcolor = color.new(dirColor, 88))
        line entryL = line.new(x1 = bar_index, y1 = entryPrice, x2 = rightEdge, y2 = entryPrice, xloc = xloc.bar_index, color = color.new(color.white, 25), width = 1)
        line stopL = line.new(x1 = bar_index, y1 = stopPrice, x2 = rightEdge, y2 = stopPrice, xloc = xloc.bar_index, color = dangerColor, width = 1, style = line.style_dashed)
        line targetL = line.new(x1 = bar_index, y1 = targetPrice, x2 = rightEdge, y2 = targetPrice, xloc = xloc.bar_index, color = dirColor, width = 1, style = line.style_dashed)
        label planL = label.new(x = rightEdge, y = targetPrice, text = "TARGET " + str.tostring(targetRInput, "#.#") + "R", xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dirColor, 15), textcolor = f_text_color(dirColor), size = size.tiny)
        result := TradePlan.new(entryPrice, stopPrice, targetPrice, dir, bar_index, entryL, stopL, targetL, riskB, rewardB, planL)
    result

//──────────────────────────────────────────────────────────────────────────────
// Event state and frozen record
// reversalDirection: +1 prospective long after a down drive, -1 prospective short
//──────────────────────────────────────────────────────────────────────────────
const int STATE_IDLE = 0
const int STATE_WAIT_RETREAT = 1
const int STATE_WAIT_SECOND = 2
const int STATE_SECOND_TEST = 3
const int STATE_ARMED = 4
const int STATE_SNIPER_RETEST = 5

var int eventState = STATE_IDLE
var int reversalDirection = 0
var int firstAttemptBar = na
var int retreatExtremeBar = na
var int armedBar = na
var int sniperBreakBar = na
var float eventAtr = na
var float driveOrigin = na
var float firstDriveRange = na
var float firstExtreme = na
var float firstAttemptClose = na
var float retreatExtreme = na
var float secondExtreme = na
var float zoneOuter = na
var float zoneInner = na
var float zoneMidpoint = na
var float selectedBoundary = na
var float zoneInvalidation = na

var box activeHaloBox = na
var box activeZoneBox = na
var box activeActionBox = na
var array<box> resolvedBoxes = array.new<box>()
var label actionTag = na

// Live level drawings (armed state) and trade-plan tracking.
var line triggerLine = na
var line invalidLine = na
var label triggerLevelLabel = na
var label invalidLevelLabel = na
var array<TradePlan> openTrades = array.new<TradePlan>()
var array<TradePlan> closedTrades = array.new<TradePlan>()
var int statWins = 0
var int statLosses = 0
var int statScratch = 0
var float statTotalR = 0.0

var int lastResolutionBar = na
var float lastResolutionPrice = na
var string lastResolutionText = ""
var color lastResolutionColor = na

// Confirmed one-bar pulses. Markers and alerts use these exact series.
bool longArmedPulse = false
bool shortArmedPulse = false
bool longTriggerPulse = false
bool shortTriggerPulse = false
bool invalidatedPulse = false
bool targetHitPulse = false
bool stopHitPulse = false
bool discardActiveDrawings = false
bool archiveActiveDrawings = false
color archiveColor = na

//──────────────────────────────────────────────────────────────────────────────
// Confirmed-bar engine
//──────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed
    // Start only at a mature, confirmed local extreme. If both qualify, use the stronger normalized drive.
    if eventState == STATE_IDLE
        float bullishDriveStrength = bullishDriveRange / atrSeries * bullishEfficiency
        float bearishDriveStrength = bearishDriveRange / atrSeries * bearishEfficiency
        bool chooseUpDrive = matureUpDrive and (not matureDownDrive or bullishDriveStrength >= bearishDriveStrength)
        bool chooseDownDrive = matureDownDrive and not chooseUpDrive

        if chooseUpDrive or chooseDownDrive
            lastResolutionBar := na
            lastResolutionText := ""
            reversalDirection := chooseUpDrive ? -1 : 1
            eventState := STATE_WAIT_RETREAT
            eventAtr := atrSeries
            driveOrigin := chooseUpDrive ? driveWindowLow : driveWindowHigh
            firstExtreme := chooseUpDrive ? high : low
            firstDriveRange := math.max(math.abs(firstExtreme - driveOrigin), minimumTick)
            firstAttemptClose := close
            firstAttemptBar := bar_index
            retreatExtreme := firstExtreme
            retreatExtremeBar := firstAttemptBar
            armedBar := na
            sniperBreakBar := na
            secondExtreme := na
            zoneOuter := na
            zoneInner := na
            zoneMidpoint := na
            selectedBoundary := na
            zoneInvalidation := na

            float formingDepth = math.max(eventAtr * MINIMUM_RETREAT_ATR, firstDriveRange * MINIMUM_RETREAT_DRIVE_FRACTION)
            float formingTop = reversalDirection == -1 ? firstExtreme : firstExtreme + formingDepth
            float formingBottom = reversalDirection == -1 ? firstExtreme - formingDepth : firstExtreme
            float haloPadding = math.max(formingDepth * 0.04, eventAtr * 0.03)
            if showFormingZones
                activeHaloBox := box.new(left = firstAttemptBar, top = formingTop + haloPadding, right = bar_index + 3, bottom = formingBottom - haloPadding, xloc = xloc.bar_index, border_color = na, bgcolor = color.new(formingColor, 96))
                activeZoneBox := box.new(left = firstAttemptBar, top = formingTop, right = bar_index + 3, bottom = formingBottom, xloc = xloc.bar_index, border_color = color.new(formingColor, 40), border_width = 1, bgcolor = color.new(formingColor, 92))

    // The first attempt can extend until a separate, qualified retreat appears.
    else if eventState == STATE_WAIT_RETREAT
        bool bearishSetup = reversalDirection == -1
        bool newFirstExtreme = bearishSetup ? high > firstExtreme : low < firstExtreme

        if newFirstExtreme
            firstExtreme := bearishSetup ? high : low
            firstDriveRange := math.max(math.abs(firstExtreme - driveOrigin), minimumTick)
            firstAttemptClose := close
            firstAttemptBar := bar_index
            retreatExtreme := firstExtreme
            retreatExtremeBar := firstAttemptBar
        else
            bool newRetreatExtreme = bearishSetup ? low < retreatExtreme : high > retreatExtreme
            if newRetreatExtreme
                retreatExtreme := bearishSetup ? low : high
                retreatExtremeBar := bar_index

        float retreatDistance = math.abs(firstExtreme - retreatExtreme)
        float requiredRetreat = math.max(eventAtr * MINIMUM_RETREAT_ATR, firstDriveRange * MINIMUM_RETREAT_DRIVE_FRACTION)
        float confirmedRetreat = bearishSetup ? firstExtreme - close : close - firstExtreme
        bool retreatSeparated = bar_index > firstAttemptBar
        bool retreatQualified = retreatSeparated and retreatDistance >= requiredRetreat and confirmedRetreat >= requiredRetreat
        bool waitExpired = bar_index - firstAttemptBar > formingLife

        if waitExpired
            eventState := STATE_IDLE
            reversalDirection := 0
            discardActiveDrawings := true
        else if retreatQualified
            eventState := STATE_WAIT_SECOND

    // Track the intervening counter-extreme, then freeze it when price returns near attempt one.
    if eventState == STATE_WAIT_SECOND
        bool bearishSetup = reversalDirection == -1
        bool newRetreatExtreme = bearishSetup ? low < retreatExtreme : high > retreatExtreme
        if newRetreatExtreme
            retreatExtreme := bearishSetup ? low : high
            retreatExtremeBar := bar_index

        float retreatDepth = math.abs(firstExtreme - retreatExtreme)
        float returnProximity = math.max(eventAtr * SECOND_RETURN_PROXIMITY_ATR, firstDriveRange * SECOND_RETURN_PROXIMITY_DRIVE)
        bool retreatTooDeep = retreatDepth > firstDriveRange * MAXIMUM_ZONE_DRIVE_FRACTION
        bool returnNearFirst = bearishSetup ? high >= firstExtreme - returnProximity : low <= firstExtreme + returnProximity
        bool secondIsSeparated = bar_index > retreatExtremeBar
        bool formationExpired = bar_index - firstAttemptBar > formingLife
        bool originalMoveResumed = bearishSetup ? close > firstExtreme + eventAtr * MAXIMUM_SECOND_PROGRESS_ATR : close < firstExtreme - eventAtr * MAXIMUM_SECOND_PROGRESS_ATR

        if retreatTooDeep or formationExpired or originalMoveResumed
            eventState := STATE_IDLE
            reversalDirection := 0
            discardActiveDrawings := true
        else if secondIsSeparated and returnNearFirst
            eventState := STATE_SECOND_TEST
            secondExtreme := bearishSetup ? high : low

    // The second attempt must make limited new progress and migrate its close away from the extreme.
    if eventState == STATE_SECOND_TEST
        bool bearishSetup = reversalDirection == -1
        secondExtreme := bearishSetup ? math.max(secondExtreme, high) : math.min(secondExtreme, low)

        float candidateOuter = bearishSetup ? math.max(firstExtreme, secondExtreme) : math.min(firstExtreme, secondExtreme)
        float candidateInner = retreatExtreme
        float candidateHeight = math.abs(candidateOuter - candidateInner)
        float secondNewProgress = bearishSetup ? math.max(secondExtreme - firstExtreme, 0.0) : math.max(firstExtreme - secondExtreme, 0.0)
        float secondPushDistance = math.abs(secondExtreme - retreatExtreme)
        float closeMigration = bearishSetup ? firstAttemptClose - close : close - firstAttemptClose
        float rejectionDistance = bearishSetup ? secondExtreme - close : close - secondExtreme
        float requiredRejection = math.max(eventAtr * MINIMUM_REJECTION_ATR, candidateHeight * MINIMUM_REJECTION_ZONE_FRACTION)
        float directionalCloseLocation = bearishSetup ? bearishCloseLocation : bullishCloseLocation

        bool structureClearedBeforeArm = bearishSetup ? close < candidateInner : close > candidateInner
        bool zoneGeometryValid = candidateHeight >= minimumTick and candidateHeight <= firstDriveRange * MAXIMUM_ZONE_DRIVE_FRACTION
        bool limitedProgress = secondNewProgress <= eventAtr * MAXIMUM_SECOND_PROGRESS_ATR
        bool weakerSecondPush = secondPushDistance <= firstDriveRange * MAXIMUM_SECOND_PUSH_DRIVE
        bool closeMigrated = closeMigration >= eventAtr * MINIMUM_CLOSE_MIGRATION_ATR
        bool rejectionConfirmed = rejectionDistance >= requiredRejection and directionalCloseLocation >= 0.55
        bool formationExpired = bar_index - firstAttemptBar > formingLife

        if not zoneGeometryValid or not limitedProgress or not weakerSecondPush or structureClearedBeforeArm or formationExpired
            eventState := STATE_IDLE
            reversalDirection := 0
            discardActiveDrawings := true
        else if closeMigrated and rejectionConfirmed
            zoneOuter := candidateOuter
            zoneInner := candidateInner
            zoneMidpoint := (zoneOuter + zoneInner) * 0.5
            selectedBoundary := timingInput == "Early" ? zoneMidpoint : zoneInner
            zoneInvalidation := reversalDirection == -1 ? zoneOuter + eventAtr * INVALIDATION_BUFFER_ATR : zoneOuter - eventAtr * INVALIDATION_BUFFER_ATR
            armedBar := bar_index
            eventState := STATE_ARMED
            if reversalDirection == 1
                longArmedPulse := true
            else
                shortArmedPulse := true

            float frozenTop = math.max(zoneOuter, zoneInner)
            float frozenBottom = math.min(zoneOuter, zoneInner)
            float frozenHaloTop = reversalDirection == -1 ? zoneInvalidation : frozenTop
            float frozenHaloBottom = reversalDirection == -1 ? frozenBottom : zoneInvalidation
            float actionTop = math.max(zoneMidpoint, zoneInner)
            float actionBottom = math.min(zoneMidpoint, zoneInner)
            color dirColor = reversalDirection == 1 ? bullishColor : bearishColor

            if na(activeHaloBox)
                activeHaloBox := box.new(left = firstAttemptBar, top = frozenHaloTop, right = bar_index + 3, bottom = frozenHaloBottom, xloc = xloc.bar_index, border_color = na, bgcolor = color.new(dirColor, 95))
            if na(activeZoneBox)
                activeZoneBox := box.new(left = firstAttemptBar, top = frozenTop, right = bar_index + 3, bottom = frozenBottom, xloc = xloc.bar_index, border_color = color.new(dirColor, 5), border_width = 2, bgcolor = color.new(dirColor, 85))
            activeActionBox := box.new(left = firstAttemptBar, top = actionTop, right = bar_index + 3, bottom = actionBottom, xloc = xloc.bar_index, border_color = na, bgcolor = color.new(dirColor, 72))

            box.set_left(activeHaloBox, firstAttemptBar)
            box.set_top(activeHaloBox, frozenHaloTop)
            box.set_right(activeHaloBox, bar_index + 3)
            box.set_bottom(activeHaloBox, frozenHaloBottom)
            box.set_bgcolor(activeHaloBox, color.new(dirColor, 95))
            box.set_left(activeZoneBox, firstAttemptBar)
            box.set_top(activeZoneBox, frozenTop)
            box.set_right(activeZoneBox, bar_index + 3)
            box.set_bottom(activeZoneBox, frozenBottom)
            box.set_border_color(activeZoneBox, color.new(dirColor, 5))
            box.set_border_width(activeZoneBox, 2)
            box.set_bgcolor(activeZoneBox, color.new(dirColor, 85))

            // Live levels: the exact price that triggers the setup and the exact price that kills it.
            if showLevelLines
                triggerLine := line.new(x1 = bar_index, y1 = selectedBoundary, x2 = bar_index + 8, y2 = selectedBoundary, xloc = xloc.bar_index, color = dirColor, width = 2)
                invalidLine := line.new(x1 = bar_index, y1 = zoneInvalidation, x2 = bar_index + 8, y2 = zoneInvalidation, xloc = xloc.bar_index, color = dangerColor, width = 1, style = line.style_dashed)
                triggerLevelLabel := label.new(x = bar_index + 8, y = selectedBoundary, text = "TRIGGER " + str.tostring(selectedBoundary, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dirColor, 10), textcolor = f_text_color(dirColor), size = size.small)
                invalidLevelLabel := label.new(x = bar_index + 8, y = zoneInvalidation, text = "INVALID " + str.tostring(zoneInvalidation, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left, color = color.new(dangerColor, 10), textcolor = f_text_color(dangerColor), size = size.small)

    // Armed Early/Balanced: the first confirmed boundary close decides permanently.
    if eventState == STATE_ARMED
        bool bearishSetup = reversalDirection == -1
        bool structurallyInvalid = bearishSetup ? close > zoneInvalidation : close < zoneInvalidation
        bool eligibleDecisionBar = timingInput == "Early" ? bar_index >= armedBar : bar_index > armedBar
        bool boundaryCleared = bearishSetup ? close < selectedBoundary : close > selectedBoundary
        bool directionalBody = bearishSetup ? close < open : close > open
        float directionalCloseLocation = bearishSetup ? bearishCloseLocation : bullishCloseLocation
        float boundaryOvershoot = bearishSetup ? selectedBoundary - close : close - selectedBoundary
        bool triggerCandleValid = directionalBody and barRange >= eventAtr * MINIMUM_TRIGGER_RANGE_ATR and barBodyRatio >= MINIMUM_TRIGGER_BODY_RATIO and directionalCloseLocation >= MINIMUM_TRIGGER_CLOSE_LOCATION and boundaryOvershoot <= eventAtr * MAXIMUM_TRIGGER_CHASE_ATR
        bool armedExpired = bar_index - armedBar > armedLife

        if structurallyInvalid
            invalidatedPulse := true
            lastResolutionBar := bar_index
            lastResolutionPrice := zoneInvalidation
            lastResolutionText := "SETUP INVALIDATED • ORIGINAL MOVE WON"
            lastResolutionColor := neutralColor
            eventState := STATE_IDLE
            reversalDirection := 0
            archiveActiveDrawings := true
            archiveColor := neutralColor
        else if timingInput == "Sniper" and eligibleDecisionBar and boundaryCleared
            if triggerCandleValid
                eventState := STATE_SNIPER_RETEST
                sniperBreakBar := bar_index
            else
                lastResolutionBar := bar_index
                lastResolutionPrice := selectedBoundary
                lastResolutionText := "NO ENTRY • BREAK QUALITY FAILED"
                lastResolutionColor := neutralColor
                eventState := STATE_IDLE
                reversalDirection := 0
                archiveActiveDrawings := true
                archiveColor := neutralColor
        else if timingInput != "Sniper" and eligibleDecisionBar and boundaryCleared
            if triggerCandleValid
                if reversalDirection == 1
                    longTriggerPulse := true
                else
                    shortTriggerPulse := true
                archiveActiveDrawings := true
                archiveColor := reversalDirection == 1 ? bullishColor : bearishColor
                lastResolutionText := (reversalDirection == 1 ? "LONG TRIGGERED @ " : "SHORT TRIGGERED @ ") + str.tostring(close, format.mintick) + "\nINVALID " + (reversalDirection == 1 ? "< " : "> ") + str.tostring(zoneInvalidation, format.mintick)
                lastResolutionColor := reversalDirection == 1 ? bullishColor : bearishColor
                TradePlan newTrade = f_spawn_trade(close, zoneInvalidation, reversalDirection, lastResolutionColor)
                if not na(newTrade)
                    array.push(openTrades, newTrade)
            else
                archiveActiveDrawings := true
                archiveColor := neutralColor
                lastResolutionText := "NO ENTRY • BREAK QUALITY FAILED"
                lastResolutionColor := neutralColor
            lastResolutionBar := bar_index
            lastResolutionPrice := selectedBoundary
            eventState := STATE_IDLE
            reversalDirection := 0
        else if armedExpired
            lastResolutionBar := bar_index
            lastResolutionPrice := selectedBoundary
            lastResolutionText := "ZONE EXPIRED • NO TRANSFER"
            lastResolutionColor := neutralColor
            eventState := STATE_IDLE
            reversalDirection := 0
            archiveActiveDrawings := true
            archiveColor := neutralColor

    // Sniper: the first later touch of the structural shelf decides permanently.
    if eventState == STATE_SNIPER_RETEST
        bool bearishSetup = reversalDirection == -1
        float frozenHeight = math.abs(zoneOuter - zoneInner)
        bool structurallyInvalid = bearishSetup ? close > zoneInvalidation : close < zoneInvalidation
        bool laterBar = bar_index > sniperBreakBar
        bool retestReachedEdge = laterBar and (bearishSetup ? high >= zoneInner : low <= zoneInner)
        bool retestStayedShallow = bearishSetup ? high <= zoneInner + frozenHeight * SNIPER_RETEST_DEPTH_FRACTION : low >= zoneInner - frozenHeight * SNIPER_RETEST_DEPTH_FRACTION
        bool holdClearance = bearishSetup ? close <= zoneInner - eventAtr * SNIPER_HOLD_CLEARANCE_ATR : close >= zoneInner + eventAtr * SNIPER_HOLD_CLEARANCE_ATR
        bool directionalBody = bearishSetup ? close < open : close > open
        float directionalCloseLocation = bearishSetup ? bearishCloseLocation : bullishCloseLocation
        bool heldRetest = retestReachedEdge and retestStayedShallow and holdClearance and directionalBody and barBodyRatio >= SNIPER_MINIMUM_BODY_RATIO and directionalCloseLocation >= SNIPER_MINIMUM_CLOSE_LOCATION
        bool extendedWithoutRetest = laterBar and (bearishSetup ? zoneInner - close > eventAtr * SNIPER_LATE_EXTENSION_ATR : close - zoneInner > eventAtr * SNIPER_LATE_EXTENSION_ATR)
        bool retestExpired = laterBar and bar_index - sniperBreakBar > sniperRetestLife

        if structurallyInvalid
            invalidatedPulse := true
            lastResolutionText := "SETUP INVALIDATED • RETEST FAILED"
            lastResolutionColor := neutralColor
            lastResolutionBar := bar_index
            lastResolutionPrice := zoneInvalidation
            eventState := STATE_IDLE
            reversalDirection := 0
            archiveActiveDrawings := true
            archiveColor := neutralColor
        else if retestReachedEdge
            if heldRetest
                if reversalDirection == 1
                    longTriggerPulse := true
                else
                    shortTriggerPulse := true
                archiveActiveDrawings := true
                archiveColor := reversalDirection == 1 ? bullishColor : bearishColor
                lastResolutionText := (reversalDirection == 1 ? "LONG HELD RETEST @ " : "SHORT HELD RETEST @ ") + str.tostring(close, format.mintick) + "\nINVALID " + (reversalDirection == 1 ? "< " : "> ") + str.tostring(zoneInvalidation, format.mintick)
                lastResolutionColor := reversalDirection == 1 ? bullishColor : bearishColor
                TradePlan newTrade = f_spawn_trade(close, zoneInvalidation, reversalDirection, lastResolutionColor)
                if not na(newTrade)
                    array.push(openTrades, newTrade)
            else
                archiveActiveDrawings := true
                archiveColor := neutralColor
                lastResolutionText := "NO ENTRY • FIRST RETEST FAILED"
                lastResolutionColor := neutralColor
            lastResolutionBar := bar_index
            lastResolutionPrice := zoneInner
            eventState := STATE_IDLE
            reversalDirection := 0
        else if extendedWithoutRetest or retestExpired
            lastResolutionBar := bar_index
            lastResolutionPrice := zoneInner
            lastResolutionText := "NO ENTRY • RETEST NEVER ARRIVED"
            lastResolutionColor := neutralColor
            eventState := STATE_IDLE
            reversalDirection := 0
            archiveActiveDrawings := true
            archiveColor := neutralColor

    // An Early zone can arm and resolve on one confirmed bar; do not also emit an Armed alert.
    if eventState == STATE_IDLE
        if longArmedPulse
            longArmedPulse := false
        if shortArmedPulse
            shortArmedPulse := false

    // Update the live forming geometry only after all confirmed state decisions.
    if eventState == STATE_WAIT_RETREAT or eventState == STATE_WAIT_SECOND or eventState == STATE_SECOND_TEST
        bool bearishSetup = reversalDirection == -1
        float currentOuter = eventState == STATE_SECOND_TEST ? (bearishSetup ? math.max(firstExtreme, secondExtreme) : math.min(firstExtreme, secondExtreme)) : firstExtreme
        float provisionalDepth = math.max(eventAtr * MINIMUM_RETREAT_ATR, firstDriveRange * MINIMUM_RETREAT_DRIVE_FRACTION)
        float currentInner = eventState == STATE_WAIT_RETREAT and math.abs(firstExtreme - retreatExtreme) < minimumTick ? (bearishSetup ? firstExtreme - provisionalDepth : firstExtreme + provisionalDepth) : retreatExtreme
        float formingTop = math.max(currentOuter, currentInner)
        float formingBottom = math.min(currentOuter, currentInner)
        float formingHeight = math.max(formingTop - formingBottom, minimumTick)
        float haloPadding = math.max(formingHeight * 0.04, eventAtr * 0.03)

        if showFormingZones
            if na(activeHaloBox)
                activeHaloBox := box.new(left = firstAttemptBar, top = formingTop + haloPadding, right = bar_index + 3, bottom = formingBottom - haloPadding, xloc = xloc.bar_index, border_color = na, bgcolor = color.new(formingColor, 96))
            if na(activeZoneBox)
                activeZoneBox := box.new(left = firstAttemptBar, top = formingTop, right = bar_index + 3, bottom = formingBottom, xloc = xloc.bar_index, border_color = color.new(formingColor, 40), border_width = 1, bgcolor = color.new(formingColor, 92))
            box.set_left(activeHaloBox, firstAttemptBar)
            box.set_top(activeHaloBox, formingTop + haloPadding)
            box.set_right(activeHaloBox, bar_index + 3)
            box.set_bottom(activeHaloBox, formingBottom - haloPadding)
            box.set_left(activeZoneBox, firstAttemptBar)
            box.set_top(activeZoneBox, formingTop)
            box.set_right(activeZoneBox, bar_index + 3)
            box.set_bottom(activeZoneBox, formingBottom)

    // Active armed drawings extend a few bars right without changing frozen prices.
    if eventState == STATE_ARMED or eventState == STATE_SNIPER_RETEST
        if not na(activeHaloBox)
            box.set_right(activeHaloBox, bar_index + 3)
        if not na(activeZoneBox)
            box.set_right(activeZoneBox, bar_index + 3)
        if not na(activeActionBox)
            box.set_right(activeActionBox, bar_index + 3)

    // Preserve a bounded, honest record: vivid transfers and faint failed armed zones.
    if archiveActiveDrawings
        if not na(triggerLine)
            line.delete(triggerLine)
            triggerLine := na
        if not na(invalidLine)
            line.delete(invalidLine)
            invalidLine := na
        if not na(triggerLevelLabel)
            label.delete(triggerLevelLabel)
            triggerLevelLabel := na
        if not na(invalidLevelLabel)
            label.delete(invalidLevelLabel)
            invalidLevelLabel := na
        bool confirmedTransfer = longTriggerPulse or shortTriggerPulse
        color resolvedColor = na(archiveColor) ? neutralColor : archiveColor
        if showResolvedZones and not na(activeZoneBox) and not na(activeHaloBox) and not na(activeActionBox)
            box.set_right(activeHaloBox, bar_index + 6)
            box.set_bgcolor(activeHaloBox, color.new(resolvedColor, confirmedTransfer ? 95 : 98))
            box.set_right(activeZoneBox, bar_index + 6)
            box.set_border_color(activeZoneBox, color.new(resolvedColor, confirmedTransfer ? 5 : 70))
            box.set_bgcolor(activeZoneBox, color.new(resolvedColor, confirmedTransfer ? 85 : 95))
            box.set_right(activeActionBox, bar_index + 6)
            box.set_bgcolor(activeActionBox, color.new(resolvedColor, confirmedTransfer ? 78 : 97))
            array.push(resolvedBoxes, activeHaloBox)
            array.push(resolvedBoxes, activeZoneBox)
            array.push(resolvedBoxes, activeActionBox)
            while array.size(resolvedBoxes) > resolvedZoneCount * 3
                box oldestBox = array.shift(resolvedBoxes)
                box.delete(oldestBox)
        else
            if not na(activeHaloBox)
                box.delete(activeHaloBox)
            if not na(activeZoneBox)
                box.delete(activeZoneBox)
            if not na(activeActionBox)
                box.delete(activeActionBox)
        activeHaloBox := na
        activeZoneBox := na
        activeActionBox := na

    if discardActiveDrawings
        if not na(activeHaloBox)
            box.delete(activeHaloBox)
        if not na(activeZoneBox)
            box.delete(activeZoneBox)
        if not na(activeActionBox)
            box.delete(activeActionBox)
        activeHaloBox := na
        activeZoneBox := na
        activeActionBox := na

//──────────────────────────────────────────────────────────────────────────────
// Trade-plan tracking: every trigger is followed to target, stop, or timeout.
// If one bar touches both stop and target, the stop is credited first.
//──────────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed and array.size(openTrades) > 0
    array<TradePlan> survivors = array.new<TradePlan>()
    for tp in openTrades
        bool resolved = false
        if bar_index > tp.openBar
            bool hitStop = tp.dir == 1 ? low <= tp.stop : high >= tp.stop
            bool hitTarget = tp.dir == 1 ? high >= tp.target : low <= tp.target
            bool timedOut = bar_index - tp.openBar >= tradeMaxBars
            if hitStop or hitTarget or timedOut
                resolved := true
                color resColor = hitStop ? dangerColor : hitTarget ? (tp.dir == 1 ? bullishColor : bearishColor) : neutralColor
                string resText = hitStop ? "✗ -1R" : hitTarget ? "✓ +" + str.tostring(targetRInput, "#.#") + "R" : "0R EXPIRED"
                if hitStop
                    statLosses += 1
                    statTotalR -= 1.0
                    stopHitPulse := true
                else if hitTarget
                    statWins += 1
                    statTotalR += targetRInput
                    targetHitPulse := true
````
