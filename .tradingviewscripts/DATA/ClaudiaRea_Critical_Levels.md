<!-- tradingview-pine-id: PUB;a27387839d544e06803504527b63df4a -->
<!-- tradingviewscripts-format: 1 -->
# ClaudiaRea Critical Levels

Source: https://www.tradingview.com/script/6GWokB1Q-ClaudiaRea-Key-Levels/

## Description

Key Levels — Manual S/R Zones with Full Style Control

This indicator plots your most important price levels as clean, translucent green horizontal lines directly on any chart. Designed for traders who identify their own key levels and want a fast, flexible way to mark them without cluttering the chart.

What it plots:

4HR Zone — shaded supply or demand area with adjustable fill
Monthly Open — auto-labeled reference line updated each month
Daily Level — intraday anchor level
Up to 5 Key Levels — your main support and resistance prices
Up to 5 Extra Levels — tagged individually as Support, Resistance, or Neutral
Features:

All lines rendered in translucent green for clean, non-distracting visuals
Per-group line width (1–6), line style (solid / dashed / dotted), and transparency control
Global label size selector and optional price value displayed on each label
Toggle each group on or off independently
Works on all symbols and all timeframes
No repainting — all levels are manually set and drawn on the last bar only
How to use:
Open Settings, enter your price levels in each group, choose your preferred line thickness and style, and adjust transparency to match your chart theme. Set any level to 0 to hide it. Enable Extra Levels and assign each one as Support or Resistance for quick visual reference during live trading.

React to price action. The levels tell you where to look — the wick tells you what to do.

---

## Source Code

````pine
//@version=6
indicator('ClaudiaRea Critical Levels', overlay = true, max_lines_count = 500, max_labels_count = 500)

groupClaudia = 'ClaudiaRea Critical Levels Settings (PRIMARY)'
groupTfView  = 'Chart Timeframe Visibility Switches (ON / OFF)'
groupManual  = 'Manual Custom Levels (Fully Editable, Drawn Left-to-Right)'

plotOn1Min    = input.bool(true, 'Display Levels on 1-Minute Chart', group = groupTfView)
plotOn5Min    = input.bool(true, 'Display Levels on 5-Minute Chart', group = groupTfView)
plotOn15Min   = input.bool(true, 'Display Levels on 15-Minute Chart', group = groupTfView)
plotOn1H      = input.bool(true, 'Display Levels on 1-Hour Chart', group = groupTfView)
plotOn4H      = input.bool(true, 'Display Levels on 4-Hour Chart', group = groupTfView)
plotOnDaily   = input.bool(true, 'Display Levels on Daily Chart', group = groupTfView)
plotOnWeekly  = input.bool(true, 'Display Levels on Weekly Chart', group = groupTfView)
plotOnMonthly = input.bool(true, 'Display Levels on Monthly Chart', group = groupTfView)

showClaudia        = input.bool(true, 'Enable ClaudiaRea Critical Levels', group = groupClaudia)
claudiaColor       = input.color(#00ffcc, 'Claudia Color Base', group = groupClaudia)
claudiaLabelColor  = input.color(#00ffcc, 'Claudia Label Color', group = groupClaudia)

customLabelText    = input.string('CR', 'Editable Level Name Tag Text', group = groupClaudia)

collapseOverlapLabels  = input.bool(true, 'Collapse Overlapping Labels Into One', group = groupClaudia)
collapseProximityTicks = input.int(20, 'Label Collapse Proximity (Ticks)', minval = 0, group = groupClaudia)
collapseProximityPct   = input.float(0.05, 'Label Collapse Proximity (% of Price)', minval = 0, step = 0.01, group = groupClaudia)

claudiaLeftStyle   = input.string('Solid', 'Left History Line Style', options = ['Solid', 'Dotted', 'Dashed'], group = groupClaudia)
claudiaRightStyle  = input.string('Solid', 'Right Extension Line Style', options = ['Solid', 'Dotted', 'Dashed'], group = groupClaudia)
hideOnCloseBreach  = input.bool(true, 'Auto-Hide Level if Candle Closes Past It', group = groupClaudia)
showBrokenHistory  = input.bool(true, 'Keep Broken Levels as Gray History Lines', group = groupClaudia)
brokenHistoryColor = input.color(#8a8a8a, 'Broken History Line Color', group = groupClaudia)
brokenHistoryTrans = input.int(60, 'Broken History Line Transparency (0-100)', minval = 0, maxval = 100, group = groupClaudia)

claudiaLeftTrans   = input.int(55, 'Left History Transparency (0-100)', minval = 0, maxval = 100, group = groupClaudia)
claudiaRightTrans  = input.int(50, 'Right Extension Transparency (0-100)', minval = 0, maxval = 100, group = groupClaudia)

pivotLen           = input.int(5, 'Pivot Left/Right Strength', minval = 2, group = groupClaudia)
touchZoneTicks     = input.int(15, 'Touch Proximity Zone (Ticks)', minval = 0, group = groupClaudia)

maxLookbackBars    = input.int(476, 'Maximum Historical Lookback Bars', minval = 10, group = groupClaudia)
fadeLookbackBars   = input.int(120, 'Bars After Which to Fade Levels (93%)', minval = 5, group = groupClaudia)
extendRightBars    = input.int(3, 'Bars to Extend Past Price Action', minval = 0, group = groupClaudia)

manual1Enable = input.bool(false, 'Enable Manual Level 1', group = groupManual)
manual1Price  = input.float(0, 'Manual Level 1 Price', group = groupManual)
manual1Label  = input.string('M1', 'Manual Level 1 Label Text', group = groupManual)
manual1Color  = input.color(color.new(#14532d, 40), 'Manual Level 1 Color', group = groupManual)

manual2Enable = input.bool(false, 'Enable Manual Level 2', group = groupManual)
manual2Price  = input.float(0, 'Manual Level 2 Price', group = groupManual)
manual2Label  = input.string('M2', 'Manual Level 2 Label Text', group = groupManual)
manual2Color  = input.color(color.new(#14532d, 40), 'Manual Level 2 Color', group = groupManual)

manual3Enable = input.bool(false, 'Enable Manual Level 3', group = groupManual)
manual3Price  = input.float(0, 'Manual Level 3 Price', group = groupManual)
manual3Label  = input.string('M3', 'Manual Level 3 Label Text', group = groupManual)
manual3Color  = input.color(color.new(#14532d, 40), 'Manual Level 3 Color', group = groupManual)

manual4Enable = input.bool(false, 'Enable Manual Level 4', group = groupManual)
manual4Price  = input.float(0, 'Manual Level 4 Price', group = groupManual)
manual4Label  = input.string('M4', 'Manual Level 4 Label Text', group = groupManual)
manual4Color  = input.color(color.new(#14532d, 40), 'Manual Level 4 Color', group = groupManual)

plot(close, title = 'Global Anchor', color = color.new(color.white, 100))

var bool isVisibleChartTimeframe = false

if barstate.isfirst
    isMin   = timeframe.isintraday and timeframe.multiplier == 1
    is5Min  = timeframe.isintraday and timeframe.multiplier == 5
    is15Min = timeframe.isintraday and timeframe.multiplier == 15
    isHour  = timeframe.isintraday and timeframe.multiplier == 60
    is4Hour = timeframe.isintraday and timeframe.multiplier == 240
    isD     = timeframe.isdaily
    isW     = timeframe.isweekly
    isM     = timeframe.ismonthly

    isVisibleChartTimeframe := (isMin and plotOn1Min) or (is5Min and plotOn5Min) or (is15Min and plotOn15Min) or (isHour and plotOn1H) or (is4Hour and plotOn4H) or (isD and plotOnDaily) or (isW and plotOnWeekly) or (isM and plotOnMonthly) or (not isMin and not is5Min and not is15Min and not isHour and not is4Hour and not isD and not isW and not isM)

pHi = ta.pivothigh(high, pivotLen, pivotLen)
pLo = ta.pivotlow(low, pivotLen, pivotLen)
tickSize = syminfo.mintick
proximityThreshold = touchZoneTicks * tickSize
collapseThreshold  = math.max(collapseProximityTicks * tickSize, close * collapseProximityPct / 100)

float lvl1 = ta.valuewhen(not na(pHi) or not na(pLo), not na(pHi) ? pHi : pLo, 0)
float lvl2 = ta.valuewhen(not na(pHi) or not na(pLo), not na(pHi) ? pHi : pLo, 1)
float lvl3 = ta.valuewhen(not na(pHi) or not na(pLo), not na(pHi) ? pHi : pLo, 2)
float lvl4 = ta.valuewhen(not na(pHi) or not na(pLo), not na(pHi) ? pHi : pLo, 3)

var int score1 = 1
var int score2 = 1
var int score3 = 1
var int score4 = 1

var bool broken1 = false
var bool broken2 = false
var bool broken3 = false
var bool broken4 = false

var int age1 = 0
var int age2 = 0
var int age3 = 0
var int age4 = 0

chg1 = ta.change(lvl1)
chg2 = ta.change(lvl2)
chg3 = ta.change(lvl3)
chg4 = ta.change(lvl4)

if showClaudia and isVisibleChartTimeframe and barstate.isconfirmed
    if not na(chg1) and chg1 != 0
        score1 := 1
        broken1 := false
        age1 := 0
    if not na(chg2) and chg2 != 0
        score2 := 1
        broken2 := false
        age2 := 0
    if not na(chg3) and chg3 != 0
        score3 := 1
        broken3 := false
        age3 := 0
    if not na(chg4) and chg4 != 0
        score4 := 1
        broken4 := false
        age4 := 0

    if not na(lvl1)
        age1 += 1
    if not na(lvl2)
        age2 += 1
    if not na(lvl3)
        age3 += 1
    if not na(lvl4)
        age4 += 1

    if not broken1 and (high >= lvl1 - proximityThreshold and low <= lvl1 + proximityThreshold)
        score1 += 1
    if not broken2 and (high >= lvl2 - proximityThreshold and low <= lvl2 + proximityThreshold)
        score2 += 1
    if not broken3 and (high >= lvl3 - proximityThreshold and low <= lvl3 + proximityThreshold)
        score3 += 1
    if not broken4 and (high >= lvl4 - proximityThreshold and low <= lvl4 + proximityThreshold)
        score4 += 1

    if hideOnCloseBreach and ((close > lvl1 and open < lvl1) or (close < lvl1 and open > lvl1))
        broken1 := true
    if hideOnCloseBreach and ((close > lvl2 and open < lvl2) or (close < lvl2 and open > lvl2))
        broken2 := true
    if hideOnCloseBreach and ((close > lvl3 and open < lvl3) or (close < lvl3 and open > lvl3))
        broken3 := true
    if hideOnCloseBreach and ((close > lvl4 and open < lvl4) or (close < lvl4 and open > lvl4))
        broken4 := true

var line ln1_h = na, var line ln1_e = na, var label lb1 = na
var line ln2_h = na, var line ln2_e = na, var label lb2 = na
var line ln3_h = na, var line ln3_e = na, var label lb3 = na
var line ln4_h = na, var line ln4_e = na, var label lb4 = na

fFade(_baseTrans, _age) =>
    _ratio = math.min(1.0, _age / fadeLookbackBars)
    int(math.round(_baseTrans + (93 - _baseTrans) * _ratio))

fBuildClusterLabel(_prices, _idx, _scores, _from, _to, _x) =>
    int _m = _to - _from + 1
    float _avg = 0.0
    string _txt = customLabelText
    string _scr = ''
    for _k = _from to _to
        _avg += array.get(_prices, _k)
        _txt += (_k == _from ? ' ' : '|') + str.tostring(array.get(_idx, _k))
        _scr += (_k == _from ? '' : '+') + str.tostring(array.get(_scores, _k))
    _avg := _avg / _m
    _txt += ' [' + _scr + ']'
    label.new(_x, _avg, text = _txt, color = color.new(claudiaLabelColor, 100), textcolor = claudiaLabelColor, style = label.style_label_left, size = size.small)

if showClaudia and isVisibleChartTimeframe and barstate.islast
    line.delete(ln1_h), line.delete(ln1_e), label.delete(lb1)
    line.delete(ln2_h), line.delete(ln2_e), label.delete(lb2)
    line.delete(ln3_h), line.delete(ln3_e), label.delete(lb3)
    line.delete(ln4_h), line.delete(ln4_e), label.delete(lb4)

    leftStyle  = claudiaLeftStyle == 'Dotted' ? line.style_dotted : (claudiaLeftStyle == 'Dashed' ? line.style_dashed : line.style_solid)
    rightStyle = claudiaRightStyle == 'Dotted' ? line.style_dotted : (claudiaRightStyle == 'Dashed' ? line.style_dashed : line.style_solid)

    int startVisualIndex = math.max(0, bar_index - maxLookbackBars)
    int extendedBarIndex = bar_index + extendRightBars

    if not na(lvl1)
        if not broken1
            color c1 = score1 > 1 ? #004d26 : claudiaColor
            ln1_h := line.new(startVisualIndex, lvl1, bar_index, lvl1, color = color.new(c1, fFade(claudiaLeftTrans, age1)), style = leftStyle)
            ln1_e := line.new(bar_index, lvl1, extendedBarIndex, lvl1, color = color.new(c1, fFade(claudiaRightTrans, age1)), style = rightStyle)
        else if showBrokenHistory
            ln1_h := line.new(startVisualIndex, lvl1, bar_index, lvl1, color = color.new(brokenHistoryColor, brokenHistoryTrans), style = leftStyle)

    if not na(lvl2)
        if not broken2
            color c2 = score2 > 1 ? #004d26 : claudiaColor
            ln2_h := line.new(startVisualIndex, lvl2, bar_index, lvl2, color = color.new(c2, fFade(claudiaLeftTrans, age2)), style = leftStyle)
            ln2_e := line.new(bar_index, lvl2, extendedBarIndex, lvl2, color = color.new(c2, fFade(claudiaRightTrans, age2)), style = rightStyle)
        else if showBrokenHistory
            ln2_h := line.new(startVisualIndex, lvl2, bar_index, lvl2, color = color.new(brokenHistoryColor, brokenHistoryTrans), style = leftStyle)

    if not na(lvl3)
        if not broken3
            color c3 = score3 > 1 ? #004d26 : claudiaColor
            ln3_h := line.new(startVisualIndex, lvl3, bar_index, lvl3, color = color.new(c3, fFade(claudiaLeftTrans, age3)), style = leftStyle)
            ln3_e := line.new(bar_index, lvl3, extendedBarIndex, lvl3, color = color.new(c3, fFade(claudiaRightTrans, age3)), style = rightStyle)
        else if showBrokenHistory
            ln3_h := line.new(startVisualIndex, lvl3, bar_index, lvl3, color = color.new(brokenHistoryColor, brokenHistoryTrans), style = leftStyle)

    if not na(lvl4)
        if not broken4
            color c4 = score4 > 1 ? #004d26 : claudiaColor
            ln4_h := line.new(startVisualIndex, lvl4, bar_index, lvl4, color = color.new(c4, fFade(claudiaLeftTrans, age4)), style = leftStyle)
            ln4_e := line.new(bar_index, lvl4, extendedBarIndex, lvl4, color = color.new(c4, fFade(claudiaRightTrans, age4)), style = rightStyle)
        else if showBrokenHistory
            ln4_h := line.new(startVisualIndex, lvl4, bar_index, lvl4, color = color.new(brokenHistoryColor, brokenHistoryTrans), style = leftStyle)

    var array<float> _p = array.new<float>()
    var array<int> _ix = array.new<int>()
    var array<int> _sc = array.new<int>()
    array.clear(_p), array.clear(_ix), array.clear(_sc)

    if not broken1 and not na(lvl1)
        array.push(_p, lvl1), array.push(_ix, 1), array.push(_sc, score1)
    if not broken2 and not na(lvl2)
        array.push(_p, lvl2), array.push(_ix, 2), array.push(_sc, score2)
    if not broken3 and not na(lvl3)
        array.push(_p, lvl3), array.push(_ix, 3), array.push(_sc, score3)
    if not broken4 and not na(lvl4)
        array.push(_p, lvl4), array.push(_ix, 4), array.push(_sc, score4)

    int _n = array.size(_p)
    if _n > 0
        for _i = 0 to _n - 2
            int _mi = _i
            for _j = _i + 1 to _n - 1
                if array.get(_p, _j) < array.get(_p, _mi)
                    _mi := _j
            if _mi != _i
                float _t = array.get(_p, _i)
                array.set(_p, _i, array.get(_p, _mi))
                array.set(_p, _mi, _t)
                int _ti = array.get(_ix, _i)
                array.set(_ix, _i, array.get(_ix, _mi))
                array.set(_ix, _mi, _ti)
                int _ts = array.get(_sc, _i)
                array.set(_sc, _i, array.get(_sc, _mi))
                array.set(_sc, _mi, _ts)

        int _groupStart = 0
        int _slot = 0
        for _k = 1 to _n - 1
            if collapseOverlapLabels and array.get(_p, _k) - array.get(_p, _groupStart) <= collapseThreshold
                continue
            label _lbl = fBuildClusterLabel(_p, _ix, _sc, _groupStart, _k - 1, extendedBarIndex)
            if _slot == 0
                lb1 := _lbl
            else if _slot == 1
                lb2 := _lbl
            else if _slot == 2
                lb3 := _lbl
            else
                lb4 := _lbl
            _slot += 1
            _groupStart := _k
        label _lblLast = fBuildClusterLabel(_p, _ix, _sc, _groupStart, _n - 1, extendedBarIndex)
        if _slot == 0
            lb1 := _lblLast
        else if _slot == 1
            lb2 := _lblLast
        else if _slot == 2
            lb3 := _lblLast
        else
            lb4 := _lblLast

var line mln1 = na, var label mlb1 = na
var line mln2 = na, var label mlb2 = na
var line mln3 = na, var label mlb3 = na
var line mln4 = na, var label mlb4 = na

if showClaudia and barstate.islast
    line.delete(mln1), label.delete(mlb1)
    line.delete(mln2), label.delete(mlb2)
    line.delete(mln3), label.delete(mlb3)
    line.delete(mln4), label.delete(mlb4)

    int manualRightIndex = bar_index + extendRightBars

    if manual1Enable and manual1Price > 0
        mln1 := line.new(bar_index, manual1Price, manualRightIndex, manual1Price, extend = extend.left, color = manual1Color, style = line.style_solid, width = 1)
        mlb1 := label.new(manualRightIndex, manual1Price, text = manual1Label, color = color.new(manual1Color, 100), textcolor = manual1Color, style = label.style_label_left, size = size.small)

    if manual2Enable and manual2Price > 0
        mln2 := line.new(bar_index, manual2Price, manualRightIndex, manual2Price, extend = extend.left, color = manual2Color, style = line.style_solid, width = 1)
        mlb2 := label.new(manualRightIndex, manual2Price, text = manual2Label, color = color.new(manual2Color, 100), textcolor = manual2Color, style = label.style_label_left, size = size.small)

    if manual3Enable and manual3Price > 0
        mln3 := line.new(bar_index, manual3Price, manualRightIndex, manual3Price, extend = extend.left, color = manual3Color, style = line.style_solid, width = 1)
        mlb3 := label.new(manualRightIndex, manual3Price, text = manual3Label, color = color.new(manual3Color, 100), textcolor = manual3Color, style = label.style_label_left, size = size.small)

    if manual4Enable and manual4Price > 0
        mln4 := line.new(bar_index, manual4Price, manualRightIndex, manual4Price, extend = extend.left, color = manual4Color, style = line.style_solid, width = 1)
        mlb4 := label.new(manualRightIndex, manual4Price, text = manual4Label, color = color.new(manual4Color, 100), textcolor = manual4Color, style = label.style_label_left, size = size.small)
````
