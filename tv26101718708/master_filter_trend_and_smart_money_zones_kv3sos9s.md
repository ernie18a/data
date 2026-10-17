# Master Filter - Trend and Smart Money Zones

- url: https://www.tradingview.com/script/kv3SOS9S-Master-Filter-Trend-and-Smart-Money-Zones/
- type: indicator
- pine_id: PUB;4afeaaeeeadd467cb888175d8a9f8508
- version: 1.0

## Description

[b]Overview[/b]
Master Filter combines a proprietary trend engine with the smart-money tools traders actually act on - EMA structure, Fair Value Gaps, Order Blocks and market-structure labels - in a single, clean overlay. Instead of stacking five separate indicators, you get one consistent read of [i]where the trend is[/i] and [i]where price is likely to react[/i].

Everything is computed on the current chart timeframe and updates live as new bars form.

[b]What's inside[/b]

[b]1. The Master Filter © - trend & signals[/b]
A triple-smoothed price baseline (TEMA) is tracked against an adaptive average that follows the highs in an uptrend and the lows in a downtrend. An ATR-based channel (length 365 x multiplier, smoothed) acts as a confirmation filter that aims to suppress false flips during chop. When direction confirms, the script prints a [b]LONG[/b] / [b]SHORT[/b] marker on the bar. You can optionally plot the high / middle / low channel lines.

[b]2. EMA suite + smoothed mirrors[/b]
EMA 100 / 200 / 300 / 365 for trend context, with a shaded zone between the 300 and 365 EMAs. Two optional "mirror" EMAs (a smoothed reflection of the 200 and 365) project the opposite side of price to frame mean-reversion zones.

[b]3. Fair Value Gaps (current timeframe)[/b]
Three-bar imbalances are drawn as boxes with a dashed mid-line and tagged with the chart timeframe. Live gaps extend to the current bar and are removed automatically once price trades back through them (mitigation). A "max visible" cap keeps only the most recent gaps.

[b]4. Order Blocks (current timeframe)[/b]
SMC-style order blocks are detected on structure breaks (price closing through the last swing high/low). The OB candle is selected within a bounded search window, with a volatility filter so an oversized, high-range bar isn't mistaken for the block. Each OB is drawn as a box plus dashed mid-line, kept per direction up to a configurable limit, and dropped on a strict break. A "max pivot age" setting skips stale blocks far from current price during strong trends.

[b]5. Market structure - HH / HL / LH / LL[/b]
Swing pivots are labelled as Higher High / Higher Low / Lower High / Lower Low (teal for higher, orange for lower) so structure shifts are visible at a glance.

[b]How to use[/b]
[list]
[*]Read the trend from the LONG/SHORT markers and EMA stack; trade with it.
[*]Use FVG and Order Block zones as areas to look for entries, partial exits or invalidation - not as automatic buy/sell signals.
[*]Confirm with HH/HL/LH/LL: continuation favours trend-aligned zones; a structure break warns of a possible shift.
[/list]

[b]Settings[/b]
Grouped by section - [b]Main trend[/b] (length, multiplier, channel filter, plot channel), [b]Moving Average[/b] (EMA lengths, mirrors, smoothing), [b]Fair Value Gaps[/b] (show, max visible, colours), [b]Order Blocks[/b] (show, max per side, search/structure length, max pivot age, colours), and [b]HH/HL/LH/LL[/b] (show, swing length, lookback).

[b]Alerts[/b]
[list]
[*][i]Change of the trend[/i] - fires when the Master Filter direction flips.
[/list]

[b]Notes[/b]
This indicator is a decision-support tool, not a signal-for-hire system. It does not place orders and past behaviour does not guarantee future results. Always combine it with your own risk management.

## Source Code

````pine
// Master Filter — Trend & Smart-Money Zones.
//
// The Master Filter © trend engine with LONG/SHORT markers, an EMA suite
// (100/200/300/365 + smoothed mirrors), market-structure labels (HH/HL/LH/LL)
// and current-timeframe Fair Value Gaps & Order Blocks.
//
//@version=6
indicator("Master Filter — Trend & Smart-Money Zones", shorttitle="Master Filter", overlay=true, max_lines_count=100, max_labels_count=300, max_boxes_count=100)

//=========================================================================================================
// ─── TREND  (The Master Filter ©)
//=========================================================================================================

smaIn        = input.int(48, title="Length", minval=1, group="Main trend", inline="Main trend", display=display.all)
mtMultiplier = input.int(3, title="Multiplier", minval=1, group="Main trend", inline="Main trend", display=display.all)
mtUseChannel = input.bool(true, title="The Master Filter ©", group="Main trend", tooltip="The indicator will try to filter out fake signals.", display=display.none)
showChannel  = input.bool(false, title="Print channel", group="Main trend")

tema1 = ta.ema(close, 20)
tema2 = ta.ema(tema1, 20)
tema3 = ta.ema(tema2, 20)
tema  = 3 * (tema1 - tema2) + tema3

temaUp = tema >= tema[3]

maSeries   = temaUp ? high : low
sma1Result = ta.sma(maSeries, smaIn)

longSignal  = ta.crossunder(sma1Result, tema)
shortSignal = ta.crossover(sma1Result, tema)

var bool isLong = true
isLong := not isLong and longSignal ? true : isLong and shortSignal ? false : isLong

// core
atr    = ta.atr(365) * mtMultiplier
delta  = ta.ema(atr, 50)
delta2 = delta / 2

// source line
highMax  = math.max(close, open)
lowMax   = math.min(close, open)
highLine = highMax
lowLine  = lowMax

highTrigger = highLine > nz(highLine[1], highLine - delta)
lowTrigger  = lowLine  < nz(lowLine[1],  lowLine  + delta)

float middleLine = na
middleLine := lowTrigger  ? lowMax + delta2  : highTrigger ? lowMax     : middleLine[1]
middleLine := highTrigger ? highMax - delta2 : lowTrigger  ? middleLine : middleLine[1]

lowLine  := middleLine - delta2
highLine := middleLine + delta2

var bool channelInLong = true
channelInLong := highTrigger and not channelInLong and isLong ? true : lowTrigger and channelInLong and not isLong ? false : channelInLong
channelLongSignal  = channelInLong and not channelInLong[1]
channelShortSignal = not channelInLong and channelInLong[1]

longSignal  := mtUseChannel ? isLong and channelLongSignal      : longSignal
shortSignal := mtUseChannel ? not isLong and channelShortSignal : shortSignal

isLong := not isLong and longSignal ? true : isLong and shortSignal ? false : isLong
changeDirection = isLong != isLong[1]

// Render
colorHigh   = #FF0000
colorMiddle = #FF7F00
colorLow    = #008000
plot(showChannel ? highLine   : na, color=colorHigh,   linewidth=2, title="High line",   display=display.pane)
plot(showChannel ? middleLine : na, color=colorMiddle, linewidth=2, title="Middle line", display=display.pane)
plot(showChannel ? lowLine    : na, color=colorLow,    linewidth=2, title="Low line",    display=display.pane)

plotshape(longSignal  ? sma1Result : na, title="TREND LONG",  style=shape.triangleup,   size=size.small, text="LONG", location=location.belowbar, color=color.green, textcolor=color.green, display=display.pane)
plotshape(shortSignal ? sma1Result : na, title="TREND SHORT", style=shape.triangledown, size=size.small, text="SHORT", location=location.abovebar, color=color.red,   textcolor=color.red,   display=display.pane)

// Alerts
alertcondition(changeDirection, title="Change of the trend", message="The trend changed {{ticker}}:{{interval}} {{close}}")

//=========================================================================================================
// ─── MOVING AVERAGES + SMOOTH MIRRORS
//=========================================================================================================
group_ma = "Moving Average"

transpMA        = 40
colorEMA        = color.white
colorMiddleEMA  = color.rgb(255, 255, 255, 90)
colorThinBigEMA = color.rgb(156, 39, 176, 80)
colorBigEMA     = color.purple

ema100_len = input.int(100, title="EMA", group=group_ma, inline='EMA', display=display.none)
ema100     = ta.ema(close, ema100_len)

ema200_len = input.int(200, title="", group=group_ma, inline='EMA', display=display.none)
ema200     = ta.ema(close, ema200_len)

ema300_len = input.int(300, title="", group=group_ma, inline='EMA', display=display.none)
ema300     = ta.ema(close, ema300_len)

ema365_len = input.int(365, title="", group=group_ma, inline='Big EMA', display=display.none)
ema365     = ta.ema(close, ema365_len)

plotEMA300 = plot(ema300, color=color.new(color.purple, 40), linewidth=1, title="EMA 300 (fill)", display=display.none)
plotEMA365 = plot(ema365, color=color.new(color.purple, 40), linewidth=1, title="EMA 365 (fill)", display=display.none)

show_mirror = input.bool(true, title="Show EMA 200/365 Mirror", group=group_ma)

plot(ema100, title='EMA 100', color=color.new(colorEMA, transpMA), linewidth=2, display=display.data_window + display.pane)
plot(ema200, title='EMA 200', color=colorMiddleEMA,                linewidth=1, display=display.data_window + display.pane)
plot(ema300, title='EMA 300', color=colorThinBigEMA,               linewidth=1, display=display.data_window + display.pane)
plot(ema365, title='EMA 365', color=colorBigEMA,                   linewidth=2, display=display.data_window + display.pane)

fill(plotEMA300, plotEMA365, color=color.new(color.purple, 90))

smooth_len = input.int(200, "Mirror Smooth Length", group=group_ma, display=display.none)

ema200_mirror = ta.ema(2 * close - ema200, smooth_len)
ema365_mirror = ta.ema(2 * close - ema365, smooth_len)

plot(show_mirror ? ema200_mirror : na, title='EMA 200 Mirror (Smoothed)', color=colorThinBigEMA, linewidth=1, display=display.data_window + display.pane)
plot(show_mirror ? ema365_mirror : na, title='EMA 365 Mirror (Smoothed)', color=colorBigEMA,     linewidth=2, display=display.data_window + display.pane)

//=========================================================================================================
// ─── FAIR VALUE GAPS  (current timeframe)
//=========================================================================================================
group_fvg    = "Fair Value Gaps"
showFvg      = input.bool(true, "Show FVG",    group=group_fvg, inline="fvg_main")
fvgMaxCount  = input.int(6,     "Max visible", group=group_fvg, minval=1, maxval=30, inline="fvg_main", tooltip="Newest N gaps are kept; the oldest are dropped. Mitigated gaps are removed automatically.")
fvgBullColor = input.color(color.new(#26a69a, 80), "Bullish", group=group_fvg, inline="fvgcol")
fvgBearColor = input.color(color.new(#ff7043, 80), "Bearish", group=group_fvg, inline="fvgcol")

_currentTfLabel() =>
    string result = timeframe.period
    if timeframe.isseconds
        result := str.tostring(timeframe.multiplier) + "s"
    else if timeframe.isminutes
        result := timeframe.multiplier % 60 == 0 ? str.tostring(int(timeframe.multiplier / 60)) + "h" : str.tostring(timeframe.multiplier) + "m"
    else if timeframe.isdaily
        result := timeframe.multiplier == 1 ? "D" : str.tostring(timeframe.multiplier) + "D"
    else if timeframe.isweekly
        result := timeframe.multiplier == 1 ? "W" : str.tostring(timeframe.multiplier) + "W"
    else if timeframe.ismonthly
        result := timeframe.multiplier == 1 ? "M" : str.tostring(timeframe.multiplier) + "M"
    result

chartTfLabel = _currentTfLabel()

// Shared block shape for current-TF FVG and Order Blocks: a filled box plus a
// dashed mid line. `bias` is +1 bullish / -1 bearish.
type Zone
    box  bx
    line mid
    int  bias

_zoneDelete(array<Zone> zones, int index) =>
    z = zones.get(index)
    z.bx.delete()
    z.mid.delete()
    zones.remove(index)

_countBias(array<Zone> zones, int targetBias) =>
    int total = 0
    if zones.size() > 0
        for i = 0 to zones.size() - 1
            if zones.get(i).bias == targetBias
                total += 1
    total

// Keep the newest `maxCount` zones of a given bias; drop the oldest beyond that.
_trimOldestByBias(array<Zone> zones, int targetBias, int maxCount) =>
    while _countBias(zones, targetBias) > maxCount
        int removeIdx = -1
        for i = zones.size() - 1 to 0
            if zones.get(i).bias == targetBias
                removeIdx := i
                break
        if removeIdx < 0
            break
        _zoneDelete(zones, removeIdx)

var array<Zone> fvgZones = array.new<Zone>()

bullFvg = low > high[2]
bearFvg = high < low[2]

if showFvg
    // Extend live gaps to the current bar; drop a gap once price trades back through it.
    if fvgZones.size() > 0
        for i = fvgZones.size() - 1 to 0
            z = fvgZones.get(i)
            zTop = z.bx.get_top()
            zBot = z.bx.get_bottom()
            if (z.bias == 1 and low <= zBot) or (z.bias == -1 and high >= zTop)
                _zoneDelete(fvgZones, i)
            else
                z.bx.set_right(time)
                z.mid.set_x2(time)

    if bullFvg
        midY = math.avg(low, high[2])
        fvgZones.unshift(Zone.new(
             bx   = box.new(left=time[1], top=low, right=time, bottom=high[2], xloc=xloc.bar_time, border_color=color.new(fvgBullColor, 100), bgcolor=fvgBullColor, text="FVG " + chartTfLabel, text_size=size.tiny, text_color=color.new(fvgBullColor, 0), text_halign=text.align_right, text_valign=text.align_top),
             mid  = line.new(x1=time[1], y1=midY, x2=time, y2=midY, xloc=xloc.bar_time, color=color.new(fvgBullColor, 30), style=line.style_dashed, width=1),
             bias = 1))
        while fvgZones.size() > fvgMaxCount
            _zoneDelete(fvgZones, fvgZones.size() - 1)

    if bearFvg
        midY = math.avg(low[2], high)
        fvgZones.unshift(Zone.new(
             bx   = box.new(left=time[1], top=low[2], right=time, bottom=high, xloc=xloc.bar_time, border_color=color.new(fvgBearColor, 100), bgcolor=fvgBearColor, text="FVG " + chartTfLabel, text_size=size.tiny, text_color=color.new(fvgBearColor, 0), text_halign=text.align_right, text_valign=text.align_top),
             mid  = line.new(x1=time[1], y1=midY, x2=time, y2=midY, xloc=xloc.bar_time, color=color.new(fvgBearColor, 30), style=line.style_dashed, width=1),
             bias = -1))
        while fvgZones.size() > fvgMaxCount
            _zoneDelete(fvgZones, fvgZones.size() - 1)

//=========================================================================================================
// ─── ORDER BLOCKS  (current timeframe)
//=========================================================================================================
group_ob   = "Order Blocks"
showOb     = input.bool(true, "Show Order Blocks", group=group_ob, inline="ob_main")
obMaxCount = input.int(5,     "Max per side",      group=group_ob, minval=1, maxval=10, inline="ob_main", tooltip="Max Order Blocks kept PER DIRECTION (bullish and bearish trimmed independently), so up to 2× this value can be on screen.")
obLookback = input.int(10,    "Search / structure", group=group_ob, minval=1, maxval=50, inline="ob_scan", tooltip="Search bars: how far back to look for the OB candle. Structure length: swing-pivot length for OB qualification.")
obSwingLen = input.int(5,     "",                  group=group_ob, minval=2, maxval=50, inline="ob_scan")
obMaxAge   = input.int(100,   "Max pivot age (bars)", group=group_ob, minval=0, maxval=5000, tooltip="Skip the OB signal when the swing pivot it would cross is older than N bars. Avoids 'fresh' OBs far from price on strong trends. 0 = no limit.")
obBullColor = input.color(color.new(#29b6f6, 80), "Bullish", group=group_ob, inline="obcol")
obBearColor = input.color(color.new(#f23645, 80), "Bearish", group=group_ob, inline="obcol")

var array<Zone> obZones = array.new<Zone>()

obPivotHigh = ta.pivothigh(high, obSwingLen, obSwingLen)
obPivotLow  = ta.pivotlow(low,  obSwingLen, obSwingLen)

// SMC-style OB candle selection: invert high/low for high-volatility bars so we
// don't pick a giant volatile candle as the OB.
obAtr            = ta.atr(200)
obHighVolatility = (high - low) >= 2 * obAtr
obParsedHigh     = obHighVolatility ? low : high
obParsedLow      = obHighVolatility ? high : low

var float obLastHigh        = na
var int   obLastHighIndex   = na
var bool  obLastHighCrossed = false
var float obLastLow         = na
var int   obLastLowIndex    = na
var bool  obLastLowCrossed  = false
var int   structureBias     = 0

if not na(obPivotHigh)
    obLastHigh := obPivotHigh
    obLastHighIndex := bar_index - obSwingLen
    obLastHighCrossed := false

if not na(obPivotLow)
    obLastLow := obPivotLow
    obLastLowIndex := bar_index - obSwingLen
    obLastLowCrossed := false

// Reject crossovers of pivots older than obMaxAge bars. 0 disables the limit.
_obAgeOk(pivotIdx) =>
    obMaxAge <= 0 or na(pivotIdx) or (bar_index - pivotIdx) <= obMaxAge

// Pull ta.* out of the short-circuited `and` so they run on every bar.
obCrossOverLastHigh = ta.crossover(close, obLastHigh)
obCrossUnderLastLow = ta.crossunder(close, obLastLow)
bullObSignal = not na(obLastHigh) and not obLastHighCrossed and obCrossOverLastHigh and _obAgeOk(obLastHighIndex)
bearObSignal = not na(obLastLow)  and not obLastLowCrossed  and obCrossUnderLastLow and _obAgeOk(obLastLowIndex)

// If a single bar pierces both swings, keep the side aligned with the prior structure bias.
if bullObSignal and bearObSignal
    if structureBias == -1
        bullObSignal := false
    else
        bearObSignal := false

if bullObSignal
    obLastHighCrossed := true
    structureBias := 1
if bearObSignal
    obLastLowCrossed := true
    structureBias := -1

if showOb
    // Extend live OBs to the current bar; drop one when price closes through it (strict break).
    if obZones.size() > 0
        for i = obZones.size() - 1 to 0
            z = obZones.get(i)
            zTop = z.bx.get_top()
            zBot = z.bx.get_bottom()
            if (z.bias == 1 and low < zBot) or (z.bias == -1 and high > zTop)
                _zoneDelete(obZones, i)
            else
                z.bx.set_right(time)
                z.mid.set_x2(time)

    if bullObSignal
        int   obIndex = na
        float obLow   = na
        // Cap the search window so a stale pivot can't pull it back hundreds of bars.
        int obBarsFromStructure = na(obLastHighIndex) ? obLookback : math.min(obLookback, math.max(1, bar_index - obLastHighIndex))
        for i = 1 to obBarsFromStructure
            if na(obLow) or obParsedLow[i] < obLow
                obLow := obParsedLow[i]
                obIndex := i
        if not na(obIndex)
            midY = math.avg(high[obIndex], low[obIndex])
            obZones.unshift(Zone.new(
                 bx   = box.new(left=time[obIndex], top=high[obIndex], right=time, bottom=low[obIndex], xloc=xloc.bar_time, border_color=color.new(obBullColor, 100), bgcolor=obBullColor, text="OB " + chartTfLabel, text_size=size.tiny, text_color=color.new(obBullColor, 0), text_halign=text.align_right, text_valign=text.align_top),
                 mid  = line.new(x1=time[obIndex], y1=midY, x2=time, y2=midY, xloc=xloc.bar_time, color=color.new(obBullColor, 30), style=line.style_dashed, width=1),
                 bias = 1))
            _trimOldestByBias(obZones, 1, obMaxCount)

    if bearObSignal
        int   obIndex = na
        float obHigh  = na
        int obBarsFromStructure = na(obLastLowIndex) ? obLookback : math.min(obLookback, math.max(1, bar_index - obLastLowIndex))
        for i = 1 to obBarsFromStructure
            if na(obHigh) or obParsedHigh[i] > obHigh
                obHigh := obParsedHigh[i]
                obIndex := i
        if not na(obIndex)
            midY = math.avg(high[obIndex], low[obIndex])
            obZones.unshift(Zone.new(
                 bx   = box.new(left=time[obIndex], top=high[obIndex], right=time, bottom=low[obIndex], xloc=xloc.bar_time, border_color=color.new(obBearColor, 100), bgcolor=obBearColor, text="OB " + chartTfLabel, text_size=size.tiny, text_color=color.new(obBearColor, 0), text_halign=text.align_right, text_valign=text.align_top),
                 mid  = line.new(x1=time[obIndex], y1=midY, x2=time, y2=midY, xloc=xloc.bar_time, color=color.new(obBearColor, 30), style=line.style_dashed, width=1),
                 bias = -1))
            _trimOldestByBias(obZones, -1, obMaxCount)

//=========================================================================================================
// ─── HH / HL / LH / LL
//=========================================================================================================
group_hhll   = "HH/HL/LH/LL"
showHHLL     = input.bool(true, "Show HH/HL/LH/LL", group=group_hhll)
hhllSwingLen = input.int(5,    "Swing / lookback",  group=group_hhll, minval=1, maxval=50,   inline="hhll_scan", tooltip="Swing length: pivot strength for detecting swings. Lookback: number of bars scanned for the label history.")
hhllLookback = input.int(1000, "",                  group=group_hhll, minval=100, maxval=5000, inline="hhll_scan")

hhllPivotHigh = ta.pivothigh(high, hhllSwingLen, hhllSwingLen)
hhllPivotLow  = ta.pivotlow(low,  hhllSwingLen, hhllSwingLen)

var float hhllPrevHigh = na
var float hhllPrevLow  = na
var array<label> hhllLabels = array.new<label>()

hhllMaxLabels = math.max(10, math.min(200, hhllLookback / hhllSwingLen))

if showHHLL
    if not na(hhllPivotHigh)
        if not na(hhllPrevHigh)
            isHH = hhllPivotHigh >= hhllPrevHigh
            txt  = isHH ? "HH" : "LH"
            col  = isHH ? color.new(color.teal, 0) : color.new(color.orange, 0)
            hhllLabels.unshift(label.new(x=bar_index - hhllSwingLen, y=high[hhllSwingLen], text=txt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.white, 100), textcolor=col, style=label.style_label_down, size=size.tiny))
            while hhllLabels.size() > hhllMaxLabels
                hhllLabels.pop().delete()
        hhllPrevHigh := hhllPivotHigh

    if not na(hhllPivotLow)
        if not na(hhllPrevLow)
            isHL = hhllPivotLow >= hhllPrevLow
            txt  = isHL ? "HL" : "LL"
            col  = isHL ? color.new(color.teal, 0) : color.new(color.orange, 0)
            hhllLabels.unshift(label.new(x=bar_index - hhllSwingLen, y=low[hhllSwingLen], text=txt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.white, 100), textcolor=col, style=label.style_label_up, size=size.tiny))
            while hhllLabels.size() > hhllMaxLabels
                hhllLabels.pop().delete()
        hhllPrevLow := hhllPivotLow
````
