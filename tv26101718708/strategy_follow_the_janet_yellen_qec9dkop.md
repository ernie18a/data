# [STRATEGY] Follow the Janet Yellen

- url: https://www.tradingview.com/script/qEc9DKoP-STRATEGY-Follow-the-Janet-Yellen/
- type: strategy
- pine_id: PUB;1807
- version: -1.0

## Description

In the era of central bank's helicopter money, the market will always be skyrocketing up and up given enough time. 

[b]What's the strategy to profit from indices? [/b]
Only short the market when its in a state of euphoria /irrational exuberance bubble, or sell when it is confirmed (20% drawdown). Otherwise, you really have no reason not to long at every chance. 

[b]Conclusion: [/b]
Follow the printing press like a sheep.

## Source Code

````pine
//@version=2
strategy("Follow the Janet Yellen", overlay=true)

// Input
close_price = close[0]
len = input(defval=100, minval=1, title="Linear Regression length")

linear_reg = linreg(close_price, len, 0)
linear_reg_prev = linreg(close[1], len, 0)
slope = ((linear_reg - linear_reg_prev) / interval)

plotarrow(slope, colorup=teal, colordown=orange, transp=40)
plot(linear_reg, color = red, title = "Linear Regression Curve", style = line, linewidth = 2)

if (slope < -10)
    strategy.entry("Short", strategy.short)
if (slope > 75)
    strategy.entry("Madness", strategy.short)
if (slope > 5 and slope < 20) 
    strategy.entry("Long", strategy.long)
````
