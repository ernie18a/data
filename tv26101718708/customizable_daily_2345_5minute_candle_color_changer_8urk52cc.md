# Customizable Daily 23:45 5-Minute Candle Color Changer

- url: https://www.tradingview.com/script/8URK52cC/
- type: indicator
- pine_id: PUB;a17677fae17245ec86f0fac9863ce7c4
- version: 1.0

## Description

Description (描述)
This script highlights the 5-minute candle at 23:45 Beijing time every trading day.
- Bullish candle (close >= open) turns light pink
- Bearish candle (close < open) turns light green
Both the candle body and border colors are changed.
You can customize the target hour/minute and the bullish/bearish colors via script inputs.
Important: Only works on 5-minute charts. Other timeframes will show an error.

## Source Code

````pine
//@version=6
indicator("23:45 5分钟K线高亮（无背景）", overlay=true)

// 可自定义的颜色变量（K线整体颜色，包括实体和边框）
bullColor    = input.color(color.new(#FFC0CB, 0), "阳线颜色")   // 浅粉色
bearColor    = input.color(color.new(#90EE90, 0), "阴线颜色")   // 浅绿色

// 目标时间
targetHour   = input.int(23, "目标小时")
targetMinute = input.int(45, "目标分钟")

// 检查周期
if timeframe.period != "5"
    runtime.error("本脚本仅适用于5分钟图表")

// 北京时间判断
utcTime = time
isTarget = hour(utcTime, "Asia/Shanghai") == targetHour and minute(utcTime, "Asia/Shanghai") == targetMinute

// 阴阳线
isBullish = close >= open

// 仅修改目标K线的整体颜色（无背景高亮）
barcolor(isTarget ? (isBullish ? bullColor : bearColor) : na)
````
