# PSP [Daye's Theory]

- url: https://www.tradingview.com/script/iGgCqhWd-PSP-Daye-s-Theory/
- type: indicator
- pine_id: PUB;415f57e8cf3745ab94a70f374fc72508
- version: 1.0

## Description

PSP (Pair Strength Projection) is a correlation and divergence indicator based on Daye's Theory, designed to identify moments when related index markets lose synchronization.

The indicator compares the candle direction of up to three selected assets and highlights chart candles whenever a divergence occurs between them.

By monitoring whether correlated markets are moving together or apart, traders can quickly spot potential liquidity events, relative strength shifts, and short-term market inefficiencies.

Features:

• Multi-Asset Correlation Analysis
• Compare Up To 3 Markets Simultaneously
• NQ vs ES Dedicated Correlation Mode
• Automatic Candle Direction Detection
• Divergence (PSP) Highlighting
• Custom Highlight Colors
• Works On Any Intraday Timeframe

Common use cases:

• NQ vs ES divergence detection
• ES vs YM confirmation analysis
• Relative strength and weakness studies
• ICT / SMT style market confirmation

## Source Code

````pine
//@version=6
indicator("PSP [Daye's Theory]", overlay=true)

// User input to choose 3 assets
asset1 = input.string("MNQ1!", title="Select Asset 1", options=["MNQ1!", "MES1!", "MYM1!", "ES1!", "NQ1!", "YM1!"])
asset2 = input.string("MES1!", title="Select Asset 2", options=["MNQ1!", "MES1!", "MYM1!", "ES1!", "NQ1!", "YM1!"])
asset3 = input.string("MYM1!", title="Select Asset 3", options=["MNQ1!", "MES1!", "MYM1!", "ES1!", "NQ1!", "YM1!"])

// Automatically select the timeframe from the first asset
asset1_timeframe = timeframe.isintraday ? timeframe.period : "D"

// Checkbox for enabling correlation check between NQ and ES
pairs_check = input.bool(false, title="Check PSP NQ & ES only")

// Declare highlight color globally
highlight_color = input.color(color.red, title="PSP Color")

// Fetch data for all assets
asset1_open = request.security(asset1, asset1_timeframe, open)
asset1_close = request.security(asset1, asset1_timeframe, close)

asset2_open = request.security(asset2, asset1_timeframe, open)
asset2_close = request.security(asset2, asset1_timeframe, close)

asset3_open = request.security(asset3, asset1_timeframe, open)
asset3_close = request.security(asset3, asset1_timeframe, close)

// Define the candle color for each asset
asset1_color = asset1_close > asset1_open ? color.green : color.red
asset2_color = asset2_close > asset2_open ? color.green : color.red
asset3_color = asset3_close > asset3_open ? color.green : color.red

// Initialize candle_diff
var bool candle_diff = false

if pairs_check
    // Only check correlation between asset1 and asset2
    candle_diff := asset1_color != asset2_color
else
    // Check correlation among all three assets
    candle_diff := asset1_color != asset2_color or asset2_color != asset3_color or asset1_color != asset3_color

// Apply the barcolor globally if the condition is met
barcolor(candle_diff ? highlight_color : na)
````
