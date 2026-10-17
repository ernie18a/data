# 5 SMA Perfect Order + 6 SMA Display

- url: https://www.tradingview.com/script/7xF6QW8m/
- type: indicator
- pine_id: PUB;3d9f9bb600034951af6b8e7219998fc1
- version: 1.0

## Description

A clean trend-following indicator built around multiple Simple Moving Averages (SMAs).

This indicator combines trend confirmation, momentum visualization, and crossover signals while keeping the chart easy to read.

## Features

* Displays **5, 20, 60, 100, and 200 SMAs**.
* Highlights the chart background when a **Perfect Order** is established:

  * **Bullish:** 5 > 20 > 60 > 100
  * **Bearish:** 5 < 20 < 60 < 100
* Fills the area between the **5 SMA** and **20 SMA** only when the short-term and medium-term trends are aligned:

  * Green: **5 > 20 > 60**
  * Red: **5 < 20 < 60**
* Displays **buy and sell arrows** when the **5 SMA crosses the 20 SMA**.
* Includes **alert support** for both bullish and bearish 5/20 SMA crossovers.

## How to Use

* **Background color** helps identify the overall trend.
* **5–20 SMA fill** highlights periods when short-term momentum agrees with the medium-term trend, helping reduce signals during ranging markets.
* **Cross arrows** provide potential entry timing based on the 5/20 SMA crossover.

## Notes

This indicator is designed for trend-following and swing trading strategies. It is intended to simplify chart analysis by showing only the most important trend information without unnecessary visual clutter.

## Source Code

````pine
//@version=6
indicator("5-20-60 Perfect Order + 5/20 Cross Arrows", overlay=true)

// ===== SMA設定 =====
sma5Length   = input.int(5, "SMA 5")
sma20Length  = input.int(20, "SMA 20")
sma60Length  = input.int(60, "SMA 60")
sma100Length = input.int(100, "SMA 100")
sma200Length = input.int(200, "SMA 200")

// ===== SMA計算 =====
sma5   = ta.sma(close, sma5Length)
sma20  = ta.sma(close, sma20Length)
sma60  = ta.sma(close, sma60Length)
sma100 = ta.sma(close, sma100Length)
sma200 = ta.sma(close, sma200Length)

// ===== パーフェクトオーダー（5・20・60・100）=====
bullPerfect =
     sma5 > sma20 and
     sma20 > sma60 and
     sma60 > sma100

bearPerfect =
     sma5 < sma20 and
     sma20 < sma60 and
     sma60 < sma100

// ===== 背景色 =====
bgcolor(
     bullPerfect ? color.new(color.green, 90) :
     bearPerfect ? color.new(color.red, 90) :
     na
)

// ===== SMA表示 =====
p5  = plot(sma5,   title="SMA 5",   color=color.rgb(255, 0, 0), linewidth=1)
p20 = plot(sma20,  title="SMA 20",  color=color.rgb(3, 36, 249), linewidth=1)

plot(sma60,  title="SMA 60",  color=color.rgb(116, 5, 252), linewidth=1)
plot(sma100, title="SMA 100", color=color.rgb(245, 111, 1), linewidth=1)
plot(sma200, title="SMA 200", color=color.rgb(24, 197, 162), linewidth=1)

// ===== 5SMAと20SMAの間を塗る（20SMAと60SMAが同方向の時だけ）=====
fill(
     p5,
     p20,
     color =
         sma5 > sma20 and sma20 > sma60 ? color.new(color.green, 85) :
         sma5 < sma20 and sma20 < sma60 ? color.new(color.red, 85) :
         na
)

// ===== 5SMAと20SMAのクロス矢印 =====
buySignal = ta.crossover(sma5, sma20)
sellSignal = ta.crossunder(sma5, sma20)

plotshape(
     buySignal,
     style=shape.triangleup,
     location=location.belowbar,
     color=#1ea38d,
     size=size.tiny
)

plotshape(
     sellSignal,
     style=shape.triangledown,
     location=location.abovebar,
     color=color.rgb(244, 123, 123),
     size=size.tiny
)

// ===== どちらかのクロスでアラート =====
crossSignal = buySignal or sellSignal

alertcondition(
     crossSignal,
     title="5SMA and 20SMA Cross",
     message="5SMA and 20SMA have crossed."
)
````
