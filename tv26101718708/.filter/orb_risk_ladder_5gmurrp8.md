# ORB Risk Ladder

- url: https://www.tradingview.com/script/5Gmurrp8-ORB-Risk-Ladder/
- type: indicator
- pine_id: PUB;0fff8dafe6d54d19b033c988e0c0c7ed
- version: 1.0

## Description

ORB Risk Ladder 

ORB Risk Ladder is a Trade Manager-style opening range research indicator built for traders who want more than a basic ORB high/low plot.

Most ORB indicators stop at drawing the opening range and marking a breakout. This one is designed around the full trade-planning sequence after the range breaks: where the breakout triggered, where the setup is invalidated, and where structured targets sit relative to the initial risk.

[b]What makes it different:[/b]
- Full risk map, not just an ORB box: the script plots Entry, Stop Loss, TP1, TP2, and TP3 after the first qualified breakout.
- Clean one-signal session logic: it focuses on the first valid breakout in the selected trade window instead of filling the chart with repeated arrows.
- R-based target ladder: TP levels are calculated from the distance between entry and stop, so the ladder adapts to the actual range size instead of using fixed arbitrary points.
- Optional midpoint stop mode: choose between a wider opposite-side ORB stop or a tighter midpoint invalidation model.
- Compact right-side labels: price values are attached to the end of each level line so the chart stays readable while still showing the exact ladder values.
- Session controls: customize the opening range window and breakout window to match the market or session you trade.
- Planning-first design: the output is meant to organize a setup visually, not claim prediction or profitability.

[b]Core visual elements:[/b]
- Opening range box
- BUY/SELL breakout marker
- Entry line with price value
- Stop-loss line with price value
- TP1/TP2/TP3 ladder with price values
- Optional ORB midpoint reference

[b]Suggested use:[/b]
Use it on intraday charts where the opening range matters and the trader wants a fast visual read of trigger, invalidation, and target structure. The default 9:30-9:45 opening range and 9:45-11:00 breakout window are designed around the U.S. cash open, but both are adjustable.

[b]Suggested timeframe:[/b]
15m on NQ or ES for the cleanest public screenshot. Lower timeframes can be used for more granular review, but 15m keeps the ladder and range structure readable.


Important:
This script is provided for educational and research purposes only. BUY/SELL markers, TP levels, and SL levels are visual planning references, not financial advice or trade recommendations. The script does not predict market direction, guarantee profitability, or replace independent risk management. Test all settings on your own market and timeframe before relying on any output.

## Source Code

````pine
//@version=5
indicator("ORB Risk Ladder", shorttitle="ORB Risk Ladder", overlay=true, max_lines_count=80, max_labels_count=80, max_boxes_count=20)

// Trade Manager original research tool. BUY/SELL and TP/SL visuals are planning references only. Not financial advice.

orbSession = input.session("0930-0945", "Opening Range Session", group="ORB")
tradeSession = input.session("0945-1100", "Breakout Window", group="ORB")
useMidStop = input.bool(false, "Use ORB Midpoint Stop", group="Risk")
rr1 = input.float(1.0, "TP1 R", minval=0.25, step=0.25, group="Risk")
rr2 = input.float(2.0, "TP2 R", minval=0.5, step=0.25, group="Risk")
rr3 = input.float(3.0, "TP3 R", minval=0.75, step=0.25, group="Risk")
showBox = input.bool(true, "Show ORB Box", group="Display")
bullColor = input.color(color.rgb(38,166,154), "BUY Color", group="Display")
bearColor = input.color(color.rgb(239,83,80), "SELL Color", group="Display")
tpColor = input.color(color.rgb(102,187,106), "TP Color", group="Display")
slColor = input.color(color.rgb(239,83,80), "SL Color", group="Display")
entryColor = input.color(color.rgb(255,167,38), "Entry Color", group="Display")
levelBars = input.int(50, "Level Line Length", minval=10, maxval=200, group="Display")

inOrb = not na(time(timeframe.period, orbSession))
inTrade = not na(time(timeframe.period, tradeSession))
newDay = ta.change(time("D"))
var float orbHigh = na
var float orbLow = na
var bool fired = false
var box orbBox = na

if newDay
    orbHigh := na
    orbLow := na
    fired := false
    if not na(orbBox)
        box.delete(orbBox)
        orbBox := na

if inOrb
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow := na(orbLow) ? low : math.min(orbLow, low)
    if showBox
        if na(orbBox)
            orbBox := box.new(bar_index, high, bar_index, low, bgcolor=color.new(color.silver, 88), border_color=color.new(color.silver, 45))
        else
            box.set_right(orbBox, bar_index)
            box.set_top(orbBox, orbHigh)
            box.set_bottom(orbBox, orbLow)

orbMid = (orbHigh + orbLow) / 2.0
buySignal = inTrade and not fired and not na(orbHigh) and close > orbHigh
sellSignal = inTrade and not fired and not na(orbLow) and close < orbLow

var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label entryLab = na
var label slLab = na
var label tp1Lab = na
var label tp2Lab = na
var label tp3Lab = na

if buySignal or sellSignal
    fired := true
    if not na(entryLine)
        line.delete(entryLine)
        line.delete(slLine)
        line.delete(tp1Line)
        line.delete(tp2Line)
        line.delete(tp3Line)
        label.delete(entryLab)
        label.delete(slLab)
        label.delete(tp1Lab)
        label.delete(tp2Lab)
        label.delete(tp3Lab)
    dir = buySignal ? 1.0 : -1.0
    entry = close
    sl = buySignal ? (useMidStop ? orbMid : orbLow) : (useMidStop ? orbMid : orbHigh)
    risk = math.max(math.abs(entry - sl), syminfo.mintick)
    tp1 = entry + dir * risk * rr1
    tp2 = entry + dir * risk * rr2
    tp3 = entry + dir * risk * rr3
    sigColor = buySignal ? bullColor : bearColor
    entryTxt = str.tostring(entry, format.mintick)
    slTxt = str.tostring(sl, format.mintick)
    tp1Txt = str.tostring(tp1, format.mintick)
    tp2Txt = str.tostring(tp2, format.mintick)
    tp3Txt = str.tostring(tp3, format.mintick)
    levelEnd = bar_index + levelBars
    label.new(bar_index, buySignal ? low : high, buySignal ? "BUY" : "SELL", style=buySignal ? label.style_label_up : label.style_label_down, color=sigColor, textcolor=color.white, size=size.small)
    entryLine := line.new(bar_index, entry, levelEnd, entry, extend=extend.none, color=entryColor, width=2)
    slLine := line.new(bar_index, sl, levelEnd, sl, extend=extend.none, color=slColor, width=2)
    tp1Line := line.new(bar_index, tp1, levelEnd, tp1, extend=extend.none, color=tpColor, width=1)
    tp2Line := line.new(bar_index, tp2, levelEnd, tp2, extend=extend.none, color=tpColor, width=1)
    tp3Line := line.new(bar_index, tp3, levelEnd, tp3, extend=extend.none, color=tpColor, width=2)
    entryLab := label.new(levelEnd, entry, "ENTRY " + entryTxt, style=label.style_label_left, color=entryColor, textcolor=color.white, size=size.small)
    slLab := label.new(levelEnd, sl, "SL " + slTxt, style=label.style_label_left, color=slColor, textcolor=color.white, size=size.small)
    tp1Lab := label.new(levelEnd, tp1, "TP1 " + tp1Txt, style=label.style_label_left, color=tpColor, textcolor=color.white, size=size.small)
    tp2Lab := label.new(levelEnd, tp2, "TP2 " + tp2Txt, style=label.style_label_left, color=tpColor, textcolor=color.white, size=size.small)
    tp3Lab := label.new(levelEnd, tp3, "TP3 " + tp3Txt, style=label.style_label_left, color=tpColor, textcolor=color.white, size=size.small)

plot(orbHigh, "ORB High", color=color.new(bullColor, 20), linewidth=1)
plot(orbLow, "ORB Low", color=color.new(bearColor, 20), linewidth=1)
plot(useMidStop ? orbMid : na, "ORB Mid", color=color.new(entryColor, 20), linewidth=1)
alertcondition(buySignal, "ORB Risk Ladder BUY", "ORB Risk Ladder: BUY planning marker created with TP/SL ladder.")
alertcondition(sellSignal, "ORB Risk Ladder SELL", "ORB Risk Ladder: SELL planning marker created with TP/SL ladder.")
````
