# Kaufman Moving Average Adaptive Strategy by MKB

- url: https://www.tradingview.com/script/qgTc4zie-Kaufman-Moving-Average-Adaptive-Strategy-by-MKB/
- type: strategy
- pine_id: PUB;9931639625e5461db56e6e6748eb5127
- version: 2.0

## Description

KAMA Momentum Strategy is a trend-following momentum strategy based on the Kaufman Adaptive Moving Average.

The strategy is designed to capture strong upside momentum by entering only when price breaks above the KAMA plus a volatility-based standard deviation filter. This helps reduce weak signals and filters out some of the noise that often appears in sideways markets.

The exit condition remains simple and disciplined: the position is closed when price crosses back below the KAMA. This allows the strategy to follow momentum while still using the adaptive moving average as the main trend reference.

In my tests, the strategy works best on the daily timeframe. It is especially effective in cryptocurrency markets, where strong momentum phases and volatility expansions are common.

Key features:

Kaufman Adaptive Moving Average trend filter
Standard deviation-based entry confirmation
Momentum-focused long-only structure
Designed primarily for daily charts
Works well on crypto assets
Single-position logic with no pyramiding

Suggested starting settings:

KAMA Length: 21
Standard Deviation Length: 20
Standard Deviation Multiplier: 0.5

This strategy is intended for backtesting, research, and educational purposes. It should not be considered financial advice. Always test different assets and market conditions before using any strategy in live trading.

## Source Code

````pine
//@version=6
strategy(
     title="Kaufman Moving Average Adaptive Strategy by MKB",
     shorttitle="KAMA by MKB",
     overlay=true,
     initial_capital=1000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=85,
     pyramiding=0,
     commission_type=strategy.commission.percent,
     commission_value=0.1
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

length = input.int(21, "KAMA Length", minval=1)
src = input.source(close, "Source")

fastEnd = input.float(0.666, "Fast End", step=0.001)
slowEnd = input.float(0.0645, "Slow End", step=0.0001)

// Standart sapma filtresi sadece alım için
stdevLength = input.int(20, "Std Dev Length", minval=1)
stdevMultiplier = input.float(0.5, "Std Dev Multiplier", step=0.1)

// Grafik temizliği
showSignalLabels = input.bool(false, "Show AL/SAT Labels")
showStdBand = input.bool(true, "Show KAMA + Std Dev Band")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// KAMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

xvnoise = math.abs(src - src[1])

signal = math.abs(src - src[length])
noise = math.sum(xvnoise, length)

efRatio = noise != 0 ? signal / noise : 0.0

smooth = math.pow(
     efRatio * (fastEnd - slowEnd) + slowEnd,
     2
)

var float kama = 0.0
kama := nz(kama[1]) + smooth * (src - nz(kama[1]))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Standart Sapma Bandı
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

stdev = ta.stdev(src, stdevLength)
upperBand = kama + stdevMultiplier * stdev

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Strategy Rules
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// AL: fiyat KAMA + x standart sapma bandını yukarı kırarsa
buySignal = ta.crossover(src, upperBand)

// SAT: fiyat KAMA altına inerse
sellSignal = ta.crossunder(src, kama)

// Sadece gerçek işlem sinyalleri
realBuySignal = buySignal and strategy.position_size == 0
realSellSignal = sellSignal and strategy.position_size > 0

if realBuySignal
    strategy.entry("Long", strategy.long)

if realSellSignal
    strategy.close("Long")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plot
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(kama, color=color.blue, title="KAMA", linewidth=2)

plot(
     showStdBand ? upperBand : na,
     color=color.orange,
     title="KAMA + Std Dev",
     linewidth=1
)

plotshape(
     showSignalLabels and realBuySignal,
     title="AL",
     style=shape.triangleup,
     location=location.belowbar,
     size=size.small,
     text="AL",
     color=color.green,
     textcolor=color.white
)

plotshape(
     showSignalLabels and realSellSignal,
     title="SAT",
     style=shape.triangledown,
     location=location.abovebar,
     size=size.small,
     text="SAT",
     color=color.red,
     textcolor=color.white
)
````
