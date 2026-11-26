# Maket Strat Absorption Bubbles

- url: https://www.tradingview.com/script/tk40l4Ix-Maket-Strat-Absorption-Bubbles/
- type: indicator
- pine_id: PUB;7f0951df7b2345da9f46a4e01e51ea6f
- version: 1.0

## Description

# Market Strategies Absorption Bubbles

Market Strategies Absorption Bubbles is designed to help traders identify potential absorption events where aggressive buying or selling is being absorbed by larger participants. These areas can often signal hidden liquidity, exhaustion, reversals, or important decision points within the market.

The indicator analyzes relative volume compared to historical volume activity and highlights candles where significant volume is occurring within key wick regions of the bar.

## How It Works

The script measures current volume against a normalized volume standard deviation model to identify unusually high participation.

When elevated volume is detected:

🟢 **Green Bubbles (Buying Absorption)**

* Appear in the lower wick region.
* Suggest sellers pushed price lower, but buyers absorbed the selling pressure.
* Can indicate potential support, accumulation, or reversal zones.

🔴 **Red Bubbles (Selling Absorption)**

* Appear in the upper wick region.
* Suggest buyers pushed price higher, but sellers absorbed the buying pressure.
* Can indicate potential resistance, distribution, or reversal zones.

## Bubble Strength

Bubble size increases with relative volume strength:

• Small = Elevated Volume
• Medium = Strong Volume
• Large = High Volume
• Strong = Very High Volume
• Extreme = Exceptional Volume

Larger bubbles represent greater participation and potentially more significant absorption activity.

## Heavy Volume Body Detection

The indicator also highlights candles experiencing exceptionally high volume within the candle body itself.

Bullish heavy-volume candles are colored dark green.

Bearish heavy-volume candles are colored dark red.

These candles can help traders quickly identify areas where institutional activity may be present.

## Alerts Included

✔ Buying Absorption Bubble

✔ Selling Absorption Bubble

✔ Any Absorption Bubble

Alerts trigger only on confirmed bars to reduce false signals from intrabar fluctuations.

## Best Uses

* Market Structure Analysis
* Reversal Identification
* Liquidity Sweeps
* Support & Resistance Confirmation
* Order Flow Confluence
* Auction Market Theory
* Volume-Based Trading Systems

## Market Strategies Tip

Absorption signals are most effective when combined with market structure, liquidity sweeps, VWAP, value areas, supply and demand zones, and higher timeframe directional bias. The strongest setups occur when absorption aligns with key technical levels and confirms a shift in order flow.

Built for traders who want to see where significant volume meets price rejection and where smart money may be actively defending important levels.

## Source Code

````pine
//@version=6
indicator("Maket Strat Absorption Bubbles", overlay = true)

// === Input Settings ===
showDots       = input.bool(true, "Show Bubbles?", group = "Maket Strat Absorption Bubbles")
limitFactor    = input.float(0.1, "Absorption Threshold", step = 0.1, minval = 0.1, group = "Maket Strat Absorption Bubbles")
lookbackperiod = input.int(100, "Lookback Period", group = "Maket Strat Absorption Bubbles")

// Darker, more pronounced colors
bullBubbleColor = color.rgb(0, 120, 0)
bearBubbleColor = color.rgb(150, 0, 0)

// === Core Calculations ===
volData   = volume
midPrice  = (high + low) / 2
volStDev  = ta.stdev(volData, lookbackperiod)
scaledVol = volStDev != 0 ? volData / volStDev : 0

condA = showDots and scaledVol >= limitFactor and scaledVol < limitFactor + 1
condB = showDots and scaledVol >= limitFactor + 1 and scaledVol < limitFactor + 2
condC = showDots and scaledVol >= limitFactor + 2 and scaledVol < limitFactor + 3
condD = showDots and scaledVol >= limitFactor + 3 and scaledVol < limitFactor + 6
condE = showDots and scaledVol >= limitFactor + 6

bullBar = close > open
bearBar = close < open

// Wick zones
topWick    = high
topBody    = math.max(open, close)
lowBody    = math.min(open, close)
bottomWick = low

upperZone = midPrice >= topBody and midPrice <= topWick
lowerZone = midPrice <= lowBody and midPrice >= bottomWick

validUp = upperZone
validDn = lowerZone

anyBubble = condA or condB or condC or condD or condE

buyingAbsorption  = anyBubble and validDn
sellingAbsorption = anyBubble and validUp
anyAbsorption     = anyBubble and (validUp or validDn)

// === Bubble Plots ===
// Upper wick = selling absorption
plotshape(condA and validUp ? midPrice : na, title = "Small Selling Absorption", style = shape.circle, location = location.absolute, color = bearBubbleColor, size = size.small)
plotshape(condB and validUp ? midPrice : na, title = "Medium Selling Absorption", style = shape.circle, location = location.absolute, color = bearBubbleColor, size = size.normal)
plotshape(condC and validUp ? midPrice : na, title = "Large Selling Absorption", style = shape.circle, location = location.absolute, color = bearBubbleColor, size = size.large)
plotshape(condD and validUp ? midPrice : na, title = "Strong Selling Absorption", style = shape.circle, location = location.absolute, color = bearBubbleColor, size = size.huge)
plotshape(condE and validUp ? midPrice : na, title = "Extreme Selling Absorption", style = shape.circle, location = location.absolute, color = bearBubbleColor, size = size.huge)

// Lower wick = buying absorption
plotshape(condA and validDn ? midPrice : na, title = "Small Buying Absorption", style = shape.circle, location = location.absolute, color = bullBubbleColor, size = size.small)
plotshape(condB and validDn ? midPrice : na, title = "Medium Buying Absorption", style = shape.circle, location = location.absolute, color = bullBubbleColor, size = size.normal)
plotshape(condC and validDn ? midPrice : na, title = "Large Buying Absorption", style = shape.circle, location = location.absolute, color = bullBubbleColor, size = size.large)
plotshape(condD and validDn ? midPrice : na, title = "Strong Buying Absorption", style = shape.circle, location = location.absolute, color = bullBubbleColor, size = size.huge)
plotshape(condE and validDn ? midPrice : na, title = "Extreme Buying Absorption", style = shape.circle, location = location.absolute, color = bullBubbleColor, size = size.huge)

// === Bar Coloring ===
insideBody   = midPrice > lowBody and midPrice < topBody
heavyVolBody = scaledVol > limitFactor + 2

barcolor(insideBody and heavyVolBody and bullBar ? color.rgb(0, 180, 0) : na)
barcolor(insideBody and heavyVolBody and bearBar ? color.rgb(180, 0, 0) : na)

// === Alerts ===
alertcondition(buyingAbsorption and barstate.isconfirmed,
     title = "Maket Strat Buying Absorption Bubble",
     message = "Maket Strat Absorption Bubbles: Buying absorption bubble detected. Buyers may be absorbing selling pressure.")

alertcondition(sellingAbsorption and barstate.isconfirmed,
     title = "Maket Strat Selling Absorption Bubble",
     message = "Maket Strat Absorption Bubbles: Selling absorption bubble detected. Sellers may be absorbing buying pressure.")

alertcondition(anyAbsorption and barstate.isconfirmed,
     title = "Maket Strat Absorption Bubble",
     message = "Maket Strat Absorption Bubbles: Absorption bubble detected.")
````
