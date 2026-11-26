# Support & Resistance

- url: https://www.tradingview.com/script/FOutQayY-Support-Resistance/
- type: indicator
- pine_id: PUB;9095a18666124dca8b5bd646e692cfc1
- version: 1.0

## Description

s&r mtf is a support and resistance indicator designed to display clean zones directly on the chart.

the script automatically detects support zones from pivot lows and resistance zones from pivot highs. each zone is displayed with a rectangle, a dotted center line, and an optional label.

the goal is to help the trader identify important areas where price may react, reject, break, or come back for a retest.

the mtf version allows zones from a higher timeframe to be displayed on a lower timeframe. for example, daily zones can be displayed on an h1, 30 minute, or 15 minute chart.

this script is not an automatic buy or sell system. it is designed to read market structure, prepare decision zones, and avoid trading without context.

main features

automatic support zones
automatic resistance zones
chart mode or mtf mode
display higher timeframe zones on the current chart
support only below price
resistance only above price
left zone extension
right zone extension
merge zones that touch
merge zones that are too close according to the minimum distance setting
keep the lowest support when zones merge
keep the highest resistance when zones merge
strong candle break filter
optional candle close confirmation
doji filter
atr strength filter
force percentage inside the label
support break alerts
resistance break alerts
clean display with rectangles, center lines, and labels

how the script works

the script creates a resistance zone when a pivot high is confirmed.

the script creates a support zone when a pivot low is confirmed.

a resistance is valid only when it is above the current price.

a support is valid only when it is below the current price.

if two support zones touch or are too close, they are merged and the lowest support is kept.

if two resistance zones touch or are too close, they are merged and the highest resistance is kept.

if price breaks a zone with the selected break conditions, the zone can be removed and an alert can be triggered.

chart mode

chart mode uses the current chart timeframe.

example:
if the chart is on 30 minutes, the zones are calculated from the 30 minute chart pivots.

this mode is useful for reading the exact timeframe you are trading.

mtf mode

mtf mode calculates zones from a higher timeframe and displays them on the current chart.

example:
you are on an h1 chart.
you enable mtf mode.
you choose the daily timeframe.
the script displays daily zones directly on the h1 chart.

this helps keep major market zones visible while trading intraday.

mtf use case example

if you trade on 30 minutes, you can display daily zones.

this helps avoid buying directly under a daily resistance or selling directly above a daily support.

mtf zones are often more important than small lower timeframe zones because they come from a wider market structure.

beginner tutorial

step 1: enable the module

enable the support and resistance module.

if the mode is set to chart, the script uses the current chart timeframe.

if the mode is set to mtf, the script uses the timeframe selected in the mtf settings.

step 2: choose the mode

use chart if you want zones from the current timeframe.

use mtf if you want to see zones from a higher timeframe.

simple example:
for scalping on 10 minutes, display h1 or daily zones.
for trading on h1, display daily zones.
for trading on h4, display daily or weekly zones.

step 3: watch support zones

support zones are located below price.

a support can be used as an area of interest to look for a bullish reaction.

a beginner can wait for a wick rejection, a bullish close, or a reclaim above the zone before looking for a possible long setup.

step 4: watch resistance zones

resistance zones are located above price.

a resistance can be used as an area of interest to look for a bearish reaction.

a beginner can wait for rejection, a bearish close, or a failed breakout before looking for a possible short setup.

step 5: do not trade a zone alone

a zone is not an automatic signal.

you should wait for confirmation.

possible confirmations:
price reaction
wick rejection
clean close
volume
trend alignment
confirmed breakout
zone retest

step 6: use the merge logic

if several zones touch or are too close, the script groups them together.

this helps avoid a chart filled with useless overlapping zones.

for supports, the lowest level is kept.

for resistances, the highest level is kept.

step 7: use the minimum distance setting

minimum distance helps prevent zones from being created too close to each other.

if you lower the distance, the script accepts more zones.

if you increase the distance, the chart becomes cleaner and more selective.

even if the minimum distance is low, two zones that really touch should remain merged.

input explanation

enable s/r module

turns the support and resistance module on or off.

zone source mode

selects the source of the zones.

chart uses the current timeframe.

mtf uses the selected higher timeframe.

mtf zone timeframe

selects the timeframe used to calculate mtf zones.

example:
daily to display daily zones on h1 or 30 minute charts.
weekly to display weekly zones on h4 or daily charts.

pivot length

controls pivot sensitivity.

a lower value creates more zones and reacts faster.

a higher value creates fewer zones but makes them more selective.

number of visible zones

sets the maximum number of visible zones.

a lower value gives a cleaner chart.

a higher value shows more historical structure.

show s/r labels

shows or hides zone labels.

labels can display the zone type, percentage distance, and force value.

show only 2 active zones

keeps only the latest active resistance and the latest active support.

this is useful for a very clean chart.

minimum distance between zones

sets the minimum space between zones.

the higher the value, the fewer close zones will remain.

the lower the value, the more close zones the script accepts.

zone left extension

extends zones to the left.

this helps show the visual origin of a zone.

zone right extension

extends zones to the right.

this projects the zones into the future.

confirm breaks only on candle close

when enabled, a break is confirmed only after the candle closes.

this reduces false breaks during a live candle.

break equals full body outside zone plus strong candle

when enabled, the script requires the full candle body to close outside the zone with enough strength.

this makes break detection stricter.

max doji body to range

defines when a candle is considered a doji.

a doji is a candle with a small body.

doji candles can be ignored to avoid weak break signals.

min strength body to range

defines the minimum body size compared to the full candle range.

a higher value requires a stronger candle.

min strength body greater or equal atr multiplier

defines the minimum body strength compared to atr.

the higher the value, the stronger the break candle must be.

show force percent

shows the zone penetration force inside the label.

cap force percent

limits the displayed force value to avoid very large numbers.

max cap percent

sets the maximum displayed value when the force cap is enabled.

alert break resistance

enables the alert when a resistance zone is broken.

alert break support

enables the alert when a support zone is broken.

bullish use case example

price comes back to a support zone.

the support remains below price.

the market shows a bullish reaction.

a rejection candle appears.

the trader can then watch for a possible long setup, especially if the general trend is bullish.

bearish use case example

price comes back to a resistance zone.

the resistance remains above price.

the market shows rejection.

a bearish candle appears.

the trader can then watch for a possible short setup, especially if the general trend is bearish.

mtf example

you trade on h1.

you enable mtf mode.

you choose daily.

daily zones appear on the h1 chart.

if price reaches a daily resistance, the trader avoids buying too late.

if price returns to a daily support, the trader watches for a possible reaction.

beginner tips

do not trade every zone automatically.

always wait for price reaction.

avoid buying directly below resistance.

avoid selling directly above support.

use mtf zones as major decision areas.

always use a stop loss.

use proper position sizing.

combine the zones with trend, volume, candlesticks, and market structure.

important note

this script does not guarantee results.

supports can break.

resistances can break.

the best use of this tool is to treat it as a map of important market zones, combined with strict risk management and personal confirmation before each trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("S&R", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 1000)

group_SR = "🧱 Support & Resistance"
enableSR       = input.bool(true,  "Enable S/R module", group = group_SR, tooltip = "Enable or disable the support and resistance zone module.")
sr_sourceMode  = input.string("Chart", "Zone source mode", options = ["Chart", "MTF"], group = group_SR, tooltip = "Select Chart to calculate zones from the current chart timeframe, or MTF to calculate zones from a higher/custom timeframe while displaying them on the current chart.")
sr_mtfTF      = input.timeframe("D", "MTF zone timeframe", options = ["15", "30", "60", "240", "D", "W", "M"], group = group_SR, tooltip = "Timeframe used to calculate support and resistance zones when Zone source mode is set to MTF. Example: use D to display daily zones on 1h or 30m charts.")
sr_pivotLen    = input.int(5,      "Pivot length (L = R)", minval = 1, maxval = 50, group = group_SR, tooltip = "Number of bars used on the left and right side of a pivot to confirm a support or resistance level.")
maxZones       = input.int(15,     "Number of visible zones", minval = 1, maxval = 30, group = group_SR, tooltip = "Maximum number of visible support zones and resistance zones kept on the chart.")
showSRLabels   = input.bool(true,  "Show S/R labels", group = group_SR, tooltip = "Show or hide the text labels displayed at the center of each support or resistance zone.")
showOnlyLast2  = input.bool(false, "Show only 2 active zones (zones)", group = group_SR, tooltip = "When enabled, the script keeps only the latest active resistance and the latest active support.")
minZoneDist    = input.float(3,  "Minimum distance between zones (%)", minval = 0.0, step = 0.1, group = group_SR, tooltip = "Minimum vertical gap required between two zones of the same type. If two supports or two resistances touch or are closer than this value, they are merged.")
zoneLeftExt    = input.int(0, "Zone left extension (bars)", minval = 0, maxval = 500, group = group_SR, tooltip = "Extends each zone to the left by the selected number of bars from its original pivot point.")
zoneRightExt   = input.int(200, "Zone right extension (bars)", minval = 0, maxval = 500, group = group_SR, tooltip = "Extends each zone to the right beyond the current bar by the selected number of bars. Maximum is limited to 500 bars.")
confirm_on_close = input.bool(true, "Confirm breaks only on candle close", group="Wizard Volumetric Order Blocks Settings", tooltip = "When enabled, a support or resistance break is confirmed only after the candle closes.")
ok_confirm = not confirm_on_close or barstate.isconfirmed

group_BR = "✅ Break filter"
useStrongBodyBreak   = input.bool(true,  "Break = full body outside zone + strong candle", group = group_BR, tooltip = "Requires the full candle body to close outside the zone with enough strength before deleting a broken zone.")
dojiMaxBodyToRange   = input.float(0.20, "Max doji (body/range)", minval = 0.01, maxval = 0.50, step = 0.01, group = group_BR, tooltip = "Maximum body-to-range ratio used to classify a candle as a doji and avoid weak break confirmations.")
minBodyToRange       = input.float(0.15, "Min strength (body/range)", minval = 0.10, maxval = 0.95, step = 0.01, group = group_BR, tooltip = "Minimum candle body-to-range ratio required to validate a strong support or resistance break.")
minBodyAtr           = input.float(0.15, "Min strength (body >= ATR*x)", minval = 0.00, maxval = 5.00, step = 0.05, group = group_BR, tooltip = "Minimum candle body size expressed as an ATR multiplier required to validate a strong break.")
atrBR = ta.atr(14)

group_F = "💪 Force %"
showForcePct    = input.bool(true,  "Show Force % (zone penetration)", group = group_F, tooltip = "Show or hide the penetration strength percentage inside each support or resistance label.")
capForce        = input.bool(true,  "Cap Force % (prevent huge values)", group = group_F, tooltip = "Caps the displayed force percentage to prevent extremely large values after strong moves beyond a zone.")
capForceMax     = input.float(100.0, "Max cap (%)", minval = 100.0, maxval = 1000.0, step = 10.0, group = group_F, tooltip = "Maximum value allowed for the displayed force percentage when the cap is enabled.")

colRes = color.rgb(255, 3, 3)
colSup = color.rgb(1, 146, 45)

group_AL = "🚨 Alerts — Break S/R"
alertBreakRes = input.bool(true, "Alert: Break Resistance", group=group_AL, tooltip = "Enable an alert condition when a resistance zone is broken by the filtered break logic.")
alertBreakSup = input.bool(true, "Alert: Break Support",    group=group_AL, tooltip = "Enable an alert condition when a support zone is broken by the filtered break logic.")

var bool didBreakRes = false
var bool didBreakSup = false
didBreakRes := false
didBreakSup := false

atrSR = ta.atr(14)

ph = ta.pivothigh(high, sr_pivotLen, sr_pivotLen)
pl = ta.pivotlow(low, sr_pivotLen, sr_pivotLen)
isHigh = not na(ph)
isLow  = not na(pl)

useMTF = sr_sourceMode == "MTF"
f_mtfData() =>
    float _ph = ta.pivothigh(high, sr_pivotLen, sr_pivotLen)
    float _pl = ta.pivotlow(low, sr_pivotLen, sr_pivotLen)
    int _phT = not na(_ph) ? time[sr_pivotLen] : na
    int _plT = not na(_pl) ? time[sr_pivotLen] : na
    [_ph, _pl, _phT, _plT]
[mtfPh, mtfPl, mtfPhTime, mtfPlTime] = request.security(syminfo.tickerid, sr_mtfTF, f_mtfData(), barmerge.gaps_off, barmerge.lookahead_off)
var int lastMtfResTime = na
var int lastMtfSupTime = na

barMs = int(timeframe.in_seconds(timeframe.period) * 1000)

f_safeDenom(y) => math.max(math.abs(y), 1e-6)
f_pct(y)       => ((close - y) / f_safeDenom(y)) * 100.0
vbarLen(_y)    => math.max(atrSR * 0.30, syminfo.mintick * 3)
f_validRes(_y) => _y > close
f_validSup(_y) => _y < close
f_left(_t) => _t - barMs * zoneLeftExt
f_right() => time + barMs * zoneRightExt
f_top(_y) => _y + vbarLen(_y)
f_bot(_y) => _y - vbarLen(_y)
f_zoneGap(_a, _b) =>
    float _aTop = f_top(_a)
    float _aBot = f_bot(_a)
    float _bTop = f_top(_b)
    float _bBot = f_bot(_b)
    _aBot > _bTop ? _aBot - _bTop : _bBot > _aTop ? _bBot - _aTop : 0.0
f_minGap(_a, _b) => math.max(math.max(math.abs(_a), math.abs(_b)) * (minZoneDist * 0.01), 0.0)
f_zonesTouch(_a, _b) => f_zoneGap(_a, _b) <= syminfo.mintick
f_zonesNear(_a, _b) => minZoneDist > 0 and f_zoneGap(_a, _b) <= f_minGap(_a, _b)
f_zonesTouchOrNear(_a, _b) => f_zonesTouch(_a, _b) or f_zonesNear(_a, _b)

f_cap(x) =>
    capForce ? math.min(x, capForceMax) : x

f_forceRes(_y) =>
    float top = _y + vbarLen(_y)
    float bot = _y - vbarLen(_y)
    float h   = math.max(top - bot, syminfo.mintick)
    float f   = 0.0

    if close <= bot
        f := 0.0
    else if close >= top
        f := 100.0 + ((close - top) / h) * 100.0
    else
        f := ((close - bot) / h) * 100.0

    f_cap(f)

f_forceSup(_y) =>
    float top = _y + vbarLen(_y)
    float bot = _y - vbarLen(_y)
    float h   = math.max(top - bot, syminfo.mintick)
    float f   = 0.0

    if close >= top
        f := 0.0
    else if close <= bot
        f := 100.0 + ((bot - close) / h) * 100.0
    else
        f := ((top - close) / h) * 100.0

    f_cap(f)

f_labelTextRes(_y) =>
    string txt = "Resistance " + str.tostring(f_pct(_y), "#.##") + "%"
    if showForcePct
        txt := txt + " | S " + str.tostring(f_forceRes(_y), "#.0") + "%"
    txt

f_labelTextSup(_y) =>
    string txt = "Support " + str.tostring(f_pct(_y), "#.##") + "%"
    if showForcePct
        txt := txt + " | S " + str.tostring(f_forceSup(_y), "#.0") + "%"
    txt

var line[]  resLines      = array.new<line>()
var box[]   resBoxes      = array.new<box>()
var label[] resLabels     = array.new<label>()

var line[]  supLines      = array.new<line>()
var box[]   supBoxes      = array.new<box>()
var label[] supLabels     = array.new<label>()

f_deleteRes(_i) =>
    line.delete(array.get(resLines, _i))
    box.delete(array.get(resBoxes, _i))
    label _lb = array.get(resLabels, _i)
    if not na(_lb)
        label.delete(_lb)
    array.remove(resLines, _i)
    array.remove(resBoxes, _i)
    array.remove(resLabels, _i)

f_deleteSup(_i) =>
    line.delete(array.get(supLines, _i))
    box.delete(array.get(supBoxes, _i))
    label _lb = array.get(supLabels, _i)
    if not na(_lb)
        label.delete(_lb)
    array.remove(supLines, _i)
    array.remove(supBoxes, _i)
    array.remove(supLabels, _i)

f_updateResObj(_i, _level, _left) =>
    int _right = f_right()
    line _ln = array.get(resLines, _i)
    line.set_x1(_ln, _left)
    line.set_y1(_ln, _level)
    line.set_x2(_ln, _right)
    line.set_y2(_ln, _level)
    box _rect = array.get(resBoxes, _i)
    box.set_left(_rect, _left)
    box.set_right(_rect, _right)
    box.set_top(_rect, _level + vbarLen(_level))
    box.set_bottom(_rect, _level - vbarLen(_level))
    label _lb = array.get(resLabels, _i)
    if showSRLabels and not na(_lb)
        int _mid = int(math.round((_left + _right) / 2.0))
        label.set_x(_lb, _mid)
        label.set_y(_lb, _level)
        label.set_text(_lb, f_labelTextRes(_level))
    if not showSRLabels and not na(_lb)
        label.set_text(_lb, "")

f_updateSupObj(_i, _level, _left) =>
    int _right = f_right()
    line _ln = array.get(supLines, _i)
    line.set_x1(_ln, _left)
    line.set_y1(_ln, _level)
    line.set_x2(_ln, _right)
    line.set_y2(_ln, _level)
    box _rect = array.get(supBoxes, _i)
    box.set_left(_rect, _left)
    box.set_right(_rect, _right)
    box.set_top(_rect, _level + vbarLen(_level))
    box.set_bottom(_rect, _level - vbarLen(_level))
    label _lb = array.get(supLabels, _i)
    if showSRLabels and not na(_lb)
        int _mid = int(math.round((_left + _right) / 2.0))
        label.set_x(_lb, _mid)
        label.set_y(_lb, _level)
        label.set_text(_lb, f_labelTextSup(_level))
    if not showSRLabels and not na(_lb)
        label.set_text(_lb, "")

f_mergeResAll() =>
    bool _merged = true
    while _merged
        _merged := false
        int _n = array.size(resLines)
        if _n > 1
            for i = _n - 1 to 1
                if not _merged
                    for j = i - 1 to 0
                        if not _merged
                            float _a = line.get_y1(array.get(resLines, i))
                            float _b = line.get_y1(array.get(resLines, j))
                            if f_zonesTouchOrNear(_a, _b)
                                float _level = math.max(_a, _b)
                                int _left = math.min(line.get_x1(array.get(resLines, i)), line.get_x1(array.get(resLines, j)))
                                f_updateResObj(i, _level, _left)
                                f_deleteRes(j)
                                _merged := true

f_mergeSupAll() =>
    bool _merged = true
    while _merged
        _merged := false
        int _n = array.size(supLines)
        if _n > 1
            for i = _n - 1 to 1
                if not _merged
                    for j = i - 1 to 0
                        if not _merged
                            float _a = line.get_y1(array.get(supLines, i))
                            float _b = line.get_y1(array.get(supLines, j))
                            if f_zonesTouchOrNear(_a, _b)
                                float _level = math.min(_a, _b)
                                int _left = math.min(line.get_x1(array.get(supLines, i)), line.get_x1(array.get(supLines, j)))
                                f_updateSupObj(i, _level, _left)
                                f_deleteSup(j)
                                _merged := true

f_body()  => math.abs(close - open)
f_range() => math.max(high - low, syminfo.mintick)
f_isBull() => close > open
f_isBear() => close < open

f_bodyToRange() =>
    float r = f_range()
    f_body() / r

f_isDoji() =>
    f_bodyToRange() <= dojiMaxBodyToRange

f_isStrongBody() =>
    bool okRange = f_bodyToRange() >= minBodyToRange
    bool okAtr   = f_body() >= (atrBR * minBodyAtr)
    okRange and okAtr

f_breakRes(_y) =>
    float top = _y + vbarLen(_y)
    bool bodyOutside = (open > top) and (close > top)
    if not useStrongBodyBreak
        close > _y
    else
        bodyOutside and f_isBull() and not f_isDoji() and f_isStrongBody()

f_breakSup(_y) =>
    float bot = _y - vbarLen(_y)
    bool bodyOutside = (open < bot) and (close < bot)
    if not useStrongBodyBreak
        close < _y
    else
        bodyOutside and f_isBear() and not f_isDoji() and f_isStrongBody()

f_addRes(_t, _y) =>
    float _level = _y
    int _left = f_left(_t)
    bool _changed = true

    while _changed
        _changed := false
        int _n = array.size(resLines)
        if _n > 0
            for j = _n - 1 to 0
                line _oldLine = array.get(resLines, j)
                float _oldY = line.get_y1(_oldLine)
                if f_zonesTouchOrNear(_level, _oldY)
                    _level := math.max(_level, _oldY)
                    _left := math.min(_left, line.get_x1(_oldLine))
                    f_deleteRes(j)
                    _changed := true

    float _vlen = vbarLen(_level)
    int _right = f_right()

    box rect = box.new(
        left = _left, right = _right,
        top = _level + _vlen, bottom = _level - _vlen,
        xloc = xloc.bar_time,
        bgcolor = color.new(colRes, 85),
        border_color = color.new(colRes, 0),
        border_width = 1
    )
    array.push(resBoxes, rect)

    line ln = line.new(
        x1 = _left, y1 = _level, x2 = _right, y2 = _level,
        xloc = xloc.bar_time,
        color = color.new(colRes, 60),
        style = line.style_dotted,
        width = 1
    )
    array.push(resLines, ln)

    int _mid = int(math.round((_left + _right) / 2.0))
    label lb = na
    if showSRLabels
        lb := label.new(
            x = _mid, y = _level,
            text = f_labelTextRes(_level),
            xloc = xloc.bar_time, yloc = yloc.price,
            style = label.style_label_center,
            textcolor = color.white,
            size = size.tiny,
            color = color.new(color.black, 100)
        )
    array.push(resLabels, lb)

    while array.size(resLines) > maxZones
        f_deleteRes(0)

f_addSup(_t, _y) =>
    float _level = _y
    int _left = f_left(_t)
    bool _changed = true

    while _changed
        _changed := false
        int _n = array.size(supLines)
        if _n > 0
            for j = _n - 1 to 0
                line _oldLine = array.get(supLines, j)
                float _oldY = line.get_y1(_oldLine)
                if f_zonesTouchOrNear(_level, _oldY)
                    _level := math.min(_level, _oldY)
                    _left := math.min(_left, line.get_x1(_oldLine))
                    f_deleteSup(j)
                    _changed := true

    float _vlen = vbarLen(_level)
    int _right = f_right()

    box rect = box.new(
        left = _left, right = _right,
        top = _level + _vlen, bottom = _level - _vlen,
        xloc = xloc.bar_time,
        bgcolor = color.new(colSup, 85),
        border_color = color.new(colSup, 0),
        border_width = 1
    )
    array.push(supBoxes, rect)

    line ln = line.new(
        x1 = _left, y1 = _level, x2 = _right, y2 = _level,
        xloc = xloc.bar_time,
        color = color.new(colSup, 60),
        style = line.style_dotted,
        width = 1
    )
    array.push(supLines, ln)

    int _mid = int(math.round((_left + _right) / 2.0))
    label lb = na
    if showSRLabels
        lb := label.new(
            x = _mid, y = _level,
            text = f_labelTextSup(_level),
            xloc = xloc.bar_time, yloc = yloc.price,
            style = label.style_label_center,
            textcolor = color.white,
            size = size.tiny,
            color = color.new(color.black, 100)
        )
    array.push(supLabels, lb)

    while array.size(supLines) > maxZones
        f_deleteSup(0)

if enableSR
    if useMTF
        bool newMtfRes = not na(mtfPh) and not na(mtfPhTime) and (na(lastMtfResTime) or mtfPhTime != lastMtfResTime)
        bool newMtfSup = not na(mtfPl) and not na(mtfPlTime) and (na(lastMtfSupTime) or mtfPlTime != lastMtfSupTime)
        if newMtfRes
            lastMtfResTime := mtfPhTime
            if f_validRes(mtfPh)
                f_addRes(mtfPhTime, mtfPh)
        if newMtfSup
            lastMtfSupTime := mtfPlTime
            if f_validSup(mtfPl)
                f_addSup(mtfPlTime, mtfPl)
    else
        if isHigh and f_validRes(ph)
            f_addRes(time[sr_pivotLen], ph)
        if isLow and f_validSup(pl)
            f_addSup(time[sr_pivotLen], pl)
    f_mergeResAll()
    f_mergeSupAll()

if enableSR

    int nRes = array.size(resLines)
    if nRes > 0
        for i = nRes - 1 to 0
            line ln = array.get(resLines, i)
            float y = line.get_y1(ln)

            box rect = array.get(resBoxes, i)
            label lb = array.get(resLabels, i)
            bool br = f_breakRes(y)
            bool invalidResSide = not f_validRes(y)

            if invalidResSide
                f_deleteRes(i)
            else
                int _right = f_right()
                line.set_x2(ln, _right)
                box.set_right(rect, _right)
                box.set_top(rect, y + vbarLen(y))
                box.set_bottom(rect, y - vbarLen(y))

                if showSRLabels and not na(lb)
                    int mid = int(math.round((line.get_x1(ln) + _right) / 2.0))
                    label.set_x(lb, mid)
                    label.set_y(lb, y)
                    label.set_text(lb, f_labelTextRes(y))
                if not showSRLabels and not na(lb)
                    label.set_text(lb, "")

                if ok_confirm and br
                    didBreakRes := true
                    f_deleteRes(i)

    int nSup = array.size(supLines)
    if nSup > 0
        for i = nSup - 1 to 0
            line ln = array.get(supLines, i)
            float y = line.get_y1(ln)

            box rect = array.get(supBoxes, i)
            label lb = array.get(supLabels, i)
            bool bs = f_breakSup(y)
            bool invalidSupSide = not f_validSup(y)

            if invalidSupSide
                f_deleteSup(i)
            else
                int _right = f_right()
                line.set_x2(ln, _right)
                box.set_right(rect, _right)
                box.set_top(rect, y + vbarLen(y))
                box.set_bottom(rect, y - vbarLen(y))

                if showSRLabels and not na(lb)
                    int mid = int(math.round((line.get_x1(ln) + _right) / 2.0))
                    label.set_x(lb, mid)
                    label.set_y(lb, y)
                    label.set_text(lb, f_labelTextSup(y))
                if not showSRLabels and not na(lb)
                    label.set_text(lb, "")

                if ok_confirm and bs
                    didBreakSup := true
                    f_deleteSup(i)

if enableSR and showOnlyLast2
    while array.size(resLines) > 1
        f_deleteRes(0)

    while array.size(supLines) > 1
        f_deleteSup(0)
alertcondition(alertBreakRes and didBreakRes, title="break resistance", message="s&r: resistance zone broken.")
alertcondition(alertBreakSup and didBreakSup, title="break support", message="s&r: support zone broken.")
alertcondition((alertBreakRes and didBreakRes) or (alertBreakSup and didBreakSup), title="any s/r break", message="s&r: support or resistance zone broken.")
````
