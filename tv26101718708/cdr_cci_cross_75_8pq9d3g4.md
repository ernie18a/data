# CDR CCI Cross 75

- url: https://www.tradingview.com/script/8PQ9d3g4-CDR-CCI-Cross-75/
- type: indicator
- pine_id: PUB;bbfbcf55e5c44b438aa7b0ad7b47fb21
- version: 1.0

## Description

shows CCI crossing through 75 going higher and nothing else - puts arrows on indicator when triggered

## Source Code

````pine
//@version=6
indicator("CDR CCI Cross 75", shorttitle="CDR CCI Cross 75", overlay=false)

//this is for scanner - 6-22-26

// Inputs
length = input.int(20, "CCI Length")

// CCI Calculation
cci = ta.cci(hlc3, length)

// Crossover condition
crossUp75 = cci[1] < 75 and cci >= 75

// Plot for visual confirmation (in indicator pane)
plot(cci, "CCI", color=color.blue)
hline(75, "75 Level", color=color.red, linestyle=hline.style_dashed)

// Signal
plotshape(crossUp75, title="Cross Up", style=shape.triangleup, location=location.bottom, color=color.green, size=size.normal, text="75↑")

// For Screener
alertcondition(crossUp75, title="CCI Cross Up 75", message="CCI crossed above 75")

// Output for scanner (this is what the screener uses)
plot(crossUp75 ? 1 : 0, "Signal", display=display.none)
````
