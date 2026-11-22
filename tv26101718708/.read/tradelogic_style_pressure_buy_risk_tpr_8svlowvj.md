# TradeLogic Style Pressure / Buy Risk / TPR

- url: https://www.tradingview.com/script/8SvlowVJ-TradeLogic-Style-Pressure-Buy-Risk-TPR/
- type: indicator
- pine_id: PUB;3ae9dd2f034f48dca29f431ea226fec4
- version: 1.0

## Description

This indicator's goal is to turn a full checklist trend template, risk location, and RS leadership, into colored bands so you can see whether a stock is 1. in a strong enough trend, 2. sitting at a buyable price zone, and 3. acting like a true leader.

## Source Code

````pine
//@version=5
indicator("Minervini Style Pressure / Buy Risk / TPR", overlay=false)

// Inputs
benchmark    = input.symbol("AMEX:SPY", "Benchmark")
shortLen     = input.int(21, "Short Trend Length", minval=5)
midLen       = input.int(50, "Mid Trend Length", minval=10)
longLen1     = input.int(150, "Long Trend Length 1", minval=50)
longLen2     = input.int(200, "Long Trend Length 2", minval=50)
rsSmooth     = input.int(10, "RS Smooth Length", minval=1)
rprLookback  = input.int(252, "RPR Lookback", minval=50)
greenMaxPct  = input.float(15.0, "Green max % above 50MA", step=0.1)
yellowMaxPct = input.float(25.0, "Yellow max % above 50MA", step=0.1)

// MAs
ema21  = ta.ema(close, shortLen)
sma50  = ta.sma(close, midLen)
sma150 = ta.sma(close, longLen1)
sma200 = ta.sma(close, longLen2)

// Relative strength
benchClose = request.security(benchmark, timeframe.period, close)
rsRaw      = close / benchClose
rsLine     = ta.ema(rsRaw, rsSmooth)
rsRank     = ta.percentrank(rsRaw, rprLookback) * 100.0

// Buy Risk
distPct = ((close - sma50) / sma50) * 100.0

buyRiskState = 0
if distPct < 0
    buyRiskState := -1
else if distPct <= greenMaxPct
    buyRiskState := 1
else if distPct <= yellowMaxPct
    buyRiskState := 0
else
    buyRiskState := -1

buyRiskColor = color.red
if buyRiskState == 1
    buyRiskColor := color.green
else if buyRiskState == 0
    buyRiskColor := color.yellow
else
    buyRiskColor := color.red

// Pressure
trendScore = 0
trendScore += close > ema21 ? 1 : 0
trendScore += close > sma50 ? 1 : 0
trendScore += sma50 > sma150 ? 1 : 0
trendScore += sma150 > sma200 ? 1 : 0
trendScore += sma200 > sma200[20] ? 1 : 0
trendScore += rsLine > rsLine[10] ? 1 : 0

pressureState = 0
if trendScore >= 5
    pressureState := 1
else if trendScore >= 3
    pressureState := 0
else
    pressureState := -1

pressureColor = color.red
if pressureState == 1
    pressureColor := color.green
else if pressureState == 0
    pressureColor := color.yellow
else
    pressureColor := color.red

// TPR proxy
tpr = 0.0
tpr += close > ema21 ? 20 : 0
tpr += close > sma50 ? 20 : 0
tpr += sma50 > sma150 ? 20 : 0
tpr += sma150 > sma200 ? 20 : 0
tpr += rsLine > rsLine[20] ? 20 : 0

tprState = 0
if tpr >= 80
    tprState := 1
else if tpr >= 60
    tprState := 0
else
    tprState := -1

tprColor = color.red
if tprState == 1
    tprColor := color.green
else if tprState == 0
    tprColor := color.yellow
else
    tprColor := color.red

// Rows
pressureRow = 3
buyRiskRow  = 2
tprRow      = 1

plot(pressureRow, title="Pressure", style=plot.style_columns, color=pressureColor, linewidth=12)
plot(buyRiskRow, title="Buy Risk", style=plot.style_columns, color=buyRiskColor, linewidth=12)
plot(tprRow, title="TPR", style=plot.style_columns, color=tprColor, linewidth=12)

tprLineScaled = 1.0 + (tpr / 100.0) * 0.8
plot(tprLineScaled, title="TPR Blue Line", color=color.aqua, linewidth=2)

// Optional hidden RPR line
plot(rsRank / 100.0, title="RPR Rank", color=color.blue, linewidth=2, display=display.none)
````
