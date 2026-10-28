# Trading Spaces Zonal Strategy V3 Clean

- url: https://www.tradingview.com/script/ZW6OhFOl-Trading-Spaces-Zonal-Strategy-V3-Clean/
- type: indicator
- pine_id: PUB;ee0b754a65c64791a765760701ef8ee6
- version: 1.0

## Description

This script manages liquidity shows sweeps and potential oppertunitys

## Source Code

````pine
//@version=6
indicator("Trading Spaces Zonal Strategy V3 Clean", overlay=true, max_boxes_count=350, max_labels_count=500, max_lines_count=50, max_bars_back=5000)

//====================================================
// INPUTS
//====================================================
groupCore = "1. Core Logic"
zoneModeLevel     = input.string("Normal", "Zone Detection Mode", options=["Strict", "Normal", "Aggressive"], group=groupCore)
impulseLookback   = input.int(12, "Impulse Break Lookback", minval=3, maxval=50, group=groupCore)
displacementATR   = input.float(0.8, "Base Displacement ATR Multiplier", minval=0.2, step=0.1, group=groupCore)
obSearchLookback  = input.int(8, "Base OB Search Lookback", minval=2, maxval=30, group=groupCore)
obMode            = input.string("Body", "Order Block Range", options=["Body", "Wick"], group=groupCore)
useBaseCluster    = input.bool(true, "Allow Small Base Cluster Zones", group=groupCore)
zoneInvalidation  = input.string("Close", "Zone Invalidation", options=["Close", "Wick"], group=groupCore)

groupTF = "2. Timeframes"
show15m = input.bool(true, "Show 15m Zones", group=groupTF)
show1h  = input.bool(true, "Show 1 Hour Zones", group=groupTF)
show4h  = input.bool(false, "Show 4 Hour Zones", group=groupTF)

groupStyle = "3. Visual Style"
extendBars            = input.int(220, "Zone Extension Bars", minval=10, maxval=4000, group=groupStyle)
showMitigated         = input.bool(true, "Show Mitigated Zones", group=groupStyle)
maxStoredZones        = input.int(120, "Max Stored Zones", minval=20, maxval=250, group=groupStyle)
showNearestLabelsOnly = input.bool(true, "Label Nearest Zones Only", group=groupStyle)
showRangeInLabels     = input.bool(true, "Show Range In Labels", group=groupStyle)
mitigatedFadeBoost    = input.int(10, "Extra Fade For Mitigated", minval=0, maxval=40, group=groupStyle)

groupConfirm = "4. Sweeps & Confirmations"
showSweepLabels = input.bool(true, "Show Sweeps", group=groupConfirm)
showBuySellConf = input.bool(true, "Show Buy / Sell Confirmations", group=groupConfirm)
sweepLookback   = input.int(6, "Sweep Lookback", minval=2, maxval=20, group=groupConfirm)
confirmWindow   = input.int(3, "Confirmation Window Bars", minval=1, maxval=10, group=groupConfirm)
labelOffsetATR  = input.float(0.15, "Label Offset ATR", minval=0.01, step=0.01, group=groupConfirm)

groupColors = "5. Colors / Opacity"
bull15Bg = input.int(88, "15m Bull Opacity", minval=0, maxval=100, group=groupColors)
bear15Bg = input.int(88, "15m Bear Opacity", minval=0, maxval=100, group=groupColors)
bull1hBg = input.int(91, "1H Bull Opacity", minval=0, maxval=100, group=groupColors)
bear1hBg = input.int(91, "1H Bear Opacity", minval=0, maxval=100, group=groupColors)
bull4hBg = input.int(94, "4H Bull Opacity", minval=0, maxval=100, group=groupColors)
bear4hBg = input.int(94, "4H Bear Opacity", minval=0, maxval=100, group=groupColors)

//====================================================
// MODE PARAMETERS
//====================================================
modeDisp        = zoneModeLevel == "Strict" ? displacementATR * 1.20 : zoneModeLevel == "Normal" ? displacementATR : displacementATR * 0.75
modeSearch      = zoneModeLevel == "Strict" ? math.max(2, obSearchLookback - 2) : zoneModeLevel == "Normal" ? obSearchLookback : obSearchLookback + 4
modeRangeFactor = zoneModeLevel == "Strict" ? 1.25 : zoneModeLevel == "Normal" ? 1.05 : 0.85
modeBodyFactor  = zoneModeLevel == "Strict" ? 1.00 : zoneModeLevel == "Normal" ? 0.85 : 0.65

//====================================================
// HELPERS
//====================================================
f_bull_ob_top(_mode, _search) =>
    float top = na
    for i = 1 to _search
        if close[i] < open[i]
            top := _mode == "Body" ? open[i] : high[i]
            break
    top

f_bull_ob_bot(_mode, _search) =>
    float bot = na
    for i = 1 to _search
        if close[i] < open[i]
            bot := _mode == "Body" ? close[i] : low[i]
            break
    bot

f_bear_ob_top(_mode, _search) =>
    float top = na
    for i = 1 to _search
        if close[i] > open[i]
            top := _mode == "Body" ? close[i] : high[i]
            break
    top

f_bear_ob_bot(_mode, _search) =>
    float bot = na
    for i = 1 to _search
        if close[i] > open[i]
            bot := _mode == "Body" ? open[i] : low[i]
            break
    bot

f_bull_cluster_top(_mode, _search) =>
    float top = na
    int found = 0
    for i = 1 to _search
        if close[i] <= open[i]
            val = _mode == "Body" ? open[i] : high[i]
            top := na(top) ? val : math.max(top, val)
            found += 1
            if found >= 3
                break
    top

f_bull_cluster_bot(_mode, _search) =>
    float bot = na
    int found = 0
    for i = 1 to _search
        if close[i] <= open[i]
            val = _mode == "Body" ? close[i] : low[i]
            bot := na(bot) ? val : math.min(bot, val)
            found += 1
            if found >= 3
                break
    bot

f_bear_cluster_top(_mode, _search) =>
    float top = na
    int found = 0
    for i = 1 to _search
        if close[i] >= open[i]
            val = _mode == "Body" ? close[i] : high[i]
            top := na(top) ? val : math.max(top, val)
            found += 1
            if found >= 3
                break
    top

f_bear_cluster_bot(_mode, _search) =>
    float bot = na
    int found = 0
    for i = 1 to _search
        if close[i] >= open[i]
            val = _mode == "Body" ? open[i] : low[i]
            bot := na(bot) ? val : math.min(bot, val)
            found += 1
            if found >= 3
                break
    bot

f_tfShort(_tf) =>
    _tf == "15" ? "15m" : _tf == "60" ? "1H" : "4H"

f_zoneText(_tf, _dir, _bot, _top) =>
    base = f_tfShort(_tf) + (_dir == 1 ? " Buy" : " Sell")
    showRangeInLabels ? base + "\n" + str.tostring(_bot, format.mintick) + " - " + str.tostring(_top, format.mintick) : base

f_bg(_dir, _tf, _mit) =>
    int extra = _mit ? mitigatedFadeBoost : 0
    int op = 90
    if _tf == "15"
        op := _dir == 1 ? math.min(100, bull15Bg + extra) : math.min(100, bear15Bg + extra)
    else if _tf == "60"
        op := _dir == 1 ? math.min(100, bull1hBg + extra) : math.min(100, bear1hBg + extra)
    else
        op := _dir == 1 ? math.min(100, bull4hBg + extra) : math.min(100, bear4hBg + extra)
    _dir == 1 ? (_tf == "15" ? color.new(color.lime, op) : _tf == "60" ? color.new(color.green, op) : color.new(color.teal, op))
              : (_tf == "15" ? color.new(color.red, op)  : _tf == "60" ? color.new(color.maroon, op) : color.new(color.orange, op))

f_border(_dir, _tf, _mit) =>
    int op = _mit ? 72 : (_tf == "15" ? 12 : 4)
    _dir == 1 ? (_tf == "15" ? color.new(color.lime, op) : _tf == "60" ? color.new(color.green, op) : color.new(color.teal, op))
              : (_tf == "15" ? color.new(color.red, op)  : _tf == "60" ? color.new(color.maroon, op) : color.new(color.orange, op))

//====================================================
// MTF SERIES ENGINE
//====================================================
f_tf_bull_top() =>
    atrLocal = ta.atr(14)
    bodyLocal = math.abs(close - open)
    rangeLocal = high - low
    highestPrev = ta.highest(high[1], impulseLookback)
    bullImpulse = close > open and close > highestPrev and (bodyLocal >= atrLocal * modeDisp * modeBodyFactor or rangeLocal >= atrLocal * modeDisp * modeRangeFactor)

    var float bullTop = na
    var float bullBot = na
    var bool bullActive = false

    if bullImpulse
        tmpTop = useBaseCluster ? f_bull_cluster_top(obMode, modeSearch) : f_bull_ob_top(obMode, modeSearch)
        tmpBot = useBaseCluster ? f_bull_cluster_bot(obMode, modeSearch) : f_bull_ob_bot(obMode, modeSearch)
        if not na(tmpTop) and not na(tmpBot) and tmpTop > tmpBot
            bullTop := tmpTop
            bullBot := tmpBot
            bullActive := true

    bullInvalid = bullActive and not na(bullBot) and (zoneInvalidation == "Close" ? close < bullBot : low < bullBot)
    if bullInvalid
        bullTop := na
        bullBot := na
        bullActive := false

    bullTop

f_tf_bull_bot() =>
    atrLocal = ta.atr(14)
    bodyLocal = math.abs(close - open)
    rangeLocal = high - low
    highestPrev = ta.highest(high[1], impulseLookback)
    bullImpulse = close > open and close > highestPrev and (bodyLocal >= atrLocal * modeDisp * modeBodyFactor or rangeLocal >= atrLocal * modeDisp * modeRangeFactor)

    var float bullTop = na
    var float bullBot = na
    var bool bullActive = false

    if bullImpulse
        tmpTop = useBaseCluster ? f_bull_cluster_top(obMode, modeSearch) : f_bull_ob_top(obMode, modeSearch)
        tmpBot = useBaseCluster ? f_bull_cluster_bot(obMode, modeSearch) : f_bull_ob_bot(obMode, modeSearch)
        if not na(tmpTop) and not na(tmpBot) and tmpTop > tmpBot
            bullTop := tmpTop
            bullBot := tmpBot
            bullActive := true

    bullInvalid = bullActive and not na(bullBot) and (zoneInvalidation == "Close" ? close < bullBot : low < bullBot)
    if bullInvalid
        bullTop := na
        bullBot := na
        bullActive := false

    bullBot

f_tf_bear_top() =>
    atrLocal = ta.atr(14)
    bodyLocal = math.abs(close - open)
    rangeLocal = high - low
    lowestPrev = ta.lowest(low[1], impulseLookback)
    bearImpulse = close < open and close < lowestPrev and (bodyLocal >= atrLocal * modeDisp * modeBodyFactor or rangeLocal >= atrLocal * modeDisp * modeRangeFactor)

    var float bearTop = na
    var float bearBot = na
    var bool bearActive = false

    if bearImpulse
        tmpTop = useBaseCluster ? f_bear_cluster_top(obMode, modeSearch) : f_bear_ob_top(obMode, modeSearch)
        tmpBot = useBaseCluster ? f_bear_cluster_bot(obMode, modeSearch) : f_bear_ob_bot(obMode, modeSearch)
        if not na(tmpTop) and not na(tmpBot) and tmpTop > tmpBot
            bearTop := tmpTop
            bearBot := tmpBot
            bearActive := true

    bearInvalid = bearActive and not na(bearTop) and (zoneInvalidation == "Close" ? close > bearTop : high > bearTop)
    if bearInvalid
        bearTop := na
        bearBot := na
        bearActive := false

    bearTop

f_tf_bear_bot() =>
    atrLocal = ta.atr(14)
    bodyLocal = math.abs(close - open)
    rangeLocal = high - low
    lowestPrev = ta.lowest(low[1], impulseLookback)
    bearImpulse = close < open and close < lowestPrev and (bodyLocal >= atrLocal * modeDisp * modeBodyFactor or rangeLocal >= atrLocal * modeDisp * modeRangeFactor)

    var float bearTop = na
    var float bearBot = na
    var bool bearActive = false

    if bearImpulse
        tmpTop = useBaseCluster ? f_bear_cluster_top(obMode, modeSearch) : f_bear_ob_top(obMode, modeSearch)
        tmpBot = useBaseCluster ? f_bear_cluster_bot(obMode, modeSearch) : f_bear_ob_bot(obMode, modeSearch)
        if not na(tmpTop) and not na(tmpBot) and tmpTop > tmpBot
            bearTop := tmpTop
            bearBot := tmpBot
            bearActive := true

    bearInvalid = bearActive and not na(bearTop) and (zoneInvalidation == "Close" ? close > bearTop : high > bearTop)
    if bearInvalid
        bearTop := na
        bearBot := na
        bearActive := false

    bearBot

//====================================================
// REQUEST HTF DATA
//====================================================
tf15BullTop = request.security(syminfo.tickerid, "15",  f_tf_bull_top(), lookahead=barmerge.lookahead_off)
tf15BullBot = request.security(syminfo.tickerid, "15",  f_tf_bull_bot(), lookahead=barmerge.lookahead_off)
tf15BearTop = request.security(syminfo.tickerid, "15",  f_tf_bear_top(), lookahead=barmerge.lookahead_off)
tf15BearBot = request.security(syminfo.tickerid, "15",  f_tf_bear_bot(), lookahead=barmerge.lookahead_off)

tf1HBullTop = request.security(syminfo.tickerid, "60",  f_tf_bull_top(), lookahead=barmerge.lookahead_off)
tf1HBullBot = request.security(syminfo.tickerid, "60",  f_tf_bull_bot(), lookahead=barmerge.lookahead_off)
tf1HBearTop = request.security(syminfo.tickerid, "60",  f_tf_bear_top(), lookahead=barmerge.lookahead_off)
tf1HBearBot = request.security(syminfo.tickerid, "60",  f_tf_bear_bot(), lookahead=barmerge.lookahead_off)

tf4HBullTop = request.security(syminfo.tickerid, "240", f_tf_bull_top(), lookahead=barmerge.lookahead_off)
tf4HBullBot = request.security(syminfo.tickerid, "240", f_tf_bull_bot(), lookahead=barmerge.lookahead_off)
tf4HBearTop = request.security(syminfo.tickerid, "240", f_tf_bear_top(), lookahead=barmerge.lookahead_off)
tf4HBearBot = request.security(syminfo.tickerid, "240", f_tf_bear_bot(), lookahead=barmerge.lookahead_off)

//====================================================
// STORED ZONES
//====================================================
var box[]     zoneBoxes     = array.new_box()
var label[]   zoneLabels    = array.new_label()
var float[]   zoneTops      = array.new_float()
var float[]   zoneBots      = array.new_float()
var int[]     zoneDirs      = array.new_int()
var string[]  zoneTFs       = array.new_string()
var bool[]    zoneMits      = array.new_bool()
var bool[]    zoneInvalids  = array.new_bool()
var int[]     zoneLefts     = array.new_int()

var float lastSeen15BullTop = na
var float lastSeen15BullBot = na
var float lastSeen15BearTop = na
var float lastSeen15BearBot = na
var float lastSeen1HBullTop = na
var float lastSeen1HBullBot = na
var float lastSeen1HBearTop = na
var float lastSeen1HBearBot = na
var float lastSeen4HBullTop = na
var float lastSeen4HBullBot = na
var float lastSeen4HBearTop = na
var float lastSeen4HBearBot = na

f_trimZones() =>
    while array.size(zoneBoxes) > maxStoredZones
        oldBox = array.shift(zoneBoxes)
        oldLbl = array.shift(zoneLabels)
        array.shift(zoneTops)
        array.shift(zoneBots)
        array.shift(zoneDirs)
        array.shift(zoneTFs)
        array.shift(zoneMits)
        array.shift(zoneInvalids)
        array.shift(zoneLefts)
        box.delete(oldBox)
        label.delete(oldLbl)

f_storeZone(_tf, _dir, _top, _bot) =>
    if not na(_top) and not na(_bot) and _top > _bot
        leftBar = bar_index
        width = _tf == "15" ? 1 : _tf == "60" ? 2 : 3
        b = box.new(left=leftBar, top=_top, right=bar_index + extendBars, bottom=_bot, xloc=xloc.bar_index, bgcolor=f_bg(_dir, _tf, false), border_color=f_border(_dir, _tf, false), border_width=width, force_overlay=true)
        l = label.new(x=bar_index + extendBars, y=_dir == 1 ? _top : _bot, text="", xloc=xloc.bar_index, yloc=yloc.price, style=_dir == 1 ? label.style_label_down : label.style_label_up, textcolor=color.white, color=color.new(color.black, 75), size=size.small, force_overlay=true)

        array.push(zoneBoxes, b)
        array.push(zoneLabels, l)
        array.push(zoneTops, _top)
        array.push(zoneBots, _bot)
        array.push(zoneDirs, _dir)
        array.push(zoneTFs, _tf)
        array.push(zoneMits, false)
        array.push(zoneInvalids, false)
        array.push(zoneLefts, leftBar)

        f_trimZones()

//====================================================
// STORE ALL NEW HTF ZONES
//====================================================
new15Bull = show15m and not na(tf15BullTop) and not na(tf15BullBot) and (na(lastSeen15BullTop) or na(lastSeen15BullBot) or tf15BullTop != lastSeen15BullTop or tf15BullBot != lastSeen15BullBot)
new15Bear = show15m and not na(tf15BearTop) and not na(tf15BearBot) and (na(lastSeen15BearTop) or na(lastSeen15BearBot) or tf15BearTop != lastSeen15BearTop or tf15BearBot != lastSeen15BearBot)
new1HBull = show1h and not na(tf1HBullTop) and not na(tf1HBullBot) and (na(lastSeen1HBullTop) or na(lastSeen1HBullBot) or tf1HBullTop != lastSeen1HBullTop or tf1HBullBot != lastSeen1HBullBot)
new1HBear = show1h and not na(tf1HBearTop) and not na(tf1HBearBot) and (na(lastSeen1HBearTop) or na(lastSeen1HBearBot) or tf1HBearTop != lastSeen1HBearTop or tf1HBearBot != lastSeen1HBearBot)
new4HBull = show4h and not na(tf4HBullTop) and not na(tf4HBullBot) and (na(lastSeen4HBullTop) or na(lastSeen4HBullBot) or tf4HBullTop != lastSeen4HBullTop or tf4HBullBot != lastSeen4HBullBot)
new4HBear = show4h and not na(tf4HBearTop) and not na(tf4HBearBot) and (na(lastSeen4HBearTop) or na(lastSeen4HBearBot) or tf4HBearTop != lastSeen4HBearTop or tf4HBearBot != lastSeen4HBearBot)

if new15Bull
    f_storeZone("15", 1, tf15BullTop, tf15BullBot)
    lastSeen15BullTop := tf15BullTop
    lastSeen15BullBot := tf15BullBot

if new15Bear
    f_storeZone("15", -1, tf15BearTop, tf15BearBot)
    lastSeen15BearTop := tf15BearTop
    lastSeen15BearBot := tf15BearBot

if new1HBull
    f_storeZone("60", 1, tf1HBullTop, tf1HBullBot)
    lastSeen1HBullTop := tf1HBullTop
    lastSeen1HBullBot := tf1HBullBot

if new1HBear
    f_storeZone("60", -1, tf1HBearTop, tf1HBearBot)
    lastSeen1HBearTop := tf1HBearTop
    lastSeen1HBearBot := tf1HBearBot

if new4HBull
    f_storeZone("240", 1, tf4HBullTop, tf4HBullBot)
    lastSeen4HBullTop := tf4HBullTop
    lastSeen4HBullBot := tf4HBullBot

if new4HBear
    f_storeZone("240", -1, tf4HBearTop, tf4HBearBot)
    lastSeen4HBearTop := tf4HBearTop
    lastSeen4HBearBot := tf4HBearBot

//====================================================
// UPDATE STORED ZONES
//====================================================
bool inAnyBullZone = false
bool inAnyBearZone = false

float nearestBullDist = na
float nearestBearDist = na
int nearestBullIdx = na
int nearestBearIdx = na

zoneCount = array.size(zoneBoxes)
if zoneCount > 0
    for i = 0 to zoneCount - 1
        zBox  = array.get(zoneBoxes, i)
        zLbl  = array.get(zoneLabels, i)
        zTop  = array.get(zoneTops, i)
        zBot  = array.get(zoneBots, i)
        zDir  = array.get(zoneDirs, i)
        zTF   = array.get(zoneTFs, i)
        zMit  = array.get(zoneMits, i)
        zInv  = array.get(zoneInvalids, i)
        zLeft = array.get(zoneLefts, i)

        inZoneNow = high >= zBot and low <= zTop

        if not zMit and bar_index > zLeft and inZoneNow
            zMit := true
            array.set(zoneMits, i, true)

        invalidNow = false
        if not zInv
            if zDir == 1
                invalidNow := zoneInvalidation == "Close" ? close < zBot : low < zBot
            else
                invalidNow := zoneInvalidation == "Close" ? close > zTop : high > zTop

        if invalidNow
            zInv := true
            array.set(zoneInvalids, i, true)

        if not zInv and inZoneNow
            if zDir == 1
                inAnyBullZone := true
            else
                inAnyBearZone := true

        if not zInv
            zoneMid = (zTop + zBot) * 0.5
            dist = math.abs(close - zoneMid)
            if zDir == 1
                if na(nearestBullDist) or dist < nearestBullDist
                    nearestBullDist := dist
                    nearestBullIdx := i
            else
                if na(nearestBearDist) or dist < nearestBearDist
                    nearestBearDist := dist
                    nearestBearIdx := i

        visibleZone = not zInv and (showMitigated or not zMit)
        if visibleZone
            box.set_left(zBox, zLeft)
            box.set_right(zBox, bar_index + extendBars)
            box.set_top(zBox, zTop)
            box.set_bottom(zBox, zBot)
            box.set_bgcolor(zBox, f_bg(zDir, zTF, zMit))
            box.set_border_color(zBox, f_border(zDir, zTF, zMit))
        else
            box.set_bgcolor(zBox, color.new(color.white, 100))
            box.set_border_color(zBox, color.new(color.white, 100))
            label.set_text(zLbl, "")
            label.set_color(zLbl, color.new(color.white, 100))
            label.set_textcolor(zLbl, color.new(color.white, 100))

//====================================================
// LABEL MANAGEMENT
//====================================================
if zoneCount > 0
    for i = 0 to zoneCount - 1
        zLbl  = array.get(zoneLabels, i)
        zTop  = array.get(zoneTops, i)
        zBot  = array.get(zoneBots, i)
        zDir  = array.get(zoneDirs, i)
        zTF   = array.get(zoneTFs, i)
        zMit  = array.get(zoneMits, i)
        zInv  = array.get(zoneInvalids, i)

        visibleZone = not zInv and (showMitigated or not zMit)
        showThisLabel = visibleZone and (not showNearestLabelsOnly or i == nearestBullIdx or i == nearestBearIdx)

        if showThisLabel
            label.set_xy(zLbl, bar_index + extendBars, zDir == 1 ? zTop : zBot)
            label.set_text(zLbl, f_zoneText(zTF, zDir, zBot, zTop))
            label.set_color(zLbl, color.new(color.black, 75))
            label.set_textcolor(zLbl, color.white)
        else
            label.set_text(zLbl, "")
            label.set_color(zLbl, color.new(color.white, 100))
            label.set_textcolor(zLbl, color.new(color.white, 100))

//====================================================
// SWEEPS & CONFIRMATIONS
//====================================================
atrNow = ta.atr(14)
belowY = low - atrNow * labelOffsetATR
aboveY = high + atrNow * labelOffsetATR

lowestSweepPrev = ta.lowest(low[1], sweepLookback)
highestSweepPrev = ta.highest(high[1], sweepLookback)

bearishSweep = low < lowestSweepPrev and close > open
bullishSweep = high > highestSweepPrev and close < open

bullSweepInZone = bearishSweep and inAnyBullZone
bearSweepInZone = bullishSweep and inAnyBearZone

var int lastBullSweepBar = na
var int lastBearSweepBar = na

if bullSweepInZone
    lastBullSweepBar := bar_index
    if showSweepLabels
        label.new(x=bar_index, y=belowY, text="SWP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=color.lime, color=color.new(color.black, 100), size=size.tiny, force_overlay=true)

if bearSweepInZone
    lastBearSweepBar := bar_index
    if showSweepLabels
        label.new(x=bar_index, y=aboveY, text="SWP", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=color.red, color=color.new(color.black, 100), size=size.tiny, force_overlay=true)

buyConfirm = not na(lastBullSweepBar) and bar_index > lastBullSweepBar and (bar_index - lastBullSweepBar <= confirmWindow) and close > high[1] and close > open and inAnyBullZone
sellConfirm = not na(lastBearSweepBar) and bar_index > lastBearSweepBar and (bar_index - lastBearSweepBar <= confirmWindow) and close < low[1] and close < open and inAnyBearZone

if showBuySellConf and buyConfirm
    label.new(x=bar_index, y=belowY - atrNow * 0.08, text="BUY", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, textcolor=color.white, color=color.new(color.lime, 0), size=size.small, force_overlay=true)
    lastBullSweepBar := na

if showBuySellConf and sellConfirm
    label.new(x=bar_index, y=aboveY + atrNow * 0.08, text="SELL", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 0), size=size.small, force_overlay=true)
    lastBearSweepBar := na
````
