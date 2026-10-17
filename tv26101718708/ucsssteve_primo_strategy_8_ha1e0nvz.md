# UCS_S_Steve Primo - Strategy #8

- url: https://www.tradingview.com/script/Ha1E0nVZ-UCS-S-Steve-Primo-Strategy-8/
- type: indicator
- pine_id: PUB;1164
- version: -1.0

## Description

Hello Fellas, 

Hope you are trading fantastic and fine. Here is another setup from Steve Primo (Stocks) Setups. He claims this can be applied on any market, and you can. Primarily focused on Stocks and Futures market. 

NOTE : I DID CODE THE BOTTOM INDICATOR, NOT PUBLISHING IT, ITS JUST RSI(5)

What did I change, ofcourse I don't publish what I find, There is a bit of me in the codes.....
1. Setup only shows up at meaningful levels, Stringent Filter

Myself and tradearcher will keep this upto date. As he has volenteered to help with the track record of steve primo strategies. 
https://docs.google.com/spreadsheets/d/1I-BLZGJl612g3a8UoWhtRhdF1ECgM49djVbf5TQIHsM/edit?usp=sharing

This is more like catching a freight train after a mini pullback. 

AGAIN, This is not a holy grail, but this fits my personality of trading, Buying pullbacks on stronger stocks. Because it is harder to get a UCS_momo_Oscillator to signal a setup, primarily because of the smoothing, you can use this as an alternative to catch the excitement trade. 

Do not sit on it for more than T+4 days, Unless another setup triggered in your way. 

Rule - Buy/Sell the candle breakout next day after the setup -  in the direction it is setting up
- Close the Position @ 100% candle extension or RSI Oversold.

## Source Code

````pine
// Coded by UCSgears - Steve Primo's Setup
// I do not own the strategy, Developed by taking hints from his video library in Youtube
// So far, this can be one of my fav setup, Fits my mentalilty.

study(shorttitle="SP-S#8", title = "Steve Primo - Strategy #8", overlay = true, precision = 2)

trend = sma(close, 50)
rsi = rsi(close, 5)
rsitriggervalue = 50
petd = ema(close,15)

// PET-D
petdcolor = close > petd ? green : red
barcolor (petdcolor)

// ALL PLOT
plot(trend, linewidth = 3, color = black, title = "Trend - Long Term")
plot(petd, linewidth = 1, color = blue, title = "Trend - Short Term")

//Setup Long
al = low > trend and close > trend
bl = rsi[1] < rsitriggervalue and rsi > rsitriggervalue and rsi < 60
cl = close > petd 
zl = (al == 1 and bl == 1 and cl == 1) ? 1 : na

//Setup Short
as = high < trend and close < trend
bs = rsi[1] > rsitriggervalue and rsi < rsitriggervalue and rsi > 40
cs = close < petd 
zs = (as == 1 and bs == 1 and cs == 1) ? 1 : na

// Bar Color 
zc = zl == 1 ? green : zs == 1 ? red : na

// All Plot
plotchar(zl ,location=location.belowbar, text="Strategy #8 Long", color = zc)
plotchar(zs ,location=location.abovebar, text="Strategy #8 Short", color = zc)

//plot(rsi)
//plot(rsitriggervalue)
````
