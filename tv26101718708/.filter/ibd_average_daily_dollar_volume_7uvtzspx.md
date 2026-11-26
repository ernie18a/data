# IBD Average Daily Dollar Volume

- url: https://www.tradingview.com/script/7UvtZSPx-IBD-Average-Daily-Dollar-Volume/
- type: indicator
- pine_id: PUB;3d39d9a133644bda918353d848ae6830
- version: 2.0

## Description

This is average dollar volume must be use for liquidity.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gagandeep98aug
//@version=6
//@version=6
indicator("IBD Dollar Volume + Average", shorttitle="IBD $Vol", overlay=false, format=format.volume)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
avgLength = input.int(50, "IBD Average Volume Period", minval=1)

showLevels = input.bool(true, "Show Liquidity Levels")

show30M  = input.bool(true, "$30M Level")
show50M  = input.bool(true, "$50M Level")
show100M = input.bool(true, "$100M Level")
show500M = input.bool(true, "$500M Level")
show1B   = input.bool(true, "$1B Level")

// ─────────────────────────────────────────────
// DAILY DOLLAR VOLUME
// ─────────────────────────────────────────────
dollarVolume = close * volume

// ─────────────────────────────────────────────
// IBD-STYLE AVERAGE DAILY DOLLAR VOLUME
// Current price × average daily share volume
// ─────────────────────────────────────────────
averageVolume = ta.sma(volume, avgLength)
ibdAverageDollarVolume = close * averageVolume

// ─────────────────────────────────────────────
// DAILY DOLLAR VOLUME BARS
// ─────────────────────────────────────────────
barColor = close >= close[1] ? color.new(color.green, 15) : color.new(color.red, 15)

plot(
     dollarVolume,
     title="Daily Dollar Volume",
     style=plot.style_columns,
     color=barColor
     )

// ─────────────────────────────────────────────
// IBD AVERAGE LINE
// ─────────────────────────────────────────────
plot(
     ibdAverageDollarVolume,
     title="IBD Average Daily Dollar Volume",
     color=color.orange,
     linewidth=2
     )

// ─────────────────────────────────────────────
// LIQUIDITY LEVELS
// ─────────────────────────────────────────────
plot(showLevels and show30M  ? 30e6  : na, "$30M",  color=color.new(color.gray, 50))
plot(showLevels and show50M  ? 50e6  : na, "$50M",  color=color.new(color.yellow, 50))
plot(showLevels and show100M ? 100e6 : na, "$100M", color=color.new(color.green, 50))
plot(showLevels and show500M ? 500e6 : na, "$500M", color=color.new(color.blue, 50))
plot(showLevels and show1B   ? 1e9   : na, "$1B",   color=color.new(color.purple, 50))
````
