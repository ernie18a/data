# SPX RTH Gap % (Cash Session)

- url: https://www.tradingview.com/script/uwD8s9Es-SPX-RTH-Gap-Cash-Session/
- type: indicator
- pine_id: PUB;30c681612a3e4e93934d57cc4142f994
- version: 1.0

## Description

This simple indicator shows the percentage that SPX gaps up or down by comparing the previous days close to the next day's open.

## Source Code

````pine
//@version=5
indicator("SPX RTH Gap % (Cash Session)", overlay=true)

// Regular cash session for US equities/index cash hours
sess = "0930-1600"
tz   = "America/New_York"

// True when bar is inside regular session
inSess = not na(time(timeframe.period, sess, tz))

// Session boundaries
sessStart = inSess and not inSess[1]
sessEnd   = not inSess and inSess[1]

// Persist yesterday close + today's open
var float prevRthClose = na
var float todayRthOpen = na

// Last bar of session -> yesterday's RTH close
if sessEnd
    prevRthClose := close[1]

// First bar of session -> today's RTH open
if sessStart
    todayRthOpen := open

gapPct = (todayRthOpen - prevRthClose) / prevRthClose * 100.0

// Print once per session start (only if we have both values)
if sessStart and not na(prevRthClose)
    label.new(bar_index, high, "SPX Gap: " + str.tostring(gapPct, "#.##") + "%", style=label.style_label_down,
      color=(gapPct >= 0 ? color.green : color.red), textcolor=color.white)
````
