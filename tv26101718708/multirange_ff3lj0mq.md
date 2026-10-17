# Multirange

- url: https://www.tradingview.com/script/FF3lJ0Mq-Multirange/
- type: indicator
- pine_id: PUB;1ae76ecec73146f5a342ec25688b6e6f
- version: 1.0

## Description

Script works well with large cap cryptos and some commodities. 

In a bullish scenario (green channel), use the bottom band and the medium for support

In a bearish scenario (red channel), use the top ban and median as resistance.

I recommend studying the BTC 4-year cycle and navigate it with this script. A bullish prompt in a bear market may result in unfavorable price action, not because the indicator is wrong, but macroeconomic action will typically outweight the script in the long term. 

I recently took my old one down and reduced some features, will update it in a near feature.

## Source Code

````pine
//@version=6
indicator("Multirange", overlay=true)

len=input.int(38,"multis ")
mult=input.float(1.0,"Swing")
atrLen=input.int(35,"ATR")
conf=input.int(2,"Confirm Bars", minval=1, maxval=3)

lag=math.max(int(math.floor((len-1)/2)),0)
zl=ta.ema(lag>0?close+(close-close[lag]):close,len)
atr=ta.atr(atrLen)
up=zl+atr*mult
dn=zl-atr*mult

// Swing confirmation
bull = close>up and close[1]>up[1] and close[conf-1]>up[conf-1] and zl>zl[1]
bear = close<dn and close[1]<dn[1] and close[conf-1]<dn[conf-1] and zl<zl[1]

var int tr=0
tr := bull?1: bear?-1: nz(tr[1],0)
flip = barstate.isconfirmed and tr!=tr[1] and tr!=0

pU=plot(up,color=color.blue,linewidth=2)
pD=plot(dn,color=color.blue,linewidth=2)
plot(zl,linewidth=4,color=tr==1?color.lime:tr==-1?color.red:color.gray)
fill(pU,pD,color=tr==1?color.new(color.lime,55):tr==-1?color.new(color.red,55):na)
````
