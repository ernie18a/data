# Fair Value Gap (FVG) Supply & Demand Zones [JPT]

- url: https://www.tradingview.com/script/otawhXzH-Fair-Value-Gap-FVG-Supply-Demand-Zones-JPT/
- type: indicator
- pine_id: PUB;c90b1deb71bc481393653ce298fcca0c
- version: 1.0

## Description

🔷 [b]OVERVIEW[/b]

[b]Fair Value Gap (FVG) Supply & Demand Zones [JPT][/b] is a market structure indicator that automatically detects Fair Value Gaps (FVGs) together with Supply and Demand Zones to help traders identify potential areas where price may react.

The indicator continuously scans price action for imbalance formations and plots dynamic zones directly on the chart. When price revisits these areas, the indicator highlights potential reaction zones while displaying [b]LONG[/b] and [b]SHORT[/b] signals based on its programmed logic.

Designed with a clean visual layout, the indicator helps traders monitor market structure without manually drawing imbalance or supply and demand zones.

🔷 [b]HOW IT WORKS[/b]

The indicator continuously analyzes price action to identify market imbalances and institutional trading zones.

When qualifying conditions are met, it automatically:

• Detects Bullish Fair Value Gaps (FVG)

• Detects Bearish Fair Value Gaps (FVG)

• Identifies Demand Zones

• Identifies Supply Zones

• Tracks active zones until they are mitigated

• Displays LONG and SHORT signals according to the indicator's programmed conditions

• Updates zones dynamically as new market structure develops

This provides traders with a structured view of areas where price may revisit before continuing or changing direction.

📈 [b]Bullish Demand Setup[/b]
1. A bullish imbalance creates a Fair Value Gap.
2. A Demand Zone is established.
3. Price retraces into the zone.
4. The indicator highlights the area and may display a [b]LONG[/b] signal when its programmed conditions are satisfied.

📉 [b]Bearish Supply Setup[/b]

1. A bearish imbalance creates a Fair Value Gap.
2. A Supply Zone is established.
3. Price revisits the supply area.
4. The indicator highlights the zone and may display a [b]SHORT[/b] signal when its programmed conditions are satisfied.

📊 [b]Dynamic Market Structure[/b]

Throughout changing market conditions, the indicator continuously updates:

• Bullish Fair Value Gaps

• Bearish Fair Value Gaps

• Supply Zones

• Demand Zones

• LONG Signals

• SHORT Signals

This helps traders monitor developing market structure in real time.

🔷 [b]VISUAL FEATURES[/b]

• Automatic Fair Value Gap Detection

• Automatic Supply Zone Detection

• Automatic Demand Zone Detection

• Dynamic Zone Updates

• LONG & SHORT Signal Labels

• Historical Zone Display

• Customizable Colors

• Clean Chart Layout

• Real-Time Market Structure Updates

• Confirmed Calculation Logic

🔷[b] INPUTS[/b]

The indicator includes customizable settings for:

• Fair Value Gap Detection Length

• Supply & Demand Sensitivity

• Zone Extension

• Maximum Number of Zones

• Show LONG Signals

• Show SHORT Signals

• Color Settings

• Historical Zone Display

🔷 [b]USAGE[/b]

A common workflow is:

• Monitor newly created Fair Value Gaps.

• Observe active Supply and Demand Zones.

• Watch for price revisiting these areas.

• Use LONG or SHORT signals together with your own market structure and confirmation techniques.

• Apply appropriate risk management before entering any trade.

The indicator is intended to support technical analysis and can be combined with additional tools such as trend analysis, support and resistance, volume, or candlestick confirmation.

🔷[b] MARKETS[/b]

The indicator can be applied to:

• Forex

• Gold (XAUUSD)

• Silver

• Cryptocurrency

• Stocks

• Indices

• Commodities

It is designed to adapt to multiple markets and can be used for intraday, swing, or longer-term analysis.

🔷 [b]IDEAL TIMEFRAMES[/b]

Recommended timeframes include:

• 15 Minute

• 30 Minute

• 1 Hour

• 2 Hour

• 4 Hour

• Daily

Higher timeframes generally produce more significant market structure zones, while lower timeframes provide more frequent trading opportunities.

🔷 [b]BEST PRACTICES[/b]

Many traders combine this indicator with:

• Market Structure Analysis

• Trend Direction

• Support & Resistance

• Liquidity Analysis

• Volume

• Candlestick Confirmation

• Risk Management Rules

Using multiple forms of analysis can help provide additional context when evaluating potential trading opportunities.

🔷 [b]DISCLAIMER[/b]

This indicator is designed as a technical analysis tool and does not predict future market movements. Fair Value Gaps, Supply Zones, Demand Zones, and LONG or SHORT signals are generated according to the indicator's programmed logic and should be used alongside your own market analysis and risk management. No indicator can guarantee profitable trading results.

[b]Developed by Jos-ProTrader (JPT)[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Fair Value Gap (FVG) Supply & Demand Zones [JPT]", overlay=true)

// Inputs
extendBars = input.int(30, "Zone Extension", minval=5)
showFVG = input.bool(true, "Show Fair Value Gaps")
showSD = input.bool(true, "Show Supply/Demand")
deleteFilled = input.bool(false, "Delete Filled Zones")

// Colors
bullColor = color.new(#000000, 85)
bearColor = color.new(#000000, 85)
demandColor = color.new(#04ff36, 80)
supplyColor = color.new(#ff0000, 80)

// =========================
// Fair Value Gaps
// =========================
bullFVG = low > high[2]
bearFVG = high < low[2]

// Draw Bullish FVG
if showFVG and bullFVG
    box.new(
         bar_index-2,
         low,
         bar_index+extendBars,
         high[2],
         bgcolor=bullColor,
         border_color=color.rgb(93, 93, 93))

// Draw Bearish FVG
if showFVG and bearFVG
    box.new(
         bar_index-2,
         low[2],
         bar_index+extendBars,
         high,
         bgcolor=bearColor,
         border_color=color.rgb(97, 93, 93))

// =========================
// Demand & Supply
// =========================

// Bullish Engulfing
bullDemand =
 close > open and
 close[1] < open[1] and
 close > high[1]

// Bearish Engulfing
bearSupply =
 close < open and
 close[1] > open[1] and
 close < low[1]

// Demand Zone
if showSD and bullDemand
    box.new(
         bar_index-1,
         high[1],
         bar_index+extendBars,
         low[1],
         bgcolor=demandColor,
         border_color=color.rgb(0, 230, 58))


// Supply Zone
if showSD and bearSupply
    box.new(
         bar_index-1,
         high[1],
         bar_index+extendBars,
         low[1],
         bgcolor=supplyColor,
         border_color=color.rgb(241, 58, 58))

// Buy Signal
plotshape(bullDemand,
     style=shape.labelup,
     color=color.lime,
     location=location.belowbar,
     text="LONG")

// Sell Signal
plotshape(bearSupply,
     style=shape.labeldown,
     color=color.rgb(255, 42, 42),
     location=location.abovebar,
     text="SHORT")

// Alerts
alertcondition(bullFVG, "Bullish FVG", "Bullish Fair Value Gap")
alertcondition(bearFVG, "Bearish FVG", "Bearish Fair Value Gap")
alertcondition(bullDemand, "Demand Zone", "Demand Zone Created")
alertcondition(bearSupply, "Supply Zone", "Supply Zone Created")
````
