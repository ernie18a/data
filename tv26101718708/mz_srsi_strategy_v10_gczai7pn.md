# MZ SRSI Strategy V1.0

- url: https://www.tradingview.com/script/GcZaI7pn-MZ-SRSI-Strategy-V1-0/
- type: strategy
- pine_id: PUB;b37c1e767f9f457f9cfbbf8fed8c357b
- version: 1.0

## Description

[b]Strategy Introduction[/b]

[list]
[*]This strategy starts from selection of 1st Moving Average from one of following:
[list]
[*]SMA
[*]EMA
[*]DEMA
[*]TEMA
[*]LRC
[*]WMA
[*]MF
[*]VAMA
[*]TMA
[*]HMA
[*]JMA
[*]Kijun v2
[*]EDSMA
[*]McGinley
[/list]
[*]Then it calculates the RSI of selected 1st Moving Average
[*]In the end it calculates Moving Average of previously calculated RSI and for this purpose 2nd Moving Average is also selected from above list.
[*]Cross of RSI and its Moving Average generates Strategy Alerts
[*]Only long trades are enabled currently
[/list]

[b]Default Settings[/b]

[list]
[*]I've set the default selection to the perfect options for 1D and 4h timeframes. You can modify both MAs selection and their length according to your selected timeframe.
[*]Following default settings are used:
[list]
[*]Heiken Ashi Candles are selected by default as source
[*]1st Moving Average selection is set to LRC (Linear Regression Curve)
[*]Length of 1st Moving Average is set to 50
[*]RSI length is set to 2 because it is supposed to be fast
[*]2nd Moving Average of RSI is set to TMA (Triangular Moving Average)
[*]Length of 1st Moving Average is set to 5
[*]Start date is set to 2011 
[*]Backtesting can also be done selecting %age of equity
[/list]
[/list]

[b]Suggestions for Usage[/b]

Mostly winning trades have no prominent drawdown so losing trades can be abolished with Stoploss. Would soon add Stoploss, MTF and Takeprofit options in next version. Also if you want an alerts version of it then just comment below and would publish it later. I’ve found this strategy useful on 1D and 4h timeframes with described default settings.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MightyZinger
//@version=4
strategy(shorttitle="MZ SRSI",title="MightyZinger SRSI Strategy", overlay=false, pyramiding=1, calc_on_order_fills=true, calc_on_every_tick=true, default_qty_type=strategy.fixed, default_qty_value=5,commission_value=0.1)

//heiking ashi calculation
UseHAcandles    = input(true, title="Use Heikin Ashi Candles in Algo Calculations")
////
// === /INPUTS ===

// === BASE FUNCTIONS ===
haClose = UseHAcandles ? security(heikinashi(syminfo.tickerid), timeframe.period, close) : close
haOpen  = UseHAcandles ? security(heikinashi(syminfo.tickerid), timeframe.period, open) : open
haHigh  = UseHAcandles ? security(heikinashi(syminfo.tickerid), timeframe.period, high) : high
haLow   = UseHAcandles ? security(heikinashi(syminfo.tickerid), timeframe.period, low) : low


//Backtest dates
fromMonth = input(defval = 1,    title = "From Month",      type = input.integer, minval = 1, maxval = 12)
fromDay   = input(defval = 1,    title = "From Day",        type = input.integer, minval = 1, maxval = 31)
fromYear  = input(defval = 2021, title = "From Year",       type = input.integer, minval = 1970)
thruMonth = input(defval = 12,    title = "Thru Month",      type = input.integer, minval = 1, maxval = 12)
thruDay   = input(defval = 30,    title = "Thru Day",        type = input.integer, minval = 1, maxval = 31)
thruYear  = input(defval = 2021, title = "Thru Year",       type = input.integer, minval = 1970)

showDate  = input(defval = true, title = "Show Date Range", type = input.bool)

start     = timestamp(fromYear, fromMonth, fromDay, 00, 00)        // backtest start window
finish    = timestamp(thruYear, thruMonth, thruDay, 23, 59)        // backtest finish window
window()  => time >= start and time <= finish ? true : false       // create function "within window of time"

src = UseHAcandles ? haClose : input(close, title="Source")

TopBand = input(80, step=0.01)
LowBand = input(20, step=0.01)
lengthRSI = input(2, minval=1,title="RSI Length")
lengthMA = input(50, minval=1,title="MA Length")
lengthRSI_MA= input(5, minval=1,title="RSI MA Length")


//RSI Source
maType = input(title="MA Type", type=input.string, defval="LRC", options=["SMA","EMA","DEMA","TEMA","LRC","WMA","MF","VAMA","TMA","HMA", "JMA", "Kijun v2", "EDSMA","McGinley"])
rsiMaType = input(title="RSI MA Type", type=input.string, defval="TMA", options=["SMA","EMA","DEMA","TEMA","LRC","WMA","MF","VAMA","TMA","HMA", "JMA", "Kijun v2", "EDSMA","McGinley"])

//MA Function

//           Pre-reqs
//
tema(src, len) =>
    ema1 = ema(src, len)
    ema2 = ema(ema1, len)
    ema3 = ema(ema2, len)
    (3 * ema1) - (3 * ema2) + ema3
kidiv = input(defval=1,maxval=4,  title="Kijun MOD Divider")

jurik_phase = input(title="* Jurik (JMA) Only - Phase", type=input.integer, defval=3)
jurik_power = input(title="* Jurik (JMA) Only - Power", type=input.integer, defval=1)
volatility_lookback = input(10, title="* Volatility Adjusted (VAMA) Only - Volatility lookback length")
//                  MF
beta = input(0.8,minval=0,maxval=1,step=0.1,  title="Modular Filter, General Filter Only - Beta")
feedback = input(false, title="Modular Filter Only - Feedback")
z = input(0.5,title="Modular Filter Only - Feedback Weighting",step=0.1, minval=0, maxval=1)
//EDSMA
ssfLength = input(title="EDSMA - Super Smoother Filter Length", type=input.integer, minval=1, defval=20)
ssfPoles = input(title="EDSMA - Super Smoother Filter Poles", type=input.integer, defval=2, options=[2, 3])

//----
//                  EDSMA
get2PoleSSF(src, length) =>
    PI = 2 * asin(1)
    arg = sqrt(2) * PI / length
    a1 = exp(-arg)
    b1 = 2 * a1 * cos(arg)
    c2 = b1
    c3 = -pow(a1, 2)
    c1 = 1 - c2 - c3
    
    ssf = 0.0
    ssf := c1 * src + c2 * nz(ssf[1]) + c3 * nz(ssf[2])

get3PoleSSF(src, length) =>
    PI = 2 * asin(1)

    arg = PI / length
    a1 = exp(-arg)
    b1 = 2 * a1 * cos(1.738 * arg)
    c1 = pow(a1, 2)

    coef2 = b1 + c1
    coef3 = -(c1 + b1 * c1)
    coef4 = pow(c1, 2)
    coef1 = 1 - coef2 - coef3 - coef4

    ssf = 0.0
    ssf := coef1 * src + coef2 * nz(ssf[1]) + coef3 * nz(ssf[2]) + coef4 * nz(ssf[3])

//          MA Main function
ma(type, src, len) =>
    float result = 0
    if type=="TMA"
        result := sma(sma(src, ceil(len / 2)), floor(len / 2) + 1)
    if type=="MF"
        ts=0.,b=0.,c=0.,os=0.
        //----
        alpha = 2/(len+1)
        a = feedback ? z*src + (1-z)*nz(ts[1],src) : src
        //----
        b := a > alpha*a+(1-alpha)*nz(b[1],a) ? a : alpha*a+(1-alpha)*nz(b[1],a)
        c := a < alpha*a+(1-alpha)*nz(c[1],a) ? a : alpha*a+(1-alpha)*nz(c[1],a)
        os := a == b ? 1 : a == c ? 0 : os[1]
        //----
        upper = beta*b+(1-beta)*c
        lower = beta*c+(1-beta)*b 
        ts := os*upper+(1-os)*lower
        result := ts
    if type=="LRC"
        result := linreg(src, len, 0)
    if type=="SMA" // Simple
        result := sma(src, len)
    if type=="EMA" // Exponential
        result := ema(src, len)
    if type=="DEMA" // Double Exponential
        e = ema(src, len)
        result := 2 * e - ema(e, len)
    if type=="TEMA" // Triple Exponential
        e = ema(src, len)
        result := 3 * (e - ema(e, len)) + ema(ema(e, len), len)
    if type=="WMA" // Weighted
        result := wma(src, len)
    if type=="VAMA" // Volatility Adjusted
        /// Copyright © 2019 to present, Joris Duyck (JD)
        mid=ema(src,len)
        dev=src-mid
        vol_up=highest(dev,volatility_lookback)
        vol_down=lowest(dev,volatility_lookback)
        result := mid+avg(vol_up,vol_down)
    if type=="HMA" // Hull
        result := wma(2 * wma(src, len / 2) - wma(src, len), round(sqrt(len)))
    if type=="JMA" // Jurik
        /// Copyright © 2018 Alex Orekhov (everget)
        /// Copyright © 2017 Jurik Research and Consulting.
        phaseRatio = jurik_phase < -100 ? 0.5 : jurik_phase > 100 ? 2.5 : jurik_phase / 100 + 1.5
        beta = 0.45 * (len - 1) / (0.45 * (len - 1) + 2)
        alpha = pow(beta, jurik_power)
        jma = 0.0
        e0 = 0.0
        e0 := (1 - alpha) * src + alpha * nz(e0[1])
        e1 = 0.0
        e1 := (src - e0) * (1 - beta) + beta * nz(e1[1])
        e2 = 0.0
        e2 := (e0 + phaseRatio * e1 - nz(jma[1])) * pow(1 - alpha, 2) + pow(alpha, 2) * nz(e2[1])
        jma := e2 + nz(jma[1])
        result := jma
    if type=="Kijun v2"
        kijun = avg(lowest(len), highest(len))//, (open + close)/2)
        conversionLine = avg(lowest(len/kidiv), highest(len/kidiv))
        delta = (kijun + conversionLine)/2
        result :=delta
    if type=="McGinley"
        mg = 0.0
        mg := na(mg[1]) ? ema(src, len) : mg[1] + (src - mg[1]) / (len * pow(src/mg[1], 4))
        result :=mg
    if type=="EDSMA"
    
        zeros = src - nz(src[2])
        avgZeros = (zeros + zeros[1]) / 2
        
        // Ehlers Super Smoother Filter 
        ssf = ssfPoles == 2
             ? get2PoleSSF(avgZeros, ssfLength)
             : get3PoleSSF(avgZeros, ssfLength)
        
        // Rescale filter in terms of Standard Deviations
        stdev = stdev(ssf, len)
        scaledFilter = stdev != 0
             ? ssf / stdev
             : 0
        
        alpha = 5 * abs(scaledFilter) / len
        
        edsma = 0.0
        edsma := alpha * src + (1 - alpha) * nz(edsma[1])
        result :=  edsma
    result


//Indicator
hline(TopBand, color=color.red,linestyle=hline.style_dotted, linewidth=2)
hline(LowBand, color=color.green, linestyle=hline.style_dashed, linewidth=2)

// RSI Definition
rsiSource = ma(maType, src , lengthMA)
frsi = rsi(rsiSource, lengthRSI)
fsma = ma(rsiMaType, frsi , lengthRSI_MA)

plot(frsi,title='frsi', color= color.lime, linewidth=3)
fsmaColor=color.new(color.red, 80)
plot(fsma,title='fsma', color= fsmaColor , linewidth=3, style=plot.style_area)

//Background
bgcolor(frsi > fsma ? color.lime : color.orange, 80)

longcondition = crossover (frsi , fsma)
shortcondition = crossunder(frsi , fsma)


////////////////////////////////
//if (longcondition)
//    strategy.entry("BUY", strategy.long, when = window())
    
//if (shortcondition)
//    strategy.close("SELL", strategy.short, when = window())

strategy.entry(id="long", long = true, when = longcondition and window())
strategy.close("long", when = shortcondition and window())
````
