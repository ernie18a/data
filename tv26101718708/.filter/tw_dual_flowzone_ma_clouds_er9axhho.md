# TW - Dual FlowZone MA Clouds

- url: https://www.tradingview.com/script/eR9axhhO-TW-Dual-FlowZone-MA-Clouds/
- type: indicator
- pine_id: PUB;238b2ed2883c4b4bbcd42f03c29f1f5c
- version: 1.0

## Description

## Dual FlowZone MA Clouds

Dual FlowZone MA Clouds is a trend visualization indicator designed to help traders quickly identify market direction, trend strength, and potential transitions before they become obvious.

Unlike traditional moving average indicators that simply plot one or two averages, Dual FlowZone MA Clouds uses two independent FlowZones to provide both short-term momentum and longer-term trend context in a single, easy-to-read visualization.

FlowZone A is designed to help identify momentum, pullbacks, and trend continuation, while FlowZone B provides higher timeframe directional bias and market context. When both FlowZones align, traders can quickly recognize strong trending conditions. When they diverge, the market may be transitioning or losing participation.

### Flow Status Table

The optional Flow Status table provides an instant summary of current market conditions without requiring traders to interpret multiple moving averages.

The table displays:

* **Primary Flow** – Current direction of FlowZone A (Bullish, Bearish, Neutral, or Weakening)
* **Secondary Flow** – Current direction of FlowZone B
* **Alignment** – Indicates whether both FlowZones are aligned or providing mixed signals

This allows traders to assess overall trend bias with a quick glance before analyzing price action.

### ORB-Style Visual Design

The Flow Status table uses the same visual style as the Traders Workshop ORB Sessions indicator, providing a consistent interface across the indicator suite.

### Chart Labels

When a FlowZone crossover occurs, optional chart labels identify the signal directly on the chart, making it easy to review historical trend changes without searching through moving average crosses.

The indicator also supports optional Flow Dots and subtle background bias to provide additional visual confirmation while keeping the chart clean and uncluttered.

### Features

• Two fully independent Moving Average FlowZones
• Supports SMA, EMA, WMA, RMA, VWMA and HMA
• Configurable MA lengths, colors and line widths
• Dynamic bullish, bearish and transition cloud coloring
• Optional Flow Status dashboard
• Optional crossover markers
• Optional Flow Dots
• Optional background trend bias
• Individual alerts for crossovers, trend changes and FlowZone alignment

Dual FlowZone MA Clouds is designed to complement price action—not replace it. Use it alongside market structure, volume, VWAP, auction concepts, and support/resistance to better understand trend quality and directional bias.

---

**Part of the Traders Workshop indicator collection**

**Real Trading. Real Testing. Real Results.**

## Source Code

````pine
//@version=6
//=====================================================================
//  Indicator: Dual FlowZone MA Clouds
//  Author: Christopher C. Berg
//  TradingView: ChristopherBergTraderWorkshop
//  Version: 1.2.1
//  Initial Release: June 2026
//=====================================================================
//
//  Dual FlowZone MA Clouds is a trend visualization tool built around
//  two independent moving average flow zones.
//
//  FlowZone A is designed for short-term momentum and pullback structure.
//  FlowZone B is designed for longer-term trend bias and regime context.
//
//  Includes configurable MA types, dynamic cloud coloring, crossover
//  signals, optional flow dots, background bias, alerts, weakening
//  logic, and an at-a-glance flow status table.
//
//=====================================================================

indicator('Dual FlowZone MA Clouds', overlay = true)

//=====================================================================
// Inputs
//=====================================================================
groupGeneral = 'General'
src = input.source(close, 'Source', group = groupGeneral)

//=====================================================================
// FlowZone A
//=====================================================================
groupA = 'FlowZone A - Primary'
showA = input.bool(true, 'Enable FlowZone A', group = groupA)
aMa1Type = input.string('EMA', 'A MA 1 Type', options = ['SMA', 'EMA', 'WMA', 'RMA', 'VWMA', 'HMA'], group = groupA)
aMa1Len = input.int(9, 'A MA 1 Length', minval = 1, group = groupA)
aMa1Color = input.color(color.new(color.teal, 0), 'A MA 1 Color', group = groupA)
aMa2Type = input.string('EMA', 'A MA 2 Type', options = ['SMA', 'EMA', 'WMA', 'RMA', 'VWMA', 'HMA'], group = groupA)
aMa2Len = input.int(21, 'A MA 2 Length', minval = 1, group = groupA)
aMa2Color = input.color(color.new(color.orange, 0), 'A MA 2 Color', group = groupA)
aLineWidth = input.int(1, 'A Line Width', minval = 1, maxval = 5, group = groupA)

//=====================================================================
// FlowZone B
//=====================================================================
groupB = 'FlowZone B - Secondary'
showB = input.bool(false, 'Enable FlowZone B', group = groupB)
bMa1Type = input.string('EMA', 'B MA 1 Type', options = ['SMA', 'EMA', 'WMA', 'RMA', 'VWMA', 'HMA'], group = groupB)
bMa1Len = input.int(50, 'B MA 1 Length', minval = 1, group = groupB)
bMa1Color = input.color(color.new(color.gray, 50), 'B MA 1 Color', group = groupB)
bMa2Type = input.string('EMA', 'B MA 2 Type', options = ['SMA', 'EMA', 'WMA', 'RMA', 'VWMA', 'HMA'], group = groupB)
bMa2Len = input.int(200, 'B MA 2 Length', minval = 1, group = groupB)
bMa2Color = input.color(color.new(color.gray, 65), 'B MA 2 Color', group = groupB)
bLineWidth = input.int(1, 'B Line Width', minval = 1, maxval = 5, group = groupB)

//=====================================================================
// Cloud A
//=====================================================================
groupCloudA = 'Cloud A'
showCloudA = input.bool(true, 'Show Cloud A', group = groupCloudA)
showNeutralCloudA = input.bool(true, 'Show Neutral Cloud A', group = groupCloudA)
aBullFill = input.color(color.new(#006400, 50), 'A Bullish Fill', group = groupCloudA)
aBearFill = input.color(color.new(#8B0000, 50), 'A Bearish Fill', group = groupCloudA)
aNeutralFill = input.color(color.new(#0600BA, 50), 'A Neutral / Weakening Fill', group = groupCloudA)

//=====================================================================
// Cloud B
//=====================================================================
groupCloudB = 'Cloud B'
showCloudB = input.bool(true, 'Show Cloud B', group = groupCloudB)
showNeutralCloudB = input.bool(false, 'Show Neutral Cloud B', group = groupCloudB)
bBullFill = input.color(color.new(#006400, 88), 'B Bullish Fill', group = groupCloudB)
bBearFill = input.color(color.new(#8B0000, 88), 'B Bearish Fill', group = groupCloudB)
bNeutralFill = input.color(color.new(#0600BA, 90), 'B Neutral / Weakening Fill', group = groupCloudB)

//=====================================================================
// Flow Logic
//=====================================================================
groupFlow = 'Flow Logic - Shared'
slopeFilterLen = input.int(3, 'Slope Sensitivity', minval = 1, group = groupFlow)
requireBothSlopes = input.bool(false, 'Require Both MA Slopes', group = groupFlow)

//=====================================================================
// Visuals
//=====================================================================
groupVisual = 'Visuals - Shared'
showBgBias = input.bool(false, 'Subtle Background Bias', group = groupVisual)
showCrossMarksA = input.bool(true, 'Show Cross Markers A', group = groupVisual)
showCrossMarksB = input.bool(false, 'Show Cross Markers B', group = groupVisual)
showFlowDotsA = input.bool(false, 'Show Flow Dots A', group = groupVisual)
showFlowDotsB = input.bool(false, 'Show Flow Dots B', group = groupVisual)

//=====================================================================
// Flow Status Table
//=====================================================================
groupTable = 'Flow Status Table'
showStatusTable = input.bool(true, 'Show Flow Status Table', group = groupTable)
statusTextSize = input.string('Normal', 'Text Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = groupTable)
showAlignmentRow = input.bool(true, 'Show Alignment Row', group = groupTable)

// ORB-style table colors
tblHdrBg = color.new(color.blue, 70)
tblFlowBg = color.new(color.blue, 88)
tblSectionBg = color.new(color.rgb(0, 128, 128), 70)
tblAlignBg = color.new(color.rgb(0, 128, 128), 88)
tblText = color.white
tblEmpty = color.new(color.black, 100)

// Status text colors
bullTextColor = color.lime
bearTextColor = color.red
neutralTextColor = color.rgb(100, 170, 255)
weakeningTextColor = color.yellow
alignmentTextColor = color.lime

//=====================================================================
// Functions
//=====================================================================
getMA(_src, _len, _type) =>
    float result = na
    if _type == 'SMA'
        result := ta.sma(_src, _len)
    else if _type == 'EMA'
        result := ta.ema(_src, _len)
    else if _type == 'WMA'
        result := ta.wma(_src, _len)
    else if _type == 'RMA'
        result := ta.rma(_src, _len)
    else if _type == 'VWMA'
        result := ta.vwma(_src, _len)
    else
        result := ta.hma(_src, _len)
    result

getTextSize(_size) =>
    string result = size.small
    if _size == 'Tiny'
        result := size.tiny
    else if _size == 'Small'
        result := size.small
    else if _size == 'Normal'
        result := size.normal
    else if _size == 'Large'
        result := size.large
    else
        result := size.huge
    result

getFlowText(_bull, _bear, _weakening) =>
    _bull ? 'BULLISH' : _bear ? 'BEARISH' : _weakening ? 'WEAKENING' : 'NEUTRAL'

getFlowColor(_bull, _bear, _weakening) =>
    _bull ? bullTextColor : _bear ? bearTextColor : _weakening ? weakeningTextColor : neutralTextColor

//=====================================================================
// Calculations - FlowZone A
//=====================================================================
aMa1 = getMA(src, aMa1Len, aMa1Type)
aMa2 = getMA(src, aMa2Len, aMa2Type)

aMa1SlopeUp = aMa1 > aMa1[slopeFilterLen]
aMa1SlopeDn = aMa1 < aMa1[slopeFilterLen]
aMa2SlopeUp = aMa2 > aMa2[slopeFilterLen]
aMa2SlopeDn = aMa2 < aMa2[slopeFilterLen]

aBullTrend = aMa1 > aMa2
aBearTrend = aMa1 < aMa2

aBullSlopeOK = requireBothSlopes ? aMa1SlopeUp and aMa2SlopeUp : aMa1SlopeUp
aBearSlopeOK = requireBothSlopes ? aMa1SlopeDn and aMa2SlopeDn : aMa1SlopeDn

aBullFlow = aBullTrend and aBullSlopeOK
aBearFlow = aBearTrend and aBearSlopeOK
aWeakeningFlow = (aBullTrend and not aBullSlopeOK) or (aBearTrend and not aBearSlopeOK)

aCloudColor = aBullFlow ? aBullFill : aBearFlow ? aBearFill : showNeutralCloudA ? aNeutralFill : na

aBullCross = ta.crossover(aMa1, aMa2)
aBearCross = ta.crossunder(aMa1, aMa2)

//=====================================================================
// Calculations - FlowZone B
//=====================================================================
bMa1 = getMA(src, bMa1Len, bMa1Type)
bMa2 = getMA(src, bMa2Len, bMa2Type)

bMa1SlopeUp = bMa1 > bMa1[slopeFilterLen]
bMa1SlopeDn = bMa1 < bMa1[slopeFilterLen]
bMa2SlopeUp = bMa2 > bMa2[slopeFilterLen]
bMa2SlopeDn = bMa2 < bMa2[slopeFilterLen]

bBullTrend = bMa1 > bMa2
bBearTrend = bMa1 < bMa2

bBullSlopeOK = requireBothSlopes ? bMa1SlopeUp and bMa2SlopeUp : bMa1SlopeUp
bBearSlopeOK = requireBothSlopes ? bMa1SlopeDn and bMa2SlopeDn : bMa1SlopeDn

bBullFlow = bBullTrend and bBullSlopeOK
bBearFlow = bBearTrend and bBearSlopeOK
bWeakeningFlow = (bBullTrend and not bBullSlopeOK) or (bBearTrend and not bBearSlopeOK)

bCloudColor = bBullFlow ? bBullFill : bBearFlow ? bBearFill : showNeutralCloudB ? bNeutralFill : na

bBullCross = ta.crossover(bMa1, bMa2)
bBearCross = ta.crossunder(bMa1, bMa2)

//=====================================================================
// Alignment Logic
//=====================================================================
bothBullish = showA and showB and aBullFlow and bBullFlow
bothBearish = showA and showB and aBearFlow and bBearFlow
bothWeakening = showA and showB and aWeakeningFlow and bWeakeningFlow
mixedFlow = showA and showB and not bothBullish and not bothBearish and not bothWeakening

alignmentText = bothBullish ? 'ALIGNED BULLISH' : bothBearish ? 'ALIGNED BEARISH' : bothWeakening ? 'BOTH WEAKENING' : mixedFlow ? 'MIXED' : 'N/A'
alignmentColor = bothBullish ? bullTextColor : bothBearish ? bearTextColor : bothWeakening ? weakeningTextColor : alignmentTextColor

//=====================================================================
// Plots - FlowZone B First
//=====================================================================
bPlot1 = plot(showB ? bMa1 : na, 'FlowZone B MA 1', color = bMa1Color, linewidth = bLineWidth)
bPlot2 = plot(showB ? bMa2 : na, 'FlowZone B MA 2', color = bMa2Color, linewidth = bLineWidth)
fill(bPlot1, bPlot2, color = showB and showCloudB ? bCloudColor : na, title = 'FlowZone B Cloud')

//=====================================================================
// Plots - FlowZone A Second
//=====================================================================
aPlot1 = plot(showA ? aMa1 : na, 'FlowZone A MA 1', color = aMa1Color, linewidth = aLineWidth)
aPlot2 = plot(showA ? aMa2 : na, 'FlowZone A MA 2', color = aMa2Color, linewidth = aLineWidth)
fill(aPlot1, aPlot2, color = showA and showCloudA ? aCloudColor : na, title = 'FlowZone A Cloud')

//=====================================================================
// Cross Markers
//=====================================================================
plotshape(showA and showCrossMarksA and aBullCross, title = 'FlowZone A Bullish Cross', style = shape.triangleup, location = location.belowbar, color = color.new(color.green, 0), size = size.tiny)
plotshape(showA and showCrossMarksA and aBearCross, title = 'FlowZone A Bearish Cross', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 0), size = size.tiny)

plotshape(showB and showCrossMarksB and bBullCross, title = 'FlowZone B Bullish Cross', style = shape.triangleup, location = location.belowbar, color = color.new(color.green, 35), size = size.tiny)
plotshape(showB and showCrossMarksB and bBearCross, title = 'FlowZone B Bearish Cross', style = shape.triangledown, location = location.abovebar, color = color.new(color.red, 35), size = size.tiny)

//=====================================================================
// Flow Dots
//=====================================================================
plotshape(showA and showFlowDotsA and aBullFlow, title = 'FlowZone A Bull Flow Dot', style = shape.circle, location = location.bottom, color = color.new(color.green, 35), size = size.tiny)
plotshape(showA and showFlowDotsA and aBearFlow, title = 'FlowZone A Bear Flow Dot', style = shape.circle, location = location.top, color = color.new(color.red, 35), size = size.tiny)

plotshape(showB and showFlowDotsB and bBullFlow, title = 'FlowZone B Bull Flow Dot', style = shape.circle, location = location.bottom, color = color.new(color.green, 60), size = size.tiny)
plotshape(showB and showFlowDotsB and bBearFlow, title = 'FlowZone B Bear Flow Dot', style = shape.circle, location = location.top, color = color.new(color.red, 60), size = size.tiny)

//=====================================================================
// Background Bias - Uses FlowZone A
//=====================================================================
bgBiasColor = aBullFlow ? color.new(color.green, 94) : aBearFlow ? color.new(color.red, 94) : na
bgcolor(showBgBias and showA ? bgBiasColor : na)

//=====================================================================
// Status Table
//=====================================================================
var table statusTable = table.new(position.top_center, 2, 5, border_width = 1)

if barstate.islast
    table.clear(statusTable, 0, 0, 1, 4)

    if showStatusTable
        txtSize = getTextSize(statusTextSize)

        aText = showA ? getFlowText(aBullFlow, aBearFlow, aWeakeningFlow) : 'OFF'
        aColor = showA ? getFlowColor(aBullFlow, aBearFlow, aWeakeningFlow) : neutralTextColor

        bText = showB ? getFlowText(bBullFlow, bBearFlow, bWeakeningFlow) : 'OFF'
        bColor = showB ? getFlowColor(bBullFlow, bBearFlow, bWeakeningFlow) : neutralTextColor

        table.cell(statusTable, 0, 0, 'FLOW STATUS', text_color = tblText, bgcolor = tblHdrBg, text_size = txtSize, text_halign = text.align_left)
        table.cell(statusTable, 1, 0, '', text_color = tblText, bgcolor = tblHdrBg, text_size = txtSize)

        table.cell(statusTable, 0, 1, 'Primary Flow', text_color = tblText, bgcolor = tblFlowBg, text_size = txtSize, text_halign = text.align_left)
        table.cell(statusTable, 1, 1, aText, text_color = aColor, bgcolor = tblFlowBg, text_size = txtSize, text_halign = text.align_right)

        table.cell(statusTable, 0, 2, 'Secondary Flow', text_color = tblText, bgcolor = tblFlowBg, text_size = txtSize, text_halign = text.align_left)
        table.cell(statusTable, 1, 2, bText, text_color = bColor, bgcolor = tblFlowBg, text_size = txtSize, text_halign = text.align_right)

        if showAlignmentRow
            table.cell(statusTable, 0, 3, 'ALIGNMENT', text_color = tblText, bgcolor = tblSectionBg, text_size = txtSize, text_halign = text.align_left)
            table.cell(statusTable, 1, 3, '', text_color = tblText, bgcolor = tblSectionBg, text_size = txtSize)

            table.cell(statusTable, 0, 4, 'Status', text_color = tblText, bgcolor = tblAlignBg, text_size = txtSize, text_halign = text.align_left)
            table.cell(statusTable, 1, 4, alignmentText, text_color = alignmentColor, bgcolor = tblAlignBg, text_size = txtSize, text_halign = text.align_right)

//=====================================================================
// Alerts
//=====================================================================
alertcondition(aBullCross, title = 'FlowZone A Bullish MA Cross', message = 'Dual FlowZone MA Clouds: FlowZone A bullish MA cross')
alertcondition(aBearCross, title = 'FlowZone A Bearish MA Cross', message = 'Dual FlowZone MA Clouds: FlowZone A bearish MA cross')
alertcondition(aBullFlow and not aBullFlow[1], title = 'FlowZone A Bull Flow Begins', message = 'Dual FlowZone MA Clouds: FlowZone A bullish flow begins')
alertcondition(aBearFlow and not aBearFlow[1], title = 'FlowZone A Bear Flow Begins', message = 'Dual FlowZone MA Clouds: FlowZone A bearish flow begins')
alertcondition(aWeakeningFlow and not aWeakeningFlow[1], title = 'FlowZone A Weakening', message = 'Dual FlowZone MA Clouds: FlowZone A is weakening')

alertcondition(bBullCross, title = 'FlowZone B Bullish MA Cross', message = 'Dual FlowZone MA Clouds: FlowZone B bullish MA cross')
alertcondition(bBearCross, title = 'FlowZone B Bearish MA Cross', message = 'Dual FlowZone MA Clouds: FlowZone B bearish MA cross')
alertcondition(bBullFlow and not bBullFlow[1], title = 'FlowZone B Bull Flow Begins', message = 'Dual FlowZone MA Clouds: FlowZone B bullish flow begins')
alertcondition(bBearFlow and not bBearFlow[1], title = 'FlowZone B Bear Flow Begins', message = 'Dual FlowZone MA Clouds: FlowZone B bearish flow begins')
alertcondition(bWeakeningFlow and not bWeakeningFlow[1], title = 'FlowZone B Weakening', message = 'Dual FlowZone MA Clouds: FlowZone B is weakening')

alertcondition(bothBullish and not bothBullish[1], title = 'Both FlowZones Bullish', message = 'Dual FlowZone MA Clouds: Both FlowZones are bullish')
alertcondition(bothBearish and not bothBearish[1], title = 'Both FlowZones Bearish', message = 'Dual FlowZone MA Clouds: Both FlowZones are bearish')
alertcondition(bothWeakening and not bothWeakening[1], title = 'Both FlowZones Weakening', message = 'Dual FlowZone MA Clouds: Both FlowZones are weakening')
alertcondition(mixedFlow and not mixedFlow[1], title = 'FlowZone Alignment Changed', message = 'Dual FlowZone MA Clouds: FlowZone alignment has changed')
````
