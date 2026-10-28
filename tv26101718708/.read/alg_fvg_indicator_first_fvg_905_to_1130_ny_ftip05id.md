# ALG FVG Indicator (First FVG 9:05 to 11:30 NY)

- url: https://www.tradingview.com/script/FTIP05iD-ALG-FVG-Indicator-First-FVG-9-05-to-11-30-NY/
- type: indicator
- pine_id: PUB;5a9d498b268440e7817c6f73a6f980b8
- version: 1.0

## Description

**ALG First FVG Indicator**

Marks the **first 5-minute Fair Value Gap (FVG)** formed during the asian session between **9:05 PM and 11:30 PM (EST)**.
Draws a fixed FVG rectangle (bullish or bearish) and provides an alert when the setup appears, helping traders quickly identify the earliest imbalance opportunity of the session.

## Source Code

````pine
//@version=6
indicator("ALG FVG Indicator (First FVG 9:05 to 11:30 NY)", overlay=true)

// =====================
// INPUTS
// =====================
fvgWindow = input.session("2105-2330", "Valid FVG Window (New York)")

// =====================
// SESSION FILTER
// =====================
validFVGWindow = not na(time(timeframe.period, fvgWindow, "America/New_York"))

// =====================
// STATE VARIABLES
// =====================
var bool fvgFound = false
var float fvgHigh = na
var float fvgLow  = na
var string fvgDirection = ""
var box fvgBox = na

// Alert trigger
var bool fvgAlert = false

// =====================
// DAILY RESET
// =====================
if ta.change(time("D")) != 0
    fvgFound := false
    fvgHigh := na
    fvgLow := na
    fvgDirection := ""
    fvgAlert := false

    if not na(fvgBox)
        box.delete(fvgBox)
        fvgBox := na

// Reset alert each bar
fvgAlert := false

// =====================
// FVG DETECTION (ICT 3-CANDLE)
// =====================
bullishFVG = high[2] < low
bearishFVG = low[2] > high

// =====================
// CAPTURE FIRST VALID FVG
// =====================
if validFVGWindow and not fvgFound and barstate.isconfirmed
    if bullishFVG
        fvgHigh := low
        fvgLow  := high[2]
        fvgDirection := "Bullish"
        fvgFound := true
        fvgAlert := true

        fvgBox := box.new(
            left = bar_index,
            right = bar_index + 1,
            top = fvgHigh,
            bottom = fvgLow,
            border_color = color.green,
            bgcolor = color.new(color.green, 85)
        )

    else if bearishFVG
        fvgHigh := low[2]
        fvgLow  := high
        fvgDirection := "Bearish"
        fvgFound := true
        fvgAlert := true

        fvgBox := box.new(
            left = bar_index,
            right = bar_index + 1,
            top = fvgHigh,
            bottom = fvgLow,
            border_color = color.red,
            bgcolor = color.new(color.red, 85)
        )

// =====================
// EXTEND BOX
// =====================
if not na(fvgBox)
    box.set_right(fvgBox, bar_index)

// =====================
// ALERT CONDITION (FOR UI)
// =====================
alertcondition(
    fvgAlert,
    title="ALG First FVG Detected",
    message="ALG: {{ticker}} {{interval}} First {{strategy.order.action}} FVG formed in session"
)

// =====================
// OPTIONAL: DIRECTIONAL ALERT MESSAGE
// =====================
if fvgAlert
    alert("ALG FVG: " + fvgDirection + " FVG formed on " + syminfo.ticker + " " + timeframe.period, alert.freq_once_per_bar_close)
````
