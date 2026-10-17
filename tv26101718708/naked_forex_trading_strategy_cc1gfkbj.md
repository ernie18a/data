# Naked Forex Trading Strategy

- url: https://www.tradingview.com/script/cC1gFKBJ-Naked-Forex-Trading-Strategy/
- type: indicator
- pine_id: PUB;1270
- version: -1.0

## Description

Based on "How Naked Trading Works" video by Walter Peters: https://youtu.be/t-pD3fap25c?t=1m21s. I don't know this person and I am in no way affiliated with him. I just found his video interesting enough to make this into a script.

Rules as described by Walter in his video:

1. if current candle makes a higher high than the previous one
2. and is a bearish engulfing candle
3. and has room to the left
4. and is the largest candle (high - low) compared to the last 7-10 previous ones

Then open trade on the next candle once it breaks bearish engulfing candle's low and take profit close above previous support. Stop loss goes a few pips above bearish engulfing candle high

Do the opposite on a bullish engulfing candle signal.

Works best on 1H, 4H and 1D timeframes.

I haven't done any extensive backtesting on this, but it looks like it gives pretty good signals: [image]https://www.tradingview.com/x/BNXuzY7S/[/image]

## Source Code

````pine
//Based on "How Naked Trading Works" video by Walter Peters: https://youtu.be/t-pD3fap25c?t=1m21s
study(title = "Naked Forex Trading Strategy", overlay = true)

roomToTheLeftPeriod = input(title="RoomToLeftIntervalCheck", type=integer, defval=7, minval=2, maxval=30)
largestCandlePeriod = input(title="LargestOfLastXCandles", type=integer, defval=7, minval=2, maxval=30)

//1. if current candle makes a higher high
//2. and is a bearish engulfing candle
//3. and has room to the left
//4. and is the largest candle (high - low) compared to the last 7 previous ones

//Open trade on the next candle once it breaks bearish engulfing candle's low and take profit close above previous support
//Stop loss goes a few pips above signal candle high

higherHigh = high > high[1]//step 1
bearishEngulfing = close[1] > open[1] and open > close and open >= close[1] and open[1] >= close and open - close > close[1] - open[1] //step 2
roomToTheLeftRising = rising(high, roomToTheLeftPeriod) //step 3
largestCandle = max(high - low, largestCandlePeriod) //step 4
barcolor(higherHigh and bearishEngulfing and roomToTheLeftRising and largestCandle ? yellow : na)

//1. if current candle makes a lower low
//2. and is a bullish engulfing candle
//3. and has room to the left
//4. and is the largest candle (high - low) compared to the last 7 previous ones

//Open trade on the next candle once it breaks bulish engulfing candle's high and take profit close below previous resistance
//Stop loss goes a few pips below signal candle low

lowerLow = low < low[1]
bullishEngulfing = open[1] > close[1] and close > open and close >= open[1] and close[1] >= open and close - open and open[1] - close[1] 
roomToTheLeftFalling = falling(low, roomToTheLeftPeriod)
barcolor(lowerLow and bullishEngulfing and roomToTheLeftFalling and largestCandle ? white : na)
````
