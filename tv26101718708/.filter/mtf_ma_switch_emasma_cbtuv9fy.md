# MTF MA Switch (EMA/SMA)

- url: https://www.tradingview.com/script/cBtuV9fy/
- type: indicator
- pine_id: PUB;0699721953d446db963eae3a6dd0466c
- version: 1.0

## Description

MTF MA Switch (EMA/SMA)

MTF MA Switch is a simple and flexible moving average indicator that displays up to six moving averages directly on the price chart.

The indicator shows four moving averages from the current chart timeframe and two additional moving averages from user-selectable timeframes. The moving average type can be switched globally between EMA and SMA.

Features:
- 4 moving averages based on the current chart timeframe
- 2 multi-timeframe moving averages
- Global EMA/SMA switch
- Customizable lengths, colors and timeframes
- Optional confirmed higher timeframe calculation to reduce repainting
- Works on any chart timeframe

The multi-timeframe moving averages can be used to display important higher timeframe levels, such as daily or weekly moving averages, while trading on lower timeframes.

Example:
If you are viewing a 5-minute chart, the indicator can display four moving averages from the 5-minute timeframe and additionally show the daily EMA 20 and daily EMA 10.

Repainting note:
When "Use Confirmed Higher Timeframe Bars" is enabled, the indicator uses the last confirmed higher timeframe bar for MTF moving averages. This helps avoid repainting on lower timeframes. If the selected MTF timeframe matches the current chart timeframe, no offset is applied.

This indicator is intended for trend analysis, multi-timeframe context, support and resistance observation, and discretionary trading setups.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © P_auf_i

//@version=5
indicator(title="MTF MA Switch (EMA/SMA)", shorttitle="MTF MA", overlay=true)

// ─────────────────────────────────────────────
// 1. INPUTS
// ─────────────────────────────────────────────

// General settings
maTypeInput = input.string(title="MA Type", defval="EMA", options=["EMA", "SMA"], group="General Settings")
src = input.source(close, title="Source", group="General Settings")
useConfirmedHTF = input.bool(true, title="Use Confirmed Higher Timeframe Bars", group="General Settings", tooltip="Enabled: MTF moving averages use the last confirmed higher timeframe bar to avoid repainting on lower timeframes. Disabled: MTF moving averages use the current, still developing higher timeframe value.")

// ─────────────────────────────────────────────
// 2. CURRENT TIMEFRAME — 4 MA
// ─────────────────────────────────────────────

groupCurrent = "Current Timeframe Moving Averages"

showMA1 = input.bool(true, title="Show MA 1", group=groupCurrent)
lenMA1 = input.int(200, title="MA 1 Length", minval=1, group=groupCurrent)
colMA1 = input.color(color.red, title="MA 1 Color", group=groupCurrent)

showMA2 = input.bool(true, title="Show MA 2", group=groupCurrent)
lenMA2 = input.int(100, title="MA 2 Length", minval=1, group=groupCurrent)
colMA2 = input.color(color.blue, title="MA 2 Color", group=groupCurrent)

showMA3 = input.bool(true, title="Show MA 3", group=groupCurrent)
lenMA3 = input.int(50, title="MA 3 Length", minval=1, group=groupCurrent)
colMA3 = input.color(color.green, title="MA 3 Color", group=groupCurrent)

showMA4 = input.bool(true, title="Show MA 4", group=groupCurrent)
lenMA4 = input.int(10, title="MA 4 Length", minval=1, group=groupCurrent)
colMA4 = input.color(color.yellow, title="MA 4 Color", group=groupCurrent)


// ─────────────────────────────────────────────
// 3. MULTI-TIMEFRAME — 2 MA
// ─────────────────────────────────────────────

groupMTF = "Multi-Timeframe Moving Averages"

showMTF1 = input.bool(true, title="Show MTF MA 1", group=groupMTF)
tfMTF1 = input.timeframe("D", title="MTF MA 1 Timeframe", group=groupMTF)
lenMTF1 = input.int(20, title="MTF MA 1 Length", minval=1, group=groupMTF)
colMTF1 = input.color(color.fuchsia, title="MTF MA 1 Color", group=groupMTF)

showMTF2 = input.bool(true, title="Show MTF MA 2", group=groupMTF)
tfMTF2 = input.timeframe("D", title="MTF MA 2 Timeframe", group=groupMTF)
lenMTF2 = input.int(10, title="MTF MA 2 Length", minval=1, group=groupMTF)
colMTF2 = input.color(color.orange, title="MTF MA 2 Color", group=groupMTF)


// ─────────────────────────────────────────────
// 4. FUNCTIONS
// ─────────────────────────────────────────────

calcMA(_source, _length, _maType) =>
    _maType == "EMA" ? ta.ema(_source, _length) : ta.sma(_source, _length)

calcMTFMA(_timeframe, _length, _maType, _confirmed) =>
    sameTF = timeframe.period == _timeframe
    request.security(syminfo.tickerid, _timeframe, sameTF ? calcMA(src, _length, _maType) : (_confirmed ? calcMA(src, _length, _maType)[1] : calcMA(src, _length, _maType)), lookahead=barmerge.lookahead_off)


// ─────────────────────────────────────────────
// 5. CALCULATIONS
// ─────────────────────────────────────────────

// Current timeframe moving averages
ma1 = calcMA(src, lenMA1, maTypeInput)
ma2 = calcMA(src, lenMA2, maTypeInput)
ma3 = calcMA(src, lenMA3, maTypeInput)
ma4 = calcMA(src, lenMA4, maTypeInput)

// Multi-timeframe moving averages
mtfMA1 = calcMTFMA(tfMTF1, lenMTF1, maTypeInput, useConfirmedHTF)
mtfMA2 = calcMTFMA(tfMTF2, lenMTF2, maTypeInput, useConfirmedHTF)


// ─────────────────────────────────────────────
// 6. PLOTS
// ─────────────────────────────────────────────

// Current timeframe plots
plot(showMA1 ? ma1 : na, title="Current TF MA 1", color=colMA1, linewidth=2)
plot(showMA2 ? ma2 : na, title="Current TF MA 2", color=colMA2, linewidth=1)
plot(showMA3 ? ma3 : na, title="Current TF MA 3", color=colMA3, linewidth=1)
plot(showMA4 ? ma4 : na, title="Current TF MA 4", color=colMA4, linewidth=1)

// Multi-timeframe plots
plot(showMTF1 ? mtfMA1 : na, title="MTF MA 1", color=colMTF1, linewidth=2, style=plot.style_linebr)
plot(showMTF2 ? mtfMA2 : na, title="MTF MA 2", color=colMTF2, linewidth=2, style=plot.style_linebr)
````
