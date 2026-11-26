# OptionsMillionaire SPY Moving Averages and Signals

- url: https://www.tradingview.com/script/t8uBvyEy-OptionsMillionaire-SPY-Moving-Averages-and-Signals/
- type: indicator
- pine_id: PUB;KSz0yeOiH2GSFfMWVJNcAVXXsR7mMOtP
- version: 11.0

## Description

by ColeJustice

OptionsMillionaire's SPY Options trading system is based mainly on these indicators:
[b] - 8 EMA*[/b]
[b] - 21 EMA*[/b]
[b] - 100 SMA*[/b]
[b] - 200 SMA*[/b][/b]
 - MACD
 - RSI
 - Squeeze Momentum
[b](*provided by this indicator)[/b]

and follows these rules:
|  
|    1)  I never fight the trend. If its green, i buy calls. If its red, i buy puts. I will only buy puts on a green day if there is a overall change in market trend. Inversely, calls on a red day
|    2)  Price action is my #1 indicator. I wait for it to confirm my thesis before i enter a trade
|    3)  I only trade SPY Options
|    4)  My baseline is to choose a call/put that has a DTE (Date To Expiration) 6-7 days out, with a strike $2-$3 away. I adjust that to fit my current appetite for volatility. i virtually never play same day DTE's. 
|    5)  I set a 10% stop, but usually exit at 8% before my stop triggers depending on current situation
|    6)  I utilize about 10-20% of my Portfolio for one trade. Sometimes more. Rarely less. 
|    7)  I never hold overnight in these market conditions.
|    8)  I shoot for 10-20% for gains. Depending on market conditions.
|    9)  Always look for confirmations in your indicators.
|  10)  I never force a trade. No trade is a good trade too if the entry just isn't there. 
|  11)  Patience always pays off. A great set-up can form in minutes or seconds. I never regret being patient to enter. I nearly always regret rushing into a trade.
|

This indicator combines the moving averages into a single unit to simplify one part of the indicator usage rules: the [b]8 EMA / 21 EMA Cross. [/b]. The 8 crossing over the 21 is a Bullish signal, while the 8 crossing under the 21 is a Bearish signal. This indicator places flags at these crossover/under points, as well as shading the area between the 8 and 21 EMAs to help visualize the strength of the trend; green during a Bullish cross, and red during a Bearish cross.

A new addition to this strategy is the Hull Moving Average, or HMA. This script defaults to an HMA of 20 and shows alerts when candles close above or below the plot in the form of green and red candle backgrounds. This alert is best used in conjunction with the main crossovers and should be considered an addition level of confidence rather than providing trade entry/exits directly. This indicator is more flexible and you should feel free to adjust the period if you find a different value works better within your own personal trading style.

Each individual element of this indicator can be modified or toggled, providing maximum customization. While you should strive to become comfortable with the default settings, these options are provided in case you feel the need to adjust for your own style (or if testing on tickers other than SPY, for example).

Goodluch, and happy trading!

## Source Code

````pine
study("SPY Moving Averages and Signals", shorttitle="OM's MAs & Signals", overlay = true)

//@version=4
// Version 2.4
// Author: ColeJustice
// Based on OptionMillionaire's preferred moving averages when day trading SPY options.
//
// This indicator shows the crossing point of two moving average. 
// OM uses the EMA(8) and EMA(21), so those are the defaults.
// The basic signals are:
//  - 8ema crossing over 21ema is bullish
//  - 8ema crossing under 21ema is bearish
//  NOTE: Optimized for the 5m timeframe.

priceSource = input(close, title="Price Source For The Moving Averages", group="General")
IgnoreExtendedHours = input(true, title="Ignore Extended Hours", group="General")
resolution = timeframe.period
price = security(syminfo.tickerid, resolution, priceSource)

shortMAPeriod = input(8,  title="Short Moving Average Period & Type:", group="Crossover Moving Averages", inline="short")
shortMAType   = input(defval="EMA", title="", type=input.string, confirm=false, options=["EMA","SMA","WMA","HMA","ALMA","LIN","ZLMA"], group="Crossover Moving Averages", inline="short")
longMAPeriod  = input(21, title=" Long Moving Average Period & Type :", group="Crossover Moving Averages", inline="long")
longMAType    = input(defval="EMA", title="", type=input.string, confirm=false, options=["EMA","SMA","WMA","HMA","ALMA","LIN","ZLMA"],  group="Crossover Moving Averages", inline="long")
i_timeframe_signal = input(title="Crossover MAs Timeframe", type=input.resolution, defval="", group="Crossover Moving Averages")
useTextLabels = input(true, title="Use Text-Based Crossover Labels?", group="Crossover Moving Averages")

showBonusMA1     = input(true, title="Bonus MA", group="Bonus Moving Averages", inline="bma1")
bonusMA1Period   = input(34,  title="", group="Bonus Moving Averages", inline="bma1")
bonus1MAType     = input(defval="EMA", title="", type=input.string, confirm=false, options=["EMA","SMA","WMA","HMA","ALMA","LIN","ZLMA"], group="Bonus Moving Averages", inline="bma1")
i_timeframe_bma1 = input(title="", type=input.resolution, defval="", group="Bonus Moving Averages", inline="bma1")
showBonusMA2     = input(false, title="Bonus MA", group="Bonus Moving Averages",inline= "bma2")
bonusMA2Period   = input(50, title="", group="Bonus Moving Averages", inline="bma2")
bonus2MAType     = input(defval="SMA", title="", type=input.string, confirm=false, options=["EMA","SMA","WMA","HMA","ALMA","LIN","ZLMA"], group="Bonus Moving Averages", inline="bma2")
i_timeframe_bma2 = input(title="", type=input.resolution, defval="", group="Bonus Moving Averages", inline="bma2")
showBonusMA3     = input(false, title="Bonus MA", group="Bonus Moving Averages", inline="bma3")
bonusMA3Period   = input(100, title="", group="Bonus Moving Averages", inline="bma3")
bonus3MAType     = input(defval="SMA", title="", type=input.string, confirm=false, options=["EMA","SMA","WMA","HMA","ALMA","LIN","ZLMA"], group="Bonus Moving Averages", inline="bma3")
i_timeframe_bma3 = input(title="", type=input.resolution, defval="", group="Bonus Moving Averages", inline="bma3")

ZLMASmooth = 3

f_security(_sym, _res, _src) => security(_sym, _res, _src[barstate.isrealtime ? 1 : 0], barmerge.gaps_off, lookahead=barmerge.lookahead_off)[barstate.isrealtime ? 0 : 1]

ticker = tickerid(syminfo.prefix, syminfo.ticker, IgnoreExtendedHours ? session.regular : syminfo.session)

// MA calculation
short = shortMAType == "SMA"  ? f_security(ticker, i_timeframe_signal, sma(price, shortMAPeriod)) : 
     shortMAType    == "EMA"  ? f_security(ticker, i_timeframe_signal, ema(price, shortMAPeriod)) :
     shortMAType    == "WMA"  ? f_security(ticker, i_timeframe_signal, wma(price, shortMAPeriod)) :
     shortMAType    == "HMA"  ? f_security(ticker, i_timeframe_signal, hma(price, shortMAPeriod)) :
     shortMAType    == "ALMA" ? f_security(ticker, i_timeframe_signal, alma(price, shortMAPeriod, 0.85, 6)) :
     shortMAType    == "LIN"  ? f_security(ticker, i_timeframe_signal, linreg(price, shortMAPeriod, 0)) :
     shortMAType    == "ZLMA" ? f_security(ticker, i_timeframe_signal, (2 * wma(wma(price, shortMAPeriod),ZLMASmooth)) - wma(wma(wma(price, shortMAPeriod),ZLMASmooth), shortMAPeriod)) : na
        
long = longMAType == "SMA"  ? f_security(ticker, i_timeframe_signal, sma(price, longMAPeriod)) :
     longMAType   == "EMA"  ? f_security(ticker, i_timeframe_signal, ema(price, longMAPeriod)) :
     longMAType   == "WMA"  ? f_security(ticker, i_timeframe_signal, wma(price, longMAPeriod)) :
     longMAType   == "HMA"  ? f_security(ticker, i_timeframe_signal, hma(price, longMAPeriod)) :
     longMAType   == "ALMA" ? f_security(ticker, i_timeframe_signal, alma(price, longMAPeriod, 0.85, 6))  :
     longMAType   == "LIN"  ? f_security(ticker, i_timeframe_signal, linreg(price, longMAPeriod, 0)) :
     longMAType   == "ZLMA" ? f_security(ticker, i_timeframe_signal, (2 * wma(wma(price, longMAPeriod),ZLMASmooth)) - wma(wma(wma(price, longMAPeriod),ZLMASmooth), longMAPeriod)) : na

bonus1 = bonus1MAType == "SMA"  ? f_security(ticker, i_timeframe_bma1, sma(price, bonusMA1Period)) :
     bonus1MAType     == "EMA"  ? f_security(ticker, i_timeframe_bma1, ema(price, bonusMA1Period)) :
     bonus1MAType     == "WMA"  ? f_security(ticker, i_timeframe_bma1, wma(price, bonusMA1Period)) :
     bonus1MAType     == "HMA"  ? f_security(ticker, i_timeframe_bma1, hma(price, bonusMA1Period)) :
     bonus1MAType     == "ALMA" ? f_security(ticker, i_timeframe_bma1, alma(price, bonusMA1Period, 0.85, 6))  :
     bonus1MAType     == "LIN"  ? f_security(ticker, i_timeframe_bma1, linreg(price, bonusMA1Period, 0)) :
     bonus1MAType     == "ZLMA" ? f_security(ticker, i_timeframe_bma1, (2 * wma(wma(price, bonusMA1Period),ZLMASmooth)) - wma(wma(wma(price, bonusMA1Period),ZLMASmooth), bonusMA1Period)) : na
     
bonus2 = bonus2MAType == "SMA"  ? f_security(ticker, i_timeframe_bma2, sma(price, bonusMA2Period)) :
     bonus2MAType     == "EMA"  ? f_security(ticker, i_timeframe_bma2, ema(price, bonusMA2Period)) :
     bonus2MAType     == "WMA"  ? f_security(ticker, i_timeframe_bma2, wma(price, bonusMA2Period)) :
     bonus2MAType     == "HMA"  ? f_security(ticker, i_timeframe_bma2, hma(price, bonusMA2Period)) :
     bonus2MAType     == "ALMA" ? f_security(ticker, i_timeframe_bma2, alma(price, bonusMA2Period, 0.85, 6)) :
     bonus2MAType     == "LIN"  ? f_security(ticker, i_timeframe_bma2, linreg(price, bonusMA2Period, 0)) :
     bonus2MAType     == "ZLMA" ? f_security(ticker, i_timeframe_bma2, (2 * wma(wma(price, bonusMA2Period),ZLMASmooth)) - wma(wma(wma(price, bonusMA2Period),ZLMASmooth), bonusMA2Period)) : na
     
bonus3 = bonus3MAType == "SMA"  ? f_security(ticker, i_timeframe_bma3, sma(price, bonusMA3Period)) :
     bonus3MAType     == "EMA"  ? f_security(ticker, i_timeframe_bma3, ema(price, bonusMA3Period)) :
     bonus3MAType     == "WMA"  ? f_security(ticker, i_timeframe_bma3, wma(price, bonusMA3Period)) :
     bonus3MAType     == "HMA"  ? f_security(ticker, i_timeframe_bma3, hma(price, bonusMA3Period)) :
     bonus3MAType     == "ALMA" ? f_security(ticker, i_timeframe_bma3, alma(price, bonusMA3Period, 0.85, 6)) :
     bonus3MAType     == "LIN"  ? f_security(ticker, i_timeframe_bma3, linreg(price, bonusMA3Period, 0)) :
     bonus3MAType     == "ZLMA" ? f_security(ticker, i_timeframe_bma3, (2 * wma(wma(price, bonusMA3Period),ZLMASmooth)) - wma(wma(wma(price, bonusMA3Period),ZLMASmooth), bonusMA3Period)) : na

// trend direction/color
TrendingUp()   => short > long 
TrendingDown() => short < long 
Uptrend() => TrendingUp() and TrendingDown()[1]
Downtrend() => TrendingDown() and TrendingUp()[1]
trendColor = TrendingUp() ? color.new(color.green , 85) : TrendingDown() ? color.new(color.red , 85) : color.new(color.blue , 85)

MA1 = plot(short, title="Short Period Moving Average", color=#FF00FF, linewidth=2, style=plot.style_line)
MA2 = plot(long,  title="Long Period Moving Average",  color=#00FF00, linewidth=1, style=plot.style_line)
fill(MA1, MA2, color=trendColor, title="Short/Long Divergence Fill")
plot(showBonusMA1 ? bonus1 : na, title="Bonus Moving Average 1", color=#FFFF00, linewidth=1, style=plot.style_line)
plot(showBonusMA2 ? bonus2 : na, title="Bonus Moving Average 2",  color=#FF0000, linewidth=1, style=plot.style_line)
plot(showBonusMA3 ? bonus3 : na, title="Bonus Moving Average 3",  color=#00FFFF, linewidth=1, style=plot.style_line)

// Short & Long Moving Averages cross alert
MAcrossing = cross(short, long) ? short : na
plot(MAcrossing[0], title = "Calls/Puts Crossing Icon", style = plot.style_cross, linewidth = 3, color=trendColor)

// Bull and Bear Alerts
Bull = crossover(short, long)
Bear = crossunder(short, long)

plotshape(Bull, title="Calls Label", color=color.new(color.green, 25),
     textcolor=useTextLabels ? color.white : color.new(color.white, 100),
     style=useTextLabels ? shape.labelup : shape.triangleup,
     text="Calls", location=location.belowbar)
     
plotshape(Bear, title="Puts Label", color=color.new(color.red, 25),
     textcolor=useTextLabels ? color.white : color.new(color.white, 100),
     style=useTextLabels ? shape.labeldown : shape.triangledown,
     text="Puts", location=location.abovebar)


if Bull
    alert("Calls Alert: 8ema crossed over 21ema", alert.freq_once_per_bar_close)
if Bear
    alert("Puts Alert: 8ema crossed under 21ema", alert.freq_once_per_bar_close)


// -- VWAP -- //

showVWAP        = input(true, title="Show VWAP?", group="VWAP")
showVWAPStdDevs1 = input(false, title="Display Standard Deviation Bands 1", group="VWAP", inline="vwap")
VWAPStdDevMult1 =  input(1.0, step=0.1, title="", group="VWAP",  inline="vwap")
showVWAPStdDevs2 = input(false, title="Display Standard Deviation Bands 2", group="VWAP", inline="vwap")
VWAPStdDevMult2 =  input(2.0, step=0.1, title="", group="VWAP",  inline="vwap")
fillVWAPBands = input(true, title="Fill VWAP Bands", group="VWAP")

start = security(syminfo.tickerid, "D", time)
newSession = change(time('D'))

var float sumSrcVol = na
var float sumVol = na
var float sumSrcSrcVol = na


sumSrcVol := newSession ? hlc3 * volume : hlc3 * volume + sumSrcVol[1]
sumVol := newSession ? volume : volume + sumVol[1]
sumSrcSrcVol := newSession ? volume * pow(hlc3, 2) : volume * pow(hlc3, 2) + sumSrcSrcVol[1]

_vwap = sumSrcVol / sumVol
variance = sumSrcSrcVol / sumVol - pow(_vwap, 2)
variance := variance < 0 ? 0 : variance
stDev1 = sqrt(variance) * VWAPStdDevMult1
stDev2 = sqrt(variance) * VWAPStdDevMult2

plot(showVWAP ? vwap : na, color=color.new(color.white, 60), title = "VWAP", style=plot.style_circles)
vwap1plot1 = plot(showVWAPStdDevs1 ? vwap - stDev1 : na, color=color.new(color.white, 50), title = "VWAP - Std Dev 1", style=plot.style_line)
vwap1plot2 = plot(showVWAPStdDevs1 ? vwap + stDev1 : na, color=color.new(color.white, 50), title = "VWAP + Std Dev 1", style=plot.style_line)
vwap2plot1 = plot(showVWAPStdDevs2 ? vwap - stDev2 : na, color=color.new(color.white, 50), title = "VWAP - Std Dev 2", style=plot.style_line)
vwap2plot2 = plot(showVWAPStdDevs2 ? vwap + stDev2 : na, color=color.new(color.white, 50), title = "VWAP + Std Dev 2", style=plot.style_line)
fill(vwap1plot1, vwap1plot2, color=fillVWAPBands ? color.new(color.lime, 92) : na, title="VWAP 1 Fill")
fill(vwap2plot1, vwap2plot2, color=fillVWAPBands ? color.new(color.aqua, 92) : na, title="VWAP 2 Fill")

// ————— Show warning or HTF reminder, if needed.
f_tfReminderAndErrorCheck(_userSelectionOfTf, _tfReminder) =>
    // Get chart's TF.
    var float _chartTfInMinutes = timeframe.multiplier * (
      timeframe.isseconds ? 1. / 60             :
      timeframe.isminutes ? 1.                  :
      timeframe.isdaily   ? 60. * 24            :
      timeframe.isweekly  ? 60. * 24 * 7        :
      timeframe.ismonthly ? 60. * 24 * 30.4375  : na)
    
    // Get HTF.
    float _htfInMinutes = security(syminfo.tickerid, _userSelectionOfTf, _chartTfInMinutes)
    
    // Label.
    string _txt = ""
    var color _color = na
    if _chartTfInMinutes > _htfInMinutes
        // Chart TF is higher than user-selected TF.
        _txt := "The chart's timeframe\nshould not be greater than " + _userSelectionOfTf
        _color := color.red
    else if _tfReminder
        // Display reminder of HTF.
        _txt := _userSelectionOfTf
        _color := color.silver
    float _y = lowest(50)[1]
    var label _lbl = label.new(bar_index, _y, _txt, xloc.bar_index, yloc.price, #00000000, label.style_label_left, _color, size.large, text.align_left)
    if barstate.islast and _txt != ""
        // Update label.
        label.set_xy(_lbl, bar_index, _y)
        label.set_text(_lbl, _txt)
        label.set_textcolor(_lbl, _color)
    [_chartTfInMinutes, _htfInMinutes]

f_tfReminderAndErrorCheck(i_timeframe_signal, false)
f_tfReminderAndErrorCheck(i_timeframe_bma1, false)
f_tfReminderAndErrorCheck(i_timeframe_bma2, false)
f_tfReminderAndErrorCheck(i_timeframe_bma3, false)
````
