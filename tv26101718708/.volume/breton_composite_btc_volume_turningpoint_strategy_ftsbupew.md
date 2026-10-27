# Breton Composite BTC Volume -turningpoint -strategy

- url: https://www.tradingview.com/script/FtsbUpew-Breton-Composite-BTC-Volume-turningpoint-strategy/
- type: strategy
- pine_id: PUB;gnwH6YDnUEhdZvQ7RPUwQKre3fPiZUkE
- version: 1.0

## Description

Composite BTCUSD Volume strategy compiled from 9 different exchanges, attempting to isolate turning points by trading on volume spikes and bag holding bars

## Source Code

````pine

strategy(title="Breton Composite BTC Volume -turningpoint -strategy")

vol1 = security("BINANCE:BTCUSDC", period, volume)
vol2 = security("BITSTAMP:BTCUSD", period, volume)
vol3 = security("BITFINEX:BTCUSD", period, volume)
vol4 = security("COINBASE:BTCUSD",  period, volume)
vol5 = security("BITMEX:XBTUSD",  period, volume)
vol6 = security("HITBTC:BTCUSD", period, volume)
vol7 = security("KRAKEN:BTCUSD", period, volume)
vol8 = security("BITTREX:BTCUSD", period, volume)
vol9 = security("HUOBI:BTCUSDT", period, volume)


volumeSum = vol1+vol2+vol3+vol4+vol5+vol6+vol7+vol8+vol9

Length_HH = input(40, minval=1)
Length_LLSmall = input(2, minval=2)
Length_LLBig = input(20, minval=2)
LengthMA    = input(20, minval=1)
hline(0, color=gray, linestyle=dashed)
xSMA_vol = sma(volumeSum, LengthMA)
xHH_vol = highest(volumeSum, Length_HH)
xLL_volSmall = lowest(volumeSum, Length_LLSmall)
xLL_volBig = lowest(volumeSum, Length_LLBig)

hl = close-low<2 and high-open<2

eq = (open-close)<2 and hl

pavg=input(defval=100, title="percent avg")
percentage_above_avg=((volumeSum-xSMA_vol)/xSMA_vol)*100
turningpoint=eq and percentage_above_avg>pavg and volumeSum>xSMA_vol


LongCondition= turningpoint and close[0] > close[1]  //and crossover(close,enter)
//if (LongCondition)
strategy.entry("long", strategy.long, LongCondition)


//when= strategy.position_size <=0

//SellCondition = turningpoint and close[0] < close[1] //and (close[0] < enterless)
//if (SellCondition)
//strategy.entry("short", strategy.short, when= strategy.position_size <=0 and SellCondition)

tpoints=input(defval=60)
toffset=input(defval=20)
stoploss=input(defval=5000)
takeprofit=input(defval=5000)

strategy.exit("long", trail_points= tpoints, trail_offset= toffset, loss= stoploss, profit=takeprofit)
//strategy.exit("short", trail_points= tpoints, trail_offset= toffset, loss= stoploss, profit=takeprofit)


plot(volumeSum, color=white, title="Vol", style=histogram, linewidth=2)
plot(xSMA_vol, color=green, title="SMA")



//(open-close)>1 and (open-close)<2


plot(percentage_above_avg, color=blue, title="avg", style=histogram)


plotshape(turningpoint, style=shape.circle,location=location.abovebar, color=orange, size=size.large)
````
