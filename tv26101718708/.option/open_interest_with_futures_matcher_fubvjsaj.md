# Open Interest with futures matcher

- url: https://www.tradingview.com/script/fuBvjSaj-open-interest-with-futures-matcher/
- type: indicator
- pine_id: PUB;dbbf9c521a8d46099081d3a582c86431
- version: 1.0

## Description

If you open a spot contract, this script will try to find your futures contract (with the suffix ".P") on the same exchange (since the spot contract cannot calculate OI and the standard indicator gives an error).

## Source Code

````pine
//@version=6
indicator('Open Interest with futures matcher', 'OI matcher', format = format.volume, dynamic_requests = true)

//log.info(syminfo.tickerid)
var tickerOI = ""
if str.endswith(syminfo.tickerid, ".P") == false
    tickerOI := str.format('{0}.P_OI', ticker.standard(syminfo.tickerid))
else
    tickerOI := str.format('{0}_OI', ticker.standard(syminfo.tickerid))

[oiOpen, oiHigh, oiLow, oiClose, oiColorCond] = if timeframe.isintraday
    request.security(tickerOI, timeframe.period, [open, high, low, close, close > close[1]], ignore_invalid_symbol = true)
else
    [na, na, na, na, false]
[oiCloseD, oiColorCondD] = request.security(tickerOI, "1D", [close, close > close[1]], ignore_invalid_symbol = true)
if barstate.islastconfirmedhistory and na(oiClose) and na(oiCloseD)
    runtime.error(str.format('No Open Interest data found for the `{0}` symbol.', syminfo.prefix + ':' + syminfo.ticker))
var hasIntraday = false
if not na(oiClose)
    hasIntraday := true
plot(hasIntraday ? na : oiCloseD, 'Open Interest', oiColorCondD ? color.teal : color.red, style = plot.style_stepline, linewidth = 4)
openInterestColor = oiColorCond ? color.teal : color.red
plotcandle(oiOpen, oiHigh, oiLow, oiClose, 'Open Interest', color = openInterestColor, wickcolor = openInterestColor, bordercolor = openInterestColor)
````
