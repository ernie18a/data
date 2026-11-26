# Metis Speculative Entry Engine v1

- url: https://www.tradingview.com/script/ENU5w88Q-Metis-Speculative-Entry-Engine-v1/
- type: indicator
- pine_id: PUB;6cf361f24f624852bd7cbb09ca5a7e5f
- version: 1.0

## Description

Metis Speculative Entry Engine v1 is a long-only technical approval framework designed for speculative stocks, thematic baskets, and high-volatility names where entry timing matters more than rigid valuation-based accumulation.

Unlike traditional RSI tools that rely on simple oversold/overbought readings, this engine is built around a reclaim-and-confirm model. It uses a smoothed RSI structure, an internal signal line, optional trend filters, optional weekly RSI confirmation, and optional relative volume filters to sort speculative setups into three practical states:
	•	EARLY — a washout reclaim or early technical improvement is emerging
	•	APPROVED — conditions have improved enough to justify a higher-quality speculative entry
	•	HIGH CONVICTION — the setup shows stronger alignment across RSI, trend, weekly strength, and volume

The goal is not to predict exact bottoms or generate automated trades. Instead, the engine is meant to function as a technical approval tool that helps determine whether a speculative name is merely oversold, beginning to repair, or showing sufficiently constructive behavior to justify action.

This makes it especially useful for:
	•	speculative growth baskets
	•	thematic portfolios
	•	insider-driven opportunity lists
	•	biotech / psychedelic / microcap watchlists
	•	random high-volatility names where timing discipline is critical

Core logic

The engine evaluates:
	•	smoothed RSI
	•	RSI signal line
	•	reclaim behavior from extreme or oversold zones
	•	optional trend structure using moving averages
	•	optional weekly RSI health
	•	optional relative volume confirmation

By combining these layers, the script moves beyond “RSI is low, so buy” and instead asks a more useful question:

Has this stock improved enough technically to earn entry approval?

What makes it different

This script is not intended to replace a ladder-based accumulation system for core holdings. It is designed for the part of a portfolio where names are more speculative, more volatile, and more prone to false bottoms. In that world, a structured approval model can be more useful than either pure discretionary chart reading or naive RSI oversold signals.

Best use cases
	•	Use EARLY as a watchlist or stalking signal
	•	Use APPROVED as the main speculative entry authorization
	•	Use HIGH CONVICTION when you want your strongest technical timing filter for speculative names

Important note

This is an analytical and decision-support tool, not an execution system. It is best used to improve entry timing, reduce impulsive buys, and create more consistency across speculative portfolio decisions.

## Source Code

````pine
//@version=6
indicator("Métis Speculative Entry Engine v1", shorttitle="Métis Spec Entry v1", overlay=false, max_labels_count=500)

// ============================================================================
// INPUTS
// ============================================================================
groupRsi = "RSI Engine"
rsiSource   = input.source(close, "RSI Source", group=groupRsi)
rsiLength   = input.int(14, "RSI Length", minval=1, group=groupRsi)
smoothMode  = input.string("EMA", "RSI Smoothing", options=["None", "EMA", "SMA", "RMA"], group=groupRsi)
smoothLen   = input.int(5, "Smoothing Length", minval=1, group=groupRsi)
signalLen   = input.int(9, "Signal Length", minval=1, group=groupRsi)
signalMode  = input.string("EMA", "Signal Smoothing", options=["EMA", "SMA", "RMA"], group=groupRsi)

groupLevels = "RSI Levels"
overbought  = input.int(65, "Overbought", minval=50, maxval=100, group=groupLevels)
oversold    = input.int(35, "Oversold", minval=0, maxval=50, group=groupLevels)
extremeHigh = input.int(75, "Extreme High", minval=60, maxval=100, group=groupLevels)
extremeLow  = input.int(25, "Extreme Low", minval=0, maxval=40, group=groupLevels)

groupFilters = "Approval Filters"
useTrendFilter       = input.bool(true, "Use Trend Filter", group=groupFilters)
fastLen              = input.int(20, "Fast EMA Length", minval=1, group=groupFilters)
slowLen              = input.int(50, "Slow SMA Length", minval=1, group=groupFilters)
requireCloseAboveFast = input.bool(true, "Require Close Above Fast EMA", group=groupFilters)
requireFastAboveSlow  = input.bool(false, "Require Fast EMA Above Slow SMA", group=groupFilters)
requireFastSlopeUp    = input.bool(true, "Require Fast EMA Rising", group=groupFilters)

useWeeklyFilter      = input.bool(true, "Use Weekly RSI Filter", group=groupFilters)
weeklyRsiLen         = input.int(14, "Weekly RSI Length", minval=1, group=groupFilters)
weeklyRsiMin         = input.float(45.0, "Weekly RSI Minimum", minval=0, maxval=100, group=groupFilters)

useVolumeFilter      = input.bool(true, "Use Relative Volume Filter", group=groupFilters)
volLen               = input.int(20, "Relative Volume Length", minval=1, group=groupFilters)
relVolMin            = input.float(1.1, "Minimum Relative Volume", minval=0.1, step=0.1, group=groupFilters)

useSignalConfirm     = input.bool(true, "Require RSI Above Signal For Approval", group=groupFilters)

groupSignals = "Signal Logic"
highConvictionWeeklyBuffer = input.float(5.0, "High Conviction Weekly RSI Buffer", minval=0, step=0.5, group=groupSignals)
highConvictionRelVol       = input.float(1.3, "High Conviction Relative Volume", minval=0.1, step=0.1, group=groupSignals)

groupVisual = "Visual Settings"
showBgExtreme = input.bool(true, "Highlight Extreme Background", group=groupVisual)
showPanel     = input.bool(true, "Show Status Panel", group=groupVisual)
panelPosition = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=groupVisual)
panelTextSize = input.string("Small", "Panel Text Size", options=["Tiny", "Small", "Normal"], group=groupVisual)
showPriceLabels = input.bool(true, "Show Price-Chart Labels", group=groupVisual)

groupAlerts = "Alerts"
enableEarlyAlerts         = input.bool(true, "Enable EARLY Alerts", group=groupAlerts)
enableApprovedAlerts      = input.bool(true, "Enable APPROVED Alerts", group=groupAlerts)
enableHighConvictionAlerts = input.bool(true, "Enable HIGH CONVICTION Alerts", group=groupAlerts)

// ============================================================================
// COLORS
// ============================================================================
clrBg       = color.rgb(13, 17, 23)
clrHeader   = color.rgb(31, 41, 55)
clrBorder   = color.rgb(48, 54, 61)
clrText     = color.rgb(230, 237, 243)
clrMuted    = color.rgb(139, 148, 158)
clrBlue     = color.rgb(88, 166, 255)
clrGreen    = color.rgb(34, 197, 94)
clrRed      = color.rgb(239, 68, 68)
clrOrange   = color.rgb(245, 158, 11)
clrPurple   = color.rgb(168, 85, 247)
clrCardA    = color.rgb(22, 27, 34)
clrCardB    = color.rgb(18, 22, 28)

// ============================================================================
// HELPERS
// ============================================================================
getTablePosition(_pos) =>
    switch _pos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

getTableTextSize(_size) =>
    switch _size
        "Tiny"   => size.tiny
        "Normal" => size.normal
        => size.small

ma(_src, _len, _mode) =>
    _mode == "EMA" ? ta.ema(_src, _len) :
     _mode == "SMA" ? ta.sma(_src, _len) :
     _mode == "RMA" ? ta.rma(_src, _len) :
     _src

// ============================================================================
// RSI ENGINE
// ============================================================================
rsiRaw    = ta.rsi(rsiSource, rsiLength)
rsiSmooth = smoothMode == "None" ? rsiRaw : ma(rsiRaw, smoothLen, smoothMode)
signal    = ma(rsiSmooth, signalLen, signalMode)
delta     = rsiSmooth - rsiSmooth[1]
spread    = rsiSmooth - signal

weeklyRsi = request.security(syminfo.tickerid, "W", ta.rsi(close, weeklyRsiLen))

fastEMA = ta.ema(close, fastLen)
slowSMA = ta.sma(close, slowLen)

avgVol = ta.sma(volume, volLen)
relVol = avgVol != 0 ? volume / avgVol : na

// ============================================================================
// CONDITIONS
// ============================================================================
reclaimExtreme = ta.crossover(rsiSmooth, extremeLow) and barstate.isconfirmed
reclaimOversold = ta.crossover(rsiSmooth, oversold) and barstate.isconfirmed

trendOk = not useTrendFilter or (
     (not requireCloseAboveFast or close > fastEMA) and
     (not requireFastAboveSlow or fastEMA > slowSMA) and
     (not requireFastSlopeUp or fastEMA > fastEMA[5])
)

weeklyOk = not useWeeklyFilter or weeklyRsi >= weeklyRsiMin
volumeOk = not useVolumeFilter or relVol >= relVolMin
signalOk = not useSignalConfirm or rsiSmooth > signal

// Approval states
earlySignal = reclaimExtreme
approvedSignal = reclaimOversold and trendOk and weeklyOk and volumeOk and signalOk
highConvictionSignal = approvedSignal and weeklyRsi >= (weeklyRsiMin + highConvictionWeeklyBuffer) and relVol >= highConvictionRelVol

// ============================================================================
// STATUS
// ============================================================================
stateText =
     highConvictionSignal ? "HIGH CONVICTION" :
     approvedSignal ? "APPROVED" :
     earlySignal ? "EARLY" :
     rsiSmooth <= extremeLow ? "WASHOUT" :
     rsiSmooth <= oversold ? "OVERSOLD" :
     rsiSmooth >= extremeHigh ? "EXTREME HIGH" :
     rsiSmooth >= overbought ? "OVERBOUGHT" :
     "NEUTRAL"

stateColor =
     highConvictionSignal ? clrPurple :
     approvedSignal ? clrGreen :
     earlySignal ? clrOrange :
     rsiSmooth <= extremeLow ? clrGreen :
     rsiSmooth <= oversold ? clrGreen :
     rsiSmooth >= extremeHigh ? clrRed :
     rsiSmooth >= overbought ? clrRed :
     clrBlue

momentumText =
     delta >= 1.5  ? "Strong Up" :
     delta > 0     ? "Up" :
     delta <= -1.5 ? "Strong Down" :
     delta < 0     ? "Down" :
     "Flat"

momentumColor =
     delta >= 1.5  ? clrGreen :
     delta > 0     ? clrBlue :
     delta <= -1.5 ? clrRed :
     delta < 0     ? clrRed :
     clrMuted

trendText =
     trendOk ? "Trend OK" : "Trend Weak"

trendColor =
     trendOk ? clrGreen : clrRed

volumeText =
     useVolumeFilter ? "RelVol " + str.tostring(relVol, "#.##") : "Vol Filter Off"

volumeColor =
     not useVolumeFilter ? clrMuted : relVol >= relVolMin ? clrGreen : clrRed

// ============================================================================
// LEVELS
// ============================================================================
h100 = hline(100, "100", color=color.new(clrMuted, 100))
h0   = hline(0, "0", color=color.new(clrMuted, 100))
h50  = hline(50, "Center", color=color.new(clrMuted, 60), linestyle=hline.style_dotted)
hOB  = hline(overbought, "Overbought", color=color.new(clrRed, 30), linestyle=hline.style_dashed)
hOS  = hline(oversold, "Oversold", color=color.new(clrGreen, 30), linestyle=hline.style_dashed)
hEH  = hline(extremeHigh, "Extreme High", color=color.new(clrRed, 55), linestyle=hline.style_dotted)
hEL  = hline(extremeLow, "Extreme Low", color=color.new(clrGreen, 55), linestyle=hline.style_dotted)

fill(hOB, h100, color=color.new(clrRed, 85), title="Overbought Zone")
fill(hOS, h0, color=color.new(clrGreen, 85), title="Oversold Zone")

bgcolor(showBgExtreme and rsiSmooth >= extremeHigh ? color.new(clrRed, 85) : na)
bgcolor(showBgExtreme and rsiSmooth <= extremeLow ? color.new(clrGreen, 85) : na)

// ============================================================================
// RSI PLOT
// ============================================================================
rsiColor =
     highConvictionSignal ? clrPurple :
     approvedSignal ? clrGreen :
     earlySignal ? clrOrange :
     rsiSmooth >= extremeHigh ? clrRed :
     rsiSmooth <= extremeLow ? clrGreen :
     clrBlue

plot(rsiSmooth, "RSI", color=rsiColor, linewidth=3)
plot(signal, "Signal", color=color.new(clrText, 35), linewidth=2)

// ============================================================================
// PRICE-CHART LABELS
// ============================================================================
if showPriceLabels and earlySignal
    label.new(
         x=bar_index,
         y=low,
         text="EARLY",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.new(clrOrange, 0),
         textcolor=color.white,
         size=size.small,
         force_overlay=true)

if showPriceLabels and approvedSignal
    label.new(
         x=bar_index,
         y=low,
         text="APPROVED",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.new(clrGreen, 0),
         textcolor=color.black,
         size=size.small,
         force_overlay=true)

if showPriceLabels and highConvictionSignal
    label.new(
         x=bar_index,
         y=low,
         text="HIGH CONVICTION",
         xloc=xloc.bar_index,
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.new(clrPurple, 0),
         textcolor=color.white,
         size=size.small,
         force_overlay=true)

// ============================================================================
// STATUS PANEL
// ============================================================================
panelPos  = getTablePosition(panelPosition)
panelSize = getTableTextSize(panelTextSize)

var table panel = table.new(panelPos, 2, 6, border_width=1, frame_color=clrBorder, border_color=clrBorder)

if barstate.islast
    if showPanel
        table.cell(panel, 0, 0, "SPEC ENTRY", text_color=clrText, text_size=panelSize, bgcolor=clrHeader)
        table.cell(panel, 1, 0, "STATE", text_color=clrText, text_size=panelSize, bgcolor=clrHeader)

        table.cell(panel, 0, 1, "RSI", text_color=clrMuted, text_size=panelSize, bgcolor=clrCardA)
        table.cell(panel, 1, 1, str.tostring(rsiSmooth, "#.##"), text_color=rsiColor, text_size=panelSize, bgcolor=clrCardA)

        table.cell(panel, 0, 2, "Signal", text_color=clrMuted, text_size=panelSize, bgcolor=clrCardB)
        table.cell(panel, 1, 2, str.tostring(signal, "#.##"), text_color=clrText, text_size=panelSize, bgcolor=clrCardB)

        table.cell(panel, 0, 3, "Approval", text_color=clrMuted, text_size=panelSize, bgcolor=clrCardA)
        table.cell(panel, 1, 3, stateText, text_color=stateColor, text_size=panelSize, bgcolor=clrCardA)

        table.cell(panel, 0, 4, "Momentum", text_color=clrMuted, text_size=panelSize, bgcolor=clrCardB)
        table.cell(panel, 1, 4, momentumText, text_color=momentumColor, text_size=panelSize, bgcolor=clrCardB)

        table.cell(panel, 0, 5, "Trend / Vol", text_color=clrMuted, text_size=panelSize, bgcolor=clrCardA)
        table.cell(panel, 1, 5, trendText + " | " + volumeText, text_color=trendColor, text_size=panelSize, bgcolor=clrCardA)
    else
        for row = 0 to 5
            table.cell(panel, 0, row, "", bgcolor=color.new(clrBg, 100))
            table.cell(panel, 1, row, "", bgcolor=color.new(clrBg, 100))

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(enableEarlyAlerts and earlySignal, title="Métis Speculative Entry Engine v1 - EARLY", message="Métis Speculative Entry Engine v1: {{ticker}} has an EARLY reclaim signal.")
alertcondition(enableApprovedAlerts and approvedSignal, title="Métis Speculative Entry Engine v1 - APPROVED", message="Métis Speculative Entry Engine v1: {{ticker}} has an APPROVED entry signal.")
alertcondition(enableHighConvictionAlerts and highConvictionSignal, title="Métis Speculative Entry Engine v1 - HIGH CONVICTION", message="Métis Speculative Entry Engine v1: {{ticker}} has a HIGH CONVICTION entry signal.")
````
