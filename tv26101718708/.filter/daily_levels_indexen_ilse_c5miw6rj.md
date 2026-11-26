# Daily levels indexen Ilse

- url: https://www.tradingview.com/script/c5mIW6Rj-Daily-levels-indexen-Ilse/
- type: indicator
- pine_id: PUB;1dd1f2da3a7e46c9a2ee7b33d4dcd083
- version: 1.0

## Description

Daily levels Yesterday High/Low and Close on daily and lower timeframes.

## Source Code

````pine
//@version=5
indicator("Yesterday's Levels (YH/YC/YL)", shorttitle="YH/YC/YL", overlay=true)

// ─── DATA ────────────────────────────────────────────────────────────────────
prevHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)

// ─── EERSTE BAR VAN DE DAG (voor intraday) ───────────────────────────────────
isNewDay = ta.change(time("D")) != 0
var int dayStartTime = na
if isNewDay
    dayStartTime := time

// ─── LINES & LABELS ──────────────────────────────────────────────────────────
var line yhLine = na
var line ycLine = na
var line ylLine = na
var label yhLabel = na
var label ycLabel = na
var label ylLabel = na

if barstate.islast
    line.delete(yhLine)
    line.delete(ycLine)
    line.delete(ylLine)
    label.delete(yhLabel)
    label.delete(ycLabel)
    label.delete(ylLabel)

    labelBar = bar_index + 10

    // DAILY
    if timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
        startBar = bar_index - 1
        yhLine := line.new(startBar, prevHigh,  startBar + 1, prevHigh,  color=color.green, width=2, extend=extend.right, style=line.style_solid)
        ycLine := line.new(startBar, prevClose, startBar + 1, prevClose, color=color.red,   width=2, extend=extend.right, style=line.style_solid)
        ylLine := line.new(startBar, prevLow,   startBar + 1, prevLow,   color=color.green, width=2, extend=extend.right, style=line.style_solid)

    // INTRADAY
    else
        endTime = dayStartTime + 10 * 24 * 60 * 60 * 1000
        yhLine := line.new(dayStartTime, prevHigh,  endTime, prevHigh,  color=color.green, width=2, extend=extend.right, style=line.style_solid, xloc=xloc.bar_time)
        ycLine := line.new(dayStartTime, prevClose, endTime, prevClose, color=color.red,   width=2, extend=extend.right, style=line.style_solid, xloc=xloc.bar_time)
        ylLine := line.new(dayStartTime, prevLow,   endTime, prevLow,   color=color.green, width=2, extend=extend.right, style=line.style_solid, xloc=xloc.bar_time)

    // label.style_none = tekst exact OP de lijn, geen ballon
    yhLabel := label.new(labelBar, prevHigh,  text="YH", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none, size=size.normal)
    ycLabel := label.new(labelBar, prevClose, text="YC", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none, size=size.normal)
    ylLabel := label.new(labelBar, prevLow,   text="YL", color=color.new(color.white, 100), textcolor=color.black, style=label.style_none, size=size.normal)
````
