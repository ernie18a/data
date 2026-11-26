# EMA 5/13 Crossover  Indicator

- url: https://www.tradingview.com/script/AJi0VNrZ-EMA-5-13-Crossover-Indicator/
- type: indicator
- pine_id: PUB;8ea1a767ac764220a966a053dcbc142f
- version: 1.0

## Description

EMA 5/13 Crossover

signals when the 2 emas cross over with a multi time frame dashboard

## Source Code

````pine
//@version=6
indicator("EMA 5/13 Crossover — Indicator", overlay=true)

// === Parameters (indicator-only) === //
showEMATrendBox  = input.bool(true, "Show EMA Trend Box (Multi-TF)")
showVWAP         = input.bool(true, "Show VWAP (Base Line)")
showDev1         = input.bool(false, "Show VWAP ±1σ")
showDev2         = input.bool(false, "Show VWAP ±2σ")
showDev3         = input.bool(false, "Show VWAP ±3σ")
deviationPeriod  = input.int(50, "Deviation Period")
smoothing         = input.int(5,  "Deviation Smoothing")
useRetestMarkers = input.bool(true, "Show First Retest Markers of EMA13 after Cross")

// === EMAs / WMA === //
ema5  = ta.ema(close, 5)
ema13 = ta.ema(close, 13)
wma96  = ta.wma(close, 96)

plot(ema5,  title="EMA 5",  color=color.green, linewidth=2)
plot(ema13, title="EMA 13", color=color.red,   linewidth=2)
plot(wma96,  title="WMA 96",  color=color.white, linewidth=1)

// === Crosses === //
bullishCross = ta.crossover(ema5, ema13)
bearishCross = ta.crossunder(ema5, ema13)

// Mark the cross on the EMA5 line position for visibility
plot(bullishCross ? ema5 : na, title="Bullish EMA Cross", color=color.yellow, style=plot.style_cross, linewidth=4)
plot(bearishCross ? ema5 : na, title="Bearish EMA Cross", color=color.yellow, style=plot.style_cross, linewidth=4)

// === VWAP & deviations === //
vwapSrc = (high + low + close) / 3
sessStamp = time("D")
isDelayedFirstBarOfSession = nz(sessStamp[1]) != nz(sessStamp[2])

var float cumPV = 0.0
var float cumV  = 0.0

if isDelayedFirstBarOfSession
    cumPV := 0.0
    cumV  := 0.0

cumPV += vwapSrc * volume
cumV  += volume
vwap = cumPV / cumV

hloc4 = (high + low + open + close) / 4
rollingDev  = ta.stdev(hloc4, deviationPeriod)
smoothedDev = ta.ema(rollingDev, smoothing)

vwapUpper1 = vwap + smoothedDev
vwapLower1 = vwap - smoothedDev
vwapUpper2 = vwap + smoothedDev * 2 
vwapLower2 = vwap - smoothedDev * 2
vwapUpper3 = vwap + smoothedDev * 3
vwapLower3 = vwap - smoothedDev * 3

plot(showVWAP ? vwap : na,             title="VWAP (Session)", color=color.blue, linewidth=1)
plot(showDev1 ? vwapUpper1 : na,       title="VWAP +1σ", color=color.gray)
plot(showDev1 ? vwapLower1 : na,       title="VWAP -1σ", color=color.gray)
plot(showDev2 ? vwapUpper2 : na,       title="VWAP +2σ", color=color.gray)
plot(showDev2 ? vwapLower2 : na,       title="VWAP -2σ", color=color.gray)
plot(showDev3 ? vwapUpper3 : na,       title="VWAP +3σ", color=color.gray)
plot(showDev3 ? vwapLower3 : na,       title="VWAP -3σ", color=color.gray)

// === First Retest markers of EMA13 following a cross === //
var bool waitLongRetest  = false
var bool waitShortRetest = false

if useRetestMarkers
    if bullishCross
        waitLongRetest  := true
        waitShortRetest := false
    if bearishCross
        waitShortRetest := true
        waitLongRetest  := false

firstLongRetest  = useRetestMarkers and waitLongRetest  and low  <= ema13
firstShortRetest = useRetestMarkers and waitShortRetest and high >= ema13

if firstLongRetest
    waitLongRetest := false
if firstShortRetest
    waitShortRetest := false

plotshape(firstLongRetest,  title="Long Retest Marker",  style=shape.diamond, location=location.belowbar, color=color.green, size=size.small, text="RT↑")
plotshape(firstShortRetest, title="Short Retest Marker", style=shape.diamond, location=location.abovebar, color=color.red,   size=size.small, text="RT↓")

// === Multi-Timeframe EMA Trend Box (updated to 5/13) === //
ema5_3m    = request.security(syminfo.tickerid, "3",   ta.ema(close, 5))
ema13_3m   = request.security(syminfo.tickerid, "3",   ta.ema(close, 13))
ema5_5m    = request.security(syminfo.tickerid, "5",   ta.ema(close, 5))
ema13_5m   = request.security(syminfo.tickerid, "5",   ta.ema(close, 13))
ema5_12m   = request.security(syminfo.tickerid, "12",  ta.ema(close, 5))
ema13_12m  = request.security(syminfo.tickerid, "12",  ta.ema(close, 13))
ema5_15m   = request.security(syminfo.tickerid, "15",  ta.ema(close, 5))
ema13_15m  = request.security(syminfo.tickerid, "15",  ta.ema(close, 13))
ema5_30m   = request.security(syminfo.tickerid, "30",  ta.ema(close, 5))
ema13_30m  = request.security(syminfo.tickerid, "30",  ta.ema(close, 13))
ema5_45m   = request.security(syminfo.tickerid, "45",  ta.ema(close, 5))
ema13_45m  = request.security(syminfo.tickerid, "45",  ta.ema(close, 13))
ema5_1h    = request.security(syminfo.tickerid, "60",  ta.ema(close, 5))
ema13_1h   = request.security(syminfo.tickerid, "60",  ta.ema(close, 13))
ema5_2h    = request.security(syminfo.tickerid, "120", ta.ema(close, 5))
ema13_2h   = request.security(syminfo.tickerid, "120", ta.ema(close, 13))
ema5_3h    = request.security(syminfo.tickerid, "180", ta.ema(close, 5))
ema13_3h   = request.security(syminfo.tickerid, "180", ta.ema(close, 13))
ema5_4h    = request.security(syminfo.tickerid, "240", ta.ema(close, 5))
ema13_4h   = request.security(syminfo.tickerid, "240", ta.ema(close, 13))
ema5_333m  = request.security(syminfo.tickerid, "333", ta.ema(close, 5))
ema13_333m = request.security(syminfo.tickerid, "333", ta.ema(close, 13))
ema5_1d    = request.security(syminfo.tickerid, "D",   ta.ema(close, 5))
ema13_1d   = request.security(syminfo.tickerid, "D",   ta.ema(close, 13))

trend_3m   = ema5_3m > ema13_3m ? "🟢" : "🔴"
trend_5m   = ema5_5m > ema13_5m ? "🟢" : "🔴"
trend_12m  = ema5_12m > ema13_12m ? "🟢" : "🔴"
trend_15m  = ema5_15m > ema13_15m ? "🟢" : "🔴"
trend_30m  = ema5_30m > ema13_30m ? "🟢" : "🔴"
trend_45m  = ema5_45m > ema13_45m ? "🟢" : "🔴"
trend_1h   = ema5_1h > ema13_1h ? "🟢" : "🔴"
trend_2h   = ema5_2h > ema13_2h ? "🟢" : "🔴"
trend_3h   = ema5_3h > ema13_3h ? "🟢" : "🔴"
trend_4h   = ema5_4h > ema13_4h ? "🟢" : "🔴"
trend_333m = ema5_333m > ema13_333m ? "🟢" : "🔴"
trend_1d   = ema5_1d > ema13_1d ? "🟢" : "🔴"

trendBoxText = "EMA:  3m " + trend_3m + "  |  5m " + trend_5m + "  |  12m " + trend_12m + "  |  15m " + trend_15m + "  |  30m " + trend_30m + "  |  45m " + trend_45m + "  |  1h " + trend_1h + "  |  2h " + trend_2h + "  |  3h " + trend_3h + "  |  4h " + trend_4h + "  |  333m " + trend_333m + "  |  1D " + trend_1d + "  |         "

var table tfTrendTable = table.new(position.top_right, 1, 1, border_width=0)
if showEMATrendBox
    table.cell(tfTrendTable, 0, 0, trendBoxText, text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 85))
else
    table.cell(tfTrendTable, 0, 0, "")
````
