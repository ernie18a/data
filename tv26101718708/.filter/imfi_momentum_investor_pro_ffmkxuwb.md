# IMFI Momentum Investor Pro

- url: https://www.tradingview.com/script/ffMkXUWb-IMFI-Momentum-Investor-Pro/
- type: indicator
- pine_id: PUB;95e77a43d34e44f1ae63e3ab5475344f
- version: 1.0

## Description

IMFI Momentum Investor Pro is a medium-term momentum investing indicator designed for 3–12 month investors. It combines trend strength (EMA 20/50/200), volume participation, RSI momentum, and relative strength versus Nifty into a single actionable framework. The indicator identifies Buy, Accumulate, Hold, Reduce, and Sell opportunities while filtering out short-term market noise. It also highlights unusual events such as a 15% price decline within two trading sessions and tracks weekly/monthly price performance along with volume momentum. The dashboard provides a quick view of trend quality, momentum, risk signals, and institutional accumulation strength.

## Source Code

````pine
//@version=6
indicator("IMFI Momentum Investor Pro", overlay=true, max_bars_back=300)

ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(ema20, "EMA20", color=color.green, linewidth=2)
plot(ema50, "EMA50", color=color.orange, linewidth=2)
plot(ema200, "EMA200", color=color.red, linewidth=3)

avgVol = ta.sma(volume, 20)
volRatio = avgVol > 0 ? volume / avgVol : 0.0

obv = ta.cum(close > close[1] ? volume : close < close[1] ? -volume : 0)
obvMA = ta.sma(obv, 20)

rsiValue = ta.rsi(close, 14)

niftyClose = request.security("NSE:NIFTY", timeframe.period, close)

stockReturn20 = close[20] != 0 ? ((close / close[20]) - 1) * 100 : 0
niftyReturn20 = niftyClose[20] != 0 ? ((niftyClose / niftyClose[20]) - 1) * 100 : 0

weekReturn = close[5] != 0 ? ((close / close[5]) - 1) * 100 : 0
monthReturn = close[21] != 0 ? ((close / close[21]) - 1) * 100 : 0

high52 = ta.highest(high, 252)
distance52 = high52 > 0 ? ((high52 - close) / high52) * 100 : 0

trendScore = 0.0
if close > ema20
    trendScore += 10
if ema20 > ema50
    trendScore += 10
if ema50 > ema200
    trendScore += 10

volumeScore = 0.0
if volRatio > 1.5
    volumeScore += 10
if obv > obvMA
    volumeScore += 10
if close > close[1] and volume > volume[1]
    volumeScore += 5

momentumScore = rsiValue > 60 ? 15 : rsiValue > 50 ? 8 : 0
rsScore = stockReturn20 > niftyReturn20 ? 15 : 0

highScore = distance52 < 5 ? 15 : distance52 < 10 ? 8 : distance52 < 20 ? 4 : 0

IMFI = trendScore + volumeScore + momentumScore + rsScore + highScore

bullTrend = close > ema20 and ema20 > ema50 and ema50 > ema200
bearTrend = close < ema20 and ema20 < ema50 and ema50 < ema200

bullReversal = ta.crossover(close, ema20) and volume > avgVol * 1.5 and rsiValue > 55
bearReversal = ta.crossunder(close, ema20) and volume > avgVol * 1.5 and rsiValue < 45

highest50 = ta.highest(high, 50)
breakout = close > highest50[1] and volume > avgVol * 2

volumeBlast = volume > avgVol * 2.5

twoDayReturn = close[2] != 0 ? ((close / close[2]) - 1) * 100 : 0
sharpFallAlert = twoDayReturn <= -15

priceWeakness = close < close[5] and close[5] < close[10]
volumeWeakness = ta.sma(volume, 5) < ta.sma(volume, 20)
distributionSell = priceWeakness and volumeWeakness

buySignal = (bullReversal or breakout) and IMFI >= 70

reduceSignal = close < ema50 and close[5] < ema50[5]

strongSell = close < ema200 and ema20 < ema50 and ema50 < ema200 and IMFI < 40

signalText = "HOLD"
if strongSell
    signalText := "SELL"
else if reduceSignal
    signalText := "REDUCE"
else if buySignal
    signalText := "BUY"
else if IMFI >= 60
    signalText := "ACCUM"

if sharpFallAlert
    signalText := signalText + " ⚠"

plotshape(buySignal, title="BUY", style=shape.labelup, text="BUY", location=location.belowbar, color=color.green)
plotshape(strongSell, title="SELL", style=shape.labeldown, text="SELL", location=location.abovebar, color=color.red)
plotshape(sharpFallAlert, title="15% Fall", style=shape.flag, text="15%↓", location=location.abovebar, color=color.orange)

bgColor = color.new(color.yellow, 92)
if sharpFallAlert
    bgColor := color.new(color.red, 60)
else if distributionSell
    bgColor := color.new(color.fuchsia, 80)
else if breakout
    bgColor := color.new(color.green, 70)
else if bullTrend
    bgColor := color.new(color.green, 92)
else if bearTrend
    bgColor := color.new(color.red, 92)

bgcolor(bgColor)



//=====================================================
// VOLUME MOMENTUM
//=====================================================
dailyVolumeChange = volume[1] > 0 ? ((volume / volume[1]) - 1) * 100 : 0
weeklyAvgVol = ta.sma(volume, 5)
monthlyAvgVol = ta.sma(volume, 20)
weeklyVolumeChange = monthlyAvgVol > 0 ? ((weeklyAvgVol / monthlyAvgVol) - 1) * 100 : 0


var table dashboard = table.new(position.bottom_right, 2, 11)

if barstate.islast
    table.cell(dashboard,0,0,"IMFI")
    table.cell(dashboard,1,0,str.tostring(IMFI,"#.##"))
    table.cell(dashboard,0,1,"Trend")
    table.cell(dashboard,1,1,bullTrend ? "Bull" : bearTrend ? "Bear" : "Side")
    table.cell(dashboard,0,2,"RSI")
    table.cell(dashboard,1,2,str.tostring(rsiValue,"#.##"))
    table.cell(dashboard,0,3,"Vol Week %")
    table.cell(dashboard,1,3,str.tostring(weeklyVolumeChange,"#.##")+"%")
    table.cell(dashboard,0,4,"Vol Week %")
    table.cell(dashboard,1,4,str.tostring(weekReturn,"#.##")+"%")
    table.cell(dashboard,0,5,"Month %")
    table.cell(dashboard,1,5,str.tostring(monthReturn,"#.##")+"%")
    table.cell(dashboard,0,6,"Price")
    table.cell(dashboard,1,6,str.tostring(close,"#.##"))
    table.cell(dashboard,0,7,"RS Nifty")
    table.cell(dashboard,1,7,stockReturn20 > niftyReturn20 ? "Strong" : "Weak")
    table.cell(dashboard,0,8,"2D Fall")
    table.cell(dashboard,1,8,sharpFallAlert ? "YES" : "NO")
    table.cell(dashboard,0,9,"Signal")
    table.cell(dashboard,1,9,signalText)
    table.cell(dashboard,0,10,"IMFI Zone")
    table.cell(dashboard,1,10,IMFI >= 70 ? "Strong" : IMFI >= 60 ? "Accum" : "Neutral")

alertcondition(buySignal, title="IMFI BUY", message="IMFI BUY")
alertcondition(strongSell, title="IMFI SELL", message="IMFI SELL")
````
