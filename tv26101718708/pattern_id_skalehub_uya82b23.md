# Pattern ID [SkaleHub]

- url: https://www.tradingview.com/script/UYA82B23-Pattern-ID-SkaleHub/
- type: indicator
- pine_id: PUB;4371f087a9004e088ec635cf0852a018
- version: 1.0

## Description

Overview
A smart, algorithmic candlestick identifier designed to help develop a trader's eye for price action. It prints a clean, small text label directly above or below obvious, high-probability candlestick formations.

The Edge
Memorizing candlestick patterns can take months of screen time. This tool acts as real-time training wheels to accelerate your chart-reading skills, instantly pointing out the exact moments when buyers or sellers aggressively take control of the market.

Key Features:

Strict Quality Filtering: The algorithm uses precise mathematical ratios to ensure it only highlights high-quality patterns, filtering out "almost" patterns that lead to false signals.

Core Price Action Recognition: Automatically identifies the most reliable reversal patterns in trading: Bullish/Bearish Engulfing candles, Hammers, and Shooting Stars.

Customizable Toggles: Gives you the ability to turn specific patterns on or off in the settings, preventing chart clutter as you begin to recognize setups on your own.

How to Use

Apply the indicator to your chart.

When a label appears (e.g., "Bull Eng" or "Hammer"), use it as a trigger signal in confluence with your Level 1 Trend Filter or your Level 2 Support/Resistance Zones.

Do not trade patterns blindly in the middle of nowhere. Only take trades when a pattern prints at a logical area of structure.

Author's Note
This indicator is part of the SkaleHub Free Starter Library. It is designed to be paired with the SkaleHub Training System to help newer traders build mechanical discipline and systemize their trading process.

## Source Code

````pine
//@version=5
indicator("Pattern ID [SkaleHub]", overlay=true, max_labels_count=500)

// =========================================================================
// 1. INPUT PARAMETERS
// =========================================================================
showEngulfing = input.bool(true, title="Show Engulfing Patterns", group="Pattern Toggles")
showPins      = input.bool(true, title="Show Hammers & Shooting Stars", group="Pattern Toggles")

c_bull = input.color(color.new(#00ff00, 40), title="Bullish Label Color", group="Visuals")
c_bear = input.color(color.new(#ff0000, 40), title="Bearish Label Color", group="Visuals")
c_text = input.color(color.new(color.white, 0), title="Text Color", group="Visuals")

// =========================================================================
// 2. MATH & LOGIC (Candle Anatomy)
// =========================================================================
bodySize   = math.abs(close - open)
candleSize = high - low
upperWick  = high - math.max(close, open)
lowerWick  = math.min(close, open) - low

// =========================================================================
// 3. PATTERN RECOGNITION LOGIC
// =========================================================================
// A. Engulfing Patterns
// The current body must completely engulf the previous candle's body, and reverse the color.
bullEngulfing = close > open and close[1] < open[1] and close >= open[1] and open <= close[1] and bodySize > math.abs(close[1] - open[1])
bearEngulfing = close < open and close[1] > open[1] and close <= open[1] and open >= close[1] and bodySize > math.abs(close[1] - open[1])

// B. Hammers and Shooting Stars (Pin Bars)
// Wicked rejections. The rejecting wick must be at least 2x the body, the opposing wick must be tiny, and there must be actual range.
isHammer       = lowerWick >= (bodySize * 2.0) and upperWick <= bodySize and candleSize > 0
isShootingStar = upperWick >= (bodySize * 2.0) and lowerWick <= bodySize and candleSize > 0

// =========================================================================
// 4. VISUAL PLOTTING (Labels)
// =========================================================================
if showEngulfing and bullEngulfing
    label.new(bar_index, low, text="Bull Eng", style=label.style_label_up, color=c_bull, textcolor=c_text, size=size.small)

if showEngulfing and bearEngulfing
    label.new(bar_index, high, text="Bear Eng", style=label.style_label_down, color=c_bear, textcolor=c_text, size=size.small)

if showPins and isHammer
    label.new(bar_index, low, text="Hammer", style=label.style_label_up, color=c_bull, textcolor=c_text, size=size.small)

if showPins and isShootingStar
    label.new(bar_index, high, text="Star", style=label.style_label_down, color=c_bear, textcolor=c_text, size=size.small)
````
