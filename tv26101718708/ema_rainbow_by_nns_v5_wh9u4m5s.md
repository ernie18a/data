# EMA Rainbow by NNS V5

- url: https://www.tradingview.com/script/wh9U4m5S-EMA-Rainbow-by-NNS-V5/
- type: indicator
- pine_id: PUB;760a95743780446bb64deb1cee1b73e6
- version: 1.0

## Description

EMA Rainbow by NNS
update 21/4/2569

split with many ema to provide to momentum

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © New Normal Skill (Updated to v5)

//@version=5
indicator(title="EMA Rainbow by New Normal Skill", overlay=true)

// Calculating EMAs using the ta.ema() function
line1 = ta.ema(close, 5)
line2 = ta.ema(close, 15)
line3 = ta.ema(high, 35)
line32 = ta.ema(close, 35)
line33 = ta.ema(low, 35)
line4 = ta.ema(close, 89)
line5 = ta.ema(close, 100)
line6 = ta.ema(close, 144)
line7 = ta.ema(close, 169)
line8 = ta.ema(close, 200)

// Plotting the lines with updated color constants
plot(line1, "ema5", color = color.yellow)
plot(line2, "ema15", color = color.orange)
plot(line3, "ema35H", color = color.red)
plot(line32, "ema35C", color = color.red)
plot(line33, "ema35L", color = color.red)
plot(line4, "ema89", color = color.aqua)
plot(line5, "ema100", color = color.aqua)
plot(line6, "ema144", color = #2196f3)
plot(line7, "ema169", color = #2196f3)
plot(line8, "ema200", color = color.white)
````
