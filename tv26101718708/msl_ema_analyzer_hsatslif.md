# MSL EMA Analyzer

- url: https://www.tradingview.com/script/HSaTSLIf-msl-ema-analyzer/
- type: indicator
- pine_id: PUB;487631ee6782477f94f5524bdda1fdd5
- version: 2.0

## Description

MSL EMA Analyzer is a market-context indicator developed by MarketStructureLab.

It helps traders read the current market regime through 5 layered moving average pairs, from fast impulse to macro trend.

The indicator can use either EMA or SMA and plots each pair directly on the chart as a filled layer between the Fast MA and the Slow MA.

When the Fast MA is above the Slow MA, the layer turns green and shows a bullish state.
When the Fast MA is below the Slow MA, the layer turns red and shows a bearish state.

This gives a clean visual view of whether short-term, medium-term, long-term and macro trend structures are aligned or conflicting.

━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━

MSL EMA Analyzer uses 5 moving average layers:

Layer 1: 5 / 12
Fast impulse layer.
Designed to react quickly to early movement and short-term momentum shifts.

Layer 2: 9 / 13
Short-term trend layer.
Helps smooth some of the noise from the fastest layer and shows near-term direction.

Layer 3: 34 / 50
Medium-term trend layer.
Acts as the primary trend filter and helps identify the main working direction.

Layer 4: 72 / 89
Long-term trend layer.
Shows the broader trend structure and higher-timeframe pressure.

Layer 5: 180 / 200
Macro trend layer.
Helps define the overall bull / bear market regime.

━━━━━━━━━━━━━━━━━━━━
LAYER COLORS
━━━━━━━━━━━━━━━━━━━━

Green layer:
Fast MA is above Slow MA.
This means the layer is in a bullish state.

Red layer:
Fast MA is below Slow MA.
This means the layer is in a bearish state.

When most layers are green, the market context is bullish.
When most layers are red, the market context is bearish.
When layers are mixed, the market is likely in a transition, pullback, consolidation or sideways phase.

━━━━━━━━━━━━━━━━━━━━
DASHBOARD
━━━━━━━━━━━━━━━━━━━━

The dashboard shows each layer direction and the overall market context.

Overall UPTREND:
4 or 5 layers are bullish.

Overall DOWNTREND:
0 or 1 layer is bullish, meaning 4 or 5 layers are bearish.

Overall SIDEWAYS:
2 or 3 layers are bullish, meaning there is no clear trend alignment.

Score:
The score shows how many layers are currently bullish.

Example:
5 / 5 bullish layers = full bullish alignment.
3 / 5 bullish layers = mixed structure.
0 / 5 bullish layers = full bearish alignment.

━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━

MSL EMA Analyzer includes 3 alert conditions:

Uptrend started:
The overall market context flipped to bullish.

Downtrend started:
The overall market context flipped to bearish.

Trend changed:
The overall market context changed direction.

These alerts are designed to notify about regime changes, not direct trade entries.

━━━━━━━━━━━━━━━━━━━━
SUGGESTED USAGE
━━━━━━━━━━━━━━━━━━━━

Scalping, 1m–15m:
Focus mainly on Layers 1–2.

Intraday, 15m–1h:
Focus mainly on Layers 2–3.

Swing trading, 4h–1D:
Focus mainly on Layers 3–4.

Position trading, 1D and higher:
Focus mainly on Layers 4–5.

━━━━━━━━━━━━━━━━━━━━
SETTINGS TIPS
━━━━━━━━━━━━━━━━━━━━

Show EMA Lines:
Turn this off for the cleanest visual.
Turn it on if you want to see the exact Fast and Slow MA lines inside each layer.

MA Type:
EMA reacts faster to recent price movement.
SMA is smoother and slower.

Source:
Default source is HL2, which uses the average of high and low.

Leading Offset:
Shifts the layers forward visually.
This is only a visual offset and should not be treated as a price forecast.

Layer visibility:
Layers 1–3 are useful for active trading and short-to-medium-term context.
Layers 4–5 are better suited for higher timeframes and broader trend structure.

━━━━━━━━━━━━━━━━━━━━
IMPORTANT
━━━━━━━━━━━━━━━━━━━━

MSL EMA Analyzer is a context indicator, not a signal indicator.

It does not generate direct buy or sell entries.
It does not predict future price.
It does not replace risk management.

The purpose of this indicator is to help traders understand the current market regime, trend alignment and structural context.

Use it as a trend filter together with your own trading plan, entry model, confirmation tools and risk management rules.

━━━━━━━━━━━━━━━━━━━━
BEST USED FOR
━━━━━━━━━━━━━━━━━━━━

Trend filtering
Market context analysis
Multi-layer moving average structure
Regime detection
Trend alignment
Higher-timeframe confirmation
Crypto, stocks, forex, indices and other liquid markets[url=https://www.tradingview.com/x/hegMYvU9/]https://www.tradingview.com/x/hegMYvU9/[/url][image]https://www.tradingview.com/x/hegMYvU9/[/image]

## Source Code

````pine
// This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
// You may share and adapt this code for non-commercial purposes, with attribution.
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// EMA Analyzer — developed by MarketStructureLab.
// May your trades be green and your stops never hit. Good luck out there.

//@version=6
indicator("MSL EMA Analyzer", shorttitle="EMA Anlyz", overlay=true)

//============================================================
// INPUTS
//============================================================

groupCalc   = "Calculation"
groupVisual = "Visual"
groupTable  = "Dashboard"

maType = input.string("EMA", "MA Type", options=["EMA", "SMA"], group=groupCalc, display=display.none, tooltip="Moving average type. EMA reacts faster to recent prices; SMA is smoother and steadier.")

src = input.source(hl2, "Source", group=groupCalc, display=display.none, tooltip="Price source for the calculation. Default hl2 = (high+low)/2 smooths the noise from closes.")

offsetBars = input.int(0, "Leading Offset", minval=0, group=groupCalc, display=display.none, tooltip="Shift layers forward in bars. 0 = no shift. Higher values project the zones into the future visually.")

layer1Fast = input.int(5,   "Layer 1 — Fast", minval=1, inline="L1", group=groupCalc, display=display.none, tooltip="Layer 1 — the fastest impulse layer (5/12). Catches the start of moves and intraday impulses.")
layer1Slow = input.int(12,  "Slow",           minval=2, inline="L1", group=groupCalc, display=display.none)

layer2Fast = input.int(9,   "Layer 2 — Fast", minval=1, inline="L2", group=groupCalc, display=display.none, tooltip="Layer 2 — short-term trend (9/13). Smooths the noise of the fast layer.")
layer2Slow = input.int(13,  "Slow",           minval=2, inline="L2", group=groupCalc, display=display.none)

layer3Fast = input.int(34,  "Layer 3 — Fast", minval=1, inline="L3", group=groupCalc, display=display.none, tooltip="Layer 3 — medium-term trend (34/50). The primary direction filter.")
layer3Slow = input.int(50,  "Slow",           minval=2, inline="L3", group=groupCalc, display=display.none)

layer4Fast = input.int(72,  "Layer 4 — Fast", minval=1, inline="L4", group=groupCalc, display=display.none, tooltip="Layer 4 (72/89). The slowest of the trading horizons: the structure that survives a normal pullback. Computed on the chart's own bars, like every other layer.")
layer4Slow = input.int(89,  "Slow",           minval=2, inline="L4", group=groupCalc, display=display.none)

layer5Fast = input.int(180, "Layer 5 — Fast", minval=1, inline="L5", group=groupCalc, display=display.none, tooltip="Layer 5 — macro trend (180/200). Overall bull / bear market regime.")
layer5Slow = input.int(200, "Slow",           minval=2, inline="L5", group=groupCalc, display=display.none)

showLayer1 = input.bool(true,  "Layer 1 (5/12)",    group=groupVisual, display=display.none, tooltip="Show / hide the fast impulse layer 5/12.")
showLayer2 = input.bool(true,  "Layer 2 (9/13)",    group=groupVisual, display=display.none, tooltip="Show / hide the short-term trend layer 9/13.")
showLayer3 = input.bool(true,  "Layer 3 (34/50)",   group=groupVisual, display=display.none, tooltip="Show / hide the medium-term trend layer 34/50.")
showLayer4 = input.bool(false, "Layer 4 (72/89)",   group=groupVisual, display=display.none, tooltip="Show / hide the long-term trend layer 72/89.")
showLayer5 = input.bool(false, "Layer 5 (180/200)", group=groupVisual, display=display.none, tooltip="Show / hide the macro trend layer 180/200.")

showMA = input.bool(false, "Show EMA Lines", group=groupVisual, display=display.none, tooltip="Draw the actual EMA lines inside the layers. Off = fill only (cleaner visual).")

bullColor    = input.color(color.rgb(38, 166, 154),  "Bull",    inline="col", group=groupVisual, display=display.none, tooltip="Layer color when bullish (Fast MA above Slow MA). Default is the MSL signature teal.")
bearColor    = input.color(color.rgb(239, 83, 80),   "Bear",    inline="col", group=groupVisual, display=display.none)
neutralColor = input.color(color.rgb(120, 123, 134), "Neutral", inline="col", group=groupVisual, display=display.none)

showTable = input.bool(true,        "Show Dashboard", group=groupTable, display=display.none, tooltip="Show the dashboard table with per-layer direction and overall trend context.")
tablePos  = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right","Middle Left"], group=groupTable, display=display.none, tooltip="Dashboard position on the chart.")
textColor = input.color(color.white,  "Text Color", group=groupTable, display=display.none, tooltip="Text color used in the dashboard.")

//============================================================
// COLORS
//============================================================

bullSoft       = color.new(bullColor, 70)
bearSoft       = color.new(bearColor, 70)
headerBg       = color.new(color.black,  20)
leftColBg      = color.new(color.gray,   80)
rightNeutralBg = color.new(neutralColor, 70)
borderColor    = color.new(color.gray,   60)

//============================================================
// CALCULATIONS
//============================================================

calcMA(int len) => maType == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

l1Fast = calcMA(layer1Fast)
l1Slow = calcMA(layer1Slow)
l2Fast = calcMA(layer2Fast)
l2Slow = calcMA(layer2Slow)
l3Fast = calcMA(layer3Fast)
l3Slow = calcMA(layer3Slow)
l4Fast = calcMA(layer4Fast)
l4Slow = calcMA(layer4Slow)
l5Fast = calcMA(layer5Fast)
l5Slow = calcMA(layer5Slow)

//============================================================
// SIGNAL ENGINE
//============================================================

layer1Up = l1Fast >= l1Slow
layer2Up = l2Fast >= l2Slow
layer3Up = l3Fast >= l3Slow
layer4Up = l4Fast >= l4Slow
layer5Up = l5Fast >= l5Slow

stackScore = (layer1Up ? 1 : 0) + (layer2Up ? 1 : 0) + (layer3Up ? 1 : 0) + (layer4Up ? 1 : 0) + (layer5Up ? 1 : 0)

trendState = stackScore >= 4 ? 1 : stackScore <= 1 ? -1 : 0
isUptrend  = trendState == 1

//============================================================
// SIGNAL STATS
//============================================================

var int lastTrend = 0
longSignal  = trendState ==  1 and lastTrend !=  1
shortSignal = trendState == -1 and lastTrend != -1
if trendState != 0
    lastTrend := trendState

//============================================================
// VISUAL STATE
//============================================================

layer1Fill = layer1Up ? color.new(bullColor, 60) : color.new(bearColor, 60)
layer2Fill = layer2Up ? color.new(bullColor, 70) : color.new(bearColor, 70)
layer3Fill = layer3Up ? color.new(bullColor, 75) : color.new(bearColor, 75)
layer4Fill = layer4Up ? color.new(bullColor, 75) : color.new(bearColor, 75)
layer5Fill = layer5Up ? color.new(bullColor, 75) : color.new(bearColor, 75)

layer1Stroke = showMA and showLayer1 ? (layer1Up ? bullColor : bearColor) : na
layer2Stroke = showMA and showLayer2 ? (layer2Up ? bullColor : bearColor) : na
layer3Stroke = showMA and showLayer3 ? (layer3Up ? bullColor : bearColor) : na
layer4Stroke = showMA and showLayer4 ? (layer4Up ? bullColor : bearColor) : na
layer5Stroke = showMA and showLayer5 ? (layer5Up ? bullColor : bearColor) : na

//============================================================
// PLOTS
//============================================================

p1Fast = plot(showLayer1 ? l1Fast : na, "L1 Fast", color=layer1Stroke, linewidth=1, offset=offsetBars, display=display.pane)
p1Slow = plot(showLayer1 ? l1Slow : na, "L1 Slow", color=layer1Stroke, linewidth=2, offset=offsetBars, display=display.pane)
p2Fast = plot(showLayer2 ? l2Fast : na, "L2 Fast", color=layer2Stroke, linewidth=1, offset=offsetBars, display=display.pane)
p2Slow = plot(showLayer2 ? l2Slow : na, "L2 Slow", color=layer2Stroke, linewidth=2, offset=offsetBars, display=display.pane)
p3Fast = plot(showLayer3 ? l3Fast : na, "L3 Fast", color=layer3Stroke, linewidth=1, offset=offsetBars, display=display.pane)
p3Slow = plot(showLayer3 ? l3Slow : na, "L3 Slow", color=layer3Stroke, linewidth=2, offset=offsetBars, display=display.pane)
p4Fast = plot(showLayer4 ? l4Fast : na, "L4 Fast", color=layer4Stroke, linewidth=1, offset=offsetBars, display=display.pane)
p4Slow = plot(showLayer4 ? l4Slow : na, "L4 Slow", color=layer4Stroke, linewidth=2, offset=offsetBars, display=display.pane)
p5Fast = plot(showLayer5 ? l5Fast : na, "L5 Fast", color=layer5Stroke, linewidth=1, offset=offsetBars, display=display.pane)
p5Slow = plot(showLayer5 ? l5Slow : na, "L5 Slow", color=layer5Stroke, linewidth=2, offset=offsetBars, display=display.pane)

fill(p1Fast, p1Slow, color=layer1Fill, title="Layer 1")
fill(p2Fast, p2Slow, color=layer2Fill, title="Layer 2")
fill(p3Fast, p3Slow, color=layer3Fill, title="Layer 3")
fill(p4Fast, p4Slow, color=layer4Fill, title="Layer 4")
fill(p5Fast, p5Slow, color=layer5Fill, title="Layer 5")

//============================================================
// ALERTS
//============================================================

alertcondition(longSignal,  title="MSL EMA Analyzer — Uptrend started",   message="MarketStructureLab EMA Analyzer: trend turned UPTREND (context only — not a trade signal)")
alertcondition(shortSignal, title="MSL EMA Analyzer — Downtrend started", message="MarketStructureLab EMA Analyzer: trend turned DOWNTREND (context only — not a trade signal)")
alertcondition(longSignal or shortSignal, title="MSL EMA Analyzer — Trend changed", message="MarketStructureLab EMA Analyzer: trend direction has changed (context only — not a trade signal)")

//============================================================
// TABLE
//============================================================

resolvePos(string p) => p == "Top Left" ? position.top_left : p == "Top Right" ? position.top_right : p == "Bottom Left" ? position.bottom_left : p == "Bottom Right" ? position.bottom_right : p == "Middle Left" ? position.middle_left : position.middle_right

var table proTable = table.new(resolvePos(tablePos), 2, 8, border_width=1, border_color=borderColor)

if barstate.islast and showTable
    table.clear(proTable, 0, 0, 1, 7)

    string trendStr = trendState ==  1 ? "🟢 UPTREND" : trendState == -1 ? "🔴 DOWNTREND" : "⚪ SIDEWAYS"
    color  trendBg  = trendState ==  1 ? bullSoft     : trendState == -1 ? bearSoft       : rightNeutralBg

    table.cell(proTable, 0, 0, "MSL EMA Analyzer", text_color=textColor, bgcolor=headerBg, text_size=size.small)
    table.cell(proTable, 1, 0, "Trend",            text_color=textColor, bgcolor=headerBg, text_size=size.small)

    table.cell(proTable, 0, 1, "Overall", text_color=textColor, bgcolor=leftColBg, text_size=size.small)
    table.cell(proTable, 1, 1, trendStr,  text_color=textColor, bgcolor=trendBg,   text_size=size.small)

    table.cell(proTable, 0, 2, "Layer 1 (" + str.tostring(layer1Fast) + "/" + str.tostring(layer1Slow) + ")", text_color=textColor, bgcolor=leftColBg, text_size=size.small)
    table.cell(proTable, 1, 2, layer1Up ? "🟢 up" : "🔴 down", text_color=textColor, bgcolor=layer1Up ? bullSoft : bearSoft, text_size=size.small)

    table.cell(proTable, 0, 3, "Layer 2 (" + str.tostring(layer2Fast) + "/" + str.tostring(layer2Slow) + ")", text_color=textColor, bgcolor=leftColBg, text_size=size.small)
    table.cell(proTable, 1, 3, layer2Up ? "🟢 up" : "🔴 down", text_color=textColor, bgcolor=layer2Up ? bullSoft : bearSoft, text_size=size.small)

    table.cell(proTable, 0, 4, "Layer 3 (" + str.tostring(layer3Fast) + "/" + str.tostring(layer3Slow) + ")", text_color=textColor, bgcolor=leftColBg, text_size=size.small)
    table.cell(proTable, 1, 4, layer3Up ? "🟢 up" : "🔴 down", text_color=textColor, bgcolor=layer3Up ? bullSoft : bearSoft, text_size=size.small)

    table.cell(proTable, 0, 5, "Layer 4 (" + str.tostring(layer4Fast) + "/" + str.tostring(layer4Slow) + ")", text_color=textColor, bgcolor=leftColBg, text_size=size.small)
    table.cell(proTable, 1, 5, layer4Up ? "🟢 up" : "🔴 down", text_color=textColor, bgcolor=layer4Up ? bullSoft : bearSoft, text_size=size.small)

    table.cell(proTable, 0, 6, "Layer 5 (" + str.tostring(layer5Fast) + "/" + str.tostring(layer5Slow) + ")", text_color=textColor, bgcolor=leftColBg, text_size=size.small)
    table.cell(proTable, 1, 6, layer5Up ? "🟢 up" : "🔴 down", text_color=textColor, bgcolor=layer5Up ? bullSoft : bearSoft, text_size=size.small)

    table.cell(proTable, 0, 7, "Score", text_color=textColor, bgcolor=leftColBg,      text_size=size.small)
    table.cell(proTable, 1, 7, str.tostring(stackScore) + " / 5  up", text_color=textColor, bgcolor=rightNeutralBg, text_size=size.small)
````
