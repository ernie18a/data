# Sector Rotation vs SPY - Indexed & Smoothed

- url: https://www.tradingview.com/script/vtB21SsA-Sector-Rotation-vs-SPY-Indexed-Smoothed/
- type: indicator
- pine_id: PUB;2911632e48424ef397af0ee0f92508d6
- version: 1.0

## Description

6.27.26 combines the multi sector strength vs the SPY

## Source Code

````pine
//@version=6
indicator("Sector Rotation vs SPY - Indexed & Smoothed", overlay=false)

len = input.int(20, "Smoothing length", minval=1)
lookback = input.int(252, "Index lookback bars", minval=20)

spy = request.security("AMEX:SPY", timeframe.period, close)

sectorIndex(sym) =>
    sector = request.security(sym, timeframe.period, close)
    ratio = sector / spy
    base = ratio[lookback]
    indexed = base != 0 ? (ratio / base) * 100 : na
    ta.sma(indexed, len)

plot(sectorIndex("AMEX:XLK"),  "XLK Tech", linewidth=2)
plot(sectorIndex("AMEX:XLF"),  "XLF Financials", linewidth=2)
plot(sectorIndex("AMEX:XLI"),  "XLI Industrials", linewidth=2)
plot(sectorIndex("AMEX:XLE"),  "XLE Energy", linewidth=2)
plot(sectorIndex("AMEX:XLV"),  "XLV Healthcare", linewidth=2)
plot(sectorIndex("AMEX:XLU"),  "XLU Utilities", linewidth=2)
plot(sectorIndex("AMEX:XLY"),  "XLY Discretionary", linewidth=2)
plot(sectorIndex("AMEX:XLP"),  "XLP Staples", linewidth=2)
plot(sectorIndex("AMEX:XLB"),  "XLB Materials", linewidth=2)
plot(sectorIndex("AMEX:XLRE"), "XLRE Real Estate", linewidth=2)
plot(sectorIndex("AMEX:XLC"),  "XLC Communications", linewidth=2)

hline(100, "SPY-relative baseline", linestyle=hline.style_dashed)
````
