# SMA 21, 50 y 200 All-in-One Script | Triple Moving Average

- url: https://www.tradingview.com/script/5tKpTFVq/
- type: indicator
- pine_id: PUB;bd9ebfa40fef48a9ae6bd9d3f2862fef
- version: 2.0

## Description

📊 TRIPLE MOVING AVERAGE SCRIPT (3-in-1)

This script plots the 3 most important Simple Moving 
Averages in a single indicator:

📈 MOVING AVERAGES INCLUDED
- SMA 21 → Short-term trend
- SMA 50 → Medium-term trend  
- SMA 200 → Long-term trend

🎯 HOW TO USE
✅ Price above SMA 200 = Bullish bias
✅ SMA 21 crosses above SMA 50 = Buy signal
❌ SMA 21 crosses below SMA 50 = Sell signal
❌ Price below SMA 200 = Bearish bias

⚙️ FEATURES
- All 3 MAs in one single indicator
- Clean and simple visualization
- Works on any timeframe
- Works on any asset (stocks, crypto, forex)

💡 RECOMMENDED TIMEFRAMES
Daily and Weekly for best results

⚠️ DISCLAIMER
This is not financial advice. 
Use it as part of your own analysis.

## Source Code

````pine
//@version=6
indicator("Medias Móviles 21 / 50 / 200", overlay=true)

// Parámetros
len21  = input.int(21,  title="SMA 21")
len50  = input.int(50,  title="SMA 50")
len200 = input.int(200, title="SMA 200")

// Cálculo
sma21  = ta.sma(close, len21)
sma50  = ta.sma(close, len50)
sma200 = ta.sma(close, len200)

// Ploteo
plot(sma21,  color=color.blue,  linewidth=2, title="SMA 21")
plot(sma50,  color=color.yellow, linewidth=2, title="SMA 50")
plot(sma200, color=color.red,    linewidth=3, title="SMA 200")
````
