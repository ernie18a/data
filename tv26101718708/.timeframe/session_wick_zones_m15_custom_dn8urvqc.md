# Session Wick Zones (M15 Custom)

- url: https://www.tradingview.com/script/dN8uRvqc-Session-Wick-Zones-M15-Custom/
- type: indicator
- pine_id: PUB;ac68166285a9439b8f2809333a002aaa
- version: 2.0

## Description

a session indicator with a lot features. Only mark out the wick zones in m15 timeframe

## Source Code

````pine
//@version=5
indicator("Session Wick Zones (M15 Custom)", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

showAsia   = input.bool(true,  "Show Asia Zones")
showLondon = input.bool(true,  "Show London Zones")
showNY     = input.bool(true,  "Show New York Zones")

asiaColor   = input.color(color.orange, "Asia Color")
londonColor = input.color(color.blue,   "London Color")
nyColor     = input.color(color.red,    "New York Color")

asiaBorderColor   = input.color(color.orange, "Asia Border Color")
londonBorderColor = input.color(color.blue,   "London Border Color")
nyBorderColor     = input.color(color.red,    "New York Border Color")

zoneOpacity = input.int(85, "Zone Transparency (0-100)", minval=0, maxval=100)
maxZones    = input.int(20, "Max Zones Visible (0-50)", minval=0, maxval=50)
borderWidth = input.int(2, "Box Border Thickness", minval=1, maxval=5)
minHours    = input.int(6, "Min Untouched Duration (Hours)", minval=1, maxval=240)
deleteOnTap = input.bool(true, "Delete Zone When M15 Body Closes Above/Below Box")

showLabels    = input.bool(true, "Show Zone Labels")
labelSize     = input.string("small", "Label Size", options=["tiny", "small", "normal"])
labelLookback = input.int(30, "Label Offset (M15 Candles Behind Price)", minval=1, maxval=200)

mergeNearby = input.bool(true, "Merge Zones Within Pip Threshold")
pipThresh   = input.float(5.0, "Pip Threshold for Merging", minval=0.1, maxval=50)

// ==== ZONE SIZE LIMITS (PIPS) ====
useMaxZoneSize = input.bool(true, "Limit Maximum Zone Size")
maxZonePips    = input.float(10.0, "Max Zone Size (Pips)", minval=1, maxval=500, step=0.5)
useMinZoneSize = input.bool(true, "Enforce Minimum Zone Size (expand into body)")
minZonePips    = input.float(2.0, "Min Zone Size (Pips)", minval=0.1, maxval=100, step=0.1)

drawAsiaHigh   = input.bool(true, "Draw Asia High Zone")
drawAsiaLow    = input.bool(true, "Draw Asia Low Zone")
drawLondonHigh = input.bool(true, "Draw London High Zone")
drawLondonLow  = input.bool(true, "Draw London Low Zone")
drawNYHigh     = input.bool(true, "Draw NY High Zone")
drawNYLow      = input.bool(true, "Draw NY Low Zone")

asiaSession   = input.session("2000-0400:1234567", "Asia Session")
londonSession = input.session("0300-1200:1234567", "London Session")
nySession     = input.session("0800-1700:1234567", "New York Session")
tz            = "America/New_York"

is_session(sess) =>
    not na(time(timeframe.period, sess, tz))

is_newbar(sess) =>
    t = time("D", sess, tz)
    na(t[1]) and not na(t) or t[1] < t

// ==== QUALIFIED ZONE ARRAYS ====
var box[]    zones         = array.new_box()
var float[]  tops          = array.new_float()
var float[]  bottoms       = array.new_float()
var label[]  zoneLabels    = array.new_label()
var string[] zoneNames     = array.new_string()
var bool[]   zoneIsHigh    = array.new_bool()
var int[]    zoneCreatedAt = array.new_int()
var int[]    zoneLeftBar   = array.new_int()
var color[]  zoneBorderCol = array.new_color()
var color[]  zoneFillCol   = array.new_color()
var line[]   zoneTopLines  = array.new_line()
var line[]   zoneBotLines  = array.new_line()

// ==== PENDING ZONE ARRAYS ====
var float[]  pTop       = array.new_float()
var float[]  pBottom    = array.new_float()
var int[]    pLeftBar   = array.new_int()
var int[]    pStartTime = array.new_int()
var int[]    pCreatedAt = array.new_int()
var color[]  pColor     = array.new_color()
var color[]  pBorderCol = array.new_color()
var string[] pName      = array.new_string()
var bool[]   pIsHigh    = array.new_bool()
// Store the session's extreme body for minimum zone expansion
var float[]  pBodyLimit = array.new_float()

[m15_high, m15_low, m15_open, m15_close] = request.security(syminfo.tickerid, "15", [high, low, open, close])
m15_bodyTop    = math.max(m15_open, m15_close)
m15_bodyBottom = math.min(m15_open, m15_close)
m15_upperWick = m15_high
m15_lowerWick = m15_low

minDurationMs = minHours * 60 * 60 * 1000
weekMs        = 7  * 24 * 60 * 60 * 1000
monthMs       = 30 * 24 * 60 * 60 * 1000
pipSize        = syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)
pipThreshPrice = pipThresh * pipSize
maxZonePrice   = maxZonePips * pipSize
minZonePrice   = minZonePips * pipSize

getLabelSize() =>
    labelSize == "tiny" ? size.tiny : labelSize == "normal" ? size.normal : size.small

buildLabel(isHigh, createdAt) =>
    age    = time - createdAt
    hiLo   = isHigh ? " High" : " Low"
    prefix = age >= monthMs ? "Monthly" : age >= weekMs ? "Weekly" : "Session"
    prefix + hiLo

getLabelBar(leftBar) =>
    math.max(leftBar, bar_index - labelLookback)

isNearExisting(_top, _bottom) =>
    bool found = false
    if array.size(tops) > 0
        for j = 0 to array.size(tops) - 1
            eTop = array.get(tops, j)
            eBot = array.get(bottoms, j)
            if math.abs(_top - eTop) <= pipThreshPrice or math.abs(_bottom - eBot) <= pipThreshPrice or (_top >= eBot and _bottom <= eTop)
                found := true
                break
    found

// ==== CLAMP/EXPAND ZONE SIZE ====
// For HIGH zones: top = wick tip, bottom = wick base or body (expand down for min, clamp up for max)
// For LOW zones: bottom = wick tip, top = wick base or body (expand up for min, clamp down for max)
// bodyLimit: for high zone, the lowest body top of session; for low zone, the highest body bottom of session
clampZoneSize(_top, _bottom, _isHigh, _bodyLimit) =>
    float zTop = _top
    float zBot = _bottom
    float size = zTop - zBot
    // Max: keep only extreme N pips from wick tip
    if useMaxZoneSize and size > maxZonePrice
        if _isHigh
            zBot := zTop - maxZonePrice
        else
            zTop := zBot + maxZonePrice
        size := zTop - zBot
    // Min: expand into body if needed
    if useMinZoneSize and size < minZonePrice
        float needed = minZonePrice - size
        if _isHigh
            // Expand bottom down (into body), but not past bodyLimit
            zBot := math.max(zTop - minZonePrice, _bodyLimit)
        else
            // Expand top up (into body), but not past bodyLimit
            zTop := math.min(zBot + minZonePrice, _bodyLimit)
    [zTop, zBot]

addQualifiedZone(_left, _top, _bottom, _fillCol, _borderCol, _sessName, _isHigh, _createdAt) =>
    bool skip = mergeNearby ? isNearExisting(_top, _bottom) : false
    if not skip
        z  = box.new(_left, _top, bar_index, _bottom,
             border_color = color.new(color.black, 100),
             border_width = 0,
             bgcolor      = color.new(_fillCol, zoneOpacity))
        tl = line.new(_left, _top,    bar_index, _top,
             color=_borderCol, width=borderWidth, extend=extend.none)
        bl = line.new(_left, _bottom, bar_index, _bottom,
             color=_borderCol, width=borderWidth, extend=extend.none)

        array.push(zones, z)
        array.push(tops, _top)
        array.push(bottoms, _bottom)
        array.push(zoneNames, _sessName)
        array.push(zoneIsHigh, _isHigh)
        array.push(zoneCreatedAt, _createdAt)
        array.push(zoneLeftBar, _left)
        array.push(zoneBorderCol, _borderCol)
        array.push(zoneFillCol, _fillCol)
        array.push(zoneTopLines, tl)
        array.push(zoneBotLines, bl)

        if showLabels
            txt    = buildLabel(_isHigh, _createdAt)
            lblBar = getLabelBar(_left)
            lbl    = label.new(
                 x         = lblBar,
                 y         = _isHigh ? _top : _bottom,
                 text      = txt,
                 color     = color.new(color.black, 100),
                 textcolor = _borderCol,
                 style     = _isHigh ? label.style_label_lower_left : label.style_label_upper_left,
                 size      = getLabelSize())
            array.push(zoneLabels, lbl)
        else
            array.push(zoneLabels, label(na))

        while array.size(zones) > maxZones
            box.delete(array.shift(zones))
            array.shift(tops), array.shift(bottoms)
            array.shift(zoneNames), array.shift(zoneIsHigh), array.shift(zoneCreatedAt)
            array.shift(zoneLeftBar), array.shift(zoneBorderCol), array.shift(zoneFillCol)
            line.delete(array.shift(zoneTopLines))
            line.delete(array.shift(zoneBotLines))
            oldLbl = array.shift(zoneLabels)
            if not na(oldLbl)
                label.delete(oldLbl)

pushPending(_top, _bottom, _leftBar, _startTime, _fillCol, _borderCol, _name, _isHigh, _bodyLimit) =>
    array.push(pTop, _top), array.push(pBottom, _bottom)
    array.push(pLeftBar, _leftBar), array.push(pStartTime, _startTime), array.push(pCreatedAt, _startTime)
    array.push(pColor, _fillCol), array.push(pBorderCol, _borderCol)
    array.push(pName, _name), array.push(pIsHigh, _isHigh)
    array.push(pBodyLimit, _bodyLimit)

removePendingAt(i) =>
    array.remove(pTop, i), array.remove(pBottom, i)
    array.remove(pLeftBar, i), array.remove(pStartTime, i), array.remove(pCreatedAt, i)
    array.remove(pColor, i), array.remove(pBorderCol, i)
    array.remove(pName, i), array.remove(pIsHigh, i)
    array.remove(pBodyLimit, i)

removeZoneAt(i) =>
    box.delete(array.get(zones, i))
    line.delete(array.get(zoneTopLines, i))
    line.delete(array.get(zoneBotLines, i))
    lbl = array.get(zoneLabels, i)
    if not na(lbl)
        label.delete(lbl)
    array.remove(zones, i), array.remove(tops, i), array.remove(bottoms, i)
    array.remove(zoneLabels, i), array.remove(zoneNames, i), array.remove(zoneIsHigh, i)
    array.remove(zoneCreatedAt, i), array.remove(zoneLeftBar, i)
    array.remove(zoneBorderCol, i), array.remove(zoneFillCol, i)
    array.remove(zoneTopLines, i), array.remove(zoneBotLines, i)

// ==== ASIA ====
var float a_hi_wick = na, var float a_hi_body = na, var int a_hi_bar = na, var float a_hi_cleanBottom = na
var float a_lo_wick = na, var float a_lo_body = na, var int a_lo_bar = na, var float a_lo_cleanTop    = na
var float a_hi_bodyLimit = na, var float a_lo_bodyLimit = na

a_inSess = is_session(asiaSession)
a_newSess = is_newbar(asiaSession)
a_endSess = not a_inSess and not na(a_hi_wick) and a_inSess[1]

if a_newSess
    a_hi_wick := m15_high, a_hi_body := m15_bodyTop, a_hi_bar := bar_index, a_hi_cleanBottom := m15_bodyTop
    a_lo_wick := m15_low,  a_lo_body := m15_bodyBottom, a_lo_bar := bar_index, a_lo_cleanTop := m15_bodyBottom
    a_hi_bodyLimit := m15_bodyTop
    a_lo_bodyLimit := m15_bodyBottom

if a_inSess
    if m15_high > a_hi_wick
        a_hi_wick := m15_high, a_hi_body := m15_bodyTop, a_hi_bar := bar_index, a_hi_cleanBottom := m15_bodyTop
        a_hi_bodyLimit := m15_bodyTop
    else if bar_index > a_hi_bar and m15_bodyTop > a_hi_body
        a_hi_cleanBottom := math.max(a_hi_cleanBottom, m15_bodyTop)
    if m15_low < a_lo_wick
        a_lo_wick := m15_low, a_lo_body := m15_bodyBottom, a_lo_bar := bar_index, a_lo_cleanTop := m15_bodyBottom
        a_lo_bodyLimit := m15_bodyBottom
    else if bar_index > a_lo_bar and m15_bodyBottom < a_lo_body
        a_lo_cleanTop := math.min(a_lo_cleanTop, m15_bodyBottom)
    // Track the session's extreme body for min zone expansion
    a_hi_bodyLimit := math.min(nz(a_hi_bodyLimit, m15_bodyTop), m15_bodyTop)
    a_lo_bodyLimit := math.max(nz(a_lo_bodyLimit, m15_bodyBottom), m15_bodyBottom)

if a_endSess and showAsia
    if drawAsiaHigh and a_hi_cleanBottom < a_hi_wick
        [clampTop, clampBot] = clampZoneSize(a_hi_wick, a_hi_cleanBottom, true, a_hi_bodyLimit)
        if clampTop > clampBot
            pushPending(clampTop, clampBot, a_hi_bar, time, asiaColor, asiaBorderColor, "Asia", true, a_hi_bodyLimit)
    if drawAsiaLow and a_lo_cleanTop > a_lo_wick
        [clampTop, clampBot] = clampZoneSize(a_lo_cleanTop, a_lo_wick, false, a_lo_bodyLimit)
        if clampTop > clampBot
            pushPending(clampTop, clampBot, a_lo_bar, time, asiaColor, asiaBorderColor, "Asia", false, a_lo_bodyLimit)

// ==== LONDON ====
var float l_hi_wick = na, var float l_hi_body = na, var int l_hi_bar = na, var float l_hi_cleanBottom = na
var float l_lo_wick = na, var float l_lo_body = na, var int l_lo_bar = na, var float l_lo_cleanTop    = na
var float l_hi_bodyLimit = na, var float l_lo_bodyLimit = na

l_inSess = is_session(londonSession)
l_newSess = is_newbar(londonSession)
l_endSess = not l_inSess and not na(l_hi_wick) and l_inSess[1]

if l_newSess
    l_hi_wick := m15_high, l_hi_body := m15_bodyTop, l_hi_bar := bar_index, l_hi_cleanBottom := m15_bodyTop
    l_lo_wick := m15_low,  l_lo_body := m15_bodyBottom, l_lo_bar := bar_index, l_lo_cleanTop := m15_bodyBottom
    l_hi_bodyLimit := m15_bodyTop
    l_lo_bodyLimit := m15_bodyBottom

if l_inSess
    if m15_high > l_hi_wick
        l_hi_wick := m15_high, l_hi_body := m15_bodyTop, l_hi_bar := bar_index, l_hi_cleanBottom := m15_bodyTop
        l_hi_bodyLimit := m15_bodyTop
    else if bar_index > l_hi_bar and m15_bodyTop > l_hi_body
        l_hi_cleanBottom := math.max(l_hi_cleanBottom, m15_bodyTop)
    if m15_low < l_lo_wick
        l_lo_wick := m15_low, l_lo_body := m15_bodyBottom, l_lo_bar := bar_index, l_lo_cleanTop := m15_bodyBottom
        l_lo_bodyLimit := m15_bodyBottom
    else if bar_index > l_lo_bar and m15_bodyBottom < l_lo_body
        l_lo_cleanTop := math.min(l_lo_cleanTop, m15_bodyBottom)
    l_hi_bodyLimit := math.min(nz(l_hi_bodyLimit, m15_bodyTop), m15_bodyTop)
    l_lo_bodyLimit := math.max(nz(l_lo_bodyLimit, m15_bodyBottom), m15_bodyBottom)

if l_endSess and showLondon
    if drawLondonHigh and l_hi_cleanBottom < l_hi_wick
        [clampTop, clampBot] = clampZoneSize(l_hi_wick, l_hi_cleanBottom, true, l_hi_bodyLimit)
        if clampTop > clampBot
            pushPending(clampTop, clampBot, l_hi_bar, time, londonColor, londonBorderColor, "LDN", true, l_hi_bodyLimit)
    if drawLondonLow and l_lo_cleanTop > l_lo_wick
        [clampTop, clampBot] = clampZoneSize(l_lo_cleanTop, l_lo_wick, false, l_lo_bodyLimit)
        if clampTop > clampBot
            pushPending(clampTop, clampBot, l_lo_bar, time, londonColor, londonBorderColor, "LDN", false, l_lo_bodyLimit)

// ==== NY ====
var float n_hi_wick = na, var float n_hi_body = na, var int n_hi_bar = na, var float n_hi_cleanBottom = na
var float n_lo_wick = na, var float n_lo_body = na, var int n_lo_bar = na, var float n_lo_cleanTop    = na
var float n_hi_bodyLimit = na, var float n_lo_bodyLimit = na

n_inSess = is_session(nySession)
n_newSess = is_newbar(nySession)
n_endSess = not n_inSess and not na(n_hi_wick) and n_inSess[1]

if n_newSess
    n_hi_wick := m15_high, n_hi_body := m15_bodyTop, n_hi_bar := bar_index, n_hi_cleanBottom := m15_bodyTop
    n_lo_wick := m15_low,  n_lo_body := m15_bodyBottom, n_lo_bar := bar_index, n_lo_cleanTop := m15_bodyBottom
    n_hi_bodyLimit := m15_bodyTop
    n_lo_bodyLimit := m15_bodyBottom

if n_inSess
    if m15_high > n_hi_wick
        n_hi_wick := m15_high, n_hi_body := m15_bodyTop, n_hi_bar := bar_index, n_hi_cleanBottom := m15_bodyTop
        n_hi_bodyLimit := m15_bodyTop
    else if bar_index > n_hi_bar and m15_bodyTop > n_hi_body
        n_hi_cleanBottom := math.max(n_hi_cleanBottom, m15_bodyTop)
    if m15_low < n_lo_wick
        n_lo_wick := m15_low, n_lo_body := m15_bodyBottom, n_lo_bar := bar_index, n_lo_cleanTop := m15_bodyBottom
        n_lo_bodyLimit := m15_bodyBottom
    else if bar_index > n_lo_bar and m15_bodyBottom < n_lo_body
        n_lo_cleanTop := math.min(n_lo_cleanTop, m15_bodyBottom)
    n_hi_bodyLimit := math.min(nz(n_hi_bodyLimit, m15_bodyTop), m15_bodyTop)
    n_lo_bodyLimit := math.max(nz(n_lo_bodyLimit, m15_bodyBottom), m15_bodyBottom)

if n_endSess and showNY
    if drawNYHigh and n_hi_cleanBottom < n_hi_wick
        [clampTop, clampBot] = clampZoneSize(n_hi_wick, n_hi_cleanBottom, true, n_hi_bodyLimit)
        if clampTop > clampBot
            pushPending(clampTop, clampBot, n_hi_bar, time, nyColor, nyBorderColor, "NY", true, n_hi_bodyLimit)
    if drawNYLow and n_lo_cleanTop > n_lo_wick
        [clampTop, clampBot] = clampZoneSize(n_lo_cleanTop, n_lo_wick, false, n_lo_bodyLimit)
        if clampTop > clampBot
            pushPending(clampTop, clampBot, n_lo_bar, time, nyColor, nyBorderColor, "NY", false, n_lo_bodyLimit)

// ==== PROCESS PENDING ZONES ====
if array.size(pTop) > 0
    for i = array.size(pTop) - 1 to 0
        zTop       = array.get(pTop, i)
        zBottom    = array.get(pBottom, i)
        zLeftBar   = array.get(pLeftBar, i)
        zStart     = array.get(pStartTime, i)
        zCreated   = array.get(pCreatedAt, i)
        zFillCol   = array.get(pColor, i)
        zBorderCol = array.get(pBorderCol, i)
        zName      = array.get(pName, i)
        zIsHigh    = array.get(pIsHigh, i)

        bodyBrokeHigh = zIsHigh     and m15_bodyTop    > zTop
        bodyBrokeLow  = not zIsHigh and m15_bodyBottom < zBottom
        tapped        = time > zStart and (bodyBrokeHigh or bodyBrokeLow)
        matured       = (time - zStart) >= minDurationMs

        if tapped
            removePendingAt(i)
        else if matured
            addQualifiedZone(zLeftBar, zTop, zBottom, zFillCol, zBorderCol, zName, zIsHigh, zCreated)
            removePendingAt(i)

// ==== UPDATE ZONES: WICK-ONLY REFINEMENT ====
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        zTop       = array.get(tops, i)
        zBottom    = array.get(bottoms, i)
        zIsHigh    = array.get(zoneIsHigh, i)
        zCreated   = array.get(zoneCreatedAt, i)
        zLeftBar   = array.get(zoneLeftBar, i)
        zBorderCol = array.get(zoneBorderCol, i)

        box.set_right(array.get(zones, i), bar_index)
        line.set_x2(array.get(zoneTopLines, i), bar_index)
        line.set_x2(array.get(zoneBotLines, i), bar_index)

        bodyInvalidated = zIsHigh ? m15_bodyTop > zTop : m15_bodyBottom < zBottom
        if deleteOnTap and bodyInvalidated
            removeZoneAt(i)
            continue

        if zIsHigh
            if m15_upperWick > zTop
                newTop = m15_upperWick
                array.set(tops, i, newTop)
                line.set_y1(array.get(zoneTopLines, i), newTop)
                line.set_y2(array.get(zoneTopLines, i), newTop)
                box.set_top(array.get(zones, i), newTop)
            if m15_upperWick >= zBottom and m15_upperWick < array.get(tops, i)
                newBottom = math.max(zBottom, m15_upperWick)
                array.set(bottoms, i, newBottom)
                line.set_y1(array.get(zoneBotLines, i), newBottom)
                line.set_y2(array.get(zoneBotLines, i), newBottom)
                box.set_bottom(array.get(zones, i), newBottom)
        else
            if m15_lowerWick < zBottom
                newBottom = m15_lowerWick
                array.set(bottoms, i, newBottom)
                line.set_y1(array.get(zoneBotLines, i), newBottom)
                line.set_y2(array.get(zoneBotLines, i), newBottom)
                box.set_bottom(array.get(zones, i), newBottom)
            if m15_lowerWick <= zTop and m15_lowerWick > array.get(bottoms, i)
                newTop = math.min(zTop, m15_lowerWick)
                array.set(tops, i, newTop)
                line.set_y1(array.get(zoneTopLines, i), newTop)
                line.set_y2(array.get(zoneTopLines, i), newTop)
                box.set_top(array.get(zones, i), newTop)

        if showLabels
            lbl = array.get(zoneLabels, i)
            if not na(lbl)
                label.set_x(lbl, getLabelBar(zLeftBar))
                label.set_y(lbl, zIsHigh ? array.get(tops, i) : array.get(bottoms, i))
                label.set_style(lbl, zIsHigh ? label.style_label_lower_left : label.style_label_upper_left)
                label.set_text(lbl, buildLabel(zIsHigh, zCreated))
                label.set_textcolor(lbl, zBorderCol)
````
