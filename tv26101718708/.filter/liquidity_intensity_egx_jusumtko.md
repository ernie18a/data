# Liquidity Intensity EGX

- url: https://www.tradingview.com/script/jusUMTko-Liquidity-Intensity-EGX/
- type: indicator
- pine_id: PUB;c39588b4a2b348c2af1ae8ef97927654
- version: 1.0

## Description

Why This Indicator Matters:
Traditional volume indicators fail on EGX because:

A 50M EGP day is massive for a 500M market cap stock (10% ratio)
A 50M EGP day is tiny for a 50B market cap stock (0.1% ratio)
Liquidity Intensity EGX solves this by normalizing for market cap, giving you an apples-to-apples comparison across the entire exchange.

Created for the Egyptian Exchange (EGX). Works best with EGX-listed stocks, but applicable to any exchange with market cap data.


Overview
Liquidity Intensity EGX is a custom indicator designed specifically for the Egyptian Exchange (EGX) to measure and visualize stock liquidity intensity. Unlike generic volume indicators, this tool calculates the Liquidity Ratio (%) — the daily trading value relative to the company's market capitalization — giving you a normalized view of liquidity that works across all market cap sizes.


How It Works
The indicator combines three key metrics:

Metric Formula Purpose
Liquidity Ratio (%) (Volume MA × Close) / Market Cap × 100 Normalized liquidity measure
Trading Value (EGP) 21-day SMA Volume × Close Average daily turnover in EGP
Volume Spike Today's Volume > 2× Volume MA Identifies unusual activity


📋 Quick Reference Card
🟢 > 0.50% = High Intensity → Trade freely
🔵 0.10-0.30% = Healthy/Good → Optimal conditions
🟠 0.03-0.09% = Moderate → Size carefully
🔴 < 0.01% = Low/Stagnant → Avoid or limit orders
🟡 Yellow BG = Volume Spike → Momentum alert


Practical Example: Trading AMOC
Scenario
You're analysing AMOC (Alexandria Mineral Oils Company) on the daily timeframe:

Current Readings:

Liquidity Ratio: 1.80%
Line Colour: 🟢 Green (High Intensity)
Background: Transparent (no volume spike today)
Avg Trading Value: 95M EGP
Market Cap: ~5.2B EGP
Interpretation
🟢 Green Line (1.80%) — AMOC is experiencing exceptional liquidity (more than 3× the "High Intensity" threshold).
This indicates strong institutional or retail interest.

Transparent Background: While the liquidity ratio is excellent, today's volume is actually below average (95M vs 191M EGP average).
This suggests the high ratio is sustained by the stock's smaller market cap, not an explosive volume day.

Trading Decision The green signal confirms AMOC has sufficient liquidity for confident position sizing.
However, the lack of a volume spike suggests waiting for a yellow background confirmation before entering a momentum trade.

🎯 Best Practices
For Day Traders
Focus on Green + Yellow combinations for the highest probability momentum trades
Avoid Red stocks entirely, you'll face slippage and exit difficulties

For Swing Traders
Blue stocks offer the best risk/reward for multi-day holds
Use Orange stocks only for high-conviction setups with smaller position sizes

For Large Positions
Minimum Blue tier recommended for positions > 100K EGP
Orange and Red require breaking orders into smaller chunks

Market Cap Considerations
Small-Caps (< 1B EGP): Often show Green/Blue easily, verify with absolute EGP volume
Mid-Caps (1B–10B EGP): Blue/Orange range, best balance of liquidity and growth
Large-Caps (> 10B EGP): Often Orange, acceptable for stability, not momentum

🔔 Alert Conditions
The indicator includes two built-in alerts:

Alert Name Trigger Use Case
Volume Spike Detected Volume > 2× 21-day average Catch momentum early
Low Liquidity Warning Trading value drops below 5M EGP Exit illiquid positions before getting stuck

## Source Code

````pine
//@version=6
indicator("Liquidity Intensity EGX", shorttitle="Liq Intensity EGX", overlay=false, format=format.price, precision=2)

// --- Inputs ---
bool showLiqRatio = input.bool(true, "Show Liquidity Ratio (%)", tooltip="Uncheck this if the Liquidity Ratio (0-1%) squashes the Trading Value (Millions) on the same scale.")
int volLengthInput = input.int(21, "Volume MA Length", minval=1, tooltip="The period used to calculate the Volume Moving Average.")
int valueMaLengthInput = input.int(21, "Trading Value MA Length", minval=1, tooltip="The period used to calculate the Moving Average of the Trading Value.")
color valueMaColorInput = input.color(color.blue, "Trading Value MA Color")
string fiscalPeriodInput = input.string("FQ", "Fiscal Period for Market Cap", options=["FQ", "FH", "FY", "TTM"], tooltip="The reporting period for Total Shares Outstanding.")
float spikeMult = input.float(2.0, "Volume Spike Multiplier", minval=1.1, step=0.1, tooltip="Highlight bars where volume is X times the average.")

// Table Customization
string tablePosInput = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
string tableSizeInput = input.string(size.small, "Table Text Size", options=[size.tiny, size.small, size.normal, size.large, size.huge])

// --- Helper Functions ---
formatCompact(float val) =>
    float absVal = math.abs(val)
    string sign = val < 0 ? "-" : ""
    string result = ""
    if absVal >= 1e12
        result := str.format("{0,number,#.##}T", absVal / 1e12)
    else if absVal >= 1e9
        result := str.format("{0,number,#.##}B", absVal / 1e9)
    else if absVal >= 1e6
        result := str.format("{0,number,#.##}M", absVal / 1e6)
    else if absVal >= 1e3
        result := str.format("{0,number,#.##}K", absVal / 1e3)
    else
        result := str.format("{0,number,#.##}", absVal)
    sign + result

// --- Logic ---
// 1. Calculate the Volume MA and Trading Value (EGP)
float volMa = ta.sma(volume, volLengthInput)
float tradingValue = volMa * close
float currentTradingValueEGP = volume * close

// 2. Calculate Trading Value MA
float tradingValueMa = ta.sma(tradingValue, valueMaLengthInput)

// 3. Fetch Market Cap Components
float sharesOutstanding = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", fiscalPeriodInput, barmerge.gaps_off, true)
float mktCap = sharesOutstanding * close

// 4. Calculate Liquidity Ratio (%) - NOW USES ACTUAL DAILY TRADING VALUE
float liqRatio = (not na(mktCap) and mktCap > 0) ? (currentTradingValueEGP / mktCap) * 100 : na

// 5. Volume Spike Detection
bool isSpike = volume > volMa * spikeMult

// --- EGX Liquidity Tier Colors (Ratio-Based) ---
color egxLiqColor = liqRatio > 0.50 ? color.green : 
                   liqRatio >= 0.10 ? color.blue : 
                   liqRatio >= 0.03 ? color.orange : 
                   liqRatio < 0.01 ? color.red : color.gray

// --- Visualization ---
// When showLiqRatio is true, the scale is dominated by 0-1 values, squashing the Millions/Billions trading value.
// When false, the scale adjusts to the Trading Value.
plot(showLiqRatio ? liqRatio : na, "Liquidity Ratio (%)", color=egxLiqColor, linewidth=2)
plot(tradingValue, "Trading Value (EGP)", color=color.new(egxLiqColor, 80), style=plot.style_columns, display=display.all)
plot(tradingValueMa, color=valueMaColorInput, linewidth=2, title="Trading Value MA")
plot(mktCap, "Market Cap", color=color.gray, display=display.data_window)

plotshape(isSpike, "Volume Spike", shape.circle, location.bottom, color.new(color.yellow, 0), size=size.tiny)
bgcolor(isSpike ? color.new(color.yellow, 90) : na)

plot(currentTradingValueEGP, "Current Daily Trading Value", color=color.new(color.white, 20), linewidth=2, display=display.all)

// --- Table Dashboard ---
tablePos = tablePosInput == "Top Left" ? position.top_left : 
           tablePosInput == "Bottom Right" ? position.bottom_right : 
           tablePosInput == "Bottom Left" ? position.bottom_left : position.top_right

mktCapColor = mktCap >= 30000000000 ? color.green :
              mktCap >= 5000000000 ? color.yellow : color.red

var table statsTable = table.new(tablePos, 2, 6, bgcolor=color.new(color.black, 70), border_width=1, border_color=color.gray, force_overlay=true)

if barstate.islast
    table.cell(statsTable, 0, 0, "EGX Metric", text_color=color.white, text_size=tableSizeInput)
    table.cell(statsTable, 1, 0, "Value", text_color=color.white, text_size=tableSizeInput)
    table.cell(statsTable, 0, 1, "Market Cap", text_color=color.gray, text_size=tableSizeInput, text_halign=text.align_left)
    table.cell(statsTable, 1, 1, na(mktCap) ? "N/A" : formatCompact(mktCap), text_color=mktCapColor, text_size=tableSizeInput, text_halign=text.align_right)
    table.cell(statsTable, 0, 2, "Daily Trading Value", text_color=color.gray, text_size=tableSizeInput, text_halign=text.align_left)
    table.cell(statsTable, 1, 2, formatCompact(currentTradingValueEGP), text_color=color.white, text_size=tableSizeInput, text_halign=text.align_right)
    table.cell(statsTable, 0, 3, "Avg Trading Value", text_color=color.gray, text_size=tableSizeInput, text_halign=text.align_left)
    table.cell(statsTable, 1, 3, formatCompact(tradingValue), text_color=egxLiqColor, text_size=tableSizeInput, text_halign=text.align_right)
    table.cell(statsTable, 0, 4, "Liquidity %", text_color=color.gray, text_size=tableSizeInput, text_halign=text.align_left)
    table.cell(statsTable, 1, 4, str.format("{0,number,#.##}%", liqRatio), text_color=egxLiqColor, text_size=tableSizeInput, text_halign=text.align_right)
    table.cell(statsTable, 0, 5, "Spike", text_color=color.gray, text_size=tableSizeInput, text_halign=text.align_left)
    table.cell(statsTable, 1, 5, isSpike ? "Yes" : "No", text_color=isSpike ? color.yellow : color.gray, text_size=tableSizeInput, text_halign=text.align_right)

// --- Alerts ---
alertcondition(isSpike, "Volume Spike Alert", "Volume spike detected on {{ticker}}! Volume is {{volume}} which is {{spikeMult}}x the average.")
````
