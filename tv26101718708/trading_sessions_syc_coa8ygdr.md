# Trading Sessions (SYC)

- url: https://www.tradingview.com/script/Coa8YgDr/
- type: indicator
- pine_id: PUB;9d41cb6baa3a47618a4106fd1bac0eb3
- version: 1.0

## Description

This Pine Script indicator visualizes the three most critical trading sessions of the day (Asia, London, and New York) directly on your chart. It has been specifically optimized to track the highest and lowest prices (High/Low) of each session flawlessly especially for sessions that span across midnight.

## Source Code

````pine
//@version=5
indicator("Trading Sessions - Asia London New York (SYC)", shorttitle="Sessions Fixed Min", overlay=true)

// === Asia Session ===
showAsia      = input.bool(true, "Show Asia Session", group="Asia")
asiaStartH    = input.int(19, "Asia Start Hour EST", minval=0, maxval=23, group="Asia")
asiaStartM    = input.int(0,  "Asia Start Minute (5 min steps)", minval=0, maxval=55, step=5, group="Asia")
asiaEndH      = input.int(4,  "Asia End Hour EST", minval=0, maxval=23, group="Asia")
asiaEndM      = input.int(0,  "Asia End Minute (5 min steps)", minval=0, maxval=55, step=5, group="Asia")
asiaBg        = input.color(color.new(color.purple, 80), "Asia Background Color", group="Asia")
asiaLineColor = input.color(color.purple, "Asia High/Low Line Color", group="Asia")

// === London Session ===
showLondon    = input.bool(true, "Show London Session", group="London")
londonStartH  = input.int(3, "London Start Hour EST", minval=0, maxval=23, group="London")
londonStartM  = input.int(0, "London Start Minute (5 min steps)", minval=0, maxval=55, step=5, group="London")
londonEndH    = input.int(12,"London End Hour EST", minval=0, maxval=23, group="London")
londonEndM    = input.int(0, "London End Minute (5 min steps)", minval=0, maxval=55, step=5, group="London")
londonBg      = input.color(color.new(color.lime, 80), "London Background Color", group="London")
londonLineColor = input.color(color.lime, "London High/Low Line Color", group="London")

// === New York Session ===
showNY        = input.bool(true, "Show New York Session", group="New York")
nyStartH      = input.int(9,  "New York Start Hour EST", minval=0, maxval=23, group="New York")
nyStartM      = input.int(0,  "New York Start Minute (5 min steps)", minval=0, maxval=55, step=5, group="New York")
nyEndH        = input.int(16, "New York End Hour EST", minval=0, maxval=23, group="New York")
nyEndM        = input.int(0,  "New York End Minute (5 min steps)", minval=0, maxval=55, step=5, group="New York")
nyBg          = input.color(color.new(color.orange, 80), "New York Background Color", group="New York")
nyLineColor   = input.color(color.orange, "New York High/Low Line Color", group="New York")

showLines     = input.bool(true, "Show High/Low Lines", group="General")

// Zeitzone
tz = "America/New_York"

// REPARIERTE HILFSFUNKTION: Macht aus einer 5 eine "05" und aus einer 0 eine "00"
twoDigitStr(_val) => 
    _val < 10 ? "0" + str.tostring(_val) : str.tostring(_val)

// Erstellt die sauberen Zeit-Strings für die Abfrage (z.B. "1905-0400")
asiaStr   = twoDigitStr(asiaStartH)   + twoDigitStr(asiaStartM)   + "-" + twoDigitStr(asiaEndH)   + twoDigitStr(asiaEndM)
londonStr = twoDigitStr(londonStartH) + twoDigitStr(londonStartM) + "-" + twoDigitStr(londonEndH) + twoDigitStr(londonEndM)
nyStr     = twoDigitStr(nyStartH)     + twoDigitStr(nyStartM)     + "-" + twoDigitStr(nyEndH)     + twoDigitStr(nyEndM)

// Session aktiv?
inAsia   = timeframe.isintraday and not na(time(timeframe.period, asiaStr, tz))
inLondon = timeframe.isintraday and not na(time(timeframe.period, londonStr, tz))
inNY     = timeframe.isintraday and not na(time(timeframe.period, nyStr, tz))

// High/Low Variablen
var float asiaHigh   = na
var float asiaLow    = na
var float londonHigh = na
var float londonLow  = na
var float nyHigh     = na
var float nyLow      = na

// Zurücksetzen exakt beim echten Start der jeweiligen Session
if inAsia and not inAsia[1]
    asiaHigh := na
    asiaLow  := na

if inLondon and not inLondon[1]
    londonHigh := na
    londonLow  := na

if inNY and not inNY[1]
    nyHigh := na
    nyLow  := na

// Hintergründe zeichnen
bgcolor(showAsia and inAsia ? asiaBg : na)
bgcolor(showLondon and inLondon ? londonBg : na)
bgcolor(showNY and inNY ? nyBg : na)

// High/Low Werte fortlaufend updaten
if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow  := na(asiaLow)  ? low  : math.min(asiaLow, low)

if inLondon
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow  := na(londonLow)  ? low  : math.min(londonLow, low)

if inNY
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow  := na(nyLow)  ? low  : math.min(nyLow, low)

// Linien plotten
plot(showLines and inAsia ? asiaHigh : na, "Asia High", asiaLineColor, 1, plot.style_linebr)
plot(showLines and inAsia ? asiaLow  : na, "Asia Low",  asiaLineColor, 1, plot.style_linebr)

plot(showLines and inLondon ? londonHigh : na, "London High", londonLineColor, 1, plot.style_linebr)
plot(showLines and inLondon ? londonLow  : na, "London Low",  londonLineColor, 1, plot.style_linebr)

plot(showLines and inNY ? nyHigh : na, "New York High", nyLineColor, 1, plot.style_linebr)
plot(showLines and inNY ? nyLow  : na, "New York Low",  nyLineColor, 1, plot.style_linebr)
````
