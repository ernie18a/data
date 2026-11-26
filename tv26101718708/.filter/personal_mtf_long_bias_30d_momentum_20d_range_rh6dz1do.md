# Personal MTF Long Bias - 30D Momentum / 20D Range

- url: https://www.tradingview.com/script/rh6Dz1do/
- type: indicator
- pine_id: PUB;f2a4c3a18bb84dbc861d34f2d899bb47
- version: 1.0

## Description

MTF Long Bias is a higher-timeframe context indicator designed for discretionary long-side trading.

The script combines two simple filters:

1. 30D Momentum
Checks whether the confirmed higher-timeframe close is above or below the close from 30 bars ago. This is used as a simple momentum filter, not as a moving average.

2. 20D Range Position
Shows where current price sits inside the recent 20-bar high/low range. The default zones are:
- Bottom zone: lower 35%
- Top zone: upper 20%
- Middle zone: everything between them

The main idea is to separate market context from entry timing:
- 30D momentum defines whether long trades are favored or avoided.
- 20D range position helps identify whether price is near an extreme or in the middle.
- The final Long Bias table summarizes the condition as LONG OK, WAIT, or AVOID.

Default behavior:
- Uses confirmed daily data by default to reduce repainting.
- Shows the 20D range zones on the chart.
- Keeps the 30D momentum base optional through display modes.
- Labels and background colors are off by default to keep the chart clean.

This indicator is not an automated buy/sell system. LONG OK means the higher-timeframe context allows long setups, but actual entries, stops, position sizing, and risk management should be decided separately.

## Source Code

````pine
//@version=6
indicator("Personal MTF Long Bias - 30D Momentum / 20D Range", overlay=true, max_labels_count=500)

// This indicator visualizes the trade filters derived from the 2026-05-24 OKX analysis:
// 1. Longs work better when the higher-timeframe 30-bar return is positive.
// 2. Entries are cleaner near the higher-timeframe 20-bar range top 20% or bottom 35%.
// 3. Moving averages are confirmation only, not the primary trigger.

filterTf = input.timeframe("D", "Filter timeframe", group="Higher-timeframe filter")
confirmedOnly = input.bool(true, "Use confirmed HTF candles", group="Higher-timeframe filter", tooltip="ON uses the previous completed higher-timeframe candle. OFF includes the currently forming higher-timeframe candle.")
trendLen = input.int(30, "Trend lookback", minval=2, group="Higher-timeframe filter")
rangeLen = input.int(20, "Range lookback", minval=2, group="Higher-timeframe filter")
bottomPct = input.float(35.0, "Bottom zone %", minval=1.0, maxval=49.0, step=0.5, group="Range zones")
topPct = input.float(20.0, "Top zone %", minval=1.0, maxval=49.0, step=0.5, group="Range zones")
maType = input.string("SMA", "MA type", options=["SMA", "EMA"], group="Moving averages")
htfFastMaLen = input.int(20, "HTF fast MA", minval=1, group="Moving averages")
htfSlowMaLen = input.int(30, "HTF slow MA", minval=1, group="Moving averages")
entryFastMaLen = input.int(20, "Chart fast MA", minval=1, group="Entry timeframe")
entrySlowMaLen = input.int(30, "Chart slow MA", minval=1, group="Entry timeframe")
displayMode = input.string("Range only", "Chart display mode", options=["Range only", "Trend only", "Both", "Table only"], group="Display", tooltip="Range only keeps the 20-bar range zones on chart. Trend only shows only the 30-bar momentum base. Both is for review. Table only hides all chart overlays from this indicator.")
showRange = input.bool(true, "Show HTF range zones", group="Display")
showTrendBase = input.bool(true, "Show 30D momentum base", group="Display", tooltip="Shows the higher-timeframe close from 30 bars before the confirmed filter candle. Momentum is UP when the confirmed HTF close is above this line.")
showHtfMas = input.bool(false, "Show HTF MAs", group="Display")
showEntryMas = input.bool(false, "Show chart MAs", group="Display")
showBackground = input.bool(false, "Color background by long bias", group="Display")
showSignals = input.bool(false, "Show historical bias change labels", group="Display", tooltip="OFF keeps the chart clean. Turn ON only when reviewing past filter-state changes.")

f_ma(float src, int len) =>
    maType == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

f_pct(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.0") + "%"

f_price(float value) =>
    na(value) ? "n/a" : str.tostring(value, format.mintick)

[htfClose, htfTrendBase, htfRangeHigh, htfRangeLow, htfFastMa, htfSlowMa] = request.security(syminfo.tickerid, filterTf, [confirmedOnly ? close[1] : close, confirmedOnly ? close[trendLen + 1] : close[trendLen], confirmedOnly ? ta.highest(high, rangeLen)[1] : ta.highest(high, rangeLen), confirmedOnly ? ta.lowest(low, rangeLen)[1] : ta.lowest(low, rangeLen), confirmedOnly ? f_ma(close, htfFastMaLen)[1] : f_ma(close, htfFastMaLen), confirmedOnly ? f_ma(close, htfSlowMaLen)[1] : f_ma(close, htfSlowMaLen)], barmerge.gaps_off, barmerge.lookahead_off)

rangeWidth = htfRangeHigh - htfRangeLow
rangePctRaw = rangeWidth > 0 ? (close - htfRangeLow) / rangeWidth * 100.0 : na
topStartPct = 100.0 - topPct
bottomLevel = htfRangeLow + rangeWidth * bottomPct / 100.0
topLevel = htfRangeLow + rangeWidth * topStartPct / 100.0

trendReturnPct = htfTrendBase != 0 and not na(htfTrendBase) ? (htfClose / htfTrendBase - 1.0) * 100.0 : na
trendUp = not na(trendReturnPct) and trendReturnPct > 0
trendDown = not na(trendReturnPct) and trendReturnPct < 0
inBottom = not na(rangePctRaw) and rangePctRaw <= bottomPct
inTop = not na(rangePctRaw) and rangePctRaw >= topStartPct
inMiddle = not inBottom and not inTop and not na(rangePctRaw)
ready = not na(trendReturnPct) and not na(rangePctRaw)

longOk = ready and trendUp and (inTop or inBottom)
longWait = ready and trendUp and inMiddle
longAvoid = ready and trendDown
longOkStart = longOk and not longOk[1]
longWaitStart = longWait and not longWait[1]
longAvoidStart = longAvoid and not longAvoid[1]

entryFastMa = f_ma(close, entryFastMaLen)
entrySlowMa = f_ma(close, entrySlowMaLen)
entryMaBull = close > entryFastMa and entryFastMa >= entrySlowMa
entryMaBear = close < entryFastMa and entryFastMa <= entrySlowMa
trendBaseColor = color.rgb(0, 0, 0)
showRangeOnChart = showRange and (displayMode == "Range only" or displayMode == "Both")
showTrendBaseOnChart = showTrendBase and (displayMode == "Trend only" or displayMode == "Both")
showHtfMasOnChart = showHtfMas and displayMode != "Table only"
showEntryMasOnChart = showEntryMas and displayMode != "Table only"

pHigh = plot(showRangeOnChart ? htfRangeHigh : na, "HTF range high", color=color.new(color.gray, 35), linewidth=1, style=plot.style_stepline)
pTop = plot(showRangeOnChart ? topLevel : na, "HTF top zone start", color=color.new(color.teal, 0), linewidth=1, style=plot.style_stepline)
pBottom = plot(showRangeOnChart ? bottomLevel : na, "HTF bottom zone end", color=color.new(color.orange, 0), linewidth=1, style=plot.style_stepline)
pLow = plot(showRangeOnChart ? htfRangeLow : na, "HTF range low", color=color.new(color.gray, 35), linewidth=1, style=plot.style_stepline)
fill(pHigh, pTop, color=showRangeOnChart ? color.new(color.teal, 88) : na, title="Top 20% zone")
fill(pBottom, pLow, color=showRangeOnChart ? color.new(color.orange, 88) : na, title="Bottom 35% zone")

plot(showTrendBaseOnChart ? htfTrendBase : na, "HTF 30-bar momentum base", color=trendBaseColor, linewidth=1, style=plot.style_stepline)
plot(showHtfMasOnChart ? htfFastMa : na, "HTF fast MA", color=color.new(color.yellow, 0), linewidth=2, style=plot.style_stepline)
plot(showHtfMasOnChart ? htfSlowMa : na, "HTF slow MA", color=color.new(color.fuchsia, 0), linewidth=2, style=plot.style_stepline)
plot(showEntryMasOnChart ? entryFastMa : na, "Chart fast MA", color=color.new(color.blue, 0), linewidth=1)
plot(showEntryMasOnChart ? entrySlowMa : na, "Chart slow MA", color=color.new(color.purple, 0), linewidth=1)

biasColor = not ready ? color.new(color.gray, 92) : longOk ? color.new(color.green, 88) : longWait ? color.new(color.yellow, 90) : color.new(color.red, 90)
bgcolor(showBackground ? biasColor : na, title="Long bias background")

plotshape(showSignals and longOkStart, title="Long bias OK", text="LONG\nOK", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), textcolor=color.white, size=size.tiny)
plotshape(showSignals and longAvoidStart, title="Long bias avoid", text="AVOID\nLONG", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny)

alertcondition(longOkStart, "Long bias turns OK", "Long bias turned OK on {{ticker}} {{interval}}.")
alertcondition(longWaitStart, "Long bias turns WAIT", "Long bias turned WAIT on {{ticker}} {{interval}} because price entered the middle of the higher-timeframe range.")
alertcondition(longAvoidStart, "Long bias turns AVOID", "Long bias turned AVOID on {{ticker}} {{interval}}.")

trendText = not ready ? "Not enough data" : trendUp ? "UP: longs allowed" : trendDown ? "DOWN: avoid longs" : "Flat"
rangeText = not ready ? "Not enough data" : inTop ? "Top zone" : inBottom ? "Bottom zone" : "Middle zone"
biasText = not ready ? "WAIT" : longOk ? "LONG OK" : longWait ? "WAIT" : "AVOID"
entryMaText = entryMaBull ? "Bullish" : entryMaBear ? "Bearish" : "Mixed"

headerBg = color.rgb(246, 248, 251)
rowBg = color.rgb(255, 255, 255)
mutedRowBg = color.rgb(249, 250, 252)
biasBg = not ready ? color.rgb(238, 241, 245) : longOk ? color.rgb(224, 247, 232) : longWait ? color.rgb(255, 246, 222) : color.rgb(255, 232, 235)
biasTextColor = not ready ? color.rgb(31, 35, 42) : longOk ? color.rgb(18, 115, 62) : longWait ? color.rgb(139, 99, 16) : color.rgb(178, 39, 52)
textMain = color.rgb(31, 35, 42)
textMuted = color.rgb(92, 99, 112)

var table statusTable = table.new(position.top_right, 2, 7, frame_color=color.rgb(210, 215, 223), frame_width=1, border_color=color.rgb(224, 228, 235), border_width=1)

if barstate.islast
    table.cell(statusTable, 0, 0, "Filter TF", text_color=textMain, bgcolor=headerBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 1, 0, filterTf + (confirmedOnly ? " confirmed" : " live"), text_color=textMain, bgcolor=headerBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 0, 1, str.tostring(trendLen) + "D momentum", text_color=textMuted, bgcolor=rowBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 1, 1, trendText + " (" + f_pct(trendReturnPct) + ")", text_color=textMain, bgcolor=rowBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 0, 2, str.tostring(rangeLen) + "D range", text_color=textMuted, bgcolor=mutedRowBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 1, 2, rangeText + " (" + f_pct(rangePctRaw) + ")", text_color=textMain, bgcolor=mutedRowBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 0, 3, "Range high/low", text_color=textMuted, bgcolor=rowBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 1, 3, f_price(htfRangeHigh) + " / " + f_price(htfRangeLow), text_color=textMain, bgcolor=rowBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 0, 4, "Chart MA", text_color=textMuted, bgcolor=mutedRowBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 1, 4, entryMaText, text_color=textMain, bgcolor=mutedRowBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 0, 5, "Long bias", text_color=biasTextColor, bgcolor=biasBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 1, 5, biasText, text_color=biasTextColor, bgcolor=biasBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 0, 6, "Rule", text_color=textMuted, bgcolor=headerBg, text_halign=text.align_left, text_size=size.small)
    table.cell(statusTable, 1, 6, "30D up + top/bottom only", text_color=textMain, bgcolor=headerBg, text_halign=text.align_left, text_size=size.small)
````
