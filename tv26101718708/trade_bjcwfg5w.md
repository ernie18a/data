# Trade

- url: https://www.tradingview.com/script/BJcWfG5w-Trade/
- type: indicator
- pine_id: PUB;40454123041b4aa2b6634afaf24fceef
- version: 1.0

## Description

Good indicator, can use EMA's for entries, Supertrend for direction, and has session color borders.

## Source Code

````pine
//@version=6
indicator("Trade", overlay=true)


// === EMA SOURCE OPTIONS ===
emaSource23 = input.string("High", title="23 EMA Source", options=["Open", "Close", "High", "Low"])
emaSource12 = input.string("Close", title="12 EMA Source", options=["Open", "Close", "High", "Low"])

// 23 EMA Calculation with dynamic source
ema23 = switch emaSource23
    "Open" => ta.ema(open, 23)
    "High" => ta.ema(high, 23)
    "Low" => ta.ema(low, 23)
    => ta.ema(close, 23)  // Default to Close

plot(ema23, title="23 EMA", color=color.new(color.white, 75), linewidth=1)

// 12 EMA Calculation with dynamic source
ema12 = switch emaSource12
    "Open" => ta.ema(open, 12)
    "High" => ta.ema(high, 12)
    "Low" => ta.ema(low, 12)
    => ta.ema(close, 12)  // Default to Close

plot(ema12, title="12 EMA", color=color.new(color.white, 89), linewidth=1, style=plot.style_steplinebr)

// === INPUT PARAMETERS ===
atrLength = input(23, title="ATR Length")
supertrendFactor = input(3, title="Supertrend Factor")  // Adjusted to be more sensitive

// === ATR CALCULATION ===
atrValue = ta.atr(atrLength)

// === SUPER TREND CALCULATION ===
[supertrend, direction] = ta.supertrend(supertrendFactor, atrLength)

// === SUPER TREND PLOTS WITH COLOR CHANGES ===
upTrend = plot(direction < 0 ? supertrend : na, "Up Trend", color=color.rgb(79, 161, 82, 65), style=plot.style_linebr, linewidth=2)
downTrend = plot(direction < 0 ? na : supertrend, "Down Trend", color=color.rgb(237, 26, 26, 81), style=plot.style_linebr, linewidth=2)

//("Market Session Backgrounds & Labels", overlay=true)
hourGMT = hour(time, "GMT")
sessionLondon = (hourGMT >= 8 and hourGMT < 16)
sessionNY = (hourGMT >= 13 and hourGMT < 21)
sessionTokyo = (hourGMT >= 0 and hourGMT < 9)

// === BACKGROUND COLORS ===
bgcolor(sessionLondon ? color.new(color.green, 90) : na)
bgcolor(sessionNY ? color.new(color.gray, 90) : na)
bgcolor(sessionTokyo ? color.new(color.blue, 90) : na)

// === SESSION LABELS ===
var label sessionLabel = na
showSessionLabels = input.bool(true, title="Show Session Labels")

if showSessionLabels
    if not na(sessionLabel)
        label.delete(sessionLabel)

    sessionLabelText = sessionLondon ? "London Session" :
                       sessionNY ? "New York Session" :
                       sessionTokyo ? "Tokyo Session" : "No Active Session"

    sessionColor = sessionLondon ? color.green :
                   sessionNY ? color.gray :
                   sessionTokyo ? color.rgb(103, 139, 168) : na

    if sessionLabelText != "No Active Session"
        sessionLabel := label.new(x=bar_index, 
                                  y=high + atrValue * 1.5, 
                                  text=sessionLabelText, 
                                  style=label.style_label_down, 
                                  color=sessionColor, 
                                  textcolor=color.white, 
                                  size=size.normal)
````
