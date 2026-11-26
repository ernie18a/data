# Smart Circuit Detector

- url: https://www.tradingview.com/script/xf8KcFxg-Smart-Circuit-Detector/
- type: indicator
- pine_id: PUB;459d3455d67048d1990208e176d02d84
- version: 1.0

## Description

Here is a detailed, professional, and structured description you can copy and paste directly into your TradingView publication. It highlights the problem the script solves (chart clutter) and clearly explains its features to other traders.

Title: Minimal Circuit Change Detector (5%, 10%, 20% Limits)
Description:

Tracking intraday circuit limits or major percentage milestones can easily turn your chart into a messy, unreadable cluster of repetitive labels. The Minimal Circuit Change Detector is designed to solve exactly that.

This indicator cleanly detects when an asset hits critical daily percentage moves (5%, 10%, and 20%) from the previous day's close. Instead of spamming your chart with a label on every single candle that remains at that limit, it uses a strict state-tracking engine to plot a single, distinct tag only on the exact candle where the circuit limit is newly breached.

🌟 Key Features
Anti-Clutter State Tracking: The script remembers the currently active circuit limit. If a stock rides the 5% limit for 10 consecutive candles, you will only see one label on the very first candle of that move.

Multi-Tier Circuit Detection: Automatically detects and categorizes hits into three major bands:

5% Limit: Drops a Red label from above the bar.

10% Limit: Pushes a Yellow label from below the bar.

20% Limit: Pushes an Orange label from below the bar for extreme moves.

Fractional Noise Tolerance: Markets aren't perfectly precise. The script includes a minor buffer (e.g., triggering a 5% hit between 4.8% and 5.2%) to account for decimal noise and ensure you don't miss a limit hit just because the price was off by a fraction of a cent.

Flawless Previous Close Fetching: Utilizes TradingView's request.security function with lookahead_on specifically targeting historical data (close[1]). This ensures yesterday's exact closing price is grabbed cleanly for intraday calculations without any repainting issues.

🧠 How It Works
The script calculates the maximum percentage move (both high and low) relative to the previous daily close on every single intraday bar. It evaluates these percentages against the built-in thresholds. If a new threshold is hit, it triggers a "state shift" and plots the corresponding visual tag. It will then remain silent until the price either drops out of the limits entirely or advances to the next limit tier (e.g., jumping from 5% to 10%).

🎯 Best Used For:
Volatile Markets: Extremely useful for markets with hard exchange-imposed circuit breakers (like the NSE/BSE in India or crypto assets).

Momentum Traders: Easily visually identify exactly when a stock catches fire and shifts into a new volatility gear.

Clean Charting: Perfect for traders who want critical alerts without sacrificing the visibility of their price action and candlesticks.

Add it to your chart, and never miss a circuit shift again—without the visual spam!

## Source Code

````pine
//@version=6
indicator("Circuit Detector", overlay=true)

// Calculate daily max percentage moves from yesterday's close
prev_close = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
daily_high_pct = ((high - prev_close) / prev_close) * 100
daily_low_pct  = ((prev_close - low) / prev_close) * 100

// Detect hits near circuit boundaries (with a minor buffer for decimal noise)
hit_5_pct  = (daily_high_pct >= 4.8 and daily_high_pct <= 5.2)  or (daily_low_pct >= 4.8 and daily_low_pct <= 5.2)
hit_10_pct = (daily_high_pct >= 9.7 and daily_high_pct <= 10.3) or (daily_low_pct >= 9.7 and daily_low_pct <= 10.3)
hit_20_pct = (daily_high_pct >= 19.5 and daily_high_pct <= 20.5) or (daily_low_pct >= 19.5 and daily_low_pct <= 20.5)

// Determine if a limit was hit on THIS specific candle
int limit_hit_this_bar = hit_20_pct ? 20 : (hit_10_pct ? 10 : (hit_5_pct ? 5 : 0))

// Persistent state tracking for the active circuit regime
var int current_limit = 0

// -----------------------------------------------------------------------------
// THE FIX: Create a trigger that is ONLY true on the exact candle a shift happens
// -----------------------------------------------------------------------------
bool is_new_limit = (limit_hit_this_bar > 0) and (limit_hit_this_bar != current_limit)

// Update the persistent state so we don't trigger again until it shifts to a different limit
if is_new_limit
    current_limit := limit_hit_this_bar

// Plot specific labels based on the exact active band
// Using 'is_new_limit' guarantees the label plots exactly ONCE per regime change
plotshape(is_new_limit and current_limit == 5, title="Circuit Shift 5%", style=shape.labeldown, location=location.abovebar, color=color.red, text="5%", textcolor=color.black, size=size.tiny)

plotshape(is_new_limit and current_limit == 10, title="Circuit Shift 10%", style=shape.labelup, location=location.belowbar, color=color.yellow, text="10%", textcolor=color.black, size=size.tiny)

plotshape(is_new_limit and current_limit == 20, title="Circuit Shift 20%", style=shape.labelup, location=location.belowbar, color=color.orange, text="20%", textcolor=color.black, size=size.tiny)
````
