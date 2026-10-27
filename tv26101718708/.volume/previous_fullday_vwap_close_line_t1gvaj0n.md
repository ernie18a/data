# Previous Full-Day VWAP Close Line

- url: https://www.tradingview.com/script/T1Gvaj0n-Previous-Full-Day-VWAP-Close-Line/
- type: indicator
- pine_id: PUB;4f6a84bd2228433da281e75137d51176
- version: 1.0

## Description

Previous Full-Day VWAP Close Line
Previous Full-Day VWAP Close Line
Previous Full-Day VWAP Close Line
Previous Full-Day VWAP Close Line
Previous Full-Day VWAP Close Line
Previous Full-Day VWAP Close Line
Previous Full-Day VWAP Close Line

## Source Code

````pine
//@version=6
indicator("Previous Full-Day VWAP Close Line", overlay = true, max_lines_count = 100, max_labels_count = 100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priceSource = input.string(
     "HLC3",
     "VWAP Price Source",
     options = ["Close", "HL2", "HLC3", "OHLC4"]
)

showCurrentDayVWAP = input.bool(false, "Show Current Full-Day VWAP")
showPrevLine       = input.bool(true, "Show Previous Full-Day VWAP Close")
showLabel          = input.bool(true, "Show Label")

lineColor = input.color(color.yellow, "Previous VWAP Close Line Color")
currColor = input.color(color.new(color.white, 0), "Current VWAP Color")

lineWidth = input.int(2, "Line Width", minval = 1, maxval = 5)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Daily anchor logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
newDay = ta.change(time("D")) != 0

src =
     priceSource == "Close" ? close :
     priceSource == "HL2"   ? hl2 :
     priceSource == "HLC3"  ? hlc3 :
     ohlc4

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Full-day VWAP calculation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float cumPV = 0.0
var float cumV  = 0.0

var float currentDayVWAP = na
var float prevDayVWAPClose = na

// Save yesterday's final full-day VWAP before resetting.
if newDay
    prevDayVWAPClose := currentDayVWAP
    cumPV := 0.0
    cumV  := 0.0

if volume > 0
    cumPV += src * volume
    cumV  += volume

currentDayVWAP := cumV > 0 ? cumPV / cumV : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plot previous day VWAP close as line
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showPrevLine ? prevDayVWAPClose : na, "Previous Full-Day VWAP Close", color = lineColor, linewidth = lineWidth, style = plot.style_linebr)

plot(showCurrentDayVWAP ? currentDayVWAP : na, "Current Full-Day VWAP", color = currColor, linewidth = 1)
````
