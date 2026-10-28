# VWAP Signals 

- url: https://www.tradingview.com/script/prggjc1p-VWAP-Signals/
- type: indicator
- pine_id: PUB;c93a52b8e9d442fc98ea84f57211caad
- version: 2.0

## Description

[b]VWAP (Volume Weighted Average Price)[/b]

This script plots the VWAP (Volume Weighted Average Price), a widely used indicator that combines price and volume to show the average price traded throughout the current session.

[b]How it works[/b]

- VWAP is calculated using both price and volume, giving more weight to prices where higher trading volume occurred.
- The calculation resets at the beginning of each new trading session.
- It serves as a dynamic benchmark for identifying the market's fair value during the day.

[b][b]How traders use VWA[/b]P[/b]

- Price above VWAP: Indicates bullish strength and buying pressure.
- Price below VWAP: Indicates bearish strength and selling pressure.
- VWAP as Support/Resistance: Price often reacts around VWAP, making it a useful dynamic support or resistance level.
- Trend Confirmation: Traders often look for long opportunities above VWAP and short opportunities below VWAP.

[b]Best for[/b]

- Intraday trading
- Scalping
- Day trading
- Trend confirmation
- Support and resistance analysis

[b]Note: VWAP is most effective on intraday timeframes because it resets at the start of each trading session. It should be used alongside price action and proper risk management rather than as a standalone trading signal.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("VWAP Signals ", overlay=true)

vwap = ta.vwap(close)

buySignal = ta.crossover(close, vwap)
sellSignal = ta.crossunder(close, vwap)

plot(vwap, title="VWAP", color=color.orange, linewidth=2)

plotshape(buySignal, title="Buy", location=location.belowbar,
     style=shape.triangleup, color=color.green, size=size.small)

plotshape(sellSignal, title="Sell", location=location.abovebar,
     style=shape.triangledown, color=color.red, size=size.small)
````
