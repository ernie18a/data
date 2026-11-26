# Opening Range Breakout + VWAP + Volume

- url: https://www.tradingview.com/script/SStGDNGv-Opening-Range-Breakout-VWAP-Volume/
- type: indicator
- pine_id: PUB;af01f569d79f42bd83eea3475f380240
- version: 1.0

## Description

This indicator triggers when all of the following conditions are met:

1. Price breaks above the 30-minute opening range high 
  1a. Opening Range = 9:30 am to 10:00 AM EST 
  1b. breakout = close above the high of this range 
2. Current bar volume is at least 1.5x the average volume of the opening 30 minute range 
3. Price is currently above VWAP 
4. Its within the first 2 hours of the regular session (before 11:30 AM EST)

Confirmation on buying pressure: Breakout bar closes within the top 50% of its range.

## Source Code

````pine
//@version=5
indicator("Opening Range Breakout (ORB) + VWAP + Volume", shorttitle="ORB+VWAP+Vol", overlay=true)

// ============================================================================
// INPUTS
// ============================================================================
volMultiplier = input.float(1.5,  "Volume Multiplier (x OR avg)", minval=0.1, step=0.1)
showORHLine   = input.bool(true,  "Show Opening Range High line")
showTriangle  = input.bool(true,  "Mark breakout bar with triangle")
showBgColor   = input.bool(true,  "Highlight background on signal")

// ============================================================================
// SESSION WINDOWS (America/New_York handles EST/EDT automatically)
// ============================================================================
// Opening range: 9:30 AM - 10:00 AM ET
inOpeningRange = not na(time(timeframe.period, "0930-1000", "America/New_York"))

// Trading window: 9:30 AM - 11:30 AM ET (first 2 hours of regular session)
inTradingWindow = not na(time(timeframe.period, "0930-1130", "America/New_York"))

// Detect a brand new RTH session (first bar of OR)
isNewSession = inOpeningRange and not inOpeningRange[1]

// ============================================================================
// OPENING RANGE CALCULATIONS
// ============================================================================
var float orHigh      = na   // Opening range high
var float orVolSum    = na   // Cumulative OR volume
var int   orBarCount  = na   // OR bar count (for averaging)
var float orVolAvg    = na   // Average volume per bar during OR
var bool  orLocked    = false // True once OR is finalized (after 10:00 AM)

// Reset state at the start of each new session
if isNewSession
    orHigh     := high
    orVolSum   := volume
    orBarCount := 1
    orVolAvg   := na
    orLocked   := false

// Accumulate while inside the opening range
else if inOpeningRange
    orHigh     := math.max(nz(orHigh, high), high)
    orVolSum   := nz(orVolSum) + volume
    orBarCount := nz(orBarCount) + 1

// Lock the OR the first bar after 10:00 AM
if not inOpeningRange and inOpeningRange[1]
    orVolAvg := orBarCount > 0 ? orVolSum / orBarCount : na
    orLocked := true

// Persist the locked state forward through the session
if not isNewSession and orLocked[1]
    orLocked := true

// ============================================================================
// VWAP
// ============================================================================
vwapValue = ta.vwap(hlc3)

// ============================================================================
// BREAKOUT CONDITIONS
// ============================================================================
// 1. Close breaks above OR high (and we have a valid OR)
cond_breakout = orLocked and not na(orHigh) and close > orHigh

// 2. Current bar volume >= multiplier x avg OR volume
cond_volume   = not na(orVolAvg) and volume >= orVolAvg * volMultiplier

// 3. Price above VWAP
cond_vwap     = not na(vwapValue) and close > vwapValue

// 4. Within first 2 hours of regular session, and OR is done
cond_window   = inTradingWindow and not inOpeningRange

// 5. Strong-close confirmation: close in the top 50% of the bar's range
//    (close >= midpoint of high/low → buyers held control into the close)
barMidpoint   = (high + low) / 2
cond_strongClose = close >= barMidpoint

// All conditions
signal = cond_breakout and cond_volume and cond_vwap and cond_window and cond_strongClose

// Fire only once per session (first qualifying bar)
var bool firedThisSession = false
if isNewSession
    firedThisSession := false

firstSignal = signal and not firedThisSession
if firstSignal
    firedThisSession := true

// ============================================================================
// VISUALS
// ============================================================================
// Plot the OR high as a stepped line (only while session is active and OR is locked)
plot(showORHLine and orLocked and inTradingWindow ? orHigh : na,
     title="Opening Range High", color=color.new(color.orange, 0),
     linewidth=2, style=plot.style_linebr)

// Plot VWAP for reference
plot(vwapValue, title="VWAP", color=color.new(color.blue, 0), linewidth=1)

// Triangle above the breakout bar
plotshape(showTriangle and firstSignal, title="Breakout Signal",
          location=location.abovebar, style=shape.triangleup,
          color=color.new(color.green, 0), size=size.small, text="ORB")

// Light green background when ALL conditions are met
bgcolor(showBgColor and signal ? color.new(color.green, 85) : na, title="Signal Background")

// ============================================================================
// ALERT
// ============================================================================
alertcondition(firstSignal,
     title="ORB Breakout (VWAP + Volume + Strong Close)",
     message="ORB Signal | Symbol: {{ticker}} | Price: {{close}} | Time: {{time}}")
````
