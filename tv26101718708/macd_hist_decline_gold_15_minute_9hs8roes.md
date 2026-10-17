# MACD & Hist Decline gold 15 minute

- url: https://www.tradingview.com/script/9hs8roEs/
- type: indicator
- pine_id: PUB;07899c7b56d4487490a089b5c436a849
- version: 1.0

## Description

เวอร์ชั่นทดลองการเทรดทอง 15 นาที เป็นการทดลองเพื่อฝึกเขียน pine script และจะพัฒนาต่อเนื่อง ไปเรื่อยๆ

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © apichartpgg

//@version=6
indicator("Full Strategy: MACD & Hist Decline", overlay=true)

// --- Inputs ---
emaLength = input.int(200, "EMA Filter (Trend)")
rsiOS = input.int(30, "RSI Oversold (Buy)")
rsiOB = input.int(70, "RSI Overbought (Sell)")

// MACD Inputs
fast = input.int(12, "MACD Fast")
slow = input.int(26, "MACD Slow")
signal = input.int(9, "MACD Signal")
histLow = input.float(-2,"Histogram buy Threshold")

// Input for threshold to define a "small body"
bodyRatioThreshold = input.float(0.1, title="Doji Body Ratio Threshold (e.g., 0.1 for 10%)", minval=0.01, maxval=0.5)
// Input for wick ratio to define "long" or "short" wicks
wickRatioThreshold = input.float(0.4, title="Long Wick Ratio Threshold (e.g., 0.4 for 40%)", minval=0.1, maxval=0.9)

// Helper function to check for small body
isSmallBody(open_val, close_val, high_val, low_val) =>
    bodySize = math.abs(close_val - open_val)
    candleRange = high_val - low_val
    candleRange > 0 ? (bodySize / candleRange <= bodyRatioThreshold) : true // Handles Four Price Doji

// Calculate wick lengths
upperShadow = high - math.max(open, close)
lowerShadow = math.min(open, close) - low
totalRange = high - low

// --- Standard Doji ---
// Small body, relatively balanced upper and lower shadows (or overall short wicks)
isStandardDoji = isSmallBody(open, close, high, low) and
                 (upperShadow / totalRange > 0.1 and lowerShadow / totalRange > 0.1) // Some wicks
                 // More balanced wick check: math.abs(upperShadow - lowerShadow) / totalRange < 0.2

// --- Long-Legged Doji ---
// Small body, very long upper and lower shadows
isLongLeggedDoji = isSmallBody(open, close, high, low) and
                   upperShadow / totalRange >= wickRatioThreshold and
                   lowerShadow / totalRange >= wickRatioThreshold

// --- Dragonfly Doji ---
// Small body (or non-existent) at the top of the candle, long lower shadow, little to no upper shadow
isDragonflyDoji = isSmallBody(open, close, high, low) and
                  lowerShadow / totalRange >= wickRatioThreshold and
                  upperShadow / totalRange < bodyRatioThreshold * 0.5 // Upper shadow is tiny

// --- Gravestone Doji ---
// Small body (or non-existent) at the bottom of the candle, long upper shadow, little to no lower shadow
isGravestoneDoji = isSmallBody(open, close, high, low) and
                   upperShadow / totalRange >= wickRatioThreshold and
                   lowerShadow / totalRange < bodyRatioThreshold * 0.5 // Lower shadow is tiny

// --- Four Price Doji ---
// Open, high, low, close are all the same
isFourPriceDoji = (open == high) and (high == low) and (low == close)

// rsi Inputs
rsiF = ta.rsi(close,3)

// --- Calculations ---
ema200 = ta.ema(close, emaLength)
emaClose12 = ta.ema(close, 12)
emaClose3 = ta.ema(close, 3)
rsiVal = ta.rsi(close, 14)
[macdLine, signalLine, hist] = ta.macd(close, fast, slow, signal)


// ใช้สำหรับดูจังหวะ Momentum ขาขึ้นเริ่มหมดแรง
// Logic: Histogram ลดลงต่อเนื่อง 5 แท่ง (Decline)
histDecline = hist[0] < hist[1] and hist[1] < hist[2] and hist[2] < hist[3] and hist[3] < hist[4] and hist[4] < hist[5]
// Logic: Histogram เพิ่มขึ้นต่อเนื่อง 3 แท่ง (Ascend)
histAscend = hist[0] >= hist[1] and hist[1] >= hist[2] and hist[2] >= hist[3]

// Logic: Histogram 5 แท่งในโซนบวก
hits5Postive = hist[0]>=0 and hist[1]>=0 and hist[2]>=0 and hist[3]>=0 and hist[4]>=0 and hist[5]>=0 

// Logic: Histogram 5 แท่งในโซนลบ
hits5Negative = hist[0]<=0 and hist[1]<=0 and hist[2]<=0 and hist[3]<=0 and hist[4]<=0 and hist[5]<=0 

// Logic: Histogram เปลี่ยนทิศไปทางบวก แจ้งการเข้าซื้อ
histBuy = hist[0] > hist[1] and hist[1] < hist[2] 

// Logic : จุดขายเมื่อเจอ Histogram เริ่มลดลง 1 ทั้งในโซนบวกและลบ 5 แท่งก่อนหน้านี้
histSell = hist[0] < hist[1] and hist[1] > hist[2]  and hist[2] > hist[3] and (hits5Postive or hits5Negative)

rsicrossD = ta.crossunder(rsiF, rsiVal)
rsicrossU = ta.crossover(rsiF, rsiVal)
// --- BUY Condition ---
// 1. MACD ตัดขึ้นใต้เส้น 0
// 2. RSI เคยต่ำกว่า 30 (ในช่วง 5 แท่ง)
// 3. ราคาต้องยืนเหนือ EMA 200 (กรองเทรนขาขึ้น)
macdBuyCross = ta.crossover(macdLine, signalLine) and macdLine < 0
rsiBuyCond = rsicrossU and rsiVal <= rsiOS
//rsiBuyCond = ta.barssince(rsiVal <= rsiOS) <= 5
//buySignal = macdBuyCross or  rsiBuyCond or (histTop and hist < 0)//and rsiBuyCond //and close > ema200
buySignal = (histBuy and hist < histLow ) //and macdLine < -5
// --- SELL Condition ---
// 1. MACD ตัดลงเหนือเส้น 0 
// 2. หรือ RSI เข้าเขต Overbought (> 70)
// 3. หรือ Histogram เริ่มลดลงต่อเนื่อง 3 แท่งในโซนบวก (สัญญาณเตือนขายกำไร)

macdSellCross = ta.crossunder(macdLine, signalLine) //and macdLine > 0
//sellSignal = (macdSellCross and rsiVal >= rsiOB)// and  histDecline //(histDecline and hist > 0 and rsiVal > 90)
//s2 = ta.barssince(rsiVal > 90) <= 5 
//sellSignal = histSell and macdLine[0] > signalLine[0] and hist[0] < macdLine[0] and emaClose3 > emaClose12  and macdLine > -1 
sellSignal = histSell and  macdLine > -1 
//rsicrossD and hist > 0//and histAscend
//sellSignal = macdSellCross or rsiVal >= rsiOB or (histDecline and hist > 0 and rsiVal > 90)
// --- Visuals on Chart ---
plot(ema200, color=color.new(color.gray, 50), title="EMA 200")
plot(emaClose12, color=#34cc9c80, title="EMA 12")
plot(emaClose3, color=color.rgb(204, 26, 172, 50), title="EMA 3")
// แสดงจุด Buy
plotshape(buySignal, "BUY", shape.labelup, location.belowbar, color.green, text="BUY", textcolor=color.white, size=size.small)

// แสดงจุด Sell (รวมจังหวะ Histogram แผ่วด้วย)
plotshape(sellSignal, "SELL", shape.labeldown, location.abovebar, color.red, text="SELL", textcolor=color.white, size=size.small)

// ไฮไลท์สีพื้นหลังเมื่อ Histogram ลดลงต่อเนื่องในโซนบวก (Warning Zone)
bgcolor(histDecline and hist > 0 ? color.new(color.orange, 90) : na)

// Plot shapes for detected patterns
//plotshape(isStandardDoji,     title="Standard Doji",    location=location.belowbar, color=color.new(color.gray, 0), style=shape.circle, size=size.small, text="SD")
//plotshape(isLongLeggedDoji,   title="Long-Legged Doji", location=location.belowbar, color=color.new(color.orange, 0), style=shape.circle, size=size.normal, text="LLD")
//plotshape(isDragonflyDoji,    title="Dragonfly Doji",   location=location.belowbar, color=color.new(color.green, 0), style=shape.triangleup, size=size.normal, text="DFD")
//plotshape(isGravestoneDoji,   title="Gravestone Doji",  location=location.abovebar, color=color.new(color.red, 0), style=shape.triangledown, size=size.normal, text="GSD")
//plotshape(isFourPriceDoji,    title="Four Price Doji",  location=location.belowbar, color=color.new(color.purple, 0), style=shape.diamond, size=size.small, text="4PD")

// --- Alerts ---
alertcondition(buySignal, "Long Entry", "MACD Bullish Cross + RSI OS")
alertcondition(sellSignal, "Exit Signal", "MACD Bearish Cross / Hist Decline")
````
