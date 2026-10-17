# TMO Trade Trigger System v1.2

- url: https://www.tradingview.com/script/HIWsvs2U-TMO-Trade-Trigger-System-v1-2/
- type: indicator
- pine_id: PUB;ba5c691ee42a497a97a6a0b7758396ea
- version: 1.0

## Description

TMO Trade Trigger System

[b]Originally designed for the 1W timeframe on the IREN chart using the -55/+55 thresholds.
Apply to other charts and timeframes WITH CAUTION.
Momentum zone thresholds should almost certainly be adjusted manually for different timeframes (i.e., for 4H chart, I might try -73/+73).[/b]

TMO Trade Trigger System is a momentum-based trading indicator built around the True Momentum Oscillator and TTM Squeeze framework.

The indicator is designed to separate trade logic into two stages:

1. Momentum exhaustion arms the setup.
2. TMO ribbon reversal confirms the trade.

The core idea is simple:

When the TMO signal line crosses down through a user-defined oversold level, the long setup becomes ARMED. The trade does not trigger immediately. Instead, the indicator waits for the TMO ribbon to close green, signaling a momentum reversal. Once confirmed, the script displays a BUY NEXT OPEN signal.

For exits, when the TMO signal line crosses up through a user-defined overbought level, the exit setup becomes ARMED. The trade remains open until the ribbon closes red, at which point the script displays a SELL NEXT OPEN signal.

The indicator also includes add-on logic. If a trade is already open and the TMO signal line crosses back down through the entry arming level before the final exit condition is met, the system can arm a new add-on entry. Once the ribbon turns green again, it displays ADD NEXT OPEN. This allows traders to visualize potential dip-buying opportunities within an existing long trade.

Features:

* Separate oscillator pane showing the TMO Main Line, Signal Line, and ribbon
* Adjustable entry and exit arming levels
* Default weekly-style levels: -55 entry arming and +55 exit arming
* Adaptable to lower timeframes, such as 4H, by adjusting the thresholds
* On-chart markers for ARMED, BUY NEXT OPEN, ADD NEXT OPEN, and SELL NEXT OPEN
* Optional TTM Squeeze dots
* Customizable line, ribbon, zone, and marker colors
* Alert conditions for entry armed, buy trigger, add trigger, exit armed, sell trigger, and any trade event
* Designed for bar-close confirmation and next-open execution planning

Suggested use:

Use on the 1W chart timeframe with the following settings:
Entry arming level: -55
Exit arming level: +55

Alerts should generally be set to Once Per Bar Close so that signals are confirmed only after the candle closes.

Logic summary:

Entry Armed: TMO signal line crosses down through the entry arming level.

Buy Triggered: Entry is armed and the TMO ribbon turns green.

Add Armed: A trade is already open and the signal line crosses down through the entry arming level again.

Add Triggered: Add is armed and the ribbon turns green again.

Exit Armed: TMO signal line crosses up through the exit arming level.

Sell Triggered: Exit is armed and the TMO ribbon turns red.

Notes:

This indicator is intended as a visual and alerting tool, not an automated trading system. It does not account for option pricing, implied volatility, liquidity, bid/ask spreads, earnings risk, position sizing, or broader market conditions.

Use it as part of a complete trading process.

Credit: This tool builds on the True Momentum Oscillator and TTM Squeeze concept, including logic adapted from the public “TMO with TTM Squeeze” indicator by ssksubam.

Not financial advice.

## Source Code

````pine
//@version=6
indicator("TMO Trade Trigger System v1.1", "TMO Trigger v1.1", overlay=false, max_labels_count=500)

//──────────────────────────────────────────────────────────────────────────────
// Inputs
//──────────────────────────────────────────────────────────────────────────────

groupTMO = "TMO Settings"
tmoLength = input.int(21, "TMO Length", minval=2, group=groupTMO)
calcLength = input.int(5, "TMO Calc Length", minval=1, group=groupTMO)
smoothLength = input.int(3, "TMO Smooth Length", minval=1, group=groupTMO)
ttmSqLength = input.int(20, "TTM Squeeze Length", minval=1, group=groupTMO)

groupStrategy = "Strategy Settings"
entryArmingLevel = input.float(-55.0, "Entry Arming Level", step=1.0, group=groupStrategy)
exitArmingLevel = input.float(55.0, "Exit Arming Level", step=1.0, group=groupStrategy)
confirmationMode = input.string("Ribbon Flip", "Ribbon Confirmation Mode", options=["Ribbon Flip", "Ribbon State"], group=groupStrategy)
confirmOnlyOnBarClose = input.bool(true, "Confirm Signals Only On Bar Close", group=groupStrategy)

groupPane = "Pane Visuals"
showTmoLines = input.bool(true, "Show TMO Main and Signal Lines", group=groupPane)
showTtmSqueeze = input.bool(false, "Show TTM Squeeze Dots", group=groupPane)
showZones = input.bool(true, "Show OB/OS Zones", group=groupPane)
showStateBackground = input.bool(true, "Show Armed-State Background", group=groupPane)
showStateTable = input.bool(true, "Show State Table", group=groupPane)

mainBullColor = input.color(color.new(color.lime, 30), "Main Line Green", group=groupPane)
mainBearColor = input.color(color.red, "Main Line Red", group=groupPane)
signalBullColor = input.color(color.new(color.lime, 30), "Signal Line Green", group=groupPane)
signalBearColor = input.color(color.red, "Signal Line Red", group=groupPane)
ribbonBullColor = input.color(color.green, "Ribbon Green", group=groupPane)
ribbonBearColor = input.color(color.red, "Ribbon Red", group=groupPane)
ribbonTransparency = input.int(25, "Ribbon Transparency", minval=0, maxval=100, group=groupPane)

entryLineColor = input.color(color.new(color.green, 0), "Entry Arming Line Color", group=groupPane)
exitLineColor = input.color(color.new(color.red, 0), "Exit Arming Line Color", group=groupPane)
zoneBullColor = input.color(color.green, "Oversold Zone Color", group=groupPane)
zoneBearColor = input.color(color.red, "Overbought Zone Color", group=groupPane)
zoneTransparency = input.int(88, "Zone Transparency", minval=0, maxval=100, group=groupPane)

squeezeReleaseColor = input.color(color.green, "Squeeze Dot Green", group=groupPane)
squeezeOnColor = input.color(color.red, "Squeeze Dot Red", group=groupPane)

groupChart = "Main Chart Visual Aids"
showArmedMarkers = input.bool(true, "Show Armed Markers On Price Chart", group=groupChart)
showTriggerMarkers = input.bool(true, "Show Buy/Sell/Add Trigger Markers On Price Chart", group=groupChart)

entryArmedMarkerColor = input.color(color.aqua, "Entry Armed Marker Color", group=groupChart)
buyTriggerMarkerColor = input.color(color.lime, "Buy Trigger Marker Color", group=groupChart)
exitArmedMarkerColor = input.color(color.orange, "Exit Armed Marker Color", group=groupChart)
sellTriggerMarkerColor = input.color(color.red, "Sell Trigger Marker Color", group=groupChart)
markerTextColor = input.color(color.white, "Marker Text Color", group=groupChart)

//──────────────────────────────────────────────────────────────────────────────
// TMO Calculation
// Matches the reference indicator logic, then normalizes values to -100/+100.
//──────────────────────────────────────────────────────────────────────────────

float tmoData = 0.0

for i = 1 to tmoLength - 1
    if close > open[i]
        tmoData += 1.0
    if close < open[i]
        tmoData -= 1.0

emaCalc = ta.ema(tmoData, calcLength)
mainRaw = ta.ema(emaCalc, smoothLength)
signalRaw = ta.ema(mainRaw, smoothLength)

tmoMain = 100.0 * mainRaw / tmoLength
tmoSignal = 100.0 * signalRaw / tmoLength

ribbonGreen = tmoMain > tmoSignal
ribbonRed = tmoMain <= tmoSignal

ribbonFlipGreen = ta.crossover(tmoMain, tmoSignal)
ribbonFlipRed = ta.crossunder(tmoMain, tmoSignal)

mainLineColor = ribbonGreen ? mainBullColor : mainBearColor
signalLineColor = ribbonGreen ? signalBullColor : signalBearColor
ribbonColor = ribbonGreen ? ribbonBullColor : ribbonBearColor

//──────────────────────────────────────────────────────────────────────────────
// TTM Squeeze Calculation
// Matches the reference indicator's dot logic.
// Green dot = diff >= 0
// Red dot = diff < 0
//──────────────────────────────────────────────────────────────────────────────

bband(length, mult) =>
    ta.sma(close, ttmSqLength) + mult * ta.stdev(close, length)

keltner(length, mult) =>
    ta.sma(close, ttmSqLength) + mult * ta.sma(ta.tr(true), length)

e1 = (ta.highest(high, ttmSqLength) + ta.lowest(low, ttmSqLength)) / 2.0 + ta.sma(close, ttmSqLength)
osc = ta.linreg(close - e1 / 2.0, ttmSqLength, 0)
diff = bband(ttmSqLength, 2.0) - keltner(ttmSqLength, 1.5)

squeezeDotColor = diff >= 0 ? squeezeReleaseColor : squeezeOnColor

//──────────────────────────────────────────────────────────────────────────────
// Pane Plots
//──────────────────────────────────────────────────────────────────────────────

upperLine = hline(100, "OB Line", color=color.new(color.red, 0), linestyle=hline.style_solid)
lowerLine = hline(-100, "OS Line", color=color.new(color.green, 0), linestyle=hline.style_solid)
exitArmingLine = hline(exitArmingLevel, "Exit Arming Level", color=exitLineColor, linestyle=hline.style_dashed)
entryArmingLine = hline(entryArmingLevel, "Entry Arming Level", color=entryLineColor, linestyle=hline.style_dashed)
zeroLine = hline(0, "Zero Line", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

mainPlot = plot(showTmoLines ? tmoMain : na, "Main Line", color=mainLineColor, linewidth=2)
signalPlot = plot(showTmoLines ? tmoSignal : na, "Signal Line", color=signalLineColor, linewidth=2)

fill(mainPlot, signalPlot, title="Main and Signal Ribbon", color=color.new(ribbonColor, ribbonTransparency))
fill(exitArmingLine, upperLine, title="Overbought Zone", color=showZones ? color.new(zoneBearColor, zoneTransparency) : na)
fill(entryArmingLine, lowerLine, title="Oversold Zone", color=showZones ? color.new(zoneBullColor, zoneTransparency) : na)

plot(showTtmSqueeze ? 0 : na, "Squeeze", style=plot.style_circles, linewidth=1, color=squeezeDotColor)

//──────────────────────────────────────────────────────────────────────────────
// State Machine
//
// 0 = Flat
// 1 = Entry Armed
// 2 = Long
// 3 = Exit Armed
// 4 = Add Armed
//──────────────────────────────────────────────────────────────────────────────

var int tradeState = 0

barConfirmed = not confirmOnlyOnBarClose or barstate.isconfirmed
stateAtBarStart = tradeState

entryArmCondition = ta.crossunder(tmoSignal, entryArmingLevel)
exitArmCondition = ta.crossover(tmoSignal, exitArmingLevel)

buyConfirmCondition = confirmationMode == "Ribbon Flip" ? ribbonFlipGreen : ribbonGreen
sellConfirmCondition = confirmationMode == "Ribbon Flip" ? ribbonFlipRed : ribbonRed

entryArmedSignal = barConfirmed and stateAtBarStart == 0 and entryArmCondition
buyTriggeredSignal = barConfirmed and stateAtBarStart == 1 and buyConfirmCondition

addArmedSignal = barConfirmed and stateAtBarStart == 2 and entryArmCondition
addTriggeredSignal = barConfirmed and stateAtBarStart == 4 and buyConfirmCondition

exitArmedSignal = barConfirmed and (stateAtBarStart == 2 or stateAtBarStart == 4) and exitArmCondition
sellTriggeredSignal = barConfirmed and stateAtBarStart == 3 and sellConfirmCondition

if sellTriggeredSignal
    tradeState := 0
else if exitArmedSignal
    tradeState := 3
else if addTriggeredSignal
    tradeState := 2
else if buyTriggeredSignal
    tradeState := 2
else if addArmedSignal
    tradeState := 4
else if entryArmedSignal
    tradeState := 1

//──────────────────────────────────────────────────────────────────────────────
// Armed-State Pane Background
//──────────────────────────────────────────────────────────────────────────────

bgColor =
     tradeState == 1 ? color.new(entryArmedMarkerColor, 88) :
     tradeState == 3 ? color.new(exitArmedMarkerColor, 88) :
     tradeState == 4 ? color.new(entryArmedMarkerColor, 88) :
     na

bgcolor(showStateBackground ? bgColor : na, title="Armed State Background")

//──────────────────────────────────────────────────────────────────────────────
// Main Chart Visual Aids
// Requires Pine v6 force_overlay.
//──────────────────────────────────────────────────────────────────────────────

plotshape(
     showArmedMarkers and entryArmedSignal,
     title="Entry Armed",
     style=shape.circle,
     location=location.belowbar,
     color=entryArmedMarkerColor,
     size=size.tiny,
     text="ARMED",
     textcolor=markerTextColor,
     force_overlay=true
)

plotshape(
     showTriggerMarkers and buyTriggeredSignal,
     title="Buy Triggered",
     style=shape.triangleup,
     location=location.belowbar,
     color=buyTriggerMarkerColor,
     size=size.normal,
     text="BUY\nNEXT OPEN",
     textcolor=markerTextColor,
     force_overlay=true
)

plotshape(
     showArmedMarkers and addArmedSignal,
     title="Add Armed",
     style=shape.circle,
     location=location.belowbar,
     color=entryArmedMarkerColor,
     size=size.tiny,
     text="ARMED",
     textcolor=markerTextColor,
     force_overlay=true
)

plotshape(
     showTriggerMarkers and addTriggeredSignal,
     title="Add Triggered",
     style=shape.triangleup,
     location=location.belowbar,
     color=buyTriggerMarkerColor,
     size=size.normal,
     text="ADD\nNEXT OPEN",
     textcolor=markerTextColor,
     force_overlay=true
)

plotshape(
     showArmedMarkers and exitArmedSignal,
     title="Exit Armed",
     style=shape.circle,
     location=location.abovebar,
     color=exitArmedMarkerColor,
     size=size.tiny,
     text="ARMED",
     textcolor=markerTextColor,
     force_overlay=true
)

plotshape(
     showTriggerMarkers and sellTriggeredSignal,
     title="Sell Triggered",
     style=shape.triangledown,
     location=location.abovebar,
     color=sellTriggerMarkerColor,
     size=size.normal,
     text="SELL\nNEXT OPEN",
     textcolor=markerTextColor,
     force_overlay=true
)

//──────────────────────────────────────────────────────────────────────────────
// State Table
//──────────────────────────────────────────────────────────────────────────────

stateText =
     tradeState == 0 ? "FLAT" :
     tradeState == 1 ? "ENTRY ARMED" :
     tradeState == 2 ? "LONG" :
     tradeState == 3 ? "EXIT ARMED" :
     "ADD ARMED"

stateColor =
     tradeState == 0 ? color.gray :
     tradeState == 1 ? entryArmedMarkerColor :
     tradeState == 2 ? buyTriggerMarkerColor :
     tradeState == 3 ? exitArmedMarkerColor :
     entryArmedMarkerColor

var table stateTable = table.new(position.top_right, 1, 1)

if barstate.islast
    table.cell(
         stateTable,
         0,
         0,
         showStateTable ? "State: " + stateText : "",
         text_color=showStateTable ? color.white : color.new(color.white, 100),
         bgcolor=showStateTable ? color.new(stateColor, 55) : color.new(color.black, 100)
    )

//──────────────────────────────────────────────────────────────────────────────
// Alerts
// Set TradingView alerts to Once Per Bar Close.
//──────────────────────────────────────────────────────────────────────────────

alertcondition(entryArmedSignal, "Entry Armed", "{{ticker}} {{interval}}: TMO entry armed. Signal crossed down through entry arming level. Wait for green ribbon confirmation.")
alertcondition(buyTriggeredSignal, "Buy Triggered", "{{ticker}} {{interval}}: BUY triggered. Entry was armed and ribbon confirmed green. Buy at next open.")

alertcondition(addArmedSignal, "Add Armed", "{{ticker}} {{interval}}: TMO add armed. Existing trade is open and signal crossed down through entry arming level again. Wait for green ribbon confirmation.")
alertcondition(addTriggeredSignal, "Add Triggered", "{{ticker}} {{interval}}: ADD triggered. Existing trade is open and ribbon confirmed green again. Add at next open.")

alertcondition(exitArmedSignal, "Exit Armed", "{{ticker}} {{interval}}: TMO exit armed. Signal crossed up through exit arming level. Wait for red ribbon confirmation.")
alertcondition(sellTriggeredSignal, "Sell Triggered", "{{ticker}} {{interval}}: SELL triggered. Exit was armed and ribbon confirmed red. Sell at next open.")

anyTradeEvent = entryArmedSignal or buyTriggeredSignal or addArmedSignal or addTriggeredSignal or exitArmedSignal or sellTriggeredSignal
alertcondition(anyTradeEvent, "Any TMO Trade Event", "{{ticker}} {{interval}}: TMO trade event occurred. Check chart.")
````
