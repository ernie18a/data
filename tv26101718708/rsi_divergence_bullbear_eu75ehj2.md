# RSI Divergence (Bull/Bear) 

- url: https://www.tradingview.com/script/eu75eHj2-RSI-Divergence-Bull-Bear/
- type: indicator
- pine_id: PUB;11366e406e8245d8b40cf466d36a74f4
- version: 2.0

## Description

[b]RSI Divergence (Bull/Bear)[/b] is an advanced momentum analysis indicator that automatically detects bullish and bearish RSI divergence between price action and the Relative Strength Index (RSI). These divergence signals can help traders identify potential market reversals, trend exhaustion, and high-probability trading opportunities across multiple financial markets.

The [b]indicator [/b]continuously analyzes swing highs and swing lows in both price and RSI, highlighting areas where momentum no longer confirms the current price movement. These conditions often appear before significant trend reversals or corrective moves.

[b]Features[/b]
• Automatic Bullish RSI Divergence Detection
• Automatic Bearish RSI Divergence Detection
• Swing High & Swing Low Analysis
• Visual Buy & Sell Signal Labels
• Divergence Confirmation Zones
• Optional RSI Sensitivity Settings
• Clean & Lightweight Chart Layout
• Multi-Timeframe Compatible
• Non-Repainting Divergence Detection
• Customizable Signal Display

[b]How It Works[/b]
The indicator monitors price swings alongside RSI momentum.
When price forms a **Lower Low** while RSI forms a **Higher Low**, a **Bullish Divergence** is detected, suggesting weakening selling pressure and a possible bullish reversal.
When price forms a **Higher High** while RSI forms a **Lower High**, a **Bearish Divergence** is detected, indicating weakening buying momentum and a potential bearish reversal Signals are displayed directly on the chart, allowing traders to quickly identify possible turning points.

[b]Signal Types[/b]

🟢 Bullish Divergence
• Price makes a Lower Low
• RSI makes a Higher Low
• Possible bullish reversal
• Momentum strengthening

🔴 Bearish Divergence
• Price makes a Higher High
• RSI makes a Lower High
• Possible bearish reversal
• Momentum weakening

[b]Best Markets[/b]
• Forex • Gold (XAUUSD) • Silver (XAGUSD)
• Crypto • Indices • Stocks • Futures

[b]Recommended Timeframes[/b]

[b]Scalping[/b] • M5 • M15

[b]Intraday[/b] • M30 • H1

[b]Swing Trading[/b] • H4 • Daily

[b]Indicator Highlights[/b]
• Automatic RSI Divergence Detection
• Early Reversal Identification
• Visual Buy & Sell Signals
• High-Probability Momentum Analysis
• Non-Repainting Logic
• Adjustable RSI Parameters
• Beginner Friendly
• Professional Trading Tool
• Works in Trending and Ranging Markets

[b]Suggested Trading Workflow[/b]
1. Identify the overall market trend.
2. Wait for a Bullish or Bearish RSI Divergence signal.
3. Confirm the setup using market structure, support/resistance, or candlestick confirmation.
4. Enter the trade with proper risk management and position sizing.

[b]Notes[/b]
This indicator is designed to assist traders in identifying potential momentum shifts through RSI divergence analysis. It should be used alongside market structure, price action, and sound risk management principles. Like all technical analysis tools, it does not predict future price movements or guarantee profitable trades.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("RSI Divergence (Bull/Bear)", overlay=true, max_boxes_count=200)

// ───── Inputs ─────
swingLen   = input.int(5, "Swing Length", minval=2)
zoneExtend = input.int(25, "Zone Extension")
rsiLen     = input.int(14, "RSI Length")

// ───── RSI ─────
rsi = ta.rsi(close, rsiLen)

// ───── Swings ─────
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

// Store last swings
var float prevHigh = na
var float prevLow  = na
var float prevRsiH = na
var float prevRsiL = na

// Update swing highs
if not na(swingHigh)
    rsiAtHigh = rsi[swingLen]
    
    // Bearish Divergence: price higher high, RSI lower high
    bearDiv = not na(prevHigh) and swingHigh > prevHigh and rsiAtHigh < prevRsiH
    
    if bearDiv
        box.new(bar_index, high, bar_index + zoneExtend, swingHigh,
         bgcolor=color.new(color.red, 85), border_color=color.red)
        
        label.new(bar_index, high, "Bear Div", style=label.style_label_down, color=color.red)

    prevHigh := swingHigh
    prevRsiH := rsiAtHigh

// Update swing lows
if not na(swingLow)
    rsiAtLow = rsi[swingLen]
    
    // Bullish Divergence: price lower low, RSI higher low
    bullDiv = not na(prevLow) and swingLow < prevLow and rsiAtLow > prevRsiL
    
    if bullDiv
        box.new(bar_index, swingLow, bar_index + zoneExtend, low,
         bgcolor=color.new(color.green, 85), border_color=color.green)

        label.new(bar_index, low, "Bull Div", style=label.style_label_up, color=color.green)

    prevLow := swingLow
    prevRsiL := rsiAtLow

// ───── Alerts ─────
alertcondition(true, "RSI Divergence Alert", "RSI Bull/Bear Divergence Detected")
````
