# Aegis Arc Framework [JOAT]

- url: https://www.tradingview.com/script/O1Y8zdjf-Aegis-Arc-Framework-JOAT/
- type: indicator
- pine_id: PUB;1d20b40090ed46649924814c90c75120
- version: 1.0

## Description

[b]Aegis Arc Framework [JOAT][/b]

[b]Introduction[/b]

Aegis Arc Framework is an open-source anchored-trend overlay built to classify directional pressure through the interaction of three continuously updated reference systems: a confirmed trailing arc, anchored VWAP regime alignment, and ATR-normalized extension pressure. The script is designed to provide structured directional context without relying on repainting shortcuts or visually noisy retail markers.

The main problem Aegis Arc Framework solves is trend persistence versus trend exhaustion. Price can remain above a trailing framework while already becoming stretched relative to value. It can also reclaim value while a trend is still technically intact. Aegis addresses that by combining a ratcheting confirmed trail with session, weekly, and monthly VWAP context so the user can distinguish continuation, weak extension, and blocked transition states.

[image]https://www.tradingview.com/x/dLOT7V4b/[/image]

[b]Core Concepts[/b]

[b]1. Anchored VWAP Regime Gate[/b]

The indicator maintains manually anchored session, weekly, and monthly VWAP references and checks whether the active trend is aligned with those value anchors. Depending on the selected mode, the gate can require Session, Week, Month, Any, or All alignment before the dashboard and confirmed state fully agree with the direction of the arc.

[pine]
bool s = bullish ? close >= vwapSession : close <= vwapSession
bool w = bullish ? close >= vwapWeek    : close <= vwapWeek
bool m = bullish ? close >= vwapMonth   : close <= vwapMonth
[/pine]

[b]2. Ratcheted Arc Trail[/b]

The main trail is not a static moving average. It is a ratcheting arc that updates on confirmed bars, accelerates toward the active target band, and decays its internal velocity over time. This makes the line responsive during directional expansions while still preserving a smooth institutional appearance.

[b]3. Extension Pressure[/b]

Distance from the active anchored VWAP is normalized by ATR and converted into an acceleration modifier. When price becomes stretched from value, the trail responds more aggressively. This helps expose when a trend is still directional but increasingly extended.

[b]4. Confirmed Flip Logic[/b]

A trend flip is only confirmed on closed bars. The trail state does not anticipate future movement or use future references. This keeps the overlay safe for real-time use and consistent with non-repainting publication standards.

[b]5. Forward Flip Levels[/b]

Each confirmed directional transition creates a horizontal level that extends forward until invalidated or aged out. These levels act as persistent decision references and help frame whether price is defending or losing prior transition zones.

[b]Features[/b]

[list]
[*][b]Anchored value logic:[/b] Session, weekly, and monthly VWAP tracking with selectable regime gate modes
[*][b]ATR-based arc framework:[/b] Confirmed-bar ratcheting trail with velocity decay and acceleration logic
[*][b]Extension awareness:[/b] ATR-normalized distance from value used to classify whether the active move is orderly or stretched
[*][b]Persistent transition levels:[/b] Confirmed flip levels extend forward and self-clean when broken or aged out
[*][b]Institutional visual shell:[/b] Trail glow, clean cloud fill, optional candle tint, and compact top-right dashboard
[*][b]No retail markers:[/b] The script avoids arrows and clutter-focused signal decoration
[*][b]Confirmed-bar logic:[/b] Trend transitions and level invalidations are gated by confirmed bars only
[/list]

[b]Input Parameters[/b]

[b]Core Trajectory:[/b]
[list]
[*]ATR Length
[*]Trail Distance (ATRx)
[*]Base Acceleration
[*]Velocity Decay
[*]Velocity Cap
[*]Minimum Chase / Maximum Chase
[*]Run Window
[*]Minimum Flip Gap
[/list]

[b]VWAP Regime:[/b]
[list]
[*]Regime Mode: Session, Week, Month, Any, All
[*]VWAP Speed Boost
[*]Show Selected VWAP
[/list]

[b]Visual System and Levels:[/b]
[list]
[*]Bull, bear, and neutral palette controls
[*]Cloud, trail glow, and candle tint toggles
[*]Confirmed flip level styling and retention controls
[*]Dashboard display toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the active regime[/b]
Check whether price is above or below the confirmed trail and whether the dashboard shows value alignment with the selected anchored VWAP mode.

[b]Step 2: Judge extension[/b]
Use the extension and acceleration rows in the dashboard to determine whether the move is orderly or increasingly stretched from anchored value.

[b]Step 3: Use flip levels as structure references[/b]
When a confirmed transition occurs, the generated forward level becomes a practical decision point for retests, failures, and continuation checks.

[b]Step 4: Combine with execution tools[/b]
Aegis is best used as a directional and structural context layer. It can filter other entry models by allowing long setups only when the trail and value regime agree, and short setups only when the opposite condition is present.

[b]Indicator Limitations[/b]

[list]
[*]Anchored VWAP alignment may temporarily lag during very early reversals, especially when a higher anchor such as the weekly reference is selected
[*]The arc can tighten quickly during extreme volatility because acceleration is intentionally sensitive to extension pressure
[*]Flip levels are contextual structure references, not guaranteed support or resistance
[*]The script classifies directional state and extension; it does not predict future price movement
[/list]

[b]Originality Statement[/b]

Aegis Arc Framework is original in the way it combines a confirmed ratcheting trail, anchored VWAP regime gating, extension-driven acceleration, and managed forward flip levels into one coherent overlay. It is published because the combination is meaningfully different from a standard SuperTrend, a standalone VWAP overlay, or a simple trailing stop line.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice and does not recommend any specific trade or investment. All calculations are derived from historical and real-time chart data and can produce false signals. Trading involves substantial risk. Always use independent judgment and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Aegis Arc Framework [JOAT]", shorttitle="AA [JOAT]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=150)
//=============================================================================
// INPUTS
//=============================================================================

grpCore = "Core Trajectory"
trailAtrLen   = input.int(21, "ATR Length", minval=1, maxval=200, group=grpCore, tooltip="ATR length used to build the trailing arc bands.")
trailAtrMult  = input.float(2.2, "Trail Distance (ATRx)", minval=0.1, maxval=10.0, step=0.1, group=grpCore, tooltip="Base distance between price and the trailing arc.")
accelBase     = input.float(0.12, "Base Acceleration", minval=0.01, maxval=2.0, step=0.01, group=grpCore, tooltip="Base speed used to pull the arc toward the active target band.")
velocityDecay = input.float(0.92, "Velocity Decay", minval=0.50, maxval=0.999, step=0.001, group=grpCore, tooltip="How much historical velocity is retained each bar.")
velocityCap   = input.float(8.0, "Velocity Cap", minval=0.5, maxval=25.0, step=0.1, group=grpCore, tooltip="Upper bound on the internal acceleration accumulator.")
minChase      = input.float(0.08, "Minimum Chase", minval=0.01, maxval=0.50, step=0.01, group=grpCore, tooltip="Minimum fraction of distance the trail can close each confirmed bar.")
maxChase      = input.float(0.55, "Maximum Chase", minval=0.05, maxval=0.95, step=0.01, group=grpCore, tooltip="Maximum fraction of distance the trail can close each confirmed bar.")
runWindow     = input.int(14, "Run Window", minval=1, maxval=200, group=grpCore, tooltip="Used to convert trend age into an additional acceleration contribution.")
minFlipGap    = input.int(3, "Min Flip Gap", minval=0, maxval=50, group=grpCore, tooltip="Minimum number of bars required between confirmed flips.")

grpRegime = "VWAP Regime"
vwapMode      = input.string("Session", "Regime Mode", options=["Session", "Week", "Month", "Any", "All"], group=grpRegime, tooltip="Controls which anchored VWAP context is used as the regime gate.")
vwapBoost     = input.float(1.6, "VWAP Speed Boost", minval=1.0, maxval=5.0, step=0.1, group=grpRegime, tooltip="Boost applied to the trail acceleration when price is extended away from the selected VWAP context.")
showReference = input.bool(true, "Show Selected VWAP", group=grpRegime, tooltip="Display the active VWAP reference line used by the regime gate.")

grpVisual = "Visual System"
bullColorIn   = input.color(#00d8a7, "Bull Color", group=grpVisual, inline="c", tooltip="Primary bullish palette color.")
bearColorIn   = input.color(#ff4d6d, "Bear Color", group=grpVisual, inline="c", tooltip="Primary bearish palette color.")
neutralColorIn = input.color(#8fa3b8, "Neutral Color", group=grpVisual, inline="c", tooltip="Neutral palette color for blocked or transitional states.")
showCloud     = input.bool(true, "Show Cloud", group=grpVisual, tooltip="Fill the area between the trailing arc and the selected VWAP reference.")
showCandleTint = input.bool(true, "Tint Candles", group=grpVisual, tooltip="Apply trend-aware candle coloring with distance-based intensity.")
showGlow      = input.bool(true, "Glow Trail", group=grpVisual, tooltip="Render a soft glow behind the main trail for a more institutional presentation.")

grpSignals = "Signal Layer"
showSignals = input.bool(true, "Show Confirmed Signals", group=grpSignals, tooltip="Plot confirmed arc transition markers and execution labels.")
showSignalBoxes = input.bool(true, "Show Signal Boxes", group=grpSignals, tooltip="Project a compact box from each confirmed signal candle.")
showBlockedSignals = input.bool(true, "Show Blocked Attempts", group=grpSignals, tooltip="Mark flip attempts rejected by the VWAP regime gate.")
signalBoxBars = input.int(10, "Signal Box Projection", minval=2, maxval=100, group=grpSignals, inline="s1", tooltip="How many bars the signal box extends to the right.")
signalBoxAtrPad = input.float(0.65, "Signal Box ATR Pad", minval=0.1, maxval=5.0, step=0.05, group=grpSignals, inline="s1", tooltip="ATR padding wrapped around the signal candle for the projected signal box.")
signalLabelSizeIn = input.string("Small", "Signal Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpSignals, inline="s2")
maxSignalMarks = input.int(24, "Max Signal Marks", minval=4, maxval=100, group=grpSignals, inline="s2", tooltip="Upper limit for active signal labels and boxes kept on chart.")

grpLevels = "Flip Levels"
showLevels    = input.bool(true, "Show Confirmed Flip Levels", group=grpLevels, tooltip="Keep confirmed flip levels on chart until they are broken or aged out.")
levelStyleIn  = input.string("Dashed", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grpLevels, tooltip="Style used for active flip levels.")
levelWidth    = input.int(1, "Line Width", minval=1, maxval=4, group=grpLevels, tooltip="Stroke width for active flip levels.")
levelTransp   = input.int(20, "Line Transparency", minval=0, maxval=95, group=grpLevels, tooltip="Transparency applied to active flip levels.")
levelLabelOn   = input.bool(true, "Show Price Label", group=grpLevels, tooltip="Display a clean price label at each active flip level.")
levelLabelSizeIn = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=grpLevels, tooltip="Label sizing for active flip levels.")
maxLevels     = input.int(12, "Max Active Levels", minval=1, maxval=50, group=grpLevels, tooltip="Maximum number of active levels retained on chart.")
maxLevelAge   = input.int(180, "Max Level Age", minval=10, maxval=2000, group=grpLevels, tooltip="Maximum number of bars an unbroken level may remain active.")

grpDash = "Dashboard"
showDash      = input.bool(true, "Show Dashboard", group=grpDash, tooltip="Display the top-right institutional status panel.")
dashBgAlpha   = input.int(12, "Dashboard Opacity", minval=0, maxval=95, group=grpDash, tooltip="Transparency used by the dashboard background.")

//=============================================================================
// HELPER FUNCTIONS
//=============================================================================

f_clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

f_lineStyle(string styleText) =>
    switch styleText
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

f_labelSize(string sizeText) =>
    switch sizeText
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.tiny

f_priceText(float price) =>
    na(price) ? "n/a" : str.tostring(price, format.mintick)

f_alignmentText(int bullCount, int bearCount) =>
    bullCount == 3 ? "3/3 Bull" :
     bearCount == 3 ? "3/3 Bear" :
     bullCount > bearCount ? "Bull Lean" :
     bearCount > bullCount ? "Bear Lean" : "Balanced"

f_regimeText(int trendDir, bool initDone, bool bullBlocked, bool bearBlocked) =>
    not initDone ? "Warmup" :
     trendDir == 1 and bullBlocked ? "Bull Hold" :
     trendDir == -1 and bearBlocked ? "Bear Hold" :
     trendDir == 1 ? "Bull" : "Bear"

f_accelText(float velocity) =>
    velocity < 0.9 ? "Quiet" :
     velocity < 1.35 ? "Steady" :
     velocity < 2.0 ? "Charging" : "Surging"

f_extensionText(float extensionAtr) =>
    extensionAtr < 0.75 ? "Compressed" :
     extensionAtr < 1.50 ? "Balanced" :
     extensionAtr < 2.50 ? "Extended" : "Stretched"

//=============================================================================
// ANCHORED VWAPS
// ----------------------------------------------------------------------------
// These are manually accumulated so the script stays explicit and predictable.
// The reference context is selected later through the regime mode input.
//=============================================================================

newSession = timeframe.change("D")
newWeek = timeframe.change("W")
newMonth = timeframe.change("M")

var float cumPvSession = 0.0
var float cumVolSession = 0.0
var float cumPvWeek = 0.0
var float cumVolWeek = 0.0
var float cumPvMonth = 0.0
var float cumVolMonth = 0.0

if newSession
    cumPvSession := 0.0
    cumVolSession := 0.0
if newWeek
    cumPvWeek := 0.0
    cumVolWeek := 0.0
if newMonth
    cumPvMonth := 0.0
    cumVolMonth := 0.0

cumPvSession += hl2 * volume
cumVolSession += volume
cumPvWeek += hl2 * volume
cumVolWeek += volume
cumPvMonth += hl2 * volume
cumVolMonth += volume

vwapSession = cumVolSession > 0 ? cumPvSession / cumVolSession : hl2
vwapWeek = cumVolWeek > 0 ? cumPvWeek / cumVolWeek : hl2
vwapMonth = cumVolMonth > 0 ? cumPvMonth / cumVolMonth : hl2

selectedVwap = switch vwapMode
    "Session" => vwapSession
    "Week" => vwapWeek
    "Month" => vwapMonth
    => vwapSession

sessionBull = close >= vwapSession
weekBull = close >= vwapWeek
monthBull = close >= vwapMonth

bullCount = (sessionBull ? 1 : 0) + (weekBull ? 1 : 0) + (monthBull ? 1 : 0)
bearCount = 3 - bullCount

gateBull = switch vwapMode
    "Session" => sessionBull
    "Week" => weekBull
    "Month" => monthBull
    "Any" => sessionBull or weekBull or monthBull
    "All" => sessionBull and weekBull and monthBull
    => true

gateBear = switch vwapMode
    "Session" => not sessionBull
    "Week" => not weekBull
    "Month" => not monthBull
    "Any" => (not sessionBull) or (not weekBull) or (not monthBull)
    "All" => (not sessionBull) and (not weekBull) and (not monthBull)
    => true

//=============================================================================
// ARC / TRAIL ENGINE
// ----------------------------------------------------------------------------
// The trail is ratcheted in the active direction and its speed responds to:
// - VWAP extension
// - run length
// - a velocity accumulator
//
// Flips are only confirmed on bar close and only if the VWAP regime gate agrees.
//=============================================================================

trailAtr = ta.atr(trailAtrLen)
trailBase = na(trailAtr) ? na : math.max(trailAtr * trailAtrMult, syminfo.mintick * 2.0)

vwapDistance = math.abs(close - selectedVwap)
extensionAtr = na(trailAtr) or trailAtr <= 0 ? 0.0 : vwapDistance / trailAtr
extensionNorm = f_clamp(extensionAtr / 4.0, 0.0, 1.0)

var bool aegisInit = false
var int aegisTrendDir = 1
var float aegisTrail = na
var float aegisVelocity = 1.0
var int aegisRunBars = 0
var int aegisBarsSinceFlip = 1000
var float lastConfirmedFlipPrice = na
var int lastConfirmedFlipBar = na
var bool bullBlockedState = false
var bool bearBlockedState = false

float bullTargetRaw = na
float bearTargetRaw = na
float bullTargetRatcheted = na
float bearTargetRatcheted = na
float chaseFactor = minChase
float accelBoost = 1.0
float effectiveAccel = accelBase

if not na(trailBase)
    bullTargetRaw := low - trailBase
    bearTargetRaw := high + trailBase

if not aegisInit and not na(trailBase)
    aegisTrendDir := close >= selectedVwap ? 1 : -1
    aegisTrail := aegisTrendDir == 1 ? bullTargetRaw : bearTargetRaw
    aegisVelocity := 1.0
    aegisRunBars := 0
    aegisBarsSinceFlip := 1000
    aegisInit := true

if aegisInit and not na(trailBase)
    accelBoost := 1.0 + (vwapBoost - 1.0) * extensionNorm
    effectiveAccel := accelBase * accelBoost * (1.0 + math.min(aegisRunBars / float(runWindow), 2.0) * 0.12)
    aegisVelocity := f_clamp(nz(aegisVelocity[1], 1.0) * velocityDecay + effectiveAccel, 0.0, velocityCap)
    chaseFactor := f_clamp(minChase + aegisVelocity * 0.03 + extensionNorm * 0.08, minChase, maxChase)

    bullTargetRatcheted := na(aegisTrail[1]) ? bullTargetRaw : math.max(bullTargetRaw, aegisTrail[1])
    bearTargetRatcheted := na(aegisTrail[1]) ? bearTargetRaw : math.min(bearTargetRaw, aegisTrail[1])

    confirmedBullCross = barstate.isconfirmed and aegisTrendDir == -1 and not na(aegisTrail[1]) and close > aegisTrail[1]
    confirmedBearCross = barstate.isconfirmed and aegisTrendDir == 1 and not na(aegisTrail[1]) and close < aegisTrail[1]

    allowBullFlip = confirmedBullCross and gateBull and aegisBarsSinceFlip >= minFlipGap
    allowBearFlip = confirmedBearCross and gateBear and aegisBarsSinceFlip >= minFlipGap
    bullBlocked = confirmedBullCross and not allowBullFlip
    bearBlocked = confirmedBearCross and not allowBearFlip

    nextTrendDir = aegisTrendDir
    if allowBullFlip
        nextTrendDir := 1
    else if allowBearFlip
        nextTrendDir := -1

    bool trendChanged = nextTrendDir != aegisTrendDir

    if trendChanged
        aegisTrendDir := nextTrendDir
        aegisTrail := nextTrendDir == 1 ? bullTargetRaw : bearTargetRaw
        aegisVelocity := 1.0
        aegisRunBars := 0
        aegisBarsSinceFlip := 0
        lastConfirmedFlipPrice := close
        lastConfirmedFlipBar := bar_index
    else
        if aegisTrendDir == 1
            aegisTrail := na(aegisTrail[1]) ? bullTargetRatcheted : aegisTrail[1] + (bullTargetRatcheted - aegisTrail[1]) * chaseFactor
            aegisTrail := math.min(aegisTrail, low - syminfo.mintick)
        else
            aegisTrail := na(aegisTrail[1]) ? bearTargetRatcheted : aegisTrail[1] + (bearTargetRatcheted - aegisTrail[1]) * chaseFactor
            aegisTrail := math.max(aegisTrail, high + syminfo.mintick)
        aegisRunBars += 1
        aegisBarsSinceFlip += 1

    // Store blocked-state flags for dashboard text after state mutation.
    bullBlockedState := bullBlocked
    bearBlockedState := bearBlocked

//=============================================================================
// ACTIVE FLIP LEVEL REGISTRY
// ----------------------------------------------------------------------------
// Flip levels are retained as horizontal lines that extend to the right until
// price breaks them on a confirmed bar or the level ages out.
//=============================================================================

var line[] aegisLevelLines = array.new_line()
var label[] aegisLevelLabels = array.new_label()
var float[] aegisLevelPrices = array.new_float()
var bool[] aegisLevelBull = array.new_bool()
var int[] aegisLevelBorn = array.new_int()
var label[] aegisSignalLabels = array.new_label()
var box[] aegisSignalBoxes = array.new_box()

f_trimLevels() =>
    while array.size(aegisLevelLines) > maxLevels
        line oldLine = array.shift(aegisLevelLines)
        label oldLabel = array.shift(aegisLevelLabels)
        array.shift(aegisLevelPrices)
        array.shift(aegisLevelBull)
        array.shift(aegisLevelBorn)
        line.delete(oldLine)
        label.delete(oldLabel)
    true

f_clearAllLevels() =>
    while array.size(aegisLevelLines) > 0
        line oldLine = array.shift(aegisLevelLines)
        label oldLabel = array.shift(aegisLevelLabels)
        array.shift(aegisLevelPrices)
        array.shift(aegisLevelBull)
        array.shift(aegisLevelBorn)
        line.delete(oldLine)
        label.delete(oldLabel)
    true

f_pushSignalLabel(label lb) =>
    array.push(aegisSignalLabels, lb)
    while array.size(aegisSignalLabels) > maxSignalMarks
        label oldLabel = array.shift(aegisSignalLabels)
        label.delete(oldLabel)
    true

f_pushSignalBox(box bx) =>
    array.push(aegisSignalBoxes, bx)
    while array.size(aegisSignalBoxes) > maxSignalMarks
        box oldBox = array.shift(aegisSignalBoxes)
        box.delete(oldBox)
    true

f_clearSignalLabels() =>
    while array.size(aegisSignalLabels) > 0
        label oldLabel = array.shift(aegisSignalLabels)
        label.delete(oldLabel)
    true

f_clearSignalBoxes() =>
    while array.size(aegisSignalBoxes) > 0
        box oldBox = array.shift(aegisSignalBoxes)
        box.delete(oldBox)
    true

if not showLevels and array.size(aegisLevelLines) > 0
    f_clearAllLevels()

if not showSignals and array.size(aegisSignalLabels) > 0
    f_clearSignalLabels()

if not showSignalBoxes and array.size(aegisSignalBoxes) > 0
    f_clearSignalBoxes()

confirmedFlip = aegisInit and barstate.isconfirmed and lastConfirmedFlipBar == bar_index
confirmedBullFlip = confirmedFlip and aegisTrendDir == 1
confirmedBearFlip = confirmedFlip and aegisTrendDir == -1
blockedBullAttempt = aegisInit and barstate.isconfirmed and bullBlockedState
blockedBearAttempt = aegisInit and barstate.isconfirmed and bearBlockedState

if confirmedFlip and showLevels and not na(lastConfirmedFlipPrice)
    flipColor = aegisTrendDir == 1 ? bullColorIn : bearColorIn
    levelStyle = f_lineStyle(levelStyleIn)
    float flipPrice = lastConfirmedFlipPrice
    string flipLabelText = levelLabelOn ? f_priceText(flipPrice) : ""
    color flipLabelBg = levelLabelOn ? color.new(flipColor, 88) : color.new(flipColor, 100)
    color flipLabelTxt = levelLabelOn ? flipColor : color.new(flipColor, 100)

    line levelLine = line.new(bar_index - 1, flipPrice, bar_index, flipPrice, xloc=xloc.bar_index, extend=extend.right, color=color.new(flipColor, levelTransp), width=levelWidth, style=levelStyle)
    label levelLabel = label.new(bar_index, flipPrice, flipLabelText, xloc=xloc.bar_index, style=label.style_label_left, size=f_labelSize(levelLabelSizeIn), color=flipLabelBg, textcolor=flipLabelTxt)

    array.push(aegisLevelLines, levelLine)
    array.push(aegisLevelLabels, levelLabel)
    array.push(aegisLevelPrices, flipPrice)
    array.push(aegisLevelBull, aegisTrendDir == 1)
    array.push(aegisLevelBorn, bar_index)
    f_trimLevels()

// Update and prune active levels.
if array.size(aegisLevelLines) > 0
    for i = array.size(aegisLevelLines) - 1 to 0
        line activeLine = array.get(aegisLevelLines, i)
        label activeLabel = array.get(aegisLevelLabels, i)
        float activePrice = array.get(aegisLevelPrices, i)
        bool activeBull = array.get(aegisLevelBull, i)
        int bornBar = array.get(aegisLevelBorn, i)

        if not na(activeLine)
            line.set_extend(activeLine, extend.right)

        if not na(activeLabel)
            label.set_x(activeLabel, bar_index)
            label.set_y(activeLabel, activePrice)

        bool levelBroken = barstate.isconfirmed and ((activeBull and close < activePrice) or (not activeBull and close > activePrice))
        bool levelAged = bar_index - bornBar > maxLevelAge

        if levelBroken or levelAged
            line.delete(activeLine)
            label.delete(activeLabel)
            array.remove(aegisLevelLines, i)
            array.remove(aegisLevelLabels, i)
            array.remove(aegisLevelPrices, i)
            array.remove(aegisLevelBull, i)
            array.remove(aegisLevelBorn, i)

// Confirmed signal labels and projected boxes.
if showSignals and confirmedBullFlip
    string bullText = "AEGIS LONG\nFlip " + f_priceText(close) + "\n" + f_extensionText(extensionAtr)
    label bullLabel = label.new(bar_index, low, bullText, xloc=xloc.bar_index, style=label.style_label_up, size=f_labelSize(signalLabelSizeIn), color=color.new(bullColorIn, 84), textcolor=color.new(bullColorIn, 0))
    f_pushSignalLabel(bullLabel)

if showSignals and confirmedBearFlip
    string bearText = "AEGIS SHORT\nFlip " + f_priceText(close) + "\n" + f_extensionText(extensionAtr)
    label bearLabel = label.new(bar_index, high, bearText, xloc=xloc.bar_index, style=label.style_label_down, size=f_labelSize(signalLabelSizeIn), color=color.new(bearColorIn, 84), textcolor=color.new(bearColorIn, 0))
    f_pushSignalLabel(bearLabel)

if showBlockedSignals and blockedBullAttempt
    label gateBullLabel = label.new(bar_index, high, "Bull Gate", xloc=xloc.bar_index, style=label.style_label_down, size=size.tiny, color=color.new(neutralColorIn, 84), textcolor=color.new(bullColorIn, 0))
    f_pushSignalLabel(gateBullLabel)

if showBlockedSignals and blockedBearAttempt
    label gateBearLabel = label.new(bar_index, low, "Bear Gate", xloc=xloc.bar_index, style=label.style_label_up, size=size.tiny, color=color.new(neutralColorIn, 84), textcolor=color.new(bearColorIn, 0))
    f_pushSignalLabel(gateBearLabel)

if showSignalBoxes and (confirmedBullFlip or confirmedBearFlip) and not na(trailAtr)
    float signalPad = math.max(trailAtr * signalBoxAtrPad, syminfo.mintick * 4.0)
    float signalTop = high + signalPad
    float signalBottom = low - signalPad
    color signalBorder = confirmedBullFlip ? color.new(bullColorIn, 25) : color.new(bearColorIn, 25)
    color signalFill = confirmedBullFlip ? color.new(bullColorIn, 90) : color.new(bearColorIn, 90)
    box signalBox = box.new(bar_index, signalTop, bar_index + signalBoxBars, signalBottom, xloc=xloc.bar_index, bgcolor=signalFill, border_color=signalBorder, border_width=1)
    f_pushSignalBox(signalBox)

//=============================================================================
// VISUAL PALETTE
//=============================================================================

bullBase = bullColorIn
bearBase = bearColorIn
neutralBase = neutralColorIn

trendBaseColor = aegisInit ? (aegisTrendDir == 1 ? bullBase : bearBase) : neutralBase
trendColor = color.from_gradient(extensionNorm, 0.0, 1.0, color.new(trendBaseColor, 78), trendBaseColor)
trailGlowColor = color.new(trendColor, 84)
cloudAlpha = int(math.round(f_clamp(92.0 - extensionNorm * 22.0, 55.0, 92.0)))
barAlpha = int(math.round(f_clamp(82.0 - extensionNorm * 55.0, 10.0, 85.0)))

referenceColor = color.new(neutralBase, 70)
referenceGlow = color.new(neutralBase, 88)

//=============================================================================
// PLOTS
// ----------------------------------------------------------------------------
// The visual stack is intentionally simple:
// - a faint VWAP reference
// - a glow trail
// - the main arc trail
// - a soft cloud between trail and VWAP
//=============================================================================

refPlot = plot(showReference ? selectedVwap : na, "Selected VWAP", color=referenceColor, linewidth=1)
trailGlowPlot = plot(showGlow ? aegisTrail : na, "Aegis Trail Glow", color=trailGlowColor, linewidth=7)
trailPlot = plot(aegisTrail, "Aegis Trail", color=trendColor, linewidth=2)

cloudColor = showCloud ? color.new(trendBaseColor, cloudAlpha) : color.new(trendBaseColor, 100)
fill(trailPlot, refPlot, color=cloudColor, title="Aegis Cloud")

// Optional candle tinting with extension-aware intensity.
barTint = showCandleTint and aegisInit ? color.new(trendBaseColor, barAlpha) : na
barcolor(barTint)
plotshape(showSignals and confirmedBullFlip ? low : na, title="Aegis Bull Flip", style=shape.circle, location=location.absolute, color=color.new(bullBase, 0), size=size.tiny)
plotshape(showSignals and confirmedBearFlip ? high : na, title="Aegis Bear Flip", style=shape.circle, location=location.absolute, color=color.new(bearBase, 0), size=size.tiny)
plotshape(showBlockedSignals and blockedBullAttempt ? high : na, title="Aegis Bull Blocked", style=shape.xcross, location=location.absolute, color=color.new(bullBase, 0), size=size.tiny)
plotshape(showBlockedSignals and blockedBearAttempt ? low : na, title="Aegis Bear Blocked", style=shape.xcross, location=location.absolute, color=color.new(bearBase, 0), size=size.tiny)

//=============================================================================
// DASHBOARD
// ----------------------------------------------------------------------------
// Compact top-right status board for regime, VWAP alignment, acceleration,
// extension, and the latest confirmed flip price.
//=============================================================================

var table aegisDash = table.new(position.top_right, 2, 6, bgcolor=color.new(#07111d, dashBgAlpha), border_width=1, border_color=color.new(#314156, 55), frame_width=1, frame_color=color.new(#314156, 50))

dashRegime = f_regimeText(aegisTrendDir, aegisInit, bullBlockedState, bearBlockedState)
dashAlign = f_alignmentText(bullCount, bearCount)
dashAccel = f_accelText(aegisVelocity)
dashExtension = f_extensionText(extensionAtr)
dashFlip = f_priceText(lastConfirmedFlipPrice)

if barstate.islast
    if showDash
        headerBg = color.new(#102033, 0)
        sectionBg = color.new(#0f1a27, 0)
        valueBg = color.new(#111c2a, 0)
        textCore = color.new(color.white, 0)
        textSoft = color.new(#9fb2c7, 0)
        accentBull = color.new(bullBase, 0)
        accentBear = color.new(bearBase, 0)
        accentNeutral = color.new(neutralBase, 0)

        table.cell(aegisDash, 0, 0, "AEGIS ARC", bgcolor=headerBg, text_color=textCore, text_size=size.small, text_halign=text.align_center)
        table.cell(aegisDash, 1, 0, "JOAT", bgcolor=headerBg, text_color=color.new(bullBase, 0), text_size=size.small, text_halign=text.align_center)

        table.cell(aegisDash, 0, 1, "Regime", bgcolor=sectionBg, text_color=textSoft, text_size=size.small)
        table.cell(aegisDash, 1, 1, dashRegime, bgcolor=valueBg, text_color=aegisTrendDir == 1 ? accentBull : accentBear, text_size=size.small, text_halign=text.align_center)

        table.cell(aegisDash, 0, 2, "VWAP", bgcolor=sectionBg, text_color=textSoft, text_size=size.small)
        table.cell(aegisDash, 1, 2, vwapMode + " | " + dashAlign, bgcolor=valueBg, text_color=accentNeutral, text_size=size.small, text_halign=text.align_center)

        table.cell(aegisDash, 0, 3, "Acceleration", bgcolor=sectionBg, text_color=textSoft, text_size=size.small)
        table.cell(aegisDash, 1, 3, dashAccel + " | " + str.tostring(aegisVelocity, "#.00"), bgcolor=valueBg, text_color=accentNeutral, text_size=size.small, text_halign=text.align_center)

        table.cell(aegisDash, 0, 4, "Extension", bgcolor=sectionBg, text_color=textSoft, text_size=size.small)
        table.cell(aegisDash, 1, 4, dashExtension + " | " + str.tostring(extensionAtr, "#.00") + " ATR", bgcolor=valueBg, text_color=accentNeutral, text_size=size.small, text_halign=text.align_center)

        table.cell(aegisDash, 0, 5, "Flip", bgcolor=sectionBg, text_color=textSoft, text_size=size.small)
        flipAgeText = na(lastConfirmedFlipBar) ? "n/a" : str.tostring(bar_index - lastConfirmedFlipBar) + " bars"
        table.cell(aegisDash, 1, 5, dashFlip + " | " + flipAgeText, bgcolor=valueBg, text_color=accentNeutral, text_size=size.small, text_halign=text.align_center)
    else
        for r = 0 to 5
            table.cell(aegisDash, 0, r, "", bgcolor=color.new(#07111d, 100), text_color=color.new(color.white, 100))
            table.cell(aegisDash, 1, r, "", bgcolor=color.new(#07111d, 100), text_color=color.new(color.white, 100))

//=============================================================================
// ALERTS
// ----------------------------------------------------------------------------
// Alert hooks for confirmed regime flips.
//=============================================================================

alertcondition(confirmedBullFlip, title="Aegis Bullish Flip", message="Aegis Arc Framework [JOAT]: Bullish flip confirmed on {{ticker}} {{interval}}")
alertcondition(confirmedBearFlip, title="Aegis Bearish Flip", message="Aegis Arc Framework [JOAT]: Bearish flip confirmed on {{ticker}} {{interval}}")

//=============================================================================
// END
//=============================================================================
````
