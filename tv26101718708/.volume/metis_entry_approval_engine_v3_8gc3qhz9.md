# Metis Entry Approval Engine v3

- url: https://www.tradingview.com/script/8gc3QhZ9-Metis-Entry-Approval-Engine-v3/
- type: indicator
- pine_id: PUB;073b071693c94c8480eb0e68997c957a
- version: 2.0

## Description

Metis Entry Approval Engine v3 is a multi-timeframe technical framework designed to simplify entry decisions by combining daily timing and weekly context into a single, unified scoring system.

Instead of relying on multiple indicators and conflicting signals, this engine evaluates price action through a structured process and outputs one composite score and one clear decision state. The goal is to remove hesitation, reduce noise, and help you consistently identify the best opportunities within a focused watchlist.

The system calculates two core components:
	•	Daily Score — Measures short-term entry quality using RSI structure, momentum, trend alignment, and relative volume. This is the timing layer.
	•	Weekly Score — Measures higher-timeframe strength using weekly RSI, momentum, and broader trend confirmation. This is the context layer.

These are combined into a Composite Score, which represents the overall quality of the setup:
	•	Below 50 — AVOID
Weak, extended, or structurally poor setup. No action.
	•	50–64 — WATCH
Improving conditions, but not yet ready. Monitor for development.
	•	65–79 — APPROVED
Valid entry conditions. Meets the system’s criteria for participation.
	•	80+ — HIGH CONVICTION
Strong alignment across timeframes. Highest-quality opportunities.

The engine is designed to function as a decision layer, not just an indicator. It allows you to evaluate and compare multiple stocks using a consistent framework, helping answer the most important question:

“Is this the best use of capital right now?”

This makes it especially effective for:
	•	speculative growth stocks
	•	thematic portfolios
	•	insider-driven watchlists
	•	high-volatility opportunity sets

Unlike traditional RSI tools that focus only on overbought/oversold levels, this system evaluates whether a stock has improved enough across multiple dimensions to justify entry, while filtering out weak or extended setups.

The included dashboard provides a clean, real-time view of:
	•	Composite Score
	•	Daily Score
	•	Weekly Score
	•	Daily RSI
	•	Weekly RSI
	•	Relative Volume

This allows for fast, consistent decision-making without needing to interpret multiple indicators.

Core Philosophy:
One engine. One score. One decision framework.

Best used on a curated list of stocks where capital is actively being allocated, rather than broad-market scanning.

## Source Code

````pine
//@version=6
indicator("Métis Entry Approval Engine v4", overlay=false, max_labels_count=50)

// =====================
// INPUTS
// =====================
groupDaily = "Daily Engine"
rsiLen = input.int(14, "Daily RSI Length", group=groupDaily)
smoothLen = input.int(5, "Daily RSI EMA Smoothing", group=groupDaily)
signalLen = input.int(9, "Daily Signal EMA Length", group=groupDaily)

buyLow = input.float(35, "Daily Buy Zone Low", group=groupDaily)
buyHigh = input.float(55, "Daily Buy Zone High", group=groupDaily)
avoidHigh = input.float(60, "Daily Avoid Above", group=groupDaily)

groupWeekly = "Weekly Engine"
weeklyRsiLen = input.int(14, "Weekly RSI Length", group=groupWeekly)
weeklySmoothLen = input.int(5, "Weekly RSI EMA Smoothing", group=groupWeekly)
weeklySignalLen = input.int(9, "Weekly Signal EMA Length", group=groupWeekly)
weeklyMin = input.float(42, "Weekly RSI Minimum", group=groupWeekly)

groupTrend = "Trend Filters"
useTrendFilter = input.bool(true, "Use Trend Filters", group=groupTrend)
dailyEmaLen = input.int(21, "Daily Fast EMA", group=groupTrend)
weeklyEmaLen = input.int(10, "Weekly Fast EMA", group=groupTrend)

groupVolume = "Volume Filter"
useVolume = input.bool(true, "Use Relative Volume Filter", group=groupVolume)
volLen = input.int(20, "Relative Volume Length", group=groupVolume)
relVolMin = input.float(1.0, "Minimum Relative Volume", step=0.1, group=groupVolume)
highVol = input.float(1.3, "High Conviction Relative Volume", step=0.1, group=groupVolume)

groupComposite = "Composite Scoring"
dailyWeight = input.float(0.70, "Daily Weight", minval=0.0, maxval=1.0, step=0.05, group=groupComposite)
weeklyWeight = input.float(0.30, "Weekly Weight", minval=0.0, maxval=1.0, step=0.05, group=groupComposite)
highConvictionThreshold = input.int(80, "High Conviction Score", minval=0, maxval=100, group=groupComposite)
approvedThreshold = input.int(65, "Approved Score", minval=0, maxval=100, group=groupComposite)
watchThreshold = input.int(50, "Watch Score", minval=0, maxval=100, group=groupComposite)

groupExtreme = "Extreme Opportunity Mode"
enableExtremeMode = input.bool(true, "Enable Extreme Opportunity Mode", group=groupExtreme)
drawdownLookback = input.int(252, "Recent High Lookback", minval=50, group=groupExtreme)
extremeDrawdownPct = input.float(20.0, "Extreme Drawdown %", minval=5.0, step=0.5, group=groupExtreme)
extremeWeeklyRsiMax = input.float(40.0, "Extreme Weekly RSI Max", minval=10, maxval=60, step=0.5, group=groupExtreme)
extremeDailyRsiMax = input.float(45.0, "Extreme Daily RSI Max", minval=10, maxval=60, step=0.5, group=groupExtreme)
requireDailyTurnUp = input.bool(true, "Require Daily RSI Turning Up", group=groupExtreme)
requireDailyCrossInExtreme = input.bool(false, "Require Daily RSI Above Signal In Extreme Mode", group=groupExtreme)

groupVisual = "Visual"
showBackground = input.bool(true, "Show Background States", group=groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group=groupVisual)
showApprovedLabels = input.bool(true, "Show Approved Labels", group=groupVisual)
showHighConvictionLabels = input.bool(true, "Show High Conviction Labels", group=groupVisual)
showExtremeLabels = input.bool(true, "Show Extreme Opportunity Labels", group=groupVisual)

// =====================
// DAILY CALCULATIONS
// =====================
dailyRsiRaw = ta.rsi(close, rsiLen)
dailyRsi = ta.ema(dailyRsiRaw, smoothLen)
dailySignal = ta.ema(dailyRsi, signalLen)

dailyMomentumUp = dailyRsi > dailyRsi[1]
dailyAboveSignal = dailyRsi > dailySignal
dailyInBuyZone = dailyRsi >= buyLow and dailyRsi <= buyHigh
dailyTooHigh = dailyRsi > avoidHigh

dailyEma = ta.ema(close, dailyEmaLen)
dailyTrendOk = not useTrendFilter or close > dailyEma

avgVol = ta.sma(volume, volLen)
relVol = avgVol != 0 ? volume / avgVol : 0.0
dailyVolumeOk = not useVolume or relVol >= relVolMin

// =====================
// WEEKLY CALCULATIONS
// =====================
weeklyClose = request.security(syminfo.tickerid, "W", close)

weeklyRsiRaw = request.security(syminfo.tickerid, "W", ta.rsi(close, weeklyRsiLen))
weeklyRsi = request.security(syminfo.tickerid, "W", ta.ema(ta.rsi(close, weeklyRsiLen), weeklySmoothLen))
weeklySignal = request.security(syminfo.tickerid, "W", ta.ema(ta.ema(ta.rsi(close, weeklyRsiLen), weeklySmoothLen), weeklySignalLen))

weeklyMomentumUp = weeklyRsi > weeklyRsi[1]
weeklyAboveSignal = weeklyRsi > weeklySignal
weeklyLevelOk = weeklyRsi >= weeklyMin

weeklyEma = request.security(syminfo.tickerid, "W", ta.ema(close, weeklyEmaLen))
weeklyTrendOk = not useTrendFilter or weeklyClose > weeklyEma

// =====================
// DRAWDOWN / EXTREME MODE
// =====================
recentHigh = ta.highest(high, drawdownLookback)
drawdownPct = recentHigh != 0 ? (1.0 - close / recentHigh) * 100.0 : 0.0

extremeDrawdown = drawdownPct >= extremeDrawdownPct
extremeWeekly = weeklyRsi <= extremeWeeklyRsiMax
extremeDaily = dailyRsi <= extremeDailyRsiMax
extremeTurnUp = not requireDailyTurnUp or dailyMomentumUp
extremeCrossOk = not requireDailyCrossInExtreme or dailyAboveSignal

extremeOpportunity = enableExtremeMode and extremeDrawdown and extremeWeekly and extremeDaily and extremeTurnUp and extremeCrossOk

// =====================
// SCORING
// =====================
dailyScore = 0.0
dailyScore += dailyInBuyZone ? 30 : 0
dailyScore += dailyAboveSignal ? 20 : 0
dailyScore += dailyMomentumUp ? 15 : 0
dailyScore += dailyTrendOk ? 20 : 0
dailyScore += dailyVolumeOk ? 15 : 0

weeklyScore = 0.0
weeklyScore += weeklyLevelOk ? 35 : 0
weeklyScore += weeklyAboveSignal ? 25 : 0
weeklyScore += weeklyMomentumUp ? 15 : 0
weeklyScore += weeklyTrendOk ? 25 : 0

weightSum = dailyWeight + weeklyWeight
normDailyWeight = weightSum != 0 ? dailyWeight / weightSum : 0.7
normWeeklyWeight = weightSum != 0 ? weeklyWeight / weightSum : 0.3

compositeScore = math.round(dailyScore * normDailyWeight + weeklyScore * normWeeklyWeight)

// =====================
// STATES
// =====================
highConviction = compositeScore >= highConvictionThreshold and dailyAboveSignal and weeklyAboveSignal and relVol >= highVol and not dailyTooHigh
approved = compositeScore >= approvedThreshold and compositeScore < highConvictionThreshold and not dailyTooHigh
watch = compositeScore >= watchThreshold and compositeScore < approvedThreshold and not dailyTooHigh
avoid = compositeScore < watchThreshold or dailyTooHigh

stateText =
     extremeOpportunity ? "EXTREME OPPORTUNITY" :
     highConviction ? "HIGH CONVICTION" :
     approved ? "APPROVED" :
     watch ? "WATCH" :
     "AVOID"

stateColor =
     extremeOpportunity ? color.orange :
     highConviction ? color.purple :
     approved ? color.green :
     watch ? color.blue :
     color.red

newExtreme = extremeOpportunity and not extremeOpportunity[1]
newApproved = approved and not approved[1]
newHighConviction = highConviction and not highConviction[1]

// =====================
// PLOTS
// =====================
plot(dailyRsi, "Daily RSI", color=stateColor, linewidth=3)
plot(dailySignal, "Daily Signal", color=color.white, linewidth=2)

hline(avoidHigh, "Avoid", color=color.red)
hline(50, "Mid", color=color.gray)
hline(buyLow, "Buy Zone", color=color.green)

// =====================
// BACKGROUNDS
// =====================
bgcolor(showBackground and watch ? color.new(color.blue, 94) : na)
bgcolor(showBackground and approved ? color.new(color.green, 88) : na)
bgcolor(showBackground and highConviction ? color.new(color.purple, 84) : na)
bgcolor(showBackground and extremeOpportunity ? color.new(color.orange, 82) : na)

// =====================
// LABELS
// =====================
if showExtremeLabels and newExtreme
    label.new(
         bar_index,
         dailyRsi,
         "EXTREME\nOPPORTUNITY",
         style=label.style_label_up,
         color=color.orange,
         textcolor=color.white,
         size=size.small)

if showApprovedLabels and newApproved
    label.new(
         bar_index,
         dailyRsi,
         "APPROVED",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)

if showHighConvictionLabels and newHighConviction
    label.new(
         bar_index,
         dailyRsi,
         "HIGH CONVICTION",
         style=label.style_label_up,
         color=color.purple,
         textcolor=color.white,
         size=size.small)

// =====================
// DASHBOARD
// =====================
var table panel = table.new(position.top_left, 2, 9, border_width=1)

// Fully opaque panel colors
panelBg = color.rgb(28, 31, 38)
headerBg = color.rgb(34, 39, 52)

if barstate.islast and showDashboard
    table.cell(panel, 0, 0, "METIS ENTRY", text_color=color.white, bgcolor=headerBg, text_size=size.normal)
    table.cell(panel, 1, 0, stateText, text_color=stateColor, bgcolor=headerBg, text_size=size.normal)

    table.cell(panel, 0, 1, "Composite", text_color=color.white, bgcolor=panelBg, text_size=size.normal)
    table.cell(panel, 1, 1, str.tostring(compositeScore), text_color=stateColor, bgcolor=panelBg, text_size=size.normal)

    table.cell(panel, 0, 2, "Daily Score", text_color=color.white, bgcolor=panelBg, text_size=size.normal)
    table.cell(panel, 1, 2, str.tostring(math.round(dailyScore)), text_color=color.yellow, bgcolor=panelBg, text_size=size.normal)

    table.cell(panel, 0, 3, "Weekly Score", text_color=color.white, bgcolor=panelBg, text_size=size.normal)
    table.cell(panel, 1, 3, str.tostring(math.round(weeklyScore)), text_color=color.aqua, bgcolor=panelBg, text_size=size.normal)

    table.cell(panel, 0, 4, "Daily RSI", text_color=color.white, bgcolor=panelBg, text_size=size.normal)
    table.cell(panel, 1, 4, str.tostring(dailyRsi, "#.1"), text_color=color.yellow, bgcolor=panelBg, text_size=size.normal)

    table.cell(panel, 0, 5, "Weekly RSI", text_color=color.white, bgcolor=panelBg, text_size=size.normal)
    table.cell(panel, 1, 5, str.tostring(weeklyRsi, "#.1"), text_color=color.aqua, bgcolor=panelBg, text_size=size.normal)

    table.cell(panel, 0, 6, "Rel Volume", text_color=color.white, bgcolor=panelBg, text_size=size.normal)
    table.cell(panel, 1, 6, str.tostring(relVol, "#.1"), text_color=relVol >= relVolMin ? color.green : color.red, bgcolor=panelBg, text_size=size.normal)

    table.cell(panel, 0, 7, "Drawdown", text_color=color.white, bgcolor=panelBg, text_size=size.normal)
    table.cell(panel, 1, 7, str.tostring(drawdownPct, "#.1") + "%", text_color=color.orange, bgcolor=panelBg, text_size=size.normal)

    table.cell(panel, 0, 8, "Mode", text_color=color.white, bgcolor=panelBg, text_size=size.normal)
    table.cell(panel, 1, 8, extremeOpportunity ? "Extreme" : "Normal", text_color=extremeOpportunity ? color.orange : color.white, bgcolor=panelBg, text_size=size.normal)

// =====================
// ALERTS
// =====================
alertcondition(newExtreme, title="Métis Entry Approval Engine v4 - Extreme Opportunity", message="Métis Entry Approval Engine v4: {{ticker}} is in EXTREME OPPORTUNITY mode.")
alertcondition(newApproved, title="Métis Entry Approval Engine v4 - Approved", message="Métis Entry Approval Engine v4: {{ticker}} is APPROVED.")
alertcondition(newHighConviction, title="Métis Entry Approval Engine v4 - High Conviction", message="Métis Entry Approval Engine v4: {{ticker}} is HIGH CONVICTION.")
````
