# Period Range Visualizer

- url: https://www.tradingview.com/script/knPEm5T7-Period-Range-Visualizer/
- type: indicator
- pine_id: PUB;73a3281c81664abfa2e74c8261e16779
- version: 1.0

## Description

Period Range Visualizer is a Pine Script v6 overlay indicator that visualizes higher-period market structure directly on the chart.

It shows the active period high, low, open, bar-change value, bullish/bearish range boxes, labels, sweep markers, sweep candle coloring, current big candle projection, and previous candle projections.

Auto Timeframe Alignment:
1m chart → 15m period
5m chart → 1h period
15m chart → 4h period
1h chart → 1D period
Other chart timeframes use the manual period setting.

Key Features:
- Current period range boxes
- High, low, open, and bar-change value lines
- Previous high/low extension into the active period
- Previous high sweep and previous low sweep detection
- Sweep candle overlay coloring
- Current big candle projection
- Previous candle projections with weekday labels
- Customizable labels, colors, line styles, widths, and candle settings

This indicator is designed for traders who want a clean visual read of higher-period range behavior, liquidity sweeps, and active-period structure without manually switching timeframes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Period Range Visualizer", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500)

//==================================================================================================
// INPUT GROUPS
//==================================================================================================
string G_PERIOD     = "Period Settings"
string G_BOXES      = "Box Settings"
string G_OHLC       = "OHLC Line Settings"
string G_LABELS     = "Label Settings"
string G_SWEEPS     = "Sweep Settings"
string G_BIGCANDLE  = "Current Big Candle Settings"
string G_PREVCANDLE = "Previous Candles Settings"

//==================================================================================================
// INPUTS - PERIOD
//==================================================================================================
bool   autoTimeframeAlignment = input.bool(true, "Auto Timeframe Alignment", group = G_PERIOD, tooltip = "Automatically sets the period timeframe based on chart timeframe:\n1m -> 15m\n5m -> 1h\n15m -> 4h\n1h -> 1D")
string manualTimeframeInput   = input.timeframe("D", "Manual Period Timeframe", group = G_PERIOD)

string timeframeInput = autoTimeframeAlignment ? (
      timeframe.period == "1"  ? "15"  :
      timeframe.period == "5"  ? "60"  :
      timeframe.period == "15" ? "240" :
      timeframe.period == "60" ? "D"   : manualTimeframeInput
    ) : manualTimeframeInput

bool   keepHistoricalBoxes = input.bool(true, "Keep Historical Boxes", group = G_PERIOD)
bool   extendPrevHL        = input.bool(true, "Extend Previous High / Low Into Current Session", group = G_PERIOD)
bool   currentLabelsOnly   = input.bool(true, "Current Period Labels Only", group = G_PERIOD)

//==================================================================================================
// INPUTS - BOXES
//==================================================================================================
bool  showBoxes          = input.bool(true, "Show Boxes", group = G_BOXES)
color bullBoxColor       = input.color(color.new(#089981, 80), "Bull Box Fill", group = G_BOXES)
color bearBoxColor       = input.color(color.new(#f23645, 80), "Bear Box Fill", group = G_BOXES)
color bullBoxBorderColor = input.color(color.new(#089981, 100), "Bull Box Border", group = G_BOXES)
color bearBoxBorderColor = input.color(color.new(#f23645, 100), "Bear Box Border", group = G_BOXES)

//==================================================================================================
// INPUTS - OHLC LINES
//==================================================================================================
bool   showHighLine            = input.bool(true, "Show High Line", group = G_OHLC)
bool   showLowLine             = input.bool(true, "Show Low Line", group = G_OHLC)
bool   showOpenLine            = input.bool(true, "Show Open Line", group = G_OHLC)
bool   showBarChangeValueLine  = input.bool(true, "Show Bar Change Value Line", group = G_OHLC)

color  highLineColor           = input.color(color.new(#089981, 50), "High Line Color", group = G_OHLC)
color  lowLineColor            = input.color(color.new(#f23645, 50), "Low Line Color", group = G_OHLC)
color  openLineColor           = input.color(color.new(#fbdf11, 50), "Open Line Color", group = G_OHLC)
color  barChangeValueLineColor = input.color(color.new(#f23645, 20), "Bar Change Value Line Color", group = G_OHLC)

string highLineStyleInput      = input.string("Dashed", "High Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_OHLC)
string lowLineStyleInput       = input.string("Dashed", "Low Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_OHLC)
string openLineStyleInput      = input.string("Dashed", "Open Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_OHLC)
string barChangeLineStyleInput = input.string("Dotted", "Bar Change Value Line Style", options = ["Solid", "Dashed", "Dotted"], group = G_OHLC)

int highLineWidth              = input.int(1, "High Line Width", minval = 1, maxval = 5, group = G_OHLC)
int lowLineWidth               = input.int(1, "Low Line Width", minval = 1, maxval = 5, group = G_OHLC)
int openLineWidth              = input.int(1, "Open Line Width", minval = 1, maxval = 5, group = G_OHLC)
int barChangeLineWidth         = input.int(1, "Bar Change Value Line Width", minval = 1, maxval = 5, group = G_OHLC)

//==================================================================================================
// INPUTS - LABELS
//==================================================================================================
bool   showLabels               = input.bool(true, "Show Labels", group = G_LABELS)
bool   showHighLabel            = input.bool(true, "Show High Label", group = G_LABELS)
bool   showLowLabel             = input.bool(true, "Show Low Label", group = G_LABELS)
bool   showOpenLabel            = input.bool(true, "Show Open Label", group = G_LABELS)
bool   showBarChangeValueLabel  = input.bool(true, "Show Bar Change Value Label", group = G_LABELS)
bool   showBarChangeLabel       = input.bool(true, "Show Separate Bar Change Label", group = G_LABELS)
bool   showPeriodLabel          = input.bool(true, "Show Period Label", group = G_LABELS)

color  highLabelColor           = input.color(#089981, "High Label Color", group = G_LABELS)
color  lowLabelColor            = input.color(#f23645, "Low Label Color", group = G_LABELS)
color  openLabelColor           = input.color(#fbdf11, "Open Label Color", group = G_LABELS)
color  barChangeValueUpColor    = input.color(#089981, "Bar Change Value Label Up Color", group = G_LABELS)
color  barChangeValueDnColor    = input.color(#f23645, "Bar Change Value Label Down Color", group = G_LABELS)
color  barChangeUpLabelColor    = input.color(#089981, "Bar Change Label Up Color", group = G_LABELS)
color  barChangeDnLabelColor    = input.color(#f23645, "Bar Change Label Down Color", group = G_LABELS)
color  periodLabelColor         = input.color(#fbdf11, "Period Label Color", group = G_LABELS)

string labelSizeInput           = input.string("Small", "Main Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_LABELS)
string periodLabelSizeInput     = input.string("Normal", "Period Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_LABELS)
int    barChangeYOffsetTicks    = input.int(100, "Bar Change Label Offset (Ticks)", minval = 0, group = G_LABELS)
int    periodYOffsetTicks       = input.int(100, "Period Label Offset (Ticks)", minval = 0, group = G_LABELS)

//==================================================================================================
// INPUTS - SWEEPS
//==================================================================================================
bool   enableHighSweep            = input.bool(true, "Enable Previous High Sweep Detection", group = G_SWEEPS)
bool   enableLowSweep             = input.bool(true, "Enable Previous Low Sweep Detection", group = G_SWEEPS)
bool   showHighSweepLabel         = input.bool(true, "Show High Sweep Label", group = G_SWEEPS)
string highSweepText              = input.string("High Sweep", "High Sweep Label Text", group = G_SWEEPS)
color  highSweepColor             = input.color(#089981, "High Sweep Label Color", group = G_SWEEPS)

bool   showHighSweepArrow         = input.bool(true, "Show High Sweep Bottom Arrow", group = G_SWEEPS)
bool   showLowSweepArrow          = input.bool(true, "Show Low Sweep Top Arrow", group = G_SWEEPS)
color  highSweepArrowColor        = input.color(#089981, "High Sweep Arrow Color", group = G_SWEEPS)
color  lowSweepArrowColor         = input.color(#f23645, "Low Sweep Arrow Color", group = G_SWEEPS)
string sweepArrowSizeInput        = input.string("Small", "Sweep Arrow Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_SWEEPS)

bool   colorSweepCandles          = input.bool(true, "Color Sweep Candles", group = G_SWEEPS)
color  highSweepCandleBodyColor   = input.color(color.new(#089981, 0), "High Sweep Candle Body Color", group = G_SWEEPS)
color  highSweepCandleWickColor   = input.color(color.new(#089981, 0), "High Sweep Candle Wick Color", group = G_SWEEPS)
color  highSweepCandleBorderColor = input.color(color.new(#089981, 0), "High Sweep Candle Border Color", group = G_SWEEPS)
color  lowSweepCandleBodyColor    = input.color(color.new(#f23645, 0), "Low Sweep Candle Body Color", group = G_SWEEPS)
color  lowSweepCandleWickColor    = input.color(color.new(#f23645, 0), "Low Sweep Candle Wick Color", group = G_SWEEPS)
color  lowSweepCandleBorderColor  = input.color(color.new(#f23645, 0), "Low Sweep Candle Border Color", group = G_SWEEPS)

//==================================================================================================
// INPUTS - CURRENT BIG CANDLE
//==================================================================================================
bool   showBigCandle        = input.bool(true, "Show Current Big Candle Projection", group = G_BIGCANDLE)
int    bigCandleOffset      = input.int(10, "Current Big Candle Offset", minval = 1, group = G_BIGCANDLE)
int    bigCandleWidthBars   = input.int(5, "Current Big Candle Width (Bars)", minval = 1, group = G_BIGCANDLE)
color  bigCandleTextColor   = input.color(#fbdf11, "Current Big Candle Text Color", group = G_BIGCANDLE)
int    bigCandleTextOffset  = input.int(200, "Current Big Candle Text Offset (Ticks)", minval = 0, group = G_BIGCANDLE)

//==================================================================================================
// INPUTS - PREVIOUS CANDLES
//==================================================================================================
bool   showPrevCandles          = input.bool(true, "Show Previous Candles", group = G_PREVCANDLE)
int    prevCandlesToShow        = input.int(3, "Previous Candles To Show", minval = 1, maxval = 20, group = G_PREVCANDLE)
int    prevCandleWidthBars      = input.int(5, "Previous Candle Width (Bars)", minval = 1, group = G_PREVCANDLE)
int    prevCandleGapBars        = input.int(2, "Gap Between Candles (Bars)", minval = 0, group = G_PREVCANDLE)
int    prevCandleWickWidth      = input.int(2, "Previous Candle Wick Width", minval = 1, maxval = 10, group = G_PREVCANDLE)
int    prevCandleBorderWidth    = input.int(1, "Previous Candle Body Border Width", minval = 0, maxval = 10, group = G_PREVCANDLE)
bool   showPrevCandleLabels     = input.bool(true, "Show Previous Candle Labels", group = G_PREVCANDLE)
int    prevCandleLabelOffset    = input.int(150, "Previous Candle Label Offset (Ticks)", minval = 0, group = G_PREVCANDLE)
string prevCandleLabelSizeIn    = input.string("Small", "Previous Candle Label Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = G_PREVCANDLE)

color  prevBullBodyColor        = input.color(#089981, "Previous Bull Body Color", group = G_PREVCANDLE)
color  prevBearBodyColor        = input.color(#f23645, "Previous Bear Body Color", group = G_PREVCANDLE)
color  prevBullWickColor        = input.color(#089981, "Previous Bull Wick Color", group = G_PREVCANDLE)
color  prevBearWickColor        = input.color(#f23645, "Previous Bear Wick Color", group = G_PREVCANDLE)
color  prevCandleLabelColor     = input.color(#fbdf11, "Previous Candle Label Color", group = G_PREVCANDLE)

//==================================================================================================
// HELPERS
//==================================================================================================
lineStyleFromInput(styleText) =>
    styleText == "Solid" ? line.style_solid : styleText == "Dashed" ? line.style_dashed : line.style_dotted

labelSizeFromInput(sizeText) =>
    sizeText == "Tiny" ? size.tiny : sizeText == "Small" ? size.small : sizeText == "Normal" ? size.normal : sizeText == "Large" ? size.large : size.huge

formatPrice(val) =>
    str.format("{0,number,#.##}", val)

formatBarChangeTicks(val) =>
    string prefix = val >= 0 ? "+" : ""
    prefix + str.tostring(int(math.round(val))) + " ticks"

const int TRADING_DAY_SHIFT_MS = 6 * 60 * 60 * 1000

tradingDayOfWeek(ts) =>
    dayofweek(ts + TRADING_DAY_SHIFT_MS)

isTradingWeekday(ts) =>
    int dow = tradingDayOfWeek(ts)
    dow >= dayofweek.monday and dow <= dayofweek.friday

tradingDayAbbrevFromTimestamp(ts) =>
    int dow = tradingDayOfWeek(ts)
    dow == dayofweek.monday     ? "Mon"   :
     dow == dayofweek.tuesday   ? "Tue"   :
     dow == dayofweek.wednesday ? "Wed"   :
     dow == dayofweek.thursday  ? "Thurs" :
     dow == dayofweek.friday    ? "Fri"   : ""

highLineStyle      = lineStyleFromInput(highLineStyleInput)
lowLineStyle       = lineStyleFromInput(lowLineStyleInput)
openLineStyle      = lineStyleFromInput(openLineStyleInput)
barChangeLineStyle = lineStyleFromInput(barChangeLineStyleInput)

string emptyText = ""

//==================================================================================================
// TYPES
//==================================================================================================
type PeriodData
    box   upperBox
    box   lowerBox
    line  highLine
    line  lowLine
    line  openLine
    line  barChangeLine
    label highLabel
    label lowLabel
    label openLabel
    label barChangeValueLabel
    label barChangeLabel
    label periodLabel
    label highSweepLabel
    label highSweepArrow
    label lowSweepArrow
    float openPrice
    float highPrice
    float lowPrice
    float closePrice
    int   startBar
    int   startTime
    bool  highSwept
    bool  lowSwept

//==================================================================================================
// STATE
//==================================================================================================
var periodArray = array.new<PeriodData>()
var prevBodyBoxes  = array.new_box()
var prevWickLines  = array.new_line()
var prevTextLabels = array.new_label()
var int activeSweepType = 0

visiblePeriodCount() =>
    prevCandlesToShow + 1

deletePeriodObjects(p) =>
    box.delete(p.upperBox)
    box.delete(p.lowerBox)
    line.delete(p.highLine)
    line.delete(p.lowLine)
    line.delete(p.openLine)
    line.delete(p.barChangeLine)
    if not na(p.highLabel)
        label.delete(p.highLabel)
    if not na(p.lowLabel)
        label.delete(p.lowLabel)
    if not na(p.openLabel)
        label.delete(p.openLabel)
    if not na(p.barChangeValueLabel)
        label.delete(p.barChangeValueLabel)
    if not na(p.barChangeLabel)
        label.delete(p.barChangeLabel)
    if not na(p.periodLabel)
        label.delete(p.periodLabel)
    if not na(p.highSweepLabel)
        label.delete(p.highSweepLabel)
    if not na(p.highSweepArrow)
        label.delete(p.highSweepArrow)
    if not na(p.lowSweepArrow)
        label.delete(p.lowSweepArrow)

//==================================================================================================
// HELPERS - OBJECT ARRAYS
//==================================================================================================
ensurePrevCandleObjects(count) =>
    while array.size(prevBodyBoxes) < count
        array.push(prevBodyBoxes, box.new(na, na, na, na, border_color = color.new(color.white, 100), bgcolor = color.new(color.white, 100), border_width = prevCandleBorderWidth))
    while array.size(prevWickLines) < count
        array.push(prevWickLines, line.new(na, na, na, na, color = color.new(color.white, 100), width = 1))
    while array.size(prevTextLabels) < count
        array.push(prevTextLabels, label.new(na, na, "", color = #00000000, textcolor = prevCandleLabelColor, style = label.style_label_center, size = labelSizeFromInput(prevCandleLabelSizeIn)))

hidePrevCandleObject(idx) =>
    if idx < array.size(prevBodyBoxes)
        box b = array.get(prevBodyBoxes, idx)
        box.set_left(b, na)
        box.set_right(b, na)
    if idx < array.size(prevWickLines)
        line w = array.get(prevWickLines, idx)
        line.set_x1(w, na)
        line.set_x2(w, na)
    if idx < array.size(prevTextLabels)
        label lb = array.get(prevTextLabels, idx)
        label.set_x(lb, na)

//==================================================================================================
// PERIOD DETECTION
//==================================================================================================
var bool isFirstBar = true
bool isNewPeriod = (ta.change(time(timeframeInput)) != 0) or isFirstBar
isFirstBar := false

int barsSinceNewPeriod = nz(ta.barssince(isNewPeriod), 0)
float curHigh = ta.highest(high, barsSinceNewPeriod + 1)
float curLow  = ta.lowest(low, barsSinceNewPeriod + 1)

//==================================================================================================
// NEW PERIOD SETUP
//==================================================================================================
if isNewPeriod
    if currentLabelsOnly and array.size(periodArray) > 0
        for i = 0 to array.size(periodArray) - 1
            PeriodData existing = array.get(periodArray, i)

            if not na(existing.highLabel)
                label.delete(existing.highLabel)
            if not na(existing.lowLabel)
                label.delete(existing.lowLabel)
            if not na(existing.openLabel)
                label.delete(existing.openLabel)
            if not na(existing.barChangeValueLabel)
                label.delete(existing.barChangeValueLabel)
            if not na(existing.barChangeLabel)
                label.delete(existing.barChangeLabel)
            if not na(existing.periodLabel)
                label.delete(existing.periodLabel)

            existing.highLabel           := na
            existing.lowLabel            := na
            existing.openLabel           := na
            existing.barChangeValueLabel := na
            existing.barChangeLabel      := na
            existing.periodLabel         := na

            array.set(periodArray, i, existing)

    PeriodData newData = PeriodData.new()
    newData.startBar   := bar_index
    newData.startTime  := time
    newData.openPrice  := open
    newData.highPrice  := high
    newData.lowPrice   := low
    newData.closePrice := close
    newData.highSwept  := false
    newData.lowSwept   := false

    color bullFill   = showBoxes ? bullBoxColor : color.new(bullBoxColor, 100)
    color bearFill   = showBoxes ? bearBoxColor : color.new(bearBoxColor, 100)
    color bullBorder = showBoxes ? bullBoxBorderColor : color.new(bullBoxBorderColor, 100)
    color bearBorder = showBoxes ? bearBoxBorderColor : color.new(bearBoxBorderColor, 100)

    newData.upperBox := box.new(bar_index, high, bar_index, open, border_color = bullBorder, bgcolor = bullFill)
    newData.lowerBox := box.new(bar_index, open, bar_index, low, border_color = bearBorder, bgcolor = bearFill)

    float initialBarChangeTicks = (close - open) / syminfo.mintick
    float initialBarChangePrice = open + (initialBarChangeTicks * syminfo.mintick)

    newData.highLine      := line.new(bar_index, high, bar_index, high, color = showHighLine ? highLineColor : color.new(highLineColor, 100), style = highLineStyle, width = highLineWidth)
    newData.lowLine       := line.new(bar_index, low, bar_index, low, color = showLowLine ? lowLineColor : color.new(lowLineColor, 100), style = lowLineStyle, width = lowLineWidth)
    newData.openLine      := line.new(bar_index, open, bar_index, open, color = showOpenLine ? openLineColor : color.new(openLineColor, 100), style = openLineStyle, width = openLineWidth)
    newData.barChangeLine := line.new(bar_index, initialBarChangePrice, bar_index, initialBarChangePrice, color = showBarChangeValueLine ? barChangeValueLineColor : color.new(barChangeValueLineColor, 100), style = barChangeLineStyle, width = barChangeLineWidth)

    if showLabels
        if showHighLabel
            newData.highLabel := label.new(bar_index, high, "High: " + formatPrice(high), color = #00000000, textcolor = highLabelColor, style = label.style_label_left, size = labelSizeFromInput(labelSizeInput))
        if showLowLabel
            newData.lowLabel := label.new(bar_index, low, "Low: " + formatPrice(low), color = #00000000, textcolor = lowLabelColor, style = label.style_label_left, size = labelSizeFromInput(labelSizeInput))
        if showOpenLabel
            newData.openLabel := label.new(bar_index, open, "Open: " + formatPrice(open), color = #00000000, textcolor = openLabelColor, style = label.style_label_left, size = labelSizeFromInput(labelSizeInput))
        if showBarChangeValueLabel
            newData.barChangeValueLabel := label.new(bar_index, initialBarChangePrice, "Bar Change Value: " + formatBarChangeTicks(initialBarChangeTicks), color = #00000000, textcolor = initialBarChangeTicks >= 0 ? barChangeValueUpColor : barChangeValueDnColor, style = label.style_label_left, size = labelSizeFromInput(labelSizeInput))
        if showBarChangeLabel
            newData.barChangeLabel := label.new(bar_index, low, "Bar Change: " + formatBarChangeTicks(initialBarChangeTicks), color = #00000000, textcolor = initialBarChangeTicks >= 0 ? barChangeUpLabelColor : barChangeDnLabelColor, style = label.style_label_center, size = labelSizeFromInput(labelSizeInput))
        if showPeriodLabel
            newData.periodLabel := label.new(bar_index, high, timeframeInput, color = #00000000, textcolor = periodLabelColor, style = label.style_label_center, size = labelSizeFromInput(periodLabelSizeInput))

    array.unshift(periodArray, newData)

    if not keepHistoricalBoxes
        while array.size(periodArray) > 1
            PeriodData oldNoHist = array.pop(periodArray)
            deletePeriodObjects(oldNoHist)
    else
        while array.size(periodArray) > visiblePeriodCount()
            PeriodData old = array.pop(periodArray)
            deletePeriodObjects(old)

//==================================================================================================
// UPDATES
//==================================================================================================
activeSweepType := 0

if array.size(periodArray) > 0
    PeriodData p = array.get(periodArray, 0)

    p.highPrice  := curHigh
    p.lowPrice   := curLow
    p.closePrice := close

    float curOpen          = p.openPrice
    float barChangeTicks   = (close - curOpen) / syminfo.mintick
    float barChangePrice   = curOpen + (barChangeTicks * syminfo.mintick)

    color barChangeValueDynColor = barChangeTicks >= 0 ? barChangeValueUpColor : barChangeValueDnColor
    color barChangeLabelDynColor = barChangeTicks >= 0 ? barChangeUpLabelColor : barChangeDnLabelColor
    color dirCol                 = barChangeTicks >= 0 ? #089981 : #f23645
    string currentTradingDayText = tradingDayAbbrevFromTimestamp(p.startTime)

    int bigCandleMid    = math.floor(bigCandleWidthBars / 2)
    int currentBigLeft  = showBigCandle and barstate.islast ? bar_index + bigCandleOffset : bar_index
    int currentBigRight = showBigCandle and barstate.islast ? currentBigLeft + bigCandleWidthBars : bar_index

    int projectionRight = showBigCandle and barstate.islast ? currentBigRight : bar_index
    int labelX          = showBigCandle and barstate.islast ? currentBigRight + 1 : bar_index

    box.set_right(p.upperBox, projectionRight)
    box.set_top(p.upperBox, curHigh)
    box.set_bottom(p.upperBox, curOpen)
    box.set_bgcolor(p.upperBox, showBoxes ? bullBoxColor : color.new(bullBoxColor, 100))
    box.set_border_color(p.upperBox, showBoxes ? bullBoxBorderColor : color.new(bullBoxBorderColor, 100))

    box.set_right(p.lowerBox, projectionRight)
    box.set_top(p.lowerBox, curOpen)
    box.set_bottom(p.lowerBox, curLow)
    box.set_bgcolor(p.lowerBox, showBoxes ? bearBoxColor : color.new(bearBoxColor, 100))
    box.set_border_color(p.lowerBox, showBoxes ? bearBoxBorderColor : color.new(bearBoxBorderColor, 100))

    line.set_x2(p.highLine, projectionRight)
    line.set_y1(p.highLine, curHigh)
    line.set_y2(p.highLine, curHigh)
    line.set_color(p.highLine, showHighLine ? highLineColor : color.new(highLineColor, 100))
    line.set_style(p.highLine, highLineStyle)
    line.set_width(p.highLine, highLineWidth)

    line.set_x2(p.lowLine, projectionRight)
    line.set_y1(p.lowLine, curLow)
    line.set_y2(p.lowLine, curLow)
    line.set_color(p.lowLine, showLowLine ? lowLineColor : color.new(lowLineColor, 100))
    line.set_style(p.lowLine, lowLineStyle)
    line.set_width(p.lowLine, lowLineWidth)

    line.set_x2(p.openLine, projectionRight)
    line.set_y1(p.openLine, curOpen)
    line.set_y2(p.openLine, curOpen)
    line.set_color(p.openLine, showOpenLine ? openLineColor : color.new(openLineColor, 100))
    line.set_style(p.openLine, openLineStyle)
    line.set_width(p.openLine, openLineWidth)

    line.set_x2(p.barChangeLine, projectionRight)
    line.set_y1(p.barChangeLine, barChangePrice)
    line.set_y2(p.barChangeLine, barChangePrice)
    line.set_color(p.barChangeLine, showBarChangeValueLine ? barChangeValueLineColor : color.new(barChangeValueLineColor, 100))
    line.set_style(p.barChangeLine, barChangeLineStyle)
    line.set_width(p.barChangeLine, barChangeLineWidth)

    if showLabels
        if not na(p.highLabel)
            label.set_x(p.highLabel, labelX)
            label.set_y(p.highLabel, curHigh)
            label.set_text(p.highLabel, showHighLabel ? "High: " + formatPrice(curHigh) : emptyText)
            label.set_textcolor(p.highLabel, highLabelColor)

        if not na(p.lowLabel)
            label.set_x(p.lowLabel, labelX)
            label.set_y(p.lowLabel, curLow)
            label.set_text(p.lowLabel, showLowLabel ? "Low: " + formatPrice(curLow) : emptyText)
            label.set_textcolor(p.lowLabel, lowLabelColor)

        if not na(p.openLabel)
            label.set_x(p.openLabel, labelX)
            label.set_y(p.openLabel, curOpen)
            label.set_text(p.openLabel, showOpenLabel ? "Open: " + formatPrice(curOpen) : emptyText)
            label.set_textcolor(p.openLabel, openLabelColor)

        if not na(p.barChangeValueLabel)
            label.set_x(p.barChangeValueLabel, labelX)
            label.set_y(p.barChangeValueLabel, barChangePrice)
            label.set_text(p.barChangeValueLabel, showBarChangeValueLabel ? "Bar Change Value: " + formatBarChangeTicks(barChangeTicks) : emptyText)
            label.set_textcolor(p.barChangeValueLabel, barChangeValueDynColor)

        if not na(p.barChangeLabel)
            label.set_x(p.barChangeLabel, labelX)
            label.set_y(p.barChangeLabel, curLow - (syminfo.mintick * barChangeYOffsetTicks))
            label.set_text(p.barChangeLabel, showBarChangeLabel ? "Bar Change: " + formatBarChangeTicks(barChangeTicks) : emptyText)
            label.set_textcolor(p.barChangeLabel, barChangeLabelDynColor)

        if not na(p.periodLabel)
            label.set_x(p.periodLabel, labelX)
            label.set_y(p.periodLabel, curHigh + (syminfo.mintick * periodYOffsetTicks))
            label.set_text(p.periodLabel, showPeriodLabel ? timeframeInput : emptyText)
            label.set_textcolor(p.periodLabel, periodLabelColor)

    if array.size(periodArray) > 1
        PeriodData prev = array.get(periodArray, 1)

        if extendPrevHL
            line.set_x2(prev.highLine, bar_index)
            line.set_x2(prev.lowLine, bar_index)
            line.set_color(prev.highLine, showHighLine ? highLineColor : color.new(highLineColor, 100))
            line.set_color(prev.lowLine, showLowLine ? lowLineColor : color.new(lowLineColor, 100))
            line.set_style(prev.highLine, highLineStyle)
            line.set_style(prev.lowLine, lowLineStyle)
            line.set_width(prev.highLine, highLineWidth)
            line.set_width(prev.lowLine, lowLineWidth)

        float prevHigh = prev.highPrice
        float prevLow  = prev.lowPrice

        bool newHighSweep = enableHighSweep and not p.highSwept and high > prevHigh
        bool newLowSweep  = enableLowSweep and not p.lowSwept and low < prevLow

        if newHighSweep
            p.highSwept := true

            if showHighSweepLabel
                p.highSweepLabel := label.new(
                     bar_index,
                     prevHigh,
                     highSweepText,
                     color = #00000000,
                     textcolor = highSweepColor,
                     style = label.style_label_down,
                     size = labelSizeFromInput(sweepArrowSizeInput))

            if showHighSweepArrow
                p.highSweepArrow := label.new(
                     bar_index,
                     low,
                     "▲",
                     color = #00000000,
                     textcolor = highSweepArrowColor,
                     style = label.style_label_up,
                     size = labelSizeFromInput(sweepArrowSizeInput))

            if colorSweepCandles
                activeSweepType := 1

        if newLowSweep
            p.lowSwept := true

            if showLowSweepArrow
                p.lowSweepArrow := label.new(
                     bar_index,
                     high,
                     "▼",
                     color = #00000000,
                     textcolor = lowSweepArrowColor,
                     style = label.style_label_down,
                     size = labelSizeFromInput(sweepArrowSizeInput))

            if colorSweepCandles
                activeSweepType := -1

    array.set(periodArray, 0, p)

    //==================================================================================================
    // CURRENT BIG CANDLE PROJECTION
    //==================================================================================================
    var box   bigCandleBody = box.new(na, na, na, na, border_color = #089981, bgcolor = #089981)
    var line  bigCandleWick = line.new(na, na, na, na, color = #089981)
    var label bigCandleText = label.new(na, na, "", color = #00000000, textcolor = bigCandleTextColor, style = label.style_label_center)

    if showBigCandle and barstate.islast
        box.set_left(bigCandleBody, currentBigLeft)
        box.set_right(bigCandleBody, currentBigRight)
        box.set_top(bigCandleBody, math.max(curOpen, close))
        box.set_bottom(bigCandleBody, math.min(curOpen, close))
        box.set_bgcolor(bigCandleBody, dirCol)
        box.set_border_color(bigCandleBody, dirCol)

        line.set_xy1(bigCandleWick, currentBigLeft + bigCandleMid, curHigh)
        line.set_xy2(bigCandleWick, currentBigLeft + bigCandleMid, curLow)
        line.set_color(bigCandleWick, dirCol)
        line.set_width(bigCandleWick, 2)

        label.set_xy(bigCandleText, currentBigLeft + bigCandleMid, curHigh + (syminfo.mintick * bigCandleTextOffset))
        label.set_text(bigCandleText, currentTradingDayText)
        label.set_textcolor(bigCandleText, bigCandleTextColor)
        label.set_size(bigCandleText, labelSizeFromInput(periodLabelSizeInput))
    else
        box.set_left(bigCandleBody, na)
        box.set_right(bigCandleBody, na)
        line.set_x1(bigCandleWick, na)
        line.set_x2(bigCandleWick, na)
        label.set_x(bigCandleText, na)

    //==================================================================================================
    // PREVIOUS CANDLE PROJECTIONS
    //==================================================================================================
    ensurePrevCandleObjects(prevCandlesToShow)

    if showPrevCandles and barstate.islast and array.size(periodArray) > 1
        int drawnCount = 0

        for i = 1 to array.size(periodArray) - 1
            if drawnCount >= prevCandlesToShow
                break

            PeriodData hp = array.get(periodArray, i)

            if isTradingWeekday(hp.startTime)
                int objIdx = drawnCount

                int prevRight = currentBigLeft - prevCandleGapBars - (drawnCount * (prevCandleWidthBars + prevCandleGapBars))
                int prevLeft  = prevRight - prevCandleWidthBars
                int prevMid   = prevLeft + math.floor(prevCandleWidthBars / 2)

                float prevOpen  = hp.openPrice
                float prevClose = hp.closePrice
                float prevHigh  = hp.highPrice
                float prevLow   = hp.lowPrice

                bool prevBull = prevClose >= prevOpen
                color prevBodyColor = prevBull ? prevBullBodyColor : prevBearBodyColor
                color prevWickColor = prevBull ? prevBullWickColor : prevBearWickColor

                box b = array.get(prevBodyBoxes, objIdx)
                line w = array.get(prevWickLines, objIdx)
                label lb = array.get(prevTextLabels, objIdx)

                box.set_left(b, prevLeft)
                box.set_right(b, prevRight)
                box.set_top(b, math.max(prevOpen, prevClose))
                box.set_bottom(b, math.min(prevOpen, prevClose))
                box.set_bgcolor(b, prevBodyColor)
                box.set_border_color(b, prevBodyColor)
                box.set_border_width(b, prevCandleBorderWidth)

                line.set_xy1(w, prevMid, prevHigh)
                line.set_xy2(w, prevMid, prevLow)
                line.set_color(w, prevWickColor)
                line.set_width(w, prevCandleWickWidth)

                if showPrevCandleLabels
                    label.set_xy(lb, prevMid, prevHigh + (syminfo.mintick * prevCandleLabelOffset))
                    label.set_text(lb, tradingDayAbbrevFromTimestamp(hp.startTime))
                    label.set_textcolor(lb, prevCandleLabelColor)
                    label.set_size(lb, labelSizeFromInput(prevCandleLabelSizeIn))
                else
                    label.set_x(lb, na)

                drawnCount += 1

        if drawnCount < prevCandlesToShow
            for j = drawnCount to prevCandlesToShow - 1
                hidePrevCandleObject(j)
    else
        for i = 0 to prevCandlesToShow - 1
            hidePrevCandleObject(i)

    while array.size(periodArray) > visiblePeriodCount()
        PeriodData oldTrim = array.pop(periodArray)
        deletePeriodObjects(oldTrim)

//==================================================================================================
// SWEEP CANDLE STYLING
//==================================================================================================
float sweepOpen  = colorSweepCandles and activeSweepType != 0 ? open  : na
float sweepHigh  = colorSweepCandles and activeSweepType != 0 ? high  : na
float sweepLow   = colorSweepCandles and activeSweepType != 0 ? low   : na
float sweepClose = colorSweepCandles and activeSweepType != 0 ? close : na

color sweepBodyColor =
     activeSweepType == 1 ? highSweepCandleBodyColor :
     activeSweepType == -1 ? lowSweepCandleBodyColor : na

color sweepWickColor =
     activeSweepType == 1 ? highSweepCandleWickColor :
     activeSweepType == -1 ? lowSweepCandleWickColor : na

color sweepBorderColor =
     activeSweepType == 1 ? highSweepCandleBorderColor :
     activeSweepType == -1 ? lowSweepCandleBorderColor : na

plotcandle(
     sweepOpen,
     sweepHigh,
     sweepLow,
     sweepClose,
     title = "Sweep Candle Overlay",
     color = sweepBodyColor,
     wickcolor = sweepWickColor,
     bordercolor = sweepBorderColor)
````
