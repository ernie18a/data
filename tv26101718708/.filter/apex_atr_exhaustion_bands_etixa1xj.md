# Apex ATR Exhaustion Bands

- url: https://www.tradingview.com/script/EtixA1xJ-Apex-ATR-Exhaustion-Bands/
- type: indicator
- pine_id: PUB;c9b4ea591d61490cbe8b0774f8b9c14b
- version: 1.0

## Description

The Concept: Visualizing Mathematical Exhaustion
Institutional algorithms don't guess where a stock is going to reverse; they calculate it based on standard deviations and Average True Range (ATR). When a stock stretches too far in either direction past its normal daily capital allocation, the algorithms stop pushing the trend and start providing liquidity for a reversion to the mean.

The Apex ATR Exhaustion Bands script takes that macro math and plots it directly onto your charts as hard, visual boundaries. It shows you the exact price levels where buyers (or sellers) run out of their normal daily fuel.

(Note: This is Part 2 of the Apex Stalker ecosystem. It is designed to be used as a visual chart overlay alongside the "Apex Stalker: RVOL & Options Sniper" dashboard).

How the Engine Works
This indicator pulls data from the Daily timeframe (1D) and projects it onto your active chart.

It takes yesterday's closing price as the "Zero Line."

It calculates the exact dollar value of the 14-Day ATR.

It projects an Upper Exhaustion Wall (Red) and a Lower Exhaustion Wall (Green) based on your custom percentage threshold.

It fills the space between to visualize the "Normal Trading Channel."

The Playbook (How to Trade It)

Bullish Exhaustion (Fading the Rip): When a stock goes parabolic and a candle physically breaks through the Upper Red Line, the buyers have burned through their normal daily capital. Do not chase calls here. Look for a bearish structural breakdown (e.g., a shooting star or 5m trendline break) and fade the move with puts or credit call spreads.

Bearish Exhaustion (Buying the Blood): When panic selling drives a stock aggressively through the Lower Green Line, the sellers have exhausted their daily range. Look for a bullish structural confirmation (e.g., a volume hammer or RSI divergence) to play the dead-cat bounce or mean-reversion snapback.

Adjusting the Threshold: Different stocks have different personalities. Use the indicator settings to set indices (SPY, QQQ) to a strict ~100% exhaustion boundary, but give high-beta momentum stocks a wider leash of ~130% to 150%.

Customization & Automated Alerts

Macro Swing Trading vs. Intraday: Use the "Show Bands On" dropdown to restrict the bands strictly to lower timeframes (keeping daily charts clean), or unlock them across all timeframes to view historical daily exhaustion levels for swing trading setups.

The Alert Engine: Create a single alert for this indicator ("Any alert() function call"), and your phone will dynamically ping you the exact microsecond a candle breaches either the Upper or Lower exhaustion boundary, prompting you to look for a reversal setup.

Disclaimer: This script is an educational tool for visualizing statistical range limits. It is not financial advice. Always do your own due diligence and wait for structural price confirmation before deploying capital.

## Source Code

````pine
//@version=6
indicator("Apex ATR Exhaustion Bands", overlay=true)

// =========================================================================
// 1. INPUTS
// =========================================================================
atrLength  = input.int(14, title="Daily ATR Length")
exhaustPct = input.float(100.0, title="Exhaustion Boundary (%)", tooltip="Set to 100% for indices, 130%-150% for high-beta tech.")

// --- NEW: Visibility Dropdown ---
visibility = input.string("Intraday Only", title="Show Bands On", options=["Intraday Only", "All Timeframes"], tooltip="Allows you to view historical daily exhaustion bands for macro swing trading.")

// =========================================================================
// 2. DATA CALCULATION (Pulling from the Daily Timeframe)
// =========================================================================
[prevClose, prevAtr] = request.security(syminfo.tickerid, "D", [close[1], ta.atr(atrLength)[1]])

// Calculate the exact dollar amount of the allowed travel
atrTravel = prevAtr * (exhaustPct / 100)

// Map the Upper and Lower limits
upperLimit = prevClose + atrTravel
lowerLimit = prevClose - atrTravel

// =========================================================================
// 3. PLOTTING THE BANDS & FILL
// =========================================================================
// Tie the visibility logic directly to your new dropdown menu
showLines = visibility == "Intraday Only" ? timeframe.isintraday : true

// Plot Yesterday's Close as the "Zero Line" (Dotted Gray)
plot(showLines ? prevClose : na, title="Previous Close", color=color.rgb(120, 120, 120, 30), linewidth=1, style=plot.style_linebr)

// Assign the plots to variables so we can fill the space between them
p_upper = plot(showLines ? upperLimit : na, title="Upper Exhaustion", color=color.rgb(244, 67, 54, 30), linewidth=2, style=plot.style_linebr)
p_lower = plot(showLines ? lowerLimit : na, title="Lower Exhaustion", color=color.rgb(76, 175, 80, 30), linewidth=2, style=plot.style_linebr)

// Fill the "Normal Trading Zone" with a very faint background color
fill(p_upper, p_lower, color=color.rgb(255, 255, 255, 95), title="Normal Daily Range")

// =========================================================================
// 4. AUTOMATED ALERT ENGINE (Boundary Breach)
// =========================================================================
hitUpper = high >= upperLimit
hitLower = low <= lowerLimit

// Only trigger alerts on live, real-time bars
if barstate.isrealtime
    if hitUpper
        alert("🔴 UPPER BOUNDARY BREACHED: " + syminfo.ticker + " has hit its ATR Exhaustion Wall. Watch for a bearish fade setup.", alert.freq_once_per_bar)
        
    if hitLower
        alert("🟢 LOWER BOUNDARY BREACHED: " + syminfo.ticker + " has hit its ATR Exhaustion Wall. Watch for a bullish bounce setup.", alert.freq_once_per_bar)
````
