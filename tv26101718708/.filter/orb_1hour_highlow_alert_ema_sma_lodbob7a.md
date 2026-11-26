# ORB 1-Hour High/Low Alert [EMA + SMA]

- url: https://www.tradingview.com/script/lODBOB7a-ORB-1-Hour-High-Low-Alert-EMA-SMA/
- type: indicator
- pine_id: PUB;3bab65e4c14b4e0898a6d320ca0934eb
- version: 1.0

## Description

This guide is designed to help users understand and set up the ORB 1-Hour High/Low Alert indicator on TradingView.
[b]Description[/b]

[b]The ORB 1-Hour High/Low Alert [EMA + SMA] [/b] is a professional-grade momentum indicator designed for intraday traders (specifically for the Indian Market/NSE/BSE). It identifies the high and low of the first hour of trading (9:15 AM – 10:15 AM) and generates a "Long Breakout" signal when specific price, volume, and trend conditions align.

By combining the Opening Range Breakout (ORB) strategy with volume confirmation and trend filters (VWAP, EMA, and SMA), this tool helps filter out "fakeouts" and identifies high-probability trend continuation moves.
How it Works (The Strategy)

A Buy Signal (ORB BUY) is generated when the following four conditions are met simultaneously after the first hour of trade:

    Price Breakout: The current candle's close crosses above the 1-Hour High (Orange line).

    Volume Confirmation: Current candle volume is greater than the Average Volume of the first hour (multiplied by your choice of sensitivity, e.g., 1.5x).

    Trend Filter: Price must be trading above the VWAP.

    Timing: Signals only trigger after the range is fully established (after 10:15 AM IST).

[b]Usage Guide[/b]
1. Visual Legend

    Orange Line: The highest price reached between 9:15 AM and 10:15 AM.

    Purple Line: The lowest price reached between 9:15 AM and 10:15 AM.

    Yellow Line: Exponential Moving Average (EMA) – default 20.

    Blue Line: Simple Moving Average (SMA) – default 50.

    Gray Dashed Line: Volume Weighted Average Price (VWAP).

2. Key Settings

    Time Zone: Defaulted to Asia/Kolkata. Ensure your chart matches this for accurate range calculation.

    Volume Multiplier: Adjust this to control sensitivity. A value of 1.5 means the breakout candle must have 150% of the average volume of the opening hour.

    EMA/SMA Lengths: Customize these based on your preference (e.g., 9 EMA for aggressive entries or 20 EMA for conservative ones).

3. Setting Up Alerts

To get real-time notifications:

    Click the Alerts icon in TradingView.

    Select ORB 1-Hour High/Low Alert in the Condition dropdown.

    Choose ORB 1H Long Breakout.

    Set the frequency to Once Per Bar Close.

[b]Best Practices[/b]

    Timeframe: This indicator works best on 5-minute or 15-minute charts.

    Stop Loss: A common practice is to place the Stop Loss at the VWAP line or the 1-hour "Mid-point."

    Target: Look for the next major resistance level or use a trailing stop along the EMA line.

    Wait for the Close: The signal is most reliable when the candle actually closes above the orange line.

## Source Code

````pine
//@version=5
indicator("ORB 1-Hour High/Low Alert [EMA + SMA]", overlay=true, max_labels_count=500)

//==============================
// USER INPUTS
//==============================
tz             = input.string("Asia/Kolkata", "Time Zone")
volMultiplier  = input.float(1.5, "Volume Multiplier", minval=0.1, step=0.1)
showBg         = input.bool(true, "Show Light Green Background")
showTriangle   = input.bool(true, "Show Triangle Above Signal Bar")
showORHighLine = input.bool(true, "Show 1-Hour High Line (Orange)")
showORLowLine  = input.bool(true, "Show 1-Hour Low Line (Purple)")
showVWAP       = input.bool(true, "Show VWAP")

// EMA Settings
showEMA        = input.bool(true, "Show EMA", group="Moving Averages")
emaLength      = input.int(20, "EMA Length", minval=1, group="Moving Averages")
emaColor       = input.color(color.lime, "EMA Color", group="Moving Averages")

// SMA Settings
showSMA        = input.bool(true, "Show SMA", group="Moving Averages")
smaLength      = input.int(50, "SMA Length", minval=1, group="Moving Averages")
smaColor       = input.color(color.blue, "SMA Color", group="Moving Averages")

//==============================
// TIME LOGIC (9:15 AM - 10:15 AM)
//==============================
t_now    = time(timeframe.period, "0915-1015", tz)
is_range = not na(t_now)
is_after = not na(time(timeframe.period, "1015-1530", tz))

//==============================
// NEW DAY RESET
//==============================
isNewDay = ta.change(dayofmonth)

//==============================
// VARIABLES & CALCULATIONS
//==============================
var float orHigh      = na
var float orLow       = na
var float orVolSum    = 0.0
var int   orBarCount  = 0
var float orAvgVolume = na
var bool  breakoutArmed = true

if isNewDay
    orHigh         := na
    orLow          := na
    orVolSum       := 0.0
    orBarCount     := 0
    orAvgVolume    := na
    breakoutArmed  := true

// 1-Hour Range logic
if is_range
    orHigh     := na(orHigh) ? high : math.max(orHigh, high)
    orLow      := na(orLow) ? low : math.min(orLow, low) 
    orVolSum   += volume
    orBarCount += 1

if is_after and na(orAvgVolume) and orBarCount > 0
    orAvgVolume := orVolSum / orBarCount

// Technical Indicators
vwapValue = ta.vwap(hlc3)
emaValue  = ta.ema(close, emaLength)
smaValue  = ta.sma(close, smaLength)

//==============================
// SIGNAL LOGIC
//==============================
if not na(orHigh) and close < orHigh
    breakoutArmed := true

breakoutCondition = not na(orHigh) and ta.crossover(close, orHigh)
volumeCondition   = not na(orAvgVolume) and volume >= (volMultiplier * orAvgVolume)
vwapCondition     = close > vwapValue
timeCondition     = is_after

signal = breakoutArmed and breakoutCondition and volumeCondition and vwapCondition and timeCondition

if signal
    breakoutArmed := false

//==============================
// VISUALS
//==============================
// Range High/Low
plot(showORHighLine and not na(orHigh) ? orHigh : na, title="1-Hour High", color=color.orange, linewidth=2, style=plot.style_linebr)
plot(showORLowLine and not na(orLow) ? orLow : na, title="1-Hour Low", color=color.purple, linewidth=2, style=plot.style_linebr)

// Moving Averages & VWAP
plot(showVWAP ? vwapValue : na, title="VWAP", color=color.new(color.black, 65), linewidth=2)
plot(showEMA ? emaValue : na, title="EMA", color=emaColor, linewidth=1)
plot(showSMA ? smaValue : na, title="SMA", color=smaColor, linewidth=1)

// Signal Visuals
bgcolor(showBg and signal ? color.new(color.lime, 85) : na, title="Signal Background")
plotshape(showTriangle and signal, title="ORB Breakout Signal", style=shape.triangleup, location=location.abovebar, size=size.small, color=color.lime, text="ORB BUY")

//==============================
// ALERT
//==============================
alertcondition(signal, title="ORB 1H Long Breakout", message="1-Hour ORB breakout on {{ticker}} at {{close}}.")
````
