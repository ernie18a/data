# SMA Strategy [MK]

- url: https://www.tradingview.com/script/elpZekZw-SMA-Strategy-MK/
- type: strategy
- pine_id: PUB;bb3b8848d8e54693b62f0ed3b427fdfa
- version: 2.0

## Description

[b]Overview[/b]

This strategy is a momentum-based trend-following system designed to capture sustained market moves while minimizing "whipsaws" often found in sideways markets. It utilizes a dual-SMA filter for trend direction, a precise price-crossover trigger for entry, and the Average Directional Index (ADX) to gauge market strength.

[b]How It Works[/b]
The strategy follows a strict "Trend + Momentum + Strength" hierarchy:

1. Trend Identification (The Filter) The script uses a Fast SMA (20) and a Slow SMA (50).

Long Bias: SMA-20 > SMA-50.

Short Bias: SMA-20 < SMA-50.

2. Precise Entry (The Trigger) Unlike strategies that enter simply because the price is above a line, this script requires a Price Crossover.

Long Entry: Price must actively cross from below to above the SMA-20.

Short Entry: Price must actively cross from above to below the SMA-20.

3. Trend Strength (The ADX Gatekeeper) To solve the problem of sideways markets where moving averages run parallel, we’ve integrated the ADX (Average Directional Index). The strategy will only trigger a trade if the ADX is above a user-defined threshold (default is 25), ensuring we only enter when the market is trending.

4. RSI Safety Filter To prevent "buying the top" or "selling the bottom," the RSI checks for overextended conditions. It prevents long entries if the RSI is already overbought and short entries if it is oversold.

Exit Logic
The strategy features three layers of protection:

Trend Reversal Exit: Closes the position if the price crosses back over the SMA-20 while the macro trend (SMA-20/SMA-50) has flipped.

Fixed Take Profit: A percentage-based target to lock in gains during sharp moves.

Fixed Stop Loss: A percentage-based safety net to protect capital.

Key Features
Directional Selector: Choose between "Long Only," "Short Only," or "Both."

Visual Feedback: Background colors highlight "Trending" (Green) vs "Sideways" (Red) market regimes.

Fully Customizable: All lengths and thresholds for SMAs, RSI, and ADX can be adjusted to fit different assets and timeframes.

Instructions for Use
Timeframe: This strategy is optimized for trending timeframes such as the 1-Hour (1H), 4-Hour (4H), or Daily (D). Using it on very low timeframes (1-minute or 5-minute) may increase the number of false signals due to market noise.

Asset Classes: Best suited for high-volume assets like Major Forex Pairs, Large-Cap Stocks, and Blue-Chip Cryptocurrencies.

Parameter Tuning: Use the "Strategy Tester" to find the ideal ADX Threshold for your specific asset. Volatile assets usually require a higher ADX (30+) to filter out fake breakouts.

Disclaimer
Financial Risk Warning: The script provided is for educational and informational purposes only. Trading involves significant risk, and there is always the potential for loss. Past performance, whether simulated or real, is not a guarantee of future results.

The author of this script is not a financial advisor. This indicator is not a signal service or a recommendation to buy or sell any security. Always perform your own due diligence and test any strategy thoroughly on a demo account before risking live capital. By using this script, you acknowledge that you are solely responsible for your trading decisions and any resulting financial outcomes.

## Source Code

````pine
//@version=6
strategy("SMA Strategy [MK]", overlay=true, initial_capital=1000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// https://gemini.google.com/app/9fdaad123f4e5cd7

// --- User Selections ---
tradeDirection = input.string("Both", title="Strategy Direction", options=["Long Only", "Short Only", "Both"])
userTimezone   = input.string("UTC+5:30", title="Timezone (e.g. UTC-5 or UTC+5:30)")

// --- Auto-Close Settings ---
enableExit     = input.bool(true, title="Enable Intraday Auto-Close")
exitTime       = input.string("1515-1530", title="Exit Time Range (HHMM-HHMM)")

// --- Technical Inputs ---
smaFastLen = input.int(20, title="Fast SMA (20)")
smaSlowLen = input.int(50, title="Slow SMA (50)")
rsiLen     = input.int(14, title="RSI Length")
rsiUpper   = input.int(70, title="RSI Max for Long")
rsiLower   = input.int(30, title="RSI Min for Short")

// --- Calculations ---
sma20 = ta.sma(close, smaFastLen)
sma50 = ta.sma(close, smaSlowLen)
rsi   = ta.rsi(close, rsiLen)

// --- DIRECTIONAL FILTERS ---
canLong  = tradeDirection == "Long Only" or tradeDirection == "Both"
canShort = tradeDirection == "Short Only" or tradeDirection == "Both"

// --- GAP-RESISTANT CROSSOVER LOGIC ---
// Captures both standard crossovers and "jumps" over the SMA
isBullishJump = (close > sma20) and (close[1] <= sma20)
isBearishJump = (close < sma20) and (close[1] >= sma20)

// --- STRATEGY LOGIC ---
// Entry logic now only depends on Price/SMA relationship and RSI
longEntryCondition  = canLong and (sma20 > sma50) and isBullishJump and (rsi < rsiUpper)
shortEntryCondition = canShort and (sma20 < sma50) and isBearishJump and (rsi > rsiLower)

// --- EXECUTION ---
if (longEntryCondition)
    strategy.entry("Long", strategy.long)

if (shortEntryCondition)
    strategy.entry("Short", strategy.short)

// --- RISK & EXIT ---
if (strategy.position_size != 0)
    // Percentage Stops/Targets
    float stopMult = strategy.position_size > 0 ? (1.0 - 0.02) : (1.0 + 0.02)
    float tpMult   = strategy.position_size > 0 ? (1.0 + 0.05) : (1.0 - 0.05)
    strategy.exit("Risk", stop=strategy.position_avg_price * stopMult, limit=strategy.position_avg_price * tpMult)
    
    // Trend-based Exits
    if (strategy.position_size > 0 and (sma20 < sma50) and isBearishJump)
        strategy.close("Long", comment="Trend Exit")
    if (strategy.position_size < 0 and (sma20 > sma50) and isBullishJump)
        strategy.close("Short", comment="Trend Exit")

// --- INTRADAY AUTO-CLOSE ---
bool inExitWindow = not na(time(timeframe.period, exitTime, userTimezone))
if (enableExit and inExitWindow)
    strategy.close_all(comment="EOD Auto-Close")

// --- VISUALS ---
plot(sma20, color=color.blue, title="SMA 20")
plot(sma50, color=color.orange, title="SMA 50", linewidth=2)

plotshape(longEntryCondition, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Long Entry Signal")
plotshape(shortEntryCondition, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Short Entry Signal")
````
