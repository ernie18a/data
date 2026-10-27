# Mega Cap Composite: NVDA + AAPL + MSFT

- url: https://www.tradingview.com/script/jRWCbqZY-Mega-Cap-Composite-NVDA-AAPL-MSFT/
- type: indicator
- pine_id: PUB;ea672762d1974d61b0a26ec752ab10e5
- version: 1.0

## Description

s;kjdhgfqweoiuhg'oeauhg'wiPOGH
PEWARGJNA
PEKIHNP
'AWIHRG
wpijgW
PORGJO[W

## Source Code

````pine
//@version=5
indicator("Mega Cap Composite: NVDA + AAPL + MSFT", overlay=false)

// Inputs
baseSymbol1 = input.symbol("NASDAQ:NVDA", "Symbol 1")
baseSymbol2 = input.symbol("NASDAQ:AAPL", "Symbol 2")
baseSymbol3 = input.symbol("NASDAQ:MSFT", "Symbol 3")

weight1 = input.float(0.40, "NVDA Weight", step=0.05)
weight2 = input.float(0.30, "AAPL Weight", step=0.05)
weight3 = input.float(0.30, "MSFT Weight", step=0.05)

lookback = input.int(100, "Normalization Lookback")

// Get prices
s1 = request.security(baseSymbol1, timeframe.period, close)
s2 = request.security(baseSymbol2, timeframe.period, close)
s3 = request.security(baseSymbol3, timeframe.period, close)

// Normalize each stock to percentage change from lookback
n1 = ((s1 / s1[lookback]) - 1) * 100
n2 = ((s2 / s2[lookback]) - 1) * 100
n3 = ((s3 / s3[lookback]) - 1) * 100

// Composite
composite = (n1 * weight1) + (n2 * weight2) + (n3 * weight3)

// Plot
plot(composite, title="Mega Cap Composite", linewidth=2)
hline(0, "Zero Line")

// Optional individual lines
showIndividual = input.bool(false, "Show Individual Stocks")

plot(showIndividual ? n1 : na, title="NVDA Normalized")
plot(showIndividual ? n2 : na, title="AAPL Normalized")
plot(showIndividual ? n3 : na, title="MSFT Normalized")
````
