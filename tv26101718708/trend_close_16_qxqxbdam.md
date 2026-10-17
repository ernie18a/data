# Trend Close 1/6

- url: https://www.tradingview.com/script/qXqxbdam/
- type: indicator
- pine_id: PUB;39e7614c83424e51815ca0d1daf502b3
- version: 1.0

## Description

Title:
Trend Close 1/6 Bar Color Highlight (Daily Reset)

Description:
This indicator highlights bullish or bearish momentum based on the close price landing in the upper 1/6 or lower 1/6 of a candle's range, but only for the first 6 candles of each trading day.

How it works:

A new day is detected using dayofweek change (same logic as the popular "Bar Count" script).

For candles 1 through 6 each day, the script calculates the top 1/6 boundary (high - range/6) and bottom 1/6 boundary (low + range/6).

Bullish condition: Close > Open and Close ≥ top boundary → candle is recolored with the user-selected Bull Color.

Bearish condition: Close < Open and Close ≤ bottom boundary → candle is recolored with the user-selected Bear Color.

All other candles retain their default chart colors.

Features:

Fully customizable hex color inputs for both conditions (defaults: Dark Red #8B0000 for bullish, Dark Green #006400 for bearish).

Daily reset ensures only the opening range of each session is analyzed.

Clean, overlay-only design with no background fills or extra drawings.

Usage:

Use to identify early session momentum exhaustion or breakout confirmations.

Combine with volume or support/resistance levels for higher-probability entries.

Inputs:

Bull Trend Color – Color for candles closing in the upper 1/6 of their range while being bullish (close > open).

Bear Trend Color – Color for candles closing in the lower 1/6 of their range while being bearish (close < open).

## Source Code

````pine
//@version=6
indicator("Trend Close 1/6", overlay=true)

// 颜色输入（可直接粘贴十六进制码如 #FF0000）
bullColor = input.color(#8B0000, "Bull Trend Color")   // 深红默认
bearColor = input.color(#006400, "Bear Trend Color")   // 深绿默认

// 新日检测函数
is_new_day() =>
    d = dayofweek
    na(d[1]) or d != d[1]

// 当天 K 线计数（从 1 开始）
var int count = 0
if is_new_day() 
    count := 1
else
    count := count + 1

// 仅前 6 根 K 线参与判断
bool inFirstSix = count <= 6

// 计算 1/6 价格区域边界
float barRange   = high - low
float topLevel   = high - barRange / 6
float bottomLevel = low  + barRange / 6

// 条件判断
bool bullCondition = inFirstSix and close > open and close >= topLevel
bool bearCondition = inFirstSix and close < open and close <= bottomLevel

// 应用 K 线颜色
barcolor(bullCondition ? bullColor : na)
barcolor(bearCondition ? bearColor : na)
````
