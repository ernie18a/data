# MFI Simple Strategy

- url: https://www.tradingview.com/script/AKXK9Jub-MFI-Simple-Strategy/
- type: strategy
- pine_id: PUB;7b4fb1e788334eb29d7914104b0d6508
- version: 1.0

## Description

Here I've made a simple strategy based off a simple moving average of an MFI length.
Back tested on a BYBIT:BTCUSDT 30m chart.

Conditions:
---When the price is above the golden SMA of 200 bars---
 - Buy: when MFI is moving up
 - Sell: when MFI is moving down
 - Stop: golden SMA of 200 bars


If you would like alerts:
 1.) Add the strategy to your chart,
 2.) Go to "Create Alert",
 3.) Select "MFI Simple Strategy" in your alert creator,
 4.) Select whatever notifications settings or message settings,
 5.) Finally, click "Create" and you're good to go.

[b]Disclaimer:[/b] Please do your own research before making any decisions financially. Past results do not guarantee future results.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © OztheWoz

//@version=5
strategy("MFI Simple Strategy", overlay=false)

len = input(18, "Length")
mfi = ta.sma(ta.mfi(close, len), len)
mfiup = (mfi[1] < mfi) and (mfi[2] < mfi[1])
mfidn = (mfi[1] > mfi) and (mfi[2] < mfi[1])
goldsma = ta.sma(close, 200)

if goldsma < close
    strategy.entry("Long", strategy.long, when=mfiup)
strategy.exit("Long", stop=goldsma)
strategy.close("Long", when=mfidn)

a = plot(mfi)
b = plot(80, color=color.gray)
c = plot(20, color=color.gray)
fillclr = color.new(color.blue, 70)

fill(a, b, color=(mfi > 80) ? fillclr : na)
// fill(a, c)
````
