# ICT Macro Time Highlighter - NY + London Macros

- url: https://www.tradingview.com/script/g1Tdo6Ay-ICT-Macro-Time-Highlighter-NY-London-Macros/
- type: indicator
- pine_id: PUB;f513f37c28554c5e8e31be52f86560ab
- version: 1.0

## Description

ICT Macro Time Highlighter — NY & London Sessions

This indicator highlights key ICT macro time windows directly on your TradingView chart using New York time. It is designed to help traders visually identify important time-based liquidity windows during the London and New York sessions.

The script highlights the following macro times:

London Macro Windows

London Macro 1: 2:33 AM – 3:00 AM NY Time
London Macro 2: 4:03 AM – 4:30 AM NY Time

New York Macro Windows

8:50 AM – 9:10 AM: NY Open liquidity move
9:50 AM – 10:10 AM: Continuation or reversal window
10:50 AM – 11:10 AM: Liquidity/displacement window
11:50 AM – 12:10 PM: Lunch-time liquidity
1:10 PM – 1:40 PM: PM session setup
3:15 PM – 3:45 PM: Late-day move

Features:

Highlights London and New York ICT macro time windows.
Uses America/New_York timezone.
Automatically adjusts with New York daylight saving time.
Optional weekday-only filter.
Customizable colors for each macro window.
Optional labels at the start of every macro time.
Alert conditions for London macros, New York macros, and all macro windows.

This indicator is not a buy or sell signal. It is a time-based visual tool designed to help ICT traders focus on specific trading windows where liquidity sweeps, displacement, market structure shifts, fair value gaps, continuation moves, or reversals may occur.

Best used together with:

Liquidity sweep analysis
Market structure shift / CHOCH
Fair value gaps
Order blocks
Premium and discount zones
Higher timeframe bias

Recommended timeframes:

1-minute
3-minute
5-minute
15-minute

Use this indicator as a timing filter to support your ICT trading plan, not as a standalone trading strategy.

## Source Code

````pine
//@version=5
indicator("ICT Macro Time Highlighter - NY + London Macros", overlay=true, max_labels_count=500)

//==============================
// General Settings
//==============================
groupGeneral = "General Settings"

tz             = input.string("America/New_York", "Macro Timezone", group=groupGeneral)
showBg         = input.bool(true, "Highlight Macro Time Background", group=groupGeneral)
showLabels     = input.bool(true, "Show Label at Macro Start", group=groupGeneral)
weekdaysOnly   = input.bool(true, "Weekdays Only", group=groupGeneral)
labelAtrOffset = input.float(0.50, "Label Offset Using ATR", step=0.10, group=groupGeneral)

dayFilter = weekdaysOnly ? ":23456" : ":1234567"
atrValue  = ta.atr(14)

//==============================
// London Macro Time Inputs
//==============================
groupL1 = "London Macro 1 | 2:33 - 3:00 AM NY"
l1On      = input.bool(true, "Enable", group=groupL1)
l1Session = input.session("0233-0300", "NY Time", group=groupL1)
l1Color   = input.color(color.new(color.blue, 85), "Highlight Color", group=groupL1)

groupL2 = "London Macro 2 | 4:03 - 4:30 AM NY"
l2On      = input.bool(true, "Enable", group=groupL2)
l2Session = input.session("0403-0430", "NY Time", group=groupL2)
l2Color   = input.color(color.new(color.teal, 85), "Highlight Color", group=groupL2)

//==============================
// NY Macro Time Inputs
//==============================
group1 = "8:50 - 9:10 AM | NY Open Liquidity Move"
m1On      = input.bool(true, "Enable", group=group1)
m1Session = input.session("0850-0910", "NY Time", group=group1)
m1Color   = input.color(color.new(color.aqua, 85), "Highlight Color", group=group1)

group2 = "9:50 - 10:10 AM | Continuation or Reversal"
m2On      = input.bool(true, "Enable", group=group2)
m2Session = input.session("0950-1010", "NY Time", group=group2)
m2Color   = input.color(color.new(color.yellow, 85), "Highlight Color", group=group2)

group3 = "10:50 - 11:10 AM | Liquidity / Displacement Window"
m3On      = input.bool(true, "Enable", group=group3)
m3Session = input.session("1050-1110", "NY Time", group=group3)
m3Color   = input.color(color.new(color.orange, 85), "Highlight Color", group=group3)

group4 = "11:50 AM - 12:10 PM | Lunch-Time Liquidity"
m4On      = input.bool(true, "Enable", group=group4)
m4Session = input.session("1150-1210", "NY Time", group=group4)
m4Color   = input.color(color.new(color.purple, 85), "Highlight Color", group=group4)

group5 = "1:10 - 1:40 PM | PM Session Setup"
m5On      = input.bool(true, "Enable", group=group5)
m5Session = input.session("1310-1340", "NY Time", group=group5)
m5Color   = input.color(color.new(color.lime, 85), "Highlight Color", group=group5)

group6 = "3:15 - 3:45 PM | Late-Day Move"
m6On      = input.bool(true, "Enable", group=group6)
m6Session = input.session("1515-1545", "NY Time", group=group6)
m6Color   = input.color(color.new(color.red, 85), "Highlight Color", group=group6)

//==============================
// Session Detection Function
//==============================
f_inSession(_enabled, _session) =>
    _enabled and not na(time(timeframe.period, _session + dayFilter, tz))

l1 = f_inSession(l1On, l1Session)
l2 = f_inSession(l2On, l2Session)

m1 = f_inSession(m1On, m1Session)
m2 = f_inSession(m2On, m2Session)
m3 = f_inSession(m3On, m3Session)
m4 = f_inSession(m4On, m4Session)
m5 = f_inSession(m5On, m5Session)
m6 = f_inSession(m6On, m6Session)

l1Start = l1 and not nz(l1[1], false)
l2Start = l2 and not nz(l2[1], false)

m1Start = m1 and not nz(m1[1], false)
m2Start = m2 and not nz(m2[1], false)
m3Start = m3 and not nz(m3[1], false)
m4Start = m4 and not nz(m4[1], false)
m5Start = m5 and not nz(m5[1], false)
m6Start = m6 and not nz(m6[1], false)

//==============================
// Background Highlight
//==============================
macroColor =
     l1 ? l1Color :
     l2 ? l2Color :
     m1 ? m1Color :
     m2 ? m2Color :
     m3 ? m3Color :
     m4 ? m4Color :
     m5 ? m5Color :
     m6 ? m6Color :
     na

bgcolor(showBg ? macroColor : na, title="ICT Macro Time Highlight")

//==============================
// Labels
//==============================
labelY = high + atrValue * labelAtrOffset

if showLabels and l1Start
    label.new(bar_index, labelY, "London Macro 1\n2:33 - 3:00 AM NY\nApprox. 2:33 - 3:00 PM PH", style=label.style_label_down, textcolor=color.white, color=color.new(color.blue, 0), size=size.small)

if showLabels and l2Start
    label.new(bar_index, labelY, "London Macro 2\n4:03 - 4:30 AM NY\nApprox. 4:03 - 4:30 PM PH", style=label.style_label_down, textcolor=color.white, color=color.new(color.teal, 0), size=size.small)

if showLabels and m1Start
    label.new(bar_index, labelY, "8:50 - 9:10 AM\nNY Open Liquidity", style=label.style_label_down, textcolor=color.white, color=color.new(color.aqua, 0), size=size.small)

if showLabels and m2Start
    label.new(bar_index, labelY, "9:50 - 10:10 AM\nContinuation / Reversal", style=label.style_label_down, textcolor=color.black, color=color.new(color.yellow, 0), size=size.small)

if showLabels and m3Start
    label.new(bar_index, labelY, "10:50 - 11:10 AM\nLiquidity / Displacement", style=label.style_label_down, textcolor=color.white, color=color.new(color.orange, 0), size=size.small)

if showLabels and m4Start
    label.new(bar_index, labelY, "11:50 - 12:10 PM\nLunch-Time Liquidity", style=label.style_label_down, textcolor=color.white, color=color.new(color.purple, 0), size=size.small)

if showLabels and m5Start
    label.new(bar_index, labelY, "1:10 - 1:40 PM\nPM Session Setup", style=label.style_label_down, textcolor=color.white, color=color.new(color.lime, 0), size=size.small)

if showLabels and m6Start
    label.new(bar_index, labelY, "3:15 - 3:45 PM\nLate-Day Move", style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 0), size=size.small)

//==============================
// Alerts
//==============================
londonMacroStart = l1Start or l2Start
nyMacroStart     = m1Start or m2Start or m3Start or m4Start or m5Start or m6Start

anyMacroStart  = londonMacroStart or nyMacroStart
anyMacroActive = l1 or l2 or m1 or m2 or m3 or m4 or m5 or m6

alertcondition(londonMacroStart, title="London Macro Started", message="London ICT macro time has started. Watch for liquidity sweep, displacement, FVG, MSS, or reversal setup.")
alertcondition(nyMacroStart, title="NY Macro Started", message="New York ICT macro time has started. Watch for liquidity sweep, displacement, FVG, MSS, or reversal setup.")
alertcondition(anyMacroStart, title="Any ICT Macro Time Started", message="An ICT macro time window has started.")
alertcondition(anyMacroActive, title="ICT Macro Time Active", message="ICT macro time is currently active.")
````
