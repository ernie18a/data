# % From Daily SMA 200

- url: https://www.tradingview.com/script/TcJBRnxd-From-Daily-SMA-200/
- type: indicator
- pine_id: PUB;3110e7e2700c4fbdb22667c1abecb95d
- version: 1.0

## Description

Percentages from Daily SMA 200, i tend to use it on stocks screener. found out 5 - 25% from SMA 200 should be a sweet spot for entry and bullish trend continuation.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZulSyirah

//@version=6
indicator("% From Daily SMA 200", overlay=false)

// Get Daily Close
dailyClose = request.security(syminfo.tickerid, "D", close)

// Daily SMA 200
dailySMA200 = request.security(syminfo.tickerid, "D", ta.sma(close, 200))

// Percentage difference
percentFromSMA = ((dailyClose - dailySMA200) / dailySMA200) * 100

// Plot
plot(percentFromSMA, title="% From SMA 200", linewidth=2)

// Zero reference line
hline(0, "SMA 200", linestyle=hline.style_dashed)

// Optional coloring
bgcolor(
     percentFromSMA > 0
     ? color.new(color.green, 90)
     : color.new(color.red, 90)
)
````
