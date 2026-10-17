# Market Structure MTF [Joy]

- url: https://www.tradingview.com/script/v2B893hj-Market-Structure-MTF-Joy/
- type: indicator
- pine_id: PUB;6d1c0be2967542d9996cc284a1373ac2
- version: 1.0

## Description

Test 
TEST
TEST
TEST
Test
indicator
TEST
TESt for indicator
TEST
TEST

## Source Code

````pine
//@version=6
indicator("Market Structure MTF [Joy]", overlay=true, max_bars_back=500, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

grp_major = "Major Structure (Higher Timeframe)"
majorTF        = input.timeframe("240", "Major Timeframe", group=grp_major)
majorSwingLen  = input.int(5, "Swing Lookback (bars)", minval=2, maxval=20, group=grp_major)
showMajorLabel = input.bool(true, "Show HH/HL/LH/LL Labels", group=grp_major)
showMajorBOS   = input.bool(true, "Show BOS / CHoCH Lines", group=grp_major)
majorBullCol   = input.color(color.new(#00E5FF, 0), "Bullish Color", group=grp_major)
majorBearCol   = input.color(color.new(#FF4081, 0), "Bearish Color", group=grp_major)

grp_minor = "Minor Structure (Current Chart)"
minorSwingLen  = input.int(3, "Swing Lookback (bars)", minval=2, maxval=20, group=grp_minor)
showMinorLabel = input.bool(true, "Show HH/HL/LH/LL Labels", group=grp_minor)
showMinorBOS   = input.bool(true, "Show BOS / CHoCH Lines", group=grp_minor)
minorBullCol   = input.color(color.new(#00BFA5, 0), "Bullish Color", group=grp_minor)
minorBearCol   = input.color(color.new(#FF6D00, 0), "Bearish Color", group=grp_minor)

grp_sd = "Supply & Demand Zones"
showSD     = input.bool(true, "Show Zones", group=grp_sd)
sdSwingLen = input.int(5, "Zone Swing Lookback", minval=2, maxval=20, group=grp_sd)
sdMaxZones = input.int(3, "Max Zones To Show", minval=1, maxval=6, group=grp_sd)
demandCol  = input.color(color.new(#00E5FF, 85), "Demand Zone Color", group=grp_sd)
supplyCol  = input.color(color.new(#FF4081, 85), "Supply Zone Color", group=grp_sd)
invalidCol = input.color(color.new(#888888, 92), "Invalid Zone Color", group=grp_sd)

grp_liq = "Liquidity"
showLiq      = input.bool(true, "Show Liquidity", group=grp_liq)
liqLen       = input.int(3, "Swing Lookback", minval=2, maxval=20, group=grp_liq)
liqMaxLevels = input.int(5, "Max Levels To Show", minval=1, maxval=10, group=grp_liq)
eqThreshold  = input.float(0.05, "Equal H/L Threshold (%)", minval=0.01, maxval=1.0, step=0.01, group=grp_liq)
liqBullCol   = input.color(color.new(#00E5FF, 0), "Buyside Liq Color", group=grp_liq)
liqBearCol   = input.color(color.new(#FF4081, 0), "Sellside Liq Color", group=grp_liq)
liqSweptCol  = input.color(color.new(#555555, 70), "Swept Color", group=grp_liq)

grp_sniper = "Sniper Entry"
showSniper     = input.bool(true, "Show Sniper Entries", group=grp_sniper)
sniperLookback = input.int(10, "Lookback bars after CHoCH", minval=1, maxval=30, group=grp_sniper)
sniperBullCol  = input.color(color.new(#00FF88, 0), "Long Signal Color", group=grp_sniper)
sniperBearCol  = input.color(color.new(#FF0055, 0), "Short Signal Color", group=grp_sniper)

grp_disp = "Display"
labelSize     = input.string("small", "Label Size", options=["tiny","small","normal","large"], group=grp_disp)
showMajorLine = input.bool(true, "Show Major Swing Lines", group=grp_disp)
showMinorLine = input.bool(false, "Show Minor Swing Lines", group=grp_disp)

// Bulletproof TF detection using timeframe.in_seconds
// 1min = 60s, 2min = 120s, 5min = 300s
// Anything above 300s = NOT a sniper TF
tfSecs  = timeframe.in_seconds()
validTF = tfSecs <= 300

f_labelSize(s) =>
    if s == "tiny"
        size.tiny
    else if s == "small"
        size.small
    else if s == "normal"
        size.normal
    else
        size.large

lsz = f_labelSize(labelSize)

maj_ph = request.security(syminfo.tickerid, majorTF, ta.pivothigh(high, majorSwingLen, majorSwingLen), lookahead=barmerge.lookahead_off)
maj_pl = request.security(syminfo.tickerid, majorTF, ta.pivotlow(low, majorSwingLen, majorSwingLen), lookahead=barmerge.lookahead_off)

var float  maj_lastHigh    = na
var float  maj_prevHigh    = na
var float  maj_lastLow     = na
var float  maj_prevLow     = na
var int    maj_lastHighBar = 0
var int    maj_lastLowBar  = 0
var int    maj_trend       = 0
var string maj_bosDir      = ""
var line   maj_bosLine     = na
var label  maj_bosLbl      = na
var bool   maj_sawLH       = false
var bool   maj_sawHL       = false

float maj_bosCheckHigh    = maj_lastHigh
float maj_bosCheckLow     = maj_lastLow
int   maj_bosCheckHighBar = maj_lastHighBar
int   maj_bosCheckLowBar  = maj_lastLowBar

if not na(maj_ph)
    maj_prevHigh    := maj_lastHigh
    maj_lastHigh    := maj_ph
    maj_lastHighBar := bar_index - majorSwingLen

if not na(maj_pl)
    maj_prevLow    := maj_lastLow
    maj_lastLow    := maj_pl
    maj_lastLowBar := bar_index - majorSwingLen

maj_isHH = not na(maj_ph) and not na(maj_prevHigh) and maj_ph > maj_prevHigh
maj_isLH = not na(maj_ph) and not na(maj_prevHigh) and maj_ph < maj_prevHigh
maj_isHL = not na(maj_pl) and not na(maj_prevLow) and maj_pl > maj_prevLow
maj_isLL = not na(maj_pl) and not na(maj_prevLow) and maj_pl < maj_prevLow

if maj_isLH
    maj_sawLH := true
if maj_isLL and maj_sawLH
    maj_trend := -1
    maj_sawLH := false
    maj_sawHL := false
if maj_isHL
    maj_sawHL := true
if maj_isHH and maj_sawHL
    maj_trend := 1
    maj_sawHL := false
    maj_sawLH := false

maj_bullBOS = not na(maj_bosCheckHigh) and close > maj_bosCheckHigh and close[1] <= maj_bosCheckHigh
maj_bearBOS = not na(maj_bosCheckLow) and close < maj_bosCheckLow and close[1] >= maj_bosCheckLow

if maj_bullBOS
    maj_bosDir := maj_trend == -1 ? "bull_choch" : "bull_bos"
    _isCHoCH   = maj_bosDir == "bull_choch"
    _txt       = _isCHoCH ? "CHoCH" : "BOS"
    _width     = _isCHoCH ? 2 : 1
    _midBar    = math.round((maj_bosCheckHighBar + bar_index) / 2)
    line.delete(maj_bosLine)
    label.delete(maj_bosLbl)
    maj_bosLine := line.new(maj_bosCheckHighBar, maj_bosCheckHigh, bar_index, maj_bosCheckHigh, color=majorBullCol, width=_width, style=line.style_dashed)
    maj_bosLbl  := label.new(_midBar, maj_bosCheckHigh, text=_txt, color=color.new(color.black, 100), textcolor=majorBullCol, style=label.style_label_down, size=size.small)

if maj_bearBOS
    maj_bosDir := maj_trend == 1 ? "bear_choch" : "bear_bos"
    _isCHoCH   = maj_bosDir == "bear_choch"
    _txt       = _isCHoCH ? "CHoCH" : "BOS"
    _width     = _isCHoCH ? 2 : 1
    _midBar    = math.round((maj_bosCheckLowBar + bar_index) / 2)
    line.delete(maj_bosLine)
    label.delete(maj_bosLbl)
    maj_bosLine := line.new(maj_bosCheckLowBar, maj_bosCheckLow, bar_index, maj_bosCheckLow, color=majorBearCol, width=_width, style=line.style_dashed)
    maj_bosLbl  := label.new(_midBar, maj_bosCheckLow, text=_txt, color=color.new(color.black, 100), textcolor=majorBearCol, style=label.style_label_down, size=size.small)

// Major labels and lines ONLY on non-sniper timeframes
if showMajorLabel and not na(maj_ph) and not validTF
    _lbl = maj_isHH ? "HH" : "LH"
    _col = maj_isHH ? majorBullCol : majorBearCol
    label.new(bar_index - majorSwingLen, maj_ph, text=_lbl, color=_col, textcolor=color.white, style=label.style_label_down, size=lsz)

if showMajorLabel and not na(maj_pl) and not validTF
    _lbl = maj_isHL ? "HL" : "LL"
    _col = maj_isHL ? majorBullCol : majorBearCol
    label.new(bar_index - majorSwingLen, maj_pl, text=_lbl, color=_col, textcolor=color.white, style=label.style_label_up, size=lsz)

if showMajorLine and not na(maj_ph) and not validTF
    line.new(bar_index - majorSwingLen * 2, maj_ph, bar_index - majorSwingLen, maj_ph, color=color.new(majorBullCol, 60), width=1, style=line.style_dotted)

if showMajorLine and not na(maj_pl) and not validTF
    line.new(bar_index - majorSwingLen * 2, maj_pl, bar_index - majorSwingLen, maj_pl, color=color.new(majorBearCol, 60), width=1, style=line.style_dotted)

min_ph = ta.pivothigh(high, minorSwingLen, minorSwingLen)
min_pl = ta.pivotlow(low, minorSwingLen, minorSwingLen)

var float min_lastHigh     = na
var float min_prevHigh     = na
var float min_lastLow      = na
var float min_prevLow      = na
var int   min_lastHighBar  = 0
var int   min_lastLowBar   = 0
var int   min_trend        = 0
var int   min_bosDir       = 0
var line  min_bosLine      = na
var label min_bosLbl       = na
var int   min_bullChochBar = 0
var int   min_bearChochBar = 0

float min_bosCheckHigh    = min_lastHigh
float min_bosCheckLow     = min_lastLow
int   min_bosCheckHighBar = min_lastHighBar
int   min_bosCheckLowBar  = min_lastLowBar

if not na(min_ph)
    min_prevHigh    := min_lastHigh
    min_lastHigh    := min_ph
    min_lastHighBar := bar_index - minorSwingLen

if not na(min_pl)
    min_prevLow    := min_lastLow
    min_lastLow    := min_pl
    min_lastLowBar := bar_index - minorSwingLen

min_isHH = not na(min_ph) and not na(min_prevHigh) and min_ph > min_prevHigh
min_isLH = not na(min_ph) and not na(min_prevHigh) and min_ph < min_prevHigh
min_isHL = not na(min_pl) and not na(min_prevLow) and min_pl > min_prevLow
min_isLL = not na(min_pl) and not na(min_prevLow) and min_pl < min_prevLow

min_bullBOS = not na(min_bosCheckHigh) and close > min_bosCheckHigh and close[1] <= min_bosCheckHigh
min_bearBOS = not na(min_bosCheckLow) and close < min_bosCheckLow and close[1] >= min_bosCheckLow

if min_bullBOS
    min_bosDir := min_trend == -1 ? 2 : 1
    min_trend  := 1
    _isCHoCH   = min_bosDir == 2
    if _isCHoCH
        min_bullChochBar := bar_index
    _txt    = _isCHoCH ? "CHoCH" : "BOS"
    _width  = _isCHoCH ? 2 : 1
    _midBar = math.round((min_bosCheckHighBar + bar_index) / 2)
    line.delete(min_bosLine)
    label.delete(min_bosLbl)
    min_bosLine := line.new(min_bosCheckHighBar, min_bosCheckHigh, bar_index, min_bosCheckHigh, color=minorBullCol, width=_width, style=line.style_dashed)
    min_bosLbl  := label.new(_midBar, min_bosCheckHigh, text=_txt, color=color.new(color.black, 100), textcolor=minorBullCol, style=label.style_label_down, size=size.tiny)

if min_bearBOS
    min_bosDir := min_trend == 1 ? -2 : -1
    min_trend  := -1
    _isCHoCH   = min_bosDir == -2
    if _isCHoCH
        min_bearChochBar := bar_index
    _txt    = _isCHoCH ? "CHoCH" : "BOS"
    _width  = _isCHoCH ? 2 : 1
    _midBar = math.round((min_bosCheckLowBar + bar_index) / 2)
    line.delete(min_bosLine)
    label.delete(min_bosLbl)
    min_bosLine := line.new(min_bosCheckLowBar, min_bosCheckLow, bar_index, min_bosCheckLow, color=minorBearCol, width=_width, style=line.style_dashed)
    min_bosLbl  := label.new(_midBar, min_bosCheckLow, text=_txt, color=color.new(color.black, 100), textcolor=minorBearCol, style=label.style_label_down, size=size.tiny)

if showMinorLabel and not na(min_ph)
    _lbl = min_isHH ? "HH" : "LH"
    _col = min_isHH ? minorBullCol : minorBearCol
    label.new(bar_index - minorSwingLen, min_ph, text=_lbl, color=color.new(_col, 20), textcolor=color.white, style=label.style_label_down, size=size.tiny)

if showMinorLabel and not na(min_pl)
    _lbl = min_isHL ? "HL" : "LL"
    _col = min_isHL ? minorBullCol : minorBearCol
    label.new(bar_index - minorSwingLen, min_pl, text=_lbl, color=color.new(_col, 20), textcolor=color.white, style=label.style_label_up, size=size.tiny)

if showMinorLine and not na(min_ph)
    line.new(bar_index - minorSwingLen * 2, min_ph, bar_index - minorSwingLen, min_ph, color=color.new(minorBullCol, 70), width=1, style=line.style_dotted)

if showMinorLine and not na(min_pl)
    line.new(bar_index - minorSwingLen * 2, min_pl, bar_index - minorSwingLen, min_pl, color=color.new(minorBearCol, 70), width=1, style=line.style_dotted)
sd_ph = ta.pivothigh(high, sdSwingLen, sdSwingLen)
sd_pl = ta.pivotlow(low, sdSwingLen, sdSwingLen)

var box[]   sd_boxes  = array.new_box(0)
var bool[]  sd_valid  = array.new_bool(0)
var float[] sd_top    = array.new_float(0)
var float[] sd_bot    = array.new_float(0)
var bool[]  sd_supply = array.new_bool(0)

if showSD and not na(sd_ph)
    _baseTop = high[sdSwingLen]
    _baseBot = low[sdSwingLen]
    for i = 1 to 2
        if high[sdSwingLen + i] < high[sdSwingLen]
            _baseTop := math.max(_baseTop, high[sdSwingLen + i])
            _baseBot := math.min(_baseBot, low[sdSwingLen + i])
    _col = supplyCol
    _bx  = box.new(bar_index - sdSwingLen - 2, _baseTop, bar_index + 20, _baseBot, border_color=color.new(_col, 30), bgcolor=_col, extend=extend.right)
    array.unshift(sd_boxes,  _bx)
    array.unshift(sd_valid,  true)
    array.unshift(sd_top,    _baseTop)
    array.unshift(sd_bot,    _baseBot)
    array.unshift(sd_supply, true)
    if array.size(sd_boxes) > sdMaxZones
        box.delete(array.pop(sd_boxes))
        array.pop(sd_valid)
        array.pop(sd_top)
        array.pop(sd_bot)
        array.pop(sd_supply)

if showSD and not na(sd_pl)
    _baseTop = high[sdSwingLen]
    _baseBot = low[sdSwingLen]
    for i = 1 to 2
        if low[sdSwingLen + i] > low[sdSwingLen]
            _baseTop := math.max(_baseTop, high[sdSwingLen + i])
            _baseBot := math.min(_baseBot, low[sdSwingLen + i])
    _col = demandCol
    _bx  = box.new(bar_index - sdSwingLen - 2, _baseTop, bar_index + 20, _baseBot, border_color=color.new(_col, 30), bgcolor=_col, extend=extend.right)
    array.unshift(sd_boxes,  _bx)
    array.unshift(sd_valid,  true)
    array.unshift(sd_top,    _baseTop)
    array.unshift(sd_bot,    _baseBot)
    array.unshift(sd_supply, false)
    if array.size(sd_boxes) > sdMaxZones
        box.delete(array.pop(sd_boxes))
        array.pop(sd_valid)
        array.pop(sd_top)
        array.pop(sd_bot)
        array.pop(sd_supply)

if showSD
    if array.size(sd_boxes) > 0
        for i = 0 to array.size(sd_boxes) - 1
            if array.get(sd_valid, i)
                _top    = array.get(sd_top, i)
                _bot    = array.get(sd_bot, i)
                _supply = array.get(sd_supply, i)
                _bx     = array.get(sd_boxes, i)
                _broken = _supply ? close > _top : close < _bot
                if _broken
                    array.set(sd_valid, i, false)
                    box.set_bgcolor(_bx, invalidCol)
                    box.set_border_color(_bx, color.new(#888888, 60))
                    box.set_extend(_bx, extend.none)

liq_ph = ta.pivothigh(high, liqLen, liqLen)
liq_pl = ta.pivotlow(low, liqLen, liqLen)

var line[]  liq_lines  = array.new_line(0)
var label[] liq_lbls   = array.new_label(0)
var float[] liq_levels = array.new_float(0)
var bool[]  liq_bulls  = array.new_bool(0)
var bool[]  liq_swept  = array.new_bool(0)
var bool[]  liq_isEQ   = array.new_bool(0)

if showLiq and not na(liq_ph)
    _isEQ = false
    if array.size(liq_levels) > 0
        for i = 0 to array.size(liq_levels) - 1
            _lvl = array.get(liq_levels, i)
            if not na(_lvl) and array.get(liq_bulls, i) and not array.get(liq_swept, i)
                if math.abs(liq_ph - _lvl) / _lvl * 100 <= eqThreshold
                    _isEQ := true
                    break
    _col = liqBullCol
    _txt = _isEQ ? "EQH" : "BSL"
    _ln  = line.new(bar_index - liqLen, liq_ph, bar_index + 40, liq_ph, color=_col, width=1, style=line.style_dotted, extend=extend.right)
    _lbl = label.new(bar_index - liqLen, liq_ph, text=_txt, color=color.new(color.black, 100), textcolor=_col, style=label.style_label_up, size=size.tiny)
    array.unshift(liq_lines,  _ln)
    array.unshift(liq_lbls,   _lbl)
    array.unshift(liq_levels, liq_ph)
    array.unshift(liq_bulls,  true)
    array.unshift(liq_swept,  false)
    array.unshift(liq_isEQ,   _isEQ)
    if array.size(liq_lines) > liqMaxLevels
        line.delete(array.pop(liq_lines))
        label.delete(array.pop(liq_lbls))
        array.pop(liq_levels)
        array.pop(liq_bulls)
        array.pop(liq_swept)
        array.pop(liq_isEQ)

if showLiq and not na(liq_pl)
    _isEQ = false
    if array.size(liq_levels) > 0
        for i = 0 to array.size(liq_levels) - 1
            _lvl = array.get(liq_levels, i)
            if not na(_lvl) and not array.get(liq_bulls, i) and not array.get(liq_swept, i)
                if math.abs(liq_pl - _lvl) / _lvl * 100 <= eqThreshold
                    _isEQ := true
                    break
    _col = liqBearCol
    _txt = _isEQ ? "EQL" : "SSL"
    _ln  = line.new(bar_index - liqLen, liq_pl, bar_index + 40, liq_pl, color=_col, width=1, style=line.style_dotted, extend=extend.right)
    _lbl = label.new(bar_index - liqLen, liq_pl, text=_txt, color=color.new(color.black, 100), textcolor=_col, style=label.style_label_down, size=size.tiny)
    array.unshift(liq_lines,  _ln)
    array.unshift(liq_lbls,   _lbl)
    array.unshift(liq_levels, liq_pl)
    array.unshift(liq_bulls,  false)
    array.unshift(liq_swept,  false)
    array.unshift(liq_isEQ,   _isEQ)
    if array.size(liq_lines) > liqMaxLevels
        line.delete(array.pop(liq_lines))
        label.delete(array.pop(liq_lbls))
        array.pop(liq_levels)
        array.pop(liq_bulls)
        array.pop(liq_swept)
        array.pop(liq_isEQ)

var int lastBullSweepBar = 0
var int lastBearSweepBar = 0

if showLiq
    if array.size(liq_lines) > 0
        for i = 0 to array.size(liq_lines) - 1
            _swept = array.get(liq_swept, i)
            _lvl   = array.get(liq_levels, i)
            _bull  = array.get(liq_bulls, i)
            _ln    = array.get(liq_lines, i)
            _lbl   = array.get(liq_lbls, i)
            if not _swept and not na(_lvl)
                _wasSwiped = _bull ? high > _lvl : low < _lvl
                if _wasSwiped
                    array.set(liq_swept, i, true)
                    line.set_color(_ln, liqSweptCol)
                    line.set_extend(_ln, extend.none)
                    label.set_textcolor(_lbl, liqSweptCol)
                    if _bull
                        lastBullSweepBar := bar_index
                    else
                        lastBearSweepBar := bar_index

inDemandZone = false
inSupplyZone = false
if array.size(sd_boxes) > 0
    for i = 0 to array.size(sd_boxes) - 1
        if array.get(sd_valid, i)
            _top    = array.get(sd_top, i)
            _bot    = array.get(sd_bot, i)
            _supply = array.get(sd_supply, i)
            if close >= _bot and close <= _top
                if _supply
                    inSupplyZone := true
                else
                    inDemandZone := true

afterBullChoch  = (bar_index - min_bullChochBar) > 0 and (bar_index - min_bullChochBar) <= sniperLookback
afterBearChoch  = (bar_index - min_bearChochBar) > 0 and (bar_index - min_bearChochBar) <= sniperLookback
recentBearSweep = (bar_index - lastBearSweepBar) <= sniperLookback
recentBullSweep = (bar_index - lastBullSweepBar) <= sniperLookback

sniperLong  = showSniper and validTF and maj_trend == 1  and afterBullChoch and inDemandZone and recentBearSweep
sniperShort = showSniper and validTF and maj_trend == -1 and afterBearChoch  and inSupplyZone and recentBullSweep

plotshape(sniperLong,  title="Sniper Long",  location=location.belowbar, style=shape.triangleup,   size=size.normal, color=sniperBullCol)
plotshape(sniperShort, title="Sniper Short", location=location.abovebar, style=shape.triangledown, size=size.normal, color=sniperBearCol)

var color bgCol = na
if maj_trend == 1
    bgCol := color.new(majorBullCol, 95)
else if maj_trend == -1
    bgCol := color.new(majorBearCol, 95)
else
    bgCol := na

bgcolor(bgCol, title="Major Bias Background")
````
