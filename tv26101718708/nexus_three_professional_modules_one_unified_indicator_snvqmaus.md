# NEXUS  Three professional modules. One unified indicator.

- url: https://www.tradingview.com/script/sNvqMauS-NEXUS-Three-professional-modules-One-unified-indicator/
- type: indicator
- pine_id: PUB;5244538ebfe54ee5913edc9172ca189b
- version: 1.0

## Description

🌐 WHAT IS NEXUS?


NEXUS combines three independent professional-grade
modules into a single, clean indicator — eliminating
the need to stack multiple scripts on your chart.

- MODULE 1 — Market Sessions Visualizer
- MODULE 2 — Volume–Price Divergence Detector
- MODULE 3 — Key Levels & Structural Reference Engine


━━━━━━━━━━━━━━━━━━━━━
 MODULE 1 — MARKET SESSIONS
━━━━━━━━━━━━━━━━━━━━━

Visualize the four major Forex/Futures trading sessions
with precision and full customization.

★ Sessions covered:
  · Tokyo    (default: 00:00–09:00 UTC)
  · London   (default: 07:00–16:00 UTC)
  · New York (default: 13:00–22:00 UTC)
  · Sydney   (default: 21:00–06:00 UTC)

★ Display modes:
  · Boxes     — classic high/low range boxes
  · Zones     — colored background highlights
  · Timeline  — compact bar-level session markers
  · Candles   — colored candle bodies per session

★ Additional tools:
  · Session Open/Close line
  · Session 0.5 midpoint level
  · Merge overlapping sessions
  · Live pip / % change labels
  · Weekend exclusion toggle
  · Fully customizable colors, borders & label sizes
  · Lookback depth control (default: 150 days)
  · All session times entered in UTC — no timezone
    conflicts regardless of your chart setting

★ Alerts:
  Session open · New session high · New session low


━━━━━━━━━━━━━━━━━━━━━
 MODULE 2 — VOLUME–PRICE DIVERGENCE
━━━━━━━━━━━━━━━━━━━━━

Identifies moments when volume surges significantly
but price barely moves — a classic footprint of
institutional accumulation or distribution.

★ Two signal types:
  · 🔴 DIV (Divergence) — high volume + small price body
    → Strong sign of hidden positioning
  · 🟠 SHADOW — high volume + large wick / shadow candle
    → Rejection or absorption signal

★ How it works:
  · Compares current volume against a 20-bar SMA
  · Volume spike threshold: configurable (default 600%)
  · Price change measured via 3 selectable methods:
      — Body / Open
      — Body / Range
      — Range / Open
  · Shadow detection with adjustable body-to-wick ratio

★ Visual aids:
  · Color-coded volume histogram
    (Gray → Yellow → Orange → Red)
  · On-chart signal shapes with text labels
  · Live info table (top-left):
    current volume · volume % change · price % change
    body/range ratio · current signal status

★ Alerts:
  Volume spike · Shadow candle · Full divergence signal


━━━━━━━━━━━━━━━━━━━━━
 MODULE 3 — KEY LEVELS & STRUCTURAL REFERENCE
━━━━━━━━━━━━━━━━━━━━━

A comprehensive reference engine that plots all
critical price levels a professional trader monitors.

★ Session High/Low levels:
  · Asia Session   (18:00–03:00 ET, configurable)
  · London Session (03:00–08:00 ET, configurable)
  · New York Session (08:30–17:00 ET, configurable)
  → Lines auto-update in real time
  → Auto-detect and label when a level is broken

★ Market structure levels (ET — NYSE aligned):
  · Key time opens: 00:00 · 02:00 · 05:00 · 08:30
    09:30 · 10:00 · 14:00 · 15:00 · 16:00 · 17:00
  · 4H Open · Daily Open · Weekly Open · Monthly Open

★ Range midpoint levels:
  · Previous Day Mid Range (50%)
  · Market Open Mid Range (live, updates intraday)
  · Weekly Mid Range
  · Monthly Mid Range

★ Higher-timeframe levels:
  · Previous Day High / Low
  · Weekly High / Low
  · Monthly High / Low
  · All-Time High

★ Pivot calculations (previous day data):
  · Standard Pivot Points: PP · R1 · R2 · S1 · S2
  · Central Pivot Range (CPR): TC · PP · BC
    with CPR width % context label (Trending / Mixed / Range)

★ Smart features:
  · Auto-Simplify on HTF — automatically hides granular
    levels on higher timeframes to reduce visual noise
  · Smart label positioning that adapts to screen view
  · Level confluence detection — merges labels when
    two levels share the same price
  · Vertical day separator lines at 17:00 ET (last 14 days)
  · Days-of-week labels at session open
  · Extend All Lines toggle
  · Global color & text size override
  · Full per-level style control (color · style · width)
  · Timezone selector for all session calculations


━━━━━━━━━━━━━━━━━━━━━
 ⚙️ QUICK SETUP GUIDE
━━━━━━━━━━━━━━━━━━━━━

1. Add NEXUS to any intraday chart (1m to 4H recommended)

2. Sessions Module
   → All session times are in UTC by default
   → No need to change your chart timezone
   → Toggle sessions on/off individually
   → Choose your preferred display mode

3. Divergence Module
   → Start with default settings
   → Lower the Volume Threshold (%) on low-liquidity
     instruments if signals are too rare
   → Enable "Show Debug Info" for manual calibration

4. Key Levels Module
   → Set your timezone (default: America/New_York)
   → Toggle each level group independently
   → Enable "Auto-Simplify on Higher Timeframes" to keep
     the chart clean when zooming out
   → Use "Extend All Lines" for a forward-looking view


━━━━━━━━━━━━━━━━━━━━━
 📌 RECOMMENDED TIMEFRAMES
━━━━━━━━━━━━━━━━━━━━━

  All modules active   →  1m · 3m · 5m · 15m · 30m
  Sessions + Levels    →  1H · 2H · 4H
  Levels only          →  Daily

⚠️ Sessions module is intraday-only by design.
   It will not plot on Daily or higher timeframes.


━━━━━━━━━━━━━━━━━━━━━
 📊 COMPATIBLE INSTRUMENTS
━━━━━━━━━━━━━━━━━━━━━

  Futures  (ES, NQ, MES, MNQ, YM, CL, GC...)
  Forex    (all major, minor & exotic pairs)
  Crypto   (BTC, ETH and all altcoins with volume)
  Equities (US stocks & ETFs with intraday data)
  Indices  (SPX, NDX, DXY...)


━━━━━━━━━━━━━━━━━━━━━
 📋 RELEASE NOTES
━━━━━━━━━━━━━━━━━━━━━

v1.0 — Initial release
  · Full integration of all three modules
  · Smart label positioning engine
  · Timeframe-aware auto-simplification
  · Confluence level merging
  · Complete alert system


━━━━━━━━━━━━━━━━━━━━━
 ⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━

This indicator is for informational and educational
purposes only. It does not constitute financial advice.
Past signals do not guarantee future results.
Always manage risk appropriately.

## Source Code

````pine
//@version=6
//NEXUS  Market Sessions · Volume Divergence · Key Levels by Triggon
indicator(
     "NEXUS",
     overlay = true,
     max_boxes_count = 500,
     max_labels_count = 500,
     max_lines_count = 500
)

// =====================================================
// MODULE 1 — MARKET SESSIONS
// =====================================================
// Session 1 - user inputs
showTokyo      = input.bool(true, '', inline='Tokyo', group='Sessions')
stringTokyo    = input.string('Tokyo', '', inline='Tokyo', group='Sessions')
TokyoTimeX     = input.session(defval="0000-0900", title='     ', inline='Tokyo2', group='Sessions', tooltip = 'If you want to change the start/end time of the session, just make sure they are in UTC. There is no need to change the timezone of your Tradingview chart or to change the Timezone input below, because the sessions will be plotted correctly as long as the start/end time is set in UTC.')
TokyoCol       = input.color(color.rgb(255, 153, 0, 90), '' , inline='Tokyo', group='Sessions')
// Session 2 - user inputs
showLondon     = input.bool(true, '', inline='London', group='Sessions')
stringLondon   = input.string('London', '', inline='London', group='Sessions')
LondonTimeX    = input.session(defval="0700-1600", title='     ', inline='London2', group='Sessions', tooltip = 'If you want to change the start/end time of the session, just make sure they are in UTC. There is no need to change the timezone of your Tradingview chart or to change the Timezone input below, because the sessions will be plotted correctly as long as the start/end time is set in UTC.')
LondonCol      = input.color(color.rgb(76, 175, 79, 90), '' , inline='London', group='Sessions')
// Session 3 - user inputs
showNewYork    = input.bool(true, title='', inline='New York', group='Sessions')
stringNewYork  = input.string('New York', '', inline='New York', group='Sessions')
NewYorkTimeX   = input.session(defval="1300-2200", title='     ', inline='New York2', group='Sessions', tooltip = 'If you want to change the start/end time of the session, just make sure they are in UTC. There is no need to change the timezone of your Tradingview chart or to change the Timezone input below, because the sessions will be plotted correctly as long as the start/end time is set in UTC.')
NewYorkCol     = input.color(color.rgb(33, 149, 243, 90), '', inline='New York', group='Sessions')
// Session 4 - user inputs
showSydney     = input.bool(false, title='', inline='Sydney', group='Sessions')
stringSydney   = input.string('Sydney', '', inline='Sydney', group='Sessions')
SydneyTimeX    = input.session(defval="2100-0600", title='     ', inline='Sydney2', group='Sessions', tooltip = 'If you want to change the start/end time of the session, just make sure they are in UTC. There is no need to change the timezone of your Tradingview chart or to change the Timezone input below, because the sessions will be plotted correctly as long as the start/end time is set in UTC.')
SydneyCol      = input.color(color.rgb(164, 97, 187, 90), '', inline='Sydney', group='Sessions')
// Additional tools and settings - user inputs
pipChange      = input.bool(false, 'Change (Pips) ', inline='0', group = 'Additional Tools and Settings')
percentChange  = input.bool(false, 'Change (%)', inline='0', group = 'Additional Tools and Settings')
merge          = input.bool(false, 'Merge Overlaps', inline='2', group = 'Additional Tools and Settings')
hideWeekends   = input.bool(true, 'Hide Weekends', inline='2', group = 'Additional Tools and Settings')
sessionOC      = input.bool(true, 'Open/Close Line', inline='3', group = 'Additional Tools and Settings')
halfline       = input.bool(false, 'Session 0.5 Level', inline='3', group = 'Additional Tools and Settings')
colorcandles   = input.bool(false, 'Color Candles  ', inline='4', group = 'Additional Tools and Settings')
showScreener   = input.bool(false, 'Screener (Soon)', inline='4', group = 'Additional Tools and Settings')
displayType    = input.string('Boxes', 'Display Type', options = ['Boxes', 'Zones','Timeline', 'Candles'], group='Additional Tools and Settings', tooltip='Choose whether the scripts should plot session in the for of boxes or colored background zones.')
daysBack       = input.float(150, 'Lookback (Days)', group='Additional Tools and Settings', tooltip= 'This inputs defines the lookback period for plotting sessions. Eg. If it is set to 1, only the sessions of the past day will appear')
changeType     = input.string('Session High/Low','Change (%/Pips) Source', options = ['Session High/Low', 'Session Open/Close'], group='Additional Tools and Settings', tooltip='Choose whether the Change (%) and Change (Pips) should measure the distance between Session High and Session Low or the distance between Session Open and Session Close.')
SessionZone    = input.string("UTC", title="Input Timezone", group='Additional Tools and Settings', tooltip = 'This input is defining the timezone for the session times selected above. It has nothing to do with the timezone of your chart, because the sessions will be plotted correctly even if your chart is not set to UTC.')
// Appearance - user inputs
borderWidth    = input.int(1, 'Box Border', inline='border', group='Appearance')
borderStyle    = input.string('Dashed', '', ['Solid', 'Dashed', 'Dotted']  , inline='border', group='Appearance', tooltip='Select the width and style of session box borders')
levelsStyle    = input.string('Dashed', 'Line Style', ['Solid', 'Dashed', 'Dotted'], group='Appearance', tooltip='Select the style of 0.5 and Open/Close lines.')
labelSize      = input.string('Normal', 'Label Size', options = ['Auto', 'Tiny', 'Small', 'Normal'], group='Appearance', tooltip='Select the size of text labels.')
showLabels1     = input.bool(true, 'Session Labels ', inline='00', group = 'Appearance')
colorBoxes     = input.bool(true, 'Box Background', inline='00', group = 'Appearance')

// Excluding or Including Weekends 
var TokyoTime   = hideWeekends ? TokyoTimeX+":123456" : TokyoTimeX+":1234567"
var LondonTime  = hideWeekends ? LondonTimeX+":123456" : LondonTimeX+":1234567"
var NewYorkTime = hideWeekends ? NewYorkTimeX+":123456" : NewYorkTimeX+":1234567"
var SydneyTime  = hideWeekends ? SydneyTimeX+":123456" : SydneyTimeX+":1234567"

// Defining Line Style and Label Size Variables
lineStyle(x) =>
    switch x
        'Solid'  => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
labelStyle(x) =>
    switch x
        'Auto'   => size.auto
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal

// Calculating inRange, used for lookback
MSPD        = 24 * 60 * 60 * 1000
lastBarDate = timestamp(year(timenow), month(timenow), dayofmonth(timenow), hour(timenow), minute(timenow), second(timenow))
thisBarDate = timestamp(year, month, dayofmonth, hour, minute, second)
daysLeft    = math.abs(math.floor((lastBarDate - thisBarDate) / MSPD))
inRange     = daysLeft < daysBack

// Session Time
InTokyo(TokyoTime, TokyoTimeZone=syminfo.timezone)       =>
    not na(time(timeframe.period, TokyoTime, SessionZone))
InLondon(LondonTime, LondonTimeZone=syminfo.timezone)    =>
    not na(time(timeframe.period, LondonTime, SessionZone))
InNewYork(NewYorkTime, NewYorkTimeZone=syminfo.timezone) =>
    not na(time(timeframe.period, NewYorkTime, SessionZone))
InSydney(SydneyTime, SydneyTimeZone=syminfo.timezone)    =>
    not na(time(timeframe.period, SydneyTime, SessionZone))

// Creating variables Session High, Low, Open and Session Boxes, Lines and Texts
var TokyoHighPrice     = 0.0, var TokyoLowPrice      = 0.0, var TokyoOpenPrice     = 0.0, var box TokyoBox       = na, var line TokyoLine     = na, var label TokyoLabel   = na, var line TokyoOC       = na, var string TokyoText   = str.tostring(stringTokyo)
var LondonHighPrice    = 0.0, var LondonLowPrice     = 0.0, var LondonOpenPrice    = 0.0, var box LondonBox      = na, var line LondonLine    = na, var label LondonLabel  = na, var line LondonOC      = na, var string LondonText  = str.tostring(stringLondon)
var NewYorkHighPrice   = 0.0, var NewYorkLowPrice    = 0.0, var NewYorkOpenPrice   = 0.0, var box NewYorkBox     = na, var line NewYorkLine   = na, var label NewYorkLabel = na, var line NewYorkOC     = na, var string NewYorkText = str.tostring(stringNewYork)
var SydneyHighPrice    = 0.0, var SydneyLowPrice     = 0.0, var SydneyOpenPrice    = 0.0, var box SydneyBox      = na, var line SydneyLine    = na, var label SydneyLabel  = na, var line SydneyOC      = na, var string SydneyText  = str.tostring(stringSydney)

// Checking if session is active/has started
inTokyo        = InTokyo(TokyoTime, SessionZone)     and timeframe.isintraday
TokyoStart     = inTokyo   and not inTokyo[1]
inLondon       = InLondon(LondonTime, SessionZone)   and timeframe.isintraday
LondonStart    = inLondon  and not inLondon[1]
inNewYork      = InNewYork(NewYorkTime, SessionZone) and timeframe.isintraday
NewYorkStart   = inNewYork and not inNewYork[1]
inSydney       = InSydney(SydneyTime, SessionZone)   and timeframe.isintraday
SydneyStart    = inSydney  and not inSydney[1]

// Settings high, low, open at the beggining of the session
if TokyoStart
    TokyoHighPrice   := high
    TokyoLowPrice    := low
    TokyoOpenPrice   := open
if LondonStart
    LondonHighPrice  := high
    LondonLowPrice   := low
    LondonOpenPrice  := open
if NewYorkStart
    NewYorkHighPrice := high
    NewYorkLowPrice  := low
    NewYorkOpenPrice := open
if SydneyStart
    SydneyHighPrice  := high
    SydneyLowPrice   := low
    SydneyOpenPrice  := open

// Track session's max high and max low during the session
else if inTokyo
    TokyoHighPrice   := math.max(TokyoHighPrice, high)
    TokyoLowPrice    := math.min(TokyoLowPrice, low)
else if inLondon
    LondonHighPrice  := math.max(LondonHighPrice, high)
    LondonLowPrice   := math.min(LondonLowPrice, low)
else if inNewYork
    NewYorkHighPrice := math.max(NewYorkHighPrice, high)
    NewYorkLowPrice  := math.min(NewYorkLowPrice, low)
else if inSydney
    SydneyHighPrice  := math.max(SydneyHighPrice, high)
    SydneyLowPrice   := math.min(SydneyLowPrice, low)

// Plotting session boxes at the beginning of each session
if TokyoStart and showTokyo and inRange
    TokyoBox     := displayType=='Boxes' ? box.new(left=bar_index, top=na, right=na, bottom=na, border_width=borderWidth, bgcolor = colorBoxes ? TokyoCol : na, border_style = lineStyle(borderStyle), border_color=color.new(TokyoCol, 40)) : na
    TokyoLine    := halfline   ? line.new(x1=bar_index, y1=na, x2=na, y2=na, style=lineStyle(levelsStyle), color = color.new(TokyoCol, 40)) : na
    TokyoLabel   := showLabels1 ? label.new(x=na, y=na, text=TokyoText, textcolor=color.new(TokyoCol, 40), color=color.rgb(0,0,0,100), size=labelStyle(labelSize)) : na
    TokyoOC      := sessionOC  ? line.new(x1=bar_index, y1=TokyoOpenPrice, x2=na, y2=na, style=lineStyle(levelsStyle), color = color.new(TokyoCol, 40)) : na
if LondonStart and showLondon and inRange
    LondonBox    := displayType=='Boxes' ? box.new(left=bar_index, top=na, right=na, bottom=na, border_width=borderWidth, bgcolor = colorBoxes ? LondonCol : na, border_style = lineStyle(borderStyle), border_color=color.new(LondonCol, 40)) : na
    LondonLine   := halfline   ? line.new(x1=bar_index, y1=na, x2=na, y2=na, style=lineStyle(levelsStyle), color = color.new(LondonCol, 40)) : na
    LondonLabel  := showLabels1 ? label.new(x=na, y=na, text=LondonText, textcolor=color.new(LondonCol, 40), color=color.rgb(0,0,0,100), size=labelStyle(labelSize)) : na
    LondonOC     := sessionOC  ? line.new(x1=bar_index, y1=LondonOpenPrice, x2=na, y2=na, style=lineStyle(levelsStyle), color = color.new(LondonCol, 40)) : na
if NewYorkStart and showNewYork and inRange
    NewYorkBox   := displayType=='Boxes' ? box.new(left=bar_index, top=na, right=na, bottom=na, border_width=borderWidth, bgcolor = colorBoxes ? NewYorkCol : na, border_style = lineStyle(borderStyle), border_color=color.new(NewYorkCol, 40)) : na
    NewYorkLine  := halfline   ? line.new(x1=bar_index, y1=na, x2=na, y2=na, style=lineStyle(levelsStyle), color = color.new(NewYorkCol, 40)) : na
    NewYorkLabel := showLabels1 ? label.new(x=na, y=na, text=NewYorkText, textcolor=color.new(NewYorkCol, 40), color=color.rgb(0,0,0,100), size=labelStyle(labelSize)) : na
    NewYorkOC    := sessionOC  ? line.new(x1=bar_index, y1=NewYorkOpenPrice, x2=na, y2=na, style=lineStyle(levelsStyle), color = color.new(NewYorkCol, 40)) : na
if SydneyStart and showSydney and inRange
    SydneyBox    := displayType=='Boxes' ? box.new(left=bar_index, top=na, right=na, bottom=na, border_width=borderWidth, bgcolor = colorBoxes ? SydneyCol : na, border_style = lineStyle(borderStyle), border_color=color.new(SydneyCol, 40)) : na
    SydneyLine   := halfline   ? line.new(x1=bar_index, y1=na, x2=na, y2=na, style=lineStyle(levelsStyle), color = color.new(SydneyCol, 40)) : na
    SydneyLabel  := showLabels1 ? label.new(x=na, y=na, text=SydneyText, textcolor=color.new(SydneyCol, 40), color=color.rgb(0,0,0,100), size=labelStyle(labelSize)) : na
    SydneyOC     := sessionOC  ? line.new(x1=bar_index, y1=SydneyOpenPrice, x2=na, y2=na, style=lineStyle(levelsStyle), color = color.new(SydneyCol, 40)) : na

// Creating variables for alternative Sessions Box top and bottom (used for merging sessions)
var float TokyoHighM   = 0, var float TokyoLowM    = 0, var float LondonHighM  = 0, var float LondonLowM   = 0, var float NewYorkHighM = 0, var float NewYorkLowM  = 0, var float SydneyHighM  = 0, var float SydneyLowM   = 0

// Updating session boxes during sessions
if inTokyo and inRange
    TokyoHighPrice   := math.max(TokyoHighPrice, high)
    TokyoLowPrice    := math.min(TokyoLowPrice, low)
    box.set_top(TokyoBox, TokyoHighPrice)
    box.set_bottom(TokyoBox, TokyoLowPrice)
    box.set_right(TokyoBox, bar_index + 1)
    label.set_x(TokyoLabel, (box.get_left(TokyoBox)+box.get_right(TokyoBox))/2)
    label.set_y(TokyoLabel, TokyoHighPrice)
    if sessionOC
        line.set_x2(TokyoOC, bar_index)
        line.set_y2(TokyoOC, close)
    if halfline
        line.set_y1(TokyoLine, (TokyoHighPrice+TokyoLowPrice)/2)
        line.set_y2(TokyoLine, (TokyoHighPrice+TokyoLowPrice)/2)
        line.set_x2(TokyoLine, bar_index+1)
    if merge and not inLondon and showLondon
        TokyoHighM := TokyoHighPrice
        TokyoLowM  := TokyoLowPrice
    if merge and inLondon and showLondon
        box.set_top(TokyoBox, TokyoHighM)
        box.set_bottom(TokyoBox, TokyoLowM)
        label.set_y(TokyoLabel, TokyoHighM)
        box.set_right(TokyoBox, (box.get_left(LondonBox)))
        line.set_x2(TokyoLine, (box.get_left(LondonBox)))
        label.set_x(TokyoLabel, (box.get_left(TokyoBox)+box.get_right(TokyoBox))/2)
        line.set_x2(TokyoOC, (box.get_left(LondonBox)))
        line.set_y2(TokyoOC, LondonOpenPrice)
        line.set_y1(TokyoLine, (TokyoHighM+TokyoLowM)/2)
        line.set_y2(TokyoLine, (TokyoHighM+TokyoLowM)/2)
    var float pips = 0
    var float chg = 0
    pips := changeType=='Session High/Low' ? ((TokyoHighPrice - TokyoLowPrice) / syminfo.mintick / 10) : ((close - TokyoOpenPrice) / syminfo.mintick / 10)
    chg  := changeType=='Session Open/Close' ? (100 * (close - TokyoOpenPrice) / TokyoOpenPrice) : ((TokyoHighPrice - TokyoLowPrice) / TokyoLowPrice * 100)
    if percentChange and not pipChange
        label.set_text(TokyoLabel, str.tostring(TokyoText) + '  (' + str.tostring(chg, format.percent) + ')')
    if pipChange and not percentChange
        label.set_text(TokyoLabel, str.tostring(TokyoText) + '  (' + str.tostring(pips) + ')')
    if percentChange and pipChange
        label.set_text(TokyoLabel, str.tostring(TokyoText) + '  ('+ str.tostring(chg, format.percent)+ ' • ' + str.tostring(pips) + ')')
if inLondon and inRange
    LondonHighPrice  := math.max(LondonHighPrice, high)
    LondonLowPrice   := math.min(LondonLowPrice, low)
    box.set_top(LondonBox, LondonHighPrice)
    box.set_bottom(LondonBox, LondonLowPrice)
    box.set_right(LondonBox, bar_index+1)
    label.set_x(LondonLabel, (box.get_left(LondonBox)+box.get_right(LondonBox))/2)
    label.set_y(LondonLabel, LondonHighPrice)
    if sessionOC
        line.set_x2(LondonOC, bar_index)
        line.set_y2(LondonOC, close)
    if halfline
        line.set_y1(LondonLine, (LondonHighPrice+LondonLowPrice)/2)
        line.set_y2(LondonLine, (LondonHighPrice+LondonLowPrice)/2)
        line.set_x2(LondonLine, bar_index+1)
    if merge and not inNewYork and showNewYork
        LondonHighM := LondonHighPrice
        LondonLowM  := LondonLowPrice
    if merge and inNewYork and showNewYork
        box.set_top(LondonBox, LondonHighM)
        box.set_bottom(LondonBox, LondonLowM)
        label.set_y(LondonLabel, LondonHighM)
        box.set_right(LondonBox, (box.get_left(NewYorkBox)))
        line.set_x2(LondonLine, (box.get_left(NewYorkBox)))
        label.set_x(LondonLabel, (box.get_left(LondonBox)+box.get_right(LondonBox))/2)
        line.set_x2(LondonOC, (box.get_left(NewYorkBox)))
        line.set_y2(LondonOC, NewYorkOpenPrice)
        line.set_y1(LondonLine, (LondonHighM+LondonLowM)/2)
        line.set_y2(LondonLine, (LondonHighM+LondonLowM)/2)
    var float pips = 0
    var float chg = 0
    pips := changeType=='Session High/Low' ? ((LondonHighPrice - LondonLowPrice) / syminfo.mintick / 10) : ((close - LondonOpenPrice) / syminfo.mintick / 10)
    chg  := changeType=='Session Open/Close' ? (100 * (close - LondonOpenPrice) / LondonOpenPrice) : ((LondonHighPrice - LondonLowPrice) / LondonLowPrice * 100)
    if percentChange and not pipChange
        label.set_text(LondonLabel, str.tostring(LondonText) + '  (' + str.tostring(chg, format.percent) + ')')
    if pipChange and not percentChange
        label.set_text(LondonLabel, str.tostring(LondonText) + '  (' + str.tostring(pips) + ')')
    if percentChange and pipChange
        label.set_text(LondonLabel, str.tostring(LondonText) + '  ('+ str.tostring(chg, format.percent)+ ' • ' + str.tostring(pips) + ')')
if inNewYork and inRange
    NewYorkHighPrice  := math.max(NewYorkHighPrice, high)
    NewYorkLowPrice   := math.min(NewYorkLowPrice, low)
    box.set_top(NewYorkBox, NewYorkHighPrice)
    box.set_bottom(NewYorkBox, NewYorkLowPrice)
    box.set_right(NewYorkBox, bar_index + 1)
    label.set_x(NewYorkLabel, (box.get_left(NewYorkBox)+box.get_right(NewYorkBox))/2)
    label.set_y(NewYorkLabel, NewYorkHighPrice)
    if sessionOC
        line.set_x2(NewYorkOC, bar_index)
        line.set_y2(NewYorkOC, close)
    if halfline
        line.set_y1(NewYorkLine, (NewYorkHighPrice+NewYorkLowPrice)/2)
        line.set_y2(NewYorkLine, (NewYorkHighPrice+NewYorkLowPrice)/2)
        line.set_x2(NewYorkLine, bar_index+1)
    if merge and not inSydney and showSydney
        NewYorkHighM := NewYorkHighPrice
        NewYorkLowM  := NewYorkLowPrice
    if merge and inSydney and showSydney
        box.set_top(NewYorkBox, NewYorkHighM)
        box.set_bottom(NewYorkBox, NewYorkLowM)
        label.set_y(NewYorkLabel, NewYorkHighM)
        box.set_right(NewYorkBox, (box.get_left(SydneyBox)))
        line.set_x2(NewYorkLine, (box.get_left(SydneyBox)))
        label.set_x(NewYorkLabel, (box.get_left(NewYorkBox)+box.get_right(NewYorkBox))/2)
        line.set_x2(NewYorkOC, (box.get_left(SydneyBox)))
        line.set_y2(NewYorkOC, SydneyOpenPrice)
        line.set_y1(NewYorkLine, (NewYorkHighM+NewYorkLowM)/2)
        line.set_y2(NewYorkLine, (NewYorkHighM+NewYorkLowM)/2)
    var float pips = 0
    var float chg = 0
    pips := changeType=='Session High/Low' ? ((NewYorkHighPrice - NewYorkLowPrice) / syminfo.mintick / 10) : ((close - NewYorkOpenPrice) / syminfo.mintick / 10)
    chg  := changeType=='Session Open/Close' ? (100 * (close - NewYorkOpenPrice) / NewYorkOpenPrice) : ((NewYorkHighPrice - NewYorkLowPrice) / NewYorkLowPrice * 100)
    if percentChange and not pipChange
        label.set_text(NewYorkLabel, str.tostring(NewYorkText) + '  (' + str.tostring(chg, format.percent) + ')')
    if pipChange and not percentChange
        label.set_text(NewYorkLabel, str.tostring(NewYorkText) + '  (' + str.tostring(pips) + ')')
    if percentChange and pipChange
        label.set_text(NewYorkLabel, str.tostring(NewYorkText) + '  ('+ str.tostring(chg, format.percent)+ ' • ' + str.tostring(pips) + ')')
if inSydney and inRange
    SydneyHighPrice  := math.max(SydneyHighPrice, high)
    SydneyLowPrice   := math.min(SydneyLowPrice, low)
    box.set_top(SydneyBox, SydneyHighPrice)
    box.set_bottom(SydneyBox, SydneyLowPrice)
    box.set_right(SydneyBox, bar_index + 1)
    label.set_x(SydneyLabel, (box.get_left(SydneyBox)+box.get_right(SydneyBox))/2)
    label.set_y(SydneyLabel, SydneyHighPrice)
    if sessionOC
        line.set_x2(SydneyOC, bar_index)
        line.set_y2(SydneyOC, close)
    if halfline
        line.set_y1(SydneyLine, (SydneyHighPrice+SydneyLowPrice)/2)
        line.set_y2(SydneyLine, (SydneyHighPrice+SydneyLowPrice)/2)
        line.set_x2(SydneyLine, bar_index+1)
    if merge and not inTokyo and showTokyo
        SydneyHighM := SydneyHighPrice
        SydneyLowM  := SydneyLowPrice
    if merge and inTokyo and showTokyo
        box.set_top(SydneyBox, SydneyHighM)
        box.set_bottom(SydneyBox, SydneyLowM)
        label.set_y(SydneyLabel, SydneyHighM)
        box.set_right(SydneyBox, (box.get_left(TokyoBox)))
        line.set_x2(SydneyLine, (box.get_left(TokyoBox)))
        label.set_x(SydneyLabel, (box.get_left(SydneyBox)+box.get_right(SydneyBox))/2)
        line.set_x2(SydneyOC, (box.get_left(TokyoBox)))
        line.set_y2(SydneyOC, TokyoOpenPrice)
        line.set_y1(SydneyLine, (SydneyHighM+SydneyLowM)/2)
        line.set_y2(SydneyLine, (SydneyHighM+SydneyLowM)/2)
    var float pips = 0
    var float chg = 0
    pips := changeType=='Session High/Low' ? ((SydneyHighPrice - SydneyLowPrice) / syminfo.mintick / 10) : ((close - SydneyOpenPrice) / syminfo.mintick / 10)
    chg  := changeType=='Session Open/Close' ? (100 * (close - SydneyOpenPrice) / SydneyOpenPrice) : ((SydneyHighPrice - SydneyLowPrice) / SydneyLowPrice * 100)
    if percentChange and not pipChange
        label.set_text(SydneyLabel, str.tostring(SydneyText) + '  (' + str.tostring(chg, format.percent) + ')')
    if pipChange and not percentChange
        label.set_text(SydneyLabel, str.tostring(SydneyText) + '  (' + str.tostring(pips) + ')')
    if percentChange and pipChange
        label.set_text(SydneyLabel, str.tostring(SydneyText) + '  ('+ str.tostring(chg, format.percent)+ ' • ' + str.tostring(pips) + ')')

// Coloring candles
TKLO = showLondon  ? (not inLondon)  : true
LONY = showNewYork ? (not inNewYork) : true
NYSY = showSydney  ? (not inSydney)  : true
SYTK = showTokyo   ? (not inTokyo)   : true
barcolor((colorcandles or displayType=='Candles') and not merge and  showTokyo   and inTokyo   and inRange          ? color.new(TokyoCol, 40) : na, editable = false)
barcolor((colorcandles or displayType=='Candles') and not merge and  showLondon  and inLondon  and inRange          ? color.new(LondonCol, 40) : na, editable = false)
barcolor((colorcandles or displayType=='Candles') and not merge and  showNewYork and inNewYork and inRange          ? color.new(NewYorkCol, 40) : na, editable = false)
barcolor((colorcandles or displayType=='Candles') and not merge and  showSydney  and inNewYork and inRange          ? color.new(SydneyCol, 40) : na, editable = false)
barcolor((colorcandles or displayType=='Candles') and merge     and  showTokyo   and inTokyo   and TKLO and inRange ? color.new(TokyoCol, 40) : na, editable = false)
barcolor((colorcandles or displayType=='Candles') and merge     and  showLondon  and inLondon  and LONY and inRange ? color.new(LondonCol, 40) : na, editable = false)
barcolor((colorcandles or displayType=='Candles') and merge     and  showNewYork and inNewYork and NYSY and inRange ? color.new(NewYorkCol, 40) : na, editable = false)
barcolor((colorcandles or displayType=='Candles') and merge     and  showSydney  and inSydney  and SYTK and inRange ? color.new(SydneyCol, 40) : na, editable = false)

// Coloring background if displayType=='Zones'
TokyoT              = time(timeframe.period, TokyoTime)
LondonT             = time(timeframe.period, LondonTime)
NewYorkT            = time(timeframe.period, NewYorkTime)
SydneyT             = time(timeframe.period, SydneyTime)
bgcolor(displayType == 'Zones' and not merge and showTokyo   and inRange and  time == TokyoT   ? TokyoCol   : na, editable = false)
bgcolor(displayType == 'Zones' and not merge and showLondon  and inRange and  time == LondonT  ? LondonCol  : na, editable = false)
bgcolor(displayType == 'Zones' and not merge and showNewYork and inRange and  time == NewYorkT ? NewYorkCol : na, editable = false)
bgcolor(displayType == 'Zones' and not merge and showSydney  and inRange and  time == SydneyT  ? SydneyCol  : na, editable = false)
bgcolor(displayType == 'Zones' and merge and not inLondon  and showTokyo   and inRange and  time == TokyoT   ? TokyoCol   : na, editable = false)
bgcolor(displayType == 'Zones' and merge and not inNewYork and showLondon  and inRange and  time == LondonT  ? LondonCol  : na, editable = false)
bgcolor(displayType == 'Zones' and merge and not inSydney  and showNewYork and inRange and  time == NewYorkT ? NewYorkCol : na, editable = false)
bgcolor(displayType == 'Zones' and merge and not inTokyo   and showSydney  and inRange and  time == SydneyT  ? SydneyCol  : na, editable = false)

// Plotting sessions in Timeline form
plotshape(displayType=='Timeline' and (merge and showLondon  ? (showTokyo   and inTokyo   and not inLondon)  : showTokyo   and inTokyo),   style=shape.square, color=TokyoCol,   location = location.bottom, size=size.auto)
plotshape(displayType=='Timeline' and (merge and showNewYork ? (showLondon  and inLondon  and not inNewYork) : showLondon  and inLondon),  style=shape.square, color=LondonCol,  location = location.bottom, size=size.auto)
plotshape(displayType=='Timeline' and (merge and showSydney  ? (showNewYork and inNewYork and not inSydney)  : showNewYork and inNewYork), style=shape.square, color=NewYorkCol, location = location.bottom, size=size.auto)
plotshape(displayType=='Timeline' and (merge and showTokyo   ? (showSydney  and inSydney  and not inTokyo)   : showSydney  and inSydney),  style=shape.square, color=SydneyCol,  location = location.bottom, size=size.auto)

// Creating alerts
alertcondition(inTokyo   and not inTokyo[1], 'Tokyo Open', 'The Tokyo Session has started')
alertcondition(inLondon  and not inLondon[1], 'London Open', 'The London Session has started')
alertcondition(inNewYork and not inNewYork[1], 'New York Open', 'The New York Session has started')
alertcondition(inSydney  and not inSydney[1], 'Sydney Open', 'The Sydney Session has started')
alertcondition(high > TokyoHighPrice[0]    and inTokyo, 'Tokyo Session - New High', 'New High in Tokyo Session')
alertcondition(high > LondonHighPrice[0]   and inLondon, 'London Session - New High', 'New High in London Session')
alertcondition(high > NewYorkHighPrice[0]  and inNewYork, 'New York Session - New High', 'New High in New York Session')
alertcondition(high > SydneyHighPrice[0]   and inSydney, 'Sydney Session - New High', 'New High in Sydney Session')
alertcondition(low  > TokyoLowPrice[0]     and inTokyo, 'Tokyo Session - New Low', 'New Low in Tokyo Session')
alertcondition(low  > LondonLowPrice[0]    and inLondon, 'London Session - New Low', 'New Low in London Session')
alertcondition(low  > NewYorkLowPrice[0]   and inNewYork, 'New York Session - New Low', 'New Low In New York Session')
alertcondition(low  > SydneyLowPrice[0]    and inSydney, 'Sydney Session - New Low', 'New Low In Sydney Session')










// =====================================================
// MODULE 2 — VOLUME-PRICE DIVERGENCE
// =====================================================
// Volume Settings
volumeThreshold = input.float(600, "Minimum Volume Increase (%)", minval=0, step=10, group="Volume Settings")

// Price Settings
priceThreshold = input.float(0.3, "Maximum Price Change for Divergence (%)", minval=0, step=0.5, group="Price Settings")
priceCalcMethod = input.string("Body/Open", "Price Calculation Method", 
     options=["Body/Open", "Body/Range", "Range/Open"], group="Price Settings")

// Shadow Settings
enableShadowDetection = input.bool(true, "Enable Shadow Candle Detection", group="Shadow Settings")
shadowRatio = input.float(3, "Minimum Shadow to Body Ratio", minval=1, step=0.5, group="Shadow Settings")

// Display Settings
showLabels2 = input.bool(true, "Show Labels", group="Display")
showVolumeBar = input.bool(true, "Show Volume Bar Colors", group="Display")
showDebugInfo = input.bool(false, "Show Debug Info", group="Display")

// ==========================
// Volume Calculations
// ==========================

// Average volume over 20 periods
avgVolume = ta.sma(volume, 20)

// Percentage change in volume relative to average
volumeChange = ((volume - avgVolume) / avgVolume) * 100

// Does volume show significant increase?
largeVolumeIncrease = volumeChange >= volumeThreshold

// ==========================
// Price Calculations
// ==========================

// Calculate body and shadows
candleBody = math.abs(close - open)
candleRange = high - low
upperShadow = high - math.max(open, close)
lowerShadow = math.min(open, close) - low
totalShadow = upperShadow + lowerShadow

// Multiple price change calculation methods
priceChangePercent = switch priceCalcMethod
    "Body/Open" => (candleBody / open) * 100
    "Body/Range" => candleRange > 0 ? (candleBody / candleRange) * 100 : 0
    "Range/Open" => (candleRange / open) * 100
    => (candleBody / open) * 100

// Is price change below threshold?
smallPriceChange = priceChangePercent < priceThreshold

// Detect candle with large shadow and small body
hasBigShadow = enableShadowDetection and candleRange > 0 and (totalShadow >= candleBody * shadowRatio)

// ==========================
// Main Signals
// ==========================

// Main signal: High volume + Low price change (excluding shadow candles)
mainSignal = largeVolumeIncrease and smallPriceChange and not hasBigShadow

// Shadow signal: High volume + Large shadow
shadowSignal = largeVolumeIncrease and hasBigShadow

// ==========================
// Coloring and Display
// ==========================

// Volume bar color
volumeColor = showVolumeBar ? 
     (mainSignal ? color.new(color.red, 0) : 
     shadowSignal ? color.new(color.orange, 0) : 
     largeVolumeIncrease ? color.new(color.yellow, 30) : 
     color.new(color.gray, 70)) : na

plot(showVolumeBar ? volume : na, "Volume", color=volumeColor, style=plot.style_histogram)

// Display signals on chart
plotshape(
     mainSignal and showLabels2, 
     "Main Signal", 
     shape.cross, 
     location.belowbar, 
     color.new(color.red, 0), 
     text="DIV", 
     textcolor=color.white,
     size=size.small
)

plotshape(
     shadowSignal and showLabels2, 
     "Shadow Signal", 
     shape.diamond, 
     location.abovebar, 
     color.new(color.orange, 0), 
     text="SHADOW", 
     textcolor=color.white,
     size=size.small
)

// Debug labels
if showDebugInfo and (mainSignal or shadowSignal or largeVolumeIncrease)
    debugText = "Vol: " + str.tostring(volumeChange, "#.#") + "%\n" +
                 "Price: " + str.tostring(priceChangePercent, "#.##") + "%\n" +
                 "Body: " + str.tostring(candleBody, "#.####") + "\n" +
                 "Range: " + str.tostring(candleRange, "#.####")
    
    label.new(bar_index, high, debugText, 
         style=label.style_label_down, 
         color=color.new(color.blue, 70), 
         textcolor=color.white, 
         size=size.small)

// ==========================
// Alerts
// ==========================

alertcondition(mainSignal, "Main Divergence Signal", "High volume with low price change - Potential major move!")
alertcondition(shadowSignal, "Shadow Candle Signal", "High volume with large shadow candle")
alertcondition(largeVolumeIncrease, "Volume Spike", "Significant volume increase detected")

// ==========================
// Info Table
// ==========================

var table infoTable = table.new(position.top_left, 2, 6, bgcolor=color.new(color.black, 85), border_width=1)

if barstate.islast and showLabels2
    table.cell(infoTable, 0, 0, "MacrolensBot", text_color=color.yellow, text_size=size.small, 
         bgcolor=color.new(color.blue, 70))
    table.cell(infoTable, 1, 0, "Vol-Price Div", text_color=color.white, text_size=size.small, 
         bgcolor=color.new(color.blue, 70))
    
    table.cell(infoTable, 0, 1, "Current Volume:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(volume, "#,###"), text_color=color.yellow, text_size=size.small)
    
    table.cell(infoTable, 0, 2, "Volume Change:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(volumeChange, "#.##") + "%", 
         text_color=largeVolumeIncrease ? color.lime : color.white, text_size=size.small)
    
    table.cell(infoTable, 0, 3, "Price Change:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(priceChangePercent, "#.##") + "%", text_color=color.aqua, text_size=size.small)
    
    table.cell(infoTable, 0, 4, "Body/Range:", text_color=color.white, text_size=size.small)
    bodyRangeRatio = candleRange > 0 ? (candleBody / candleRange) * 100 : 0
    table.cell(infoTable, 1, 4, str.tostring(bodyRangeRatio, "#.#") + "%", text_color=color.aqua, text_size=size.small)
    
    table.cell(infoTable, 0, 5, "Status:", text_color=color.white, text_size=size.small)
    statusText = mainSignal ? "🔴 DIVERGENCE" : shadowSignal ? "🟠 SHADOW" : largeVolumeIncrease ? "🟡 HIGH VOL" : "⚪ NORMAL"
    table.cell(infoTable, 1, 5, statusText, 
         text_color=mainSignal ? color.red : shadowSignal ? color.orange : largeVolumeIncrease ? color.yellow : color.gray, 
         text_size=size.small)











// =====================================================
// MODULE 3 — KEY LEVELS & SESSION H/L 
// =====================================================
get_timeframe_minutes() =>
    if timeframe.isseconds
        1
    else if timeframe.isminutes
        timeframe.multiplier
    else if timeframe.isdaily
        timeframe.multiplier * 1440
    else if timeframe.isweekly
        timeframe.multiplier * 10080
    else if timeframe.ismonthly
        timeframe.multiplier * 43200
    else
        timeframe.multiplier

should_show_granular_market_opens() => get_timeframe_minutes() <= 15       // 15m and below (inclusive)
should_show_standard_market_opens() => get_timeframe_minutes() <= 60       // 1H and below (inclusive)
should_show_session_details() => get_timeframe_minutes() <= 240            // 4H and below
should_show_vertical_lines() => get_timeframe_minutes() <= 240             // 4H and below
should_show_intraday_details() => get_timeframe_minutes() < 1440           // Below Daily (excludes Daily+)

//=============================================================================
// GENERAL SETTINGS v2.2
//=============================================================================
timezoneInput3 = input.string(defval="America/New_York", title="Select Timezone", options=["UTC", "America/New_York", "America/Los_Angeles", "America/Chicago", "America/Toronto", "America/Vancouver", "Europe/London", "Europe/Paris", "Europe/Berlin", "Asia/Tokyo", "Asia/Shanghai", "Australia/Sydney", "Australia/Melbourne", "Asia/Dubai", "Asia/Kolkata"], group="General Settings")

showText = input.bool(true, "Show Text Labels", group="General Settings")
showPrices = input.bool(false, "Show Prices", group="General Settings")
extendAllLines = input.bool(false, "Extend All Lines", group="General Settings")
autoSimplifyOnHTF = input.bool(true, "Auto-Simplify on Higher Timeframes", group="General Settings", tooltip="Automatically reduces visual clutter on higher timeframes by hiding granular details")
showDaysOfWeek = input.bool(true, "Show Days of Week Labels", group="General Settings")
showVerticalDayLines = input.bool(true, "Draw Vertical Lines at Session Close", group="General Settings", tooltip="Draws vertical lines at session close (17:00 ES)")

useGlobalTextColor = input.bool(false, "Use Global Color for All Labels", group="General Settings")
useGlobalLineColor = input.bool(false, "Use Global Color for All Lines", group="General Settings")
globalColor = input.color(color.black, "Global Color", group="General Settings", inline = "GSS1")
textSize = input.string("small", "Global Text Size", options=["tiny", "small", "normal", "large", "huge"], group="General Settings", inline = "GSS1")

//=============================================================================
// MARKET LEVELS CONFIGURATION
//=============================================================================
marketLevelsColor = input.color(color.new(color.gray, 0), "Color", group="Market Levels - Styling", inline="MLS")
marketLevelsTextSize = input.string("small", "Text Size", options=["tiny", "small", "normal", "large", "huge"], group="Market Levels - Styling", inline="MLS")
marketLevelsStyle = input.string("dotted", "Style", options=["solid", "dashed", "dotted"], group="Market Levels - Styling", inline="MLS2")
marketLevelsWidth = input.string("thin", "Width", options=["thin", "normal", "thick"], group="Market Levels - Styling", inline="MLS2")

marketLevelsShow0000 = input.bool(true, "00:00", group="Market Levels - Open Candles (ET - NYSE)", inline="ML1")
marketLevelsShow0200 = input.bool(false, "02:00", group="Market Levels - Open Candles (ET - NYSE)", inline="ML1")
marketLevelsShow0500 = input.bool(false, "05:00", group="Market Levels - Open Candles (ET - NYSE)", inline="ML1")
marketLevelsShow0830 = input.bool(true, "08:30", group="Market Levels - Open Candles (ET - NYSE)", inline="ML1")
marketLevelsShow0930 = input.bool(true, "09:30", group="Market Levels - Open Candles (ET - NYSE)", inline="ML1", tooltip = "*Make sure TradingView is set to New York Time Zone. \n*30m intervals will only show on compatible time intervals.")
marketLevelsShow1000 = input.bool(true, "10:00", group="Market Levels - Open Candles (ET - NYSE)", inline="ML2")
marketLevelsShow1400 = input.bool(true, "14:00", group="Market Levels - Open Candles (ET - NYSE)", inline="ML2")
marketLevelsShow1500 = input.bool(false, "15:00", group="Market Levels - Open Candles (ET - NYSE)", inline="ML2")
marketLevelsShow1600 = input.bool(false, "16:00", group="Market Levels - Open Candles (ET - NYSE)", inline="ML2")
marketLevelsShow1700 = input.bool(false, "17:00", group="Market Levels - Open Candles (ET - NYSE)", inline="ML2")
marketLevelsShow4H = input.bool(false, "4H Open", group="Market Levels - Open Candles (ET - NYSE)", inline="ML3")
marketLevelsShowDailyOpen = input.bool(false, "Daily Open", group="Market Levels - Open Candles (ET - NYSE)", inline="ML3")
marketLevelsShowWeeklyOpen = input.bool(false, "Weekly Open", group="Market Levels - Open Candles (ET - NYSE)", inline="ML3")
marketLevelsShowMonthlyOpen = input.bool(false, "Monthly Open", group="Market Levels - Open Candles (ET - NYSE)", inline="ML3")

rangeLevelsShowMarketOpen50 = input.bool(false, "Market Open Mid Range", group="Market Levels - Range Levels", inline="RNG1")
rangeLevelsShowDaily50 = input.bool(true, "Previous Day Mid Range", group="Market Levels - Range Levels", inline="RNG1", tooltip="The mid range can assist with gauging market premium/discount levels") 
rangeLevelsShowWeekly50 = input.bool(false, "Weekly Mid Range", group="Market Levels - Range Levels", inline="RNG2") 
rangeLevelsShowMonthly50 = input.bool(false, "Monthly Mid Range", group="Market Levels - Range Levels", inline="RNG2")

pivotPointsShow = input.bool(false, "Enable Standard Pivot Points", group="Market Levels - Pivots", tooltip="Standard Pivot Point Formulas:\nPP = (H + L + C) / 3\nS1 = (2×PP) - H, S2 = PP - (H - L)\nR1 = (2×PP) - L, R2 = PP + (H - L)\nCalculated from previous day's High, Low, Close")
centralPivotRangeShow = input.bool(false, "Enable Central Pivot Range (CPR)", group="Market Levels - Pivots", tooltip="*Central Pivot Range (Previous Day):\n(PP) = (High + Low + Close) / 3\n(BC) = (High + Low) / 2\n(TC) = 2×PP - BC \n *CPR Width % \n < 20% (Trending/Breakout)\n 20-30% (Mixed/Chop)\n >30% (Range Bound)")

//=============================================================================
// ASIA SESSION CONFIGURATION
//=============================================================================
asiaHighShow = input.bool(true, "Show Asia High", group="Asia Session", inline="AS1")
asiaLowShow = input.bool(true, "Show Asia Low", group="Asia Session", inline="AS1")

asiaSessionTime = "1800-0300"  // 18:00–03:00 EST for futures pre-market or forex
asiaSession = input.session(asiaSessionTime, "Asia Session Time", group="Asia Session")

asiaHighText = input.string("Asia High", "High Label Text", group="Asia Session", inline="AS2")
asiaLowText = input.string("Asia Low", "Low Label Text", group="Asia Session", inline="AS2")

asiaHighColor = input.color(color.new(color.green, 0), "Color", group="Asia Session", inline="AS3")
asiaHighStyle = input.string("solid", "Style", options=["solid", "dashed", "dotted"], group="Asia Session", inline="AS3")
asiaHighWidth = input.string("thin", "Width", options=["thin", "normal", "thick"], group="Asia Session", inline="AS3")

asiaLowColor = asiaHighColor
asiaLowStyle = asiaHighStyle
asiaLowWidth = asiaHighWidth

//=============================================================================
// LONDON SESSION CONFIGURATION
//=============================================================================
londonHighShow = input.bool(true, "Show London High", group="London Session", inline="LS1")
londonLowShow = input.bool(true, "Show London Low", group="London Session", inline="LS1")

londonSessionTime = "0300-0800"  // 03:00–08:00 EST for early market
londonSession = input.session(londonSessionTime, "London Session Time", group="London Session")

londonHighText = input.string("London High", "High Label Text", group="London Session", inline="LS2")
londonLowText = input.string("London Low", "Low Label Text", group="London Session", inline="LS2")

londonHighColor = input.color(color.new(color.blue, 0), "Color", group="London Session", inline="LS3")
londonHighStyle = input.string("solid", "Style", options=["solid", "dashed", "dotted"], group="London Session", inline="LS3")
londonHighWidth = input.string("thin", "Width", options=["thin", "normal", "thick"], group="London Session", inline="LS3")

londonLowColor = londonHighColor
londonLowStyle = londonHighStyle
londonLowWidth = londonHighWidth
 
//=============================================================================
// NEW YORK SESSION CONFIGURATION
//=============================================================================
newYorkHighShow = input.bool(true, "Show New York High", group="New York Session", inline="NYS1")
newYorkLowShow = input.bool(true, "Show New York Low", group="New York Session", inline="NYS1")

newYorkSessionTime = "0830-1700"  // 08:30–17:00 EST to match futures close
newYorkSession = input.session(newYorkSessionTime, "New York Session Time", group="New York Session")

newYorkHighText = input.string("New York High", "High Label Text", group="New York Session", inline="NYS2")
newYorkLowText = input.string("New York Low", "Low Label Text", group="New York Session", inline="NYS2")

newYorkHighColor = input.color(color.new(color.orange, 0), "Color", group="New York Session", inline="NYS3")
newYorkHighStyle = input.string("solid", "Style", options=["solid", "dashed", "dotted"], group="New York Session", inline="NYS3")
newYorkHighWidth = input.string("thin", "Width", options=["thin", "normal", "thick"], group="New York Session", inline="NYS3")

newYorkLowColor = newYorkHighColor
newYorkLowStyle = newYorkHighStyle
newYorkLowWidth = newYorkHighWidth

//=============================================================================
// WEEKLY LEVELS CONFIGURATION
//=============================================================================
weeklyHighShow = input.bool(true, "Show Weekly High", group="Weekly Levels", inline="WL1")
weeklyLowShow = input.bool(true, "Show Weekly Low", group="Weekly Levels", inline="WL1")

weeklyHighText = input.string("Weekly High", "High Label Text", group="Weekly Levels", inline="WL2")
weeklyLowText = input.string("Weekly Low", "Low Label Text", group="Weekly Levels", inline="WL2")

weeklyHighColor = input.color(color.new(color.purple, 0), "Color", group="Weekly Levels", inline="WL3")
weeklyHighStyle = input.string("solid", "Style", options=["solid", "dashed", "dotted"], group="Weekly Levels", inline="WL3")
weeklyHighWidth = input.string("thin", "Width", options=["thin", "normal", "thick"], group="Weekly Levels", inline="WL3")

weeklyLowColor = weeklyHighColor
weeklyLowStyle = weeklyHighStyle
weeklyLowWidth = weeklyHighWidth

//=============================================================================
// MONTHLY LEVELS CONFIGURATION
//=============================================================================
monthlyHighShow = input.bool(true, "Show Monthly High", group="Monthly Levels", inline="ML1")
monthlyLowShow = input.bool(true, "Show Monthly Low", group="Monthly Levels", inline="ML1")

monthlyHighText = input.string("Monthly High", "High Label Text", group="Monthly Levels", inline="ML2")
monthlyLowText = input.string("Monthly Low", "Low Label Text", group="Monthly Levels", inline="ML2")

monthlyHighColor = input.color(color.new(color.teal, 0), "Color", group="Monthly Levels", inline="ML3")
monthlyHighStyle = input.string("solid", "Style", options=["solid", "dashed", "dotted"], group="Monthly Levels", inline="ML3")
monthlyHighWidth = input.string("thin", "Width", options=["thin", "normal", "thick"], group="Monthly Levels", inline="ML3")

monthlyLowColor = monthlyHighColor
monthlyLowStyle = monthlyHighStyle
monthlyLowWidth = monthlyHighWidth

//=============================================================================
// PREVIOUS DAY LEVELS CONFIGURATION
//=============================================================================
prevDayHighShow = input.bool(true, "Show Previous Day High", group="Previous Day Levels", inline="PDL1")
prevDayLowShow = input.bool(true, "Show Previous Day Low", group="Previous Day Levels", inline="PDL1")

prevDayHighText = input.string("Previous Day High", "High Label Text", group="Previous Day Levels", inline="PDL2")
prevDayLowText = input.string("Previous Day Low", "Low Label Text", group="Previous Day Levels", inline="PDL2")

prevDayHighColor = input.color(color.new(color.maroon, 0), "Color", group="Previous Day Levels", inline="PDL3")
prevDayHighStyle = input.string("solid", "Style", options=["solid", "dashed", "dotted"], group="Previous Day Levels", inline="PDL3")
prevDayHighWidth = input.string("thin", "Width", options=["thin", "normal", "thick"], group="Previous Day Levels", inline="PDL3")

prevDayLowColor = prevDayHighColor
prevDayLowStyle = prevDayHighStyle
prevDayLowWidth = prevDayHighWidth

//=============================================================================
// ALL TIME HIGH CONFIGURATION
//=============================================================================
allTimeHighShow = input.bool(true, "Show All Time High", group="All Time High", inline="ATH1")

allTimeHighText = input.string("All Time High", "High Label Text", group="All Time High", inline="ATH2")

allTimeHighColor = input.color(color.new(color.red, 0), "Color", group="All Time High", inline="ATH3")
allTimeHighStyle = input.string("solid", "Style", options=["solid", "dashed", "dotted"], group="All Time High", inline="ATH3")
allTimeHighWidth = input.string("normal", "Width", options=["thin", "normal", "thick"], group="All Time High", inline="ATH3")

//=============================================================================
// HELPER FUNCTIONS
//=============================================================================
text_size() =>
    switch textSize
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        => size.huge

market_text_size() =>
    switch marketLevelsTextSize
        "tiny" => size.tiny
        "small" => size.small
        "normal" => size.normal
        "large" => size.large
        => size.huge

line_thickness(thickness) =>
    switch thickness
        "thin" => 1
        "normal" => 2
        "thick" => 4
        => 2

line_style3(style) =>
    if na(style)
        line.style_solid
    else
        switch style
            "solid" => line.style_solid
            "dashed" => line.style_dashed
            "dotted" => line.style_dotted
            => line.style_solid

//=============================================================================
// LEVEL DATA TYPE
//=============================================================================
type LevelData
    float price
    int startTime
    int endTime
    color levelColor
    string levelStyle
    string levelWidth
    string labelText
    bool isBroken
    bool isSessionOpen
    bool shouldExtend
    bool isMarketLevel
    bool isHighLevel

//=============================================================================
// SMART LABEL POSITIONING FUNCTIONS
//=============================================================================
get_label_position(startTime, endTime, isBroken, isSessionOpen, isMarketLevel = false) =>
    if isMarketLevel
        time + (timeframe.multiplier * 60000 * 2)
    else
        hasChartData = not na(chart.left_visible_bar_time) and not na(chart.right_visible_bar_time)
        
        if not hasChartData or isBroken
            lineDuration = endTime - startTime
            if isSessionOpen
                startTime + (lineDuration * 0.9)
            else if isBroken
                startTime + (lineDuration * 0.5)
            else
                startTime + (lineDuration * 0.9)
        else
            screenStartTime = chart.left_visible_bar_time
            screenEndTime = chart.right_visible_bar_time
            screenDuration = screenEndTime - screenStartTime
            
            visibleStartTime = math.max(startTime, screenStartTime)
            visibleEndTime = math.min(endTime, screenEndTime)
            
            if visibleStartTime >= visibleEndTime
                na
            else
                // Calculate line length relative to screen
                lineDuration = endTime - startTime
                lineVisibleDuration = visibleEndTime - visibleStartTime
                
                // If line is short relative to screen, position label more to the right
                lineToScreenRatio = lineDuration / screenDuration
                
                var float desiredPosition = na
                
                if lineToScreenRatio < 0.15  // Line is less than 30% of screen width
                    // For short lines, position label near the end of the actual line
                    if isSessionOpen
                        desiredPosition := visibleStartTime + (lineVisibleDuration * 0.8)
                    else
                        desiredPosition := visibleStartTime + (lineVisibleDuration * 0.85)
                else
                    // For longer lines, use the original screen-based positioning
                    if isSessionOpen
                        desiredPosition := screenStartTime + (screenDuration * 0.85)
                    else
                        desiredPosition := screenStartTime + (screenDuration * 0.85)
                
                // Ensure the position stays within visible bounds
                math.max(visibleStartTime, math.min(desiredPosition, visibleEndTime))

create_combined_label(price, combinedText, levelColor, startTime, endTime, isBroken, isSessionOpen, isMarketLevel = false, isHighLevel = false) =>
    if showText
        labelPosition = get_label_position(startTime, endTime, isBroken, isSessionOpen, isMarketLevel)
        
        // Check if position is valid (not na and not NaN)
        if not na(labelPosition) and labelPosition == labelPosition
            finalText = ""
            if showPrices and not na(price)
                if str.contains(combinedText, "PP") or str.contains(combinedText, "CPR")
                    finalText := combinedText + " (" + str.tostring(math.round(price), "#") + ")"
                else
                    finalText := combinedText + " (" + str.tostring(price, "#.#####") + ")"
            else
                finalText := combinedText
            
            labelTextColor = useGlobalTextColor ? globalColor : levelColor
            
            if isMarketLevel
                label.new(math.round(labelPosition), price, finalText, xloc=xloc.bar_time, style=label.style_label_left, size=market_text_size(), textcolor=labelTextColor, color=color.new(color.white, 100))
            else
                label.new(math.round(labelPosition), price, finalText, xloc=xloc.bar_time, style=label.style_none, size=text_size(), textcolor=labelTextColor, textalign=text.align_center)
        else
            // Real-time fallback: if positioning fails on real-time bars, create label at current time
            if barstate.isrealtime
                finalText = ""
                if showPrices and not na(price)
                    if str.contains(combinedText, "PP") or str.contains(combinedText, "CPR")
                        finalText := combinedText + " (" + str.tostring(math.round(price), "#") + ")"
                    else
                        finalText := combinedText + " (" + str.tostring(price, "#.#####") + ")"
                else
                    finalText := combinedText
                
                labelTextColor = useGlobalTextColor ? globalColor : levelColor
                
                if isMarketLevel
                    label.new(time, price, finalText, xloc=xloc.bar_time, style=label.style_label_left, size=market_text_size(), textcolor=labelTextColor, color=color.new(color.white, 100))
                else
                    label.new(time, price, finalText, xloc=xloc.bar_time, style=label.style_none, size=text_size(), textcolor=labelTextColor, textalign=text.align_center)
            else
                na
    else
        na

//=============================================================================
// TIME-BASED DRAWING FUNCTIONS
//=============================================================================
create_time_line(startTime, endTime, price, levelColor, levelStyle, levelWidth, shouldExtend) =>
    finalLineColor = useGlobalLineColor ? globalColor : levelColor
    line.new(startTime, price, endTime, price, xloc=xloc.bar_time, color=finalLineColor, style=line_style3(levelStyle), width=line_thickness(levelWidth), extend=shouldExtend ? extend.right : extend.none)

create_market_level_line(startTime, endTime, price, levelColor, levelStyle, levelWidth, shouldExtend) =>
    finalLineColor = useGlobalLineColor ? globalColor : levelColor
    finalEndTime = endTime + (timeframe.multiplier * 60000 * 3)
    line.new(startTime, price, finalEndTime, price, xloc=xloc.bar_time, color=finalLineColor, style=line_style3(levelStyle), width=line_thickness(levelWidth), extend=shouldExtend ? extend.right : extend.none)

get_line_end_time(startTime, isBroken, breakTime, shouldExtend) =>
    if shouldExtend
        time + (24 * 3600000)
    else if isBroken
        not na(breakTime) ? breakTime : startTime + 3600000
    else
        time

//=============================================================================
// PRICE LEVEL COMBINING FUNCTION - POSITION-BASED (SIMPLE & CORRECT)
//=============================================================================
combine_levels_at_same_price(levels) =>
    var array<LevelData> combinedLevels = array.new<LevelData>()
    array.clear(combinedLevels)
    
    if array.size(levels) == 0
        combinedLevels
    else
        for i = 0 to array.size(levels) - 1
            currentLevel = array.get(levels, i)
            currentPrice = math.round(currentLevel.price * 100000)
            
            foundMatch = false
            matchIndex = 0
            
            if array.size(combinedLevels) > 0
                for j = 0 to array.size(combinedLevels) - 1
                    existingLevel = array.get(combinedLevels, j)
                    existingPrice = math.round(existingLevel.price * 100000)
                    
                    // Combine only if:
                    // 1. Prices match AND
                    // 2. Both have the same label positioning (both market levels OR both non-market levels)
                    if currentPrice == existingPrice and currentLevel.isMarketLevel == existingLevel.isMarketLevel
                        foundMatch := true
                        matchIndex := j
                        break
            
            if foundMatch and array.size(combinedLevels) > matchIndex
                existingLevel = array.get(combinedLevels, matchIndex)
                newText = existingLevel.labelText + " | " + currentLevel.labelText
                newStartTime = math.min(existingLevel.startTime, currentLevel.startTime)
                newEndTime = math.max(existingLevel.endTime, currentLevel.endTime)
                newBroken = existingLevel.isBroken or currentLevel.isBroken
                newSessionOpen = existingLevel.isSessionOpen or currentLevel.isSessionOpen
                
                updatedLevel = LevelData.new(existingLevel.price, newStartTime, newEndTime, existingLevel.levelColor, existingLevel.levelStyle, existingLevel.levelWidth, newText, newBroken, newSessionOpen, existingLevel.shouldExtend, existingLevel.isMarketLevel or currentLevel.isMarketLevel, existingLevel.isHighLevel or currentLevel.isHighLevel)
                array.set(combinedLevels, matchIndex, updatedLevel)
            else
                array.push(combinedLevels, currentLevel)
        
        combinedLevels

//=============================================================================
// GET PREVIOUS DAY DATA
//=============================================================================
prevDayCloseValue = request.security(syminfo.tickerid, "1D", close[1])

//=============================================================================
// SESSION LOGIC
//=============================================================================
timezoneToUse = timezoneInput3

inAsia3 = not na(time(timeframe.period, asiaSession, timezoneToUse))
inLondon3 = not na(time(timeframe.period, londonSession, timezoneToUse))
inNewYork3 = not na(time(timeframe.period, newYorkSession, timezoneToUse))

newAsiaSession = inAsia3 and not inAsia3[1]
newLondonSession = inLondon3 and not inLondon3[1]
newNewYorkSession = inNewYork3 and not inNewYork3[1]

isMarketLevel0000 = hour(time, "America/New_York") == 0 and minute(time, "America/New_York") == 0 and second == 0
isMarketLevel0200 = hour(time, "America/New_York") == 2 and minute(time, "America/New_York") == 0 and second == 0
isMarketLevel0500 = hour(time, "America/New_York") == 5 and minute(time, "America/New_York") == 0 and second == 0
isMarketLevel0830 = hour(time, "America/New_York") == 8 and minute(time, "America/New_York") == 30 and second == 0
isMarketLevel0930 = hour(time, "America/New_York") == 9 and minute(time, "America/New_York") == 30 and second == 0
isMarketLevel1000 = hour(time, "America/New_York") == 10 and minute(time, "America/New_York") == 0 and second == 0
isMarketLevel1400 = hour(time, "America/New_York") == 14 and minute(time, "America/New_York") == 0 and second == 0
isMarketLevel1500 = hour(time, "America/New_York") == 15 and minute(time, "America/New_York") == 0 and second == 0
isMarketLevel1600 = hour(time, "America/New_York") == 16 and minute(time, "America/New_York") == 0 and second == 0
isMarketLevel1700 = hour(time, "America/New_York") == 17 and minute(time, "America/New_York") == 0 and second == 0

newMarketLevel0000 = isMarketLevel0000 and not isMarketLevel0000[1]
newMarketLevel0200 = isMarketLevel0200 and not isMarketLevel0200[1]
newMarketLevel0500 = isMarketLevel0500 and not isMarketLevel0500[1]
newMarketLevel0830 = isMarketLevel0830 and not isMarketLevel0830[1]
newMarketLevel0930 = isMarketLevel0930 and not isMarketLevel0930[1]
newMarketLevel1000 = isMarketLevel1000 and not isMarketLevel1000[1]
newMarketLevel1400 = isMarketLevel1400 and not isMarketLevel1400[1]
newMarketLevel1500 = isMarketLevel1500 and not isMarketLevel1500[1]
newMarketLevel1600 = isMarketLevel1600 and not isMarketLevel1600[1]
newMarketLevel1700 = isMarketLevel1700 and not isMarketLevel1700[1]

newWeek = ta.change(time('1W')) != 0
newMonth = ta.change(time('1M')) != 0
newDay = ta.change(time('1D')) != 0

//=============================================================================
// STATE VARIABLES
//=============================================================================
var float asiaHigh = na
var float asiaLow = na
var int asiaHighTime = na
var int asiaLowTime = na
var bool asiaHighBroken = false
var bool asiaLowBroken = false
var int asiaHighBreakTime = na
var int asiaLowBreakTime = na

var float londonHigh = na
var float londonLow = na
var int londonHighTime = na
var int londonLowTime = na
var bool londonHighBroken = false
var bool londonLowBroken = false
var int londonHighBreakTime = na
var int londonLowBreakTime = na

var float newYorkHigh = na
var float newYorkLow = na
var int newYorkHighTime = na
var int newYorkLowTime = na
var bool newYorkHighBroken = false
var bool newYorkLowBroken = false
var int newYorkHighBreakTime = na
var int newYorkLowBreakTime = na

var float allTimeHigh = na
var int allTimeHighTime = na
var bool allTimeHighBroken = false
var int allTimeHighBreakTime = na

var float weeklyHigh = na
var float weeklyLow = na
var int weeklyHighTime = na
var int weeklyLowTime = na
var bool weeklyHighBroken = false
var bool weeklyLowBroken = false
var int weeklyHighBreakTime = na
var int weeklyLowBreakTime = na

var float monthlyHigh = na
var float monthlyLow = na
var int monthlyHighTime = na
var int monthlyLowTime = na
var bool monthlyHighBroken = false
var bool monthlyLowBroken = false
var int monthlyHighBreakTime = na
var int monthlyLowBreakTime = na

var float prevDayHigh = na
var float prevDayLow = na
var float prevDayClose = na
var int prevDayHighTime = na
var int prevDayLowTime = na
var bool prevDayHighBroken = false
var bool prevDayLowBroken = false
var int prevDayHighBreakTime = na
var int prevDayLowBreakTime = na
var int prevDayMarketOpenTime = na

var float currentDayHigh = na
var float currentDayLow = na
var int currentDayHighTime = na
var int currentDayLowTime = na

var float marketLevel0000Price = na
var int marketLevel0000Time = na
var float marketLevel0200Price = na
var int marketLevel0200Time = na
var float marketLevel0500Price = na
var int marketLevel0500Time = na
var float marketLevel0830Price = na
var int marketLevel0830Time = na
var float marketLevel0930Price = na
var int marketLevel0930Time = na
var float marketLevel1000Price = na
var int marketLevel1000Time = na
var float marketLevel1400Price = na
var int marketLevel1400Time = na
var float marketLevel1500Price = na
var int marketLevel1500Time = na
var float marketLevel1600Price = na
var int marketLevel1600Time = na
var float marketLevel1700Price = na
var int marketLevel1700Time = na
var float marketLevel4HPrice = na
var int marketLevel4HTime = na
var float marketLevelDailyOpenPrice = na
var int marketLevelDailyOpenTime = na
var float marketLevelWeeklyOpenPrice = na
var int marketLevelWeeklyOpenTime = na
var float marketLevelMonthlyOpenPrice = na
var int marketLevelMonthlyOpenTime = na

var float rangeLevelDaily50Price = na
var int rangeLevelDaily50Time = na
var float rangeLevelMarketOpen50Price = na
var int rangeLevelMarketOpen50Time = na
var float rangeLevelWeekly50Price = na
var int rangeLevelWeekly50Time = na
var float rangeLevelMonthly50Price = na
var int rangeLevelMonthly50Time = na

var float sessionOpenHigh = na
var float sessionOpenLow = na

var float pivotPoint = na
var float pivotS1 = na
var float pivotS2 = na
var float pivotR1 = na
var float pivotR2 = na

var float cprPivotPoint = na
var float cprBottomCentral = na
var float cprTopCentral = na
var float cprWidthPercent = na

var array<line> allLines = array.new<line>()
var array<label> allLabels = array.new<label>()

//=============================================================================
// SESSION RESET LOGIC
//=============================================================================
if newAsiaSession
    asiaHigh := na
    asiaLow := na
    asiaHighTime := na
    asiaLowTime := na
    asiaHighBroken := false
    asiaLowBroken := false
    asiaHighBreakTime := na
    asiaLowBreakTime := na

if newLondonSession
    londonHigh := na
    londonLow := na
    londonHighTime := na
    londonLowTime := na
    londonHighBroken := false
    londonLowBroken := false
    londonHighBreakTime := na
    londonLowBreakTime := na

if newNewYorkSession
    newYorkHigh := na
    newYorkLow := na
    newYorkHighTime := na
    newYorkLowTime := na
    newYorkHighBroken := false
    newYorkLowBroken := false
    newYorkHighBreakTime := na
    newYorkLowBreakTime := na

if newWeek
    weeklyHigh := na
    weeklyLow := na
    weeklyHighTime := na
    weeklyLowTime := na
    weeklyHighBroken := false
    weeklyLowBroken := false
    weeklyHighBreakTime := na
    weeklyLowBreakTime := na

if newMonth
    monthlyHigh := na
    monthlyLow := na
    monthlyHighTime := na
    monthlyLowTime := na
    monthlyHighBroken := false
    monthlyLowBroken := false
    monthlyHighBreakTime := na
    monthlyLowBreakTime := na

if newDay
    if not na(currentDayHigh) and not na(currentDayLow)
        prevDayHigh := currentDayHigh
        prevDayLow := currentDayLow
        prevDayClose := prevDayCloseValue
        prevDayHighTime := currentDayHighTime
        prevDayLowTime := currentDayLowTime
        prevDayHighBroken := false
        prevDayLowBroken := false
        prevDayHighBreakTime := na
        prevDayLowBreakTime := na
        
        if not na(prevDayCloseValue) and not na(prevDayHigh) and not na(prevDayLow)
            pivotPoint := (prevDayHigh + prevDayLow + prevDayCloseValue) / 3
            pivotS1 := (2 * pivotPoint) - prevDayHigh
            pivotR1 := (2 * pivotPoint) - prevDayLow
            pivotS2 := pivotPoint - (prevDayHigh - prevDayLow)
            pivotR2 := pivotPoint + (prevDayHigh - prevDayLow)
        
        if not na(prevDayCloseValue) and not na(prevDayHigh) and not na(prevDayLow)
            cprPivotPoint := (prevDayHigh + prevDayLow + prevDayCloseValue) / 3
            cprBottomCentral := (prevDayHigh + prevDayLow) / 2
            cprTopCentral := 2 * cprPivotPoint - cprBottomCentral

        if not na(cprTopCentral) and not na(cprBottomCentral) and not na(prevDayHigh) and not na(prevDayLow)
            cprWidth = cprTopCentral - cprBottomCentral
            prevDayRange = prevDayHigh - prevDayLow
            cprWidthPercent := (cprWidth / prevDayRange) * 100

    currentDayHigh := high
    currentDayLow := low
    currentDayHighTime := time
    currentDayLowTime := time
    sessionOpenHigh := na
    sessionOpenLow := na
    rangeLevelMarketOpen50Price := na
    rangeLevelMarketOpen50Time := na

if newMarketLevel0000
    // Reset all market levels when 00:00 triggers (start of new trading day)
    marketLevel0000Price := na
    marketLevel0000Time := na
    marketLevel0200Price := na
    marketLevel0200Time := na
    marketLevel0500Price := na
    marketLevel0500Time := na
    marketLevel0830Price := na
    marketLevel0830Time := na
    marketLevel0930Price := na
    marketLevel0930Time := na
    marketLevel1000Price := na
    marketLevel1000Time := na
    marketLevel1400Price := na
    marketLevel1400Time := na
    marketLevel1500Price := na
    marketLevel1500Time := na
    marketLevel1600Price := na
    marketLevel1600Time := na
    marketLevel1700Price := na
    marketLevel1700Time := na
    marketLevel4HPrice := na
    marketLevel4HTime := na
    
    // Set the new 00:00 level
    marketLevel0000Price := open
    marketLevel0000Time := time

if newMarketLevel0200
    marketLevel0200Price := open
    marketLevel0200Time := time

if newMarketLevel0500
    marketLevel0500Price := open
    marketLevel0500Time := time

if newMarketLevel0830
    marketLevel0830Price := open
    marketLevel0830Time := time

if newMarketLevel0930
    marketLevel0930Price := open
    marketLevel0930Time := time

if newMarketLevel1000
    marketLevel1000Price := open
    marketLevel1000Time := time

if newMarketLevel1400
    marketLevel1400Price := open
    marketLevel1400Time := time

if newMarketLevel1500
    marketLevel1500Price := open
    marketLevel1500Time := time

if newMarketLevel1600
    marketLevel1600Price := open
    marketLevel1600Time := time

if newMarketLevel1700
    marketLevel1700Price := open
    marketLevel1700Time := time

// 4H candle open (most recent)
new4H = ta.change(time('240')) != 0
if new4H
    marketLevel4HPrice := open
    marketLevel4HTime := time

// Daily open
if newDay
    marketLevelDailyOpenPrice := open
    marketLevelDailyOpenTime := time
    
    // Initialize Market Open Range tracking
    sessionOpenHigh := high
    sessionOpenLow := low
    rangeLevelMarketOpen50Time := time
    rangeLevelMarketOpen50Price := low + ((high - low) * 0.5)

// Weekly open  
if newWeek
    marketLevelWeeklyOpenPrice := open
    marketLevelWeeklyOpenTime := time

// Monthly open
if newMonth
    marketLevelMonthlyOpenPrice := open
    marketLevelMonthlyOpenTime := time

if newDay
    // Store the previous day's market open time BEFORE overwriting
    if not na(marketLevelDailyOpenTime)
        prevDayMarketOpenTime := marketLevelDailyOpenTime
    
    // Set the new day's market open
    marketLevelDailyOpenPrice := open
    marketLevelDailyOpenTime := time

if newDay and not na(prevDayHigh) and not na(prevDayLow) and not na(prevDayMarketOpenTime)
    rangeLevelDaily50Price := prevDayLow + ((prevDayHigh - prevDayLow) * 0.5)
    rangeLevelDaily50Time := time

// Update Market Open Range throughout the day
if not na(sessionOpenHigh) and not na(sessionOpenLow) and not na(rangeLevelMarketOpen50Time)
    rangeUpdated = false
    
    if high > sessionOpenHigh
        sessionOpenHigh := high
        rangeUpdated := true
    if low < sessionOpenLow  
        sessionOpenLow := low
        rangeUpdated := true
    
    // Recalculate market open 50% level when range changes
    if rangeUpdated
        rangeLevelMarketOpen50Price := sessionOpenLow + ((sessionOpenHigh - sessionOpenLow) * 0.5)

if newWeek or (not na(weeklyHigh) and not na(weeklyLow) and na(rangeLevelWeekly50Time))
    if not na(weeklyHigh) and not na(weeklyLow)
        rangeLevelWeekly50Price := weeklyLow + ((weeklyHigh - weeklyLow) * 0.5)
        if na(rangeLevelWeekly50Time) or newWeek
            rangeLevelWeekly50Time := time

// Update Weekly 50% when weekly high/low changes
if not na(weeklyHigh) and not na(weeklyLow) and not na(rangeLevelWeekly50Time)
    newWeekly50Price = weeklyLow + ((weeklyHigh - weeklyLow) * 0.5)
    if newWeekly50Price != rangeLevelWeekly50Price
        rangeLevelWeekly50Price := newWeekly50Price

// Calculate Monthly 50% Range 
if newMonth or (not na(monthlyHigh) and not na(monthlyLow) and na(rangeLevelMonthly50Time))
    if not na(monthlyHigh) and not na(monthlyLow)
        rangeLevelMonthly50Price := monthlyLow + ((monthlyHigh - monthlyLow) * 0.5)
        if na(rangeLevelMonthly50Time) or newMonth
            rangeLevelMonthly50Time := time

// Update Monthly 50% when monthly high/low changes
if not na(monthlyHigh) and not na(monthlyLow) and not na(rangeLevelMonthly50Time)
    newMonthly50Price = monthlyLow + ((monthlyHigh - monthlyLow) * 0.5)
    if newMonthly50Price != rangeLevelMonthly50Price
        rangeLevelMonthly50Price := newMonthly50Price

//=============================================================================
// UPDATE HIGHS AND LOWS & CHECK FOR BREAKS
//=============================================================================
if inAsia3
    if na(asiaHigh) or high > asiaHigh
        asiaHigh := high
        asiaHighTime := time
    if na(asiaLow) or low < asiaLow
        asiaLow := low
        asiaLowTime := time

if inLondon3
    if na(londonHigh) or high > londonHigh
        londonHigh := high
        londonHighTime := time
    if na(londonLow) or low < londonLow
        londonLow := low
        londonLowTime := time

if inNewYork3
    if na(newYorkHigh) or high > newYorkHigh
        newYorkHigh := high
        newYorkHighTime := time
    if na(newYorkLow) or low < newYorkLow
        newYorkLow := low
        newYorkLowTime := time

// Update All Time High
if na(allTimeHigh) or high > allTimeHigh
    allTimeHigh := high
    allTimeHighTime := time

// Check for All Time High breaks (if using non-extending lines)
if not extendAllLines and not na(allTimeHigh) and not allTimeHighBroken
    if high > allTimeHigh
        allTimeHighBroken := true
        allTimeHighBreakTime := time

if na(weeklyHigh) or high > weeklyHigh
    weeklyHigh := high
    weeklyHighTime := time
if na(weeklyLow) or low < weeklyLow
    weeklyLow := low
    weeklyLowTime := time

if na(monthlyHigh) or high > monthlyHigh
    monthlyHigh := high
    monthlyHighTime := time
if na(monthlyLow) or low < monthlyLow
    monthlyLow := low
    monthlyLowTime := time

if na(currentDayHigh) or high > currentDayHigh
    currentDayHigh := high
    currentDayHighTime := time
if na(currentDayLow) or low < currentDayLow
    currentDayLow := low
    currentDayLowTime := time

if not extendAllLines
    if not inAsia3 and not na(asiaHigh) and not asiaHighBroken
        if high > asiaHigh
            asiaHighBroken := true
            asiaHighBreakTime := time
    
    if not inAsia3 and not na(asiaLow) and not asiaLowBroken
        if low < asiaLow
            asiaLowBroken := true
            asiaLowBreakTime := time
    
    if not inLondon3 and not na(londonHigh) and not londonHighBroken
        if high > londonHigh
            londonHighBroken := true
            londonHighBreakTime := time
    
    if not inLondon3 and not na(londonLow) and not londonLowBroken
        if low < londonLow
            londonLowBroken := true
            londonLowBreakTime := time
    
    if not inNewYork3 and not na(newYorkHigh) and not newYorkHighBroken
        if high > newYorkHigh
            newYorkHighBroken := true
            newYorkHighBreakTime := time
    
    if not inNewYork3 and not na(newYorkLow) and not newYorkLowBroken
        if low < newYorkLow
            newYorkLowBroken := true
            newYorkLowBreakTime := time
    
    if not na(weeklyHigh) and not weeklyHighBroken
        if high > weeklyHigh
            weeklyHighBroken := true
            weeklyHighBreakTime := time
    
    if not na(weeklyLow) and not weeklyLowBroken
        if low < weeklyLow
            weeklyLowBroken := true
            weeklyLowBreakTime := time
    
    if not na(monthlyHigh) and not monthlyHighBroken
        if high > monthlyHigh
            monthlyHighBroken := true
            monthlyHighBreakTime := time
    
    if not na(monthlyLow) and not monthlyLowBroken
        if low < monthlyLow
            monthlyLowBroken := true
            monthlyLowBreakTime := time
    
    if not na(prevDayHigh) and not prevDayHighBroken
        if high > prevDayHigh
            prevDayHighBroken := true
            prevDayHighBreakTime := time
    
    if not na(prevDayLow) and not prevDayLowBroken
        if low < prevDayLow
            prevDayLowBroken := true
            prevDayLowBreakTime := time

//=============================================================================
// MAIN DRAWING LOGIC WITH TIMEFRAME-AWARE FILTERING
//=============================================================================
if barstate.isrealtime or barstate.islast or newAsiaSession or newLondonSession or newNewYorkSession or newWeek or newMonth or newDay or new4H or newMarketLevel0000 or newMarketLevel0200 or newMarketLevel0500 or newMarketLevel0830 or newMarketLevel0930 or newMarketLevel1000 or newMarketLevel1400 or newMarketLevel1500 or newMarketLevel1600 or newMarketLevel1700
    if array.size(allLines) > 0
        for i = 0 to array.size(allLines) - 1
            line.delete(array.get(allLines, i))
        array.clear(allLines)

    if array.size(allLabels) > 0
        for i = 0 to array.size(allLabels) - 1
            label.delete(array.get(allLabels, i))
        array.clear(allLabels)

    var array<LevelData> allLevels = array.new<LevelData>()
    array.clear(allLevels)

    // Timeframe-aware filtering logic
    showGranularOpens = not autoSimplifyOnHTF or should_show_granular_market_opens()
    showStandardOpens = not autoSimplifyOnHTF or should_show_standard_market_opens()
    showSessionLevels = not autoSimplifyOnHTF or should_show_session_details()
    showIntradayLevels = not autoSimplifyOnHTF or should_show_intraday_details()
    showVerticalLines = not autoSimplifyOnHTF or should_show_vertical_lines()

    // Market Levels - Filtered by timeframe
    if marketLevelsShow0000 and not na(marketLevel0000Price) and not na(marketLevel0000Time) and showStandardOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml0000Level = LevelData.new(marketLevel0000Price, marketLevel0000Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "00:00", false, true, extendAllLines, true, false)
        array.push(allLevels, ml0000Level)

    if marketLevelsShow0200 and not na(marketLevel0200Price) and not na(marketLevel0200Time) and showGranularOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml0200Level = LevelData.new(marketLevel0200Price, marketLevel0200Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "02:00", false, true, extendAllLines, true, false)
        array.push(allLevels, ml0200Level)

    if marketLevelsShow0500 and not na(marketLevel0500Price) and not na(marketLevel0500Time) and showGranularOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml0500Level = LevelData.new(marketLevel0500Price, marketLevel0500Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "05:00", false, true, extendAllLines, true, false)
        array.push(allLevels, ml0500Level)

    if marketLevelsShow0830 and not na(marketLevel0830Price) and not na(marketLevel0830Time) and showStandardOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml0830Level = LevelData.new(marketLevel0830Price, marketLevel0830Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "08:30", false, true, extendAllLines, true, false)
        array.push(allLevels, ml0830Level)

    if marketLevelsShow0930 and not na(marketLevel0930Price) and not na(marketLevel0930Time) and showStandardOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml0930Level = LevelData.new(marketLevel0930Price, marketLevel0930Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "09:30", false, true, extendAllLines, true, false)
        array.push(allLevels, ml0930Level)

    if marketLevelsShow1000 and not na(marketLevel1000Price) and not na(marketLevel1000Time) and showGranularOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml1000Level = LevelData.new(marketLevel1000Price, marketLevel1000Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "10:00", false, true, extendAllLines, true, false)
        array.push(allLevels, ml1000Level)

    if marketLevelsShow1400 and not na(marketLevel1400Price) and not na(marketLevel1400Time) and showStandardOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml1400Level = LevelData.new(marketLevel1400Price, marketLevel1400Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "14:00", false, true, extendAllLines, true, false)
        array.push(allLevels, ml1400Level)

    if marketLevelsShow1500 and not na(marketLevel1500Price) and not na(marketLevel1500Time) and showGranularOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml1500Level = LevelData.new(marketLevel1500Price, marketLevel1500Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "15:00", false, true, extendAllLines, true, false)
        array.push(allLevels, ml1500Level)

    if marketLevelsShow1600 and not na(marketLevel1600Price) and not na(marketLevel1600Time) and showGranularOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml1600Level = LevelData.new(marketLevel1600Price, marketLevel1600Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "16:00", false, true, extendAllLines, true, false)
        array.push(allLevels, ml1600Level)

    if marketLevelsShow1700 and not na(marketLevel1700Price) and not na(marketLevel1700Time) and showStandardOpens
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml1700Level = LevelData.new(marketLevel1700Price, marketLevel1700Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "17:00", false, true, extendAllLines, true, false)
        array.push(allLevels, ml1700Level)

    if marketLevelsShow4H and not na(marketLevel4HPrice) and not na(marketLevel4HTime) and showIntradayLevels
        endTime = extendAllLines ? time + (24 * 3600000) : time
        ml4HLevel = LevelData.new(marketLevel4HPrice, marketLevel4HTime, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "4H Open", false, true, extendAllLines, true, false)
        array.push(allLevels, ml4HLevel)

    if marketLevelsShowDailyOpen and not na(marketLevelDailyOpenPrice) and not na(marketLevelDailyOpenTime) and showIntradayLevels
        endTime = extendAllLines ? time + (24 * 3600000) : time
        mlDailyOpenLevel = LevelData.new(marketLevelDailyOpenPrice, marketLevelDailyOpenTime, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "Daily Open", false, true, extendAllLines, true, false)
        array.push(allLevels, mlDailyOpenLevel)

    if marketLevelsShowWeeklyOpen and not na(marketLevelWeeklyOpenPrice) and not na(marketLevelWeeklyOpenTime)
        endTime = extendAllLines ? time + (24 * 3600000) : time
        mlWeeklyOpenLevel = LevelData.new(marketLevelWeeklyOpenPrice, marketLevelWeeklyOpenTime, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "Weekly Open", false, true, extendAllLines, true, false)
        array.push(allLevels, mlWeeklyOpenLevel)

    if marketLevelsShowMonthlyOpen and not na(marketLevelMonthlyOpenPrice) and not na(marketLevelMonthlyOpenTime)
        endTime = extendAllLines ? time + (24 * 3600000) : time
        mlMonthlyOpenLevel = LevelData.new(marketLevelMonthlyOpenPrice, marketLevelMonthlyOpenTime, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "Monthly Open", false, true, extendAllLines, true, false)
        array.push(allLevels, mlMonthlyOpenLevel)

    // Range Levels - Filtered by timeframe
    if rangeLevelsShowDaily50 and not na(rangeLevelDaily50Price) and not na(rangeLevelMarketOpen50Time) and showIntradayLevels
        endTime = extendAllLines ? time + (24 * 3600000) : time
        prevDayStartTime = rangeLevelMarketOpen50Time - (24 * 60 * 60 * 1000)
        rangeDaily50Level = LevelData.new(rangeLevelDaily50Price, prevDayStartTime, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "Prev Day Mid Range", false, true, extendAllLines, true, false)
        array.push(allLevels, rangeDaily50Level)

    if rangeLevelsShowMarketOpen50 and not na(rangeLevelMarketOpen50Price) and not na(rangeLevelMarketOpen50Time) and showIntradayLevels
        endTime = extendAllLines ? time + (24 * 3600000) : time
        rangeMarketOpen50Level = LevelData.new(rangeLevelMarketOpen50Price, rangeLevelMarketOpen50Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "Market Open Mid Range", false, true, extendAllLines, true, false)
        array.push(allLevels, rangeMarketOpen50Level)

    if rangeLevelsShowWeekly50 and not na(rangeLevelWeekly50Price) and not na(rangeLevelWeekly50Time)
        endTime = extendAllLines ? time + (24 * 3600000) : time
        rangeWeekly50Level = LevelData.new(rangeLevelWeekly50Price, rangeLevelWeekly50Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "Weekly Mid Range", false, true, extendAllLines, true, false)
        array.push(allLevels, rangeWeekly50Level)

    if rangeLevelsShowMonthly50 and not na(rangeLevelMonthly50Price) and not na(rangeLevelMonthly50Time)
        endTime = extendAllLines ? time + (24 * 3600000) : time
        rangeMonthly50Level = LevelData.new(rangeLevelMonthly50Price, rangeLevelMonthly50Time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "Monthly Mid Range", false, true, extendAllLines, true, false)
        array.push(allLevels, rangeMonthly50Level)
    
    // Vertical Day Lines - Only show on appropriate timeframes
    if showVerticalDayLines and showVerticalLines
        chartHigh = ta.highest(high, 100)
        chartLow = ta.lowest(low, 100)
        
        // Draw lines for the past 14 days at 17:00
        for i = 0 to 13
            pastDate = time - (i * 24 * 60 * 60 * 1000)
            line1700Time = timestamp("America/New_York", year(pastDate), month(pastDate), dayofmonth(pastDate), 17, 0, 0)
            
            if line1700Time <= time and line1700Time > (time - 16 * 24 * 60 * 60 * 1000)
                vertLine1700 = line.new(line1700Time, chartLow, line1700Time, chartHigh, xloc=xloc.bar_time, color=useGlobalLineColor ? globalColor : marketLevelsColor, style=line_style3(marketLevelsStyle), width=line_thickness(marketLevelsWidth), extend=extend.both)
                array.push(allLines, vertLine1700)

    // Standard Pivot Points - Only show on intraday timeframes
    if pivotPointsShow and not na(pivotPoint) and showIntradayLevels
        endTime = extendAllLines ? time + (24 * 3600000) : time
        
        dailyRange = prevDayHigh - prevDayLow
        rangeTicks = math.round(dailyRange / syminfo.mintick)
        
        ppLabelText = "PP (R: " + str.tostring(rangeTicks, "#") + "tk)"
        ppLevel = LevelData.new(pivotPoint, time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, ppLabelText, false, true, extendAllLines, true, false)
        array.push(allLevels, ppLevel)
        
        ppS1Level = LevelData.new(pivotS1, time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "PP-S1", false, true, extendAllLines, true, false)
        array.push(allLevels, ppS1Level)
        
        ppS2Level = LevelData.new(pivotS2, time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "PP-S2", false, true, extendAllLines, true, false)
        array.push(allLevels, ppS2Level)
        
        ppR1Level = LevelData.new(pivotR1, time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "PP-R1", false, true, extendAllLines, true, false)
        array.push(allLevels, ppR1Level)
        
        ppR2Level = LevelData.new(pivotR2, time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "PP-R2", false, true, extendAllLines, true, false)
        array.push(allLevels, ppR2Level)

    // Central Pivot Range - Only show on intraday timeframes
    if centralPivotRangeShow and not na(cprPivotPoint) and showIntradayLevels
        endTime = extendAllLines ? time + (24 * 3600000) : time
        
        cprRange = cprTopCentral - cprBottomCentral
        cprRangeTicks = math.round(cprRange / syminfo.mintick)

        cprPPLabelText = "CPR-PP (" + str.tostring(cprWidthPercent, "#.##") + "%" + ")"

        cprPPLevel = LevelData.new(cprPivotPoint, time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, cprPPLabelText, false, true, extendAllLines, true, false)
        array.push(allLevels, cprPPLevel)
        
        cprBCLevel = LevelData.new(cprBottomCentral, time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "CPR-BC", false, true, extendAllLines, true, false)
        array.push(allLevels, cprBCLevel)
        
        cprTCLevel = LevelData.new(cprTopCentral, time, endTime, marketLevelsColor, marketLevelsStyle, marketLevelsWidth, "CPR-TC", false, true, extendAllLines, true, false)
        array.push(allLevels, cprTCLevel)

    // Session Levels - Only show on appropriate timeframes
    if asiaHighShow and not na(asiaHigh) and not na(asiaHighTime) and showSessionLevels
        endTime = get_line_end_time(asiaHighTime, asiaHighBroken, asiaHighBreakTime, extendAllLines)
        ahLevel = LevelData.new(asiaHigh, asiaHighTime, endTime, asiaHighColor, asiaHighStyle, asiaHighWidth, asiaHighText, asiaHighBroken, false, extendAllLines, false, true)
        array.push(allLevels, ahLevel)

    if asiaLowShow and not na(asiaLow) and not na(asiaLowTime) and showSessionLevels
        endTime = get_line_end_time(asiaLowTime, asiaLowBroken, asiaLowBreakTime, extendAllLines)
        alLevel = LevelData.new(asiaLow, asiaLowTime, endTime, asiaLowColor, asiaLowStyle, asiaLowWidth, asiaLowText, asiaLowBroken, false, extendAllLines, false, false)
        array.push(allLevels, alLevel)

    if londonHighShow and not na(londonHigh) and not na(londonHighTime) and showSessionLevels
        endTime = get_line_end_time(londonHighTime, londonHighBroken, londonHighBreakTime, extendAllLines)
        lhLevel = LevelData.new(londonHigh, londonHighTime, endTime, londonHighColor, londonHighStyle, londonHighWidth, londonHighText, londonHighBroken, false, extendAllLines, false, true)
        array.push(allLevels, lhLevel)

    if londonLowShow and not na(londonLow) and not na(londonLowTime) and showSessionLevels
        endTime = get_line_end_time(londonLowTime, londonLowBroken, londonLowBreakTime, extendAllLines)
        llLevel = LevelData.new(londonLow, londonLowTime, endTime, londonLowColor, londonLowStyle, londonLowWidth, londonLowText, londonLowBroken, false, extendAllLines, false, false)
        array.push(allLevels, llLevel)

    if newYorkHighShow and not na(newYorkHigh) and not na(newYorkHighTime) and showSessionLevels
        endTime = get_line_end_time(newYorkHighTime, newYorkHighBroken, newYorkHighBreakTime, extendAllLines)
        nyhLevel = LevelData.new(newYorkHigh, newYorkHighTime, endTime, newYorkHighColor, newYorkHighStyle, newYorkHighWidth, newYorkHighText, newYorkHighBroken, false, extendAllLines, false, true)
        array.push(allLevels, nyhLevel)

    if newYorkLowShow and not na(newYorkLow) and not na(newYorkLowTime) and showSessionLevels
        endTime = get_line_end_time(newYorkLowTime, newYorkLowBroken, newYorkLowBreakTime, extendAllLines)
        nylLevel = LevelData.new(newYorkLow, newYorkLowTime, endTime, newYorkLowColor, newYorkLowStyle, newYorkLowWidth, newYorkLowText, newYorkLowBroken, false, extendAllLines, false, false)
        array.push(allLevels, nylLevel)

    // Higher timeframe levels - Always show (Weekly, Monthly, Previous Day)
    if weeklyHighShow and not na(weeklyHigh) and not na(weeklyHighTime)
        endTime = get_line_end_time(weeklyHighTime, weeklyHighBroken, weeklyHighBreakTime, extendAllLines)
        whLevel = LevelData.new(weeklyHigh, weeklyHighTime, endTime, weeklyHighColor, weeklyHighStyle, weeklyHighWidth, weeklyHighText, weeklyHighBroken, false, extendAllLines, false, true)
        array.push(allLevels, whLevel)

    if weeklyLowShow and not na(weeklyLow) and not na(weeklyLowTime)
        endTime = get_line_end_time(weeklyLowTime, weeklyLowBroken, weeklyLowBreakTime, extendAllLines)
        wlLevel = LevelData.new(weeklyLow, weeklyLowTime, endTime, weeklyLowColor, weeklyLowStyle, weeklyLowWidth, weeklyLowText, weeklyLowBroken, false, extendAllLines, false, false)
        array.push(allLevels, wlLevel)

    if monthlyHighShow and not na(monthlyHigh) and not na(monthlyHighTime)
        endTime = get_line_end_time(monthlyHighTime, monthlyHighBroken, monthlyHighBreakTime, extendAllLines)
        mhLevel = LevelData.new(monthlyHigh, monthlyHighTime, endTime, monthlyHighColor, monthlyHighStyle, monthlyHighWidth, monthlyHighText, monthlyHighBroken, false, extendAllLines, false, true)
        array.push(allLevels, mhLevel)

    if monthlyLowShow and not na(monthlyLow) and not na(monthlyLowTime)
        endTime = get_line_end_time(monthlyLowTime, monthlyLowBroken, monthlyLowBreakTime, extendAllLines)
        mlLevel = LevelData.new(monthlyLow, monthlyLowTime, endTime, monthlyLowColor, monthlyLowStyle, monthlyLowWidth, monthlyLowText, monthlyLowBroken, false, extendAllLines, false, false)
        array.push(allLevels, mlLevel)

    // Previous Day Levels - Show on intraday timeframes
    if prevDayHighShow and not na(prevDayHigh) and not na(prevDayHighTime) and showIntradayLevels
        endTime = get_line_end_time(prevDayHighTime, prevDayHighBroken, prevDayHighBreakTime, extendAllLines)
        pdhLevel = LevelData.new(prevDayHigh, prevDayHighTime, endTime, prevDayHighColor, prevDayHighStyle, prevDayHighWidth, prevDayHighText, prevDayHighBroken, false, extendAllLines, false, true)
        array.push(allLevels, pdhLevel)

    if prevDayLowShow and not na(prevDayLow) and not na(prevDayLowTime) and showIntradayLevels
        endTime = get_line_end_time(prevDayLowTime, prevDayLowBroken, prevDayLowBreakTime, extendAllLines)
        pdlLevel = LevelData.new(prevDayLow, prevDayLowTime, endTime, prevDayLowColor, prevDayLowStyle, prevDayLowWidth, prevDayLowText, prevDayLowBroken, false, extendAllLines, false, false)
        array.push(allLevels, pdlLevel)

    // All Time High - Always show
    if allTimeHighShow and not na(allTimeHigh) and not na(allTimeHighTime)
        endTime = get_line_end_time(allTimeHighTime, allTimeHighBroken, allTimeHighBreakTime, extendAllLines)
        athLevel = LevelData.new(allTimeHigh, allTimeHighTime, endTime, allTimeHighColor, allTimeHighStyle, allTimeHighWidth, allTimeHighText, allTimeHighBroken, false, extendAllLines, false, true)
        array.push(allLevels, athLevel)

    combinedLevels = combine_levels_at_same_price(allLevels)

    if array.size(combinedLevels) > 0
        for i = 0 to array.size(combinedLevels) - 1
            level = array.get(combinedLevels, i)
            
            levelLine = line(na)
            
            if level.isMarketLevel
                levelLine := create_market_level_line(level.startTime, level.endTime, level.price, level.levelColor, level.levelStyle, level.levelWidth, level.shouldExtend)
            else
                levelLine := create_time_line(level.startTime, level.endTime, level.price, level.levelColor, level.levelStyle, level.levelWidth, level.shouldExtend)
            
            array.push(allLines, levelLine)
            
            levelLabel = create_combined_label(level.price, level.labelText, level.levelColor, level.startTime, level.endTime, level.isBroken, level.isSessionOpen, level.isMarketLevel, level.isHighLevel)
            if not na(levelLabel)
                array.push(allLabels, levelLabel)

//=============================================================================
// DAYS OF WEEK DISPLAY - Filtered by timeframe
//=============================================================================
// Days of week labels using global settings - only show on appropriate timeframes
finalDOWColor = useGlobalTextColor ? color.new(globalColor, 50) : color.new(color.gray, 50)
showDOWLabels = showDaysOfWeek and (not autoSimplifyOnHTF or should_show_intraday_details())

plotshape(showDOWLabels ? hour(time, timezoneToUse) == 9 and minute(time, timezoneToUse) == 0 and dayofweek == dayofweek.sunday : false, text='Sunday', style=shape.circle, color=na, textcolor=finalDOWColor, location=location.bottom, size=size.tiny, offset=0)
plotshape(showDOWLabels ? hour(time, timezoneToUse) == 9 and minute(time, timezoneToUse) == 0 and dayofweek == dayofweek.monday : false, text='Monday', style=shape.circle, color=na, textcolor=finalDOWColor, location=location.bottom, size=size.tiny, offset=0)
plotshape(showDOWLabels ? hour(time, timezoneToUse) == 9 and minute(time, timezoneToUse) == 0 and dayofweek == dayofweek.tuesday : false, text='Tuesday', style=shape.circle, color=na, textcolor=finalDOWColor, location=location.bottom, size=size.tiny, offset=0)
plotshape(showDOWLabels ? hour(time, timezoneToUse) == 9 and minute(time, timezoneToUse) == 0 and dayofweek == dayofweek.wednesday : false, text='Wednesday', style=shape.circle, color=na, textcolor=finalDOWColor, location=location.bottom, size=size.tiny, offset=0)
plotshape(showDOWLabels ? hour(time, timezoneToUse) == 9 and minute(time, timezoneToUse) == 0 and dayofweek == dayofweek.thursday : false, text='Thursday', style=shape.circle, color=na, textcolor=finalDOWColor, location=location.bottom, size=size.tiny, offset=0)
plotshape(showDOWLabels ? hour(time, timezoneToUse) == 9 and minute(time, timezoneToUse) == 0 and dayofweek == dayofweek.friday : false, text='Friday', style=shape.circle, color=na, textcolor=finalDOWColor, location=location.bottom, size=size.tiny, offset=0)
plotshape(showDOWLabels ? hour(time, timezoneToUse) == 9 and minute(time, timezoneToUse) == 0 and dayofweek == dayofweek.saturday : false, text='Saturday', style=shape.circle, color=na, textcolor=finalDOWColor, location=location.bottom, size=size.tiny, offset=0)
````
