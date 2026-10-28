# Hydra PVSRA

- url: https://www.tradingview.com/script/MIdBdGI4-Hydra-PVSRA/
- type: indicator
- pine_id: PUB;0c7cfe856b0d46109085b8b7696f76fe
- version: 1.0

## Description

[b]Hydra PVSRA[/b]
The Hydra PVSRA is a high-performance analysis tool designed to identify significant market participation by combining volume surges with price expansion logic. By filtering "noise" and focusing on high-interest areas, this indicator helps traders spot potential institutional "footprints" and potential trend reversals.

🚀 [b]Key Features[/b]
• [b]Dynamic Volume Spike Detection:[/b] Automatically identifies candles where volume exceeds a user-defined percentage of the recent average (default 150%).
• [b]Vector Candle Logic:[/b] Goes beyond simple volume by identifying "Vector Candles"—bars that exhibit both high volume and high price spread (volatility). This represents significant "effort" resulting in clear price displacement.
• [b]External Source Override:[/b] A powerful feature for cross-exchange analysis. You can override the local volume with a feed from another ticker (e.g., using CME Bitcoin Futures volume while trading on a spot exchange).
• [b]Price Chart Integration:[/b] Toggle the "Apply to Price Candles" option to have the detected signals color your main price chart candles automatically.
• [b]Dual Color Themes:[/b] Separate, fully customizable color sets for standard local volume and external volume feeds.
• [b]Smart Alerts:[/b] Integrated alert() functionality for both general Volume Spikes and specific Bullish/Bearish Vector Candles.

📊 [b]How it Works[/b]
1. [b]Volume Spikes[/b]
The indicator calculates a Simple Moving Average (SMA) of volume over a lookback period. If the current volume exceeds this average by your specified multiplier, it is flagged as a Spike. This highlights sudden bursts of activity.

2. [b]Vector Candles[/b]
A Vector Candle is the ultimate sign of market intent. It occurs when:
• A Volume Spike is present.
• The Price Spread (High - Low) is significantly larger than the recent average spread.
[b]Bullish Vectors[/b] suggest aggressive buying/short covering.
[b]Bearish Vectors[/b] suggest aggressive selling/long liquidation.

3. [b]External Volume Feed[/b]
Professional traders often look at high-liquidity exchanges for the "true" volume. This script allows you to view volume from a master source (like CME or Binance) while keeping your eyes on your preferred trading pair's price action.

⚙️ [b]Settings[/b]
[b]Lookback Period:[/b] Adjust the window for calculating average volume and spread (Default: 20).
[b]Volume Increase %:[/b] The sensitivity for a "spike" (Default: 150%).
[b]Vector Spread Multiplier:[/b] How much price expansion is required to upgrade a spike to a "Vector" (Default: 1.5x).
[b]External Symbol:[/b] Choose any ticker to use as your volume source.

🔔 [b]Alerts[/b]
To set up alerts, create an alert on the indicator and select "Any alert() function call". You will receive notifications for:

• Standard Volume Spikes
• Bullish Vector Candles
• Bearish Vector Candles

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © InvestiShare

//@version=6
indicator("Hydra PVSRA", shorttitle="Hydra", overlay=false)

// --- Inputs ---
groupSettings = "Volume Spike Settings"
volLength     = input.int(20, "Lookback Period", minval=1, group=groupSettings, tooltip="Number of bars used to calculate the average volume.")
volMult       = input.float(150.0, "Volume Increase %", minval=0.0, step=10.0, group=groupSettings, tooltip="Threshold percentage of the average volume to identify a spike.")

groupVector   = "Vector Candle Settings"
showVector    = input.bool(true, "Enable Vector Candle Detection", group=groupVector, tooltip="Vector candles are high-volume bars with high price spread.")
vecMult       = input.float(1.5, "Vector Spread Multiplier", minval=1.0, step=0.1, group=groupVector, tooltip="Multiplier applied to the average spread to identify a Vector candle.")

groupStyle    = "Standard Style"
spikeColor    = input.color(#5b9cf6, "Standard Spike", group=groupStyle)
bullVecColor  = input.color(#089981, "Bullish Vector", group=groupStyle)
bearVecColor  = input.color(#f23645, "Bearish Vector", group=groupStyle)
baseColor     = input.color(color.new(#787b86, 50), "Base Volume Color", group=groupStyle)

groupExternal = "External Source Override"
useExternal   = input.bool(false, "Use External Volume Feed", group=groupExternal, tooltip="Override the local volume with volume from another ticker (e.g., CME Futures).")
extSymbol     = input.symbol("CME:BTC1!", "External Ticker", group=groupExternal)
extSpikeColor = input.color(#ff9800, "External Spike", group=groupExternal)
extBullVec    = input.color(#e91e63, "External Bull Vector", group=groupExternal)
extBearVec    = input.color(#9c27b0, "External Bear Vector", group=groupExternal)

groupGeneral  = "General Configuration"
matchPrice    = input.bool(true, "Apply to Price Candles", group=groupGeneral)

// --- Calculations ---
// Fetch External Volume if enabled
extVol = request.security(extSymbol, timeframe.period, volume)
activeVol = useExternal ? extVol : volume

// Volume Spike Logic
avgVol = ta.sma(activeVol, volLength)
isVolSpike = activeVol >= avgVol * (volMult / 100.0)

// Vector Candle Logic (High Volume + High Spread)
// Note: Spread logic remains on the current chart's price action
spread = high - low
avgSpread = ta.sma(spread, volLength)
isVector = showVector and isVolSpike and spread >= avgSpread * vecMult
isBullVector = isVector and close > open
isBearVector = isVector and close <= open

// Determine Colors based on Source
finalBullVec = useExternal ? extBullVec    : bullVecColor
finalBearVec = useExternal ? extBearVec    : bearVecColor
finalSpike   = useExternal ? extSpikeColor : spikeColor

volColor = isBullVector ? finalBullVec : 
           isBearVector ? finalBearVec : 
           isVolSpike   ? finalSpike   : baseColor

// --- Visuals ---
// Plot Volume columns
plot(activeVol, "Active Volume", color=volColor, style=plot.style_columns)

// Plot average volume for reference
plot(avgVol, "Average Volume", color=color.new(chart.fg_color, 70), style=plot.style_line)

// Apply color to price bars if enabled
barcolor(matchPrice ? (isBullVector ? finalBullVec : isBearVector ? finalBearVec : isVolSpike ? finalSpike : na) : na, title="Bar Color")

// --- Alerts ---
alertTitle = useExternal ? "External " : ""
if isVector
    alert(alertTitle + "Vector Candle Detected on " + syminfo.ticker + " (" + (close > open ? "Bullish" : "Bearish") + ")", alert.freq_once_per_bar_close)
else if isVolSpike
    alert(alertTitle + "Volume Spike Detected on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
