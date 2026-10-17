# SlingShotStrategy

- url: https://www.tradingview.com/script/0M0wfs7E-SlingShotStrategy/
- type: strategy
- pine_id: PUB;Ar7NtTT3XQ03jm4YV2AokUhmir6GPcXI
- version: 3.0

## Description

Based on an existing SlingShotStrategy.  Added the ability to set capital, and order limit in settings.. Back Testing is great.   Plan to improve more, let me know what you think.

## Source Code

````pine
//Created by ChrisMoody on 10-05-2014
// @version=3
// Turned into a strategy by Rick Bird
// SlingShot Strategy 
strategy("SlingShotStrategy", overlay=true, default_qty_value=100000, initial_capital=10000)
sae = input(true, title="Show Aggressive Entry?, Or Use as Alert To Potential Conservative Entry?")
sce = input(true, title="Show Conservative Entry?")
st = input(true, title="Show Trend Arrows at Top and Bottom of Screen?")
def = input(false, title="Only Choose 1 - Either Conservative Entry Arrows or 'B'-'S' Letters")
pa = input(true, title="Show Conservative Entry Arrows?")
sl = input(false, title="Show 'B'-'S' Letters?")
sema = input(50,title = "SEMA")
fema = input(20,title = "FEMA")


// Component Code Start
tradingStyle = input(title="Trading Style", defval="Conservative", options=["Conservative", "Aggressive"])
backTestOn = input(false, title="Set Back Test Range")
testStartYear = input(2018, "Backtest Start Year")
testStartMonth = input(1, "Backtest Start Month")
testStartDay = input(1, "Backtest Start Day")
testPeriodStart = timestamp(testStartYear,testStartMonth,testStartDay,0,0)

testStopYear = input(2019, "Backtest Stop Year")
testStopMonth = input(12, "Backtest Stop Month")
testStopDay = input(30, "Backtest Stop Day")
testPeriodStop = timestamp(testStopYear,testStopMonth,testStopDay,0,0)

// A switch to control background coloring of the test period
testPeriodBackground = input(title="Color Background?", type=bool, defval=true)
testPeriodBackgroundColor = testPeriodBackground and (time >= testPeriodStart) and (time <= testPeriodStop) ? #00FF00 : na
bgcolor(testPeriodBackgroundColor, transp=97)

testPeriod() => not backTestOn or (time >= testPeriodStart and time <= testPeriodStop ? true : false)
    

//EMA Definitions
emaSlow = ema(close, 50)
emaFast = ema(close, 20)

//Aggressive Entry or Alert To Potential Trade
pullbackUpT() => emaFast > emaSlow and close < emaFast
pullbackDnT() => emaFast < emaSlow and close > emaFast

//Conservative Entry Code For Highlight Bars
entryUpT() => emaFast > emaSlow and close[1] < emaFast and close > emaFast
entryDnT() => emaFast < emaSlow and close[1] > emaFast and close < emaFast

//Conservative Entry True/False Condition
entryUpTrend = emaFast > emaSlow and close[1] < emaFast and close > emaFast ? 1 : 0
entryDnTrend = emaFast < emaSlow and close[1] > emaFast and close < emaFast ? 1 : 0

//Define Up and Down Trend for Trend Arrows at Top and Bottom of Screen
upTrend = emaFast >= emaSlow
downTrend = emaFast < emaSlow

//Definition for Conseervative Entry Up and Down PlotArrows
codiff = entryUpTrend == 1 ? entryUpTrend : 0
codiff2 = entryDnTrend == 1 ? entryDnTrend : 0

//Color definition for Moving Averages
col = emaFast > emaSlow ? lime : emaFast < emaSlow ? red : yellow

//Moving Average Plots and Fill
p1 = plot(emaSlow, title="Slow MA", style=linebr, linewidth=4, color=col)
p2 = plot(emaFast, title="Fast MA", style=linebr, linewidth=2, color=col)
fill(p1, p2, color=silver, transp=50)

//Aggressive Entry, Conservative Entry Highlight Bars
barcolor(sae and pullbackUpT() ? yellow : sae and pullbackDnT() ? yellow : na)
barcolor(sce and entryUpT() ? aqua : sce and entryDnT() ? aqua : na)

//Trend Triangles at Top and Bottom of Screen
plotshape(st and upTrend ? upTrend : na, title="Conservative Buy Entry Triangle",style=shape.triangleup, location=location.bottom, color=lime, transp=0, offset=0)
plotshape(st and downTrend ? downTrend : na, title="Conservative Short Entry Triangle",style=shape.triangledown, location=location.top, color=red, transp=0, offset=0)

//Plot Arrows OR Letters B and S for Buy Sell Signals
plotarrow(pa and codiff ? codiff : na, title="Up Entry Arrow", colorup=lime, maxheight=30, minheight=30, transp=0)
plotarrow(pa and codiff2*-1 ? codiff2*-1 : na, title="Down Entry Arrow", colordown=red, maxheight=30, minheight=30, transp=0)
plotchar(sl and codiff ? low - tr : na, title="Buy Entry", offset=0, char='B', location=location.absolute, color=lime, transp=0)
plotchar(sl and codiff2 ? high + tr : na, title="Short Entry", offset=0, char='S', location=location.absolute, color=red, transp=0)

// Now Enter Buy/Sells
if tradingStyle == "Conservative"
    strategy.entry("long", strategy.long, when = testPeriod() and entryUpTrend)
    strategy.entry("short", strategy.short, when = testPeriod() and entryDnTrend)

if tradingStyle == "Aggressive"
    strategy.entry("long", strategy.long, when = testPeriod() and pullbackUpT())
    strategy.entry("short", strategy.short, when = testPeriod() and pullbackDnT())
````
