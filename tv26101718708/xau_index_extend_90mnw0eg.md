# XAU Index Extend

- url: https://www.tradingview.com/script/90MNw0EG/
- type: indicator
- pine_id: PUB;b914982b970b47ba8d3298290f42017b
- version: 2.0

## Description

XAU Composite Index is a custom multi-factor indicator designed to analyze the broader market environment for XAUUSD.

The indicator combines gold price behavior with several related macro and risk-market inputs such as DXY, US500, USOIL, US10Y and inflation-related factors. These inputs are transformed into a composite score to help visualize whether the current gold environment is bullish, bearish, sideways, or conflicting.

Main features:
- Composite XAU market index
- Bullish, bearish, sideways and conflict regime detection
- Background regime zones directly on the chart
- Histogram panel for market bias visualization
- Optional alert conditions for bullish, bearish and conflict signals
- Designed for multi-factor gold market analysis

Color interpretation:
- Green: bullish gold bias
- Red: bearish gold bias
- Blue/gray: sideways or neutral condition
- Yellow/orange: conflict, warning, or mixed market condition

This indicator is not a standalone buy or sell system. It should be used together with price action, market structure, support and resistance, trend analysis, and proper risk management.

The purpose of this tool is to help traders understand the broader environment around gold, not to guarantee trading outcomes.

For educational and analytical purposes only. Not financial advice.

## Source Code

````pine
//@version=6
indicator("(Deprecated) XAU Index Extend", overlay=true)

plot(na, title="(Deprecated) XAU Index Extend")
````
