# SMC + Support Resistance Level by Mas Sat

- url: https://www.tradingview.com/script/rw5SkwMe-SMC-Support-Resistance-Level-by-Mas-Sat/
- type: indicator
- pine_id: PUB;48ca1344572b407d9390d6b0e0e4bf36
- version: 1.0

## Description

SMC + Support & Resistance Level by Mas Sat

This indicator combines two popular concepts
into a single view: Smart Money Concepts (SMC)
and Support & Resistance Levels with Breaks.

The goal is to help beginner traders (like myself)
see market structure, order blocks, fair value gaps,
liquidity, and support/resistance levels on one
chart without needing multiple separate indicators.

KEY FEATURES:

Smart Money Concepts:
- Internal & Swing Market Structure (BOS/CHoCH)
- Order Blocks (Internal & Swing)
- Fair Value Gaps (FVG)
- Equal Highs/Lows (EQH/EQL)
- Premium & Discount Zones
- Strong/Weak High-Low labels
- Multi-timeframe levels (Daily/Weekly/Monthly)

Support & Resistance:
- Automatic support/resistance level detection
- Breakout labels with volume confirmation
- Wick break detection (bullish/bearish)

HOW TO USE:

Use H4/Daily to determine bias,
H1 to identify zones (OB, FVG, S&R),
and M15/M5 to confirm entry
(sweep + CHoCH).

CREDIT & LICENSE:

This indicator is a modification and combination
of two works by LuxAlgo:
- Smart Money Concepts [LuxAlgo]
- Support and Resistance Levels with Breaks
  [LuxAlgo]

All core logic belongs to LuxAlgo.
I only combined and adapted them for
Pine Script v6 and added some labels
in Indonesian.

License: CC BY-NC-SA 4.0
https://creativecommons.org/licenses/by-nc-sa/4.0/

DISCLAIMER:

This indicator is an analysis tool,
not an automatic trading signal.
Always use proper risk management and
do additional analysis before entering a trade.

by Mas Sat — Let's learn together!
Feedback and suggestions are always welcome.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════
// SMC + Support Resistance Level by Mas Sat
// Gabungan: Smart Money Concepts [LuxAlgo] + Support & Resistance Levels with Breaks [LuxAlgo]
// Dikonversi ke Pine Script v6 & digabungkan oleh Mas Sat — Ayo belajar bareng
// Lisensi asal: CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
// ═══════════════════════════════════════════════════════════════════

//@version=6
indicator('SMC + Support Resistance Level by Mas Sat', 'MasSat - SMC+SR', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 1 — CONSTANTS & STRINGS
//---------------------------------------------------------------------------------------------------------------------{
BULLISH_LEG                     = 1
BEARISH_LEG                     = 0

BULLISH                         = +1
BEARISH                         = -1

GREEN                           = #089981
RED                             = #F23645
BLUE                            = #2157f3
GRAY                            = #878b94
MONO_BULLISH                    = #b2b5be
MONO_BEARISH                    = #5d606b

HISTORICAL                      = 'Historical'
PRESENT                         = 'Present'

COLORED                         = 'Colored'
MONOCHROME                      = 'Monochrome'

ALL                             = 'All'
BOS                             = 'BOS'
CHOCH                           = 'CHoCH'

TINY                            = size.tiny
SMALL                           = size.small
NORMAL                          = size.normal

ATR                             = 'Atr'
RANGE                           = 'Cumulative Mean Range'

CLOSE                           = 'Close'
HIGHLOW                         = 'High/Low'

SOLID                           = '⎯⎯⎯'
DASHED                          = '----'
DOTTED                          = '····'

// Group names
SR_GROUP                        = '══ Support & Resistance ══'
SMART_GROUP                     = '══ Smart Money Concepts ══'
INTERNAL_GROUP                  = 'Real Time Internal Structure'
SWING_GROUP                     = 'Real Time Swing Structure'
BLOCKS_GROUP                    = 'Order Blocks'
EQUAL_GROUP                     = 'EQH/EQL'
GAPS_GROUP                      = 'Fair Value Gaps'
LEVELS_GROUP                    = 'Highs & Lows MTF'
ZONES_GROUP                     = 'Premium & Discount Zones'

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 2 — INPUTS: SUPPORT & RESISTANCE
//---------------------------------------------------------------------------------------------------------------------{
toggleBreaks        = input.bool(   true,   'Show Breaks',          group = SR_GROUP)
leftBars            = input.int(    15,     'Left Bars',            group = SR_GROUP, minval = 1)
rightBars           = input.int(    15,     'Right Bars',           group = SR_GROUP, minval = 1)
volumeThresh        = input.int(    20,     'Volume Threshold',     group = SR_GROUP, minval = 0)
srResistColor       = input.color(  #FF0000,'Resistance Color',     group = SR_GROUP)
srSupportColor      = input.color(  #233dee,'Support Color',        group = SR_GROUP)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 3 — INPUTS: SMART MONEY CONCEPTS
//---------------------------------------------------------------------------------------------------------------------{
modeTooltip                     = 'Allows to display historical Structure or only the recent ones'
styleTooltip                    = 'Indicator color theme'
showTrendTooltip                = 'Display additional candles with a color reflecting the current trend detected by structure'
showInternalsTooltip            = 'Display internal market structure'
internalFilterConfluenceTooltip = 'Filter non significant internal structure breakouts'
showStructureTooltip            = 'Display swing market Structure'
showSwingsTooltip               = 'Display swing point as labels on the chart'
showHighLowSwingsTooltip        = 'Highlight most recent strong and weak high/low points on the chart'
showInternalOrderBlocksTooltip  = 'Display internal order blocks on the chart\n\nNumber of internal order blocks to display on the chart'
showSwingOrderBlocksTooltip     = 'Display swing order blocks on the chart\n\nNumber of internal swing blocks to display on the chart'
orderBlockFilterTooltip         = 'Method used to filter out volatile order blocks \n\nIt is recommended to use the cumulative mean range method when a low amount of data is available'
orderBlockMitigationTooltip     = 'Select what values to use for order block mitigation'
showEqualHighsLowsTooltip       = 'Display equal highs and equal lows on the chart'
equalHighsLowsLengthTooltip     = 'Number of bars used to confirm equal highs and equal lows'
equalHighsLowsThresholdTooltip  = 'Sensitivity threshold in a range (0, 1) used for the detection of equal highs & lows\n\nLower values will return fewer but more pertinent results'
showFairValueGapsTooltip        = 'Display fair values gaps on the chart'
fairValueGapsThresholdTooltip   = 'Filter out non significant fair value gaps'
fairValueGapsTimeframeTooltip   = 'Fair value gaps timeframe'
fairValueGapsExtendTooltip      = 'Determine how many bars to extend the Fair Value Gap boxes on chart'
showPremiumDiscountZonesTooltip = 'Display premium, discount, and equilibrium zones on chart'

modeInput                       = input.string( HISTORICAL, 'Mode',                     group = SMART_GROUP,    tooltip = modeTooltip, options = [HISTORICAL, PRESENT])
styleInput                      = input.string( COLORED,    'Style',                    group = SMART_GROUP,    tooltip = styleTooltip,options = [COLORED, MONOCHROME])
showTrendInput                  = input(        false,      'Color Candles',            group = SMART_GROUP,    tooltip = showTrendTooltip)

showInternalsInput              = input(        true,       'Show Internal Structure',  group = INTERNAL_GROUP, tooltip = showInternalsTooltip)
showInternalBullInput           = input.string( ALL,        'Bullish Structure',        group = INTERNAL_GROUP, inline = 'ibull', options = [ALL,BOS,CHOCH])
internalBullColorInput          = input(        GREEN,      '',                         group = INTERNAL_GROUP, inline = 'ibull')
showInternalBearInput           = input.string( ALL,        'Bearish Structure' ,       group = INTERNAL_GROUP, inline = 'ibear', options = [ALL,BOS,CHOCH])
internalBearColorInput          = input(        RED,        '',                         group = INTERNAL_GROUP, inline = 'ibear')
internalFilterConfluenceInput   = input(        false,      'Confluence Filter',        group = INTERNAL_GROUP, tooltip = internalFilterConfluenceTooltip)
internalStructureSize           = input.string( TINY,       'Internal Label Size',      group = INTERNAL_GROUP, options = [TINY,SMALL,NORMAL])

showStructureInput              = input(        true,       'Show Swing Structure',     group = SWING_GROUP,    tooltip = showStructureTooltip)
showSwingBullInput              = input.string( ALL,        'Bullish Structure',        group = SWING_GROUP,    inline = 'bull',    options = [ALL,BOS,CHOCH])
swingBullColorInput             = input(        GREEN,      '',                         group = SWING_GROUP,    inline = 'bull')
showSwingBearInput              = input.string( ALL,        'Bearish Structure',        group = SWING_GROUP,    inline = 'bear',    options = [ALL,BOS,CHOCH])
swingBearColorInput             = input(        RED,        '',                         group = SWING_GROUP,    inline = 'bear')
swingStructureSize              = input.string( SMALL,      'Swing Label Size',         group = SWING_GROUP,    options = [TINY,SMALL,NORMAL])
showSwingsInput                 = input(        false,      'Show Swings Points',       group = SWING_GROUP,    tooltip = showSwingsTooltip,inline = 'swings')
swingsLengthInput               = input.int(    50,         '',                         group = SWING_GROUP,    minval = 10,                inline = 'swings')
showHighLowSwingsInput          = input(        true,       'Show Strong/Weak High/Low',group = SWING_GROUP,    tooltip = showHighLowSwingsTooltip)

showInternalOrderBlocksInput    = input(        true,       'Internal Order Blocks' ,   group = BLOCKS_GROUP,   tooltip = showInternalOrderBlocksTooltip,   inline = 'iob')
internalOrderBlocksSizeInput    = input.int(    5,          '',                         group = BLOCKS_GROUP,   minval = 1, maxval = 20,                    inline = 'iob')
showSwingOrderBlocksInput       = input(        false,      'Swing Order Blocks',       group = BLOCKS_GROUP,   tooltip = showSwingOrderBlocksTooltip,      inline = 'ob')
swingOrderBlocksSizeInput       = input.int(    5,          '',                         group = BLOCKS_GROUP,   minval = 1, maxval = 20,                    inline = 'ob')
orderBlockFilterInput           = input.string( 'Atr',      'Order Block Filter',       group = BLOCKS_GROUP,   tooltip = orderBlockFilterTooltip,          options = [ATR, RANGE])
orderBlockMitigationInput       = input.string( HIGHLOW,    'Order Block Mitigation',   group = BLOCKS_GROUP,   tooltip = orderBlockMitigationTooltip,      options = [CLOSE,HIGHLOW])
internalBullishOrderBlockColor  = input.color(color.new(#3179f5, 80), 'Internal Bullish OB',    group = BLOCKS_GROUP)
internalBearishOrderBlockColor  = input.color(color.new(#f77c80, 80), 'Internal Bearish OB',    group = BLOCKS_GROUP)
swingBullishOrderBlockColor     = input.color(color.new(#1848cc, 80), 'Bullish OB',             group = BLOCKS_GROUP)
swingBearishOrderBlockColor     = input.color(color.new(#b22833, 80), 'Bearish OB',             group = BLOCKS_GROUP)

showEqualHighsLowsInput         = input(        true,       'Equal High/Low',           group = EQUAL_GROUP,    tooltip = showEqualHighsLowsTooltip)
equalHighsLowsLengthInput       = input.int(    3,          'Bars Confirmation',        group = EQUAL_GROUP,    tooltip = equalHighsLowsLengthTooltip,      minval = 1)
equalHighsLowsThresholdInput    = input.float(  0.1,        'Threshold',                group = EQUAL_GROUP,    tooltip = equalHighsLowsThresholdTooltip,   minval = 0, maxval = 0.5, step = 0.1)
equalHighsLowsSizeInput         = input.string( TINY,       'Label Size',               group = EQUAL_GROUP,    options = [TINY,SMALL,NORMAL])

showFairValueGapsInput          = input(        false,      'Fair Value Gaps',          group = GAPS_GROUP,     tooltip = showFairValueGapsTooltip)
fairValueGapsThresholdInput     = input(        true,       'Auto Threshold',           group = GAPS_GROUP,     tooltip = fairValueGapsThresholdTooltip)
fairValueGapsTimeframeInput     = input.timeframe('',       'Timeframe',                group = GAPS_GROUP,     tooltip = fairValueGapsTimeframeTooltip)
fairValueGapsBullColorInput     = input.color(color.new(#00ff68, 70), 'Bullish FVG',   group = GAPS_GROUP)
fairValueGapsBearColorInput     = input.color(color.new(#ff0008, 70), 'Bearish FVG',   group = GAPS_GROUP)
fairValueGapsExtendInput        = input.int(    1,          'Extend FVG',               group = GAPS_GROUP,     tooltip = fairValueGapsExtendTooltip,       minval = 0)

showDailyLevelsInput            = input(        false,      'Daily',    group = LEVELS_GROUP,   inline = 'daily')
dailyLevelsStyleInput           = input.string( SOLID,      '',         group = LEVELS_GROUP,   inline = 'daily',   options = [SOLID,DASHED,DOTTED])
dailyLevelsColorInput           = input(        BLUE,       '',         group = LEVELS_GROUP,   inline = 'daily')
showWeeklyLevelsInput           = input(        false,      'Weekly',   group = LEVELS_GROUP,   inline = 'weekly')
weeklyLevelsStyleInput          = input.string( SOLID,      '',         group = LEVELS_GROUP,   inline = 'weekly',  options = [SOLID,DASHED,DOTTED])
weeklyLevelsColorInput          = input(        BLUE,       '',         group = LEVELS_GROUP,   inline = 'weekly')
showMonthlyLevelsInput          = input(        false,      'Monthly',  group = LEVELS_GROUP,   inline = 'monthly')
monthlyLevelsStyleInput         = input.string( SOLID,      '',         group = LEVELS_GROUP,   inline = 'monthly', options = [SOLID,DASHED,DOTTED])
monthlyLevelsColorInput         = input(        BLUE,       '',         group = LEVELS_GROUP,   inline = 'monthly')

showPremiumDiscountZonesInput   = input(        false,      'Premium/Discount Zones',   group = ZONES_GROUP,    tooltip = showPremiumDiscountZonesTooltip)
premiumZoneColorInput           = input.color(  RED,        'Premium Zone',             group = ZONES_GROUP)
equilibriumZoneColorInput       = input.color(  GRAY,       'Equilibrium Zone',         group = ZONES_GROUP)
discountZoneColorInput          = input.color(  GREEN,      'Discount Zone',            group = ZONES_GROUP)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 4 — DATA STRUCTURES (SMC)
//---------------------------------------------------------------------------------------------------------------------{
type alerts
    bool internalBullishBOS         = false
    bool internalBearishBOS         = false
    bool internalBullishCHoCH       = false
    bool internalBearishCHoCH       = false
    bool swingBullishBOS            = false
    bool swingBearishBOS            = false
    bool swingBullishCHoCH          = false
    bool swingBearishCHoCH          = false
    bool internalBullishOrderBlock  = false
    bool internalBearishOrderBlock  = false
    bool swingBullishOrderBlock     = false
    bool swingBearishOrderBlock     = false
    bool equalHighs                 = false
    bool equalLows                  = false
    bool bullishFairValueGap        = false
    bool bearishFairValueGap        = false
    // SR alerts
    bool supportBroken              = false
    bool resistanceBroken           = false

type trailingExtremes
    float top
    float bottom
    int barTime
    int barIndex
    int lastTopTime
    int lastBottomTime

type fairValueGap
    float top
    float bottom
    int bias
    box topBox
    box bottomBox

type trend
    int bias

type equalDisplay
    line l_ine      = na
    label l_abel    = na

type pivot
    float currentLevel
    float lastLevel
    bool crossed
    int barTime     = time
    int barIndex    = bar_index

type orderBlock
    float barHigh
    float barLow
    int barTime
    int bias

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 5 — VARIABLES (SMC)
//---------------------------------------------------------------------------------------------------------------------{
var pivot swingHigh                 = pivot.new(na,na,false)
var pivot swingLow                  = pivot.new(na,na,false)
var pivot internalHigh              = pivot.new(na,na,false)
var pivot internalLow               = pivot.new(na,na,false)
var pivot equalHigh                 = pivot.new(na,na,false)
var pivot equalLow                  = pivot.new(na,na,false)
var trend swingTrend                = trend.new(0)
var trend internalTrend             = trend.new(0)
var equalDisplay equalHighDisplay   = equalDisplay.new()
var equalDisplay equalLowDisplay    = equalDisplay.new()
var array<fairValueGap> fairValueGaps       = array.new<fairValueGap>()
var array<float> parsedHighs                = array.new<float>()
var array<float> parsedLows                 = array.new<float>()
var array<float> highs                      = array.new<float>()
var array<float> lows                       = array.new<float>()
var array<int> times                        = array.new<int>()
var trailingExtremes trailing               = trailingExtremes.new()
var array<orderBlock> swingOrderBlocks      = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks   = array.new<orderBlock>()
var array<box> swingOrderBlocksBoxes        = array.new<box>()
var array<box> internalOrderBlocksBoxes     = array.new<box>()

var swingBullishColor               = styleInput == MONOCHROME ? MONO_BULLISH : swingBullColorInput
var swingBearishColor               = styleInput == MONOCHROME ? MONO_BEARISH : swingBearColorInput
var fairValueGapBullishColor        = styleInput == MONOCHROME ? color.new(MONO_BULLISH,70) : fairValueGapsBullColorInput
var fairValueGapBearishColor        = styleInput == MONOCHROME ? color.new(MONO_BEARISH,70) : fairValueGapsBearColorInput
var premiumZoneColor                = styleInput == MONOCHROME ? MONO_BEARISH : premiumZoneColorInput
var discountZoneColor               = styleInput == MONOCHROME ? MONO_BULLISH : discountZoneColorInput

varip int currentBarIndex           = bar_index
varip int lastBarIndex              = bar_index
alerts currentAlerts                = alerts.new()
var initialTime                     = time

// Box setup untuk Order Blocks
if barstate.isfirst
    if showSwingOrderBlocksInput
        for index = 1 to swingOrderBlocksSizeInput
            swingOrderBlocksBoxes.push(box.new(na,na,na,na,xloc = xloc.bar_time,extend = extend.right))
    if showInternalOrderBlocksInput
        for index = 1 to internalOrderBlocksSizeInput
            internalOrderBlocksBoxes.push(box.new(na,na,na,na,xloc = xloc.bar_time,extend = extend.right))

bearishOrderBlockMitigationSource   = orderBlockMitigationInput == CLOSE ? close : high
bullishOrderBlockMitigationSource   = orderBlockMitigationInput == CLOSE ? close : low
atrMeasure                          = ta.atr(200)
volatilityMeasure                   = orderBlockFilterInput == ATR ? atrMeasure : ta.cum(ta.tr)/bar_index
highVolatilityBar                   = (high - low) >= (2 * volatilityMeasure)
parsedHigh                          = highVolatilityBar ? low : high
parsedLow                           = highVolatilityBar ? high : low

parsedHighs.push(parsedHigh)
parsedLows.push(parsedLow)
highs.push(high)
lows.push(low)
times.push(time)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 6 — FUNCTIONS: SMC
//---------------------------------------------------------------------------------------------------------------------{
leg(int size) =>
    var leg     = 0
    newLegHigh  = high[size] > ta.highest(size)
    newLegLow   = low[size]  < ta.lowest(size)
    if newLegHigh
        leg := BEARISH_LEG
    else if newLegLow
        leg := BULLISH_LEG
    leg

startOfNewLeg(int leg)      => ta.change(leg) != 0
startOfBearishLeg(int leg)  => ta.change(leg) == -1
startOfBullishLeg(int leg)  => ta.change(leg) == +1

drawLabel(int labelTime, float labelPrice, string tag, color labelColor, string labelStyle) =>
    var label l_abel = na
    if modeInput == PRESENT
        l_abel.delete()
    l_abel := label.new(chart.point.new(labelTime,na,labelPrice),tag,xloc.bar_time,color=color(na),textcolor=labelColor,style = labelStyle,size = size.small)

drawEqualHighLow(pivot p_ivot, float level, int size, bool equalHigh) =>
    equalDisplay e_qualDisplay = equalHigh ? equalHighDisplay : equalLowDisplay
    string tag          = 'EQL'
    color equalColor    = swingBullishColor
    string labelStyle   = label.style_label_up
    if equalHigh
        tag         := 'EQH'
        equalColor  := swingBearishColor
        labelStyle  := label.style_label_down
    if modeInput == PRESENT
        line.delete(    e_qualDisplay.l_ine)
        label.delete(   e_qualDisplay.l_abel)
    e_qualDisplay.l_ine     := line.new(chart.point.new(p_ivot.barTime,na,p_ivot.currentLevel), chart.point.new(time[size],na,level), xloc = xloc.bar_time, color = equalColor, style = line.style_dotted)
    labelPosition           = math.round(0.5*(p_ivot.barIndex + bar_index - size))
    e_qualDisplay.l_abel    := label.new(chart.point.new(na,labelPosition,level), tag, xloc.bar_index, color = color(na), textcolor = equalColor, style = labelStyle, size = equalHighsLowsSizeInput)

getCurrentStructure(int size, bool equalHighLow = false, bool internal = false) =>
    currentLeg  = leg(size)
    newPivot    = startOfNewLeg(currentLeg)
    pivotLow    = startOfBullishLeg(currentLeg)
    pivotHigh   = startOfBearishLeg(currentLeg)
    if newPivot
        if pivotLow
            pivot p_ivot = equalHighLow ? equalLow : internal ? internalLow : swingLow
            if equalHighLow and math.abs(p_ivot.currentLevel - low[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot, low[size], size, false)
                currentAlerts.equalLows := true
            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := low[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]
            if not equalHighLow and not internal
                trailing.bottom         := p_ivot.currentLevel
                trailing.barTime        := p_ivot.barTime
                trailing.barIndex       := p_ivot.barIndex
                trailing.lastBottomTime := p_ivot.barTime
            if showSwingsInput and not internal and not equalHighLow
                drawLabel(time[size], p_ivot.currentLevel, p_ivot.currentLevel < p_ivot.lastLevel ? 'LL' : 'HL', swingBullishColor, label.style_label_up)
        else
            pivot p_ivot = equalHighLow ? equalHigh : internal ? internalHigh : swingHigh
            if equalHighLow and math.abs(p_ivot.currentLevel - high[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot,high[size],size,true)
                currentAlerts.equalHighs := true
            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := high[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]
            if not equalHighLow and not internal
                trailing.top            := p_ivot.currentLevel
                trailing.barTime        := p_ivot.barTime
                trailing.barIndex       := p_ivot.barIndex
                trailing.lastTopTime    := p_ivot.barTime
            if showSwingsInput and not internal and not equalHighLow
                drawLabel(time[size], p_ivot.currentLevel, p_ivot.currentLevel > p_ivot.lastLevel ? 'HH' : 'LH', swingBearishColor, label.style_label_down)

drawStructure(pivot p_ivot, string tag, color structureColor, string lineStyle, string labelStyle, string labelSize) =>
    var line l_ine      = line.new(na,na,na,na,xloc = xloc.bar_time)
    var label l_abel    = label.new(na,na)
    if modeInput == PRESENT
        l_ine.delete()
        l_abel.delete()
    l_ine   := line.new(chart.point.new(p_ivot.barTime,na,p_ivot.currentLevel), chart.point.new(time,na,p_ivot.currentLevel), xloc.bar_time, color=structureColor, style=lineStyle)
    l_abel  := label.new(chart.point.new(na,math.round(0.5*(p_ivot.barIndex+bar_index)),p_ivot.currentLevel), tag, xloc.bar_index, color=color(na), textcolor=structureColor, style=labelStyle, size = labelSize)

deleteOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    for [index,eachOrderBlock] in orderBlocks
        bool crossedOderBlock = false
        if bearishOrderBlockMitigationSource > eachOrderBlock.barHigh and eachOrderBlock.bias == BEARISH
            crossedOderBlock := true
            if internal
                currentAlerts.internalBearishOrderBlock := true
            else
                currentAlerts.swingBearishOrderBlock    := true
        else if bullishOrderBlockMitigationSource < eachOrderBlock.barLow and eachOrderBlock.bias == BULLISH
            crossedOderBlock := true
            if internal
                currentAlerts.internalBullishOrderBlock := true
            else
                currentAlerts.swingBullishOrderBlock    := true
        if crossedOderBlock
            orderBlocks.remove(index)

storeOrdeBlock(pivot p_ivot, bool internal = false, int bias) =>
    if (not internal and showSwingOrderBlocksInput) or (internal and showInternalOrderBlocksInput)
        array<float> a_rray = na
        int parsedIndex = na
        if bias == BEARISH
            a_rray      := parsedHighs.slice(p_ivot.barIndex,bar_index)
            parsedIndex := p_ivot.barIndex + a_rray.indexof(a_rray.max())
        else
            a_rray      := parsedLows.slice(p_ivot.barIndex,bar_index)
            parsedIndex := p_ivot.barIndex + a_rray.indexof(a_rray.min())
        orderBlock o_rderBlock          = orderBlock.new(parsedHighs.get(parsedIndex), parsedLows.get(parsedIndex), times.get(parsedIndex),bias)
        array<orderBlock> orderBlocks   = internal ? internalOrderBlocks : swingOrderBlocks
        if orderBlocks.size() >= 100
            orderBlocks.pop()
        orderBlocks.unshift(o_rderBlock)

drawOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    orderBlocksSize = orderBlocks.size()
    if orderBlocksSize > 0
        maxOrderBlocks                      = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput
        array<orderBlock> parsedOrdeBlocks  = orderBlocks.slice(0, math.min(maxOrderBlocks,orderBlocksSize))
        array<box> b_oxes                   = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes
        for [index,eachOrderBlock] in parsedOrdeBlocks
            orderBlockColor = styleInput == MONOCHROME ? (eachOrderBlock.bias == BEARISH ? color.new(MONO_BEARISH,80) : color.new(MONO_BULLISH,80)) : internal ? (eachOrderBlock.bias == BEARISH ? internalBearishOrderBlockColor : internalBullishOrderBlockColor) : (eachOrderBlock.bias == BEARISH ? swingBearishOrderBlockColor : swingBullishOrderBlockColor)
            box b_ox        = b_oxes.get(index)
            b_ox.set_top_left_point(    chart.point.new(eachOrderBlock.barTime,na,eachOrderBlock.barHigh))
            b_ox.set_bottom_right_point(chart.point.new(last_bar_time,na,eachOrderBlock.barLow))
            b_ox.set_border_color(      internal ? na : orderBlockColor)
            b_ox.set_bgcolor(           orderBlockColor)

displayStructure(bool internal = false) =>
    var bullishBar = true
    var bearishBar = true
    if internalFilterConfluenceInput
        bullishBar := high - math.max(close, open) > math.min(close, open - low)
        bearishBar := high - math.max(close, open) < math.min(close, open - low)
    pivot p_ivot    = internal ? internalHigh : swingHigh
    trend t_rend    = internal ? internalTrend : swingTrend
    lineStyle       = internal ? line.style_dashed : line.style_solid
    labelSize       = internal ? internalStructureSize : swingStructureSize
    extraCondition  = internal ? internalHigh.currentLevel != swingHigh.currentLevel and bullishBar : true
    bullishColor    = styleInput == MONOCHROME ? MONO_BULLISH : internal ? internalBullColorInput : swingBullColorInput
    if ta.crossover(close,p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BEARISH ? CHOCH : BOS
        if internal
            currentAlerts.internalBullishCHoCH  := tag == CHOCH
            currentAlerts.internalBullishBOS    := tag == BOS
        else
            currentAlerts.swingBullishCHoCH     := tag == CHOCH
            currentAlerts.swingBullishBOS       := tag == BOS
        p_ivot.crossed  := true
        t_rend.bias     := BULLISH
        displayCondition = internal ? showInternalsInput and (showInternalBullInput == ALL or (showInternalBullInput == BOS and tag != CHOCH) or (showInternalBullInput == CHOCH and tag == CHOCH)) : showStructureInput and (showSwingBullInput == ALL or (showSwingBullInput == BOS and tag != CHOCH) or (showSwingBullInput == CHOCH and tag == CHOCH))
        if displayCondition
            drawStructure(p_ivot,tag,bullishColor,lineStyle,label.style_label_down,labelSize)
        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrdeBlock(p_ivot,internal,BULLISH)
    p_ivot          := internal ? internalLow : swingLow
    extraCondition  := internal ? internalLow.currentLevel != swingLow.currentLevel and bearishBar : true
    bearishColor    = styleInput == MONOCHROME ? MONO_BEARISH : internal ? internalBearColorInput : swingBearColorInput
    if ta.crossunder(close,p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BULLISH ? CHOCH : BOS
        if internal
            currentAlerts.internalBearishCHoCH  := tag == CHOCH
            currentAlerts.internalBearishBOS    := tag == BOS
        else
            currentAlerts.swingBearishCHoCH     := tag == CHOCH
            currentAlerts.swingBearishBOS       := tag == BOS
        p_ivot.crossed := true
        t_rend.bias := BEARISH
        displayCondition = internal ? showInternalsInput and (showInternalBearInput == ALL or (showInternalBearInput == BOS and tag != CHOCH) or (showInternalBearInput == CHOCH and tag == CHOCH)) : showStructureInput and (showSwingBearInput == ALL or (showSwingBearInput == BOS and tag != CHOCH) or (showSwingBearInput == CHOCH and tag == CHOCH))
        if displayCondition
            drawStructure(p_ivot,tag,bearishColor,lineStyle,label.style_label_up,labelSize)
        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrdeBlock(p_ivot,internal,BEARISH)

fairValueGapBox(leftTime, rightTime, topPrice, bottomPrice, boxColor) =>
    box.new(chart.point.new(leftTime,na,topPrice),chart.point.new(rightTime + fairValueGapsExtendInput * (time-time[1]),na,bottomPrice), xloc=xloc.bar_time, border_color = boxColor, bgcolor = boxColor)

deleteFairValueGaps() =>
    for [index,eachFairValueGap] in fairValueGaps
        if (low < eachFairValueGap.bottom and eachFairValueGap.bias == BULLISH) or (high > eachFairValueGap.top and eachFairValueGap.bias == BEARISH)
            eachFairValueGap.topBox.delete()
            eachFairValueGap.bottomBox.delete()
            fairValueGaps.remove(index)

drawFairValueGaps() =>
    [lastClose, lastOpen, lastTime, currentHigh, currentLow, currentTime, last2High, last2Low] = request.security(syminfo.tickerid, fairValueGapsTimeframeInput, [close[1], open[1], time[1], high[0], low[0], time[0], high[2], low[2]], lookahead = barmerge.lookahead_on)
    barDeltaPercent     = (lastClose - lastOpen) / (lastOpen * 100)
    newTimeframe        = timeframe.change(fairValueGapsTimeframeInput)
    threshold           = fairValueGapsThresholdInput ? ta.cum(math.abs(newTimeframe ? barDeltaPercent : 0)) / bar_index * 2 : 0
    bullishFairValueGap = currentLow > last2High and lastClose > last2High and barDeltaPercent > threshold and newTimeframe
    bearishFairValueGap = currentHigh < last2Low and lastClose < last2Low and -barDeltaPercent > threshold and newTimeframe
    if bullishFairValueGap
        currentAlerts.bullishFairValueGap := true
        fairValueGaps.unshift(fairValueGap.new(currentLow,last2High,BULLISH,fairValueGapBox(lastTime,currentTime,currentLow,math.avg(currentLow,last2High),fairValueGapBullishColor),fairValueGapBox(lastTime,currentTime,math.avg(currentLow,last2High),last2High,fairValueGapBullishColor)))
    if bearishFairValueGap
        currentAlerts.bearishFairValueGap := true
        fairValueGaps.unshift(fairValueGap.new(currentHigh,last2Low,BEARISH,fairValueGapBox(lastTime,currentTime,currentHigh,math.avg(currentHigh,last2Low),fairValueGapBearishColor),fairValueGapBox(lastTime,currentTime,math.avg(currentHigh,last2Low),last2Low,fairValueGapBearishColor)))

getStyle(string style) =>
    switch style
        SOLID  => line.style_solid
        DASHED => line.style_dashed
        DOTTED => line.style_dotted

drawLevels(string timeframe, bool sameTimeframe, string style, color levelColor) =>
    [topLevel, bottomLevel, leftTime, rightTime] = request.security(syminfo.tickerid, timeframe, [high[1], low[1], time[1], time], lookahead = barmerge.lookahead_on)
    float parsedTop         = sameTimeframe ? high : topLevel
    float parsedBottom      = sameTimeframe ? low : bottomLevel
    int parsedLeftTime      = sameTimeframe ? time : leftTime
    int parsedRightTime     = sameTimeframe ? time : rightTime
    int parsedTopTime       = time
    int parsedBottomTime    = time
    if not sameTimeframe
        int leftIndex               = times.binary_search_rightmost(parsedLeftTime)
        int rightIndex              = times.binary_search_rightmost(parsedRightTime)
        array<int> timeArray        = times.slice(leftIndex,rightIndex)
        array<float> topArray       = highs.slice(leftIndex,rightIndex)
        array<float> bottomArray    = lows.slice(leftIndex,rightIndex)
        parsedTopTime               := timeArray.size() > 0 ? timeArray.get(topArray.indexof(topArray.max())) : initialTime
        parsedBottomTime            := timeArray.size() > 0 ? timeArray.get(bottomArray.indexof(bottomArray.min())) : initialTime
    var line topLine        = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = getStyle(style))
    var line bottomLine     = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = getStyle(style))
    var label topLabel      = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}H',timeframe), color=color(na), textcolor = levelColor, size = size.small, style = label.style_label_left)
    var label bottomLabel   = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}L',timeframe), color=color(na), textcolor = levelColor, size = size.small, style = label.style_label_left)
    topLine.set_first_point(    chart.point.new(parsedTopTime,na,parsedTop))
    topLine.set_second_point(   chart.point.new(last_bar_time + 20 * (time-time[1]),na,parsedTop))
    topLabel.set_point(         chart.point.new(last_bar_time + 20 * (time-time[1]),na,parsedTop))
    bottomLine.set_first_point( chart.point.new(parsedBottomTime,na,parsedBottom))
    bottomLine.set_second_point(chart.point.new(last_bar_time + 20 * (time-time[1]),na,parsedBottom))
    bottomLabel.set_point(      chart.point.new(last_bar_time + 20 * (time-time[1]),na,parsedBottom))

higherTimeframe(string timeframe) => timeframe.in_seconds() > timeframe.in_seconds(timeframe)

updateTrailingExtremes() =>
    trailing.top            := math.max(high,trailing.top)
    trailing.lastTopTime    := trailing.top == high ? time : trailing.lastTopTime
    trailing.bottom         := math.min(low,trailing.bottom)
    trailing.lastBottomTime := trailing.bottom == low ? time : trailing.lastBottomTime

drawHighLowSwings() =>
    var line topLine        = line.new(na, na, na, na, color = swingBearishColor, xloc = xloc.bar_time)
    var line bottomLine     = line.new(na, na, na, na, color = swingBullishColor, xloc = xloc.bar_time)
    var label topLabel      = label.new(na, na, color=color(na), textcolor = swingBearishColor, xloc = xloc.bar_time, style = label.style_label_down, size = size.tiny)
    var label bottomLabel   = label.new(na, na, color=color(na), textcolor = swingBullishColor, xloc = xloc.bar_time, style = label.style_label_up, size = size.tiny)
    rightTimeBar            = last_bar_time + 20 * (time - time[1])
    topLine.set_first_point(    chart.point.new(trailing.lastTopTime, na, trailing.top))
    topLine.set_second_point(   chart.point.new(rightTimeBar, na, trailing.top))
    topLabel.set_point(         chart.point.new(rightTimeBar, na, trailing.top))
    topLabel.set_text(          swingTrend.bias == BEARISH ? 'Strong High' : 'Weak High')
    bottomLine.set_first_point( chart.point.new(trailing.lastBottomTime, na, trailing.bottom))
    bottomLine.set_second_point(chart.point.new(rightTimeBar, na, trailing.bottom))
    bottomLabel.set_point(      chart.point.new(rightTimeBar, na, trailing.bottom))
    bottomLabel.set_text(       swingTrend.bias == BULLISH ? 'Strong Low' : 'Weak Low')

drawZone(float labelLevel, int labelIndex, float top, float bottom, string tag, color zoneColor, string style) =>
    var label l_abel    = label.new(na,na,text = tag, color=color(na),textcolor = zoneColor, style = style, size = size.small)
    var box b_ox        = box.new(na,na,na,na,bgcolor = color.new(zoneColor,80),border_color = color(na), xloc = xloc.bar_time)
    b_ox.set_top_left_point(    chart.point.new(trailing.barTime,na,top))
    b_ox.set_bottom_right_point(chart.point.new(last_bar_time,na,bottom))
    l_abel.set_point(           chart.point.new(na,labelIndex,labelLevel))

drawPremiumDiscountZones() =>
    drawZone(trailing.top, math.round(0.5*(trailing.barIndex + last_bar_index)), trailing.top, 0.95*trailing.top + 0.05*trailing.bottom, 'Premium', premiumZoneColor, label.style_label_down)
    equilibriumLevel = math.avg(trailing.top, trailing.bottom)
    drawZone(equilibriumLevel, last_bar_index, 0.525*trailing.top + 0.475*trailing.bottom, 0.525*trailing.bottom + 0.475*trailing.top, 'Equilibrium', equilibriumZoneColorInput, label.style_label_left)
    drawZone(trailing.bottom, math.round(0.5*(trailing.barIndex + last_bar_index)), 0.95*trailing.bottom + 0.05*trailing.top, trailing.bottom, 'Discount', discountZoneColor, label.style_label_up)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 7 — KALKULASI: SUPPORT & RESISTANCE
//---------------------------------------------------------------------------------------------------------------------{
// Pivot high/low untuk level S&R (dikonversi dari Pine v4 ke v5)
highUsePivot    = fixnan(ta.pivothigh(leftBars, rightBars)[1])
lowUsePivot     = fixnan(ta.pivotlow(leftBars, rightBars)[1])

// Volume oscillator untuk filter break (dikonversi dari Pine v4 ke v5)
srShort         = ta.ema(volume, 5)
srLong          = ta.ema(volume, 10)
srOsc           = 100 * (srShort - srLong) / srLong

// Deteksi break dengan konfirmasi volume
srResistBroken  = ta.crossover(close, highUsePivot) and not (open - low > close - open) and srOsc > volumeThresh
srSupportBroken = ta.crossunder(close, lowUsePivot) and not (open - close < high - open) and srOsc > volumeThresh
srBullWick      = ta.crossover(close, highUsePivot) and (open - low > close - open)
srBearWick      = ta.crossunder(close, lowUsePivot) and (open - close < high - open)

// Set alert SR
currentAlerts.resistanceBroken  := srResistBroken
currentAlerts.supportBroken     := srSupportBroken

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 8 — PLOTTING: SUPPORT & RESISTANCE LEVELS
//---------------------------------------------------------------------------------------------------------------------{
// Plot garis Support & Resistance — warna hilang saat level berubah (sama persis dengan aslinya)
r1 = plot(highUsePivot, color = ta.change(highUsePivot) != 0 ? na : srResistColor, linewidth = 3, offset = -(rightBars + 1), title = 'Resistance')
s1 = plot(lowUsePivot,  color = ta.change(lowUsePivot)  != 0 ? na : srSupportColor, linewidth = 3, offset = -(rightBars + 1), title = 'Support')

// Label break dengan konfirmasi volume
plotshape(toggleBreaks and srSupportBroken, title = 'Support Break',    text = 'B',         style = shape.labeldown, location = location.abovebar, color = color.red,   textcolor = color.white, size = size.tiny)
plotshape(toggleBreaks and srResistBroken,  title = 'Resistance Break', text = 'B',         style = shape.labelup,   location = location.belowbar, color = color.green, textcolor = color.white, size = size.tiny)

// Label wick breaks
plotshape(toggleBreaks and srBullWick,      title = 'Bull Wick Break',  text = 'Bull Wick', style = shape.labelup,   location = location.belowbar, color = color.green, textcolor = color.white, size = size.tiny)
plotshape(toggleBreaks and srBearWick,      title = 'Bear Wick Break',  text = 'Bear Wick', style = shape.labeldown, location = location.abovebar, color = color.red,   textcolor = color.white, size = size.tiny)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 9 — EXECUTION: SMART MONEY CONCEPTS
//---------------------------------------------------------------------------------------------------------------------{
// Warna candle berdasarkan trend SMC (opsional)
parsedOpen  = showTrendInput ? open : na
candleColor = internalTrend.bias == BULLISH ? swingBullishColor : swingBearishColor
plotcandle(parsedOpen, high, low, close, color = candleColor, wickcolor = candleColor, bordercolor = candleColor)

// Update trailing extremes untuk Strong/Weak High-Low dan Premium/Discount Zones
if showHighLowSwingsInput or showPremiumDiscountZonesInput
    updateTrailingExtremes()
    if showHighLowSwingsInput
        drawHighLowSwings()
    if showPremiumDiscountZonesInput
        drawPremiumDiscountZones()

// Hapus FVG yang sudah termitigasi
if showFairValueGapsInput
    deleteFairValueGaps()

// Deteksi struktur swing dan internal
getCurrentStructure(swingsLengthInput, false)
getCurrentStructure(5, false, true)

// Deteksi Equal Highs/Lows
if showEqualHighsLowsInput
    getCurrentStructure(equalHighsLowsLengthInput, true)

// Tampilkan struktur internal (BOS/CHoCH) dan Order Blocks
if showInternalsInput or showInternalOrderBlocksInput or showTrendInput
    displayStructure(true)

// Tampilkan struktur swing dan Order Blocks swing
if showStructureInput or showSwingOrderBlocksInput or showHighLowSwingsInput
    displayStructure()

// Hapus Order Blocks yang sudah termitigasi
if showInternalOrderBlocksInput
    deleteOrderBlocks(true)
if showSwingOrderBlocksInput
    deleteOrderBlocks()

// Gambar Fair Value Gaps baru
if showFairValueGapsInput
    drawFairValueGaps()

// Gambar Order Block boxes di bar terakhir
if barstate.islastconfirmedhistory or barstate.islast
    if showInternalOrderBlocksInput
        drawOrderBlocks(true)
    if showSwingOrderBlocksInput
        drawOrderBlocks()

// Update bar index tracking
lastBarIndex    := currentBarIndex
currentBarIndex := bar_index
newBar          = currentBarIndex != lastBarIndex

// Gambar HTF Levels (Daily/Weekly/Monthly)
if barstate.islastconfirmedhistory or (barstate.isrealtime and newBar)
    if showDailyLevelsInput and not higherTimeframe('D')
        drawLevels('D', timeframe.isdaily,   dailyLevelsStyleInput,   dailyLevelsColorInput)
    if showWeeklyLevelsInput and not higherTimeframe('W')
        drawLevels('W', timeframe.isweekly,  weeklyLevelsStyleInput,  weeklyLevelsColorInput)
    if showMonthlyLevelsInput and not higherTimeframe('M')
        drawLevels('M', timeframe.ismonthly, monthlyLevelsStyleInput, monthlyLevelsColorInput)

//---------------------------------------------------------------------------------------------------------------------}
// SECTION 10 — ALERTS (SMC + S&R)
//---------------------------------------------------------------------------------------------------------------------{
// --- SMC Alerts ---
alertcondition(currentAlerts.internalBullishBOS,        'Internal Bullish BOS',         'Internal Bullish BOS formed')
alertcondition(currentAlerts.internalBullishCHoCH,      'Internal Bullish CHoCH',       'Internal Bullish CHoCH formed')
alertcondition(currentAlerts.internalBearishBOS,        'Internal Bearish BOS',         'Internal Bearish BOS formed')
alertcondition(currentAlerts.internalBearishCHoCH,      'Internal Bearish CHoCH',       'Internal Bearish CHoCH formed')
alertcondition(currentAlerts.swingBullishBOS,           'Bullish BOS',                  'Bullish BOS formed')
alertcondition(currentAlerts.swingBullishCHoCH,         'Bullish CHoCH',                'Bullish CHoCH formed')
alertcondition(currentAlerts.swingBearishBOS,           'Bearish BOS',                  'Bearish BOS formed')
alertcondition(currentAlerts.swingBearishCHoCH,         'Bearish CHoCH',                'Bearish CHoCH formed')
alertcondition(currentAlerts.internalBullishOrderBlock, 'Bullish Internal OB Breakout', 'Price broke bullish internal OB')
alertcondition(currentAlerts.internalBearishOrderBlock, 'Bearish Internal OB Breakout', 'Price broke bearish internal OB')
alertcondition(currentAlerts.swingBullishOrderBlock,    'Bullish Swing OB Breakout',    'Price broke bullish swing OB')
alertcondition(currentAlerts.swingBearishOrderBlock,    'Bearish Swing OB Breakout',    'Price broke bearish swing OB')
alertcondition(currentAlerts.equalHighs,                'Equal Highs',                  'Equal highs detected')
alertcondition(currentAlerts.equalLows,                 'Equal Lows',                   'Equal lows detected')
alertcondition(currentAlerts.bullishFairValueGap,       'Bullish FVG',                  'Bullish FVG formed')
alertcondition(currentAlerts.bearishFairValueGap,       'Bearish FVG',                  'Bearish FVG formed')

// --- S&R Alerts ---
alertcondition(currentAlerts.supportBroken,             'Support Broken',               'Support level broken with volume')
alertcondition(currentAlerts.resistanceBroken,          'Resistance Broken',            'Resistance level broken with volume')

//---------------------------------------------------------------------------------------------------------------------}
````
