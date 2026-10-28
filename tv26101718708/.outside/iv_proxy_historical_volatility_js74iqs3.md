# IV Proxy / Historical Volatility

- url: https://www.tradingview.com/script/JS74IqS3-IV-Proxy-Historical-Volatility/
- type: indicator
- pine_id: PUB;5bc0c2516de54acf9da6221ccc67edde
- version: 1.0

## Description

The first one is the yellow line — the actual volatility reading itself. In your case, if you used the earlier TradingView script, it is not true broker-fed implied volatility but an IV proxy / historical volatility measure, calculated from recent price returns and annualized into a percentage.

What it means
That yellow line tells you how much the market has been moving, or is expected to move if you are using true IV, but it does not tell you direction. A higher reading means bigger swings and more uncertainty; a lower reading means calmer price action and smaller expected moves.

How to read it
If the yellow line rises, volatility is expanding and the market is becoming more active or more nervous. If it falls, volatility is compressing and the market is becoming quieter, which often means smaller price swings and cheaper option premiums.

Simple example
If the yellow line is around 20, that suggests a relatively calm regime; if it jumps to 50 or 60, that suggests much larger movement is being priced in or realized. Think of it as a speedometer for movement size, not a signal for whether price is going up or down.

Why it matters
For options, higher volatility usually means higher premiums, while lower volatility usually means cheaper premiums. So the yellow line helps you judge whether the environment is more favorable for buying premium or selling premium, but it works best when paired with the blue rank line so you know whether the current level is unusually high or low for that asset.

## Source Code

````pine
//@version=5
indicator("IV Proxy / Historical Volatility", overlay=false, precision=2)

len = input.int(20, "Lookback", minval=2)
barsPerYear = input.int(252, "Bars per Year", minval=1)
showRank = input.bool(true, "Show Vol Rank")
rankLookback = input.int(252, "Rank Lookback", minval=10)

logRet = math.log(close / close[1])
stdevRet = ta.stdev(logRet, len)
hv = stdevRet * math.sqrt(barsPerYear) * 100

lowestHv = ta.lowest(hv, rankLookback)
highestHv = ta.highest(hv, rankLookback)
ivRank = highestHv != lowestHv ? ((hv - lowestHv) / (highestHv - lowestHv)) * 100 : na

plot(hv, title="IV Proxy %", color=color.orange, linewidth=2)
plot(showRank ? ivRank : na, title="IV Rank", color=color.aqua, linewidth=2)

hline(20, "Low Vol", color=color.new(color.green, 70))
hline(50, "Mid Vol", color=color.new(color.gray, 70))
hline(80, "High Vol", color=color.new(color.red, 70))
````
