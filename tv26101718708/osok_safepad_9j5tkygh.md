# OSOK SafePad

- url: https://www.tradingview.com/script/9J5TkYgh-OSOK-SafePad/
- type: indicator
- pine_id: PUB;f2155b8dbc134189b40f77aabf220497
- version: 1.0

## Description

OSOK SafePad is a lightweight price-level tool for marking a configurable safety buffer above and below the current reference price. It is designed for traders who want a clean visual guide for breakout, stop-entry, or event-driven execution plans without cluttering the historical chart.

[b]Key features[/b]

[list]
[*]  Plots an Upper Pad and Lower Pad around the reference price.
[*]  Configurable pad size in points.
[*]  Optional freeze mode to lock levels at the start of a chosen session window, defaulting to 8:30 New York time.
[*]  Optional take-profit and stop-loss guide levels for both long and short stop-entry scenarios.
[*]  TP and SL levels are calculated from account-currency targets using the symbol point value and order size.
[*]  Lines extend to the right for easier monitoring without leaving historical marks as new bars print.
[*]  Clean, low-saturation colour palette designed to work on both dark and light charts.
[/list]

[b]How it works[/b]

Before the freeze time, SafePad tracks the latest chart price and displays the pad levels from the current candle. When freeze mode is enabled and the chart enters the configured freeze window, the indicator captures that candle’s open as the reference price and locks the pad levels from that point onward.

For example, with a 25-point pad, the Upper Pad is drawn 25 points above the reference price and the Lower Pad is drawn 25 points below it.

[b]Take-profit and stop-loss guides[/b]

The optional TP and SL lines are derived from the configured dollar target, order size, and the symbol’s point value. These levels are visual planning aids for a hypothetical buy-stop at the Upper Pad and sell-stop at the Lower Pad.

[b]Notes and limitations[/b]

[list]
[*]  This is a visual planning indicator, not an automated trading system.
[*]  TP/SL calculations depend on TradingView’s syminfo.pointvalue; verify values for the instrument and broker feed you trade.
[*]  No trading signals, alerts, or order execution are included.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NixYoung

//@version=6
indicator("OSOK SafePad", overlay=true, max_lines_count=10)

// ──────────────────────────────────────────────────────────
// Inputs
// ──────────────────────────────────────────────────────────

// Pad
padSize   = input.float(25.0, title="Pad Size (Points)", minval=0.01, step=1.0, group="SafePad",
             tooltip="Distance in points above and below the reference price.")
orderSize = input.int(6, title="Order Size (Contracts)", minval=1, step=1, group="SafePad",
             tooltip="Number of contracts/shares per order. Used to convert USD targets to price distance.")

// Freeze
freezeOn      = input.bool(true, title="Enable Freeze", group="Freeze",
                 tooltip="Lock pad lines at the start of the session window below.")
freezeSession = input.session("0830-1659", title="Freeze Window", group="Freeze",
                 tooltip="Lines freeze at the START of this window and remain frozen for the rest of the day.")
freezeTZ      = input.string("America/New_York", title="Timezone", options=[
                 "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles",
                 "Europe/London", "Europe/Berlin", "Europe/Paris", "Europe/Moscow",
                 "Asia/Tokyo", "Asia/Hong_Kong", "Asia/Shanghai", "Asia/Singapore", "Asia/Kolkata",
                 "Australia/Sydney", "Pacific/Auckland", "UTC"],
                 group="Freeze")

// Take Profit lines
showTP = input.bool(true, title="Show Take Profit", group="Take Profit",
          tooltip="Draw take-profit level lines for both buy-stop and sell-stop entries.")
tpAmt  = input.float(3000.0, title="Target ($)", minval=0.01, step=100.0, group="Take Profit",
          tooltip="Total take-profit in account currency across all contracts.")

// Stop Loss lines
showSL = input.bool(false, title="Show Stop Loss", group="Stop Loss",
          tooltip="Draw stop-loss level lines for both buy-stop and sell-stop entries.")
slAmt  = input.float(2000.0, title="Target ($)", minval=0.01, step=100.0, group="Stop Loss",
          tooltip="Total stop-loss in account currency across all contracts.")

// ──────────────────────────────────────────────────────────
// Palette
// ──────────────────────────────────────────────────────────

color upperPadColor = color.rgb(59, 130, 246)
color lowerPadColor = color.rgb(220, 76, 70)
color takeProfitColor = color.rgb(60, 166, 120)
color stopLossColor = color.rgb(229, 168, 75)
color dataWindowColor = color.rgb(117, 128, 143)

// ──────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────

extendLine(line id, int startTime, float level, color lineColor, int lineWidth, bool dashed) =>
    if not na(id)
        line.delete(id)
    line newLine = na
    if not na(startTime) and not na(level)
        newLine := line.new(
             x1     = startTime,
             y1     = level,
             x2     = startTime + 1,
             y2     = level,
             xloc   = xloc.bar_time,
             extend = extend.right,
             color  = lineColor,
             style  = dashed ? line.style_dashed : line.style_solid,
             width  = lineWidth)
    newLine

// ──────────────────────────────────────────────────────────
// Freeze Logic
// ──────────────────────────────────────────────────────────

var float frozenPrice   = na
var bool  isFrozen      = false
var int   freezeTime     = na
var int   prevDateKey    = -1

currDateKey = year(time, freezeTZ) * 10000 + month(time, freezeTZ) * 100 + dayofmonth(time, freezeTZ)

// Reset on new calendar day in the selected timezone
if currDateKey != prevDateKey
    frozenPrice  := na
    isFrozen     := false
    freezeTime    := na
    prevDateKey  := currDateKey

// Detect whether the current bar falls inside the freeze session
inFreezeWindow = not na(time(timeframe.period, freezeSession, freezeTZ))

// Capture price on the first bar that enters the freeze window
if freezeOn and not isFrozen and inFreezeWindow
    frozenPrice  := open
    freezeTime   := time
    isFrozen     := true

// ──────────────────────────────────────────────────────────
// Compute Pad Levels
// ──────────────────────────────────────────────────────────

refPrice   = freezeOn and isFrozen and not na(frozenPrice) ? frozenPrice : close
upperLevel = refPrice + padSize
lowerLevel = refPrice - padSize

// TP / SL distances in price units (USD → points)
// e.g. NQ: pointvalue=20, orderSize=6 → $3000 / (20*6) = 25 pts
pointVal = not na(syminfo.pointvalue) and syminfo.pointvalue > 0 ? syminfo.pointvalue : 1.0
tpPoints = tpAmt / (pointVal * orderSize)
slPoints = slAmt / (pointVal * orderSize)

// Buy-stop entry at upperLevel (long)
buyTpLevel  = upperLevel + tpPoints
buySlLevel  = upperLevel - slPoints

// Sell-stop entry at lowerLevel (short)
sellTpLevel = lowerLevel - tpPoints
sellSlLevel = lowerLevel + slPoints

// ──────────────────────────────────────────────────────────
// Plots
// ──────────────────────────────────────────────────────────

lastDateKey    = year(last_bar_time, freezeTZ) * 10000 + month(last_bar_time, freezeTZ) * 100 + dayofmonth(last_bar_time, freezeTZ)
isLastDate     = currDateKey == lastDateKey
plotLevel      = isLastDate and barstate.islast
lineStartTime  = freezeOn and isFrozen and not na(freezeTime) ? freezeTime : time

plot(plotLevel ? upperLevel : na, "Upper Pad", color=upperPadColor, linewidth=2, trackprice=false, show_last=1)
plot(plotLevel ? lowerLevel : na, "Lower Pad", color=lowerPadColor, linewidth=2, trackprice=false, show_last=1)
plot(plotLevel and showTP ? buyTpLevel  : na, "Buy TP",  color=takeProfitColor, linewidth=1, trackprice=false, show_last=1)
plot(plotLevel and showTP ? sellTpLevel : na, "Sell TP", color=takeProfitColor, linewidth=1, trackprice=false, show_last=1)
plot(plotLevel and showSL ? buySlLevel  : na, "Buy SL",  color=stopLossColor, linewidth=1, trackprice=false, show_last=1)
plot(plotLevel and showSL ? sellSlLevel : na, "Sell SL", color=stopLossColor, linewidth=1, trackprice=false, show_last=1)
plot(refPrice, "Ref Price", color=color.new(dataWindowColor, 100), display=display.data_window + display.status_line)

// ──────────────────────────────────────────────────────────
// Right Extensions
// ──────────────────────────────────────────────────────────

var line upperExt  = na
var line lowerExt  = na
var line buyTpExt  = na
var line sellTpExt = na
var line buySlExt  = na
var line sellSlExt = na

if barstate.islast
    upperExt := plotLevel ? extendLine(upperExt, lineStartTime, upperLevel, upperPadColor, 2, false) : extendLine(upperExt, na, na, upperPadColor, 2, false)
    lowerExt := plotLevel ? extendLine(lowerExt, lineStartTime, lowerLevel, lowerPadColor, 2, false) : extendLine(lowerExt, na, na, lowerPadColor, 2, false)
    buyTpExt := plotLevel and showTP ? extendLine(buyTpExt, lineStartTime, buyTpLevel, takeProfitColor, 1, true) : extendLine(buyTpExt, na, na, takeProfitColor, 1, true)
    sellTpExt := plotLevel and showTP ? extendLine(sellTpExt, lineStartTime, sellTpLevel, takeProfitColor, 1, true) : extendLine(sellTpExt, na, na, takeProfitColor, 1, true)
    buySlExt := plotLevel and showSL ? extendLine(buySlExt, lineStartTime, buySlLevel, stopLossColor, 1, true) : extendLine(buySlExt, na, na, stopLossColor, 1, true)
    sellSlExt := plotLevel and showSL ? extendLine(sellSlExt, lineStartTime, sellSlLevel, stopLossColor, 1, true) : extendLine(sellSlExt, na, na, stopLossColor, 1, true)
````
