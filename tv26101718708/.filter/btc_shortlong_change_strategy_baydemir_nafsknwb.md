# BTC Short/Long Change Strategy [Baydemir]

- url: https://www.tradingview.com/script/nafsKNWb-BTC-Short-Long-Change-Strategy-Baydemir/
- type: strategy
- pine_id: PUB;rE9H5nYJGLVk1re5KHPa41W61PArZGF4
- version: 3.0

## Description

BTC Short/Long Change Strategy [Baydemir]

## Source Code

````pine
//@version=3
strategy("BTC Short/Long Change Strategy [Baydemir]")
res=period
//len1=input(defval=4, title="FAST PERIOD", type=integer,minval=2)
len2=input(defval=5, title="SLOW PERIOD", type=integer,minval=2)

line1=security("btcusdshorts",res,close)
line2=security("btcusdlongs",res,close)

hist=-line1+line2
mahist=wma(hist,len2)

//val=(wma(hist,len1)-wma(hist,len2))
val=(hist-mahist)

//plot(line1,title="SHORTS",color=red,linewidth=2)
//plot(line2,title="LONG",color=green, linewidth=2)

bcolor = iff( val >= 0, iff( val > nz(val[1]), lime, green),iff( val < nz(val[1]), red, maroon)) 
p1=plot(val,title="SMA",style=histogram,color=bcolor, linewidth=4)

plot(hist,color=blue)
plot(mahist,color=red)

longCondition = crossover(hist,mahist)
shortCondition = crossunder(hist,mahist)
strategy.entry("LONG",true,qty=1,when=longCondition)
strategy.entry("SHORT",false,qty=1,when=shortCondition)
````
