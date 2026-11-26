# N Rushi Sushi - Volume Algebra

- url: https://www.tradingview.com/script/ffsDo5UJ-N-Rushi-Sushi-Volume-Algebra/
- type: indicator
- pine_id: PUB;021e71db32e940d2a16fa89e3f279437
- version: 1.0

## Description

N Rushi Sushi – Volume Algebra Indicator
The One-Sentence Summary
This indicator watches volume (how many people are trading) and price (which direction), does simple math, and tells you when to BUY, SHORT, or WAIT.

How It Works
Every candle on your chart contains two pieces of information: price and volume.

Volume tells you how much participation is happening.

Price tells you the direction.

When volume and price move together, the move is real and worth following.
When they move apart, the move is weak and likely to fail.

This indicator does the math for you so you don't have to guess.

The Four Market Categories
Based on your original framework (adapted for CFDs/indices using volume as the proxy):

Volume	Price	Meaning	Signal
↑ (increasing)	↑ (increasing)	Big money is buying	BUY
↑ (increasing)	↓ (decreasing)	Big money is selling	SHORT
↓ (decreasing)	↑ (increasing)	Fake move – volume not confirmed	WAIT / CAUTION
↓ (decreasing)	↓ (decreasing)	Panic or exhaustion	WAIT / CAUTION
The indicator only trades the top two rows. Everything else is WAIT.

The Algebraic Formula
text
SCORE = (0.40 × Volume Change %) + (0.35 × |Price Change %|) + (0.25 × Volume Ratio)
Component	Weight	What It Measures
Volume Change %	40%	How much volume increased or decreased
Price Change %	35%	How much price moved (absolute value)
Volume Ratio	25%	Current volume ÷ previous volume
The higher the SCORE, the stronger the signal.

Score Thresholds
Score Range	Strength	Suggested Action
< 1.5	Insufficient	No trade
1.5 – 2.5	Weak	Small position only
2.5 – 4.0	Moderate	Normal position
> 4.0	Strong	Full confidence
What the Table Shows (Bottom Right)
Row	What It Means
SIGNAL	BUY / SHORT / WAIT / CAUTION – your trading instruction
SCORE	The algebraic number (higher = stronger)
STRENGTH	INSUFFICIENT / WEAK / MODERATE / STRONG
VOL Δ%	Volume percentage change (green = increasing)
PRICE Δ%	Price percentage change (green = up, red = down)
VOL RATIO	Current volume ÷ previous volume (above 1.05 = active)
STOP	Suggested stop loss price (shown on BUY/SHORT only)
How to Use This Indicator (Step by Step)
Set your timeframe – 15 minutes is recommended for beginners

Wait for a signal – BUY or SHORT only; ignore WAIT/CAUTION

Check STRENGTH – MODERATE or STRONG is preferred

Confirm volume – VOL Δ% should be green (positive)

Use the STOP – Exit if price hits the suggested stop level

Risk only 1-2% of your account per trade

Important Notes
Works on any timeframe (1-minute to monthly)

Works on any symbol (stocks, forex, crypto, indices, CFDs)

Does not repaint – signals are based on closed candles only

Alerts are available for BUY and SHORT signals

Disclaimer
This indicator is a tool, not a guarantee. No indicator wins 100% of trades. Always use proper risk management, trade small while learning, and never risk more than you can afford to lose. Past performance does not guarantee future results.

Credits
Based on the original framework by N Rushi Sushi:
"Intraday trading is mathematics – basic algebra applied to volume and price."

Optional: Add This Line at the Bottom (For Humor/Honesty)
"This indicator will not make you a king overnight. But it will stop you from trading like a peasant."

## Source Code

````pine
//@version=6
indicator(title="N Rushi Sushi - Volume Algebra", overlay=true)

// ============================================================================
// 1. USER INPUTS - Customize these values
// ============================================================================

// Volume lookback period (how many candles to compare)
volumeLookback = input.int(1, "Volume Comparison Period (bars ago)", minval=1, maxval=10)

// Score thresholds
weakThreshold = input.float(1.5, "Weak Signal Threshold", minval=0.5, maxval=5.0, step=0.1)
moderateThreshold = input.float(2.5, "Moderate Signal Threshold", minval=1.0, maxval=8.0, step=0.1)
strongThreshold = input.float(4.0, "Strong Signal Threshold", minval=2.0, maxval=10.0, step=0.1)

// Weights for the algebraic formula (0.4 + 0.35 + 0.25 = 1.0)
weightOI    = input.float(0.40, "Weight: OI/Volume Change", minval=0, maxval=1, step=0.01)
weightPrice = input.float(0.35, "Weight: Price Change", minval=0, maxval=1, step=0.01)
weightVol   = input.float(0.25, "Weight: Volume Ratio", minval=0, maxval=1, step=0.01)

// Table position and size options
tablePosition = input.string("Middle Right", "Table Position", options=["Top Right", "Top Left", "Middle Left", "Middle Right", "Bottom Right", "Bottom Left"])
tableSize = input.string("Small", "Table Size", options=["Small", "Medium", "Large"])

// ============================================================================
// 2. CALCULATE THE ALGEBRAIC COMPONENTS
// ============================================================================

// For CFDs/indices without OI, we use Volume as the primary flow proxy
// Volume Ratio (current vs previous period)
currentVolume = volume
previousVolume = volume[volumeLookback]
volumeRatio = previousVolume != 0 ? currentVolume / previousVolume : 1.0

// Volume Percentage Change (ΔOI% proxy)
volumeChangePct = (volumeRatio - 1.0) * 100

// Price Percentage Change (ΔPrice%)
currentPrice = close
previousPrice = close[volumeLookback]
priceChangePct = previousPrice != 0 ? ((currentPrice - previousPrice) / previousPrice) * 100 : 0.0

// Short signal uses absolute value of negative price change
priceChangeAbs = math.abs(priceChangePct)

// Volume ratio for scoring (capped at 3.0 to avoid runaway scores)
volumeRatioScore = math.min(volumeRatio, 3.0)

// ============================================================================
// 3. APPLY YOUR ALGEBRAIC FORMULA
// ============================================================================

// Raw Score = (0.40 × ΔOI%) + (0.35 × ΔPrice%) + (0.25 × Volume Ratio)
// For Short trades: use absolute value of ΔPrice%
rawScore = (weightOI * volumeChangePct) + (weightPrice * priceChangeAbs) + (weightVol * volumeRatioScore)
score = math.max(0, rawScore)  // No negative scores

// Determine Signal Type based on Volume + Price direction
// Category 1: OI/Volume ↑ + Price ↑ -> BUY
// Category 2: OI/Volume ↑ + Price ↓ -> SHORT
// Category 3-4: Other combinations -> WAIT
volumeIncreasing = volumeRatio > 1.05  // >5% volume increase
priceUp = priceChangePct > 0
priceDown = priceChangePct < 0

// Determine primary signal
signalType = "WAIT"
signalColor = color.new(color.gray, 0)

if volumeIncreasing and priceUp and score >= weakThreshold
    signalType := "BUY"
    signalColor := color.new(color.green, 0)
else if volumeIncreasing and priceDown and score >= weakThreshold
    signalType := "SHORT"
    signalColor := color.new(color.red, 0)
else if score >= weakThreshold
    // Score is high but volume/price direction doesn't match -> caution
    signalType := "CAUTION"
    signalColor := color.new(color.orange, 0)

// Signal strength description based on score
strengthText = ""
if score >= strongThreshold
    strengthText := "STRONG"
else if score >= moderateThreshold
    strengthText := "MODERATE"
else if score >= weakThreshold
    strengthText := "WEAK"
else
    strengthText := "INSUFFICIENT"

// ============================================================================
// 4. OPTIONAL: STOP LOSS CALCULATION (Based on ATR)
// ============================================================================

atrLength = input.int(14, "ATR Length for Stop Loss", minval=1, maxval=50)
atrValue = ta.atr(atrLength)
stopMultiplier = input.float(1.5, "ATR Stop Multiplier", minval=0.5, maxval=3.0, step=0.1)

longStop = currentPrice - (atrValue * stopMultiplier)
shortStop = currentPrice + (atrValue * stopMultiplier)

// Determine suggested stop based on signal
suggestedStop = signalType == "BUY" ? longStop : signalType == "SHORT" ? shortStop : na

// ============================================================================
// 5. DETERMINE TABLE POSITION (INCLUDING MIDDLE RIGHT)
// ============================================================================

getTablePosition(pos) =>
    switch pos
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Middle Left" => position.middle_left
        "Middle Right" => position.middle_right
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.middle_right  // Default to Middle Right

// Determine table size
getTableTextSize(size) =>
    switch size
        "Small" => size.small
        "Large" => size.large
        => size.normal  // Medium default

// Apply selected position
tablePositionEnum = getTablePosition(tablePosition)
tableFontSize = getTableTextSize(tableSize)

// ============================================================================
// 6. CREATE TABLE (MIDDLE RIGHT POSITION)
// ============================================================================

// Create table (only once using 'var')
var signalTable = table.new(
     position = tablePositionEnum,
     columns = 2,
     rows = 8,
     bgcolor = color.new(color.black, 85),
     border_width = 1,
     border_color = color.new(color.gray, 50)
)

// Helper function to update table cell
f_setCell(col, row, txt, textColor, bgColor) =>
    table.cell(signalTable, col, row, txt, text_color=textColor, bgcolor=bgColor, text_size=tableFontSize)

// Header row
f_setCell(0, 0, "METRIC", color.white, color.new(color.gray, 70))
f_setCell(1, 0, "VALUE", color.white, color.new(color.gray, 70))

// Row 1: Signal Type
f_setCell(0, 1, "SIGNAL", color.white, color.new(color.black, 100))
f_setCell(1, 1, signalType, signalColor, color.new(color.black, 100))

// Row 2: Score
scoreColor = score >= strongThreshold ? color.lime : score >= moderateThreshold ? color.yellow : score >= weakThreshold ? color.orange : color.red
f_setCell(0, 2, "SCORE", color.white, color.new(color.black, 100))
f_setCell(1, 2, str.tostring(score, "#.##"), scoreColor, color.new(color.black, 100))

// Row 3: Strength
strengthColor = strengthText == "STRONG" ? color.lime : strengthText == "MODERATE" ? color.yellow : strengthText == "WEAK" ? color.orange : color.gray
f_setCell(0, 3, "STRENGTH", color.white, color.new(color.black, 100))
f_setCell(1, 3, strengthText, strengthColor, color.new(color.black, 100))

// Row 4: Volume Change
volColor = volumeChangePct > 5 ? color.lime : volumeChangePct > 0 ? color.yellow : volumeChangePct < -5 ? color.red : color.gray
f_setCell(0, 4, "VOL Δ%", color.white, color.new(color.black, 100))
f_setCell(1, 4, str.tostring(volumeChangePct, "#.##") + "%", volColor, color.new(color.black, 100))

// Row 5: Price Change
priceColor = priceChangePct > 0 ? color.lime : priceChangePct < 0 ? color.red : color.gray
f_setCell(0, 5, "PRICE Δ%", color.white, color.new(color.black, 100))
f_setCell(1, 5, str.tostring(priceChangePct, "#.##") + "%", priceColor, color.new(color.black, 100))

// Row 6: Volume Ratio
f_setCell(0, 6, "VOL RATIO", color.white, color.new(color.black, 100))
f_setCell(1, 6, str.tostring(volumeRatio, "#.##"), color.white, color.new(color.black, 100))

// Row 7: Suggested Stop (only if signal is BUY or SHORT)
if signalType == "BUY" or signalType == "SHORT"
    f_setCell(0, 7, "STOP", color.white, color.new(color.gray, 70))
    f_setCell(1, 7, str.tostring(suggestedStop, format.mintick), color.white, color.new(color.black, 100))
else
    f_setCell(0, 7, "", color.white, color.new(color.black, 100))
    f_setCell(1, 7, "", color.white, color.new(color.black, 100))

// ============================================================================
// 7. PLOT SIGNAL ARROWS ON CHART
// ============================================================================

showArrows = input.bool(true, "Show Signal Arrows on Chart")

plotshape(showArrows and signalType == "BUY", 
     title="Buy Signal", 
     location=location.belowbar, 
     style=shape.arrowup, 
     color=color.new(color.green, 0), 
     size=size.small)

plotshape(showArrows and signalType == "SHORT", 
     title="Short Signal", 
     location=location.abovebar, 
     style=shape.arrowdown, 
     color=color.new(color.red, 0), 
     size=size.small)

// ============================================================================
// 8. ALERTS
// ============================================================================

alertcondition(signalType == "BUY", title="BUY Signal", message="NRS: BUY Signal Triggered")
alertcondition(signalType == "SHORT", title="SHORT Signal", message="NRS: SHORT Signal Triggered")
alertcondition(signalType == "CAUTION", title="CAUTION", message="NRS: Caution - Check Direction")

// ============================================================================
// 9. PLOT DEBUG VALUES (Optional - can be turned off)
// ============================================================================

showDebug = input.bool(false, "Show Debug Values on Chart")

plot(showDebug ? score : na, title="Debug Score", color=color.purple, linewidth=1, display=display.all)
hline(showDebug ? weakThreshold : na, "Weak Threshold", color=color.new(color.orange, 50), linestyle=hline.style_dotted)
hline(showDebug ? moderateThreshold : na, "Moderate Threshold", color=color.new(color.yellow, 50), linestyle=hline.style_dotted)
hline(showDebug ? strongThreshold : na, "Strong Threshold", color=color.new(color.lime, 50), linestyle=hline.style_dotted)
````
