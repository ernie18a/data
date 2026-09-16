<!-- tradingview-pine-id: PUB;b35e5bd1452e41ad821ca05a72743c37 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Cycle-Phase Liquidity Reversal Engine [PhenLabs]

Source: https://www.tradingview.com/script/VWCJiykV-Cycle-Phase-Liquidity-Reversal-Engine-PhenLabs/

## Description

📊 Cycle-Phase Liquidity Reversal Engine [PhenLabs]

Version: PineScript™ v6

📌 Description
The Cycle-Phase Liquidity Reversal Engine identifies liquidity sweeps that occur when price is stretched within its local cycle and beginning to rotate. Instead of treating every wick through a swing as a reversal, it qualifies the event with cyclical phase and an optional volume-absorption proxy.

A qualified sweep arms a setup rather than printing an immediate signal. Price must then confirm through the sweep candle within a user-defined window, helping separate genuine reclaims from unresolved stop runs. Confirmed setups receive risk-proportional entry, invalidation, and target projections.

🚀 Points of Innovation

[*]Combines confirmed swing-liquidity sweeps with normalized cyclical displacement.
[*]Uses cycle rotation to distinguish a stretched turning point from a sweep in active continuation.
[*]Adds a price-and-volume absorption proxy without requiring order-flow data.
[*]Separates setup qualification from structural confirmation.
[*]Projects two configurable R-multiple targets from the actual swept level.
[*]Summarizes phase, relative volume, setup state, and signal bias in a live dashboard.

🔧 Core Components

[*]Liquidity structure engine: confirms pivot highs and lows, then monitors those levels for wick-through-and-reclaim behavior.
[*]Cycle phase model: detrends price with an EMA and normalizes displacement as a rolling z-score.
[*]Absorption gate: identifies elevated relative volume paired with a compressed candle body.
[*]Confirmation engine: requires a close through the qualified sweep candle before releasing a signal.
[*]Projection model: anchors invalidation beyond the swept level and derives targets from the resulting risk distance.

🔥 Key Features

[*]Non-lookahead pivot structure with confirmed-bar sweep detection.
[*]Balanced and Strict qualification modes for flexible signal density.
[*]Optional EMA context filter for directional alignment.
[*]Active buy-side and sell-side liquidity plots.
[*]Qualified-sweep markers plus distinct confirmed-reversal signals.
[*]Bullish and bearish alert conditions for automation-ready monitoring.

🎨 Visualization

[*]Muted horizontal liquidity lines show the latest confirmed swing high and swing low.
[*]Small circles identify qualified sweeps; triangles identify fully confirmed reversals.
[*]Dotted entry and invalidation projections separate execution levels from structure.
[*]Dashed Target 1 and Target 2 lines show configurable reward multiples.
[*]The top-right dashboard displays cycle z-score, phase, relative volume, absorption state, armed setup, and last signal bias.

📖 Usage Guidelines

[*]Pivot Strength — Default: 5 — Range: 2-25 — Increase for higher-timeframe structure and fewer liquidity levels; reduce for more reactive intraday swings.
[*]Confirmation Window — Default: 4 — Range: 1-20 — Sets how long price has to confirm through the sweep candle.
[*]Cycle Length — Default: 34 — Range: 10-100 — Controls the detrending and normalization horizon.
[*]Phase Stretch Threshold — Default: 0.85 — Range: 0.25-3.00 — Higher values demand more extreme cyclical displacement.
[*]Qualification Mode — Default: Balanced — Options: Balanced or Strict — Balanced accepts phase rotation or absorption; Strict requires both.
[*]Relative Volume Length — Default: 20 — Range: 5-100 — Sets the baseline used for the volume comparison.
[*]Minimum Relative Volume — Default: 1.20 — Range: 0.50-5.00 — Raises or lowers the activity required by the absorption proxy.
[*]Maximum Body / Range — Default: 0.45 — Range: 0.10-0.90 — Lower values require stronger rejection and compression.
[*]EMA Context Filter — Default: Off — When enabled, bullish confirmations must close above the EMA and bearish confirmations below it.
[*]Stop Buffer — Default: 0.20 ATR — Range: 0.00-2.00 — Adds volatility-adjusted space beyond the swept level.
[*]Target 1 — Default: 1.00R — Range: 0.50-5.00R — Sets the first projected objective.
[*]Target 2 — Default: 2.00R — Range: 1.00-10.00R — Sets the extended projected objective.

✅ Best Use Cases

[*]Intraday liquidity reclaims around established swing highs and lows.
[*]Index, futures, FX, and liquid crypto markets with reliable volume behavior.
[*]Reversal confirmation after stop runs at session or local structural extremes.
[*]Confluence with session levels, higher-timeframe bias, or independent market structure.

⚠️ Limitations

[*]Confirmed pivots appear only after the right-side pivot bars have elapsed.
[*]The volume gate uses chart volume and is not a substitute for exchange-level order flow.
[*]Cycle behavior is unstable during one-directional expansion and news-driven repricing.
[*]Projected levels are analytical references, not guaranteed fills or outcomes.

💡 What Makes This Unique

[*]Temporal liquidity qualification: the engine evaluates where a sweep occurs within a normalized local price cycle.
[*]Two-stage signal design: a sweep must first qualify and then earn confirmation through subsequent price structure.
[*]Risk geometry: targets adapt to the distance between confirmation and the swept liquidity level rather than using arbitrary fixed offsets.

🔬 How It Works

[*]Confirmed pivots establish the current buy-side and sell-side liquidity references.
[*]A wick through a reference followed by a close back across it registers a sweep.
[*]The sweep is qualified by cycle stretch and rotation, volume absorption, or both, depending on the selected mode.
[*]The setup remains armed for the chosen confirmation window.
[*]A close through the sweep candle confirms the reversal and releases the signal.
[*]The script places invalidation beyond the swept level and projects two R-multiple targets.

💡 Note:
Use the dashboard to distinguish a developing qualification from a confirmed setup. Start with Balanced mode, then move to Strict mode when the symbol provides dependable volume and you want fewer signals. Combine the engine with independent context and test settings on each market and timeframe. This tool is an analytical aid and is not financial advice.

---

## Source Code

````pine
//@version=6
indicator("Cycle-Phase Liquidity Reversal Engine [PhenLabs]", shorttitle="CPLRE", overlay=true, max_lines_count=100, max_labels_count=50)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
groupStructure = "Liquidity Structure"
pivotLen = input.int(5, "Pivot Strength", minval=2, maxval=25, group=groupStructure, tooltip="Bars on each side required to confirm a swing liquidity level.")
confirmBars = input.int(4, "Confirmation Window", minval=1, maxval=20, group=groupStructure, tooltip="Bars allowed after a qualified sweep for price to confirm through the sweep candle.")
showLevels = input.bool(true, "Show Active Liquidity", group=groupStructure, tooltip="Plots the latest confirmed swing high and swing low.")

groupCycle = "Cycle Phase"
cycleLen = input.int(34, "Cycle Length", minval=10, maxval=100, group=groupCycle, tooltip="Lookback used to detrend price and normalize cyclical displacement.")
phaseThreshold = input.float(0.85, "Phase Stretch Threshold", minval=0.25, maxval=3.00, step=0.05, group=groupCycle, tooltip="Required absolute cycle z-score at the sweep. Higher values produce fewer, more stretched setups.")

groupAbsorption = "Absorption Gate"
gateMode = input.string("Balanced", "Qualification Mode", options=["Balanced", "Strict"], group=groupAbsorption, tooltip="Balanced accepts phase rotation or absorption. Strict requires both.")
volumeLen = input.int(20, "Relative Volume Length", minval=5, maxval=100, group=groupAbsorption)
minRelVolume = input.float(1.20, "Minimum Relative Volume", minval=0.50, maxval=5.00, step=0.05, group=groupAbsorption)
maxBodyFraction = input.float(0.45, "Maximum Body / Range", minval=0.10, maxval=0.90, step=0.05, group=groupAbsorption, tooltip="Small candle bodies on elevated volume are treated as an absorption proxy.")

groupTrend = "Context Filter"
useTrendFilter = input.bool(false, "Use EMA Context Filter", group=groupTrend, tooltip="Requires bullish confirmations above the EMA and bearish confirmations below it.")
trendLen = input.int(100, "EMA Length", minval=20, maxval=300, group=groupTrend)

groupRisk = "Projection & Risk"
atrLen = input.int(14, "ATR Length", minval=5, maxval=50, group=groupRisk)
stopBuffer = input.float(0.20, "Stop Buffer (ATR)", minval=0.00, maxval=2.00, step=0.05, group=groupRisk)
targetOneRR = input.float(1.00, "Target 1 (R)", minval=0.50, maxval=5.00, step=0.25, group=groupRisk)
targetTwoRR = input.float(2.00, "Target 2 (R)", minval=1.00, maxval=10.00, step=0.25, group=groupRisk)
projectionBars = input.int(40, "Projection Length", minval=10, maxval=200, group=groupRisk)

groupVisual = "Visuals"
bullColor = input.color(#00D6A3, "Bullish Color", group=groupVisual)
bearColor = input.color(#FF4D7D, "Bearish Color", group=groupVisual)
neutralColor = input.color(#8A93A6, "Neutral Color", group=groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group=groupVisual)

// ─────────────────────────────────────────────────────────────────────────────
// Structure and cycle state
// ─────────────────────────────────────────────────────────────────────────────
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow = na
var int lastSwingHighBar = na
var int lastSwingLowBar = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh
    lastSwingHighBar := bar_index - pivotLen

if not na(pivotLow)
    lastSwingLow := pivotLow
    lastSwingLowBar := bar_index - pivotLen

cycleBasis = ta.ema(close, cycleLen)
cycleValue = close - cycleBasis
cycleMean = ta.sma(cycleValue, cycleLen)
cycleDeviation = ta.stdev(cycleValue, cycleLen)
cycleZ = not na(cycleDeviation) and cycleDeviation > 0.0 ? (cycleValue - cycleMean) / cycleDeviation : 0.0
cycleDelta = ta.change(cycleValue)

bullPhase = cycleZ <= -phaseThreshold and not na(cycleDelta) and cycleDelta > 0.0
bearPhase = cycleZ >= phaseThreshold and not na(cycleDelta) and cycleDelta < 0.0

averageVolume = ta.sma(volume, volumeLen)
relativeVolume = not na(averageVolume) and averageVolume > 0.0 ? volume / averageVolume : 0.0
candleSpan = math.max(high - low, syminfo.mintick)
bodyFraction = math.abs(close - open) / candleSpan
absorption = relativeVolume >= minRelVolume and bodyFraction <= maxBodyFraction

atrValue = ta.atr(atrLen)
trendEMA = ta.ema(close, trendLen)

bullSweep = barstate.isconfirmed and not na(lastSwingLow) and not na(lastSwingLowBar) and bar_index > lastSwingLowBar and low < lastSwingLow and close > lastSwingLow
bearSweep = barstate.isconfirmed and not na(lastSwingHigh) and not na(lastSwingHighBar) and bar_index > lastSwingHighBar and high > lastSwingHigh and close < lastSwingHigh

bullGate = gateMode == "Strict" ? bullPhase and absorption : bullPhase or absorption
bearGate = gateMode == "Strict" ? bearPhase and absorption : bearPhase or absorption

// ─────────────────────────────────────────────────────────────────────────────
// Arm qualified sweeps, then require structural confirmation
// ─────────────────────────────────────────────────────────────────────────────
var bool bullArmed = false
var bool bearArmed = false
var int bullArmedBar = na
var int bearArmedBar = na
var int bullExpiryBar = na
var int bearExpiryBar = na
var float bullConfirmLevel = na
var float bearConfirmLevel = na
var float bullSweptLevel = na
var float bearSweptLevel = na
var int consumedLowBar = na
var int consumedHighBar = na

// Clear stale setups before evaluating this bar for a fresh sweep.
if bullArmed and not na(bullExpiryBar) and bar_index > bullExpiryBar
    bullArmed := false

if bearArmed and not na(bearExpiryBar) and bar_index > bearExpiryBar
    bearArmed := false

// A pivot can seed only one setup. Detect two-sided ambiguity before applying
// armed-state gates so an outside bar cannot reverse an existing setup.
bullEligible = bullSweep and bullGate and (na(consumedLowBar) or lastSwingLowBar != consumedLowBar)
bearEligible = bearSweep and bearGate and (na(consumedHighBar) or lastSwingHighBar != consumedHighBar)
dualSweep = bullEligible and bearEligible
acceptBullSweep = bullEligible and not dualSweep and not bullArmed
acceptBearSweep = bearEligible and not dualSweep and not bearArmed

if acceptBullSweep
    bullArmed := true
    bearArmed := false
    bullArmedBar := bar_index
    bullExpiryBar := bar_index + confirmBars
    bullConfirmLevel := high
    bullSweptLevel := lastSwingLow
    consumedLowBar := lastSwingLowBar

if acceptBearSweep
    bearArmed := true
    bullArmed := false
    bearArmedBar := bar_index
    bearExpiryBar := bar_index + confirmBars
    bearConfirmLevel := low
    bearSweptLevel := lastSwingHigh
    consumedHighBar := lastSwingHighBar

bullTrendOK = not useTrendFilter or close >= trendEMA
bearTrendOK = not useTrendFilter or close <= trendEMA

bullSignal = barstate.isconfirmed and not na(atrValue) and bullArmed and not na(bullArmedBar) and not na(bullConfirmLevel) and bar_index > bullArmedBar and close > bullConfirmLevel and bullTrendOK
bearSignal = barstate.isconfirmed and not na(atrValue) and bearArmed and not na(bearArmedBar) and not na(bearConfirmLevel) and bar_index > bearArmedBar and close < bearConfirmLevel and bearTrendOK

if bullSignal
    bullArmed := false

if bearSignal
    bearArmed := false

// ─────────────────────────────────────────────────────────────────────────────
// Signal projections
// ─────────────────────────────────────────────────────────────────────────────
var line entryLine = na
var line stopLine = na
var line targetOneLine = na
var line targetTwoLine = na
var int lastSignalBias = 0
var float activeEntry = na
var float activeStop = na
var float activeTargetOne = na
var float activeTargetTwo = na

if bullSignal and not na(atrValue) and not na(bullSweptLevel)
    activeEntry := close
    activeStop := bullSweptLevel - atrValue * stopBuffer
    float bullRisk = math.max(activeEntry - activeStop, syminfo.mintick)
    activeTargetOne := activeEntry + bullRisk * targetOneRR
    activeTargetTwo := activeEntry + bullRisk * targetTwoRR
    lastSignalBias := 1
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(targetOneLine)
        line.delete(targetOneLine)
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
    entryLine := line.new(bar_index, activeEntry, bar_index + projectionBars, activeEntry, color=color.new(bullColor, 20), style=line.style_dotted, width=1)
    stopLine := line.new(bar_index, activeStop, bar_index + projectionBars, activeStop, color=color.new(bearColor, 20), style=line.style_dotted, width=1)
    targetOneLine := line.new(bar_index, activeTargetOne, bar_index + projectionBars, activeTargetOne, color=color.new(bullColor, 20), style=line.style_dashed, width=1)
    targetTwoLine := line.new(bar_index, activeTargetTwo, bar_index + projectionBars, activeTargetTwo, color=bullColor, style=line.style_dashed, width=2)

if bearSignal and not na(atrValue) and not na(bearSweptLevel)
    activeEntry := close
    activeStop := bearSweptLevel + atrValue * stopBuffer
    float bearRisk = math.max(activeStop - activeEntry, syminfo.mintick)
    activeTargetOne := activeEntry - bearRisk * targetOneRR
    activeTargetTwo := activeEntry - bearRisk * targetTwoRR
    lastSignalBias := -1
    if not na(entryLine)
        line.delete(entryLine)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(targetOneLine)
        line.delete(targetOneLine)
    if not na(targetTwoLine)
        line.delete(targetTwoLine)
    entryLine := line.new(bar_index, activeEntry, bar_index + projectionBars, activeEntry, color=color.new(bearColor, 20), style=line.style_dotted, width=1)
    stopLine := line.new(bar_index, activeStop, bar_index + projectionBars, activeStop, color=color.new(bullColor, 20), style=line.style_dotted, width=1)
    targetOneLine := line.new(bar_index, activeTargetOne, bar_index + projectionBars, activeTargetOne, color=color.new(bearColor, 20), style=line.style_dashed, width=1)
    targetTwoLine := line.new(bar_index, activeTargetTwo, bar_index + projectionBars, activeTargetTwo, color=bearColor, style=line.style_dashed, width=2)

// ─────────────────────────────────────────────────────────────────────────────
// Chart visuals
// ─────────────────────────────────────────────────────────────────────────────
plot(showLevels ? lastSwingHigh : na, "Buy-Side Liquidity", color=color.new(bearColor, 45), linewidth=1, style=plot.style_linebr)
plot(showLevels ? lastSwingLow : na, "Sell-Side Liquidity", color=color.new(bullColor, 45), linewidth=1, style=plot.style_linebr)
plot(useTrendFilter ? trendEMA : na, "Context EMA", color=color.new(neutralColor, 35), linewidth=1)

plotshape(acceptBullSweep, title="Qualified Bullish Sweep", style=shape.circle, location=location.belowbar, color=color.new(bullColor, 35), size=size.tiny)
plotshape(acceptBearSweep, title="Qualified Bearish Sweep", style=shape.circle, location=location.abovebar, color=color.new(bearColor, 35), size=size.tiny)
plotshape(bullSignal, title="Bullish Phase-Locked Reversal", style=shape.triangleup, location=location.belowbar, color=bullColor, size=size.small, text="CPL")
plotshape(bearSignal, title="Bearish Phase-Locked Reversal", style=shape.triangledown, location=location.abovebar, color=bearColor, size=size.small, text="CPL")

barcolor(acceptBullSweep ? color.new(bullColor, 45) : acceptBearSweep ? color.new(bearColor, 45) : na)

// ─────────────────────────────────────────────────────────────────────────────
// Live dashboard
// ─────────────────────────────────────────────────────────────────────────────
var table dashboard = table.new(position.top_right, 2, 7, border_width=1)

if barstate.islast and showDashboard
    color headerColor = color.new(#151A24, 0)
    color panelColor = color.new(#202633, 10)
    color cycleColor = cycleZ <= -phaseThreshold ? bullColor : cycleZ >= phaseThreshold ? bearColor : neutralColor
    string phaseText = bullPhase ? "LOW → TURN" : bearPhase ? "HIGH → TURN" : cycleZ < 0.0 ? "LOW HALF" : "HIGH HALF"
    string volumeText = str.tostring(relativeVolume, "#.##") + "x"
    string gateText = absorption ? "ABSORBING" : "NORMAL"
    string setupText = bullArmed ? "BULL ARMED" : bearArmed ? "BEAR ARMED" : "SCANNING"
    color setupColor = bullArmed ? bullColor : bearArmed ? bearColor : neutralColor
    string biasText = lastSignalBias == 1 ? "LAST: BULL" : lastSignalBias == -1 ? "LAST: BEAR" : "NONE"
    color biasColor = lastSignalBias == 1 ? bullColor : lastSignalBias == -1 ? bearColor : neutralColor
    table.cell(dashboard, 0, 0, "CPLRE", text_color=color.white, bgcolor=headerColor)
    table.cell(dashboard, 1, 0, "PHENLABS", text_color=color.white, bgcolor=headerColor)
    table.cell(dashboard, 0, 1, "Cycle Z", text_color=color.white, bgcolor=panelColor)
    table.cell(dashboard, 1, 1, str.tostring(cycleZ, "#.##"), text_color=cycleColor, bgcolor=panelColor)
    table.cell(dashboard, 0, 2, "Phase", text_color=color.white, bgcolor=panelColor)
    table.cell(dashboard, 1, 2, phaseText, text_color=cycleColor, bgcolor=panelColor)
    table.cell(dashboard, 0, 3, "Rel. Volume", text_color=color.white, bgcolor=panelColor)
    table.cell(dashboard, 1, 3, volumeText, text_color=relativeVolume >= minRelVolume ? bullColor : neutralColor, bgcolor=panelColor)
    table.cell(dashboard, 0, 4, "Flow Gate", text_color=color.white, bgcolor=panelColor)
    table.cell(dashboard, 1, 4, gateText, text_color=absorption ? bullColor : neutralColor, bgcolor=panelColor)
    table.cell(dashboard, 0, 5, "Setup", text_color=color.white, bgcolor=panelColor)
    table.cell(dashboard, 1, 5, setupText, text_color=setupColor, bgcolor=panelColor)
    table.cell(dashboard, 0, 6, "Signal Bias", text_color=color.white, bgcolor=panelColor)
    table.cell(dashboard, 1, 6, biasText, text_color=biasColor, bgcolor=panelColor)

if barstate.islast and not showDashboard
    table.clear(dashboard, 0, 0, 1, 6)

// ─────────────────────────────────────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(bullSignal, title="CPLRE Bullish Reversal", message="Cycle-Phase Liquidity Reversal Engine confirmed a bullish reversal on {{ticker}} {{interval}}.")
alertcondition(bearSignal, title="CPLRE Bearish Reversal", message="Cycle-Phase Liquidity Reversal Engine confirmed a bearish reversal on {{ticker}} {{interval}}.")
````
