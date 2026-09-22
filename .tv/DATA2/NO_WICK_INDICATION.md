<!-- tradingview-pine-id: PUB;0e6f6ca61cbc477bad46ce2533cc02c2 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# NO WICK INDICATION

Source: https://www.tradingview.com/script/nd0MHOFp-NO-WICK-INDICATION/

## Description

NO WICK INDICATION highlights candles that have no wick on one side of the candle. The idea is that when a candle has no wick, price showed no rejection on that side during the candle. This can represent strong one-sided pressure, where buyers or sellers controlled the move with little opposition.

These no-wick areas can become important levels to watch later because they may represent aggressive buying or selling, or areas where heavy orders were present around the bid or ask. When price returns to these areas, they may become potential reaction or reversal zones.

Green dots mark qualifying green no-wick candles, while red dots mark qualifying red no-wick candles. The minimum body-size setting helps filter out smaller candles and focus on stronger moves.

RECOMMENDED SETTINGS / PRESET

Green candle with no upper wick → marker▼ above the candle.
Green candle with no lower wick → marker▲ below the candle.
Red candle with no upper wick → marker ▼ above the candle.
Red candle with no lower wick → marker▲ below the candle.

Wick Tolerance: 0 — requires a true NO WICK

Minimum Body Size: 10 points as the starting preset
For more signals, lower Minimum Body Size from 10 to 5. For stronger/larger candles only, raise it to 15, 20, or higher.

Recommended starting preset: 10 Points / 0 Wick Tolerance / All 4 No-Wick Types ON.

---

## Source Code

````pine
//@version=6
indicator("NO WICK INDICATION", shorttitle="NO WICK INDICATION", overlay=true)

//====================================================
// SETTINGS
//====================================================

minimumBodyPoints = input.float(
     10.0,
     "Minimum Candle Body Size (Points)",
     minval=0.0,
     step=0.25,
     display=display.none
)

wickToleranceTicks = input.int(
     0,
     "Wick Tolerance (Ticks)",
     minval=0,
     maxval=100,
     display=display.none
)

//====================================================
// INDIVIDUAL ON / OFF SETTINGS
//====================================================

showGreenNoUpperWick = input.bool(
     true,
     "Green No Upper Wick - Dot Above",
     display=display.none
)

showGreenNoLowerWick = input.bool(
     true,
     "Green No Lower Wick - Dot Below",
     display=display.none
)

showRedNoUpperWick = input.bool(
     true,
     "Red No Upper Wick - Dot Above",
     display=display.none
)

showRedNoLowerWick = input.bool(
     true,
     "Red No Lower Wick - Dot Below",
     display=display.none
)

//====================================================
// COLORS
//====================================================

greenColor = input.color(
     color.lime,
     "Green Dot Color",
     display=display.none
)

redColor = input.color(
     color.red,
     "Red Dot Color",
     display=display.none
)

//====================================================
// WICK TOLERANCE
//====================================================

tolerance = syminfo.mintick * wickToleranceTicks

//====================================================
// CANDLE BODY SIZE
//====================================================

bodySize = math.abs(close - open)

bodySizeOK = bodySize >= minimumBodyPoints

//====================================================
// CANDLE DIRECTION
//====================================================

greenCandle = close > open
redCandle = close < open

//====================================================
// GREEN CONDITIONS
//====================================================

// Green candle with no wick at TOP
// Close = High
greenNoUpperWick =
     greenCandle and
     bodySizeOK and
     math.abs(high - close) <= tolerance

// Green candle with no wick at BOTTOM
// Open = Low
greenNoLowerWick =
     greenCandle and
     bodySizeOK and
     math.abs(open - low) <= tolerance

//====================================================
// RED CONDITIONS
//====================================================

// Red candle with no wick at TOP
// Open = High
redNoUpperWick =
     redCandle and
     bodySizeOK and
     math.abs(high - open) <= tolerance

// Red candle with no wick at BOTTOM
// Close = Low
redNoLowerWick =
     redCandle and
     bodySizeOK and
     math.abs(close - low) <= tolerance

//====================================================
// GREEN DOTS
//====================================================

plotshape(
     showGreenNoUpperWick and greenNoUpperWick,
     title="Green No Upper Wick",
     style=shape.circle,
     location=location.abovebar,
     color=greenColor,
     size=size.tiny
)

plotshape(
     showGreenNoLowerWick and greenNoLowerWick,
     title="Green No Lower Wick",
     style=shape.circle,
     location=location.belowbar,
     color=greenColor,
     size=size.tiny
)

//====================================================
// RED DOTS
//====================================================

plotshape(
     showRedNoUpperWick and redNoUpperWick,
     title="Red No Upper Wick",
     style=shape.circle,
     location=location.abovebar,
     color=redColor,
     size=size.tiny
)

plotshape(
     showRedNoLowerWick and redNoLowerWick,
     title="Red No Lower Wick",
     style=shape.circle,
     location=location.belowbar,
     color=redColor,
     size=size.tiny
)

//====================================================
// ALERTS
//====================================================

alertcondition(
     showGreenNoUpperWick and greenNoUpperWick,
     title="Green No Upper Wick",
     message="Green candle with no upper wick and required body size detected."
)

alertcondition(
     showGreenNoLowerWick and greenNoLowerWick,
     title="Green No Lower Wick",
     message="Green candle with no lower wick and required body size detected."
)

alertcondition(
     showRedNoUpperWick and redNoUpperWick,
     title="Red No Upper Wick",
     message="Red candle with no upper wick and required body size detected."
)

alertcondition(
     showRedNoLowerWick and redNoLowerWick,
     title="Red No Lower Wick",
     message="Red candle with no lower wick and required body size detected."
)
````
