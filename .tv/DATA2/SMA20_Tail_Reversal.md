<!-- tradingview-pine-id: PUB;3b1ae9a003004b62a3b980754a784d2d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SMA20 Tail Reversal

Source: https://www.tradingview.com/script/F9qp7zAP-SMA20-Tail-Reversal/

## Description

📌   Description:

      The SMA20 Tail Reversal indicator is an upgraded, highly customizable tool designed to identify high-probability counter-trend reversals. Rather than signaling every minor pullback, this advanced version filters for stronger confirmation by tracking consecutive signals and requiring a "Higher Low" structure before triggering a "Strong Buy."

📌   What's New & Different from the Previous Version (SMA7 to SMA20):

       Customizable Inputs: You can now adjust the SMA Length (default 20), Volume SMA Length, and Wick Ratio Threshold directly in the settings without editing the code.
Trend Shift (SMA7 → SMA20): The default moving average has been expanded to 20, filtering out market noise and focusing on more significant structural divergences.

Stricter Wick Condition: The default wick ratio has been tightened from 50% to 10% (0.1), ensuring only the cleanest, most decisive candles are considered.

"Strong Buy" & Higher Low Logic (Major Update): The script no longer prints every single signal. Instead, it internally tracks base signals. A Strong Buy is only triggered if the current base buy signal forms a higher low than the previous base buy signal.

Visual Overhaul: Bar coloring and the dotted connecting line have been completely removed for a cleaner chart. Signals are now displayed as highly visible "★ BUY" labels below the triggering candle.

Alerts Added: Built-in alerts allow traders to receive notifications exactly when a "Strong Buy" (consecutive & higher low) occurs.

📌 How It Works:

   1. Moving Average & Volume Filters:
Calculates a Simple Moving Average (SMA) of length 20 (adjustable) as the primary threshold.
Requires the current candle's volume to be higher than the 20-period volume SMA.

   2. Strict Candle Classification:
Bullish Candle: Close > Open, and the upper wick is extremely small (less than 10% of the body size by default).
Bearish Candle: Close < Open, and the lower wick is extremely small.

   3. Base Signal Generation (Internal):
Base Long: High & Low are strictly below the SMA20 + Volume condition met + Bullish Candle detected.
Base Short: High & Low are strictly above the SMA20 + Volume condition met + Bearish Candle detected (used internally to break buy flows).

   4. Consecutive Signal Confirmation:
When a Base Long occurs, the script checks the previous signal. If the previous signal was also a Base Long, and the current candle's low is higher than the previous signal's low, it confirms a Strong Buy.

📌 Visual Representation:

   Blue Cross Shape (★ BUY): Appears below the candle only when the strict "Strong Buy" (Higher Low) conditions are met. (You can toggle this visibility in the settings).

📌 Usage:

   Best applied to find exhaustion in downtrends where price has detached from the SMA20 and is beginning to form higher lows.

Designed to reduce false positives by requiring secondary confirmation (a consecutive setup with a higher low) rather than jumping in on the very first dip.

Can be hooked up to automated trading bots or mobile notifications using the built-in alert system.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rikyu04
//@version=6
indicator("SMA20 Tail Reversal", overlay=true)

// ==========================================
// [1] USER INPUTS
// ==========================================
grp_main = "Main Logic Settings"
smaLen   = input.int(20, title="SMA Length", minval=1, group=grp_main)
volLen   = input.int(20, title="Volume SMA Length", minval=1, group=grp_main)
wickRatio= input.float(0.1, title="Wick Ratio Threshold", step=0.1, maxval=1.0, minval=0.1, group=grp_main)

grp_vis  = "Visual Settings"
showLabel= input.bool(true, title="Show STRONG BUY Labels", group=grp_vis)

// Color Definitions
color strongLongCol = color.new(#00BFFF, 0) // Strong Buy (Blue)

// ==========================================
// [2] CALCULATIONS (Executed internally for logic, not plotted)
// ==========================================
smaVal  = ta.sma(close, smaLen)
volCond = volume > ta.sma(volume, volLen)

bodySize  = math.abs(close - open)
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

bullCandle = (close > open) and (upperWick < (bodySize * wickRatio))
bearCandle = (close < open) and (lowerWick < (bodySize * wickRatio))

// Base signal calculation (for internal tracking)
baseLongCond  = volCond and bullCandle and (high < smaVal) and (low < smaVal)
baseShortCond = volCond and bearCandle and (low > smaVal) and (high > smaVal)

// ==========================================
// [3] CONSECUTIVE SIGNAL (Strong Buy) LOGIC
// ==========================================
var int   lastSignalType = 0  // 1 = Buy, -1 = Sell
var float lastSignalLow  = na

bool strongLongCond = false

// On Buy Condition
if baseLongCond
    // If the previous signal was a BUY and the current low is higher than the previous low, it's a Strong Buy!
    if lastSignalType == 1 and low > lastSignalLow
        strongLongCond := true
    lastSignalType := 1
    lastSignalLow  := low

// On Sell Condition (Internally tracked to break the consecutive buy flow)
if baseShortCond
    lastSignalType := -1

// ==========================================
// [4] VISUALS - Show labels only
// ==========================================
plotshape(showLabel and strongLongCond, title="Strong Buy Signal", style=shape.cross, location=location.belowbar, color=strongLongCol, text="★ BUY", textcolor=color.white, size=size.small)

// ==========================================
// [5] ALERTS
// ==========================================
alertcondition(strongLongCond, title="[Buy] STRONG (★)", message="Strong BUY! Consecutive & Higher Low")
````
