<!-- tradingview-pine-id: PUB;7d26259adcba44b28fd946c751b85571 -->
<!-- tradingviewscripts-format: 1 -->
# IST Sessions & Kill Zones

Source: https://www.tradingview.com/script/lGJKQ5Fv-Forex-Sessions-with-Kill-Zone/

## Description

IST Sessions & Kill Zones

IST Sessions & Kill Zones is a TradingView indicator that automatically plots the major forex trading sessions and ICT-inspired kill zones using Indian Standard Time (IST). It eliminates the need for manual time conversion by automatically switching between Daylight Saving Time (DST) and Non-DST schedules.

Features
Automatic DST Adjustment
Automatically switches between DST (March–October) and Non-DST (November–February) session schedules.
Major Trading Sessions
Sydney Session
Tokyo Session
London Session
New York Session
ICT Kill Zones
Asia Kill Zone
London Kill Zone
New York Kill Zone
Dynamic Range Boxes
Draws live session and kill zone boxes.
Continuously updates the session high and low while the session is active.
Range Midlines
Optional 50% dashed midline for every session and kill zone.
Customizable Appearance
Individual colors for each session and kill zone.
Adjustable box opacity.
Configurable label size and position.
Optional start markers for every session and kill zone.
Fully Configurable Session Times
Modify DST and Non-DST schedules directly from the indicator settings.
Trading Alerts
Alerts for the start of every trading session and kill zone.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("IST Sessions & Kill Zones", "IST Sessions", overlay = true, max_labels_count = 500)

// --- Constants ---
const string IST_TIMEZONE = "Asia/Kolkata"

// The DST schedule is applied from March through October. November through February
// uses the non-DST schedule, matching the seasonal periods supplied by the user.
const string DST_SYDNEY = "0230-1130"
const string DST_TOKYO = "0530-1430"
const string DST_LONDON = "1230-2130"
const string DST_NEW_YORK = "1730-0230"

const string DST_ASIA_KZ = "0530-0930"
const string DST_LONDON_KZ = "1130-1430"
const string DST_NEW_YORK_KZ = "1630-0730"

const string NON_DST_SYDNEY = "0330-1230"
const string NON_DST_TOKYO = "0530-1430"
const string NON_DST_LONDON = "1330-2230"
const string NON_DST_NEW_YORK = "1830-0330"

const string NON_DST_ASIA_KZ = "0630-1030"
const string NON_DST_LONDON_KZ = "1230-1530"
const string NON_DST_NEW_YORK_KZ = "1730-0830"

// --- Inputs ---
groupSessions = "Sessions"
groupKillZones = "Kill Zones"
groupStyle = "Style"
groupDstTimes = "Daylight-saving times (IST)"
groupNonDstTimes = "Non-daylight-saving times (IST)"
groupText = "Text"

dstSydneyTimeInput = input.session(DST_SYDNEY, "Sydney", group = groupDstTimes, tooltip = "Sydney session time used from March through October, in IST.")
dstTokyoTimeInput = input.session(DST_TOKYO, "Tokyo", group = groupDstTimes, tooltip = "Tokyo session time used from March through October, in IST.")
dstLondonTimeInput = input.session(DST_LONDON, "London", group = groupDstTimes, tooltip = "London session time used from March through October, in IST.")
dstNewYorkTimeInput = input.session(DST_NEW_YORK, "New York", group = groupDstTimes, tooltip = "New York session time used from March through October, in IST.")
dstAsiaKillZoneTimeInput = input.session(DST_ASIA_KZ, "Asia kill zone", group = groupDstTimes, tooltip = "Asia kill-zone time used from March through October, in IST.")
dstLondonKillZoneTimeInput = input.session(DST_LONDON_KZ, "London kill zone", group = groupDstTimes, tooltip = "London kill-zone time used from March through October, in IST.")
dstNewYorkKillZoneTimeInput = input.session(DST_NEW_YORK_KZ, "New York kill zone", group = groupDstTimes, tooltip = "New York kill-zone time used from March through October, in IST.")

nonDstSydneyTimeInput = input.session(NON_DST_SYDNEY, "Sydney", group = groupNonDstTimes, tooltip = "Sydney session time used from November through February, in IST.")
nonDstTokyoTimeInput = input.session(NON_DST_TOKYO, "Tokyo", group = groupNonDstTimes, tooltip = "Tokyo session time used from November through February, in IST.")
nonDstLondonTimeInput = input.session(NON_DST_LONDON, "London", group = groupNonDstTimes, tooltip = "London session time used from November through February, in IST.")
nonDstNewYorkTimeInput = input.session(NON_DST_NEW_YORK, "New York", group = groupNonDstTimes, tooltip = "New York session time used from November through February, in IST.")
nonDstAsiaKillZoneTimeInput = input.session(NON_DST_ASIA_KZ, "Asia kill zone", group = groupNonDstTimes, tooltip = "Asia kill-zone time used from November through February, in IST.")
nonDstLondonKillZoneTimeInput = input.session(NON_DST_LONDON_KZ, "London kill zone", group = groupNonDstTimes, tooltip = "London kill-zone time used from November through February, in IST.")
nonDstNewYorkKillZoneTimeInput = input.session(NON_DST_NEW_YORK_KZ, "New York kill zone", group = groupNonDstTimes, tooltip = "New York kill-zone time used from November through February, in IST.")

showSessionsInput = input.bool(true, "Show sessions", group = groupSessions, tooltip = "Shade the Sydney, Tokyo, London, and New York sessions in IST.")
showKillZonesInput = input.bool(true, "Show kill zones", group = groupKillZones, tooltip = "Shade the Asia, London, and New York kill zones in IST.")
showMidlinesInput = input.bool(true, "Show range midlines", group = groupStyle, tooltip = "Show a dashed 50% line through every range box.")
showMarkersInput = input.bool(false, "Show start markers", group = groupStyle, tooltip = "Display a marker when each session or kill zone begins.")
sessionOpacityInput = input.int(16, "Session box opacity", minval = 0, maxval = 100, group = groupStyle, tooltip = "Opacity of session box fills. 0 is invisible and 100 is fully opaque.")
killZoneOpacityInput = input.int(28, "Kill-zone box opacity", minval = 0, maxval = 100, group = groupStyle, tooltip = "Opacity of kill-zone box fills. 0 is invisible and 100 is fully opaque.")
sydneyColorInput = input.color(#5b9cf6, "Sydney", group = groupStyle, inline = "sessionColors", tooltip = "Sydney session color.")
tokyoColorInput = input.color(#8e7dff, "Tokyo", group = groupStyle, inline = "sessionColors", tooltip = "Tokyo session color.")
londonColorInput = input.color(#f6a04d, "London", group = groupStyle, inline = "sessionColors", tooltip = "London session color.")
newYorkColorInput = input.color(#f23645, "New York", group = groupStyle, inline = "sessionColors", tooltip = "New York session color.")
asiaKillZoneColorInput = input.color(#089981, "Asia KZ", group = groupStyle, inline = "killZoneColors", tooltip = "Asia kill zone color.")
londonKillZoneColorInput = input.color(#f6a04d, "London KZ", group = groupStyle, inline = "killZoneColors", tooltip = "London kill zone color.")
newYorkKillZoneColorInput = input.color(#f23645, "New York KZ", group = groupStyle, inline = "killZoneColors", tooltip = "New York kill zone color.")


// --- Text Settings ---
textSizeInput = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = groupText)

textHAlignInput = input.string("Center", "Horizontal Position",
     options = ["Left", "Center", "Right"],
     group = groupText)

textVAlignInput = input.string("Top", "Vertical Position",
     options = ["Top", "Center", "Bottom"],
     group = groupText)

textSize =
     textSizeInput == "Tiny" ? size.tiny :
     textSizeInput == "Small" ? size.small :
     textSizeInput == "Large" ? size.large :
     textSizeInput == "Huge" ? size.huge :
     size.normal

textHAlign =
     textHAlignInput == "Left" ? text.align_left :
     textHAlignInput == "Right" ? text.align_right :
     text.align_center

textVAlign =
     textVAlignInput == "Bottom" ? text.align_bottom :
     textVAlignInput == "Center" ? text.align_center :
     text.align_top

    
// --- Seasonal schedule ---
istMonth = month(time, IST_TIMEZONE)
isDstSeason = istMonth >= 3 and istMonth <= 10

// --- Session state ---
dstSydneyActive = not na(time(timeframe.period, dstSydneyTimeInput, IST_TIMEZONE))
nonDstSydneyActive = not na(time(timeframe.period, nonDstSydneyTimeInput, IST_TIMEZONE))
dstTokyoActive = not na(time(timeframe.period, dstTokyoTimeInput, IST_TIMEZONE))
nonDstTokyoActive = not na(time(timeframe.period, nonDstTokyoTimeInput, IST_TIMEZONE))
dstLondonActive = not na(time(timeframe.period, dstLondonTimeInput, IST_TIMEZONE))
nonDstLondonActive = not na(time(timeframe.period, nonDstLondonTimeInput, IST_TIMEZONE))
dstNewYorkActive = not na(time(timeframe.period, dstNewYorkTimeInput, IST_TIMEZONE))
nonDstNewYorkActive = not na(time(timeframe.period, nonDstNewYorkTimeInput, IST_TIMEZONE))
dstAsiaKillZoneActive = not na(time(timeframe.period, dstAsiaKillZoneTimeInput, IST_TIMEZONE))
nonDstAsiaKillZoneActive = not na(time(timeframe.period, nonDstAsiaKillZoneTimeInput, IST_TIMEZONE))
dstLondonKillZoneActive = not na(time(timeframe.period, dstLondonKillZoneTimeInput, IST_TIMEZONE))
nonDstLondonKillZoneActive = not na(time(timeframe.period, nonDstLondonKillZoneTimeInput, IST_TIMEZONE))
dstNewYorkKillZoneActive = not na(time(timeframe.period, dstNewYorkKillZoneTimeInput, IST_TIMEZONE))
nonDstNewYorkKillZoneActive = not na(time(timeframe.period, nonDstNewYorkKillZoneTimeInput, IST_TIMEZONE))

sydneyActive = isDstSeason ? dstSydneyActive : nonDstSydneyActive
tokyoActive = isDstSeason ? dstTokyoActive : nonDstTokyoActive
londonActive = isDstSeason ? dstLondonActive : nonDstLondonActive
newYorkActive = isDstSeason ? dstNewYorkActive : nonDstNewYorkActive
asiaKillZoneActive = isDstSeason ? dstAsiaKillZoneActive : nonDstAsiaKillZoneActive
londonKillZoneActive = isDstSeason ? dstLondonKillZoneActive : nonDstLondonKillZoneActive
newYorkKillZoneActive = isDstSeason ? dstNewYorkKillZoneActive : nonDstNewYorkKillZoneActive

// --- Start detection ---
sydneyStart = sydneyActive and not sydneyActive[1]
tokyoStart = tokyoActive and not tokyoActive[1]
londonStart = londonActive and not londonActive[1]
newYorkStart = newYorkActive and not newYorkActive[1]
asiaKillZoneStart = asiaKillZoneActive and not asiaKillZoneActive[1]
londonKillZoneStart = londonKillZoneActive and not londonKillZoneActive[1]
newYorkKillZoneStart = newYorkKillZoneActive and not newYorkKillZoneActive[1]

// --- Persistent range objects ---
var box sydneyBox = na
var box tokyoBox = na
var box londonBox = na
var box newYorkBox = na
var box asiaKillZoneBox = na
var box londonKillZoneBox = na
var box newYorkKillZoneBox = na
var line sydneyMidline = na
var line tokyoMidline = na
var line londonMidline = na
var line newYorkMidline = na
var line asiaKillZoneMidline = na
var line londonKillZoneMidline = na
var line newYorkKillZoneMidline = na
var float sydneyHigh = na
var float sydneyLow = na
var float tokyoHigh = na
var float tokyoLow = na
var float londonHigh = na
var float londonLow = na
var float newYorkHigh = na
var float newYorkLow = na
var float asiaKillZoneHigh = na
var float asiaKillZoneLow = na
var float londonKillZoneHigh = na
var float londonKillZoneLow = na
var float newYorkKillZoneHigh = na
var float newYorkKillZoneLow = na

// --- Sydney range box ---
if showSessionsInput and sydneyStart
    sydneyHigh := high
    sydneyLow := low
    sydneyBox := box.new(left = bar_index, top = sydneyHigh, right = bar_index, bottom = sydneyLow, bgcolor = color.new(sydneyColorInput, 100 - sessionOpacityInput), border_color = sydneyColorInput, border_width = 1)
    box.set_text(sydneyBox, "Sydney Session")
    box.set_text_color(sydneyBox, chart.fg_color)
    box.set_text_halign(sydneyBox, textHAlign)
    box.set_text_valign(sydneyBox, textVAlign)
    box.set_text_size(sydneyBox, textSize)
    sydneyMidline := showMidlinesInput ? line.new(x1 = bar_index, y1 = hl2, x2 = bar_index, y2 = hl2, color = sydneyColorInput, style = line.style_dashed) : na
else if showSessionsInput and sydneyActive
    sydneyHigh := math.max(sydneyHigh, high)
    sydneyLow := math.min(sydneyLow, low)
    box.set_top(sydneyBox, sydneyHigh)
    box.set_bottom(sydneyBox, sydneyLow)
    box.set_right(sydneyBox, bar_index)
    if not na(sydneyMidline)
        line.set_xy1(sydneyMidline, box.get_left(sydneyBox), (sydneyHigh + sydneyLow) / 2.0)
        line.set_xy2(sydneyMidline, bar_index, (sydneyHigh + sydneyLow) / 2.0)

// --- Tokyo range box ---
if showSessionsInput and tokyoStart
    tokyoHigh := high
    tokyoLow := low
    tokyoBox := box.new(left = bar_index, top = tokyoHigh, right = bar_index, bottom = tokyoLow, bgcolor = color.new(tokyoColorInput, 100 - sessionOpacityInput), border_color = tokyoColorInput, border_width = 1)
    box.set_text(tokyoBox, "Tokyo Session")
    box.set_text_color(tokyoBox, chart.fg_color)
    box.set_text_halign(tokyoBox, textHAlign)
    box.set_text_valign(tokyoBox, textVAlign)
    box.set_text_size(tokyoBox, textSize)
    tokyoMidline := showMidlinesInput ? line.new(x1 = bar_index, y1 = hl2, x2 = bar_index, y2 = hl2, color = tokyoColorInput, style = line.style_dashed) : na
else if showSessionsInput and tokyoActive
    tokyoHigh := math.max(tokyoHigh, high)
    tokyoLow := math.min(tokyoLow, low)
    box.set_top(tokyoBox, tokyoHigh)
    box.set_bottom(tokyoBox, tokyoLow)
    box.set_right(tokyoBox, bar_index)
    if not na(tokyoMidline)
        line.set_xy1(tokyoMidline, box.get_left(tokyoBox), (tokyoHigh + tokyoLow) / 2.0)
        line.set_xy2(tokyoMidline, bar_index, (tokyoHigh + tokyoLow) / 2.0)

// --- London range box ---
if showSessionsInput and londonStart
    londonHigh := high
    londonLow := low
    londonBox := box.new(left = bar_index, top = londonHigh, right = bar_index, bottom = londonLow, bgcolor = color.new(londonColorInput, 100 - sessionOpacityInput), border_color = londonColorInput, border_width = 1)
    box.set_text(londonBox, "London Session")
    box.set_text_color(londonBox, chart.fg_color)
    box.set_text_halign(londonBox, textHAlign)
    box.set_text_valign(londonBox, textVAlign)
    box.set_text_size(londonBox, textSize)
    londonMidline := showMidlinesInput ? line.new(x1 = bar_index, y1 = hl2, x2 = bar_index, y2 = hl2, color = londonColorInput, style = line.style_dashed) : na
else if showSessionsInput and londonActive
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)
    box.set_top(londonBox, londonHigh)
    box.set_bottom(londonBox, londonLow)
    box.set_right(londonBox, bar_index)
    if not na(londonMidline)
        line.set_xy1(londonMidline, box.get_left(londonBox), (londonHigh + londonLow) / 2.0)
        line.set_xy2(londonMidline, bar_index, (londonHigh + londonLow) / 2.0)

// --- New York range box ---
if showSessionsInput and newYorkStart
    newYorkHigh := high
    newYorkLow := low
    newYorkBox := box.new(left = bar_index, top = newYorkHigh, right = bar_index, bottom = newYorkLow, bgcolor = color.new(newYorkColorInput, 100 - sessionOpacityInput), border_color = newYorkColorInput, border_width = 1)
    box.set_text(newYorkBox, "New York Session")
    box.set_text_color(newYorkBox, chart.fg_color)
    box.set_text_halign(newYorkBox, textHAlign)
    box.set_text_valign(newYorkBox, textVAlign)
    box.set_text_size(newYorkBox, textSize)
    newYorkMidline := showMidlinesInput ? line.new(x1 = bar_index, y1 = hl2, x2 = bar_index, y2 = hl2, color = newYorkColorInput, style = line.style_dashed) : na
else if showSessionsInput and newYorkActive
    newYorkHigh := math.max(newYorkHigh, high)
    newYorkLow := math.min(newYorkLow, low)
    box.set_top(newYorkBox, newYorkHigh)
    box.set_bottom(newYorkBox, newYorkLow)
    box.set_right(newYorkBox, bar_index)
    if not na(newYorkMidline)
        line.set_xy1(newYorkMidline, box.get_left(newYorkBox), (newYorkHigh + newYorkLow)  / 2.0)
        line.set_xy2(newYorkMidline, bar_index, (newYorkHigh + newYorkLow) / 2.0)

// --- Asia kill-zone range box ---
if showKillZonesInput and asiaKillZoneStart
    asiaKillZoneHigh := high
    asiaKillZoneLow := low
    asiaKillZoneBox := box.new(left = bar_index, top = asiaKillZoneHigh, right = bar_index, bottom = asiaKillZoneLow, bgcolor = color.new(asiaKillZoneColorInput, 100 - killZoneOpacityInput), border_color = asiaKillZoneColorInput, border_width = 1)
    box.set_text(asiaKillZoneBox, "Asia Killzone")
    box.set_text_color(asiaKillZoneBox, chart.fg_color)
    box.set_text_halign(asiaKillZoneBox, textHAlign)
    box.set_text_valign(asiaKillZoneBox, textVAlign)
    box.set_text_size(asiaKillZoneBox, textSize)
    asiaKillZoneMidline := showMidlinesInput ? line.new(x1 = bar_index, y1 = hl2, x2 = bar_index, y2 = hl2, color = asiaKillZoneColorInput, style = line.style_dashed) : na
else if showKillZonesInput and asiaKillZoneActive
    asiaKillZoneHigh := math.max(asiaKillZoneHigh, high)
    asiaKillZoneLow := math.min(asiaKillZoneLow, low)
    box.set_top(asiaKillZoneBox, asiaKillZoneHigh)
    box.set_bottom(asiaKillZoneBox, asiaKillZoneLow)
    box.set_right(asiaKillZoneBox, bar_index)
    if not na(asiaKillZoneMidline)
        line.set_xy1(asiaKillZoneMidline, box.get_left(asiaKillZoneBox), (asiaKillZoneHigh + asiaKillZoneLow) / 2.0)
        line.set_xy2(asiaKillZoneMidline, bar_index, (asiaKillZoneHigh + asiaKillZoneLow) / 2.0)

// --- London kill-zone range box ---
if showKillZonesInput and londonKillZoneStart
    londonKillZoneHigh := high
    londonKillZoneLow := low
    londonKillZoneBox := box.new(left = bar_index, top = londonKillZoneHigh, right = bar_index, bottom = londonKillZoneLow, bgcolor = color.new(londonKillZoneColorInput, 100 - killZoneOpacityInput), border_color = londonKillZoneColorInput, border_width = 1)
    box.set_text(londonKillZoneBox, "London Killzone")
    box.set_text_color(londonKillZoneBox, chart.fg_color)
    box.set_text_halign(londonKillZoneBox, textHAlign)
    box.set_text_valign(londonKillZoneBox, textVAlign)
    box.set_text_size(londonKillZoneBox, textSize)
    londonKillZoneMidline := showMidlinesInput ? line.new(x1 = bar_index, y1 = hl2, x2 = bar_index, y2 = hl2, color = londonKillZoneColorInput, style = line.style_dashed) : na
else if showKillZonesInput and londonKillZoneActive
    londonKillZoneHigh := math.max(londonKillZoneHigh, high)
    londonKillZoneLow := math.min(londonKillZoneLow, low)
    box.set_top(londonKillZoneBox, londonKillZoneHigh)
    box.set_bottom(londonKillZoneBox, londonKillZoneLow)
    box.set_right(londonKillZoneBox, bar_index)
    if not na(londonKillZoneMidline)
        line.set_xy1(londonKillZoneMidline, box.get_left(londonKillZoneBox), (londonKillZoneHigh + londonKillZoneLow) / 2.0)
        line.set_xy2(londonKillZoneMidline, bar_index, (londonKillZoneHigh + londonKillZoneLow) / 2.0)

// --- New York kill-zone range box ---
if showKillZonesInput and newYorkKillZoneStart
    newYorkKillZoneHigh := high
    newYorkKillZoneLow := low
    newYorkKillZoneBox := box.new(left = bar_index, top = newYorkKillZoneHigh, right = bar_index, bottom = newYorkKillZoneLow, bgcolor = color.new(newYorkKillZoneColorInput, 100 - killZoneOpacityInput), border_color = newYorkKillZoneColorInput, border_width = 1)
    box.set_text(newYorkKillZoneBox, "New York Killzone")
    box.set_text_color(newYorkKillZoneBox, chart.fg_color)
    box.set_text_halign(newYorkKillZoneBox, textHAlign)
    box.set_text_valign(newYorkKillZoneBox, textVAlign)
    box.set_text_size(newYorkKillZoneBox, textSize)
    newYorkKillZoneMidline := showMidlinesInput ? line.new(x1 = bar_index, y1 = hl2, x2 = bar_index, y2 = hl2, color = newYorkKillZoneColorInput, style = line.style_dashed) : na
else if showKillZonesInput and newYorkKillZoneActive
    newYorkKillZoneHigh := math.max(newYorkKillZoneHigh, high)
    newYorkKillZoneLow := math.min(newYorkKillZoneLow, low)
    box.set_top(newYorkKillZoneBox, newYorkKillZoneHigh)
    box.set_bottom(newYorkKillZoneBox, newYorkKillZoneLow)
    box.set_right(newYorkKillZoneBox, bar_index)
    if not na(newYorkKillZoneMidline)
        line.set_xy1(newYorkKillZoneMidline, box.get_left(newYorkKillZoneBox), (newYorkKillZoneHigh + newYorkKillZoneLow) / 2.0)
        line.set_xy2(newYorkKillZoneMidline, bar_index, (newYorkKillZoneHigh + newYorkKillZoneLow) / 2.0)

// --- Optional start markers ---
plotshape(showMarkersInput and sydneyStart, title = "Sydney start", style = shape.labeldown, location = location.abovebar, color = sydneyColorInput, text = "SYD", textcolor = color.white, size = size.tiny)
plotshape(showMarkersInput and tokyoStart, title = "Tokyo start", style = shape.labeldown, location = location.abovebar, color = tokyoColorInput, text = "TOK", textcolor = color.white, size = size.tiny)
plotshape(showMarkersInput and londonStart, title = "London start", style = shape.labeldown, location = location.abovebar, color = londonColorInput, text = "LON", textcolor = color.white, size = size.tiny)
plotshape(showMarkersInput and newYorkStart, title = "New York start", style = shape.labeldown, location = location.abovebar, color = newYorkColorInput, text = "NY", textcolor = color.white, size = size.tiny)
plotshape(showMarkersInput and asiaKillZoneStart, title = "Asia kill zone start", style = shape.labelup, location = location.belowbar, color = asiaKillZoneColorInput, text = "KZ A", textcolor = color.white, size = size.tiny)
plotshape(showMarkersInput and londonKillZoneStart, title = "London kill zone start", style = shape.labelup, location = location.belowbar, color = londonKillZoneColorInput, text = "KZ L", textcolor = color.white, size = size.tiny)
plotshape(showMarkersInput and newYorkKillZoneStart, title = "New York kill zone start", style = shape.labelup, location = location.belowbar, color = newYorkKillZoneColorInput, text = "KZ NY", textcolor = color.white, size = size.tiny)

// --- Alerts ---
alertcondition(sydneyStart, "Sydney session started", "Sydney session started in IST.")
alertcondition(tokyoStart, "Tokyo session started", "Tokyo session started in IST.")
alertcondition(londonStart, "London session started", "London session started in IST.")
alertcondition(newYorkStart, "New York session started", "New York session started in IST.")
alertcondition(asiaKillZoneStart, "Asia kill zone started", "Asia kill zone started in IST.")
alertcondition(londonKillZoneStart, "London kill zone started", "London kill zone started in IST.")
alertcondition(newYorkKillZoneStart, "New York kill zone started", "New York kill zone started in IST.")
````
