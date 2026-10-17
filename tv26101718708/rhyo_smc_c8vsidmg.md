# Rhyo SMC

- url: https://www.tradingview.com/script/c8VsiDmg-Rhyo-SMC/
- type: indicator
- pine_id: PUB;51667f7081d14b42a6871ba2130c1f58
- version: 3.0

## Description

test. educational purposes only, do not rely on this for everything.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// © LuxAlgo — MSS, and additional modifications
// Merged with LuxAlgo Buyside & Sellside Liquidity

//@version=6
indicator('Rhyo SMC', 'Rhyo SMC', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)
max_bars_back(high, 500)
max_bars_back(low, 500)

//---------------------------------------------------------------------------------------------------------------------}
// CONSTANTS & STRINGS & INPUTS
//---------------------------------------------------------------------------------------------------------------------{
BULLISH_LEG = 1
BEARISH_LEG = 0

BULLISH = +1
BEARISH = -1

GREEN        = #089981
RED          = #F23645
BLUE         = #2157f3
GRAY         = #878b94
MONO_BULLISH = #b2b5be
MONO_BEARISH = #5d606b

HISTORICAL = 'Historical'
PRESENT    = 'Present'

COLORED    = 'Colored'
MONOCHROME = 'Monochrome'

ALL = 'All'
BOS = 'BOS'
MSS = 'MSS'

TINY   = size.tiny
SMALL  = size.small
NORMAL = size.normal

ATR   = 'Atr'
RANGE = 'Cumulative Mean Range'

CLOSE   = 'Close'
HIGHLOW = 'High/Low'

SOLID  = '⎯⎯⎯'
DASHED = '----'
DOTTED = '····'

SMART_GROUP    = 'Smart Money Concepts'
INTERNAL_GROUP = 'Real Time Internal Structure'
SWING_GROUP    = 'Real Time Swing Structure'
EQUAL_GROUP    = 'EQH/EQL'
LEVELS_GROUP   = 'Highs & Lows MTF'
ZONES_GROUP    = 'Premium & Discount Zones'
CISD_GROUP     = 'CISD'
RSID_GROUP     = 'RSI Divergence'
LIQ_GROUP      = 'Liquidity Detection'

modeTooltip                    = 'Allows to display historical Structure or only the recent ones'
styleTooltip                   = 'Indicator color theme'
showTrendTooltip               = 'Display additional candles with a color reflecting the current trend detected by structure'
showInternalsTooltip           = 'Display internal market structure'
internalFilterConfluenceTooltip = 'Filter non significant internal structure breakouts'
showStructureTooltip           = 'Display swing market Structure'
showSwingsTooltip              = 'Display swing point as labels on the chart'
showHighLowSwingsTooltip       = 'Highlight most recent strong and weak high/low points on the chart'
showEqualHighsLowsTooltip      = 'Display equal highs and equal lows on the chart'
equalHighsLowsLengthTooltip    = 'Number of bars used to confirm equal highs and equal lows'
equalHighsLowsThresholdTooltip = 'Sensitivity threshold in a range (0, 1) used for the detection of equal highs & lows\n\nLower values will return fewer but more pertinent results'
showPremiumDiscountZonesTooltip = 'Display premium, discount, and equilibrium zones on chart'

modeInput      = input.string(HISTORICAL, 'Mode',          group = SMART_GROUP, tooltip = modeTooltip,  options = [HISTORICAL, PRESENT])
styleInput     = input.string(COLORED,    'Style',         group = SMART_GROUP, tooltip = styleTooltip, options = [COLORED, MONOCHROME])
showTrendInput = input(false,             'Color Candles', group = SMART_GROUP, tooltip = showTrendTooltip)

showInternalsInput            = input(true,  'Show Internal Structure',  group = INTERNAL_GROUP, tooltip = showInternalsTooltip)
showInternalBullInput         = input.string(ALL, 'Bullish Structure',   group = INTERNAL_GROUP, inline = 'ibull', options = [ALL, BOS, MSS])
internalBullColorInput        = input(GREEN, '',                         group = INTERNAL_GROUP, inline = 'ibull')
showInternalBearInput         = input.string(ALL, 'Bearish Structure',   group = INTERNAL_GROUP, inline = 'ibear', options = [ALL, BOS, MSS])
internalBearColorInput        = input(RED,   '',                         group = INTERNAL_GROUP, inline = 'ibear')
internalFilterConfluenceInput = input(false, 'Confluence Filter',        group = INTERNAL_GROUP, tooltip = internalFilterConfluenceTooltip)
internalStructureSize         = input.string(TINY, 'Internal Label Size',group = INTERNAL_GROUP, options = [TINY, SMALL, NORMAL])

showStructureInput     = input(true,  'Show Swing Structure',       group = SWING_GROUP, tooltip = showStructureTooltip)
showSwingBullInput     = input.string(ALL, 'Bullish Structure',     group = SWING_GROUP, inline = 'bull', options = [ALL, BOS, MSS])
swingBullColorInput    = input(GREEN, '',                           group = SWING_GROUP, inline = 'bull')
showSwingBearInput     = input.string(ALL, 'Bearish Structure',     group = SWING_GROUP, inline = 'bear', options = [ALL, BOS, MSS])
swingBearColorInput    = input(RED,   '',                           group = SWING_GROUP, inline = 'bear')
swingStructureSize     = input.string(SMALL, 'Swing Label Size',    group = SWING_GROUP, options = [TINY, SMALL, NORMAL])
showSwingsInput        = input(false, 'Show Swings Points',         group = SWING_GROUP, tooltip = showSwingsTooltip, inline = 'swings')
swingsLengthInput      = input.int(50, '',                          group = SWING_GROUP, minval = 10, inline = 'swings')
showHighLowSwingsInput = input(true,  'Show Strong/Weak High/Low',  group = SWING_GROUP, tooltip = showHighLowSwingsTooltip)

showEqualHighsLowsInput      = input(true,  'Equal High/Low',        group = EQUAL_GROUP, tooltip = showEqualHighsLowsTooltip)
equalHighsLowsLengthInput    = input.int(3, 'Bars Confirmation',     group = EQUAL_GROUP, tooltip = equalHighsLowsLengthTooltip, minval = 1)
equalHighsLowsThresholdInput = input.float(0.1, 'Threshold',         group = EQUAL_GROUP, tooltip = equalHighsLowsThresholdTooltip, minval = 0, maxval = 0.5, step = 0.1)
equalHighsLowsSizeInput      = input.string(TINY, 'Label Size',      group = EQUAL_GROUP, options = [TINY, SMALL, NORMAL])

showCISDInput      = input(false, 'Show CISD',            group = CISD_GROUP)
cisdBullColorInput = input.color(color.new(#00ff68, 0), 'Bull CISD', inline = 'cbu', group = CISD_GROUP)
cisdBullStr        = input.string('+CISD', ' ',           tooltip = 'Text displayed next to the +CISD level.', inline = 'cbu', group = CISD_GROUP)
cisdBullishAlerts  = input.bool(false, 'Alert?', 'Send an alert when price closes below the current +CISD level.', inline = 'cbu', group = CISD_GROUP)
cisdBearColorInput = input.color(color.new(#ff0008, 0), 'Bear CISD', inline = 'cbe', group = CISD_GROUP)
cisdBearStr        = input.string('-CISD', ' ',           tooltip = 'Text displayed next to the -CISD level.', inline = 'cbe', group = CISD_GROUP)
cisdBearishAlerts  = input.bool(false, 'Alert?', 'Send an alert when price closes above the current -CISD level.', inline = 'cbe', group = CISD_GROUP)
cisdLineWidth      = input.int(1, 'Line Width',            minval = 1, maxval = 5, group = CISD_GROUP)
cisdLookAheadBars  = input.int(5, 'Line Extension Bars',   minval = 1, maxval = 5, group = CISD_GROUP)
cisdStyleOption    = input.string('Solid (─)', 'Line Style', options = ['Solid (─)', 'Dotted (┈)', 'Dashed (╌)'], group = CISD_GROUP)
cisdKeepLevels     = input.bool(false, 'Keep Old CISD Levels', group = CISD_GROUP)
cisdShowTable      = input(false, 'Enable Stat Table',     group = CISD_GROUP)
cisdTablePosition  = input.string('Top Right', 'Table Position', options = ['Top Right', 'Bottom Right', 'Middle Right', 'Bottom Center', 'Middle Left'], group = CISD_GROUP)

showDailyLevelsInput    = input(false, 'Daily',   group = LEVELS_GROUP, inline = 'daily')
dailyLevelsStyleInput   = input.string(SOLID, '', group = LEVELS_GROUP, inline = 'daily',   options = [SOLID, DASHED, DOTTED])
dailyLevelsColorInput   = input(BLUE,  '',        group = LEVELS_GROUP, inline = 'daily')
showDailyOpenInput      = input(false, 'Open',    group = LEVELS_GROUP, inline = 'daily',   tooltip = 'Also draw the previous Daily open price.')
showWeeklyLevelsInput   = input(false, 'Weekly',  group = LEVELS_GROUP, inline = 'weekly')
weeklyLevelsStyleInput  = input.string(SOLID, '', group = LEVELS_GROUP, inline = 'weekly',  options = [SOLID, DASHED, DOTTED])
weeklyLevelsColorInput  = input(BLUE,  '',        group = LEVELS_GROUP, inline = 'weekly')
showWeeklyOpenInput     = input(false, 'Open',    group = LEVELS_GROUP, inline = 'weekly',  tooltip = 'Also draw the previous Weekly open price.')
showMonthlyLevelsInput  = input(false, 'Monthly', group = LEVELS_GROUP, inline = 'monthly')
monthlyLevelsStyleInput = input.string(SOLID, '', group = LEVELS_GROUP, inline = 'monthly', options = [SOLID, DASHED, DOTTED])
monthlyLevelsColorInput = input(BLUE,  '',        group = LEVELS_GROUP, inline = 'monthly')
showMonthlyOpenInput    = input(false, 'Open',    group = LEVELS_GROUP, inline = 'monthly',  tooltip = 'Also draw the previous Monthly open price.')
show4HLevelsInput       = input(false, '4 Hour',  group = LEVELS_GROUP, inline = '4h')
fourHLevelsStyleInput   = input.string(DASHED,'', group = LEVELS_GROUP, inline = '4h',      options = [SOLID, DASHED, DOTTED])
fourHLevelsColorInput   = input(GRAY,  '',        group = LEVELS_GROUP, inline = '4h')
showFourHOpenInput      = input(false, 'Open',    group = LEVELS_GROUP, inline = '4h',      tooltip = 'Also draw the previous 4H open price.')
show1HLevelsInput       = input(false, '1 Hour',  group = LEVELS_GROUP, inline = '1h')
oneHLevelsStyleInput    = input.string(DOTTED,'', group = LEVELS_GROUP, inline = '1h',      options = [SOLID, DASHED, DOTTED])
oneHLevelsColorInput    = input(GRAY,  '',        group = LEVELS_GROUP, inline = '1h')
showOneHOpenInput       = input(false, 'Open',    group = LEVELS_GROUP, inline = '1h',      tooltip = 'Also draw the previous 1H open price.')

showPremiumDiscountZonesInput = input(false, 'Premium/Discount Zones', group = ZONES_GROUP, tooltip = showPremiumDiscountZonesTooltip)
premiumZoneColorInput         = input.color(RED,   'Premium Zone',     group = ZONES_GROUP)
equilibriumZoneColorInput     = input.color(GRAY,  'Equilibrium Zone', group = ZONES_GROUP)
discountZoneColorInput        = input.color(GREEN, 'Discount Zone',    group = ZONES_GROUP)

showRSIDInput       = input(true,  'Show RSI Divergence', group = RSID_GROUP)
rsiLengthInput      = input.int(14, 'RSI Length',          group = RSID_GROUP, minval = 1)
rsiDivLookbackInput = input.int(5,  'Pivot Lookback',      group = RSID_GROUP, minval = 2, tooltip = 'Number of bars on each side used to confirm a price pivot for divergence detection')
rsidBullColorInput  = input.color(color.new(#00ff68, 0), 'Bullish RSID', group = RSID_GROUP)
rsidBearColorInput  = input.color(color.new(#ff0008, 0), 'Bearish RSID', group = RSID_GROUP)
rsidLabelSizeInput  = input.string(TINY, 'RSID Label Size', group = RSID_GROUP, options = [TINY, SMALL, NORMAL])

// LUXALGO LIQUIDITY INPUTS
liqLen = input.int   (7, title = 'Detection Length', minval = 3, maxval = 13, inline = 'LIQ', group = LIQ_GROUP)
liqMar = 10 / input.float (6.9, 'Margin', minval = 4, maxval = 9, step = 0.1, inline = 'LIQ', group = LIQ_GROUP)

liqBuy = input.bool (true, 'Buyside Liquidity Zones, Margin', inline = 'Buyside', group = LIQ_GROUP)
marBuy    = input.float(2.3, '', minval = 1.5, maxval = 10, step = .1, inline = 'Buyside', group = LIQ_GROUP)
cLIQ_B = input.color (color.new(#4caf50,  0), '', inline = 'Buyside', group = LIQ_GROUP)

liqSel = input.bool (true, 'Sellside Liquidity Zones, Margin', inline = 'Sellside', group = LIQ_GROUP)
marSel = input.float(2.3, '', minval = 1.5, maxval = 10, step = .1, inline = 'Sellside', group = LIQ_GROUP)
cLIQ_S = input.color (color.new(#f23645,  0), '', inline = 'Sellside', group = LIQ_GROUP)

lqVoid = input.bool (false, 'Liquidity Voids, Bullish', inline = 'void', group = LIQ_GROUP)
cLQV_B = input.color (color.new(#4caf50,  0), '', inline = 'void', group = LIQ_GROUP)
cLQV_S = input.color (color.new(#f23645,  0), 'Bearish', inline = 'void', group = LIQ_GROUP)
lqText = input.bool (false, 'Label', inline = 'void', group = LIQ_GROUP)

liqMode   = input.string('Present', title = 'Mode', options =['Present', 'Historical'], inline = 'LIQMOD', group = LIQ_GROUP)
visLiq = input.int   (3, '    # Visible Levels', minval = 1, maxval = 50, inline = 'LIQMOD', group = LIQ_GROUP)

//---------------------------------------------------------------------------------------------------------------------}
// RSI DIVERGENCE SERIES — unconditional so Pine allocates the correct buffer
//---------------------------------------------------------------------------------------------------------------------{
_rsidRSI   = ta.rsi(close, rsiLengthInput)
_rsidPHigh = ta.pivothigh(high, rsiDivLookbackInput, rsiDivLookbackInput)
_rsidPLow  = ta.pivotlow(low,  rsiDivLookbackInput, rsiDivLookbackInput)

//---------------------------------------------------------------------------------------------------------------------}
// UDTs
//---------------------------------------------------------------------------------------------------------------------{
type trailingExtremes
    float top
    float bottom
    int   barTime
    int   barIndex
    int   lastTopTime
    int   lastBottomTime

type trend
    int bias

type equalDisplay
    line  l_ine  = na
    label l_abel = na

type pivot
    float currentLevel
    float lastLevel
    bool  crossed
    int   barTime  = time
    int   barIndex = bar_index

type MarketStructure
    float topPrice
    float bottomPrice
    bool  isBullish

type cisdLevel
    line  lvl
    label txt
    bool  completed

// LUXALGO UDTs
type ZZ 
    int   [] d
    int   [] x 
    float [] y 

type liq
    box   bx
    box   bxz
    box   bxt
    bool  brZ
    bool  brL
    line  ln
    line  lne

//---------------------------------------------------------------------------------------------------------------------}
// STATE VARIABLES
//---------------------------------------------------------------------------------------------------------------------{
var pivot swingHigh    = pivot.new(na, na, false)
var pivot swingLow     = pivot.new(na, na, false)
var pivot internalHigh = pivot.new(na, na, false)
var pivot internalLow  = pivot.new(na, na, false)
var pivot equalHigh    = pivot.new(na, na, false)
var pivot equalLow     = pivot.new(na, na, false)
var trend swingTrend    = trend.new(0)
var trend internalTrend = trend.new(0)
var equalDisplay equalHighDisplay = equalDisplay.new()
var equalDisplay equalLowDisplay  = equalDisplay.new()
var array<float> parsedHighs = array.new<float>()
var array<float> parsedLows  = array.new<float>()
var array<float> highs       = array.new<float>()
var array<float> lows        = array.new<float>()
var array<int>   times       = array.new<int>()
var trailingExtremes trailing = trailingExtremes.new()

var swingBullishColor        = styleInput == MONOCHROME ? MONO_BULLISH : swingBullColorInput
var swingBearishColor        = styleInput == MONOCHROME ? MONO_BEARISH : swingBearColorInput
var premiumZoneColor         = styleInput == MONOCHROME ? MONO_BEARISH : premiumZoneColorInput
var discountZoneColor        = styleInput == MONOCHROME ? MONO_BULLISH : discountZoneColorInput

varip int currentBarIndex = bar_index
varip int lastBarIndex    = bar_index
var initialTime = time

var MarketStructure  cisdStructure         = MarketStructure.new(0, 0, false)
var array<cisdLevel> cisdLevelsBu          = array.new<cisdLevel>()
var array<cisdLevel> cisdLevelsBe          = array.new<cisdLevel>()
var bool  cisdIsBullishPullback            = false
var bool  cisdIsBearishPullback            = false
var float cisdPotentialTopPrice            = na
var float cisdPotentialBottomPrice         = na
var int   cisdBullishBreakIndex            = na
var int   cisdBearishBreakIndex            = na
var bool  cisdCurrentState                 = false

// LUXALGO VARIABLES
var maxSize = 50
atr     = ta.atr(10)
atr200  = ta.atr(200)
per     = liqMode == 'Present' ? last_bar_index - bar_index <=  500 : true

var ZZ aZZ = ZZ.new(
 array.new <int>  (maxSize,  0), 
 array.new <int>  (maxSize,  0), 
 array.new <float>(maxSize, na)
 )

var liq[] b_liq_B = array.new<liq> (1, liq.new(box(na), box(na), box(na), false, false, line(na), line(na)))
var liq[] b_liq_S = array.new<liq> (1, liq.new(box(na), box(na), box(na), false, false, line(na), line(na)))

var b_liq_V = array.new_box()

var int dir = na
var int x1 = na
var float y1 = na
var int x2 = na
var float y2 = na

cisdLineStyle = cisdStyleOption == 'Dotted (┈)' ? line.style_dotted :
     cisdStyleOption == 'Dashed (╌)' ? line.style_dashed :
         line.style_solid

atrMeasure        = ta.atr(200)
volatilityMeasure = ATR
highVolatilityBar = high - low >= 2 * atrMeasure
parsedHigh        = highVolatilityBar ? low  : high
parsedLow         = highVolatilityBar ? high : low

parsedHighs.push(parsedHigh)
parsedLows.push(parsedLow)
highs.push(high)
lows.push(low)
times.push(time)

//---------------------------------------------------------------------------------------------------------------------}
// LUXALGO FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------{
method in_out(ZZ aZZ, int _d, int _x, float _y) =>
    array.insert(aZZ.d, 0, _d), array.insert(aZZ.x, 0, _x), array.insert(aZZ.y, 0, _y), aZZ.d.pop(), aZZ.x.pop(), aZZ.y.pop()

max_bars_back(time, 1000)

//---------------------------------------------------------------------------------------------------------------------}
// USER-DEFINED FUNCTIONS
//---------------------------------------------------------------------------------------------------------------------{
leg(int size) =>
    var leg = 0
    newLegHigh = high[size] > ta.highest(high, size)
    newLegLow  = low[size]  < ta.lowest(low, size)
    if newLegHigh
        leg := BEARISH_LEG
    else if newLegLow
        leg := BULLISH_LEG
    leg

startOfNewLeg(int leg)     => ta.change(leg) != 0
startOfBearishLeg(int leg) => ta.change(leg) == -1
startOfBullishLeg(int leg) => ta.change(leg) == +1

drawLabel(int labelTime, float labelPrice, string tag, color labelColor, string labelStyle) =>
    var label l_abel = na
    if modeInput == PRESENT
        l_abel.delete()
    l_abel := label.new(chart.point.new(labelTime, na, labelPrice), tag, xloc.bar_time, color = color(na), textcolor = labelColor, style = labelStyle, size = size.small)
    l_abel

drawEqualHighLow(pivot p_ivot, float level, int size, bool isHigh) =>
    equalDisplay e_qual = isHigh ? equalHighDisplay : equalLowDisplay
    string tag    = isHigh ? 'EQH' : 'EQL'
    color  eqCol  = isHigh ? swingBearishColor : swingBullishColor
    string lStyle = isHigh ? label.style_label_down : label.style_label_up
    if modeInput == PRESENT
        line.delete(e_qual.l_ine)
        label.delete(e_qual.l_abel)
    e_qual.l_ine  := line.new(chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel), chart.point.new(time[size], na, level), xloc = xloc.bar_time, color = eqCol, style = line.style_dotted)
    labelPos       = math.round(0.5 * (p_ivot.barIndex + bar_index - size))
    e_qual.l_abel := label.new(chart.point.new(na, labelPos, level), tag, xloc.bar_index, color = color(na), textcolor = eqCol, style = lStyle, size = equalHighsLowsSizeInput)
    e_qual.l_abel

getCurrentStructure(int size, bool equalHighLow = false, bool internal = false) =>
    currentLeg = leg(size)
    newPivot   = startOfNewLeg(currentLeg)
    pivotLow   = startOfBullishLeg(currentLeg)
    if newPivot
        if pivotLow
            pivot p_ivot = equalHighLow ? equalLow : internal ? internalLow : swingLow
            if equalHighLow and math.abs(p_ivot.currentLevel - low[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot, low[size], size, false)
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
                drawEqualHighLow(p_ivot, high[size], size, true)
            p_ivot.lastLevel    := p_ivot.currentLevel
            p_ivot.currentLevel := high[size]
            p_ivot.crossed      := false
            p_ivot.barTime      := time[size]
            p_ivot.barIndex     := bar_index[size]
            if not equalHighLow and not internal
                trailing.top         := p_ivot.currentLevel
                trailing.barTime     := p_ivot.barTime
                trailing.barIndex    := p_ivot.barIndex
                trailing.lastTopTime := p_ivot.barTime
            if showSwingsInput and not internal and not equalHighLow
                drawLabel(time[size], p_ivot.currentLevel, p_ivot.currentLevel > p_ivot.lastLevel ? 'HH' : 'LH', swingBearishColor, label.style_label_down)

drawStructure(pivot p_ivot, string tag, color structureColor, string lineStyle, string labelStyle, string labelSize) =>
    var line  l_ine  = line.new(na, na, na, na, xloc = xloc.bar_time)
    var label l_abel = label.new(na, na)
    if modeInput == PRESENT
        l_ine.delete()
        l_abel.delete()
    l_ine  := line.new(chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel), chart.point.new(time, na, p_ivot.currentLevel), xloc.bar_time, color = structureColor, style = lineStyle)
    l_abel := label.new(chart.point.new(na, math.round(0.5 * (p_ivot.barIndex + bar_index)), p_ivot.currentLevel), tag, xloc.bar_index, color = color(na), textcolor = structureColor, style = labelStyle, size = labelSize)
    l_abel

getStyle(string style) =>
    switch style
        SOLID  => line.style_solid
        DASHED => line.style_dashed
        DOTTED => line.style_dotted

drawLevels(string tf, bool sameTimeframe, string style, color levelColor, string tfLabel = '', bool showOpen = false) =>
    [topLevel, bottomLevel, openLevel, leftTime, rightTime] = request.security(syminfo.tickerid, tf, [high[1], low[1], open[1], time[1], time], lookahead = barmerge.lookahead_on)
    float parsedTop    = sameTimeframe ? high[1]  : topLevel
    float parsedBottom = sameTimeframe ? low[1]   : bottomLevel
    float parsedOpen   = sameTimeframe ? open[1]  : openLevel
    int   parsedLeft   = sameTimeframe ? time[1]  : leftTime
    int   parsedRight  = sameTimeframe ? time     : rightTime
    int   parsedTopTime    = sameTimeframe ? time[1] : time
    int   parsedBottomTime = sameTimeframe ? time[1] : time

    if not sameTimeframe
        int leftIndex  = times.binary_search_leftmost(parsedLeft)
        int rightIndex = times.binary_search_leftmost(parsedRight)
        array<int>   timeArray   = times.slice(leftIndex, rightIndex)
        array<float> topArray    = highs.slice(leftIndex, rightIndex)
        array<float> bottomArray = lows.slice(leftIndex, rightIndex)
        parsedTopTime    := timeArray.size() > 0 ? timeArray.get(topArray.indexof(topArray.max()))       : initialTime
        parsedBottomTime := timeArray.size() > 0 ? timeArray.get(bottomArray.indexof(bottomArray.min())) : initialTime

    string displayLabel = tfLabel != '' ? tfLabel : tf
    int extendRight     = last_bar_time + 20 * (time - time[1])
    int labelRight      = last_bar_time +  3 * (time - time[1])
    int topTouchTime    = extendRight
    int bottomTouchTime = extendRight
    int openTouchTime   = extendRight
    int touchScanStart  = times.binary_search_leftmost(parsedRight)

    for i = touchScanStart to times.size() - 1 by 1
        if highs.get(i) >= parsedTop
            topTouchTime := times.get(i)
            break

    for i = touchScanStart to times.size() - 1 by 1
        if lows.get(i) <= parsedBottom
            bottomTouchTime := times.get(i)
            break

    int openStartIdx = times.binary_search_rightmost(parsedRight)
    for i = openStartIdx to times.size() - 1 by 1
        if lows.get(i) <= parsedOpen and highs.get(i) >= parsedOpen
            openTouchTime := times.get(i)
            break

    var line  topLine     = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = getStyle(style))
    var line  bottomLine  = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = getStyle(style))
    var label topLabel    = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}H', displayLabel), color = color(na), textcolor = levelColor, size = size.small, style = label.style_label_down)
    var label bottomLabel = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}L', displayLabel), color = color(na), textcolor = levelColor, size = size.small, style = label.style_label_up)

    int topCenterTime    = math.round((parsedTopTime    + topTouchTime)    / 2)
    int bottomCenterTime = math.round((parsedBottomTime + bottomTouchTime) / 2)

    topLine.set_first_point(chart.point.new(parsedTopTime, na, parsedTop))
    topLine.set_second_point(chart.point.new(topTouchTime, na, parsedTop))
    topLabel.set_point(chart.point.new(topCenterTime, na, parsedTop))
    bottomLine.set_first_point(chart.point.new(parsedBottomTime, na, parsedBottom))
    bottomLine.set_second_point(chart.point.new(bottomTouchTime, na, parsedBottom))
    bottomLabel.set_point(chart.point.new(bottomCenterTime, na, parsedBottom))

    if showOpen
        var line  openLine  = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = line.style_dashed)
        var label openLabel = label.new(na, na, xloc = xloc.bar_time, text = str.format('P{0}O', displayLabel), color = color(na), textcolor = levelColor, size = size.small, style = label.style_label_left)
        openLine.set_first_point(chart.point.new(parsedLeft, na, parsedOpen))
        openLine.set_second_point(chart.point.new(openTouchTime, na, parsedOpen))
        openLabel.set_point(chart.point.new(labelRight, na, parsedOpen))

higherTimeframe(string tf) =>
    timeframe.in_seconds() > timeframe.in_seconds(tf)

updateTrailingExtremes() =>
    trailing.top            := na(trailing.top)    ? high : math.max(high, trailing.top)
    trailing.lastTopTime    := trailing.top == high ? time : trailing.lastTopTime
    trailing.bottom         := na(trailing.bottom) ? low  : math.min(low, trailing.bottom)
    trailing.lastBottomTime := trailing.bottom == low ? time : trailing.lastBottomTime

drawHighLowSwings() =>
    var line  topLine     = line.new(na, na, na, na, color = swingBearishColor, xloc = xloc.bar_time)
    var line  bottomLine  = line.new(na, na, na, na, color = swingBullishColor, xloc = xloc.bar_time)
    var label topLabel    = label.new(na, na, color = color(na), textcolor = swingBearishColor, xloc = xloc.bar_time, style = label.style_label_down, size = size.tiny)
    var label bottomLabel = label.new(na, na, color = color(na), textcolor = swingBullishColor, xloc = xloc.bar_time, style = label.style_label_up,   size = size.tiny)
    rightTimeBar = last_bar_time + 20 * (time - time[1])
    topLine.set_first_point(chart.point.new(trailing.lastTopTime, na, trailing.top))
    topLine.set_second_point(chart.point.new(rightTimeBar, na, trailing.top))
    topLabel.set_point(chart.point.new(rightTimeBar, na, trailing.top))
    topLabel.set_text(swingTrend.bias == BEARISH ? 'Strong High' : 'Weak High')
    bottomLine.set_first_point(chart.point.new(trailing.lastBottomTime, na, trailing.bottom))
    bottomLine.set_second_point(chart.point.new(rightTimeBar, na, trailing.bottom))
    bottomLabel.set_point(chart.point.new(rightTimeBar, na, trailing.bottom))
    bottomLabel.set_text(swingTrend.bias == BULLISH ? 'Strong Low' : 'Weak Low')

drawZone(float labelLevel, int labelIndex, float top, float bottom, string tag, color zoneColor, string style) =>
    var label l_abel = label.new(na, na, text = tag, color = color(na), textcolor = zoneColor, style = style, size = size.small)
    var box   b_ox   = box.new(na, na, na, na, bgcolor = color.new(zoneColor, 80), border_color = color(na), xloc = xloc.bar_time)
    b_ox.set_top_left_point(chart.point.new(trailing.barTime, na, top))
    b_ox.set_bottom_right_point(chart.point.new(last_bar_time, na, bottom))
    l_abel.set_point(chart.point.new(na, labelIndex, labelLevel))

drawPremiumDiscountZones() =>
    drawZone(trailing.top, math.round(0.5 * (trailing.barIndex + last_bar_index)), trailing.top, 0.95 * trailing.top + 0.05 * trailing.bottom, 'Premium', premiumZoneColor, label.style_label_down)
    equilibriumLevel = math.avg(trailing.top, trailing.bottom)
    drawZone(equilibriumLevel, last_bar_index, 0.525 * trailing.top + 0.475 * trailing.bottom, 0.525 * trailing.bottom + 0.475 * trailing.top, 'Equilibrium', equilibriumZoneColorInput, label.style_label_left)
    drawZone(trailing.bottom, math.round(0.5 * (trailing.barIndex + last_bar_index)), 0.95 * trailing.bottom + 0.05 * trailing.top, trailing.bottom, 'Discount', discountZoneColor, label.style_label_up)

cisdGetTablePos(string pos) =>
    switch pos
        'Top Right'     => position.top_right
        'Bottom Right'  => position.bottom_right
        'Middle Right'  => position.middle_right
        'Bottom Center' => position.bottom_center
        => position.bottom_left

displayStructure(bool internal = false) =>
    var bullishBar = true
    var bearishBar = true
    if internalFilterConfluenceInput
        bullishBar := high - math.max(close, open) > math.min(close, open) - low
        bearishBar := high - math.max(close, open) < math.min(close, open) - low

    pivot p_ivot   = internal ? internalHigh : swingHigh
    trend t_rend   = internal ? internalTrend : swingTrend
    lineStyle      = internal ? line.style_dashed : line.style_solid
    labelSize      = internal ? internalStructureSize : swingStructureSize
    extraCondition = internal ? internalHigh.currentLevel != swingHigh.currentLevel and bullishBar : true
    bullishColor   = styleInput == MONOCHROME ? MONO_BULLISH : internal ? internalBullColorInput : swingBullColorInput

    if ta.crossover(close, p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BEARISH ? MSS : BOS
        p_ivot.crossed := true
        t_rend.bias    := BULLISH
        displayCondition = internal ?
             showInternalsInput and (showInternalBullInput == ALL or showInternalBullInput == BOS and tag != MSS or showInternalBullInput == MSS and tag == MSS) :
             showStructureInput and (showSwingBullInput   == ALL or showSwingBullInput   == BOS and tag != MSS or showSwingBullInput   == MSS and tag == MSS)
        if displayCondition
            drawStructure(p_ivot, tag, bullishColor, lineStyle, label.style_label_down, labelSize)

    extraCondition := internal ? internalLow.currentLevel != swingLow.currentLevel and bearishBar : true
    bearishColor    = styleInput == MONOCHROME ? MONO_BEARISH : internal ? internalBearColorInput : swingBearColorInput

    if ta.crossunder(close, p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BULLISH ? MSS : BOS
        p_ivot.crossed := true
        t_rend.bias    := BEARISH
        displayCondition = internal ?
             showInternalsInput and (showInternalBearInput == ALL or showInternalBearInput == BOS and tag != MSS or showInternalBearInput == MSS and tag == MSS) :
             showStructureInput and (showSwingBearInput   == ALL or showSwingBearInput   == BOS and tag != MSS or showSwingBearInput   == MSS and tag == MSS)
        if displayCondition
            drawStructure(p_ivot, tag, bearishColor, lineStyle, label.style_label_up, labelSize)

drawRSIDivergence(float rsiVal, float phPrice, float plPrice) =>
    lb = rsiDivLookbackInput
    var float ph1Price = na
    var int   ph1Time  = na
    var int   ph1Bar   = na
    var float ph1RSI   = na
    var float ph2Price = na
    var int   ph2Time  = na
    var int   ph2Bar   = na
    var float ph2RSI   = na
    var float pl1Price = na
    var int   pl1Time  = na
    var int   pl1Bar   = na
    var float pl1RSI   = na
    var float pl2Price = na
    var int   pl2Time  = na
    var int   pl2Bar   = na
    var float pl2RSI   = na

    if not na(phPrice)
        ph2Price := ph1Price
        ph2Time  := ph1Time
        ph2Bar   := ph1Bar
        ph2RSI   := ph1RSI
        ph1Price := phPrice
        ph1Time  := time[lb]
        ph1Bar   := bar_index[lb]
        ph1RSI   := rsiVal[lb]
        if not na(ph2Price) and ph1Price > ph2Price and ph1RSI < ph2RSI
            divColor = styleInput == MONOCHROME ? MONO_BEARISH : rsidBearColorInput
            line.new(chart.point.new(ph2Time, na, ph2Price), chart.point.new(ph1Time, na, ph1Price), xloc = xloc.bar_time, color = divColor, style = line.style_dashed, width = 2)
            label.new(chart.point.new(na, math.round((ph2Bar + ph1Bar) / 2), math.avg(ph2Price, ph1Price)), 'RSID', xloc = xloc.bar_index, color = color(na), textcolor = divColor, style = label.style_label_down, size = rsidLabelSizeInput)

    if not na(plPrice)
        pl2Price := pl1Price
        pl2Time  := pl1Time
        pl2Bar   := pl1Bar
        pl2RSI   := pl1RSI
        pl1Price := plPrice
        pl1Time  := time[lb]
        pl1Bar   := bar_index[lb]
        pl1RSI   := rsiVal[lb]
        if not na(pl2Price) and pl1Price < pl2Price and pl1RSI > pl2RSI
            divColor = styleInput == MONOCHROME ? MONO_BULLISH : rsidBullColorInput
            line.new(chart.point.new(pl2Time, na, pl2Price), chart.point.new(pl1Time, na, pl1Price), xloc = xloc.bar_time, color = divColor, style = line.style_dashed, width = 2)
            label.new(chart.point.new(na, math.round((pl2Bar + pl1Bar) / 2), math.avg(pl2Price, pl1Price)), 'RSID', xloc = xloc.bar_index, color = color(na), textcolor = divColor, style = label.style_label_up, size = rsidLabelSizeInput)

//---------------------------------------------------------------------------------------------------------------------}
// EXECUTION
//---------------------------------------------------------------------------------------------------------------------}
parsedOpen  = showTrendInput ? open : na
candleColor = internalTrend.bias == BULLISH ? swingBullishColor : swingBearishColor
plotcandle(parsedOpen, high, low, close, color = candleColor, wickcolor = candleColor, bordercolor = candleColor)

if showHighLowSwingsInput or showPremiumDiscountZonesInput
    updateTrailingExtremes()
    if showHighLowSwingsInput
        drawHighLowSwings()
    if showPremiumDiscountZonesInput
        drawPremiumDiscountZones()

getCurrentStructure(swingsLengthInput, false)
getCurrentStructure(5, false, true)

if showEqualHighsLowsInput
    getCurrentStructure(equalHighsLowsLengthInput, true)

if showInternalsInput or showTrendInput
    displayStructure(true)

if showStructureInput or showHighLowSwingsInput
    displayStructure()

// ── CISD ──────────────────────────────────────────────────────────────────────
if showCISDInput
    _cisdBearPull = close[1] > open[1]
    _cisdBullPull = close[1] < open[1]

    if _cisdBearPull and not cisdIsBearishPullback
        cisdIsBearishPullback   := true
        cisdPotentialTopPrice   := open[1]
        cisdBullishBreakIndex   := bar_index[1]

    if _cisdBullPull and not cisdIsBullishPullback
        cisdIsBullishPullback    := true
        cisdPotentialBottomPrice := open[1]
        cisdBearishBreakIndex    := bar_index[1]

    if cisdIsBullishPullback
        if open < cisdPotentialBottomPrice
            cisdPotentialBottomPrice := open
            cisdBearishBreakIndex    := bar_index
        if close < open and open > cisdPotentialBottomPrice
            cisdPotentialBottomPrice := open
            cisdBearishBreakIndex    := bar_index

    if cisdIsBearishPullback
        if open > cisdPotentialTopPrice
            cisdPotentialTopPrice  := open
            cisdBullishBreakIndex  := bar_index
        if close > open and open < cisdPotentialTopPrice
            cisdPotentialTopPrice  := open
            cisdBullishBreakIndex  := bar_index

    if low < cisdStructure.bottomPrice
        cisdStructure.bottomPrice := low
        cisdStructure.isBullish   := false
        _drawBull = false
        if cisdIsBearishPullback and bar_index - cisdBullishBreakIndex != 0
            _offset = bar_index - cisdBullishBreakIndex
            cisdStructure.topPrice := math.max(high[_offset], high[math.max(_offset - 1, 0)])
            cisdIsBearishPullback  := false
            _drawBull              := true
        else if close[1] > open[1] and close < open
            cisdStructure.topPrice := high[1]
            cisdIsBearishPullback  := false
            _drawBull              := true
        if _drawBull
            _ln  = line.new(cisdBullishBreakIndex, cisdPotentialTopPrice, bar_index + cisdLookAheadBars, cisdPotentialTopPrice, color = cisdBullColorInput, width = cisdLineWidth, style = cisdLineStyle)
            _lbl = label.new(bar_index + cisdLookAheadBars, cisdPotentialTopPrice, cisdBullStr, color = color.new(color.white, 100), textcolor = cisdBullColorInput, style = label.style_label_left, text_font_family = font.family_default, size = size.small, text_formatting = text.format_italic)
            cisdLevelsBe.push(cisdLevel.new(_ln, _lbl, false))

    if high > cisdStructure.topPrice
        cisdStructure.isBullish := true
        cisdStructure.topPrice  := high
        _drawBear = false
        if cisdIsBullishPullback and bar_index - cisdBearishBreakIndex != 0
            _offset = bar_index - cisdBearishBreakIndex
            cisdStructure.bottomPrice := math.min(low[_offset], low[math.max(_offset - 1, 0)])
            cisdIsBullishPullback     := false
            _drawBear                 := true
        else if close[1] < open[1] and close > open
            cisdStructure.bottomPrice := low[1]
            cisdIsBullishPullback     := false
            _drawBear                 := true
        if _drawBear
            _ln  = line.new(cisdBearishBreakIndex, cisdPotentialBottomPrice, bar_index + cisdLookAheadBars, cisdPotentialBottomPrice, color = cisdBearColorInput, width = cisdLineWidth, style = cisdLineStyle)
            _lbl = label.new(bar_index + cisdLookAheadBars, cisdPotentialBottomPrice, cisdBearStr, color = color.new(color.white, 100), textcolor = cisdBearColorInput, style = label.style_label_left, text_font_family = font.family_default, size = size.small, text_formatting = text.format_italic)
            cisdLevelsBu.push(cisdLevel.new(_ln, _lbl, false))

    if cisdLevelsBu.size() > 1 and not cisdKeepLevels
        _old = cisdLevelsBu.get(0)
        array.remove(cisdLevelsBu, 0)
        _old.lvl.delete()
        _old.txt.delete()

    if cisdLevelsBe.size() > 1 and not cisdKeepLevels
        _old = cisdLevelsBe.get(0)
        array.remove(cisdLevelsBe, 0)
        _old.lvl.delete()
        _old.txt.delete()

    if cisdLevelsBu.size() >= 1
        _latest = cisdLevelsBu.get(0)
        if not _latest.completed
            if close >= _latest.lvl.get_y2()
                _latest.lvl.set_x2(bar_index + cisdLookAheadBars)
                _latest.txt.set_x(bar_index + cisdLookAheadBars)
            else
                _latest.completed := true
                if cisdBullishAlerts
                    alert('Bearish CISD: price closed below +CISD level', alert.freq_once_per_bar_close)
                _ln  = line.new(cisdBullishBreakIndex, cisdPotentialTopPrice, bar_index + cisdLookAheadBars, cisdPotentialTopPrice, color = cisdBullColorInput, width = cisdLineWidth, style = cisdLineStyle)
                _lbl = label.new(bar_index + cisdLookAheadBars, cisdPotentialTopPrice, cisdBullStr, color = color.new(color.white, 100), textcolor = cisdBullColorInput, style = label.style_label_left, text_font_family = font.family_monospace, size = size.small, text_formatting = text.format_italic)
                cisdLevelsBe.push(cisdLevel.new(_ln, _lbl, false))
                cisdCurrentState := false

    if cisdLevelsBe.size() >= 1
        _latest = cisdLevelsBe.get(0)
        if not _latest.completed
            if close <= _latest.lvl.get_y2()
                _latest.lvl.set_x2(bar_index + cisdLookAheadBars)
                _latest.txt.set_x(bar_index + cisdLookAheadBars)
            else
                _latest.completed := true
                if cisdBearishAlerts
                    alert('Bullish CISD: price closed above -CISD level', alert.freq_once_per_bar_close)
                _ln  = line.new(cisdBearishBreakIndex, cisdPotentialBottomPrice, bar_index + cisdLookAheadBars, cisdPotentialBottomPrice, color = cisdBearColorInput, width = cisdLineWidth, style = cisdLineStyle)
                _lbl = label.new(bar_index + cisdLookAheadBars, cisdPotentialBottomPrice, cisdBearStr, color = color.new(color.white, 100), textcolor = cisdBearColorInput, style = label.style_label_left, text_font_family = font.family_monospace, size = size.small, text_formatting = text.format_italic)
                cisdLevelsBu.push(cisdLevel.new(_ln, _lbl, false))
                cisdCurrentState := true

    if cisdShowTable and barstate.islast
        var table _tbl = table.new(cisdGetTablePos(cisdTablePosition), 4, 4, bgcolor = chart.bg_color, border_color = chart.fg_color, frame_color = chart.fg_color, frame_width = 1, border_width = 1)
        table.cell(_tbl, 0, 0, syminfo.ticker + ', ' + timeframe.period, text_size = size.tiny, text_color = chart.fg_color, text_font_family = font.family_monospace)
        table.cell(_tbl, 0, 1, 'Current State', text_color = chart.bg_color, text_size = size.small, text_font_family = font.family_monospace, text_formatting = text.format_bold, bgcolor = chart.fg_color)
        table.cell(_tbl, 0, 2, cisdCurrentState ? 'Bullish' : 'Bearish', text_color = chart.fg_color, text_size = size.small, text_font_family = font.family_monospace, text_formatting = text.format_bold)

// ── RSI Divergence ────────────────────────────────────────────────────────────
if showRSIDInput
    drawRSIDivergence(_rsidRSI, _rsidPHigh, _rsidPLow)

// ── MTF Levels ────────────────────────────────────────────────────────────────
lastBarIndex  := currentBarIndex
currentBarIndex := bar_index

if barstate.islastconfirmedhistory or barstate.islast
    if showDailyLevelsInput and not higherTimeframe('D')
        drawLevels('D', timeframe.isdaily, dailyLevelsStyleInput, dailyLevelsColorInput, '', showDailyOpenInput)
    if showWeeklyLevelsInput and not higherTimeframe('W')
        drawLevels('W', timeframe.isweekly, weeklyLevelsStyleInput, weeklyLevelsColorInput, '', showWeeklyOpenInput)
    if showMonthlyLevelsInput and not higherTimeframe('M')
        drawLevels('M', timeframe.ismonthly, monthlyLevelsStyleInput, monthlyLevelsColorInput, '', showMonthlyOpenInput)
    if show4HLevelsInput and not higherTimeframe('240')
        drawLevels('240', timeframe.in_seconds() == timeframe.in_seconds('240'), fourHLevelsStyleInput, fourHLevelsColorInput, '4H', showFourHOpenInput)
    if show1HLevelsInput and not higherTimeframe('60')
        drawLevels('60', timeframe.in_seconds() == timeframe.in_seconds('60'), oneHLevelsStyleInput, oneHLevelsColorInput, '1H', showOneHOpenInput)

//---------------------------------------------------------------------------------------------------------------------}
// LUXALGO LIQUIDITY CALCULATIONS
//---------------------------------------------------------------------------------------------------------------------}
x2 := bar_index - 1
ph  = ta.pivothigh(liqLen, 1)
pl  = ta.pivotlow (liqLen, 1)

if not na(ph)   
    dir := aZZ.d.get(0) 
    x1  := aZZ.x.get(0) 
    y1  := aZZ.y.get(0) 
    y2  := nz(high[1])

    if dir < 1
        aZZ.in_out(1, x2, y2)
    else
        if dir == 1 and ph > y1 
            aZZ.x.set(0, x2), aZZ.y.set(0, y2)
    
    if per
        count = 0
        st_P  = 0.
        st_B  = 0
        minP  = 0.
        maxP  = 10e6

        for i = 0 to maxSize - 1
            if aZZ.d.get(i) ==  1 
                if aZZ.y.get(i) > ph + (atr / liqMar)
                    break
                else
                    if aZZ.y.get(i) > ph - (atr / liqMar) and aZZ.y.get(i) < ph + (atr / liqMar)
                        count += 1
                        st_B := aZZ.x.get(i)
                        st_P := aZZ.y.get(i)
                        if aZZ.y.get(i) > minP
                            minP := aZZ.y.get(i)
                        if aZZ.y.get(i) < maxP 
                            maxP := aZZ.y.get(i)

        if count > 2
            getB = b_liq_B.get(0)

            if st_B == getB.bx.get_left()
                getB.bx.set_top(math.avg(minP, maxP) + (atr / liqMar))
                getB.bx.set_rightbottom(bar_index + 10, math.avg(minP, maxP) - (atr / liqMar))
            else
                array.insert(b_liq_B, 0,
                 liq.new(
                   box.new(st_B, math.avg(minP, maxP) + (atr / liqMar), bar_index + 10, math.avg(minP, maxP) - (atr / liqMar), bgcolor=color(na), border_color=color(na)), 
                   box.new(na, na, na, na, bgcolor = color(na), border_color = color(na)),
                   box.new(st_B, st_P, bar_index + 10, st_P, text = 'Buyside liquidity', text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom, text_color = color.new(cLIQ_B, 25), bgcolor = color(na), border_color = color(na)),
                   false, 
                   false,
                   line.new(st_B   , st_P, bar_index - 1, st_P, color = color.new(cLIQ_B, 0)),
                   line.new(bar_index - 1, st_P, na     , st_P, color = color.new(cLIQ_B, 0), style = line.style_dotted))
                 )

                alert('buyside liquidity level detected/updated for ' + syminfo.ticker)

            if b_liq_B.size() > visLiq
                getLast = b_liq_B.pop()
                getLast.bx.delete()
                getLast.bxz.delete()
                getLast.bxt.delete()
                getLast.ln.delete()
                getLast.lne.delete()               

if not na(pl)
    dir := aZZ.d.get (0) 
    x1  := aZZ.x.get (0) 
    y1  := aZZ.y.get (0) 
    y2  := nz(low[1])
    
    if dir > -1
        aZZ.in_out(-1, x2, y2)
    else
        if dir == -1 and pl < y1 
            aZZ.x.set(0, x2), aZZ.y.set(0, y2)
    
    if per
        count = 0
        st_P  = 0.
        st_B  = 0
        minP  = 0.
        maxP  = 10e6

        for i = 0 to maxSize - 1
            if aZZ.d.get(i) == -1 
                if aZZ.y.get(i) < pl - (atr / liqMar)
                    break
                else
                    if aZZ.y.get(i) > pl - (atr / liqMar) and aZZ.y.get(i) < pl + (atr / liqMar)
                        count += 1
                        st_B := aZZ.x.get(i)
                        st_P := aZZ.y.get(i)
                        if aZZ.y.get(i) > minP
                            minP := aZZ.y.get(i)
                        if aZZ.y.get(i) < maxP 
                            maxP := aZZ.y.get(i)

        if count > 2
            getB = b_liq_S.get(0)

            if st_B == getB.bx.get_left()
                getB.bx.set_top(math.avg(minP, maxP) + (atr / liqMar))
                getB.bx.set_rightbottom(bar_index + 10, math.avg(minP, maxP) - (atr / liqMar))
            else
                array.insert(b_liq_S, 0,
                 liq.new(
                   box.new(st_B, math.avg(minP, maxP) + (atr / liqMar), bar_index + 10, math.avg(minP, maxP) - (atr / liqMar), bgcolor=color(na), border_color=color(na)),
                   box.new(na, na, na, na, bgcolor=color(na), border_color=color(na)),
                   box.new(st_B, st_P, bar_index + 10, st_P, text = 'Sellside liquidity', text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top, text_color = color.new(cLIQ_S, 25), bgcolor=color(na), border_color=color(na)),
                   false,
                   false,
                   line.new(st_B   , st_P, bar_index - 1, st_P, color = color.new(cLIQ_S, 0)),
                   line.new(bar_index - 1, st_P, na     , st_P, color = color.new(cLIQ_S, 0), style = line.style_dotted))
                 )  

                alert('sellside liquidity level detected/updated for ' + syminfo.ticker)

            if b_liq_S.size() > visLiq
                getLast = b_liq_S.pop()
                getLast.bx.delete()
                getLast.bxz.delete()
                getLast.bxt.delete()
                getLast.ln.delete()            
                getLast.lne.delete()               


for i = 0 to b_liq_B.size() - 1
    x = b_liq_B.get(i)
    
    if not x.brL
        x.lne.set_x2(bar_index)

        if high > x.bx.get_top()
            x.brL := true
            x.brZ := true
            alert('buyside liquidity level breached for ' + syminfo.ticker)

            x.bxz.set_lefttop(bar_index - 1, math.min(x.ln.get_y1() + marBuy * (atr), high))
            x.bxz.set_rightbottom(bar_index + 1, x.ln.get_y1())
            x.bxz.set_bgcolor(color.new(cLIQ_B, liqBuy ? 73 : 100))

    else if x.brZ
        if low > x.ln.get_y1() - marBuy * (atr) and high < x.ln.get_y1() + marBuy * (atr)
            x.bxz.set_right(bar_index + 1)
            x.bxz.set_top(math.max(high, x.bxz.get_top()))
            if liqBuy
                x.lne.set_x2(bar_index + 1)
        else
            x.brZ := false

for i = 0 to b_liq_S.size() - 1
    x = b_liq_S.get(i)

    if not x.brL
        x.lne.set_x2(bar_index)

        if low < x.bx.get_bottom()
            x.brL := true
            x.brZ := true
            alert('sellside liquidity level breached for ' + syminfo.ticker)

            x.bxz.set_lefttop(bar_index - 1, x.ln.get_y1())
            x.bxz.set_rightbottom(bar_index + 1, math.max(x.ln.get_y1() - marSel * (atr), low))
            x.bxz.set_bgcolor(color.new(cLIQ_S, liqSel ? 73 : 100))

    else if x.brZ
        if low > x.ln.get_y1() - marSel * (atr) and high < x.ln.get_y1() + marSel * (atr)
            x.bxz.set_rightbottom(bar_index + 1, math.min(low, x.bxz.get_bottom()))
            if liqSel
                x.lne.set_x2(bar_index + 1)
        else
            x.brZ := false

if lqVoid and per
    bull = low - high[2] > atr200 and low > high[2] and close[1] > high[2]
    bear = low[2] - high > atr200 and high < low[2] and close[1] < low[2]

    if bull 
        l  = 13
        if bull[1] 
            st = math.abs(low - low[1]) / l
            for i = 0 to l - 1
                array.push(b_liq_V, box.new(bar_index - 2, low[1] + i * st, bar_index, low[1] + (i + 1) * st, border_color = na, bgcolor = color.new(cLQV_B, 90) ))
        else   
            st = math.abs(low - high[2]) / l
            for i = 0 to l - 1
                if lqText and i == 0
                    array.push(b_liq_V, box.new(bar_index - 2, high[2] + i * st, bar_index, high[2] + (i + 1) * st, text = 'Liquidity Void   ', text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_bottom, text_color = na, border_color = na, bgcolor = color.new(cLQV_B, 90) ))
                else
                    array.push(b_liq_V, box.new(bar_index - 2, high[2] + i * st, bar_index, high[2] + (i + 1) * st, border_color = na, bgcolor = color.new(cLQV_B, 90) ))

    if bear
        l  = 13
        if bear[1]
            st = math.abs(high[1] - high) / l
            for i = 0 to l - 1
                array.push(b_liq_V, box.new(bar_index - 2, high + i * st, bar_index, high + (i + 1) * st, border_color = na, bgcolor = color.new(cLQV_S, 90) ))
        else
            st = math.abs(low[2] - high) / l
            for i = 0 to l - 1
                if lqText and i == l - 1
                    array.push(b_liq_V, box.new(bar_index - 2, high + i * st, bar_index, high + (i + 1) * st, text = 'Liquidity Void   ', text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_top, text_color = na, border_color = na, bgcolor = color.new(cLQV_S, 90) ))
                else
                    array.push(b_liq_V, box.new(bar_index - 2, high + i * st, bar_index, high + (i + 1) * st, border_color = na, bgcolor = color.new(cLQV_S, 90) ))

if b_liq_V.size() > 0
    qt = b_liq_V.size()
    for bn = qt - 1 to 0
        if bn < b_liq_V.size()
            cb = b_liq_V.get(bn)
            ba = math.avg(cb.get_bottom(), cb.get_top())

            if math.sign(close[1] - ba) != math.sign(close - ba) or math.sign(close[1] - ba) != math.sign(low - ba) or math.sign(close[1] - ba) != math.sign(high - ba)
                array.remove(b_liq_V, bn)
            else
                cb.set_right(bar_index + 1)

                if bar_index - cb.get_left() > 21
                    cb.set_text_color(color.new(color.gray, 25))
````
