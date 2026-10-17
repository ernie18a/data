# Bollinger Candles

- url: https://www.tradingview.com/script/EvqqVnJi/
- type: indicator
- pine_id: PUB;e5e7f7acc48445e1aacfbcb53f14e98b
- version: 3.0

## Description

It consists of Bollinger Bands converted into candlesticks. You can also calculate the middle band using different moving averages. Additionally, you can add the Bollinger Bands to the calculated candlesticks.

## Source Code

````pine
//@version=6
// @author CyberFalcon
//
indicator('Bollinger Candles', overlay = false, shorttitle = 'BollCandle')

getMA(src, length, MA_Type) =>
    switch MA_Type
        'SMA' => ta.sma(src, length)
        'WMA' => ta.wma(src, length)
        'LSMA' => 
    	    ma1 = ta.sma(src, length)
    	    ma2 = ta.wma(src, length)
    	    ma = 3 * ma2 - 2 * ma1
    	    ma
        'EMA' => ta.ema(src, length)
        'ZEMA' => 
    	    ma1 = ta.ema(src, length)
    	    ma2 = ta.ema(ma1, length)
    	    ma = 2 * ma1 - ma2
    	    ma
        'TMA' => ta.sma(ta.sma(src, math.ceil(length / 2)), math.floor(length / 2) + 1)
        'VAR' => 
    	    ma = 0.0
    	    vDD = math.sum(math.abs(src - src[1]), 9)
    	    vCMO = nz(math.abs(src - src[9])) / vDD * 2 / (length + 1)
    	    ma := nz(vCMO * src) + (1 - vCMO) * nz(ma[1])
    	    ma
        'WWMA' => 
    	    ma = 0.0
    	    wwalpha = 1 / length
    	    ma := wwalpha * src + (1 - wwalpha) * nz(ma[1])
    	    ma
        'ZLEMA' => 
    	    zxLag = math.floor(length / 2)
    	    zxEMAData = src + src - src[zxLag]
    	    ma = ta.ema(zxEMAData, length)
    	    ma
        'TSF' => 2 * ta.linreg(src, length, 0) - ta.linreg(src, length, 1)
        'KAMA' => 
    	    ma = 0.0
    	    xvnoise = math.abs(src - src[1])
    	    nfastend = 0.6015
    	    nslowend = 0.0645
    	    nsignal = math.abs(src - src[length]) / math.sum(xvnoise, length)
    	    nefratio = nsignal * nfastend + nslowend
    	    nsmooth = nefratio * nefratio
    	    ma := nz(ma[1]) + nsmooth * (src - nz(ma[1]))
    	    ma
        => na

getMAExt(lastSrc, newLastSrc, length, ma_, MA_Type) =>
    switch MA_Type
        'SMA' => ma_ + (newLastSrc - lastSrc) / length
        'WMA' => ma_ + (newLastSrc - lastSrc) * 2 / (length + 1)
        'LSMA' => ma_ + (newLastSrc - lastSrc) * (6 / (length + 1) - 2 / length)
        'EMA' => ma_ + (newLastSrc - lastSrc) * 2 / (length + 1)
        'ZEMA' => ma_ + (newLastSrc - lastSrc) * 4 / (length + 1) / (length + 1)
        'TMA' => ma_ + (newLastSrc - lastSrc) / math.ceil(length / 2) / (math.floor(length / 2) + 1)
		=> na


StDev(priceSD, MA_SD, lengthSD, coeff, special, last) =>
    sum = (last - MA_SD) * (last - MA_SD)
    for i = 1 to lengthSD - 1 by 1
        sum := sum + (priceSD[i] - MA_SD[special ? i : 0]) * (priceSD[i] - MA_SD[special ? i : 0])
        sum
    coeff * math.sqrt(sum / lengthSD)


Price = input(close, inline = 'Head')
SDSpecial = input(false, 'Candle Spec St Dev', inline = 'Head')
SDSpecialMA = input(false, 'MA Spec St Dev', inline = 'Head')

var GRP = 'MA by Compute Candle'
showCandle = input(true, '', inline = 'Candle MA', group = GRP)
MA1Type = input.string(defval = 'EMA', title = 'Candle MA', inline = 'Candle MA', group = GRP
 , options = ['SMA', 'WMA', 'LSMA', 'EMA', 'ZEMA', 'TMA'])
length = input(13, 'Per.', inline = 'Candle MA', group = GRP)
MA = getMA(Price, length, MA1Type)
MAh = getMAExt(Price, high, length, MA, MA1Type)
MAl = getMAExt(Price, low, length, MA, MA1Type)
MAo = getMAExt(Price, open, length, MA, MA1Type)
StDevMA1 = StDev(Price, MA, length, 1.0, SDSpecial, Price)
StDevMA1h = StDev(Price, MAh, length, 1.0, SDSpecial, high)
StDevMA1l = StDev(Price, MAl, length, 1.0, SDSpecial, low)
StDevMA1o = StDev(Price, MAo, length, 1.0, SDSpecial, open)
o = 100 * request.security(syminfo.tickerid, timeframe.period, (open - MAo) / StDevMA1o)
h = 100 * request.security(syminfo.tickerid, timeframe.period, (high - MAh) / StDevMA1h)
l = 100 * request.security(syminfo.tickerid, timeframe.period, (low - MAl) / StDevMA1l)
c = 100 * request.security(syminfo.tickerid, timeframe.period, (Price - MA) / StDevMA1)

var GRP1 = "Candle's Bollinger Bands"
showBollMA = input(true, '', inline = 'Boll MA', group = GRP1)
BollMAType = input.string(defval = 'EMA', title = 'Boll MA ', options = ['SMA', 'WMA', 'LSMA', 'EMA', 'ZEMA', 'TMA', 'VAR', 'WWMA', 'ZLEMA', 'TSF', 'KAMA'], inline = 'Boll MA', group = GRP1)
lengthBoll = input(13, 'Per.', inline = 'Boll MA', group = GRP1)
showMAB = input(true, 'Band', inline = 'Boll MA', group = GRP1)
showMABX = input(false, 'Extra', inline = 'Boll MA', group = GRP1)
BollMA = getMA(c, lengthBoll, BollMAType)
BollMAh = getMAExt(c, h, lengthBoll, BollMA, BollMAType)
BollMAl = getMAExt(c, l, lengthBoll, BollMA, BollMAType)
StDevBoll = StDev(c, BollMA, lengthBoll, 2.0, SDSpecialMA, c)
StDevBollh = StDev(c, BollMAh, lengthBoll, 2.0, SDSpecialMA, h)
StDevBolll = StDev(c, BollMAl, lengthBoll, 2.0, SDSpecialMA, l)
col = o > c ? color.red : #2c9a9a
plotcandle(showCandle ? o : na, h, l, c, 'BBCandle', color = col)
plot(showBollMA ? BollMA : na, color = color.new(#00FFFF, 0), linewidth = 2, title = 'Boll MA')
plot(showMAB ? BollMA + StDevBoll : na, color = color.new(#00FFFF, 0), linewidth = 1, title = 'Boll MA')
plot(showMAB ? BollMA - StDevBoll : na, color = color.new(#00FFFF, 0), linewidth = 1, title = 'Boll MA')
plot(showMABX ? BollMAh : na, color = bar_index % 2 == 1 ? color.new(#007F7F, 0) : color.new(#00FFFF, 0), linewidth = 1, title = 'Boll MA')
plot(showMABX ? BollMAl : na, color = bar_index % 2 == 1 ? color.new(#007F7F, 0) : color.new(#00FFFF, 0), linewidth = 1, title = 'Boll MA')
plot(showMABX ? BollMAh + StDevBollh : na, color = bar_index % 2 == 1 ? color.new(#007F7F, 0) : color.new(#00FFFF, 0), linewidth = 1, title = 'Boll MA')
plot(showMABX ? BollMAl - StDevBolll : na, color = bar_index % 2 == 1 ? color.new(#007F7F, 0) : color.new(#00FFFF, 0), linewidth = 1, title = 'Boll MA')

hline(0, linestyle = hline.style_solid)
hline(100)
hline(200)
hline(-100)
hline(-200)
````
