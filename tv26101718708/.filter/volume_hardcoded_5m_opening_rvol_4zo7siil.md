# Volume + Hardcoded 5m Opening RVOL

- url: https://www.tradingview.com/script/4zO7siiL-Volume-Hardcoded-5m-Opening-RVOL/
- type: indicator
- pine_id: PUB;4d61943f43bd4c028b58cb989af84905
- version: 1.0

## Description

sScript that helps ya lose money. shfbdshdbfsjhdbfjshdbfjhsbdfsfsdhfbsjhdfjs I have to put text here

## Source Code

````pine
//@version=5
indicator("Volume + Hardcoded 5m Opening RVOL", overlay=false, format=format.volume)

lookback = 14

opening5mVol = request.security(syminfo.tickerid, "5", hour == 9 and minute == 30 ? volume : na, gaps=barmerge.gaps_on)

newOpeningBar = not na(opening5mVol) and na(opening5mVol[1])

var float[] openingVols = array.new_float()
var float openingAvg = na
var float openingRVOL = na

if newOpeningBar
    openingAvg := array.size(openingVols) >= lookback ? array.avg(array.slice(openingVols, array.size(openingVols) - lookback, array.size(openingVols))) : na
    openingRVOL := not na(openingAvg) ? (opening5mVol / openingAvg) * 100 : na
    array.push(openingVols, opening5mVol)

volColor = close >= close[1] ? color.green : color.red

plot(volume, style=plot.style_columns, color=volColor, title="Volume")
plot(openingAvg, color=color.orange, linewidth=2, title="14D Avg Opening 5m Volume")

if newOpeningBar and not na(openingRVOL)
    label.new(bar_index, volume, str.tostring(openingRVOL, "#.0") + "%", style=label.style_label_down, color=color.black, textcolor=color.white)
````
