# Relative Strength vs TOPIX

- url: https://www.tradingview.com/script/tJPewucB-Relative-Strength-vs-TOPIX/
- type: indicator
- pine_id: PUB;a4b6b30710394f4186480410b02afc30
- version: 1.0

## Description

# Relative Strength vs TOPIX

This indicator measures a stock's performance relative to the TOPIX Index by plotting the ratio of the stock's closing price to the TOPIX closing price.

The indicator helps investors identify whether a stock is outperforming or underperforming the broader Japanese equity market. A rising line indicates the stock is gaining strength relative to TOPIX, while a falling line suggests relative weakness.

### How to Use

* Rising Relative Strength Line = Outperformance vs TOPIX
* Falling Relative Strength Line = Underperformance vs TOPIX
* New highs in Relative Strength often signal improving investor sentiment before earnings revisions or estimate upgrades.
* Divergences between price and relative strength can help identify potential leadership changes within a sector.

### Best Applications

* Japanese consumer and retail stocks
* Sector rotation analysis
* Identifying market leaders and laggards
* Screening for stocks attracting institutional buying

### Formula

Relative Strength = Stock Close ÷ TOPIX Close

This indicator automatically updates when the chart symbol changes, making it ideal for comparing multiple stocks against the Japanese market benchmark.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © oshiosk

//@version=6
indicator("Relative Strength vs TOPIX", overlay=false)

topix = request.security("TSE_DLY:TOPIX", timeframe.period, close)

rs = close / topix

plot(rs, title="Stock / TOPIX", linewidth=2)
````
