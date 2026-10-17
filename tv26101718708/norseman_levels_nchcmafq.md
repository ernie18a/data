# Norseman Levels

- url: https://www.tradingview.com/script/nCHcMafQ-Norseman-Levels/
- type: indicator
- pine_id: PUB;644b9dcb237f459689b00f473d26980a
- version: 1.0

## Description

10% off all time high to measure bullish structure and 21 EMA to measure bullish trend.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AaronHemeon



//@version=5
indicator("Norseman Levels", overlay=true)

// B/BL Line - 10% below ATH
ath = ta.highest(high, 252)
bbl = ath * 0.90
plot(bbl, "B/BL -10% from ATH", color=color.red, linewidth=2)

// 21-week EMA
ema21 = ta.ema(close, 21)
plot(ema21, "21-Week EMA", color=color.blue, linewidth=2)
````
