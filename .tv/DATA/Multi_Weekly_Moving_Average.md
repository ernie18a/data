<!-- tradingview-pine-id: PUB;5abd5cf080ae45808914cef37fb7a120 -->
<!-- tradingviewscripts-format: 1 -->
# Multi Weekly Moving Average

Source: https://www.tradingview.com/script/OFDcOYKy-Multi-Weekly-Moving-Average/

## Description

An indicator which show multiple weekly Moving Averages in one. 

Currently up to 3 weekly MAs are displayed at once.

---

## Source Code

````pine
//@version=6
indicator(title = 'Multi Weekly Moving Average', shorttitle = 'Multi Weekly MA', overlay = true)

len1 = input(200, 'MA Length 1')
src1 = input(close, 'Source 1')

ma1 = request.security(syminfo.tickerid, 'W', ta.sma(close, len1))
plot(ma1, color = color.new(color.red, 0), linewidth = 2)


len2 = input(200, 'MA Length 2')
src2 = input(close, 'Source 2')

ma2 = request.security(syminfo.tickerid, 'W', ta.sma(close, len2))
plot(ma2, color = color.new(color.red, 0), linewidth = 2)


len3 = input(200, 'MA Length 3')
src3 = input(close, 'Source 3')

ma3 = request.security(syminfo.tickerid, 'W', ta.sma(close, len3))
plot(ma3, color = color.new(color.red, 0), linewidth = 2)
````
