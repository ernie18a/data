# 72s Strat: Backtesting Adaptive HMA+ pt.1

- url: https://www.tradingview.com/script/FrjeeWdl-72s-Strat-Backtesting-Adaptive-HMA-pt-1/
- type: strategy
- pine_id: PUB;58ujcjLFItoYCyX4gPyWv2fU5sC17e6T
- version: 3.0

## Description

This is a follow up to my previous publication of [b][url=https://www.tradingview.com/script/ls42zPSE-72s-Adaptive-Hull-Moving-Average/]Adaptive HMA+[/url][/b] few months ago, as a mean to provide some kind of initial backtesting tools. Which can be use to explore many possible strategies, optimise its settings to better conform user's pair/tf, and hopefully able to help tweaking your general strategy.

If you haven't read the study or use the indicator, kindly go [i][url=https://www.tradingview.com/script/ls42zPSE-72s-Adaptive-Hull-Moving-Average/]here[/url][/i] first to get the overall idea.

The first strategy introduce in this backtest is one most basic already described in the study; buy/sell is when movement is there and everything is on the right side; When RSI has turned to other side, we can use it as exit point (if in profit of course, else just let it hit our TP/SL, why would we exit before profit). Also, base on RSI when we make entry, we can further differentiate type of signals. --Please check all comments in code directly where the [b]signals[/b], [b]entries[/b], and [b]exits[/b] section are. 

Second additional strategy to check; is when we also use second faster Adaptive HMA+ for exit. So this is like a double orders on a signal but with different exit-rule (/more on this on snapshots below). Alternatively, you can also work the code so to only use this type of exit. 

There's also an additional feature which you can enable its visuals, the [b]Distance Zone[/b], is to help measuring price distance to our xHMA+. It's just a simple atr based envelope really, I already put the sample code in study's comment section, but better gonna update it there directly for non-coder too, after this.

In this sample I use [i]Lot[/i] for order quantity size just because that's what I use on my broker. Also what few friends use while we forward-testing it since the study is published, so we also checked/compared each profit/loss report by real number. To use default or other unit of measurement, change the entry code accordingly.

If you change your order size, you should also change the [i]commission[/i] in Properties Tab. My broker commission is 5 USD per order/lot, so in there with example order size 0.1 lot I put commission 0.5$ per order (I'll put 2.5$ for 0.5 lot, 10$ for 2 lot, and so on). Crypto usually has higher charge. --It is important that you should fill it base on your broker. 

[b]SETTINGS[/b]
I'm trying to keep it short. Please explore it further again. (Beginner should also first get acquaintance with terms use here.)
[list]
[*][b]ORDERS:[/b] 
[b]Base Minimum Profit Before Exit:[/b] 
The number is multiplier of ongoing ATR. Means that when basic exit condition is met, algo will check whether you're already in minimum profit or not, if not, let it still run to TP or SL, or until it meets subsequent exit condition, then it will check again.  
[b]Default Target Profit:[/b] 
Multiplier of ATR at signal. If reached before any [i]eligible exit condition[/i] is met, exit TP.
[b]Base StopLoss Point:[/b] 
You can change directly in code to use other like ATR Trailing SL, fix percent SL, or whatever. In the sample, 4 options provided.
[b]Maximum StopLoss:[/b] 
This is like a safety-net, that if at some point your chosen SL point from input above happens to be exceeding this maximum input that you can tolerate, then this max point is the one will be use as SL.
[b]Activate 2nd order...:[/b] 
The additional doubling of certain buy/sell with different exits as described above. If enable, you should also set pyramiding to at least: 2. If not, it does nothing.

[*][b]ADAPTIVE HMA+ PERIOD[/b]
Many users already have their own settings for these. So in here I only sample the default as first presented in the study. Make it to your adaptive.

[*][b]MARKET MOVEMENT[/b]
(1) Now you can check in realtime how much slope degree is best to define your specific pair/tf is out of congestion (yellow) area. And (2) also able to check directly what ATR lengths are more suitable defining your pair's volatility.

[*][b]DISTANCE ZONE[/b]
Distance Multiplier. Each pair/tf has its own best distance zone (in xHMA+ perspective). The zone also determine whether a signal should appear or not. (Or what [i]type[/i] of signal, if you wanna go more detail in constructing your strategy)
[/list]

[b]USAGE[/b]
(Provided you already have your own comfortable settings for minimum-maximum period of Adaptive HMA+. Best if you already have backtested it manually too and/or apply as an add-on to your working strategy)
1. In our experiences, first most important to define is both elements in the [b]Market Movement Settings[/b]. These also tend to be persistent for whole season since it's kinda describing that pair/tf overall behaviour. Don't worry if you still get a low Profit Factor here, but by tweaking you should start to see positive changes in one of Max Drawdown and Net Profit, or Percent Profitable.
2. Afterwards, find your pair/tf [b]Distance Zone[/b]. When optimising this, what we seek is just a "not to bad" equity curves to start forming. At least Max Drawdown should lessen more. Doesn't have to be great already, but should be better, no red in Net Profit. 
3. Then go manage the "Trailing Minimum Profit", TP, SL, and max SL. 
4. Repeat 1,2,3. 👻
5. Manage order size, commission, and/or enable double-order (need pyramiding) if you like. Check if your equity can handle max drawdown before margin call.
6. After getting an acceptable backtest result, go to [i]List of Trades[/i] tab and find the biggest loss or when many sequencing loss in a row happened. Click on it to go to exact point on chart, [b]observe why the signal failed and get at least general idea how it can be prevented[/b]. The rest is yours, you should know your pair/tf more than other.

You can also re-explore your minimum-maximum period for both Major and minor xHMA+.

Keep in mind that all numbers in Setting are conceptually in a form of [i]range[/i]. You don't want to get superb equity curves but actually a "fragile" , means one can easily turn it to disaster just by changing only a fraction in one/two of the setting. 

---
If you just wanna test the strength of the indicator alone, you can disable "Use StopLoss" temporarily while optimising settings. 

Using no SL might be tempting in overall result data in some cases, but NOTE: It is [b]not[/b] recommended to not using SL, don't forget that we deliberately enter when it's in high volatility. If want to add flexibility or trading for long-term, just maximise your SL. ie.: chose SL Point>ATR only and set it maximum. (Check your max drawdown after this).
      I think this is quite important specially for beginners, so here's an example; Hypothetically in below scenario, because of some settings, the buy order after the loss sell signal didn't appear. Let's say if our initial capital only 1000$ using leverage and order size 0,5 lot (risky position sizing already), moreover if this happens at the beginning of your trading season, [i]that's half of account gone already in one trade[/i]. Your max SL should've made you exit after that pumping bar.
[image]https://www.tradingview.com/x/YUBW2TP8[/image]

The Trailing Minimum Profit is actually look like this. Search in the code if you want to plot it. I just don't like too many lines on chart.
[image]https://www.tradingview.com/x/FedEHS3a/[/image]

To maximise profit we can try enabling double-order. The only added rule coded is: RSI should rising when buy and falling when sell. 2nd signal will appears above or below default buy/sell signal. (Of course it's also prone to double-loss, re-check your max drawdown after. Profit factor play its part in here for a long run). Snapshot in comparison:
[image]https://www.tradingview.com/x/N4ciPSkD[/image]
Two default sell signals on left closed at RSI exit, the additional sell signal closed later on when price crossover minor xHMA+. On buy side, price haven't met our minimum profit when first crossunder minor xHMA+. If later on we hit SL on this "+buy" signal, at least we already profited from default buy signal. You can also consider/treat this as multiple TP points. 

For longer-term trading, what you need to maximise is the [b]Minimum Profit[/b], so it won't exit whenever an exit condition happened, it can happen several times before reaching minimum profit. Hopefully this snapshot can explain:
[image]http://www.tradingview.com/x/Dk9O4jAH[/image]
Notice in comparison default sell and buy signal now close in average after 3 days. What's best is when we also have confirmation from higher TF. It's like targeting higher TF by entering from smaller TF. 

As also mention in the study, we can still experiment via original HMA by putting same value for minimum-maximum period setting. This is experimental EU 1H with Major xHMA+: 144-144, Flat market 13, Distance multiplier 3.6, with 2nd order activated.
[image]https://www.tradingview.com/x/zqyaScFe[/image]

Kiwi was a bit surprising for me. It's flat market is effectively below 6, with quite far distance zone of 3.5. Probably because I'm using big numbers in adaptive period.
[image]https://www.tradingview.com/x/0pix3Hg7[/image]

---
The result you see in strategy tester report below for EURUSD 15m is using just default settings you see in code, as follow:
[list]
[*] 0,1 lot for each order (which is the smallest allowed by my broker).
[*] No pyramiding. Commission: 0.5 usd per order. Slippage: 3
[*] Opening position is only using basic strategy #1 (RSI exit). Additional exit not activated.
[*] Minimum Profit: 1. TP: 3. 
[*] SL use: Half-distance zone. Max SL: 4.5.
[*] Major xHMA+: 172-233. minor xHMA+: 89-121
[*] Distance Zone Multiplier: 2.7
[*] RSI: Standard 14.
[/list]

(From our forward-testing, the difference we get from net profit is because of the spread, our entry isn't exactly at the close/open price. Not so much though, but not the same. If somebody can direct me to any example where we can code our entry via current bid/ask price, that would be awesome!)

It's already a long post (sorry), think I'm gonna pause here. Check out the code :)

---
DISCLAIMER: [b]Past performance is no guarantee of future results[/b], and so on.. you know the drill ;)
Please read whole description first before using, don't take 1-2 paragraph and claim it's the whole logic, you are responsible of your own actions and understanding.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// 2020 © io72signals / Antorio Bergasdito

//@version=4
strategy("72s Strategy: Adaptive Hull Moving Average+ pt.1", shorttitle="72s Strat: Adaptive HMA+ pt.1", overlay=true, 
     pyramiding=1, initial_capital=1000, commission_type=strategy.commission.cash_per_order, commission_value=.5, 
     slippage=3, max_bars_back=1000)

atrBase  = atr(21)
src      = close
adaptPct = 0.03141

//{ INPUTS
orderSize   = input(0.1, title="Order Size (in Lot)", step=.1, group="ORDERS")
minProfit   = input(1, step=.1, title="Base Minimum Profit before exit (ATR)", group="ORDERS") * atrBase
takeProfit  = input(3, step=.1, title="Default Target Profit (ATR)", group="ORDERS") * atrBase
useSL       = input(true, title="Use StopLoss", group="ORDERS")
SLInput     = input("Half Distance Zone", title="Base StopLoss Point", 
                 options=["One Distance Zone", "Half Distance Zone", "Last High/Low", "ATR Only"], group="ORDERS")
maxSL       = input(4.5, step=.1, title="Maximum StopLoss (ATR)", group="ORDERS") * atrBase

doubleUp    = input(false, "Activate 2nd order with xHMA+ exits", group="ORDERS")    //If enable, set pyramiding to at least: 2

minLength   = input(172, title="Minimum:", group="Adaptive HMA+ Period", inline="HMA+")
maxLength   = input(233, title="Maximum:", group="Adaptive HMA+ Period", inline="HMA+")

flat        = input(17, title="Flat Market when xHMA's slope below", group="Market Movement")
atrFast     = input(14, "Charged if ATR", group="Market Movement", inline="volality", minval=2, maxval=34)
atrSlow     = input(46, ">= ATR", group="Market Movement", inline="volality", minval=21, maxval=120)
showZone    = input(false, title="Show Adaptive HMA+ Distance Zone", group="DISTANCE ZONE")
mult        = input(2.7, title="Distance (Envelope) Multiplier", step=.1, group="DISTANCE ZONE") 

minorMin    = input(89, title="Minimum:", group="Minor Adaptive HMA+ Period", inline="mHMA+")
minorMax    = input(121, title="Maximum:", group="Minor Adaptive HMA+ Period", inline="mHMA+")

showMA      = input(true, title="Show MA?", group="OTHER")
useBg       = input(true, title="Background color to differentiate movement", group="OTHER")
rsi         = rsi(input(close,"RSI Source", inline="RSI", group="OTHER"), input(14, "RSI Length", inline="RSI", group="OTHER"))
//}...inputs


//{ ADAPTIVE HMA+
//Condition to adapt to:
charged = atr(atrFast) > atr(atrSlow)           //<--Volatility Meter. Change it to whatever match your strat/pair/tf.

//Dynamics 
var float dynamicLength = avg(minLength,maxLength)
var float minorLength   = avg(minorMin,minorMax)
dynamicLength   := iff(charged, max(minLength, dynamicLength * (1 - adaptPct)), min(maxLength, dynamicLength * (1 + adaptPct)))
minorLength     := iff(charged, max(minorMin, minorLength * (1 - adaptPct)), min(minorMax, minorLength * (1 + adaptPct)))

//Slope calculation to determine whether market is in trend, or in consolidation or choppy, or might about to change current trend
pi = atan(1) * 4
highestHigh = highest(34), lowestLow = lowest(34)
slope_range = 25 / (highestHigh - lowestLow) * lowestLow
calcslope(_ma)=>
    dt = (_ma[2] - _ma) / src * slope_range  
    c = sqrt(1 + dt * dt)
    xAngle = round(180 * acos(1 / c) / pi)
    maAngle = iff(dt > 0, -xAngle, xAngle)
    maAngle
    
//MA coloring+ to mark market dynamics 
dynColor(_ma,_col1a,_col1b,_col2a,_col2b,_col0) =>
    slope = calcslope(_ma)
    slope >= flat ? charged? _col1a : _col1b :
     slope < flat and slope > -flat ? _col0 : 
     slope <= -flat ? charged? _col2a : _col2b : _col0

//Adaptive HMA 
xhma(_src,_length) => _return = wma(2 * wma(_src, _length / 2) - wma(_src, _length), floor(sqrt(_length))) 

dynamicHMA = xhma(src,int(dynamicLength))       //<--Batman - Our main xHMA+
minorHMA = xhma(src,int(minorLength))           //<--Robin  - Faster minor xHMA+ (Optional). Can be use to assist for 
                                                //            faster entry, slower exit point, or pullbacks info too.

_slope = calcslope(dynamicHMA)
plotchar(_slope, "slope is:", "", location.top) //<--Output current slope to Data Window, for our reference when optimizing Strategy

//Envelope the main DynamicHMA with ATR band, just one way to approximate current price distance to MA. Other usages/methods may vary.
upperTL = dynamicHMA + mult * atr(40)        ,  lowerTL = dynamicHMA - mult * atr(40)           //<--Half distance zone
topTL = dynamicHMA + (mult*2) * atr(40)      ,  botTL = dynamicHMA - (mult*2) * atr(40)         //<--One distance zone
stopupperTL = dynamicHMA + (mult/2) * atr(40),  stoplowerTL = dynamicHMA - (mult/2) * atr(40)   //<--Half of the half. If need ie. tighter SL or trailing

//Plotting Distance Zone
plot(showZone?upperTL:na, color=color.green, transp=72)
plot(showZone?lowerTL:na, color=color.red,   transp=72)
plot(showZone?topTL:na, color=color.gray, transp=72)
plot(showZone?botTL:na, color=color.gray, transp=72)
sutl = plot(showZone?stopupperTL:na, color=color.white, transp=100)
sltl = plot(showZone?stoplowerTL:na, color=color.white, transp=100)
colZone = showZone? color.purple:color.new(color.white,100)
fill(sutl, sltl, color=colZone, transp=90)

plot(showMA?dynamicHMA:na, "Adaptive HMA+", dynColor(dynamicHMA, #6fbf73, #c0f5ae, #eb4d5c, #f2b1d4, color.yellow), 3)
plot(showMA?minorHMA:na,   "minor HMA+",    dynColor(minorHMA,   #6fbf73, #c0f5ae, #eb4d5c, #f2b1d4, color.yellow), 1)

//Backgroud color to differentiate market condition
notgreat = _slope < flat and _slope > -flat
bgcolor(useBg? charged? na : #afb4b9 : na)

//EMA 200. (Not being use in here. But since they've been a BFF since long, thought I'm just gonna put it here..)
emma200 = ema(close,200) //, plot(emma200)
//}...adaptive HMA+


//{ SIGNALS
//Base; When HMA+ turn to a darker color and market is out from low volatility
upSig = _slope >=  flat and charged
dnSig = _slope <= -flat and charged

//Default buy/sell, when market switchs to the above base condition, and typical price is still in tolerated distance, and RSI is on the right side.
buy  = upSig and not upSig[1] and close>dynamicHMA and low<=upperTL  and (rsi>51  and rsi<=70)
sell = dnSig and not dnSig[1] and close<dynamicHMA and high>=lowerTL and (rsi<49  and rsi>=30)

//Alternative buy/sell, when price is a bit far from MA, and RSI is still on the same side but already on oversold/overbought (relatively).
overBuy = upSig and not upSig[1] and rsi>70 and close>dynamicHMA and hl2>upperTL and minorHMA>dynamicHMA
overSell= dnSig and not dnSig[1] and rsi<30 and close<dynamicHMA and hl2<lowerTL and minorHMA<dynamicHMA

//Alternative additional buy/sell with different exits at Robin's.
secondBuy  = (buy  or overBuy)  and rsi[1]<rsi
secondSell = (sell or overSell) and rsi[1]>rsi

//Plot 'em up
atrPos = 0.2 * atr(5)
plotshape(buy?  dynamicHMA-atrPos:na,color=color.green, location=location.absolute, style=shape.labelup,   text="buy",  textcolor=color.white, size = size.small)
plotshape(sell? dynamicHMA+atrPos:na,  color=color.red, location=location.absolute, style=shape.labeldown, text="sell", textcolor=color.white, size = size.small)
plotshape(overBuy? dynamicHMA-atrPos:na,color=color.green, location=location.absolute, style=shape.labelup,   text="overBuy",  textcolor=color.white, size = size.small)
plotshape(overSell?dynamicHMA+atrPos:na,  color=color.red, location=location.absolute, style=shape.labeldown, text="overSell", textcolor=color.white, size = size.small)

plotshape(doubleUp and secondBuy? dynamicHMA-atrPos*8:na,color=color.green, location=location.absolute, style=shape.labelup,   text="+buy",  textcolor=color.white, size = size.small)
plotshape(doubleUp and secondSell?dynamicHMA+atrPos*8:na,  color=color.red, location=location.absolute, style=shape.labeldown, text="+sell", textcolor=color.white, size = size.small)

//Alert 
if buy
    alert("Buy signal at "+tostring(close), alert.freq_once_per_bar_close)
if sell
    alert("Sell signal at "+tostring(close), alert.freq_once_per_bar_close)
if overBuy
    alert("OverBuy signal at "+tostring(close), alert.freq_once_per_bar_close)
if overSell
    alert("OverSell signal at "+tostring(close), alert.freq_once_per_bar_close)
if doubleUp and secondBuy
    alert("2nd Buy signal at "+tostring(close), alert.freq_once_per_bar_close)
if doubleUp and secondSell
    alert("2nd Sell signal at "+tostring(close), alert.freq_once_per_bar_close)
//}...signals


//{ ORDERS
//(I use Lot just because it's how I usually trade, matches my flow when thinking/planning. Change the "qty" in "strategy.entry()" below to use other UOM.)
//Forex pairs are 100,000 units per 1 lot. Units per 1 lot vary on non-forex pairs, please check with your broker and change accordingly if necessary.
//(ie: In MT4 and MT5 right click a symbol and then click Specification. The Contract Size field tells how many units are in one lot.)
standard1LotUnits = 
     syminfo.type == "forex" ? 100000 : 
     syminfo.ticker == "XAUUSD" ? 100 : 
     syminfo.ticker == "XAGUSD" ? 5000 : 
     syminfo.type == "crypto" ? 1 : 1000

lotSize = standard1LotUnits * orderSize 
pip() => syminfo.mintick * (syminfo.type == "forex" ? 10 : 1)

//{ StopLoss
SLHighMax = high + maxSL, SLLowMax = low - maxSL        //<--Maximum StopLoss. If a chosen SL-point from input above happen
                                                        //   to be outside this max point, then this one will be use as SL.

lastHigh = highest(high, 48) + (5 * pip())              //<--Last High/Low. If use as SL-point, adjust the lookback length  
lastLow  = lowest(low, 48) - (5 * pip())                //   according to where your comfort lies (and position-size).

//Delivering SL from inputs
SLBuy = SLInput == "One Distance Zone"? botTL : SLInput == "Half Distance Zone"? lowerTL : 
     SLInput == "Last High/Low"? lastLow : SLInput == "ATR Only"? SLLowMax : SLLowMax
SLSell= SLInput == "One Distance Zone"? topTL : SLInput == "Half Distance Zone"? upperTL : 
     SLInput == "Last High/Low"? lastHigh: SLInput == "ATR Only"? SLHighMax: SLHighMax
//}---stopLoss

//
float entryPrice = na, float normOrder = 0, float riskOrder = 0
float buyTP = na, float sellTP = na, float buySL = na, float sellSL = na
entryPrice := nz(entryPrice[1]), normOrder := nz(normOrder[1]), riskOrder := nz(riskOrder[1])
buyTP:=nz(buyTP[1]), sellTP:=nz(sellTP[1]), buySL:=nz(buySL[1]), sellSL :=nz(sellSL[1])

//This part will also make your TP/SL change dynamically if there's a new signal while you have an open position.
//If you want to fire this TP/SL only in a new position, then add "strategy.position_size == 0" 
if (buy or sell or overBuy or overSell) //and strategy.position_size == 0
    entryPrice := close
    if buy or sell and strategy.position_size == 0
        normOrder := 1
    if overBuy or overSell and strategy.position_size == 0
        riskOrder := 1
    buyTP   := high + takeProfit 
    sellTP  := low  - takeProfit 
    if buy or overBuy
        buySL := SLLowMax<SLBuy? SLBuy:SLLowMax 
    if sell or overSell
        sellSL:= SLHighMax>SLSell? SLSell:SLHighMax 

//Trailing Minimum-Profit. --Just a simple helper to prevent premature exit rule. Or at least to have a
//change to get break-even (after commission) if market turns its back on us, before heading to stoploss area.
minBuyProfit  = strategy.position_avg_price  + minProfit 
minSellProfit = strategy.position_avg_price  - minProfit 

//{ Exit Points
//TP/SL Exits
stopLossBuy  = useSL? low <=buySL : na
stopLossSell = useSL? high>=sellSL: na
takeProfitBuy  = high>= buyTP
takeProfitSell = low <= sellTP 

//Simplified RSI Exits
RSIexitBuy  = crossunder(rsi,70) or rsi<50
RSIexitSell = crossover(rsi,30)  or rsi>50

//Exit Conditions
exitBuy  = ( close >= minBuyProfit  and (RSIexitBuy  or crossunder(close,dynamicHMA)) ) or stopLossBuy  or takeProfitBuy  
exitSell = ( close <= minSellProfit and (RSIexitSell or crossover(close,dynamicHMA) ) ) or stopLossSell or takeProfitSell
exitoverBuy  = ( close >= minBuyProfit  and (crossunder(rsi,45) or (open<stopupperTL and hl2<stopupperTL)) ) or (open<dynamicHMA and rsi<60)
     or stopLossBuy  or takeProfitBuy 
exitoverSell = ( close <= minSellProfit and (crossover(rsi,55)  or (open>stoplowerTL and hl2>stoplowerTL)) ) or (open>dynamicHMA and rsi>40)
     or stopLossSell or takeProfitSell 

//Alternative 2nd Exits at Robin's (or SL)
exitSecondBuy  = (close >= minBuyProfit and crossunder(close, minorHMA)) or stopLossBuy
exitSecondSell = (close <= minSellProfit and crossover(close, minorHMA)) or stopLossSell
    
//Plotting and Alert for Exits
inBuyExit  = strategy.position_size > 0 and ((normOrder == 1 and exitBuy)  or (riskOrder == 1 and exitoverBuy))
inSellExit = strategy.position_size < 0 and ((normOrder == 1 and exitSell) or (riskOrder == 1 and exitoverSell))
in2ndBuyExit = strategy.position_size > 0 and (doubleUp and exitSecondBuy)
in2ndSellExit=  strategy.position_size < 0 and (doubleUp and exitSecondSell)

if inBuyExit or inSellExit
    if normOrder == 1 and exitBuy 
        normOrder := 0, alert("Close Buy Position/s at "+tostring(close), alert.freq_once_per_bar_close)
    if normOrder == 1 and exitSell
        normOrder := 0, alert("Close Sell Position/s at "+tostring(close), alert.freq_once_per_bar_close)
    if riskOrder == 1 and exitoverBuy 
        riskOrder := 0, alert("Close overBuy Position/s at "+tostring(close), alert.freq_once_per_bar_close)
    if riskOrder == 1 and exitoverSell
        riskOrder := 0, alert("Close overSell Position/s at "+tostring(close), alert.freq_once_per_bar_close)

if in2ndBuyExit
    alert("Close 2nd Buy Position/s at "+tostring(close), alert.freq_once_per_bar_close)
if in2ndSellExit
    alert("Close 2nd Sell Position/s at "+tostring(close), alert.freq_once_per_bar_close)
    
plotchar(inBuyExit, color=color.green, location=location.abovebar, char="ⓧ", size=size.tiny)
plotchar(inSellExit,  color=color.red, location=location.belowbar, char="ⓧ", size=size.tiny)
plotchar(in2ndBuyExit, color=color.teal, location=location.abovebar, char="ⓧ", size=size.tiny)
plotchar(in2ndSellExit,  color=color.maroon, location=location.belowbar, char="ⓧ", size=size.tiny)
//}---exit points

//{ Actions
//ENTRIES
strategy.entry("buy",  strategy.long,  qty=lotSize, when=buy )
strategy.entry("sell", strategy.short, qty=lotSize, when=sell)
strategy.entry("overBuy",  strategy.long,  qty=lotSize, when=overBuy )
strategy.entry("overSell", strategy.short, qty=lotSize, when=overSell)

if doubleUp
    strategy.entry("2ndBuy",  strategy.long,  qty=lotSize, when=secondBuy )
    strategy.entry("2ndSell", strategy.short, qty=lotSize, when=secondSell) 

//EXITS
//We use just "strategy.close" because we already set limit conditions above for SL and TP, fires at candle close. If you want to
//separate exit data or exit at the exact SL/TP you can add such as: strategy.exit("exitbuy", from_entry="buy", stop=buySL, limit=buyTP)
//accordingly. And delete stopLossBuy, stopLossSell, takeProfitBuy, takeProfitSell definitions from above.
strategy.close("buy",  when=exitBuy , comment="close buy")
strategy.close("sell", when=exitSell, comment="close sell")
strategy.close("overBuy",  when=exitoverBuy , comment="close overBuy")
strategy.close("overSell", when=exitoverSell, comment="close overSell")

if doubleUp
    strategy.close("2ndBuy",  when=exitSecondBuy , comment="close 2nd Buy")
    strategy.close("2ndSell", when=exitSecondSell, comment="close 2nd Sell")
//}---actions

orderCol = strategy.position_size>0? color.green : strategy.position_size<0? color.red : na
// plot(strategy.position_size>0? minBuyProfit : strategy.position_size<0? minSellProfit : na, color=orderCol, style=plot.style_linebr, linewidth=1, title="Minimum Profit")
plot(strategy.position_size != 0? entryPrice:na, style=plot.style_cross, transp=50)
plot(useSL and strategy.position_size>0? buySL : useSL and strategy.position_size<0? sellSL : na, color=color.red, style=plot.style_cross, linewidth=1, title="Stop Loss", transp=50)
plot(strategy.position_size>0? buyTP : strategy.position_size<0? sellTP : na, color=color.green, style=plot.style_cross, linewidth=1, title="Take Profit", transp=50)
//}...orders


//{------------------------------------------------------------------------

//Below is just fancy stuff approximating gain in pips. You probably don't need this.
//(Also I'm not too sure this is the right way calculating pip gain in pine. If somebody knows how, kindly correct me please)
mUnit = lotSize*pip()
ppip = round((strategy.grossprofit-strategy.grossprofit[1]) / syminfo.pointvalue/mUnit,1)
lpip = round((strategy.grossloss-strategy.grossloss[1]) / syminfo.pointvalue/mUnit,1)
pipGain = round((strategy.grossprofit/syminfo.pointvalue)/mUnit)
pipLoss = round((strategy.grossloss/syminfo.pointvalue)/mUnit)
avg_ppip = round((pipGain/strategy.wintrades),1)
pctProfit = round(strategy.wintrades/strategy.closedtrades * 100, 2)
maxDD = ceil(strategy.max_drawdown/ syminfo.pointvalue/mUnit) //check if our margin can handle DD's pips*orderSize
var txt2 = ""
txt = "Total trades: "+ tostring(strategy.closedtrades)+"\n("+tostring(pctProfit)+"%) Win: "+tostring(strategy.wintrades)+" / Loss: "+tostring(strategy.losstrades)+
     "\nAverage win pips per trade: "+ tostring(avg_ppip) + " pips\n\nApproximate (*give n take)\nTotal Pip Gain: "+ tostring(pipGain) +" pips"+
     "\nTotal Pip Loss: "+tostring(pipLoss)+ " pips"+"\n\nMax Drawdown so far: "+tostring(maxDD)+" pips"
if strategy.wintrades>strategy.wintrades[1]
    txt2 := "\n\nLast closed trade: Bagged "+tostring(ppip)+" pips 👻"
if strategy.losstrades>strategy.losstrades[1]
    txt2 := "\n\nLast closed trade: Blew "+tostring(lpip)+" pips 😪"

txt += txt2
label pvtLabel   = label.new(time, lowestLow, text=txt, 
     color=color.new(color.white,100), xloc=xloc.bar_time, style=label.style_label_left, textcolor=color.gray, textalign=text.align_left)
label.set_x(pvtLabel, label.get_x(pvtLabel) + ((time-time[1]) * 21))
label.delete(pvtLabel[1])
//}
````
