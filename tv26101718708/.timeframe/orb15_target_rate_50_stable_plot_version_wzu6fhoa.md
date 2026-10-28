# ORB15 Target Rate 50 - Stable Plot Version

- url: https://www.tradingview.com/script/Wzu6fhOA/
- type: indicator
- pine_id: PUB;bf5b693e9e594d7ebfa4219a8d374ab0
- version: 1.0

## Description

ORB15 Target Rate 50

本指标用于日内交易中的 ORB15（Opening Range Breakout 15 minutes）目标价辅助分析。

指标会自动读取当天开盘后第一根 15 分钟K线的高点与低点，计算 ORB High、ORB Low 以及 ORB Range，并根据设定的目标比例自动绘制做多与做空方向的目标价格。

默认目标比例为 50%，因此目标线计算方式如下：

做多方向：
TP1 = ORB High + ORB Range × 0.5
TP2 = ORB High + ORB Range × 1.0
TP3 = ORB High + ORB Range × 1.5

做空方向：
TP1 = ORB Low - ORB Range × 0.5
TP2 = ORB Low - ORB Range × 1.0
TP3 = ORB Low - ORB Range × 1.5

本指标适合用于日内交易中判断突破后的分批止盈位置，也可以配合成交量、MACD、VWAP、斐波那契回撤等工具进行多周期确认。

使用建议：

1. 价格突破 ORB High 后，可优先观察 Long TP1 / TP2 / TP3。
2. 价格跌破 ORB Low 后，可优先观察 Short TP1 / TP2 / TP3。
3. TP1 适合作为第一止盈参考，TP2 为标准目标，TP3 适合强趋势行情。
4. 不建议单独依赖本指标进行买卖决策，应结合趋势、成交量、市场环境和风险控制综合判断。

注意事项：
本指标仅用于技术分析和交易辅助，不构成任何投资建议。交易者应自行承担交易风险。

## Source Code

````pine
//@version=6
indicator("ORB15 Target Rate 50 - Stable Plot Version", overlay=true, max_labels_count=100)

// ==============================
// Inputs
// ==============================
groupOrb = "ORB Settings"
orbTf = input.timeframe("15", "ORB Timeframe", group=groupOrb)
timeZone = input.string("Asia/Tokyo", "Timezone", group=groupOrb)
displaySession = input.session("0915-1530", "Display Session", group=groupOrb)

groupTarget = "Target Settings"
targetRatePct = input.float(50.0, "Target Rate %", minval=1, step=1, group=groupTarget)

showOrbLines = input.bool(true, "Show ORB High / Low", group=groupTarget)
showLongTargets = input.bool(true, "Show Long Targets", group=groupTarget)
showShortTargets = input.bool(true, "Show Short Targets", group=groupTarget)
showPriceLabels = input.bool(true, "Show Price Labels", group=groupTarget)
labelOffset = input.int(5, "Label Offset Bars", minval=1, maxval=50, group=groupTarget)

groupStyle = "Style Settings"
targetTransparency = input.int(35, "Target Line Transparency", minval=0, maxval=90, group=groupStyle)

// ==============================
// ORB15 Calculation
// Same idea as:
// security(tickerid, "15", valuewhen(change(time("D")), high, 0))
// ==============================
orbHigh = request.security(
     syminfo.tickerid,
     orbTf,
     ta.valuewhen(ta.change(time("D")) != 0, high, 0),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

orbLow = request.security(
     syminfo.tickerid,
     orbTf,
     ta.valuewhen(ta.change(time("D")) != 0, low, 0),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

orbRange = orbHigh - orbLow
orbReady = timeframe.isintraday and not na(orbHigh) and not na(orbLow) and orbRange > 0

// Display only after 09:15, to avoid showing current-day ORB before the first 15-min bar is complete.
inDisplaySession = not na(time(timeframe.period, displaySession, timeZone))
showNow = orbReady and inDisplaySession

// ==============================
// Target Calculation
// ==============================
rate1 = targetRatePct / 100.0
rate2 = rate1 * 2.0
rate3 = rate1 * 3.0

longTP1 = orbHigh + orbRange * rate1
longTP2 = orbHigh + orbRange * rate2
longTP3 = orbHigh + orbRange * rate3

shortTP1 = orbLow - orbRange * rate1
shortTP2 = orbLow - orbRange * rate2
shortTP3 = orbLow - orbRange * rate3

// ==============================
// Plot ORB High / Low
// ==============================
plot(
     showOrbLines and showNow ? orbHigh : na,
     title="ORB High",
     color=color.new(color.green, 0),
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showOrbLines and showNow ? orbLow : na,
     title="ORB Low",
     color=color.new(color.red, 0),
     linewidth=2,
     style=plot.style_linebr
)

// ==============================
// Plot Long Targets
// Stable continuous plot lines
// ==============================
plot(
     showLongTargets and showNow ? longTP1 : na,
     title="Long TP1",
     color=color.new(color.teal, targetTransparency),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showLongTargets and showNow ? longTP2 : na,
     title="Long TP2",
     color=color.new(color.teal, targetTransparency),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showLongTargets and showNow ? longTP3 : na,
     title="Long TP3",
     color=color.new(color.teal, targetTransparency),
     linewidth=1,
     style=plot.style_linebr
)

// ==============================
// Plot Short Targets
// Stable continuous plot lines
// ==============================
plot(
     showShortTargets and showNow ? shortTP1 : na,
     title="Short TP1",
     color=color.new(color.orange, targetTransparency),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showShortTargets and showNow ? shortTP2 : na,
     title="Short TP2",
     color=color.new(color.orange, targetTransparency),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showShortTargets and showNow ? shortTP3 : na,
     title="Short TP3",
     color=color.new(color.orange, targetTransparency),
     linewidth=1,
     style=plot.style_linebr
)

// ==============================
// Label Function
// ==============================
f_updateLabel(label oldLabel, bool condition, float price, string labelText, color bgColor) =>
    if not na(oldLabel)
        label.delete(oldLabel)

    label newLabel = na

    if condition and not na(price)
        newLabel := label.new(
             bar_index + labelOffset,
             price,
             labelText + "  " + str.tostring(price, format.mintick),
             xloc=xloc.bar_index,
             style=label.style_label_left,
             color=bgColor,
             textcolor=color.white,
             size=size.small
        )

    newLabel

// ==============================
// Labels
// ==============================
var label lblOrbHigh = na
var label lblOrbLow = na
var label lblLong1 = na
var label lblLong2 = na
var label lblLong3 = na
var label lblShort1 = na
var label lblShort2 = na
var label lblShort3 = na

if barstate.islast
    lblOrbHigh := f_updateLabel(
         lblOrbHigh,
         showPriceLabels and showOrbLines and showNow,
         orbHigh,
         "ORB High",
         color.new(color.green, 0)
    )

    lblOrbLow := f_updateLabel(
         lblOrbLow,
         showPriceLabels and showOrbLines and showNow,
         orbLow,
         "ORB Low",
         color.new(color.red, 0)
    )

    lblLong1 := f_updateLabel(
         lblLong1,
         showPriceLabels and showLongTargets and showNow,
         longTP1,
         "Long TP1",
         color.new(color.teal, 0)
    )

    lblLong2 := f_updateLabel(
         lblLong2,
         showPriceLabels and showLongTargets and showNow,
         longTP2,
         "Long TP2",
         color.new(color.teal, 0)
    )

    lblLong3 := f_updateLabel(
         lblLong3,
         showPriceLabels and showLongTargets and showNow,
         longTP3,
         "Long TP3",
         color.new(color.teal, 0)
    )

    lblShort1 := f_updateLabel(
         lblShort1,
         showPriceLabels and showShortTargets and showNow,
         shortTP1,
         "Short TP1",
         color.new(color.orange, 0)
    )

    lblShort2 := f_updateLabel(
         lblShort2,
         showPriceLabels and showShortTargets and showNow,
         shortTP2,
         "Short TP2",
         color.new(color.orange, 0)
    )

    lblShort3 := f_updateLabel(
         lblShort3,
         showPriceLabels and showShortTargets and showNow,
         shortTP3,
         "Short TP3",
         color.new(color.orange, 0)
    )
````
