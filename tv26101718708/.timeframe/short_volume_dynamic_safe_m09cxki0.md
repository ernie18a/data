# Short Volume Dynamic (Safe)

- url: https://www.tradingview.com/script/m09cxkI0-Short-Volume-Dynamic-Safe/
- type: indicator
- pine_id: PUB;90e8ff18823a4994b9638026798ffac9
- version: 1.0

## Description

Plot the Daily short volume for any ticker. This is only for educational purposes

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trade007_75

//@version=5
indicator("Short Volume Dynamic (Safe)", overlay=false)

symbol = syminfo.tickerid
shortSymbol = "FINRA:" + syminfo.ticker + "_SHORT_VOLUME"

shortVol = request.security(shortSymbol, "D", close)
totalVol = volume

shortRatio = na(shortVol) ? na : shortVol / totalVol

plot(shortVol, title="Short Volume", color=color.red)
plot(shortRatio, title="Short Ratio", color=color.blue)

// Show warning if no data
var label lbl = na
if barstate.islast and na(shortVol)
    label.new(bar_index, high, "No short volume data available", color=color.red)
````
