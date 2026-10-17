# Multi Session High/Low (SYC)

- url: https://www.tradingview.com/script/dXUUHXqJ/
- type: indicator
- pine_id: PUB;7203ca0ac35047398ef84810be387133
- version: 1.0

## Description

This high performance TradingView indicator automatically tracks and plots the High and Low price levels for the Asia, London, and New York trading sessions.

## Source Code

````pine
//@version=6
indicator("Multi-Session High/Low (Live & Clean)", overlay=true, max_lines_count=500)

// --- General Settings ---
var string G_GEN = "General Settings"
sessionTz    = input.string("America/New_York", "Timezone for all Sessions", options=["Exchange", "UTC", "America/New_York", "Europe/London", "Europe/Berlin"], group=G_GEN)
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=G_GEN)

// --- Asia Session Settings ---
var string G_ASIA = "Asia Session"
asiaSess     = input.session("0000-0900", "Asia Time Window", group=G_ASIA)
asiaHighCol  = input.color(color.blue, "Asia High Color", group=G_ASIA)
asiaLowCol   = input.color(color.blue, "Asia Low Color", group=G_ASIA)
asiaWidth    = input.int(2, "Asia Line Width", minval=1, maxval=5, group=G_ASIA)

// --- London Session Settings ---
var string G_LON = "London Session"
lonSess      = input.session("0800-1700", "London Time Window", group=G_LON)
lonHighCol   = input.color(color.green, "London High Color", group=G_LON)
lonLowCol    = input.color(color.green, "London Low Color", group=G_LON)
lonWidth     = input.int(2, "London Line Width", minval=1, maxval=5, group=G_LON)

// --- New York Session Settings ---
var string G_NY = "New York Session"
nySess       = input.session("1300-2200", "New York Time Window", group=G_NY)
nyHighCol    = input.color(color.orange, "New York High Color", group=G_NY)
nyLowCol     = input.color(color.orange, "New York Low Color", group=G_NY)
nyWidth      = input.int(2, "New York Line Width", minval=1, maxval=5, group=G_NY)

// Timezone Assignment
tz = sessionTz == "Exchange" ? syminfo.timezone : sessionTz

// --- Data Structures for Tracking ---
type TrackedLine
    line  ln
    float yVal
    bool  isBroken
    int   startBar

type SessionData
    string        timeWindow
    color         hiColor
    color         loColor
    int           lineWidth
    TrackedLine[] hiLines
    TrackedLine[] loLines
    float         hiVal
    float         loVal
    int           startBar

// --- Core Method for Logic ---
method process(SessionData s, string tz, string lStyle) =>
    inS = not na(time(timeframe.period, s.timeWindow + ":1234567", tz))
    newS = inS and not inS[1]
    style = lStyle == "Dashed" ? line.style_dashed : lStyle == "Dotted" ? line.style_dotted : line.style_solid
    
    if newS
        s.hiVal := high
        s.loVal := low
        s.startBar := bar_index
        
        // Create new lines
        TrackedLine nH = TrackedLine.new(line.new(bar_index, high, bar_index, high, color=s.hiColor, width=s.lineWidth, style=style), high, false, bar_index)
        TrackedLine nL = TrackedLine.new(line.new(bar_index, low, bar_index, low, color=s.loColor, width=s.lineWidth, style=style), low, false, bar_index)
        
        array.unshift(s.hiLines, nH)
        array.unshift(s.loLines, nL)
        
        // Strictly limit tracking to the last 3 sessions
        if array.size(s.hiLines) > 3
            TrackedLine oH = array.pop(s.hiLines)
            line.delete(oH.ln)
        if array.size(s.loLines) > 3
            TrackedLine oL = array.pop(s.loLines)
            line.delete(oL.ln)
            
    else if inS
        if high > s.hiVal
            s.hiVal := high
        if low < s.loVal
            s.loVal := low

    // Monitoring High Lines (Delete on Touch)
    if array.size(s.hiLines) > 0
        for i = 0 to array.size(s.hiLines) - 1
            TrackedLine tl = array.get(s.hiLines, i)
            if not tl.isBroken
                if i == 0 and inS
                    tl.yVal := s.hiVal
                    line.set_xy1(tl.ln, s.startBar, tl.yVal)
                    line.set_xy2(tl.ln, bar_index, tl.yVal)
                else
                    if high >= tl.yVal
                        line.delete(tl.ln)
                        tl.isBroken := true
                    else
                        line.set_x2(tl.ln, bar_index)
            continue 

    // Monitoring Low Lines (Delete on Touch)
    if array.size(s.loLines) > 0
        for i = 0 to array.size(s.loLines) - 1
            TrackedLine tl = array.get(s.loLines, i)
            if not tl.isBroken
                if i == 0 and inS
                    tl.yVal := s.loVal
                    line.set_xy1(tl.ln, s.startBar, tl.yVal)
                    line.set_xy2(tl.ln, bar_index, tl.yVal)
                else
                    if low <= tl.yVal
                        line.delete(tl.ln)
                        tl.isBroken := true
                    else
                        line.set_x2(tl.ln, bar_index)
            continue 

// --- Create Instances ---
var asiaData = SessionData.new(asiaSess, asiaHighCol, asiaLowCol, asiaWidth, array.new<TrackedLine>(), array.new<TrackedLine>(), na, na, na)
var lonData  = SessionData.new(lonSess, lonHighCol, lonLowCol, lonWidth, array.new<TrackedLine>(), array.new<TrackedLine>(), na, na, na)
var nyData   = SessionData.new(nySess, nyHighCol, nyLowCol, nyWidth, array.new<TrackedLine>(), array.new<TrackedLine>(), na, na, na)

// Real-time synchronization of menu inputs
asiaData.timeWindow := asiaSess, asiaData.hiColor := asiaHighCol, asiaData.loColor := asiaLowCol, asiaData.lineWidth := asiaWidth
lonData.timeWindow  := lonSess,  lonData.hiColor  := lonHighCol,  lonData.loColor  := lonLowCol,  lonData.lineWidth  := lonWidth
nyData.timeWindow   := nySess,   nyData.hiColor   := nyHighCol,   nyData.loColor   := nyLowCol,   nyData.lineWidth   := nyWidth

// --- Execution ---
asiaData.process(tz, lineStyleInput)
lonData.process(tz, lineStyleInput)
nyData.process(tz, lineStyleInput)
````
