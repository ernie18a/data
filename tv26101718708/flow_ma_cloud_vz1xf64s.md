# Flow MA Cloud

- url: https://www.tradingview.com/script/vZ1XF64s-Flow-MA-Cloud/
- type: indicator
- pine_id: PUB;fc2c8967ee4a4f55a4f883b5e359e6a8
- version: 1.0

## Description

Flow MA Cloud is a clean trend and market flow visualization tool built around the relationship between two fully configurable moving averages.

Unlike traditional moving average crossover indicators that focus solely on entry signals, Flow MA Cloud is designed to help traders quickly identify directional bias, trend strength, and changes in participation through dynamic cloud coloring and optional flow-state confirmation.

Supported moving average types include:

• SMA (Simple Moving Average)
• EMA (Exponential Moving Average)
• WMA (Weighted Moving Average)
• RMA (Running Moving Average)
• VWMA (Volume Weighted Moving Average)
• HMA (Hull Moving Average)

**  Suggested Default Setup: 9 EMA / 21 EMA

Both moving averages can be configured independently, allowing traders to create anything from traditional EMA trend clouds to custom flow and trend models.

**  Pairs well with ORB Sessions Pro for directional bias and Everex Lite for participation confirmation.

Additional features include:

• Dynamic bullish, bearish, and neutral cloud visualization
• Optional slope-based flow confirmation
• Bullish and bearish crossover markers
• Optional background bias highlighting
• Custom alert conditions for crossover and flow-state changes
• Adjustable colors, line widths, and visual settings

The cloud changes color based on both moving average positioning and directional slope, helping traders distinguish between strong trends, weakening trends, and neutral market conditions.

Flow MA Cloud is designed to be simple, visually clean, and easy to integrate into existing trading workflows for futures, stocks, forex, and cryptocurrency markets.

Real Trading. Real Testing. Real Results.

### Related Indicators

Flow MA Cloud is part of the Traders Workshop indicator suite.

For a complete market workflow, consider pairing it with:

• ORB Sessions Pro — Tracks Pre-Market and NY Open Opening Ranges, session statistics, average range expectations, and expansion levels.

• Everex Lite — A streamlined Effort vs Result indicator designed to visualize participation and directional flow.

Together, these tools help traders answer three critical questions:

1. Where is the market likely to move? (ORB Sessions Pro)
2. What is the current trend direction? (Flow MA Cloud)
3. Is participation supporting the move? (Everex Lite)

Real Trading. Real Testing. Real Results.

## Source Code

````pine
//@version=6
//=====================================================================
//  Indicator: Flow MA Cloud
//  Author: Christopher C. Berg
//  TradingView: ChristopherBergTraderWorkshop
//  Version: 1.0.0
//  Initial Release: June 2026
//=====================================================================
//
//  Flow MA Cloud is a trend and participation visualization tool
//  built around the relationship between two moving averages.
//
//  The indicator combines configurable moving averages, dynamic
//  cloud coloring, crossover signals, and optional flow-state
//  visualization to help traders quickly identify directional bias.
//
//  Designed for clean charting and trend confirmation.
//
//=====================================================================

indicator('Flow MA Cloud', overlay = true)

//=====================================================================
// Inputs
//=====================================================================
groupGeneral = 'General'
src = input.source(close, 'Source', group = groupGeneral)

groupMA1 = 'MA 1'
showMA1 = input.bool(true, 'Show MA 1', group = groupMA1)
ma1Type = input.string('EMA', 'MA 1 Type', options = ['SMA', 'EMA', 'WMA', 'RMA', 'VWMA', 'HMA'], group = groupMA1)
ma1Len = input.int(9, 'MA 1 Length', minval = 1, group = groupMA1)
ma1Color = input.color(color.new(color.teal, 0), 'MA 1 Color', group = groupMA1)
ma1Width = input.int(1, 'MA 1 Width', minval = 1, maxval = 5, group = groupMA1)

groupMA2 = 'MA 2'
showMA2 = input.bool(true, 'Show MA 2', group = groupMA2)
ma2Type = input.string('EMA', 'MA 2 Type', options = ['SMA', 'EMA', 'WMA', 'RMA', 'VWMA', 'HMA'], group = groupMA2)
ma2Len = input.int(21, 'MA 2 Length', minval = 1, group = groupMA2)
ma2Color = input.color(color.new(color.orange, 0), 'MA 2 Color', group = groupMA2)
ma2Width = input.int(1, 'MA 2 Width', minval = 1, maxval = 5, group = groupMA2)

groupCloud = 'Cloud'
showCloud = input.bool(true, 'Show Cloud', group = groupCloud)
showNeutralCloud = input.bool(true, 'Show Neutral Cloud', group = groupCloud)
bullFill    = input.color(color.new(#006400, 50), 'Bullish Fill', group = groupCloud)
bearFill    = input.color(color.new(#8B0000, 50), 'Bearish Fill', group = groupCloud)
neutralFill = input.color(color.new(#0600ba, 50), 'Neutral Fill', group = groupCloud)

groupFlow = 'Flow Logic'
slopeFilterLen = input.int(3, 'Slope Sensitivity', minval = 1, group = groupFlow)
requireBothSlopes = input.bool(false, 'Require Both MA Slopes', group = groupFlow)

groupVisual = 'Visual Enhancements'
showBgBias = input.bool(false, 'Subtle Background Bias', group = groupVisual)
showCrossMarks = input.bool(true, 'Show Cross Markers', group = groupVisual)
showFlowDots = input.bool(false, 'Show Flow Dots', group = groupVisual)

//=====================================================================
// MA Function
//=====================================================================
ma(src, len, type) =>
    switch type
        'SMA' => ta.sma(src, len)
        'EMA' => ta.ema(src, len)
        'WMA' => ta.wma(src, len)
        'RMA' => ta.rma(src, len)
        'VWMA' => ta.vwma(src, len)
        'HMA' => ta.hma(src, len)

//=====================================================================
// Calculations
//=====================================================================
ma1 = ma(src, ma1Len, ma1Type)
ma2 = ma(src, ma2Len, ma2Type)

ma1SlopeUp = ma1 > ma1[slopeFilterLen]
ma1SlopeDn = ma1 < ma1[slopeFilterLen]
ma2SlopeUp = ma2 > ma2[slopeFilterLen]
ma2SlopeDn = ma2 < ma2[slopeFilterLen]

bullSlopeOK = requireBothSlopes ? ma1SlopeUp and ma2SlopeUp : ma1SlopeUp
bearSlopeOK = requireBothSlopes ? ma1SlopeDn and ma2SlopeDn : ma1SlopeDn

bullFlow = ma1 > ma2 and bullSlopeOK
bearFlow = ma1 < ma2 and bearSlopeOK
neutralFlow = not bullFlow and not bearFlow

cloudColor = bullFlow ? bullFill : bearFlow ? bearFill : showNeutralCloud ? neutralFill : na

bullCross = ta.crossover(ma1, ma2)
bearCross = ta.crossunder(ma1, ma2)

//=====================================================================
// Plots
//=====================================================================
p1 = plot(showMA1 ? ma1 : na, 'MA 1', color = ma1Color, linewidth = ma1Width)
p2 = plot(showMA2 ? ma2 : na, 'MA 2', color = ma2Color, linewidth = ma2Width)

fill(p1, p2, color = showCloud ? cloudColor : na, title = 'Flow Cloud')

plotshape(showCrossMarks and bullCross, title = 'Bullish Cross', style = shape.triangleup, location = location.belowbar, color = color.new(color.green, 0), size = size.tiny)
plotshape(showCrossMarks and bearCross, title = 'Bearish Cross', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.tiny)

plotshape(showFlowDots and bullFlow, title = 'Bull Flow Dot', style = shape.circle, location = location.bottom, color = color.new(color.green, 35), size = size.tiny)
plotshape(showFlowDots and bearFlow, title = 'Bear Flow Dot', style = shape.circle, location = location.top, color = color.new(color.red, 35), size = size.tiny)

bgcolor(showBgBias ? bullFlow ? color.new(color.green, 94) : bearFlow ? color.new(color.red, 94) : na : na)

//=====================================================================
// Alerts
//=====================================================================
alertcondition(bullCross, title = 'Bullish MA Cross', message = 'Flow MA Cloud: Bullish MA cross')
alertcondition(bearCross, title = 'Bearish MA Cross', message = 'Flow MA Cloud: Bearish MA cross')
alertcondition(bullFlow and not bullFlow[1], title = 'Bull Flow Begins', message = 'Flow MA Cloud: Bullish flow begins')
alertcondition(bearFlow and not bearFlow[1], title = 'Bear Flow Begins', message = 'Flow MA Cloud: Bearish flow begins')
````
