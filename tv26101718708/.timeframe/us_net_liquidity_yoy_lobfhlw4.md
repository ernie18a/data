# US Net Liquidity YoY

- url: https://www.tradingview.com/script/LObfHlw4/
- type: indicator
- pine_id: PUB;597dc6d9441a4e26adecc1e1d6b37fa1
- version: 1.0

## Description

US Net Liquidity (YoY)
The year-over-year (YoY) analysis of US net liquidity reveals whether market liquidity conditions have improved or deteriorated compared to the same time last year.

The following parameters are used for the calculation:
1. Fed Balance Sheet	FRED:WALCL
(Total assets of the Fed)

2. Treasury General Account	FRED:WTREGEN
(Funds held by the US Treasury at the Fed)

3. Reverse Repo	FRED:RRPONTSYD
(Funds parked at the Fed via reverse repos)

WALCL and WTREGEN are published weekly, whereas RRPONTSYD is reported daily. The data comes from the Fed (or, in the case of RRP, the New York Fed).

The calculation formula is:
Net Liquidity = Fed Balance Sheet − TGA − RRP
netLiquidityYoY = (netLiquidity / netLiquidity[52] - 1) * 100

A typical favorable environment for the US stock market is:
Net Liquidity ↑ → S&P 500 ↑

## Source Code

````pine
//@version=6
indicator("US Net Liquidity YoY", shorttitle="Net Liquidity YoY", overlay=false)

// Fed Balance Sheet
walcl = request.security("FRED:WALCL", "W", close)

// Treasury General Account
tga = request.security("FRED:WTREGEN", "W", close)

// Reverse Repo
rrp = request.security("FRED:RRPONTSYD", "W", close)

// Net Liquidity
netLiquidity = walcl - tga - rrp

// Net Liquidity vor ca. 1 Jahr
netLiquidityYoY = (netLiquidity / netLiquidity[52] - 1) * 100

// Darstellung
plot(netLiquidityYoY, title="Net Liquidity YoY %", linewidth=2)

hline(0, "0 %", linestyle=hline.style_dashed)
````
