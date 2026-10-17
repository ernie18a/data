# TriexDev - SuperBuySellTrend

- url: https://www.tradingview.com/script/lz0rpQtQ-TriexDev-SuperBuySellTrend/
- type: indicator
- pine_id: PUB;d765c6b1c91f41d686d2abef6e06fe59
- version: 2.0

## Description

Minimal but powerful.

Have been using this for myself, so thought it would be nice to share publicly. Of course no script is correct 100% of the time, but this is one of if not the best in my basic tools.

Two indicators will appear, the default ATR multipliers are already set for what I believe to be perfect for this particular (double indicator) strategy. 
If you want to break it yourself (I couldn't find anything that tested more accurately myself), you can do so in the settings.

Basic rundown:
[list]
[*]A single Buy/Sell indicator in the dim colour; may be setting a direction change, or just healthy movement.
[*]When the brighter Buy/Sell indicator appears; it often means that a change in direction (uptrend or downtrend) is confirmed.
[/list]

[image]https://www.tradingview.com/x/z2B45Iaf/[/image]
You can see here, there was a (brighter) green indicator which flipped down then up into a (brighter) red sell indicator which set the downtrend. Once you understand the basics of how it works - it can become a very useful tool in your trading arsenal.

Typically I will use this and other indicators to confirm likeliness of a direction change prior to the brighter/confirmation one appearing - but just going by the 2nd(brighter) indicators, have found it to be surprisingly accurate.

Tends to work well on virtually all timeframes, but personally prefer to use it on 5min,15min,1hr, 4hr, daily, weekly. Will still work for shorter/other timeframes, but may be more accurate on mid ones.

## Source Code

````pine
//@version=5
indicator('TriexDev - SuperBuySellTrend', overlay=true, format=format.price, precision=2, timeframe='')
Periods = input(title='ATR Period', defval=10)
src = input(hl2, title='Source')
Multiplier1 = input.float(title='ATR Multiplier 1', step=0.1, defval=0.8)
Multiplier2 = input.float(title='ATR Multiplier 2', step=0.1, defval=1.6)
changeATR = input(title='Change ATR Calculation Method ?', defval=true)
showsignals = input(title='Show Buy/Sell Signals ?', defval=true)
highlighting = input(title='Highlighter On/Off ?', defval=true)
atr2 = ta.sma(ta.tr, Periods)
atr = changeATR ? ta.atr(Periods) : atr2
up = src - Multiplier1 * atr
up1 = nz(up[1], up)
up := close[1] > up1 ? math.max(up, up1) : up
dn = src + Multiplier1 * atr
dn1 = nz(dn[1], dn)
dn := close[1] < dn1 ? math.min(dn, dn1) : dn
trend = 1
trend := nz(trend[1], trend)
trend := trend == -1 and close > dn1 ? 1 : trend == 1 and close < up1 ? -1 : trend
upPlot = plot(trend == 1 ? up : na, title='Up Trend', style=plot.style_linebr, linewidth=2, color=color.new(color.green, 0))
buySignal = trend == 1 and trend[1] == -1
plotshape(buySignal ? up : na, title='UpTrend Begins', location=location.absolute, style=shape.circle, size=size.tiny, color=color.new(color.green, 0))
plotshape(buySignal and showsignals ? up : na, title='Buy', text='Buy', location=location.absolute, style=shape.labelup, size=size.tiny, color=color.new(color.green, 0), textcolor=color.new(color.white, 0))
dnPlot = plot(trend == 1 ? na : dn, title='Down Trend', style=plot.style_linebr, linewidth=2, color=color.new(color.red, 0))
sellSignal = trend == -1 and trend[1] == 1
plotshape(sellSignal ? dn : na, title='DownTrend Begins', location=location.absolute, style=shape.circle, size=size.tiny, color=color.new(color.red, 0))
plotshape(sellSignal and showsignals ? dn : na, title='Sell', text='Sell', location=location.absolute, style=shape.labeldown, size=size.tiny, color=color.new(color.red, 0), textcolor=color.new(color.white, 0))
mPlot = plot(ohlc4, title='', style=plot.style_circles, linewidth=0)
longFillColor = highlighting ? trend == 1 ? color.green : color.white : color.white
shortFillColor = highlighting ? trend == -1 ? color.red : color.white : color.white
fill(mPlot, upPlot, title='UpTrend Highlighter', color=longFillColor, transp=90)
fill(mPlot, dnPlot, title='DownTrend Highlighter', color=shortFillColor, transp=90)
alertcondition(buySignal, title='SBST Buy', message='SBST Buy!')
alertcondition(sellSignal, title='SBST Sell', message='SBST Sell!')
changeCond = trend != trend[1]
alertcondition(changeCond, title='SBST Direction Change', message='SBST has changed direction!')
upx = src - Multiplier2 * atr
upx1 = nz(upx[1], upx)
upx := close[1] > upx1 ? math.max(upx, upx1) : upx
dnx = src + Multiplier2 * atr
dnx1 = nz(dnx[1], dnx)
dnx := close[1] < dnx1 ? math.min(dnx, dnx1) : dnx
trendx = 1
trendx := nz(trendx[1], trendx)
trendx := trendx == -1 and close > dnx1 ? 1 : trendx == 1 and close < upx1 ? -1 : trendx
upxPlot = plot(trendx == 1 ? upx : na, title='Up Trend', style=plot.style_linebr, linewidth=2, color=color.rgb(0, 255, 0))
buySignalx = trendx == 1 and trendx[1] == -1
plotshape(buySignalx ? upx : na, title='UpTrend Confirmed', location=location.absolute, style=shape.circle, size=size.tiny, color=color.rgb(0, 255, 0), transp=0)
plotshape(buySignalx and showsignals ? upx : na, title='Buy', text='Buy', location=location.absolute, style=shape.labelup, size=size.tiny, color=color.rgb(0, 255, 0), textcolor=color.new(color.black, 0), transp=0)
dnxPlot = plot(trendx == 1 ? na : dnx, title='Down Trend', style=plot.style_linebr, linewidth=2, color=color.rgb(255, 0, 0))
sellSignalx = trendx == -1 and trendx[1] == 1
plotshape(sellSignalx ? dnx : na, title='DownTrend Confirmed', location=location.absolute, style=shape.circle, size=size.tiny, color=color.rgb(255, 0, 0), transp=0)
plotshape(sellSignalx and showsignals ? dnx : na, title='Sell', text='Sell', location=location.absolute, style=shape.labeldown, size=size.tiny, color=color.rgb(255, 0, 0), textcolor=color.new(color.white, 0), transp=0)
mxPlot = plot(ohlc4, title='', style=plot.style_circles, linewidth=0)
longFillColorx = highlighting ? trendx == 1 ? color.green : color.white : color.white
shortFillColorx = highlighting ? trendx == -1 ? color.red : color.white : color.white
fill(mxPlot, upxPlot, title='UpTrend Highlighter', color=longFillColorx, transp=90)
fill(mxPlot, dnxPlot, title='DownTrend Highlighter', color=shortFillColorx, transp=90)
alertcondition(buySignalx, title='SBST Buy Confirm', message='SBST Buy Direction Confirmed!')
alertcondition(sellSignalx, title='SBST Sell Confirm', message='SBST Sell Direction Confirmed!')
changeCondx = trendx != trendx[1]
alertcondition(changeCondx, title='SBST Direction Confirmation', message='SBST has confirmed direction!')
````
