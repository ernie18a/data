# JJ VWAP Sessions

- url: https://www.tradingview.com/script/fx1de2me-JJ-VWAP-Sessions/
- type: indicator
- pine_id: PUB;b9daea651b2f40d08cd2704b050a63c7
- version: 5.0

## Description

This indicator is helpful for futures trading to show different session anchored VWAPs and how price is reacting to each. You can show/hide the following session lines and labels:

[list]
[*] Day VWAP
[*] Asia Session VWAP
[*] London Session VWAP
[*] New York Session VWAP
[*] Week VWAP
[*] Month VWAP
[*] Quarter VWAP
[*] Year VWAP
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Media-Driven

//@version=6
indicator("JJ VWAP Sessions", overlay = true)
 
 
/// Session Times
asiaSession   = input.session("1900-0400", "Asia Session (NY)")
londonSession = input.session("0300-1130", "London Session (NY)")
nySession     = input.session("0930-1600", "NY Session (NY)")
newDay = ta.change(time("D")) != 0
newWeek = ta.change(time("W")) != 0
newMonth = ta.change(time("M")) != 0
newQuarter = ta.change(time("3M")) != 0
newYear = ta.change(time("12M")) != 0


/// Labels
showlabels = input.bool(true, "Show Labels", group = "Labels")
label_position = input.int(title = 'Label Position', defval = 10, minval = 0, maxval = 50, tooltip = 'When increasing number, labels move right', group = "Labels")

/// VWAPs
showvwap = input.bool(true, "Show VWAP", group = "VWAP Sessions")
showvwapa = input.bool(true, "Show Asia VWAP", group = "VWAP Sessions")
showvwapl = input.bool(true, "Show London VWAP", group = "VWAP Sessions")
showvwapn = input.bool(true, "Show NY VWAP", group = "VWAP Sessions")
showvwapw = input.bool(false, "Show Week VWAP", group = "VWAP Sessions")
showvwapm = input.bool(false, "Show Month VWAP", group = "VWAP Sessions")
showvwapq = input.bool(false, "Show Quarter VWAP", group = "VWAP Sessions")
showvwapy = input.bool(false, "Show Year VWAP", group = "VWAP Sessions")

plotCrosses = input.bool(true, "Show Touch Characters", group = "Touch Settings")
sourceInput = input.string("High/Low", "Touch Type", options = ["High/Low", "Open/Close"], group="Touch Settings")



/// PREVIOUS SESSION SETTINGS
showPrevSessions = input.bool(true, "Show Previous Session VWAPs", group = "Previous VWAPs", tooltip = "Show previous Asia, London, New York, and daily session close VWAP")
previousSessions = input.int(2, "Previous Sessions To Show", minval = 1, maxval = 20, group = "Previous VWAPs")


/// Colors
color = input.color(color.new(color.white, 0), title="VWAP Color", group="Color Settings")
colora = input.color(color.new(color.red, 0), title="Asia VWAP Color", group="Color Settings")
colorl = input.color(color.new(color.orange, 0), title="London VWAP Color", group="Color Settings")
colorn = input.color(color.new(color.green, 0), title="NY VWAP Color", group="Color Settings")
colorw = input.color(color.new(color.blue, 0), title="Week VWAP Color", group="Color Settings")
colorm = input.color(color.new(color.purple, 0), title="Month VWAP Color", group="Color Settings")
colorq = input.color(color.new(color.fuchsia, 0), title="Quarter VWAP Color", group="Color Settings")
colory = input.color(color.new(color.gray, 0), title="Year VWAP Color", group="Color Settings")


/// VWAP TOUCH FUNCTION

f_vwapCross(vwapValue, crossType) =>

    bool crossed = false

    if crossType == "High/Low"

        crossed :=
             high >= vwapValue and
             low <= vwapValue

    else

        crossed :=
             vwapValue >= math.min(open, close) and
             vwapValue <= math.max(open, close)

    crossed


/// Session VWAP Function
f_sessionVWAP(sess) =>
    inSession = not na(time(timeframe.period, sess, "America/New_York"))
    newSession = inSession and not inSession[1]

    var float cumPV = na
    var float cumVol = na

    if newSession
        cumPV := hlc3 * volume
        cumVol := volume
    else if inSession
        cumPV += hlc3 * volume
        cumVol += volume

    vwap = cumVol != 0 ? cumPV / cumVol : na
    vwap

/// Session VWAP
asiaVWAP = f_sessionVWAP(asiaSession)
londonVWAP = f_sessionVWAP(londonSession)
nyVWAP  = f_sessionVWAP(nySession)
VWAP = ta.vwap(hlc3)


wVWAP = ta.vwap(hlc3,newWeek)
mVWAP = ta.vwap(hlc3,newMonth)
qVWAP = ta.vwap(hlc3,newQuarter)
yVWAP = ta.vwap(hlc3,newYear)


/// Plot
plot(showvwapa ? asiaVWAP : na,   color=colora,   linewidth=2, title="Asia VWAP")
plot(showvwapl ? londonVWAP : na, color=colorl, linewidth=2, title="London VWAP")
plot(showvwapn ? nyVWAP : na,     color=colorn,  linewidth=2, title="NY VWAP")
plot(showvwap ? VWAP : na,     color=color,  linewidth=2, title="Daily VWAP")

plot(showvwapw ? wVWAP : na,     color=colorw,  linewidth=2, title="Daily VWAP")
plot(showvwapm ? mVWAP : na,     color=colorm,  linewidth=2, title="Daily VWAP")
plot(showvwapq ? qVWAP : na,     color=colorq,  linewidth=2, title="Daily VWAP")
plot(showvwapy ? yVWAP : na,     color=colory,  linewidth=2, title="Daily VWAP")

 
/// Labels
if showlabels
    if showvwap
        label vwapl = label.new(bar_index + label_position, VWAP, 'VWAP', style = label.style_none, textcolor = color.new(color,50), size = size.normal, textalign = text.align_left)
        label.delete(vwapl[1])
    if showvwapa
        label vwapal = label.new(bar_index + label_position, asiaVWAP, 'Asia VWAP', style = label.style_none, textcolor = color.new(colora,50), size = size.normal, textalign = text.align_left)
        label.delete(vwapal[1])
    if showvwapl
        label vwapll = label.new(bar_index + label_position, londonVWAP, 'London VWAP', style = label.style_none, textcolor = color.new(colorl,50), size = size.normal, textalign = text.align_left)
        label.delete(vwapll[1])
    if showvwapn
        label vwapnl = label.new(bar_index + label_position, nyVWAP, 'NY VWAP', style = label.style_none, textcolor = color.new(colorn,50), size = size.normal, textalign = text.align_left)
        label.delete(vwapnl[1])
    if showvwapw
        label vwapwl = label.new(bar_index + label_position, wVWAP, 'Week VWAP', style = label.style_none, textcolor = color.new(colorw,50), size = size.normal, textalign = text.align_left)
        label.delete(vwapwl[1])
    if showvwapm
        label vwapml = label.new(bar_index + label_position, mVWAP, 'Month VWAP', style = label.style_none, textcolor = color.new(colorm,50), size = size.normal, textalign = text.align_left)
        label.delete(vwapml[1])
    if showvwapq
        label vwapql = label.new(bar_index + label_position, qVWAP, 'Quarter VWAP', style = label.style_none, textcolor = color.new(colorq,50), size = size.normal, textalign = text.align_left)
        label.delete(vwapql[1])
    if showvwapy
        label vwapyl = label.new(bar_index + label_position, yVWAP, 'Year VWAP', style = label.style_none, textcolor = color.new(colory,50), size = size.normal, textalign = text.align_left)
        label.delete(vwapyl[1])
    



/// SESSION STATES
asiaInSession   = not na(time(timeframe.period, asiaSession, "America/New_York"))
londonInSession = not na(time(timeframe.period, londonSession, "America/New_York"))
nyInSession     = not na(time(timeframe.period, nySession, "America/New_York"))

/// NEW SESSION DETECTION
asiaNewSession   = asiaInSession and not asiaInSession[1]
londonNewSession = londonInSession and not londonInSession[1]
nyNewSession     = nyInSession and not nyInSession[1]

/// ARRAYS TO STORE LINES
var line[] asiaLines = array.new_line()
var line[] londonLines = array.new_line()
var line[] nyLines = array.new_line()
var line[] dLines = array.new_line()

// Update stored line styles
f_updateLineStyles(linesArray, baseColor) =>

    for i = 0 to array.size(linesArray) - 1

        l = array.get(linesArray, i)

        // Most recent line
        if i == 0
            line.set_width(l, 2)
            line.set_color(l, color.new(baseColor, 0))

        // Older lines
        else
            line.set_width(l, 1)
            line.set_color(l, color.new(baseColor, 0))

        
/// STORE PREVIOUS ASIA VWAPS
if asiaNewSession and not na(asiaVWAP[1]) and showPrevSessions and showvwapa

    asiaLine = line.new(
         bar_index,
         asiaVWAP[1],
         bar_index,
         asiaVWAP[1],
         extend = extend.none,
         color = colora,
         width = 2,
         style = line.style_dotted)

    array.unshift(asiaLines, asiaLine)

    if array.size(asiaLines) > previousSessions
        oldLine = array.pop(asiaLines)
        line.delete(oldLine)

    f_updateLineStyles(asiaLines, colora)

// UPDATE PREVIOUS VWAP LINES TO CURRENT BAR

if array.size(asiaLines) > 0

    for i = 0 to array.size(asiaLines) - 1

        l = array.get(asiaLines, i)

        line.set_x2(l, bar_index)


/// STORE PREVIOUS LONDON VWAPS
if londonNewSession and not na(londonVWAP[1]) and showPrevSessions and showvwapl

    londonLine = line.new(
         bar_index,
         londonVWAP[1],
         bar_index,
         londonVWAP[1],
         extend = extend.none,
         color = colorl,
         width = 2,
         style = line.style_dotted)

    array.unshift(londonLines, londonLine)

    if array.size(londonLines) > previousSessions
        oldLine = array.pop(londonLines)
        line.delete(oldLine)

    f_updateLineStyles(londonLines, colorl)


// UPDATE PREVIOUS VWAP LINES TO CURRENT BAR

if array.size(londonLines) > 0

    for i = 0 to array.size(londonLines) - 1

        l = array.get(londonLines, i)

        line.set_x2(l, bar_index)


/// STORE PREVIOUS NY VWAPS
if nyNewSession and not na(nyVWAP[1]) and showPrevSessions and showvwapn

    nyLine = line.new(
         bar_index,
         nyVWAP[1],
         bar_index,
         nyVWAP[1],
         extend = extend.none,
         color = colorn,
         width = 2,
         style = line.style_dotted)

    array.unshift(nyLines, nyLine)

    if array.size(nyLines) > previousSessions
        oldLine = array.pop(nyLines)
        line.delete(oldLine)

    f_updateLineStyles(nyLines, colorn)


// UPDATE PREVIOUS VWAP LINES TO CURRENT BAR

if array.size(nyLines) > 0

    for i = 0 to array.size(nyLines) - 1

        l = array.get(nyLines, i)

        line.set_x2(l, bar_index)


/// STORE PREVIOUS NY VWAPS
if newDay and not na(VWAP[1]) and showPrevSessions and showvwap

    dLine = line.new(
         bar_index,
         VWAP[1],
         bar_index,
         VWAP[1],
         extend = extend.none,
         color = color,
         width = 2,
         style = line.style_dotted)

    array.unshift(dLines, dLine)

    if array.size(dLines) > previousSessions
        oldLine = array.pop(dLines)
        line.delete(oldLine)

    f_updateLineStyles(dLines, color)


// UPDATE PREVIOUS VWAP LINES TO CURRENT BAR

if array.size(dLines) > 0

    for i = 0 to array.size(dLines) - 1

        l = array.get(dLines, i)

        line.set_x2(l, bar_index)


/// Alerts

/// Daily
dvwapcross = f_vwapCross(VWAP, sourceInput)
alertcondition(dvwapcross, title='VWAP Touch', message="VWAP Touch")
plotshape(showvwap and plotCrosses and dvwapcross ? VWAP : na, "Bullish Entry", shape.circle, location.absolute, color.new(color, 0), size=size.small, force_overlay = true, display=display.pane)

/// Asia
asiavwapcross = f_vwapCross(asiaVWAP, sourceInput)
alertcondition(asiavwapcross, title='Asia VWAP Touch', message="Asia VWAP Touch")
plotshape(showvwapa and plotCrosses and asiavwapcross ? asiaVWAP : na, "Bullish Entry", shape.circle, location.absolute, color.new(colora, 0), size=size.small, force_overlay = true, display=display.pane)

/// London
//londonvwapcross = (sourceInput > londonVWAP and sourceInput[1] < londonVWAP[1]) or (sourceInput < londonVWAP and sourceInput[1] > londonVWAP[1])
londonvwapcross = f_vwapCross(londonVWAP, sourceInput)
alertcondition(londonvwapcross, title='London VWAP Touch', message="London VWAP Touch")
plotshape(showvwapl and plotCrosses and londonvwapcross ? londonVWAP : na, "Bullish Entry", shape.circle, location.absolute, color.new(colorl, 0), size=size.small, force_overlay = true, display=display.pane)

/// NY
nyvwapcross = f_vwapCross(nyVWAP, sourceInput)
alertcondition(nyvwapcross, title='NY VWAP Touch', message="NY VWAP Touch")
plotshape(showvwapn and plotCrosses and nyvwapcross ? nyVWAP : na, "Bullish Entry", shape.circle, location.absolute, color.new(colorn, 0), size=size.small, force_overlay = true, display=display.pane)
````
