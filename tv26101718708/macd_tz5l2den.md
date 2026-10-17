# MACD+++

- url: https://www.tradingview.com/script/TZ5l2dEn-MACD/
- type: indicator
- pine_id: PUB;0dc1966f69464cf780ecf8e069ca4d87
- version: 2.0

## Description

Pang Malakasan, This is for confirmation TRBO and TLSBD

## Source Code

````pine
//@version=6
indicator("Moving Average Convergence Divergence", "MACD", timeframe = "", timeframe_gaps = true)

// Inputs
float  sourceInput  = input.source(close, "Source")
int    fastLenInput = input.int(12, "Fast length",   1)
int    slowLenInput = input.int(26, "Slow length",   1)
int    sigLenInput  = input.int(9,  "Signal length", 1)
string oscTypeInput = input.string("EMA", "Oscillator MA type", ["EMA", "SMA"], display = display.none)
string sigTypeInput = input.string("EMA", "Signal MA type",     ["EMA", "SMA"], display = display.none)

// MA function
ma(float source, int length, simple string maType) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)

// MACD calculations
float maFast = ma(sourceInput, fastLenInput, oscTypeInput)
float maSlow = ma(sourceInput, slowLenInput, oscTypeInput)
float macd   = maFast - maSlow
float signal = ma(macd, sigLenInput, sigTypeInput)
float hist   = macd - signal

// Histogram colors
color hColor = hist >= 0 ? hist > hist[1] ? #26a69a : #b2dfdb : hist > hist[1] ? #ffcdd2 : #ff5252

// Plot MACD
hline(0, "Zero", #787b8680)
plot(hist, "Histogram", hColor, style = plot.style_columns)
plot(macd, "MACD")
plot(signal, "Signal line", #ff6d00)


// ===============================
//  FIXED PLACEMENT CIRCLES & PLUS BASED ON CROSS POSITION
// ===============================

// MACD ↔ Signal crosses
bullCross = ta.crossover(macd, signal)
bearCross = ta.crossunder(macd, signal)

// Zero line regime change
bullZero = ta.crossover(macd, 0)
bearZero = ta.crossunder(macd, 0)

// Fixed levels for visual placement
circleLevelAbove = 0.01   // Circle above zero
circleLevelBelow = -0.01  // Circle below zero
plusLevelOffset  = 0.01   // Plus sign offset above/below circle

// CIRCLES = Bull/Bear crosses
// Bullish Cross - top when MACD > 0
plotshape(
     bullCross and macd > 0 ? 1 : na,
     title="Bullish Cross Top",
     style=shape.xcross,
     location=location.top,
     size=size.small,
     color=color.lime
)

// Bullish Cross - bottom when MACD <= 0
plotshape(
     bullCross and macd <= 0 ? 1 : na,
     title="Bullish Cross Bottom",
     style=shape.xcross,
     location=location.bottom,
     size=size.small,
     color=color.lime
)

// Bearish Cross - top when MACD > 0
plotshape(
     bearCross and macd > 0 ? 1 : na,
     title="Bearish Cross Top",
     style=shape.xcross,
     location=location.top,
     size=size.small,
     color=color.red
)

// Bearish Cross - bottom when MACD <= 0
plotshape(
     bearCross and macd <= 0 ? 1 : na,
     title="Bearish Cross Bottom",
     style=shape.xcross,
     location=location.bottom,
     size=size.small,
     color=color.red
)
plusTopFixed = 1.0    // pinned near top of pane
plusBottomFixed = -1.0 // pinned near bottom of pane
// Bullish Zero-line Cross (MACD > 0) → fixed top, slightly above circle
plotshape(
     bullZero ? 1 : na,
     title="MACD Crossed Above Zero",
     style=shape.triangleup,
     location=location.top,  // pinned to top of pane
     size=size.small,
     color=color.lime
)

// Bearish Zero-line Cross (MACD <= 0) → fixed bottom, slightly below circle
plotshape(
     bearZero ? 1 : na,
     title="MACD Crossed Below Zero",
     style=shape.triangledown,
     location=location.bottom,  // pinned to bottom of pane
     size=size.small,
     color=color.red
)


// 1. MACD Green Weakening (Histogram still green but decreasing)
greenWeakening = hist > 0 and hist < hist[1]

// 2. MACD Red Weakening (Histogram still red but increasing)
redWeakening = hist < 0 and hist > hist[1]

// 3. MACD Green Strengthening (Histogram green and increasing)
greenStrengthening = hist > 0 and hist > hist[1]

// 4. MACD Red Strengthening (Histogram red and getting stronger down)
redStrengthening = hist < 0 and hist < hist[1]

// 5. MACD Bullish Cross Above 0
bullCrossAboveZero = ta.crossover(macd, signal) and macd > 0

// 6. MACD Bearish Cross Below 0
bearCrossBelowZero = ta.crossunder(macd, signal) and macd < 0

// 7. MACD Line Crossed Above 0
macdCrossAboveZero = ta.crossover(macd, 0)

// 8. MACD Line Crossed Below 0
macdCrossBelowZero = ta.crossunder(macd, 0)


// ALERTS
alertcondition(greenWeakening, "MACD Green Weakening", "MACD histogram green but weakening")

alertcondition(redWeakening, "MACD Red Weakening", "MACD histogram red but weakening")

alertcondition(greenStrengthening, "MACD Green Strengthening", "MACD histogram green and strengthening")

alertcondition(redStrengthening, "MACD Red Strengthening", "MACD histogram red and strengthening")

alertcondition(bullCrossAboveZero, "MACD Bullish Cross Above 0 Line", "MACD bullish cross above zero line")

alertcondition(bearCrossBelowZero, "MACD Bearish Cross Below 0 Line", "MACD bearish cross below zero line")

alertcondition(macdCrossAboveZero, "MACD Line Crossed Above 0 Line", "MACD line crossed above zero line")

alertcondition(macdCrossBelowZero, "MACD Line Crossed Below 0 Line", "MACD line crossed below zero line")
````
