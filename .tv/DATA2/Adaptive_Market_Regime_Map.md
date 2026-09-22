<!-- tradingview-pine-id: PUB;fd4122ee062f437d96fd333057554779 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Market Regime Map

Source: https://www.tradingview.com/script/yTPFjW2W-Adaptive-Market-Regime-Map/

## Description

Adaptive Market Regime Map is a chart-overlay context tool that separates directional conditions from volatility conditions. It is designed to help traders describe the current market environment without presenting buy or sell signals.

WHAT IT SHOWS

The indicator organizes market context into two layers:

• Directional regime: Bullish, Bearish, or Neutral
• Volatility state: Compressed, Normal, or Expanding

A layered corridor is plotted around an adaptive equilibrium line. Its width responds to ATR, while its color and intensity reflect the current directional regime and measured trend strength.

In bullish conditions, the lower half of the corridor is emphasized as support context. In bearish conditions, the upper half is emphasized as resistance context. These areas are descriptive context zones, not fixed support or resistance levels and not trade-entry signals.

HOW IT WORKS

The directional engine combines:

• the distance between a fast EMA and the equilibrium EMA, normalized by ATR;
• the slope of the equilibrium EMA, also normalized by ATR;
• path efficiency, calculated from net movement relative to total movement over the selected window.

The resulting directional score is bounded and compared with the Trend Threshold to classify the market as Bullish, Bearish, or Neutral.

The volatility engine compares current ATR with a moving baseline of ATR:

• below the Compression Ratio: Compressed
• above the Expansion Ratio: Expanding
• between both thresholds: Normal

The dashboard displays the current regime, normalized strength, volatility state, and the number of bars spent in the current directional regime.

HOW TO USE IT

Use the map as a context filter alongside your own analysis:

• Bullish indicates persistent positive directional structure.
• Bearish indicates persistent negative directional structure.
• Neutral indicates that directional strength is below the selected threshold.
• Compressed indicates volatility below its recent baseline.
• Expanding indicates volatility above its recent baseline.

The corridor can also provide visual context around the equilibrium line. Price moving outside the corridor does not, by itself, constitute a breakout or reversal signal.

INPUTS

Regime Engine

• Fast Length: Period of the faster EMA used in directional separation.
• Equilibrium Length: Period of the central EMA used for the corridor.
• Slope Lookback: Bars used to measure the equilibrium slope.
• Efficiency Length: Window used to compare net movement with total path movement.
• ATR Length: ATR period used for normalization and corridor width.
• Volatility Baseline: Window used for the rolling ATR baseline.
• Spread Weight and Slope Weight: Relative contribution of both directional components.

Classification

• Trend Threshold: Minimum absolute directional score required for a bullish or bearish regime.
• Compression Ratio: ATR-to-baseline ratio below which volatility is classified as compressed.
• Expansion Ratio: ATR-to-baseline ratio above which volatility is classified as expanding.

Regime Corridor

• Inner Zone ATR and Outer Zone ATR: Width of the two corridor layers.
• Show Outer Context Zone: Displays or hides the lighter outer layer.
• Show Equilibrium Line: Displays or hides the central line.
• Color Transition Bars: Controls how quickly a new regime color reaches full intensity. This affects presentation only.
• Tint Candles By Regime and Tint Chart Background: Optional visual context, disabled by default.

State Changes

• Label Confirmation Bars: Number of persistent state bars required before a label is displayed.
• Same-Label Minimum Distance: Minimum distance between labels of the same type.
• Neutral labels are optional and disabled by default.

ALERTS

The script provides five alert conditions:

• Market Regime Changed
• Bullish Regime Started
• Bearish Regime Started
• Compression Started
• Expansion Started

Alerts are confirmed on bar close by default. Label confirmation is separate from alert timing, so the optional label delay does not delay the corresponding regime alert.

REALTIME AND REPAINTING BEHAVIOR

The script does not use higher-timeframe requests, future data, offsets into the future, or lookahead logic. Historical classifications are calculated from information available on each bar.

On an open realtime bar, price, ATR, the corridor, and the displayed regime can change as new ticks arrive. With Confirm Alerts On Bar Close enabled, alerts trigger only after the bar is confirmed. This is the recommended setting for stable alert behavior.

LIMITATIONS

• This is an indicator, not a strategy or automated trading system.
• It does not predict future price movement.
• Bullish and bearish states are contextual classifications, not trade recommendations.
• The corridor provides volatility-scaled context and does not define fixed support or resistance levels.
• Results depend on symbol, timeframe, data quality, and selected parameters.
• Very short history can produce a warmup state until all calculations are available.
• Non-standard chart types use synthetic chart prices and may behave differently from standard OHLC charts.

ORIGINALITY

This script is an original implementation. Its distinctive contribution is the combination of an ATR-normalized directional engine, path-efficiency weighting, separate volatility classification, asymmetric regime-context zones, and a compact state dashboard in one causal chart overlay.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Horizon Algo
// Version 1.0

//@version=6
indicator("Adaptive Market Regime Map", shorttitle = "Regime Map", overlay = true, max_labels_count = 100, explicit_plot_zorder = true)

//------------------------------------------------------------------------------
// Groups
//------------------------------------------------------------------------------
string GROUP_ENGINE = "Regime Engine"
string GROUP_THRESHOLDS = "Classification"
string GROUP_CORRIDOR = "Regime Corridor"
string GROUP_SIGNALS = "State Changes"
string GROUP_DASHBOARD = "Dashboard"
string GROUP_ALERTS = "Alerts"

//------------------------------------------------------------------------------
// Engine inputs
//------------------------------------------------------------------------------
source = input.source(close, "Source", group = GROUP_ENGINE, display = display.data_window)
fastLength = input.int(21, "Fast Length", minval = 2, group = GROUP_ENGINE, display = display.data_window)
slowLength = input.int(55, "Equilibrium Length", minval = 3, group = GROUP_ENGINE, display = display.data_window)
slopeLength = input.int(8, "Slope Lookback", minval = 1, group = GROUP_ENGINE, display = display.data_window)
efficiencyLength = input.int(20, "Efficiency Length", minval = 2, group = GROUP_ENGINE, display = display.data_window)
atrLength = input.int(14, "ATR Length", minval = 1, group = GROUP_ENGINE, display = display.data_window)
volatilityBaselineLength = input.int(100, "Volatility Baseline", minval = 20, group = GROUP_ENGINE, display = display.data_window)
spreadWeight = input.float(1.60, "Spread Weight", minval = 0.0, step = 0.05, group = GROUP_ENGINE, display = display.data_window)
slopeWeight = input.float(1.10, "Slope Weight", minval = 0.0, step = 0.05, group = GROUP_ENGINE, display = display.data_window)

trendThreshold = input.float(27.0, "Trend Threshold", minval = 5.0, maxval = 80.0, step = 0.5, group = GROUP_THRESHOLDS, display = display.data_window)
compressionRatio = input.float(0.78, "Compression Ratio", minval = 0.20, maxval = 1.00, step = 0.01, group = GROUP_THRESHOLDS, display = display.data_window)
expansionRatio = input.float(1.25, "Expansion Ratio", minval = 1.00, maxval = 3.00, step = 0.01, group = GROUP_THRESHOLDS, display = display.data_window)

//------------------------------------------------------------------------------
// Original Horizon visual system
//------------------------------------------------------------------------------
bullColor = input.color(#17C3A2, "Bullish", group = GROUP_CORRIDOR, display = display.data_window)
bearColor = input.color(#FF5D70, "Bearish", group = GROUP_CORRIDOR, display = display.data_window)
neutralColor = input.color(#8B98AA, "Neutral", group = GROUP_CORRIDOR, display = display.data_window)
compressionColor = input.color(#F2A93B, "Compression", group = GROUP_CORRIDOR, display = display.data_window)
expansionColor = input.color(#4C8DFF, "Expansion", group = GROUP_CORRIDOR, display = display.data_window)
innerAtr = input.float(0.65, "Inner Zone ATR", minval = 0.10, step = 0.05, group = GROUP_CORRIDOR, display = display.data_window)
outerAtr = input.float(1.35, "Outer Zone ATR", minval = 0.20, step = 0.05, group = GROUP_CORRIDOR, display = display.data_window)
showOuterZone = input.bool(true, "Show Outer Context Zone", group = GROUP_CORRIDOR, display = display.data_window)
showEquilibrium = input.bool(true, "Show Equilibrium Line", group = GROUP_CORRIDOR, display = display.data_window)
transitionFadeBars = input.int(3, "Color Transition Bars", minval = 1, maxval = 10, group = GROUP_CORRIDOR, tooltip = "Fades a new regime color in over this many bars without changing the underlying classification.", display = display.data_window)
colorCandles = input.bool(false, "Tint Candles By Regime", group = GROUP_CORRIDOR, display = display.data_window)
showChartTint = input.bool(false, "Tint Chart Background", group = GROUP_CORRIDOR, display = display.data_window)
chartTintTransparency = input.int(97, "Chart Tint Transparency", minval = 92, maxval = 100, group = GROUP_CORRIDOR, display = display.data_window)

showStateLabels = input.bool(true, "Show Bullish/Bearish Changes", group = GROUP_SIGNALS, display = display.data_window)
showNeutralChanges = input.bool(false, "Show Neutral Changes", group = GROUP_SIGNALS, display = display.data_window)
labelDistanceAtr = input.float(0.30, "Label Distance ATR", minval = 0.0, step = 0.05, group = GROUP_SIGNALS, display = display.data_window)
labelConfirmationBars = input.int(2, "Label Confirmation Bars", minval = 1, maxval = 5, group = GROUP_SIGNALS, tooltip = "A state must persist for this many bars before a label is printed. This affects labels only, not the corridor classification.", display = display.data_window)
sameLabelCooldown = input.int(12, "Same-Label Minimum Distance", minval = 0, maxval = 100, group = GROUP_SIGNALS, tooltip = "Minimum bars between two labels of the same type.", display = display.data_window)

showDashboard = input.bool(true, "Show Dashboard", group = GROUP_DASHBOARD, display = display.data_window)
dashboardPosition = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GROUP_DASHBOARD, display = display.data_window)

confirmAlertsOnClose = input.bool(true, "Confirm Alerts On Bar Close", group = GROUP_ALERTS, display = display.data_window)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_squash(float value) =>
    100.0 * value / (1.0 + math.abs(value))

f_dashboardPosition(string setting) =>
    switch setting
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

//------------------------------------------------------------------------------
// Causal regime engine
//------------------------------------------------------------------------------
fastEma = ta.ema(source, fastLength)
equilibrium = ta.ema(source, slowLength)
atrValue = ta.atr(atrLength)
atrSafe = math.max(atrValue, syminfo.mintick)
atrBaseline = ta.sma(atrValue, volatilityBaselineLength)

emaSpreadNormalized = (fastEma - equilibrium) / atrSafe
slopeNormalized = (equilibrium - equilibrium[slopeLength]) / atrSafe
directionalRaw = emaSpreadNormalized * spreadWeight + slopeNormalized * slopeWeight
directionalScore = f_squash(directionalRaw)

pathTraveled = math.sum(math.abs(ta.change(source)), efficiencyLength)
netMovement = math.abs(source - source[efficiencyLength])
efficiency = pathTraveled > 0.0 ? f_clamp(netMovement / pathTraveled, 0.0, 1.0) : 0.0
trendScore = f_clamp(directionalScore * efficiency, -100.0, 100.0)
volatilityRatio = atrBaseline > 0.0 ? atrValue / atrBaseline : 1.0

warmupBars = math.max(math.max(slowLength + slopeLength, efficiencyLength + 1), volatilityBaselineLength + atrLength)
ready = bar_index >= warmupBars and not na(trendScore) and not na(volatilityRatio)

int directionState = ready ? trendScore >= trendThreshold ? 1 : trendScore <= -trendThreshold ? -1 : 0 : 0
int previousDirectionState = nz(directionState[1], directionState)
directionChanged = ready and directionState != previousDirectionState
isCompression = ready and volatilityRatio <= compressionRatio
isExpansion = ready and volatilityRatio >= expansionRatio

var int regimeBars = 0
regimeBars := not ready ? 0 : directionChanged ? 1 : regimeBars + 1

regimeText = directionState == 1 ? "BULLISH" : directionState == -1 ? "BEARISH" : ready ? "NEUTRAL" : "WARMUP"
volatilityText = isCompression ? "COMPRESSED" : isExpansion ? "EXPANDING" : ready ? "NORMAL" : "WARMUP"
baseRegimeColor = directionState == 1 ? bullColor : directionState == -1 ? bearColor : neutralColor
volatilityColor = isCompression ? compressionColor : isExpansion ? expansionColor : neutralColor
trendStrength = ready ? f_clamp(math.abs(trendScore) / trendThreshold * 50.0, 0.0, 100.0) : 0.0
strengthText = trendStrength >= 75.0 ? "STRONG" : trendStrength >= 45.0 ? "DEVELOPING" : "QUIET"

// Color intensity reflects measured trend strength. New states fade in visually
// over a few bars while the causal regime classification itself remains unchanged.
fadeProgress = ready ? f_clamp(regimeBars / transitionFadeBars, 0.0, 1.0) : 0.0
targetSoftColor = color.from_gradient(trendStrength, 0.0, 100.0, color.new(baseRegimeColor, 62), color.new(baseRegimeColor, 12))
targetCoreColor = color.from_gradient(trendStrength, 0.0, 100.0, color.new(baseRegimeColor, 28), baseRegimeColor)
softRegimeColor = color.from_gradient(fadeProgress, 0.0, 1.0, color.new(neutralColor, 70), targetSoftColor)
coreRegimeColor = color.from_gradient(fadeProgress, 0.0, 1.0, color.new(neutralColor, 42), targetCoreColor)

//------------------------------------------------------------------------------
// Layered regime corridor
//------------------------------------------------------------------------------
innerUpper = equilibrium + atrValue * innerAtr
innerLower = equilibrium - atrValue * innerAtr
outerUpper = equilibrium + atrValue * outerAtr
outerLower = equilibrium - atrValue * outerAtr

outerUpperPlot = plot(ready and showOuterZone ? outerUpper : na, "Outer Upper", color = color.new(softRegimeColor, 86), linewidth = 1, display = display.all - display.status_line - display.price_scale)
innerUpperPlot = plot(ready ? innerUpper : na, "Inner Upper", color = color.new(coreRegimeColor, 58), linewidth = 1, display = display.all - display.status_line - display.price_scale)
equilibriumAnchor = plot(ready ? equilibrium : na, "Equilibrium Fill Anchor", color = color.new(coreRegimeColor, 100), display = display.none)
innerLowerPlot = plot(ready ? innerLower : na, "Inner Lower", color = color.new(coreRegimeColor, 58), linewidth = 1, display = display.all - display.status_line - display.price_scale)
outerLowerPlot = plot(ready and showOuterZone ? outerLower : na, "Outer Lower", color = color.new(softRegimeColor, 86), linewidth = 1, display = display.all - display.status_line - display.price_scale)

// In bullish regimes the lower half acts as the stronger support-context zone.
// In bearish regimes the upper half acts as the stronger resistance-context zone.
upperActiveTransparency = directionState == -1 ? 77 : directionState == 1 ? 91 : 86
lowerActiveTransparency = directionState == 1 ? 77 : directionState == -1 ? 91 : 86

fill(outerUpperPlot, innerUpperPlot, color = showOuterZone ? color.new(softRegimeColor, 94) : na, title = "Upper Context Layer")
fill(innerUpperPlot, equilibriumAnchor, color = color.new(softRegimeColor, upperActiveTransparency), title = "Resistance Context")
fill(equilibriumAnchor, innerLowerPlot, color = color.new(softRegimeColor, lowerActiveTransparency), title = "Support Context")
fill(innerLowerPlot, outerLowerPlot, color = showOuterZone ? color.new(softRegimeColor, 94) : na, title = "Lower Context Layer")

plot(ready and showEquilibrium ? equilibrium : na, "Equilibrium", color = color.new(coreRegimeColor, 4), linewidth = 2, display = display.all - display.status_line - display.price_scale)

barcolor(colorCandles and ready ? color.new(coreRegimeColor, 28) : na, title = "Regime Candles")
bgcolor(showChartTint and ready ? color.new(baseRegimeColor, chartTintTransparency) : na, title = "Regime Background")

//------------------------------------------------------------------------------
// Sparse state-change labels
//------------------------------------------------------------------------------
candidateConfirmed = ready and regimeBars >= labelConfirmationBars
bullishStarted = candidateConfirmed and directionState == 1 and directionState[labelConfirmationBars] != 1
bearishStarted = candidateConfirmed and directionState == -1 and directionState[labelConfirmationBars] != -1
neutralStarted = candidateConfirmed and directionState == 0 and directionState[labelConfirmationBars] != 0

var int lastBullishLabelBar = na
var int lastBearishLabelBar = na
var int lastNeutralLabelBar = na

bullishLabelAllowed = bullishStarted and (na(lastBullishLabelBar) or bar_index - lastBullishLabelBar >= sameLabelCooldown)
bearishLabelAllowed = bearishStarted and (na(lastBearishLabelBar) or bar_index - lastBearishLabelBar >= sameLabelCooldown)
neutralLabelAllowed = neutralStarted and (na(lastNeutralLabelBar) or bar_index - lastNeutralLabelBar >= sameLabelCooldown)

if showStateLabels and bullishLabelAllowed
    label.new(bar_index, outerLower - atrValue * labelDistanceAtr, "BULL", style = label.style_label_up, color = color.new(bullColor, 12), textcolor = color.white, size = size.tiny, tooltip = "Confirmed bullish market regime")
    lastBullishLabelBar := bar_index

if showStateLabels and bearishLabelAllowed
    label.new(bar_index, outerUpper + atrValue * labelDistanceAtr, "BEAR", style = label.style_label_down, color = color.new(bearColor, 12), textcolor = color.white, size = size.tiny, tooltip = "Confirmed bearish market regime")
    lastBearishLabelBar := bar_index

if showNeutralChanges and neutralLabelAllowed
    label.new(bar_index, equilibrium, "NEUTRAL", style = label.style_label_left, color = color.new(neutralColor, 32), textcolor = color.white, size = size.tiny, tooltip = "Confirmed neutral market regime")
    lastNeutralLabelBar := bar_index

//------------------------------------------------------------------------------
// Expanded but restrained dashboard
//------------------------------------------------------------------------------
var table dashboard = table.new(f_dashboardPosition(dashboardPosition), 3, 5, bgcolor = color.new(chart.bg_color, 4), frame_color = color.new(chart.fg_color, 82), frame_width = 1, border_color = color.new(chart.fg_color, 92), border_width = 1)

if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 2, 0)

if barstate.islast
    if showDashboard
        table.cell(dashboard, 0, 0, "MARKET STATE", text_color = color.new(chart.fg_color, 22), bgcolor = color.new(chart.fg_color, 93), text_size = size.small)

        table.cell(dashboard, 0, 1, " ", bgcolor = baseRegimeColor, width = 1)
        table.cell(dashboard, 1, 1, "REGIME", text_color = color.new(chart.fg_color, 42), bgcolor = color.new(chart.bg_color, 4), text_size = size.small, width = 8)
        table.cell(dashboard, 2, 1, regimeText, text_color = baseRegimeColor, bgcolor = color.new(baseRegimeColor, 91), text_size = size.normal, width = 11)

        table.cell(dashboard, 0, 2, " ", bgcolor = coreRegimeColor, width = 1)
        table.cell(dashboard, 1, 2, "STRENGTH", text_color = color.new(chart.fg_color, 42), bgcolor = color.new(chart.bg_color, 4), text_size = size.small)
        table.cell(dashboard, 2, 2, strengthText + "  " + str.tostring(trendStrength, "#") + "%", text_color = coreRegimeColor, bgcolor = color.new(coreRegimeColor, 94), text_size = size.small)

        table.cell(dashboard, 0, 3, " ", bgcolor = volatilityColor, width = 1)
        table.cell(dashboard, 1, 3, "VOLATILITY", text_color = color.new(chart.fg_color, 42), bgcolor = color.new(chart.bg_color, 4), text_size = size.small)
        table.cell(dashboard, 2, 3, volatilityText, text_color = volatilityColor, bgcolor = color.new(volatilityColor, 94), text_size = size.small)

        table.cell(dashboard, 0, 4, " ", bgcolor = color.new(baseRegimeColor, 35), width = 1)
        table.cell(dashboard, 1, 4, "DURATION", text_color = color.new(chart.fg_color, 42), bgcolor = color.new(chart.bg_color, 4), text_size = size.small)
        table.cell(dashboard, 2, 4, str.tostring(regimeBars) + " BARS", text_color = chart.fg_color, bgcolor = color.new(chart.bg_color, 4), text_size = size.small)
    else
        table.clear(dashboard, 0, 0, 2, 4)

//------------------------------------------------------------------------------
// Alerts
//------------------------------------------------------------------------------
alertConfirmed = not confirmAlertsOnClose or barstate.isconfirmed
bullishRegimeStarted = ready and directionState == 1 and previousDirectionState != 1
bearishRegimeStarted = ready and directionState == -1 and previousDirectionState != -1
compressionStarted = ready and isCompression and not isCompression[1]
expansionStarted = ready and isExpansion and not isExpansion[1]

alertcondition(alertConfirmed and directionChanged, "Market Regime Changed", "Adaptive Market Regime Map changed direction state on {{ticker}} {{interval}}.")
alertcondition(alertConfirmed and bullishRegimeStarted, "Bullish Regime Started", "Adaptive Market Regime Map detected a bullish regime on {{ticker}} {{interval}}.")
alertcondition(alertConfirmed and bearishRegimeStarted, "Bearish Regime Started", "Adaptive Market Regime Map detected a bearish regime on {{ticker}} {{interval}}.")
alertcondition(alertConfirmed and compressionStarted, "Compression Started", "Adaptive Market Regime Map detected volatility compression on {{ticker}} {{interval}}.")
alertcondition(alertConfirmed and expansionStarted, "Expansion Started", "Adaptive Market Regime Map detected volatility expansion on {{ticker}} {{interval}}.")
````
