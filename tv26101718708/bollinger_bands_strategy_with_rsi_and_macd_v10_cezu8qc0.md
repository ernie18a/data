# Bollinger Bands strategy with RSI and MACD v1.0 

- url: https://www.tradingview.com/script/CEzU8qc0/
- type: strategy
- pine_id: PUB;XX41Qaqzpmdl8RjvzOiLnhbE5dQcP5ol
- version: 1.0

## Description

This is a strategy based on the Bollinger Bands, where buy trades are made when the price crosses the lower line of the Bollinger Bands upwards, and sell trades are made when the price crosses the upper line downwards.

In addition, it is possible through the inputs to enable trading with RSI and MACD, so that buy or sell trades are supported by these two indicators.

Trades are partially and fully closed in the following way, a buy trade will close half of the position when the price touches the middle line of the Bollinger bands and will be fully closed when the price touches the upper band. In the case of a sell position, half of the position will be closed if the price touches the middle band and the entire position will be closed when the price touches the lower band. Alternatively, a fixed take profit can be placed. In case the price moves against us, trailing stops can be placed.

In case of selecting to use RSI, MACD, or MACD variation, trades will be executed as long as The Bollinger Bands, and all the above-mentioned indicators give the same signals, either buy or sell.

For example in the case of selecting only Use RSI, buy trades would be made as long as RSI and BB give buy signals.

[b]Strategy inputs:[/b]

-BB source: Bollinger Bands price source.

-Bollinger Bands SMA length: Bollinger Bands simple moving average length.

-Bollinger Bands StdDev length: Bollinger Bands standard deviation length.

-Trail Long Loss (%): Distance in percentage at which the stop loss will initially be placed for buy trades. 

-Trail Short Loss (%): Distance in percentage at which the stop loss will be initially placed for sell trades. 

-Maximum orders: Maximum of simultaneous operations, for example, if it is 3, up to 3 parallel operations of buy and up to 3 parallel operations of sell will be carried out. 

-Position size: Number of contracts per trade.

-Use RSI: If selected, the strategy will also trade based on oversold or overbought signals provided by the RSI.

-RSI source: RSI price source.

-RSI period: The RSI period to use.

-RSI value for buy: If the RSI is below this value, it will give a buy signal.

-RSI value for sell: If the RSI value is above this value, it will give a sell signal.

-Use MACD: If selected, buy trades will be made when the MACD crosses 0 upwards, and sell trades will be made when the MACD crosses 0 downwards.

-Use MACD variation: Only available if MACD is previously selected. In this case, buy trades are made if the MACD value in the last 3 candles has been decreasing, and sell trades are made if the MACD value has been increasing.

-MACD source: MACD price source.

-MACD fast length: MACD fast EMA lenght.

-MACD slow length: MACD slow EMA lenght.

-MACD signal length: MACD signal EMA lenght.

-Use maximum TP long: If selected, a fixed take profit will be placed for buy trades. The position could be closed before reaching this take profit if the price touches one of the lower or upper lines first.

-Maximum take profit long (%): Distance in percentage at which the take profit will be placed for buy trades.

-Use maximum TP short: if selected, a fixed take profit will be placed for sell trades. The position could be closed before reaching this take profit if the price touches one of the lower or upper lines first.

-Maximum take profit short (%): Distance in percentage at which the take profit will be set for sell trades.

I hope you like it and as always all feedback is welcome.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © juliangonzaconde

//@version=4
strategy(title="BB-strategy", calc_on_every_tick=true,max_labels_count=500, max_bars_back = 1000, overlay=true, pyramiding=5, default_qty_value=3,initial_capital=100000, currency=currency.EUR)

bbSource = input(title="BB source", type=input.source, defval=close)
smaLength = input(title="Bollinger Bands SMA length", type=input.integer, defval=20)
stdLength = input(title="Bollinger Bands StdDev length", type=input.integer, defval=2)
longTrailPerc = input(title="Trail Long Loss (%) (min: 0.0)", type=input.float, minval=0.0, step=0.1, defval=4.0) * 0.01
shortTrailPerc = input(title="Trail Short Loss (%) (min: 0.0)", type=input.float, minval=0.0, step=0.1, defval=4.0) * 0.01
maxOrders= input(title="Maximum orders (min: 1, max: 3)", type=input.integer,minval=1, maxval=3, defval=2)
posSize= input(title="Position size (min: 1, max: 100)", type=input.integer, minval=1, maxval=100, defval=2)
rsiChosen= input(title="Use RSI", type=input.bool, defval=false)
rsiSource = input(title="RSI source", type=input.source, defval=close)
rsiPeriod= input(title="RSI period", type=input.integer, minval=1, maxval=1000, defval=14)
rsiBuy = input(title="RSI value for buy", type=input.integer, minval=1, maxval=99, defval=30)
rsiSell = input(title="RSI value for sell", type=input.integer, minval=1, maxval=99, defval=70)
macdChosen= input(title="Use MACD", type=input.bool, defval=false)
macdVariation= input(title="Use MACD variation (Use MACD must be selected)", type=input.bool, defval=false)
macdSource = input(title="MACD source", type=input.source, defval=close)
fastLen= input(title="MACD fast length", type=input.integer, minval=1, maxval=1000, defval=12)
slowLen= input(title="MACD slow length", type=input.integer, minval=1, maxval=1000, defval=26)
signLen= input(title="MACD signal length", type=input.integer, minval=1, maxval=1000, defval=9)
longMaxTpChosen= input(title="Use maximum TP long", type=input.bool, defval=true)
longMaxTp= input(title="Maximum take profit long (%) (min: 0.5, max: 30.0)", type=input.float, minval=0.5, step=0.1, defval=3.0 ,maxval=30.0) * 0.01
shortMaxTpChosen= input(title="Use maximum TP short", type=input.bool, defval=true)
shortMaxTp= input(title="Maximum take profit short (%) (min: 0.5, max: 30.0)", type=input.float, minval=0.5, step=0.1, defval=3.0 ,maxval=30.0) * 0.01

rsiValue= rsi(rsiSource, rsiPeriod)

[macdLine, signalLine, histLine] = macd(macdSource, fastLen, slowLen, signLen)

plot(macdLine, color=color.red)
plot(signalLine, color=color.green)
plot(histLine, color=color.yellow, style=plot.style_histogram)


[middle, upper, lower] = bb(bbSource, smaLength, stdLength)

var idsLong = array.new_string(maxOrders,na)

var idsShort = array.new_string(maxOrders,na)

var stopLong = array.new_float(maxOrders, 0.0)

var stopShort = array.new_float(maxOrders,999999.0)

var longPartialClose = array.new_bool(maxOrders,false)

var shortPartialClose = array.new_bool(maxOrders,false)

var opTp = array.new_float(maxOrders, 0.0)

var opTpShort = array.new_float(maxOrders, 0.0)

canBuyMacd = true
if macdVariation
    canBuyMacd := histLine[2]<histLine[1] and histLine[1] < histLine
    if not macdChosen
        canBuyMacd := true
else
    canBuyMacd := histLine[2]<0 and histLine[1] >= 0 and histLine >= 0
    if not macdChosen
        canBuyMacd := true

canSellMacd = true
if macdVariation
    canSellMacd := histLine[2]> histLine[1] and histLine[1]> histLine
    if not macdChosen
        canSellMacd := true
else
    canSellMacd := histLine[2]>0 and histLine[1] <= 0 and histLine <= 0
    if not macdChosen
        canSellMacd := true

canBuyRsi = true
if rsiChosen
    if rsiValue > rsiBuy
        canBuyRsi := false
        
canSellRsi = true
if rsiChosen
    if rsiValue < rsiSell
        canSellRsi := false



canBuy = false
int index = na
for i = 0 to (maxOrders - 1)
    val=array.get(idsLong,i)
    if val==na
        canBuy := true
        index := i

canSell = false
int indexSell= na
for i = 0 to (maxOrders - 1)
    val=array.get(idsShort,i)
    if val==na
        canSell := true
        indexSell := i


bool isLong = close[2] < lower[2] and close[1] > close[2] and close > close[1] and canBuy and close[3] > close[2] and close < middle and (canBuyRsi and canBuyMacd)
bool isShort = close[2] > upper[2] and close[1] < close[2] and close < close[1] and canSell and close[3] < close[2] and close > middle and (canSellRsi and canSellMacd)

longStopPrice = 0.0
    
shortStopPrice = 0.0
tp=0.0
id = ""
if (isLong)
    
    id := tostring(time)
    strategy.entry(id=id, long=true, qty=posSize)
    array.set(idsLong, index, id)
    stopValue = close * (1 - longTrailPerc)
    longStopPrice := stopValue
    array.set(stopLong, index, longStopPrice)
    tp := close * (1 + longMaxTp)
    array.set(opTp,index,tp)
    
    

for i = 0 to (maxOrders - 1)
    stopValue = close * (1 - longTrailPerc)
    longStopPrice := max(stopValue, array.get(stopLong,i))
    array.set(stopLong,i,longStopPrice)
    if ((longMaxTpChosen and array.get(opTp,i)<= close) or close >= upper or close <= array.get(stopLong,i)) and array.get(idsLong,i) != na
        id := array.get(idsLong,i) 
        strategy.close(id=id, qty=posSize)
        array.set(idsLong,i,na)
        array.set(stopLong,i,0.0)
        array.set(longPartialClose,i,false)
    if close > middle and array.get(idsLong,i) != na and not array.get(longPartialClose,i)
        id := array.get(idsLong,i)
        x=array.get(idsLong,i)
        
        strategy.close(id=id, qty=posSize/2)
        array.set(longPartialClose,i,true)
        

if (isShort)
    id := tostring(time)
    strategy.entry(id=id, long=false, qty=posSize)
    array.set(idsShort, indexSell, id)
    stopValue = close * (1 + shortTrailPerc)
    shortStopPrice := stopValue
    array.set(stopShort, indexSell, shortStopPrice)
    tp := close * (1 - shortMaxTp)
    array.set(opTpShort,indexSell,tp)


    
for i = 0 to (maxOrders - 1)
    stopValue = close * (1 + shortTrailPerc)
    shortStopPrice := min(stopValue, array.get(stopShort,i))
    array.set(stopShort,i,shortStopPrice)
    if ((shortMaxTpChosen and array.get(opTpShort,i) >= close) or close <= lower or close >= array.get(stopShort,i)) and array.get(idsShort,i) != na
        id := array.get(idsShort,i)
        strategy.close(id=id, qty=posSize)
        array.set(idsShort,i,na)
        array.set(stopShort,i,999999.0)
        array.set(shortPartialClose,i,false)
    if close < middle and not array.get(shortPartialClose,i) and array.get(idsShort,i) != na
        id := array.get(idsShort,i)
        strategy.close(id=id, qty=posSize/2)
        array.set(shortPartialClose,i,true)
        
plot(middle, color=color.yellow)
plot(upper, color=color.yellow)
plot(lower, color=color.yellow)
````
