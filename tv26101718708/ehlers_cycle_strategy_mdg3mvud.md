# Ehlers Cycle Strategy

- url: https://www.tradingview.com/script/mdg3Mvud-Ehlers-Cycle-Strategy/
- type: strategy
- pine_id: PUB;tHZ6iD4rF5WNmoO2M0HCSVCWvZ6UM6dq
- version: 2.0

## Description

This uses Ehlers methods to create a cycle trading strategy.

It finds the dominant cycle in the market, then creates filters out noise to create an oscillator.  It then creates a trigger line using momentum to predict a reversal in price.  Finally, Ehlers Empirical Mode Discriminator is used to evaluate trends and eliminate trading against the trend.

Shout out to HPotter, Everget, and LazyBear for implementing many of Ehlers indicators, which I sampled to create this indicator and strategy.

## Source Code

````pine
//@version=3
strategy(title="Ehlers Cycle Strategy")
Delta = input(defval=0.4, title="Delta")
Alpha = input(.1)
Lookback = input(1000)
Overbought = input(80)
Oversold = input(20)
TrendLength = input(30)
TrendFraction = input(0.25)
PeriodMultiplier= input(3.0)
a = Alpha
src =  hl2


Pi = 3.141592654

ip = 0.0
s = (src + 2*src[1] + 2*src[2] + src[3])/6.0
c = 0.0
c := n<7?(src - 2*src[1] + src[2])/4.0:((1 - 0.5*a)*(1 - 0.5*a)*(s - 2*s[1] + s[2]) + 2*(1-a)*c[1] - (1 - a)*(1-a)*c[2])
q1 = (.0962*c + 0.5769*c[2] - 0.5769*c[4] - .0962*c[6])*(0.5+.08*nz(ip[1]))
I1 = c[3]
dp_ = iff(q1 != 0 and q1[1] != 0, (I1/q1 - I1[1]/q1[1]) / (1 + I1*I1[1]/(q1*q1[1])),0)
dp = iff(dp_ < 0.1, 0.1, iff(dp_ > 1.1, 1.1, dp_))
med(x,y,z) => (x+y+z) - min(x,min(y,z)) - max(x,max(y,z))
md = med(dp,dp[1], med(dp[2], dp[3], dp[4]))
dc = iff(md == 0, 15, 6.28318 / md + 0.5)

ip := .33*dc + .67*nz(ip[1])
p = 0.0
p := .15*ip + .85*nz(p[1])

length = p * PeriodMultiplier
hline(Overbought, color=white, linestyle=dotted)
hline(Oversold, color=white, linestyle=dotted)
beta = cos(Pi * (360 / length) / 180)
gamma = 1 / cos(Pi * (720 * Delta / length) / 180)
alpha = gamma - sqrt(gamma * gamma - 1)
BP = 0.0
BP := 0.5 * (1 - alpha) * (src - src[2]) + beta * (1 + alpha) * nz(BP[1]) - alpha * nz(BP[2])

q = (BP -BP[1])*length/(2.0*Pi)

lead = .5*BP + .866*q

leadPR = percentrank(lead, Lookback)
BPPR = percentrank(BP, Lookback)


xBandpassFilter = 0.0
xBandpassFilter := 0.5 * (1 - alpha) * (src - src[2]) + beta * (1 + alpha) * nz(xBandpassFilter[1]) - alpha * nz(xBandpassFilter[2])
xMean = sma(xBandpassFilter, 2 * TrendLength)
xPeak = 0.0
xPeak:=  iff (xBandpassFilter[1] > xBandpassFilter and xBandpassFilter[1] > xBandpassFilter[2], xBandpassFilter[1], nz(xPeak[1])) 
xValley = 0.0
xValley:=  iff (xBandpassFilter[1] < xBandpassFilter and xBandpassFilter[1] < xBandpassFilter[2], xBandpassFilter[1], nz(xValley[1])) 
xAvrPeak = sma(xPeak, 50)
xAvrValley = sma(xValley, 50)
nAvrPeak = TrendFraction * xAvrPeak
nAvrValley = TrendFraction * xAvrValley





if (leadPR > leadPR[1] and leadPR[1] <= leadPR[2] and leadPR[1] < Oversold and BPPR < 50)
    strategy.exit(id="BPSE")
    
    if (xMean >= nAvrValley)
        strategy.entry("BPLE", strategy.long, oca_name="BullishBP", oca_type=strategy.oca.cancel, comment="BPLE")

    
if (leadPR < leadPR[1] and leadPR[1] >= leadPR[2] and leadPR[1] > Overbought and BPPR > 50)
    strategy.exit(id="BPLE")
    
    if (xMean <= nAvrPeak)
        strategy.entry("BPSE", strategy.short, oca_name="BearishBP", oca_type=strategy.oca.cancel, comment="DivSE")

    
xColor = xMean > nAvrPeak ? green : xMean < nAvrValley ? red : yellow
plot(BPPR, color=#FF55FF, title="In Phase")
plot(leadPR, color=#55FF55, title="Lead")
plot(50, color=xColor, style=cross)
````
