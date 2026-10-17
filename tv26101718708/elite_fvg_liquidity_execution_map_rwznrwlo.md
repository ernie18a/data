# Elite FVG + Liquidity Execution Map

- url: https://www.tradingview.com/script/rwZnrwLo-Elite-FVG-Liquidity-Execution-Map/
- type: indicator
- pine_id: PUB;594005d5f44a45be91f17d35e1a0dd37
- version: 1.0

## Description

1. Professional / Store Listing Style
The Elite FVG + Liquidity Execution Map is a precision-based ICT trading tool designed to identify high-probability execution zones using multi-timeframe fair value gaps and resting liquidity. It dynamically plots 1H and 30M FVGs, along with 1H and 4H buy-side and sell-side liquidity, highlighting areas where price is most likely to react. The indicator automatically manages mitigation, removes filled zones, and tracks real-time confluence such as liquidity sweeps into FVGs. A built-in dashboard provides bias, active zones, and market state, giving traders a clean, structured view of price delivery.

## Source Code

````pine
//@version=6
indicator("Elite FVG + Liquidity Execution Map", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
groupDisplay = "Display"
show1H_FVG       = input.bool(true, "Show 1H FVGs", group=groupDisplay)
show30M_FVG      = input.bool(true, "Show 30M FVGs", group=groupDisplay)
show1H_Liq       = input.bool(true, "Show 1H Liquidity", group=groupDisplay)
show4H_Liq       = input.bool(true, "Show 4H Liquidity", group=groupDisplay)
showPDLevels     = input.bool(true, "Show PDH / PDL / PWH / PWL", group=groupDisplay)
showLabels       = input.bool(true, "Show Labels", group=groupDisplay)
showCE           = input.bool(true, "Show FVG CE Lines", group=groupDisplay)
showDashboard    = input.bool(true, "Show Dashboard", group=groupDisplay)
nearestOnly      = input.bool(false, "Only Show Nearest Active Zones", group=groupDisplay)

groupLogic = "Logic"
extendBars       = input.int(220, "Extend Zones / Lines", minval=10, group=groupLogic)
maxFVGs          = input.int(80, "Max Stored FVGs", minval=10, maxval=250, group=groupLogic)
maxLiq           = input.int(80, "Max Stored Liquidity Levels", minval=10, maxval=250, group=groupLogic)
liqPivotLen      = input.int(2, "Liquidity Pivot Length", minval=1, maxval=10, group=groupLogic)
minGapTicks      = input.int(2, "Minimum FVG Size In Ticks", minval=1, group=groupLogic)
mitigationMode   = input.string("Shrink Until Full", "FVG Mitigation", options=["Shrink Until Full", "Delete On Touch", "Delete On CE"], group=groupLogic)
confluenceWindow = input.int(20, "Sweep-To-FVG Window", minval=1, maxval=100, group=groupLogic)

groupFilters = "Filters"
useSessionFilter = input.bool(false, "Use Session Filter", group=groupFilters)
tradeSession     = input.session("0830-1100", "Active Session", group=groupFilters)
biasMode         = input.string("Off", "4H Bias Filter", options=["Off", "Aligned Or Neutral", "Strict Aligned"], group=groupFilters)
pdFilter         = input.string("Off", "Premium / Discount Filter", options=["Off", "Previous Day Midpoint"], group=groupFilters)

groupStyle = "Style"
labelSizeOpt     = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal"], group=groupStyle)
lineStyleOpt     = input.string("Solid", "Liquidity Line Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle)
liqTextOffset    = input.int(8, "Liquidity Label Offset In Ticks", minval=1, maxval=50, group=groupStyle)

bull1HColor      = input.color(color.new(#00C076, 84), "1H Bull FVG", group=groupStyle)
bear1HColor      = input.color(color.new(#FF4D4D, 84), "1H Bear FVG", group=groupStyle)
bull30Color      = input.color(color.new(#00A7C2, 87), "30M Bull FVG", group=groupStyle)
bear30Color      = input.color(color.new(#FFB000, 87), "30M Bear FVG", group=groupStyle)
ceColor          = input.color(color.new(color.white, 20), "CE Line", group=groupStyle)
fvgBorderColor   = input.color(color.new(color.white, 76), "FVG Border", group=groupStyle)

liq1HHighColor   = input.color(#FF4D4D, "1H BSL", group=groupStyle)
liq1HLowColor    = input.color(#00C076, "1H SSL", group=groupStyle)
liq4HHighColor   = input.color(#B00020, "4H BSL", group=groupStyle)
liq4HLowColor    = input.color(#25D366, "4H SSL", group=groupStyle)
pdColor          = input.color(color.new(color.white, 15), "PD / PW Levels", group=groupStyle)

//--------------------------------------------------
// Utilities
//--------------------------------------------------
f_labelSize() =>
    labelSizeOpt == "Tiny" ? size.tiny : labelSizeOpt == "Normal" ? size.normal : size.small

f_lineStyle() =>
    lineStyleOpt == "Dashed" ? line.style_dashed : lineStyleOpt == "Dotted" ? line.style_dotted : line.style_solid

f_gapOk(_top, _bot) =>
    math.abs(_top - _bot) >= minGapTicks * syminfo.mintick

f_sessionOk() =>
    not useSessionFilter or not na(time(timeframe.period, tradeSession))

f_mid(_top, _bot) =>
    (_top + _bot) / 2.0

f_visibleColor(_color, _visible, _hiddenTransp) =>
    _visible ? _color : color.new(_color, _hiddenTransp)

f_labelText(_txt, _visible) =>
    showLabels and _visible ? _txt : ""

//--------------------------------------------------
// Higher timeframe data
//--------------------------------------------------
f_getFVG(_tf) =>
    [h3, l3, h1, l1, tfTime] = request.security(
         syminfo.tickerid,
         _tf,
         [high[3], low[3], high[1], low[1], time],
         lookahead=barmerge.lookahead_off
     )

    isNewTFBar = ta.change(tfTime) != 0

    bull = l1 > h3
    bear = h1 < l3

    bullTop = l1
    bullBot = h3

    bearTop = l3
    bearBot = h1

    [isNewTFBar, bull, bear, bullTop, bullBot, bearTop, bearBot]

f_getLiquidity(_tf, _pivotLen) =>
    [tfTime, ph, pl] = request.security(
         syminfo.tickerid,
         _tf,
         [time, ta.pivothigh(high, _pivotLen, _pivotLen), ta.pivotlow(low, _pivotLen, _pivotLen)],
         lookahead=barmerge.lookahead_off
     )

    isNewTFBar = ta.change(tfTime) != 0

    [isNewTFBar and not na(ph), isNewTFBar and not na(pl), ph, pl]

//--------------------------------------------------
// Previous day / week levels
//--------------------------------------------------
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)

pdMid = (pdh + pdl) / 2.0

//--------------------------------------------------
// 4H structure bias
//--------------------------------------------------
[new4HHighBias, new4HLowBias, biasPH, biasPL] = f_getLiquidity("240", liqPivotLen)

var float prevPH = na
var float lastPH = na
var float prevPL = na
var float lastPL = na

if new4HHighBias
    prevPH := lastPH
    lastPH := biasPH

if new4HLowBias
    prevPL := lastPL
    lastPL := biasPL

bias = 0
if not na(prevPH) and not na(lastPH) and not na(prevPL) and not na(lastPL)
    bias := lastPH > prevPH and lastPL > prevPL ? 1 : lastPH < prevPH and lastPL < prevPL ? -1 : 0

biasText = bias == 1 ? "Bullish" : bias == -1 ? "Bearish" : "Neutral"

f_biasOk(_dir) =>
    biasMode == "Off" ? true :
     biasMode == "Aligned Or Neutral" ? (bias == 0 or bias == _dir) :
     bias == _dir

f_pdOk(_dir, _top, _bot) =>
    zoneMid = f_mid(_top, _bot)
    pdFilter == "Off" ? true : _dir == 1 ? zoneMid <= pdMid : zoneMid >= pdMid

//--------------------------------------------------
// FVG storage
//--------------------------------------------------
var box[] fvgBoxes = array.new_box()
var line[] fvgCELines = array.new_line()
var label[] fvgLabels = array.new_label()
var float[] fvgTops = array.new_float()
var float[] fvgBots = array.new_float()
var int[] fvgDirs = array.new_int()
var string[] fvgNames = array.new_string()
var color[] fvgColors = array.new_color()

//--------------------------------------------------
// Liquidity storage
//--------------------------------------------------
var line[] liqLines = array.new_line()
var label[] liqLabels = array.new_label()
var float[] liqPrices = array.new_float()
var int[] liqSides = array.new_int()
var string[] liqNames = array.new_string()
var color[] liqColors = array.new_color()
var int[] liqWidths = array.new_int()

//--------------------------------------------------
// Nearest indexes
//--------------------------------------------------
f_nearestBullFVG() =>
    idx = -1
    dist = 10e10

    if array.size(fvgBoxes) > 0
        for i = 0 to array.size(fvgBoxes) - 1
            dir = array.get(fvgDirs, i)
            topVal = array.get(fvgTops, i)

            if dir == 1 and topVal <= close
                d = close - topVal
                if d < dist
                    dist := d
                    idx := i

    idx

f_nearestBearFVG() =>
    idx = -1
    dist = 10e10

    if array.size(fvgBoxes) > 0
        for i = 0 to array.size(fvgBoxes) - 1
            dir = array.get(fvgDirs, i)
            botVal = array.get(fvgBots, i)

            if dir == -1 and botVal >= close
                d = botVal - close
                if d < dist
                    dist := d
                    idx := i

    idx

f_nearestHighLiq() =>
    idx = -1
    dist = 10e10

    if array.size(liqLines) > 0
        for i = 0 to array.size(liqLines) - 1
            side = array.get(liqSides, i)
            priceVal = array.get(liqPrices, i)

            if side == 1 and priceVal >= close
                d = priceVal - close
                if d < dist
                    dist := d
                    idx := i

    idx

f_nearestLowLiq() =>
    idx = -1
    dist = 10e10

    if array.size(liqLines) > 0
        for i = 0 to array.size(liqLines) - 1
            side = array.get(liqSides, i)
            priceVal = array.get(liqPrices, i)

            if side == -1 and priceVal <= close
                d = close - priceVal
                if d < dist
                    dist := d
                    idx := i

    idx

//--------------------------------------------------
// Add / update FVGs
//--------------------------------------------------
f_trimFVGs() =>
    while array.size(fvgBoxes) > maxFVGs
        box.delete(array.shift(fvgBoxes))
        line.delete(array.shift(fvgCELines))
        label.delete(array.shift(fvgLabels))
        array.shift(fvgTops)
        array.shift(fvgBots)
        array.shift(fvgDirs)
        array.shift(fvgNames)
        array.shift(fvgColors)

f_addFVG(_dir, _top, _bot, _name, _color) =>
    if f_gapOk(_top, _bot) and f_sessionOk() and f_biasOk(_dir) and f_pdOk(_dir, _top, _bot)
        mid = f_mid(_top, _bot)

        bx = box.new(
             left=bar_index,
             top=_top,
             right=bar_index + extendBars,
             bottom=_bot,
             bgcolor=_color,
             border_color=fvgBorderColor,
             border_width=1
         )

        ce = line.new(
             x1=bar_index,
             y1=mid,
             x2=bar_index + extendBars,
             y2=mid,
             color=showCE ? ceColor : color.new(ceColor, 100),
             width=1,
             style=line.style_dotted
         )

        lb = label.new(
             x=bar_index,
             y=mid,
             text=showLabels ? _name : "",
             style=label.style_label_left,
             textcolor=showLabels ? color.white : color.new(color.white, 100),
             color=showLabels ? color.new(color.black, 68) : color.new(color.black, 100),
             size=f_labelSize()
         )

        array.push(fvgBoxes, bx)
        array.push(fvgCELines, ce)
        array.push(fvgLabels, lb)
        array.push(fvgTops, _top)
        array.push(fvgBots, _bot)
        array.push(fvgDirs, _dir)
        array.push(fvgNames, _name)
        array.push(fvgColors, _color)

        f_trimFVGs()

f_updateFVGs(_nearBull, _nearBear, _lastHighSweepBar, _lastLowSweepBar) =>
    bullTap = false
    bearTap = false
    bullCE = false
    bearCE = false
    bullConfluence = false
    bearConfluence = false

    i = array.size(fvgBoxes) - 1

    while i >= 0
        bx = array.get(fvgBoxes, i)
        ce = array.get(fvgCELines, i)
        lb = array.get(fvgLabels, i)
        topVal = array.get(fvgTops, i)
        botVal = array.get(fvgBots, i)
        dir = array.get(fvgDirs, i)
        name = array.get(fvgNames, i)
        baseColor = array.get(fvgColors, i)
        mid = f_mid(topVal, botVal)

        isBull = dir == 1
        touched = isBull ? low <= topVal : high >= botVal
        ceTouched = isBull ? low <= mid : high >= mid
        fullFilled = isBull ? low <= botVal : high >= topVal

        removeZone = mitigationMode == "Delete On Touch" ? touched : mitigationMode == "Delete On CE" ? ceTouched : fullFilled

        if touched
            if isBull
                bullTap := true
                bullCE := ceTouched
                bullConfluence := not na(_lastLowSweepBar) and bar_index - _lastLowSweepBar <= confluenceWindow
            else
                bearTap := true
                bearCE := ceTouched
                bearConfluence := not na(_lastHighSweepBar) and bar_index - _lastHighSweepBar <= confluenceWindow

        if removeZone
            box.delete(bx)
            line.delete(ce)
            label.delete(lb)
            array.remove(fvgBoxes, i)
            array.remove(fvgCELines, i)
            array.remove(fvgLabels, i)
            array.remove(fvgTops, i)
            array.remove(fvgBots, i)
            array.remove(fvgDirs, i)
            array.remove(fvgNames, i)
            array.remove(fvgColors, i)
        else
            if mitigationMode == "Shrink Until Full" and touched
                if isBull and low < topVal and low > botVal
                    topVal := low
                    array.set(fvgTops, i, topVal)

                if not isBull and high > botVal and high < topVal
                    botVal := high
                    array.set(fvgBots, i, botVal)

                mid := f_mid(topVal, botVal)

            visible = not nearestOnly or i == _nearBull or i == _nearBear
            labelName = name

            if isBull and not na(_lastLowSweepBar) and bar_index - _lastLowSweepBar <= confluenceWindow and touched
                labelName := "SSL -> " + name

            if not isBull and not na(_lastHighSweepBar) and bar_index - _lastHighSweepBar <= confluenceWindow and touched
                labelName := "BSL -> " + name

            box.set_top(bx, topVal)
            box.set_bottom(bx, botVal)
            box.set_right(bx, bar_index + extendBars)
            box.set_bgcolor(bx, f_visibleColor(baseColor, visible, 100))
            box.set_border_color(bx, f_visibleColor(fvgBorderColor, visible, 100))

            line.set_x2(ce, bar_index + extendBars)
            line.set_y1(ce, mid)
            line.set_y2(ce, mid)
            line.set_color(ce, showCE and visible ? ceColor : color.new(ceColor, 100))

            label.set_x(lb, bar_index)
            label.set_y(lb, mid)
            label.set_text(lb, f_labelText(labelName, visible))
            label.set_textcolor(lb, showLabels and visible ? color.white : color.new(color.white, 100))
            label.set_color(lb, showLabels and visible ? color.new(color.black, 68) : color.new(color.black, 100))

        i -= 1

    [bullTap, bearTap, bullCE, bearCE, bullConfluence, bearConfluence]

//--------------------------------------------------
// Add / update liquidity
//--------------------------------------------------
f_trimLiq() =>
    while array.size(liqLines) > maxLiq
        line.delete(array.shift(liqLines))
        label.delete(array.shift(liqLabels))
        array.shift(liqPrices)
        array.shift(liqSides)
        array.shift(liqNames)
        array.shift(liqColors)
        array.shift(liqWidths)

f_addLiq(_side, _price, _name, _color, _width) =>
    if f_sessionOk()
        ln = line.new(
             x1=bar_index,
             y1=_price,
             x2=bar_index + extendBars,
             y2=_price,
             color=_color,
             width=_width,
             style=f_lineStyle()
         )

        yOff = liqTextOffset * syminfo.mintick
        y = _side == 1 ? _price + yOff : _price - yOff

        lb = label.new(
             x=bar_index,
             y=y,
             text=showLabels ? _name : "",
             style=label.style_none,
             textcolor=showLabels ? _color : color.new(_color, 100),
             color=na,
             size=f_labelSize()
         )

        array.push(liqLines, ln)
        array.push(liqLabels, lb)
        array.push(liqPrices, _price)
        array.push(liqSides, _side)
        array.push(liqNames, _name)
        array.push(liqColors, _color)
        array.push(liqWidths, _width)

        f_trimLiq()

f_updateLiq(_nearHigh, _nearLow) =>
    highSweep = false
    lowSweep = false

    i = array.size(liqLines) - 1

    while i >= 0
        ln = array.get(liqLines, i)
        lb = array.get(liqLabels, i)
        priceVal = array.get(liqPrices, i)
        side = array.get(liqSides, i)
        name = array.get(liqNames, i)
        baseColor = array.get(liqColors, i)

        swept = side == 1 ? high >= priceVal : low <= priceVal

        if swept
            if side == 1
                highSweep := true
            else
                lowSweep := true

            line.delete(ln)
            label.delete(lb)
            array.remove(liqLines, i)
            array.remove(liqLabels, i)
            array.remove(liqPrices, i)
            array.remove(liqSides, i)
            array.remove(liqNames, i)
            array.remove(liqColors, i)
            array.remove(liqWidths, i)
        else
            visible = not nearestOnly or i == _nearHigh or i == _nearLow
            yOff = liqTextOffset * syminfo.mintick
            y = side == 1 ? priceVal + yOff : priceVal - yOff

            line.set_x2(ln, bar_index + extendBars)
            line.set_color(ln, f_visibleColor(baseColor, visible, 100))

            label.set_x(lb, bar_index)
            label.set_y(lb, y)
            label.set_text(lb, f_labelText(name, visible))
            label.set_textcolor(lb, showLabels and visible ? baseColor : color.new(baseColor, 100))

        i -= 1

    [highSweep, lowSweep]

//--------------------------------------------------
// Detect FVGs
//--------------------------------------------------
[isNew1H, bull1H, bear1H, bull1HTop, bull1HBot, bear1HTop, bear1HBot] = f_getFVG("60")
[isNew30, bull30, bear30, bull30Top, bull30Bot, bear30Top, bear30Bot] = f_getFVG("30")

if show1H_FVG and isNew1H
    if bull1H
        f_addFVG(1, bull1HTop, bull1HBot, "1H FVG+", bull1HColor)
    if bear1H
        f_addFVG(-1, bear1HTop, bear1HBot, "1H FVG-", bear1HColor)

if show30M_FVG and isNew30
    if bull30
        f_addFVG(1, bull30Top, bull30Bot, "30M FVG+", bull30Color)
    if bear30
        f_addFVG(-1, bear30Top, bear30Bot, "30M FVG-", bear30Color)

//--------------------------------------------------
// Detect liquidity
//--------------------------------------------------
[new1HHigh, new1HLow, liq1HHigh, liq1HLow] = f_getLiquidity("60", liqPivotLen)
[new4HHigh, new4HLow, liq4HHigh, liq4HLow] = f_getLiquidity("240", liqPivotLen)

if show1H_Liq
    if new1HHigh
        f_addLiq(1, liq1HHigh, "1H BSL", liq1HHighColor, 1)
    if new1HLow
        f_addLiq(-1, liq1HLow, "1H SSL", liq1HLowColor, 1)

if show4H_Liq
    if new4HHigh
        f_addLiq(1, liq4HHigh, "4H BSL", liq4HHighColor, 2)
    if new4HLow
        f_addLiq(-1, liq4HLow, "4H SSL", liq4HLowColor, 2)

//--------------------------------------------------
// Update active objects
//--------------------------------------------------
nearBullFVG = f_nearestBullFVG()
nearBearFVG = f_nearestBearFVG()
nearHighLiq = f_nearestHighLiq()
nearLowLiq = f_nearestLowLiq()

[liqHighSweep, liqLowSweep] = f_updateLiq(nearHighLiq, nearLowLiq)

var int lastHighSweepBar = na
var int lastLowSweepBar = na

if liqHighSweep
    lastHighSweepBar := bar_index

if liqLowSweep
    lastLowSweepBar := bar_index

[fvgBullTap, fvgBearTap, fvgBullCE, fvgBearCE, bullConfluence, bearConfluence] = f_updateFVGs(nearBullFVG, nearBearFVG, lastHighSweepBar, lastLowSweepBar)

//--------------------------------------------------
// Previous day / week lines
//--------------------------------------------------
var line pdhLine = na
var line pdlLine = na
var line pwhLine = na
var line pwlLine = na
var label pdhLabel = na
var label pdlLabel = na
var label pwhLabel = na
var label pwlLabel = na

pdVisible = showPDLevels

if barstate.isfirst
    pdhLine := line.new(bar_index, pdh, bar_index + extendBars, pdh, color=pdVisible ? pdColor : color.new(pdColor, 100), style=line.style_dashed)
    pdlLine := line.new(bar_index, pdl, bar_index + extendBars, pdl, color=pdVisible ? pdColor : color.new(pdColor, 100), style=line.style_dashed)
    pwhLine := line.new(bar_index, pwh, bar_index + extendBars, pwh, color=pdVisible ? pdColor : color.new(pdColor, 100), style=line.style_solid, width=2)
    pwlLine := line.new(bar_index, pwl, bar_index + extendBars, pwl, color=pdVisible ? pdColor : color.new(pdColor, 100), style=line.style_solid, width=2)

    pdhLabel := label.new(bar_index, pdh, "PDH", style=label.style_none, textcolor=pdVisible ? pdColor : color.new(pdColor, 100), size=f_labelSize())
    pdlLabel := label.new(bar_index, pdl, "PDL", style=label.style_none, textcolor=pdVisible ? pdColor : color.new(pdColor, 100), size=f_labelSize())
    pwhLabel := label.new(bar_index, pwh, "PWH", style=label.style_none, textcolor=pdVisible ? pdColor : color.new(pdColor, 100), size=f_labelSize())
    pwlLabel := label.new(bar_index, pwl, "PWL", style=label.style_none, textcolor=pdVisible ? pdColor : color.new(pdColor, 100), size=f_labelSize())

if not na(pdhLine)
    line.set_xy1(pdhLine, bar_index, pdh)
    line.set_xy2(pdhLine, bar_index + extendBars, pdh)
    line.set_color(pdhLine, pdVisible ? pdColor : color.new(pdColor, 100))

    line.set_xy1(pdlLine, bar_index, pdl)
    line.set_xy2(pdlLine, bar_index + extendBars, pdl)
    line.set_color(pdlLine, pdVisible ? pdColor : color.new(pdColor, 100))

    line.set_xy1(pwhLine, bar_index, pwh)
    line.set_xy2(pwhLine, bar_index + extendBars, pwh)
    line.set_color(pwhLine, pdVisible ? pdColor : color.new(pdColor, 100))

    line.set_xy1(pwlLine, bar_index, pwl)
    line.set_xy2(pwlLine, bar_index + extendBars, pwl)
    line.set_color(pwlLine, pdVisible ? pdColor : color.new(pdColor, 100))

    label.set_x(pdhLabel, bar_index)
    label.set_y(pdhLabel, pdh)
    label.set_text(pdhLabel, pdVisible and showLabels ? "PDH" : "")
    label.set_textcolor(pdhLabel, pdVisible and showLabels ? pdColor : color.new(pdColor, 100))

    label.set_x(pdlLabel, bar_index)
    label.set_y(pdlLabel, pdl)
    label.set_text(pdlLabel, pdVisible and showLabels ? "PDL" : "")
    label.set_textcolor(pdlLabel, pdVisible and showLabels ? pdColor : color.new(pdColor, 100))

    label.set_x(pwhLabel, bar_index)
    label.set_y(pwhLabel, pwh)
    label.set_text(pwhLabel, pdVisible and showLabels ? "PWH" : "")
    label.set_textcolor(pwhLabel, pdVisible and showLabels ? pdColor : color.new(pdColor, 100))

    label.set_x(pwlLabel, bar_index)
    label.set_y(pwlLabel, pwl)
    label.set_text(pwlLabel, pdVisible and showLabels ? "PWL" : "")
    label.set_textcolor(pwlLabel, pdVisible and showLabels ? pdColor : color.new(pdColor, 100))

pdhSweep = showPDLevels and high >= pdh
pdlSweep = showPDLevels and low <= pdl
pwhSweep = showPDLevels and high >= pwh
pwlSweep = showPDLevels and low <= pwl

//--------------------------------------------------
// Dashboard
//--------------------------------------------------
var table dash = table.new(position.top_right, 2, 8, border_width=1)

if barstate.islast
    if showDashboard
        activeFVGs = array.size(fvgBoxes)
        activeLiq = array.size(liqLines)
        setupState = bullConfluence ? "SSL -> Bull FVG" : bearConfluence ? "BSL -> Bear FVG" : liqHighSweep ? "BSL Swept" : liqLowSweep ? "SSL Swept" : "Waiting"

        table.cell(dash, 0, 0, "Elite Map", text_color=color.white, bgcolor=color.new(color.black, 10))
        table.cell(dash, 1, 0, "Live", text_color=color.white, bgcolor=color.new(color.black, 10))

        table.cell(dash, 0, 1, "4H Bias", text_color=color.white, bgcolor=color.new(color.black, 78))
        table.cell(dash, 1, 1, biasText, text_color=bias == 1 ? liq1HLowColor : bias == -1 ? liq1HHighColor : color.white, bgcolor=color.new(color.black, 78))

        table.cell(dash, 0, 2, "FVGs", text_color=color.white, bgcolor=color.new(color.black, 84))
        table.cell(dash, 1, 2, str.tostring(activeFVGs), text_color=color.white, bgcolor=color.new(color.black, 84))

        table.cell(dash, 0, 3, "Liquidity", text_color=color.white, bgcolor=color.new(color.black, 84))
        table.cell(dash, 1, 3, str.tostring(activeLiq), text_color=color.white, bgcolor=color.new(color.black, 84))

        table.cell(dash, 0, 4, "PD Mid", text_color=color.white, bgcolor=color.new(color.black, 88))
        table.cell(dash, 1, 4, str.tostring(pdMid, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 88))

        table.cell(dash, 0, 5, "FVG Mode", text_color=color.white, bgcolor=color.new(color.black, 88))
        table.cell(dash, 1, 5, mitigationMode, text_color=color.white, bgcolor=color.new(color.black, 88))

        table.cell(dash, 0, 6, "Nearest", text_color=color.white, bgcolor=color.new(color.black, 88))
        table.cell(dash, 1, 6, nearestOnly ? "On" : "Off", text_color=color.white, bgcolor=color.new(color.black, 88))

        table.cell(dash, 0, 7, "State", text_color=color.white, bgcolor=color.new(color.black, 82))
        table.cell(dash, 1, 7, setupState, text_color=color.white, bgcolor=color.new(color.black, 82))
    else
        for row = 0 to 7
            table.cell(dash, 0, row, "", bgcolor=color.new(color.black, 100))
            table.cell(dash, 1, row, "", bgcolor=color.new(color.black, 100))

//--------------------------------------------------
// Alerts
//--------------------------------------------------
alertcondition(fvgBullTap, "Bullish FVG Tapped", "Price tapped a bullish FVG.")
alertcondition(fvgBearTap, "Bearish FVG Tapped", "Price tapped a bearish FVG.")
alertcondition(fvgBullCE, "Bullish FVG CE Tapped", "Price reached bullish FVG consequent encroachment.")
alertcondition(fvgBearCE, "Bearish FVG CE Tapped", "Price reached bearish FVG consequent encroachment.")
alertcondition(liqHighSweep, "Buy-Side Liquidity Swept", "Price swept buy-side liquidity.")
alertcondition(liqLowSweep, "Sell-Side Liquidity Swept", "Price swept sell-side liquidity.")
alertcondition(bullConfluence, "SSL Sweep Into Bullish FVG", "Sell-side liquidity swept, then price tapped a bullish FVG.")
alertcondition(bearConfluence, "BSL Sweep Into Bearish FVG", "Buy-side liquidity swept, then price tapped a bearish FVG.")
alertcondition(pdhSweep, "PDH Swept", "Previous day high swept.")
alertcondition(pdlSweep, "PDL Swept", "Previous day low swept.")
alertcondition(pwhSweep, "PWH Swept", "Previous week high swept.")
alertcondition(pwlSweep, "PWL Swept", "Previous week low swept.")
````
