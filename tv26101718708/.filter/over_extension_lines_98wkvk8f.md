# Over Extension Lines

- url: https://www.tradingview.com/script/98WKVk8f-Over-Extension-Lines/
- type: indicator
- pine_id: PUB;13cb6d588eb6433fa726a13674093633
- version: 1.0

## Description

Takes yesterday's range and projects it onto today to show where price is overcooked. It grabs the prior day's high, low, and range, throws up extension levels above and below, and draws the 9:30 to 9:45 opening range on top. When price tags an extension it's stretched relative to what yesterday actually did, which is where moves tend to stall or turn. Use the extensions as reversion targets and exhaustion spots, and the opening range as your first structure of the day. The prior-day numbers come off the last completed daily bar, so that reference doesn't repaint.

## Source Code

````pine
// ============================================================================
//  PUBLISH TITLE:  NQ Over Extension - prior-day range projections
//  (paste the lines below into the TradingView publish Description box)
// ----------------------------------------------------------------------------
//  Takes yesterday's range and projects it onto today to show where price is
//  overcooked. It grabs the prior day's high, low, and range, throws up
//  extension levels above and below, and draws the 9:30 to 9:45 opening range
//  on top. When price tags an extension it's stretched relative to what
//  yesterday actually did, which is where moves tend to stall or turn. Use
//  the extensions as reversion targets and exhaustion spots, and the opening
//  range as your first structure of the day. The prior-day numbers come off
//  the last completed daily bar, so that reference doesn't repaint.
// ============================================================================
//
//@version=6
indicator('NQ Over Extension', overlay = true)

// === PREVIOUS DAY HIGH/LOW ===
prevDayHigh = request.security(syminfo.tickerid, 'D', high[1], lookahead = barmerge.lookahead_on)
prevDayLow = request.security(syminfo.tickerid, 'D', low[1], lookahead = barmerge.lookahead_on)
prevDayRange = prevDayHigh - prevDayLow

pdUpperExt = prevDayLow + prevDayRange * 1.3414
pdLowerExt = prevDayLow + prevDayRange * -0.3414

// === NY OPENING RANGE (First 15 min: 9:30 - 9:45 ET) ===
nyOpenTime = timestamp('America/New_York', year, month, dayofmonth, 9, 30, 0)
nyCloseTime = timestamp('America/New_York', year, month, dayofmonth, 9, 45, 0)

var float orHigh = na
var float orLow = na
var bool orDone = false

isNewDay = ta.change(time('D'))
if bool(isNewDay)
    orHigh := na
    orLow := na
    orDone := false
    orDone

inOR = time >= nyOpenTime and time < nyCloseTime
if inOR
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow := na(orLow) ? low : math.min(orLow, low)
    orLow

if time >= nyCloseTime and not orDone
    orDone := true
    orDone

orRange = orHigh - orLow
orUpperExt = orDone ? orLow + orRange * 1.3414 : na
orLowerExt = orDone ? orLow + orRange * -0.3414 : na

// === SINGLE LINE PER SIDE (higher of the two for longs, lower of the two for shorts) ===
upperLine = orDone ? math.max(pdUpperExt, orUpperExt) : pdUpperExt
lowerLine = orDone ? math.min(pdLowerExt, orLowerExt) : pdLowerExt

// === OVER EXTENSION LOGIC (longs only for now) ===
overExtUp = close > upperLine

// === PLOTS ===
plot(upperLine, 'Upper OE Line', color = color.red, linewidth = 2)
plot(lowerLine, 'Lower OE Line', color = color.green, linewidth = 2)

// === LABELS ===
plotshape(overExtUp and not overExtUp[1], title = 'OE Up', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small)
````
