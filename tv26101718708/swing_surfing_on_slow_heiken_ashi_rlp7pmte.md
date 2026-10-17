# Swing Surfing on Slow Heiken Ashi

- url: https://www.tradingview.com/script/rlp7pMte-Swing-Surfing-on-Slow-Heiken-Ashi/
- type: indicator
- pine_id: PUB;159U6mwMmb5FoY5SL4Veaj977smbeqmz
- version: 1.0

## Description

Good for Crypto related markets.  Guaranteed to catch every big swing, just have to make sure you keep your positions updated. 3m chart.

## Source Code

````pine
//@version=2
study("Catching swings on SHA", overlay=true)

//SHA
p=input(6,title='Period')
fastend=input(0.666,step=0.001)
slowend=input(0.0645,step=0.0001)
kama(close,amaLength)=>
    diff=abs(close[0]-close[1])
    signal=abs(close-close[amaLength])
    noise=sum(diff, amaLength)
    efratio=noise!=0 ? signal/noise : 1
    smooth=pow(efratio*(fastend-slowend)+slowend,2)
    kama=nz(kama[1], close)+smooth*(close-nz(kama[1], close))
    kama
hakamaper=1
Om=sma(open,p)
Hm=sma(high,p)
Lm=sma(low,p)
Cm=sma(close,p)
vClose=(Om+Hm+Lm+Cm)/4
vOpen= kama(vClose[1],hakamaper)
vHigh= max(Hm,max(vClose, vOpen))
vLow=  min(Lm,min(vClose, vOpen))
asize=vOpen-vClose
size=abs(asize)
down=vClose>vOpen and size[1]>size 
up=vClose<vOpen and size[1]>size
halfcandle=(abs(1/2*size))+(vOpen>vClose ? vClose : vOpen)

src=close

long=crossover(src, halfcandle)
short=crossunder(src, halfcandle)

plotshape(long, style=shape.arrowup, color=blue, size=size.normal, location=location.belowbar)
plotshape(short, style=shape.arrowdown, color=red, size=size.normal, location=location.abovebar)

signal=long or short 
alertcondition(signal, title="SHA Signal", message="Check XBT")

//if long
//    strategy.entry("LONG", strategy.long)
//if short
//    strategy.entry("SHORT", strategy.short)
````
