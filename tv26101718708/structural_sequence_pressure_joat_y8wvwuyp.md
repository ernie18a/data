# Structural Sequence Pressure [JOAT]

- url: https://www.tradingview.com/script/Y8wVWuyP-Structural-Sequence-Pressure-JOAT/
- type: indicator
- pine_id: PUB;38c20247efb9434bbda865e4ecc679be
- version: 1.0

## Description

[b]Structural Sequence Pressure [JOAT][/b]

[b]Introduction[/b]

Structural Sequence Pressure [JOAT] is a market-structure breakout indicator built around the idea that not all pivot levels carry the same weight. A level formed after one isolated pivot is ordinary. A level formed after repeated higher lows or lower highs represents structural persistence. This script quantifies that persistence, plots the resulting support and resistance levels, and highlights when those levels break.

The indicator is designed for traders who want clean structure without overfitting. It tracks sequence depth, manages active levels, and focuses attention on breaks that matter more because the market spent time constructing them.

[image]https://www.tradingview.com/x/TJCkYWvc[/image]

[b]Why This Indicator Exists[/b]

[list]
[*][b]Sequence-Based Structure:[/b] Measures how many pivots formed in the same directional progression
[*][b]Level Significance Filter:[/b] Helps distinguish weak levels from structurally reinforced ones
[*][b]Live Break Detection:[/b] Signals when meaningful support or resistance gives way
[*][b]Clutter Control:[/b] Caps active lines and labels to keep charts readable
[*][b]Statistical Feedback:[/b] Shows the most recent sequence pressure behavior directly in the dashboard
[/list]

[b]Core Components Explained[/b]

[b]1. Confirmed Pivot Detection[/b]

[pine]
pivHigh = ta.pivothigh(high, leftBars, rightBars)
pivLow  = ta.pivotlow(low, leftBars, rightBars)
[/pine]

The script only reacts to confirmed pivots. This means levels are built from validated swing points rather than from intrabar noise, which keeps the tool stable and non-repainting after pivot confirmation.

[b]2. Upward and Downward Sequence Counting[/b]

When a new pivot low forms higher than the previous pivot low, the upward sequence count increases. When a new pivot high forms lower than the previous pivot high, the downward sequence count increases. If the relationship fails, the sequence resets to one.

[list]
[*][b]Higher lows:[/b] Build upward structural pressure
[*][b]Lower highs:[/b] Build downward structural pressure
[*][b]Longer sequences:[/b] Represent stronger structural continuity
[/list]

[b]3. Active Level Engine[/b]

Every confirmed pivot creates a horizontal level that extends right. Support levels come from pivot lows. Resistance levels come from pivot highs. Each level stores:

[list]
[*]Its price
[*]Whether it is support or resistance
[*]Its sequence depth
[*]Its creation time
[/list]

Levels are trimmed by age and capped by quantity so the chart stays clean.

[b]4. Break Logic[/b]

[pine]
brokeSupport    = close < supportLevel
brokeResistance = close > resistanceLevel
[/pine]

Only levels with sequence depth greater than or equal to the selected threshold can trigger signals. This creates a cleaner breakout map that emphasizes structurally meaningful failures and expansions.

[b]5. Chart Hygiene Controls[/b]

The script stores and prunes pivot labels so they do not accumulate indefinitely. Broken or expired levels are removed from active management, and broken levels can optionally be deleted immediately for a cleaner chart.

[b]Visual Elements[/b]

[list]
[*][b]Support Lines:[/b] Teal dashed levels extending from higher-low pivots
[*][b]Resistance Lines:[/b] Red dashed levels extending from lower-high pivots
[*][b]Pivot Labels:[/b] Compact U/D sequence tags showing progression depth
[*][b]Break Markers:[/b] Triangles on bullish resistance breaks and bearish support breaks
[*][b]Dashboard:[/b] Up sequence, down sequence, total breaks, last break depths, and active level count
[/list]

[b]Input Parameters[/b]

[list]
[*][b]Pivot Left / Right Bars:[/b] Confirmation strength for structural swings
[*][b]Minimum Sequence:[/b] Required sequence depth before a break can trigger
[*][b]Max Active Levels:[/b] Hard cap for line management and chart cleanliness
[*][b]Max Level Age:[/b] Removes stale structure from consideration
[*][b]Delete Broken Levels:[/b] Optional cleanup for a more minimal chart
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify whether the market is building higher lows or lower highs.  
[b]Step 2:[/b] Focus on levels with deeper sequence counts.  
[b]Step 3:[/b] Treat bullish signals as upside breaks of resistance sequences.  
[b]Step 4:[/b] Treat bearish signals as downside breaks of support sequences.  
[b]Step 5:[/b] Use the level count and recent break depths to judge whether structure is compressing or resolving.

[b]Best Practices[/b]

[list]
[*]Use larger pivot settings on volatile instruments to reduce noise
[*]Increase minimum sequence length when markets are choppy
[*]Pair with trend or participation tools to separate continuation from exhaustion
[*]Respect old levels less than fresh ones unless they were built with deep sequence pressure
[*]Use the dashboard to calibrate structure sensitivity instrument by instrument
[/list]

[b]Indicator Limitations[/b]

[list]
[*]Pivot-based tools confirm after the fact by design
[*]Sequence strength measures persistence, not certainty
[*]Very low pivot settings can create too many structural levels
[*]Very high pivot settings can delay signals
[*]Breakouts can still fail, especially in range-bound conditions
[/list]

[b]Technical Implementation[/b]

Built in Pine Script v6 using:
[list]
[*]Confirmed pivot detection
[*]Directional sequence counting
[*]Array-managed line storage
[*]Label retention caps for chart cleanliness
[*]Age-based level cleanup
[*]Non-repainting break logic on confirmed bars
[/list]

[b]Originality Statement[/b]

This indicator is original in its focus on sequence depth as the source of structural weighting. Many support and resistance tools draw levels; this one grades their importance by the persistence of the swing process that created them, then filters breakout logic through that structural pressure.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Structural breaks can fail, reverse, or whipsaw. Always use independent analysis, stops, and appropriate risk management.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Structural Sequence Pressure [JOAT]", shorttitle="SSP [JOAT]", overlay=true, max_labels_count=200, max_lines_count=200)

grp_core = "Pivot Settings"
grp_filter = "Break Filters"
grp_vis = "Visual Settings"
grp_table = "Dashboard"

i_left_bars = input.int(7, "Pivot Left Bars", minval=1, maxval=50, group=grp_core)
i_right_bars = input.int(7, "Pivot Right Bars", minval=1, maxval=50, group=grp_core)
i_min_seq = input.int(2, "Minimum Sequence", minval=2, maxval=20, group=grp_core)
i_stat_memory = input.int(200, "Sequence Memory", minval=20, maxval=1000, group=grp_core)
i_max_active = input.int(30, "Max Active Levels", minval=5, maxval=100, group=grp_filter)
i_max_age = input.int(250, "Max Level Age", minval=10, maxval=1000, group=grp_filter)
i_delete_broken = input.bool(true, "Delete Broken Levels", group=grp_filter)

i_sup_col = input.color(#26a69a, "Support Color", group=grp_vis)
i_res_col = input.color(#cf1717, "Resistance Color", group=grp_vis)
i_bull_sig = input.color(#06a22f, "Bull Break Color", group=grp_vis)
i_bear_sig = input.color(#cf1717, "Bear Break Color", group=grp_vis)
i_show_labels = input.bool(true, "Show Pivot Labels", group=grp_vis)
i_show_marks = input.bool(true, "Show Break Markers", group=grp_vis)
i_show_barcolor = input.bool(true, "Show Candle Coloring", group=grp_vis)
i_show_bg = input.bool(true, "Show Bias Background", group=grp_vis)

i_show_table = input.bool(true, "Show Dashboard", group=grp_table)
i_table_pos = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grp_table)
i_table_size = input.string("Normal", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_table)
i_date_format = input.bool(true, "Date Format DD.MM.YYYY", group=grp_table)

f_tpos(s) =>
    switch s
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        => position.bottom_right

f_tsize(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_dateText(int t) =>
    datePart = i_date_format ? str.tostring(dayofmonth(t, "UTC"), "00") + "." + str.tostring(month(t, "UTC"), "00") + "." + str.tostring(year(t, "UTC")) : str.tostring(month(t, "UTC"), "00") + "/" + str.tostring(dayofmonth(t, "UTC"), "00") + "/" + str.tostring(year(t, "UTC"))
    timePart = timeframe.isintraday ? " " + str.tostring(hour(t, "UTC"), "00") + ":" + str.tostring(minute(t, "UTC"), "00") : ""
    datePart + timePart

pivHigh = ta.pivothigh(high, i_left_bars, i_right_bars)
pivLow = ta.pivotlow(low, i_left_bars, i_right_bars)

var float lastPivHigh = na
var float lastPivLow = na
var int upPivotCount = 0
var int downPivotCount = 0
var int totalBullBreaks = 0
var int totalBearBreaks = 0
var int lastBullSeqLen = 0
var int lastBearSeqLen = 0
var int oldestLevelTime = na

var line[] activeLines = array.new_line()
var label[] pivotLabels = array.new_label()
var float[] activeLevels = array.new_float()
var bool[] activeIsSupport = array.new_bool()
var int[] activeSeqLens = array.new_int()
var int[] activeCreated = array.new_int()
var int[] activeCreatedTime = array.new_int()
var int[] seqLengths = array.new_int()
var int[] seqFreq = array.new_int()

f_trim_oldest() =>
    if array.size(activeLines) > i_max_active
        oldLine = array.shift(activeLines)
        line.delete(oldLine)
        array.shift(activeLevels)
        array.shift(activeIsSupport)
        array.shift(activeSeqLens)
        array.shift(activeCreated)
        array.shift(activeCreatedTime)
    if array.size(pivotLabels) > i_max_active
        oldLabel = array.shift(pivotLabels)
        label.delete(oldLabel)

f_storeSequence(int seqLen) =>
    array.push(seqLengths, seqLen)
    while array.size(seqFreq) <= seqLen
        array.push(seqFreq, 0)
    array.set(seqFreq, seqLen, array.get(seqFreq, seqLen) + 1)
    if array.size(seqLengths) > i_stat_memory
        removed = array.shift(seqLengths)
        array.set(seqFreq, removed, math.max(array.get(seqFreq, removed) - 1, 0))

f_dominantSequence() =>
    bestLen = 0
    bestCount = 0
    if array.size(seqFreq) > 1
        for idx = 1 to array.size(seqFreq) - 1
            count = array.get(seqFreq, idx)
            if count > bestCount
                bestLen := idx
                bestCount := count
    [bestLen, bestCount]

if barstate.isconfirmed and not na(pivHigh)
    pivotBar = bar_index - i_right_bars
    prevDown = downPivotCount
    downPivotCount := not na(lastPivHigh) and pivHigh < lastPivHigh ? downPivotCount + 1 : 1
    if prevDown > 0 and downPivotCount == 1
        f_storeSequence(prevDown)
    lastPivHigh := pivHigh
    newLine = line.new(pivotBar, pivHigh, bar_index, pivHigh, color=color.new(i_res_col, 45), width=math.min(downPivotCount, 3), style=line.style_dashed, extend=extend.right)
    array.push(activeLines, newLine)
    array.push(activeLevels, pivHigh)
    array.push(activeIsSupport, false)
    array.push(activeSeqLens, downPivotCount)
    array.push(activeCreated, bar_index)
    array.push(activeCreatedTime, time[i_right_bars])
    f_trim_oldest()
    if i_show_labels
        newLabel = label.new(pivotBar, high[i_right_bars], text="D" + str.tostring(downPivotCount), style=label.style_label_down, color=color.new(i_res_col, 75), textcolor=color.white, size=size.tiny)
        array.push(pivotLabels, newLabel)
        f_trim_oldest()

if barstate.isconfirmed and not na(pivLow)
    pivotBar = bar_index - i_right_bars
    prevUp = upPivotCount
    upPivotCount := not na(lastPivLow) and pivLow > lastPivLow ? upPivotCount + 1 : 1
    if prevUp > 0 and upPivotCount == 1
        f_storeSequence(prevUp)
    lastPivLow := pivLow
    newLine = line.new(pivotBar, pivLow, bar_index, pivLow, color=color.new(i_sup_col, 45), width=math.min(upPivotCount, 3), style=line.style_dashed, extend=extend.right)
    array.push(activeLines, newLine)
    array.push(activeLevels, pivLow)
    array.push(activeIsSupport, true)
    array.push(activeSeqLens, upPivotCount)
    array.push(activeCreated, bar_index)
    array.push(activeCreatedTime, time[i_right_bars])
    f_trim_oldest()
    if i_show_labels
        newLabel = label.new(pivotBar, low[i_right_bars], text="U" + str.tostring(upPivotCount), style=label.style_label_up, color=color.new(i_sup_col, 75), textcolor=color.white, size=size.tiny)
        array.push(pivotLabels, newLabel)
        f_trim_oldest()

bullBreak = false
bearBreak = false
oldestLevelTime := na

if barstate.isconfirmed and array.size(activeLines) > 0
    for i = array.size(activeLines) - 1 to 0
        lvl = array.get(activeLevels, i)
        isSupport = array.get(activeIsSupport, i)
        seqLen = array.get(activeSeqLens, i)
        created = array.get(activeCreated, i)
        createdTime = array.get(activeCreatedTime, i)
        ln = array.get(activeLines, i)
        expired = bar_index - created > i_max_age
        oldestLevelTime := na(oldestLevelTime) ? createdTime : math.min(oldestLevelTime, createdTime)
        broke = isSupport ? close < lvl : close > lvl
        if expired
            line.delete(ln)
            array.remove(activeLines, i)
            array.remove(activeLevels, i)
            array.remove(activeIsSupport, i)
            array.remove(activeSeqLens, i)
            array.remove(activeCreated, i)
            array.remove(activeCreatedTime, i)
        else if broke and seqLen >= i_min_seq
            if isSupport
                bearBreak := true
                lastBearSeqLen := seqLen
                totalBearBreaks += 1
                line.set_color(ln, i_bear_sig)
            else
                bullBreak := true
                lastBullSeqLen := seqLen
                totalBullBreaks += 1
                line.set_color(ln, i_bull_sig)
            line.set_style(ln, line.style_solid)
            line.set_width(ln, 2)
            line.set_extend(ln, extend.none)
            line.set_x2(ln, bar_index)
            if i_delete_broken
                line.delete(ln)
            array.remove(activeLines, i)
            array.remove(activeLevels, i)
            array.remove(activeIsSupport, i)
            array.remove(activeSeqLens, i)
            array.remove(activeCreated, i)
            array.remove(activeCreatedTime, i)
        else
            line.set_x2(ln, bar_index)

plotshape(i_show_marks and bullBreak, "Bull Break", style=shape.triangleup, location=location.belowbar, color=i_bull_sig, size=size.small)
plotshape(i_show_marks and bearBreak, "Bear Break", style=shape.triangledown, location=location.abovebar, color=i_bear_sig, size=size.small)

[dominantSeqLen, dominantSeqCount] = f_dominantSequence()
oldestText = na(oldestLevelTime) ? "N/A" : f_dateText(oldestLevelTime)
supportCount = 0
resistanceCount = 0
float nearestSupport = na
float nearestResistance = na

if array.size(activeLevels) > 0
    for idx = 0 to array.size(activeLevels) - 1
        lvl = array.get(activeLevels, idx)
        isSupport = array.get(activeIsSupport, idx)
        if isSupport
            supportCount += 1
            nearestSupport := na(nearestSupport) ? lvl : (lvl <= close and lvl > nearestSupport ? lvl : nearestSupport)
        else
            resistanceCount += 1
            nearestResistance := na(nearestResistance) ? lvl : (lvl >= close and lvl < nearestResistance ? lvl : nearestResistance)

structureBias = upPivotCount - downPivotCount
pressureScore = math.min(math.abs(structureBias) * 20.0 + dominantSeqCount * 5.0, 100.0)
sspBarCol = i_show_barcolor ? color.from_gradient(math.min(math.abs(structureBias) / 5.0, 1.0), 0.0, 1.0, color.new(structureBias >= 0 ? i_bull_sig : i_bear_sig, 80), structureBias >= 0 ? i_bull_sig : i_bear_sig) : na
breakState = bullBreak ? "BULL BREAK" : bearBreak ? "BEAR BREAK" : "IDLE"
levelImbalance = supportCount - resistanceCount
supportResistanceState = levelImbalance > 0 ? "SUPPORT HEAVY" : levelImbalance < 0 ? "RESISTANCE HEAVY" : "BALANCED"
biasPersistence = structureBias > 0 ? ta.barssince(structureBias <= 0) : structureBias < 0 ? ta.barssince(structureBias >= 0) : 0
dominantScore = dominantSeqLen * dominantSeqCount
structureAcceptance = math.max(0.0, 100.0 - pressureScore)
nearestSpread = not na(nearestSupport) and not na(nearestResistance) ? nearestResistance - nearestSupport : na
breakPressure = (bullBreak ? lastBullSeqLen : bearBreak ? lastBearSeqLen : dominantSeqLen) * 10.0
marketShape = nearestSpread > 0 ? "EXPANDED" : "COMPRESSED"
activeDensity = array.size(activeLines) / math.max(i_max_active, 1) * 100.0
activeState = supportCount > resistanceCount ? "SUPPORT LED" : resistanceCount > supportCount ? "RESISTANCE LED" : "BALANCED"
breakQuality = math.min(breakPressure + pressureScore * 0.5, 100.0)
sequenceDrive = upPivotCount > downPivotCount ? "UP DRIVE" : downPivotCount > upPivotCount ? "DOWN DRIVE" : "NEUTRAL"
barcolor(sspBarCol, title="SSP Candle Color")
bgcolor(i_show_bg and structureBias > 0 ? color.new(i_bull_sig, 95) : i_show_bg and structureBias < 0 ? color.new(i_bear_sig, 95) : na)
pSupport = plot(not na(nearestSupport) ? nearestSupport : na, "Nearest Support", color=color.new(i_sup_col, 15), linewidth=2, style=plot.style_linebr)
pResistance = plot(not na(nearestResistance) ? nearestResistance : na, "Nearest Resistance", color=color.new(i_res_col, 15), linewidth=2, style=plot.style_linebr)
fill(pSupport, pResistance, color=color.new(levelImbalance >= 0 ? i_sup_col : i_res_col, 93), title="SR Pocket Fill")

var table dash = na
if i_show_table
    if na(dash)
        dash := table.new(position.top_right, 2, 9, bgcolor=#1a1a2e, border_color=#333355, border_width=1, frame_color=#444466, frame_width=1)
    if barstate.islast
        sz = size.normal
        table.cell(dash, 0, 0, "SSP [JOAT]", text_color=#ffd700, text_size=sz, bgcolor=#0d0d1a, text_halign=text.align_center)
        table.cell(dash, 1, 0, "VALUE", text_color=#aaaacc, text_size=sz, bgcolor=#0d0d1a, text_halign=text.align_center)
        table.cell(dash, 0, 1, "Bias", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 1, structureBias > 0 ? "BULLISH" : structureBias < 0 ? "BEARISH" : "NEUTRAL", text_color=structureBias > 0 ? i_bull_sig : structureBias < 0 ? i_bear_sig : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 2, "Break State", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 2, breakState, text_color=breakState == "BULL BREAK" ? i_bull_sig : breakState == "BEAR BREAK" ? i_bear_sig : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 3, "Dominant Seq", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 3, dominantSeqLen > 0 ? str.tostring(dominantSeqLen) + " (" + str.tostring(dominantSeqCount) + ")" : "N/A", text_color=#ffd700, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 4, "Pressure", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 4, str.tostring(pressureScore, "#.0") + "%", text_color=pressureScore >= 50 ? #ffd700 : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 5, "SR Pocket", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 5, (na(nearestSupport) ? "n/a" : str.tostring(nearestSupport, format.mintick)) + " | " + (na(nearestResistance) ? "n/a" : str.tostring(nearestResistance, format.mintick)), text_color=#ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 6, "Level Imbal.", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 6, str.tostring(levelImbalance), text_color=levelImbalance > 0 ? i_sup_col : levelImbalance < 0 ? i_res_col : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 7, "Break Quality", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 7, str.tostring(breakQuality, "#.0") + "%", text_color=#ffd700, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 8, "Seq Drive", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 8, sequenceDrive, text_color=structureBias > 0 ? i_bull_sig : structureBias < 0 ? i_bear_sig : #ccccdd, text_size=sz, bgcolor=#111122)

alertcondition(bullBreak, "SSP: Bull Sequence Break", "SSP [JOAT]: bearish resistance sequence broke to the upside.")
alertcondition(bearBreak, "SSP: Bear Sequence Break", "SSP [JOAT]: bullish support sequence broke to the downside.")
````
