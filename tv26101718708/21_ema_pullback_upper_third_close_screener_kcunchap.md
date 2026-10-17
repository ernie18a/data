# 21 EMA Pullback + Upper Third Close Screener

- url: https://www.tradingview.com/script/kCuNChaP/
- type: indicator
- pine_id: PUB;9b4f49db429343dbbe5be4038017f8fc
- version: 2.0

## Description

سكنر لبحث الاسهم التي عادت الى متوسط 21
21 EMA Pullback + Upper Third Close Screener

## Source Code

````pine
//@version=6
indicator("Abdullah Pullback Screener 21EMA", overlay=true)

// المتوسطات
ema21 = ta.ema(close, 21)
sma50 = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)

// الحجم
volAvg50 = ta.sma(volume, 50)
strongVolume = volume > volAvg50

// لمس 21 EMA
touchEMA21 = low <= ema21 and high >= ema21

// الإغلاق في الثلث العلوي
candleRange = high - low
upperThirdClose = candleRange > 0 ? (close - low) / candleRange >= 0.67 : false

// ترند صحي
above21 = close > ema21
above50 = close > sma50
above150 = close > sma150
above200 = close > sma200
maStack = sma50 > sma150 and sma150 > sma200

// قريب من أعلى 52 أسبوع
high52 = ta.highest(high, 252)
offHigh52 = ((close / high52) - 1) * 100
nearHigh52 = offHigh52 >= -25

// الشرط النهائي
setup = touchEMA21 and upperThirdClose and strongVolume and above21 and above50 and above150 and above200 and maStack and nearHigh52

// أعمدة تظهر في Pine Screener
plot(setup ? 1 : 0, title="Setup")
plot(ema21, title="EMA21")
plot(offHigh52, title="Off 52W High %")
plot(volume / volAvg50, title="Volume vs Avg50")
plot(close / ema21, title="Close vs EMA21")
````
