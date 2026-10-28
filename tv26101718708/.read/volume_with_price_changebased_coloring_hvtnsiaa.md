# Volume with Price Change-based Coloring

- url: https://www.tradingview.com/script/hvtnSIAa-Volume-with-Price-Change-based-Coloring/
- type: indicator
- pine_id: PUB;d6c688da2a4c4e24b78fcde9fe680c9c
- version: 1.0

## Description

This script presents volume as Gray bars unless there is a significant price gain or drop on that bar. This avoids the problem where there might be high volume within a time bar, but the price surges up or down and then returns near where it started. With conventional volume plots this would show as a large Red or Green bar, but the ultimate price move is somewhat arbitrary since the bar close is near the open. The script also includes a configurable moving average line and standard deviation line for visual reference.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheSoapTrade

//@version=6
// This script presents volume as Gray bars unless there is a significant price gain or drop on that bar. 
// This avoids the problem where there might be high volume within a time bar, but the price surges up or down and then returns near where it started. 
// The script also includes a configurable moving average line and standard deviation line for visual reference. 
indicator('Volume with Price Change-based Coloring', overlay = false)

ma_length = input.int(20, 'Volume MA Length')
hist_length = input.int(200, 'Fixed SD Calculation Length')
sd_threshold = input.float(1.0, 'Volume SD Threshold')
price_sd_threshold = input.float(1.0, 'Price Change SD Threshold')

normal_color = input.color(color.gray, 'Normal Volume Color')
up_color = input.color(color.green, 'Up Price Color')
down_color = input.color(color.red, 'Down Price Color')

ma = ta.sma(volume, ma_length)
fixed_sd = ta.stdev(volume, hist_length)

price_change = close - close[1]
price_change_sd = ta.stdev(price_change, hist_length)

volColor = price_change > price_sd_threshold * price_change_sd ? up_color : price_change < -price_sd_threshold * price_change_sd ? down_color : normal_color

plot(volume, style = plot.style_columns, color = volColor, title = 'Volume')
plot(ma, color = color.black, linewidth = 2, title = 'Volume SMA')
plot(ma + sd_threshold * fixed_sd, color = color.black, title = 'Upper Volume SD Threshold')
````
