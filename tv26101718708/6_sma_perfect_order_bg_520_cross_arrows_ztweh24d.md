# 6 SMA Perfect Order BG + 5/20 Cross Arrows

- url: https://www.tradingview.com/script/ZtwEH24d/
- type: indicator
- pine_id: PUB;863c2f2e3a464b0d8fba24f898fad43a
- version: 8.0

## Description

SMA表示は6本
SMA5とSMA20の間に色がつきます。
そして交差のシグナルが表示されます。
また、パーフェクトオーダーでバックグラウンドに色がつきます。

## Source Code

````pine
//@version=6
indicator("SMA Perfect Order & Pullback", overlay=true)

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

// ===== 5SMAと20SMAの間を塗る =====
fill(
     p5,
     p20,
     color =
         sma5 > sma20 ? color.new(color.green, 85) :
         sma5 < sma20 ? color.new(color.red, 85) :
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
     size=size.small
)

plotshape(
     sellSignal,
     style=shape.triangledown,
     location=location.abovebar,
     color=color.rgb(244, 123, 123),
     size=size.small
)

// ===== どちらかのクロスでアラート =====
crossSignal = buySignal or sellSignal

alertcondition(
     crossSignal,
     title="5SMA and 20SMA Cross",
     message="5SMA and 20SMA have crossed."
)
````
