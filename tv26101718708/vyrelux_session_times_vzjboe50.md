# VyreLux Session Times 

- url: https://www.tradingview.com/script/VZJBOE50-VyreLux-Session-Times/
- type: indicator
- pine_id: PUB;2fbee007635e423a8952c637930ec873
- version: 1.0

## Description

Marks out session times for almost any time zone utc 4,5,6,7,8. Enjoy for anyone using this.

## Source Code

````pine
//@version=6
indicator("VyreLux Session Times (Safe Multi-Timezone)", overlay=true)

// =========================
// USER TIMEZONE
// =========================
tz = input.string("Etc/GMT+6", "Chart Timezone",
     options=["Etc/GMT+8","Etc/GMT+7","Etc/GMT+6","Etc/GMT+5","Etc/GMT+4"])

// =========================
// SESSIONS
// =========================
asia      = not na(time(timeframe.period, "1600-2300", tz))
london    = not na(time(timeframe.period, "0100-0630", tz))
preMarket = not na(time(timeframe.period, "0630-0730", tz))
nyAM      = not na(time(timeframe.period, "0730-1030", tz))
lunch     = not na(time(timeframe.period, "1030-1330", tz))
nyPM      = not na(time(timeframe.period, "1330-1455", tz))

// =========================
// DEAD ZONES
// =========================
dead1 = not na(time(timeframe.period, "2300-0100", tz))
dead2 = not na(time(timeframe.period, "1455-1600", tz))

// =========================
// COLORS
// =========================
asiaColor      = input.color(color.blue, "Asia Color")
londonColor    = input.color(color.purple, "London Color")
nyColor        = input.color(color.green, "NY AM Color")
preColor       = input.color(color.orange, "Pre-Market Color")
lunchColor     = input.color(color.yellow, "Lunch Color")
nyPMColor      = input.color(color.red, "NY PM Color")
deadColor      = input.color(color.gray, "Dead Zone Color")

// =========================
// BACKGROUND
// =========================
bgcolor(asia      ? color.new(asiaColor, 88)   : na)
bgcolor(london    ? color.new(londonColor, 88) : na)
bgcolor(preMarket ? color.new(preColor, 88)    : na)
bgcolor(nyAM      ? color.new(nyColor, 85)     : na)
bgcolor(lunch     ? color.new(lunchColor, 88)  : na)
bgcolor(nyPM      ? color.new(nyPMColor, 88)   : na)

bgcolor(dead1 ? color.new(deadColor, 92) : na)
bgcolor(dead2 ? color.new(deadColor, 92) : na)

// =========================
// LABELS
// =========================
showLabels = input.bool(true, "Show Labels")
isNew(x) => x and not x[1]

// offset to lift labels above candles
offset = ta.atr(14) * 0.8

// =========================
// ASIA
// =========================
if showLabels and isNew(asia)
    label.new(bar_index, high + offset, "ASIA OPEN", color=asiaColor, textcolor=color.white)

if showLabels and not asia and asia[1]
    label.new(bar_index, high + offset, "ASIA END", color=asiaColor, textcolor=color.white)

// =========================
// LONDON
// =========================
if showLabels and isNew(london)
    label.new(bar_index, high + offset, "LONDON OPEN", color=londonColor, textcolor=color.white)

if showLabels and not london and london[1]
    label.new(bar_index, high + offset, "LONDON END", color=londonColor, textcolor=color.white)

// =========================
// PRE-MARKET
// =========================
if showLabels and isNew(preMarket)
    label.new(bar_index, high + offset, "PRE-MARKET OPEN", color=preColor, textcolor=color.white)

// =========================
// NY
// =========================
if showLabels and isNew(nyAM)
    label.new(bar_index, high + offset, "NY OPEN", color=nyColor, textcolor=color.white)

if showLabels and not nyAM and nyAM[1]
    label.new(bar_index, high + offset, "NY AM END", color=nyColor, textcolor=color.white)

// =========================
// LUNCH
// =========================
if showLabels and isNew(lunch)
    label.new(bar_index, high + offset, "LUNCH OPEN", color=lunchColor, textcolor=color.white)

if showLabels and not lunch and lunch[1]
    label.new(bar_index, high + offset, "LUNCH END", color=lunchColor, textcolor=color.white)

// =========================
// NY PM
// =========================
if showLabels and isNew(nyPM)
    label.new(bar_index, high + offset, "NY PM OPEN", color=nyPMColor, textcolor=color.white)

if showLabels and not nyPM and nyPM[1]
    label.new(bar_index, high + offset, "NY PM END", color=nyPMColor, textcolor=color.white)
````
