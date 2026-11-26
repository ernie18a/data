# Extended Recursive Bands Strategy

- url: https://www.tradingview.com/script/ZE5dQUPR-Extended-Recursive-Bands-Strategy/
- type: strategy
- pine_id: PUB;a71574b97f6b41eebf4953db282c8d55
- version: 3.0

## Description

[b]The [url=https://www.tradingview.com/script/ZkxYgPTT-Extended-Recursive-Bands-Maximum-Efficiency-With-Extra-Options/]original indicator[/url] was created by [url=https://www.tradingview.com/u/alexgrover]alexgrover[/url].[/b]

All credit goes to alexgrover for creating the indicator that this strategy uses.

This strategy was posted because there were multiple requests for it, and no strategy based on this indicator exists yet.

The Recursive Bands Indicator, an indicator specially created to be extremely efficient, I think you already know that calculation time is extra important in algorithmic trading, and this is the principal motivation for the creation of the proposed indicator. Originally described in Alex's paper "Pierrefeu, Alex (2019): Recursive Bands - A New Indicator For Technical Analysis", the indicator framework has been widely used in his previous uploaded indicators, however it would have been a shame to not upload it, however user experience being a major concern for me, I decided to add extra options, which explain the term "extended".

[b]The Indicator[/b]
The indicator displays one upper and one lower band, every common usages applied to bands indicators such as support/resistance , breakout, trailing stop, etc, can also be applied to this one. Length controls how reactive the bands are, higher values will make the bands cross the price less often.

In order to provide more flexibility for the user alexgrover added the option to use various methods for the calculation of the indicator, therefore the indicator can use the average true range , standard deviation, average high-low range, and one totally exclusive method specially designed for this indicator.

[b]Added logic:[/b]
We have implemented a logic that checks whether the bands have been following in the same direction for a set amount of bars. This logic must be true before it can enter trades. This is completely new code that was written by us entirely, and it makes a huge difference on strategy performance.

[b]Strategy Long conditions:[/b]
1 — Price low is below the the lower band.
2 — The lower band keeps increasing in value until the 'lookback' setting amount of bars is reached.

[b]Strategy Short conditions:[/b]
1 — Price high is above the upper band.
2 — The upper band keeps decreasing in value until the 'lookback' setting amount of bars is reached.

[b]Strategy Properties:[/b]
We have set a default commission of 0.06% because these are Bybit's fees. The strategy uses an order size of 10% of equity, since drawdown is very low like this. We also use a 10 tick slippage to keep results realistic and account for this. All other settings were left as default apart from initial capital, just to decrease the size of the numbers.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// @version=5
// Original indicator by alexgrover.
// Strategy version by Adulari, with added functionality.

// Strategy
strategy('Extended Recursive Bands Strategy', overlay=true, commission_type=strategy.commission.percent,commission_value=0.06,default_qty_type =strategy.percent_of_equity,default_qty_value = 100,initial_capital =1000, pyramiding=0)

// Inputs
showTrades = input.bool(false, title='Trades',group='Display Settings', confirm=true,inline='Trades')
showPlots = input.bool(false, title='Plots',group='Display Settings',confirm=true,inline='Trades')
rsiEntry = input.bool(true,title='RSI',group='Entry Conditions')
mfiEntry = input.bool(true,title='MFI',group='Entry Conditions')
adxEntry = input.bool(false,title='ADX',group='Entry Conditions')
cfEntry = input.bool(false, title='CF', group='Entry Conditions')
erbLength = input.int(250,minval=1,step=10, title='Length', group='ERB Settings',inline='Length')
erbSource = input(close, title='Source', group='ERB Settings',inline='Length')
erbMethod = input.string('Classic', options=['Classic', 'ATR', 'STDEV', 'AHLR', 'RFV'], title='Method', group='ERB Settings',inline='Method')
erbLookback = input.int(4,minval=1,title='Lookback', group='ERB Settings',inline='Method')
erbBDC = input.bool(true, title='Bands Direction', group='ERB Settings')
RR = input.float(3.4,title='RR',group='Risk Settings',inline='RR')
atrLength = input.int(14,minval=1,title='Length',inline='Length',group='ATR Settings')
atrMultiplier = input.float(4.0,minval=0.0,step=0.1,title='Multiplier',inline='Length',group='ATR Settings')
rsiLength = input.int(title='Length',minval=1, defval=14, group='RSI Settings',inline='Length')
rsiSource = input(close, title="Source", group='RSI Settings',inline='Length')
rsiOversold = input.int(title='Oversold', minval=0,defval=30, group='RSI Settings',inline='Oversold')
rsiOverbought = input.int(title='Overbought',minval=0, defval=69, group='RSI Settings',inline='Oversold')
mfiLength = input.int(title='Length',minval=1, defval=14, group='MFI Settings',inline='Length')
mfiSource = input(close, title="Source", group='MFI Settings',inline='Length')
mfiOversold = input.int(title='Oversold', minval=0,defval=50, group='MFI Settings',inline='Oversold')
mfiOverbought = input.int(title='Overbought',minval=0, defval=50, group='MFI Settings',inline='Oversold')
cfLength = input.int(59,minval=1, title='Length', group='CF Settings', inline='Length')
cfLookback = input.int(36,minval=1, title='Lookback', group='CF Settings', inline='Length')
adxSmoothing = input.int(24,minval=1, title='ADX Smoothing', group='ADX Settings', inline='ADX Smoothing')
diLength = input.int(24,minval=1, title='DI Length', group='ADX Settings', inline='ADX Smoothing')
adxThreshold = input.float(18,minval=0, title='Threshold', group='ADX Settings', inline='Threshold')
CbTiOD = input.bool(title='Close by Trade in Opposite Direction',defval=true,group='Behavioral Settings')

// Calculate Methods
atr = ta.atr(erbLength)
stdev = ta.stdev(erbSource, erbLength)
ahlr = ta.sma(high - low, erbLength)
rfv = 0.
rfv := ta.rising(erbSource, erbLength) or ta.falling(erbSource, erbLength) ? math.abs(ta.change(erbSource)) : rfv[1]

// Get ERB erbMethod
f(a, b, c) =>
    erbMethod == a ? b : c
v(x) =>
    f('ATR', atr, f('STDEV', stdev, f('AHLR', ahlr, f('RFV', rfv, x))))

// Recursive Bands
erbSC = 2 / (erbLength + 1)
erbUpperBand = 0.
erbUpperBand := math.max(nz(erbUpperBand[1], erbSource), erbSource) - erbSC * v(math.abs(erbSource - nz(erbUpperBand[1], erbSource)))
erbLowerBand = 0.
erbLowerBand := math.min(nz(erbLowerBand[1], erbSource), erbSource) + erbSC * v(math.abs(erbSource - nz(erbLowerBand[1], erbSource)))
erbMiddleBand = (erbUpperBand+erbLowerBand)/2 // added recursive middle line
erbOpenLong = ta.crossunder(low,erbLowerBand)
erbOpenShort = ta.crossover(high,erbUpperBand)

// RSI
RSI = ta.rsi(rsiSource,rsiLength)
rsiOpenLong = rsiEntry ? RSI<rsiOversold : true
rsiOpenShort = rsiEntry ? RSI>rsiOverbought : true

// MFI
MFI = ta.mfi(mfiSource,mfiLength)
mfiOpenLong = mfiEntry ? MFI<mfiOversold : true
mfiOpenShort = mfiEntry ? MFI>mfiOverbought : true

// ADX
[_,_,ADX] = ta.dmi(diLength,adxSmoothing)
adxOpen = adxEntry ? ADX>adxThreshold : true

// Band Direction by Adulari
bhdUptrendCount = 0
bhdDowntrendCount = 0
for i = 0 to erbLookback-1
    if erbLowerBand[i] > erbLowerBand[i+1]
        bhdUptrendCount:=bhdUptrendCount+1
    if erbUpperBand[i] < erbUpperBand[i+1]
        bhdDowntrendCount:=bhdDowntrendCount+1
bhdOpenLong = erbBDC ? bhdUptrendCount==erbLookback : true
bhdOpenShort = erbBDC ? bhdDowntrendCount==erbLookback : true

// ATR
ATR = ta.atr(atrLength)
atrLower = low-atr*atrMultiplier
atrHigher = high+atr*atrMultiplier

// Consolidation Zones by Lonesometheblue
float cfHighestBars = ta.highestbars(cfLookback) == 0 ? high : na
float cfLowestBars = ta.lowestbars(cfLookback) == 0 ? low : na
var int cfDir = 0
float cfZZ = na
float cfPP = na
cfIff = cfLowestBars and na(cfHighestBars) ? -1 : cfDir
cfDir := cfHighestBars and na(cfLowestBars) ? 1 : cfIff
if cfHighestBars and cfLowestBars
    if cfDir == 1
        cfZZ := cfHighestBars
        cfZZ
    else
        cfZZ := cfLowestBars
        cfZZ
else
    cfIff = cfLowestBars ? cfLowestBars : na
    cfZZ := cfHighestBars ? cfHighestBars : cfIff
    cfZZ
for x = 0 to 1000 by 1
    if na(close) or cfDir != cfDir[x]
        break
    if cfZZ[x]
        if na(cfPP)
            cfPP := cfZZ[x]
            cfPP
        else
            if cfDir[x] == 1 and cfZZ[x] > cfPP
                cfPP := cfZZ[x]
                cfPP
            if cfDir[x] == -1 and cfZZ[x] < cfPP
                cfPP := cfZZ[x]
                cfPP
var int cfCount = 0
var float cfHigh = na
var float cfLow = na
float cfH = ta.highest(cfLength)
float cfL = ta.lowest(cfLength)
var line cfUpperLine = na
var line cfLowerLine = na
bool cfBreakout = false
bool cfBreakdown = false
if ta.change(cfPP)
    if cfCount > cfLength
        if cfPP > cfHigh
            cfBreakout := true
            cfBreakout
        if cfPP < cfLow
            cfBreakdown := true
            cfBreakdown
    if cfCount > 0 and cfPP <= cfHigh and cfPP >= cfLow
        cfCount += 1
        cfCount
    else
        cfCount := 0
        cfCount
else
    cfCount += 1
    cfCount

if cfCount >= cfLength
    if cfCount == cfLength
        cfHigh := cfH
        cfLow := cfL
        cfLow
    else
        cfHigh := math.max(cfHigh, high)
        cfLow := math.min(cfLow, low)
        cfLow
    cfLowerLine
cfOpen = cfEntry ? cfCount < cfLength : true

// Stop Loss & Take Profit
barsSinceEntry = ta.barssince(bar_index==strategy.opentrades.entry_bar_index(0))
max_bars_back(atrLower, 5000)
max_bars_back(atrHigher, 5000)
longSL = atrLower[barsSinceEntry]
shortSL = atrHigher[barsSinceEntry]
longTP = strategy.position_avg_price+(strategy.position_avg_price-longSL)*RR
shortTP = strategy.position_avg_price-(shortSL-strategy.position_avg_price)*RR

// Conditions
CbTiODLong = CbTiOD ? true : strategy.position_size>0 or strategy.opentrades==0
CbTiODShort = CbTiOD ? true : strategy.position_size<0 or strategy.opentrades==0
openLong = erbOpenLong and bhdOpenLong and rsiOpenLong and adxOpen and cfOpen and CbTiODLong and mfiOpenLong
openShort = erbOpenShort and bhdOpenShort and rsiOpenShort and adxOpen and cfOpen and CbTiODShort and mfiOpenShort

closeLong = (low<longSL or high>longTP)
closeShort = (high>shortSL or low<shortTP)

// Colors
beColor = #675F76
buColor = #a472ff

// Plots
pA = plot(showPlots ? erbUpperBand : na, color=color.new(beColor, 0), linewidth=1, title='Upper Band')
pB = plot(showPlots ? erbLowerBand : na, color=color.new(buColor, 0), linewidth=1, title='Lower Band')
pC = plot(showPlots ? erbMiddleBand : na, color=color.rgb(120,123,134,0), linewidth=1, title='Middle Band')
fill(pC, pA, color=color.new(beColor,95))
fill(pC, pB, color=color.new(buColor,95))

// Orders
if openLong
    strategy.entry(id='Long',direction=strategy.long)
if openShort
    strategy.entry(id='Short',direction=strategy.short)
if closeLong
    strategy.close(id='Long')
if closeShort
    strategy.close(id='Short')

// Trade Plots
entryPlot = plot(showTrades ? strategy.opentrades > 0 ? strategy.position_avg_price : na : na, title='Strategy Entry', color=color.rgb(120,123,134,0),style=plot.style_linebr,editable=true)
tpPlot = plot(showTrades ? strategy.position_size > 0 ? longTP : strategy.position_size < 0 ? shortTP : na : na, title='Take Profit', color=buColor,style=plot.style_linebr,editable=true)
slPlot = plot(showTrades ? strategy.position_size > 0 ? longSL : strategy.position_size < 0 ? shortSL : na : na, title='Stop Loss', color=beColor,style=plot.style_linebr,editable=true)
fill(entryPlot,slPlot,color=showTrades ? color.new(beColor,95) : na,editable=true)
fill(entryPlot,tpPlot,color=showTrades ? color.new(buColor,95) : na,editable=true)
````
