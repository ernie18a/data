# Mr Balwants Session (Asia, London, New York)

- url: https://www.tradingview.com/script/2A2TpsxQ-Mr-Balwants-Session-Asia-London-New-York/
- type: indicator
- pine_id: PUB;5be8ba3b180d47ed93fcb3935de6c880
- version: 1.0

## Description

Mr Balwants Sessions Indicator

This indicator highlights the three major trading sessions directly on the chart using Indian Standard Time (IST):

• Asia Session: 5:30 AM – 11:30 AM IST
• London Session: 12:30 PM – 5:30 PM IST
• New York Session: 5:30 PM – 2:30 AM IST

The indicator automatically colors the background for each session, making it easier to identify market activity, liquidity shifts, and session overlaps at a glance.

Features:

* Clear visual separation of major market sessions
* Session labels displayed at the start of each session
* Fixed IST timings for Indian traders
* Lightweight and easy to use on any timeframe

This tool is designed to help traders improve market structure analysis, session-based strategies, and overall chart readability.

## Source Code

````pine
//@version=5
indicator("Mr Balwants Session (Asia, London, New York)", overlay=true)

// Session Times (IST)
asiaSession   = not na(time(timeframe.period, "0530-1130", "Asia/Kolkata"))
londonSession = not na(time(timeframe.period, "1230-1730", "Asia/Kolkata"))
newyorkSession = not na(time(timeframe.period, "1730-0230", "Asia/Kolkata"))

// Background Colors
bgcolor(asiaSession ? color.new(color.green, 90) : na, title="Asia")
bgcolor(londonSession ? color.new(color.blue, 90) : na, title="London")
bgcolor(newyorkSession ? color.new(color.red, 90) : na, title="New York")

// Session Labels
if asiaSession and not asiaSession[1]
    label.new(bar_index, high, "ASIA", color=color.green, textcolor=color.white, style=label.style_label_down)

if londonSession and not londonSession[1]
    label.new(bar_index, high, "LONDON", color=color.blue, textcolor=color.white, style=label.style_label_down)

if newyorkSession and not newyorkSession[1]
    label.new(bar_index, high, "NEW YORK", color=color.red, textcolor=color.white, style=label.style_label_down)
````
