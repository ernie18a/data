# Free Trend Lines Tool/Indicator

- url: https://www.tradingview.com/script/8JNoyOZh-Free-Trend-Lines-Tool-Indicator/
- type: indicator
- pine_id: PUB;owSIe7au19NaCD5hGfTZaRP617R9X9qf
- version: 3.0

## Description

I don't trade much with trend lines, but I was bored so made this hopefully someone will make use of it or program a strategy with it or something like that. It finds the highs and lows, works out the distance in time and price, then uses that to calculate the angle of the trend which can be used to pain the trend line. If you have any questions on how to implement it into a strategy feel free to ask. It is written in quite a messy wayt so sorry about that.

## Source Code

````pine
//@version=3
study("Trend Lines", overlay=true)
//update

length1 = input(20)
check = input(9)
//length2 = input(200)


u=0.0
u := u[1]

l=0.0
l := l[1]

y=0.0
y := y[1]

yl=0.0
yl := yl[1]

angle = 0.0
angle := angle[1]

anglel = 0.0
anglel := anglel[1]

if (highest(length1) == high[check] and highest(length1) == highest(length1)[check] and barssince(barstate.isfirst) > check)
    u := high[check]

    
if (lowest(length1) == low[check] and lowest(length1) == lowest(length1)[check] and barssince(barstate.isfirst) > check)
    l := low[check]
    

    
p = round(barssince(u == high[check]))

pl = round(barssince(l == low[check]))

if p == 0 and barssince(barstate.isfirst) > check
    y := high[abs(p[1]+1+check)]
    
if pl == 0 and barssince(barstate.isfirst) > check
    yl := low[abs(pl[1]+1+check)]    
    

if p == 0
    angle := (u-y)/p[1]

if pl == 0
    anglel := (l-yl)/pl[1]

uppertrend = u+ (p * angle)

lowertrend = l+ (pl * anglel)

extendup = if barssince(barstate.isfirst) > check
    uppertrend[check] + angle[check] * check*2

extenddown = if barssince(barstate.isfirst) > check
    lowertrend[check] + anglel[check] * check*2




//plot(l[offset]-u,color=red)
//plot(u[offset]-l,color = green )
plot(lowertrend, color = green, style=cross, transp=70,offset = -check)
plot(extenddown, color = green, style=cross, transp=0)
plot(uppertrend, color = red, style = cross,transp=70, offset = -check)
plot(extendup, color = red, style = cross, transp=0)
//plot(l[offset], color = red)
````
