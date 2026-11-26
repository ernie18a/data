# Smart Money Flow SMC Liquidity Voids Edition

- url: https://www.tradingview.com/script/j6IjyHB5/
- type: indicator
- pine_id: PUB;c79bf2c7bc17473bbdb37359cc80bc42
- version: 2.0

## Description

This script is based on "Smart Money Concepts [LuxAlgo]" © LuxAlgo
Licensed under CC BY-NC-SA 4.0
Original: https://www.tradingview.com/script/CnB3fSph

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHAT'S NEW IN THIS VERSION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔷 Liquidity Voids Module (new)
Detects price gaps larger than a configurable ATR(144) threshold
and renders each void as 13 stacked gradient sub-boxes.
Each void tracks its own filled/unfilled state — when price trades
through it, the boxes transition to a neutral color or are removed
depending on your preference. Supports Historical and Present modes
with adjustable lookback depth.

🔷 Configurable OB Fill Transparency (new)
A dedicated input decouples the Order Block fill opacity from the
border opacity. This solves the washed-out OB appearance common
on dark themes — you can keep a sharp border while using a subtle
fill, or go fully solid, all without touching the color pickers.

🔷 Pine Script v6 Full Migration (new)
All drawing calls updated to the chart.point.new() API.
UDT fields use explicit types throughout.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ORIGINAL FEATURES (LuxAlgo engine)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Break of Structure (BOS) and Change of Character (CHoCH)
  on both Internal and Swing timeframes
- Internal and Swing Order Blocks with mitigation tracking
- Equal Highs / Equal Lows detection
- Fair Value Gaps with auto threshold
- Strong High / Weak High — Strong Low / Weak Low
- Premium, Equilibrium and Discount Zones
- Multi-timeframe Daily, Weekly and Monthly levels
- Colored candles by trend bias
- Historical and Present display modes
- Monochrome style option

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE — LIQUIDITY VOIDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Liquidity Voids mark areas where price moved so fast that little
to no trading occurred. These zones often act as targets for future
price revisits, similar to Fair Value Gaps but detected via a
gap-based method rather than a three-candle imbalance pattern.

- Threshold: increase to show only large voids, decrease for more.
- Historical mode: scans all bars up to # Bars back.
- Present mode: only tracks voids forming in real time.
- Show Filled Voids: keep filled zones visible (grayed out)
  or remove them completely when price trades through.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// ═══════════════════════════════════════════════════════════════════
// SMC Flow — Liquidity Voids Edition
// ═══════════════════════════════════════════════════════════════════
// Author : Fabricio Nicolau
//
// CREDITS
// ───────────────────────────────────────────────────────────────────
// Core SMC engine (BOS, CHoCH, Order Blocks, FVG, MTF Levels,
// Premium/Discount Zones, Equal Highs/Lows) is based on:
//   "Smart Money Concepts [LuxAlgo]" © LuxAlgo
//   Licensed under CC BY-NC-SA 4.0
//   https://www.tradingview.com/script/CnB3fSph
//
// ADDITIONS BY FABRICIO NICOLAU
// ───────────────────────────────────────────────────────────────────
// 1. Liquidity Voids module — detects price gaps via ATR threshold
//    and renders each void as 13 stacked gradient sub-boxes.
//    Tracks filled/unfilled state per void independently.
//    Supports Historical and Present modes with configurable depth.
// 2. Configurable OB fill transparency (obTranspInput) — decouples
//    fill opacity from border opacity so Order Blocks remain visible
//    on any chart theme without washing out.
// 3. Pine Script v6 full migration — chart.point.new() API throughout,
//    explicit typed UDT fields, cleaned-up varip usage.
// ═══════════════════════════════════════════════════════════════════

//@version=6
indicator(
     title            = 'SMC Flow — Liquidity Voids Edition',
     shorttitle        = 'SMCFlow-LVE',
     overlay           = true,
     max_labels_count  = 500,
     max_lines_count   = 500,
     max_boxes_count   = 500)

// ─────────────────────────────────────────────────────────────────
// CONSTANTS
// ─────────────────────────────────────────────────────────────────
BULLISH_LEG  = 1
BEARISH_LEG  = 0
BULLISH      = +1
BEARISH      = -1

GREEN        = #26c6da
RED          = #e53935
BLUE         = #2157f3
GRAY         = #878b94
MONO_BULLISH = #b2b5be
MONO_BEARISH = #5d606b

HISTORICAL   = 'Historical'
PRESENT      = 'Present'
COLORED      = 'Colored'
MONOCHROME   = 'Monochrome'
ALL          = 'All'
BOS          = 'BOS'
CHOCH        = 'CHoCH'
TINY         = size.tiny
SMALL        = size.small
NORMAL       = size.normal
ATR          = 'Atr'
RANGE        = 'Cumulative Mean Range'
CLOSE        = 'Close'
HIGHLOW      = 'High/Low'
SOLID        = '⎯⎯⎯'
DASHED       = '----'
DOTTED       = '····'

// Input group labels
SMART_GROUP    = 'Smart Money Concepts'
INTERNAL_GROUP = 'Real Time Internal Structure'
SWING_GROUP    = 'Real Time Swing Structure'
BLOCKS_GROUP   = 'Order Blocks'
EQUAL_GROUP    = 'EQH/EQL'
GAPS_GROUP     = 'Fair Value Gaps'
LEVELS_GROUP   = 'Highs & Lows MTF'
ZONES_GROUP    = 'Premium & Discount Zones'
LV_GROUP       = 'Liquidity Voids'

// ─────────────────────────────────────────────────────────────────
// INPUTS — SMC (base: LuxAlgo)
// ─────────────────────────────────────────────────────────────────
modeInput                     = input.string(HISTORICAL, 'Mode',                       group = SMART_GROUP,    options = [HISTORICAL, PRESENT])
styleInput                    = input.string(COLORED,    'Style',                      group = SMART_GROUP,    options = [COLORED, MONOCHROME])
showTrendInput                = input.bool(false,        'Color Candles',              group = SMART_GROUP)

showInternalsInput            = input.bool(true,         'Show Internal Structure',    group = INTERNAL_GROUP)
showInternalBullInput         = input.string(ALL,        'Bullish Structure',          group = INTERNAL_GROUP, inline = 'ibull', options = [ALL, BOS, CHOCH])
internalBullColorInput        = input.color(GREEN,       '',                           group = INTERNAL_GROUP, inline = 'ibull')
showInternalBearInput         = input.string(ALL,        'Bearish Structure',          group = INTERNAL_GROUP, inline = 'ibear', options = [ALL, BOS, CHOCH])
internalBearColorInput        = input.color(RED,         '',                           group = INTERNAL_GROUP, inline = 'ibear')
internalFilterConfluenceInput = input.bool(false,        'Confluence Filter',          group = INTERNAL_GROUP)
internalStructureSize         = input.string(TINY,       'Internal Label Size',        group = INTERNAL_GROUP, options = [TINY, SMALL, NORMAL])

showStructureInput            = input.bool(true,         'Show Swing Structure',       group = SWING_GROUP)
showSwingBullInput            = input.string(ALL,        'Bullish Structure',          group = SWING_GROUP,    inline = 'bull', options = [ALL, BOS, CHOCH])
swingBullColorInput           = input.color(GREEN,       '',                           group = SWING_GROUP,    inline = 'bull')
showSwingBearInput            = input.string(ALL,        'Bearish Structure',          group = SWING_GROUP,    inline = 'bear', options = [ALL, BOS, CHOCH])
swingBearColorInput           = input.color(RED,         '',                           group = SWING_GROUP,    inline = 'bear')
swingStructureSize            = input.string(SMALL,      'Swing Label Size',           group = SWING_GROUP,    options = [TINY, SMALL, NORMAL])
showSwingsInput               = input.bool(false,        'Show Swing Points',          group = SWING_GROUP,    inline = 'swings')
swingsLengthInput             = input.int(50,            '',                           group = SWING_GROUP,    minval = 10, inline = 'swings')
showHighLowSwingsInput        = input.bool(true,         'Show Strong/Weak High/Low',  group = SWING_GROUP)

showInternalOrderBlocksInput  = input.bool(true,         'Internal Order Blocks',      group = BLOCKS_GROUP,   inline = 'iob')
internalOrderBlocksSizeInput  = input.int(3,             '',                           group = BLOCKS_GROUP,   minval = 1, maxval = 20, inline = 'iob')
showSwingOrderBlocksInput     = input.bool(false,        'Swing Order Blocks',         group = BLOCKS_GROUP,   inline = 'ob')
swingOrderBlocksSizeInput     = input.int(3,             '',                           group = BLOCKS_GROUP,   minval = 1, maxval = 20, inline = 'ob')
orderBlockFilterInput         = input.string('Atr',      'Order Block Filter',         group = BLOCKS_GROUP,   options = [ATR, RANGE])
orderBlockMitigationInput     = input.string(HIGHLOW,    'Order Block Mitigation',     group = BLOCKS_GROUP,   options = [CLOSE, HIGHLOW])

// ── Addition (Nicolau): independent fill transparency for OB boxes ──
obTranspInput                 = input.int(85,
     'OB Fill Transparency  (0 = solid · 100 = invisible)',
     group   = BLOCKS_GROUP,
     minval  = 0,
     maxval  = 100,
     tooltip = 'Decouples OB fill opacity from border opacity. Useful to keep blocks visible on dark themes without a washed-out look.')

internalBullishOrderBlockColor = input.color(#26c6da, 'Internal Bullish OB Color', group = BLOCKS_GROUP)
internalBearishOrderBlockColor = input.color(#e53935, 'Internal Bearish OB Color', group = BLOCKS_GROUP)
swingBullishOrderBlockColor    = input.color(#26c6da, 'Swing Bullish OB Color',    group = BLOCKS_GROUP)
swingBearishOrderBlockColor    = input.color(#e53935, 'Swing Bearish OB Color',    group = BLOCKS_GROUP)

showEqualHighsLowsInput       = input.bool(true,    'Equal High/Low',             group = EQUAL_GROUP)
equalHighsLowsLengthInput     = input.int(3,        'Bars Confirmation',          group = EQUAL_GROUP,    minval = 1)
equalHighsLowsThresholdInput  = input.float(0.1,    'Threshold',                  group = EQUAL_GROUP,    minval = 0, maxval = 0.5, step = 0.1)
equalHighsLowsSizeInput       = input.string(TINY,  'Label Size',                 group = EQUAL_GROUP,    options = [TINY, SMALL, NORMAL])

showFairValueGapsInput        = input.bool(false,   'Fair Value Gaps',            group = GAPS_GROUP)
fairValueGapsThresholdInput   = input.bool(true,    'Auto Threshold',             group = GAPS_GROUP)
fairValueGapsTimeframeInput   = input.timeframe('', 'Timeframe',                  group = GAPS_GROUP)
fairValueGapsBullColorInput   = input.color(color.new(#26c6da, 70), 'Bullish FVG', group = GAPS_GROUP)
fairValueGapsBearColorInput   = input.color(color.new(#e53935, 70), 'Bearish FVG', group = GAPS_GROUP)
fairValueGapsExtendInput      = input.int(1,        'Extend FVG',                 group = GAPS_GROUP,     minval = 0)

showDailyLevelsInput          = input.bool(false,   'Daily',                      group = LEVELS_GROUP,   inline = 'daily')
dailyLevelsStyleInput         = input.string(SOLID, '',                           group = LEVELS_GROUP,   inline = 'daily',   options = [SOLID, DASHED, DOTTED])
dailyLevelsColorInput         = input.color(BLUE,   '',                           group = LEVELS_GROUP,   inline = 'daily')
showWeeklyLevelsInput         = input.bool(false,   'Weekly',                     group = LEVELS_GROUP,   inline = 'weekly')
weeklyLevelsStyleInput        = input.string(SOLID, '',                           group = LEVELS_GROUP,   inline = 'weekly',  options = [SOLID, DASHED, DOTTED])
weeklyLevelsColorInput        = input.color(BLUE,   '',                           group = LEVELS_GROUP,   inline = 'weekly')
showMonthlyLevelsInput        = input.bool(false,   'Monthly',                    group = LEVELS_GROUP,   inline = 'monthly')
monthlyLevelsStyleInput       = input.string(SOLID, '',                           group = LEVELS_GROUP,   inline = 'monthly', options = [SOLID, DASHED, DOTTED])
monthlyLevelsColorInput       = input.color(BLUE,   '',                           group = LEVELS_GROUP,   inline = 'monthly')

showPremiumDiscountZonesInput = input.bool(false, 'Premium/Discount Zones',       group = ZONES_GROUP)
premiumZoneColorInput         = input.color(color.new(RED,   80), 'Premium Zone',     group = ZONES_GROUP)
equilibriumZoneColorInput     = input.color(color.new(GRAY,  80), 'Equilibrium Zone', group = ZONES_GROUP)
discountZoneColorInput        = input.color(color.new(GREEN, 80), 'Discount Zone',    group = ZONES_GROUP)

// ─────────────────────────────────────────────────────────────────
// INPUTS — LIQUIDITY VOIDS (Fabricio Nicolau addition)
// ─────────────────────────────────────────────────────────────────
lv_mode = input.string('Historical', 'Mode',
     group = LV_GROUP, options = ['Present', 'Historical'], inline = 'LVMOD')
lv_back = input.int(360, '# Bars',
     group = LV_GROUP, minval = 100, maxval = 5000, step = 10, inline = 'LVMOD',
     tooltip = 'How many bars back to scan for voids (Historical mode only).')
lv_TH   = input.float(.5, 'Liquidity Voids Threshold',
     group = LV_GROUP, minval = 0, step = .1,
     tooltip = 'Minimum gap size as a multiple of ATR(144) to qualify as a Liquidity Void.')
lv_BC   = input.color(color.new(#26c6da, 73), 'Bullish Void', group = LV_GROUP, inline = 'VD')
lv_SC   = input.color(color.new(#e53935, 73), 'Bearish Void', group = LV_GROUP, inline = 'VD')
lv_TX   = input.bool(true,  'Label',            group = LV_GROUP, inline = 'VD')
lv_VF   = input.bool(true,  'Show Filled Voids', group = LV_GROUP, inline = 'FL')
lv_FC   = input.color(color.new(#787b86, 73), '', group = LV_GROUP, inline = 'FL')

// ─────────────────────────────────────────────────────────────────
// DATA STRUCTURES
// ─────────────────────────────────────────────────────────────────
type alerts
    bool internalBullishBOS        = false
    bool internalBearishBOS        = false
    bool internalBullishCHoCH      = false
    bool internalBearishCHoCH      = false
    bool swingBullishBOS           = false
    bool swingBearishBOS           = false
    bool swingBullishCHoCH         = false
    bool swingBearishCHoCH         = false
    bool internalBullishOrderBlock = false
    bool internalBearishOrderBlock = false
    bool swingBullishOrderBlock    = false
    bool swingBearishOrderBlock    = false
    bool equalHighs                = false
    bool equalLows                 = false
    bool bullishFairValueGap       = false
    bool bearishFairValueGap       = false

type trailingExtremes
    float top
    float bottom
    int   barTime
    int   barIndex
    int   lastTopTime
    int   lastBottomTime

type fairValueGap
    float top
    float bottom
    int   bias
    box   topBox
    box   bottomBox

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

type orderBlock
    float barHigh
    float barLow
    int   barTime
    int   bias

// ─────────────────────────────────────────────────────────────────
// STATE VARIABLES
// ─────────────────────────────────────────────────────────────────
var pivot swingHigh               = pivot.new(na, na, false)
var pivot swingLow                = pivot.new(na, na, false)
var pivot internalHigh            = pivot.new(na, na, false)
var pivot internalLow             = pivot.new(na, na, false)
var pivot equalHigh               = pivot.new(na, na, false)
var pivot equalLow                = pivot.new(na, na, false)
var trend swingTrend              = trend.new(0)
var trend internalTrend           = trend.new(0)
var equalDisplay equalHighDisplay = equalDisplay.new()
var equalDisplay equalLowDisplay  = equalDisplay.new()
var array<fairValueGap> fairValueGaps     = array.new<fairValueGap>()
var array<float> parsedHighs      = array.new<float>()
var array<float> parsedLows       = array.new<float>()
var array<float> highs            = array.new<float>()
var array<float> lows             = array.new<float>()
var array<int>   times            = array.new<int>()
var trailingExtremes trailing     = trailingExtremes.new()
var array<orderBlock> swingOrderBlocks    = array.new<orderBlock>()
var array<orderBlock> internalOrderBlocks = array.new<orderBlock>()
var array<box> swingOrderBlocksBoxes      = array.new<box>()
var array<box> internalOrderBlocksBoxes   = array.new<box>()

var swingBullishColor        = styleInput == MONOCHROME ? MONO_BULLISH : swingBullColorInput
var swingBearishColor        = styleInput == MONOCHROME ? MONO_BEARISH : swingBearColorInput
var fairValueGapBullishColor = styleInput == MONOCHROME ? color.new(MONO_BULLISH, 70) : fairValueGapsBullColorInput
var fairValueGapBearishColor = styleInput == MONOCHROME ? color.new(MONO_BEARISH, 70) : fairValueGapsBearColorInput
var premiumZoneColor         = styleInput == MONOCHROME ? MONO_BEARISH : premiumZoneColorInput
var discountZoneColor        = styleInput == MONOCHROME ? MONO_BULLISH : discountZoneColorInput

varip int currentBarIndex = bar_index
varip int lastBarIndex    = bar_index
alerts currentAlerts      = alerts.new()
var initialTime           = time

// Pre-create OB boxes on first bar (Pine v6 best practice)
if barstate.isfirst
    if showSwingOrderBlocksInput
        for index = 1 to swingOrderBlocksSizeInput
            swingOrderBlocksBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right))
    if showInternalOrderBlocksInput
        for index = 1 to internalOrderBlocksSizeInput
            internalOrderBlocksBoxes.push(box.new(na, na, na, na, xloc = xloc.bar_time, extend = extend.right))

// Per-bar calculations
bearishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : high
bullishOrderBlockMitigationSource = orderBlockMitigationInput == CLOSE ? close : low
atrMeasure        = ta.atr(200)
volatilityMeasure = orderBlockFilterInput == ATR ? atrMeasure : ta.cum(ta.tr) / bar_index
highVolatilityBar = (high - low) >= (2 * volatilityMeasure)
parsedHigh        = highVolatilityBar ? low  : high
parsedLow         = highVolatilityBar ? high : low

parsedHighs.push(parsedHigh)
parsedLows.push(parsedLow)
highs.push(high)
lows.push(low)
times.push(time)

// ─────────────────────────────────────────────────────────────────
// DATA STRUCTURES — LIQUIDITY VOIDS (Fabricio Nicolau addition)
// ─────────────────────────────────────────────────────────────────
// Each bar's OHLC snapshotted into a UDT so it can be referenced
// via history operator [n] inside the void detection logic.
type bar
    float h = high
    float l = low
    float c = close
    int   i = bar_index

bar lv_b     = bar.new()
var lv_array = array.new_box()

// ─────────────────────────────────────────────────────────────────
// FUNCTIONS — STRUCTURE (base: LuxAlgo)
// ─────────────────────────────────────────────────────────────────
leg(int size) =>
    var leg    = 0
    newLegHigh = high[size] > ta.highest(size)
    newLegLow  = low[size]  < ta.lowest(size)
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
    l_abel := label.new(chart.point.new(labelTime, na, labelPrice), tag,
         xloc.bar_time, color = color(na), textcolor = labelColor,
         style = labelStyle, size = size.small)

drawEqualHighLow(pivot p_ivot, float level, int size, bool equalHigh_) =>
    equalDisplay e_qualDisplay = equalHigh_ ? equalHighDisplay : equalLowDisplay
    string tag        = 'EQL'
    color  equalColor = swingBullishColor
    string labelStyle = label.style_label_up
    if equalHigh_
        tag        := 'EQH'
        equalColor := swingBearishColor
        labelStyle := label.style_label_down
    if modeInput == PRESENT
        line.delete(e_qualDisplay.l_ine)
        label.delete(e_qualDisplay.l_abel)
    e_qualDisplay.l_ine  := line.new(
         chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel),
         chart.point.new(time[size], na, level),
         xloc = xloc.bar_time, color = equalColor, style = line.style_dotted)
    labelPosition        = math.round(0.5 * (p_ivot.barIndex + bar_index - size))
    e_qualDisplay.l_abel := label.new(
         chart.point.new(na, labelPosition, level), tag,
         xloc.bar_index, color = color(na), textcolor = equalColor,
         style = labelStyle, size = equalHighsLowsSizeInput)

getCurrentStructure(int size, bool equalHighLow = false, bool internal = false) =>
    currentLeg = leg(size)
    newPivot   = startOfNewLeg(currentLeg)
    pivotLow   = startOfBullishLeg(currentLeg)
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
                drawLabel(time[size], p_ivot.currentLevel,
                     p_ivot.currentLevel < p_ivot.lastLevel ? 'LL' : 'HL',
                     swingBullishColor, label.style_label_up)
        else
            pivot p_ivot = equalHighLow ? equalHigh : internal ? internalHigh : swingHigh
            if equalHighLow and math.abs(p_ivot.currentLevel - high[size]) < equalHighsLowsThresholdInput * atrMeasure
                drawEqualHighLow(p_ivot, high[size], size, true)
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
                drawLabel(time[size], p_ivot.currentLevel,
                     p_ivot.currentLevel > p_ivot.lastLevel ? 'HH' : 'LH',
                     swingBearishColor, label.style_label_down)

drawStructure(pivot p_ivot, string tag, color structureColor, string lineStyle, string labelStyle, string labelSize) =>
    var line  l_ine  = line.new(na, na, na, na, xloc = xloc.bar_time)
    var label l_abel = label.new(na, na)
    if modeInput == PRESENT
        l_ine.delete()
        l_abel.delete()
    l_ine  := line.new(
         chart.point.new(p_ivot.barTime, na, p_ivot.currentLevel),
         chart.point.new(time, na, p_ivot.currentLevel),
         xloc.bar_time, color = structureColor, style = lineStyle)
    l_abel := label.new(
         chart.point.new(na, math.round(0.5 * (p_ivot.barIndex + bar_index)), p_ivot.currentLevel),
         tag, xloc.bar_index, color = color(na),
         textcolor = structureColor, style = labelStyle, size = labelSize)

deleteOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    for [index, eachOrderBlock] in orderBlocks
        bool crossedOrderBlock = false
        if bearishOrderBlockMitigationSource > eachOrderBlock.barHigh and eachOrderBlock.bias == BEARISH
            crossedOrderBlock := true
            if internal
                currentAlerts.internalBearishOrderBlock := true
            else
                currentAlerts.swingBearishOrderBlock    := true
        else if bullishOrderBlockMitigationSource < eachOrderBlock.barLow and eachOrderBlock.bias == BULLISH
            crossedOrderBlock := true
            if internal
                currentAlerts.internalBullishOrderBlock := true
            else
                currentAlerts.swingBullishOrderBlock    := true
        if crossedOrderBlock
            orderBlocks.remove(index)

storeOrderBlock(pivot p_ivot, bool internal = false, int bias) =>
    if (not internal and showSwingOrderBlocksInput) or (internal and showInternalOrderBlocksInput)
        array<float> a_rray = na
        int parsedIndex     = na
        if bias == BEARISH
            a_rray      := parsedHighs.slice(p_ivot.barIndex, bar_index)
            parsedIndex := p_ivot.barIndex + a_rray.indexof(a_rray.max())
        else
            a_rray      := parsedLows.slice(p_ivot.barIndex, bar_index)
            parsedIndex := p_ivot.barIndex + a_rray.indexof(a_rray.min())
        orderBlock o_rderBlock        = orderBlock.new(parsedHighs.get(parsedIndex), parsedLows.get(parsedIndex), times.get(parsedIndex), bias)
        array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
        if orderBlocks.size() >= 100
            orderBlocks.pop()
        orderBlocks.unshift(o_rderBlock)

drawOrderBlocks(bool internal = false) =>
    array<orderBlock> orderBlocks = internal ? internalOrderBlocks : swingOrderBlocks
    orderBlocksSize = orderBlocks.size()
    if orderBlocksSize > 0
        maxOrderBlocks                    = internal ? internalOrderBlocksSizeInput : swingOrderBlocksSizeInput
        array<orderBlock> parsedOrderBlocks = orderBlocks.slice(0, math.min(maxOrderBlocks, orderBlocksSize))
        array<box> b_oxes                 = internal ? internalOrderBlocksBoxes : swingOrderBlocksBoxes
        for [index, eachOrderBlock] in parsedOrderBlocks
            // ── Nicolau: obTranspInput decouples fill from border opacity ──
            baseColor   = styleInput == MONOCHROME
                 ? (eachOrderBlock.bias == BEARISH ? MONO_BEARISH : MONO_BULLISH)
                 : internal
                      ? (eachOrderBlock.bias == BEARISH ? internalBearishOrderBlockColor : internalBullishOrderBlockColor)
                      : (eachOrderBlock.bias == BEARISH ? swingBearishOrderBlockColor    : swingBullishOrderBlockColor)
            fillColor   = color.new(baseColor, obTranspInput)
            borderColor = color.new(baseColor, 0)
            box b_ox = b_oxes.get(index)
            b_ox.set_top_left_point(    chart.point.new(eachOrderBlock.barTime, na, eachOrderBlock.barHigh))
            b_ox.set_bottom_right_point(chart.point.new(last_bar_time,          na, eachOrderBlock.barLow))
            b_ox.set_border_color(borderColor)
            b_ox.set_bgcolor(fillColor)

displayStructure(bool internal = false) =>
    var bullishBar = true
    var bearishBar = true
    if internalFilterConfluenceInput
        bullishBar := high - math.max(close, open) > math.min(close, open - low)
        bearishBar := high - math.max(close, open) < math.min(close, open - low)
    pivot p_ivot   = internal ? internalHigh : swingHigh
    trend t_rend   = internal ? internalTrend : swingTrend
    lineStyle      = internal ? line.style_dashed : line.style_solid
    labelSize      = internal ? internalStructureSize : swingStructureSize
    extraCondition = internal ? internalHigh.currentLevel != swingHigh.currentLevel and bullishBar : true
    bullishColor   = styleInput == MONOCHROME ? MONO_BULLISH : internal ? internalBullColorInput : swingBullColorInput
    if ta.crossover(close, p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BEARISH ? CHOCH : BOS
        if internal
            currentAlerts.internalBullishCHoCH := tag == CHOCH
            currentAlerts.internalBullishBOS   := tag == BOS
        else
            currentAlerts.swingBullishCHoCH    := tag == CHOCH
            currentAlerts.swingBullishBOS      := tag == BOS
        p_ivot.crossed := true
        t_rend.bias    := BULLISH
        displayCondition = internal
             ? showInternalsInput and (showInternalBullInput == ALL or (showInternalBullInput == BOS and tag != CHOCH) or (showInternalBullInput == CHOCH and tag == CHOCH))
             : showStructureInput and (showSwingBullInput    == ALL or (showSwingBullInput    == BOS and tag != CHOCH) or (showSwingBullInput    == CHOCH and tag == CHOCH))
        if displayCondition
            drawStructure(p_ivot, tag, bullishColor, lineStyle, label.style_label_down, labelSize)
        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrderBlock(p_ivot, internal, BULLISH)
    p_ivot         := internal ? internalLow : swingLow
    extraCondition := internal ? internalLow.currentLevel != swingLow.currentLevel and bearishBar : true
    bearishColor   = styleInput == MONOCHROME ? MONO_BEARISH : internal ? internalBearColorInput : swingBearColorInput
    if ta.crossunder(close, p_ivot.currentLevel) and not p_ivot.crossed and extraCondition
        string tag = t_rend.bias == BULLISH ? CHOCH : BOS
        if internal
            currentAlerts.internalBearishCHoCH := tag == CHOCH
            currentAlerts.internalBearishBOS   := tag == BOS
        else
            currentAlerts.swingBearishCHoCH    := tag == CHOCH
            currentAlerts.swingBearishBOS      := tag == BOS
        p_ivot.crossed := true
        t_rend.bias    := BEARISH
        displayCondition = internal
             ? showInternalsInput and (showInternalBearInput == ALL or (showInternalBearInput == BOS and tag != CHOCH) or (showInternalBearInput == CHOCH and tag == CHOCH))
             : showStructureInput and (showSwingBearInput    == ALL or (showSwingBearInput    == BOS and tag != CHOCH) or (showSwingBearInput    == CHOCH and tag == CHOCH))
        if displayCondition
            drawStructure(p_ivot, tag, bearishColor, lineStyle, label.style_label_up, labelSize)
        if (internal and showInternalOrderBlocksInput) or (not internal and showSwingOrderBlocksInput)
            storeOrderBlock(p_ivot, internal, BEARISH)

fairValueGapBox(leftTime, rightTime, topPrice, bottomPrice, boxColor, string fvgLabel) =>
    box.new(
         chart.point.new(leftTime, na, topPrice),
         chart.point.new(rightTime + fairValueGapsExtendInput * (time - time[1]), na, bottomPrice),
         xloc = xloc.bar_time, border_color = boxColor, bgcolor = boxColor,
         text = fvgLabel, text_size = size.tiny, text_color = chart.fg_color,
         text_halign = text.align_right, text_valign = text.align_bottom)

deleteFairValueGaps() =>
    for [index, eachFairValueGap] in fairValueGaps
        if (low < eachFairValueGap.bottom and eachFairValueGap.bias == BULLISH) or (high > eachFairValueGap.top and eachFairValueGap.bias == BEARISH)
            eachFairValueGap.topBox.delete()
            eachFairValueGap.bottomBox.delete()
            fairValueGaps.remove(index)

drawFairValueGaps() =>
    [lastClose, lastOpen, lastTime, currentHigh, currentLow, currentTime, last2High, last2Low] = request.security(
         syminfo.tickerid, fairValueGapsTimeframeInput,
         [close[1], open[1], time[1], high[0], low[0], time[0], high[2], low[2]],
         lookahead = barmerge.lookahead_on)
    barDeltaPercent     = (lastClose - lastOpen) / (lastOpen * 100)
    newTimeframe        = timeframe.change(fairValueGapsTimeframeInput)
    threshold           = fairValueGapsThresholdInput ? ta.cum(math.abs(newTimeframe ? barDeltaPercent : 0)) / bar_index * 0.3 : 0
    bullishFairValueGap = currentLow > last2High and lastClose > last2High and barDeltaPercent > threshold and newTimeframe
    bearishFairValueGap = currentHigh < last2Low and lastClose < last2Low and -barDeltaPercent > threshold and newTimeframe
    if bullishFairValueGap
        currentAlerts.bullishFairValueGap := true
        fairValueGaps.unshift(fairValueGap.new(currentLow, last2High, BULLISH,
             fairValueGapBox(lastTime, currentTime, currentLow,    math.avg(currentLow, last2High),  fairValueGapBullishColor, 'FVG'),
             fairValueGapBox(lastTime, currentTime, math.avg(currentLow, last2High), last2High,       fairValueGapBullishColor, '')))
    if bearishFairValueGap
        currentAlerts.bearishFairValueGap := true
        fairValueGaps.unshift(fairValueGap.new(currentHigh, last2Low, BEARISH,
             fairValueGapBox(lastTime, currentTime, currentHigh,   math.avg(currentHigh, last2Low),  fairValueGapBearishColor, 'FVG'),
             fairValueGapBox(lastTime, currentTime, math.avg(currentHigh, last2Low), last2Low,        fairValueGapBearishColor, '')))

getStyle(string style) =>
    switch style
        SOLID  => line.style_solid
        DASHED => line.style_dashed
        DOTTED => line.style_dotted

drawLevels(string timeframe_, bool sameTimeframe, string style, color levelColor) =>
    [topLevel, bottomLevel, leftTime, rightTime] = request.security(
         syminfo.tickerid, timeframe_,
         [high[1], low[1], time[1], time], lookahead = barmerge.lookahead_on)
    float parsedTop      = sameTimeframe ? high : topLevel
    float parsedBottom   = sameTimeframe ? low  : bottomLevel
    int   parsedLeftTime = sameTimeframe ? time : leftTime
    int   parsedRightTime= sameTimeframe ? time : rightTime
    int   parsedTopTime  = time
    int   parsedBotTime  = time
    if not sameTimeframe
        int leftIndex          = times.binary_search_rightmost(parsedLeftTime)
        int rightIndex         = times.binary_search_rightmost(parsedRightTime)
        array<int>   timeArray = times.slice(leftIndex, rightIndex)
        array<float> topArray  = highs.slice(leftIndex, rightIndex)
        array<float> botArray  = lows.slice(leftIndex, rightIndex)
        parsedTopTime := timeArray.size() > 0 ? timeArray.get(topArray.indexof(topArray.max())) : initialTime
        parsedBotTime := timeArray.size() > 0 ? timeArray.get(botArray.indexof(botArray.min())) : initialTime
    int ext = last_bar_time + 20 * (time - time[1])
    var line  topLine  = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = getStyle(style))
    var line  botLine  = line.new(na, na, na, na, xloc = xloc.bar_time, color = levelColor, style = getStyle(style))
    var label topLabel = label.new(na, na, xloc = xloc.bar_time,
         text = str.format('P{0}H', timeframe_), color = color(na),
         textcolor = levelColor, size = size.small, style = label.style_label_left)
    var label botLabel = label.new(na, na, xloc = xloc.bar_time,
         text = str.format('P{0}L', timeframe_), color = color(na),
         textcolor = levelColor, size = size.small, style = label.style_label_left)
    topLine.set_first_point(  chart.point.new(parsedTopTime, na, parsedTop))
    topLine.set_second_point( chart.point.new(ext,           na, parsedTop))
    topLabel.set_point(       chart.point.new(ext,           na, parsedTop))
    botLine.set_first_point(  chart.point.new(parsedBotTime, na, parsedBottom))
    botLine.set_second_point( chart.point.new(ext,           na, parsedBottom))
    botLabel.set_point(       chart.point.new(ext,           na, parsedBottom))

higherTimeframe(string timeframe_) => timeframe.in_seconds() > timeframe.in_seconds(timeframe_)

updateTrailingExtremes() =>
    trailing.top            := math.max(high, trailing.top)
    trailing.lastTopTime    := trailing.top == high ? time : trailing.lastTopTime
    trailing.bottom         := math.min(low, trailing.bottom)
    trailing.lastBottomTime := trailing.bottom == low ? time : trailing.lastBottomTime

drawHighLowSwings() =>
    var line  topLine    = line.new(na, na, na, na, color = swingBearishColor, xloc = xloc.bar_time)
    var line  bottomLine = line.new(na, na, na, na, color = swingBullishColor, xloc = xloc.bar_time)
    var label topLabel   = label.new(na, na, color = color(na), textcolor = swingBearishColor,
         xloc = xloc.bar_time, style = label.style_label_down, size = size.tiny)
    var label botLabel   = label.new(na, na, color = color(na), textcolor = swingBullishColor,
         xloc = xloc.bar_time, style = label.style_label_up,   size = size.tiny)
    rightTimeBar = last_bar_time + 20 * (time - time[1])
    topLine.set_first_point(    chart.point.new(trailing.lastTopTime,    na, trailing.top))
    topLine.set_second_point(   chart.point.new(rightTimeBar,            na, trailing.top))
    topLabel.set_point(         chart.point.new(rightTimeBar,            na, trailing.top))
    topLabel.set_text(swingTrend.bias == BEARISH ? 'Strong High' : 'Weak High')
    bottomLine.set_first_point( chart.point.new(trailing.lastBottomTime, na, trailing.bottom))
    bottomLine.set_second_point(chart.point.new(rightTimeBar,            na, trailing.bottom))
    botLabel.set_point(         chart.point.new(rightTimeBar,            na, trailing.bottom))
    botLabel.set_text(swingTrend.bias == BULLISH ? 'Strong Low' : 'Weak Low')

drawZone(float labelLevel, int labelIndex, float top, float bottom, string tag, color zoneColor, string style) =>
    var label l_abel = label.new(na, na, text = tag, color = color(na),
         textcolor = zoneColor, style = style, size = size.small)
    var box b_ox = box.new(na, na, na, na,
         bgcolor = color.new(zoneColor, 90), border_color = color(na), xloc = xloc.bar_time)
    b_ox.set_top_left_point(    chart.point.new(trailing.barTime, na, top))
    b_ox.set_bottom_right_point(chart.point.new(last_bar_time,   na, bottom))
    l_abel.set_point(           chart.point.new(na, labelIndex, labelLevel))

drawPremiumDiscountZones() =>
    drawZone(trailing.top,
         math.round(0.5 * (trailing.barIndex + last_bar_index)),
         trailing.top, 0.95 * trailing.top + 0.05 * trailing.bottom,
         'Premium', premiumZoneColor, label.style_label_down)
    equilibriumLevel = math.avg(trailing.top, trailing.bottom)
    drawZone(equilibriumLevel, last_bar_index,
         0.525 * trailing.top  + 0.475 * trailing.bottom,
         0.525 * trailing.bottom + 0.475 * trailing.top,
         'Equilibrium', equilibriumZoneColorInput, label.style_label_left)
    drawZone(trailing.bottom,
         math.round(0.5 * (trailing.barIndex + last_bar_index)),
         0.95 * trailing.bottom + 0.05 * trailing.top, trailing.bottom,
         'Discount', discountZoneColor, label.style_label_up)

// ─────────────────────────────────────────────────────────────────
// EXECUTION — SMC (base: LuxAlgo)
// ─────────────────────────────────────────────────────────────────
parsedOpen  = showTrendInput ? open : na
candleColor = internalTrend.bias == BULLISH ? swingBullishColor : swingBearishColor
plotcandle(parsedOpen, high, low, close, color = candleColor, wickcolor = candleColor, bordercolor = candleColor)

if showHighLowSwingsInput or showPremiumDiscountZonesInput
    updateTrailingExtremes()
    if showHighLowSwingsInput
        drawHighLowSwings()
    if showPremiumDiscountZonesInput
        drawPremiumDiscountZones()

if showFairValueGapsInput
    deleteFairValueGaps()

getCurrentStructure(swingsLengthInput, false)
getCurrentStructure(5, false, true)

if showEqualHighsLowsInput
    getCurrentStructure(equalHighsLowsLengthInput, true)

if showInternalsInput or showInternalOrderBlocksInput or showTrendInput
    displayStructure(true)

if showStructureInput or showSwingOrderBlocksInput or showHighLowSwingsInput
    displayStructure()

if showInternalOrderBlocksInput
    deleteOrderBlocks(true)

if showSwingOrderBlocksInput
    deleteOrderBlocks()

if showFairValueGapsInput
    drawFairValueGaps()

if barstate.islastconfirmedhistory or barstate.islast
    if showInternalOrderBlocksInput
        drawOrderBlocks(true)
    if showSwingOrderBlocksInput
        drawOrderBlocks()

lastBarIndex    := currentBarIndex
currentBarIndex := bar_index
newBar          = currentBarIndex != lastBarIndex

if barstate.islastconfirmedhistory or (barstate.isrealtime and newBar)
    if showDailyLevelsInput and not higherTimeframe('D')
        drawLevels('D', timeframe.isdaily,   dailyLevelsStyleInput,   dailyLevelsColorInput)
    if showWeeklyLevelsInput and not higherTimeframe('W')
        drawLevels('W', timeframe.isweekly,  weeklyLevelsStyleInput,  weeklyLevelsColorInput)
    if showMonthlyLevelsInput and not higherTimeframe('M')
        drawLevels('M', timeframe.ismonthly, monthlyLevelsStyleInput, monthlyLevelsColorInput)

// ─────────────────────────────────────────────────────────────────
// EXECUTION — LIQUIDITY VOIDS (Fabricio Nicolau addition)
// ─────────────────────────────────────────────────────────────────
// Void detection: three-bar gap logic filtered by ATR threshold.
// Rendering: 13 stacked sub-boxes per void (gradient visual effect).
// State: each void extends right every bar until price fills it.
// ─────────────────────────────────────────────────────────────────
lv_per = lv_mode == 'Present' ? last_bar_index - lv_b.i <= lv_back : true
lv_atr = ta.atr(144) * lv_TH

if lv_per and bar_index >= 2 and not na(high) and not na(high[1]) and not na(high[2])
    bar lv_b0 = lv_b
    bar lv_b1 = lv_b[1]
    bar lv_b2 = lv_b[2]

    // — Bullish void: gap up between bar[2] high and bar[0] low —
    lv_bull = (lv_b0.l - lv_b2.h) > lv_atr and lv_b0.l > lv_b2.h and lv_b1.c > lv_b2.h
    if lv_bull
        l = 13
        if (lv_b[1]).l - (lv_b[2]).h > lv_atr and (lv_b[1]).l > (lv_b[2]).h and (lv_b[2]).c > (lv_b[3]).h
            st = math.abs(lv_b0.l - lv_b1.l) / l
            for i = 0 to l - 1
                array.push(lv_array, box.new(lv_b0.i - 2, lv_b1.l + (i + 1) * st, lv_b0.i, lv_b1.l + i * st, na, bgcolor = lv_BC))
        else
            st = math.abs(lv_b0.l - lv_b2.h) / l
            for i = 0 to l - 1
                if lv_TX and i == 0
                    array.push(lv_array, box.new(lv_b0.i - 2, lv_b2.h + (i + 1) * st, lv_b0.i, lv_b2.h + i * st, na,
                         text = 'Liquidity Void   ', text_size = size.tiny,
                         text_halign = text.align_right, text_valign = text.align_bottom,
                         text_color = na, bgcolor = lv_BC))
                else
                    array.push(lv_array, box.new(lv_b0.i - 2, lv_b2.h + (i + 1) * st, lv_b0.i, lv_b2.h + i * st, na, bgcolor = lv_BC))

    // — Bearish void: gap down between bar[2] low and bar[0] high —
    lv_bear = (lv_b2.l - lv_b0.h) > lv_atr and lv_b0.h < lv_b2.l and lv_b1.c < lv_b2.l
    if lv_bear
        l = 13
        if (lv_b[1]).l[2] - (lv_b[1]).h > lv_atr and (lv_b[1]).h > (lv_b[1]).l[2] and (lv_b[2]).c < (lv_b[3]).l
            st = math.abs(lv_b1.h - lv_b0.h) / l
            for i = 0 to l - 1
                array.push(lv_array, box.new(lv_b0.i - 2, lv_b0.h + (i + 1) * st, lv_b0.i, lv_b0.h + i * st, na, bgcolor = lv_SC))
        else
            st = math.abs(lv_b2.l - lv_b0.h) / l
            for i = 0 to l - 1
                if lv_TX and i == l - 1
                    array.push(lv_array, box.new(lv_b0.i - 2, lv_b0.h + (i + 1) * st, lv_b0.i, lv_b0.h + i * st, na,
                         text = 'Liquidity Void   ', text_size = size.tiny,
                         text_halign = text.align_right, text_valign = text.align_top,
                         text_color = na, bgcolor = lv_SC))
                else
                    array.push(lv_array, box.new(lv_b0.i - 2, lv_b0.h + (i + 1) * st, lv_b0.i, lv_b0.h + i * st, na, bgcolor = lv_SC))

// Extend active voids right every bar; fill or delete when price trades through
if lv_array.size() > 0
    qt = lv_array.size()
    for bn = qt - 1 to 0
        if bn < lv_array.size()
            cb  = lv_array.get(bn)
            tBX = cb.get_top()
            bBX = cb.get_bottom()
            if lv_b.h > bBX and lv_b.l < tBX
                if lv_VF
                    cb.set_bgcolor(lv_FC)
                else
                    cb.delete()
                lv_array.remove(bn)
            else
                cb.set_right(lv_b.i + 1)
                if lv_b.i - cb.get_left() > 21
                    cb.set_text_color(chart.fg_color)
    if lv_array.size() > 500
        lv_array.shift()

// ─────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────
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
````
