# New York Session Highlighter v6 (08:30-11:30)

- url: https://www.tradingview.com/script/K7mTWl7y-New-York-Session-Highlighter-v6-08-30-11-30/
- type: indicator
- pine_id: PUB;4e409bdc9e334a17854cb18c5e786d8a
- version: 2.0

## Description

* **NY AM Session Highlight**: Automatically shades the chart background from 08:30 to 11:30 New York Time (the classic NY Killzone / Morning Session).
* **Automatic DST Handling**: Utilizing the "America/New_York" timezone, this script automatically adjusts for Eastern Standard Time (EST) and Eastern Daylight Time (EDT). No manual updates required.
* **Fully Customizable**: Easily adjust the session hours, active days, background color, and opacity directly from the script settings.
* **Pine Script v6 Optimized**: Built natively using the latest v6 standards for maximum type-safety and chart performance.

## Source Code

````pine
//@version=6
indicator(
     "纽约时间高亮 v6 (08:30-11:30)",
     overlay=true,
     max_lines_count=500
)

// 输入参数
timeSession  = input.session("0830-1130", title="高亮时间段")
timeZone     = input.string("America/New_York", title="时区")
bgColorInput = input.color(color.new(color.blue, 90), title="高亮颜色")

line0930Color = input.color(color.red, title="09:30 竖线颜色")
line0950Color = input.color(color.orange, title="09:50 竖线颜色")
lineWidth     = input.int(1, title="竖线宽度", minval=1, maxval=5)

// 08:30–11:30 背景高亮
inSession = not na(
     time(timeframe.period, timeSession + ":234567", timeZone)
)

bgcolor(inSession ? bgColorInput : na)

// 获取当前 K 线对应的纽约日期
nyYear  = year(time, timeZone)
nyMonth = month(time, timeZone)
nyDay   = dayofmonth(time, timeZone)

// 当天纽约时间 09:30 和 09:50 的时间戳
time0930 = timestamp(timeZone, nyYear, nyMonth, nyDay, 9, 30)
time0950 = timestamp(timeZone, nyYear, nyMonth, nyDay, 9, 50)

// 当前 K 线首次跨过目标时间
cross0930 = time >= time0930 and time[1] < time0930
cross0950 = time >= time0950 and time[1] < time0950

// 绘制贯穿图表的竖线
if cross0930
    line.new(
         x1=time0930,
         y1=low,
         x2=time0930,
         y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=line0930Color,
         width=lineWidth
    )

if cross0950
    line.new(
         x1=time0950,
         y1=low,
         x2=time0950,
         y2=high,
         xloc=xloc.bar_time,
         extend=extend.both,
         color=line0950Color,
         width=lineWidth
    )
````
