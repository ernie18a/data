# SPY + QQQ-Implied Daily SMAs

- url: https://www.tradingview.com/script/Sx7ZEd33-SPY-QQQ-Implied-Daily-SMAs/
- type: indicator
- pine_id: PUB;6032e2ad27b84b339aa003b88a67cdec
- version: 2.0

## Description

Displays SPY’s live 5/20/200-day SMAs and converts QQQ’s live 5/20/200-day SMAs into equivalent SPY chart levels using the current SPY/QQQ ratio.

## Source Code

````pine
//@version=5
indicator("Live SPY + QQQ-Implied Daily SMAs", overlay=true, max_labels_count=50)

// Locked symbols
spySymbol = "AMEX:SPY"
qqqSymbol = "NASDAQ:QQQ"

// Inputs
showSPYActual = input.bool(true, "Show SPY Actual SMAs")
showQQQImplied = input.bool(true, "Show QQQ-Implied SPY Levels")
labelOffset = input.int(5, "Label Offset Bars", minval=1)
smoothLen = input.int(1, "Smoothing Factor", minval=1)

// Live daily SMA recalculated intraday
liveDailySMA(symbol, len) =>
    currentPrice = request.security(symbol, timeframe.period, close)

    priorDailySum = request.security(
         symbol,
         "D",
         math.sum(close[1], len - 1),
         lookahead = barmerge.lookahead_on
     )

    (currentPrice + priorDailySum) / len

// Smoothing function
smooth(src) =>
    smoothLen > 1 ? ta.sma(src, smoothLen) : src

// Current live prices
spyPrice = request.security(spySymbol, timeframe.period, close)
qqqPrice = request.security(qqqSymbol, timeframe.period, close)

// SPY actual live daily SMAs
spy5Raw   = liveDailySMA(spySymbol, 5)
spy20Raw  = liveDailySMA(spySymbol, 20)
spy200Raw = liveDailySMA(spySymbol, 200)

// QQQ actual live daily SMAs
qqq5Raw   = liveDailySMA(qqqSymbol, 5)
qqq20Raw  = liveDailySMA(qqqSymbol, 20)
qqq200Raw = liveDailySMA(qqqSymbol, 200)

// QQQ-implied SPY levels, raw
qqqImpliedSpy5Raw   = spyPrice * (qqq5Raw / qqqPrice)
qqqImpliedSpy20Raw  = spyPrice * (qqq20Raw / qqqPrice)
qqqImpliedSpy200Raw = spyPrice * (qqq200Raw / qqqPrice)

// Apply one smoothing factor to all plotted lines
spy5   = smooth(spy5Raw)
spy20  = smooth(spy20Raw)
spy200 = smooth(spy200Raw)

qqqImpliedSpy5   = smooth(qqqImpliedSpy5Raw)
qqqImpliedSpy20  = smooth(qqqImpliedSpy20Raw)
qqqImpliedSpy200 = smooth(qqqImpliedSpy200Raw)

// Colors
col5   = color.yellow
col20  = color.red
col200 = color.green

qqqCol5   = color.new(color.yellow, 50)
qqqCol20  = color.new(color.red, 50)
qqqCol200 = color.new(color.green, 50)

// SPY actual SMA lines
plot(showSPYActual ? spy5 : na,   title="SPY Actual 5MA",   color=col5,   linewidth=1)
plot(showSPYActual ? spy20 : na,  title="SPY Actual 20MA",  color=col20,  linewidth=1)
plot(showSPYActual ? spy200 : na, title="SPY Actual 200MA", color=col200, linewidth=1)

// QQQ-implied SPY levels
plot(showQQQImplied ? qqqImpliedSpy5 : na,   title="QQQ Implied 5MA",   color=qqqCol5,   linewidth=1)
plot(showQQQImplied ? qqqImpliedSpy20 : na,  title="QQQ Implied 20MA",  color=qqqCol20,  linewidth=1)
plot(showQQQImplied ? qqqImpliedSpy200 : na, title="QQQ Implied 200MA", color=qqqCol200, linewidth=1)

// Floating labels
var label spy5Label   = na
var label spy20Label  = na
var label spy200Label = na
var label qqq5Label   = na
var label qqq20Label  = na
var label qqq200Label = na

makeLabel(oldLabel, enabled, y, txt, bgColor, txtColor) =>
    label.delete(oldLabel)
    enabled and not na(y) ? label.new(
         x = bar_index + labelOffset,
         y = y,
         text = txt,
         xloc = xloc.bar_index,
         yloc = yloc.price,
         style = label.style_label_left,
         color = bgColor,
         textcolor = txtColor,
         size = size.small
     ) : na

if barstate.islast
    spy5Label   := makeLabel(spy5Label,   showSPYActual, spy5,   "SPY 5MA",   col5,   color.black)
    spy20Label  := makeLabel(spy20Label,  showSPYActual, spy20,  "SPY 20MA",  col20,  color.white)
    spy200Label := makeLabel(spy200Label, showSPYActual, spy200, "SPY 200MA", col200, color.white)

qqq5Label   := makeLabel(qqq5Label,   showQQQImplied, qqqImpliedSpy5,   "QQQ Implied 5MA",   qqqCol5,   color.black)
qqq20Label  := makeLabel(qqq20Label,  showQQQImplied, qqqImpliedSpy20,  "QQQ Implied 20MA",  qqqCol20,  color.white)
qqq200Label := makeLabel(qqq200Label, showQQQImplied, qqqImpliedSpy200, "QQQ Implied 200MA", qqqCol200, color.white)
````
