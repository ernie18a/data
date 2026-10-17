# ATR20 SMA x3.5 Trailing Line

- url: https://www.tradingview.com/script/41aUv3gh/
- type: indicator
- pine_id: PUB;3ddb0bc6c3044ff7b13ad3a6649edd79
- version: 1.0

## Description

I backtested high-momentum stocks and turned the stop-loss line that performed well into an indicator.
急騰銘柄を対象にバックテストを行い、ストップロスとして成績の良かったラインをインジケーター化しました。

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © hibinomasakazu1991
//@version=6
indicator("ATR20 SMA x3.5 Trailing Line", overlay = true)

atrLen = input.int(20, "ATR Length", minval = 1)
atrMult = input.float(3.5, "ATR Multiplier", minval = 0.1, step = 0.1)
lookbackHighLen = input.int(20, "High Lookback", minval = 1)

// True Range
prevClose = close[1]
tr = math.max(
     high - low,
     math.max(math.abs(high - prevClose), math.abs(low - prevClose))
)

// ATR using SMA
atrSma = ta.sma(tr, atrLen)

// Line: recent high - ATR x multiplier
atrExitLine = ta.highest(high, lookbackHighLen) - atrMult * atrSma

plot(
     atrExitLine,
     title = "ATR20 SMA x3.5 Line",
     color = color.red,
     linewidth = 2
)
````
