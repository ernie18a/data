<!-- tradingview-pine-id: PUB;9366d8c39bdc4d209fdaebc47faa4e50 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BT Trend Quality

Source: https://www.tradingview.com/script/JfnlXnsb/

## Description

BT Trend Quality

Four market measurements in one compact panel: EMA/DEMA separation, relative volume, directional movement spread, and distance above the previous lookback high.

This free indicator keeps each measurement visible separately. It does not generate buy/sell signals, price targets, position sizes, or a combined probability score.

What It Measures

EMA/DEMA separation: Percentage distance between EMA9 and DEMA200. Default threshold: ≥0.30%.

Relative volume: Current bar volume divided by its 20-bar simple average, including the current bar. Default threshold: >1.10×.

DI spread: DI+ minus DI−, using a 14-period directional movement calculation. Default threshold: ≥10.

Prior-high distance: Closing price relative to the highest high of the preceding 10 bars. The current bar is excluded from the reference high. Default threshold: >0.10%.

ADX is displayed separately for context. All lengths and thresholds are adjustable. The defaults are reference settings, not universally optimal parameters.

Display and Alerts

Four historical rows show whether each measurement meets its threshold. The table displays the latest confirmed values. Missing data and insufficient history are marked N/A, rather than treated as a failed condition.

Calculations use the chart’s timeframe. Ten bars represent ten days only on a daily chart. With default settings, the indicator requires 400 preceding bars before displaying its measurements.

Each measurement offers a separate alert for threshold-state changes in either direction, evaluated at bar close. During an unfinished candle, the table retains the previous confirmed values. Users must create their alerts through TradingView.

An alert describes a change in a measurement, not an instruction to trade. The thresholds focus on upward expansion and positive directional separation; a value below a threshold is not a short signal.

Purpose and Limitations

These are established technical-analysis calculations, not newly invented indicators. This implementation brings them together while preserving their individual values, making it easier to compare trend structure, participation, and directional movement without an opaque combined score.

No claim is made that this combination is unique or outperforms other tools. Historical research on a separate strategy does not establish this indicator’s future performance.

Data-provider differences, price adjustments, historical revisions, and missing volume can affect readings. Use standard price charts when comparing calculations.

This is an analytical tool, not personalized investment advice. It does not predict future prices or guarantee trading outcomes.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gregorfun

//@version=6
indicator("BT Trend Quality")
plot(close)
fastLength = input.int(9, "EMA length", minval=1, maxval=500, group="Structure")
slowLength = input.int(200, "DEMA length", minval=2, maxval=500, group="Structure")
separationLimit = input.float(0.30, "Separation threshold (%)", minval=0, step=0.05, group="Structure")
breakoutLength = input.int(10, "Prior high lookback", minval=1, maxval=500, group="Structure")
breakoutBuffer = input.float(0.10, "Prior high buffer (%)", minval=0, step=0.05, group="Structure")
volumeLength = input.int(20, "Volume average length", minval=2, maxval=500, group="Participation")
volumeLimit = input.float(1.10, "Relative volume threshold", minval=0, step=0.05, group="Participation")
diLength = input.int(14, "DI length", minval=2, maxval=100, group="Direction")
adxLength = input.int(14, "ADX smoothing", minval=2, maxval=100, group="Direction")
spreadLimit = input.float(10.0, "DI+ minus DI- threshold", minval=0, step=1, group="Direction")
fast = ta.ema(close, fastLength)
slowEma = ta.ema(close, slowLength)
slow = 2 * slowEma - ta.ema(slowEma, slowLength)
priorHigh = ta.highest(high, breakoutLength)[1]
meanVolume = ta.sma(volume, volumeLength)
[diPlus, diMinus, adx] = ta.dmi(diLength, adxLength)
separation = slow > 0 ? 100 * (fast - slow) / slow : na
highDistance = priorHigh > 0 ? 100 * (close / priorHigh - 1) : na
relativeVolume = not na(volume) and meanVolume > 0 ? volume / meanVolume : na
spread = diPlus - diMinus
warmup = math.max(2 * math.max(slowLength, fastLength), math.max(breakoutLength + 1, math.max(volumeLength, diLength + adxLength)))
ready = bar_index >= warmup
// -1 denotes unavailable data; it must never silently become a failed filter.
state(float value, float threshold, bool inclusive) =>
    not ready or na(value) ? -1 : (inclusive ? value >= threshold : value > threshold) ? 1 : 0
sepState = state(separation, separationLimit, true)
volState = state(relativeVolume, volumeLimit, false)
diState = state(spread, spreadLimit, true)
highState = state(highDistance, breakoutBuffer, false)
changed(int value) =>
    barstate.isconfirmed and value >= 0 and value[1] >= 0 and value != value[1]
alertcondition(changed(sepState), "Separation state changed", "Trend Quality: EMA/DEMA separation state changed at bar close. {{ticker}} {{interval}}")
alertcondition(changed(volState), "Relative volume state changed", "Trend Quality: relative volume state changed at bar close. {{ticker}} {{interval}}")
alertcondition(changed(diState), "DI spread state changed", "Trend Quality: DI spread state changed at bar close. {{ticker}} {{interval}}")
alertcondition(changed(highState), "Prior high state changed", "Trend Quality: prior high distance state changed at bar close. {{ticker}} {{interval}}")
tone(int value, color active) =>
    value < 0 ? color.new(color.gray, 80) : value == 1 ? active : color.new(color.gray, 55)
plot(barstate.isconfirmed and ready ? 4 : na, "EMA/DEMA separation lane", tone(sepState, color.teal), 4, plot.style_circles)
plot(barstate.isconfirmed and ready ? 3 : na, "Relative volume lane", tone(volState, color.blue), 4, plot.style_circles)
plot(barstate.isconfirmed and ready ? 2 : na, "DI spread lane", tone(diState, color.green), 4, plot.style_circles)
plot(barstate.isconfirmed and ready ? 1 : na, "Prior high lane", tone(highState, color.fuchsia), 4, plot.style_circles)
plot(5, "Upper margin", color.new(color.gray, 100), editable=false)
plot(0, "Lower margin", color.new(color.gray, 100), editable=false)
// Live table/data-window values remain on the latest closed bar.
offset = barstate.isconfirmed ? 0 : 1
shownSeparation = ready[offset] ? separation[offset] : na
shownVolume = ready[offset] ? relativeVolume[offset] : na
shownSpread = ready[offset] ? spread[offset] : na
shownHigh = ready[offset] ? highDistance[offset] : na
plot(shownSeparation, "Separation (%)", display=display.data_window)
plot(shownVolume, "Relative volume (x)", display=display.data_window)
plot(shownSpread, "DI+ minus DI-", display=display.data_window)
plot(shownHigh, "Distance above prior high (%)", display=display.data_window)
plot(ready[offset] ? adx[offset] : na, "ADX context", display=display.data_window)
formatValue(float value, string unit) =>
    na(value) ? "N/A" : str.tostring(value, "#.00") + unit
var table panel = table.new(position.top_right, 3, 6, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.new(color.gray, 65))
row(int index, string label, float value, string unit, int status, color active) =>
    table.cell(panel, 0, index, label, text_color=color.white, text_size=size.small)
    table.cell(panel, 1, index, formatValue(value, unit), text_color=color.white, text_size=size.small)
    table.cell(panel, 2, index, status < 0 ? "N/A" : status == 1 ? "Above" : "Below", bgcolor=tone(status, active), text_color=color.white, text_size=size.small)
if barstate.islast
    table.cell(panel, 0, 0, "bot-trade.de", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 0, "Closed bar", text_color=color.silver, text_size=size.small)
    table.cell(panel, 2, 0, timeframe.period, text_color=color.silver, text_size=size.small)
    row(1, "4 | Separation", shownSeparation, "%", sepState[offset], color.teal)
    row(2, "3 | Relative volume", shownVolume, "x", volState[offset], color.blue)
    row(3, "2 | DI spread", shownSpread, "", diState[offset], color.green)
    row(4, "1 | Prior high", shownHigh, "%", highState[offset], color.fuchsia)
    table.cell(panel, 0, 5, "ADX", text_color=color.silver, text_size=size.small)
    table.cell(panel, 1, 5, formatValue(ready[offset] ? adx[offset] : na, ""), text_color=color.silver, text_size=size.small)
    table.cell(panel, 2, 5, ready[offset] ? "Context" : "Warmup", text_color=color.silver, text_size=size.small)
````
