# Session Breakout ATR Levels

- url: https://www.tradingview.com/script/Kvj0Ynd6-Session-Breakout-ATR-Levels/
- type: indicator
- pine_id: PUB;322cfb902ea34f09abbdd1bfc196d789
- version: 1.0

## Description

This script is an institutional-style intraday trading framework designed primarily for NQ/MNQ futures trading. It combines a New York session anchor price, ATR-based expansion levels, London session high and low liquidity zones, EMA trend filters, and a smooth session trendline to create a complete market structure map for the trading day. The script uses the 6:00 PM New York open as the session baseline and projects volatility levels above and below it using ATR calculations, which act as breakout triggers, targets, and exhaustion zones. It also tracks the London session range to identify important liquidity pools and breakout areas that often influence New York price action. The custom session trendline provides a visual representation of overall directional bias and momentum throughout the session, while the EMAs help confirm trend alignment and momentum continuation. In strategy mode, the script converts these levels into rule-based trade entries and exits, allowing traders to backtest breakout and momentum setups using ATR targets, London range breaks, and EMA confirmation. Overall, the system is built to help identify high-probability trend and volatility expansion moves during active market sessions while filtering out weaker or choppy conditions.

## Source Code

````pine
//@version=5
indicator("Session Breakout ATR Levels", overlay=true, max_bars_back=500, max_lines_count=500, max_labels_count=500)

openHour   = input.int(18, "Open Hour NY")
openMinute = input.int(0, "Open Minute NY")
atrLen     = input.int(14, "ATR Length Daily")

showLondon = input.bool(true, "Show London High/Low")
londonSess = input.session("0230-0730", "London Session NY Time")

showSessionTrend = input.bool(true, "Show Session Trendline")
trendSess        = input.session("2200-1300", "Trendline Session NY Time")
trendColor       = input.color(color.black, "Trendline Color")
trendWidth       = input.int(1, "Trendline Width")

showEMA9   = input.bool(true, "9 Day EMA")
showEMA21  = input.bool(false, "21 Day EMA")
showEMA50  = input.bool(false, "50 Day EMA")
showEMA200 = input.bool(false, "200 Day EMA")

ema9Color   = input.color(color.blue, "9 EMA Color")
ema21Color  = input.color(color.rgb(234,170,120), "21 EMA Color")
ema50Color  = input.color(color.rgb(220,90,200), "50 EMA Color")
ema200Color = input.color(color.rgb(140,220,140), "200 EMA Color")

showSMA  = input.bool(false, "SMA 9")
smaLen   = input.int(9, "SMA Length")
smaSrc   = input.source(close, "SMA Source")
smaColor = input.color(color.yellow, "SMA Color")

showText      = input.bool(true, "Show Line Text")
labelBarsBack = input.int(8, "Text Position Bars Back")

posColor    = color.rgb(0,150,136)
negColor    = color.rgb(255,70,70)
londonColor = color.orange
anchorColor = color.gray

nyHour   = hour(time, "America/New_York")
nyMinute = minute(time, "America/New_York")
isNewAnchor = nyHour == openHour and nyMinute == openMinute

var float anchor = na
if isNewAnchor
    anchor := open

dailyATR = request.security(syminfo.tickerid, "D", ta.atr(atrLen), lookahead=barmerge.lookahead_on)

plus025  = anchor + dailyATR * 0.25
plus050  = anchor + dailyATR * 0.50
plus075  = anchor + dailyATR * 0.75
plus100  = anchor + dailyATR

minus025 = anchor - dailyATR * 0.25
minus050 = anchor - dailyATR * 0.50
minus075 = anchor - dailyATR * 0.75
minus100 = anchor - dailyATR

buyTrigger  = plus025
sellTrigger = minus025

inLondon = not na(time(timeframe.period, londonSess, "America/New_York"))

var float londonHigh = na
var float londonLow  = na

if isNewAnchor
    londonHigh := na
    londonLow  := na

if inLondon
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow  := na(londonLow) ? low : math.min(londonLow, low)

get_session_trend(session) =>
    var int len = 1
    var float cwma = na
    var float csma = na
    var float csma2 = na
    var float y1 = na
    var float y2 = na
    if session > session[1]
        len := 1
        cwma := close
        csma := close
        csma2 := close * close
    if session and session == session[1]
        len += 1
        csma += close
        csma2 += close * close
        cwma += close * len
        sma = csma / len
        wma = cwma / (len * (len + 1) / 2)
        y1 := 4 * sma - 3 * wma
        y2 := 3 * wma - 2 * sma
    [y1, y2]

set_session_line(session, y1, y2, lineColor, lineWidth) =>
    var line tl = na
    if session > session[1]
        tl := line.new(bar_index, close, bar_index, close, color=lineColor, width=lineWidth)
    if session and session == session[1]
        line.set_y1(tl, y1)
        line.set_xy2(tl, bar_index, y2)
        line.set_color(tl, lineColor)
        line.set_width(tl, lineWidth)

inTrend = math.sign(nz(time(timeframe.period, trendSess, "America/New_York")))

if showSessionTrend
    [trendY1, trendY2] = get_session_trend(inTrend)
    set_session_line(inTrend, trendY1, trendY2, trendColor, trendWidth)

ema9   = ta.ema(close, 9)
ema21  = ta.ema(close, 21)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)
smaValue = ta.sma(smaSrc, smaLen)

plot(anchor, "Open Anchor", anchorColor, 1)

plot(plus025, "+0.25 / Buy Trigger", posColor, 1)
plot(plus050, "+0.50 ATR", posColor, 1)
plot(plus075, "+0.75 ATR", posColor, 1)
plot(plus100, "FULL ATR", posColor, 1)

plot(minus025, "-0.25 / Sell Trigger", negColor, 1)
plot(minus050, "-0.50 ATR", negColor, 1)
plot(minus075, "-0.75 ATR", negColor, 1)
plot(minus100, "-FULL ATR", negColor, 1)

plot(showLondon ? londonHigh : na, "London High", londonColor, 1)
plot(showLondon ? londonLow : na, "London Low", londonColor, 1)

plot(showEMA9 ? ema9 : na, "9 Day EMA", ema9Color, 1)
plot(showEMA21 ? ema21 : na, "21 Day EMA", ema21Color, 1)
plot(showEMA50 ? ema50 : na, "50 Day EMA", ema50Color, 1)
plot(showEMA200 ? ema200 : na, "200 Day EMA", ema200Color, 1)
plot(showSMA ? smaValue : na, "SMA 9", smaColor, 1)

var label lblFullATR = na
var label lblHalfATR = na
var label lblNegFullATR = na
var label lblNegHalfATR = na
var label lblBuy = na
var label lblSell = na
var label lblLondonHigh = na
var label lblLondonLow = na
var label lblOpen = na

if barstate.islast and showText
    label.delete(lblFullATR)
    label.delete(lblHalfATR)
    label.delete(lblNegFullATR)
    label.delete(lblNegHalfATR)
    label.delete(lblBuy)
    label.delete(lblSell)
    label.delete(lblLondonHigh)
    label.delete(lblLondonLow)
    label.delete(lblOpen)

    xPos = bar_index - labelBarsBack

    lblFullATR := label.new(xPos, plus100, "FULL ATR", xloc=xloc.bar_index, style=label.style_none, textcolor=posColor, size=size.normal)
    lblHalfATR := label.new(xPos, plus050, "+1/2 ATR", xloc=xloc.bar_index, style=label.style_none, textcolor=posColor, size=size.normal)
    lblBuy := label.new(xPos, buyTrigger, "Buy trigger", xloc=xloc.bar_index, style=label.style_none, textcolor=posColor, size=size.normal)

    lblOpen := label.new(xPos, anchor, "Open", xloc=xloc.bar_index, style=label.style_none, textcolor=anchorColor, size=size.normal)

    lblSell := label.new(xPos, sellTrigger, "Sell trigger", xloc=xloc.bar_index, style=label.style_none, textcolor=negColor, size=size.normal)
    lblNegHalfATR := label.new(xPos, minus050, "-1/2 ATR", xloc=xloc.bar_index, style=label.style_none, textcolor=negColor, size=size.normal)
    lblNegFullATR := label.new(xPos, minus100, "-FULL ATR", xloc=xloc.bar_index, style=label.style_none, textcolor=negColor, size=size.normal)

    if showLondon
        lblLondonHigh := label.new(xPos, londonHigh, "London High", xloc=xloc.bar_index, style=label.style_none, textcolor=londonColor, size=size.normal)
        lblLondonLow := label.new(xPos, londonLow, "London Low", xloc=xloc.bar_index, style=label.style_none, textcolor=londonColor, size=size.normal)
````
