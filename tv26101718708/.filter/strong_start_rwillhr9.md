# STRONG START

- url: https://www.tradingview.com/script/RwiLLHr9-STRONG-START/
- type: indicator
- pine_id: PUB;bc652c72b51347c1b3ff7b78f02ee3d8
- version: 1.0

## Description

Signal if ANY ONE of these is true on the first 5-minute candle:

Condition 1: Gap-Up

Today's open is at least X% above yesterday's close.
(Default: 0.1%)

OR

Condition 2: Open = Low

The first 5-minute candle's low is within Y% of the day's open.
(Default: 0.5%)

## Source Code

````pine
//@version=6
indicator("Gap-Up OR Open=Low (First 5 Min)", overlay=true)

// ===== USER INPUTS =====
gapUpPct = input.float(0.1, "Minimum Gap-Up (%)", step=0.1)
openLowTolerance = input.float(0.5, "Open=Low Tolerance (%)", step=0.1)

shapeColor = input.color(color.lime, "Shape Color")

shapeType = input.string(
     "Triangle",
     "Shape Type",
     options = ["Triangle", "Circle", "Square", "Diamond"]
)

// ===== IDENTIFY FIRST BAR OF DAY =====
isNewDay = ta.change(time("D")) != 0

// ===== CONDITIONS =====
gapPct = (open - close[1]) / close[1] * 100

gapUpSignal = isNewDay and gapPct >= gapUpPct

openLowSignal = isNewDay and ((open - low) / open * 100 <= openLowTolerance)

// ===== OR CONDITION =====
signal = gapUpSignal or openLowSignal

// ===== SHAPES =====
plotshape(signal and shapeType == "Triangle",
     style=shape.triangleup,
     location=location.belowbar,
     color=shapeColor,
     size=size.small,
     title="Triangle")

plotshape(signal and shapeType == "Circle",
     style=shape.circle,
     location=location.belowbar,
     color=shapeColor,
     size=size.small,
     title="Circle")

plotshape(signal and shapeType == "Square",
     style=shape.square,
     location=location.belowbar,
     color=shapeColor,
     size=size.small,
     title="Square")

plotshape(signal and shapeType == "Diamond",
     style=shape.diamond,
     location=location.belowbar,
     color=shapeColor,
     size=size.small,
     title="Diamond")

// ===== ALERT =====
alertcondition(signal,
     title="Gap-Up OR Open=Low",
     message="Stock satisfies Gap-Up OR Open=Low condition")
````
