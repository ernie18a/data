# Rainbow Structure Cycle (RSC)

- url: https://www.tradingview.com/script/lO0YzeZY-Rainbow-Structure-Cycle-RSC/
- type: indicator
- pine_id: PUB;a353cddcedfa42e3adc78096575ea7c5
- version: 1.0

## Description

# RSC Ribbon

RSC Ribbon is a multi-layer Simple Moving Average (SMA) ribbon designed to help traders evaluate the **length**, **maturity**, and **overall condition** of a trend.

Unlike traditional moving average systems that rely on crossover signals, RSC Ribbon is **not designed to generate buy or sell signals**. Its primary purpose is to provide a clear visual representation of how a trend evolves over time.

The ribbon consists of seven adaptive Simple Moving Averages whose lengths automatically adjust according to the selected chart timeframe. This approach offers a broader perspective of trend development while keeping the chart clean and easy to read.

## Features

* Seven adaptive Simple Moving Averages (SMA)
* Automatic MA lengths based on the current timeframe
* Color-filled ribbon for quick visual analysis
* Helps evaluate trend length and maturity
* Identifies trend expansion and contraction
* Suitable for multi-timeframe trend observation

## How to Interpret the Ribbon

* **Wide ribbon:** Indicates a well-established and mature trend.
* **Compressed ribbon:** Suggests a weakening trend or a consolidation phase.
* **Expanding ribbon:** Shows increasing trend strength and directional commitment.
* **Contracting ribbon:** Indicates decreasing momentum and possible market transition.
* **Price above the ribbon:** Bullish market environment.
* **Price below the ribbon:** Bearish market environment.

## Timeframe Logic

The moving average lengths are automatically optimized for each supported timeframe. Instead of relying on a single moving average, RSC Ribbon combines multiple layers to provide a broader view of trend progression and market alignment.

## Disclaimer

RSC Ribbon is a trend analysis tool, not a signal generator. It is intended to provide market context and can be used alongside any trading methodology or price action approach.

## Source Code

````pine
//@version=6
indicator("Rainbow Structure Cycle (RSC)", overlay=true)

// ─── Inputs ───
vol_ma_length = input.int(title="Volume MA Length", defval=20)

zcolup = input.color(title="Zone Up Color", defval=color.new(color.lime, 80))
zcoldn = input.color(title="Zone Down Color", defval=color.new(color.red, 80))

// ─── MA lengths per timeframe ───
get_ma_lengths() =>
    tf = timeframe.period

    if tf == "12M"
        [50, 100, float(na), float(na), float(na), float(na), float(na)]
    else if tf == "6M"
        [50, 100, float(na), float(na), float(na), float(na), float(na)]
    else if tf == "3M"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "1M"
        [50, 100, 150, 200, 250, 300, float(na)]
    else if tf == "2W"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "1W"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "3D"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "1D"
        [50, 100, 150, 200, 250, 300, 350]
    else if tf == "720"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "480"
        [50, 100, 150, float(na), float(na), float(na), float(na)]
    else if tf == "240"
        [50, 100, 150, 200, 250, 300, float(na)]
    else if tf == "120"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "60"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "30"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "15"
        [50, 100, 150, 200, float(na), float(na), float(na)]
    else if tf == "5"
        [50, 100, 150, 200, 250, 300, float(na)]
    else if tf == "1"
        [50, 100, 150, 200, 250, 300, 400]
    else
        [50, 100, 150, 200, 250, 300, 400]

// ─── Get lengths ───
[m1, m2, m3, m4, m5, m6, m7] = get_ma_lengths()

// ─── Safe MA calc ───
ma1 = na(m1) ? na : ta.sma(close, int(m1))
ma2 = na(m2) ? na : ta.sma(close, int(m2))
ma3 = na(m3) ? na : ta.sma(close, int(m3))
ma4 = na(m4) ? na : ta.sma(close, int(m4))
ma5 = na(m5) ? na : ta.sma(close, int(m5))
ma6 = na(m6) ? na : ta.sma(close, int(m6))
ma7 = na(m7) ? na : ta.sma(close, int(m7))

// ─── Plot ───
p1 = plot(ma1, color=color.green, linewidth=1)
p2 = plot(ma2, color=color.blue, linewidth=1)
p3 = plot(ma3, color=color.red, linewidth=1)
p4 = plot(ma4, color=color.orange, linewidth=1)
p5 = plot(ma5, color=color.purple, linewidth=1)
p6 = plot(ma6, color=color.yellow, linewidth=1)
p7 = plot(ma7, color=color.white, linewidth=1)

// ─── Fill zones (pairwise) ───
fill(p1, p2, color = ma1 > ma2 ? zcolup : zcoldn)
fill(p2, p3, color = ma2 > ma3 ? zcolup : zcoldn)
fill(p3, p4, color = ma3 > ma4 ? zcolup : zcoldn)
fill(p4, p5, color = ma4 > ma5 ? zcolup : zcoldn)
fill(p5, p6, color = ma5 > ma6 ? zcolup : zcoldn)
fill(p6, p7, color = ma6 > ma7 ? zcolup : zcoldn)
````
