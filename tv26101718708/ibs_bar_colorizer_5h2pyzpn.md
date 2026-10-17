# IBS Bar Colorizer

- url: https://www.tradingview.com/script/5h2pyzPn-IBS-Bar-Colorizer/
- type: indicator
- pine_id: PUB;0ec8e471ca174afdac3e3b5c53e00639
- version: 1.0

## Description

makes bars with >69 ibs green and bars with < 31 ibs red

## Source Code

````pine
//@version=5
indicator("IBS Bar Colorizer", overlay=true)

range_ = high - low
ibs = range_ > 0 ? (close - low) / range_ * 100 : 50

isBullBar = close > open
isBearBar = close < open

barcolor(isBullBar and ibs >= 69 ? color.green : isBearBar and ibs <= 31 ? color.red : na)
````
