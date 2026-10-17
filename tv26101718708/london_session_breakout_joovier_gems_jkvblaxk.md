# London Session Breakout - Joovier Gems

- url: https://www.tradingview.com/script/JkVblAXK-London-Session-Breakout-Joovier-Gems/
- type: indicator
- pine_id: PUB;c3b14e5405c84b819da0ee96b2e7e0f8
- version: 1.0

## Description

London Session Breakout [NQ]

London Session Breakout [NQ] is a visual breakout indicator designed for traders who want a clean, mechanical way to track the pre-market London range on Nasdaq futures.

This indicator marks the 3:00 AM–9:00 AM New York time range, highlights the active trading window from 9:30 AM–11:00 AM, and plots breakout signals when price closes outside the London range.

The goal is simple: help traders visually identify when NQ breaks out of the London session range during the New York morning session.

How It Works

1. The indicator draws a box around the 3:00 AM–9:00 AM NY time session.
2. It marks the London session high and low.
3. The New York execution window from 9:30 AM–11:00 AM is highlighted on the chart.
4. A buy signal appears when a 5-minute candle closes above the London high.
5. A sell signal appears when a 5-minute candle closes below the London low.
6. Optional entry, stop loss, and take profit lines can be displayed automatically.

Trade Logic

This indicator is built around a simple breakout model:

* Long Signal: Candle closes above the 3:00 AM–9:00 AM range high.
* Short Signal: Candle closes below the 3:00 AM–9:00 AM range low.
* Entry: Breakout candle close.
* Stop Loss: 5 ticks beyond the breakout candle.
* Take Profit: 2R by default.
* Signals Only Appear: Between 9:30 AM and 11:00 AM New York time.

Features

* London range box
* London high and low levels
* New York execution window highlight
* Buy and sell breakout arrows
* Optional one-signal-per-day mode
* Optional entry, stop loss, and take profit lines
* Adjustable stop offset and take-profit R multiple
* Customizable colors, arrows, labels, and text size
* Alert conditions for long, short, or any breakout

Recommended Use

This indicator is intended for use on the NQ 5-minute chart with extended-hours data enabled.

It is best used as a visual backtesting and trade-planning tool. The indicator does not guarantee profitability and should be combined with proper risk management, market context, and your own testing.

Disclaimer

This script is for educational and informational purposes only. It is not financial advice. Trading futures involves risk, and past performance does not guarantee future results. Always backtest and forward-test any strategy before using it with real money.

## Source Code

````pine
//@version=6
indicator("London Session Breakout [NQ]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
// Inputs: Sessions
// ─────────────────────────────────────────────
tz              = input.string("America/New_York", "Session Timezone")
londonSession   = input.session("0300-0900", "London Range Session")
tradeSession    = input.session("0930-1100", "Execution Window")
extendSession   = input.session("0900-1100", "Extend High/Low Lines Until")

// ─────────────────────────────────────────────
// Inputs: Logic
// ─────────────────────────────────────────────
restrictToNQ    = input.bool(true, "Restrict Signals To NQ Only")
oneSignalPerDay = input.bool(true, "Only One Breakout Signal Per Day")
stopTicks       = input.int(5, "Stop Offset In Ticks", minval=1)
takeProfitR     = input.float(2.0, "Take Profit R Multiple", minval=0.25, step=0.25)

// ─────────────────────────────────────────────
// Inputs: Display Toggles
// ─────────────────────────────────────────────
showBox         = input.bool(true, "Show London Box")
showLevels      = input.bool(true, "Show London High/Low Lines")
showTradeBg     = input.bool(true, "Highlight Execution Window")
showWarnings    = input.bool(true, "Show Chart Warnings")
showArrowText   = input.bool(true, "Show BUY/SELL Text On Arrows")

// ─────────────────────────────────────────────
// Inputs: Trade Line Toggles
// ─────────────────────────────────────────────
showEntryLine   = input.bool(true, "Show Entry Line")
showStopLine    = input.bool(true, "Show Stop Loss Line")
showTargetLine  = input.bool(true, "Show Take Profit Line")
showTradeLabels = input.bool(true, "Show Entry/SL/TP Labels")

tradeLineBars   = input.int(30, "Trade Line Extension Bars", minval=1, maxval=300)
tradeLineWidth  = input.int(2, "Trade Line Width", minval=1, maxval=5)

entryLineColor  = input.color(color.new(color.white, 0), "Entry Line Color")
stopLineColor   = input.color(color.new(color.red, 0), "Stop Loss Line Color")
targetLineColor = input.color(color.new(color.lime, 0), "Take Profit Line Color")

tradeLabelTextColor = input.color(color.white, "Trade Label Text Color")
entryLabelBgColor   = input.color(color.new(color.gray, 20), "Entry Label Background")
stopLabelBgColor    = input.color(color.new(color.red, 20), "Stop Label Background")
targetLabelBgColor  = input.color(color.new(color.green, 20), "Take Profit Label Background")

tradeLabelSizeInput = input.string(
     "Small",
     "Trade Label Text Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"]
)

tradeLabelSize = switch tradeLabelSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

// ─────────────────────────────────────────────
// Inputs: London Box Styling
// ─────────────────────────────────────────────
boxBgColor      = input.color(color.new(color.blue, 88), "London Box Fill Color")
boxBorderColor  = input.color(color.new(color.blue, 20), "London Box Border Color")

// ─────────────────────────────────────────────
// Inputs: Level Line Styling
// ─────────────────────────────────────────────
highLineColor   = input.color(color.new(color.lime, 0), "London High Line Color")
lowLineColor    = input.color(color.new(color.red, 0), "London Low Line Color")
levelLineWidth  = input.int(2, "High/Low Line Width", minval=1, maxval=5)

// ─────────────────────────────────────────────
// Inputs: Execution Window Styling
// ─────────────────────────────────────────────
tradeBgColor    = input.color(color.new(color.yellow, 88), "Execution Window Background Color")

// ─────────────────────────────────────────────
// Inputs: Arrow Styling
// ─────────────────────────────────────────────
longArrowColor  = input.color(color.lime, "Long Arrow Color")
shortArrowColor = input.color(color.red, "Short Arrow Color")
arrowTextColor  = input.color(color.white, "Arrow Text Color")

arrowSizeInput = input.string(
     "Tiny",
     "Arrow/Text Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"]
)

// ─────────────────────────────────────────────
// Inputs: Warning Table Styling
// ─────────────────────────────────────────────
warningTextColor = input.color(color.white, "Warning Text Color")
warningOkBg      = input.color(color.new(color.green, 75), "Warning OK Background")
warningBadBg     = input.color(color.new(color.red, 70), "Warning Error Background")

warningTextSizeInput = input.string(
     "Small",
     "Warning Text Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"]
)

warningTextSize = switch warningTextSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge

// ─────────────────────────────────────────────
// Session Helper
// ─────────────────────────────────────────────
inSession(sess) =>
    not na(time(timeframe.period, sess, tz))

// ─────────────────────────────────────────────
// Session Logic
// ─────────────────────────────────────────────
inLondon      = inSession(londonSession)
inTradeWindow = inSession(tradeSession)
inExtend      = inSession(extendSession)

inLondonPrev = inLondon[1] == true

londonStart = inLondon and not inLondonPrev
londonEnd   = not inLondon and inLondonPrev

// ─────────────────────────────────────────────
// Symbol / Timeframe Checks
// ─────────────────────────────────────────────
symbolRoot = str.upper(syminfo.root)
symbolOk   = not restrictToNQ or symbolRoot == "NQ"

timeframeOk = timeframe.isminutes and timeframe.multiplier == 5

// ─────────────────────────────────────────────
// London Range Variables
// ─────────────────────────────────────────────
var float londonHigh = na
var float londonLow  = na
var bool rangeLocked = false
var bool signalFired = false

var box londonBox = na
var line londonHighLine = na
var line londonLowLine  = na

// ─────────────────────────────────────────────
// Start New London Session
// ─────────────────────────────────────────────
if londonStart
    londonHigh := high
    londonLow  := low
    rangeLocked := false
    signalFired := false

    if showBox
        londonBox := box.new(
             left=bar_index,
             top=londonHigh,
             right=bar_index,
             bottom=londonLow,
             bgcolor=boxBgColor,
             border_color=boxBorderColor
        )

// ─────────────────────────────────────────────
// Build London High / Low During 3 AM - 9 AM
// ─────────────────────────────────────────────
if inLondon
    londonHigh := math.max(nz(londonHigh, high), high)
    londonLow  := math.min(nz(londonLow, low), low)

    if showBox and not na(londonBox)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_right(londonBox, bar_index)
        box.set_bgcolor(londonBox, boxBgColor)
        box.set_border_color(londonBox, boxBorderColor)

// ─────────────────────────────────────────────
// Lock Range After London Session Ends
// ─────────────────────────────────────────────
if londonEnd and not na(londonHigh) and not na(londonLow)
    rangeLocked := true

    if showBox and not na(londonBox)
        box.set_right(londonBox, bar_index - 1)
        box.set_top(londonBox, londonHigh)
        box.set_bottom(londonBox, londonLow)
        box.set_bgcolor(londonBox, boxBgColor)
        box.set_border_color(londonBox, boxBorderColor)

    if showLevels
        londonHighLine := line.new(
             x1=bar_index - 1,
             y1=londonHigh,
             x2=bar_index,
             y2=londonHigh,
             color=highLineColor,
             width=levelLineWidth
        )

        londonLowLine := line.new(
             x1=bar_index - 1,
             y1=londonLow,
             x2=bar_index,
             y2=londonLow,
             color=lowLineColor,
             width=levelLineWidth
        )

// ─────────────────────────────────────────────
// Extend London High / Low Lines Through Trade Window
// ─────────────────────────────────────────────
if rangeLocked and inExtend and showLevels
    if not na(londonHighLine)
        line.set_x2(londonHighLine, bar_index + 1)
        line.set_y1(londonHighLine, londonHigh)
        line.set_y2(londonHighLine, londonHigh)
        line.set_color(londonHighLine, highLineColor)
        line.set_width(londonHighLine, levelLineWidth)

    if not na(londonLowLine)
        line.set_x2(londonLowLine, bar_index + 1)
        line.set_y1(londonLowLine, londonLow)
        line.set_y2(londonLowLine, londonLow)
        line.set_color(londonLowLine, lowLineColor)
        line.set_width(londonLowLine, levelLineWidth)

// ─────────────────────────────────────────────
// Execution Window Background
// ─────────────────────────────────────────────
bgcolor(showTradeBg and inTradeWindow ? tradeBgColor : na, title="9:30 - 11:00 Execution Window")

// ─────────────────────────────────────────────
// Breakout Signals
// ─────────────────────────────────────────────
rawLongSignal  = symbolOk and timeframeOk and rangeLocked and inTradeWindow and barstate.isconfirmed and close > londonHigh
rawShortSignal = symbolOk and timeframeOk and rangeLocked and inTradeWindow and barstate.isconfirmed and close < londonLow

longSignal  = rawLongSignal and (not oneSignalPerDay or not signalFired)
shortSignal = rawShortSignal and (not oneSignalPerDay or not signalFired)

if longSignal or shortSignal
    signalFired := true

// ─────────────────────────────────────────────
// Trade Price Calculations
// Entry = signal candle close.
// Long SL = signal candle low - stop ticks.
// Short SL = signal candle high + stop ticks.
// TP = R multiple.
// ─────────────────────────────────────────────
tickOffset = stopTicks * syminfo.mintick

longEntry  = close
longStop   = low - tickOffset
longRisk   = longEntry - longStop
longTarget = longEntry + longRisk * takeProfitR

shortEntry  = close
shortStop   = high + tickOffset
shortRisk   = shortStop - shortEntry
shortTarget = shortEntry - shortRisk * takeProfitR

// ─────────────────────────────────────────────
// Draw Long Trade Levels
// ─────────────────────────────────────────────
if longSignal and longRisk > 0
    if showEntryLine
        line.new(
             x1=bar_index,
             y1=longEntry,
             x2=bar_index + tradeLineBars,
             y2=longEntry,
             color=entryLineColor,
             width=tradeLineWidth
        )

    if showStopLine
        line.new(
             x1=bar_index,
             y1=longStop,
             x2=bar_index + tradeLineBars,
             y2=longStop,
             color=stopLineColor,
             width=tradeLineWidth
        )

    if showTargetLine
        line.new(
             x1=bar_index,
             y1=longTarget,
             x2=bar_index + tradeLineBars,
             y2=longTarget,
             color=targetLineColor,
             width=tradeLineWidth
        )

    if showTradeLabels and showEntryLine
        label.new(
             x=bar_index + tradeLineBars,
             y=longEntry,
             text="Entry",
             style=label.style_label_left,
             textcolor=tradeLabelTextColor,
             color=entryLabelBgColor,
             size=tradeLabelSize
        )

    if showTradeLabels and showStopLine
        label.new(
             x=bar_index + tradeLineBars,
             y=longStop,
             text="SL",
             style=label.style_label_left,
             textcolor=tradeLabelTextColor,
             color=stopLabelBgColor,
             size=tradeLabelSize
        )

    if showTradeLabels and showTargetLine
        label.new(
             x=bar_index + tradeLineBars,
             y=longTarget,
             text=str.tostring(takeProfitR) + "R TP",
             style=label.style_label_left,
             textcolor=tradeLabelTextColor,
             color=targetLabelBgColor,
             size=tradeLabelSize
        )

// ─────────────────────────────────────────────
// Draw Short Trade Levels
// ─────────────────────────────────────────────
if shortSignal and shortRisk > 0
    if showEntryLine
        line.new(
             x1=bar_index,
             y1=shortEntry,
             x2=bar_index + tradeLineBars,
             y2=shortEntry,
             color=entryLineColor,
             width=tradeLineWidth
        )

    if showStopLine
        line.new(
             x1=bar_index,
             y1=shortStop,
             x2=bar_index + tradeLineBars,
             y2=shortStop,
             color=stopLineColor,
             width=tradeLineWidth
        )

    if showTargetLine
        line.new(
             x1=bar_index,
             y1=shortTarget,
             x2=bar_index + tradeLineBars,
             y2=shortTarget,
             color=targetLineColor,
             width=tradeLineWidth
        )

    if showTradeLabels and showEntryLine
        label.new(
             x=bar_index + tradeLineBars,
             y=shortEntry,
             text="Entry",
             style=label.style_label_left,
             textcolor=tradeLabelTextColor,
             color=entryLabelBgColor,
             size=tradeLabelSize
        )

    if showTradeLabels and showStopLine
        label.new(
             x=bar_index + tradeLineBars,
             y=shortStop,
             text="SL",
             style=label.style_label_left,
             textcolor=tradeLabelTextColor,
             color=stopLabelBgColor,
             size=tradeLabelSize
        )

    if showTradeLabels and showTargetLine
        label.new(
             x=bar_index + tradeLineBars,
             y=shortTarget,
             text=str.tostring(takeProfitR) + "R TP",
             style=label.style_label_left,
             textcolor=tradeLabelTextColor,
             color=targetLabelBgColor,
             size=tradeLabelSize
        )

// ─────────────────────────────────────────────
// Arrow Plotting
// Pine requires plotshape text and size to be constant.
// ─────────────────────────────────────────────

// Long arrows WITH text
plotshape(longSignal and showArrowText and arrowSizeInput == "Tiny",   title="Long Breakout Tiny Text",   style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.tiny,   text="BUY",  textcolor=arrowTextColor)
plotshape(longSignal and showArrowText and arrowSizeInput == "Small",  title="Long Breakout Small Text",  style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.small,  text="BUY",  textcolor=arrowTextColor)
plotshape(longSignal and showArrowText and arrowSizeInput == "Normal", title="Long Breakout Normal Text", style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.normal, text="BUY",  textcolor=arrowTextColor)
plotshape(longSignal and showArrowText and arrowSizeInput == "Large",  title="Long Breakout Large Text",  style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.large,  text="BUY",  textcolor=arrowTextColor)
plotshape(longSignal and showArrowText and arrowSizeInput == "Huge",   title="Long Breakout Huge Text",   style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.huge,   text="BUY",  textcolor=arrowTextColor)

// Short arrows WITH text
plotshape(shortSignal and showArrowText and arrowSizeInput == "Tiny",   title="Short Breakout Tiny Text",   style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.tiny,   text="SELL", textcolor=arrowTextColor)
plotshape(shortSignal and showArrowText and arrowSizeInput == "Small",  title="Short Breakout Small Text",  style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.small,  text="SELL", textcolor=arrowTextColor)
plotshape(shortSignal and showArrowText and arrowSizeInput == "Normal", title="Short Breakout Normal Text", style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.normal, text="SELL", textcolor=arrowTextColor)
plotshape(shortSignal and showArrowText and arrowSizeInput == "Large",  title="Short Breakout Large Text",  style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.large,  text="SELL", textcolor=arrowTextColor)
plotshape(shortSignal and showArrowText and arrowSizeInput == "Huge",   title="Short Breakout Huge Text",   style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.huge,   text="SELL", textcolor=arrowTextColor)

// Long arrows WITHOUT text
plotshape(longSignal and not showArrowText and arrowSizeInput == "Tiny",   title="Long Breakout Tiny",   style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.tiny)
plotshape(longSignal and not showArrowText and arrowSizeInput == "Small",  title="Long Breakout Small",  style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.small)
plotshape(longSignal and not showArrowText and arrowSizeInput == "Normal", title="Long Breakout Normal", style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.normal)
plotshape(longSignal and not showArrowText and arrowSizeInput == "Large",  title="Long Breakout Large",  style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.large)
plotshape(longSignal and not showArrowText and arrowSizeInput == "Huge",   title="Long Breakout Huge",   style=shape.triangleup,   location=location.belowbar, color=longArrowColor,  size=size.huge)

// Short arrows WITHOUT text
plotshape(shortSignal and not showArrowText and arrowSizeInput == "Tiny",   title="Short Breakout Tiny",   style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.tiny)
plotshape(shortSignal and not showArrowText and arrowSizeInput == "Small",  title="Short Breakout Small",  style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.small)
plotshape(shortSignal and not showArrowText and arrowSizeInput == "Normal", title="Short Breakout Normal", style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.normal)
plotshape(shortSignal and not showArrowText and arrowSizeInput == "Large",  title="Short Breakout Large",  style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.large)
plotshape(shortSignal and not showArrowText and arrowSizeInput == "Huge",   title="Short Breakout Huge",   style=shape.triangledown, location=location.abovebar, color=shortArrowColor, size=size.huge)

// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(
     longSignal,
     title="London Session Breakout Long",
     message="NQ London Session Breakout LONG: 5-minute candle closed above the 3 AM - 9 AM NY range high."
)

alertcondition(
     shortSignal,
     title="London Session Breakout Short",
     message="NQ London Session Breakout SHORT: 5-minute candle closed below the 3 AM - 9 AM NY range low."
)

alertcondition(
     longSignal or shortSignal,
     title="London Session Breakout Any",
     message="NQ London Session Breakout: 5-minute candle closed outside the 3 AM - 9 AM NY range."
)

// ─────────────────────────────────────────────
// Warning Table
// ─────────────────────────────────────────────
var table warningTable = table.new(position.top_right, 1, 1)

if barstate.islast and showWarnings
    warningText = ""

    if not timeframeOk
        warningText += "Use 5-minute chart\n"

    if restrictToNQ and not symbolOk
        warningText += "Signals restricted to NQ\n"

    if warningText == ""
        warningText := "London Breakout OK"

    warningBg = warningText == "London Breakout OK" ? warningOkBg : warningBadBg

    table.cell(
         warningTable,
         0,
         0,
         warningText,
         text_color=warningTextColor,
         bgcolor=warningBg,
         text_size=warningTextSize
    )
else if barstate.islast and not showWarnings
    table.cell(
         warningTable,
         0,
         0,
         "",
         text_color=color.new(color.white, 100),
         bgcolor=color.new(color.black, 100)
    )
````
