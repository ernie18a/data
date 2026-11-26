# 50-MA Extension Dot [ATR / % / Points]

- url: https://www.tradingview.com/script/b0BzhMTP-50-MA-Extension-Dot-ATR-Points/
- type: indicator
- pine_id: PUB;1f9b6f852eb9493699c99a523d92cf55
- version: 1.0

## Description

50-MA Extension Dot [ATR / % / Points] marks when price has moved a defined distance above a daily moving-average anchor. The goal of the script is to help traders study when price becomes extended relative to its daily trend structure, rather than judging a move by price alone.

The script supports three extension methods: ATR Extension, Percent, and Points. ATR Extension compares the distance from price to the daily moving average against the instrument’s daily ATR, making the reading volatility-adjusted. Percent mode measures how far price is above the moving average in percentage terms. Points mode measures the raw point distance above the moving-average anchor.

The moving-average type, moving-average length, threshold method, threshold value, ATR length, and extension source are customizable so traders can study past moves and build their own rules. For example, users can test how a symbol historically behaved when it became one ATR, two ATRs, a fixed percentage, or a fixed point distance above its daily moving-average reference.

When the selected threshold is reached, the script plots a small dot above the candle. The dot is not a standalone buy or sell signal. It is a visual marker showing that price has reached a defined extension zone relative to the chosen daily moving-average reference.

The script can also display the daily moving average, an optional threshold line, and a small table showing the current daily moving average, daily ATR, extension price, percentage distance from the moving average, ATR percentage, and ATR extension value.

This tool is useful for studying stretched moves, breakout extensions, momentum exhaustion, and conditions where price may be moving too far too quickly above its daily trend anchor. Because different symbols have different volatility profiles, the customizable inputs allow traders to compare past extensions and develop rules that fit their own process.

This indicator does not predict future price movement. It is a contextual extension tool designed to measure distance from a daily trend reference and help traders research historical extension behavior.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MysticMads

//@version=6
indicator("50-MA Extension Dot [ATR / % / Points]", overlay=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
maType   = input.string("EMA", "MA Type", options=["EMA", "SMA"])
maLength = input.int(50, "MA Length", minval=1)

thresholdMode = input.string("ATR Extension", "Threshold Mode", options=["ATR Extension", "Percent", "Points"])
threshold      = input.float(1.0, "Threshold Above Daily MA", minval=0.0, step=0.1)

atrLength = input.int(14, "Daily ATR Length", minval=1)

maSrc        = input.source(close, "Daily MA Source")
extensionSrc = input.source(high, "Extension Price Source")

showMA        = input.bool(true, "Show Daily MA")
showThreshold = input.bool(false, "Show Threshold Line")
showTable     = input.bool(true, "Show Table")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Daily MA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dailyMA = request.security(
     syminfo.tickerid,
     "D",
     maType == "EMA" ? ta.ema(maSrc, maLength) : ta.sma(maSrc, maLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Daily ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dailyATR = request.security(
     syminfo.tickerid,
     "D",
     ta.atr(atrLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Extension Calculations
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
extensionPrice = extensionSrc

distanceFromMA = extensionPrice - dailyMA

percentAwayFromMA = dailyMA != 0 ? distanceFromMA / dailyMA * 100 : na

atrPercent = extensionPrice != 0 ? dailyATR / extensionPrice * 100 : na

percentRatioAtrExtension = atrPercent != 0 ? percentAwayFromMA / atrPercent : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Threshold Level For Visual Plot
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dailyThreshold = switch thresholdMode
    "ATR Extension" => dailyMA * (1 + ((dailyATR / extensionPrice) * threshold))
    "Percent"       => dailyMA * (1 + threshold / 100)
    "Points"        => dailyMA + threshold

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Correct Dot Condition
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
condition = switch thresholdMode
    "ATR Extension" => percentRatioAtrExtension >= threshold
    "Percent"       => percentAwayFromMA >= threshold
    "Points"        => distanceFromMA >= threshold

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(
     showMA ? dailyMA : na,
     title="Daily MA",
     color=color.orange,
     linewidth=2
)

plot(
     showThreshold ? dailyThreshold : na,
     title="Threshold Line",
     color=color.new(color.orange, 60),
     linewidth=1
)

plotshape(
     condition,
     title="Above Daily MA Threshold",
     style=shape.circle,
     location=location.abovebar,
     size=size.tiny,
     color=color.rgb(230, 234, 89)
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table t = table.new(position.top_right, 2, 6, border_width=1)

if barstate.islast
    if showTable
        table.cell(t, 0, 0, "Daily MA", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 0, str.tostring(dailyMA, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(t, 0, 1, "Daily ATR", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 1, str.tostring(dailyATR, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(t, 0, 2, "Ext Price", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 2, str.tostring(extensionPrice, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(t, 0, 3, "% Away MA", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 3, str.tostring(percentAwayFromMA, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(t, 0, 4, "ATR %", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 4, str.tostring(atrPercent, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.black, 0))

        table.cell(t, 0, 5, "ATR Ext", text_color=color.white, bgcolor=color.new(color.black, 0))
        table.cell(t, 1, 5, str.tostring(percentRatioAtrExtension, "#.##") + "x", text_color=color.lime, bgcolor=color.new(color.black, 0))
    else
        table.clear(t, 0, 0, 1, 5)
````
