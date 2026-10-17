# Strong Candle Closure

- url: https://www.tradingview.com/script/qAJmCINh-Strong-Candle-Closure/
- type: indicator
- pine_id: PUB;5ca8d137c00245d9b604ecd7f21421d8
- version: 1.0

## Description

The indicator highlights strongly closed candlesticks - you can adjust the closing force manually, the indicator provides the ability to set up 2 ranges and send a notification to each of them.

For example, for you, a strongly closed candle is a candle that has closed from 85 to 100% of the maximum/minimum, respectively, after a candle, such as a daily candle, closes, a notification will be triggered

## Source Code

````pine
//@version=6
indicator("STR Close", overlay = true)

// ───── Включение диапазонов ─────
useRange1 = input.bool(true,  "Enable Range 1")
useRange2 = input.bool(true,  "Enable Range 2")

// ───── Настройки диапазонов ─────
minStrength1 = input.float(85.0, "Range 1 Min (%)", minval = 0, maxval = 100, step = 0.1)
maxStrength1 = input.float(100.0,"Range 1 Max (%)", minval = 0, maxval = 100, step = 0.1)

minStrength2 = input.float(80.0, "Range 2 Min (%)", minval = 0, maxval = 100, step = 0.1)
maxStrength2 = input.float(84.99,"Range 2 Max (%)", minval = 0, maxval = 100, step = 0.1)

// ───── Цвета ─────
bullColor1 = input.color(color.new(color.green, 0), "Bull Color Range 1")
bearColor1 = input.color(color.new(color.red,   0), "Bear Color Range 1")

bullColor2 = input.color(color.new(color.blue,  0), "Bull Color Range 2")
bearColor2 = input.color(color.new(color.purple,0), "Bear Color Range 2")

// ───── Логика ─────
candleRange = high - low
validRange  = candleRange > 0

closePos = validRange ? (close - low) / candleRange * 100 : na

isConfirmed = barstate.isconfirmed

eps = 0.0001

// ───── Диапазон 1 ─────
strongBull1 = useRange1 and isConfirmed and validRange and close > open and closePos >= minStrength1 and closePos < (maxStrength1 + eps)
strongBear1 = useRange1 and isConfirmed and validRange and close < open and closePos <= (100 - minStrength1 + eps) and closePos > (100 - maxStrength1 - eps)

// ───── Диапазон 2 ─────
strongBull2 = useRange2 and isConfirmed and validRange and close > open and closePos >= minStrength2 and closePos <= (maxStrength2 + eps)
strongBear2 = useRange2 and isConfirmed and validRange and close < open and closePos <= (100 - minStrength2 + eps) and closePos >= (100 - maxStrength2 - eps)

// ───── Окрашивание свечей ─────
barcolor(
     strongBull2 ? bullColor2 :
     strongBear2 ? bearColor2 :
     strongBull1 ? bullColor1 :
     strongBear1 ? bearColor1 :
     na
)

// ───── Алерты ─────
alertcondition(strongBull1, title = "STR Bull Candle R1", message = "STR Bull Candle R1")
alertcondition(strongBear1, title = "STR Bear Candle R1", message = "STR Bear Candle R1")

alertcondition(strongBull2, title = "STR Bull Candle R2", message = "STR Bull Candle R2")
alertcondition(strongBear2, title = "STR Bear Candle R2", message = "STR Bear Candle R2")
````
