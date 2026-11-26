# Smart Money Concepts SMC 

- url: https://www.tradingview.com/script/QLSQE141-Smart-Money-Concepts-SMC/
- type: indicator
- pine_id: PUB;3a8044e45e834b789c819cb8a2f7388d
- version: 1.0

## Description

Smart Money Concepts (SMC) — Precision Edition
                                                                                                                                                                                                                     
  A comprehensive Smart Money Concepts indicator built for Indian markets, designed to identify institutional order flow through market structure, order blocks, and fair value gaps — with zero clutter.
                                                                                                                                                                                                                     
  Market Structure                                          
  Automatically detects and labels Break of Structure (BOS), Change of Character (CHoCH), and Market Structure Shift (MSS) using pivot-based swing detection. MSS signals are filtered by ATR-based displacement to  
  ensure only genuine momentum shifts are marked, reducing false signals.                                                                                                                                            
  
  Auto Swing Length                                                                                                                                                                                                  
  The swing detection length adjusts automatically when you change timeframes — no manual tuning required. Each timeframe uses a calibrated value optimised for clean, accurate structure detection. You can override
   it manually at any time from the settings.                                                                                                                                                                        
  
  Order Blocks                                                                                                                                                                                                       
  Marks the last significant opposing candle before each structural break as an Order Block. A minimum body size filter (0.4× ATR) ensures only meaningful institutional candles are highlighted — eliminating tiny,
  irrelevant candles that create noise. Mitigated Order Blocks vanish automatically the moment price trades through them, keeping the chart clean at all times. Each active OB is clearly labelled as Bull OB or Bear
   OB.
                                                                                                                                                                                                                     
  Fair Value Gaps                                           
  Detects and highlights bullish and bearish imbalances between candles. FVGs are removed once price fills or touches them, depending on your mitigation preference.
                                                                                                                                                                                                                     
  Previous High / Low
  Plots the previous session's high and low from any higher timeframe of your choice. Defaults to Daily, giving you immediate reference to key overnight levels.                                                     
                                                                                                                                                                                                                     
  Session Highlighter
  Optionally highlights your custom trading session. Pre-configured for Indian market hours — 9:15 AM to 3:30 PM IST — out of the box.                                                                               
                                                                                                                                                                                                                     
  Settings
  All inputs are grouped and labelled clearly. Zone transparency, label size, and colours for bullish, bearish, BOS, CHoCH, and MSS are all fully customisable.

## Source Code

````pine
//@version=6
indicator("Smart Money Concepts SMC", "SMC", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

groupStructure = "Market Structure"
groupFvg = "Fair Value Gaps"
groupOb = "Order Blocks"
groupLevels = "Previous High Low"
groupSession = "Session"
groupStyle = "Style"

autoSwing = input.bool(true, "Auto Swing Length", group=groupStructure)
swingLenManual = input.int(8, "Manual Swing Length", minval=2, maxval=100, group=groupStructure)
showSwings = input.bool(false, "Show Swing H/L", group=groupStructure)

autoSwingLen = switch timeframe.period
    "1"   => 3
    "3"   => 4
    "5"   => 5
    "10"  => 6
    "15"  => 8
    "30"  => 9
    "45"  => 10
    "60"  => 10
    "120" => 11
    "240" => 12
    "D"   => 7
    "W"   => 5
    "M"   => 4
    => 8

swingLen = autoSwing ? autoSwingLen : swingLenManual
showBos = input.bool(true, "Show BOS", group=groupStructure)
showChoch = input.bool(true, "Show CHoCH", group=groupStructure)
showMss = input.bool(true, "Show MSS", group=groupStructure)
mssAtrLen = input.int(14, "MSS ATR Length", minval=1, maxval=100, group=groupStructure)
mssAtrMult = input.float(0.8, "MSS Displacement ATR", minval=0.0, step=0.1, group=groupStructure)
maxStructureMarks = input.int(80, "Max Structure Marks", minval=10, maxval=250, group=groupStructure)

showFvg = input.bool(true, "Show FVG", group=groupFvg)
fvgMitigation = input.string("Fill", "FVG Mitigation", options=["Touch", "Fill"], group=groupFvg)
maxFvgs = input.int(20, "Max Active FVGs", minval=1, maxval=100, group=groupFvg)

showOb = input.bool(true, "Show Order Blocks", group=groupOb)
obLookback = input.int(10, "OB Search Bars", minval=1, maxval=100, group=groupOb)
obRange = input.string("Body", "OB Range", options=["Full Candle", "Body"], group=groupOb)
obMitigation = input.string("Wick", "OB Mitigation", options=["Wick", "Close"], group=groupOb)
obBodyMinMult = input.float(0.4, "Min Body Size (ATR×)", minval=0.0, step=0.1, group=groupOb)
maxOrderBlocks = input.int(5, "Max Active OBs", minval=1, maxval=20, group=groupOb)

showPrevHL = input.bool(true, "Show Previous High Low", group=groupLevels)
prevTf = input.timeframe("1D", "Timeframe", group=groupLevels)

showSession = input.bool(false, "Show Session", group=groupSession)
sessionTime = input.session("0915-1530", "Session", group=groupSession)
sessionZone = input.string("Asia/Kolkata", "Time Zone", group=groupSession)

bosColor = input.color(color.rgb(37, 99, 235), "BOS", group=groupStyle)
chochColor = input.color(color.rgb(245, 158, 11), "CHoCH", group=groupStyle)
mssColor = input.color(color.rgb(147, 51, 234), "MSS", group=groupStyle)
bullColor = input.color(color.rgb(22, 163, 74), "Bullish", group=groupStyle)
bearColor = input.color(color.rgb(220, 38, 38), "Bearish", group=groupStyle)
zoneTransp = input.int(84, "Zone Transparency", minval=50, maxval=95, group=groupStyle)
labelSizeChoice = input.string("Tiny", "Label Size", options=["Tiny", "Small", "Normal"], group=groupStyle)

labelSize = switch labelSizeChoice
    "Small" => size.small
    "Normal" => size.normal
    => size.tiny

atr = ta.atr(mssAtrLen)
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var int lastHighBar = na
var bool lastHighBroken = false
var float lastLow = na
var int lastLowBar = na
var bool lastLowBroken = false
var int trend = 0

var line[] structureLines = array.new_line()
var label[] structureLabels = array.new_label()
var box[] obBoxes = array.new_box()
var label[] obLabels = array.new_label()
var int[] obDirs = array.new_int()
var box[] fvgBoxes = array.new_box()
var int[] fvgDirs = array.new_int()

f_add_structure(_x1, _y, _txt, _color) =>
    newLine = line.new(_x1, _y, bar_index, _y, color=_color, width=1, style=line.style_dashed)
    newLabel = label.new(bar_index, _y, _txt, color=_color, textcolor=color.white, style=label.style_label_left, size=labelSize)
    array.push(structureLines, newLine)
    array.push(structureLabels, newLabel)
    if array.size(structureLines) > maxStructureMarks
        oldLine = array.shift(structureLines)
        oldLabel = array.shift(structureLabels)
        line.delete(oldLine)
        label.delete(oldLabel)

f_add_ob(_dir, _left, _top, _bot) =>
    obColor = _dir == 1 ? bullColor : bearColor
    newOb = box.new(_left, _top, bar_index, _bot,
                    border_color=color.new(obColor, 10), border_width=2,
                    bgcolor=color.new(obColor, 88), extend=extend.right)
    midPrice = (_top + _bot) / 2.0
    obTxt = _dir == 1 ? "Bull OB" : "Bear OB"
    newLbl = label.new(_left, midPrice, obTxt,
                       color=color.new(obColor, 20),
                       textcolor=color.white,
                       style=label.style_label_right, size=size.small)
    array.push(obBoxes, newOb)
    array.push(obLabels, newLbl)
    array.push(obDirs, _dir)
    if array.size(obBoxes) > maxOrderBlocks
        label.delete(array.shift(obLabels))
        box.delete(array.shift(obBoxes))
        array.shift(obDirs)

f_add_fvg(_dir, _left, _top, _bot) =>
    fvgColor = _dir == 1 ? bullColor : bearColor
    newFvg = box.new(_left, _top, bar_index, _bot, border_color=color.new(fvgColor, 55), bgcolor=color.new(fvgColor, zoneTransp + 4), extend=extend.right)
    array.push(fvgBoxes, newFvg)
    array.push(fvgDirs, _dir)
    if array.size(fvgBoxes) > maxFvgs
        oldFvg = array.shift(fvgBoxes)
        array.shift(fvgDirs)
        box.delete(oldFvg)

if not na(ph)
    lastHigh := ph
    lastHighBar := bar_index - swingLen
    lastHighBroken := false
    if showSwings
        label.new(lastHighBar, ph, "H", color=color.new(bearColor, 10), textcolor=color.white, style=label.style_label_down, size=labelSize)

if not na(pl)
    lastLow := pl
    lastLowBar := bar_index - swingLen
    lastLowBroken := false
    if showSwings
        label.new(lastLowBar, pl, "L", color=color.new(bullColor, 10), textcolor=color.white, style=label.style_label_up, size=labelSize)

if showFvg and array.size(fvgBoxes) > 0
    for i = array.size(fvgBoxes) - 1 to 0
        fvg = array.get(fvgBoxes, i)
        dir = array.get(fvgDirs, i)
        top = box.get_top(fvg)
        bot = box.get_bottom(fvg)
        mitigated = dir == 1 ? (fvgMitigation == "Touch" ? low <= top : low <= bot) : (fvgMitigation == "Touch" ? high >= bot : high >= top)
        if mitigated
            box.set_extend(fvg, extend.none)
            box.set_right(fvg, bar_index)
            box.set_bgcolor(fvg, color.new(dir == 1 ? bullColor : bearColor, 94))
            array.remove(fvgBoxes, i)
            array.remove(fvgDirs, i)

if showOb and array.size(obBoxes) > 0
    for i = array.size(obBoxes) - 1 to 0
        ob = array.get(obBoxes, i)
        dir = array.get(obDirs, i)
        top = box.get_top(ob)
        bot = box.get_bottom(ob)
        mitigated = dir == 1 ? (obMitigation == "Close" ? close < bot : low < bot) : (obMitigation == "Close" ? close > top : high > top)
        if mitigated
            label.delete(array.remove(obLabels, i))
            box.delete(array.remove(obBoxes, i))
            array.remove(obDirs, i)

bullBreak = not na(lastHigh) and not lastHighBroken and bar_index > lastHighBar and close > lastHigh
bearBreak = not na(lastLow) and not lastLowBroken and bar_index > lastLowBar and close < lastLow
bullDisplacement = close > open and math.abs(close - open) >= atr * mssAtrMult
bearDisplacement = close < open and math.abs(close - open) >= atr * mssAtrMult

if bullBreak
    isBos = trend == 1
    isMss = trend == -1 and bullDisplacement
    txt = isBos ? "BOS" : isMss ? "MSS" : "CHoCH"
    col = isBos ? bosColor : isMss ? mssColor : chochColor
    drawIt = isBos ? showBos : isMss ? showMss : showChoch
    if drawIt
        f_add_structure(lastHighBar, lastHigh, txt, col)
    if showOb
        int obBar = na
        float obTop = na
        float obBot = na
        for i = 1 to obLookback
            bodySize = math.abs(close[i] - open[i])
            if close[i] < open[i] and bodySize >= atr * obBodyMinMult
                obBar := bar_index - i
                obTop := obRange == "Body" ? math.max(open[i], close[i]) : high[i]
                obBot := obRange == "Body" ? math.min(open[i], close[i]) : low[i]
                break
        if not na(obBar)
            f_add_ob(1, obBar, obTop, obBot)
    lastHighBroken := true
    trend := 1

if bearBreak
    isBos = trend == -1
    isMss = trend == 1 and bearDisplacement
    txt = isBos ? "BOS" : isMss ? "MSS" : "CHoCH"
    col = isBos ? bosColor : isMss ? mssColor : chochColor
    drawIt = isBos ? showBos : isMss ? showMss : showChoch
    if drawIt
        f_add_structure(lastLowBar, lastLow, txt, col)
    if showOb
        int obBar = na
        float obTop = na
        float obBot = na
        for i = 1 to obLookback
            bodySize = math.abs(close[i] - open[i])
            if close[i] > open[i] and bodySize >= atr * obBodyMinMult
                obBar := bar_index - i
                obTop := obRange == "Body" ? math.max(open[i], close[i]) : high[i]
                obBot := obRange == "Body" ? math.min(open[i], close[i]) : low[i]
                break
        if not na(obBar)
            f_add_ob(-1, obBar, obTop, obBot)
    lastLowBroken := true
    trend := -1

bullFvg = showFvg and bar_index >= 2 and high[2] < low and close[1] > open[1]
bearFvg = showFvg and bar_index >= 2 and low[2] > high and close[1] < open[1]

if bullFvg
    f_add_fvg(1, bar_index - 2, low, high[2])

if bearFvg
    f_add_fvg(-1, bar_index - 2, low[2], high)

prevHigh = request.security(syminfo.tickerid, prevTf, high[1], lookahead=barmerge.lookahead_on)
prevLow = request.security(syminfo.tickerid, prevTf, low[1], lookahead=barmerge.lookahead_on)

plot(showPrevHL ? prevHigh : na, "Previous High", color=color.new(bearColor, 25), style=plot.style_stepline, linewidth=1)
plot(showPrevHL ? prevLow : na, "Previous Low", color=color.new(bullColor, 25), style=plot.style_stepline, linewidth=1)

inSession = showSession and not na(time(timeframe.period, sessionTime, sessionZone))
bgcolor(inSession ? color.new(color.yellow, 92) : na)
````
