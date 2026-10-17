# FAN EMA Scalper 

- url: https://www.tradingview.com/script/lvu7TAN8-FAN-EMA-Scalper/
- type: indicator
- pine_id: PUB;a34bd5ff168f4ffba8660e48fa9d0ece
- version: 1.0

## Description

A multi-timeframe EMA trading toolkit designed for traders who want higher-timeframe context, trend confirmation, breakout detection, and clean chart visualization in one indicator. Built for scalping, day trading, and swing trading

## Source Code

````pine
//@version=6
indicator("Tony's EMA Scalper - MTF EMA Labels", shorttitle="EMA Scalper MTF", overlay=true, max_labels_count=500)

// =========================
// Inputs
// =========================
lenMain         = input.int(20, minval=1, title="Main EMA Length")
src             = input.source(close, title="Source")

showEMA500      = input.bool(true,  title="Show EMA 500")
showEMA300      = input.bool(true,  title="Show EMA 300")
showEMA200      = input.bool(true,  title="Show EMA 200")
showEMA100      = input.bool(true,  title="Show EMA 100")
showEMA50       = input.bool(true,  title="Show EMA 50")
showEMA21       = input.bool(true,  title="Show EMA 21")
showEMA12       = input.bool(true,  title="Show EMA 12")

show1mEMA       = input.bool(true,  title="Show Fixed 1m EMA")
show5mEMA       = input.bool(true,  title="Show Fixed 5m EMA")
show30mEMA      = input.bool(true,  title="Show Fixed 30m EMA")
show1hEMA       = input.bool(true,  title="Show Fixed 1H EMA")
showDailyEMA   = input.bool(true,  title="Show Fixed Daily EMA")
showWeeklyEMA  = input.bool(true,  title="Show Fixed Weekly EMA")
showMonthlyEMA = input.bool(true,  title="Show Fixed Monthly EMA")
showQuarterlyEMA = input.bool(true, title="Show Fixed Quarterly EMA")

fixedEmaLen     = input.int(27, minval=1, title="Fixed EMA Length")
fixedLineWidth  = input.int(5, minval=1, maxval=10, title="Fixed EMA Line Width")

showFixedLabels = input.bool(true,  title="Show Fixed EMA Price Labels")
showEmaTags     = input.bool(true,  title="Show EMA Tags 12 / 21 / 50 / 100")
showTrendLabel  = input.bool(true,  title="Show Trend Status Label")
labelOffset     = input.int(1, minval=1, title="Label Offset Right")

showRange       = input.bool(true,  title="Show Recent Range High / Low")
rangeLen        = input.int(8, minval=1, title="Range Lookback")

showSignals     = input.bool(true,  title="Show Buy / Sell Signals")
showBreakouts   = input.bool(true,  title="Show BO / BD Signals")
useStackFilter  = input.bool(true,  title="Filter Signals With EMA Stack")
showBgTrend     = input.bool(true,  title="Show Bull / Bear Background")

// =========================
// Main EMA
// =========================
mainEMA = ta.ema(src, lenMain)
plot(mainEMA, title="Main EMA", color=color.orange)


// =========================
// Regular EMA Timeframe Override
// =========================
useEmaTfOverride = input.bool(false, "Override Regular EMA Timeframe")

emaTfOverride = input.timeframe(
     "D",
     "Regular EMA Timeframe",
     options=["1","5","15","30","60","240","D","W","M"]
)

emaTf = useEmaTfOverride ? emaTfOverride : timeframe.period

// =========================
// Standard chart timeframe EMAs
// =========================
ema500 = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, 500),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

ema300 = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, 300),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

ema200 = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, 200),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

ema100 = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, 100),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

ema50 = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, 50),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

ema21 = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, 21),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

ema12 = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, 12),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

plot(showEMA500 ? ema500 : na, color=color.teal,   title="EMA 500")
plot(showEMA300 ? ema300 : na, color=color.white,  title="EMA 300")
plot(showEMA200 ? ema200 : na, color=color.purple, title="EMA 200")
plot(showEMA100 ? ema100 : na, color=color.red,    title="EMA 100")
plot(showEMA50  ? ema50  : na, color=color.yellow, title="EMA 50")
plot(showEMA21  ? ema21  : na, color=color.green,  title="EMA 21")
plot(showEMA12  ? ema12  : na, color=color.blue,   title="EMA 12")

// =========================
// EMA Stack Trend Filter
// =========================
bullStack = ema12 > ema21 and ema21 > ema50 and ema50 > ema100
bearStack = ema12 < ema21 and ema21 < ema50 and ema50 < ema100

bgcolor(showBgTrend and bullStack ? color.new(color.green, 92) : na, title="Bull Stack Background")
bgcolor(showBgTrend and bearStack ? color.new(color.red, 92) : na, title="Bear Stack Background")

// =========================
// Recent range using true highs/lows
// =========================
rangeHigh = ta.highest(high, rangeLen)
rangeLow  = ta.lowest(low, rangeLen)

plot(showRange ? rangeHigh : na, title="Range High", color=color.red, linewidth=2)
plot(showRange ? rangeLow : na, title="Range Low", color=color.green, linewidth=2)

// =========================
// Buy / Sell logic
// =========================
crossMain = ta.cross(close, mainEMA)

bullishRaw = crossMain and close[1] < close
bearishRaw = crossMain and close[1] > close

bullish = useStackFilter ? (bullishRaw and bullStack) : bullishRaw
bearish = useStackFilter ? (bearishRaw and bearStack) : bearishRaw

plotshape(showSignals and bullish, color=color.green, style=shape.arrowup,   text="Buy",  location=location.belowbar, title="Buy Signal")
plotshape(showSignals and bearish, color=color.red,   style=shape.arrowdown, text="Sell", location=location.abovebar, title="Sell Signal")

// =========================
// Range breakout logic
// Uses prior bar range for confirmation
// =========================
breakoutUpRaw   = close > rangeHigh[1]
breakoutDownRaw = close < rangeLow[1]

breakoutUp   = useStackFilter ? (breakoutUpRaw and bullStack) : breakoutUpRaw
breakoutDown = useStackFilter ? (breakoutDownRaw and bearStack) : breakoutDownRaw

plotshape(showBreakouts and breakoutUp,   color=color.lime,   style=shape.triangleup,   location=location.belowbar, title="Range Breakout Up",   text="BO")
plotshape(showBreakouts and breakoutDown, color=color.maroon, style=shape.triangledown, location=location.abovebar, title="Range Breakout Down", text="BD")

// =========================
// Fixed timeframe EMAs
// =========================
emaFixed_1m   = request.security(syminfo.tickerid, "1",  ta.ema(close, fixedEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaFixed_5m   = request.security(syminfo.tickerid, "5",  ta.ema(close, fixedEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaFixed_30m  = request.security(syminfo.tickerid, "30", ta.ema(close, fixedEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaFixed_1h   = request.security(syminfo.tickerid, "60", ta.ema(close, fixedEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaFixed_D    = request.security(syminfo.tickerid, "D",  ta.ema(close, fixedEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaFixed_W    = request.security(syminfo.tickerid, "W",  ta.ema(close, fixedEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaFixed_M    = request.security(syminfo.tickerid, "M",  ta.ema(close, fixedEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
emaFixed_Q    = request.security(syminfo.tickerid, "3M", ta.ema(close, fixedEmaLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

plot(show1mEMA ? emaFixed_1m : na, color=color.white, linewidth=fixedLineWidth, title="Fixed 1m EMA")
plot(show5mEMA ? emaFixed_5m : na, color=color.aqua, linewidth=fixedLineWidth, title="Fixed 5m EMA")
plot(show30mEMA ? emaFixed_30m : na, color=color.orange, linewidth=fixedLineWidth, title="Fixed 30m EMA")
plot(show1hEMA ? emaFixed_1h : na, color=color.fuchsia, linewidth=fixedLineWidth, title="Fixed 1H EMA")
plot(showDailyEMA ? emaFixed_D : na, color=color.lime, linewidth=fixedLineWidth, title="Fixed Daily EMA")
plot(showWeeklyEMA ? emaFixed_W : na, color=color.red, linewidth=fixedLineWidth, title="Fixed Weekly EMA")
plot(showMonthlyEMA ? emaFixed_M : na, color=color.blue, linewidth=fixedLineWidth, title="Fixed Monthly EMA")
plot(showQuarterlyEMA ? emaFixed_Q : na, color=color.purple, linewidth=fixedLineWidth, title="Fixed Quarterly EMA")

// =========================
// Fixed EMA price labels
// =========================
var label lbl1m   = na
var label lbl5m   = na
var label lbl30m  = na
var label lbl1h   = na
var label lblD    = na
var label lblW    = na
var label lblM    = na
var label lblQ    = na

if barstate.islast
    label.delete(lbl1m)
    label.delete(lbl5m)
    label.delete(lbl30m)
    label.delete(lbl1h)
    label.delete(lblD)
    label.delete(lblW)
    label.delete(lblM)
    label.delete(lblQ)

    if showFixedLabels and show1mEMA
        lbl1m := label.new(
             x = bar_index + labelOffset,
             y = emaFixed_1m,
             text = "1m - " + str.tostring(emaFixed_1m, format.mintick),
             style = label.style_label_left,
             textcolor = color.white,
             color = color.new(color.black, 0),
             size = size.small)

    if showFixedLabels and show5mEMA
        lbl5m := label.new(
             x = bar_index + labelOffset,
             y = emaFixed_5m,
             text = "5m - " + str.tostring(emaFixed_5m, format.mintick),
             style = label.style_label_left,
             textcolor = color.aqua,
             color = color.new(color.black, 0),
             size = size.small)

    if showFixedLabels and show30mEMA
        lbl30m := label.new(
             x = bar_index + labelOffset,
             y = emaFixed_30m,
             text = "30m - " + str.tostring(emaFixed_30m, format.mintick),
             style = label.style_label_left,
             textcolor = color.orange,
             color = color.new(color.black, 0),
             size = size.small)

    if showFixedLabels and show1hEMA
        lbl1h := label.new(
             x = bar_index + labelOffset,
             y = emaFixed_1h,
             text = "1H - " + str.tostring(emaFixed_1h, format.mintick),
             style = label.style_label_left,
             textcolor = color.fuchsia,
             color = color.new(color.black, 0),
             size = size.small)

    if showFixedLabels and showDailyEMA
        lblD := label.new(
             x = bar_index + labelOffset,
             y = emaFixed_D,
             text = "D - " + str.tostring(emaFixed_D, format.mintick),
             style = label.style_label_left,
             textcolor = color.lime,
             color = color.new(color.black, 0),
             size = size.small)

    if showFixedLabels and showWeeklyEMA
        lblW := label.new(
             x = bar_index + labelOffset,
             y = emaFixed_W,
             text = "W - " + str.tostring(emaFixed_W, format.mintick),
             style = label.style_label_left,
             textcolor = color.red,
             color = color.new(color.black, 0),
             size = size.small)

    if showFixedLabels and showMonthlyEMA
        lblM := label.new(
             x = bar_index + labelOffset,
             y = emaFixed_M,
             text = "M - " + str.tostring(emaFixed_M, format.mintick),
             style = label.style_label_left,
             textcolor = color.blue,
             color = color.new(color.black, 0),
             size = size.small)

    if showFixedLabels and showQuarterlyEMA
        lblQ := label.new(
             x = bar_index + labelOffset,
             y = emaFixed_Q,
             text = "Q - " + str.tostring(emaFixed_Q, format.mintick),
             style = label.style_label_left,
             textcolor = color.purple,
             color = color.new(color.black, 0),
             size = size.small)

// =========================
// EMA number tags
// =========================
var label lbl12  = na
var label lbl21  = na
var label lbl50  = na
var label lbl100 = na
var label lbl200 = na

if barstate.islast
    label.delete(lbl12)
    label.delete(lbl21)
    label.delete(lbl50)
    label.delete(lbl100)
    label.delete(lbl200)

    if showEmaTags and showEMA12
        lbl12 := label.new(
             x = bar_index + labelOffset,
             y = ema12,
             text = "12",
             style = label.style_label_left,
             textcolor = color.blue,
             color = color.new(color.black, 80),
             size = size.small)

    if showEmaTags and showEMA21
        lbl21 := label.new(
             x = bar_index + labelOffset,
             y = ema21,
             text = "21",
             style = label.style_label_left,
             textcolor = color.green,
             color = color.new(color.black, 80),
             size = size.small)

    if showEmaTags and showEMA50
        lbl50 := label.new(
             x = bar_index + labelOffset,
             y = ema50,
             text = "50",
             style = label.style_label_left,
             textcolor = color.yellow,
             color = color.new(color.black, 80),
             size = size.small)

    if showEmaTags and showEMA100
        lbl100 := label.new(
             x = bar_index + labelOffset,
             y = ema100,
             text = "100",
             style = label.style_label_left,
             textcolor = color.red,
             color = color.new(color.black, 80),
             size = size.small)

    if showEmaTags and showEMA200
        lbl200 := label.new(
             x = bar_index + labelOffset,
             y = ema200,
             text = "200",
             style = label.style_label_left,
             textcolor = color.purple,
             color = color.new(color.black, 80),
             size = size.small)
// =========================
// Trend status label
// =========================
var label trendLbl = na

if barstate.islast
    label.delete(trendLbl)

    trendText  = bullStack ? "BULL STACK" : bearStack ? "BEAR STACK" : "MIXED"
    trendColor = bullStack ? color.green : bearStack ? color.red : color.gray

    if showTrendLabel
        trendLbl := label.new(
             x = bar_index + labelOffset,
             y = high,
             text = trendText,
             style = label.style_label_left,
             textcolor = color.white,
             color = trendColor,
             size = size.small)

// =========================
// Alerts
// =========================
crossUp1m    = ta.crossover(close, emaFixed_1m)
crossDown1m  = ta.crossunder(close, emaFixed_1m)

crossUp5m    = ta.crossover(close, emaFixed_5m)
crossDown5m  = ta.crossunder(close, emaFixed_5m)

crossUp30m   = ta.crossover(close, emaFixed_30m)
crossDown30m = ta.crossunder(close, emaFixed_30m)

crossUp1h    = ta.crossover(close, emaFixed_1h)
crossDown1h  = ta.crossunder(close, emaFixed_1h)

crossUpD    = ta.crossover(close, emaFixed_D)
crossDownD  = ta.crossunder(close, emaFixed_D)

crossUpW    = ta.crossover(close, emaFixed_W)
crossDownW  = ta.crossunder(close, emaFixed_W)

crossUpM    = ta.crossover(close, emaFixed_M)
crossDownM  = ta.crossunder(close, emaFixed_M)

crossUpQ    = ta.crossover(close, emaFixed_Q)
crossDownQ  = ta.crossunder(close, emaFixed_Q)

alertcondition(crossUp1m,    title="Cross Up 1m Fixed EMA",    message="Price crossed above the fixed 1m EMA")
alertcondition(crossDown1m,  title="Cross Down 1m Fixed EMA",  message="Price crossed below the fixed 1m EMA")

alertcondition(crossUp5m,    title="Cross Up 5m Fixed EMA",    message="Price crossed above the fixed 5m EMA")
alertcondition(crossDown5m,  title="Cross Down 5m Fixed EMA",  message="Price crossed below the fixed 5m EMA")

alertcondition(crossUp30m,   title="Cross Up 30m Fixed EMA",   message="Price crossed above the fixed 30m EMA")
alertcondition(crossDown30m, title="Cross Down 30m Fixed EMA", message="Price crossed below the fixed 30m EMA")

alertcondition(crossUp1h,    title="Cross Up 1H Fixed EMA",    message="Price crossed above the fixed 1H EMA")
alertcondition(crossDown1h,  title="Cross Down 1H Fixed EMA",  message="Price crossed below the fixed 1H EMA")

alertcondition(crossUpD,   title="Cross Up Daily Fixed EMA",   message="Price crossed above the fixed Daily EMA")
alertcondition(crossDownD, title="Cross Down Daily Fixed EMA", message="Price crossed below the fixed Daily EMA")

alertcondition(crossUpW,   title="Cross Up Weekly Fixed EMA",   message="Price crossed above the fixed Weekly EMA")
alertcondition(crossDownW, title="Cross Down Weekly Fixed EMA", message="Price crossed below the fixed Weekly EMA")

alertcondition(crossUpM,   title="Cross Up Monthly Fixed EMA",   message="Price crossed above the fixed Monthly EMA")
alertcondition(crossDownM, title="Cross Down Monthly Fixed EMA", message="Price crossed below the fixed Monthly EMA")

alertcondition(crossUpQ,   title="Cross Up Quarterly Fixed EMA",   message="Price crossed above the fixed Quarterly EMA")
alertcondition(crossDownQ, title="Cross Down Quarterly Fixed EMA", message="Price crossed below the fixed Quarterly EMA")

alertcondition(breakoutUp,   title="Breakout Above Range High", message="Price closed above the previous range high")
alertcondition(breakoutDown, title="Breakout Below Range Low",  message="Price closed below the previous range low")

alertcondition(bullish,      title="Buy Signal",  message="Buy signal triggered")
alertcondition(bearish,      title="Sell Signal", message="Sell signal triggered")
````
