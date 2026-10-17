# Compression Shift Index [JOAT]

- url: https://www.tradingview.com/script/Urm1jvav-Compression-Shift-Index-JOAT/
- type: indicator
- pine_id: PUB;7a0d8b27e4e2403bb71d53d89499b4ef
- version: 1.0

## Description

[b]Compression Shift Index [JOAT][/b]

[b]Introduction[/b]

Compression Shift Index is an open-source Pine Script v6 indicator designed to detect transitions between compression and displacement. It measures whether price is storing energy in a tight state, whether that energy is beginning to release directionally, and whether the release is supported by enough pressure and travel efficiency to matter.

The problem this indicator solves is timing. Traders often recognize trend after the move is already mature, or they chase weak momentum bursts that never become true displacement. Compression Shift Index is built to distinguish between quiet compression, directional pressure, and confirmed shift conditions so the user can see whether price is merely active or whether a real state change is underway.

The script lives in its own pane, but it also projects tactical shift ranges onto the main chart. That means it can work as both a state engine and a visual execution aid. The pane handles classification and scoring. The overlay range preserves the high, low, and midpoint of the most recent active shift so price can be read against the trigger zone directly on the chart.

Rather than relying on one oscillator reading, the script blends moving-average spread, RSI of momentum, ATR expansion, path efficiency, and compression mathematics. The result is not a conventional trend tool. It is a state-transition tool built to show when stored pressure is becoming directional opportunity.

[image]https://www.tradingview.com/x/jE9aJOq9/[/image]

[b]Core Concepts[/b]

[b]1. Compression Score[/b]

Compression is measured by comparing the recent price range to ATR-normalized movement over a configurable window. As the range contracts relative to expected volatility, the compression score rises.

[pine]
float compressionRatio = safeDiv(ta.highest(high, compressionLength) - ta.lowest(low, compressionLength), ta.atr(compressionLength) * compressionLength) * 100.0
float compressionScore = clamp(100.0 - compressionRatio, 0, 100)
[/pine]

This means the script is not labeling compression by candle size alone. It evaluates the market relative to its own volatility conditions.

[b]2. Displacement Score[/b]

Displacement is measured through moving-average spread magnitude, RSI-based pressure away from neutrality, and fast-versus-slow ATR expansion. A high displacement score means price is no longer just compressed. It is pushing with enough directional force to deserve attention.

[b]3. Pressure Confirmation[/b]

Directional pressure requires more than a large reading. Bullish pressure needs positive spread and price acceptance above the fast EMA. Bearish pressure requires the opposite. This creates a separation between raw movement and directional pressure that is actually aligned with the current path of price.

[b]4. Shift Range Memory[/b]

When a confirmed bull or bear shift occurs, the script stores the initiating bar’s high and low, then extends that range for a configurable number of bars. As new bars arrive, the active range updates its upper and lower boundaries.

This transforms the shift from a momentary signal into a tactical map. The trader can judge whether price is holding inside the shift range, stretching away from it, or failing back through the structure.

[b]5. Quality And Travel Efficiency[/b]

Not every shift is equal. The script measures path efficiency by comparing net travel to the cumulative path traveled across the efficiency window. That helps distinguish efficient directional release from noisy back-and-fill movement.

When displacement, pressure, and efficiency all align, the quality score rises. This is especially useful for separating impulsive continuation from unstable burst behavior.

[image]https://www.tradingview.com/x/lVlhCCCm/[/image]

[b]Features[/b]

[list]
[*][b]Compression and displacement state engine:[/b] Differentiates quiet conditions from directional release
[*][b]Bull and bear shift detection:[/b] Confirms directional shifts only after displacement and pressure criteria align
[*][b]Tactical overlay range:[/b] Projects the active shift high, low, and midpoint onto the main chart
[*][b]Ribbon bias display:[/b] Adds a visual ribbon showing directional pressure inside the pane
[*][b]Travel efficiency scoring:[/b] Measures whether displacement is clean or noisy
[*][b]State backdrop and candle tinting:[/b] Tints both pane and chart context according to the current state
[*][b]Detailed dashboard:[/b] Publishes compression, displacement, ATR ratio, heat, range, stretch, velocity, efficiency, quality, and persistence
[*][b]Confirmed-bar alerts:[/b] Includes compression, bull shift, bear shift, pressure, release, fade, and quality-state alerts
[*][b]Data-window exports:[/b] Makes many internal scores accessible without adding extra plots to the pane
[*][b]Range-aging logic:[/b] Tracks how long the active shift has been in effect
[/list]

[b]Visual Elements[/b]

[list]
[*][b]Pane state curves:[/b] The net shift, compression, and displacement lines provide a layered read of current state
[*][b]Ribbon bias fill:[/b] The pane ribbon helps show whether directional pressure is leaning bullish or bearish before full shift confirmation
[*][b]Overlay shift range:[/b] The active high, low, and midpoint are projected onto the price chart for tactical context
[*][b]Backdrop and candle tinting:[/b] The indicator colors both pane and chart state to make transitions easier to identify at a glance
[*][b]Dashboard diagnostics:[/b] The top-right panel summarizes metrics that would otherwise require several separate indicators
[/list]

[b]Best Practices[/b]

[list]
[*]Wait for displacement to dominate compression before assuming a move has truly released
[*]Use high-quality shifts as higher-priority context than low-efficiency state changes
[*]Read the active shift range as a tactical map, not as a guarantee that price will respect every boundary
[*]If pressure improves but displacement remains weak, treat the move as developing rather than already established
[*]Use the state engine to filter your existing entries instead of trying to trade every alert in isolation
[/list]

[b]Input Parameters[/b]

[b]Signal Engine:[/b]
[list]
[*]Fast MA Length: Sets the fast trend reference
[*]Slow MA Length: Sets the slow trend reference
[*]Compression Window: Defines the state lookback for range contraction
[*]RSI Length: Sets the smoothing period for momentum pressure evaluation
[*]Momentum Length: Defines the raw momentum lookback
[/list]

[b]Thresholds:[/b]
[list]
[*]Compression Threshold: Determines how compressed the market must be to count as compressed
[*]Displacement Threshold: Determines how forceful the move must be to count as a shift
[*]Shift Hold Bars: Controls how long the active shift range remains alive
[*]Efficiency Length: Sets the path-efficiency lookback
[*]Show Trigger Range: Toggles the projected overlay range on the chart
[/list]

[b]Visual Language:[/b]
[list]
[*]Bull and bear color pairs
[*]Neutral color and panel background
[*]Show Dashboard toggle
[*]Show State Backdrop toggle
[*]Show State Ribbon toggle
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify The Current State[/b]
Start with the dashboard and pane. If compression is dominant, the market is still storing energy. If bull or bear pressure is present, directional force is building. If a bull or bear shift is confirmed, the state transition has already occurred.

[b]Step 2: Compare Compression To Displacement[/b]
The most useful read is not the absolute number alone, but the relationship between compression and displacement. When compression is high and displacement is still low, the market is coiled. When displacement overtakes compression, the release phase is gaining control.

[b]Step 3: Use The Active Shift Range[/b]
Once a shift is active, watch the projected upper, lower, and midpoint lines on the main chart. These define the tactical zone created by the displacement event. Price behavior around that range often provides better context than the signal bar alone.

[b]Step 4: Check Quality And Efficiency[/b]
A high-quality state means the release is not only directional but also relatively efficient. If quality is weak, treat the shift more cautiously because the move may be noisy or unstable.

[b]Step 5: Use It As A State Filter[/b]
Compression Shift Index is most effective as a state filter for your own process. It can help you avoid forcing breakout logic during compression and avoid fading a move that is still in active displacement.

[b]Indicator Limitations[/b]

[list]
[*]Compression does not guarantee that a strong displacement event will follow immediately
[*]A shift can fail quickly if the broader market context does not support follow-through
[*]Travel efficiency can lag during early release phases because noisy price action is still being absorbed into the lookback
[*]The active shift range is a tactical reference zone, not an automatic support or resistance guarantee
[/list]

[b]Originality Statement[/b]

Compression Shift Index is original in the way it turns compression, displacement, pressure, efficiency, and range memory into one unified transition model. It is not simply an oscillator blend for cosmetic effect:

[list]
[*]It frames compression and release as a state transition rather than a single threshold cross
[*]It preserves the originating shift range on the main chart, which links pane analysis to execution context
[*]It includes efficiency and velocity metrics that help separate orderly displacement from noisy expansion
[*]It uses a dashboard that summarizes the full state stack rather than forcing the user to infer everything from one line
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Compression and displacement readings describe market state, not guaranteed future direction. Markets can remain compressed longer than expected or reverse immediately after a shift appears. Always use independent judgment and proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Compression Shift Index [JOAT]", shorttitle = "KIN [JOAT]", overlay = false, max_lines_count = 500, max_labels_count = 200, max_boxes_count = 200)

//--------------------------------------------------------------------------------------------------
// JOAT Compression Shift Index
//--------------------------------------------------------------------------------------------------
// Purpose:
// - Detect transitions between compression and displacement.
// - Measure whether directional pressure is emerging with enough force to matter.
// - Preserve tactical trigger ranges on the chart without turning into a trend overlay.
//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
// Inputs
//--------------------------------------------------------------------------------------------------
string groupSignal = "Signal Engine"
int fastMaLength = input.int(21, "Fast MA Length", minval = 5, maxval = 80, group = groupSignal)
int slowMaLength = input.int(55, "Slow MA Length", minval = 10, maxval = 150, group = groupSignal)
int compressionLength = input.int(34, "Compression Window", minval = 10, maxval = 100, group = groupSignal)
int rsiLength = input.int(14, "RSI Length", minval = 5, maxval = 50, group = groupSignal)
int momentumLength = input.int(9, "Momentum Length", minval = 3, maxval = 30, group = groupSignal)

string groupThresholds = "Thresholds"
float compressionThreshold = input.float(32.0, "Compression Threshold", minval = 5.0, maxval = 80.0, step = 0.5, group = groupThresholds)
float displacementThreshold = input.float(58.0, "Displacement Threshold", minval = 20.0, maxval = 100.0, step = 0.5, group = groupThresholds)
int shiftHoldBars = input.int(14, "Shift Hold Bars", minval = 4, maxval = 40, group = groupThresholds)
int efficiencyLength = input.int(21, "Efficiency Length", minval = 5, maxval = 80, group = groupThresholds)
bool showOverlayRange = input.bool(true, "Show Trigger Range", group = groupThresholds)

string groupStyle = "Visual Language"
color bullCore = input.color(color.rgb(29, 202, 150), "Bull Core", group = groupStyle, inline = "a")
color bearCore = input.color(color.rgb(198, 66, 183), "Bear Core", group = groupStyle, inline = "a")
color bullAccent = input.color(color.rgb(34, 124, 199), "Bull Accent", group = groupStyle, inline = "b")
color bearAccent = input.color(color.rgb(255, 128, 68), "Bear Accent", group = groupStyle, inline = "b")
color neutralCore = input.color(color.rgb(135, 145, 160), "Neutral", group = groupStyle)
color panelBg = input.color(color.rgb(14, 20, 30), "Panel Background", group = groupStyle)
bool showDashboard = input.bool(true, "Show Dashboard", group = groupStyle)
bool showBackdrop = input.bool(true, "Show State Backdrop", group = groupStyle)
bool showRibbon = input.bool(true, "Show State Ribbon", group = groupStyle)

//--------------------------------------------------------------------------------------------------
// Persistent state
//--------------------------------------------------------------------------------------------------
var int shiftStart = na
var float shiftUpper = na
var float shiftLower = na
var color shiftColor = na
var table dashboard = table.new(position.top_right, 2, 18, frame_color = color.new(color.white, 85), frame_width = 1)

//--------------------------------------------------------------------------------------------------
// Helpers
//--------------------------------------------------------------------------------------------------
safeDiv(float numerator, float denominator) =>
    denominator == 0.0 ? 0.0 : numerator / denominator

clamp(float value, float minValue, float maxValue) =>
    math.max(minValue, math.min(maxValue, value))

dashboardCell(int column, int row, string cellText, color bg, color fg) =>
    table.cell(dashboard, column, row, cellText, bgcolor = bg, text_color = fg, text_size = size.small)

signalColor(bool bull, float intensity) =>
    color primary = bull ? bullCore : bearCore
    color accent = bull ? bullAccent : bearAccent
    color.from_gradient(intensity, 0, 100, color.new(accent, 70), color.new(primary, 0))

fillColor(bool bull, float intensity) =>
    color primary = bull ? bullCore : bearCore
    color accent = bull ? bullAccent : bearAccent
    color.from_gradient(intensity, 0, 100, color.new(accent, 94), color.new(primary, 84))

//--------------------------------------------------------------------------------------------------
// Signal stack
//--------------------------------------------------------------------------------------------------
float fastEma = ta.ema(close, fastMaLength)
float slowEma = ta.ema(close, slowMaLength)
float atrFast = ta.atr(21)
float atrSlow = ta.atr(100)
float atrRatio = safeDiv(atrFast, atrSlow) * 100.0

float spread = fastEma - slowEma
float spreadMagnitude = safeDiv(math.abs(spread), atrSlow) * 100.0
float compressionRatio = safeDiv(ta.highest(high, compressionLength) - ta.lowest(low, compressionLength), ta.atr(compressionLength) * compressionLength) * 100.0

float momentum = ta.mom(close, momentumLength)
float pressureRsi = ta.rsi(momentum, rsiLength)
float heatNorm = safeDiv(close - ta.lowest(low, compressionLength), math.max(ta.highest(high, compressionLength) - ta.lowest(low, compressionLength), syminfo.mintick)) * 100.0

float compressionScore = clamp(100.0 - compressionRatio, 0, 100)
float displacementScore = clamp(spreadMagnitude * 0.50 + math.abs(pressureRsi - 50.0) * 1.00 + atrRatio * 0.30, 0, 100)
float directionalScore = clamp(math.abs(pressureRsi - 50.0) * 2.0, 0, 100)
float shiftStretchAtr = safeDiv(close - fastEma, atrFast)
float pressureDelta = pressureRsi - 50.0
float compressionDelta = compressionThreshold - compressionScore
float ribbonBias = clamp(pressureDelta * 1.8 + ta.change(close, 3) * 0.02, -100, 100)
float displacementVelocity = ta.change(displacementScore)
float compressionVelocity = ta.change(compressionScore)
int effectiveEfficiencyLength = math.min(efficiencyLength, bar_index)
float pathTravel = effectiveEfficiencyLength > 0 ? math.sum(math.abs(ta.change(close)), effectiveEfficiencyLength) : 0.0
float travelEfficiency = effectiveEfficiencyLength > 0 ? safeDiv(math.abs(close - close[effectiveEfficiencyLength]), math.max(pathTravel, syminfo.mintick)) * 100.0 : 0.0
float qualityScore = clamp(displacementScore - compressionScore + travelEfficiency * 0.25, 0, 100)

bool bullPressure = pressureRsi > 54 and spread > 0 and close > fastEma
bool bearPressure = pressureRsi < 46 and spread < 0 and close < fastEma

bool compressionState = compressionScore >= compressionThreshold and displacementScore < displacementThreshold
bool bullShift = barstate.isconfirmed and displacementScore >= displacementThreshold and bullPressure
bool bearShift = barstate.isconfirmed and displacementScore >= displacementThreshold and bearPressure
var int statePersistence = 0
statePersistence := compressionState == compressionState[1] ? nz(statePersistence[1]) + 1 : 0

//--------------------------------------------------------------------------------------------------
// Shift range memory
//--------------------------------------------------------------------------------------------------
if bullShift or bearShift
    shiftStart := bar_index
    shiftUpper := high
    shiftLower := low
    shiftColor := bullShift ? signalColor(true, displacementScore) : signalColor(false, displacementScore)

bool shiftActive = not na(shiftStart) and bar_index - shiftStart <= shiftHoldBars
int shiftAge = shiftActive ? bar_index - shiftStart : na
if shiftActive
    shiftUpper := math.max(shiftUpper, high)
    shiftLower := math.min(shiftLower, low)
else
    shiftUpper := na
    shiftLower := na
    shiftColor := na

//--------------------------------------------------------------------------------------------------
// Pane calculations
//--------------------------------------------------------------------------------------------------
float netShift =
     bullPressure
     ? displacementScore
     : bearPressure
       ? -displacementScore
       : 0.0

float compressionBandUpper = compressionThreshold
float displacementBandUpper = displacementThreshold

color mainOscColor =
     netShift >= 0
     ? color.from_gradient(netShift, 0, 100, color.new(bullAccent, 70), color.new(bullCore, 0))
     : color.from_gradient(math.abs(netShift), 0, 100, color.new(bearAccent, 70), color.new(bearCore, 0))

plotNet = plot(netShift, "Net Shift", color = mainOscColor, linewidth = 2)
plotZero = plot(0, "Zero", color = color.new(neutralCore, 40))
plotCompression = plot(compressionScore, "Compression Score", color = color.new(neutralCore, 10), linewidth = 1)
plotDisplacement = plot(displacementScore, "Displacement Score", color = color.new(color.white, 30), linewidth = 1)

hline(compressionThreshold, "Compression Threshold", color = color.new(neutralCore, 60), linestyle = hline.style_dashed)
hline(displacementThreshold, "Displacement Threshold", color = color.new(neutralCore, 60), linestyle = hline.style_dashed)
hline(-displacementThreshold, "-Displacement Threshold", color = color.new(neutralCore, 60), linestyle = hline.style_dashed)

fill(plotNet, plotZero, netShift > 0 ? color.new(bullCore, 88) : color.new(bearCore, 88))
plotRibbonUpper = plot(showRibbon ? ribbonBias : na, "Ribbon Bias", color = color.new(mainOscColor, 0), linewidth = 1, style = plot.style_area)
plotRibbonLower = plot(showRibbon ? 0 : na, "", color = color.new(neutralCore, 100))
fill(plotRibbonUpper, plotRibbonLower, ribbonBias >= 0 ? color.new(bullAccent, 88) : color.new(bearAccent, 88))

//--------------------------------------------------------------------------------------------------
// Tactical overlay range
//--------------------------------------------------------------------------------------------------
plot(showOverlayRange and shiftActive ? shiftUpper : na, "Shift Upper", color = shiftColor, style = plot.style_linebr, force_overlay = true)
plot(showOverlayRange and shiftActive ? shiftLower : na, "Shift Lower", color = shiftColor, style = plot.style_linebr, force_overlay = true)
rangeTop = plot(showOverlayRange and shiftActive ? shiftUpper : na, "", color = color.new(shiftColor, 70), linewidth = 3, force_overlay = true)
rangeBot = plot(showOverlayRange and shiftActive ? shiftLower : na, "", color = color.new(shiftColor, 70), linewidth = 3, force_overlay = true)
fill(rangeTop, rangeBot, color = color.new(shiftColor, 90))

float shiftMid = shiftActive ? math.avg(shiftUpper, shiftLower) : na
float zoneDistanceAtr = shiftActive ? safeDiv(close - shiftMid, atrFast) : na
float activeRangeAtr = shiftActive ? safeDiv(shiftUpper - shiftLower, atrFast) : na
plot(showOverlayRange and shiftActive ? shiftMid : na, "Shift Mid", color = color.new(neutralCore, 10), style = plot.style_linebr, force_overlay = true)

color overlayCandle =
     bullShift
     ? signalColor(true, displacementScore)
     : bearShift
       ? signalColor(false, displacementScore)
       : compressionState
         ? color.new(neutralCore, 40)
         : na

bgcolor(showBackdrop ? color.new(overlayCandle, 94) : na)
barcolor(overlayCandle)
plotcandle(open, high, low, close, color = overlayCandle, wickcolor = overlayCandle, bordercolor = overlayCandle, force_overlay = true, title = "Shift Candles")

//--------------------------------------------------------------------------------------------------
// Dashboard
//--------------------------------------------------------------------------------------------------
if showDashboard and barstate.islast
    bool bullDominant = netShift >= 0
    color panelTop = color.new(bullDominant ? bullCore : bearCore, 84)
    string zoneTag = shiftActive ? (netShift >= 0 ? "Bull Range" : "Bear Range") : "No Active Range"
    string stateTag =
         compressionState ? "Compression" :
         bullShift ? "Bull Shift" :
         bearShift ? "Bear Shift" :
         bullPressure ? "Bull Pressure" :
         bearPressure ? "Bear Pressure" :
         "Neutral"

    dashboardCell(0, 0, "Shift Index", panelTop, color.white)
    dashboardCell(1, 0, stateTag, panelTop, color.white)

    dashboardCell(0, 1, "Compression", panelBg, color.new(color.white, 10))
    dashboardCell(1, 1, str.tostring(compressionScore, "#.0") + "%", panelBg, compressionState ? neutralCore : color.white)

    dashboardCell(0, 2, "Displacement", panelBg, color.new(color.white, 10))
    dashboardCell(1, 2, str.tostring(displacementScore, "#.0") + "%", panelBg, bullDominant ? bullCore : bearCore)

    dashboardCell(0, 3, "Pressure RSI", panelBg, color.new(color.white, 10))
    dashboardCell(1, 3, str.tostring(pressureRsi, "#.0"), panelBg, bullPressure ? bullCore : bearPressure ? bearCore : color.white)

    dashboardCell(0, 4, "Spread ATR", panelBg, color.new(color.white, 10))
    dashboardCell(1, 4, str.tostring(spreadMagnitude, "#.0") + "%", panelBg, bullDominant ? bullCore : bearCore)

    dashboardCell(0, 5, "ATR Ratio", panelBg, color.new(color.white, 10))
    dashboardCell(1, 5, str.tostring(atrRatio, "#.0") + "%", panelBg, color.white)

    dashboardCell(0, 6, "Heat", panelBg, color.new(color.white, 10))
    dashboardCell(1, 6, str.tostring(heatNorm, "#.0") + "%", panelBg, bullDominant ? bullCore : bearCore)

    dashboardCell(0, 7, "Range", panelBg, color.new(color.white, 10))
    dashboardCell(1, 7, shiftActive ? str.tostring(shiftUpper - shiftLower, format.mintick) : "Inactive", panelBg, shiftColor)

    dashboardCell(0, 8, "Stretch ATR", panelBg, color.new(color.white, 10))
    dashboardCell(1, 8, str.tostring(shiftStretchAtr, "#.00"), panelBg, shiftStretchAtr >= 0 ? bullCore : bearCore)

    dashboardCell(0, 9, "Zone Dist ATR", panelBg, color.new(color.white, 10))
    dashboardCell(1, 9, shiftActive ? str.tostring(zoneDistanceAtr, "#.00") + " | " + zoneTag : "na", panelBg, shiftColor)

    dashboardCell(0, 10, "Press Delta", panelBg, color.new(color.white, 10))
    dashboardCell(1, 10, str.tostring(pressureDelta, "#.0"), panelBg, pressureDelta >= 0 ? bullCore : bearCore)

    dashboardCell(0, 11, "Comp Delta", panelBg, color.new(color.white, 10))
    dashboardCell(1, 11, str.tostring(compressionDelta, "#.0"), panelBg, compressionDelta >= 0 ? neutralCore : color.white)

    dashboardCell(0, 12, "Ribbon Bias", panelBg, color.new(color.white, 10))
    dashboardCell(1, 12, str.tostring(ribbonBias, "#.0"), panelBg, ribbonBias >= 0 ? bullCore : bearCore)

    dashboardCell(0, 13, "Disp Vel", panelBg, color.new(color.white, 10))
    dashboardCell(1, 13, str.tostring(displacementVelocity, "#.0"), panelBg, displacementVelocity >= 0 ? bullCore : bearCore)

    dashboardCell(0, 14, "Comp Vel", panelBg, color.new(color.white, 10))
    dashboardCell(1, 14, str.tostring(compressionVelocity, "#.0"), panelBg, compressionVelocity >= 0 ? neutralCore : color.white)

    dashboardCell(0, 15, "Eff / Range", panelBg, color.new(color.white, 10))
    dashboardCell(1, 15, str.tostring(travelEfficiency, "#.0") + "% | " + (shiftActive ? str.tostring(activeRangeAtr, "#.00") : "na"), panelBg, travelEfficiency >= 50 ? bullCore : bearCore)

    dashboardCell(0, 16, "Quality", panelBg, color.new(color.white, 10))
    dashboardCell(1, 16, str.tostring(qualityScore, "#.0") + "%", panelBg, qualityScore >= 50 ? bullCore : bearCore)

    dashboardCell(0, 17, "Persist / Age", panelBg, color.new(color.white, 10))
    dashboardCell(1, 17, str.tostring(statePersistence) + " | " + (shiftActive ? str.tostring(shiftAge) : "na"), panelBg, color.white)

//--------------------------------------------------------------------------------------------------
// Alerts
//--------------------------------------------------------------------------------------------------
bool confirmedCompression = barstate.isconfirmed and compressionState
bool confirmedBullShift = bullShift
bool confirmedBearShift = bearShift
bool confirmedBullPressure = barstate.isconfirmed and bullPressure and not bullShift
bool confirmedBearPressure = barstate.isconfirmed and bearPressure and not bearShift
bool confirmedRelease = barstate.isconfirmed and compressionVelocity < 0 and displacementVelocity > 0 and displacementScore >= displacementThreshold * 0.85
bool confirmedFade = barstate.isconfirmed and compressionState and travelEfficiency < 35 and math.abs(pressureDelta) < 5
bool confirmedBullQuality = barstate.isconfirmed and qualityScore >= 55 and netShift > 0
bool confirmedBearQuality = barstate.isconfirmed and qualityScore >= 55 and netShift < 0
bool confirmedRangeExpansion = barstate.isconfirmed and shiftActive and activeRangeAtr >= 1.0 and math.abs(ribbonBias) >= 20

alertcondition(confirmedCompression, "JOAT Shift Compression", "Compression Shift Index confirms a compression state.")
alertcondition(confirmedBullShift, "JOAT Shift Bull Displacement", "Compression Shift Index confirms a bullish displacement shift.")
alertcondition(confirmedBearShift, "JOAT Shift Bear Displacement", "Compression Shift Index confirms a bearish displacement shift.")
alertcondition(confirmedBullPressure, "JOAT Shift Bull Pressure", "Compression Shift Index confirms bullish pressure before displacement.")
alertcondition(confirmedBearPressure, "JOAT Shift Bear Pressure", "Compression Shift Index confirms bearish pressure before displacement.")
alertcondition(confirmedRelease, "JOAT Shift Release", "Compression Shift Index confirms a volatility release sequence.")
alertcondition(confirmedFade, "JOAT Shift Fade", "Compression Shift Index confirms a low-efficiency compression fade.")
alertcondition(confirmedBullQuality, "JOAT Shift Bull Quality", "Compression Shift Index confirms a high-quality bullish state.")
alertcondition(confirmedBearQuality, "JOAT Shift Bear Quality", "Compression Shift Index confirms a high-quality bearish state.")
alertcondition(confirmedRangeExpansion, "JOAT Shift Range Expansion", "Compression Shift Index confirms an expanding active shift range.")

plot(qualityScore, "Quality Score (Data Window)", color = qualityScore >= 50 ? bullCore : bearCore, display = display.data_window)
plot(activeRangeAtr, "Active Range ATR (Data Window)", color = shiftColor, display = display.data_window)
````
