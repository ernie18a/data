# News

- url: https://www.tradingview.com/script/NkWqoYvw/
- type: indicator
- pine_id: PUB;ea62e746d09a4345a34da30fb7b82f98
- version: 3.0

## Description

Live Economic Calendar with High/Low Levels
This indicator is based on the news framework by toodegrees. My thanks go to toodegrees for providing the open-source code that serves as the foundation for this extension.

Features:
News High/Low Levels: The indicator marks the high and low points of the candles where news events occur. These levels remains active on the chart until they are breached by price or exceed the defined maximum duration (in days).

Optimized User Interface: The UI is designed to be space-saving (with many settings placed inline) to improve clarity within the indicator settings menu.

Timezone Adjustment: Support for various timezones (e.g., Europe/Berlin) to synchronize event times with your local time.

Design Options: Colors, line styles (Solid, Dashed, Dotted), and text sizes for the news levels can be customized individually.

Filters: News can be filtered by impact (High, Medium, Low) as well as by currency. An automatic mode for the current chart symbol is integrated.

Credits:
The core logic for retrieving economic data is based on the work of toodegrees. This version extends the original by adding visual price levels and a more compact menu navigation.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Original News indicator © toodegrees
// A sincere thank you to toodegrees for this excellent open-source contribution!
// © 2025 kp_eu_de
// Released under the MIT License

// -----------------------------------------------------------------------------------------------
// Credits & Open Source Collaboration:
// The News section of this indicator is based on the framework by toodegrees. 
// My sincere thanks go to toodegrees for providing the excellent open-source code that serves 
// as the foundation for this extension. This custom extension expands the original functionality, 
// which highlights the news candle using lines and points, by adding horizontal lines that mark 
// and track the extreme points (highs and lows) of the news candle directly within the chart area.
//
// Der Indikators basiert auf dem Framework von toodegrees. 
// Mein herzlicher Dank geht an toodegrees für die Bereitstellung des hervorragenden Open-Source-Codes, 
// der als Grundlage dient. Die ursprüngliche Version markiert die Newskerze 
// bereits mit Linien und Punkten. Ich habe diesen Code um zusätzliche historische Linien erweitert, 
// um die Extrempunkte (Hochs und Tiefs) der Newskerze direkt im aktuellen Chartbereich 
// sichtbar zu machen, um sie präzise verfolgen zu können.
// -----------------------------------------------------------------------------------------------

import toodegrees/forex_factory_utility/14 as ffUtil
import toodegrees/forex_factory_decoding/27 as ffDec

//@version=5
indicator("Original News indicator © toodegrees Modified"
         , shorttitle="News"
         , overlay=true
         , max_lines_count=500
         , max_labels_count=500)

//#region[Timeframe Limitations]
if timeframe.in_seconds(timeframe.period)>86400
    runtime.error("Go to the Daily Timeframe or lower!")
else if timeframe.in_seconds(timeframe.period)<30
    runtime.error("Go to the 30-Second Timeframe or higher!")
//#endregion

//#region[Global, Functions, Methods]
var mdnCheck = false
if hour(time,"America/New_York")==0 and hour(time[1],"America/New_York")!=0 and not mdnCheck
    mdnCheck := true
newDay = mdnCheck ? hour(time,"America/New_York")==0 and hour(time[1],"America/New_York")!=0 : timeframe.change("D")

requestData() =>
    [request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_1",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_2",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_3",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_4",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_5",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_6",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_7",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_8",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume)),
     request.seed("seed_toodegrees_toogit","TOODEGREES_FOREX_FACTORY_SLOT_9",str.tostring(open)+","+str.tostring(high)+","+str.tostring(low)+","+str.tostring(close)+","+str.tostring(volume))]

method processData(ffUtil.News[] N, string S1, string S2, string S3, string S4, string S5, string S6, string S7, string S8, string S9) =>
    ffDec.readNews(N,S1), ffDec.readNews(N,S2), ffDec.readNews(N,S3)
    ffDec.readNews(N,S4), ffDec.readNews(N,S5), ffDec.readNews(N,S6)
    ffDec.readNews(N,S7), ffDec.readNews(N,S8), ffDec.readNews(N,S9)
//#endregion

//#region[User Input & Styles]
selectedTz = input.string("Europe/Berlin", title="Timezone", options=["Europe/Berlin", "Europe/London", "America/New_York", "UTC"], group="Timezone Settings")

var high_impact = input.bool(true, title="🔴 High", group="Impact & Currencies", inline="1")
var med_impact  = input.bool(true, title="🟠 Mid", group="Impact & Currencies", inline="1")
var low_impact  = input.bool(false, title="🟡 Low", group="Impact & Currencies", inline="1")
var holiday     = input.bool(false, title="⚪ Hol", group="Impact & Currencies", inline="1")

var AUTO = input.bool(true , title="Auto?", group="Impact & Currencies", inline="2")
var AUD  = input.bool(false, title="AUD", group="Impact & Currencies", inline="2")
var CAD  = input.bool(false, title="CAD", group="Impact & Currencies", inline="2")
var CHF  = input.bool(false, title="CHF", group="Impact & Currencies", inline="2")
var CNY  = input.bool(false, title="CNY", group="Impact & Currencies", inline="2")
var EUR  = input.bool(false, title="EUR", group="Impact & Currencies", inline="3")
var GBP  = input.bool(false, title="GBP", group="Impact & Currencies", inline="3")
var JPY  = input.bool(false, title="JPY", group="Impact & Currencies", inline="3")
var NZD  = input.bool(false, title="NZD", group="Impact & Currencies", inline="3")
var USD  = input.bool(false, title="USD", group="Impact & Currencies", inline="3")

groupStyle = "Styling News Lines & Text"
colorHigh  = input.color(color.green, "High", group=groupStyle, inline="H")
styleHigh  = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle, inline="H")
colorLow   = input.color(color.red, "Low ", group=groupStyle, inline="L")
styleLow   = input.string("Solid", "Style", options=["Solid", "Dashed", "Dotted"], group=groupStyle, inline="L")
textColor  = input.color(color.gray, "Text ", group=groupStyle, inline="T")
textSize   = input.string("Small", "Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupStyle, inline="T")

var onChartT   = input.string("This Week", title="History", group="News On Chart", options=["Today", "This Week", "Manual"], inline="C1")
var onChartLB  = input.int(30, title="Days", group="News On Chart", inline="C1")
var showLabels = input.bool(true, title="Impact Symbols?", group="News On Chart", inline="C2")
var labelS     = ffUtil.size(input.string("Normal", title="Size", group="News On Chart", options=["Tiny", "Small", "Normal", "Large", "Huge"], inline="C2"))
var labelY     = input.string("Auto", title="Pos", group="News On Chart", options=["Above", "Below", "Auto"], inline="C3")
var lblOutLn   = input.bool(true, title="Outline?", group="News On Chart", inline="C3")

var showTable = input.bool(false, title="Table?", group="News Table", inline="Tab")
var tableX    = input.string("Right", title="X", group="News Table", options=["Left", "Center", "Right" ], inline="Tab")
var tableY    = input.string("Bottom", title="Y", group="News Table", options=["Top" , "Middle", "Bottom"], inline="Tab")

showDate      = input.bool(true, "Date?", group="Extension", inline="Ext")
showTime      = input.bool(true, "Time?", group="Extension", inline="Ext")
maxDays       = input.int(3, "Max Days", group="Extension", inline="Ext")

getLineStyle(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
getTextSize(s)  => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal
tzOffset = selectedTz == "Europe/Berlin" ? 1 : selectedTz == "Europe/London" ? 0 : selectedTz == "America/New_York" ? -5 : 0
//#endregion

//#region[Import & Processing]
var currWeek = array.new<ffUtil.News>()
var nextWeek = array.new<ffUtil.News>()
var currDay  = array.new<ffUtil.News>()

[slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9] = requestData()

if timeframe.change("W")
    nextWeek := ffUtil.bubbleSort_News(nextWeek)
    nextWeek := ffUtil.adjustTimezone(nextWeek, tzOffset, 0)
    currWeek := nextWeek.copy()
    currWeek := ffUtil.weekNews(currWeek,ffUtil.curFilter(AUTO,AUD,CAD,CHF,CNY,EUR,GBP,JPY,NZD,USD),ffUtil.impFilter(holiday,low_impact,med_impact,high_impact))
    nextWeek.clear()
if newDay
    currDay.clear()
    currDay := ffUtil.todayNews(currWeek,currDay,mdnCheck)
nextWeek.processData(slot1,slot2,slot3,slot4,slot5,slot6,slot7,slot8,slot9)

f_deduplicateNews(newsArray) =>
    uniqueNews = array.new<ffUtil.News>()
    if array.size(newsArray) > 0
        for i = 0 to array.size(newsArray) - 1
            currentEvent = array.get(newsArray, i)
            duplicateFound = false
            if array.size(uniqueNews) > 0
                for j = 0 to array.size(uniqueNews) - 1
                    existingEvent = array.get(uniqueNews, j)
                    if currentEvent.tmst == existingEvent.tmst and currentEvent.ttl == existingEvent.ttl
                        duplicateFound := true
                        break
            if not duplicateFound
                array.push(uniqueNews, currentEvent)
    uniqueNews
//#endregion

//#region[Drawings: Table & Original Markers]
var _table = ffUtil.newTable(ffUtil.boxLoc(tableX, tableY))
if showTable and currWeek.size() > 0
    deduped = f_deduplicateNews(onChartT == "Today" ? currDay : currWeek)
    _table := ffUtil.FF_Table(deduped, ffUtil.boxLoc(tableX, tableY), "Small", #dee1e9, #283c70, #000000, #dee1e9)
    ffUtil.timeline(deduped, _table, #787b86, tzOffset, 0)
else
    _table.delete()

// Zeichnet die Linien und Punkte (Zukunft und Vergangenheit)
if onChartT != "Today" and timeframe.change("W")
    ffUtil.FF_OnChartLine(currWeek, ffUtil.lineTrnsp("Heavy"), ffUtil.lineStyle("Solid"))
else if onChartT == "Today" and newDay
    ffUtil.FF_OnChartLine(currDay, ffUtil.lineTrnsp("Heavy"), ffUtil.lineStyle("Solid"))

if showLabels
    ffUtil.FF_OnChartLabel(currWeek,labelY,labelS,lblOutLn)


if barstate.islast
    allLines = line.all
    if array.size(allLines) > 0
        for i = array.size(allLines) - 1 to 0
            ln = array.get(allLines, i)
            x1 = line.get_x1(ln)
            // Nur zeitbasierte vertikale Linien (Zeitstempel-Bereich)
            if x1 > 1000000000000 and line.get_y1(ln) != line.get_y2(ln)
                if x1 < time 
                    line.delete(ln)
//#endregion

//#region[Extension: High/Low Lines]
type NewsLevel
    line ln
    label lbl
    float val
    bool isHigh
    int startBar
    int startTime
    bool broken
    int breakTime

var activeLevels = array.new<NewsLevel>()
barLen = timeframe.in_seconds(timeframe.period) * 1000

isNewsBar = false
int newsTimestamp = 0
newsArrayForLines = onChartT == "Today" ? currDay : currWeek
if array.size(newsArrayForLines) > 0
    for i = 0 to array.size(newsArrayForLines) - 1
        ev = array.get(newsArrayForLines, i)
        if ev.tmst >= time and ev.tmst < (time + barLen)
            isNewsBar := true
            newsTimestamp := ev.tmst
            break

var int lastNewsBarIndex = -1
if isNewsBar and bar_index > lastNewsBarIndex
    lastNewsBarIndex := bar_index
    
    dtPart = showDate ? str.format_time(newsTimestamp, "dd.MM", selectedTz) : ""
    tmPart = showTime ? str.format_time(newsTimestamp, "HH:mm", selectedTz) : ""
    extraInfo = " (" + dtPart + (dtPart != "" and tmPart != "" ? " " : "") + tmPart + ")"
    
    lnH = line.new(bar_index, high, bar_index, high, color=colorHigh, width=1, style=getLineStyle(styleHigh))
    lbH = label.new(bar_index, high, "news high" + extraInfo, style=label.style_none, textcolor=textColor, size=getTextSize(textSize), textalign=text.align_left)
    array.push(activeLevels, NewsLevel.new(lnH, lbH, high, true, bar_index, time, false, 0))
    
    lnL = line.new(bar_index, low, bar_index, low, color=colorLow, width=1, style=getLineStyle(styleLow))
    lbL = label.new(bar_index, low, "news low" + extraInfo, style=label.style_none, textcolor=textColor, size=getTextSize(textSize), textalign=text.align_left)
    array.push(activeLevels, NewsLevel.new(lnL, lbL, low, false, bar_index, time, false, 0))

if array.size(activeLevels) > 0
    for i = array.size(activeLevels) - 1 to 0
        lvl = array.get(activeLevels, i)
        if not lvl.broken
            line.set_x2(lvl.ln, bar_index)
            label.set_x(lvl.lbl, bar_index)
            if bar_index > lvl.startBar
                if (lvl.isHigh and high > lvl.val) or (not lvl.isHigh and low < lvl.val)
                    lvl.broken := true
                    lvl.breakTime := time
                    label.set_text(lvl.lbl, "") 
            if (time - lvl.startTime) / 86400000 >= maxDays
                line.delete(lvl.ln), label.delete(lvl.lbl), array.remove(activeLevels, i)
        else if dayofmonth(time) != dayofmonth(lvl.breakTime) and time > lvl.breakTime
            line.delete(lvl.ln), label.delete(lvl.lbl), array.remove(activeLevels, i)
//#endregion

//Log: Bug Fix (26.05.2026)
//Issue: Incorrect barLen calculation via previous bar time difference caused erroneous news line creation on gap candles.
//Fix: Changed barLen to a static calculation based on the current timeframe (timeframe.in_seconds() * 1000).
//Result: Precise line generation strictly limited to the correct news candle.
````
