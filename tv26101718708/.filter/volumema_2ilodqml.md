# VolumeMA

- url: https://www.tradingview.com/script/2ilOdQMl/
- type: indicator
- pine_id: PUB;b128c345be904f2a80602bc79385aa6b
- version: 1.0

## Description

VolumeMA

VolumeMA is a volume-based indicator designed to visualize market participation by combining trading volume with price direction.

Unlike traditional volume indicators that display only raw volume, VolumeMA assigns positive volume to rising price bars and negative volume to falling price bars. This helps traders identify whether buying or selling pressure is dominating the market.

The indicator smooths these values using a moving average, reducing short-term noise and making underlying market participation easier to observe.

 Features

 Directional Volume

Volume is assigned based on price movement:

* Rising price bar → Positive volume
* Falling price bar → Negative volume

This allows traders to quickly identify whether buyers or sellers are currently in control.

 Volume Moving Average

The directional volume is smoothed using a Simple Moving Average (SMA), creating the Volume Moving Average histogram.

This helps highlight trends in market participation rather than focusing on individual volume spikes.

 SMA Signal Line

An additional SMA is applied to the Volume Moving Average.

When the Volume Moving Average is above its SMA, market participation is considered relatively strong.

When it is below its SMA, market participation is considered relatively weak.

 Zero Line

The zero line separates bullish and bearish volume pressure:

* Above zero → Buying pressure dominates
* Below zero → Selling pressure dominates

 Color Visualization

Histogram colors automatically change depending on whether the Volume Moving Average is above or below its SMA, making shifts in momentum easier to identify.

 Usage

VolumeMA is designed as a complementary tool for market analysis. It can be used alongside price action, trend analysis, and other indicators to better understand market participation and momentum.

As with any indicator, it should not be used in isolation and does not guarantee future performance.

## Source Code

````pine
//@version=6
indicator("VolumeMA", shorttitle="VolumeMA", overlay=false)

// === inputs
baseline = input.bool(true, title="Baseline Chart")
len = input.int(14, minval=1, title="Moving Average Length")
smaLenVolume = input.int(14, minval=1, title="SMA Length for Volume Moving Average")

// === 色設定
barColorAbove = input.color(color.rgb(121, 213, 171), "Volume MA Color Above SMA")
barColorBelow = input.color(color.rgb(56, 157, 151), "Volume MA Color Below SMA")
smaColor      = input.color(color.lime, "SMA Color")

// === 方向判定
// 上昇バーなら +Volume、下降バーなら -Volume
direction = math.sign(close - close[1])

// ベースライン有効時は0ラインを基準に上下表示
bpv = (baseline ? direction : 1) * volume

// === 単純14期間平均
maSV = ta.sma(bpv, len)

// === SMA of Volume Moving Average
smaVolumeMA = ta.sma(maSV, smaLenVolume)

// === 色分岐
colorVolumeMA = maSV > smaVolumeMA ? barColorAbove : barColorBelow

// === プロット
plot(maSV,
     title="Volume Moving Average",
     style=plot.style_columns,
     color=colorVolumeMA,
     linewidth=1)

plot(smaVolumeMA,
     title="SMA of Volume Moving Average",
     style=plot.style_line,
     color=smaColor,
     linewidth=1)

// === ゼロライン
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
````
