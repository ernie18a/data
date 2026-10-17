#  Micro Pivot 

- url: https://www.tradingview.com/script/Zk1xmQbV-Micro-Pivot/
- type: indicator
- pine_id: PUB;98327a9240a6401b9de1755541fc4856
- version: 1.0

## Description

[b]Short description:[/b]
A structure-based intraday framework that highlights small pivot points where price may be transitioning from continuation to rejection, or from pullback to renewed directional control.

[b]Full description:[/b]
The TM Micro Pivot Framework is a research and validation tool for studying short-term market structure. It is designed to help traders identify compact swing points, local support/resistance reactions, and potential continuation or rejection zones on intraday charts.

This concept focuses on micro pivots: small but meaningful inflection areas that can appear before larger directional moves. Rather than treating every minor swing as important, the framework is intended to organize price action around repeatable structure: prior swing highs/lows, reaction zones, trend context, volatility, and invalidation levels.

[b]Core use cases:[/b]
- Identify local intraday pivot highs and pivot lows.
- Mark potential reaction zones where price may pause, reject, or continue.
- Study pullback behavior inside a larger trend context.
- Compare aggressive early structure signals against more conservative confirmation signals.
- Support forward testing and strategy research before any live execution decision.

[b]How to read it:[/b]
A bullish micro pivot area may form when price creates a local low, holds above a prior reaction zone, and begins to reclaim short-term structure. A bearish micro pivot area may form when price creates a local high, rejects a prior reaction zone, and begins to lose short-term structure.

Signals and plots are not trade recommendations. They are visual research markers intended to help traders study whether specific structure conditions are present.

[b]Suggested validation workflow:[/b]
1. Start with the higher-timeframe trend and key levels.
2. Use the micro pivot markers to identify local structure changes.
3. Define invalidation before considering any setup.
4. Forward test the behavior in a controlled environment.
5. Review results over a meaningful sample before making execution decisions.

[b]Important notes:[/b]
- This tool does not predict market direction.
- This tool does not guarantee profitable trades.
- This tool should not be used as a standalone trading system.
- Market conditions, liquidity, volatility, news, and execution quality can materially affect outcomes.
- Any strategy based on this concept should be tested and validated before use.

[b]Risk disclaimer:[/b]
Trading futures, stocks, options, forex, crypto, and other financial instruments involves substantial risk and may not be suitable for all traders. Past performance is not indicative of future results. This script is provided for educational and research purposes only and should not be considered financial advice, investment advice, or a recommendation to buy or sell any instrument. Traders are responsible for their own decisions, risk management, and compliance with applicable rules and regulations.

[b]Publication note:[/b]
This description is written for TradingView educational/research presentation. It avoids performance claims, guaranteed outcomes, financial advice, and unverifiable profitability language.

## Source Code

````pine
//@version=5
indicator("TM Micro Pivot Map — Futures", overlay=true, max_lines_count=80, max_labels_count=80)

// Trade Manager original adaptation inspired by public EMA/pivot target mapping concepts.
// Built for NQ/ES/MNQ/MES intraday chart work. Educational/research only. Not financial advice.

gBias = "Bias Ribbon"
fastLen = input.int(13, "Fast EMA", minval=2, group=gBias)
slowLen = input.int(34, "Slow EMA", minval=5, group=gBias)
neutralTicks = input.int(12, "Neutral ribbon width, ticks", minval=1, group=gBias)

gPivot = "Micro Pivot Map"
pivotLen = input.int(3, "Pivot strength", minval=1, maxval=10, group=gPivot)
clusterTicks = input.int(10, "Cluster proximity, ticks", minval=1, group=gPivot)
maxLevels = input.int(12, "Max active levels", minval=4, maxval=30, group=gPivot)
showTargets = input.bool(true, "Show 1:1 / 1:2 target bands", group=gPivot)

bull = color.rgb(0,217,192)
bear = color.rgb(255,0,127)
warn = color.rgb(255,215,0)
muted = color.rgb(138,138,138)

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)
ribbonTicks = math.abs(emaFast - emaSlow) / syminfo.mintick
bullBias = emaFast > emaSlow and close > emaFast and ribbonTicks > neutralTicks
bearBias = emaFast < emaSlow and close < emaFast and ribbonTicks > neutralTicks
neutral = not bullBias and not bearBias
ribColor = bullBias ? color.new(bull, 82) : bearBias ? color.new(bear, 82) : color.new(muted, 86)
p1 = plot(emaFast, "EMA Fast", color=bullBias ? bull : bearBias ? bear : muted, linewidth=2)
p2 = plot(emaSlow, "EMA Slow", color=color.new(color.white, 10), linewidth=1)
fill(p1, p2, color=ribColor, title="TM Bias Ribbon")

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)
cluster = syminfo.mintick * clusterTicks

var line[] levelLines = array.new_line()
var label[] levelLabels = array.new_label()
var float[] levels = array.new_float()
var int[] touches = array.new_int()
var bool[] isSupport = array.new_bool()

f_addLevel(_price, _support) =>
    rounded = math.round(_price / syminfo.mintick) * syminfo.mintick
    idx = -1
    sz = array.size(levels)
    if sz > 0
        for i = 0 to sz - 1
            if math.abs(array.get(levels, i) - rounded) <= cluster
                idx := i
    if idx >= 0
        array.set(touches, idx, array.get(touches, idx) + 1)
    else
        if array.size(levels) >= maxLevels
            oldLine = array.shift(levelLines)
            oldLab = array.shift(levelLabels)
            line.delete(oldLine)
            label.delete(oldLab)
            array.shift(levels)
            array.shift(touches)
            array.shift(isSupport)
        col = _support ? color.new(bull, 15) : color.new(bear, 15)
        ln = line.new(bar_index - pivotLen, rounded, bar_index, rounded, extend=extend.right, color=col, style=line.style_dotted, width=2)
        lb = label.new(bar_index, rounded, (_support ? "S" : "R") + " 1x", style=label.style_label_left, textcolor=color.white, color=color.new(col, 35), size=size.tiny)
        array.push(levelLines, ln)
        array.push(levelLabels, lb)
        array.push(levels, rounded)
        array.push(touches, 1)
        array.push(isSupport, _support)

if not na(ph)
    f_addLevel(ph, false)
if not na(pl)
    f_addLevel(pl, true)

sz2 = array.size(levels)
if sz2 > 0
    for i = 0 to sz2 - 1
        lvl = array.get(levels, i)
        sup = array.get(isSupport, i)
        t = array.get(touches, i)
        col = sup ? bull : bear
        width = math.min(4, 1 + t)
        line.set_x2(array.get(levelLines, i), bar_index)
        line.set_width(array.get(levelLines, i), width)
        line.set_color(array.get(levelLines, i), neutral ? color.new(muted, 45) : color.new(col, 10))
        label.set_x(array.get(levelLabels, i), bar_index)
        label.set_y(array.get(levelLabels, i), lvl)
        label.set_text(array.get(levelLabels, i), (sup ? "S" : "R") + " " + str.tostring(t) + "x")

nearestHigh = ta.highest(high, 20)
nearestLow = ta.lowest(low, 20)
longFlip = bullBias and ta.crossover(close, emaFast) and close > emaSlow
shortFlip = bearBias and ta.crossunder(close, emaFast) and close < emaSlow
rangeNow = math.max(math.abs(nearestHigh - nearestLow), ta.atr(14))
plot(showTargets and longFlip ? close + rangeNow : na, "Long 1:1 target", color=color.new(bull, 0), style=plot.style_linebr, linewidth=2)
plot(showTargets and longFlip ? close + rangeNow * 2 : na, "Long 1:2 target", color=color.new(bull, 35), style=plot.style_linebr, linewidth=1)
plot(showTargets and shortFlip ? close - rangeNow : na, "Short 1:1 target", color=color.new(bear, 0), style=plot.style_linebr, linewidth=2)
plot(showTargets and shortFlip ? close - rangeNow * 2 : na, "Short 1:2 target", color=color.new(bear, 35), style=plot.style_linebr, linewidth=1)
plotshape(longFlip, "Bullish flip", shape.labelup, location.belowbar, color=color.new(bull, 0), text="TM\nFLIP", textcolor=color.black, size=size.tiny)
plotshape(shortFlip, "Bearish flip", shape.labeldown, location.abovebar, color=color.new(bear, 0), text="TM\nFLIP", textcolor=color.white, size=size.tiny)
bgcolor(neutral ? color.new(muted, 94) : na, title="Chop warning")
alertcondition(longFlip, "TM Micro Pivot Bull Flip", "TM Micro Pivot Map: bullish ribbon reclaim / flip")
alertcondition(shortFlip, "TM Micro Pivot Bear Flip", "TM Micro Pivot Map: bearish ribbon rejection / flip")
````
