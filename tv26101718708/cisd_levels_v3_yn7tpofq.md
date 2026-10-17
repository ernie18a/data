# CISD Levels V3

- url: https://www.tradingview.com/script/YN7tPOfq-CISD-Levels-V3/
- type: indicator
- pine_id: PUB;005f6767d27f43f6a935ef0f0eb7aa5a
- version: 1.0

## Description

CISD Levels V3 is an advanced market structure script designed to dynamically identify and trail Change in State of Delivery (CISD) levels. Built for precision, this indicator tracks the continuous flow of valid consecutive candles and instantly adapts to breakouts by establishing accurate opposing levels based on immediate historical price action.

Core Features:

Dynamic State Flipping: When the price closes through an active CISD level, the script instantly evaluates the breakout's candle sequence and drops a new opposing CISD line retroactively anchored to the correct sequence origin.

Body % Threshold Filter: Filters out market noise by allowing you to set a minimum required body size (High-to-Low percentage) for a candle to be considered "valid." A streak must contain at least two valid candles to confirm a structural sequence.

Bar-Close Confirmation: Strict barstate.isconfirmed logic prevents false mid-candle repainting. Lines only shift, flip, or extend the exact millisecond a candle officially closes.

Clean Chart History: Automatically curates your chart by saving a user-defined number of historical CISD levels while deleting old ones to prevent visual clutter.

Integrated Alerts: Built-in alert() functions for both Bullish and Bearish confirmations. Set up a single "Any alert() function call" in TradingView to receive real-time notifications exactly when the state flips.

Customizable Settings:
Adjust body size thresholds, forward line extensions, maximum historical lines displayed, and sequence lookback limits to fit your specific timeframe and trading style.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Zaad Trades

//@version=6
indicator("CISD Levels V3", overlay = true, max_lines_count = 500, max_labels_count = 500)

// --- Inputs ---
float bodyThresholdInput = input.float(10.0, "Body % Threshold", minval = 0.0, maxval = 100.0, tooltip = "Minimum body size as a percentage of the total candle range (High - Low).") / 100.0
color bullLineColorInput  = input.color(#4caf50, "Bullish", inline = "Colors")
color bearLineColorInput  = input.color(#ff9800, "Bearish", inline = "Colors")
int   extensionInput      = input.int(10, "Extension Offset", minval = 0, tooltip = "How many bars to extend the active line into the future.")

// --- Historical Settings ---
int   maxHistoryLines     = input.int(10, "Max Historical Lines Displayed", minval = 1, maxval = 500, tooltip = "Number of past confirmed CISD lines to keep visible on the chart.")
int   maxLookbackBars     = input.int(100, "Max Lookback for Opposite CISD (Bars)", minval = 1, tooltip = "Maximum allowed bars back to anchor the start of a streak.")

// --- Variables ---
var int   marketState     = 0    // 1: Bullish, -1: Bearish, 0: Neutral
var float activeLevel     = na
var line  activeLine      = na
var label activeLabel     = na
var bool  isCurrentBull   = false

// Arrays to manage historical lines on the chart
var line[]  historyLines  = array.new_line()
var label[] historyLabels = array.new_label()

// Running Trackers for Streaks (To evaluate sequence validity)
var int   bearStreakLen   = 0
var int   bearSigCount    = 0
var float bearStartOpen   = na
var int   bearStartIndex  = na

var int   bullStreakLen   = 0
var int   bullSigCount    = 0
var float bullStartOpen   = na
var int   bullStartIndex  = na

// --- Functions ---
method isSignificant(float o, float h, float l, float c, float threshold) =>
    float candleRange = h - l
    float bodySize    = math.abs(c - o)
    candleRange > 0 and bodySize >= candleRange * threshold

// Evaluate the current candle
bool isSig = isSignificant(open, high, low, close, bodyThresholdInput)

// Continuously update streak trackers on every bar
if close < open
    bearStreakLen += 1
    bearSigCount += (isSig ? 1 : 0)
    if bearStreakLen == 1
        bearStartOpen := open
        bearStartIndex := bar_index
    // Reset opposing streak
    bullStreakLen := 0
    bullSigCount := 0
else if close > open
    bullStreakLen += 1
    bullSigCount += (isSig ? 1 : 0)
    if bullStreakLen == 1
        bullStartOpen := open
        bullStartIndex := bar_index
    // Reset opposing streak
    bearStreakLen := 0
    bearSigCount := 0
else // Doji breaks the streak
    bearStreakLen := 0
    bearSigCount := 0
    bullStreakLen := 0
    bullSigCount := 0

// Determine if the current ongoing streak is valid for standard trailing
bool bullPatternTrigger = bearStreakLen >= 2 and bearSigCount >= 2
bool bearPatternTrigger = bullStreakLen >= 2 and bullSigCount >= 2

// --- State Flip (Closing through the line) ---
bool justFlippedBull = false
bool justFlippedBear = false

if not na(activeLevel) and not na(activeLine) and barstate.isconfirmed
    // If searching for Bullish flip and price closes above
    if marketState <= 0 and close > activeLevel and isCurrentBull
        marketState := 1
        activeLine.set_x2(bar_index) // Lock old line
        
        // Store in history
        array.push(historyLines, activeLine)
        array.push(historyLabels, activeLabel)
        if array.size(historyLines) > maxHistoryLines
            line.delete(array.shift(historyLines))
            label.delete(array.shift(historyLabels))
        
        // JUMP-START BEARISH CISD
        bool validLookback = not na(bullStartIndex) and (bar_index - bullStartIndex) <= maxLookbackBars
        if bullSigCount >= 2 and validLookback // Valid streak of >= 2 threshold candles
            activeLevel := bullStartOpen
            activeLine  := line.new(bullStartIndex, activeLevel, bar_index + extensionInput, activeLevel, color = bearLineColorInput, width = 2)
        else // Invalid streak or no preceding bullish candles
            activeLevel := open
            activeLine  := line.new(bar_index, activeLevel, bar_index + extensionInput, activeLevel, color = bearLineColorInput, width = 2)
        
        activeLabel   := label.new(bar_index, activeLevel, "CISD", color = #00000000, textcolor = #ffffff, style = label.style_label_center, size = size.small)
        isCurrentBull := false
        justFlippedBull := true 

    // If searching for Bearish flip and price closes below
    else if marketState >= 0 and close < activeLevel and not isCurrentBull
        marketState := -1
        activeLine.set_x2(bar_index) // Lock old line
        
        // Store in history
        array.push(historyLines, activeLine)
        array.push(historyLabels, activeLabel)
        if array.size(historyLines) > maxHistoryLines
            line.delete(array.shift(historyLines))
            label.delete(array.shift(historyLabels))

        // JUMP-START BULLISH CISD
        bool validLookback = not na(bearStartIndex) and (bar_index - bearStartIndex) <= maxLookbackBars
        if bearSigCount >= 2 and validLookback // Valid streak of >= 2 threshold candles
            activeLevel := bearStartOpen
            activeLine  := line.new(bearStartIndex, activeLevel, bar_index + extensionInput, activeLevel, color = bullLineColorInput, width = 2)
        else // Invalid streak or no preceding bearish candles
            activeLevel := open
            activeLine  := line.new(bar_index, activeLevel, bar_index + extensionInput, activeLevel, color = bullLineColorInput, width = 2)
            
        activeLabel   := label.new(bar_index, activeLevel, "CISD", color = #00000000, textcolor = #ffffff, style = label.style_label_center, size = size.small)
        isCurrentBull := true
        justFlippedBear := true 

// --- Standard Trailing (Updating levels as price moves normally) ---

// If Bearish/Neutral, trailing Bullish CISD
if (marketState <= 0) and bullPatternTrigger and not justFlippedBear and barstate.isconfirmed
    if not na(activeLine)
        activeLine.delete()
    if not na(activeLabel)
        activeLabel.delete()
    
    activeLevel   := bearStartOpen
    activeLine    := line.new(bearStartIndex, activeLevel, bar_index + extensionInput, activeLevel, color = bullLineColorInput, width = 2)
    activeLabel   := label.new(bar_index, activeLevel, "CISD", color = #00000000, textcolor = #ffffff, style = label.style_label_center, size = size.small)
    isCurrentBull := true

// If Bullish/Neutral, trailing Bearish CISD
if (marketState >= 0) and bearPatternTrigger and not justFlippedBull and barstate.isconfirmed
    if not na(activeLine)
        activeLine.delete()
    if not na(activeLabel)
        activeLabel.delete()
    
    activeLevel   := bullStartOpen
    activeLine    := line.new(bullStartIndex, activeLevel, bar_index + extensionInput, activeLevel, color = bearLineColorInput, width = 2)
    activeLabel   := label.new(bar_index, activeLevel, "CISD", color = #00000000, textcolor = #ffffff, style = label.style_label_center, size = size.small)
    isCurrentBull := false

// Extend the line visually once the running candle closes
if not na(activeLine) and barstate.isconfirmed
    activeLine.set_x2(bar_index + extensionInput)
    activeLabel.set_x(bar_index)

// --- Alerts ---
if justFlippedBull
    alert("Bullish CISD Confirmed! Price closed above the active level.", alert.freq_once_per_bar_close)

if justFlippedBear
    alert("Bearish CISD Confirmed! Price closed below the active level.", alert.freq_once_per_bar_close)
````
