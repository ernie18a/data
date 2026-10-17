# Reyna_Session_Levels

- url: https://www.tradingview.com/script/7HhD64YV-Reyna-Session-Levels/
- type: indicator
- pine_id: PUB;6e35c8fcd2eb44d7b658ad473ea3dc16
- version: 1.0

## Description

🌍 REYNA SESSION LEVELS — Asia, London & New York H/L/Eq

A minimalist overlay tool that plots the Highs, Lows, and 
Equilibriums (midpoints) of the three major global trading 
sessions — Asia, London, and New York. Includes automatic 
liquidity sweep detection when price wicks through a stored 
session level and closes back.

Built for traders who understand that session extremes are 
NOT the same as static support/resistance — they are 
time-bound narrative anchors that carry liquidity weight 
and get hunted by smart money.

═══════════════════════════════════════════════════════════

WHY SESSION LEVELS MATTER

Every session's high and low tells a story:
- Asia's high is the ceiling Asian traders couldn't break
- London's high is whether London respected or violated Asia's boundary  
- New York's high is the American verdict on London's move

These aren't just price levels — they are decisions made by 
different institutional regions at different times. When 
price returns to them, it's often to hunt the liquidity 
sitting just beyond, because retail stop orders cluster at 
these obvious levels.

The equilibrium (midpoint) of each session's range is the 
often-forgotten oracle. Price frequently gravitates to 
session midpoints during retracements, making them powerful 
pivot references that most traders overlook.

═══════════════════════════════════════════════════════════

WHAT THIS TOOL DRAWS

For each session (Asia, London, New York):

- HIGH LINE — solid horizontal line at the session's peak
- LOW LINE — solid horizontal line at the session's floor  
- EQUILIBRIUM LINE — dashed horizontal line at the midpoint

Each level is color-coded by session:
🟣 Asia — violet
🟡 London — gold
🔵 New York — cyan

Lines extend forward until a new session of the same type 
starts (which then draws fresh levels). Old sessions are 
automatically cleared to prevent chart clutter.

═══════════════════════════════════════════════════════════

LIVE RANGE HIGHLIGHTING

When a session is CURRENTLY active, ghost lines show the 
developing high and low updating in real time. This lets 
you see the session forming its extremes as it happens, 
rather than waiting for the session to close.

═══════════════════════════════════════════════════════════

LIQUIDITY SWEEP DETECTION

When price wicks THROUGH a stored session level (from a 
previous session) but closes back on the original side, 
this is marked with a small ⚡ symbol.

These sweeps often precede reversals because:
1. Stop orders clustered just beyond the level get hit
2. Smart money uses that liquidity to enter opposite direction
3. The wick becomes the fingerprint of the trap

═══════════════════════════════════════════════════════════

HOW IT DIFFERS FROM STANDARD S/R INDICATORS

Standard support/resistance indicators mark generic price 
levels based on historical touches. They don't distinguish 
WHO set the level or WHEN.

Session levels are different:
- They're anchored to specific institutional regions
- They carry different weight based on session character
- They tell a narrative across time zones
- They're the liquidity pools smart money hunts

═══════════════════════════════════════════════════════════

SETTINGS EXPLAINED

DAYS OF HISTORY (1-7): Start at 2. Increase if you want more 
context. Decrease for minimalist reads.

HIGHLIGHT CURRENT SESSION: Shows the live-developing range 
of the session you're currently in.

EXTEND LINES FORWARD: When ON, session levels project 
rightward across the chart until invalidated.

SESSION TIMES: Default to UTC standard windows. Adjust if 
your broker uses different session anchors.

SHOW LIQUIDITY SWEEPS: Marks ⚡ when price wicks through a 
stored session level and closes back.

═══════════════════════════════════════════════════════════

RECOMMENDED USE

This tool pairs beautifully with structure analysis 
(BOS/CHoCH), order block identification, and cosmic timing 
tools. It gives you the day's institutional map so you can 
see where price is likely to be hunted or defended.

Best timeframes: 5m, 15m, 30m, 1H
Best markets: Any market with distinct session character 
(crypto, forex, indices)

═══════════════════════════════════════════════════════════

ALERTS INCLUDED

🟣 Asia High Swept
🟣 Asia Low Swept
🟡 London High Swept  
🟡 London Low Swept
🔵 New York High Swept
🔵 New York Low Swept

Set as "Once Per Bar Close" for confirmed sweeps.

═══════════════════════════════════════════════════════════

Pattern over proof. Simplicity over jargon. 
Empowerment over fear.

For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════
//   🌍 REYNA SESSION LEVELS
//   Asia, London, and New York session Highs, Lows, and Equilibriums
//   with liquidity sweep detection
//
//   Session Highs and Lows are the ceilings and floors set by each of 
//   the three major trading regions. They act as magnets for price,
//   liquidity pools for smart money, and pivot points for the day's story.
//
//   Not the same as static support/resistance — these levels are 
//   TIME-BOUND. They carry narrative weight and are hunted often.
//
//   Pattern over proof. Simplicity over jargon. 
//   Empowerment over fear. 🌙
// ═══════════════════════════════════════════════════════════════════

indicator("🌍 Reyna Session Levels", 
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 50)

// Invisible anchor plot — satisfies Pine v6 compiler requirement
plot(na, title = "_anchor", display = display.none)

// ═══════════════════════════════════════════════════════════════════
//                        🎛️ INPUTS
// ═══════════════════════════════════════════════════════════════════

grpDisplay = "Display Settings"
daysBack     = input.int(2, "Days of History to Show", minval = 1, maxval = 7, group = grpDisplay, tooltip = "How many previous days of session levels to display. Start with 2, adjust as your eye develops.")
showLive     = input.bool(true, "Highlight Current Session Live Range", group = grpDisplay, tooltip = "Draws subtle top/bottom lines that update as the current session forms.")
extendLines  = input.bool(true, "Extend Lines Forward", group = grpDisplay, tooltip = "When ON, session H/L lines project rightward until invalidated.")
labelPosition = input.string("right", "Label Position", options = ["right", "off"], group = grpDisplay)

grpLevels = "Levels to Show"
showHigh   = input.bool(true, "Show Session Highs",       group = grpLevels)
showLow    = input.bool(true, "Show Session Lows",        group = grpLevels)
showEq     = input.bool(true, "Show Session Equilibriums (Midpoints)", group = grpLevels, tooltip = "The often-forgotten oracle. Price loves to gravitate here on retracements.")

grpAsia = "🟣 Asia Session"
showAsia    = input.bool(true, "Show Asia Levels", group = grpAsia)
asiaSession = input.session("0000-0600", "Asia Time (UTC)", group = grpAsia)

grpLondon = "🟡 London Session"
showLondon    = input.bool(true, "Show London Levels", group = grpLondon)
londonSession = input.session("0700-1000", "London Time (UTC)", group = grpLondon)

grpNY = "🔵 New York Session"
showNY    = input.bool(true, "Show NY Levels", group = grpNY)
nySession = input.session("1330-1600", "NY Time (UTC)", group = grpNY)

grpSweep = "⚡ Liquidity Sweeps"
showSweeps    = input.bool(true, "Mark Session Level Sweeps", group = grpSweep, tooltip = "Small ⚡ symbol when price wicks through a session level and closes back.")

// ═══════════════════════════════════════════════════════════════════
//                        🎨 COLORS
// ═══════════════════════════════════════════════════════════════════

colAsia       = color.new(#9D4EDD, 0)      // Violet
colAsiaFade   = color.new(#9D4EDD, 60)
colAsiaGhost  = color.new(#9D4EDD, 80)
colLondon     = color.new(#FFD700, 0)      // Gold
colLondonFade = color.new(#FFD700, 60)
colLondonGhost = color.new(#FFD700, 80)
colNY         = color.new(#00B4D8, 0)      // Cyan
colNYFade     = color.new(#00B4D8, 60)
colNYGhost    = color.new(#00B4D8, 80)
colSweep      = color.new(#FFFF00, 0)      // Electric yellow for sweep marks

// ═══════════════════════════════════════════════════════════════════
//                        📊 SESSION DETECTION
// ═══════════════════════════════════════════════════════════════════

inAsia   = not na(time(timeframe.period, asiaSession,   "UTC"))
inLondon = not na(time(timeframe.period, londonSession, "UTC"))
inNY     = not na(time(timeframe.period, nySession,     "UTC"))

asiaStart   = inAsia   and not inAsia[1]
londonStart = inLondon and not inLondon[1]
nyStart     = inNY     and not inNY[1]

asiaEnd   = not inAsia   and inAsia[1]
londonEnd = not inLondon and inLondon[1]
nyEnd     = not inNY     and inNY[1]

// ═══════════════════════════════════════════════════════════════════
//                        📐 SESSION TRACKING
// ═══════════════════════════════════════════════════════════════════

// Running highs/lows for the CURRENT session in progress
var float currentAsiaHigh   = na
var float currentAsiaLow    = na
var int   currentAsiaStart  = na
var float currentLondonHigh   = na
var float currentLondonLow    = na
var int   currentLondonStart  = na
var float currentNYHigh   = na
var float currentNYLow    = na
var int   currentNYStart  = na

// Update running values during active session
if inAsia
    if asiaStart
        currentAsiaHigh  := high
        currentAsiaLow   := low
        currentAsiaStart := bar_index
    else
        currentAsiaHigh := math.max(nz(currentAsiaHigh, high), high)
        currentAsiaLow  := math.min(nz(currentAsiaLow,  low),  low)

if inLondon
    if londonStart
        currentLondonHigh  := high
        currentLondonLow   := low
        currentLondonStart := bar_index
    else
        currentLondonHigh := math.max(nz(currentLondonHigh, high), high)
        currentLondonLow  := math.min(nz(currentLondonLow,  low),  low)

if inNY
    if nyStart
        currentNYHigh  := high
        currentNYLow   := low
        currentNYStart := bar_index
    else
        currentNYHigh := math.max(nz(currentNYHigh, high), high)
        currentNYLow  := math.min(nz(currentNYLow,  low),  low)

// ═══════════════════════════════════════════════════════════════════
//                        🎨 LEVEL DRAWING
// ═══════════════════════════════════════════════════════════════════

// Arrays to hold completed session lines/labels for cleanup
var array<line>  asiaLines   = array.new<line>()
var array<label> asiaLabels  = array.new<label>()
var array<line>  londonLines = array.new<line>()
var array<label> londonLabels = array.new<label>()
var array<line>  nyLines     = array.new<line>()
var array<label> nyLabels    = array.new<label>()

// Store completed session ranges for later reference & sweep detection
var array<float> asiaHighs   = array.new<float>()
var array<float> asiaLows    = array.new<float>()
var array<float> londonHighs = array.new<float>()
var array<float> londonLows  = array.new<float>()
var array<float> nyHighs     = array.new<float>()
var array<float> nyLows      = array.new<float>()

// Function to trim old lines/labels
trimSessions(array<line> lArr, array<label> lblArr, array<float> hArr, array<float> lowArr, int maxKeep) =>
    while array.size(lArr) > maxKeep * 3  // 3 lines per session (H, L, Eq)
        oldLine = array.shift(lArr)
        line.delete(oldLine)
    while array.size(lblArr) > maxKeep * 3
        oldLabel = array.shift(lblArr)
        label.delete(oldLabel)
    while array.size(hArr) > maxKeep
        array.shift(hArr)
    while array.size(lowArr) > maxKeep
        array.shift(lowArr)

// Draw completed session levels
drawSessionLevels(bool sessionEnded, float sessionHigh, float sessionLow, int startBar,
                  bool showThisSession, color sessionColor, string sessionLabel,
                  array<line> lineArr, array<label> labelArr,
                  array<float> highArr, array<float> lowArr) =>
    if sessionEnded and showThisSession and not na(sessionHigh) and not na(sessionLow)
        endBar   = bar_index - 1
        rightBar = extendLines ? bar_index + 500 : endBar
        eqPrice  = (sessionHigh + sessionLow) / 2
        
        // High line
        if showHigh
            hLine = line.new(startBar, sessionHigh, rightBar, sessionHigh, 
                             color = sessionColor, width = 1, style = line.style_solid,
                             extend = extendLines ? extend.right : extend.none)
            array.push(lineArr, hLine)
            if labelPosition == "right"
                hLabel = label.new(rightBar, sessionHigh, text = sessionLabel + " H",
                                    color = color.new(color.black, 100),
                                    textcolor = sessionColor, style = label.style_label_left,
                                    size = size.small)
                array.push(labelArr, hLabel)
        
        // Low line
        if showLow
            lLine = line.new(startBar, sessionLow, rightBar, sessionLow,
                             color = sessionColor, width = 1, style = line.style_solid,
                             extend = extendLines ? extend.right : extend.none)
            array.push(lineArr, lLine)
            if labelPosition == "right"
                lLabel = label.new(rightBar, sessionLow, text = sessionLabel + " L",
                                    color = color.new(color.black, 100),
                                    textcolor = sessionColor, style = label.style_label_left,
                                    size = size.small)
                array.push(labelArr, lLabel)
        
        // Equilibrium (midpoint) line — dashed to distinguish
        if showEq
            eqLine = line.new(startBar, eqPrice, rightBar, eqPrice,
                              color = sessionColor, width = 1, style = line.style_dashed,
                              extend = extendLines ? extend.right : extend.none)
            array.push(lineArr, eqLine)
            if labelPosition == "right"
                eqLabel = label.new(rightBar, eqPrice, text = sessionLabel + " Eq",
                                     color = color.new(color.black, 100),
                                     textcolor = sessionColor, style = label.style_label_left,
                                     size = size.tiny)
                array.push(labelArr, eqLabel)
        
        // Store for sweep tracking
        array.push(highArr, sessionHigh)
        array.push(lowArr, sessionLow)
        
        // Trim to daysBack limit
        trimSessions(lineArr, labelArr, highArr, lowArr, daysBack)

// Draw when each session ends
if asiaEnd
    drawSessionLevels(true, currentAsiaHigh, currentAsiaLow, currentAsiaStart,
                      showAsia, colAsia, "Asia", asiaLines, asiaLabels, asiaHighs, asiaLows)

if londonEnd
    drawSessionLevels(true, currentLondonHigh, currentLondonLow, currentLondonStart,
                      showLondon, colLondon, "London", londonLines, londonLabels, londonHighs, londonLows)

if nyEnd
    drawSessionLevels(true, currentNYHigh, currentNYLow, currentNYStart,
                      showNY, colNY, "NY", nyLines, nyLabels, nyHighs, nyLows)

// ═══════════════════════════════════════════════════════════════════
//                        🌟 CURRENT SESSION LIVE RANGE
// ═══════════════════════════════════════════════════════════════════

// These plot() calls draw thin ghost lines showing the CURRENT session's
// developing high/low. They update every bar until session ends.
plot(showLive and showAsia   and inAsia   ? currentAsiaHigh   : na, "Asia Live High",   color = colAsiaGhost,   linewidth = 1, style = plot.style_linebr)
plot(showLive and showAsia   and inAsia   ? currentAsiaLow    : na, "Asia Live Low",    color = colAsiaGhost,   linewidth = 1, style = plot.style_linebr)
plot(showLive and showLondon and inLondon ? currentLondonHigh : na, "London Live High", color = colLondonGhost, linewidth = 1, style = plot.style_linebr)
plot(showLive and showLondon and inLondon ? currentLondonLow  : na, "London Live Low",  color = colLondonGhost, linewidth = 1, style = plot.style_linebr)
plot(showLive and showNY     and inNY     ? currentNYHigh     : na, "NY Live High",     color = colNYGhost,     linewidth = 1, style = plot.style_linebr)
plot(showLive and showNY     and inNY     ? currentNYLow      : na, "NY Live Low",      color = colNYGhost,     linewidth = 1, style = plot.style_linebr)

// ═══════════════════════════════════════════════════════════════════
//                        ⚡ LIQUIDITY SWEEP DETECTION
// ═══════════════════════════════════════════════════════════════════

// A sweep happens when price wicks THROUGH a stored session level 
// but closes back on the original side
sweepAny(array<float> highArr, array<float> lowArr) =>
    sweptHigh = false
    sweptLow  = false
    if array.size(highArr) > 0
        for i = 0 to array.size(highArr) - 1
            lvl = array.get(highArr, i)
            if high > lvl and close < lvl and high[1] <= lvl
                sweptHigh := true
    if array.size(lowArr) > 0
        for i = 0 to array.size(lowArr) - 1
            lvl = array.get(lowArr, i)
            if low < lvl and close > lvl and low[1] >= lvl
                sweptLow := true
    [sweptHigh, sweptLow]

[asiaSweepH, asiaSweepL]     = sweepAny(asiaHighs, asiaLows)
[londonSweepH, londonSweepL] = sweepAny(londonHighs, londonLows)
[nySweepH, nySweepL]         = sweepAny(nyHighs, nyLows)

anyHighSweep = (showAsia and asiaSweepH) or (showLondon and londonSweepH) or (showNY and nySweepH)
anyLowSweep  = (showAsia and asiaSweepL) or (showLondon and londonSweepL) or (showNY and nySweepL)

plotshape(showSweeps and anyHighSweep, title = "Session High Sweep", style = shape.arrowdown, location = location.abovebar, color = color.new(colSweep, 100), size = size.tiny, text = "⚡", textcolor = colSweep)
plotshape(showSweeps and anyLowSweep,  title = "Session Low Sweep",  style = shape.arrowup,   location = location.belowbar, color = color.new(colSweep, 100), size = size.tiny, text = "⚡", textcolor = colSweep)

// ═══════════════════════════════════════════════════════════════════
//                        🔔 ALERTS
// ═══════════════════════════════════════════════════════════════════

alertcondition(asiaSweepH,   title = "Asia High Swept",   message = "🟣⚡ Asia session high just swept")
alertcondition(asiaSweepL,   title = "Asia Low Swept",    message = "🟣⚡ Asia session low just swept")
alertcondition(londonSweepH, title = "London High Swept", message = "🟡⚡ London session high just swept")
alertcondition(londonSweepL, title = "London Low Swept",  message = "🟡⚡ London session low just swept")
alertcondition(nySweepH,     title = "NY High Swept",     message = "🔵⚡ New York session high just swept")
alertcondition(nySweepL,     title = "NY Low Swept",      message = "🔵⚡ New York session low just swept")
````
