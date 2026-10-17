# Candle Sweep Long/Short with LVN

- url: https://www.tradingview.com/script/nB0qCCHo-Candle-Sweep-Long-Short-with-LVN/
- type: indicator
- pine_id: PUB;dd52d645201e4cc68bbd6d82298c36a0
- version: 1.0

## Description

Overview
The Candle Sweep Long/Short with LVN is a sophisticated Pine Script indicator for TradingView that identifies high-probability sweep trading opportunities by detecting when price sweeps recent swing highs or lows while incorporating multiple validation filters. This multi-layered approach combines candle pattern analysis, volume confirmation, Low Volume Node (LVN) detection, RSI filtering, and consecutive candle analysis to generate reliable long and short signals.

Core Concept
The indicator works on the principle that when price sweeps a recent extreme (breaking above a swing high or below a swing low) but closes back within the range, it often indicates a false breakout. This creates potential reversal opportunities that the script captures. However, unlike simpler sweep strategies, this indicator adds robust filtering to significantly reduce false signals.

Key Features
1. Sweep Detection Logic
Long Signals: Identifies when price breaks below the lowest low of the lookback period but closes above that level (bullish sweep)

Short Signals: Detects when price breaks above the highest high of the lookback period but closes below that level (bearish sweep)

Configurable lookback period (1-50 bars) to adjust sweep sensitivity

2. Advanced Filtering System
Candle Quality Filters
Close Position Requirement: Candle must close in the top/bottom X% of its range (default 70%), confirming strong directional momentum

Range Filter: Optionally requires signal candle to be larger than the prior candle by a minimum percentage, filtering out low-volatility signals

Body Size Filter: Ensures the candle body represents a minimum percentage of the total range, confirming genuine directional conviction

Consecutive Candle Filter (NEW)
Invalidates long signals if X or more consecutive red candles appeared before the signal

Invalidates short signals if X or more consecutive green candles appeared before the signal

Helps avoid entering against established momentum trends

RSI Filter
Long signals can be invalidated if RSI is above overbought levels or below its moving average

Short signals can be invalidated if RSI is below oversold levels or above its moving average

All filter conditions can be independently enabled/disabled

3. Low Volume Node (LVN) Validation (NEW - Expanded to 16 Zones)
Manually define up to 16 LVN zones (areas of low trading volume acting as key support/resistance)

Signals are only valid if the candle touches an LVN zone AND closes beyond the 50% midpoint of that zone

LVN zones are visually displayed as semi-transparent gray boxes on the chart

Each LVN zone can be independently defined with high/low prices

4. Visual Signals & Alerts
Long signals: Green triangle below the candle with "LONG" label

Short signals: Red triangle above the candle with "SHORT" label

Signal candle highlighting: Candles with valid signals are colored green/red with reduced opacity

Black candle overlay (optional): Colors signal candles black if the next candle moves opposite to the signal direction, helping visualize failed signals

Alert conditions: Configurable alerts for sweep signal detection

Technical Parameters
Signal Parameters
Close in Top/Bottom X% of Range (0-100%): Determines how extreme the close must be relative to the candle range

Sweep Lookback Bars (1-50): Number of bars to look back for swing points

Range Filter
Require Signal Candle Larger Than Prior Candle: Toggle the range filter

Minimum % Larger Than Prior Candle: The minimum percentage by which the signal candle must exceed the prior candle's range

Body Size Filter
Minimum Body Size (% of Range): Minimum candle body percentage required (excludes doji-like candles)

Consecutive Opposite Candles Filter
Consecutive Red Candles Required to Invalidate Long (1-10)

Consecutive Green Candles Required to Invalidate Short (1-10)

RSI Filter Parameters
RSI Length (default 14)

Overbought/Oversold levels (default 70/30)

RSI Moving Average Length (default 9)

Individual toggle for each invalidation condition

LVN Settings
Up to 16 customizable LVN price zones

Toggle LVN filter on/off

Toggle LVN box visibility on/off

Trading Strategy Application
Ideal Use Cases
Range-bound markets: Excellent for identifying false breakouts in consolidation phases

Mean reversion strategies: Signals often occur when price temporarily moves outside the range before reverting

Reversal trading: Captures potential trend reversals when combined with RSI and LVN validation

Best Practices
Use higher timeframes (15min+) for more reliable signals

Consider using in conjunction with volume analysis for confirmation

Apply stricter LVN and RSI filters in volatile markets

Use the consecutive candle filter to avoid counter-trend entries

Customization Flexibility
The indicator offers extensive customization with toggles for each filter type, allowing traders to:

Disable any filter for simpler strategies

Adjust parameters to match specific market conditions

Add or remove LVN zones as market structure evolves

Fine-tune RSI conditions to match personal risk tolerance

Comparative Advantages
Comprehensive filtering: More filters than typical sweep indicators, reducing false signals

LVN integration: Unique ability to validate sweeps against known volume nodes

Visual clarity: Clear signal markers and optional LVN visualization

Flexibility: All components can be independently adjusted or disabled

Limitations & Considerations
Requires manual LVN zone definition (not automatically detected)

May generate fewer signals with all filters enabled (quality over quantity)

RSI and LVN filters may cause signals to appear after significant price movement

Best used in conjunction with other analysis tools for trade management

This indicator is suitable for traders looking for high-quality sweep signals with multiple confirmation layers, particularly those who trade breakouts, reversals, and mean reversion strategies in ranging markets.

## Source Code

````pine
//@version=6
indicator("Candle Sweep Long/Short with LVN", overlay=true)

// Signal Parameters
closePercentTop = input.float(70.0, "Close in Top/Bottom X% of Range", minval=0, maxval=100, step=5)
lookbackBars = input.int(5, "Sweep Lookback Bars", minval=1, maxval=50)

// Range Filter
useRangeFilter = input.bool(true, "Require Signal Candle Larger Than Prior Candle")
rangeMinPercent = input.float(20.0, "Minimum % Larger Than Prior Candle", minval=0, step=5)

// Body Size Filter
minBodyPercent = input.float(10.0, "Minimum Body Size (% of Range)", minval=0, maxval=100, step=5)

// Black Candle After Opposite Signal
blackCandleOnOpposite = input.bool(true, "Black Out Signal Candle If Next Candle Is Opposite")

// Consecutive Opposite Candles Filter (NEW)
consecutiveRedCandlesRequired = input.int(3, "Consecutive Red Candles Required to Invalidate Long", minval=1, maxval=10, tooltip="If X or more red candles appear before a long signal, the signal is invalidated")
consecutiveGreenCandlesRequired = input.int(3, "Consecutive Green Candles Required to Invalidate Short", minval=1, maxval=10, tooltip="If X or more green candles appear before a short signal, the signal is invalidated")

// RSI Filter Inputs (from Swing Levels script)
enableRSIFilter = input.bool(true, "Enable RSI Filter")
rsiLength = input.int(14, "RSI Length", minval=1, maxval=100)
rsiOverbought = input.int(70, "RSI Overbought Level", minval=1, maxval=100)
rsiOversold = input.int(30, "RSI Oversold Level", minval=1, maxval=100)
rsiMALength = input.int(9, "RSI MA Length", minval=1, maxval=50)
invalidateLongAboveOverbought = input.bool(true, "Invalidate Long If RSI Above Overbought", tooltip="Long signals invalid when RSI is above overbought level")
invalidateLongBelowRSIMA = input.bool(true, "Invalidate Long If RSI Below RSI MA", tooltip="Long signals invalid when RSI is below its moving average")
invalidateShortBelowOversold = input.bool(true, "Invalidate Short If RSI Below Oversold", tooltip="Short signals invalid when RSI is below oversold level")
invalidateShortAboveRSIMA = input.bool(true, "Invalidate Short If RSI Above RSI MA", tooltip="Short signals invalid when RSI is above its moving average")

// LVN Inputs
enableLVNFilter = input.bool(true, "Enable LVN Filter")
lvn1High = input.float(0.0, "LVN 1 High")
lvn1Low  = input.float(0.0, "LVN 1 Low")
lvn2High = input.float(0.0, "LVN 2 High")
lvn2Low  = input.float(0.0, "LVN 2 Low")
lvn3High = input.float(0.0, "LVN 3 High")
lvn3Low  = input.float(0.0, "LVN 3 Low")
lvn4High = input.float(0.0, "LVN 4 High")
lvn4Low  = input.float(0.0, "LVN 4 Low")
lvn5High = input.float(0.0, "LVN 5 High")
lvn5Low  = input.float(0.0, "LVN 5 Low")
lvn6High = input.float(0.0, "LVN 6 High")
lvn6Low  = input.float(0.0, "LVN 6 Low")
lvn7High = input.float(0.0, "LVN 7 High")
lvn7Low  = input.float(0.0, "LVN 7 Low")
lvn8High = input.float(0.0, "LVN 8 High")
lvn8Low  = input.float(0.0, "LVN 8 Low")
// LVN 9-16 (NEW)
lvn9High = input.float(0.0, "LVN 9 High")
lvn9Low  = input.float(0.0, "LVN 9 Low")
lvn10High = input.float(0.0, "LVN 10 High")
lvn10Low  = input.float(0.0, "LVN 10 Low")
lvn11High = input.float(0.0, "LVN 11 High")
lvn11Low  = input.float(0.0, "LVN 11 Low")
lvn12High = input.float(0.0, "LVN 12 High")
lvn12Low  = input.float(0.0, "LVN 12 Low")
lvn13High = input.float(0.0, "LVN 13 High")
lvn13Low  = input.float(0.0, "LVN 13 Low")
lvn14High = input.float(0.0, "LVN 14 High")
lvn14Low  = input.float(0.0, "LVN 14 Low")
lvn15High = input.float(0.0, "LVN 15 High")
lvn15Low  = input.float(0.0, "LVN 15 Low")
lvn16High = input.float(0.0, "LVN 16 High")
lvn16Low  = input.float(0.0, "LVN 16 Low")
showLVNBoxes = input.bool(true, "Show LVN Boxes on Chart")

// LVN Functions
f_is_touching_lvn(float highPrice, float lowPrice, float lvnHigh, float lvnLow) =>
    (highPrice >= lvnLow and lowPrice <= lvnHigh)

f_is_closing_beyond_50_percent_lvn(float closePrice, float lvnHigh, float lvnLow, bool isBullish) =>
    float lvnMid = (lvnHigh + lvnLow) / 2
    isBullish ? closePrice > lvnMid : closePrice < lvnMid

f_check_lvn_validation(float candleHigh, float candleLow, float candleClose, bool isBullish) =>
    bool isValid = false
    if lvn1High != 0 or lvn1Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn1High, lvn1Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn1High, lvn1Low, isBullish)
            isValid := true
    if lvn2High != 0 or lvn2Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn2High, lvn2Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn2High, lvn2Low, isBullish)
            isValid := true
    if lvn3High != 0 or lvn3Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn3High, lvn3Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn3High, lvn3Low, isBullish)
            isValid := true
    if lvn4High != 0 or lvn4Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn4High, lvn4Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn4High, lvn4Low, isBullish)
            isValid := true
    if lvn5High != 0 or lvn5Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn5High, lvn5Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn5High, lvn5Low, isBullish)
            isValid := true
    if lvn6High != 0 or lvn6Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn6High, lvn6Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn6High, lvn6Low, isBullish)
            isValid := true
    if lvn7High != 0 or lvn7Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn7High, lvn7Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn7High, lvn7Low, isBullish)
            isValid := true
    if lvn8High != 0 or lvn8Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn8High, lvn8Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn8High, lvn8Low, isBullish)
            isValid := true
    // LVN 9-16 validation (NEW)
    if lvn9High != 0 or lvn9Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn9High, lvn9Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn9High, lvn9Low, isBullish)
            isValid := true
    if lvn10High != 0 or lvn10Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn10High, lvn10Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn10High, lvn10Low, isBullish)
            isValid := true
    if lvn11High != 0 or lvn11Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn11High, lvn11Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn11High, lvn11Low, isBullish)
            isValid := true
    if lvn12High != 0 or lvn12Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn12High, lvn12Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn12High, lvn12Low, isBullish)
            isValid := true
    if lvn13High != 0 or lvn13Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn13High, lvn13Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn13High, lvn13Low, isBullish)
            isValid := true
    if lvn14High != 0 or lvn14Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn14High, lvn14Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn14High, lvn14Low, isBullish)
            isValid := true
    if lvn15High != 0 or lvn15Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn15High, lvn15Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn15High, lvn15Low, isBullish)
            isValid := true
    if lvn16High != 0 or lvn16Low != 0
        if f_is_touching_lvn(candleHigh, candleLow, lvn16High, lvn16Low) and f_is_closing_beyond_50_percent_lvn(candleClose, lvn16High, lvn16Low, isBullish)
            isValid := true
    isValid

// Draw LVN Boxes
if showLVNBoxes
    if lvn1High != 0 or lvn1Low != 0
        box.new(left=bar_index-50, top=lvn1High, right=bar_index, bottom=lvn1Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn2High != 0 or lvn2Low != 0
        box.new(left=bar_index-50, top=lvn2High, right=bar_index, bottom=lvn2Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn3High != 0 or lvn3Low != 0
        box.new(left=bar_index-50, top=lvn3High, right=bar_index, bottom=lvn3Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn4High != 0 or lvn4Low != 0
        box.new(left=bar_index-50, top=lvn4High, right=bar_index, bottom=lvn4Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn5High != 0 or lvn5Low != 0
        box.new(left=bar_index-50, top=lvn5High, right=bar_index, bottom=lvn5Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn6High != 0 or lvn6Low != 0
        box.new(left=bar_index-50, top=lvn6High, right=bar_index, bottom=lvn6Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn7High != 0 or lvn7Low != 0
        box.new(left=bar_index-50, top=lvn7High, right=bar_index, bottom=lvn7Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn8High != 0 or lvn8Low != 0
        box.new(left=bar_index-50, top=lvn8High, right=bar_index, bottom=lvn8Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    // LVN 9-16 boxes (NEW)
    if lvn9High != 0 or lvn9Low != 0
        box.new(left=bar_index-50, top=lvn9High, right=bar_index, bottom=lvn9Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn10High != 0 or lvn10Low != 0
        box.new(left=bar_index-50, top=lvn10High, right=bar_index, bottom=lvn10Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn11High != 0 or lvn11Low != 0
        box.new(left=bar_index-50, top=lvn11High, right=bar_index, bottom=lvn11Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn12High != 0 or lvn12Low != 0
        box.new(left=bar_index-50, top=lvn12High, right=bar_index, bottom=lvn12Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn13High != 0 or lvn13Low != 0
        box.new(left=bar_index-50, top=lvn13High, right=bar_index, bottom=lvn13Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn14High != 0 or lvn14Low != 0
        box.new(left=bar_index-50, top=lvn14High, right=bar_index, bottom=lvn14Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn15High != 0 or lvn15Low != 0
        box.new(left=bar_index-50, top=lvn15High, right=bar_index, bottom=lvn15Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))
    if lvn16High != 0 or lvn16Low != 0
        box.new(left=bar_index-50, top=lvn16High, right=bar_index, bottom=lvn16Low, bgcolor=color.new(color.gray,85), border_color=color.new(color.gray,50))

// ==================== RSI FILTER (from Swing Levels script) ====================
rsiValue = ta.rsi(close, rsiLength)
rsiMA = ta.sma(rsiValue, rsiMALength)

// RSI validation for long signals
bool rsiLongValid = true
if enableRSIFilter
    bool rsiAboveOverbought = rsiValue >= rsiOverbought
    bool rsiBelowMA = rsiValue < rsiMA
    
    if invalidateLongAboveOverbought and rsiAboveOverbought
        rsiLongValid := false
    if invalidateLongBelowRSIMA and rsiBelowMA
        rsiLongValid := false

// RSI validation for short signals
bool rsiShortValid = true
if enableRSIFilter
    bool rsiBelowOversold = rsiValue <= rsiOversold
    bool rsiAboveMA = rsiValue > rsiMA
    
    if invalidateShortBelowOversold and rsiBelowOversold
        rsiShortValid := false
    if invalidateShortAboveRSIMA and rsiAboveMA
        rsiShortValid := false

// ==================== CONSECUTIVE OPPOSITE CANDLE DETECTION ====================
// Count consecutive red candles (close < open)
var int consecutiveRedCount = 0
if close < open
    consecutiveRedCount := consecutiveRedCount + 1
else
    consecutiveRedCount := 0

// Count consecutive green candles (close > open)
var int consecutiveGreenCount = 0
if close > open
    consecutiveGreenCount := consecutiveGreenCount + 1
else
    consecutiveGreenCount := 0

// Get the consecutive count from the previous candle (before the potential signal candle)
float prevConsecutiveRed = consecutiveRedCount[1]
float prevConsecutiveGreen = consecutiveGreenCount[1]

// Invalidation conditions
bool invalidateLongByConsecutiveRed = prevConsecutiveRed >= consecutiveRedCandlesRequired
bool invalidateShortByConsecutiveGreen = prevConsecutiveGreen >= consecutiveGreenCandlesRequired

// Calculate candle metrics
float candleRange = high - low
float closePositionBull = candleRange > 0 ? ((close - low) / candleRange) * 100 : 50
float closePositionBear = candleRange > 0 ? ((high - close) / candleRange) * 100 : 50
float bodyPercent = candleRange > 0 ? (math.abs(close - open) / candleRange) * 100 : 0

// Volume condition
float volumeRatio = volume / volume[1]
bool volumeCondition = volumeRatio >= 0.75

// Range condition
float priorCandleRange = candleRange[1]
bool rangeCondition = useRangeFilter ? candleRange >= priorCandleRange * (1 + rangeMinPercent / 100) : true

// Body size condition
bool bodySizeCondition = bodyPercent >= minBodyPercent

// ========== LONG SIGNAL ==========
float lowestLowInLookback = ta.lowest(low[1], lookbackBars)
bool longSweepCondition = low < lowestLowInLookback and close > lowestLowInLookback

bool longSignal = longSweepCondition and 
                  close > open and 
                  volumeCondition and 
                  closePositionBull >= closePercentTop and 
                  (enableLVNFilter ? f_check_lvn_validation(high, low, close, true) : true) and 
                  rangeCondition and
                  bodySizeCondition and
                  rsiLongValid and
                  not invalidateLongByConsecutiveRed

// ========== SHORT SIGNAL ==========
float highestHighInLookback = ta.highest(high[1], lookbackBars)
bool shortSweepCondition = high > highestHighInLookback and close < highestHighInLookback

bool shortSignal = shortSweepCondition and 
                   close < open and 
                   volumeCondition and 
                   closePositionBear >= closePercentTop and 
                   (enableLVNFilter ? f_check_lvn_validation(high, low, close, false) : true) and 
                   rangeCondition and
                   bodySizeCondition and
                   rsiShortValid and
                   not invalidateShortByConsecutiveGreen

// Track signals for black candle functionality
var bool wasLongSignal = false
var bool wasShortSignal = false
bool signalForming = longSignal or shortSignal

if longSignal
    wasLongSignal := true
    wasShortSignal := false
else if shortSignal
    wasShortSignal := true
    wasLongSignal := false
else
    wasLongSignal := false
    wasShortSignal := false

bool nextCandleOppositeToLong = wasLongSignal[1] and close < open
bool nextCandleOppositeToShort = wasShortSignal[1] and close > open

color barCol = na

if signalForming
    barCol := longSignal ? color.new(color.green, 20) : color.new(color.red, 20)
else if blackCandleOnOpposite and (nextCandleOppositeToLong or nextCandleOppositeToShort)
    barCol := color.black

barcolor(barCol)

plotshape(longSignal, location=location.belowbar, style=shape.triangleup, color=color.new(color.green, 0), size=size.small, text="LONG")
plotshape(shortSignal, location=location.abovebar, style=shape.triangledown, color=color.new(color.red, 0), size=size.small, text="SHORT")

alertcondition(longSignal or shortSignal, title="Sweep Signal", message="Sweep signal detected: {{ticker}} at {{close}}")
````
