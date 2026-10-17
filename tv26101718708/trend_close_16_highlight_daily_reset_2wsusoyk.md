# Trend Close 1/6 Highlight (Daily Reset)

- url: https://www.tradingview.com/script/2WSUSoYk/
- type: indicator
- pine_id: PUB;3f02701303974d64a57a10dbb0559431
- version: 1.0

## Description

Indicator Name: Trend Close 1/6 Highlight

Description:

This indicator highlights the first 6 bars of each trading day when the closing price is within the extreme 1/6 price range of that bar.

For a bearish bar (close < open) that closes in the lower 1/6 of its range (i.e., close ≤ low + (high-low)/6), a semi‑transparent light green rectangle is drawn from high to low, covering the entire price range of the bar.

For a bullish bar (close > open) that closes in the upper 1/6 of its range (i.e., close ≥ high – (high-low)/6), a semi‑transparent light pink rectangle is drawn from high to low.

Key features:

The count resets at the start of each new trading day (detected by a change in the day of the week).

Only the first 6 bars of the day are evaluated; no rectangles are drawn on later bars.

Rectangles are aligned precisely with the bar's time interval (time to time_close) using xloc.bar_time, so they do not extend into adjacent bars.

The background color transparency can be adjusted (default: 80/100).

No border is drawn (border_width = 0).

Use case:
Quickly spot bars where price closes extremely near the low (strong bearish momentum) or extremely near the high (strong bullish momentum) during the early part of the trading session.

## Source Code

````pine
//@version=6
indicator("Trend Close 1/6 Highlight (Daily Reset)", overlay=true)

// 使用与 Bar Count 相同的新日检测函数
is_new_day() =>
    d = dayofweek
    na(d[1]) or d != d[1]

// 当天已走完的 K 线计数（从 1 开始）
var int count = 0
if is_new_day()
    count := 1
else
    count := count + 1

// 仅对前 6 根 K 线进行判断
bool inFirstSix = count <= 6

// 当前 K 线的 1/6 价格区间
float barRange = high - low
float topLevel  = high - barRange / 6   // 上 1/6 区域的下边界
float bottomLevel = low + barRange / 6  // 下 1/6 区域的上边界

// 条件判断（确保数据有效）
bool bearCondition = close < open and close <= bottomLevel
bool bullCondition = close > open and close >= topLevel

// 绘制矩形（仅在前 6 根且数据有效时）
if inFirstSix and not na(close) and not na(open)
    if bearCondition
        box.new(
             left   = time,
             right  = time_close,
             top    = high,
             bottom = low,
             bgcolor = color.new(color.green, 80),
             border_width = 0,
             xloc = xloc.bar_time
         )
    if bullCondition
        box.new(
             left   = time,
             right  = time_close,
             top    = high,
             bottom = low,
             bgcolor = color.new(color.red, 80),
             border_width = 0,
             xloc = xloc.bar_time
         )
````
