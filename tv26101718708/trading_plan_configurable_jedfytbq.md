# Trading Plan - Configurable

- url: https://www.tradingview.com/script/jEDfYtbQ-Trading-Plan-Configurable/
- type: indicator
- pine_id: PUB;4c8b72d124cd4fa483e06dbac1693be4
- version: 2.0

## Description

Trading Plan Dashboard — Session-Based Decision Framework

A minimal, session-aware dashboard designed to keep traders aligned with their plan, timing, and execution rules.

This tool does not generate signals.
Instead, it answers three critical questions in real time:

What time / session am I in?
What type of trade is expected today?
Am I allowed to take a trade right now?
🧠 Concept

Most trading mistakes don’t come from bad entries — they come from:

Trading at the wrong time
Ignoring session context
Forcing trades outside your plan

This dashboard acts as a discipline filter, keeping you focused on when and whether to trade — not just how.

⚙️ Key Features
⏰ Session Awareness
Configurable session windows (W1–W5)
Automatically detects the current trading window
Displays “OUTSIDE SESSION” when no trades should be considered
📅 Day-Based Trade Modes
Assign each day a mode:
TS1 (Continuation)
TS2 (Reversal)
No Trade
Example default:
Monday → Continuation
Tue–Thu → Reversal
Friday → No Trade
🔥 Execution State Engine

Real-time state based on time + session logic:

LOCKED → No trading allowed
WATCH → Setup forming (ORB / build phase)
ARMED → Conditions valid, trade can be taken
🧭 Trade Context Display
Current session (W1–W5)
Trade type (TS1 / TS2 / No Trade)
Expected behavior (customizable text)
Day + time (12h format)
🎛 Fully Configurable
Session start/end times
Window names
Day-of-week behavior
Trade and expectation text
Panel position, colors, and sizing
🚫 What This Indicator Does NOT Do
No buy/sell signals
No indicators (RSI, EMA, etc.)
No automated entries

This is intentional.

🎯 Who This Is For
Traders using session-based strategies
ORB / time-window traders
Discretionary traders who want structure without losing intuition
Anyone struggling with overtrading or poor timing
🧠 Philosophy

“Execution improves when decisions are constrained.”

This tool is designed to reduce:

impulsive trades
trading in dead zones
decision fatigue

…and reinforce:

patience
timing
consistency
🔧 Suggested Use
Pair with your own strategy or indicators
Use it as a pre-trade filter, not a signal
Let it guide when you’re allowed to engage with the market
⚠️ Disclaimer

This indicator is a planning and visualization tool only.
It does not provide financial advice or guaranteed outcomes.

## Source Code

````pine
//@version=5
indicator("Trading Plan  Dashoboard - Configurable", overlay=true)

// =============================
// SETTINGS
// =============================
groupGen = "General"
tz = input.string("America/New_York", "Timezone", group=groupGen)
panelPosInput = input.string("Bottom Right", "Panel Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=groupGen)
headerSizeInput = input.string("Small", "Header Text Size", options=["Tiny", "Small", "Normal"], group=groupGen)
stateSizeInput  = input.string("Normal", "State Text Size", options=["Small", "Normal", "Large"], group=groupGen)
infoSizeInput   = input.string("Small", "Info Text Size", options=["Tiny", "Small", "Normal"], group=groupGen)

// =============================
// DAY MODES
// =============================
groupDays = "Day Modes"
monMode = input.string("TS1", "Monday", options=["TS1", "TS2", "NO TRADE"], group=groupDays)
tueMode = input.string("TS2", "Tuesday", options=["TS1", "TS2", "NO TRADE"], group=groupDays)
wedMode = input.string("TS2", "Wednesday", options=["TS1", "TS2", "NO TRADE"], group=groupDays)
thuMode = input.string("TS2", "Thursday", options=["TS1", "TS2", "NO TRADE"], group=groupDays)
friMode = input.string("NO TRADE", "Friday", options=["TS1", "TS2", "NO TRADE"], group=groupDays)
satMode = input.string("NO TRADE", "Saturday", options=["TS1", "TS2", "NO TRADE"], group=groupDays)
sunMode = input.string("NO TRADE", "Sunday", options=["TS1", "TS2", "NO TRADE"], group=groupDays)

// =============================
// MODE TEXT
// =============================
groupModes = "Mode Text"
ts1TradeText = input.string("TS1 CONTINUATION", "TS1 Trade Text", group=groupModes)
ts1ExpectText = input.string("BREAK TO CONTINUE", "TS1 Expectation", group=groupModes)

ts2TradeText = input.string("TS2 REVERSAL", "TS2 Trade Text", group=groupModes)
ts2ExpectText = input.string("SWEEP TO REVERSE", "TS2 Expectation", group=groupModes)

noTradeText = input.string("NO TRADE", "No-Trade Trade Text", group=groupModes)
noSetupText = input.string("NO SETUP", "No-Trade Expectation", group=groupModes)

// =============================
// SESSION WINDOWS
// =============================
groupW1 = "W1"
w1Enabled = input.bool(true, "Enable W1", group=groupW1)
w1Name = input.string("W1 LONDON", "W1 Name", group=groupW1)
w1StartH = input.int(3, "Start Hour", minval=0, maxval=23, group=groupW1)
w1StartM = input.int(0, "Start Minute", minval=0, maxval=59, group=groupW1)
w1EndH = input.int(3, "End Hour", minval=0, maxval=23, group=groupW1)
w1EndM = input.int(15, "End Minute", minval=0, maxval=59, group=groupW1)
w1OrbEndH = input.int(3, "ORB End Hour", minval=0, maxval=23, group=groupW1)
w1OrbEndM = input.int(15, "ORB End Minute", minval=0, maxval=59, group=groupW1)

groupW2 = "W2"
w2Enabled = input.bool(true, "Enable W2", group=groupW2)
w2Name = input.string("W2 LONDON", "W2 Name", group=groupW2)
w2StartH = input.int(4, "Start Hour", minval=0, maxval=23, group=groupW2)
w2StartM = input.int(15, "Start Minute", minval=0, maxval=59, group=groupW2)
w2EndH = input.int(6, "End Hour", minval=0, maxval=23, group=groupW2)
w2EndM = input.int(15, "End Minute", minval=0, maxval=59, group=groupW2)

groupW3 = "W3"
w3Enabled = input.bool(true, "Enable W3", group=groupW3)
w3Name = input.string("W3 NYC", "W3 Name", group=groupW3)
w3StartH = input.int(8, "Start Hour", minval=0, maxval=23, group=groupW3)
w3StartM = input.int(0, "Start Minute", minval=0, maxval=59, group=groupW3)
w3EndH = input.int(9, "End Hour", minval=0, maxval=23, group=groupW3)
w3EndM = input.int(30, "End Minute", minval=0, maxval=59, group=groupW3)
w3OrbEndH = input.int(8, "ORB End Hour", minval=0, maxval=23, group=groupW3)
w3OrbEndM = input.int(15, "ORB End Minute", minval=0, maxval=59, group=groupW3)

groupW4 = "W4"
w4Enabled = input.bool(true, "Enable W4", group=groupW4)
w4Name = input.string("W4 NYSE", "W4 Name", group=groupW4)
w4StartH = input.int(9, "Start Hour", minval=0, maxval=23, group=groupW4)
w4StartM = input.int(30, "Start Minute", minval=0, maxval=59, group=groupW4)
w4EndH = input.int(11, "End Hour", minval=0, maxval=23, group=groupW4)
w4EndM = input.int(30, "End Minute", minval=0, maxval=59, group=groupW4)

groupW5 = "W5"
w5Enabled = input.bool(true, "Enable W5", group=groupW5)
w5Name = input.string("W5 LATE", "W5 Name", group=groupW5)
w5StartH = input.int(11, "Start Hour", minval=0, maxval=23, group=groupW5)
w5StartM = input.int(30, "Start Minute", minval=0, maxval=59, group=groupW5)
w5EndH = input.int(15, "End Hour", minval=0, maxval=23, group=groupW5)
w5EndM = input.int(0, "End Minute", minval=0, maxval=59, group=groupW5)

// =============================
// COLORS
// =============================
groupColors = "Colors"
headerBg = input.color(color.new(color.gray, 15), "Header Background", group=groupColors)
panelBg = input.color(color.new(color.black, 10), "Panel Background", group=groupColors)
lockedBg = input.color(color.new(color.red, 40), "Locked Background", group=groupColors)
watchBg = input.color(color.new(color.orange, 35), "Watch Background", group=groupColors)
armedBg = input.color(color.new(color.green, 35), "Armed Background", group=groupColors)

// =============================
// HELPERS
// =============================
f_tablePos(_pos) =>
    _pos == "Top Left" ? position.top_left :
     _pos == "Top Right" ? position.top_right :
     _pos == "Bottom Left" ? position.bottom_left :
     position.bottom_right

f_textSize(_s) =>
    _s == "Tiny" ? size.tiny :
     _s == "Small" ? size.small :
     _s == "Normal" ? size.normal :
     size.normal

f_inWindow(_h, _m, _sh, _sm, _eh, _em) =>
    cur = _h * 60 + _m
    start = _sh * 60 + _sm
    stop = _eh * 60 + _em
    start < stop ? (cur >= start and cur < stop) : (cur >= start or cur < stop)

f_dayMode() =>
    string result = "NO TRADE"
    if dayofweek == dayofweek.monday
        result := monMode
    else if dayofweek == dayofweek.tuesday
        result := tueMode
    else if dayofweek == dayofweek.wednesday
        result := wedMode
    else if dayofweek == dayofweek.thursday
        result := thuMode
    else if dayofweek == dayofweek.friday
        result := friMode
    else if dayofweek == dayofweek.saturday
        result := satMode
    else
        result := sunMode
    result

f_dayStr() =>
    string d = "SUN"
    if dayofweek == dayofweek.monday
        d := "MON"
    else if dayofweek == dayofweek.tuesday
        d := "TUE"
    else if dayofweek == dayofweek.wednesday
        d := "WED"
    else if dayofweek == dayofweek.thursday
        d := "THU"
    else if dayofweek == dayofweek.friday
        d := "FRI"
    else if dayofweek == dayofweek.saturday
        d := "SAT"
    d

// =============================
// TIME
// =============================
t = time(timeframe.period, tz)
h24 = hour(t)
m = minute(t)

h12 = h24 % 12
if h12 == 0
    h12 := 12

string ampm = "AM"
if h24 >= 12
    ampm := "PM"

timeStr = str.tostring(h12, "00") + ":" + str.tostring(m, "00") + " " + ampm
dayStr = f_dayStr()

// =============================
// WINDOWS
// =============================
inW1 = w1Enabled and f_inWindow(h24, m, w1StartH, w1StartM, w1EndH, w1EndM)
inW2 = w2Enabled and f_inWindow(h24, m, w2StartH, w2StartM, w2EndH, w2EndM)
inW3 = w3Enabled and f_inWindow(h24, m, w3StartH, w3StartM, w3EndH, w3EndM)
inW4 = w4Enabled and f_inWindow(h24, m, w4StartH, w4StartM, w4EndH, w4EndM)
inW5 = w5Enabled and f_inWindow(h24, m, w5StartH, w5StartM, w5EndH, w5EndM)

string windowTxt = "OUTSIDE SESSION"
if inW1
    windowTxt := w1Name
else if inW2
    windowTxt := w2Name
else if inW3
    windowTxt := w3Name
else if inW4
    windowTxt := w4Name
else if inW5
    windowTxt := w5Name

// =============================
// ORB / STATE
// =============================
inOrbW1 = w1Enabled and f_inWindow(h24, m, w1StartH, w1StartM, w1OrbEndH, w1OrbEndM)
inOrbW3 = w3Enabled and f_inWindow(h24, m, w3StartH, w3StartM, w3OrbEndH, w3OrbEndM)

orbBuilding = inOrbW1 or inOrbW3
active = inW1 or inW2 or inW3 or inW4 or inW5

dayMode = f_dayMode()

string tradeTxt = noTradeText
string expectTxt = noSetupText

if dayMode == "TS1"
    tradeTxt := ts1TradeText
    expectTxt := ts1ExpectText
else if dayMode == "TS2"
    tradeTxt := ts2TradeText
    expectTxt := ts2ExpectText

string state = "LOCKED"
if dayMode != "NO TRADE"
    if active
        if orbBuilding
            state := "WATCH"
        else
            state := "ARMED"

string stateTxt = "LOCKED"
if state == "WATCH"
    stateTxt := "WATCH"
else if state == "ARMED"
    stateTxt := "ARMED"

stateBg = lockedBg
if state == "WATCH"
    stateBg := watchBg
else if state == "ARMED"
    stateBg := armedBg

// =============================
// TABLE
// =============================
var table dash = table.new(f_tablePos(panelPosInput), 1, 4, border_width=1)

if barstate.islast
    table.cell(dash, 0, 0, dayStr + " " + timeStr, text_color=color.white, bgcolor=headerBg, text_size=f_textSize(headerSizeInput))
    table.cell(dash, 0, 1, stateTxt, text_color=color.white, bgcolor=stateBg, text_size=f_textSize(stateSizeInput))
    table.cell(dash, 0, 2, windowTxt, text_color=color.white, bgcolor=panelBg, text_size=f_textSize(infoSizeInput))
    table.cell(dash, 0, 3, tradeTxt + " | " + expectTxt, text_color=color.new(color.white, 5), bgcolor=panelBg, text_size=f_textSize(infoSizeInput))
````
