# Linear Regression Pearson's R - Trend Channel Strategy

- url: https://www.tradingview.com/script/6VHnjgfp-Linear-Regression-Pearson-s-R-Trend-Channel-Strategy/
- type: strategy
- pine_id: PUB;QwWTVXTXH8l9NESgTx5RYpvlIkLY8ZDZ
- version: 1.0

## Description

This script takes advantage of the Pearson's R attribute of the data set you provide.  

Pearson's R attempts to find how correlated data is with a potential pattern.  If the number is [b]negative[/b] the correlation is [b]upwards[/b].  If it's [b]positive[/b] the correlation is [b]downwards[/b].  Pearson's R can only be a number between -1 and 1.  It should be impossible to ever reach -1 or 1 as that would be a perfect correlation.

This particular strategy involves using linear regression and Pearson's R to keep recalculating steps back from the current position until the Pearson's R reaches the desired amount.  For example, in my experience I have found that 0.85 for as a buy point is very good as it means the trend is very reliable and solid.  When the market tends to be bullish it tends to do so longer then when it's bearish.

Likewise when a downtrend is more real, I found that 0.71 for the negative Pearson's R value is ideal and gives the best results.

These can all be changed in the settings section (with the gear icon) next to when you set your results.

This strategy is really fun/useful to watch if you have the [b]replay bar mode[/b] enabled for TradingView.  This script supports this and all you have to do is [b]go into the settings and enable realtime mode[/b].  Doing this you can actually see the trend lines change in realtime and comes in very handy for seeing long term reversals as you will see the Pearson's R value start to go down or up indicating the path it's going on.

WARNING: This script is very intensive on the processing power of your machine.  If you find that it's to slow you may have to go into the settings of the script and adjust the 'step by' parameter so that it calculates a little faster.  It won't be as accurate but it will be good enough.  I feel I've optimized it with it's current setting as an example of what you want to aim for.

If there are any questions do no hesitate to message or ask me.  I love feedback on the community for new features and ideas!

This works best with with [b]XBTUSD on the 4 hourly chart[/b].  It does not seem to work well if you go below hourly or go above daily.

## Source Code

````pine
// @version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © x11joe
// Credit given to @midtownsk8rguy for some original source code parts (I was given permission to do so). I simply modified to add Pearson's R and the ability to always draw lines matching a certain Pearson's R as well as my own unique strategy involving using Pearson's R as it changes over time.

strategy(title="Linear Regression Pearson's R - Trend Channel Strategy", overlay=true,initial_capital=1000,commission_type=strategy.commission.percent,commission_value=0.26,default_qty_type=strategy.percent_of_equity,default_qty_value=100)
//period     = input(     200, "Period"       , input.integer, minval=3)
deviations = input(    2.0, "Deviation(s)" , input.float  , minval=0.1, step=0.1)
extendType = input("None", "Extend Method", input.string , options=["Right","None"])=="Right" ? extend.right : extend.none
var int tempPeriod = na
minPeriod = input(24,"Min Period",input.integer)//24 would be 48 hours (2 days) on the 2 hour.
stepBy    = input(12,"Step By (Speeds Up Calculation, MUST be multiple of min and max)",input.integer)
maxPeriod = input(360,"Max Period",input.integer)//168 would be 2 weeks or 14 days on the 2 hour.
pearsonsIdealPositive = input(0.85,"Pearson's Ideal Value +",input.float)
pearsonsIdealNegative = input(-0.71,"Pearson's Ideal Value -",input.float)
useRealTime = input(false,"Use Real Time Data (Good for Rewind Mode)",input.bool)

//Initially Define the variables
var int periodMinusOne = na
var float Ex = na
var float Ey = na
var float Ex2 = na
var float Ey2 = na
var float Exy = na
var float ExT2 = na //Sum of X THEN Squared
var float EyT2 = na //Sum of Y THEN Squared
var float PearsonsR = na
var float ExEx = na
var float slope = na
var float linearRegression = na
var float intercept = na
var float deviation = na
var float startingPointY = na

//Loop through the max period back to find situations in which the Pearson's is either -8.0 or 8.0
var int perfectPeriod = na
var float maxPearsons = na
var float maxStartingPointY = na
var float maxLinearRegression = na
var float maxDeviation = na

for k=maxPeriod to minPeriod by stepBy
    periodMinusOne := k-1
    Ex := 0.0, Ey := 0.0, Ex2 := 0.0,Ey2 := 0.0, Exy := 0.0, for i=0 to periodMinusOne
        closeI = nz(close[i]), Ex := Ex + i, Ey := Ey + closeI, Ex2 := Ex2 + (i * i),Ey2 := Ey2 + (closeI * closeI), Exy := Exy + (closeI * i)
    ExT2 := pow(Ex,2.0) //Sum of X THEN Squared
    EyT2 := pow(Ey,2.0) //Sym of Y THEN Squared
    PearsonsR := (Exy - ((Ex*Ey)/k))/(sqrt(Ex2-(ExT2/k))*sqrt(Ey2-(EyT2/k)))
    ExEx := Ex * Ex, slope = Ex2==ExEx ? 0.0 : (k * Exy - Ex * Ey) / (k * Ex2 - ExEx)
    linearRegression := (Ey - slope * Ex) / k
    intercept := linearRegression + bar_index * slope
    deviation := 0.0
    for i=0 to periodMinusOne
        deviation := deviation + pow(nz(close[i]) - (intercept - slope * (bar_index[i])), 2.0)
    deviation := deviations * sqrt(deviation / periodMinusOne)
    startingPointY := linearRegression + slope * periodMinusOne
    perfectPeriod:=k
    if(k==maxPeriod)
        maxPearsons:=PearsonsR
        maxStartingPointY:=startingPointY
        maxLinearRegression:=linearRegression
        maxDeviation := deviation
    if(PearsonsR>=pearsonsIdealPositive or PearsonsR<=pearsonsIdealNegative)
        break//exit the loop early and a line is chosen.

var line upperChannelLine = na  , var line medianChannelLine = na  , var line lowerChannelLine = na, var line upperTradeLine = na, var line lowerTradeLine = na, var line maxTradeLine = na, var line maxUpperChannelLine = na, var line maxLowerChannelLine = na
upperChannelLine  := line.new(bar_index - perfectPeriod + 1, startingPointY + deviation, bar_index, linearRegression + deviation, xloc.bar_index, extendType, color.new(#FF0000, 0), line.style_solid , 2)
medianChannelLine := line.new(bar_index - perfectPeriod + 1, startingPointY            , bar_index, linearRegression            , xloc.bar_index, extendType, color.new(#C0C000, 0), line.style_solid , 1)
lowerChannelLine  := line.new(bar_index - perfectPeriod + 1, startingPointY - deviation, bar_index, linearRegression - deviation, xloc.bar_index, extendType, color.new(#00FF00, 0), line.style_solid , 2)

upperTradeLine    := line.new(bar_index - perfectPeriod + 1, startingPointY + (deviation*2), bar_index, linearRegression + (deviation*2), xloc.bar_index, extendType, color.new(#FF0000, 0), line.style_dashed , 2)
lowerTradeLine    := line.new(bar_index - perfectPeriod + 1, startingPointY - (deviation*2), bar_index, linearRegression - (deviation*2), xloc.bar_index, extendType, color.new(#00FF00, 0), line.style_dashed , 2)

maxTradeLine         := line.new(bar_index - maxPeriod + 1, maxStartingPointY , bar_index, maxLinearRegression , xloc.bar_index, extendType, color.new(#C0C000, 50), line.style_dotted , 2)
maxUpperChannelLine  := line.new(bar_index - maxPeriod + 1, maxStartingPointY + maxDeviation, bar_index, maxLinearRegression + maxDeviation, xloc.bar_index, extendType, color.new(#FF0000, 50), line.style_dotted , 3)
maxLowerChannelLine  := line.new(bar_index - maxPeriod + 1, maxStartingPointY - maxDeviation, bar_index, maxLinearRegression - maxDeviation, xloc.bar_index, extendType, color.new(#FF0000, 50), line.style_dotted , 3)

var bool maxDowntrend = na
var bool currentDownTrend = na

var label pearsonsRLabel = na
var label pearsonsRMaxLabel = na

pearsonsRLabel := label.new(bar_index - perfectPeriod + 1,startingPointY - deviation*1.5,text=tostring(PearsonsR)+" P=("+tostring(perfectPeriod)+") - Short Trend", color=color.black,style=label.style_labelup,textcolor=color.white,size=size.large)
pearsonsRMaxLabel := label.new(bar_index - perfectPeriod + 1,startingPointY - deviation*3.5,text=tostring(maxPearsons)+" P=("+tostring(maxPeriod)+") - Long Trend", color=color.black,style=label.style_labelup,textcolor=color.white,size=size.normal)
//Clear the old lines and label
line.delete(upperChannelLine[1]), line.delete(medianChannelLine[1]), line.delete(lowerChannelLine[1]), line.delete(upperTradeLine[1]), line.delete(lowerTradeLine[1]), line.delete(maxTradeLine[1]),line.delete(maxUpperChannelLine[1]),line.delete(maxLowerChannelLine[1])
label.delete(pearsonsRLabel[1]),label.delete(pearsonsRMaxLabel[1])

if(useRealTime==false)
    if(PearsonsR<0) 
        strategy.entry("Long", strategy.long)//5 percent loss at any time is OK
    if(PearsonsR>0)
        strategy.entry("Short",strategy.short)//5 Percent loss at any time is okay
else
    if(barstate.isrealtime==true)
        if(PearsonsR<0) 
            strategy.entry("Long", strategy.long)//5 percent loss at any time is OK
        if(PearsonsR>0)
            strategy.entry("Short",strategy.short)//5 Percent loss at any time is okay
````
