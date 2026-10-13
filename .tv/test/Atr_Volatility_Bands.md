<!-- tradingview-pine-id: PUB;fddcbf939e6b4d78b4450ce077fe567f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Atr Volatility Bands

Source: https://www.tradingview.com/script/AltueKKa-Atr-Volatility-Bands/

## Description

Atr Volatility Bands

Atr Volatility Bands is an ATR-based trend and volatility indicator designed to provide a clear visual view of market direction, volatility, and changing price conditions.

The indicator combines a smoothed ATR Trail with an additional ATR-based outer band and a dynamic three-color gradient. The ATR Trail adapts to market volatility and changes direction when price moves through the calculated volatility levels.

The gradient continuously changes based on the position of price within the ATR bands, creating a smooth visual transition between different market conditions. The same gradient is also applied to the candles, making trend and momentum changes easier to recognize directly on the chart.

Main Settings

• Adaptive ATR Trail
Tracks the current market direction while adapting to changing volatility.

• ATR Outer Band
Provides additional volatility context around the main ATR Trail.

• Dynamic Color Gradient
Uses a smooth purple, blue, and cyan transition based on price position within the ATR range.

• Trend Shift Detection
Helps visually identify when the current market direction changes.

• Gradient Bar Coloring
Colors candles according to the current ATR-based market condition.

• Sensitivity
Adjusts the responsiveness of the ATR calculations.

• Gradient Smoothness
Controls how smoothly the color transitions respond to price changes.

Atr Volatility Bands is designed to keep the chart clean while providing an intuitive view of trend direction, volatility, and price movement.

Use the indicator together with your preferred market structure, price action, and confirmation tools. It is not intended to be used as a standalone buy or sell signal.

---

## Source Code

````pine
//@version=6
indicator('Atr Volatility Bands', overlay = true, max_labels_count = 500)

// Atr Trail
getBandOffsetSource(srcIn, isUpperBand) =>
    ret = close
    switch srcIn
        'close' => 
    	    ret := close
    	    ret
        'wicks' => 
    	    ret := isUpperBand ? high : low
    	    ret
        => 
    	    ret := close
    	    ret
    ret

getAtrTrail(float scaledATR) =>
    upperATRBand = getBandOffsetSource('close', true) + scaledATR
    lowerATRBand = getBandOffsetSource('close', false) - scaledATR
    var b = 0.
    var pos = 1
    upper = ta.sma(upperATRBand, 10)
    lower = ta.sma(lowerATRBand, 10)
    upper := ta.ema(upper, 5)
    lower := ta.ema(lower, 5)
    if pos == 1
        b := lower
        b
    if pos == -1
        b := upper
        b
    if pos == 1 and close < lower
        pos := -1
        b := upper
        b
    if pos == -1 and close > upper
        pos := 1
        b := lower
        b
    b

// Inputs
Atrsens = input.int(6, 'Sensitivity', minval = 1)
gradientSmoothLength = input.int(8, 'Gradient Smoothness', minval = 1)

// ATR settings
atrlen = Atrsens == 1 ? 3 : Atrsens == 2 ? 5 : Atrsens == 3 ? 7 : 2
atrmul = Atrsens * 0.5

// ATR
scaleatr = ta.atr(atrlen) * atrmul

// Atr Trail
supert = getAtrTrail(scaleatr)

// Second ATR band
atrs = ta.atr(atrlen * 5)
float supert2 = na
supert2 := close > supert ? supert + atrs : close < supert ? supert - atrs : supert

// Gradient colors
bullCol = #871ee9
midCol  = #1e98e9
bearCol = #0df1c6

// Smoothed ATR bands
upperATRBand = close + scaleatr
lowerATRBand = close - scaleatr

upperBand = ta.sma(upperATRBand, 10)
lowerBand = ta.sma(lowerATRBand, 10)

upperBand := ta.ema(upperBand, 5)
lowerBand := ta.ema(lowerBand, 5)

// Price position inside ATR bands
bandRange = upperBand - lowerBand
gradientValue = bandRange != 0 ? (close - lowerBand) / bandRange * 100 : 50
gradientValue := math.max(0, math.min(100, gradientValue))

// Smooth gradient
gradientSmooth = ta.ema(gradientValue, gradientSmoothLength)

// 3-color smooth gradient
gradientCol = gradientSmooth <= 50 ? color.from_gradient(gradientSmooth, 0, 50, bullCol, midCol) : color.from_gradient(gradientSmooth, 50, 100, midCol, bearCol)

// Atr Trail color
AtrTrailColor = gradientCol

// Plots
t = plot(supert, title = 'Atr Trail', color = AtrTrailColor, linewidth = 2)
tt = plot(supert2, title = 'Atr Trail Outer Band', color = color.new(color.black, 100))

// Fill
fill(t, tt, color = color.new(AtrTrailColor, 80))

// Bar color
barcolor(AtrTrailColor)
````
