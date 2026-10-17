# Trend Predictor Ribbon Clone - Fixed roj karo moj karo

- url: https://www.tradingview.com/script/XtGU6toW-Trend-Predictor-Ribbon-Clone-Fixed-roj-karo-moj-karo/
- type: indicator
- pine_id: PUB;eec9d5bec0764b4ba9cfd017cc446ad7
- version: 1.0

## Description

this is for reading and watching purpose  roj karo moj karo

## Source Code

````pine
//@version=6
indicator("Trend Predictor Ribbon Clone - Fixed", overlay=true)

// --- Inputs (पैरामीटर्स जो आप सेटिंग से बदल सकते हैं) ---
src = input.source(close, title="Source")
length = input.int(10, minval=1, title="Trend Length")
multiplier = input.float(2.0, minval=0.1, title="ATR Multiplier")

// --- Calculations (कैलकुलेशन) ---
atrValue = ta.atr(length)
hmaValue = ta.hma(src, length)

// ट्रेंड की दिशा तय करने के लिए बेसिक्स
var float trendStop = na
var int trendDir = 1

longStop = hmaValue - (multiplier * atrValue)
shortStop = hmaValue + (multiplier * atrValue)

if (na(trendStop))
    trendStop := hmaValue

if trendDir == 1 and close < trendStop
    trendDir := -1
    trendStop := shortStop
else if trendDir == -1 and close > trendStop
    trendDir := 1
    trendStop := longStop
else
    trendStop := trendDir == 1 ? math.max(longStop, trendStop) : math.min(shortStop, trendStop)

// --- Colors & Transparency (कलर फिक्स) ---
bullColor = color.new(color.green, 10)
bearColor = color.new(color.red, 10)
cloudBull = color.new(color.green, 85)
cloudBear = color.new(color.red, 85)
fullyTransparent = color.new(color.blue, 100) // यहाँ एरर को फिक्स किया गया है

// --- Plots (चार्ट पर ड्रा करना) ---
p_price = plot(close, title="Price Line", color=fullyTransparent)
p_stop = plot(trendStop, title="Trend Line", color=trendDir == 1 ? bullColor : bearColor, linewidth=3)

// इमेज जैसा Gradient Cloud इफ़ेक्ट देने के लिए fill कमांड
fill(p_price, p_stop, color=trendDir == 1 ? cloudBull : cloudBear, title="Trend Ribbon")

// --- Buy/Sell Shapes ---
plotshape(ta.crossover(close, trendStop), title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(ta.crossunder(close, trendStop), title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
````
