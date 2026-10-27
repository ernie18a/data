# Closewinter Volume Value

- url: https://www.tradingview.com/script/Q4GEVOht-Closewinter-Volume-Value/
- type: indicator
- pine_id: PUB;ea3ef6dd10c649fb8b8bf77f97935ac1
- version: 1.0

## Description

The Illusion of Token Count vs. Actual Capital Volume

To put it simply, the critical limitation of traditional volume indicators is that they fail to account for price changes and only display the absolute number of tokens traded.

For instance, buying $100 worth of an asset at $1 generates 100 tokens. However, buying $100 worth at $10 generates only 10 tokens. Even though the exact same amount of capital was deployed, the number of filled tokens varies depending on the price.

The inherent flaw is that standard charts do not reflect this disconnect—the fact that actual capital volume and token count are not strictly proportional. This is precisely why you must look at Traded Value (or Fiat Volume / Notional Volume) rather than just raw trading volume.

## Source Code

````pine
//@version=6
indicator("CW 거래대금 (USD Value)", overlay=false)
plot(volume * close, color=color.teal, style=plot.style_columns)
````
