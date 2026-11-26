# Moving Average XL

- url: https://www.tradingview.com/script/nAixh2oM-Moving-Average-XL/
- type: indicator
- pine_id: PUB;c9d3c8739ad74c6a94f5e094d82329da
- version: 3.0

## Description

Moving Average XL is a customizable multi-moving-average overlay that allows traders to plot up to three separate moving averages on the chart at the same time. Each moving average can be independently enabled, adjusted, styled, and color-coded, making it useful for trend direction, dynamic support and resistance, crossover analysis, and multi-timeframe-style trend context.

Each MA group includes the same core settings. “Show MA” turns that moving average on or off. “Length” controls the number of candles used in the calculation, with shorter lengths reacting faster to price and longer lengths smoothing price action more heavily. “Type” lets the user choose between SMA, EMA, WMA, VWMA, RMA, and HMA depending on how responsive or smooth they want the line to be. “Line Style” changes the visual display between solid, stepline, or circles. “Line Thickness” controls the weight of the plotted line, and “Color” lets the user customize each average for easier chart reading.

This indicator is designed for traders who want a clean, flexible moving average tool without unnecessary clutter. Use shorter averages to track near-term momentum, medium averages to define intermediate trend direction, and longer averages to identify major trend bias or high-probability support and resistance areas.

## Source Code

````pine
//@version=6
indicator('Moving Average XL', overlay = true)

// ─────────────────────────────────────
// Helper: Moving Average selector
// ─────────────────────────────────────
ma(source, length, type) =>
    switch type
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'WMA' => ta.wma(source, length)
        'VWMA' => ta.vwma(source, length)
        'RMA' => ta.rma(source, length)
        'HMA' => ta.hma(source, length)
        => ta.sma(source, length)

// ─────────────────────────────────────
// Helper: Plot style selector (for the MA plots)
// ─────────────────────────────────────
lineStyle(style) =>
    switch style
        'Solid' => plot.style_line
        'Stepline' => plot.style_stepline
        'Circles' => plot.style_circles
        => plot.style_line

// ─────────────────────────────────────
// Helper: Line-object style selector (for the projection lines)
// ─────────────────────────────────────
projLineStyle(style) =>
    switch style
        'Solid' => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted
        => line.style_dashed

// ─────────────────────────────────────
// Helper: Draw / refresh a projection line on the last bar only
// Deletes the previous line each tick so nothing smears.
// ─────────────────────────────────────
projectMA(bool draw, float startY, float slope, int pLen, color col, int w, string lStyle, line prevLn) =>
    line newLn = prevLn
    if barstate.islast
        line.delete(prevLn)
        newLn := draw and not na(startY) and not na(slope) ? line.new(bar_index, startY, bar_index + pLen, startY + slope * pLen, xloc = xloc.bar_index, color = col, width = w, style = lStyle) : na
    newLn

// ─────────────────────────────────────
// General
// ─────────────────────────────────────
nonRepaint = input.bool(false, 'Non-Repaint', group = 'General', tooltip = 'When ON, everything uses only confirmed (closed-bar) values, so nothing shown depends on the still-forming bar and no displayed value changes after the fact. Costs one bar of lag. Note: on closed historical bars, MAs of close do not repaint either way — this mainly affects the live bar and the projection.')

// One-bar offset: 0 = live bar (default), 1 = last confirmed bar.
rpOff = nonRepaint ? 1 : 0

// ─────────────────────────────────────
// MA 1 Inputs
// ─────────────────────────────────────
showMA1 = input.bool(true, 'Show MA 1', group = 'MA 1')
lenMA1 = input.int(20, 'MA 1 Length', minval = 1, group = 'MA 1')
typeMA1 = input.string('SMA', 'MA 1 Type', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA', 'HMA'], group = 'MA 1')
styleMA1 = input.string('Solid', 'MA 1 Line Style', options = ['Solid', 'Stepline', 'Circles'], group = 'MA 1')
widthMA1 = input.int(1, 'MA 1 Line Thickness', minval = 1, maxval = 10, group = 'MA 1')
colorMA1 = input.color(color.blue, 'MA 1 Color', group = 'MA 1')

projMA1 = input.bool(false, 'MA 1 · Show Projection', group = 'MA 1')
projLenMA1 = input.int(20, 'MA 1 · Projection Length', minval = 1, maxval = 500, group = 'MA 1', tooltip = 'Bars extended into the future. Capped at 500 (Pine limit for bar-index drawings).')
projSlopeMA1 = input.int(20, 'MA 1 · Slope Lookback', minval = 1, group = 'MA 1', tooltip = 'Bars used to measure the average slope of this MA.')
projStyleMA1 = input.string('Dotted', 'MA 1 · Projection Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'MA 1')
projWidthMA1 = input.int(1, 'MA 1 · Projection Thickness', minval = 1, maxval = 10, group = 'MA 1')
projColorMA1 = input.color(color.blue, 'MA 1 · Projection Color', group = 'MA 1')

// ─────────────────────────────────────
// MA 2 Inputs
// ─────────────────────────────────────
showMA2 = input.bool(true, 'Show MA 2', group = 'MA 2')
lenMA2 = input.int(50, 'MA 2 Length', minval = 1, group = 'MA 2')
typeMA2 = input.string('SMA', 'MA 2 Type', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA', 'HMA'], group = 'MA 2')
styleMA2 = input.string('Solid', 'MA 2 Line Style', options = ['Solid', 'Stepline', 'Circles'], group = 'MA 2')
widthMA2 = input.int(2, 'MA 2 Line Thickness', minval = 1, maxval = 10, group = 'MA 2')
colorMA2 = input.color(color.red, 'MA 2 Color', group = 'MA 2')

projMA2 = input.bool(false, 'MA 2 · Show Projection', group = 'MA 2')
projLenMA2 = input.int(20, 'MA 2 · Projection Length', minval = 1, maxval = 500, group = 'MA 2', tooltip = 'Bars extended into the future. Capped at 500 (Pine limit for bar-index drawings).')
projSlopeMA2 = input.int(50, 'MA 2 · Slope Lookback', minval = 1, group = 'MA 2', tooltip = 'Bars used to measure the average slope of this MA.')
projStyleMA2 = input.string('Dotted', 'MA 2 · Projection Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'MA 2')
projWidthMA2 = input.int(2, 'MA 2 · Projection Thickness', minval = 1, maxval = 10, group = 'MA 2')
projColorMA2 = input.color(color.red, 'MA 2 · Projection Color', group = 'MA 2')

// ─────────────────────────────────────
// MA 3 Inputs
// ─────────────────────────────────────
showMA3 = input.bool(true, 'Show MA 3', group = 'MA 3')
lenMA3 = input.int(200, 'MA 3 Length', minval = 1, group = 'MA 3')
typeMA3 = input.string('SMA', 'MA 3 Type', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA', 'HMA'], group = 'MA 3')
styleMA3 = input.string('Solid', 'MA 3 Line Style', options = ['Solid', 'Stepline', 'Circles'], group = 'MA 3')
widthMA3 = input.int(4, 'MA 3 Line Thickness', minval = 1, maxval = 10, group = 'MA 3')
colorMA3 = input.color(color.black, 'MA 3 Color', group = 'MA 3')

projMA3 = input.bool(false, 'MA 3 · Show Projection', group = 'MA 3')
projLenMA3 = input.int(20, 'MA 3 · Projection Length', minval = 1, maxval = 500, group = 'MA 3', tooltip = 'Bars extended into the future. Capped at 500 (Pine limit for bar-index drawings).')
projSlopeMA3 = input.int(200, 'MA 3 · Slope Lookback', minval = 1, group = 'MA 3', tooltip = 'Bars used to measure the average slope of this MA.')
projStyleMA3 = input.string('Dotted', 'MA 3 · Projection Style', options = ['Solid', 'Dashed', 'Dotted'], group = 'MA 3')
projWidthMA3 = input.int(4, 'MA 3 · Projection Thickness', minval = 1, maxval = 10, group = 'MA 3')
projColorMA3 = input.color(color.black, 'MA 3 · Projection Color', group = 'MA 3')

// ─────────────────────────────────────
// Calculations
// ─────────────────────────────────────
ma1 = ma(close, lenMA1, typeMA1)
ma2 = ma(close, lenMA2, typeMA2)
ma3 = ma(close, lenMA3, typeMA3)

// rpOff shifts every displayed value to the last confirmed bar when Non-Repaint is ON.
ma1Disp = ma1[rpOff]
ma2Disp = ma2[rpOff]
ma3Disp = ma3[rpOff]

// Average per-bar slope over each MA's own lookback window, measured from confirmed data when Non-Repaint is ON.
slope1 = (ma1[rpOff] - ma1[rpOff + projSlopeMA1]) / projSlopeMA1
slope2 = (ma2[rpOff] - ma2[rpOff + projSlopeMA2]) / projSlopeMA2
slope3 = (ma3[rpOff] - ma3[rpOff + projSlopeMA3]) / projSlopeMA3

// ─────────────────────────────────────
// Plots (the MA lines themselves)
// ─────────────────────────────────────
plot(showMA1 ? ma1Disp : na, title = 'MA 1', color = colorMA1, linewidth = math.max(1, widthMA1), style = lineStyle(styleMA1), editable = false)
plot(showMA2 ? ma2Disp : na, title = 'MA 2', color = colorMA2, linewidth = math.max(1, widthMA2), style = lineStyle(styleMA2), editable = false)
plot(showMA3 ? ma3Disp : na, title = 'MA 3', color = colorMA3, linewidth = math.max(1, widthMA3), style = lineStyle(styleMA3), editable = false)

// ─────────────────────────────────────
// Projection lines (drawn once, off the last bar)
// ─────────────────────────────────────
var line projLine1 = na
var line projLine2 = na
var line projLine3 = na
projLine1 := projectMA(showMA1 and projMA1, ma1Disp, slope1, projLenMA1, projColorMA1, projWidthMA1, projLineStyle(projStyleMA1), projLine1)
projLine2 := projectMA(showMA2 and projMA2, ma2Disp, slope2, projLenMA2, projColorMA2, projWidthMA2, projLineStyle(projStyleMA2), projLine2)
projLine3 := projectMA(showMA3 and projMA3, ma3Disp, slope3, projLenMA3, projColorMA3, projWidthMA3, projLineStyle(projStyleMA3), projLine3)
````
