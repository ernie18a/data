# Bystry Counter Strike Style + PVSRA

- url: https://www.tradingview.com/script/3TXZGw0G/
- type: indicator
- pine_id: PUB;f717d4c944384d85b7bfa85bbfcdacf9
- version: 1.0

## Description

Bystry Counter Strike Style + PVSRA

This indicator is a breakout and trade-management tool designed to help traders visualize potential long and short strike zones, dynamic profit targets, stop levels, and volume-based candle context directly on the chart.

The script combines four main components:

1. Dynamic Strike Channel
   The indicator builds a dynamic price channel using recent market structure. The upper boundary represents a potential long breakout area, while the lower boundary represents a potential short breakout area.

The channel is calculated from recent highs and lows over a configurable lookback window. This makes the tool adapt to changing market conditions instead of using fixed horizontal levels.

2. Breakout Signals
   Long signals are generated when price breaks above the upper strike level, while short signals are generated when price breaks below the lower strike level.

The user can choose between:

* Confirmed Close mode: signals are based on candle close confirmation.
* Intrabar Wick Touch mode: signals can appear when price touches the level during the candle.

Confirmed Close mode is designed to reduce intrabar signal changes and is the default approach for cleaner confirmation.

3. Dynamic TP and SL Logic
   The indicator automatically calculates potential TP1 and stop-loss levels using ATR and the width of the strike channel.

This allows the risk and target zones to expand or contract depending on current volatility.

The script includes:

* Future Long TP1
* Future Long SL
* Future Short TP1
* Future Short SL
* Active trade lines
* Optional fixed or trailing stop behavior

The stop mode can be set to:

* Auto
* Fixed
* Trailing

In Auto mode, the script can switch to trailing behavior depending on market volatility conditions.

4. PVSRA Candle Coloring
   This version includes PVSRA-style candle coloring to highlight unusual volume behavior.

The candle coloring uses:

* Average volume
* Candle spread
* Volume multiplied by spread
* Climax volume conditions
* Rising volume conditions

The purpose of this layer is to help traders see when a breakout or rejection happens with increased volume activity.

Default PVSRA candle logic:

* Bullish climax candles are highlighted when bullish candles appear with strong volume or strong volume-spread behavior.
* Bearish climax candles are highlighted when bearish candles appear with strong volume or strong volume-spread behavior.
* Rising volume candles are marked separately to show increased participation before or during a move.

Main Features

* Dynamic long breakout level
* Dynamic short breakout level
* Adaptive strike channel
* ATR-based TP and SL levels
* Optional EMA trend filter
* Optional volatility filter
* Fixed or trailing stop logic
* PVSRA candle coloring
* Entry labels
* TP1 labels
* Stop and trailing exit labels
* Performance table
* Alert conditions for entries, TP1, stop events, trailing conversion, and channel changes
* Dynamic alert messages using alert()

How To Use

This tool is intended to be used as a visual decision-support indicator, not as a standalone automated trading system.

A basic workflow may look like this:

1. Use the EMA filter to define directional bias.

   * Price above EMA may favor long setups.
   * Price below EMA may favor short setups.

2. Watch the dynamic strike channel.

   * A break above the upper level may suggest bullish continuation.
   * A break below the lower level may suggest bearish continuation.

3. Use PVSRA candle colors as additional context.

   * Strong volume on a breakout can indicate participation.
   * Strong opposite volume near a level may suggest rejection or absorption.

4. Use TP1 and SL levels as reference zones.

   * These levels are calculated dynamically from ATR and channel width.
   * They are not guaranteed execution prices.

5. Combine the indicator with your own market structure analysis.

   * Higher timeframe trend
   * Support and resistance
   * Liquidity zones
   * Session timing
   * Risk management

Inputs

Counter Strike Engine:

* AI Direction: choose Long & Short, Trade Longs, or Trade Shorts.
* Signal Mode: choose Full System or Entries Only.
* Learning / Strike Window: controls the lookback period for the strike channel.
* ATR Length: controls volatility calculation.
* Minimum ATR Profit Target: sets the minimum target distance.
* Minimum ATR Stop Loss: sets the minimum stop distance.
* Auto ATR Adjustment On Very Low Timeframes: increases ATR distance on very low timeframes.
* Entry Buffer ATR: adds a small ATR-based buffer to breakout levels.
* Stop Loss Mode: Auto, Trailing, or Fixed.
* Same Candle TP/SL Assumption: controls how the script handles candles where both TP and SL are touched.
* Entry Trigger: Confirmed Close or Intrabar Wick Touch.

Filters:

* EMA Filter: optional trend filter.
* EMA Filter Length: default trend filter length.
* Volatility Filter: optional filter for market volatility conditions.

Visuals:

* Show Strike Channel
* Show EMA
* Show Future TP/SL
* Show Trade Buttons
* Show Performance Table
* Label Size
* Brighter Labels
* Table Location

PVSRA Candle Coloring:

* Enable PVSRA Candle Coloring
* PVSRA Volume MA Length
* Climax Volume Multiplier
* Rising Volume Multiplier
* Custom candle colors for bullish and bearish volume conditions

Alerts

The script includes alert conditions for:

* Long Entry
* Short Entry
* TP1 Hit
* Trailing Stop Conversion
* Stop or Trail Exit
* Long Entry Price Changed
* Short Entry Price Changed
* Any Important Event

It also includes optional dynamic alert() messages with symbol, timeframe, entry price, TP1, and SL information.

Important Notes

This indicator does not use future data or lookahead logic.

The performance table is a simplified internal visual reference and should not be treated as an official strategy backtest. For full backtesting, commission modeling, slippage modeling, and order execution simulation, a dedicated strategy version should be used.

Signals may behave differently depending on the selected trigger mode. Confirmed Close mode is generally cleaner for historical review, while Intrabar Wick Touch mode can react earlier but may change during the live candle.

This tool is not financial advice. It does not predict the future and does not guarantee profitable results. It should be used together with proper risk management and independent market analysis.

Recommended Markets and Timeframes

The indicator can be tested on forex, crypto, indices, commodities, and futures markets.

For cleaner signals, higher intraday timeframes such as 15m, 30m, and 1h are generally more stable than very low timeframes. Very low timeframes may produce more noise and should be used with additional confirmation.

Originality

This script is an original breakout and trade-management tool that combines a dynamic strike channel, ATR-based target and stop logic, optional trend and volatility filters, alert support, and PVSRA-style candle coloring in one chart-based workflow.

It is not intended to reproduce or copy any closed-source script. The calculations, trade-management logic, and visual structure are implemented independently.

## Source Code

````pine
//@version=6
indicator("Bystry Counter Strike Style + PVSRA", overlay=true, max_labels_count=500, max_lines_count=500)

// =====================================================================
// BYSTRY COUNTER STRIKE STYLE + PVSRA
// Autorska wersja inspirowana publicznym opisem systemu breakout.
// Nie kopiuje zamkniętego algorytmu TradingIQ.
// =====================================================================

// =====================================================================
// FUNCTIONS
// =====================================================================
f_price(float x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_num(float x) =>
    na(x) ? "n/a" : str.tostring(x, "#.##")

f_pf(float grossProfit, float grossLoss) =>
    grossLoss == 0.0 ? grossProfit > 0.0 ? "∞" : "n/a" : str.tostring(grossProfit / grossLoss, "#.##")

f_pct(float entry, float level, int dir) =>
    na(entry) or na(level) ? "n/a" :
     dir == 1 ? str.tostring(((level - entry) / entry) * 100.0, "#.##") + "%" :
     str.tostring(((entry - level) / entry) * 100.0, "#.##") + "%"

// =====================================================================
// INPUTS — COUNTER STRIKE ENGINE
// =====================================================================
grpCore = "Counter Strike Engine"

directionMode = input.string(
     "Long & Short",
     "AI Direction",
     options=["Long & Short", "Trade Longs", "Trade Shorts"],
     group=grpCore
)

signalMode = input.string(
     "Full System",
     "Signal Mode",
     options=["Full System", "Entries Only"],
     group=grpCore
)

strikeLen = input.int(55, "Learning / Strike Window", minval=10, maxval=500, group=grpCore)
atrLen = input.int(14, "ATR Length", minval=1, group=grpCore)

minAtrTPInput = input.float(1.50, "Minimum ATR Profit Target", minval=0.10, step=0.05, group=grpCore)
minAtrSLInput = input.float(1.00, "Minimum ATR Stop Loss", minval=0.10, step=0.05, group=grpCore)

autoLowTfAtr = input.bool(true, "Auto ATR Adjustment On Very Low Timeframes", group=grpCore)
entryBufferAtr = input.float(0.02, "Entry Buffer ATR", minval=0.00, step=0.01, group=grpCore)

stopMode = input.string(
     "Auto",
     "Stop Loss Mode",
     options=["Auto", "Trailing", "Fixed"],
     group=grpCore
)

executionAssumption = input.string(
     "Conservative: SL before TP",
     "Same Candle TP/SL Assumption",
     options=["Conservative: SL before TP", "Aggressive: TP before SL"],
     group=grpCore
)

triggerMode = input.string(
     "Confirmed Close",
     "Entry Trigger",
     options=["Confirmed Close", "Intrabar Wick Touch"],
     group=grpCore
)

// =====================================================================
// INPUTS — FILTERS
// =====================================================================
grpFilters = "Filters"

useEmaFilter = input.bool(true, "EMA Filter", group=grpFilters)
emaLen = input.int(200, "EMA Filter Length", minval=1, group=grpFilters)

volatilityFilter = input.string(
     "Off",
     "Volatility Filter",
     options=["Off", "High only", "Normal/High", "Low/Normal"],
     group=grpFilters
)

// =====================================================================
// INPUTS — VISUALS
// =====================================================================
grpVisual = "Visuals"

showStrikeChannel = input.bool(true, "Show Strike Channel", group=grpVisual)
showEma = input.bool(true, "Show EMA", group=grpVisual)
showFutureTPSL = input.bool(true, "Show Future TP/SL", group=grpVisual)
showTradeButtons = input.bool(true, "Show Trade Buttons", group=grpVisual)
showPerformanceTable = input.bool(true, "Show Performance Table", group=grpVisual)

labelSizeInput = input.string(
     "Small",
     "Label Size",
     options=["Tiny", "Small", "Normal", "Large"],
     group=grpVisual
)

brighterLabels = input.bool(true, "Brighter Labels", group=grpVisual)

tableLocationInput = input.string(
     "Top Right",
     "Table Location",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=grpVisual
)

// =====================================================================
// INPUTS — PVSRA CANDLE COLORING
// =====================================================================
grpPvsra = "PVSRA Candle Coloring"

pvsraEnable = input.bool(true, "Enable PVSRA Candle Coloring", group=grpPvsra)
pvsraLen = input.int(10, "PVSRA Volume MA Length", minval=1, group=grpPvsra)

pvsraHighMult = input.float(2.0, "Climax Volume Multiplier", minval=1.0, step=0.1, group=grpPvsra)
pvsraRisingMult = input.float(1.5, "Rising Volume Multiplier", minval=1.0, step=0.1, group=grpPvsra)

pvsraBullClimaxColor = input.color(color.lime, "Bull Climax Color", group=grpPvsra)
pvsraBearClimaxColor = input.color(color.red, "Bear Climax Color", group=grpPvsra)
pvsraBullRisingColor = input.color(color.blue, "Bull Rising Color", group=grpPvsra)
pvsraBearRisingColor = input.color(color.purple, "Bear Rising Color", group=grpPvsra)

// =====================================================================
// INPUTS — ALERTS
// =====================================================================
grpAlerts = "Alerts"

useDynamicAlerts = input.bool(true, "Use Dynamic alert() Messages", group=grpAlerts)
alertOnEntry = input.bool(true, "Alert: Entry", group=grpAlerts)
alertOnTP1 = input.bool(true, "Alert: TP1 Hit", group=grpAlerts)
alertOnTrailConversion = input.bool(true, "Alert: Trailing Stop Conversion", group=grpAlerts)
alertOnStopOut = input.bool(true, "Alert: Stop Out", group=grpAlerts)
alertOnChannelChange = input.bool(false, "Alert: Strike Channel Change", group=grpAlerts)

// =====================================================================
// BASIC SERIES
// =====================================================================
atr = ta.atr(atrLen)
atrAvg = ta.sma(atr, 100)
volScore = atrAvg > 0.0 ? atr / atrAvg : 1.0

lowTfMult = autoLowTfAtr and timeframe.isminutes and timeframe.multiplier <= 3 ? 1.25 : 1.0
minAtrTP = minAtrTPInput * lowTfMult
minAtrSL = minAtrSLInput * lowTfMult

emaValue = ta.ema(close, emaLen)

allowLong = directionMode == "Long & Short" or directionMode == "Trade Longs"
allowShort = directionMode == "Long & Short" or directionMode == "Trade Shorts"

emaLongOk = not useEmaFilter or close > emaValue
emaShortOk = not useEmaFilter or close < emaValue

volOk = switch volatilityFilter
    "High only" => volScore >= 1.05
    "Normal/High" => volScore >= 0.85
    "Low/Normal" => volScore <= 1.15
    => true

// =====================================================================
// STRIKE CHANNEL
// =====================================================================
rawResistance = ta.highest(high, strikeLen)[1]
rawSupport = ta.lowest(low, strikeLen)[1]

longBreakoutPoint = rawResistance + atr * entryBufferAtr
shortBreakoutPoint = rawSupport - atr * entryBufferAtr

channelWidth = longBreakoutPoint - shortBreakoutPoint

dynamicTpDistance = math.max(atr * minAtrTP, math.max(channelWidth * 0.25, syminfo.mintick))
dynamicSlDistance = math.max(atr * minAtrSL, math.max(channelWidth * 0.14, syminfo.mintick))

futureLongTP = longBreakoutPoint + dynamicTpDistance
futureLongSL = longBreakoutPoint - dynamicSlDistance
futureShortTP = shortBreakoutPoint - dynamicTpDistance
futureShortSL = shortBreakoutPoint + dynamicSlDistance

// =====================================================================
// PLOTS — STRIKE CHANNEL
// =====================================================================
longPlot = plot(
     showStrikeChannel ? longBreakoutPoint : na,
     title="Long Breakout Point",
     color=color.new(color.lime, 0),
     linewidth=2
)

shortPlot = plot(
     showStrikeChannel ? shortBreakoutPoint : na,
     title="Short Breakout Point",
     color=color.new(color.fuchsia, 0),
     linewidth=2
)

fill(longPlot, shortPlot, color=showStrikeChannel ? color.new(color.gray, 92) : na, title="Acceptable Strike Zone")

plot(showEma ? emaValue : na, title="EMA Filter", color=color.new(color.orange, 0), linewidth=1)

plot(
     showFutureTPSL and signalMode == "Full System" ? futureLongTP : na,
     title="Future Long TP1",
     color=color.new(color.blue, 35),
     style=plot.style_linebr
)

plot(
     showFutureTPSL and signalMode == "Full System" ? futureLongSL : na,
     title="Future Long SL",
     color=color.new(color.red, 35),
     style=plot.style_linebr
)

plot(
     showFutureTPSL and signalMode == "Full System" ? futureShortTP : na,
     title="Future Short TP1",
     color=color.new(color.blue, 35),
     style=plot.style_linebr
)

plot(
     showFutureTPSL and signalMode == "Full System" ? futureShortSL : na,
     title="Future Short SL",
     color=color.new(color.red, 35),
     style=plot.style_linebr
)

// Hidden plots for alert/data window access
plot(longBreakoutPoint, title="Data Long Entry Price", display=display.data_window)
plot(shortBreakoutPoint, title="Data Short Entry Price", display=display.data_window)
plot(futureLongTP, title="Data Future Long TP1", display=display.data_window)
plot(futureLongSL, title="Data Future Long SL", display=display.data_window)
plot(futureShortTP, title="Data Future Short TP1", display=display.data_window)
plot(futureShortSL, title="Data Future Short SL", display=display.data_window)

// =====================================================================
// PVSRA CANDLES
// =====================================================================
pvsraSpread = high - low
pvsraVolAvg = ta.sma(volume, pvsraLen)
pvsraVolSpread = volume * pvsraSpread
pvsraVolSpreadAvg = ta.sma(pvsraVolSpread, pvsraLen)

pvsraReady = not na(pvsraVolAvg) and pvsraVolAvg > 0.0 and not na(pvsraVolSpreadAvg) and pvsraVolSpreadAvg > 0.0

pvsraBull = close >= open
pvsraClimax = pvsraReady and (volume >= pvsraVolAvg * pvsraHighMult or pvsraVolSpread >= pvsraVolSpreadAvg * pvsraHighMult)
pvsraRising = pvsraReady and not pvsraClimax and volume >= pvsraVolAvg * pvsraRisingMult

pvsraColor =
     pvsraClimax and pvsraBull ? pvsraBullClimaxColor :
     pvsraClimax and not pvsraBull ? pvsraBearClimaxColor :
     pvsraRising and pvsraBull ? pvsraBullRisingColor :
     pvsraRising and not pvsraBull ? pvsraBearRisingColor :
     na

barcolor(pvsraEnable ? pvsraColor : na)

// =====================================================================
// LABEL / TABLE SETTINGS
// =====================================================================
labelSize = switch labelSizeInput
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large
    => size.small

tableLocation = switch tableLocationInput
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

longEntryColor = brighterLabels ? color.lime : color.new(color.green, 0)
shortEntryColor = brighterLabels ? color.red : color.new(color.maroon, 0)
exitColor = brighterLabels ? color.aqua : color.new(color.blue, 0)
tpColor = brighterLabels ? color.blue : color.new(color.blue, 15)
slColor = brighterLabels ? color.red : color.new(color.red, 10)

// =====================================================================
// TRADE STATE
// =====================================================================
var int tradeDir = 0
var int entryBar = na

var float tradeEntry = na
var float tradeTP1 = na
var float tradeSL = na
var float tradeTrail = na

var bool tradeTP1Hit = false
var bool trailingThisTrade = false

var line activeEntryLine = na
var line activeTPLine = na
var line activeSLLine = na
var line activeTrailLine = na

var label longButton = na
var label shortButton = na

var float longGrossProfit = 0.0
var float longGrossLoss = 0.0
var float shortGrossProfit = 0.0
var float shortGrossLoss = 0.0

var int longTrades = 0
var int shortTrades = 0
var int longWins = 0
var int shortWins = 0
var int longLosses = 0
var int shortLosses = 0

// =====================================================================
// EVENT FLAGS
// =====================================================================
bool evLongEntry = false
bool evShortEntry = false
bool evTP1 = false
bool evTrailConvert = false
bool evStopOut = false

// =====================================================================
// ENTRY CONDITIONS
// =====================================================================
validChannel = not na(longBreakoutPoint) and not na(shortBreakoutPoint) and channelWidth > syminfo.mintick

confirmedOk = triggerMode == "Intrabar Wick Touch" ? true : barstate.isconfirmed

longTouch = triggerMode == "Intrabar Wick Touch" ? high >= longBreakoutPoint : close >= longBreakoutPoint
shortTouch = triggerMode == "Intrabar Wick Touch" ? low <= shortBreakoutPoint : close <= shortBreakoutPoint

longWasBelow = triggerMode == "Intrabar Wick Touch" ? high[1] < longBreakoutPoint[1] : close[1] < longBreakoutPoint[1]
shortWasAbove = triggerMode == "Intrabar Wick Touch" ? low[1] > shortBreakoutPoint[1] : close[1] > shortBreakoutPoint[1]

longSignal = validChannel and confirmedOk and tradeDir == 0 and allowLong and emaLongOk and volOk and longTouch and longWasBelow
shortSignal = validChannel and confirmedOk and tradeDir == 0 and allowShort and emaShortOk and volOk and shortTouch and shortWasAbove

// =====================================================================
// ENTRY EXECUTION
// =====================================================================
if longSignal
    evLongEntry := true
    tradeDir := 1
    entryBar := bar_index
    tradeEntry := longBreakoutPoint
    tradeTP1 := tradeEntry + dynamicTpDistance
    tradeSL := tradeEntry - dynamicSlDistance
    tradeTrail := na
    tradeTP1Hit := false
    trailingThisTrade := stopMode == "Trailing" or (stopMode == "Auto" and volScore >= 1.0)

    longTrades += 1

    label.new(
         bar_index,
         low,
         "LONG\n" + f_price(tradeEntry),
         style=label.style_label_up,
         color=longEntryColor,
         textcolor=color.black,
         size=labelSize,
         tooltip="Long Entry\nEntry: " + f_price(tradeEntry) + "\nTP1: " + f_price(tradeTP1) + " (" + f_pct(tradeEntry, tradeTP1, 1) + ")" + "\nSL: " + f_price(tradeSL) + " (" + f_pct(tradeEntry, tradeSL, 1) + ")"
    )

    if signalMode == "Full System"
        activeEntryLine := line.new(bar_index, tradeEntry, bar_index, tradeEntry, color=longEntryColor, style=line.style_dotted, width=1)
        activeTPLine := line.new(bar_index, tradeTP1, bar_index, tradeTP1, color=tpColor, style=line.style_solid, width=2)
        activeSLLine := line.new(bar_index, tradeSL, bar_index, tradeSL, color=slColor, style=line.style_solid, width=2)
        activeTrailLine := na

else if shortSignal
    evShortEntry := true
    tradeDir := -1
    entryBar := bar_index
    tradeEntry := shortBreakoutPoint
    tradeTP1 := tradeEntry - dynamicTpDistance
    tradeSL := tradeEntry + dynamicSlDistance
    tradeTrail := na
    tradeTP1Hit := false
    trailingThisTrade := stopMode == "Trailing" or (stopMode == "Auto" and volScore >= 1.0)

    shortTrades += 1

    label.new(
         bar_index,
         high,
         "SHORT\n" + f_price(tradeEntry),
         style=label.style_label_down,
         color=shortEntryColor,
         textcolor=color.white,
         size=labelSize,
         tooltip="Short Entry\nEntry: " + f_price(tradeEntry) + "\nTP1: " + f_price(tradeTP1) + " (" + f_pct(tradeEntry, tradeTP1, -1) + ")" + "\nSL: " + f_price(tradeSL) + " (" + f_pct(tradeEntry, tradeSL, -1) + ")"
    )

    if signalMode == "Full System"
        activeEntryLine := line.new(bar_index, tradeEntry, bar_index, tradeEntry, color=shortEntryColor, style=line.style_dotted, width=1)
        activeTPLine := line.new(bar_index, tradeTP1, bar_index, tradeTP1, color=tpColor, style=line.style_solid, width=2)
        activeSLLine := line.new(bar_index, tradeSL, bar_index, tradeSL, color=slColor, style=line.style_solid, width=2)
        activeTrailLine := na

// =====================================================================
// TRADE MANAGEMENT — LONG
// =====================================================================
if tradeDir == 1 and bar_index > entryBar
    tpTouch = not tradeTP1Hit and high >= tradeTP1
    slTouchBefore = low <= tradeSL

    conservativeStopFirst = executionAssumption == "Conservative: SL before TP" and tpTouch and slTouchBefore and not tradeTP1Hit

    if conservativeStopFirst
        evStopOut := true
        exitPrice = tradeSL
        pl = exitPrice - tradeEntry

        if pl >= 0
            longGrossProfit += pl
            longWins += 1
        else
            longGrossLoss += math.abs(pl)
            longLosses += 1

        if signalMode == "Full System"
            label.new(bar_index, tradeSL, "STOP\n" + f_price(tradeSL), style=label.style_label_down, color=slColor, textcolor=color.white, size=labelSize)

        tradeDir := 0
        tradeEntry := na
        tradeTP1 := na
        tradeSL := na
        tradeTrail := na
        tradeTP1Hit := false
        trailingThisTrade := false

    else
        if tpTouch
            tradeTP1Hit := true
            evTP1 := true

            if signalMode == "Full System"
                label.new(bar_index, tradeTP1, "TP1\n50%", style=label.style_label_down, color=tpColor, textcolor=color.white, size=labelSize)

            if trailingThisTrade
                evTrailConvert := true
                tradeTrail := close - dynamicSlDistance
                tradeSL := math.max(tradeSL, tradeTrail)

                if signalMode == "Full System"
                    activeTrailLine := line.new(bar_index, tradeSL, bar_index, tradeSL, color=exitColor, style=line.style_solid, width=2)

        if tradeTP1Hit and trailingThisTrade
            newTrail = close - dynamicSlDistance
            tradeTrail := na(tradeTrail) ? newTrail : math.max(tradeTrail, newTrail)
            tradeSL := math.max(tradeSL, tradeTrail)

        if signalMode == "Full System"
            if not na(activeEntryLine)
                line.set_x2(activeEntryLine, bar_index)
            if not na(activeTPLine)
                line.set_x2(activeTPLine, bar_index)
            if not na(activeSLLine)
                line.set_x2(activeSLLine, bar_index)
                line.set_y1(activeSLLine, tradeSL)
                line.set_y2(activeSLLine, tradeSL)
            if not na(activeTrailLine)
                line.set_x2(activeTrailLine, bar_index)
                line.set_y1(activeTrailLine, tradeSL)
                line.set_y2(activeTrailLine, tradeSL)

        slTouchAfter = low <= tradeSL

        if slTouchAfter
            evStopOut := true
            exitPrice = tradeSL
            pl = tradeTP1Hit ? ((tradeTP1 - tradeEntry) * 0.5 + (exitPrice - tradeEntry) * 0.5) : (exitPrice - tradeEntry)

            if pl >= 0
                longGrossProfit += pl
                longWins += 1
            else
                longGrossLoss += math.abs(pl)
                longLosses += 1

            if signalMode == "Full System"
                label.new(
                     bar_index,
                     tradeSL,
                     tradeTP1Hit ? "TRAIL EXIT\n" + f_price(tradeSL) : "STOP\n" + f_price(tradeSL),
                     style=label.style_label_down,
                     color=exitColor,
                     textcolor=color.black,
                     size=labelSize
                )

            tradeDir := 0
            tradeEntry := na
            tradeTP1 := na
            tradeSL := na
            tradeTrail := na
            tradeTP1Hit := false
            trailingThisTrade := false

// =====================================================================
// TRADE MANAGEMENT — SHORT
// =====================================================================
if tradeDir == -1 and bar_index > entryBar
    tpTouch = not tradeTP1Hit and low <= tradeTP1
    slTouchBefore = high >= tradeSL

    conservativeStopFirst = executionAssumption == "Conservative: SL before TP" and tpTouch and slTouchBefore and not tradeTP1Hit

    if conservativeStopFirst
        evStopOut := true
        exitPrice = tradeSL
        pl = tradeEntry - exitPrice

        if pl >= 0
            shortGrossProfit += pl
            shortWins += 1
        else
            shortGrossLoss += math.abs(pl)
            shortLosses += 1

        if signalMode == "Full System"
            label.new(bar_index, tradeSL, "STOP\n" + f_price(tradeSL), style=label.style_label_up, color=slColor, textcolor=color.white, size=labelSize)

        tradeDir := 0
        tradeEntry := na
        tradeTP1 := na
        tradeSL := na
        tradeTrail := na
        tradeTP1Hit := false
        trailingThisTrade := false

    else
        if tpTouch
            tradeTP1Hit := true
            evTP1 := true

            if signalMode == "Full System"
                label.new(bar_index, tradeTP1, "TP1\n50%", style=label.style_label_up, color=tpColor, textcolor=color.white, size=labelSize)

            if trailingThisTrade
                evTrailConvert := true
                tradeTrail := close + dynamicSlDistance
                tradeSL := math.min(tradeSL, tradeTrail)

                if signalMode == "Full System"
                    activeTrailLine := line.new(bar_index, tradeSL, bar_index, tradeSL, color=exitColor, style=line.style_solid, width=2)

        if tradeTP1Hit and trailingThisTrade
            newTrail = close + dynamicSlDistance
            tradeTrail := na(tradeTrail) ? newTrail : math.min(tradeTrail, newTrail)
            tradeSL := math.min(tradeSL, tradeTrail)

        if signalMode == "Full System"
            if not na(activeEntryLine)
                line.set_x2(activeEntryLine, bar_index)
            if not na(activeTPLine)
                line.set_x2(activeTPLine, bar_index)
            if not na(activeSLLine)
                line.set_x2(activeSLLine, bar_index)
                line.set_y1(activeSLLine, tradeSL)
                line.set_y2(activeSLLine, tradeSL)
            if not na(activeTrailLine)
                line.set_x2(activeTrailLine, bar_index)
                line.set_y1(activeTrailLine, tradeSL)
                line.set_y2(activeTrailLine, tradeSL)

        slTouchAfter = high >= tradeSL

        if slTouchAfter
            evStopOut := true
            exitPrice = tradeSL
            pl = tradeTP1Hit ? ((tradeEntry - tradeTP1) * 0.5 + (tradeEntry - exitPrice) * 0.5) : (tradeEntry - exitPrice)

            if pl >= 0
                shortGrossProfit += pl
                shortWins += 1
            else
                shortGrossLoss += math.abs(pl)
                shortLosses += 1

            if signalMode == "Full System"
                label.new(
                     bar_index,
                     tradeSL,
                     tradeTP1Hit ? "TRAIL EXIT\n" + f_price(tradeSL) : "STOP\n" + f_price(tradeSL),
                     style=label.style_label_up,
                     color=exitColor,
                     textcolor=color.black,
                     size=labelSize
                )

            tradeDir := 0
            tradeEntry := na
            tradeTP1 := na
            tradeSL := na
            tradeTrail := na
            tradeTP1Hit := false
            trailingThisTrade := false

// =====================================================================
// CHANNEL CHANGE EVENTS
// =====================================================================
longChannelChanged = not na(longBreakoutPoint) and not na(longBreakoutPoint[1]) and longBreakoutPoint != longBreakoutPoint[1]
shortChannelChanged = not na(shortBreakoutPoint) and not na(shortBreakoutPoint[1]) and shortBreakoutPoint != shortBreakoutPoint[1]

// =====================================================================
// TRADE BUTTONS
// =====================================================================
if showTradeButtons and barstate.islast
    if not na(longButton)
        label.delete(longButton)
    if not na(shortButton)
        label.delete(shortButton)

    longButton := label.new(
         bar_index + 3,
         longBreakoutPoint,
         "LONG ENTRY\n" + f_price(longBreakoutPoint),
         style=label.style_label_left,
         color=color.new(color.lime, 0),
         textcolor=color.black,
         size=size.small
    )

    shortButton := label.new(
         bar_index + 3,
         shortBreakoutPoint,
         "SHORT ENTRY\n" + f_price(shortBreakoutPoint),
         style=label.style_label_left,
         color=color.new(color.fuchsia, 0),
         textcolor=color.white,
         size=size.small
    )

// =====================================================================
// PERFORMANCE TABLE
// =====================================================================
var table perfTable = table.new(tableLocation, 2, 9, border_width=1)

if showPerformanceTable and barstate.islast
    longPF = f_pf(longGrossProfit, longGrossLoss)
    shortPF = f_pf(shortGrossProfit, shortGrossLoss)

    longWinrate = longTrades > 0 ? str.tostring((longWins / longTrades) * 100.0, "#.##") + "%" : "n/a"
    shortWinrate = shortTrades > 0 ? str.tostring((shortWins / shortTrades) * 100.0, "#.##") + "%" : "n/a"

    statusText = tradeDir == 1 ? "LONG ACTIVE" : tradeDir == -1 ? "SHORT ACTIVE" : "NO TRADE"
    stopTypeText = trailingThisTrade ? "Trailing" : "Fixed"

    table.cell(perfTable, 0, 0, "Bystry Counter Strike", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(perfTable, 1, 0, syminfo.ticker + " / " + timeframe.period, text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(perfTable, 0, 1, "Status", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(perfTable, 1, 1, statusText, text_color=color.white, bgcolor=tradeDir == 1 ? color.new(color.green, 45) : tradeDir == -1 ? color.new(color.red, 45) : color.new(color.gray, 70))

    table.cell(perfTable, 0, 2, "Long PF", text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.cell(perfTable, 1, 2, longPF, text_color=color.white, bgcolor=color.new(color.gray, 80))

    table.cell(perfTable, 0, 3, "Short PF", text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.cell(perfTable, 1, 3, shortPF, text_color=color.white, bgcolor=color.new(color.gray, 80))

    table.cell(perfTable, 0, 4, "Long Winrate", text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.cell(perfTable, 1, 4, longWinrate, text_color=color.white, bgcolor=color.new(color.gray, 80))

    table.cell(perfTable, 0, 5, "Short Winrate", text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.cell(perfTable, 1, 5, shortWinrate, text_color=color.white, bgcolor=color.new(color.gray, 80))

    table.cell(perfTable, 0, 6, "Volatility", text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.cell(perfTable, 1, 6, f_num(volScore), text_color=color.white, bgcolor=color.new(color.gray, 80))

    table.cell(perfTable, 0, 7, "Stop Type", text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.cell(perfTable, 1, 7, stopTypeText, text_color=color.white, bgcolor=color.new(color.gray, 80))

    table.cell(perfTable, 0, 8, "PVSRA", text_color=color.white, bgcolor=color.new(color.gray, 80))
    table.cell(perfTable, 1, 8, pvsraEnable ? "ON" : "OFF", text_color=color.white, bgcolor=pvsraEnable ? color.new(color.green, 60) : color.new(color.red, 60))

// =====================================================================
// ALERTCONDITIONS — TRADINGVIEW ALERT UI
// =====================================================================
anyEvent = evLongEntry or evShortEntry or evTP1 or evTrailConvert or evStopOut or longChannelChanged or shortChannelChanged

alertcondition(evLongEntry, "CS Long Entry", "Counter Strike Style: Long Entry")
alertcondition(evShortEntry, "CS Short Entry", "Counter Strike Style: Short Entry")
alertcondition(evTP1, "CS TP1 Hit", "Counter Strike Style: TP1 Hit")
alertcondition(evTrailConvert, "CS Trailing Stop Conversion", "Counter Strike Style: Stop Loss converted to trailing stop")
alertcondition(evStopOut, "CS Stop / Trail Exit", "Counter Strike Style: Stop or trailing stop hit")
alertcondition(longChannelChanged, "CS Long Entry Price Changed", "Counter Strike Style: Long breakout point changed")
alertcondition(shortChannelChanged, "CS Short Entry Price Changed", "Counter Strike Style: Short breakout point changed")
alertcondition(anyEvent, "CS Any Alert", "Counter Strike Style: Any important event")

// =====================================================================
// DYNAMIC ALERTS
// =====================================================================
if useDynamicAlerts and barstate.isconfirmed
    if alertOnEntry and evLongEntry
        alert("CS LONG ENTRY | " + syminfo.ticker + " | TF " + timeframe.period + " | Entry: " + f_price(tradeEntry) + " | TP1: " + f_price(tradeTP1) + " | SL: " + f_price(tradeSL), alert.freq_once_per_bar_close)

    if alertOnEntry and evShortEntry
        alert("CS SHORT ENTRY | " + syminfo.ticker + " | TF " + timeframe.period + " | Entry: " + f_price(tradeEntry) + " | TP1: " + f_price(tradeTP1) + " | SL: " + f_price(tradeSL), alert.freq_once_per_bar_close)

    if alertOnTP1 and evTP1
        alert("CS TP1 HIT | " + syminfo.ticker + " | TF " + timeframe.period, alert.freq_once_per_bar_close)

    if alertOnTrailConversion and evTrailConvert
        alert("CS TRAILING CONVERSION | " + syminfo.ticker + " | TF " + timeframe.period + " | New SL: " + f_price(tradeSL), alert.freq_once_per_bar_close)

    if alertOnStopOut and evStopOut
        alert("CS STOP / TRAIL EXIT | " + syminfo.ticker + " | TF " + timeframe.period, alert.freq_once_per_bar_close)

    if alertOnChannelChange and longChannelChanged
        alert("CS LONG ENTRY PRICE CHANGED | " + syminfo.ticker + " | TF " + timeframe.period + " | Long Entry: " + f_price(longBreakoutPoint), alert.freq_once_per_bar_close)

    if alertOnChannelChange and shortChannelChanged
        alert("CS SHORT ENTRY PRICE CHANGED | " + syminfo.ticker + " | TF " + timeframe.period + " | Short Entry: " + f_price(shortBreakoutPoint), alert.freq_once_per_bar_close)
````
