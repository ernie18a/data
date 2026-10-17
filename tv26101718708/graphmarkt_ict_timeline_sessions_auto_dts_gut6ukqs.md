# Graphmarkt ICT Timeline & Sessions Auto DTS

- url: https://www.tradingview.com/script/GUT6UKqS/
- type: indicator
- pine_id: PUB;f2fea3c686044f4ca4d0889a3df79221
- version: 1.0

## Description

10.05.2026 tarihli Graphmarkt ICT & Price Action kanalımızda ICT oynatma listemizde saat 15:00'da yayınladığımız videoda bahsedilen birleştirilmiş ve son güncel haliyle sunulmuş indikatörümüze buradan ulaşabilirsiniz

## Source Code

````pine
//@version=6
indicator("Graphmarkt ICT Timeline + Sessions Auto DST", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =====================
// SETTINGS
// =====================
showAsia      = input.bool(true,  "Show Asia Range")
showLondon    = input.bool(true,  "Show London Killzone")
showOverlap   = input.bool(true,  "Show NY / London Overlap")
showSB        = input.bool(true,  "Show Silver Bullet Background")
showNYMarkers = input.bool(true,  "Show NY Open Relative Lines")
showEvents    = input.bool(true,  "Show Auction / FOMC Lines")

// =====================
// NY TIME LOGIC
// =====================
nyH = hour(time, "America/New_York")
nyM = minute(time, "America/New_York")
nyMinutes = nyH * 60 + nyM

inWindow(startHour, startMinute, endHour, endMinute) =>
    startTotal = startHour * 60 + startMinute
    endTotal   = endHour * 60 + endMinute
    startTotal < endTotal ? (nyMinutes >= startTotal and nyMinutes < endTotal) : (nyMinutes >= startTotal or nyMinutes < endTotal)

isExactNY(h, m) =>
    nyH == h and nyM == m

// =====================
// SESSION WINDOWS - NY TIME
// DST otomatik: America/New_York
// =====================
asiaActive    = showAsia    and inWindow(20, 0, 3, 0)
londonActive  = showLondon  and inWindow(3, 0, 6, 0)
overlapActive = showOverlap and inWindow(8, 0, 12, 0)

// Silver Bullet
lonSB = showSB and inWindow(3, 0, 4, 0)
amSB  = showSB and inWindow(10, 0, 11, 0)
pmSB  = showSB and inWindow(14, 0, 15, 0)

// =====================
// COLORS
// =====================
asiaColor       = color.new(color.gray, 84)
londonColor     = color.new(color.blue, 85)
overlapColor    = color.new(color.green, 85)

borderAsia      = color.new(color.gray, 25)
borderLondon    = color.new(color.blue, 5)
borderOverlap   = color.new(color.green, 5)

lonSBColor      = color.new(color.blue, 88)
amSBColor       = color.new(color.aqua, 88)
pmSBColor       = color.new(color.purple, 88)

// =====================
// BOX VARIABLES
// =====================
var box asiaBox = na
var float asiaHi = na
var float asiaLo = na
var int asiaLeft = na
var label asiaLabel = na

var box londonBox = na
var float londonHi = na
var float londonLo = na
var int londonLeft = na
var label londonLabel = na

var box overlapBox = na
var float overlapHi = na
var float overlapLo = na
var int overlapLeft = na
var label overlapLabel = na

// =====================
// ASIA RANGE BOX
// =====================
asiaStart = asiaActive and not asiaActive[1]
asiaEnd   = not asiaActive and asiaActive[1]

if asiaStart
    asiaHi := high
    asiaLo := low
    asiaLeft := bar_index
    asiaBox := box.new(
         left=bar_index,
         top=asiaHi,
         right=bar_index,
         bottom=asiaLo,
         bgcolor=asiaColor,
         border_color=borderAsia,
         border_width=1
     )

if asiaActive and not na(asiaBox)
    asiaHi := math.max(asiaHi, high)
    asiaLo := math.min(asiaLo, low)
    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, asiaHi)
    box.set_bottom(asiaBox, asiaLo)

if asiaEnd and not na(asiaBox)
    asiaLabel := label.new(
         asiaLeft,
         asiaHi,
         "ASIA RANGE",
         style=label.style_label_down,
         color=color.new(borderAsia, 10),
         textcolor=color.white,
         size=size.small
     )

// =====================
// LONDON KILLZONE BOX
// =====================
londonStart = londonActive and not londonActive[1]
londonEnd   = not londonActive and londonActive[1]

if londonStart
    londonHi := high
    londonLo := low
    londonLeft := bar_index
    londonBox := box.new(
         left=bar_index,
         top=londonHi,
         right=bar_index,
         bottom=londonLo,
         bgcolor=londonColor,
         border_color=borderLondon,
         border_width=1
     )

if londonActive and not na(londonBox)
    londonHi := math.max(londonHi, high)
    londonLo := math.min(londonLo, low)
    box.set_right(londonBox, bar_index)
    box.set_top(londonBox, londonHi)
    box.set_bottom(londonBox, londonLo)

if londonEnd and not na(londonBox)
    londonLabel := label.new(
         londonLeft,
         londonHi,
         "LONDON KZ",
         style=label.style_label_down,
         color=color.new(borderLondon, 10),
         textcolor=color.white,
         size=size.small
     )

// =====================
// NY / LONDON OVERLAP BOX
// =====================
overlapStart = overlapActive and not overlapActive[1]
overlapEnd   = not overlapActive and overlapActive[1]

if overlapStart
    overlapHi := high
    overlapLo := low
    overlapLeft := bar_index
    overlapBox := box.new(
         left=bar_index,
         top=overlapHi,
         right=bar_index,
         bottom=overlapLo,
         bgcolor=overlapColor,
         border_color=borderOverlap,
         border_width=1
     )

if overlapActive and not na(overlapBox)
    overlapHi := math.max(overlapHi, high)
    overlapLo := math.min(overlapLo, low)
    box.set_right(overlapBox, bar_index)
    box.set_top(overlapBox, overlapHi)
    box.set_bottom(overlapBox, overlapLo)

if overlapEnd and not na(overlapBox)
    overlapLabel := label.new(
         overlapLeft,
         overlapHi,
         "NY/LONDON OVERLAP",
         style=label.style_label_down,
         color=color.new(borderOverlap, 10),
         textcolor=color.white,
         size=size.small
     )

// =====================
// SILVER BULLET BACKGROUND
// =====================
bgcolor(lonSB ? lonSBColor : na, title="London Silver Bullet")
bgcolor(amSB  ? amSBColor  : na, title="NY AM Silver Bullet")
bgcolor(pmSB  ? pmSBColor  : na, title="NY PM Silver Bullet")

// =====================
// VERTICAL LINE FUNCTION
// =====================
drawVLine(cond, clr, txt) =>
    if cond
        line.new(
             x1=bar_index,
             y1=high,
             x2=bar_index,
             y2=low,
             extend=extend.both,
             color=clr,
             width=2,
             style=line.style_dotted
         )
        label.new(
             bar_index,
             high,
             txt,
             style=label.style_label_left,
             color=color.new(clr, 30),
             textcolor=color.white,
             size=size.small
         )

// =====================
// NY OPEN RELATIVE MARKERS
// NY OPEN = 09:30 NY
// =====================
drawVLine(showNYMarkers and isExactNY(8, 0),  color.teal, "NY -1.5")
drawVLine(showNYMarkers and isExactNY(9, 0),  color.teal, "NY -0.5")
drawVLine(showNYMarkers and isExactNY(9, 30), color.yellow, "NY OPEN")
drawVLine(showNYMarkers and isExactNY(10, 0), color.teal, "NY +0.5")

// =====================
// EVENT MARKERS
// =====================
drawVLine(showEvents and isExactNY(14, 0), color.purple, "AUCTION")
drawVLine(showEvents and isExactNY(15, 0), color.purple, "FOMC")
````
