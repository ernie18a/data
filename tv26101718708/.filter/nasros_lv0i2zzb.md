# NASROS

- url: https://www.tradingview.com/script/lV0I2zZB/
- type: indicator
- pine_id: PUB;cba59fc207fc45c5bbbcaf3c9ac30548
- version: 1.0

## Description

هذا النص البرمجي تجريبي لمحاولة اقتناص قاع انعكاسي 
تمنياتي للجميع بالتوفيق

## Source Code

````pine
//@version=5
indicator("Reversal Scanner | Volume + Candles + Lows", overlay=true)

// القاع السنوي
lowest_52 = ta.lowest(low, 252)
near_low = close <= lowest_52 * 1.10

// شموع الانعكاس
bull_engulf = close > open and open < close[1] and open[1] > close[1]
hammer = (high - low) > 3 * math.abs(open - close) and (close - low) <= (high - low) * 0.25
morning_star = close[2] < open[2] and close[1] < open[1] and close > (open[2] + close[2]) / 2

candle_signal = bull_engulf or hammer or morning_star

// فوليوم شراء قوي
vol_avg = ta.sma(volume, 20)
vol_signal = volume > vol_avg * 1.5

// RSI
rsi = ta.rsi(close, 14)
rsi_signal = rsi >= 30 and rsi <= 45

// MACD Histogram rising
macd = ta.ema(close, 12) - ta.ema(close, 26)
signal = ta.ema(macd, 9)
hist = macd - signal
macd_signal = hist > hist[1]

// الشرط النهائي
reversal_zone = near_low and candle_signal and vol_signal and rsi_signal and macd_signal

// تغيير لون الشمعة عند تحقق الانعكاس
barcolor(reversal_zone ? color.white : na)

// كتابة النص تحت الشمعة
plotshape(reversal_zone, style=shape.labeldown, text="ناصر متكي هنا", location=location.belowbar, color=color.white, textcolor=color.black, size=size.tiny)
````
