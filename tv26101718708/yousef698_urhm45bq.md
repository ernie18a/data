# Yousef_698

- url: https://www.tradingview.com/script/Urhm45bq-Yousef-698/
- type: indicator
- pine_id: PUB;87d1eb024ae34a8a95d22fdeb3c78b4d
- version: 1.0

## Description

to find Ls candles that can help you with your S and will help you find patterns and entry signals

## Source Code

````pine
//@version=6
indicator("Dominant Shadow Candles v6", overlay = true)

// === Candle Parts ===
body = math.abs(close - open)
upperShadow = high - math.max(open, close)
lowerShadow = math.min(open, close) - low

// جلوگیری از دوجی‌های بدون بادی
hasBody = body > syminfo.mintick

// === Pattern 1: Dominant Lower Shadow ===
// شدوی پایین از بادی و شدوی بالا بزرگتر باشد
// شدوی بالا بیشتر از 7 برابر بادی نباشد
lowerPattern = hasBody and
     lowerShadow > body and
     lowerShadow > upperShadow and
     upperShadow <= body * 7

// === Pattern 2: Dominant Upper Shadow ===
// شدوی بالا از بادی و شدوی پایین بزرگتر باشد
// شدوی پایین بیشتر از 7 برابر بادی نباشد
upperPattern = hasBody and
     upperShadow > body and
     upperShadow > lowerShadow and
     lowerShadow <= body * 7

// === Plot Shapes ===
plotshape(lowerPattern, 
     title = "Lower Dominant", 
     style = shape.triangleup, 
     location = location.belowbar, 
     color = color.lime, 
     size = size.small)

plotshape(upperPattern, 
     title = "Upper Dominant", 
     style = shape.triangledown, 
     location = location.abovebar, 
     color = color.red, 
     size = size.small)

// رنگی کردن کندل‌ها (اختیاری)
barcolor(lowerPattern ? color.lime : upperPattern ? color.red : na)

// === Alerts ===
alertcondition(lowerPattern, 
     title = "Lower Shadow Alert", 
     message = "Dominant lower shadow candle detected")

alertcondition(upperPattern, 
     title = "Upper Shadow Alert", 
     message = "Dominant upper shadow candle detected")
````
