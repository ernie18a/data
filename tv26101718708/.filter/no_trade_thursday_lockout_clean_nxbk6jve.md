# NO TRADE THURSDAY - LOCKOUT (CLEAN)

- url: https://www.tradingview.com/script/nXBK6JVE-NO-TRADE-THURSDAY-LOCKOUT-CLEAN/
- type: indicator
- pine_id: PUB;38da21b2f5164ea394d8f9e3289fd9ff
- version: 1.0

## Description

For some reason trades dont work on thursday for me . So this completely disrupts thursday price action forcing me to not see or trade on thursday

## Source Code

````pine
//@version=5
indicator("NO TRADE THURSDAY - LOCKOUT (CLEAN)", overlay=true)

isThursday = dayofweek == dayofweek.thursday
newDay = ta.change(time("D"))

// Background block
bgcolor(isThursday ? color.black : na)

// Range
rangeSize = high - low

// Distorted bars (only on Thursday)
fakeOpen  = isThursday ? open  + rangeSize * 8  : na
fakeHigh  = isThursday ? high  + rangeSize * 15 : na
fakeLow   = isThursday ? low   - rangeSize * 15 : na
fakeClose = isThursday ? close - rangeSize * 8  : na

plotbar(fakeOpen, fakeHigh, fakeLow, fakeClose, color=color.red)

// --- CLEAN LINE BREAKING (no carryover)
upperLine = isThursday ? high + rangeSize * 20 : na
lowerLine = isThursday ? low  - rangeSize * 20 : na
midHigh   = isThursday ? close + rangeSize * 10 : na
midLow    = isThursday ? close - rangeSize * 10 : na

plot(upperLine, color=color.red, linewidth=8, style=plot.style_linebr)
plot(lowerLine, color=color.red, linewidth=8, style=plot.style_linebr)
plot(midHigh,   color=color.orange, linewidth=6, style=plot.style_linebr)
plot(midLow,    color=color.orange, linewidth=6, style=plot.style_linebr)

// Big label once per day
if isThursday and newDay
    label.new(bar_index, high, "🚫 THURSDAY LOCKOUT 🚫\nNO TRADES", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.huge)

// Repeating warning labels (only on Thursday bars)
if isThursday and bar_index % 20 == 0
    label.new(bar_index, close, "DON'T TRADE", style=label.style_label_center, color=color.red, textcolor=color.white, size=size.large)
````
