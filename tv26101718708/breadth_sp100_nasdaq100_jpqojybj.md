# Breadth S&P100 / Nasdaq100

- url: https://www.tradingview.com/script/JPQOJYBJ-Breadth-S-P100-Nasdaq100/
- type: indicator
- pine_id: PUB;3f8b0e1a3e854de6832b5eb028139242
- version: 1.0

## Description

Breadth S&P100 / Nasdaq100

The indicator calculates the ratio between the two widths (S1F1/N1F1)
The dotted line at 1.00 is the equilibrium level
Above 1.00 = Stronger S&P 100 (Risk in the S&P)
Below 1.00 = Stronger Nasdaq 100

The indicator is simply the ratio S1FI ÷ NDFI, where:

S1FI = % of S&P 100 stocks above the 50-day moving average (MA50)
NDFI = % of Nasdaq 100 stocks above the MA50

Interpretation:

Above 1.00 → market moving towards value (S&P stronger)
Below 1.00 → market moving towards technology (Nasdaq stronger)

## Source Code

````pine
//@version=5
indicator("Breadth S&P100 / Nasdaq100", overlay=false)

s1fi = request.security("S1FI", timeframe.period, close)
ndfi = request.security("NDFI", timeframe.period, close)

ratio = s1fi / ndfi

plot(ratio, color=color.purple)
hline(1.0, color=color.white, linestyle=hline.style_dotted)
````
