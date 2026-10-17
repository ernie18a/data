# Advanced Volatility

- url: https://www.tradingview.com/script/84Ak8gm5-Advanced-Volatility/
- type: indicator
- pine_id: PUB;6e0bb16ebc3d4120a1acc6d9f24c7c1f
- version: 1.0

## Description

1. Normalized ATR (%) - The Blue Line
What it is: The standard Average True Range (ATR) divided by the current closing price.
Why it matters: It tells you exactly what percentage the asset moves on an average bar. If the nATR is 2.0%, you know the asset swings roughly 2% per candle. This is incredibly useful for setting dynamic stop losses and take profits that scale mathematically with the asset's price, rather than guessing arbitrary dollar amounts.

2. BB Width (%) - The Orange Line
What it is: The distance between the Upper and Lower Bollinger Bands, divided by the Middle Band.
Why it matters: This acts as a highly effective "Squeeze" proxy. Volatility is cyclical; it contracts, then it expands. When you see the Orange line drop to extremely low historical levels, it means the Bollinger Bands are pinching tight. This contraction indicates that energy is building up, and a massive breakout/expansion move is imminent.

3. Historical Volatility (%) - The Fuchsia Line
What it is: A strict statistical calculation heavily used in options pricing (often referred to as HV or Realized Volatility). It calculates the standard deviation of logarithmic returns over a period, and annualizes it (multiplying by √252 trading days).
Why it matters: It gives you the "true" statistical variance of the asset. A rising Fuchsia line means the market is becoming highly chaotic and unpredictable, while a falling line means the market is returning to a stable, directional grind.
By layering all three of these metrics on one panel, you can easily spot when a market has compressed to zero (all lines dropping near the Zero Base) right before a massive trend erupts!

## Source Code

````pine
//@version=6
indicator("Greymyst Advanced Volatility", shorttitle="GM_Vol", format=format.price, precision=2)

grp_vol = "Volatility Settings"
atrLen = input.int(14, "ATR Length", group=grp_vol)
bbLen = input.int(20, "BB Length", group=grp_vol)
bbMult = input.float(2.0, "BB Multiplier", group=grp_vol)

// 1. Normalized ATR
atr = ta.atr(atrLen)
natr = (atr / close) * 100

// 2. BB Width (Squeeze proxy)
[middle, upper, lower] = ta.bb(close, bbLen, bbMult)
bbWidth = (upper - lower) / middle * 100

// 3. Historical Volatility
hvLen = input.int(20, "HV Length", group=grp_vol)
hv = ta.stdev(math.log(close / close[1]), hvLen) * math.sqrt(252) * 100

// Plotting
plot(natr, "Normalized ATR (%)", color=color.new(color.blue, 0), linewidth=2)
plot(bbWidth, "BB Width (%)", color=color.new(color.orange, 0), linewidth=2)
plot(hv, "Historical Volatility (%)", color=color.new(color.fuchsia, 0), linewidth=2)

hline(0, "Zero Base", color=color.new(color.gray, 50))
````
