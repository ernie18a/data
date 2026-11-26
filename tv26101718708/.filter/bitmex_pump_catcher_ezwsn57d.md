# BitMEX pump catcher

- url: https://www.tradingview.com/script/EzWSn57d-BitMEX-pump-catcher/
- type: strategy
- pine_id: PUB;GAvGyoXjps4N0cp6IvFsELQQSqzTpFdJ
- version: 1.0

## Description

What is going on here? This strategy is pretty simple. We start by measuring a very long chunk of volume history on BitMEX:XBTUSD 1 hour chart to find out if the current volume is high or low. At 1.0 the indicator is showing we are at 100% of normal historical volume. The blue line is a measure of recent volume! This indicator gets interested when the volume drops below 90% of the regular volume (0.9), and then comes back up over 90%.  There's usually a pump of increased price activity during this time. When the 0.9 line is crossed by the blue line, the indicator surveys the last 2 bars of price action to figure out which way we're going, long or short. Green is long. Red is short. To exit the trade we use a 7 period fast ema of the volume crossing under an 11 ema slower period which shows declining interest in the market signifying an end to the pump or dump. The profit factor is quite high with 5x leverage, but historically we see 50% drawdown -- very risky. 1x leverage looks nice and tight with very low drawdown. Play with the inputs to see what matches your own risk profile. I would not recommend taking this into much lower timeframes as trading fees are not included in the profit calculations. Please don't get burned trading on stupid high leverage. This indicator is probably not going to work well on alts, as Bitcoin FOMO build up and behavior is different. This whole indicator is tuned to Bitcoin, and attempts to trade only the meatiest part of the market moves.

Weaknesses: it can sometimes pick to trade the wrong direction if if hits support or resistance and changes direction after a trade is entered. Use a stoploss.

Strengths: It usually gets things right. Historically over 57% right. 

Use at your own risk!

## Source Code

````pine
//@version=4
strategy("BitMEX pump catcher",precision=8,initial_capital=1000)
leverage=input(5,"leverage",step=.25)
threshold=input(.9,"threshold",step=.05)
fama=input(7,"fastema")
slma=input(11,"slowema")
dirtime=input(2,"direction picker # bars")
b=sum(volume,24)
c=0.0
for i = 24 to 1200 by +24
    c:=b[i]+c

d=c/50
e=b/d
plot(e)
spikemeter=0.0
spikemeter:=if e>threshold
    nz(spikemeter[1])+1
else
    nz(spikemeter[1])
    
spikecum=0.0    
spikecum:=if spikemeter>spikemeter[1]
    nz(spikecum[1])+e
else
    nz(spikecum[1])
    
spikeavg=spikecum/spikemeter

plot(spikeavg)

dir=if close/close[dirtime] > 1
    1
else
    -1
    
hline(threshold)

eema=ema(e,slma)
eemafast=ema(e,fama)
plot(eema,color=color.yellow)
plot(eemafast,color=color.red)
long=crossover(e,threshold) and dir==1 and eema>eema[1]
keeplong=0
keeplong:=if long
    1
else
    nz(keeplong[1])

closelong=eema>eemafast
keeplong:=if closelong
    0
else
    keeplong
    
short= (crossover(e,threshold) and dir==-1 and eema>eema[1])

keepshort=0
keepshort:=if short
    1
else
    nz(keepshort[1])
    
closeshort=eema>eemafast

keepshort:=if closeshort
    0
else
    keepshort

bgcolor(keeplong==1?color.lime:keepshort==1?color.red:na,transp=70)

if(long)
    strategy.entry("Long1",strategy.long,qty=max(0.000001,min((strategy.equity*leverage/open),100000000)))
if(closelong)
    strategy.close("Long1")

if(short)    
    strategy.entry("Short1",strategy.short,qty=max(0.000001,min((strategy.equity*leverage/open),100000000)))
if(closeshort)
    strategy.close("Short1")  
    
//plot(strategy.equity,color=color.lime)
````
