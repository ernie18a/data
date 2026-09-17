<!-- tradingview-pine-id: PUB;033208af1e904d95bf1125cdb3b7d782 -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# FCP | HL Levels | Previous Day Week Month High & Low 

Source: https://www.tradingview.com/script/XWOqLz1y-FCP-HL-Levels-Daily-Weekly-Monthly-Multi-Timeframe-High-Low/

## Description

HL Levels draws the high, low and midpoint of each completed higher-timeframe candle directly on your chart, so you can see where the market reacted without switching timeframes.

What it plots

For every closed candle of the selected timeframe, three horizontal segments are drawn across the range of that period:

High — the peak of the previous period
Low — the trough of the previous period
Midpoint — the 50% level between them, drawn as a dotted line

Each segment spans only its own period, so the chart reads as a sequence of ranges rather than a cluster of endless rays.

Timeframes

Three fixed groups are available out of the box:

Daily — previous day's high, low and midpoint
Weekly — previous week's high, low and midpoint
Monthly — previous month's high, low and midpoint

Each can be toggled independently and given its own colour and line width.

Custom timeframe

A fourth group lets you pick any timeframe you want. It is off by default. Turn it on, choose a timeframe, and set how many candles back to draw.

This is aimed at intraday traders who work on low timeframes but need a mid-level reference — for example a 5-minute chart showing 4-hour highs and lows. Its look-back is measured in candles, not days, because the timeframe is yours to choose and a day-based count would produce thousands of objects on a 1-minute setting.

Look-back

The three fixed groups share a single look-back measured in days (default 60). The indicator converts that into the right number of candles for each timeframe automatically, so one setting controls all three consistently.

Notes

A group is skipped when its timeframe is lower than the chart's own timeframe, since those levels would change faster than the bars drawn beneath them.
Higher-timeframe data is requested with lookahead_on applied to high[1] and low[1] — that is, only fully closed candles are read. Nothing repaints.
The script respects Pine's 500-line drawing budget. Older periods are removed as new ones form.

How to use it

Previous-period highs and lows are among the most watched levels in any market. Price approaching a prior daily high often meets sellers; a prior weekly low often attracts buyers. The midpoint marks the equilibrium of that period and frequently acts as support or resistance in its own right.

These are reference levels, not signals. Combine them with your own analysis and risk management.

---

## Source Code

````pine
//@version=6
indicator("FCP | HL Levels | Previous Day Week Month High & Low ",  overlay = true, max_lines_count = 500)

grpDaily   = "■■■■■ Daily ■■■■■"
showDaily  = input.bool(true,     "Show daily levels", group = grpDaily)
dailyColor = input.color(#39FF55, "Color", inline = "dStyle", group = grpDaily)
dailyWidth = input.int(2, "Width", minval = 1, maxval = 5, inline = "dStyle", group = grpDaily, display = display.none)

grpWeekly   = "■■■■■ Weekly ■■■■■"
showWeekly  = input.bool(true,     "Show weekly levels", group = grpWeekly)
weeklyColor = input.color(#00E5FF, "Color", inline = "wStyle", group = grpWeekly)
weeklyWidth = input.int(2, "Width", minval = 1, maxval = 5, inline = "wStyle", group = grpWeekly, display = display.none)

grpMonthly   = "■■■■■ Monthly ■■■■■"
showMonthly  = input.bool(true,     "Show monthly levels", group = grpMonthly)
monthlyColor = input.color(#E0E0E0, "Color", inline = "mStyle", group = grpMonthly)
monthlyWidth = input.int(3, "Width", minval = 1, maxval = 5, inline = "mStyle", group = grpMonthly, display = display.none)

grpGeneral   = "■■■■■ General ■■■■■"
lookBackDays = input.int(60, "Look-back (days)", minval = 1, group = grpGeneral, display = display.none)

grpCustom   = "■■■■■ Custom Timeframe ■■■■■"
showCustom  = input.bool(false,     "Show custom timeframe levels", group = grpCustom)
customTF    = input.timeframe("240", "Timeframe",                   group = grpCustom, display = display.none)
customCount = input.int(21,         "Look-back (candles)", minval = 1, maxval = 150, group = grpCustom, display = display.none)
customColor = input.color(#FF0000,  "Color", inline = "cStyle",     group = grpCustom)
customWidth = input.int(1, "Width", minval = 1, maxval = 5, inline = "cStyle", group = grpCustom, display = display.none)

type PeriodLines
    line H
    line L
    line M
    int  endT

var array<PeriodLines> dailyLines   = array.new<PeriodLines>()
var array<PeriodLines> weeklyLines  = array.new<PeriodLines>()
var array<PeriodLines> monthlyLines = array.new<PeriodLines>()
var array<PeriodLines> customLines  = array.new<PeriodLines>()

f_maxCount(float daysPerBar) =>
    math.max(1, int(math.ceil(lookBackDays / daysPerBar)))

f_trim(array<PeriodLines> arr, int maxCount) =>
    while array.size(arr) > maxCount
        old = array.shift(arr)
        line.delete(old.H)
        line.delete(old.L)
        line.delete(old.M)

f_safeX2(int endTime) =>
    maxTime = time + 490 * timeframe.in_seconds() * 1000
    endTime > maxTime ? maxTime : endTime

f_setX2(PeriodLines p, int x2) =>
    line.set_x2(p.H, x2)
    line.set_x2(p.L, x2)
    line.set_x2(p.M, x2)

f_extend(array<PeriodLines> arr) =>
    if array.size(arr) > 0
        cur = array.last(arr)
        x2  = f_safeX2(cur.endT)
        if line.get_x2(cur.H) != x2
            f_setX2(cur, x2)

f_draw(array<PeriodLines> arr, int t1, int t2, float H, float L, color clr, int mainW, int maxCount) =>
    if array.size(arr) > 0
        prev = array.last(arr)
        f_setX2(prev, prev.endT)
    M  = (H + L) / 2
    x2 = f_safeX2(t2)
    lineH = line.new(t1, H, x2, H, xloc = xloc.bar_time, color = clr, width = mainW)
    lineL = line.new(t1, L, x2, L, xloc = xloc.bar_time, color = clr, width = mainW)
    lineM = line.new(t1, M, x2, M, xloc = xloc.bar_time, color = clr, width = 1, style = line.style_dotted)
    array.push(arr, PeriodLines.new(lineH, lineL, lineM, t2))
    f_trim(arr, maxCount)

[dH, dL, dT1, dT2] = request.security(syminfo.tickerid, "D", [high[1], low[1], time, time_close], barmerge.gaps_off, barmerge.lookahead_on)
[wH, wL, wT1, wT2] = request.security(syminfo.tickerid, "W", [high[1], low[1], time, time_close], barmerge.gaps_off, barmerge.lookahead_on)
[mH, mL, mT1, mT2] = request.security(syminfo.tickerid, "M", [high[1], low[1], time, time_close], barmerge.gaps_off, barmerge.lookahead_on)
[cH, cL, cT1, cT2] = request.security(syminfo.tickerid, customTF, [high[1], low[1], time, time_close], barmerge.gaps_off, barmerge.lookahead_on)

chartSec = timeframe.in_seconds()
canD = chartSec <= timeframe.in_seconds("D")
canW = chartSec <= timeframe.in_seconds("W")
canM = chartSec <= timeframe.in_seconds("M")
canC = chartSec <= timeframe.in_seconds(customTF)

if showDaily and canD
    if timeframe.change("D") and not na(dH)
        f_draw(dailyLines, dT1, dT2, dH, dL, dailyColor, dailyWidth, f_maxCount(1))
    f_extend(dailyLines)

if showWeekly and canW
    if timeframe.change("W") and not na(wH)
        f_draw(weeklyLines, wT1, wT2, wH, wL, weeklyColor, weeklyWidth, f_maxCount(7))
    f_extend(weeklyLines)

if showMonthly and canM
    if timeframe.change("M") and not na(mH)
        f_draw(monthlyLines, mT1, mT2, mH, mL, monthlyColor, monthlyWidth, f_maxCount(30))
    f_extend(monthlyLines)

if showCustom and canC
    if timeframe.change(customTF) and not na(cH)
        f_draw(customLines, cT1, cT2, cH, cL, customColor, customWidth, customCount)
    f_extend(customLines)
````
