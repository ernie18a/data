# Volatility Speed Analyzer

- url: https://www.tradingview.com/script/4hyaFXCx/
- type: indicator
- pine_id: PUB;1667b09778ff4bd2b9208d127d648dba
- version: 1.0

## Description

# Volatility Speed Analyzer

Volatility Speed Analyzer measures how aggressively a stock, cryptocurrency, or financial instrument moves by analyzing its ATR percentage over the last 1 year.

Instead of focusing on price alone, the indicator evaluates relative volatility using:

ATR % = ATR / Price × 100

This allows traders to quickly identify whether a market behaves as:

• SLOW
• MEDIUM
• FAST
• EXTREME

The classification is displayed in a clean table along with volatility conditions and market type.

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

• 1-Year volatility analysis
• ATR % normalization
• Automatic market speed classification
• Professional volatility table
• Works on stocks, crypto, forex, and indices
• Useful for selecting proper strategy settings and risk profiles

━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━

Slow markets:
• Better for trend-following systems
• Higher ATR multipliers may work better

Fast markets:
• Better for momentum or breakout trading
• Lower ATR multipliers may improve responsiveness

Extreme markets:
• Higher volatility and risk
• Increased probability of sharp reversals and fake breakouts
[url=https://www.tradingview.com/x/cU0Nqufi/]https://www.tradingview.com/x/cU0Nqufi/[/url]

━━━━━━━━━━━━━━━━━━
INTERPRETATION
━━━━━━━━━━━━━━━━━━

ATR % < 2      → Slow
ATR % 2 - 4    → Medium
ATR % 4 - 7    → Fast
ATR % > 7      → Extreme

━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━

This indicator does not generate buy or sell signals.

Its purpose is to help traders understand market behavior, volatility regime, and strategy suitability.

## Source Code

````pine
//@version=5
indicator("Volatility Speed Analyzer", overlay=true)

atrLength = input.int(14, title="ATR Length")
lookbackPeriod = input.int(252, title="Lookback Period")

atrValue = ta.atr(atrLength)

atrPercent = (atrValue / close) * 100

avgAtrPercent = ta.sma(atrPercent, lookbackPeriod)

string speedLabel = ""
string marketCondition = ""

color speedColor = color.gray

if avgAtrPercent < 2
    speedLabel := "SLOW"
    marketCondition := "Calm Trend"
    speedColor := color.blue

else if avgAtrPercent >= 2 and avgAtrPercent < 4
    speedLabel := "MEDIUM"
    marketCondition := "Balanced"
    speedColor := color.orange

else if avgAtrPercent >= 4 and avgAtrPercent < 7
    speedLabel := "FAST"
    marketCondition := "Aggressive"
    speedColor := color.green

else
    speedLabel := "EXTREME"
    marketCondition := "Speculative"
    speedColor := color.red

var table infoTable = table.new(position.top_right, 2, 5, border_width=1)

if barstate.islast

    table.cell(infoTable, 0, 0, "METRIC", bgcolor=color.black, text_color=color.white)
    table.cell(infoTable, 1, 0, "VALUE", bgcolor=color.black, text_color=color.white)

    table.cell(infoTable, 0, 1, "ATR %")
    table.cell(infoTable, 1, 1, str.tostring(avgAtrPercent, "#.##") + "%")

    table.cell(infoTable, 0, 2, "SPEED")
    table.cell(infoTable, 1, 2, speedLabel, bgcolor=speedColor, text_color=color.white)

    table.cell(infoTable, 0, 3, "VOLATILITY")

    table.cell(
         infoTable,
         1,
         3,
         avgAtrPercent < 2 ? "Low" :
         avgAtrPercent < 4 ? "Normal" :
         avgAtrPercent < 7 ? "High" :
         "Extreme"
     )

    table.cell(infoTable, 0, 4, "MARKET TYPE")
    table.cell(infoTable, 1, 4, marketCondition)

plot(avgAtrPercent, color=speedColor, linewidth=2, title="ATR %")

hline(2, "Slow Threshold")
hline(4, "Medium Threshold")
hline(7, "Fast Threshold")
````
