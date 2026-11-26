# Breakout Quality Scanner

- url: https://www.tradingview.com/script/OiVhEFoG-Breakout-Quality-Scanner/
- type: indicator
- pine_id: PUB;8bf8e22ef22b4c71bf1dd2a87b4a38c2
- version: 1.0

## Description

Breakout Quality Scanner, Volume-Graded Breakouts with Continuation Tracking
 
Not all breakouts are equal. This indicator grades every breakout by volume quality and then monitors the next 2 bars to tell you if the breakout is holding or failing.
 
🔍 What it does
 
Detects breakouts from a 20-bar range (roughly 1 month on daily charts). When price closes above the range high or below the range low, the indicator fires a signal and immediately grades the breakout quality based on volume.
 
After the breakout, it watches the next 2 bars for either continuation or warning signs, so you know whether to trust the breakout or be cautious.
 
Breakout Grading
 
Strong Breakout (green for longs, red for shorts): Volume is above the 20-bar average. Shows the volume ratio (e.g., "Vol: 1.8x"). Institutional participation is present. Higher probability of follow-through.
 
Caution Breakout (yellow): Volume is below average. The breakout happened but conviction is weak. Needs confirmation in the following days. Many failed breakouts start here.
 
✓ Continuation Confirmed (blue checkmark): After the breakout, price held above the breakout level for 2 bars with no rejection. Volume stayed calm. The breakout is real.
 
⚠ Warning Signal (red warning): After the breakout, a rejection candle appeared, large wick, red day, rising volume. Sellers stepped in. The breakout is likely failing. Also triggers if price closes back below the breakout bar's low.
 
Settings
 
Range Length: Default 20. Defines how many bars form the range. Higher = bigger breakouts, fewer signals.
 
Cooldown: Default 5. Minimum bars between signals to prevent clustering on the same move.
 
Volume MA Length: Default 20. Baseline for volume comparison.
 
Monitoring Window: Default 2. How many bars after the breakout to watch for continuation or warning.
 
Rejection Wick Ratio: Default 0.5. How large the wick needs to be relative to the candle range to trigger a warning. Lower = more sensitive.
 
Recommended settings by timeframe:
- Daily: Range 20, Cooldown 5 (default)
- Weekly: Range 10, Cooldown 3
 
Alerts
 
Built-in alert conditions for: Strong Bullish Breakout, Strong Bearish Breakout, Caution Breakout, Warning Signal, and Continuation Confirmed. Set up TradingView notifications to catch breakouts in real time.
 
How to use it
 
The strongest setups are strong breakouts (above-average volume) followed by a blue checkmark continuation. These breakouts have both the initial conviction and the follow-through.
 
Be cautious with yellow "Low Vol" breakouts many of these fail. Wait for the continuation checkmark before committing.
 
If you see the red warning signal after any breakout, the move is likely failing. Consider avoiding or exiting.
 
Pairs well with RSI divergence analysis. A strong volume breakout with no RSI divergence is the highest quality setup. A low-volume breakout with bearish RSI divergence is the lowest.
 
Important
 
This indicator identifies breakout events and grades their quality. It is not a complete trading system you should use it alongside your own analysis, risk management, and other tools. Not financial advice.

## Source Code

````pine
//@version=5
indicator("Breakout Quality Scanner", shorttitle="BQ Scanner", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================
// INPUTS
// ============================================================
rangeLen    = input.int(20, "Range Length (bars)", minval=10, maxval=100, group="Breakout Detection", tooltip="How many bars to define the range. 20 = roughly 1 month on daily.")
cooldownLen = input.int(5, "Cooldown (bars)", minval=2, maxval=20, group="Breakout Detection", tooltip="Minimum bars between breakout signals to avoid clustering.")
volLen      = input.int(20, "Volume MA Length", minval=5, maxval=50, group="Volume Settings")
monitorBars = input.int(2, "Monitoring Window (bars)", minval=1, maxval=5, group="Continuation Check", tooltip="How many bars after breakout to monitor for continuation or warning.")
rejectionWickRatio = input.float(0.5, "Rejection Wick Ratio", minval=0.2, maxval=0.8, step=0.05, group="Continuation Check", tooltip="If upper wick is this proportion of the candle range, it's a rejection.")

// Colors
strongCol   = input.color(color.rgb(0, 230, 118), "Strong Breakout", group="Colors")
cautionCol  = input.color(color.rgb(255, 193, 7), "Caution Breakout", group="Colors")
warningCol  = input.color(color.rgb(255, 82, 82), "Warning Signal", group="Colors")
continueCol = input.color(color.rgb(0, 176, 255), "Continuation Confirmed", group="Colors")

// ============================================================
// CORE CALCULATIONS
// ============================================================
volMA = ta.sma(volume, volLen)

// Range high/low — look at the range BEFORE the current bar
rangeHigh = ta.highest(high, rangeLen)[1]
rangeLow  = ta.lowest(low, rangeLen)[1]

// ============================================================
// BREAKOUT DETECTION
// ============================================================
// Bullish breakout: close above range high
// Bearish breakout: close below range low
bullBreak = close > rangeHigh
bearBreak = close < rangeLow

// Cooldown — prevent signals from clustering
var int lastBreakBar = 0
cooldownOk = bar_index - lastBreakBar >= cooldownLen

// Volume assessment on breakout bar
volAboveAvg = volume >= volMA
volRatio = volMA > 0 ? volume / volMA : 0

// Final breakout signals with cooldown
bullSignal = bullBreak and cooldownOk
bearSignal = bearBreak and cooldownOk

// ============================================================
// BREAKOUT QUALITY GRADING
// ============================================================
// Strong: volume above average on breakout bar
// Caution: volume below average on breakout bar — needs continuation

var int   breakDir     = 0     // 1 = bull, -1 = bear, 0 = none
var float breakPrice   = na    // breakout bar close
var float breakHigh    = na    // breakout bar high
var float breakLow     = na    // breakout bar low
var int   breakBarIdx  = 0     // bar index of breakout
var bool  breakStrong  = false // volume was above average
var int   monitorCount = 0     // bars since breakout
var bool  resolved     = true  // whether we've given a verdict

// New breakout detected
if (bullSignal or bearSignal) and resolved
    breakDir     := bullSignal ? 1 : -1
    breakPrice   := close
    breakHigh    := high
    breakLow     := low
    breakBarIdx  := bar_index
    breakStrong  := volAboveAvg
    monitorCount := 0
    resolved     := false
    lastBreakBar := bar_index

// Count bars after breakout
if not resolved and bar_index > breakBarIdx
    monitorCount += 1

// ============================================================
// CONTINUATION / WARNING ANALYSIS
// ============================================================
// Analyze the bars AFTER the breakout during the monitoring window

// For bullish breakouts:
// WARNING: red day with rejection wick + rising volume = sellers stepping in
// CONTINUATION: holds above breakout level, no major pullback, volume steady or declining

// For bearish breakouts:
// WARNING: green day with lower wick rejection + rising volume = buyers stepping in
// CONTINUATION: stays below breakout level, no major bounce, volume steady or declining

candleRange  = high - low
upperWick    = high - math.max(open, close)
lowerWick    = math.min(open, close) - low
isRedDay     = close < open
isGreenDay   = close > open
volRising    = volume > volume[1] and volume > volMA

// Rejection detection
bullRejection = isRedDay and candleRange > 0 and (upperWick / candleRange) >= rejectionWickRatio and volRising
bearRejection = isGreenDay and candleRange > 0 and (lowerWick / candleRange) >= rejectionWickRatio and volRising

// Continuation detection
bullContinuation = not isRedDay and close >= breakPrice and volume <= volMA * 1.5
bearContinuation = not isGreenDay and close <= breakPrice and volume <= volMA * 1.5

// Price holding breakout level
bullHolding = close > breakPrice * 0.98  // within 2% of breakout price
bearHolding = close < breakPrice * 1.02

// ============================================================
// VERDICT SIGNALS
// ============================================================
var bool showWarning      = false
var bool showContinuation = false
showWarning      := false
showContinuation := false

if not resolved and monitorCount >= 1 and monitorCount <= monitorBars
    if breakDir == 1
        // Bullish breakout monitoring
        if bullRejection or close < breakLow
            showWarning  := true
            resolved     := true
        else if monitorCount == monitorBars and bullHolding and not bullRejection
            showContinuation := true
            resolved         := true
    
    if breakDir == -1
        // Bearish breakout monitoring
        if bearRejection or close > breakHigh
            showWarning  := true
            resolved     := true
        else if monitorCount == monitorBars and bearHolding and not bearRejection
            showContinuation := true
            resolved         := true

// Force resolve if monitoring window passed without verdict
if not resolved and monitorCount > monitorBars
    resolved := true

// ============================================================
// PLOTTING — BREAKOUT BAR
// ============================================================
// Strong breakout — volume above average
bullStrong = bullSignal and volAboveAvg
bearStrong = bearSignal and volAboveAvg

// Caution breakout — volume below average
bullCaution = bullSignal and not volAboveAvg
bearCaution = bearSignal and not volAboveAvg

// Breakout labels
atrVal = ta.atr(14)

if bullStrong
    label.new(bar_index, low - atrVal * 0.8, "BREAKOUT\nVol: " + str.tostring(math.round(volRatio, 1)) + "x", style=label.style_label_up, color=strongCol, textcolor=color.black, size=size.small)

if bullCaution
    label.new(bar_index, low - atrVal * 0.8, "BREAKOUT\nLow Vol", style=label.style_label_up, color=cautionCol, textcolor=color.black, size=size.small)

if bearStrong
    label.new(bar_index, high + atrVal * 0.8, "BREAKOUT\nVol: " + str.tostring(math.round(volRatio, 1)) + "x", style=label.style_label_down, color=warningCol, textcolor=color.white, size=size.small)

if bearCaution
    label.new(bar_index, high + atrVal * 0.8, "BREAKOUT\nLow Vol", style=label.style_label_down, color=cautionCol, textcolor=color.black, size=size.small)

// ============================================================
// PLOTTING — CONTINUATION / WARNING VERDICTS
// ============================================================
if showWarning and breakDir == 1
    label.new(bar_index, high + atrVal * 0.5, "⚠", style=label.style_none, textcolor=warningCol, size=size.large)

if showWarning and breakDir == -1
    label.new(bar_index, low - atrVal * 0.5, "⚠", style=label.style_none, textcolor=warningCol, size=size.large)

if showContinuation and breakDir == 1
    label.new(bar_index, low - atrVal * 0.5, "✓", style=label.style_none, textcolor=continueCol, size=size.large)

if showContinuation and breakDir == -1
    label.new(bar_index, high + atrVal * 0.5, "✓", style=label.style_none, textcolor=continueCol, size=size.large)

// ============================================================
// RANGE VISUALIZATION
// ============================================================
// Draw the range high/low as a subtle box
var line rangeHighLine = na
var line rangeLowLine  = na

if barstate.islast
    if not na(rangeHighLine)
        line.delete(rangeHighLine)
    if not na(rangeLowLine)
        line.delete(rangeLowLine)
    rangeHighLine := line.new(bar_index - rangeLen, rangeHigh, bar_index, rangeHigh, color=color.new(color.white, 60), style=line.style_dashed, width=1)
    rangeLowLine  := line.new(bar_index - rangeLen, rangeLow, bar_index, rangeLow, color=color.new(color.white, 60), style=line.style_dashed, width=1)

// ============================================================
// ALERTS
// ============================================================
alertcondition(bullStrong, title="Strong Bull Breakout", message="Strong bullish breakout with above-average volume")
alertcondition(bearStrong, title="Strong Bear Breakout", message="Strong bearish breakout with above-average volume")
alertcondition(bullCaution or bearCaution, title="Caution Breakout", message="Breakout detected but volume below average — watch for continuation")
alertcondition(showWarning, title="Breakout Warning", message="Breakout showing warning signs — rejection or failed continuation")
alertcondition(showContinuation, title="Continuation Confirmed", message="Breakout holding — continuation confirmed")
````
